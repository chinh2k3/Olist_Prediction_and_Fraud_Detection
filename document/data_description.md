# TÀI LIỆU MÔ TẢ DỮ LIỆU
## Bộ Dữ Liệu Olist E-Commerce Brazil

> Mô tả các cột dữ liệu và ý nghĩa tương ứng bằng tiếng Việt

---

## 1. Bảng `olist_order_items` (Chi tiết đơn hàng)

Chứa thông tin từng sản phẩm trong một đơn hàng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `order_id` | Mã đơn hàng | Mã định danh duy nhất của đơn hàng |
| `order_item_id` | Số thứ tự sản phẩm | Số thứ tự của sản phẩm trong cùng một đơn hàng (bắt đầu từ 1) |
| `product_id` | Mã sản phẩm | Mã định danh duy nhất của sản phẩm được đặt mua |
| `seller_id` | Mã người bán | Mã định danh duy nhất của người bán cung cấp sản phẩm |
| `shipping_limit_date` | Hạn giao hàng cho vận chuyển | Thời hạn tối đa người bán cần bàn giao hàng cho đơn vị vận chuyển |
| `price` | Giá sản phẩm | Giá bán của sản phẩm (đơn vị: BRL - Real Brazil) |
| `freight_value` | Phí vận chuyển | Phí vận chuyển tương ứng với sản phẩm trong đơn hàng |

---

## 2. Bảng `olist_customers` (Khách hàng)

Chứa thông tin về khách hàng đặt hàng trên nền tảng Olist.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `customer_id` | Mã khách hàng | Mã định danh duy nhất của khách hàng trong từng đơn hàng (có thể lặp lại nếu khách đặt nhiều đơn) |
| `customer_unique_id` | Mã khách hàng duy nhất | Mã định danh duy nhất của khách hàng trên toàn hệ thống (không trùng lặp dù đặt nhiều đơn) |
| `customer_zip_code_prefix` | Mã bưu chính (5 số đầu) | 5 chữ số đầu của mã bưu chính nơi khách hàng cư trú |
| `customer_city` | Thành phố | Tên thành phố nơi khách hàng sinh sống |
| `customer_state` | Bang/Tỉnh | Mã bang nơi khách hàng cư trú theo tiêu chuẩn Brazil (2 chữ cái) |

---

## 3. Bảng `olist_orders` (Đơn hàng)

Chứa thông tin tổng quan về trạng thái và mốc thời gian của từng đơn hàng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `order_id` | Mã đơn hàng | Mã định danh duy nhất của đơn hàng |
| `customer_id` | Mã khách hàng | Mã khách hàng liên kết với bảng olist_customers |
| `order_status` | Trạng thái đơn hàng | Trạng thái hiện tại của đơn hàng (ví dụ: delivered, shipped, canceled...) |
| `order_purchase_timestamp` | Thời điểm đặt hàng | Ngày và giờ khách hàng thực hiện đặt hàng |
| `order_approved_at` | Thời điểm xác nhận thanh toán | Ngày và giờ đơn hàng được xác nhận thanh toán thành công |
| `order_delivered_carrier_date` | Ngày giao cho vận chuyển | Ngày đơn hàng được bàn giao cho đơn vị vận chuyển |
| `order_delivered_customer_date` | Ngày giao tới khách hàng | Ngày đơn hàng thực tế được giao đến tay khách hàng |
| `order_estimated_delivery_date` | Ngày giao hàng dự kiến | Ngày giao hàng ước tính được thông báo cho khách hàng khi đặt đơn |

---

## 4. Bảng `olist_products` (Sản phẩm)

Chứa thông tin mô tả về các sản phẩm được bán trên nền tảng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `product_id` | Mã sản phẩm | Mã định danh duy nhất của sản phẩm |
| `product_category_name` | Tên danh mục sản phẩm | Danh mục sản phẩm theo tên tiếng Bồ Đào Nha |
| `product_name_lenght` | Độ dài tên sản phẩm | Số ký tự trong tên sản phẩm |
| `product_description_lenght` | Độ dài mô tả sản phẩm | Số ký tự trong phần mô tả sản phẩm |
| `product_photos_qty` | Số lượng ảnh sản phẩm | Số lượng ảnh được đăng kèm sản phẩm |
| `product_weight_g` | Khối lượng sản phẩm (gram) | Khối lượng của sản phẩm tính bằng gram |
| `product_length_cm` | Chiều dài (cm) | Chiều dài của sản phẩm tính bằng centimét |
| `product_height_cm` | Chiều cao (cm) | Chiều cao của sản phẩm tính bằng centimét |
| `product_width_cm` | Chiều rộng (cm) | Chiều rộng của sản phẩm tính bằng centimét |

---

## 5. Bảng `olist_sellers` (Người bán)

Chứa thông tin địa lý và định danh của người bán hàng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `seller_id` | Mã người bán | Mã định danh duy nhất của người bán trên nền tảng Olist |
| `seller_zip_code_prefix` | Mã bưu chính người bán | 5 chữ số đầu của mã bưu chính nơi người bán đăng ký kinh doanh |
| `seller_city` | Thành phố người bán | Tên thành phố nơi người bán hoạt động |
| `seller_state` | Bang/Tỉnh người bán | Mã bang nơi người bán hoạt động (2 chữ cái theo tiêu chuẩn Brazil) |

---

## 6. Bảng `olist_order_payments` (Thanh toán)

Chứa thông tin về phương thức và giá trị thanh toán của từng đơn hàng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `order_id` | Mã đơn hàng | Mã định danh đơn hàng liên kết với bảng olist_orders |
| `payment_type` | Phương thức thanh toán | Hình thức thanh toán (ví dụ: credit_card, boleto, voucher, debit_card) |
| `payment_installments` | Số kỳ trả góp | Số lần trả góp mà khách hàng chọn để thanh toán (1 = trả một lần) |
| `payment_value` | Giá trị thanh toán | Tổng số tiền thanh toán cho kỳ hoặc lần thanh toán đó (đơn vị: BRL) |

---

## 7. Bảng `olist_reviews` (Đánh giá đơn hàng)

Chứa đánh giá và nhận xét của khách hàng sau khi nhận hàng.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `review_id` | Mã đánh giá | Mã định danh duy nhất của bản đánh giá |
| `order_id` | Mã đơn hàng | Mã đơn hàng được đánh giá, liên kết với bảng olist_orders |
| `review_score` | Điểm đánh giá | Điểm số khách hàng chấm cho đơn hàng (từ 1 đến 5 sao) |
| `review_comment_message` | Nội dung nhận xét | Nội dung bình luận, nhận xét bằng văn bản của khách hàng (có thể NULL nếu không có) |

---

## 8. Bảng `olist_geolocation` (Địa lý)

Chứa thông tin tọa độ địa lý tương ứng với mã bưu chính tại Brazil.

| Tên Cột (Tiếng Anh) | Tên Cột (Tiếng Việt) | Mô tả dữ liệu |
|---|---|---|
| `geolocation_zip_code_prefix` | Mã bưu chính | 5 chữ số đầu của mã bưu chính tại Brazil |
| `geolocation_lat` | Vĩ độ | Tọa độ vĩ độ (latitude) của khu vực tương ứng mã bưu chính |
| `geolocation_lng` | Kinh độ | Tọa độ kinh độ (longitude) của khu vực tương ứng mã bưu chính |
| `geolocation_city` | Thành phố | Tên thành phố tương ứng với mã bưu chính |
| `geolocation_state` | Bang/Tỉnh | Mã bang tương ứng với mã bưu chính (2 chữ cái theo tiêu chuẩn Brazil) |