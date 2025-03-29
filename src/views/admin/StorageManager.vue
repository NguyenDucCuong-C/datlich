<template>
  <div class="storage-manager">
    <h2>Quản lý LocalStorage</h2>
    
    <div class="storage-section">
      <h3>Danh sách người dùng</h3>
      <el-table :data="users" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="Tên đăng nhập" />
        <el-table-column prop="name" label="Họ tên" />
        <el-table-column prop="phone" label="Số điện thoại" />
        <el-table-column prop="address" label="Địa chỉ" />
        <el-table-column prop="role" label="Vai trò" width="100">
          <template #default="{ row }">
            <el-tag :type="row.role === 'admin' ? 'danger' : 'success'">
              {{ row.role === 'admin' ? 'Admin' : 'User' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div class="storage-section">
      <h3>Người dùng đang đăng nhập</h3>
      <el-descriptions :column="1" border v-loading="loading">
        <el-descriptions-item label="Tên đăng nhập">{{ currentUser?.username || 'Chưa đăng nhập' }}</el-descriptions-item>
        <el-descriptions-item label="Họ tên">{{ currentUser?.name || 'N/A' }}</el-descriptions-item>
        <el-descriptions-item label="Số điện thoại">{{ currentUser?.phone || 'N/A' }}</el-descriptions-item>
        <el-descriptions-item label="Địa chỉ">{{ currentUser?.address || 'N/A' }}</el-descriptions-item>
        <el-descriptions-item label="Vai trò">
          <el-tag :type="currentUser?.role === 'admin' ? 'danger' : 'success'">
            {{ currentUser?.role === 'admin' ? 'Admin' : 'User' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </div>

    <div class="storage-section">
      <h3>Dữ liệu khác</h3>
      <el-descriptions :column="1" border v-loading="loading">
        <el-descriptions-item label="Số lượng sản phẩm">{{ products.length }}</el-descriptions-item>
        <el-descriptions-item label="Số lượng đơn hàng">{{ orders.length }}</el-descriptions-item>
        <el-descriptions-item label="Số lượng lịch hẹn">{{ bookings.length }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <div class="actions">
      <el-button type="danger" @click="clearStorage" :loading="loading">Xóa tất cả dữ liệu</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const users = ref([])
const currentUser = ref(null)
const products = ref([])
const orders = ref([])
const bookings = ref([])
const loading = ref(false)

const loadStorageData = async () => {
  try {
    loading.value = true
    
    // Load users
    const usersData = localStorage.getItem('users')
    users.value = usersData ? JSON.parse(usersData) : []

    // Load current user
    const currentUserData = localStorage.getItem('user')
    currentUser.value = currentUserData ? JSON.parse(currentUserData) : null

    // Load other data
    const productsData = localStorage.getItem('products')
    products.value = productsData ? JSON.parse(productsData) : []

    const ordersData = localStorage.getItem('orders')
    orders.value = ordersData ? JSON.parse(ordersData) : []

    const bookingsData = localStorage.getItem('bookings')
    bookings.value = bookingsData ? JSON.parse(bookingsData) : []
  } catch (error) {
    console.error('Error loading storage data:', error)
    ElMessage.error('Có lỗi xảy ra khi tải dữ liệu!')
  } finally {
    loading.value = false
  }
}

const clearStorage = async () => {
  try {
    await ElMessageBox.confirm(
      'Bạn có chắc chắn muốn xóa tất cả dữ liệu? Hành động này không thể hoàn tác!',
      'Cảnh báo',
      {
        confirmButtonText: 'Xác nhận',
        cancelButtonText: 'Hủy',
        type: 'warning',
      }
    )
    
    loading.value = true
    localStorage.clear()
    await loadStorageData()
    ElMessage.success('Đã xóa tất cả dữ liệu!')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('Error clearing storage:', error)
      ElMessage.error('Có lỗi xảy ra khi xóa dữ liệu!')
    } else {
      ElMessage.info('Đã hủy thao tác xóa dữ liệu.')
    }
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadStorageData()
})
</script>

<style scoped>
.storage-manager {
  padding: 20px;
}

.storage-section {
  margin-bottom: 30px;
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
}

h2 {
  margin-bottom: 30px;
  color: #303133;
}

h3 {
  margin-bottom: 20px;
  color: #606266;
}

.actions {
  margin-top: 20px;
  text-align: right;
}
</style> 