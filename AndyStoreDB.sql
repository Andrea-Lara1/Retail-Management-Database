CREATE DATABASE AndyStore;

USE AndyStore;
GO
--llaves foraneas
 ALTER TABLE Sucursales ADD CONSTRAINT FK_Sucursales_Ciudades
    FOREIGN KEY (IdCiudad) REFERENCES Ciudades(IdCiudad);
 
ALTER TABLE Clientes ADD CONSTRAINT FK_Clientes_Ciudades
    FOREIGN KEY (IdCiudad) REFERENCES Ciudades(IdCiudad);
 
ALTER TABLE Proveedores ADD CONSTRAINT FK_Proveedores_Ciudades
    FOREIGN KEY (IdCiudad) REFERENCES Ciudades(IdCiudad);
 
ALTER TABLE Empleados ADD CONSTRAINT FK_Empleados_Roles
    FOREIGN KEY (IdRol) REFERENCES Roles(IdRol);
 
ALTER TABLE Empleados ADD CONSTRAINT FK_Empleados_Sucursales
    FOREIGN KEY (IdSucursal) REFERENCES Sucursales(IdSucursal);
 
ALTER TABLE Productos ADD CONSTRAINT FK_Productos_Categorias
    FOREIGN KEY (IdCategoria) REFERENCES Categorias(IdCategoria);
 
ALTER TABLE Productos ADD CONSTRAINT FK_Productos_Marcas
    FOREIGN KEY (IdMarca) REFERENCES Marcas(IdMarca);
 
ALTER TABLE Ventas ADD CONSTRAINT FK_Ventas_Clientes
    FOREIGN KEY (IdCliente) REFERENCES Clientes(IdCliente);
 
ALTER TABLE Ventas ADD CONSTRAINT FK_Ventas_Empleados
    FOREIGN KEY (IdEmpleado) REFERENCES Empleados(IdEmpleado);
 
ALTER TABLE Ventas ADD CONSTRAINT FK_Ventas_MetodoPago
    FOREIGN KEY (IdMetodoPago) REFERENCES MetodoPago(IdMetodoPago);
 
ALTER TABLE DetalleVenta ADD CONSTRAINT FK_DetalleVenta_Ventas
    FOREIGN KEY (IdVenta) REFERENCES Ventas(IdVenta);
 
ALTER TABLE DetalleVenta ADD CONSTRAINT FK_DetalleVenta_Productos
    FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto);
 
ALTER TABLE Compras ADD CONSTRAINT FK_Compras_Proveedores
    FOREIGN KEY (IdProveedor) REFERENCES Proveedores(IdProveedor);
 
ALTER TABLE DetalleCompra ADD CONSTRAINT FK_DetalleCompra_Compras
    FOREIGN KEY (IdCompra) REFERENCES Compras(IdCompra);
 
ALTER TABLE DetalleCompra ADD CONSTRAINT FK_DetalleCompra_Productos
    FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto);
 
ALTER TABLE Inventario ADD CONSTRAINT FK_Inventario_Productos
    FOREIGN KEY (IdProducto) REFERENCES Productos(IdProducto);
GO
 


-- ÍNDICES

CREATE NONCLUSTERED INDEX IX_Clientes_IdCiudad
ON Clientes(IdCiudad);

CREATE NONCLUSTERED INDEX IX_Productos_IdMarca
ON Productos(IdMarca);

CREATE NONCLUSTERED INDEX IX_Ventas_Fecha
ON Ventas(FechaVenta);

CREATE NONCLUSTERED INDEX IX_Productos_Categoria
ON Productos(IdCategoria);

CREATE NONCLUSTERED INDEX IX_Ventas_Total
ON Ventas(Total DESC);

-- Revisar los índices creados
EXEC sp_helpindex 'Clientes';
EXEC sp_helpindex 'Productos';
EXEC sp_helpindex 'Ventas';
GO


-- VISTAS

CREATE VIEW vw_Productos AS
SELECT
    p.IdProducto,
    p.NombreProducto,
    m.NombreMarca,
    p.Precio,
    p.Stock,
    c.NombreCategoria
FROM Productos p
INNER JOIN Categorias c ON p.IdCategoria = c.IdCategoria
INNER JOIN Marcas m ON p.IdMarca = m.IdMarca;


CREATE VIEW vw_Ventas AS
SELECT
    v.IdVenta,
    v.FechaVenta,
    cl.Nombre,
    cl.Apellido,
    e.Nombre AS Empleado,
    mp.Metodo AS MetodoPago,
    v.Total
FROM Ventas v
INNER JOIN Clientes cl ON v.IdCliente = cl.IdCliente
INNER JOIN Empleados e ON v.IdEmpleado = e.IdEmpleado
INNER JOIN MetodoPago mp ON v.IdMetodoPago = mp.IdMetodoPago;


CREATE VIEW vw_StockBajo AS
SELECT *
FROM Productos
WHERE Stock < 20;

CREATE VIEW vw_DetalleVentaCompleto AS
SELECT
    v.IdVenta,
    v.FechaVenta,
    cl.Nombre + ' ' + cl.Apellido AS Cliente,
    e.Nombre + ' ' + e.Apellido AS Empleado,
    s.NombreSucursal,
    mp.Metodo AS MetodoPago,
    p.NombreProducto,
    dv.Cantidad,
    dv.PrecioUnitario,
    dv.Subtotal
FROM Ventas v
INNER JOIN Clientes cl ON v.IdCliente = cl.IdCliente
INNER JOIN Empleados e ON v.IdEmpleado = e.IdEmpleado
INNER JOIN Sucursales s ON e.IdSucursal = s.IdSucursal
INNER JOIN MetodoPago mp ON v.IdMetodoPago = mp.IdMetodoPago
INNER JOIN DetalleVenta dv ON v.IdVenta = dv.IdVenta
INNER JOIN Productos p ON dv.IdProducto = p.IdProducto;

CREATE VIEW vw_ClientesResumen AS
SELECT
    cl.IdCliente,
    cl.Nombre,
    cl.Apellido,
    ciu.NombreCiudad,
    ciu.Departamento,
    COUNT(v.IdVenta) AS CantidadVentas,
    ISNULL(SUM(v.Total), 0) AS TotalComprado
FROM Clientes cl
INNER JOIN Ciudades ciu ON cl.IdCiudad = ciu.IdCiudad
LEFT JOIN Ventas v ON cl.IdCliente = v.IdCliente
GROUP BY cl.IdCliente, cl.Nombre, cl.Apellido, ciu.NombreCiudad, ciu.Departamento;

CREATE VIEW vw_RendimientoEmpleados AS
SELECT
    e.IdEmpleado,
    e.Nombre + ' ' + e.Apellido AS Empleado,
    r.NombreRol,
    s.NombreSucursal,
    COUNT(v.IdVenta) AS CantidadVentas,
    ISNULL(SUM(v.Total), 0) AS TotalVendido
FROM Empleados e
INNER JOIN Roles r ON e.IdRol = r.IdRol
INNER JOIN Sucursales s ON e.IdSucursal = s.IdSucursal
LEFT JOIN Ventas v ON e.IdEmpleado = v.IdEmpleado
GROUP BY e.IdEmpleado, e.Nombre, e.Apellido, r.NombreRol, s.NombreSucursal;


SELECT * FROM vw_RendimientoEmpleados;
SELECT * FROM vw_ClientesResumen;
SELECT * FROM vw_DetalleVentaCompleto;
SELECT * FROM vw_Productos;
SELECT * FROM vw_Ventas;
SELECT * FROM vw_StockBajo;


-- PROCEDIMIENTOS ALMACENADOS


CREATE PROCEDURE sp_ClientesCiudad
    @NombreCiudad NVARCHAR(50)
AS
BEGIN
    SELECT cl.*
    FROM Clientes cl
    INNER JOIN Ciudades ci ON cl.IdCiudad = ci.IdCiudad
    WHERE ci.NombreCiudad = @NombreCiudad;
END;


EXEC sp_ClientesCiudad 'Bogotá';

--
CREATE PROCEDURE sp_ProductosCategoria
    @IdCategoria INT
AS
BEGIN
    SELECT *
    FROM Productos
    WHERE IdCategoria = @IdCategoria;
END;


EXEC sp_ProductosCategoria 2;

--
CREATE PROCEDURE sp_VentasCliente
    @IdCliente INT
AS
BEGIN
    SELECT *
    FROM Ventas
    WHERE IdCliente = @IdCliente;
END;


EXEC sp_VentasCliente 15;

--
CREATE PROCEDURE sp_TotalVentasEmpleado
    @IdEmpleado INT
AS
BEGIN
    SELECT SUM(Total) AS TotalVentas
    FROM Ventas
    WHERE IdEmpleado = @IdEmpleado;
END;


EXEC sp_TotalVentasEmpleado 3;

--reporte de ventas de una sucursal en un rago de fechas
CREATE PROCEDURE sp_VentasPorSucursalYFecha
    @IdSucursal INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SELECT
        v.IdVenta,
        v.FechaVenta,
        cl.Nombre + ' ' + cl.Apellido AS Cliente,
        e.Nombre + ' ' + e.Apellido AS Empleado,
        mp.Metodo,
        v.Total
    FROM Ventas v
    INNER JOIN Empleados e ON v.IdEmpleado = e.IdEmpleado
    INNER JOIN Clientes cl ON v.IdCliente = cl.IdCliente
    INNER JOIN MetodoPago mp ON v.IdMetodoPago = mp.IdMetodoPago
    WHERE e.IdSucursal = @IdSucursal
      AND v.FechaVenta BETWEEN @FechaInicio AND @FechaFin
    ORDER BY v.FechaVenta;
END;

EXEC sp_VentasPorSucursalYFecha @IdSucursal = 1, @FechaInicio = '2024-01-01', @FechaFin = '2025-12-31';

--Recibe un proveedor y devuelve, por parametro de salida
-- el total comprado y la cantidad de compras

CREATE PROCEDURE sp_ResumenComprasProveedor
    @IdProveedor INT,
    @TotalComprado DECIMAL(18,2) OUTPUT,
    @CantidadCompras INT OUTPUT
AS
BEGIN
    SELECT
        @TotalComprado = ISNULL(SUM(Total), 0),
        @CantidadCompras = COUNT(*)
    FROM Compras
    WHERE IdProveedor = @IdProveedor;
END;

 
-- declaro variables para recibir la salida
DECLARE @Total DECIMAL(18,2);
DECLARE @Cantidad INT;
 
EXEC sp_ResumenComprasProveedor
    @IdProveedor = 1,
    @TotalComprado = @Total OUTPUT,
    @CantidadCompras = @Cantidad OUTPUT;
 
SELECT @Total AS TotalComprado, @Cantidad AS CantidadCompras;
GO


 
-- Cómo usarlo:
DECLARE @IdVentaGenerada INT;
 
EXEC sp_RegistrarVenta
    @IdCliente = 1,
    @IdEmpleado = 1,
    @IdMetodoPago = 1,
    @IdProducto = 10,
    @Cantidad = 2,
    @NuevoIdVenta = @IdVentaGenerada OUTPUT;
 
SELECT @IdVentaGenerada AS IdVentaCreada;
 
-- Verificar que sí se descontó el stock y se insertó todo
SELECT * FROM Ventas WHERE IdVenta = @IdVentaGenerada;
SELECT * FROM DetalleVenta WHERE IdVenta = @IdVentaGenerada;


-- TRIGGERS 

CREATE TRIGGER trg_NoStockNegativo
ON Productos
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Stock < 0)
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'No se permite stock negativo.';
    END
END;
GO

CREATE TRIGGER trg_CambioPrecio
ON Productos
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaPrecios (IdProducto, PrecioAnterior, PrecioNuevo, FechaCambio)
    SELECT
        d.IdProducto,
        d.Precio,
        i.Precio,
        GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.IdProducto = i.IdProducto
    WHERE d.Precio <> i.Precio;
END;

CREATE TRIGGER trg_CambioStock
ON Productos
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditoriaStock (IdProducto, StockAnterior, StockNuevo, FechaCambio, Usuario)
    SELECT
        d.IdProducto,
        d.Stock,
        i.Stock,
        GETDATE(),
        SYSTEM_USER
    FROM deleted d
    INNER JOIN inserted i ON d.IdProducto = i.IdProducto
    WHERE d.Stock <> i.Stock;
END;

CREATE TRIGGER trg_AuditarEliminacionVentas
ON Ventas
AFTER DELETE
AS
BEGIN
    INSERT INTO AuditoriaEliminaciones (Tabla, IdRegistroEliminado, DatosEliminados, FechaEliminacion, Usuario)
    SELECT
        'Ventas',
        d.IdVenta,
        (SELECT d2.* FROM deleted d2 WHERE d2.IdVenta = d.IdVenta FOR JSON AUTO),
        GETDATE(),
        SYSTEM_USER
    FROM deleted d;
END;
--AUDITROIAS

CREATE TABLE AuditoriaPrecios (
    IdAuditoria INT IDENTITY PRIMARY KEY,
    IdProducto INT,
    PrecioAnterior NUMERIC(18,2),
    PrecioNuevo NUMERIC(18,2),
    FechaCambio DATETIME
);

CREATE TABLE AuditoriaStock (
    IdAuditoria INT IDENTITY PRIMARY KEY,
    IdProducto INT,
    StockAnterior INT,
    StockNuevo INT,
    FechaCambio DATETIME,
    Usuario NVARCHAR(100)
);

CREATE TABLE AuditoriaEliminaciones (
    IdAuditoria INT IDENTITY PRIMARY KEY,
    Tabla NVARCHAR(50),
    IdRegistroEliminado INT,
    DatosEliminados NVARCHAR(MAX),   -- guardamos la fila completa como texto/JSON
    FechaEliminacion DATETIME,
    Usuario NVARCHAR(100)
);

-- PruebaS AUDITORIAS
UPDATE Productos
SET Precio = Precio + 50000
WHERE IdProducto = 5;

SELECT * FROM AuditoriaPrecios;

UPDATE Productos SET Stock = Stock - 5 WHERE IdProducto = 20;
SELECT * FROM AuditoriaStock;


--logins

CREATE LOGIN login_admin       WITH PASSWORD = 'Adm1n2026';
CREATE LOGIN login_gerente     WITH PASSWORD = 'Ger3nte2026';
CREATE LOGIN login_supervisor  WITH PASSWORD = 'Sup3rv2026';
CREATE LOGIN login_vendedor    WITH PASSWORD = 'Vend3dor2026';
CREATE LOGIN login_cajero      WITH PASSWORD = 'Caj3ro2026';
CREATE LOGIN login_bodega      WITH PASSWORD = 'Bod3ga2026';
GO

--user
CREATE USER user_admin       FOR LOGIN login_admin;
CREATE USER user_gerente     FOR LOGIN login_gerente;
CREATE USER user_supervisor  FOR LOGIN login_supervisor;
CREATE USER user_vendedor    FOR LOGIN login_vendedor;
CREATE USER user_cajero      FOR LOGIN login_cajero;
CREATE USER user_bodega      FOR LOGIN login_bodega;
GO

--roles
CREATE ROLE rol_admin;
CREATE ROLE rol_gerente;
CREATE ROLE rol_supervisor;
CREATE ROLE rol_vendedor;
CREATE ROLE rol_cajero;
CREATE ROLE rol_bodega;
GO

--user dentro de rol
ALTER ROLE rol_admin       ADD MEMBER user_admin;
ALTER ROLE rol_gerente     ADD MEMBER user_gerente;
ALTER ROLE rol_supervisor  ADD MEMBER user_supervisor;
ALTER ROLE rol_vendedor    ADD MEMBER user_vendedor;
ALTER ROLE rol_cajero      ADD MEMBER user_cajero;
ALTER ROLE rol_bodega      ADD MEMBER user_bodega;
GO

--permisos

-- Administrador control total sobre la base de datos
ALTER ROLE db_owner ADD MEMBER user_admin;

-- puede ver y modificar todo, pero no borrar tablas ni cambiar el esquema
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_gerente;
GRANT EXECUTE ON SCHEMA::dbo TO rol_gerente;

-- Supervisor: puede ver todo y modificar inventario/ventas, no maneja empleados/salarios
GRANT SELECT ON SCHEMA::dbo TO rol_supervisor;
GRANT INSERT, UPDATE ON Inventario TO rol_supervisor;
GRANT INSERT, UPDATE ON Ventas TO rol_supervisor;
GRANT INSERT, UPDATE ON DetalleVenta TO rol_supervisor;
DENY SELECT ON Empleados TO rol_supervisor;

-- Vendedor: solo registra ventas y consulta productos/clientes
GRANT SELECT ON Productos TO rol_vendedor;
GRANT SELECT ON Clientes TO rol_vendedor;
GRANT SELECT, INSERT ON Ventas TO rol_vendedor;
GRANT SELECT, INSERT ON DetalleVenta TO rol_vendedor;

-- Cajero: solo registra ventas (sin ver stock ni datos de empleados)
GRANT SELECT ON Productos(NombreProducto, Precio) TO rol_cajero;
GRANT SELECT, INSERT ON Ventas TO rol_cajero;
GRANT SELECT, INSERT ON DetalleVenta TO rol_cajero;

-- Bodega: solo maneja inventario y stock de productos
GRANT SELECT ON Productos TO rol_bodega;
GRANT UPDATE (Stock) ON Productos TO rol_bodega;
GRANT SELECT, INSERT ON Inventario TO rol_bodega;
GO

--verificacion 
SELECT
    dp.name AS Rol,
    o.name AS Objeto,
    p.permission_name,
    p.state_desc
FROM sys.database_permissions p
LEFT JOIN sys.objects o ON p.major_id = o.object_id
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name LIKE 'rol_%'
ORDER BY dp.name;

--BACKUPS 
ALTER DATABASE AndyStore SET RECOVERY FULL;
GO

BACKUP DATABASE AndyStore
TO DISK = 'C:\BackupsAndy\AndyStore_FULL.bak'
WITH INIT, FORMAT, NAME = 'AndyStore - Backup Completo';
GO
 

 BACKUP DATABASE AndyStore
TO DISK = 'C:\BackupsAndy\AndyStore_DIFF.bak'
WITH DIFFERENTIAL, NOINIT, NAME = 'AndyStore - Backup Diferencial';
GO
 
 BACKUP LOG AndyStore
TO DISK = 'C:\BackupsAndy\AndyStore_LOG.trn'
WITH NOINIT, NAME = 'AndyStore - Backup de Log';
GO
 
 --verificar backups 
 SELECT
    bs.database_name,
    bs.backup_start_date,
    bs.backup_finish_date,
    CASE bs.type
        WHEN 'D' THEN 'Full'
        WHEN 'I' THEN 'Diferencial'
        WHEN 'L' THEN 'Log'
    END AS TipoBackup,
    bmf.physical_device_name
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'AndyStore'
ORDER BY bs.backup_start_date DESC;

-- JOINS

--producto con categoria y marca

SELECT
    p.NombreProducto,
    m.NombreMarca,
    c.NombreCategoria,
    p.Precio,
    p.Stock
FROM Productos p
INNER JOIN Marcas m ON p.IdMarca = m.IdMarca
INNER JOIN Categorias c ON p.IdCategoria = c.IdCategoria;

-- venta completa (cliente, empleado,
-- ciudad del cliente, sucursal y método de pago)
SELECT
    v.IdVenta,
    v.FechaVenta,
    cl.Nombre + ' ' + cl.Apellido AS Cliente,
    ciu.NombreCiudad AS CiudadCliente,
    e.Nombre + ' ' + e.Apellido AS Empleado,
    s.NombreSucursal,
    mp.Metodo,
    v.Total
FROM Ventas v
INNER JOIN Clientes cl ON v.IdCliente = cl.IdCliente
INNER JOIN Ciudades ciu ON cl.IdCiudad = ciu.IdCiudad
INNER JOIN Empleados e ON v.IdEmpleado = e.IdEmpleado
INNER JOIN Sucursales s ON e.IdSucursal = s.IdSucursal
INNER JOIN MetodoPago mp ON v.IdMetodoPago = mp.IdMetodoPago;

--qeu productos se vendieron en cada venta

SELECT
    dv.IdVenta,
    p.NombreProducto,
    dv.Cantidad,
    dv.PrecioUnitario,
    dv.Subtotal
FROM DetalleVenta dv
INNER JOIN Productos p ON dv.IdProducto = p.IdProducto;

-- left join clientes tengna o no ventas registradas

SELECT
    cl.IdCliente,
    cl.Nombre,
    cl.Apellido,
    COUNT(v.IdVenta) AS CantidadVentas,
    ISNULL(SUM(v.Total), 0) AS TotalComprado
FROM Clientes cl
LEFT JOIN Ventas v ON cl.IdCliente = v.IdCliente
GROUP BY cl.IdCliente, cl.Nombre, cl.Apellido
ORDER BY TotalComprado DESC;

--Producto sin venta
SELECT
    p.IdProducto,
    p.NombreProducto,
    p.Stock
FROM Productos p
LEFT JOIN DetalleVenta dv ON p.IdProducto = dv.IdProducto
WHERE dv.IdDetalle IS NULL;

SELECT * FROM Productos;

INSERT INTO Productos VALUES (801, 'Iphone 17 pro max 256gb', 7500000, 15, 1, 5);

--compras a cada proveedor
SELECT
    pr.Empresa,
    ciu.NombreCiudad,
    COUNT(c.IdCompra) AS CantidadCompras,
    SUM(c.Total) AS TotalComprado
FROM Proveedores pr
INNER JOIN Ciudades ciu ON pr.IdCiudad = ciu.IdCiudad
LEFT JOIN Compras c ON pr.IdProveedor = c.IdProveedor
GROUP BY pr.Empresa, ciu.NombreCiudad
ORDER BY TotalComprado DESC;

-- movimientos de un produco con su nombre

SELECT
    i.IdMovimiento,
    p.NombreProducto,
    i.TipoMovimiento,
    i.Cantidad,
    i.FechaMovimiento,
    i.Observacion
FROM Inventario i
INNER JOIN Productos p ON i.IdProducto = p.IdProducto
ORDER BY i.FechaMovimiento DESC;