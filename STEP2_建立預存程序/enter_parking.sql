CREATE PROCEDURE EnterParking
    @uid NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @plate_number NVARCHAR(10);
    DECLARE @spot_id INT;

    -- 取得該 uid 的車牌（這裡只取第一台）
    SELECT TOP 1 @plate_number = plate_number
    FROM Vehicle
    WHERE uid = @uid;

    IF @plate_number IS NULL
    BEGIN
        PRINT N'⛔ 查無該使用者車輛資訊，無法進場';
        RETURN;
    END

    -- 指派一個空車位（隨機取一個）
    SELECT TOP 1 @spot_id = spot_id
    FROM ParkingSpot
    WHERE is_available = 1;

    IF @spot_id IS NULL
    BEGIN
        PRINT N'⛔ 無可用車位，請稍後再試';
        RETURN;
    END

    -- 寫入進場紀錄
    INSERT INTO ParkingRecord (entry_time, plate_number, spot_id)
    VALUES (DATEADD(HOUR, -1, GETDATE()), @plate_number, @spot_id);

    -- 標記該車位為不可用
    UPDATE ParkingSpot
    SET is_available = 0
    WHERE spot_id = @spot_id;

    PRINT N'✅ 車輛進場成功';
END;
