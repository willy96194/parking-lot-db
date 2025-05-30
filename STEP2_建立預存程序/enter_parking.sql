
CREATE PROCEDURE EnterParking
    @plate_number NVARCHAR(10),
    @spot_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 若車輛不存在，則插入預設品牌與顏色
    IF NOT EXISTS (SELECT 1 FROM Vehicle WHERE plate_number = @plate_number)
    BEGIN
        INSERT INTO Vehicle (plate_number, brand, color)
        VALUES (@plate_number, N'Unknown', N'Unknown');
    END

    -- 若該車位為可用，執行進場
    IF EXISTS (SELECT 1 FROM ParkingSpot WHERE spot_id = @spot_id AND is_available = 1)
    BEGIN
        INSERT INTO ParkingRecord (entry_time, plate_number, spot_id)
        VALUES (DATEADD(HOUR, -1, GETDATE()), @plate_number, @spot_id);

        UPDATE ParkingSpot
        SET is_available = 0
        WHERE spot_id = @spot_id;

        PRINT N'✅ 車輛進場成功，車位已標記為佔用';
    END
    ELSE
    BEGIN
        PRINT N'⛔ 該車位目前不可用';
    END
END;
