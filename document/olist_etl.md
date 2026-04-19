# Tài liệu ETL Pipeline — Olist Brazilian E-Commerce

## Mục lục
1. [Tổng quan](#1-tổng-quan)
2. [Kiến trúc Star Schema](#2-kiến-trúc-star-schema)
3. [Cấu hình & Kết nối](#3-cấu-hình--kết-nối)
4. [Luồng thực thi ETL](#4-luồng-thực-thi-etl)
5. [Chi tiết từng bước](#5-chi-tiết-từng-bước)
   - [5.1 Helper Functions](#51-helper-functions)
   - [5.2 dim_date](#52-dim_date)
   - [5.3 dim_customer](#53-dim_customer)
   - [5.4 dim_seller](#54-dim_seller)
   - [5.5 dim_product](#55-dim_product)
   - [5.6 load_key_maps](#56-load_key_maps)
   - [5.7 fact_orders](#57-fact_orders)
   - [5.8 fact_order_items](#58-fact_order_items)
6. [Khái niệm Surrogate Key](#6-khái-niệm-surrogate-key)
7. [Xử lý dữ liệu thiếu](#7-xử-lý-dữ-liệu-thiếu)
8. [Thứ tự load & ràng buộc FK](#8-thứ-tự-load--ràng-buộc-fk)

---

## 1. Tổng quan

Pipeline này thực hiện toàn bộ quá trình **ETL (Extract → Transform → Load)** cho bộ dữ liệu thương mại điện tử Olist (Brazil), chuyển đổi dữ liệu thô từ nhiều file CSV sang một **Data Warehouse** theo mô hình **Star Schema** lưu trên MySQL.

| Thông tin | Chi tiết |
|---|---|
| Nguồn dữ liệu | 8 file CSV từ Olist dataset |
| Đích đến | MySQL database `olist_dwh` |
| Mô hình | Star Schema (2 fact + 5 dim) |
| Ngôn ngữ | Python (pandas, SQLAlchemy) |

### File CSV đầu vào

| File | Nội dung |
|---|---|
| `olist_customers_dataset.csv` | Thông tin khách hàng |
| `olist_sellers_dataset.csv` | Thông tin người bán |
| `olist_products_dataset.csv` | Thông tin sản phẩm |
| `product_category_name_translation.csv` | Dịch tên danh mục PT → EN |
| `olist_orders_dataset.csv` | Đơn hàng và trạng thái |
| `olist_order_items_dataset.csv` | Chi tiết từng sản phẩm trong đơn |
| `olist_order_payments_dataset.csv` | Thông tin thanh toán |
| `olist_order_reviews_dataset.csv` | Đánh giá của khách hàng |

---

## 2. Kiến trúc Star Schema

```
                        ┌──────────────┐
                        │   dim_date   │
                        │──────────────│
                        │ date_key (PK)│
                        │ full_date    │
                        │ day / month  │
                        │ quarter/year │
                        │ is_weekend   │
                        └──────┬───────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
┌─────────┴──────┐   ┌─────────┴──────────┐  ┌─────┴────────────┐
│  dim_customer  │   │    fact_orders     │  │  dim_payment_type│
│────────────────│   │────────────────────│  │──────────────────│
│customer_key(PK)│◄──│ customer_key (FK)  │  │payment_type_key  │
│ customer_id    │   │ purchase_date_key  │──►│ payment_type     │
│ customer_city  │   │ approved_date_key  │   └──────────────────┘
│ customer_state │   │ delivered_date_key │
└────────────────┘   │ order_status       │
                     │ review_score       │
                     │ delivery_delay_days│
                     │ total_order_value  │
                     └─────────┬──────────┘
                               │ order_key
                     ┌─────────▼──────────┐
                     │  fact_order_items  │
                     │────────────────────│
                     │ order_key (FK)     │──► fact_orders
                     │ product_key (FK)   │──► dim_product
                     │ seller_key (FK)    │──► dim_seller
                     │ customer_key (FK)  │──► dim_customer
                     │ purchase_date_key  │──► dim_date
                     │ price              │
                     │ freight_value      │
                     │ total_item_value   │
                     └────────────────────┘
```

**Giải thích mô hình:**
- **Fact table** chứa các **chỉ số đo lường** (giá, số lượng, điểm đánh giá...)
- **Dimension table** chứa **ngữ cảnh** (khách hàng là ai, sản phẩm là gì, ngày nào...)
- Fact table liên kết với Dim table thông qua **surrogate key** (số nguyên tự sinh)

---

## 3. Cấu hình & Kết nối

```python
DB_USER     = "root"
DB_PASSWORD = "your_password"
DB_HOST     = "localhost"
DB_PORT     = 3306
DB_NAME     = "olist_dwh"
DATA_DIR    = "./data"
```

- Kết nối MySQL thông qua `SQLAlchemy` với driver `pymysql`
- `DATA_DIR` là thư mục chứa toàn bộ file CSV đầu vào
- `engine` là đối tượng kết nối dùng chung cho toàn bộ pipeline

---

## 4. Luồng thực thi ETL

```
run_etl()
    │
    ├─ 1. TRUNCATE tất cả bảng (tắt FK check tạm thời)
    │
    ├─ 2. Load Dimension Tables
    │       ├─ build_dim_date()       → dim_date
    │       ├─ build_dim_customer()   → dim_customer
    │       ├─ build_dim_seller()     → dim_seller
    │       └─ build_dim_product()    → dim_product
    │          (dim_payment_type đã seed sẵn qua DDL)
    │
    ├─ 3. load_key_maps()
    │       └─ Đọc surrogate key vừa được sinh ra từ DB
    │          → Tạo dict tra cứu: business_id → surrogate_key
    │
    └─ 4. Load Fact Tables (dùng maps để đổi ID → Key)
            ├─ build_fact_orders(maps)       → fact_orders
            └─ build_fact_order_items(maps)  → fact_order_items
```

**Tại sao phải load Dim trước Fact?**
Vì Fact table chứa foreign key trỏ sang Dim table. Nếu Dim chưa có dữ liệu thì không thể insert Fact (vi phạm ràng buộc FK).

---

## 5. Chi tiết từng bước

### 5.1 Helper Functions

#### `load_csv(filename)`
Đọc file CSV từ `DATA_DIR` và trả về DataFrame. In tên file đang được đọc để theo dõi tiến trình.

#### `to_date_key(series)`
Chuyển đổi cột datetime sang dạng **integer YYYYMMDD** để dùng làm foreign key liên kết với `dim_date`.

```
Ví dụ:
  2017-09-13  →  20170913
  NaT (null)  →  None
```

Lý do dùng integer thay vì lưu trực tiếp ngày: tốc độ JOIN nhanh hơn và dễ lọc theo khoảng thời gian (`WHERE purchase_date_key BETWEEN 20170101 AND 20171231`).

#### `insert_table(df, table)`
Ghi DataFrame vào MySQL với `chunksize=5000` để tránh timeout khi insert dữ liệu lớn.

---

### 5.2 dim_date

**Hàm:** `build_dim_date(start, end)`

**Mục đích:** Tạo bảng lịch từ 2016-01-01 đến 2019-12-31, mỗi ngày là 1 dòng.

**Các cột được tạo ra:**

| Cột | Ý nghĩa | Ví dụ |
|---|---|---|
| `date_key` | Khóa chính dạng int | `20170913` |
| `full_date` | Ngày đầy đủ | `2017-09-13` |
| `day` | Ngày trong tháng | `13` |
| `month` | Tháng | `9` |
| `month_name` | Tên tháng | `September` |
| `quarter` | Quý | `3` |
| `year` | Năm | `2017` |
| `week_of_year` | Tuần trong năm (ISO) | `37` |
| `day_of_week` | Thứ (0=Thứ Hai) | `2` |
| `day_name` | Tên thứ | `Wednesday` |
| `is_weekend` | Có phải cuối tuần không | `False` |

**Lý do cần bảng này:** Thay vì JOIN trực tiếp với datetime, DWH lưu `date_key` (integer) để có thể dễ dàng phân tích theo ngày/tháng/quý/năm mà không cần tính toán mỗi lần query.

---

### 5.3 dim_customer

**Hàm:** `build_dim_customer()`

**Nguồn:** `olist_customers_dataset.csv`

**Xử lý:**
- Đổi tên cột `customer_zip_code_prefix` → `customer_zip_code` cho gọn hơn
- Loại bỏ duplicate theo `customer_id`
- Surrogate key (`customer_key`) được MySQL tự sinh bằng `AUTO_INCREMENT` khi insert

**Các cột đầu ra:**

| Cột | Ý nghĩa |
|---|---|
| `customer_id` | Business key từ source (giữ để trace lại nguồn) |
| `customer_unique_id` | ID duy nhất của người dùng thực (1 người có thể có nhiều customer_id) |
| `customer_zip_code` | Mã bưu điện |
| `customer_city` | Thành phố |
| `customer_state` | Bang |

---

### 5.4 dim_seller

**Hàm:** `build_dim_seller()`

**Nguồn:** `olist_sellers_dataset.csv`

**Xử lý:**
- Đổi tên `seller_zip_code_prefix` → `seller_zip_code`
- Loại bỏ duplicate theo `seller_id`

**Các cột đầu ra:**

| Cột | Ý nghĩa |
|---|---|
| `seller_id` | Business key từ source |
| `seller_zip_code` | Mã bưu điện |
| `seller_city` | Thành phố |
| `seller_state` | Bang |

---

### 5.5 dim_product

**Hàm:** `build_dim_product()`

**Nguồn:** `olist_products_dataset.csv` + `product_category_name_translation.csv`

**Xử lý đặc biệt:**
- Merge với bảng translation để có tên danh mục bằng **tiếng Anh** (nguồn gốc là tiếng Bồ Đào Nha)
- Sửa lỗi typo từ source: `product_name_lenght` → `product_name_length`

**Các cột đầu ra:**

| Cột | Ý nghĩa |
|---|---|
| `product_id` | Business key từ source |
| `category_name_portuguese` | Tên danh mục tiếng Bồ Đào Nha |
| `category_name_english` | Tên danh mục tiếng Anh |
| `product_name_length` | Độ dài tên sản phẩm (ký tự) |
| `product_description_length` | Độ dài mô tả (ký tự) |
| `product_photos_qty` | Số ảnh sản phẩm |
| `product_weight_g` | Cân nặng (gram) |
| `product_length_cm` | Chiều dài (cm) |
| `product_height_cm` | Chiều cao (cm) |
| `product_width_cm` | Chiều rộng (cm) |

---

### 5.6 load_key_maps

**Hàm:** `load_key_maps()`

**Mục đích:** Sau khi insert các bảng Dim vào DB, MySQL đã tự sinh ra các surrogate key. Hàm này đọc lại từ DB để tạo **dict tra cứu** dùng cho bước build Fact.

**Kết quả trả về:**

```python
{
  "customer": {"abc123": 1, "def456": 2, ...},   # customer_id → customer_key
  "seller":   {"sel001": 1, "sel002": 2, ...},   # seller_id   → seller_key
  "product":  {"prod_x": 1, "prod_y": 2, ...},   # product_id  → product_key
  "payment":  {"credit_card": 1, "boleto": 2, ...} # payment_type → payment_type_key
}
```

**Tại sao cần bước này?**

Fact table từ source chỉ biết business ID (ví dụ `customer_id = "abc123"`), không biết surrogate key mà MySQL đã sinh ra. Phải tra cứu dict này để điền đúng `customer_key` vào fact table trước khi insert.

---

### 5.7 fact_orders

**Hàm:** `build_fact_orders(maps)`

**Nguồn:** 4 file CSV được merge lại: `orders` + `payments` + `reviews` + `items`

**Các bước xử lý:**

**1. Parse datetime:**
Chuyển 4 cột timestamp sang kiểu datetime để tính toán được.

**2. Aggregate payments:**
Mỗi đơn hàng có thể có nhiều dòng thanh toán (trả góp nhiều kỳ). Pipeline lấy:
- **Loại thanh toán chủ đạo** = loại có giá trị thanh toán cao nhất
- **Tổng giá trị thanh toán** = tổng tất cả các kỳ

**3. Aggregate items:**
Tính tổng số lượng sản phẩm và tổng phí vận chuyển cho mỗi đơn.

**4. Aggregate reviews:**
Nếu 1 đơn có nhiều đánh giá → lấy **điểm cao nhất** và **ngày tạo sớm nhất**.

**5. Tính chỉ số dẫn xuất:**

| Chỉ số | Công thức | Ý nghĩa |
|---|---|---|
| `delivery_delay_days` | `delivered_dt - estimated_dt` | Số ngày giao hàng trễ (âm = giao sớm) |
| `review_answer_delay_days` | `review_creation_date - purchase_dt` | Số ngày từ lúc mua đến khi đánh giá |

**6. Map surrogate key:**
- `customer_id` → `customer_key` (tra `maps["customer"]`)
- `payment_type` → `payment_type_key` (tra `maps["payment"]`)

**7. Lọc dữ liệu:**
Bỏ các dòng thiếu `customer_key` hoặc `purchase_date_key` vì đây là FK bắt buộc.

**Các cột đầu ra:**

| Cột | Kiểu | Ý nghĩa |
|---|---|---|
| `order_id` | string | Business key của đơn hàng |
| `customer_key` | int | FK → dim_customer |
| `purchase_date_key` | int | FK → dim_date (ngày đặt hàng) |
| `approved_date_key` | int | FK → dim_date (ngày duyệt) |
| `delivered_date_key` | int | FK → dim_date (ngày giao) |
| `estimated_delivery_date_key` | int | FK → dim_date (ngày dự kiến giao) |
| `order_status` | string | Trạng thái đơn hàng |
| `payment_type_key` | int | FK → dim_payment_type |
| `payment_installments` | int | Số kỳ trả góp |
| `payment_value` | float | Giá trị thanh toán chủ đạo |
| `review_score` | int | Điểm đánh giá (1-5) |
| `review_answer_delay_days` | int | Số ngày từ mua → đánh giá |
| `delivery_delay_days` | int | Số ngày trễ so với dự kiến |
| `total_items` | int | Tổng số sản phẩm trong đơn |
| `total_freight_value` | float | Tổng phí vận chuyển |
| `total_order_value` | float | Tổng giá trị đơn hàng |

---

### 5.8 fact_order_items

**Hàm:** `build_fact_order_items(maps)`

**Nguồn:** `olist_order_items_dataset.csv` + `olist_orders_dataset.csv`

**Mục đích:** Bảng fact ở **độ chi tiết thấp hơn** — mỗi dòng là 1 sản phẩm trong 1 đơn hàng (trong khi `fact_orders` mỗi dòng là 1 đơn).

**Xử lý đặc biệt:**
- Tính `total_item_value = price + freight_value`
- Tra thêm `order_key` từ DB (sau khi `fact_orders` đã được insert)
- Map 3 surrogate key: `product_key`, `seller_key`, `customer_key`

**Các cột đầu ra:**

| Cột | Kiểu | Ý nghĩa |
|---|---|---|
| `order_id` | string | Business key đơn hàng |
| `order_item_id` | int | Số thứ tự sản phẩm trong đơn |
| `order_key` | int | FK → fact_orders |
| `product_key` | int | FK → dim_product |
| `seller_key` | int | FK → dim_seller |
| `customer_key` | int | FK → dim_customer |
| `purchase_date_key` | int | FK → dim_date |
| `price` | float | Giá sản phẩm |
| `freight_value` | float | Phí vận chuyển cho sản phẩm này |
| `total_item_value` | float | Tổng giá (giá + ship) |
| `shipping_limit_date` | datetime | Hạn chót giao hàng cho người bán |

---

## 6. Khái niệm Surrogate Key

Đây là khái niệm trung tâm của toàn bộ pipeline.

**Business Key (Natural Key):** ID gốc từ hệ thống nguồn
- Ví dụ: `customer_id = "abc123ef..."` (UUID dạng string)
- Có thể trùng nếu đến từ nhiều source khác nhau
- JOIN bằng string → chậm

**Surrogate Key:** ID mới do DWH tự sinh
- Ví dụ: `customer_key = 1, 2, 3, ...` (integer auto increment)
- Luôn unique trong DWH
- JOIN bằng integer → nhanh

```
Luồng dữ liệu:

Source CSV                DWH
───────────               ─────────────────────────────
customer_id="abc123"  →   customer_key=1, customer_id="abc123"
customer_id="def456"  →   customer_key=2, customer_id="def456"

Fact table sẽ lưu:
  customer_key=1  (không lưu "abc123")
```

**Tại sao giữ lại `customer_id` trong dim?**
Để có thể trace ngược lại nguồn gốc khi cần debug hoặc reconcile dữ liệu.

---

## 7. Xử lý dữ liệu thiếu

| Trường hợp | Cách xử lý |
|---|---|
| Datetime null | `pd.to_datetime(..., errors="coerce")` → `NaT`, sau đó `to_date_key` → `None` |
| Surrogate key không tìm thấy | `dropna(subset=[...])` — loại bỏ dòng đó khỏi fact |
| Payment type không xác định | Fallback về key `5` (payment type "not_defined") |
| Review có nhiều dòng/đơn | Lấy score cao nhất, ngày đánh giá sớm nhất |
| Payment có nhiều kỳ/đơn | Lấy kỳ có giá trị cao nhất làm đại diện, cộng dồn tổng |

---

## 8. Thứ tự load & ràng buộc FK

```
TRUNCATE (FK disabled)
    ↓
dim_date
dim_customer
dim_seller
dim_product
(dim_payment_type — đã seed sẵn, không truncate)
    ↓
load_key_maps()   ← đọc surrogate key vừa được sinh
    ↓
fact_orders
    ↓
fact_order_items  ← cần order_key từ fact_orders
```

**Lý do tắt FK check khi TRUNCATE:**
MySQL không cho phép truncate bảng Dim nếu Fact đang có FK trỏ vào. Pipeline tắt kiểm tra FK tạm thời (`SET FOREIGN_KEY_CHECKS = 0`), truncate toàn bộ, rồi bật lại trước khi insert để đảm bảo dữ liệu mới vẫn đúng ràng buộc.