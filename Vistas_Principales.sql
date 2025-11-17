USE TPI_BaseDeDatosII
GO

--AQUI ESTAN LAS 3 VISTAS PRINCIPALES DEL TP INTEGRADOR, LAS 3 VISTAS OBLIGATORIAS DEL TP

--VISTAS DE LAS CUENTAS POR PAGAR -> listado de las cuentas de tipo egreso y que esten en estado 'Pendiente' o 'Vencida'
create view VW_CuentasXPagar as
select f.IdFactura as 'Factura',
f.TipoFactura as 'Tipo',
(select TipoCuenta from Cuentas where IdCuenta=(select IdCuenta from Facturas where IdFactura=f.IdFactura)) as 'Cuenta',
(select nombre from Personas where IdPersona=(select IdPersona from Facturas where IdFactura=f.IdFactura)) as 'Persona',
f.FechaEmision as 'Emision', f.TotalFactura as 'Monto', f.NroCuotas as 'Cuotas',
(select Estado from Estados where IdEstado=(select IdEstado from Facturas where IdFactura=f.IdFactura)) as 'Estado'
from Facturas f
where f.IdTipo=1 and f.IdEstado in (1,3)
go

--VISTAS DE LAS CUENTAS POR COBRAR -> listado de las cuentas de tipo ingreso y que esten en estado 'Pendiente' o 'Vencida'
create view VW_CuentasXCobrar as
select f.IdFactura as 'Factura',
f.TipoFactura as 'Tipo',
(select TipoCuenta from Cuentas where IdCuenta=(select IdCuenta from Facturas where IdFactura=f.IdFactura)) as 'Cuenta',
(select nombre from Personas where IdPersona=(select IdPersona from Facturas where IdFactura=f.IdFactura)) as 'Persona',
f.FechaEmision as 'Emision', f.TotalFactura as 'Monto', f.NroCuotas as 'Cuotas',
(select Estado from Estados where IdEstado=(select IdEstado from Facturas where IdFactura=f.IdFactura)) as 'Estado'
from Facturas f
where f.IdTipo=2 and f.IdEstado in (1,3)
go

--ESTADO DE FLUJO DE EFECTIVO-> listado de todos los movimientos que se hicieron en efectivo, es decir con la cuenta 'caja' o 'CX'
create view VW_FlujoEfectivo as
select m.IdMovimiento as 'Movimiento', m.IdFactura as 'Factura',
(select Tipo from Tipos where IdTipo=(select IdTipo from Facturas where IdFactura=m.IdFactura)) as 'Tipo',
m.FechaMovimiento as 'FechaMovimiento', m.MontoMovimiento as 'monto'
from Movimientos m inner join Facturas f on m.IdFactura=f.IdFactura
where m.FechaMovimiento is not null and f.IdCuenta=1 -- 1 -> la caja(efectivo)
GO

--VISTA DE PERDIDAS
--vista secundaria para poder generar la vista primaria de perdidas y ganancias
create view VW_Perdidas as
select sum(c.MontoCuota) as 'Perdidas'
from Facturas f inner join Movimientos m on f.IdFactura=m.IdFactura
inner join Cuotas c on m.IdMovimiento=c.IdMovimiento where f.IdTipo=1 and c.IdEstado=2
go

--VISTA DE GANANCIAS
--vista secundaria para poder generar la vista primaria de perdidas y ganancias
create view VW_Ganancias as
select sum(c.MontoCuota) as 'Ganancias'
from Facturas f inner join Movimientos m on f.IdFactura=m.IdFactura
inner join Cuotas c on m.IdMovimiento=c.IdMovimiento where f.IdTipo=2 and c.IdEstado in (2)
go

--ESTADO DE PERDIDAS Y GANANCIAS
--listado de los totales de los egresos e ingresos y la diferencia entre ellos para saber si hubo perdidas o ganancias y el numero exacto.
create view VW_PerdidasYGanancias as
select (select Perdidas from VW_Perdidas) as 'Perdidas',
(select Ganancias from VW_Ganancias) as 'Ganancias',
((select Ganancias from VW_Ganancias)-(select Perdidas from VW_Perdidas)) as '+/-'
go

--EJEMPLO DE QUE FUNCIONAN LAS VISTAS
select * from VW_CuentasXCobrar
GO

select * from VW_CuentasXPagar
GO

select * from VW_FlujoEfectivo
GO

select * from VW_PerdidasYGanancias
GO