<template>
  <div class="booking">
    <h1>Đặt lịch cắt tóc</h1>
    <el-form
      ref="formRef"
      :model="bookingForm"
      :rules="rules"
      label-width="120px"
      class="booking-form"
    >
      <el-form-item label="Họ và tên" prop="name">
        <el-input v-model="bookingForm.name" placeholder="Nhập họ và tên" />
      </el-form-item>

      <el-form-item label="Số điện thoại" prop="phone">
        <el-input v-model="bookingForm.phone" placeholder="Nhập số điện thoại" />
      </el-form-item>

      <el-form-item label="Ngày hẹn" prop="date">
        <el-date-picker
          v-model="bookingForm.date"
          type="date"
          placeholder="Chọn ngày"
          :disabled-date="disabledDate"
          format="DD/MM/YYYY"
          value-format="YYYY-MM-DD"
        />
      </el-form-item>

      <el-form-item label="Giờ hẹn" prop="time">
        <el-select v-model="bookingForm.time" placeholder="Chọn giờ">
          <el-option
            v-for="time in availableTimes"
            :key="time"
            :label="time"
            :value="time"
          />
        </el-select>
      </el-form-item>

      <el-form-item label="Dịch vụ" prop="services">
        <el-select 
          v-model="bookingForm.services" 
          placeholder="Chọn dịch vụ"
          multiple
          collapse-tags
        >
          <el-option
            v-for="service in services"
            :key="service.id"
            :label="service.name"
            :value="service.id"
          >
            <span>{{ service.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px">
              {{ formatPrice(service.price) }}
            </span>
          </el-option>
        </el-select>
      </el-form-item>

      <el-form-item label="Thợ cắt" prop="staffId">
        <el-select v-model="bookingForm.staffId" placeholder="Chọn thợ cắt">
          <el-option
            v-for="staff in availableStaff"
            :key="staff.id"
            :label="staff.name"
            :value="staff.id"
          >
            <span>{{ staff.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 13px">
              {{ getStaffSpecialties(staff) }}
            </span>
          </el-option>
        </el-select>
      </el-form-item>

      <el-form-item label="Tổng tiền">
        <span class="total-price">{{ formatPrice(totalPrice) }}</span>
      </el-form-item>

      <el-form-item label="Ghi chú" prop="notes">
        <el-input
          v-model="bookingForm.notes"
          type="textarea"
          placeholder="Nhập ghi chú (nếu có)"
        />
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="submitForm">Đặt lịch</el-button>
        <el-button @click="resetForm">Làm mới</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'

const router = useRouter()
const formRef = ref(null)
const staff = ref([])
const services = ref([])

const bookingForm = ref({
  name: '',
  phone: '',
  date: '',
  time: '',
  staffId: '',
  services: [],
  notes: '',
  status: 'pending'
})

const rules = {
  name: [
    { required: true, message: 'Vui lòng nhập họ và tên', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: 'Vui lòng nhập số điện thoại', trigger: 'blur' },
    { pattern: /^[0-9]{10}$/, message: 'Số điện thoại không hợp lệ', trigger: 'blur' }
  ],
  date: [
    { required: true, message: 'Vui lòng chọn ngày hẹn', trigger: 'change' }
  ],
  time: [
    { required: true, message: 'Vui lòng chọn giờ hẹn', trigger: 'change' }
  ],
  staffId: [
    { required: true, message: 'Vui lòng chọn thợ cắt', trigger: 'change' }
  ],
  services: [
    { required: true, message: 'Vui lòng chọn ít nhất một dịch vụ', trigger: 'change' }
  ]
}

// Tính tổng tiền
const totalPrice = computed(() => {
  if (!bookingForm.value.services) return 0
  return bookingForm.value.services.reduce((total, serviceId) => {
    const service = services.value.find(s => s.id === serviceId)
    return total + (service ? service.price : 0)
  }, 0)
})

// Lấy danh sách thợ đang làm việc và có chuyên môn phù hợp
const availableStaff = computed(() => {
  if (!bookingForm.value.services || !bookingForm.value.date || !bookingForm.value.time) return []
  
  // Lấy danh sách lịch hẹn hiện tại
  const bookings = JSON.parse(localStorage.getItem('bookings') || '[]')
  
  // Lọc thợ đã có lịch vào thời điểm này
  const busyStaffIds = bookings
    .filter(booking => 
      booking.date === bookingForm.value.date && 
      booking.time === bookingForm.value.time &&
      booking.status !== 'cancelled'
    )
    .map(booking => booking.staffId)
  
  return staff.value.filter(s => 
    s.status === 'active' && 
    s.specialties && 
    !busyStaffIds.includes(s.id) &&
    bookingForm.value.services.every(serviceId => 
      s.specialties.includes(serviceId)
    )
  )
})

// Lấy danh sách giờ có thể đặt
const availableTimes = computed(() => {
  const times = []
  for (let i = 9; i <= 20; i++) {
    times.push(`${i}:00`)
  }
  return times
})

// Kiểm tra ngày không được chọn trong quá khứ
const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7 // 8.64e7 là số mili giây trong 1 ngày
}

// Lấy danh sách chuyên môn của thợ
const getStaffSpecialties = (staff) => {
  if (!staff.specialties) return ''
  return staff.specialties
    .map(id => {
      const service = services.value.find(s => s.id === id)
      return service ? service.name : ''
    })
    .filter(Boolean)
    .join(', ')
}

// Format giá tiền
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

onMounted(() => {
  // Load danh sách thợ và dịch vụ
  staff.value = JSON.parse(localStorage.getItem('staff') || '[]')
  services.value = JSON.parse(localStorage.getItem('services') || '[]')
})

const submitForm = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate((valid) => {
    if (valid) {
      // Tạo mã lịch hẹn
      const bookingId = Date.now().toString()
      
      // Lấy thông tin thợ và dịch vụ được chọn
      const selectedStaff = staff.value.find(s => s.id === bookingForm.value.staffId)
      const selectedServices = bookingForm.value.services.map(serviceId => 
        services.value.find(s => s.id === serviceId)
      )
      
      // Tạo đối tượng lịch hẹn mới
      const newBooking = {
        id: bookingId,
        ...bookingForm.value,
        staffName: selectedStaff.name,
        staffSpecialties: getStaffSpecialties(selectedStaff),
        services: selectedServices.map(s => ({
          id: s.id,
          name: s.name,
          price: s.price
        })),
        totalPrice: totalPrice.value,
        status: 'pending'
      }
      
      // Lấy danh sách lịch hẹn hiện tại
      const bookings = JSON.parse(localStorage.getItem('bookings') || '[]')
      
      // Thêm lịch hẹn mới
      bookings.push(newBooking)
      
      // Lưu vào localStorage
      localStorage.setItem('bookings', JSON.stringify(bookings))
      
      ElMessage.success('Đặt lịch thành công!')
      resetForm()
      router.push('/bookings')
    }
  })
}

const resetForm = () => {
  if (formRef.value) {
    formRef.value.resetFields()
  }
}
</script>

<style scoped>
.booking {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 20px;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.header h2 {
  font-size: 2rem;
  color: #303133;
  margin-bottom: 10px;
}

.header p {
  color: #606266;
  font-size: 1.1rem;
}

.booking-form {
  background: white;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.form-section {
  margin-bottom: 30px;
}

.form-section h3 {
  font-size: 1.2rem;
  color: #303133;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #409EFF;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.form-item {
  margin-bottom: 20px;
}

.form-item label {
  display: block;
  margin-bottom: 8px;
  color: #606266;
  font-weight: 500;
}

.el-input-number {
  width: 100%;
}

.el-select {
  width: 100%;
}

.notes {
  margin-top: 20px;
}

.submit-section {
  text-align: center;
  margin-top: 40px;
}

.submit-button {
  padding: 12px 40px;
  font-size: 1.1rem;
}

.total-price {
  font-size: 1.2rem;
  font-weight: bold;
  color: #409EFF;
}

@media (max-width: 768px) {
  .booking {
    padding: 20px 10px;
  }

  .booking-form {
    padding: 20px;
  }

  .form-row {
    grid-template-columns: 1fr;
  }
}
</style> 