EXEC sp_GenerateDailyParkingReport '2025-06-01', '2026-06-10';

SELECT * FROM DailyParkingReport WHERE report_date BETWEEN '2025-06-01' AND '2025-06-10' ORDER BY report_date;