<template>
  <div class="cart">
    <h2>Giỏ hàng</h2>
    
    <div v-if="cartItems.length === 0" class="empty-cart">
      <el-empty description="Giỏ hàng trống">
        <el-button type="primary" @click="$router.push('/products')">Tiếp tục mua sắm</el-button>
      </el-empty>
    </div>

    <div v-else>
      <el-table :data="cartItems" style="width: 100%">
        <el-table-column prop="image" label="Sản phẩm" width="180">
          <template #default="scope">
            <img :src="scope.row.image" class="product-image">
          </template>
        </el-table-column>
        
        <el-table-column prop="name" label="Tên sản phẩm"></el-table-column>
        
        <el-table-column prop="price" label="Giá" width="180">
          <template #default="scope">
            {{ formatPrice(scope.row.price) }}
          </template>
        </el-table-column>
        
        <el-table-column label="Số lượng" width="180">
          <template #default="scope">
            <el-input-number 
              v-model="scope.row.quantity" 
              :min="1" 
              :max="10"
              @change="updateQuantity(scope.row)">
            </el-input-number>
          </template>
        </el-table-column>
        
        <el-table-column label="Tổng" width="180">
          <template #default="scope">
            {{ formatPrice(scope.row.price * scope.row.quantity) }}
          </template>
        </el-table-column>
        
        <el-table-column label="Thao tác" width="120">
          <template #default="scope">
            <el-button 
              type="danger" 
              size="small" 
              @click="removeItem(scope.row)">
              Xóa
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="cart-summary">
        <div class="total">
          <span>Tổng cộng:</span>
          <span class="total-price">{{ formatPrice(total) }}</span>
        </div>
        <el-button type="primary" size="large" @click="checkout">
          Thanh toán
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const cartItems = ref([])

onMounted(() => {
  // Đọc giỏ hàng từ localStorage khi component được mount
  const cart = JSON.parse(localStorage.getItem('cart') || '[]')
  cartItems.value = cart
})

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const total = computed(() => {
  return cartItems.value.reduce((sum, item) => {
    return sum + (item.price * item.quantity)
  }, 0)
})

const updateQuantity = (item) => {
  // Cập nhật số lượng trong giỏ hàng
  const index = cartItems.value.findIndex(i => i.id === item.id)
  if (index > -1) {
    cartItems.value[index].quantity = item.quantity
    // Cập nhật localStorage
    localStorage.setItem('cart', JSON.stringify(cartItems.value))
    ElMessage.success('Đã cập nhật số lượng!')
  }
}

const removeItem = (item) => {
  const index = cartItems.value.findIndex(i => i.id === item.id)
  if (index > -1) {
    cartItems.value.splice(index, 1)
    // Cập nhật localStorage
    localStorage.setItem('cart', JSON.stringify(cartItems.value))
    ElMessage.success('Đã xóa sản phẩm khỏi giỏ hàng!')
  }
}

const checkout = () => {
  // Xử lý thanh toán
  ElMessage.success('Đặt hàng thành công!')
  cartItems.value = []
  // Xóa giỏ hàng trong localStorage
  localStorage.removeItem('cart')
}
</script>

<style scoped>
.cart {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

h2 {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
}

.empty-cart {
  padding: 4rem 0;
}

.product-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
}

.cart-summary {
  margin-top: 2rem;
  padding: 1rem;
  background: #f5f7fa;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total {
  font-size: 1.2rem;
  color: #666;
}

.total-price {
  font-size: 1.5rem;
  color: #f56c6c;
  font-weight: bold;
  margin-left: 1rem;
}
</style> 