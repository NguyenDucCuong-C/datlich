// Định nghĩa các quyền
export const PERMISSIONS = {
  // Quyền quản trị viên
  ADMIN: {
    DASHBOARD: 'admin:dashboard',
    USERS: 'admin:users',
    PRODUCTS: 'admin:products',
    SERVICES: 'admin:services',
    ORDERS: 'admin:orders',
    APPOINTMENTS: 'admin:appointments',
    INVENTORY: 'admin:inventory',
    REPORTS: 'admin:reports'
  },
  // Quyền nhân viên
  STAFF: {
    DASHBOARD: 'staff:dashboard',
    SERVICES: 'staff:services',
    APPOINTMENTS: 'staff:appointments',
    ORDERS: 'staff:orders'
  },
  // Quyền khách hàng
  USER: {
    PROFILE: 'user:profile',
    ORDERS: 'user:orders',
    APPOINTMENTS: 'user:appointments',
    REVIEWS: 'user:reviews'
  }
}

// Định nghĩa các vai trò và quyền tương ứng
export const ROLES = {
  ADMIN: {
    name: 'ADMIN',
    permissions: Object.values(PERMISSIONS.ADMIN)
  },
  STAFF: {
    name: 'STAFF',
    permissions: Object.values(PERMISSIONS.STAFF)
  },
  USER: {
    name: 'USER',
    permissions: Object.values(PERMISSIONS.USER)
  }
}

// Hàm kiểm tra quyền
export const hasPermission = (user, permission) => {
  if (!user || !user.role) return false
  
  const role = ROLES[user.role]
  if (!role) return false
  
  return role.permissions.includes(permission)
}

// Hàm kiểm tra vai trò
export const hasRole = (user, role) => {
  if (!user || !user.role) return false
  return user.role === role
}

// Hàm lấy danh sách quyền của user
export const getUserPermissions = (user) => {
  if (!user || !user.role) return []
  
  const role = ROLES[user.role]
  if (!role) return []
  
  return role.permissions
}

// Directive kiểm tra quyền
export const vPermission = {
  mounted(el, binding) {
    const { value } = binding
    if (value && value.length > 0) {
      const user = JSON.parse(localStorage.getItem('user'))
      const hasPermission = hasPermission(user, value)
      if (!hasPermission) {
        el.parentNode?.removeChild(el)
      }
    }
  }
} 