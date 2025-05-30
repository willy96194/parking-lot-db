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