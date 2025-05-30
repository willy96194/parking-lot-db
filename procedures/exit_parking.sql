
CREATE PROCEDURE ExitParking
    @plate_number NVARCHAR(10),
    @method NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @record_id INT, @spot_id INT;

    -- 找出尚未離場的最新一筆紀錄
    SELECT TOP 1 
        @record_id = record_id,
        @spot_id = spot_id
    FROM ParkingRecord
    WHERE plate_number = @plate_number AND exit_time IS NULL
    ORDER BY entry_time DESC;

    -- 如果找不到紀錄就結束
    IF @record_id IS NULL
    BEGIN
        PRINT N'⚠️ 查無尚未離場的紀錄，無法執行離場操作';
        RETURN;
    END

    -- 更新離場時間為現在
    UPDATE ParkingRecord
    SET exit_time = GETDATE()
    WHERE record_id = @record_id;

    -- 執行計費預存程序
    EXEC ChargeParkingFee @plate_number = @plate_number, @method = @method;

    -- 將車位釋放為可用
    UPDATE ParkingSpot
    SET is_available = 1
    WHERE spot_id = @spot_id;

    PRINT N'✅ 離場完成，車位已釋放並完成計費';
END;
