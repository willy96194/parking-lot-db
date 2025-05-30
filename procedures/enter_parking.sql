
CREATE PROCEDURE EnterParking
    @plate_number NVARCHAR(10),
    @owner_name NVARCHAR(100),
    @contact_number NVARCHAR(20),
    @spot_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. 確保車輛存在於 Vehicle 表
    IF NOT EXISTS (SELECT 1 FROM Vehicle WHERE plate_number = @plate_number)
    BEGIN
        INSERT INTO Vehicle (plate_number, owner_name, contact_number)
        VALUES (@plate_number, @owner_name, @contact_number);
    END

    -- 2. 確保該車位可用
    IF EXISTS (SELECT 1 FROM ParkingSpot WHERE spot_id = @spot_id AND is_available = 1)
    BEGIN
        -- 3. 插入 ParkingRecord（模擬進場時間為 1 小時前）
        INSERT INTO ParkingRecord (entry_time, plate_number, spot_id)
        VALUES (DATEADD(HOUR, -1, GETDATE()), @plate_number, @spot_id);

        -- 4. 更新該車位為佔用
        UPDATE ParkingSpot
        SET is_available = 0
        WHERE spot_id = @spot_id;

        PRINT N'✅ 進場成功：車輛已記錄，車位設為已佔用';
    END
    ELSE
    BEGIN
        PRINT N'⛔ 進場失敗：該車位目前已佔用';
    END
END;
