<template>
  <div class="admin-orders">
    <div class="page-header">
      <h2>Quản lý đơn hàng</h2>
      <div class="header-actions">
        <el-select v-model="statusFilter" placeholder="Lọc theo trạng thái" style="width: 150px">
          <el-option label="Tất cả" value="all" />
          <el-option label="Chờ xác nhận" value="pending" />
          <el-option label="Đã xác nhận" value="confirmed" />
          <el-option label="Đã thanh toán" value="paid" />
          <el-option label="Đã hủy" value="cancelled" />
        </el-select>
      </div>
    </div>

    <el-table :data="filteredOrders" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="Mã đơn" width="100"></el-table-column>
      
      <el-table-column prop="customerName" label="Khách hàng" width="150"></el-table-column>
      
      <el-table-column prop="phone" label="Số điện thoại" width="120"></el-table-column>
      
      <el-table-column prop="address" label="Địa chỉ"></el-table-column>
      
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
      
      <el-table-column label="Thao tác" width="250">
        <template #default="scope">
          <el-button 
            v-if="scope.row.status === 'pending'"
            type="success" 
            size="small" 
            @click="handleApprove(scope.row)"
          >
            Xác nhận
          </el-button>
          <el-button 
            v-if="scope.row.status === 'confirmed'"
            type="primary" 
            size="small" 
            @click="handleMarkAsPaid(scope.row)"
          >
            Đã thanh toán
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
          <span class="label">Khách hàng:</span>
          <span class="value">{{ selectedOrder.customerName }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Số điện thoại:</span>
          <span class="value">{{ selectedOrder.phone }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Địa chỉ:</span>
          <span class="value">{{ selectedOrder.address }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Ngày đặt:</span>
          <span class="value">{{ formatDate(selectedOrder.orderDate) }}</span>
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
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const orders = ref([])
const statusFilter = ref('all')
const detailsDialogVisible = ref(false)
const selectedOrder = ref(null)

// Lọc đơn hàng theo trạng thái
const filteredOrders = computed(() => {
  if (statusFilter.value === 'all') return orders.value
  return orders.value.filter(order => order.status === statusFilter.value)
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
    case 'cancelled': return 'danger'
    default: return 'info'
  }
}

// Lấy text cho trạng thái
const getStatusText = (status) => {
  switch (status) {
    case 'pending': return 'Chờ xác nhận'
    case 'confirmed': return 'Đã xác nhận'
    case 'paid': return 'Đã thanh toán'
    case 'cancelled': return 'Đã hủy'
    default: return status
  }
}

// Hiển thị dialog chi tiết
const showDetails = (order) => {
  selectedOrder.value = order
  detailsDialogVisible.value = true
}

// Xử lý xác nhận đơn
const handleApprove = (order) => {
  ElMessageBox.confirm(
    'Xác nhận đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    const index = orders.value.findIndex(o => o.id === order.id)
    if (index > -1) {
      orders.value[index].status = 'confirmed'
      localStorage.setItem('orders', JSON.stringify(orders.value))
      ElMessage.success('Đã xác nhận đơn hàng!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}

// Xử lý đánh dấu đã thanh toán
const handleMarkAsPaid = (order) => {
  ElMessageBox.confirm(
    'Xác nhận đơn hàng đã thanh toán?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'success'
    }
  ).then(() => {
    const index = orders.value.findIndex(o => o.id === order.id)
    if (index > -1) {
      orders.value[index].status = 'paid'
      localStorage.setItem('orders', JSON.stringify(orders.value))
      ElMessage.success('Đã cập nhật trạng thái thanh toán!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}

// Xử lý hủy đơn
const handleCancel = (order) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn hủy đơn hàng này?',
    'Xác nhận',
    {
      confirmButtonText: 'Xác nhận',
      cancelButtonText: 'Hủy',
      type: 'warning'
    }
  ).then(() => {
    const index = orders.value.findIndex(o => o.id === order.id)
    if (index > -1) {
      orders.value[index].status = 'cancelled'
      localStorage.setItem('orders', JSON.stringify(orders.value))
      ElMessage.success('Đã hủy đơn hàng!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}

onMounted(() => {
  loading.value = true
  // Load danh sách đơn hàng
  orders.value = JSON.parse(localStorage.getItem('orders') || '[]')
  loading.value = false
})
</script>

<style scoped>
.admin-orders {
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

.order-item {
  display: flex;
  justify-content: space-between;
  margin: 5px 0;
  padding: 5px 0;
  border-bottom: 1px solid #ebeef5;
}

.order-item:last-child {
  border-bottom: none;
}

.order-details {
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

.products-list {
  margin: 20px 0;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 4px;
}

.product-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 10px 0;
  padding: 10px;
  background: white;
  border-radius: 4px;
}

.product-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.product-image {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
}

.product-details {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.product-name {
  font-weight: bold;
}

.product-price {
  color: #409EFF;
}

.product-quantity {
  color: #606266;
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