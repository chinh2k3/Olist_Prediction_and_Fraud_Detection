# TÀI LIỆU MÔ TẢ DATA WAREHOUSE
## Olist E-Commerce Brazil — `olist_dwh`

> Mô tả cấu trúc bảng, ý nghĩa từng cột và kiểu dữ liệu trong Data Warehouse Olist.  
> Kiến trúc: **Star Schema** — gồm các bảng Dimension (chiều) và Fact (sự kiện).

---

## Tổng quan cấu trúc

```
olist_dwh
├── DIMENSION TABLES (Bảng chiều)
│   ├── dim_date          — Chiều thời gian
│   ├── dim_customer      — Chiều khách hàng
│   ├── dim_seller        — Chiều người bán
│   ├── dim_products      — Chiều sản phẩm
│   └── dim_payment       — Chiều phương thức thanh toán
│
└── FACT TABLES (Bảng sự kiện)
    ├── fact_orders        — Sự kiện đơn hàng (1 dòng / đơn hàng)
    └── fact_order_items   — Sự kiện chi tiết đơn hàng (1 dòng / sản phẩm trong đơn)
```

---

## DIMENSION TABLES — Bảng Chiều

---

### 1. `dim_date` — Chiều Thời Gian

Lưu trữ các thuộc tính thời gian phục vụ phân tích theo ngày, tháng, quý, năm.

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `date_key` | Khóa ngày (PK) | `INT` — Số nguyên | Khóa chính định dạng YYYYMMDD (ví dụ: 20171009) |
| `full_date` | Ngày đầy đủ | `DATE` — Ngày tháng | Giá trị ngày đầy đủ (ví dụ: 2017-10-09) |
| `day` | Ngày trong tháng | `TINYINT` — Số nguyên nhỏ | Ngày trong tháng (1–31) |
| `month` | Tháng | `TINYINT` — Số nguyên nhỏ | Tháng trong năm (1–12) |
| `month_name` | Tên tháng | `VARCHAR(10)` — Chuỗi ký tự | Tên tháng bằng tiếng Anh (ví dụ: January) |
| `quarter` | Quý | `TINYINT` — Số nguyên nhỏ | Quý trong năm (1–4) |
| `year` | Năm | `SMALLINT` — Số nguyên | Năm (ví dụ: 2017) |
| `week_of_year` | Tuần trong năm | `TINYINT` — Số nguyên nhỏ | Số thứ tự tuần trong năm (1–53) |
| `day_of_week` | Thứ trong tuần | `TINYINT` — Số nguyên nhỏ | Thứ trong tuần: 0 = Thứ Hai, 6 = Chủ Nhật |
| `day_name` | Tên thứ | `VARCHAR(10)` — Chuỗi ký tự | Tên thứ bằng tiếng Anh (ví dụ: Monday) |
| `is_weekend` | Là cuối tuần? | `BOOLEAN` — Đúng/Sai | TRUE nếu là Thứ Bảy hoặc Chủ Nhật, FALSE nếu là ngày thường |

---

### 2. `dim_customer` — Chiều Khách Hàng

Lưu trữ thông tin định danh và địa lý của khách hàng.

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `customer_key` | Khóa khách hàng (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `customer_id` | Mã khách hàng | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh khách hàng theo từng đơn hàng (có thể lặp lại nếu khách đặt nhiều đơn) |
| `customer_unique_id` | Mã khách hàng duy nhất | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh duy nhất của khách hàng trên toàn hệ thống |
| `customer_zip_code` | Mã bưu chính | `VARCHAR(10)` — Chuỗi ký tự | 5 chữ số đầu của mã bưu chính nơi khách hàng cư trú |
| `customer_city` | Thành phố | `VARCHAR(100)` — Chuỗi ký tự | Tên thành phố nơi khách hàng sinh sống |
| `customer_state` | Bang/Tỉnh | `CHAR(2)` — Ký tự cố định | Mã bang nơi khách hàng cư trú (2 ký tự cố định, ví dụ: SP, RJ) |

---

### 3. `dim_seller` — Chiều Người Bán

Lưu trữ thông tin định danh và địa lý của người bán hàng.

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `seller_key` | Khóa người bán (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `seller_id` | Mã người bán | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh duy nhất của người bán trên nền tảng Olist |
| `seller_zip_code` | Mã bưu chính người bán | `VARCHAR(10)` — Chuỗi ký tự | 5 chữ số đầu của mã bưu chính nơi người bán đăng ký kinh doanh |
| `seller_city` | Thành phố người bán | `VARCHAR(100)` — Chuỗi ký tự | Tên thành phố nơi người bán hoạt động |
| `seller_state` | Bang/Tỉnh người bán | `CHAR(2)` — Ký tự cố định | Mã bang nơi người bán hoạt động (2 ký tự cố định, ví dụ: SP, MG) |

---

### 4. `dim_products` — Chiều Sản Phẩm

Lưu trữ thông tin mô tả và đặc điểm vật lý của sản phẩm.

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `product_key` | Khóa sản phẩm (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `product_id` | Mã sản phẩm | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh duy nhất của sản phẩm |
| `category_name_portuguese` | Tên danh mục (tiếng Bồ Đào Nha) | `VARCHAR(100)` — Chuỗi ký tự | Tên danh mục sản phẩm gốc bằng tiếng Bồ Đào Nha |
| `category_name_english` | Tên danh mục (tiếng Anh) | `VARCHAR(100)` — Chuỗi ký tự | Tên danh mục sản phẩm đã dịch sang tiếng Anh |
| `product_name_length` | Độ dài tên sản phẩm | `INT` — Số nguyên | Số ký tự trong tên sản phẩm |
| `product_description_length` | Độ dài mô tả sản phẩm | `INT` — Số nguyên | Số ký tự trong phần mô tả sản phẩm |
| `product_photos_qty` | Số lượng ảnh sản phẩm | `INT` — Số nguyên | Số lượng ảnh được đăng kèm sản phẩm |
| `product_weight_g` | Khối lượng (gram) | `FLOAT` — Số thực | Khối lượng của sản phẩm tính bằng gram |
| `product_length_cm` | Chiều dài (cm) | `FLOAT` — Số thực | Chiều dài của sản phẩm tính bằng centimét |
| `product_height_cm` | Chiều cao (cm) | `FLOAT` — Số thực | Chiều cao của sản phẩm tính bằng centimét |
| `product_width_cm` | Chiều rộng (cm) | `FLOAT` — Số thực | Chiều rộng của sản phẩm tính bằng centimét |

---

### 5. `dim_payment` — Chiều Phương Thức Thanh Toán

Lưu trữ danh sách các phương thức thanh toán được chấp nhận trên nền tảng.

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `payment_type_key` | Khóa phương thức thanh toán (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `payment_type` | Loại thanh toán | `VARCHAR(50)` — Chuỗi ký tự | Tên phương thức thanh toán |

**Danh sách giá trị có sẵn:**

| Giá Trị | Ý Nghĩa |
|---|---|
| `credit_card` | Thẻ tín dụng |
| `boleto` | Phiếu thanh toán (hình thức phổ biến tại Brazil) |
| `voucher` | Phiếu giảm giá / voucher |
| `debit_card` | Thẻ ghi nợ |
| `not_defined` | Không xác định |

---

## FACT TABLES — Bảng Sự Kiện

---

### 6. `fact_orders` — Sự Kiện Đơn Hàng

**Grain (Độ chi tiết):** 1 dòng = 1 đơn hàng  
**Nguồn dữ liệu:** `olist_orders` + `olist_order_payments` + `olist_order_reviews`

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `order_key` | Khóa đơn hàng (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `order_id` | Mã đơn hàng | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh duy nhất của đơn hàng từ hệ thống nguồn |
| **Khóa ngoại (FK)** | | | |
| `customer_key` | Khóa khách hàng (FK) | `INT` — Số nguyên | Liên kết tới `dim_customer.customer_key` |
| `purchase_date_key` | Khóa ngày đặt hàng (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày khách đặt hàng |
| `approved_date_key` | Khóa ngày xác nhận thanh toán (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày thanh toán được xác nhận |
| `delivered_carrier_date_key` | Khóa ngày giao hàng cho vận chuyển (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày đơn hàng bàn giao cho đơn vị vận chuyển |
| `delivered_customer_date_key` | Khóa ngày giao hàng thực tế (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày giao hàng đến khách |
| `estimated_delivery_date_key` | Khóa ngày giao hàng dự kiến (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày giao hàng ước tính |
| `payment_type_key` | Khóa phương thức thanh toán (FK) | `INT` — Số nguyên | Liên kết tới `dim_payment.payment_type_key` — loại thanh toán chủ yếu của đơn |
| **Trạng thái đơn hàng** | | | |
| `order_status` | Trạng thái đơn hàng | `VARCHAR(20)` — Chuỗi ký tự | Trạng thái hiện tại: `delivered`, `shipped`, `canceled`, `processing`... |
| **Chỉ số thanh toán** | | | |
| `payment_installments` | Số kỳ trả góp | `INT` — Số nguyên | Số lần trả góp khách hàng chọn (1 = thanh toán một lần) |
| `payment_value` | Giá trị thanh toán | `DECIMAL(10,2)` — Số thập phân | Tổng giá trị thanh toán của đơn hàng (đơn vị: BRL) |
| **Chỉ số đánh giá** | | | |
| `review_score` | Điểm đánh giá | `TINYINT` — Số nguyên nhỏ | Điểm khách hàng chấm cho đơn hàng (1–5 sao) |
| `review_answer_delay_days` | Số ngày phản hồi đánh giá | `INT` — Số nguyên | Số ngày từ lúc đặt hàng đến khi khách gửi đánh giá |
| **Chỉ số giao hàng** | | | |
| `delivery_delay_days` | Số ngày trễ/sớm giao hàng | `INT` — Số nguyên | Độ lệch giữa ngày giao thực tế và ngày dự kiến (âm = giao sớm, dương = giao trễ) |
| `carrier_to_customer_days` | Số ngày vận chuyển đến khách | `INT` — Số nguyên | Số ngày từ lúc bàn giao cho vận chuyển đến lúc giao tới khách hàng |
| **Chỉ số đo lường** | | | |
| `total_items` | Tổng số sản phẩm | `INT` — Số nguyên | Tổng số lượng sản phẩm trong đơn hàng |
| `total_freight_value` | Tổng phí vận chuyển | `DECIMAL(10,2)` — Số thập phân | Tổng phí vận chuyển của toàn bộ đơn hàng (đơn vị: BRL) |
| `total_order_value` | Tổng giá trị đơn hàng | `DECIMAL(10,2)` — Số thập phân | Tổng giá trị đơn hàng bao gồm sản phẩm và phí vận chuyển (đơn vị: BRL) |

---

### 7. `fact_order_items` — Sự Kiện Chi Tiết Đơn Hàng

**Grain (Độ chi tiết):** 1 dòng = 1 sản phẩm trong 1 đơn hàng  
**Nguồn dữ liệu:** `olist_order_items` kết hợp `olist_orders`, `olist_products`, `olist_sellers`

| Tên Cột | Tên Tiếng Việt | Kiểu Dữ Liệu | Mô Tả |
|---|---|---|---|
| `order_item_key` | Khóa chi tiết đơn hàng (PK) | `INT` — Số nguyên tự tăng | Khóa chính nội bộ của DWH, tự động tăng |
| `order_id` | Mã đơn hàng | `VARCHAR(50)` — Chuỗi ký tự | Mã định danh đơn hàng từ hệ thống nguồn |
| `order_item_id` | Số thứ tự sản phẩm trong đơn | `TINYINT` — Số nguyên nhỏ | Thứ tự của sản phẩm trong cùng một đơn hàng (bắt đầu từ 1) |
| **Khóa ngoại (FK)** | | | |
| `order_key` | Khóa đơn hàng (FK) | `INT` — Số nguyên | Liên kết tới `fact_orders.order_key` |
| `product_key` | Khóa sản phẩm (FK) | `INT` — Số nguyên | Liên kết tới `dim_products.product_key` |
| `seller_key` | Khóa người bán (FK) | `INT` — Số nguyên | Liên kết tới `dim_seller.seller_key` |
| `customer_key` | Khóa khách hàng (FK) | `INT` — Số nguyên | Liên kết tới `dim_customer.customer_key` |
| `purchase_date_key` | Khóa ngày đặt hàng (FK) | `INT` — Số nguyên | Liên kết tới `dim_date.date_key` — ngày đặt hàng |
| **Chỉ số đo lường** | | | |
| `price` | Giá sản phẩm | `DECIMAL(10,2)` — Số thập phân | Giá bán của sản phẩm (đơn vị: BRL) |
| `freight_value` | Phí vận chuyển | `DECIMAL(10,2)` — Số thập phân | Phí vận chuyển tương ứng với sản phẩm này (đơn vị: BRL) |
| `total_item_value` | Tổng giá trị dòng sản phẩm | `DECIMAL(10,2)` — Số thập phân | Tổng giá trị = `price` + `freight_value` (đơn vị: BRL) |
| **Thông tin bổ sung** | | | |
| `shipping_limit_date` | Hạn giao hàng cho vận chuyển | `DATETIME` — Ngày giờ | Thời hạn tối đa người bán phải bàn giao hàng cho đơn vị vận chuyển |

---

## 🔑 Quy Ước Kiểu Dữ Liệu

| Kiểu Dữ Liệu | Ý Nghĩa |
|---|---|
| `INT` | Số nguyên (không giới hạn độ dài hiển thị) |
| `TINYINT` | Số nguyên nhỏ (−128 đến 127), dùng cho giá trị nhỏ như điểm, thứ, tháng |
| `SMALLINT` | Số nguyên vừa (−32,768 đến 32,767), dùng cho năm |
| `FLOAT` | Số thực dấu phẩy động, dùng cho kích thước, khối lượng |
| `DECIMAL(10,2)` | Số thập phân chính xác với 2 chữ số sau dấu phẩy, dùng cho tiền tệ |
| `CHAR(2)` | Chuỗi ký tự cố định đúng 2 ký tự (ví dụ: mã bang SP, RJ) |
| `VARCHAR(n)` | Chuỗi ký tự có độ dài biến thiên tối đa n ký tự |
| `DATE` | Ngày tháng định dạng YYYY-MM-DD |
| `DATETIME` | Ngày và giờ định dạng YYYY-MM-DD HH:MM:SS |
| `BOOLEAN` | Giá trị logic TRUE / FALSE |