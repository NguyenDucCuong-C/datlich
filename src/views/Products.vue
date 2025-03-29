<template>
  <div class="products-page">
    <h1 class="page-title">Sản phẩm của chúng tôi</h1>

    <!-- Filters -->
    <div class="filters">
      <el-select v-model="selectedCategory" placeholder="Chọn danh mục" clearable>
        <el-option
          v-for="category in categories"
          :key="category.maDanhMuc"
          :label="category.tenDanhMuc"
          :value="category.maDanhMuc"
        />
      </el-select>
      <el-input
        v-model="searchQuery"
        placeholder="Tìm kiếm sản phẩm..."
        class="search-input"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
    </div>

    <!-- Products Grid -->
    <div class="products-grid">
      <el-card 
        v-for="product in filteredProducts" 
        :key="product.maSanPham" 
        class="product-card"
        @click="viewProduct(product)">
        <el-image 
          :src="product.hinhAnh" 
          :alt="product.tenSanPham" 
          fit="cover" 
          class="product-image" />
        <div class="product-info">
          <h3 class="product-name">{{ product.tenSanPham }}</h3>
          <div class="product-price">{{ formatPrice(product.gia) }}</div>
          <div class="product-meta">
            <span>
              <el-icon><Box /></el-icon>
              Còn lại: {{ product.soLuong }}
            </span>
            <span>
              <el-icon><View /></el-icon>
              Đã xem: {{ product.views }}
            </span>
          </div>
          <div class="product-description">{{ product.moTa }}</div>
        </div>
      </el-card>
    </div>

    <!-- Empty State -->
    <el-empty
      v-if="filteredProducts.length === 0"
      description="Không tìm thấy sản phẩm nào"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, Box, View } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const products = ref([])
const categories = ref([])
const selectedCategory = ref('')
const searchQuery = ref('')

const filteredProducts = computed(() => {
  let filtered = products.value || []
  
  if (selectedCategory.value) {
    filtered = filtered.filter(product => product.maDanhMuc === selectedCategory.value)
  }
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(product => 
      product.tenSanPham.toLowerCase().includes(query) ||
      product.moTa.toLowerCase().includes(query)
    )
  }
  
  return filtered
})

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const viewProduct = (product) => {
  // Tăng số lượt xem
  const updatedProducts = products.value.map(p => {
    if (p.maSanPham === product.maSanPham) {
      return { ...p, views: (p.views || 0) + 1 }
    }
    return p
  })
  
  // Cập nhật localStorage
  localStorage.setItem('products', JSON.stringify(updatedProducts))
  products.value = updatedProducts
  
  // Chuyển đến trang chi tiết
  router.push(`/product/${product.maSanPham}`)
}

const loadProducts = () => {
  try {
    const savedProducts = localStorage.getItem('products')
    if (savedProducts) {
      products.value = JSON.parse(savedProducts)
    } else {
      // Nếu chưa có dữ liệu, tạo dữ liệu mẫu
      const sampleProducts = [
        {
          maSanPham: '1',
          tenSanPham: 'Dầu gội thảo dược',
          gia: 150000,
          soLuong: 100,
          views: 0,
          moTa: 'Dầu gội thảo dược thiên nhiên, giúp tóc chắc khỏe và suôn mượt.',
          hinhAnh: '/images/products/shampoo.jpg',
          maDanhMuc: '1'
        },
        {
          maSanPham: '2',
          tenSanPham: 'Sữa tắm dưỡng ẩm',
          gia: 180000,
          soLuong: 80,
          views: 0,
          moTa: 'Sữa tắm dưỡng ẩm, giúp da mềm mại và thơm mát.',
          hinhAnh: '/images/products/body-wash.jpg',
          maDanhMuc: '2'
        }
      ]
      localStorage.setItem('products', JSON.stringify(sampleProducts))
      products.value = sampleProducts
    }
  } catch (error) {
    console.error('Error loading products:', error)
    ElMessage.error('Không thể tải danh sách sản phẩm')
  }
}

const loadCategories = () => {
  try {
    const savedCategories = localStorage.getItem('categories')
    if (savedCategories) {
      categories.value = JSON.parse(savedCategories)
    } else {
      // Nếu chưa có dữ liệu, tạo dữ liệu mẫu
      const sampleCategories = [
        {
          maDanhMuc: '1',
          tenDanhMuc: 'Chăm sóc tóc'
        },
        {
          maDanhMuc: '2',
          tenDanhMuc: 'Chăm sóc da'
        }
      ]
      localStorage.setItem('categories', JSON.stringify(sampleCategories))
      categories.value = sampleCategories
    }
  } catch (error) {
    console.error('Error loading categories:', error)
    ElMessage.error('Không thể tải danh sách danh mục')
  }
}

// Watch for changes in localStorage
window.addEventListener('storage', (e) => {
  if (e.key === 'products') {
    loadProducts()
  } else if (e.key === 'categories') {
    loadCategories()
  }
})

onMounted(() => {
  loadProducts()
  loadCategories()
})
</script>

<style scoped>
.products-page {
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

.filters {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.search-input {
  flex: 1;
  max-width: 400px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.product-card {
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.product-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.product-info {
  padding: 15px;
}

.product-name {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 10px;
}

.product-price {
  font-size: 20px;
  color: #f56c6c;
  font-weight: bold;
  margin-bottom: 10px;
}

.product-meta {
  display: flex;
  gap: 15px;
  color: #909399;
  font-size: 14px;
  margin-bottom: 10px;
}

.product-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
}

.product-description {
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

@media (max-width: 768px) {
  .filters {
    flex-direction: column;
  }

  .search-input {
    width: 100%;
  }

  .products-grid {
    grid-template-columns: 1fr;
  }
}
</style> 