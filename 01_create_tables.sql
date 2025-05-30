
-- ======================================
-- 建立資料表：Vehicle
-- ======================================
CREATE TABLE Vehicle (
    plate_number NVARCHAR(10) PRIMARY KEY,
    owner_name NVARCHAR(100),
    contact_number NVARCHAR(20)
);

-- ======================================
-- 建立資料表：ParkingSpot
-- ======================================
CREATE TABLE ParkingSpot (
    spot_id INT IDENTITY(1,1) PRIMARY KEY,
    location NVARCHAR(50),
    is_available BIT DEFAULT 1
);

-- ======================================
-- 建立資料表：ParkingRecord
-- ======================================
CREATE TABLE ParkingRecord (
    record_id INT IDENTITY(1,1) PRIMARY KEY,
    plate_number NVARCHAR(10),
    spot_id INT,
    entry_time DATETIME,
    exit_time DATETIME,
    FOREIGN KEY (plate_number) REFERENCES Vehicle(plate_number),
    FOREIGN KEY (spot_id) REFERENCES ParkingSpot(spot_id)
);

-- ======================================
-- 建立資料表：PaymentRecord
-- ======================================
CREATE TABLE PaymentRecord (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    record_id INT,
    amount DECIMAL(10,2),
    payment_time DATETIME,
    method NVARCHAR(20),
    FOREIGN KEY (record_id) REFERENCES ParkingRecord(record_id)
);
