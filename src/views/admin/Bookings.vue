<template>
  <div class="bookings">
    <div class="header">
      <h2>Quản lý đặt lịch</h2>
      <div class="stats">
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Lịch hôm nay</span>
              <el-icon><Calendar /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ todayBookings }}</div>
        </el-card>
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Đang chờ xác nhận</span>
              <el-icon><Clock /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ pendingBookings }}</div>
        </el-card>
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Đã xác nhận</span>
              <el-icon><CircleCheck /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ confirmedBookings }}</div>
        </el-card>
      </div>
    </div>

    <el-table :data="bookings" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="customerName" label="Khách hàng" width="150" />
      <el-table-column prop="phone" label="Số điện thoại" width="120" />
      <el-table-column prop="date" label="Ngày" width="120">
        <template #default="{ row }">
          {{ formatDate(row.date) }}
        </template>
      </el-table-column>
      <el-table-column prop="time" label="Giờ" width="100" />
      <el-table-column prop="serviceId" label="Dịch vụ" width="150">
        <template #default="{ row }">
          {{ getServiceName(row.serviceId) }}
        </template>
      </el-table-column>
      <el-table-column prop="staffId" label="Thợ" width="150">
        <template #default="{ row }">
          {{ getStaffName(row.staffId) }}
        </template>
      </el-table-column>
      <el-table-column prop="status" label="Trạng thái" width="120">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="Thao tác" width="200">
        <template #default="{ row }">
          <el-button-group>
            <el-button type="primary" size="small" @click="viewBooking(row)">
              Chi tiết
            </el-button>
            <el-button 
              v-if="row.status === 'pending'"
              type="success" 
              size="small" 
              @click="confirmBooking(row)"
            >
              Xác nhận
            </el-button>
            <el-button 
              v-if="row.status === 'pending'"
              type="danger" 
              size="small" 
              @click="cancelBooking(row)"
            >
              Hủy
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog xem chi tiết -->
    <el-dialog
      v-model="dialogVisible"
      title="Chi tiết đặt lịch"
      width="50%"
    >
      <div v-if="selectedBooking" class="booking-details">
        <p><strong>ID:</strong> {{ selectedBooking.id }}</p>
        <p><strong>Khách hàng:</strong> {{ selectedBooking.customerName }}</p>
        <p><strong>Số điện thoại:</strong> {{ selectedBooking.phone }}</p>
        <p><strong>Ngày:</strong> {{ formatDate(selectedBooking.date) }}</p>
        <p><strong>Giờ:</strong> {{ selectedBooking.time }}</p>
        <p><strong>Dịch vụ:</strong> {{ getServiceName(selectedBooking.serviceId) }}</p>
        <p><strong>Thợ:</strong> {{ getStaffName(selectedBooking.staffId) }}</p>
        <p><strong>Trạng thái:</strong> 
          <el-tag :type="getStatusType(selectedBooking.status)">
            {{ getStatusText(selectedBooking.status) }}
          </el-tag>
        </p>
        <p><strong>Ghi chú:</strong> {{ selectedBooking.notes || 'Không có' }}</p>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Calendar,
  Clock,
  CircleCheck
} from '@element-plus/icons-vue'

const loading = ref(false)
const bookings = ref([])
const dialogVisible = ref(false)
const selectedBooking = ref(null)

onMounted(() => {
  // Thêm dữ liệu mẫu nếu chưa có
  if (!localStorage.getItem('bookings')) {
    const sampleBookings = [
      {
        id: '1',
        customerName: 'Nguyễn Văn A',
        phone: '0123456789',
        date: new Date().toISOString().split('T')[0],
        time: '10:00',
        serviceId: '1',
        staffId: '1',
        status: 'pending',
        notes: 'Cắt tóc nam'
      },
      {
        id: '2',
        customerName: 'Trần Thị B',
        phone: '0987654321',
        date: new Date().toISOString().split('T')[0],
        time: '14:00',
        serviceId: '2',
        staffId: '2',
        status: 'confirmed',
        notes: 'Nhuộm tóc'
      }
    ]
    localStorage.setItem('bookings', JSON.stringify(sampleBookings))
  }

  // Thêm dữ liệu mẫu cho services nếu chưa có
  if (!localStorage.getItem('services')) {
    const sampleServices = [
      {
        id: '1',
        name: 'Cắt tóc nam',
        description: 'Cắt tóc nam các kiểu',
        price: 100000,
        duration: 30
      },
      {
        id: '2',
        name: 'Nhuộm tóc',
        description: 'Nhuộm tóc các màu',
        price: 500000,
        duration: 120
      }
    ]
    localStorage.setItem('services', JSON.stringify(sampleServices))
  }

  // Thêm dữ liệu mẫu cho staff nếu chưa có
  if (!localStorage.getItem('staff')) {
    const sampleStaff = [
      {
        id: '1',
        name: 'Thợ A',
        phone: '0123456789',
        email: 'thoa@example.com',
        specialty: 'Cắt tóc nam',
        status: 'active'
      },
      {
        id: '2',
        name: 'Thợ B',
        phone: '0987654321',
        email: 'thob@example.com',
        specialty: 'Nhuộm tóc',
        status: 'active'
      }
    ]
    localStorage.setItem('staff', JSON.stringify(sampleStaff))
  }

  loadBookings()
})

const loadBookings = () => {
  loading.value = true
  // Giả lập API call
  setTimeout(() => {
    bookings.value = JSON.parse(localStorage.getItem('bookings') || '[]')
    loading.value = false
  }, 500)
}

const todayBookings = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return bookings.value.filter(booking => booking.date === today).length
})

const pendingBookings = computed(() => {
  return bookings.value.filter(booking => booking.status === 'pending').length
})

const confirmedBookings = computed(() => {
  return bookings.value.filter(booking => booking.status === 'confirmed').length
})

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN')
}

const getServiceName = (serviceId) => {
  const services = JSON.parse(localStorage.getItem('services') || '[]')
  const service = services.find(s => s.id === serviceId)
  return service ? service.name : 'Không xác định'
}

const getStaffName = (staffId) => {
  const staff = JSON.parse(localStorage.getItem('staff') || '[]')
  const barber = staff.find(s => s.id === staffId)
  return barber ? barber.name : 'Không xác định'
}

const getStatusType = (status) => {
  switch (status) {
    case 'pending':
      return 'warning'
    case 'confirmed':
      return 'success'
    case 'cancelled':
      return 'danger'
    default:
      return 'info'
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 'pending':
      return 'Chờ xác nhận'
    case 'confirmed':
      return 'Đã xác nhận'
    case 'cancelled':
      return 'Đã hủy'
    default:
      return 'Không xác định'
  }
}

const viewBooking = (booking) => {
  selectedBooking.value = booking
  dialogVisible.value = true
}

const confirmBooking = async (booking) => {
  try {
    await ElMessageBox.confirm(
      'Bạn có chắc muốn xác nhận lịch hẹn này?',
      'Xác nhận',
      {
        confirmButtonText: 'Đồng ý',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const updatedBookings = bookings.value.map(b => {
      if (b.id === booking.id) {
        return { ...b, status: 'confirmed' }
      }
      return b
    })

    localStorage.setItem('bookings', JSON.stringify(updatedBookings))
    bookings.value = updatedBookings
    ElMessage.success('Đã xác nhận lịch hẹn!')
  } catch {
    // User cancelled
  }
}

const cancelBooking = async (booking) => {
  try {
    await ElMessageBox.confirm(
      'Bạn có chắc muốn hủy lịch hẹn này?',
      'Xác nhận',
      {
        confirmButtonText: 'Đồng ý',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const updatedBookings = bookings.value.map(b => {
      if (b.id === booking.id) {
        return { ...b, status: 'cancelled' }
      }
      return b
    })

    localStorage.setItem('bookings', JSON.stringify(updatedBookings))
    bookings.value = updatedBookings
    ElMessage.success('Đã hủy lịch hẹn!')
  } catch {
    // User cancelled
  }
}
</script>

<style scoped>
.bookings {
  padding: 20px;
}

.header {
  margin-bottom: 20px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.stat-card {
  text-align: center;
}

.stat-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
}

.booking-details {
  margin-bottom: 20px;
}

.booking-details p {
  margin: 10px 0;
}

.booking-details strong {
  display: inline-block;
  width: 120px;
}
</style> 