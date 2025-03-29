<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <h2>{{ isLogin ? 'Đăng nhập' : 'Đăng ký' }}</h2>
        </div>
      </template>
      
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        @submit.prevent="handleSubmit"
      >
        <el-form-item label="Tên đăng nhập" prop="tenDangNhap">
          <el-input v-model="form.tenDangNhap" placeholder="Nhập tên đăng nhập" />
        </el-form-item>

        <el-form-item label="Mật khẩu" prop="matKhau">
          <el-input
            v-model="form.matKhau"
            type="password"
            placeholder="Nhập mật khẩu"
            show-password
          />
        </el-form-item>

        <template v-if="!isLogin">
          <el-form-item label="Xác nhận mật khẩu" prop="confirmPassword">
            <el-input
              v-model="form.confirmPassword"
              type="password"
              placeholder="Nhập lại mật khẩu"
              show-password
            />
          </el-form-item>

          <el-form-item label="Họ tên" prop="hoTen">
            <el-input v-model="form.hoTen" placeholder="Nhập họ tên" />
          </el-form-item>

          <el-form-item label="Email" prop="email">
            <el-input v-model="form.email" placeholder="Nhập email" />
          </el-form-item>

          <el-form-item label="Số điện thoại" prop="soDienThoai">
            <el-input v-model="form.soDienThoai" placeholder="Nhập số điện thoại" />
          </el-form-item>
        </template>

        <el-form-item>
          <el-button
            type="primary"
            native-type="submit"
            :loading="loading"
            class="submit-btn"
          >
            {{ isLogin ? 'Đăng nhập' : 'Đăng ký' }}
          </el-button>
        </el-form-item>

        <div class="switch-form">
          <el-button link @click="isLogin = !isLogin">
            {{ isLogin ? 'Chưa có tài khoản? Đăng ký' : 'Đã có tài khoản? Đăng nhập' }}
          </el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userApi } from '@/api/user'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const isLogin = ref(true)

const form = reactive({
  tenDangNhap: '',
  matKhau: '',
  confirmPassword: '',
  hoTen: '',
  email: '',
  soDienThoai: ''
})

const validatePass = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('Vui lòng nhập mật khẩu'))
  } else {
    if (form.confirmPassword !== '') {
      formRef.value?.validateField('confirmPassword')
    }
    callback()
  }
}

const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('Vui lòng nhập lại mật khẩu'))
  } else if (value !== form.matKhau) {
    callback(new Error('Mật khẩu không khớp'))
  } else {
    callback()
  }
}

const rules = {
  tenDangNhap: [
    { required: true, message: 'Vui lòng nhập tên đăng nhập', trigger: 'blur' },
    { min: 3, max: 20, message: 'Độ dài từ 3 đến 20 ký tự', trigger: 'blur' }
  ],
  matKhau: [
    { required: true, validator: validatePass, trigger: 'blur' },
    { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ],
  hoTen: [
    { required: true, message: 'Vui lòng nhập họ tên', trigger: 'blur' }
  ],
  email: [
    { required: true, message: 'Vui lòng nhập email', trigger: 'blur' },
    { type: 'email', message: 'Email không hợp lệ', trigger: 'blur' }
  ],
  soDienThoai: [
    { required: true, message: 'Vui lòng nhập số điện thoại', trigger: 'blur' },
    { pattern: /^[0-9]{10}$/, message: 'Số điện thoại không hợp lệ', trigger: 'blur' }
  ]
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    loading.value = true

    if (isLogin.value) {
      // Kiểm tra dữ liệu trước khi gửi
      if (!form.tenDangNhap || !form.matKhau) {
        ElMessage.warning('Vui lòng nhập đầy đủ thông tin')
        return
      }

      const response = await userApi.login({
        tenDangNhap: form.tenDangNhap,
        matKhau: form.matKhau
      })
      
      ElMessage.success('Đăng nhập thành công')
      
      // Chuyển hướng dựa trên vai trò
      if (response.role === 'ADMIN') {
        router.push('/admin')
      } else if (response.role === 'STAFF') {
        router.push('/staff')
      } else {
        router.push('/')
      }
    } else {
      // Kiểm tra dữ liệu trước khi gửi
      if (!form.tenDangNhap || !form.matKhau || !form.hoTen || !form.email || !form.soDienThoai) {
        ElMessage.warning('Vui lòng nhập đầy đủ thông tin')
        return
      }

      await userApi.register({
        tenDangNhap: form.tenDangNhap,
        matKhau: form.matKhau,
        hoTen: form.hoTen,
        email: form.email,
        soDienThoai: form.soDienThoai,
        vaiTro: 'USER'
      })
      
      ElMessage.success('Đăng ký thành công')
      isLogin.value = true
      // Reset form
      form.tenDangNhap = ''
      form.matKhau = ''
      form.confirmPassword = ''
      form.hoTen = ''
      form.email = ''
      form.soDienThoai = ''
    }
  } catch (error) {
    console.error('Form submission error:', error)
    ElMessage.error(error.message || 'Có lỗi xảy ra. Vui lòng thử lại.')
  } finally {
    loading.value = false
  }
}

// Thêm hàm reset form
const resetForm = () => {
  if (formRef.value) {
    formRef.value.resetFields()
  }
  form.tenDangNhap = ''
  form.matKhau = ''
  form.confirmPassword = ''
  form.hoTen = ''
  form.email = ''
  form.soDienThoai = ''
}

// Thêm watch để reset form khi chuyển đổi giữa đăng nhập và đăng ký
watch(isLogin, () => {
  resetForm()
})
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f7fa;
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 500px;
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 0;
  color: #303133;
}

.submit-btn {
  width: 100%;
}

.switch-form {
  text-align: center;
  margin-top: 20px;
}
</style> 