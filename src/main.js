import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'
import router from './router'
import './assets/main.css'
import { vPermission } from './utils/permissions'

const app = createApp(App)

app.use(router)
app.use(ElementPlus)

// Đăng ký directive phân quyền
app.directive('permission', vPermission)

app.mount('#app') 