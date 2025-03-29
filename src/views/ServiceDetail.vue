<template>
  <div class="service-detail">
    <el-breadcrumb separator="/">
      <el-breadcrumb-item :to="{ path: '/' }">Trang chủ</el-breadcrumb-item>
      <el-breadcrumb-item :to="{ path: '/services' }">Dịch vụ</el-breadcrumb-item>
      <el-breadcrumb-item>{{ service.name }}</el-breadcrumb-item>
    </el-breadcrumb>

    <div class="service-content">
      <div class="service-gallery">
        <el-carousel height="400px">
          <el-carousel-item v-for="(image, index) in service.images" :key="index">
            <el-image :src="image" fit="cover" class="service-image" />
          </el-carousel-item>
        </el-carousel>
      </div>

      <div class="service-info">
        <h1 class="service-name">{{ service.name }}</h1>
        <div class="service-price">{{ formatPrice(service.price) }}</div>
        <div class="service-description">{{ service.description }}</div>
        
        <div class="service-meta">
          <div class="meta-item">
            <el-icon><Clock /></el-icon>
            <span>Thời gian: {{ service.duration }} phút</span>
          </div>
          <div class="meta-item">
            <el-icon><User /></el-icon>
            <span>Nhân viên: {{ service.staffName }}</span>
          </div>
        </div>

        <div class="service-actions">
          <el-button 
            type="primary" 
            size="large"
            :disabled="!isAuthenticated"
            @click="bookService">
            Đặt lịch ngay
          </el-button>
        </div>
      </div>
    </div>

    <div class="service-reviews">
      <ReviewList 
        type="service"
        :item-id="service.id"
        :item-name="service.name" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Clock, User } from '@element-plus/icons-vue'
import ReviewList from '../components/ReviewList.vue'

const route = useRoute()
const router = useRouter()
const service = ref({})
const isAuthenticated = ref(false)

const loadService = () => {
  const services = JSON.parse(localStorage.getItem('services') || '[]')
  const foundService = services.find(s => s.id === route.params.id)
  
  if (!foundService) {
    ElMessage.error('Không tìm thấy dịch vụ!')
    router.push('/services')
    return
  }

  service.value = foundService
  isAuthenticated.value = !!localStorage.getItem('user')
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const bookService = () => {
  if (!isAuthenticated.value) {
    ElMessage.warning('Vui lòng đăng nhập để đặt lịch!')
    router.push('/login')
    return
  }

  router.push({
    path: '/booking',
    query: { serviceId: service.value.id }
  })
}

onMounted(() => {
  loadService()
})
</script>

<style scoped>
.service-detail {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.service-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  margin: 20px 0;
}

.service-gallery {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.service-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.service-info {
  padding: 20px;
}

.service-name {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 16px;
}

.service-price {
  font-size: 28px;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 16px;
}

.service-description {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 24px;
}

.service-meta {
  display: flex;
  gap: 24px;
  color: #909399;
  margin-bottom: 24px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.service-actions {
  margin-top: 24px;
}

.service-reviews {
  margin-top: 40px;
  padding-top: 40px;
  border-top: 1px solid #ebeef5;
}

@media (max-width: 768px) {
  .service-content {
    grid-template-columns: 1fr;
  }
}
</style> 