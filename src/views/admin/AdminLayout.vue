<template>
  <el-container class="admin-layout">
    <el-aside width="250px">
      <div class="logo">
        <h2>Admin Panel</h2>
      </div>
      <el-menu
        :default-active="activeMenu"
        class="admin-menu"
        background-color="#304156"
        text-color="#fff"
        active-text-color="#409EFF"
        router>
        <el-menu-item index="/admin">
          <el-icon><DataLine /></el-icon>
          <span>Tổng quan</span>
        </el-menu-item>
        <el-menu-item index="/admin/products">
          <el-icon><Goods /></el-icon>
          <span>Quản lý sản phẩm</span>
        </el-menu-item>
        <el-menu-item index="/admin/services">
          <el-icon><Service /></el-icon>
          <span>Quản lý dịch vụ</span>
        </el-menu-item>
        <el-menu-item index="/admin/bookings">
          <el-icon><Calendar /></el-icon>
          <span>Quản lý đặt lịch</span>
        </el-menu-item>
        <el-menu-item index="/admin/orders">
          <el-icon><ShoppingCart /></el-icon>
          <span>Quản lý đơn hàng</span>
        </el-menu-item>
        <el-menu-item index="/admin/staff">
          <el-icon><User /></el-icon>
          <span>Quản lý thợ</span>
        </el-menu-item>
        <el-menu-item index="/admin/storage">
          <el-icon><Box /></el-icon>
          <span>Quản lý dữ liệu</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header>
        <div class="header-left">
          <el-icon class="toggle-sidebar" @click="toggleSidebar">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              {{ user.username }}
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">Đăng xuất</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  DataLine,
  Goods,
  Fold,
  Expand,
  ArrowDown,
  ShoppingCart,
  User,
  Calendar,
  Service,
  Box
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const isCollapse = ref(false)
const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))

const activeMenu = computed(() => route.path)

const toggleSidebar = () => {
  isCollapse.value = !isCollapse.value
}

const handleCommand = (command) => {
  if (command === 'logout') {
    localStorage.removeItem('user')
    ElMessage.success('Đăng xuất thành công!')
    router.push('/login')
  }
}
</script>

<style scoped>
.admin-layout {
  height: 100vh;
}

.el-aside {
  background-color: #304156;
  transition: width 0.3s;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #2b2f3a;
}

.logo h2 {
  color: white;
  margin: 0;
  font-size: 20px;
}

.admin-menu {
  border-right: none;
}

.el-header {
  background-color: white;
  border-bottom: 1px solid #e6e6e6;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.header-left {
  display: flex;
  align-items: center;
}

.toggle-sidebar {
  font-size: 20px;
  cursor: pointer;
  color: #666;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #666;
}

.user-info .el-icon {
  margin-left: 5px;
}

.el-main {
  background-color: #f0f2f5;
  padding: 20px;
}

:deep(.el-menu-item) {
  display: flex;
  align-items: center;
}

:deep(.el-menu-item .el-icon) {
  margin-right: 10px;
}
</style> 