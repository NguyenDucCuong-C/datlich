import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
import Home from '../views/Home.vue'
import Booking from '../views/Booking.vue'
import Products from '../views/Products.vue'
import Cart from '../views/Cart.vue'
import Login from '../views/Login.vue'
import ClientLayout from '../views/ClientLayout.vue'
import AdminLayout from '../views/admin/AdminLayout.vue'
import AdminDashboard from '../views/admin/Dashboard.vue'
import AdminProducts from '../views/admin/Products.vue'
import AdminOrders from '../views/admin/Orders.vue'
import AdminStaff from '../views/admin/Staff.vue'
import AdminServices from '../views/admin/Services.vue'
import AdminBookings from '../views/admin/Bookings.vue'

const routes = [
  {
    path: '/',
    component: ClientLayout,
    children: [
      {
        path: '',
        name: 'Home',
        component: Home
      },
      {
        path: 'booking',
        name: 'Booking',
        component: Booking,
        meta: { requiresAuth: true }
      },
      {
        path: 'bookings',
        name: 'Bookings',
        component: () => import('../views/Bookings.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'products',
        name: 'Products',
        component: Products
      },
      {
        path: 'cart',
        name: 'Cart',
        component: Cart,
        meta: { requiresAuth: true }
      },
      {
        path: 'login',
        name: 'Login',
        component: Login
      }
    ]
  },
  {
    path: '/admin',
    component: AdminLayout,
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: AdminDashboard
      },
      {
        path: 'products',
        name: 'AdminProducts',
        component: AdminProducts
      },
      {
        path: 'orders',
        name: 'AdminOrders',
        component: AdminOrders
      },
      {
        path: 'staff',
        name: 'AdminStaff',
        component: AdminStaff
      },
      {
        path: 'services',
        name: 'AdminServices',
        component: AdminServices
      },
      {
        path: 'bookings',
        name: 'AdminBookings',
        component: AdminBookings
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach((to, from, next) => {
  const isAuthenticated = localStorage.getItem('user')
  const user = isAuthenticated ? JSON.parse(isAuthenticated) : null
  const isAdmin = user?.role === 'admin'

  if (to.meta.requiresAuth && !isAuthenticated) {
    ElMessage.warning('Vui lòng đăng nhập để tiếp tục!')
    next({
      path: '/login',
      query: { redirect: to.fullPath }
    })
  } else if (to.meta.requiresAdmin && !isAdmin) {
    next('/')
  } else {
    next()
  }
})

export default router 