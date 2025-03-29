<template>
  <div class="admin-bookings">
    <div class="page-header">
      <h2>Quản lý đặt lịch</h2>
      <div class="header-actions">
        <el-select v-model="statusFilter" placeholder="Lọc theo trạng thái" style="width: 150px">
          <el-option label="Tất cả" value="all" />
          <el-option label="Chờ xác nhận" value="pending" />
          <el-option label="Đã xác nhận" value="confirmed" />
          <el-option label="Đã thanh toán" value="paid" />
        </el-select>
      </div>
    </div>

    <el-table :data="filteredBookings" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="Mã lịch" width="100"></el-table-column>
      
      <el-table-column prop="name" label="Khách hàng" width="150"></el-table-column>
      
      <el-table-column prop="phone" label="Số điện thoại" width="120"></el-table-column>
      
      <el-table-column label="Ngày giờ" width="180">
        <template #default="scope">
          {{ formatDate(scope.row.date) }} {{ scope.row.time }}
        </template>
      </el-table-column>
      
      <el-table-column prop="staffName" label="Thợ cắt" width="150"></el-table-column>
      
      <el-table-column label="Dịch vụ">
        <template #default="scope">
          <el-tag 
            v-for="service in scope.row.services" 
            :key="service.id"
            class="service-tag"
            style="margin-right: 5px"
          >
            {{ service.name }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column prop="totalPrice" label="Tổng tiền" width="150">
        <template #default="scope">
          {{ formatPrice(scope.row.totalPrice) }}
        </template>
      </el-table-column>
      
      <el-table-column prop="status" label="Trạng thái" width="120">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="Thao tác" width="300">
        <template #default="scope">
          <el-button 
            v-if="scope.row.status === 'pending'"
            type="success" 
            size="small" 
            @click="handleConfirm(scope.row)"
          >
            Xác nhận
          </el-button>
          <el-button 
            v-if="scope.row.status === 'confirmed'"
            type="primary" 
            size="small" 
            @click="showPaymentDialog(scope.row)"
          >
            Thanh toán
          </el-button>
          <el-button 
            v-if="scope.row.status === 'pending'"
            type="warning" 
            size="small" 
            @click="showEditDialog(scope.row)"
          >
            Sửa
          </el-button>
          <el-button 
            v-if="scope.row.status === 'pending'"
            type="danger" 
            size="small" 
            @click="handleCancel(scope.row)"
          >
            Hủy
          </el-button>
          <el-button 
            type="info" 
            size="small" 
            @click="showDetails(scope.row)"
          >
            Chi tiết
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog thanh toán -->
    <el-dialog
      v-model="paymentDialogVisible"
      title="Thanh toán hóa đơn"
      width="500px"
    >
      <div v-if="selectedBooking" class="payment-details">
        <div class="detail-row">
          <span class="label">Mã lịch:</span>
          <span class="value">{{ selectedBooking.id }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Khách hàng:</span>
          <span class="value">{{ selectedBooking.name }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Ngày giờ:</span>
          <span class="value">{{ formatDate(selectedBooking.date) }} {{ selectedBooking.time }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Thợ cắt:</span>
          <span class="value">{{ selectedBooking.staffName }}</span>
        </div>
        <div class="services-list">
          <div class="label">Dịch vụ:</div>
          <div v-for="service in selectedBooking.services" :key="service.id" class="service-item">
            <span>{{ service.name }}</span>
            <span>{{ formatPrice(service.price) }}</span>
          </div>
        </div>
        <div class="total-row">
          <span class="label">Tổng tiền:</span>
          <span class="value total">{{ formatPrice(selectedBooking.totalPrice) }}</span>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="paymentDialogVisible = false">Hủy</el-button>
          <el-button type="success" @click="handlePayment">Xác nhận thanh toán</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Dialog chi tiết -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="Chi tiết lịch hẹn"
      width="500px"
    >
      <div v-if="selectedBooking" class="booking-details">
        <div class="detail-row">
          <span class="label">Mã lịch:</span>
          <span class="value">{{ selectedBooking.id }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Khách hàng:</span>
          <span class="value">{{ selectedBooking.name }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Số điện thoại:</span>
          <span class="value">{{ selectedBooking.phone }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Ngày giờ:</span>
          <span class="value">{{ formatDate(selectedBooking.date) }} {{ selectedBooking.time }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Thợ cắt:</span>
          <span class="value">{{ selectedBooking.staffName }}</span>
        </div>
        <div class="services-list">
          <div class="label">Dịch vụ:</div>
          <div v-for="service in selectedBooking.services" :key="service.id" class="service-item">
            <span>{{ service.name }}</span>
            <span>{{ formatPrice(service.price) }}</span>
          </div>
        </div>
        <div class="detail-row">
          <span class="label">Ghi chú:</span>
          <span class="value">{{ selectedBooking.notes || 'Không có' }}</span>
        </div>
        <div class="total-row">
          <span class="label">Tổng tiền:</span>
          <span class="value total">{{ formatPrice(selectedBooking.totalPrice) }}</span>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailsDialogVisible = false">Đóng</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- Dialog sửa lịch -->
    <el-dialog
      v-model="editDialogVisible"
      title="Sửa lịch hẹn"
      width="500px"
    >
      <el-form 
        v-if="selectedBooking"
        :model="editForm"
        label-width="120px"
      >
        <el-form-item label="Khách hàng">
          <el-input v-model="editForm.name" disabled></el-input>
        </el-form-item>

        <el-form-item label="Số điện thoại">
          <el-input v-model="editForm.phone" disabled></el-input>
        </el-form-item>

        <el-form-item label="Ngày hẹn">
          <el-date-picker
            v-model="editForm.date"
            type="date"
            placeholder="Chọn ngày"
            :disabled-date="disabledDate"
            format="DD/MM/YYYY"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>

        <el-form-item label="Giờ hẹn">
          <el-select v-model="editForm.time" placeholder="Chọn giờ">
            <el-option
              v-for="time in availableTimes"
              :key="time"
              :label="time"
              :value="time"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="Thợ cắt">
          <el-select v-model="editForm.staffId" placeholder="Chọn thợ cắt">
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

        <el-form-item label="Dịch vụ">
          <el-select 
            v-model="editForm.services" 
            multiple 
            placeholder="Chọn dịch vụ"
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

        <el-form-item label="Ghi chú">
          <el-input
            v-model="editForm.notes"
            type="textarea"
            placeholder="Nhập ghi chú (nếu có)"
          />
        </el-form-item>

        <el-form-item label="Tổng tiền">
          <span class="total-price">{{ formatPrice(editFormTotalPrice) }}</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="handleSaveEdit">Lưu thay đổi</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const bookings = ref([])
const services = ref([])
const staff = ref([])
const statusFilter = ref('all')
const paymentDialogVisible = ref(false)
const detailsDialogVisible = ref(false)
const editDialogVisible = ref(false)
const selectedBooking = ref(null)
const editForm = ref({
  name: '',
  phone: '',
  date: '',
  time: '',
  staffId: '',
  services: [],
  notes: '',
  totalPrice: 0
})

// Tính tổng tiền cho form sửa
const editFormTotalPrice = computed(() => {
  if (!editForm.value.services) return 0
  return editForm.value.services.reduce((total, serviceId) => {
    const service = services.value.find(s => s.id === serviceId)
    return total + (service ? service.price : 0)
  }, 0)
})

// Lấy danh sách giờ có thể đặt
const availableTimes = computed(() => {
  const times = []
  for (let i = 9; i <= 20; i++) {
    times.push(`${i}:00`)
  }
  return times
})

// Lấy danh sách thợ có thể chọn
const availableStaff = computed(() => {
  if (!editForm.value.date || !editForm.value.time) return []
  
  // Lấy danh sách lịch hẹn hiện tại
  const bookings = JSON.parse(localStorage.getItem('bookings') || '[]')
  
  // Lọc thợ đã có lịch vào thời điểm này
  const busyStaffIds = bookings
    .filter(booking => 
      booking.date === editForm.value.date && 
      booking.time === editForm.value.time &&
      booking.status !== 'cancelled' &&
      booking.id !== selectedBooking.value?.id // Loại trừ lịch đang sửa
    )
    .map(booking => booking.staffId)
  
  return staff.value.filter(s => 
    s.status === 'active' && 
    s.specialties && 
    !busyStaffIds.includes(s.id) &&
    editForm.value.services.every(serviceId => 
      s.specialties.includes(serviceId)
    )
  )
})

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

// Kiểm tra ngày không được chọn trong quá khứ
const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7
}

// Hiển thị dialog sửa
const showEditDialog = (booking) => {
  selectedBooking.value = booking
  editForm.value = {
    ...booking,
    services: booking.services.map(s => s.id)
  }
  editDialogVisible.value = true
}

// Xử lý lưu thay đổi
const handleSaveEdit = () => {
  if (!selectedBooking.value) return

  const index = bookings.value.findIndex(b => b.id === selectedBooking.value.id)
  if (index > -1) {
    // Lấy thông tin thợ và dịch vụ được chọn
    const selectedStaff = staff.value.find(s => s.id === editForm.value.staffId)
    const selectedServices = editForm.value.services.map(serviceId => 
      services.value.find(s => s.id === serviceId)
    )

    // Cập nhật thông tin lịch hẹn
    bookings.value[index] = {
      ...bookings.value[index],
      date: editForm.value.date,
      time: editForm.value.time,
      staffId: editForm.value.staffId,
      staffName: selectedStaff.name,
      services: selectedServices.map(s => ({
        id: s.id,
        name: s.name,
        price: s.price
      })),
      notes: editForm.value.notes,
      totalPrice: editFormTotalPrice.value
    }

    localStorage.setItem('bookings', JSON.stringify(bookings.value))
    ElMessage.success('Đã cập nhật lịch hẹn!')
    editDialogVisible.value = false
  }
}

// Lọc lịch hẹn theo trạng thái
const filteredBookings = computed(() => {
  if (statusFilter.value === 'all') return bookings.value
  return bookings.value.filter(booking => booking.status === statusFilter.value)
})

// Format ngày tháng
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN')
}

// Format giá tiền
const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

// Lấy loại tag cho trạng thái
const getStatusType = (status) => {
  switch (status) {
    case 'pending': return 'warning'
    case 'confirmed': return 'primary'
    case 'paid': return 'success'
    default: return 'info'
  }
}

// Lấy text cho trạng thái
const getStatusText = (status) => {
  switch (status) {
    case 'pending': return 'Chờ xác nhận'
    case 'confirmed': return 'Đã xác nhận'
    case 'paid': return 'Đã thanh toán'
    default: return status
  }
}

// Hiển thị dialog thanh toán
const showPaymentDialog = (booking) => {
  selectedBooking.value = booking
  paymentDialogVisible.value = true
}

// Hiển thị dialog chi tiết
const showDetails = (booking) => {
  selectedBooking.value = booking
  detailsDialogVisible.value = true
}

// Xử lý xác nhận lịch
const handleConfirm = (booking) => {
  ElMessageBox.confirm(
    'Xác nhận lịch hẹn này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    const index = bookings.value.findIndex(b => b.id === booking.id)
    if (index > -1) {
      bookings.value[index].status = 'confirmed'
      localStorage.setItem('bookings', JSON.stringify(bookings.value))
      ElMessage.success('Đã xác nhận lịch hẹn!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}

// Xử lý thanh toán
const handlePayment = () => {
  if (!selectedBooking.value) return
  
  const index = bookings.value.findIndex(b => b.id === selectedBooking.value.id)
  if (index > -1) {
    bookings.value[index].status = 'paid'
    localStorage.setItem('bookings', JSON.stringify(bookings.value))
    ElMessage.success('Đã thanh toán thành công!')
    paymentDialogVisible.value = false
  }
}

// Xử lý hủy lịch
const handleCancel = (booking) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn hủy lịch hẹn này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    const index = bookings.value.findIndex(b => b.id === booking.id)
    if (index > -1) {
      bookings.value[index].status = 'cancelled'
      localStorage.setItem('bookings', JSON.stringify(bookings.value))
      ElMessage.success('Đã hủy lịch hẹn!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}

onMounted(() => {
  loading.value = true
  // Load danh sách lịch hẹn, dịch vụ và thợ
  bookings.value = JSON.parse(localStorage.getItem('bookings') || '[]')
  services.value = JSON.parse(localStorage.getItem('services') || '[]')
  staff.value = JSON.parse(localStorage.getItem('staff') || '[]')
  loading.value = false
})
</script>

<style scoped>
.admin-bookings {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #333;
}

.service-tag {
  margin-bottom: 5px;
}

.payment-details,
.booking-details {
  padding: 20px;
}

.detail-row {
  display: flex;
  margin-bottom: 15px;
}

.label {
  font-weight: bold;
  width: 120px;
  color: #606266;
}

.value {
  flex: 1;
}

.services-list {
  margin: 20px 0;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 4px;
}

.service-item {
  display: flex;
  justify-content: space-between;
  margin: 10px 0;
  padding: 5px 0;
  border-bottom: 1px solid #ebeef5;
}

.service-item:last-child {
  border-bottom: none;
}

.total-row {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px solid #ebeef5;
}

.total {
  font-size: 1.2em;
  font-weight: bold;
  color: #409EFF;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 