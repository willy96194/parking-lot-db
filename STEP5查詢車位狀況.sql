-- (Main) 查詢車位狀況
DECLARE @空位數 INT;

-- 查詢空位數
SELECT @空位數 = COUNT(*)
FROM ParkingSpot
WHERE is_available = 1;

-- 顯示空位數與狀態
IF @空位數 > 0
BEGIN
    PRINT N'✅ 目前尚有 ' + CAST(@空位數 AS VARCHAR) + N' 個空車位';
END
ELSE
BEGIN
    PRINT N'❌ 目前空位數 0';
    PRINT N'⚠️ 車位已滿';
END
