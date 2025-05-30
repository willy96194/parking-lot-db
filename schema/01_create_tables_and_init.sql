
-- ======================================
-- STEP 1: 清空並重置 ParkingSpot 表格
-- ======================================
-- (OK)清空資料，並重置 ParkingSpot 表格
DELETE FROM PaymentRecord;

DELETE FROM ParkingRecord;

DELETE FROM ParkingSpot;
DBCC CHECKIDENT ('ParkingSpot', RESEED, 0);
GO

-- 開啟允許手動給 spot_id
SET IDENTITY_INSERT ParkingSpot ON;
GO

-- 插入 30 筆資料（含 B1 / B2 命名）
WITH numbers AS (
  SELECT TOP 30 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
)
INSERT INTO ParkingSpot (spot_id, is_available, location)
SELECT
  n,
  1,
  CASE
    WHEN n <= 10 THEN CONCAT('B1-', FORMAT(n, '00'))
    ELSE CONCAT('B2-', FORMAT(n - 10, '00'))
  END
FROM numbers;
GO

-- 關閉手動插入
SET IDENTITY_INSERT ParkingSpot OFF;
GO



-- ======================================
-- STEP 2: 建立 ChargeParkingFee 預存程序
-- ======================================
CREATE PROCEDURE ChargeParkingFee 
    @plate_number NVARCHAR(20),
    @method NVARCHAR(20)  -- 新增付款方式參數
AS
BEGIN
    DECLARE @rate_per_hour INT = 60;
    DECLARE @record_id INT;
    DECLARE @entry_time DATETIME, @exit_time DATETIME;
    DECLARE @duration_minutes INT, @hours INT;

    SELECT TOP 1 
        @record_id = record_id,
        @entry_time = entry_time,
        @exit_time = exit_time
    FROM ParkingRecord
    WHERE plate_number = @plate_number
    ORDER BY entry_time DESC;

    IF @exit_time IS NULL
    BEGIN
        PRINT '此車尚未離場，無法計費';
        RETURN;
    END

    SET @duration_minutes = DATEDIFF(MINUTE, @entry_time, @exit_time);
    SET @hours = CEILING(@duration_minutes / 60.0);

    -- 使用傳入的付款方式
    INSERT INTO PaymentRecord (amount, method, payment_time, record_id)
    VALUES (@rate_per_hour * @hours, @method, GETDATE(), @record_id);
END;

-- ======================================
-- STEP 3: 查詢目前空位狀態（可重複執行）
-- ======================================
--(Main)進場前車位查詢

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



-- ======================================
-- STEP 4: 模擬一輛車進場、出場與付款
-- ======================================

-- 先插入車輛資訊（若不存在）
IF NOT EXISTS (SELECT 1 FROM Vehicle WHERE plate_number = N'NEW2345')
BEGIN
    INSERT INTO Vehicle (plate_number, owner_name, contact_number)
    VALUES (N'NEW2345', N'王小明', N'0912345678');
END

-- -- 模擬進場（1 小時前）
-- INSERT INTO ParkingRecord (entry_time, plate_number, spot_id)
-- VALUES (DATEADD(HOUR, -1, GETDATE()), N'NEW2345', 2);

EXEC EnterParking 
    @plate_number = N'NEW2345',
    @owner_name = N'王小明',
    @contact_number = N'0912345678',
    @spot_id = 2;

-- -- 模擬離場（現在時間）
-- UPDATE ParkingRecord
-- SET exit_time = GETDATE()
-- WHERE plate_number = N'NEW2345' AND exit_time IS NULL;

EXEC ExitParking 
    @plate_number = N'NEW2345',
    @method = N'現金';  -- 或其他付款方式，例如 '悠遊卡'

-- -- 呼叫計費儲存程序，付款方式為「現金」
-- EXEC ChargeParkingFee @plate_number = N'NEW2345', @method = N'現金';

-- 查詢付款紀錄
SELECT TOP 1 *
FROM PaymentRecord pr
JOIN ParkingRecord pk ON pr.record_id = pk.record_id
WHERE pk.plate_number = N'NEW2345'
ORDER BY pr.payment_time DESC;




