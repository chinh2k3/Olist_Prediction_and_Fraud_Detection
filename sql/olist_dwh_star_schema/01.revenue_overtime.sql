use olist_dwh;
/*
Tổng doanh thu (payment_value) theo từng tháng/quý/năm?
Số đơn hàng đặt theo từng tháng — có xu hướng tăng trưởng không?
Giá trị đơn hàng trung bình (AOV) theo từng tháng?
Tháng nào có doanh thu cao nhất và thấp nhất trong toàn dataset?
Tăng trưởng doanh thu YoY (Year over Year) giữa 2017 và 2018?
Phân phối đơn hàng theo ngày trong tuần — ngày nào có nhiều đơn nhất?
*/
select 
    concat('Q', dd.quarter, '-', dd.year ) as ky_bao_cao,
    count(payment_value) as doanh_thu
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.quarter, dd.year;

select 
    concat(dd.month,'/', dd.year) as ky_bao_cao,
    count(payment_value) as doanh_thu
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.month, dd.year



