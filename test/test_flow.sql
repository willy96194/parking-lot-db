

-- ================================
-- 車輛資訊表.sql
-- ================================
-- -- -- 1. 車輛資訊表：儲存每一輛車的基本資訊，並與車主 (Userinfo) 關聯
-- -- CREATE TABLE Vehicle (
-- --     plate_number NVARCHAR(10) PRIMARY KEY,      -- 車牌號碼，主鍵，唯一識別每輛車
-- --     uid NVARCHAR(20),                           -- 車主的使用者編號（對應 Userinfo 表的 uid）
-- --     brand NVARCHAR(50),                         -- 車輛品牌，如 Toyota、Tesla 等
-- --     color NVARCHAR(30),                         -- 車輛顏色
-- --     FOREIGN KEY (uid) REFERENCES Userinfo(uid)  -- 外鍵，連接到 Userinfo 表
-- -- );
-- INSERT INTO Vehicle (plate_number, brand, color)
-- VALUES 
-- (N'ABC-0001',  N'Toyota', N'White'),
-- (N'ABC-0002',  N'Honda', N'Black'),
-- (N'ABC-0003',  N'Toyota', N'Silver'),
-- (N'ABC-0004',  N'Honda', N'Black'),
-- (N'ABC-0005',  N'Ford', N'Blue'),
-- (N'ABC-0006',  N'Toyota', N'White'),
-- (N'ABC-0007',  N'Ford', N'Gray'),
-- (N'ABC-0008',  N'Honda', N'Black'),
-- (N'ABC-0009',  N'Nissan', N'Red'),
-- (N'ABC-0010',  N'Toyota', N'Silver'),
-- (N'ABC-0011',  N'Nissan', N'Red'),
-- (N'ABC-0012',  N'Toyota', N'White'),
-- (N'ABC-0013',  N'Ford', N'Gray'),
-- (N'ABC-0014',  N'Honda', N'Black'),
-- (N'ABC-0015',  N'Toyota', N'Silver'),
-- (N'ABC-0016',  N'Nissan', N'Red'),
-- (N'ABC-0017',  N'Ford', N'Blue'),
-- (N'ABC-0018',  N'Honda', N'Black'),
-- (N'ABC-0019',  N'Toyota', N'White'),
-- (N'ABC-0020',  N'Nissan', N'Gray');

-- -- 新增 A01~A20 到 uid
-- INSERT INTO Userinfo (uid)
-- VALUES
-- (N'A07'),
-- (N'A08'),
-- (N'A09'),
-- (N'A10'),
-- (N'A11'),
-- (N'A12'),
-- (N'A13'),
-- (N'A14'),
-- (N'A15'),
-- (N'A16'),
-- (N'A17'),
-- (N'A18'),
-- (N'A19'),
-- (N'A20');

-- -- 更新 Vehicle 表中的 uid
-- UPDATE Vehicle SET uid = 'A01' WHERE plate_number = 'ABC-0001';
-- UPDATE Vehicle SET uid = 'A02' WHERE plate_number = 'ABC-0002';
-- UPDATE Vehicle SET uid = 'A03' WHERE plate_number = 'ABC-0003';
-- UPDATE Vehicle SET uid = 'A04' WHERE plate_number = 'ABC-0004';
-- UPDATE Vehicle SET uid = 'A05' WHERE plate_number = 'ABC-0005';
-- UPDATE Vehicle SET uid = 'A06' WHERE plate_number = 'ABC-0006';
-- UPDATE Vehicle SET uid = 'A07' WHERE plate_number = 'ABC-0007';
-- UPDATE Vehicle SET uid = 'A08' WHERE plate_number = 'ABC-0008';
-- UPDATE Vehicle SET uid = 'A09' WHERE plate_number = 'ABC-0009';
-- UPDATE Vehicle SET uid = 'A10' WHERE plate_number = 'ABC-0010';
-- UPDATE Vehicle SET uid = 'A11' WHERE plate_number = 'ABC-0011';
-- UPDATE Vehicle SET uid = 'A12' WHERE plate_number = 'ABC-0012';
-- UPDATE Vehicle SET uid = 'A13' WHERE plate_number = 'ABC-0013';
-- UPDATE Vehicle SET uid = 'A14' WHERE plate_number = 'ABC-0014';
-- UPDATE Vehicle SET uid = 'A15' WHERE plate_number = 'ABC-0015';
-- UPDATE Vehicle SET uid = 'A16' WHERE plate_number = 'ABC-0016';
-- UPDATE Vehicle SET uid = 'A17' WHERE plate_number = 'ABC-0017';
-- UPDATE Vehicle SET uid = 'A18' WHERE plate_number = 'ABC-0018';
-- UPDATE Vehicle SET uid = 'A19' WHERE plate_number = 'ABC-0019';
-- UPDATE Vehicle SET uid = 'A20' WHERE plate_number = 'ABC-0020';

-- ================================
-- 自動化計算進出場時間、費用(更新).sql
-- ================================
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


-- ================================
-- 車輛進出場(現金).sql
-- ================================
-- Step 1: 模擬進場（1 小時前）
INSERT INTO ParkingRecord (entry_time, plate_number, spot_id)
VALUES (DATEADD(HOUR, -1, GETDATE()), N'NEW2345', 2);

-- Step 2: 模擬離場（現在時間）
UPDATE ParkingRecord
SET exit_time = GETDATE()
WHERE plate_number = N'NEW2345' AND exit_time IS NULL;

-- Step 3: 呼叫計費儲存程序，付款方式為「現金」
EXEC ChargeParkingFee @plate_number = N'NEW2345', @method = N'現金';

驗證紀錄（查詢最新付款資訊）
SELECT TOP 1 *
FROM PaymentRecord pr
JOIN ParkingRecord pk ON pr.record_id = pk.record_id
WHERE pk.plate_number = N'NEW2345'
ORDER BY pr.payment_time DESC;


-- ================================
-- README.txt
-- ================================
README

📦 停車場模擬腳本說明：

- 本腳本可模擬車輛亂數進場
- 進場後會自動偵測是否車位已滿
- 可搭配亂數離場腳本一起使用

執行順序：
1. 建立 ParkingSpot 資料表（如已建立可跳過）
2. 執行"清空資料，並重置 ParkingSpot 表格"-->插入初始車位資料（共 30 筆）
3. 執行"(Main)進場前車位查詢"
3. 執行"亂數進場模擬"（可多次執行）
3-1.可一併查看車位剩餘狀況（是否已滿）

選寫人:倩


-- ================================
-- (Main)進場前車位查詢.sql
-- ================================
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




-- ================================
-- (亂數)實際模擬.sql
-- ================================
--(亂數)實際模擬
-- //進場
-- 宣告：隨機進場數量（1~目前空位數之間）
DECLARE @空位數 INT;
DECLARE @進場數量 INT;

-- 先查目前有幾個空位
SELECT @空位數 = COUNT(*) FROM ParkingSpot WHERE is_available = 1;

-- 再從 1 ~ 空位數之間隨機選一個進場數
SELECT @進場數量 = CAST(RAND() * @空位數 + 1 AS INT);

-- 顯示看看今天有幾台車進場（可加可不加）
PRINT N'🔢 進場車輛數：' + CAST(@進場數量 AS VARCHAR);

-- 模擬進場：從空位中隨機選出 @進場數量 筆，設為已佔用
WITH 空位 AS (
    SELECT TOP (@進場數量) spot_id
    FROM ParkingSpot
    WHERE is_available = 1
    ORDER BY NEWID()
)
UPDATE ParkingSpot
SET is_available = 0
FROM ParkingSpot
JOIN 空位 ON ParkingSpot.spot_id = 空位.spot_id;

-- 🚨 進場模擬結束後，加上這段「提示訊息」

-- 宣告變數來重新查詢目前剩餘空位
DECLARE @剩餘空位 INT;
SELECT @剩餘空位 = COUNT(*) FROM ParkingSpot WHERE is_available = 1;

-- 如果剩餘為 0，表示已滿
IF @剩餘空位 = 0
BEGIN
    PRINT N'🈵 車位已滿！';
END
ELSE
BEGIN
    PRINT N'✅ 尚有空位，歡迎停車，目前剩餘：' + CAST(@剩餘空位 AS VARCHAR) + N' 個';
END



-- /////離場
-- 宣告：離場數量（不手動設，而是自動隨機產生）
DECLARE @佔用數量 INT;
DECLARE @離場數量 INT;

-- 先查目前有幾個車位是被佔用的
SELECT @佔用數量 = COUNT(*) FROM ParkingSpot WHERE is_available = 0;

-- 亂數決定要幾台車離場（從 1 ~ 佔用數量之間）
IF @佔用數量 > 0
BEGIN
    SELECT @離場數量 = CAST(RAND() * @佔用數量 + 1 AS INT);

    -- 顯示離場台數（可加可不加）
    PRINT N'🚗 離場車輛數：' + CAST(@離場數量 AS VARCHAR);

    -- 從已佔用車位中隨機選幾筆出場，設為可用
    WITH 佔用車位 AS (
        SELECT TOP (@離場數量) spot_id
        FROM ParkingSpot
        WHERE is_available = 0
        ORDER BY NEWID()
    )
    UPDATE ParkingSpot
    SET is_available = 1
    FROM ParkingSpot
    JOIN 佔用車位 ON ParkingSpot.spot_id = 佔用車位.spot_id;
END
ELSE
BEGIN
    PRINT N'❗目前沒有任何車輛可出場';
END
-- 宣告變數來重新查詢目前剩餘空位
DECLARE @剩餘空位 INT;
SELECT @剩餘空位 = COUNT(*) FROM ParkingSpot WHERE is_available = 1;

-- 如果剩餘為 0，表示已滿
IF @剩餘空位 = 0
BEGIN
    PRINT N'🈵 車位已滿！';
END
ELSE
BEGIN
    PRINT N'✅ 尚有空位，歡迎停車，目前剩餘：' + CAST(@剩餘空位 AS VARCHAR) + N' 個';
END





-- /////////////////////////////////////////基本測試///////////////////////////////////////
-- //進場
-- 宣告要進場的車輛數量
DECLARE @進場數量 INT = 3;

-- 從空位中隨機挑幾筆來模擬進場（改為佔用）
WITH 空位 AS (
    SELECT TOP (@進場數量) spot_id
    FROM ParkingSpot
    WHERE is_available = 1
    ORDER BY NEWID()
)
UPDATE ParkingSpot
SET is_available = 0
FROM ParkingSpot
JOIN 空位 ON ParkingSpot.spot_id = 空位.spot_id;


-- //出場
-- 宣告變數：要讓幾輛車離開
DECLARE @離開數量 INT = 3;

-- 把 @離開數量 輛 隨機選到的已佔用車位，設為可用
WITH 被佔用 AS (
    SELECT TOP (@離開數量) spot_id
    FROM ParkingSpot
    WHERE is_available = 0
    ORDER BY NEWID()  -- NEWID() 用來打亂順序
)
UPDATE ParkingSpot
SET is_available = 1
FROM ParkingSpot
JOIN 被佔用 ON ParkingSpot.spot_id = 被佔用.spot_id;




-- ================================
-- 清空資料，並重置 ParkingSpot 表格.sql
-- ================================
-- (OK)清空資料，並重置 ParkingSpot 表格
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




-- ================================
-- 註解.sql
-- ================================
-- spot_id 欄位註解：停車格編號（主鍵）
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'停車格編號（主鍵）', 
    @level0type = N'SCHEMA',  @level0name = 'dbo',  
    @level1type = N'TABLE',   @level1name = 'ParkingSpot',  
    @level2type = N'COLUMN',  @level2name = 'spot_id';

-- is_available 欄位註解：是否可用（0 表已佔用，1 表可停）
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'是否可用（0 表已佔用，1 表可停）', 
    @level0type = N'SCHEMA',  @level0name = 'dbo',  
    @level1type = N'TABLE',   @level1name = 'ParkingSpot',  
    @level2type = N'COLUMN',  @level2name = 'is_available';

-- location 欄位註解：停車格位置（樓層或區域）
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'停車格位置（樓層或區域）', 
    @level0type = N'SCHEMA',  @level0name = 'dbo',  
    @level1type = N'TABLE',   @level1name = 'ParkingSpot',  
    @level2type = N'COLUMN',  @level2name = 'location';


-- ================================
-- 車輛進出記錄PROCEDUR.sql
-- ================================
-- -- 3. 車輛進出記錄表
-- CREATE TABLE ParkingRecord (
--     record_id INT IDENTITY(1,1) PRIMARY KEY,
--     plate_number NVARCHAR(10),
--     spot_id INT,
--     entry_time DATETIME,
--     exit_time DATETIME NULL,
--     FOREIGN KEY (plate_number) REFERENCES Vehicle(plate_number),
--     -- FOREIGN KEY (spot_id) REFERENCES ParkingSpot(spot_id)


-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0001', '2025-02-06 06:12:00', '2025-02-06 14:29:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time)
-- VALUES('XXX-0002', '2025-05-03 13:10:00', '2025-05-03 18:45:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0003', '2025-02-27 16:18:00', '2025-02-28 01:23:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0004', '2025-03-05 12:13:00', '2025-03-05 13:31:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0005', '2025-01-20 15:42:00', '2025-01-20 17:32:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0006', '2025-05-07 22:14:00', '2025-05-08 05:05:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0007', '2025-03-29 13:56:00', '2025-03-29 20:45:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0008', '2025-04-29 08:43:00', '2025-04-29 11:14:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0009', '2025-01-18 16:58:00', '2025-01-18 23:08:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0010', '2025-03-24 03:07:00', '2025-03-24 07:52:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0011', '2025-04-14 01:57:00', '2025-04-14 03:07:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0012', '2025-05-19 09:07:00', '2025-05-19 09:23:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0013', '2025-03-03 05:08:00', '2025-03-03 08:06:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0014', '2025-04-10 04:07:00', '2025-04-10 06:47:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0015', '2025-02-20 13:23:00', '2025-02-20 22:46:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0016', '2025-04-02 12:24:00', '2025-04-02 18:31:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0017', '2025-03-18 19:39:00', '2025-03-18 20:25:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0018', '2025-02-03 04:26:00', '2025-02-03 06:07:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0019', '2025-01-02 08:08:00', '2025-01-02 09:43:00');
-- INSERT INTO ParkingRecord (plate_number, entry_time, exit_time) 
-- VALUES('XXX-0020', '2025-05-13 07:14:00', '2025-05-13 15:09:00');

-----------------------------------------------------------------------------------------------------

-- 這邊是能讓資料重新編輯的CODE 


-- DBCC CHECKIDENT ('ParkingRecord', RESEED, 0); -- 重設自動編號,再插入新資料就會從 1 開始自動編號


-- DELETE FROM ParkingRecord
-- WHERE record_id like '%%%'; -- >> 這一段可以刪除錯誤的 ID

-----------------------------------------------------------------------------------------------------

-- SELECT plate_number, entry_time, exit_time
-- FROM ParkingRecord
-- WHERE entry_time >= '2025-05-10';   >> 查特定日期之後的進場資料：


-- SELECT plate_number, entry_time, exit_time
-- FROM ParkingRecord
-- -- WHERE plate_number = 'XXX-0005';     >> 查某一車牌


-- SELECT plate_number, entry_time, exit_time
-- FROM ParkingRecord;                       >> 這會顯示所有記錄的車牌號碼、進場時間、出場時間。
-----------------------------------------------------------------------------------------------------
