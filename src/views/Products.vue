<template>
  <div class="products">
    <h1>Sản phẩm</h1>
    <el-row :gutter="20">
      <el-col v-for="product in products" :key="product.id" :xs="24" :sm="12" :md="8" :lg="6">
        <el-card class="product-card" :body-style="{ padding: '0px' }">
          <img :src="product.image" class="product-image">
          <div class="product-info">
            <h3>{{ product.name }}</h3>
            <p>{{ product.description }}</p>
            <div class="price">{{ formatPrice(product.price) }}</div>
            <el-button type="primary" @click="addToCart(product)">Thêm vào giỏ hàng</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'

const products = ref([])
const router = useRouter()

onMounted(() => {
  loadProducts()
})

const loadProducts = () => {
  const productsData = JSON.parse(localStorage.getItem('products') || '[]')
  products.value = productsData
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const addToCart = (product) => {
  const user = JSON.parse(localStorage.getItem('user'))
  if (!user) {
    ElMessage.warning('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng!')
    router.push({
      path: '/login',
      query: { redirect: '/products' }
    })
    return
  }

  const cart = JSON.parse(localStorage.getItem('cart') || '[]')
  const existingProduct = cart.find(item => item.id === product.id)
  
  if (existingProduct) {
    existingProduct.quantity += 1
  } else {
    cart.push({
      ...product,
      quantity: 1
    })
  }
  
  localStorage.setItem('cart', JSON.stringify(cart))
  ElMessage.success('Đã thêm sản phẩm vào giỏ hàng!')
}
</script>

<style scoped>
.products {
  padding: 40px 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.header h2 {
  font-size: 2rem;
  color: #303133;
  margin-bottom: 10px;
}

.header p {
  color: #606266;
  font-size: 1.1rem;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 30px;
  margin-top: 30px;
}

.product-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.product-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.product-info {
  padding: 20px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.product-name {
  font-size: 1.2rem;
  color: #303133;
  margin-bottom: 10px;
  font-weight: 500;
}

.product-description {
  color: #606266;
  margin-bottom: 15px;
  flex-grow: 1;
}

.product-price {
  font-size: 1.3rem;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 15px;
}

.product-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.add-to-cart {
  padding: 8px 20px;
}

@media (max-width: 768px) {
  .products {
    padding: 20px 10px;
  }

  .products-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
  }
}
</style> 