<template>
  <div class="orders">
    <h1>Đơn hàng của tôi</h1>
    
    <el-table :data="orders" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="Mã đơn" width="100"></el-table-column>
      
      <el-table-column label="Ngày đặt" width="180">
        <template #default="scope">
          {{ formatDate(scope.row.orderDate) }}
        </template>
      </el-table-column>
      
      <el-table-column label="Sản phẩm">
        <template #default="scope">
          <div v-for="item in scope.row.items" :key="item.id" class="order-item">
            <span>{{ item.name }}</span>
            <span>x{{ item.quantity }}</span>
            <span>{{ formatPrice(item.price) }}</span>
          </div>
        </template>
      </el-table-column>
      
      <el-table-column prop="totalAmount" label="Tổng tiền" width="150">
        <template #default="scope">
          {{ formatPrice(scope.row.totalAmount) }}
        </template>
      </el-table-column>
      
      <el-table-column prop="status" label="Trạng thái" width="120">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="Thao tác" width="120">
        <template #default="scope">
          <el-button 
            type="primary" 
            size="small" 
            @click="showDetails(scope.row)"
          >
            Chi tiết
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog chi tiết đơn hàng -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="Chi tiết đơn hàng"
      width="600px"
    >
      <div v-if="selectedOrder" class="order-details">
        <div class="detail-row">
          <span class="label">Mã đơn:</span>
          <span class="value">{{ selectedOrder.id }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Ngày đặt:</span>
          <span class="value">{{ formatDate(selectedOrder.orderDate) }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Địa chỉ:</span>
          <span class="value">{{ selectedOrder.address }}</span>
        </div>
        <div class="products-list">
          <div class="label">Sản phẩm:</div>
          <div v-for="item in selectedOrder.items" :key="item.id" class="product-item">
            <div class="product-info">
              <img :src="item.image" class="product-image" />
              <div class="product-details">
                <div class="product-name">{{ item.name }}</div>
                <div class="product-price">{{ formatPrice(item.price) }}</div>
              </div>
            </div>
            <div class="product-quantity">x{{ item.quantity }}</div>
          </div>
        </div>
        <div class="total-row">
          <span class="label">Tổng tiền:</span>
          <span class="value total">{{ formatPrice(selectedOrder.totalAmount) }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Ghi chú:</span>
          <span class="value">{{ selectedOrder.notes || 'Không có' }}</span>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailsDialogVisible = false">Đóng</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const orders = ref([])
const detailsDialogVisible = ref(false)
const selectedOrder = ref(null)

onMounted(() => {
  loadOrders()
})

const loadOrders = () => {
  loading.value = true
  const user = JSON.parse(localStorage.getItem('user'))
  if (!user) {
    ElMessage.warning('Vui lòng đăng nhập để xem đơn hàng!')
    return
  }

  const allOrders = JSON.parse(localStorage.getItem('orders') || '[]')
  orders.value = allOrders.filter(order => order.userId === user.id)
  loading.value = false
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('vi-VN')
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const getStatusType = (status) => {
  switch (status) {
    case 'pending': return 'warning'
    case 'confirmed': return 'primary'
    case 'paid': return 'success'
    case 'cancelled': return 'danger'
    default: return 'info'
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 'pending': return 'Chờ xác nhận'
    case 'confirmed': return 'Đã xác nhận'
    case 'paid': return 'Đã thanh toán'
    case 'cancelled': return 'Đã hủy'
    default: return status
  }
}

const showDetails = (order) => {
  selectedOrder.value = order
  detailsDialogVisible.value = true
}
</script>

<style scoped>
.orders {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
  color: #303133;
  font-size: 2rem;
  font-weight: 600;
}

.order-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8px 0;
  padding: 8px 0;
  border-bottom: 1px solid #ebeef5;
}

.order-item:last-child {
  border-bottom: none;
}

.order-details {
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.detail-row {
  display: flex;
  margin-bottom: 15px;
  padding: 10px;
  background: #f5f7fa;
  border-radius: 4px;
}

.label {
  font-weight: 600;
  width: 120px;
  color: #606266;
  font-size: 0.95rem;
}

.value {
  flex: 1;
  color: #303133;
  font-size: 0.95rem;
}

.products-list {
  margin: 20px 0;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
}

.product-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 15px 0;
  padding: 15px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s;
}

.product-item:hover {
  transform: translateY(-2px);
}

.product-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.product-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.product-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.product-name {
  font-weight: 600;
  color: #303133;
  font-size: 1rem;
}

.product-price {
  color: #409EFF;
  font-weight: 500;
}

.product-quantity {
  color: #606266;
  font-weight: 500;
}

.total-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 25px;
  padding-top: 20px;
  border-top: 2px solid #ebeef5;
  background: #f5f7fa;
  padding: 15px;
  border-radius: 8px;
}

.total {
  font-size: 1.3em;
  font-weight: 600;
  color: #409EFF;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 20px;
}

:deep(.el-table) {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

:deep(.el-table th) {
  background-color: #f5f7fa;
  color: #606266;
  font-weight: 600;
}

:deep(.el-table td) {
  padding: 12px 0;
}

:deep(.el-tag) {
  border-radius: 4px;
  padding: 0 10px;
  height: 28px;
  line-height: 26px;
}

:deep(.el-button) {
  border-radius: 4px;
}

@media (max-width: 768px) {
  .orders {
    padding: 1rem;
  }

  .product-item {
    flex-direction: column;
    gap: 10px;
    text-align: center;
  }

  .product-info {
    flex-direction: column;
  }

  .detail-row {
    flex-direction: column;
    gap: 5px;
  }

  .label {
    width: 100%;
  }
}
</style> 