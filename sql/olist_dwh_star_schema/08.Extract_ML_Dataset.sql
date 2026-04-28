use olist_dwh;

drop table if exists ml_dataset;

create table ml_dataset(

	-- TARGER
	review_score int,				-- Điểm đánh giá gốc từ 1-5
    is_satisfied tinyint(1),		-- Target: hài lòng 1(4-5s) không hài lòng 0 (1-3s)
    
    -- DELIVERY
    delivery_delay_days 	int,	-- Số ngày trễ so vơi dự kiến
    estimated_delivery_days int, 	-- Số ngày dự kiến giao hàng
    
    -- ORDER
    total_order_value       decimal(10,2), -- Tổng giá trị đơn hàng
    total_freight_value     decimal(10,2), -- Tổng phí vận chuyển
    total_items 			int,  		   -- Tổng số sản phẩm
    freight_ratio           decimal(10,4),  -- Tỉ lệ phí vận chuyển / giá trị đơn
    payment_installments	int, 		   -- Số kỳ trả góp
    payment_value     		decimal(10,2), -- Giá trị thanh toán
    
    -- PAYMENT
    payment_type			varchar(50),   -- Kiểu thanh toán
    
    -- PRODUCT
    category_name_english 	varchar(50),	-- Tên sản phâm bằng tiếng anh
    product_photo_qty		int, 			-- Số lượng ảnh sản phẩm
    product_weight_g		float,			-- Khối lượng sản phẩm
    
    -- GEO
    customer_state  varchar(10),   -- Bang của khách hàng
    seller_state    varchar(10),   -- Bang của người bán
    same_state      tinyint(1),    -- 1 nếu cùng bang
    
    -- TIME
	month      		int, 		-- Tháng đặt hàng (1–12),
    quarter         int,    	-- Quý đặt hàng (1–4),
    day_of_week     int, 	    -- Thứ trong tuần (0=Thứ Hai, 6=Chủ Nhật),
    is_weekend      tinyint(1)  -- 1 nếu đặt hàng vào cuối tuần
) engine = InnoDB
DEFAULT CHARSET=utf8mb4;

insert into ml_dataset
select 
	fo.review_score as review_score,
    case when fo.review_score >=4 then 1 else 0 end as is_satisfied,
    
    -- DELIVERY
    COALESCE(fo.delivery_delay_days, 0) as delivery_delay_days, 
    (fo.estimated_delivery_date_key - fo.purchase_date_key) as estimated_delivery_days,
    
    -- ORDER
    fo.total_order_value,
    fo.total_freight_value,
    fo.total_items,
	ROUND(fo.total_freight_value / NULLIF(fo.total_order_value, 0),4) as freight_ratio,
    fo.payment_installments,
    fo.payment_value,
    
    -- PAYMENT
    dp.payment_type as payment_type,
    
    -- PRODUCT
    coalesce(dpd.category_name_english, 'Unknown') as category_name_english,
    coalesce(dpd.product_photos_qty,
			( select round(avg(product_photos_qty), 2)
			  from dim_products
              where product_photos_qty is not null)
    ) as product_photos_qty,
    coalesce(dpd.product_weight_g, 
			(select round(avg(product_weight_g), 2)
            from dim_products
            where product_weight_g is not null)
    ) as product_weight_g,
    
    -- GEO
    dc.customer_state as customer_state,
	coalesce(ds.seller_state, 'Unknown')             as seller_state,
    if(dc.customer_state = ds.seller_state, 1, 0)    as same_state,
    
    -- TIME
    dd.month,
    dd.quarter,
    dd.day_of_week,
    dd.is_weekend
from fact_orders as fo
join dim_payment as dp on fo.payment_type_key = dp.payment_type_key
join dim_date as dd on fo.purchase_date_key = dd.date_key

-- Item đầu tiên của mỗi đơn (để lấy product seller customer)
left join(
	select order_key,
		min(product_key) as product_key,
        min(seller_key) as seller_key,
        min(customer_key) as customer_key
	from fact_order_items 
    group by order_key
)as foi on fo.order_key = foi.order_key

left join dim_products as dpd on foi.product_key = dpd.product_key
left join dim_seller as ds on foi.seller_key = ds.seller_key 
left join dim_customer as dc on foi.customer_key = dc.customer_key

WHERE fo.review_score IS NOT NULL AND fo.order_status = 'delivered';

