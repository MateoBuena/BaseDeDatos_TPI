USE TPI_BaseDeDatosII
GO

--INSERCION DE DATOS

--primero la insercion de datos a tablas maestros

--MONEDAS
insert into Monedas(CodMoneda,Moneda)
values ('ARS','Peso Argentino'),
	   ('USD','Dolar Estadounidense'),
	   ('BRL', 'Real Brasilero'),
	   ('EUR', 'Euro')
GO

--ROLES
insert into Roles(Rol)
values ('Proveedor'),
	   ('Cliente')
GO

--CONDICIONES FISCALES
insert into CondicionesFiscales(CondicionFiscal)
values ('Responsable Inscripto'),
	   ('Monotributista'),
	   ('Consumidor Final'),
	   ('Sujeto del Exterior')
GO

--TIPOS
insert into Tipos(Tipo)
values ('Egreso'),
	   ('Ingreso')
GO

--ESTADOS
insert into Estados(Estado)
values ('Pendiente'),
	   ('Pagada'),
	   ('Vencida')
GO

--FORMAS DE PAGO
insert into FormasPago(FormaPago)
values ('Efectivo'),
	   ('Transferencia'),
	   ('Débito'),
	   ('Crédito'),
	   ('Cheque')
GO

--insercion de datos de las diferentes tablas

--CUENTAS
INSERT INTO Cuentas (Nombre, TipoCuenta, CodMoneda, Saldo)
VALUES
('Caja',				'CX', 'ARS', 600000),
('Mercado Pago',		'DI', 'ARS', 1200000),
('BBVA ARS CC',			'CC', 'ARS', 1000000),
('Santander EUR CC',	'CC', 'EUR', 8000),
('BBVA USD CC',			'CC', 'USD', 5000),
('BBVA USD CA',			'CA', 'USD', 10500),
('Santander EUR CA',	'CA', 'EUR', 25000)
GO

--PERSONAS
INSERT INTO Personas (IdRol, Nombre, Cuit, Direccion, Telefono, Email, IdCondicionFiscal)
VALUES
(1, 'Ciber Servicios SRL', '30788999111', 'Av Belgrano 2345', '1122334455', 'CServicios@CSSRL.com',     1),
(1, 'Techno Service SA',   '30454668877', 'Córdoba 1120',     '1133445566', 'ventas@TService.com',	    1),
(1, 'Pedro Gonzalez',      '30711222333', 'Sarmiento 1234',   '1144556677', 'PGonzalez@Gmail.com',      2),
(2, 'Hugo Sanchez',        '20333444555', 'General Paz 2563', '1177889900', 'HSanchez@Hotmail.com',     2),
(2, 'Pablo Perez',		   '20322119888', 'La Pampa 3443',    '1166778899', 'perez@Gmail.com',          3),
(2, 'Techno Solutions INC','30944556677', 'Córdoba 2152',     '1137485261', 'ventas@TechnoSol.com',	    4)
GO

--FACTURAS
--esta procedimiento almacenado inserta una nueva factura con la forma automatica de el tipo de factura que corresponde
exec SP_Nueva_Factura 1, 1, 1, 15000, 3
go

exec SP_Nueva_Factura 1, 3, 2, 90000, 3
go

exec SP_Nueva_Factura 1, 2, 3, 90000, 1
go

exec SP_Nueva_Factura 2, 2, 4, 22000, 1
go

exec SP_Nueva_Factura 2, 1, 5, 18000, 3
go

exec SP_Nueva_Factura 2, 5, 6, 2500, 3
go



--MOVIMIENTOS
INSERT INTO Movimientos (IdFactura, IdFormaPago,MontoMovimiento)
VALUES
(1, 4,5000),--2
(1, 4,5000),--3
(1, 4,5000),--4
(2, 2,30000),--5
(2, 2,30000),--6
(2, 2,30000),--7
(3, 1,90000),--8
(4, 1,22000),--9
(5, 2,6000),--10
(5, 2,6000),--11
(5, 2,6000),--12
(6, 4,833.34),--13
(6, 4,833.33),--14
(6, 4,833.33)--15
GO


--CUOTAS
INSERT INTO Cuotas (IdMovimiento, NroCuota, FechaVencimiento, MontoCuota, IdEstado)
VALUES
(2, 1, GETDATE(),				   5000,   1),
(3, 2, DATEADD(MONTH,1,GETDATE()), 5000,   1),
(4, 3, DATEADD(MONTH,2,GETDATE()), 5000,   1),
(5, 1, GETDATE(),				   30000,  1),
(6, 2, DATEADD(MONTH,1,GETDATE()), 30000,  1),
(7, 3, DATEADD(MONTH,2,GETDATE()), 30000,  1),
(8, 1, GETDATE(),				   90000,  1),
(9, 1, GETDATE(),				   22000,  1),
(10,1, GETDATE(),				   6000,   1),
(11,2, DATEADD(MONTH,1,GETDATE()), 6000,   1),
(12,3, DATEADD(MONTH,2,GETDATE()), 6000,   1),
(13,1, GETDATE()				 , 833.34, 1),
(14,2, DATEADD(MONTH,1,GETDATE()), 833.33, 1),
(15,3, DATEADD(MONTH,2,GETDATE()), 833.33, 1)
GO

--PAGOS DE CUOTAS
exec SP_pago_cuota 2,2,5000,'Primera cuota'
go

exec SP_pago_cuota 5,5,30000,'Primera transferencia'
go

exec SP_pago_cuota 8,8,90000,'Unico pago'
go

exec SP_pago_cuota 9,9,22000,'Unico pago'
go

exec SP_pago_cuota 10,10,6000,'Primera Transferencia'
go

exec SP_pago_cuota 13,13,833.34,'Primera cuota'
go

exec SP_pago_cuota 3,3,5000,'Segunda cuota'
go

exec SP_pago_cuota 4,4,5000,'Ultima cuota'
go