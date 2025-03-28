<template>
  <div class="staff">
    <div class="header">
      <h2>Quản lý thợ cắt</h2>
      <el-button type="primary" @click="showAddDialog">
        Thêm thợ mới
      </el-button>
    </div>

    <el-table :data="staff" style="width: 100%" v-loading="loading">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="Họ tên" width="150" />
      <el-table-column prop="phone" label="Số điện thoại" width="120" />
      <el-table-column prop="email" label="Email" width="200" />
      <el-table-column prop="specialty" label="Chuyên môn" />
      <el-table-column prop="status" label="Trạng thái" width="120">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
            {{ row.status === 'active' ? 'Đang làm việc' : 'Đã nghỉ việc' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="Thao tác" width="200">
        <template #default="{ row }">
          <el-button-group>
            <el-button type="primary" size="small" @click="editStaff(row)">
              Sửa
            </el-button>
            <el-button 
              :type="row.status === 'active' ? 'danger' : 'success'"
              size="small" 
              @click="toggleStatus(row)"
            >
              {{ row.status === 'active' ? 'Nghỉ việc' : 'Đi làm lại' }}
            </el-button>
          </el-button-group>
        </template>
      </el-table-column>
    </el-table>

    <!-- Dialog thêm/sửa thợ -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEditing ? 'Sửa thông tin thợ' : 'Thêm thợ mới'"
      width="50%"
    >
      <el-form
        ref="formRef"
        :model="staffForm"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="Họ tên" prop="name">
          <el-input v-model="staffForm.name" />
        </el-form-item>
        <el-form-item label="Số điện thoại" prop="phone">
          <el-input v-model="staffForm.phone" />
        </el-form-item>
        <el-form-item label="Email" prop="email">
          <el-input v-model="staffForm.email" />
        </el-form-item>
        <el-form-item label="Chuyên môn" prop="specialties">
          <el-select
            v-model="staffForm.specialties"
            multiple
            placeholder="Chọn chuyên môn"
            style="width: 100%"
          >
            <el-option
              v-for="service in services"
              :key="service.id"
              :label="service.name"
              :value="service.id"
            >
              <span>{{ service.name }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">
                {{ formatPrice(service.price) }}
              </span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="Trạng thái" prop="status">
          <el-radio-group v-model="staffForm.status">
            <el-radio label="active">Đang làm việc</el-radio>
            <el-radio label="inactive">Đã nghỉ việc</el-radio>
          </el-radio-group>
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
const staff = ref([])
const services = ref([])
const dialogVisible = ref(false)
const isEditing = ref(false)
const formRef = ref(null)
const staffForm = ref({
  name: '',
  phone: '',
  email: '',
  specialties: [],
  status: 'active'
})

const rules = {
  name: [
    { required: true, message: 'Vui lòng nhập họ tên', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: 'Vui lòng nhập số điện thoại', trigger: 'blur' },
    { pattern: /^[0-9]{10}$/, message: 'Số điện thoại không hợp lệ', trigger: 'blur' }
  ],
  email: [
    { required: true, message: 'Vui lòng nhập email', trigger: 'blur' },
    { type: 'email', message: 'Email không hợp lệ', trigger: 'blur' }
  ],
  specialties: [
    { required: true, message: 'Vui lòng chọn ít nhất một chuyên môn', trigger: 'change' }
  ]
}

onMounted(() => {
  loadStaff()
  loadServices()
})

const loadStaff = () => {
  loading.value = true
  // Giả lập API call
  setTimeout(() => {
    staff.value = JSON.parse(localStorage.getItem('staff') || '[]')
    loading.value = false
  }, 500)
}

const loadServices = () => {
  services.value = JSON.parse(localStorage.getItem('services') || '[]')
}

const showAddDialog = () => {
  isEditing.value = false
  staffForm.value = {
    name: '',
    phone: '',
    email: '',
    specialties: [],
    status: 'active'
  }
  dialogVisible.value = true
}

const editStaff = (staffMember) => {
  isEditing.value = true
  staffForm.value = { ...staffMember }
  dialogVisible.value = true
}

const toggleStatus = async (staffMember) => {
  try {
    const action = staffMember.status === 'active' ? 'nghỉ việc' : 'đi làm lại'
    await ElMessageBox.confirm(
      `Bạn có chắc muốn ${action} thợ ${staffMember.name}?`,
      'Xác nhận',
      {
        confirmButtonText: 'Đồng ý',
        cancelButtonText: 'Hủy',
        type: 'warning'
      }
    )

    const updatedStaff = staff.value.map(s => {
      if (s.id === staffMember.id) {
        return {
          ...s,
          status: s.status === 'active' ? 'inactive' : 'active'
        }
      }
      return s
    })

    localStorage.setItem('staff', JSON.stringify(updatedStaff))
    staff.value = updatedStaff
    ElMessage.success(`Đã ${action} thợ ${staffMember.name}!`)
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
        // Cập nhật thợ
        const updatedStaff = staff.value.map(s => {
          if (s.id === staffForm.value.id) {
            return { ...staffForm.value }
          }
          return s
        })
        localStorage.setItem('staff', JSON.stringify(updatedStaff))
        staff.value = updatedStaff
        ElMessage.success('Cập nhật thông tin thợ thành công!')
      } else {
        // Thêm thợ mới
        const newStaff = {
          ...staffForm.value,
          id: Date.now().toString()
        }
        staff.value.push(newStaff)
        localStorage.setItem('staff', JSON.stringify(staff.value))
        ElMessage.success('Thêm thợ mới thành công!')
      }
      dialogVisible.value = false
    }
  })
}
</script>

<style scoped>
.staff {
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