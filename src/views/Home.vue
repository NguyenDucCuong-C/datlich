<template>
  <div class="home">
    <!-- Hero Section -->
    <div class="hero">
      <el-carousel height="500px">
        <el-carousel-item v-for="(item, index) in banners" :key="index">
          <img :src="item.image" :alt="item.title" class="banner-image">
          <div class="banner-content">
            <h2>{{ item.title }}</h2>
            <p>{{ item.description }}</p>
            <el-button type="primary" size="large" @click="scrollToServices">
              Khám phá ngay
            </el-button>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- Services Section -->
    <div class="services" ref="servicesSection">
      <h2 class="section-title">Dịch vụ của chúng tôi</h2>
      <div class="service-grid">
        <el-card v-for="service in services" :key="service.maDichVu" class="service-card" shadow="hover">
          <img :src="service.hinhAnh" :alt="service.tenDichVu" class="service-image">
          <div class="service-content">
            <h3>{{ service.tenDichVu }}</h3>
            <p>{{ service.moTa }}</p>
            <div class="service-footer">
              <span class="price">{{ formatPrice(service.gia) }}</span>
              <el-button type="primary" @click="bookService(service)">Đặt lịch</el-button>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- Products Section -->
    <div class="products">
      <h2 class="section-title">Sản phẩm bán chạy</h2>
      <div class="product-grid">
        <el-card v-for="product in products" :key="product.maSanPham" class="product-card" shadow="hover">
          <img :src="product.hinhAnh" :alt="product.tenSanPham" class="product-image">
          <div class="product-content">
            <h3>{{ product.tenSanPham }}</h3>
            <p>{{ product.moTa }}</p>
            <div class="product-footer">
              <span class="price">{{ formatPrice(product.gia) }}</span>
              <el-button type="primary" @click="viewProduct(product)">Chi tiết</el-button>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- Testimonials Section -->
    <div class="testimonials">
      <h2 class="section-title">Khách hàng nói gì về chúng tôi</h2>
      <el-carousel :interval="4000" type="card" height="300px">
        <el-carousel-item v-for="(testimonial, index) in testimonials" :key="index">
          <div class="testimonial-card">
            <el-avatar :size="80" :src="testimonial.avatar"></el-avatar>
            <p class="testimonial-text">{{ testimonial.content }}</p>
            <h4>{{ testimonial.name }}</h4>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>

    <!-- Booking Dialog -->
    <el-dialog
      v-model="bookingDialogVisible"
      title="Đặt lịch dịch vụ"
      width="50%"
      :before-close="handleClose"
    >
      <div v-if="selectedService" class="booking-content">
        <h3>{{ selectedService.tenDichVu }}</h3>
        <p>{{ selectedService.moTa }}</p>
        <p>Giá: {{ formatPrice(selectedService.gia) }}</p>
        <p>Thời gian thực hiện: {{ selectedService.thoiGianThucHien }} phút</p>
        
        <el-form :model="bookingForm" label-width="120px">
          <el-form-item label="Ngày hẹn">
            <el-date-picker
              v-model="bookingForm.date"
              type="date"
              placeholder="Chọn ngày"
              :disabled-date="disabledDate"
            />
          </el-form-item>
          <el-form-item label="Giờ hẹn">
            <el-time-picker
              v-model="bookingForm.time"
              :picker-options="{
                start: '09:00',
                step: '00:30',
                end: '18:00'
              }"
              placeholder="Chọn giờ"
            />
          </el-form-item>
          <el-form-item label="Ghi chú">
            <el-input
              v-model="bookingForm.notes"
              type="textarea"
              :rows="3"
              placeholder="Nhập ghi chú (nếu có)"
            />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="bookingDialogVisible = false">Hủy</el-button>
          <el-button type="primary" @click="submitBooking" :loading="bookingLoading">
            Đặt lịch
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const router = useRouter()
const servicesSection = ref(null)
const bookingDialogVisible = ref(false)
const selectedService = ref(null)
const bookingLoading = ref(false)
const services = ref([])
const products = ref([])

const bookingForm = ref({
  date: null,
  time: null,
  notes: ''
})

const banners = [
  {
    image: '/banner1.jpg',
    title: 'Chào mừng đến với Salon Beauty',
    description: 'Nơi mang đến vẻ đẹp hoàn hảo cho bạn'
  },
  {
    image: '/banner2.jpg',
    title: 'Dịch vụ chuyên nghiệp',
    description: 'Đội ngũ chuyên gia giàu kinh nghiệm'
  },
  {
    image: '/banner3.jpg',
    title: 'Sản phẩm chất lượng',
    description: 'Cam kết sử dụng sản phẩm chính hãng'
  }
]

const testimonials = [
  {
    name: 'Nguyễn Thị A',
    content: 'Dịch vụ rất tốt, nhân viên chuyên nghiệp!',
    avatar: '/avatar1.jpg'
  },
  {
    name: 'Trần Văn B',
    content: 'Hài lòng với kết quả, sẽ quay lại!',
    avatar: '/avatar2.jpg'
  },
  {
    name: 'Lê Thị C',
    content: 'Giá cả hợp lý, chất lượng tốt!',
    avatar: '/avatar3.jpg'
  }
]

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(price)
}

const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7 // Không cho chọn ngày trong quá khứ
}

const scrollToServices = () => {
  servicesSection.value?.scrollIntoView({ behavior: 'smooth' })
}

const bookService = (service) => {
  selectedService.value = service
  bookingDialogVisible.value = true
}

const viewProduct = (product) => {
  router.push(`/product/${product.maSanPham}`)
}

const handleClose = () => {
  bookingDialogVisible.value = false
  selectedService.value = null
  bookingForm.value = {
    date: null,
    time: null,
    notes: ''
  }
}

const submitBooking = async () => {
  if (!bookingForm.value.date || !bookingForm.value.time) {
    ElMessage.warning('Vui lòng chọn ngày và giờ hẹn')
    return
  }

  bookingLoading.value = true
  try {
    const user = JSON.parse(localStorage.getItem('user'))
    if (!user) {
      ElMessage.warning('Vui lòng đăng nhập để đặt lịch')
      router.push('/login')
      return
    }

    const bookingData = {
      maKhachHang: user.id,
      maDichVu: selectedService.value.maDichVu,
      ngayHen: bookingForm.value.date,
      gioHen: bookingForm.value.time,
      ghiChu: bookingForm.value.notes
    }

    // Gọi API đặt lịch
    const response = await axios.post('http://localhost:8080/api/lichhen/create', bookingData)
    
    if (response.data) {
      ElMessage.success('Đặt lịch thành công!')
      handleClose()
    } else {
      ElMessage.error('Đặt lịch thất bại')
    }
  } catch (error) {
    console.error('Booking error:', error)
    ElMessage.error('Đặt lịch thất bại. Vui lòng thử lại.')
  } finally {
    bookingLoading.value = false
  }
}

const fetchServices = async () => {
  try {
    const response = await axios.get('http://localhost:8080/api/dichvu/all')
    services.value = response.data
  } catch (error) {
    console.error('Error fetching services:', error)
  }
}

const fetchProducts = async () => {
  try {
    const response = await axios.get('http://localhost:8080/api/sanpham/all')
    products.value = response.data
  } catch (error) {
    console.error('Error fetching products:', error)
  }
}

onMounted(() => {
  fetchServices()
  fetchProducts()
})

onBeforeUnmount(() => {
  // Cleanup if needed
})
</script>

<style scoped>
.home {
  min-height: 100vh;
}

.hero {
  margin-bottom: 4rem;
}

.banner-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.banner-content h2 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.banner-content p {
  font-size: 1.2rem;
  margin-bottom: 2rem;
}

.section-title {
  text-align: center;
  margin-bottom: 3rem;
  font-size: 2rem;
  color: #333;
}

.service-grid,
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  padding: 0 2rem;
}

.service-card,
.product-card {
  transition: transform 0.3s;
}

.service-card:hover,
.product-card:hover {
  transform: translateY(-5px);
}

.service-image,
.product-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.service-content,
.product-content {
  padding: 1rem;
}

.service-content h3,
.product-content h3 {
  margin-bottom: 0.5rem;
  color: #333;
}

.service-content p,
.product-content p {
  color: #666;
  margin-bottom: 1rem;
}

.service-footer,
.product-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  font-size: 1.2rem;
  font-weight: bold;
  color: #409EFF;
}

.testimonials {
  padding: 4rem 2rem;
  background-color: #f5f7fa;
}

.testimonial-card {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  text-align: center;
}

.testimonial-text {
  font-size: 1.1rem;
  color: #666;
  margin: 1rem 0;
}

.testimonial-card h4 {
  color: #333;
  margin-top: 1rem;
}

.booking-content {
  padding: 1rem;
}

.booking-content h3 {
  margin-bottom: 1rem;
  color: #333;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}
</style> 