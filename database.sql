-- Tạo database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'salon_beauty')
BEGIN
    CREATE DATABASE salon_beauty;
END
GO

USE salon_beauty;
GO

-- Bảng NguoiDung (Người dùng)
CREATE TABLE NguoiDung (
    MaNguoiDung UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenDangNhap NVARCHAR(50) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    SoDienThoai NVARCHAR(20),
    VaiTro NVARCHAR(20) NOT NULL DEFAULT 'khachhang' 
        CHECK (VaiTro IN ('admin', 'khachhang')),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng DanhMuc (Danh mục sản phẩm)
CREATE TABLE DanhMuc (
    MaDanhMuc UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenDanhMuc NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(MAX),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng SanPham (Sản phẩm)
CREATE TABLE SanPham (
    MaSanPham UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaDanhMuc UNIQUEIDENTIFIER,
    TenSanPham NVARCHAR(200) NOT NULL,
    MoTa NVARCHAR(MAX),
    Gia DECIMAL(10,2) NOT NULL,
    SoLuongTon INT NOT NULL DEFAULT 0,
    HinhAnh NVARCHAR(255),
    TrangThai NVARCHAR(20) DEFAULT 'dangban' 
        CHECK (TrangThai IN ('dangban', 'ngungban')),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc)
);
GO

-- Bảng DichVu (Dịch vụ)
CREATE TABLE DichVu (
    MaDichVu UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenDichVu NVARCHAR(200) NOT NULL,
    MoTa NVARCHAR(MAX),
    Gia DECIMAL(10,2) NOT NULL,
    ThoiGianThucHien INT NOT NULL, -- Thời gian thực hiện (phút)
    HinhAnh NVARCHAR(255),
    TrangThai NVARCHAR(20) DEFAULT 'dangban' 
        CHECK (TrangThai IN ('dangban', 'ngungban')),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE()
);
GO

-- Bảng NhanVien (Nhân viên)
CREATE TABLE NhanVien (
    MaNhanVien UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaNguoiDung UNIQUEIDENTIFIER NOT NULL,
    ChucVu NVARCHAR(100),
    ChuyenMon NVARCHAR(MAX),
    TrangThai NVARCHAR(20) DEFAULT 'danglam' 
        CHECK (TrangThai IN ('danglam', 'nghiviec')),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng PhanCongNhanVien (Phân công nhân viên cho dịch vụ)
CREATE TABLE PhanCongNhanVien (
    MaNhanVien UNIQUEIDENTIFIER,
    MaDichVu UNIQUEIDENTIFIER,
    PRIMARY KEY (MaNhanVien, MaDichVu),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaDichVu) REFERENCES DichVu(MaDichVu)
);
GO

-- Bảng LichHen (Lịch hẹn)
CREATE TABLE LichHen (
    MaLichHen UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaKhachHang UNIQUEIDENTIFIER NOT NULL,
    MaNhanVien UNIQUEIDENTIFIER,
    MaDichVu UNIQUEIDENTIFIER NOT NULL,
    NgayHen DATE NOT NULL,
    GioHen TIME NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT 'choxacnhan' 
        CHECK (TrangThai IN ('choxacnhan', 'daxacnhan', 'dahoanthanh', 'dahuy')),
    GhiChu NVARCHAR(MAX),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaKhachHang) REFERENCES NguoiDung(MaNguoiDung),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaDichVu) REFERENCES DichVu(MaDichVu)
);
GO

-- Bảng DonHang (Đơn hàng)
CREATE TABLE DonHang (
    MaDonHang UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaKhachHang UNIQUEIDENTIFIER NOT NULL,
    TongTien DECIMAL(10,2) NOT NULL,
    TrangThai NVARCHAR(20) DEFAULT 'choxuly' 
        CHECK (TrangThai IN ('choxuly', 'dangxuly', 'dahoanthanh', 'dahuy')),
    PhuongThucThanhToan NVARCHAR(20) 
        CHECK (PhuongThucThanhToan IN ('tienmat', 'the', 'chuyenkhoan')),
    TrangThaiThanhToan NVARCHAR(20) DEFAULT 'chuathanhtoan' 
        CHECK (TrangThaiThanhToan IN ('chuathanhtoan', 'dathanhtoan', 'thatbai')),
    DiaChiGiaoHang NVARCHAR(MAX),
    GhiChu NVARCHAR(MAX),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaKhachHang) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng ChiTietDonHang (Chi tiết đơn hàng)
CREATE TABLE ChiTietDonHang (
    MaChiTiet UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaDonHang UNIQUEIDENTIFIER NOT NULL,
    MaSanPham UNIQUEIDENTIFIER NOT NULL,
    SoLuong INT NOT NULL,
    Gia DECIMAL(10,2) NOT NULL,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaDonHang) REFERENCES DonHang(MaDonHang),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);
GO

-- Bảng DanhGia (Đánh giá)
CREATE TABLE DanhGia (
    MaDanhGia UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaNguoiDung UNIQUEIDENTIFIER NOT NULL,
    LoaiDanhGia NVARCHAR(20) NOT NULL 
        CHECK (LoaiDanhGia IN ('sanpham', 'dichvu')),
    MaItem UNIQUEIDENTIFIER NOT NULL,
    SoSao INT NOT NULL CHECK (SoSao >= 1 AND SoSao <= 5),
    NoiDung NVARCHAR(MAX),
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng HinhAnhDanhGia (Hình ảnh đánh giá)
CREATE TABLE HinhAnhDanhGia (
    MaHinhAnh UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaDanhGia UNIQUEIDENTIFIER NOT NULL,
    DuongDanHinhAnh NVARCHAR(255) NOT NULL,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaDanhGia) REFERENCES DanhGia(MaDanhGia)
);
GO

-- Bảng Kho (Kho)
CREATE TABLE Kho (
    MaKho UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaSanPham UNIQUEIDENTIFIER NOT NULL,
    SoLuongTon INT NOT NULL DEFAULT 0,
    DonViTinh NVARCHAR(20),
    SoLuongToiThieu INT DEFAULT 0,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    NgayCapNhat DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaSanPham) REFERENCES SanPham(MaSanPham)
);
GO

-- Bảng LichSuKho (Lịch sử kho)
CREATE TABLE LichSuKho (
    MaLichSu UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    MaKho UNIQUEIDENTIFIER NOT NULL,
    Loai NVARCHAR(20) NOT NULL 
        CHECK (Loai IN ('nhap', 'xuat')),
    SoLuong INT NOT NULL,
    GhiChu NVARCHAR(MAX),
    MaNguoiTao UNIQUEIDENTIFIER NOT NULL,
    NgayTao DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (MaKho) REFERENCES Kho(MaKho),
    FOREIGN KEY (MaNguoiTao) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Tạo indexes để tối ưu hiệu suất
CREATE INDEX idx_nguoidung_tendangnhap ON NguoiDung(TenDangNhap);
CREATE INDEX idx_nguoidung_email ON NguoiDung(Email);
CREATE INDEX idx_sanpham_danhmuc ON SanPham(MaDanhMuc);
CREATE INDEX idx_donhang_khachhang ON DonHang(MaKhachHang);
CREATE INDEX idx_lichhen_khachhang ON LichHen(MaKhachHang);
CREATE INDEX idx_lichhen_ngay ON LichHen(NgayHen);
CREATE INDEX idx_danhgia_item ON DanhGia(LoaiDanhGia, MaItem);
CREATE INDEX idx_kho_sanpham ON Kho(MaSanPham);
GO

-- Tạo trigger để tự động cập nhật NgayCapNhat
CREATE TRIGGER TR_CapNhatNgayCapNhat_NguoiDung
ON NguoiDung
AFTER UPDATE
AS
BEGIN
    UPDATE NguoiDung
    SET NgayCapNhat = GETDATE()
    FROM NguoiDung n
    INNER JOIN inserted i ON n.MaNguoiDung = i.MaNguoiDung;
END;
GO

-- Tạo trigger cho các bảng khác
CREATE TRIGGER TR_CapNhatNgayCapNhat_DanhMuc
ON DanhMuc
AFTER UPDATE
AS
BEGIN
    UPDATE DanhMuc
    SET NgayCapNhat = GETDATE()
    FROM DanhMuc d
    INNER JOIN inserted i ON d.MaDanhMuc = i.MaDanhMuc;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_SanPham
ON SanPham
AFTER UPDATE
AS
BEGIN
    UPDATE SanPham
    SET NgayCapNhat = GETDATE()
    FROM SanPham s
    INNER JOIN inserted i ON s.MaSanPham = i.MaSanPham;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_DichVu
ON DichVu
AFTER UPDATE
AS
BEGIN
    UPDATE DichVu
    SET NgayCapNhat = GETDATE()
    FROM DichVu d
    INNER JOIN inserted i ON d.MaDichVu = i.MaDichVu;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_NhanVien
ON NhanVien
AFTER UPDATE
AS
BEGIN
    UPDATE NhanVien
    SET NgayCapNhat = GETDATE()
    FROM NhanVien n
    INNER JOIN inserted i ON n.MaNhanVien = i.MaNhanVien;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_LichHen
ON LichHen
AFTER UPDATE
AS
BEGIN
    UPDATE LichHen
    SET NgayCapNhat = GETDATE()
    FROM LichHen l
    INNER JOIN inserted i ON l.MaLichHen = i.MaLichHen;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_DonHang
ON DonHang
AFTER UPDATE
AS
BEGIN
    UPDATE DonHang
    SET NgayCapNhat = GETDATE()
    FROM DonHang d
    INNER JOIN inserted i ON d.MaDonHang = i.MaDonHang;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_DanhGia
ON DanhGia
AFTER UPDATE
AS
BEGIN
    UPDATE DanhGia
    SET NgayCapNhat = GETDATE()
    FROM DanhGia d
    INNER JOIN inserted i ON d.MaDanhGia = i.MaDanhGia;
END;
GO

CREATE TRIGGER TR_CapNhatNgayCapNhat_Kho
ON Kho
AFTER UPDATE
AS
BEGIN
    UPDATE Kho
    SET NgayCapNhat = GETDATE()
    FROM Kho k
    INNER JOIN inserted i ON k.MaKho = i.MaKho;
END;
GO

-- Thêm dữ liệu mẫu
-- Thêm người dùng (admin và khách hàng)
INSERT INTO NguoiDung (TenDangNhap, MatKhau, HoTen, Email, SoDienThoai, VaiTro) VALUES
('admin', '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iq.9ZxZxqXv6', N'Quản trị viên', 'admin@salonbeauty.com', '0123456789', 'admin'),
('nguyenvana', '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iq.9ZxZxqXv6', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '0123456780', 'khachhang'),
('tranthib', '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iq.9ZxZxqXv6', N'Trần Thị B', 'tranthib@gmail.com', '0123456781', 'khachhang'),
('levanc', '$2a$10$XOPbrlUPQdwdJUpSrIF6X.LbE14qsMmKGhM1A8W9iq.9ZxZxqXv6', N'Lê Văn C', 'levanc@gmail.com', '0123456782', 'khachhang');
GO

-- Thêm danh mục sản phẩm
INSERT INTO DanhMuc (TenDanhMuc, MoTa) VALUES
(N'Dầu gội', N'Các loại dầu gội chuyên dụng cho tóc'),
(N'Dầu xả', N'Các loại dầu xả dưỡng tóc'),
(N'Kem ủ tóc', N'Kem ủ tóc chuyên dụng'),
(N'Dụng cụ làm tóc', N'Các dụng cụ chăm sóc tóc'),
(N'Mỹ phẩm trang điểm', N'Các sản phẩm trang điểm chuyên nghiệp');
GO

-- Thêm sản phẩm
INSERT INTO SanPham (MaDanhMuc, TenSanPham, MoTa, Gia, SoLuongTon, HinhAnh) VALUES
((SELECT MaDanhMuc FROM DanhMuc WHERE TenDanhMuc = N'Dầu gội'), 
N'Dầu gội dưỡng tóc Kerastase', 
N'Dầu gội cao cấp dưỡng tóc chuyên sâu', 
450000, 100, 'kerastase-shampoo.jpg'),
((SELECT MaDanhMuc FROM DanhMuc WHERE TenDanhMuc = N'Dầu xả'), 
N'Dầu xả dưỡng tóc Kerastase', 
N'Dầu xả cao cấp dưỡng tóc chuyên sâu', 
450000, 100, 'kerastase-conditioner.jpg'),
((SELECT MaDanhMuc FROM DanhMuc WHERE TenDanhMuc = N'Kem ủ tóc'), 
N'Kem ủ tóc Olaplex', 
N'Kem ủ tóc chuyên sâu phục hồi tóc hư tổn', 
1200000, 50, 'olaplex-treatment.jpg'),
((SELECT MaDanhMuc FROM DanhMuc WHERE TenDanhMuc = N'Dụng cụ làm tóc'), 
N'Lược chải tóc chuyên dụng', 
N'Lược chải tóc cao cấp không gãy tóc', 
250000, 200, 'hair-brush.jpg'),
((SELECT MaDanhMuc FROM DanhMuc WHERE TenDanhMuc = N'Mỹ phẩm trang điểm'), 
N'Bộ trang điểm chuyên nghiệp', 
N'Bộ trang điểm đầy đủ dụng cụ chuyên nghiệp', 
1500000, 30, 'makeup-kit.jpg');
GO

-- Thêm dịch vụ
INSERT INTO DichVu (TenDichVu, MoTa, Gia, ThoiGianThucHien, HinhAnh) VALUES
(N'Cắt tóc nam', N'Cắt tóc nam theo yêu cầu', 150000, 30, 'haircut-male.jpg'),
(N'Cắt tóc nữ', N'Cắt tóc nữ theo yêu cầu', 200000, 45, 'haircut-female.jpg'),
(N'Uốn tóc', N'Uốn tóc chuyên nghiệp', 800000, 120, 'hair-perm.jpg'),
(N'Nhuộm tóc', N'Nhuộm tóc chuyên nghiệp', 1000000, 150, 'hair-color.jpg'),
(N'Massage da đầu', N'Massage da đầu thư giãn', 300000, 45, 'head-massage.jpg'),
(N'Trang điểm cô dâu', N'Trang điểm cô dâu chuyên nghiệp', 2000000, 120, 'bridal-makeup.jpg'),
(N'Chăm sóc da mặt', N'Chăm sóc da mặt chuyên sâu', 500000, 60, 'facial-care.jpg'),
(N'Massage toàn thân', N'Massage toàn thân thư giãn', 800000, 90, 'body-massage.jpg');
GO

-- Thêm nhân viên
INSERT INTO NhanVien (MaNguoiDung, ChucVu, ChuyenMon) VALUES
((SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'admin'), 
N'Quản lý', 
N'Quản lý salon, đào tạo nhân viên'),
((SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'nguyenvana'), 
N'Stylist trưởng', 
N'Cắt tóc, uốn, nhuộm chuyên nghiệp'),
((SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'tranthib'), 
N'Chuyên viên trang điểm', 
N'Trang điểm cô dâu, trang điểm chuyên nghiệp'),
((SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'levanc'), 
N'Chuyên viên massage', 
N'Massage thư giãn, chăm sóc da');
GO

-- Phân công nhân viên cho dịch vụ
INSERT INTO PhanCongNhanVien (MaNhanVien, MaDichVu)
SELECT n.MaNhanVien, d.MaDichVu
FROM NhanVien n
CROSS JOIN DichVu d
WHERE n.ChucVu IN (N'Stylist trưởng', N'Chuyên viên trang điểm', N'Chuyên viên massage');
GO

-- Thêm lịch hẹn
INSERT INTO LichHen (MaKhachHang, MaNhanVien, MaDichVu, NgayHen, GioHen, TrangThai, GhiChu)
SELECT 
    (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'nguyenvana'),
    (SELECT MaNhanVien FROM NhanVien WHERE ChucVu = N'Stylist trưởng'),
    (SELECT MaDichVu FROM DichVu WHERE TenDichVu = N'Cắt tóc nam'),
    DATEADD(day, 1, GETDATE()),
    '10:00:00',
    'choxacnhan',
    N'Cắt tóc nam theo yêu cầu';
GO

-- Thêm đơn hàng
INSERT INTO DonHang (MaKhachHang, TongTien, TrangThai, PhuongThucThanhToan, TrangThaiThanhToan, DiaChiGiaoHang)
SELECT 
    (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'tranthib'),
    900000,
    'choxuly',
    'tienmat',
    'chuathanhtoan',
    N'123 Đường ABC, Quận 1, TP.HCM';
GO

-- Thêm chi tiết đơn hàng
INSERT INTO ChiTietDonHang (MaDonHang, MaSanPham, SoLuong, Gia)
SELECT 
    (SELECT TOP 1 MaDonHang FROM DonHang ORDER BY NgayTao DESC),
    (SELECT MaSanPham FROM SanPham WHERE TenSanPham = N'Dầu gội dưỡng tóc Kerastase'),
    2,
    450000;
GO

-- Thêm đánh giá
INSERT INTO DanhGia (MaNguoiDung, LoaiDanhGia, MaItem, SoSao, NoiDung)
SELECT 
    (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'nguyenvana'),
    'sanpham',
    (SELECT MaSanPham FROM SanPham WHERE TenSanPham = N'Dầu gội dưỡng tóc Kerastase'),
    5,
    N'Sản phẩm rất tốt, tóc mềm mượt sau khi sử dụng';
GO

-- Thêm hình ảnh đánh giá
INSERT INTO HinhAnhDanhGia (MaDanhGia, DuongDanHinhAnh)
SELECT 
    (SELECT TOP 1 MaDanhGia FROM DanhGia ORDER BY NgayTao DESC),
    'review-kerastase.jpg';
GO

-- Thêm kho
INSERT INTO Kho (MaSanPham, SoLuongTon, DonViTinh, SoLuongToiThieu)
SELECT 
    MaSanPham,
    100,
    N'Chai',
    10
FROM SanPham;
GO

-- Thêm lịch sử kho
INSERT INTO LichSuKho (MaKho, Loai, SoLuong, GhiChu, MaNguoiTao)
SELECT 
    k.MaKho,
    'nhap',
    100,
    N'Nhập hàng lần đầu',
    (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'admin')
FROM Kho k;
GO 