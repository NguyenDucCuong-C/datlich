<template>
  <div class="bookings">
    <h2>Lịch hẹn của tôi</h2>
    
    <div v-if="bookings.length === 0" class="empty-bookings">
      <el-empty description="Chưa có lịch hẹn nào">
        <el-button type="primary" @click="$router.push('/booking')">Đặt lịch ngay</el-button>
      </el-empty>
    </div>

    <div v-else>
      <el-table :data="bookings" style="width: 100%">
        <el-table-column prop="name" label="Họ và tên"></el-table-column>
        <el-table-column prop="phone" label="Số điện thoại"></el-table-column>
        <el-table-column label="Ngày hẹn">
          <template #default="scope">
            {{ formatDate(scope.row.date) }}
          </template>
        </el-table-column>
        <el-table-column prop="time" label="Giờ hẹn"></el-table-column>
        <el-table-column prop="service" label="Dịch vụ">
          <template #default="scope">
            {{ getServiceName(scope.row.service) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="Trạng thái">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Thao tác" width="120">
          <template #default="scope">
            <el-button 
              type="danger" 
              size="small" 
              @click="cancelBooking(scope.row)">
              Hủy
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const bookings = ref([])

onMounted(() => {
  // Đọc danh sách lịch hẹn từ localStorage
  const savedBookings = JSON.parse(localStorage.getItem('bookings') || '[]')
  bookings.value = savedBookings
})

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN')
}

const getServiceName = (service) => {
  const services = {
    male: 'Cắt tóc nam',
    female: 'Cắt tóc nữ',
    perm: 'Uốn tóc',
    dye: 'Nhuộm tóc'
  }
  return services[service] || service
}

const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    confirmed: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: 'Chờ xác nhận',
    confirmed: 'Đã xác nhận',
    cancelled: 'Đã hủy'
  }
  return texts[status] || status
}

const cancelBooking = (booking) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn hủy lịch hẹn này?',
    'Xác nhận',
    {
      confirmButtonText: 'Có',
      cancelButtonText: 'Không',
      type: 'warning'
    }
  ).then(() => {
    // Cập nhật trạng thái lịch hẹn
    const index = bookings.value.findIndex(b => b.id === booking.id)
    if (index > -1) {
      bookings.value[index].status = 'cancelled'
      // Lưu lại vào localStorage
      localStorage.setItem('bookings', JSON.stringify(bookings.value))
      ElMessage.success('Đã hủy lịch hẹn!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}
</script>

<style scoped>
.bookings {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

h2 {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
}

.empty-bookings {
  padding: 4rem 0;
}
</style> 