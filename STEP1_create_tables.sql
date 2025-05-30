
-- STEP 1: 建立資料表

-- Vehicle 表：儲存車輛資料（含 uid 不設外鍵）
DROP TABLE IF EXISTS Vehicle;
CREATE TABLE Vehicle (
    plate_number NVARCHAR(10) PRIMARY KEY,
    brand NVARCHAR(50),
    color NVARCHAR(30),
    uid NVARCHAR(20)
);

-- ParkingSpot 表：停車格資訊
DROP TABLE IF EXISTS ParkingSpot;
CREATE TABLE ParkingSpot (
    spot_id INT IDENTITY(1,1) PRIMARY KEY,
    location NVARCHAR(50),
    is_available BIT DEFAULT 1
);

-- ParkingRecord 表：車輛進出記錄
DROP TABLE IF EXISTS ParkingRecord;
CREATE TABLE ParkingRecord (
    record_id INT IDENTITY(1,1) PRIMARY KEY,
    plate_number NVARCHAR(10),
    spot_id INT,
    entry_time DATETIME,
    exit_time DATETIME,
    FOREIGN KEY (plate_number) REFERENCES Vehicle(plate_number),
    FOREIGN KEY (spot_id) REFERENCES ParkingSpot(spot_id)
);

-- PaymentRecord 表：付款紀錄
DROP TABLE IF EXISTS PaymentRecord;
CREATE TABLE PaymentRecord (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    record_id INT,
    amount DECIMAL(10,2),
    payment_time DATETIME,
    method NVARCHAR(20),
    FOREIGN KEY (record_id) REFERENCES ParkingRecord(record_id)
);
