<template>
  <div class="admin-products">
    <div class="page-header">
      <h2>Quản lý sản phẩm</h2>
      <el-button type="primary" @click="showAddDialog">
        <el-icon><Plus /></el-icon>
        Thêm sản phẩm
      </el-button>
    </div>

    <el-table :data="products" style="width: 100%" v-loading="loading">
      <el-table-column prop="image" label="Hình ảnh" width="120">
        <template #default="scope">
          <el-image 
            :src="scope.row.image" 
            :preview-src-list="[scope.row.image]"
            fit="cover"
            class="product-image">
          </el-image>
        </template>
      </el-table-column>
      
      <el-table-column prop="name" label="Tên sản phẩm"></el-table-column>
      
      <el-table-column prop="description" label="Mô tả"></el-table-column>
      
      <el-table-column prop="price" label="Giá" width="150">
        <template #default="scope">
          {{ formatPrice(scope.row.price) }}
        </template>
      </el-table-column>
      
      <el-table-column label="Thao tác" width="200">
        <template #default="scope">
          <el-button 
            type="primary" 
            size="small" 
            @click="showEditDialog(scope.row)">
            <el-icon><Edit /></el-icon>
          </el-button>
          <el-button 
            type="danger" 
            size="small" 
            @click="handleDelete(scope.row)">
            <el-icon><Delete /></el-icon>
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog thêm/sửa sản phẩm -->
    <el-dialog
      :title="dialogType === 'add' ? 'Thêm sản phẩm' : 'Sửa sản phẩm'"
      v-model="dialogVisible"
      width="500px">
      <el-form 
        :model="productForm" 
        :rules="rules" 
        ref="productFormRef"
        label-width="100px">
        <el-form-item label="Tên sản phẩm" prop="name">
          <el-input v-model="productForm.name"></el-input>
        </el-form-item>
        
        <el-form-item label="Mô tả" prop="description">
          <el-input 
            type="textarea" 
            v-model="productForm.description"
            :rows="3">
          </el-input>
        </el-form-item>
        
        <el-form-item label="Giá" prop="price">
          <el-input-number 
            v-model="productForm.price" 
            :min="0"
            :step="10000">
          </el-input-number>
        </el-form-item>
        
        <el-form-item label="Hình ảnh" prop="image">
          <el-input v-model="productForm.image" placeholder="URL hình ảnh"></el-input>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="handleSubmit">
            {{ dialogType === 'add' ? 'Thêm' : 'Cập nhật' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Edit, Delete } from '@element-plus/icons-vue'

const loading = ref(false)
const products = ref([])
const dialogVisible = ref(false)
const dialogType = ref('add')
const productFormRef = ref(null)

const productForm = reactive({
  name: '',
  description: '',
  price: 0,
  image: ''
})

const rules = {
  name: [
    { required: true, message: 'Vui lòng nhập tên sản phẩm', trigger: 'blur' }
  ],
  description: [
    { required: true, message: 'Vui lòng nhập mô tả', trigger: 'blur' }
  ],
  price: [
    { required: true, message: 'Vui lòng nhập giá', trigger: 'blur' }
  ],
  image: [
    { required: true, message: 'Vui lòng nhập URL hình ảnh', trigger: 'blur' }
  ]
}

onMounted(() => {
  loadProducts()
})

const loadProducts = () => {
  loading.value = true
  // Giả lập API call
  setTimeout(() => {
    products.value = JSON.parse(localStorage.getItem('products') || '[]')
    loading.value = false
  }, 500)
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const showAddDialog = () => {
  dialogType.value = 'add'
  Object.assign(productForm, {
    name: '',
    description: '',
    price: 0,
    image: ''
  })
  dialogVisible.value = true
}

const showEditDialog = (product) => {
  dialogType.value = 'edit'
  Object.assign(productForm, product)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!productFormRef.value) return
  
  await productFormRef.value.validate((valid) => {
    if (valid) {
      if (dialogType.value === 'add') {
        products.value.push({
          id: Date.now(),
          ...productForm
        })
        ElMessage.success('Thêm sản phẩm thành công!')
      } else {
        const index = products.value.findIndex(p => p.id === productForm.id)
        if (index > -1) {
          products.value[index] = { ...productForm }
          ElMessage.success('Cập nhật sản phẩm thành công!')
        }
      }
      
      // Lưu vào localStorage
      localStorage.setItem('products', JSON.stringify(products.value))
      dialogVisible.value = false
    }
  })
}

const handleDelete = (product) => {
  ElMessageBox.confirm(
    'Bạn có chắc chắn muốn xóa sản phẩm này?',
    'Xác nhận',
    {
      confirmButtonText: 'Có',
      cancelButtonText: 'Không',
      type: 'warning'
    }
  ).then(() => {
    const index = products.value.findIndex(p => p.id === product.id)
    if (index > -1) {
      products.value.splice(index, 1)
      localStorage.setItem('products', JSON.stringify(products.value))
      ElMessage.success('Xóa sản phẩm thành công!')
    }
  }).catch(() => {
    ElMessage.info('Đã hủy thao tác')
  })
}
</script>

<style scoped>
.admin-products {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #333;
}

.product-image {
  width: 80px;
  height: 80px;
  border-radius: 4px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 