import { reactive } from 'vue'
import { userApi } from '@/api/user'

export const store = reactive({
  user: null,
  cart: [],
  loading: false,
  error: null,

  // Khởi tạo state
  init() {
    this.user = userApi.getCurrentUser()
    this.loadCart()
  },

  // Cập nhật thông tin user
  setUser(user) {
    this.user = user
  },

  // Xóa thông tin user
  clearUser() {
    this.user = null
    userApi.logout()
  },

  // Thêm sản phẩm vào giỏ hàng
  addToCart(product) {
    const existingItem = this.cart.find(item => item.id === product.id)
    if (existingItem) {
      existingItem.quantity++
    } else {
      this.cart.push({
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1
      })
    }
    this.saveCart()
  },

  // Xóa sản phẩm khỏi giỏ hàng
  removeFromCart(productId) {
    this.cart = this.cart.filter(item => item.id !== productId)
    this.saveCart()
  },

  // Cập nhật số lượng sản phẩm trong giỏ hàng
  updateQuantity(productId, quantity) {
    const item = this.cart.find(item => item.id === productId)
    if (item) {
      item.quantity = quantity
      if (quantity <= 0) {
        this.removeFromCart(productId)
      } else {
        this.saveCart()
      }
    }
  },

  // Tính tổng tiền giỏ hàng
  getCartTotal() {
    return this.cart.reduce((total, item) => total + (item.price * item.quantity), 0)
  },

  // Lưu giỏ hàng vào localStorage
  saveCart() {
    localStorage.setItem('cart', JSON.stringify(this.cart))
  },

  // Load giỏ hàng từ localStorage
  loadCart() {
    const savedCart = localStorage.getItem('cart')
    if (savedCart) {
      this.cart = JSON.parse(savedCart)
    }
  },

  // Xóa giỏ hàng
  clearCart() {
    this.cart = []
    localStorage.removeItem('cart')
  },

  // Set loading state
  setLoading(loading) {
    this.loading = loading
  },

  // Set error message
  setError(error) {
    this.error = error
  }
}) 