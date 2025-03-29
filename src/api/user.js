import axios from 'axios';

const API_URL = 'http://localhost:8080/api';

// Tạo instance axios với cấu hình mặc định
const api = axios.create({
    baseURL: API_URL,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json'
    }
});

// Interceptor để xử lý lỗi chung
api.interceptors.response.use(
    response => response,
    error => {
        if (error.response) {
            // Server trả về lỗi
            const message = error.response.data?.message || 'Có lỗi xảy ra. Vui lòng thử lại.';
            return Promise.reject(new Error(message));
        } else if (error.request) {
            // Không nhận được response
            return Promise.reject(new Error('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối.'));
        } else {
            // Lỗi khi tạo request
            return Promise.reject(new Error('Có lỗi xảy ra. Vui lòng thử lại.'));
        }
    }
);

export const userApi = {
    // Lấy danh sách tất cả người dùng
    getAllUsers: async () => {
        try {
            const response = await api.get('/nguoidung/all');
            return response.data;
        } catch (error) {
            console.error('Error fetching users:', error);
            throw error;
        }
    },

    // Đăng nhập
    login: async (credentials) => {
        try {
            // Lấy danh sách người dùng
            const users = await api.get('/nguoidung/all');
            
            // Tìm user với username và password tương ứng
            const user = users.data.find(u => 
                u.tenDangNhap === credentials.tenDangNhap && 
                u.matKhau === credentials.matKhau
            );

            if (user) {
                // Lưu thông tin user vào localStorage
                const userData = {
                    id: user.maNguoiDung,
                    username: user.tenDangNhap,
                    fullName: user.hoTen,
                    email: user.email,
                    phone: user.soDienThoai,
                    role: user.vaiTro.toUpperCase() // Chuyển đổi role thành chữ hoa
                };
                localStorage.setItem('user', JSON.stringify(userData));
                return userData;
            } else {
                throw new Error('Tên đăng nhập hoặc mật khẩu không đúng');
            }
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    },

    // Đăng ký
    register: async (userData) => {
        try {
            // Lấy danh sách người dùng để kiểm tra username tồn tại
            const users = await api.get('/nguoidung/all');
            
            // Kiểm tra username đã tồn tại chưa
            const existingUser = users.data.find(u => u.tenDangNhap === userData.tenDangNhap);
            if (existingUser) {
                throw new Error('Tên đăng nhập đã tồn tại');
            }

            // Thêm user mới vào danh sách
            const newUser = {
                maNguoiDung: Date.now().toString(), // Tạo ID tạm thời
                ...userData,
                vaiTro: userData.vaiTro.toUpperCase() // Chuyển đổi role thành chữ hoa
            };

            return newUser;
        } catch (error) {
            console.error('Registration error:', error);
            throw error;
        }
    },

    // Đăng xuất
    logout() {
        localStorage.removeItem('user');
    },

    // Lấy thông tin user hiện tại
    getCurrentUser() {
        const userStr = localStorage.getItem('user');
        return userStr ? JSON.parse(userStr) : null;
    },

    // Kiểm tra đăng nhập
    isAuthenticated() {
        return !!this.getCurrentUser();
    },

    // Kiểm tra quyền admin
    isAdmin() {
        const user = this.getCurrentUser();
        return user?.role === 'ADMIN';
    },

    // Kiểm tra quyền staff
    isStaff() {
        const user = this.getCurrentUser();
        return user?.role === 'STAFF';
    }
}; 