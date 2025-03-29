<template>
  <div class="register-container">
    <div class="register-box">
      <h2>Đăng ký tài khoản</h2>
      <el-form :model="registerForm" :rules="rules" ref="registerFormRef" label-width="0">
        <el-form-item prop="username">
          <el-input 
            v-model="registerForm.username" 
            placeholder="Tên đăng nhập"
            :prefix-icon="User">
          </el-input>
        </el-form-item>

        <el-form-item prop="password">
          <el-input 
            v-model="registerForm.password" 
            type="password" 
            placeholder="Mật khẩu"
            :prefix-icon="Lock"
            show-password>
          </el-input>
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <el-input 
            v-model="registerForm.confirmPassword" 
            type="password" 
            placeholder="Xác nhận mật khẩu"
            :prefix-icon="Lock"
            show-password>
          </el-input>
        </el-form-item>

        <el-form-item prop="name">
          <el-input 
            v-model="registerForm.name" 
            placeholder="Họ và tên"
            :prefix-icon="User">
          </el-input>
        </el-form-item>

        <el-form-item prop="phone">
          <el-input 
            v-model="registerForm.phone" 
            placeholder="Số điện thoại"
            :prefix-icon="Phone">
          </el-input>
        </el-form-item>

        <el-form-item prop="address">
          <el-input 
            v-model="registerForm.address" 
            placeholder="Địa chỉ"
            :prefix-icon="Location">
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleRegister" class="register-button">
            Đăng ký
          </el-button>
        </el-form-item>

        <div class="login-link">
          Đã có tài khoản? <router-link to="/login">Đăng nhập</router-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, Phone, Location } from '@element-plus/icons-vue'

const router = useRouter()
const registerFormRef = ref(null)

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  name: '',
  phone: '',
  address: ''
})

const validatePass = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('Vui lòng nhập mật khẩu'))
  } else {
    if (registerForm.confirmPassword !== '') {
      registerFormRef.value?.validateField('confirmPassword')
    }
    callback()
  }
}

const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('Vui lòng xác nhận mật khẩu'))
  } else if (value !== registerForm.password) {
    callback(new Error('Mật khẩu không khớp!'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: 'Vui lòng nhập tên đăng nhập', trigger: 'blur' },
    { min: 3, max: 20, message: 'Độ dài từ 3 đến 20 ký tự', trigger: 'blur' }
  ],
  password: [
    { required: true, validator: validatePass, trigger: 'blur' },
    { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validatePass2, trigger: 'blur' }
  ],
  name: [
    { required: true, message: 'Vui lòng nhập họ và tên', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: 'Vui lòng nhập số điện thoại', trigger: 'blur' },
    { pattern: /^[0-9]{10}$/, message: 'Số điện thoại không hợp lệ', trigger: 'blur' }
  ],
  address: [
    { required: true, message: 'Vui lòng nhập địa chỉ', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate((valid) => {
    if (valid) {
      // Lấy danh sách người dùng từ localStorage
      const users = JSON.parse(localStorage.getItem('users') || '[]')
      
      // Kiểm tra username đã tồn tại chưa
      if (users.some(user => user.username === registerForm.username)) {
        ElMessage.error('Tên đăng nhập đã tồn tại!')
        return
      }

      // Tạo user mới
      const newUser = {
        id: Date.now(),
        username: registerForm.username,
        password: registerForm.password,
        name: registerForm.name,
        phone: registerForm.phone,
        address: registerForm.address,
        role: 'user'
      }

      // Thêm user mới vào danh sách
      users.push(newUser)
      localStorage.setItem('users', JSON.stringify(users))

      ElMessage.success('Đăng ký thành công!')
      router.push('/login')
    }
  })
}
</script>

<style scoped>
.register-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-box {
  width: 400px;
  padding: 40px;
  background: white;
  border-radius: 10px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

h2 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
  font-size: 28px;
}

.register-button {
  width: 100%;
  padding: 12px;
  font-size: 16px;
  background: #409EFF;
  border: none;
  border-radius: 5px;
  color: white;
  cursor: pointer;
  transition: background 0.3s;
}

.register-button:hover {
  background: #66b1ff;
}

.login-link {
  text-align: center;
  margin-top: 20px;
  color: #606266;
}

.login-link a {
  color: #409EFF;
  text-decoration: none;
}

.login-link a:hover {
  text-decoration: underline;
}
</style> 