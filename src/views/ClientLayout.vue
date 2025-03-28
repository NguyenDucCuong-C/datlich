<template>
  <el-container>
    <el-header>
      <nav class="navbar">
        <div class="logo">
          <span>Hair Salon</span>
        </div>
        <div class="nav-links">
          <router-link to="/">Trang chủ</router-link>
          <router-link to="/booking">Đặt lịch</router-link>
          <router-link to="/bookings">Lịch hẹn</router-link>
          <router-link to="/products">Sản phẩm</router-link>
          <router-link to="/cart">Giỏ hàng</router-link>
          <template v-if="user.username">
            <a href="#" @click.prevent="handleLogout">Đăng xuất</a>
          </template>
          <router-link v-else to="/login">Đăng nhập</router-link>
        </div>
      </nav>
    </el-header>
    
    <el-main>
      <router-view></router-view>
    </el-main>
    
    <el-footer>
      <p>&copy; 2024 Haircut Booking. All rights reserved.</p>
    </el-footer>
  </el-container>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

const router = useRouter()
const user = ref({})

onMounted(() => {
  user.value = JSON.parse(localStorage.getItem('user') || '{}')
})

const handleLogout = () => {
  localStorage.removeItem('user')
  user.value = {}
  ElMessage.success('Đăng xuất thành công!')
  router.push('/')
}
</script>

<style scoped>
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.logo {
  font-size: 1.5rem;
  font-weight: bold;
  text-decoration: none;
  color: #333;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-links a {
  text-decoration: none;
  color: #666;
  transition: color 0.3s;
}

.nav-links a:hover {
  color: #409EFF;
}

.el-footer {
  text-align: center;
  padding: 1rem;
  background-color: #f5f7fa;
  color: #666;
}
</style> 