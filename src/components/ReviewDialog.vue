<template>
  <el-dialog
    v-model="dialogVisible"
    :title="`Đánh giá ${props.itemName}`"
    width="500px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    :show-close="false"
    destroy-on-close>
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="100px"
      @submit.prevent>
      <el-form-item label="Đánh giá" prop="rating">
        <el-rate
          v-model="form.rating"
          :colors="['#99A9BF', '#F7BA2A', '#FF9900']"
          show-text />
        <div class="rating-text">{{ getRatingText(form.rating) }}</div>
      </el-form-item>

      <el-form-item label="Nhận xét" prop="comment">
        <el-input
          v-model="form.comment"
          type="textarea"
          :rows="4"
          placeholder="Chia sẻ trải nghiệm của bạn..." />
      </el-form-item>

      <el-form-item label="Hình ảnh">
        <el-upload
          v-model:file-list="fileList"
          action="#"
          :auto-upload="false"
          :on-change="handleImageChange"
          :limit="3"
          multiple
          list-type="picture-card">
          <el-icon><Plus /></el-icon>
          <template #tip>
            <div class="el-upload__tip">
              Tải lên tối đa 3 ảnh, mỗi ảnh không quá 2MB
            </div>
          </template>
        </el-upload>
      </el-form-item>
    </el-form>

    <template #footer>
      <span class="dialog-footer">
        <el-button @click="handleClose">Hủy</el-button>
        <el-button type="primary" @click="handleSubmit">
          Gửi đánh giá
        </el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'

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

const emit = defineEmits(['close', 'submit'])

const dialogVisible = ref(true)
const formRef = ref(null)
const fileList = ref([])

const form = ref({
  rating: 0,
  comment: '',
  images: []
})

const rules = {
  rating: [
    { required: true, message: 'Vui lòng chọn số sao đánh giá', trigger: 'change' }
  ],
  comment: [
    { required: true, message: 'Vui lòng nhập nhận xét', trigger: 'blur' },
    { min: 10, message: 'Nhận xét phải có ít nhất 10 ký tự', trigger: 'blur' }
  ]
}

const getRatingText = (rating) => {
  const texts = {
    1: 'Rất không hài lòng',
    2: 'Không hài lòng',
    3: 'Bình thường',
    4: 'Hài lòng',
    5: 'Rất hài lòng'
  }
  return texts[rating] || ''
}

const handleImageChange = (file) => {
  try {
    const isImage = file.raw.type.startsWith('image/')
    const isLt2M = file.raw.size / 1024 / 1024 < 2

    if (!isImage) {
      ElMessage.error('Chỉ được upload file ảnh!')
      fileList.value = fileList.value.filter(f => f.uid !== file.uid)
      return false
    }

    if (!isLt2M) {
      ElMessage.error('Kích thước ảnh không được vượt quá 2MB!')
      fileList.value = fileList.value.filter(f => f.uid !== file.uid)
      return false
    }

    return true
  } catch (error) {
    console.error('Error handling image change:', error)
    ElMessage.error('Có lỗi xảy ra khi xử lý ảnh. Vui lòng thử lại!')
    return false
  }
}

const handleClose = () => {
  dialogVisible.value = false
  emit('close')
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    const images = fileList.value.map(file => URL.createObjectURL(file.raw))
    emit('submit', {
      ...form.value,
      images,
      userId: JSON.parse(localStorage.getItem('user')).id
    })
  } catch (error) {
    console.error('Form validation failed:', error)
    ElMessage.error('Vui lòng kiểm tra lại thông tin đánh giá!')
  }
}

const resetForm = () => {
  form.value = {
    rating: 0,
    comment: '',
    images: []
  }
  fileList.value = []
}

onMounted(() => {
  resetForm()
})

onBeforeUnmount(() => {
  resetForm()
})
</script>

<style scoped>
.rating-text {
  margin-top: 8px;
  color: #606266;
  font-size: 14px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-upload--picture-card) {
  width: 100px;
  height: 100px;
  line-height: 100px;
}

:deep(.el-upload-list--picture-card) {
  --el-upload-list-picture-card-size: 100px;
}

.el-upload__tip {
  margin-top: 8px;
  color: #909399;
  font-size: 12px;
}
</style> 