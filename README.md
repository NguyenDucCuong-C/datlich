# Haircut Booking

Ứng dụng web đặt lịch cắt tóc và bán sản phẩm chăm sóc tóc được xây dựng bằng Vue.js 3.

## Tính năng

- Đặt lịch cắt tóc trực tuyến
- Xem danh sách sản phẩm chăm sóc tóc
- Thêm sản phẩm vào giỏ hàng
- Quản lý giỏ hàng và thanh toán

## Cài đặt

```bash
# Cài đặt dependencies
npm install

# Chạy ứng dụng ở môi trường development
npm run serve

# Build ứng dụng cho production
npm run build
```

## Công nghệ sử dụng

- Vue.js 3
- Vue Router
- Element Plus
- Axios
- VueUse

## Cấu trúc dự án

```
src/
  ├── assets/         # Static assets
  ├── components/     # Vue components
  ├── views/          # Page components
  ├── router/         # Vue Router configuration
  ├── App.vue         # Root component
  └── main.js         # Application entry point
```

## API Endpoints

### Đặt lịch
- POST /api/bookings - Tạo lịch hẹn mới
- GET /api/bookings - Lấy danh sách lịch hẹn
- GET /api/bookings/:id - Lấy thông tin chi tiết lịch hẹn
- PUT /api/bookings/:id - Cập nhật lịch hẹn
- DELETE /api/bookings/:id - Hủy lịch hẹn

### Sản phẩm
- GET /api/products - Lấy danh sách sản phẩm
- GET /api/products/:id - Lấy thông tin chi tiết sản phẩm
- POST /api/orders - Tạo đơn hàng mới
- GET /api/orders - Lấy danh sách đơn hàng
- GET /api/orders/:id - Lấy thông tin chi tiết đơn hàng

## License

MIT 