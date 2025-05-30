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
