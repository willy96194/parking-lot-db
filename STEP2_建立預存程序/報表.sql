--生成預存程序--
CREATE PROCEDURE sp_GenerateDailyParkingReport
    @startDate DATE,
    @endDate DATE
AS
BEGIN
    -- 先刪除區間內已存在的日報表，避免重複
    DELETE FROM DailyParkingReport
    WHERE report_date >= @startDate AND report_date <= @endDate;

    -- 重新統計並插入日報表
    INSERT INTO DailyParkingReport (report_date, total_vehicles, total_amount)
    SELECT
        CAST(pr.entry_time AS DATE) AS report_date,
        COUNT(*) AS total_vehicles,
        ISNULL(SUM(pay.amount), 0) AS total_amount
    FROM ParkingRecord pr
    LEFT JOIN PaymentRecord pay ON pr.record_id = pay.record_id
    WHERE pr.entry_time >= @startDate AND pr.entry_time <= @endDate
    GROUP BY CAST(pr.entry_time AS DATE)
END
