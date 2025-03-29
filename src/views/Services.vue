<template>
  <div class="services-page">
    <h1 class="page-title">Dịch vụ của chúng tôi</h1>
    
    <div class="services-grid">
      <el-card 
        v-for="service in services" 
        :key="service.id" 
        class="service-card"
        @click="goToServiceDetail(service.id)">
        <el-image 
          :src="service.images[0]" 
          fit="cover" 
          class="service-image" />
        <div class="service-info">
          <h3 class="service-name">{{ service.name }}</h3>
          <div class="service-price">{{ formatPrice(service.price) }}</div>
          <div class="service-meta">
            <span>
              <el-icon><Clock /></el-icon>
              {{ service.duration }} phút
            </span>
            <span>
              <el-icon><User /></el-icon>
              {{ service.staffName }}
            </span>
          </div>
          <div class="service-description">{{ service.description }}</div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Clock, User } from '@element-plus/icons-vue'

const router = useRouter()
const services = ref([])

const loadServices = () => {
  const servicesData = JSON.parse(localStorage.getItem('services') || '[]')
  services.value = servicesData
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const goToServiceDetail = (serviceId) => {
  router.push(`/services/${serviceId}`)
}

onMounted(() => {
  loadServices()
})
</script>

<style scoped>
.services-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-title {
  font-size: 28px;
  color: #303133;
  margin-bottom: 30px;
  text-align: center;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.service-card {
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
}

.service-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.service-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.service-info {
  padding: 15px;
}

.service-name {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 10px;
}

.service-price {
  font-size: 20px;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 10px;
}

.service-meta {
  display: flex;
  gap: 15px;
  color: #909399;
  font-size: 14px;
  margin-bottom: 10px;
}

.service-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
}

.service-description {
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

@media (max-width: 768px) {
  .services-grid {
    grid-template-columns: 1fr;
  }
}
</style> 