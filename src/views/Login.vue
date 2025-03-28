<template>
  <div class="login-container">
    <div class="login-box">
      <h2>Đăng nhập</h2>
      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" label-width="0">
        <el-form-item prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="Tên đăng nhập"
            :prefix-icon="User">
          </el-input>
        </el-form-item>

        <el-form-item prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            placeholder="Mật khẩu"
            :prefix-icon="Lock"
            show-password>
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleLogin" class="login-button">
            Đăng nhập
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const loginFormRef = ref(null)

const loginForm = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: 'Vui lòng nhập tên đăng nhập', trigger: 'blur' }
  ],
  password: [
    { required: true, message: 'Vui lòng nhập mật khẩu', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate((valid) => {
    if (valid) {
      // Giả lập API call
      setTimeout(() => {
        // Kiểm tra tài khoản admin
        if (loginForm.username === 'admin' && loginForm.password === 'admin') {
          const user = {
            username: loginForm.username,
            role: 'admin'
          }
          localStorage.setItem('user', JSON.stringify(user))
          ElMessage.success('Đăng nhập thành công!')
          router.push('/admin')
        } 
        // Kiểm tra tài khoản client
        else if (loginForm.username === 'user' && loginForm.password === 'user') {
          const user = {
            username: loginForm.username,
            role: 'user'
          }
          localStorage.setItem('user', JSON.stringify(user))
          ElMessage.success('Đăng nhập thành công!')
          // Chuyển hướng về trang được yêu cầu hoặc trang chủ
          const redirectPath = route.query.redirect || '/'
          router.push(redirectPath)
        } 
        // Sai thông tin đăng nhập
        else {
          ElMessage.error('Tên đăng nhập hoặc mật khẩu không đúng!')
        }
      }, 500)
    }
  })
}
</script>

<style scoped>
.login-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-box {
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

.login-button {
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

.login-button:hover {
  background: #66b1ff;
}

:deep(.el-input__wrapper) {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

:deep(.el-input__wrapper:hover) {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}
</style> 