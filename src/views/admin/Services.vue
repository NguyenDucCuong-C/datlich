<template>
  <div class="services">
    <div class="header">
      <h2>Quản lý dịch vụ</h2>
      <el-button type="primary" @click="showAddDialog">
        Thêm dịch vụ mới
      </el-button>
    </div>

    <el-table :data="services" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="Tên dịch vụ" width="150" />
      <el-table-column prop="description" label="Mô tả" />
      <el-table-column prop="price" label="Giá" width="150">
        <template #default="{ row }">
          {{ formatPrice(row.price) }}
        </template>
      </el-table-column>
      <el-table-column prop="duration" label="Thời gian" width="120">
        <template #default="{ row }">
          {{ row.duration }} phút
        </template>
      </el-table-column>
      <el-table-column label="Thao tác" width="150">
        <template #default="{ row }">
          <el-button-group>
            <el-button type="primary" size="small" @click="editService(row)">
              Sửa
            </el-button>
            <el-button type="danger" size="small" @click="deleteService(row)">
              Xóa
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog thêm/sửa dịch vụ -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEditing ? 'Sửa dịch vụ' : 'Thêm dịch vụ mới'"
      width="50%"
    >
      <el-form
        ref="formRef"
        :model="serviceForm"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="Tên dịch vụ" prop="name">
          <el-input v-model="serviceForm.name" />
        </el-form-item>
        <el-form-item label="Mô tả" prop="description">
          <el-input
            v-model="serviceForm.description"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
        <el-form-item label="Giá" prop="price">
          <el-input-number
            v-model="serviceForm.price"
            :min="0"
            :step="10000"
            :precision="0"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="Thời gian" prop="duration">
          <el-input-number
            v-model="serviceForm.duration"
            :min="15"
            :step="15"
            :precision="0"
            style="width: 100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="submitForm">
            {{ isEditing ? 'Cập nhật' : 'Thêm mới' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const services = ref([])
const dialogVisible = ref(false)
const isEditing = ref(false)
const formRef = ref(null)
const serviceForm = ref({
  name: '',
  description: '',
  price: 0,
  duration: 30
})

const rules = {
  name: [
    { required: true, message: 'Vui lòng nhập tên dịch vụ', trigger: 'blur' }
  ],
  description: [
    { required: true, message: 'Vui lòng nhập mô tả dịch vụ', trigger: 'blur' }
  ],
  price: [
    { required: true, message: 'Vui lòng nhập giá dịch vụ', trigger: 'blur' }
  ],
  duration: [
    { required: true, message: 'Vui lòng nhập thời gian thực hiện', trigger: 'blur' }
  ]
}

onMounted(() => {
  loadServices()
})

const loadServices = () => {
  loading.value = true
  // Giả lập API call
  setTimeout(() => {
    services.value = JSON.parse(localStorage.getItem('services') || '[]')
    loading.value = false
  }, 500)
}

const showAddDialog = () => {
  isEditing.value = false
  serviceForm.value = {
    name: '',
    description: '',
    price: 0,
    duration: 30
  }
  dialogVisible.value = true
}

const editService = (service) => {
  isEditing.value = true
  serviceForm.value = { ...service }
  dialogVisible.value = true
}

const deleteService = async (service) => {
  try {
    await ElMessageBox.confirm(
      `Bạn có chắc muốn xóa dịch vụ "${service.name}"?`,
      'Xác nhận',
      {
        confirmButtonText: 'Đồng ý',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const updatedServices = services.value.filter(s => s.id !== service.id)
    localStorage.setItem('services', JSON.stringify(updatedServices))
    services.value = updatedServices
    ElMessage.success('Xóa dịch vụ thành công!')
  } catch {
    // User cancelled
  }
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const submitForm = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate((valid) => {
    if (valid) {
      if (isEditing.value) {
        // Cập nhật dịch vụ
        const updatedServices = services.value.map(s => {
          if (s.id === serviceForm.value.id) {
            return { ...serviceForm.value }
          }
          return s
        })
        localStorage.setItem('services', JSON.stringify(updatedServices))
        services.value = updatedServices
        ElMessage.success('Cập nhật dịch vụ thành công!')
      } else {
        // Thêm dịch vụ mới
        const newService = {
          ...serviceForm.value,
          id: Date.now().toString()
        }
        services.value.push(newService)
        localStorage.setItem('services', JSON.stringify(services.value))
        ElMessage.success('Thêm dịch vụ mới thành công!')
      }
      dialogVisible.value = false
    }
  })
}
</script>

<style scoped>
.services {
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 