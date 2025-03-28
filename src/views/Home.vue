<template>
  <div class="home">
    <div class="hero">
      <div class="hero-content">
        <h1>Chào mừng đến với Haircut Booking</h1>
        <p>Đặt lịch cắt tóc trực tuyến và mua sản phẩm chăm sóc tóc chất lượng</p>
        <el-button type="primary" size="large" @click="handleBooking">Đặt lịch ngay</el-button>
      </div>
    </div>

    <div class="features">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon"><Calendar /></el-icon>
            <h3>Đặt lịch dễ dàng</h3>
            <p>Đặt lịch cắt tóc trực tuyến 24/7, không cần gọi điện</p>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon"><Star /></el-icon>
            <h3>Thợ cắt chuyên nghiệp</h3>
            <p>Đội ngũ thợ cắt tóc giàu kinh nghiệm, tay nghề cao</p>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon"><ShoppingCart /></el-icon>
            <h3>Sản phẩm chất lượng</h3>
            <p>Mua sản phẩm chăm sóc tóc chính hãng, giá tốt</p>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <div class="services">
      <h2>Dịch vụ của chúng tôi</h2>
      <el-row :gutter="20">
        <el-col :span="6" v-for="service in services" :key="service.id">
          <el-card class="service-card" shadow="hover">
            <el-icon class="service-icon"><component :is="service.icon" /></el-icon>
            <h3>{{ service.name }}</h3>
            <p>{{ service.description }}</p>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import {
  Calendar,
  Star,
  ShoppingCart
} from '@element-plus/icons-vue'

const router = useRouter()

const services = [
  {
    id: 1,
    name: 'Cắt tóc nam',
    description: 'Cắt tóc nam các kiểu hiện đại',
    icon: 'Star'
  },
  {
    id: 2,
    name: 'Cắt tóc nữ',
    description: 'Cắt tóc nữ theo xu hướng mới nhất',
    icon: 'Star'
  },
  {
    id: 3,
    name: 'Nhuộm tóc',
    description: 'Nhuộm tóc với màu sắc đa dạng',
    icon: 'Star'
  },
  {
    id: 4,
    name: 'Uốn tóc',
    description: 'Uốn tóc các kiểu theo yêu cầu',
    icon: 'Star'
  }
]

const handleBooking = () => {
  const user = JSON.parse(localStorage.getItem('user'))
  if (!user) {
    ElMessage.warning('Vui lòng đăng nhập để đặt lịch!')
    router.push({
      path: '/login',
      query: { redirect: '/booking' }
    })
    return
  }
  router.push('/booking')
}
</script>

<style scoped>
.home {
  min-height: 100vh;
}

.hero {
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  height: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: white;
  margin-bottom: 60px;
}

.hero-content {
  max-width: 800px;
  padding: 0 20px;
}

.hero-content h1 {
  font-size: 3rem;
  margin-bottom: 20px;
  font-weight: 700;
}

.hero-content p {
  font-size: 1.2rem;
  margin-bottom: 30px;
  opacity: 0.9;
}

.features {
  padding: 60px 20px;
  background-color: #f5f7fa;
}

.feature-card {
  text-align: center;
  padding: 30px;
  height: 100%;
  transition: transform 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.feature-icon {
  font-size: 3rem;
  color: #409EFF;
  margin-bottom: 20px;
}

.feature-card h3 {
  margin: 15px 0;
  color: #303133;
}

.feature-card p {
  color: #606266;
  line-height: 1.6;
}

.services {
  padding: 60px 20px;
  text-align: center;
}

.services h2 {
  margin-bottom: 40px;
  color: #303133;
  font-size: 2rem;
}

.service-card {
  text-align: center;
  padding: 30px;
  height: 100%;
  transition: all 0.3s;
}

.service-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.service-icon {
  font-size: 3rem;
  color: #409EFF;
  margin-bottom: 20px;
}

.service-card h3 {
  margin: 15px 0;
  color: #303133;
}

.service-card p {
  color: #606266;
  line-height: 1.6;
}

@media (max-width: 768px) {
  .hero-content h1 {
    font-size: 2rem;
  }

  .hero-content p {
    font-size: 1rem;
  }

  .el-col {
    margin-bottom: 20px;
  }
}
</style> 