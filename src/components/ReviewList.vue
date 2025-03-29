<template>
  <div class="reviews-section">
    <div class="reviews-header">
      <h2>Đánh giá</h2>
      <div class="reviews-summary">
        <div class="average-rating">
          <el-rate
            v-model="averageRating"
            disabled
            show-score
            text-color="#ff9900"
            score-template="{value} điểm" />
          <span class="rating-count">({{ reviews.length }} đánh giá)</span>
        </div>
      </div>
      <el-button 
        v-if="isAuthenticated"
        type="primary"
        @click="openReviewDialog">
        Viết đánh giá
      </el-button>
    </div>

    <div v-if="reviews.length > 0" class="reviews-list">
      <div v-for="review in reviews" :key="review.id" class="review-item">
        <div class="review-header">
          <div class="user-info">
            <el-avatar :size="40">
              {{ getUserInitials(review.userId) }}
            </el-avatar>
            <div class="user-details">
              <span class="username">{{ getUserName(review.userId) }}</span>
              <el-rate
                v-model="review.rating"
                disabled
                size="small" />
            </div>
          </div>
          <span class="review-date">{{ formatDate(review.date) }}</span>
        </div>
        <div class="review-content">
          <p>{{ review.comment }}</p>
          <div v-if="review.images && review.images.length > 0" class="review-images">
            <el-image
              v-for="(image, index) in review.images"
              :key="index"
              :src="image"
              :preview-src-list="review.images"
              fit="cover"
              class="review-image" />
          </div>
        </div>
      </div>
    </div>
    <div v-else class="no-reviews">
      <p>Chưa có đánh giá nào</p>
      <el-button 
        v-if="isAuthenticated"
        type="primary"
        @click="openReviewDialog">
        Viết đánh giá đầu tiên
      </el-button>
    </div>

    <ReviewDialog
      v-if="showReviewDialog"
      :type="type"
      :item-id="itemId"
      :item-name="itemName"
      @close="closeReviewDialog"
      @submit="handleReviewSubmit" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import ReviewDialog from './ReviewDialog.vue'

const props = defineProps({
  type: {
    type: String,
    required: true,
    validator: (value) => ['product', 'service'].includes(value)
  },
  itemId: {
    type: String,
    required: true
  },
  itemName: {
    type: String,
    required: true
  }
})

const reviews = ref([])
const showReviewDialog = ref(false)
const isAuthenticated = ref(false)

const averageRating = computed(() => {
  if (reviews.value.length === 0) return 0
  const sum = reviews.value.reduce((acc, review) => acc + review.rating, 0)
  return sum / reviews.value.length
})

const loadReviews = () => {
  try {
    const reviewsData = JSON.parse(localStorage.getItem('reviews') || '[]')
    reviews.value = reviewsData.filter(review => 
      review.type === props.type && review.itemId === props.itemId
    )
    isAuthenticated.value = !!localStorage.getItem('user')
  } catch (error) {
    console.error('Error loading reviews:', error)
    reviews.value = []
    isAuthenticated.value = false
  }
}

const getUserInitials = (userId) => {
  try {
    const users = JSON.parse(localStorage.getItem('users') || '[]')
    const user = users.find(u => u.id === userId)
    if (!user) return '?'
    return user.fullName.split(' ').map(n => n[0]).join('').toUpperCase()
  } catch (error) {
    console.error('Error getting user initials:', error)
    return '?'
  }
}

const getUserName = (userId) => {
  try {
    const users = JSON.parse(localStorage.getItem('users') || '[]')
    const user = users.find(u => u.id === userId)
    return user ? user.fullName : 'Người dùng'
  } catch (error) {
    console.error('Error getting user name:', error)
    return 'Người dùng'
  }
}

const formatDate = (date) => {
  try {
    return new Date(date).toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  } catch (error) {
    console.error('Error formatting date:', error)
    return 'Ngày không hợp lệ'
  }
}

const openReviewDialog = () => {
  if (!isAuthenticated.value) {
    ElMessage.warning('Vui lòng đăng nhập để viết đánh giá!')
    return
  }
  showReviewDialog.value = true
}

const closeReviewDialog = () => {
  showReviewDialog.value = false
}

const handleReviewSubmit = (review) => {
  try {
    const reviewsData = JSON.parse(localStorage.getItem('reviews') || '[]')
    reviewsData.push({
      ...review,
      id: Date.now().toString(),
      type: props.type,
      itemId: props.itemId,
      date: new Date().toISOString()
    })
    localStorage.setItem('reviews', JSON.stringify(reviewsData))
    loadReviews()
    closeReviewDialog()
    ElMessage.success('Cảm ơn bạn đã đánh giá!')
  } catch (error) {
    console.error('Error submitting review:', error)
    ElMessage.error('Có lỗi xảy ra khi gửi đánh giá. Vui lòng thử lại!')
  }
}

onMounted(() => {
  loadReviews()
})
</script>

<style scoped>
.reviews-section {
  margin-top: 40px;
}

.reviews-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.reviews-header h2 {
  font-size: 24px;
  color: #303133;
  margin: 0;
}

.reviews-summary {
  display: flex;
  align-items: center;
  gap: 20px;
}

.average-rating {
  display: flex;
  align-items: center;
  gap: 10px;
}

.rating-count {
  color: #909399;
  font-size: 14px;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.review-item {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.username {
  font-weight: bold;
  color: #303133;
}

.review-date {
  color: #909399;
  font-size: 14px;
}

.review-content {
  color: #606266;
  line-height: 1.6;
}

.review-images {
  display: flex;
  gap: 10px;
  margin-top: 15px;
  flex-wrap: wrap;
}

.review-image {
  width: 100px;
  height: 100px;
  border-radius: 4px;
  cursor: pointer;
}

.no-reviews {
  text-align: center;
  padding: 40px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.no-reviews p {
  color: #909399;
  margin-bottom: 20px;
}
</style> 