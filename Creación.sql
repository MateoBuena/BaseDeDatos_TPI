CREATE DATABASE TPI_BaseDeDatosII
GO

CREATE TABLE Monedas(
CodMoneda CHAR(3) not null PRIMARY KEY, --ARS, USD, etc.
Moneda VARCHAR(25) not null --Peso Argentino, Dolar, etc.
)
GO

CREATE TABLE Cuentas(
IdCuenta INT not null IDENTITY(1,1) PRIMARY KEY,
Nombre VARCHAR(50) not null,
TipoCuenta CHAR(2) not null,
CodMoneda CHAR(3) not null,
Saldo MONEY not null,
Estado BIT not null DEFAULT(1),
CONSTRAINT FK_Cuentas_Monedas FOREIGN KEY (CodMoneda)
REFERENCES Monedas(CodMoneda)
)
GO

CREATE TABLE Roles(
IdRol TINYINT not null IDENTITY(1,1) PRIMARY KEY,
Rol VARCHAR(9) not null --Cliente o Proveedor
)
GO

CREATE TABLE CondicionesFiscales(
IdCondicionFiscal TINYINT not null IDENTITY(1,1) PRIMARY KEY,
CondicionFiscal VARCHAR(25) not null --Responsable inscripto, Monotributista, etc.
)
GO

CREATE TABLE Personas(
IdPersona INT not null IDENTITY(1,1) PRIMARY KEY,
IdRol TINYINT not null,
Nombre VARCHAR(50) null,
Cuit CHAR(11) null,
Direccion VARCHAR(100) null,
Telefono CHAR(13) null,
Email VARCHAR(100) null,
IdCondicionFiscal TINYINT not null,
SaldoPendiente MONEY not null DEFAULT(0),
LimiteSaldo MONEY null,
CONSTRAINT FK_Personas_Roles FOREIGN KEY (IdRol)
REFERENCES Roles(IdRol),
CONSTRAINT FK_Personas_CondicionesFiscales FOREIGN KEY (IdCondicionFiscal)
REFERENCES CondicionesFiscales(IdCondicionFiscal)
)
GO

CREATE TABLE Tipos(
IdTipo TINYINT not null identity(1,1) primary key,
Tipo CHAR(7) not null --Egreso o Ingreso
)
GO

CREATE TABLE Estados(
IdEstado TINYINT not null identity(1,1) primary key,
Estado VARCHAR(9) not null -- Pendiente, Pagada, Vencida
)
GO

CREATE TABLE Facturas(
IdFactura INT not null IDENTITY(1,1) PRIMARY KEY,
IdTipo TINYINT not null,
TipoFactura CHAR(1) null,
IdCuenta INT not null,
IdPersona INT not null,
FechaEmision DATE null DEFAULT(GETDATE()),
TotalFactura MONEY not null CHECK(TotalFactura>=0),
NroCuotas TINYINT not null CHECK(NroCuotas>=1),
IdEstado TINYINT not null,
CONSTRAINT FK_Factuas_Tipos FOREIGN KEY (IdTipo) REFERENCES
 Tipos(IdTipo),
CONSTRAINT FK_Facturas_Cuentas FOREIGN KEY (IdCuenta) REFERENCES
 Cuentas(IdCuenta),
CONSTRAINT FK_Facturas_Personas FOREIGN KEY (IdPersona) REFERENCES
 Personas(IdPersona),
CONSTRAINT FK_Factuas_Estados FOREIGN KEY (IdEstado) REFERENCES
 Estados(IdEstado)
)
GO

CREATE TABLE FormasPago(
IdFormaPago TINYINT not null IDENTITY(1,1) PRIMARY KEY,
FormaPago VARCHAR(20) not null
)
GO

CREATE TABLE Movimientos(
IdMovimiento INT not null IDENTITY(1,1) PRIMARY KEY,
IdFactura INT not null,
FechaMovimiento DATE null,
IdFormaPago TINYINT not null,
MontoMovimiento MONEY not null CHECK(MontoMovimiento>=1),
Observacion VARCHAR(150) null,
CONSTRAINT FK_Movimientos_Facturas FOREIGN KEY (IdFactura) REFERENCES
 Facturas(IdFactura),
CONSTRAINT FK_Movimientos_FormasPago FOREIGN KEY (IdFormaPago) REFERENCES
 FormasPago(IdFormaPago)
)
GO

CREATE TABLE Cuotas(
IdCuotas INT not null IDENTITY(1,1) PRIMARY KEY,
IdMovimiento INT not null,
NroCuota TINYINT not null CHECK(NroCuota>=1),
FechaVencimiento DATE not null,
MontoCuota MONEY not null,
IdEstado TINYINT not null,
CONSTRAINT FK_Cuotas_Movimientos FOREIGN KEY (IdMovimiento) REFERENCES
 Movimientos(IdMovimiento),
CONSTRAINT FK_Cuotas_Estados FOREIGN KEY (IdEstado) REFERENCES
 Estados(IdEstado)
)
GO