-- 物流线容器表
CREATE TABLE LogisticsContainer (
    ContainerCode NVARCHAR(50) PRIMARY KEY,
    ContainerName NVARCHAR(100) NOT NULL,
    LogisticsLineCode NVARCHAR(50) NOT NULL,
    ContainerType NVARCHAR(50) NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    CurrentLocation NVARCHAR(100),
    Capacity DECIMAL(18,2) NOT NULL,
    IsEnabled BIT NOT NULL DEFAULT 1,
    Remark NVARCHAR(500),
    CreateTime DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateTime DATETIME
);

-- 创建索引
CREATE INDEX IX_LogisticsContainer_LineCode ON LogisticsContainer(LogisticsLineCode);
CREATE INDEX IX_LogisticsContainer_Status ON LogisticsContainer(Status);
CREATE INDEX IX_LogisticsContainer_IsEnabled ON LogisticsContainer(IsEnabled);

-- 插入测试数据
INSERT INTO LogisticsContainer (ContainerCode, ContainerName, LogisticsLineCode, ContainerType, Status, CurrentLocation, Capacity, IsEnabled, CreateTime)
VALUES 
('C001', '托盘001', 'LINE001', '托盘', '空闲', 'A区01号位', 100.00, 1, GETDATE()),
('C002', '托盘002', 'LINE001', '托盘', '使用中', 'B区05号位', 100.00, 1, GETDATE()),
('C003', '周转箱001', 'LINE002', '周转箱', '空闲', 'C区10号位', 50.00, 1, GETDATE()),
('C004', '周转箱002', 'LINE002', '周转箱', '维护中', '维修区', 50.00, 1, GETDATE());
