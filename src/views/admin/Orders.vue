<template>
  <div class="orders">
    <div class="header">
      <h2>Quản lý đơn hàng</h2>
      <div class="stats">
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Tổng doanh thu</span>
              <el-icon><Money /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ formatPrice(totalRevenue) }}</div>
        </el-card>
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Đơn hàng mới</span>
              <el-icon><ShoppingCart /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ newOrders }}</div>
        </el-card>
        <el-card class="stat-card">
          <template #header>
            <div class="stat-header">
              <span>Đơn hàng hoàn thành</span>
              <el-icon><CircleCheck /></el-icon>
            </div>
          </template>
          <div class="stat-value">{{ completedOrders }}</div>
        </el-card>
      </div>
    </div>

    <el-table :data="orders" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="Mã đơn hàng" width="120" />
      <el-table-column prop="customerName" label="Khách hàng" width="150" />
      <el-table-column prop="phone" label="Số điện thoại" width="120" />
      <el-table-column prop="address" label="Địa chỉ" />
      <el-table-column prop="total" label="Tổng tiền" width="150">
        <template #default="{ row }">
          {{ formatPrice(row.total) }}
        </template>
      </el-table-column>
      <el-table-column prop="status" label="Trạng thái" width="120">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createdAt" label="Ngày đặt" width="180">
        <template #default="{ row }">
          {{ formatDate(row.createdAt) }}
        </template>
      </el-table-column>
      <el-table-column label="Thao tác" width="200">
        <template #default="{ row }">
          <el-button-group>
            <el-button type="primary" size="small" @click="viewOrder(row)">
              Chi tiết
            </el-button>
            <el-button 
              v-if="row.status === 'pending'"
              type="success" 
              size="small" 
              @click="updateStatus(row, 'completed')"
            >
              Hoàn thành
            </el-button>
            <el-button 
              v-if="row.status === 'pending'"
              type="danger" 
              size="small" 
              @click="updateStatus(row, 'cancelled')"
            >
              Hủy
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog chi tiết đơn hàng -->
    <el-dialog
      v-model="dialogVisible"
      title="Chi tiết đơn hàng"
      width="50%"
    >
      <div v-if="selectedOrder">
        <div class="order-details">
          <p><strong>Mã đơn hàng:</strong> {{ selectedOrder.id }}</p>
          <p><strong>Khách hàng:</strong> {{ selectedOrder.customerName }}</p>
          <p><strong>Số điện thoại:</strong> {{ selectedOrder.phone }}</p>
          <p><strong>Địa chỉ:</strong> {{ selectedOrder.address }}</p>
          <p><strong>Ngày đặt:</strong> {{ formatDate(selectedOrder.createdAt) }}</p>
          <p><strong>Trạng thái:</strong> 
            <el-tag :type="getStatusType(selectedOrder.status)">
              {{ getStatusText(selectedOrder.status) }}
            </el-tag>
          </p>
        </div>

        <el-table :data="selectedOrder.items" style="width: 100%">
          <el-table-column prop="name" label="Sản phẩm" />
          <el-table-column prop="price" label="Đơn giá" width="150">
            <template #default="{ row }">
              {{ formatPrice(row.price) }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="Số lượng" width="100" />
          <el-table-column label="Thành tiền" width="150">
            <template #default="{ row }">
              {{ formatPrice(row.price * row.quantity) }}
            </template>
          </el-table-column>
        </el-table>

        <div class="order-total">
          <p><strong>Tổng tiền:</strong> {{ formatPrice(selectedOrder.total) }}</p>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Money, ShoppingCart, CircleCheck } from '@element-plus/icons-vue'

const loading = ref(false)
const orders = ref([])
const dialogVisible = ref(false)
const selectedOrder = ref(null)

onMounted(() => {
  loadOrders()
})

const loadOrders = () => {
  loading.value = true
  // Giả lập API call
  setTimeout(() => {
    orders.value = JSON.parse(localStorage.getItem('orders') || '[]')
    loading.value = false
  }, 500)
}

const totalRevenue = computed(() => {
  return orders.value.reduce((total, order) => {
    return order.status === 'completed' ? total + order.total : total
  }, 0)
})

const newOrders = computed(() => {
  return orders.value.filter(order => order.status === 'pending').length
})

const completedOrders = computed(() => {
  return orders.value.filter(order => order.status === 'completed').length
})

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const formatDate = (date) => {
  return new Date(date).toLocaleString('vi-VN')
}

const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    completed: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: 'Chờ xử lý',
    completed: 'Hoàn thành',
    cancelled: 'Đã hủy'
  }
  return texts[status] || status
}

const viewOrder = (order) => {
  selectedOrder.value = order
  dialogVisible.value = true
}

const updateStatus = async (order, newStatus) => {
  try {
    await ElMessageBox.confirm(
      `Bạn có chắc muốn ${newStatus === 'completed' ? 'hoàn thành' : 'hủy'} đơn hàng này?`,
      'Xác nhận',
      {
        confirmButtonText: 'Đồng ý',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const updatedOrders = orders.value.map(o => {
      if (o.id === order.id) {
        return { ...o, status: newStatus }
      }
      return o
    })

    localStorage.setItem('orders', JSON.stringify(updatedOrders))
    orders.value = updatedOrders
    ElMessage.success('Cập nhật trạng thái đơn hàng thành công!')
  } catch {
    // User cancelled
  }
}
</script>

<style scoped>
.orders {
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

.order-details {
  margin-bottom: 20px;
}

.order-details p {
  margin: 5px 0;
}

.order-total {
  margin-top: 20px;
  text-align: right;
  font-size: 18px;
}
</style> 