-- 無論是否滿位，都列出完整車位狀況
SELECT 
    spot_id, 
    location, 
    is_available,
    CASE 
        WHEN is_available = 1 THEN N'✅ 空位'
        ELSE N'⛔ 已佔用'
    END AS 狀態
FROM ParkingSpot
ORDER BY spot_id;