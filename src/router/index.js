import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
import Home from '../views/Home.vue'
import Booking from '../views/Booking.vue'
import Products from '../views/Products.vue'
import ProductDetail from '../views/ProductDetail.vue'
import Services from '../views/Services.vue'
import ServiceDetail from '../views/ServiceDetail.vue'
import Cart from '../views/Cart.vue'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import ClientLayout from '../views/ClientLayout.vue'
import AdminLayout from '../views/admin/AdminLayout.vue'
import AdminDashboard from '../views/admin/Dashboard.vue'
import AdminProducts from '../views/admin/Products.vue'
import AdminOrders from '../views/admin/Orders.vue'
import AdminStaff from '../views/admin/Staff.vue'
import AdminServices from '../views/admin/Services.vue'
import AdminBookings from '../views/admin/Bookings.vue'
import AdminStorage from '../views/admin/StorageManager.vue'
import Orders from '../views/Orders.vue'
import { userApi } from '@/api/user'
import { hasRole, hasPermission } from '@/utils/permissions'

const routes = [
  {
    path: '/',
    component: ClientLayout,
    children: [
      {
        path: '',
        name: 'Home',
        component: Home,
        meta: { title: 'Trang chủ' }
      },
      {
        path: 'booking',
        name: 'Booking',
        component: Booking,
        meta: { 
          requiresAuth: true,
          title: 'Đặt lịch'
        }
      },
      {
        path: 'bookings',
        name: 'Bookings',
        component: () => import('../views/Bookings.vue'),
        meta: { 
          requiresAuth: true,
          title: 'Lịch hẹn của tôi'
        }
      },
      {
        path: 'products',
        name: 'Products',
        component: Products,
        meta: { title: 'Sản phẩm' }
      },
      {
        path: 'products/:id',
        name: 'ProductDetail',
        component: ProductDetail,
        meta: { title: 'Chi tiết sản phẩm' }
      },
      {
        path: 'services',
        name: 'Services',
        component: Services,
        meta: { title: 'Dịch vụ' }
      },
      {
        path: 'services/:id',
        name: 'ServiceDetail',
        component: ServiceDetail,
        meta: { title: 'Chi tiết dịch vụ' }
      },
      {
        path: 'cart',
        name: 'Cart',
        component: Cart,
        meta: { 
          requiresAuth: true,
          title: 'Giỏ hàng'
        }
      },
      {
        path: 'orders',
        name: 'Orders',
        component: Orders,
        meta: { 
          requiresAuth: true,
          title: 'Đơn hàng của tôi'
        }
      },
      {
        path: 'login',
        name: 'Login',
        component: Login,
        meta: { 
          title: 'Đăng nhập',
          guest: true
        }
      },
      {
        path: 'register',
        name: 'Register',
        component: Register,
        meta: { 
          title: 'Đăng ký',
          guest: true
        }
      }
    ]
  },
  {
    path: '/admin',
    component: AdminLayout,
    meta: { 
      requiresAuth: true, 
      requiresAdmin: true,
      title: 'Quản trị'
    },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: AdminDashboard,
        meta: { title: 'Tổng quan' }
      },
      {
        path: 'products',
        name: 'AdminProducts',
        component: AdminProducts,
        meta: { title: 'Quản lý sản phẩm' }
      },
      {
        path: 'orders',
        name: 'AdminOrders',
        component: AdminOrders,
        meta: { title: 'Quản lý đơn hàng' }
      },
      {
        path: 'staff',
        name: 'AdminStaff',
        component: AdminStaff,
        meta: { title: 'Quản lý nhân viên' }
      },
      {
        path: 'services',
        name: 'AdminServices',
        component: AdminServices,
        meta: { title: 'Quản lý dịch vụ' }
      },
      {
        path: 'bookings',
        name: 'AdminBookings',
        component: AdminBookings,
        meta: { title: 'Quản lý lịch hẹn' }
      },
      {
        path: 'storage',
        name: 'AdminStorage',
        component: AdminStorage,
        meta: { title: 'Quản lý kho' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// Navigation guard
router.beforeEach((to, from, next) => {
  // Set page title
  document.title = `${to.meta.title} - Salon Beauty`

  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin)
  const requiresStaff = to.matched.some(record => record.meta.requiresStaff)
  const requiredPermission = to.meta.permission

  const isAuthenticated = userApi.isAuthenticated()
  const user = userApi.getCurrentUser()

  // Nếu route yêu cầu xác thực
  if (requiresAuth) {
    if (!isAuthenticated) {
      ElMessage.warning('Vui lòng đăng nhập để tiếp tục!')
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else if (requiresAdmin && !hasRole(user, 'ADMIN')) {
      ElMessage.error('Bạn không có quyền truy cập trang này!')
      next('/')
    } else if (requiresStaff && !hasRole(user, 'STAFF')) {
      ElMessage.error('Bạn không có quyền truy cập trang này!')
      next('/')
    } else if (requiredPermission && !hasPermission(user, requiredPermission)) {
      ElMessage.error('Bạn không có quyền truy cập trang này!')
      next('/')
    } else {
      next()
    }
  } else if (to.path === '/login' && isAuthenticated) {
    // Đã đăng nhập, không cho phép vào trang login
    next({ path: '/' })
  } else {
    next()
  }
})

// After navigation
router.afterEach(() => {
  // Reset scroll position
  window.scrollTo(0, 0)
})

export default router 