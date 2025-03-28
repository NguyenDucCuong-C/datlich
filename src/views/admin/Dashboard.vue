<template>
  <div class="admin-dashboard">
    <h2>Tổng quan</h2>

    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <span>Lịch hẹn mới</span>
              <el-icon><Calendar /></el-icon>
            </div>
          </template>
          <div class="card-content">
            <div class="stat-number">{{ pendingBookings }}</div>
            <div class="stat-label">Đang chờ xác nhận</div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <span>Lịch hẹn hôm nay</span>
              <el-icon><Timer /></el-icon>
            </div>
          </template>
          <div class="card-content">
            <div class="stat-number">{{ todayBookings }}</div>
            <div class="stat-label">Đã xác nhận</div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <span>Tổng sản phẩm</span>
              <el-icon><Goods /></el-icon>
            </div>
          </template>
          <div class="card-content">
            <div class="stat-number">{{ totalProducts }}</div>
            <div class="stat-label">Đang bán</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>Lịch hẹn theo dịch vụ</span>
            </div>
          </template>
          <div class="chart-content">
            <div v-for="(count, service) in bookingsByService" :key="service" class="chart-item">
              <div class="service-name">{{ getServiceName(service) }}</div>
              <div class="service-count">{{ count }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span>Trạng thái lịch hẹn</span>
            </div>
          </template>
          <div class="chart-content">
            <div v-for="(count, status) in bookingsByStatus" :key="status" class="chart-item">
              <div class="status-name">{{ getStatusText(status) }}</div>
              <div class="status-count">{{ count }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Calendar, Timer, Goods } from '@element-plus/icons-vue'

const bookings = ref([])
const products = ref([])

onMounted(() => {
  loadData()
})

const loadData = () => {
  bookings.value = JSON.parse(localStorage.getItem('bookings') || '[]')
  products.value = JSON.parse(localStorage.getItem('products') || '[]')
}

const pendingBookings = computed(() => {
  return bookings.value.filter(b => b.status === 'pending').length
})

const todayBookings = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return bookings.value.filter(b => {
    return b.status === 'confirmed' && b.date === today
  }).length
})

const totalProducts = computed(() => {
  return products.value.length
})

const bookingsByService = computed(() => {
  const counts = {}
  bookings.value.forEach(booking => {
    counts[booking.service] = (counts[booking.service] || 0) + 1
  })
  return counts
})

const bookingsByStatus = computed(() => {
  const counts = {}
  bookings.value.forEach(booking => {
    counts[booking.status] = (counts[booking.status] || 0) + 1
  })
  return counts
})

const getServiceName = (service) => {
  const services = {
    male: 'Cắt tóc nam',
    female: 'Cắt tóc nữ',
    perm: 'Uốn tóc',
    dye: 'Nhuộm tóc'
  }
  return services[service] || service
}

const getStatusText = (status) => {
  const texts = {
    pending: 'Chờ xác nhận',
    confirmed: 'Đã xác nhận',
    cancelled: 'Đã hủy'
  }
  return texts[status] || status
}
</script>

<style scoped>
.admin-dashboard {
  padding: 20px;
}

h2 {
  margin-bottom: 20px;
  color: #333;
}

.stat-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  text-align: center;
  padding: 20px 0;
}

.stat-number {
  font-size: 36px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 10px;
}

.stat-label {
  color: #666;
  font-size: 14px;
}

.chart-row {
  margin-top: 20px;
}

.chart-card {
  height: 300px;
}

.chart-content {
  padding: 20px;
}

.chart-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #eee;
}

.chart-item:last-child {
  border-bottom: none;
}

.service-name,
.status-name {
  color: #666;
}

.service-count,
.status-count {
  font-weight: bold;
  color: #409EFF;
}
</style> 