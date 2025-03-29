<template>
  <div class="product-detail">
    <el-breadcrumb separator="/">
      <el-breadcrumb-item :to="{ path: '/' }">Trang chủ</el-breadcrumb-item>
      <el-breadcrumb-item :to="{ path: '/products' }">Sản phẩm</el-breadcrumb-item>
      <el-breadcrumb-item>{{ product.name }}</el-breadcrumb-item>
    </el-breadcrumb>

    <div class="product-content">
      <div class="product-gallery">
        <el-carousel height="400px">
          <el-carousel-item v-for="(image, index) in product.images" :key="index">
            <el-image :src="image" fit="cover" class="product-image" />
          </el-carousel-item>
        </el-carousel>
      </div>

      <div class="product-info">
        <h1 class="product-name">{{ product.name }}</h1>
        <div class="product-price">{{ formatPrice(product.price) }}</div>
        <div class="product-description">{{ product.description }}</div>
        
        <div class="product-actions">
          <el-input-number 
            v-model="quantity" 
            :min="1" 
            :max="product.stock"
            size="large"
            @change="handleQuantityChange" />
          <el-button 
            type="primary" 
            size="large"
            :disabled="!isAuthenticated"
            @click="addToCart">
            Thêm vào giỏ hàng
          </el-button>
        </div>

        <div class="product-meta">
          <div class="meta-item">
            <el-icon><Box /></el-icon>
            <span>Còn lại: {{ product.stock }}</span>
          </div>
          <div class="meta-item">
            <el-icon><View /></el-icon>
            <span>Đã xem: {{ product.views }}</span>
          </div>
        </div>
      </div>
    </div>

    <div class="product-reviews">
      <ReviewList 
        type="product"
        :item-id="product.id"
        :item-name="product.name" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Box, View } from '@element-plus/icons-vue'
import ReviewList from '../components/ReviewList.vue'

const route = useRoute()
const router = useRouter()
const product = ref({})
const quantity = ref(1)
const isAuthenticated = ref(false)

const loadProduct = () => {
  const products = JSON.parse(localStorage.getItem('products') || '[]')
  const foundProduct = products.find(p => p.id === route.params.id)
  
  if (!foundProduct) {
    ElMessage.error('Không tìm thấy sản phẩm!')
    router.push('/products')
    return
  }

  product.value = foundProduct
  isAuthenticated.value = !!localStorage.getItem('user')
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const handleQuantityChange = (value) => {
  if (value > product.value.stock) {
    quantity.value = product.value.stock
  }
}

const addToCart = () => {
  if (!isAuthenticated.value) {
    ElMessage.warning('Vui lòng đăng nhập để thêm vào giỏ hàng!')
    router.push('/login')
    return
  }

  const cart = JSON.parse(localStorage.getItem('cart') || '[]')
  const existingItem = cart.find(item => item.id === product.value.id)

  if (existingItem) {
    existingItem.quantity += quantity.value
  } else {
    cart.push({
      id: product.value.id,
      name: product.value.name,
      price: product.value.price,
      image: product.value.images[0],
      quantity: quantity.value
    })
  }

  localStorage.setItem('cart', JSON.stringify(cart))
  ElMessage.success('Đã thêm vào giỏ hàng!')
}

onMounted(() => {
  loadProduct()
})
</script>

<style scoped>
.product-detail {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.product-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
  margin: 20px 0;
}

.product-gallery {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.product-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-info {
  padding: 20px;
}

.product-name {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 16px;
}

.product-price {
  font-size: 28px;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 16px;
}

.product-description {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 24px;
}

.product-actions {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.product-meta {
  display: flex;
  gap: 24px;
  color: #909399;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.product-reviews {
  margin-top: 40px;
  padding-top: 40px;
  border-top: 1px solid #ebeef5;
}

@media (max-width: 768px) {
  .product-content {
    grid-template-columns: 1fr;
  }
}
</style> 