-- 查詢付款紀錄
SELECT TOP 1 *
FROM PaymentRecord pr
JOIN ParkingRecord pk ON pr.record_id = pk.record_id
WHERE pk.plate_number = N'ABC-0001'
ORDER BY pr.payment_time DESC;
