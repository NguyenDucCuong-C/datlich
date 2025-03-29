<template>
  <div class="payment">
    <h2>Thanh toán dịch vụ</h2>
    
    <el-table :data="pendingBookings" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="Mã lịch hẹn" width="120"></el-table-column>
      
      <el-table-column prop="name" label="Khách hàng" width="150"></el-table-column>
      
      <el-table-column prop="phone" label="Số điện thoại" width="120"></el-table-column>
      
      <el-table-column prop="date" label="Ngày hẹn" width="120">
        <template #default="scope">
          {{ formatDate(scope.row.date) }}
        </template>
      </el-table-column>
      
      <el-table-column prop="time" label="Giờ hẹn" width="100"></el-table-column>
      
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
      
      <el-table-column label="Thao tác" width="200">
        <template #default="scope">
          <el-button 
            type="success" 
            size="small" 
            @click="handlePayment(scope.row)"
          >
            Thanh toán
          </el-button>
          <el-button 
            type="danger" 
            size="small" 
            @click="handleCancel(scope.row)"
          >
            Hủy
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const bookings = ref([])

// Lọc các lịch hẹn đang chờ thanh toán
const pendingBookings = computed(() => {
  return bookings.value.filter(booking => booking.status === 'pending')
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

// Xử lý thanh toán
const handlePayment = (booking) => {
  ElMessageBox.confirm(
    'Xác nhận thanh toán cho lịch hẹn này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    const index = bookings.value.findIndex(b => b.id === booking.id)
    if (index > -1) {
      bookings.value[index].status = 'completed'
      localStorage.setItem('bookings', JSON.stringify(bookings.value))
      ElMessage.success('Đã thanh toán thành công!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
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
  // Load danh sách lịch hẹn
  bookings.value = JSON.parse(localStorage.getItem('bookings') || '[]')
  loading.value = false
})
</script>

<style scoped>
.payment {
  padding: 20px;
}

.service-tag {
  margin-bottom: 5px;
}
</style> 