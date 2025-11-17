USE TPI_BaseDeDatosII
GO

--SP=STORAGE PROCEDURE -> PROCEDIMIENTO ALMACENADO
--EN ESTE ARCHIVO SE ENCUENTRAN 2 SP PARA CUMPLIR CON LA CONDICION DEL TP INTEGRADOR DE QUE LA BD TIENE QUE TENER 2 SP

--SP QUE GENERA UNA NUEVA FACTURA INGRESANDO EL TIPO DE FACTURA QUE ES, LA CUENTA VINCULADA 
--LA PERSONA A LA QUE SE LE VA A VINCULAR ESTA FACTURA, EL TOTAL DE LA FACTURA Y EL NUMERO DE CUOTAS
CREATE PROCEDURE SP_Nueva_Factura(
	@IdTipo TINYINT, -- 1 egreso - 2 ingreso
	@IdCuenta INT,
	@IdPersona INT,
	@TotalFactura MONEY,
	@NroCuotas TINYINT
)
AS
begin
	BEGIN TRY
		BEGIN TRANSACTION
			--VALIDACIONES
			if not exists (select 1 from Personas where IdPersona=@IdPersona) begin
				raiserror('el ID de la persona no existe',16,10)
			end
			if not exists (select 1 from Cuentas where IdCuenta=@IdCuenta) begin
				raiserror('el ID de la cuenta no existe',16,10)
			end
			if not exists (select 1 from Tipos where IdTipo=@IdTipo) begin
				raiserror('el ID del tipo de factura no existe',16,10)
			end
			if @NroCuotas<0 begin
				raiserror('una factura tiene que tener minimo una cuota',16,10)
			end

			--DECLARO VARIABLES PARA AVERIGUAR ROL Y CONDICION FISCAL DE LA PERSONA INGRESADA
			declare @idrol tinyint
			declare @idcondicionfiscal tinyint
			declare @tipofactura char(1)

			--BUSCO CONDICION FISCAL Y ROL
			select @idrol=(select IdRol from Personas where IdPersona=@IdPersona)
			select @idcondicionfiscal=(select IdCondicionFiscal from Personas where IdPersona=@IdPersona)

			--ANALIZO QUE NO SE PUEDAN REALIZAR UNOS TIPOS DE COMBINACIONES ENTRE TIPO DE FACTURA Y TIPO DE ROL
			if @IdTipo=2 and @idrol=1 begin-- SI ES INGRESO Y PROVEEDOR
				raiserror('un proveedor no puede generar una factura de tipo ingreso',16,10)
			end
			if @IdTipo=1 and @idrol=2 begin-- SI ES EGRESO Y CLIENTE
				raiserror('un cliente no puede generar una factura de tipo egreso',16,10)
			end

			--VERIFICO QUE TIPO DE FACTURA (A,B,C,E) ES LA QUE LE TENDRIA QUE FIGURAR EN LA FACTURA SEGUN SU ROL Y CONDICION FISCAL
			if @idrol=2 begin
				if @idcondicionfiscal in (2,3)begin
					select @tipofactura='B'
				end
				else begin
					if @idcondicionfiscal=1 begin
						select @tipofactura='A'
					end
					else begin
							select @tipofactura='E'
					end
				end
			end
			else begin
				if @idcondicionfiscal=1 begin
					select @tipofactura='A'
				end
				else begin
					if @idcondicionfiscal=2 begin
						select @tipofactura='C'
					end
					else begin
						select @tipofactura='E'
					end
				end
			end

			insert into Facturas(IdTipo,TipoFactura,IdCuenta,IdPersona,TotalFactura,NroCuotas,IdEstado)
			values(@IdTipo,@tipofactura,@IdCuenta,@IdPersona,@TotalFactura,@NroCuotas,1)

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT error_message()
		ROLLBACK TRANSACTION
	END CATCH
end
GO

--2DO PROCEDIMIENTO ALMACENADO

--SP PARA PAGAR UNA CUOTA Y REGISTRARLO EN MOVIMIENTOS.
create procedure SP_pago_cuota(
	@IdCuotas INT,
	@IdMovimiento INT,
	@monto money,
	@observacion varchar(150)
)
as
begin
	begin try
		begin transaction

			--VALIDACIONES
			--verifico que el idcuota pasado por parametro exista en la base de datos
			if not exists (select 1 from Cuotas where IdCuotas=@IdCuotas) begin
				raiserror('Id de la cuota inexistente',16,10)
			end
			--verifico que el idmovimiento pasado por parametro exista en la tabla movimientos y en la tabla cuotas
			if not exists (select 1 from Movimientos m inner join Cuotas c on m.IdMovimiento=c.IdMovimiento) begin
				raiserror('Id del movimiento inexistente',16,10)
			end
			--verifico que el monto sea mayor a 0
			if @monto<0 begin
				raiserror('el monto tiene que ser mayor a cero',16,10)
			end

			--DECLARACION DE VARIABLES
			declare @idfactura int
			declare @nrocuotas_facturas tinyint
			declare @nrocuota_cuotas tinyint

			--INSERCION DE DATOS A VARIABLES
			select @idfactura=(select IdFactura from Movimientos where IdMovimiento=@IdMovimiento)
			select @nrocuotas_facturas=(select NroCuotas from Facturas where IdFactura=@idfactura)
			select @nrocuota_cuotas=(select NroCuota from Cuotas where IdCuotas=@IdCuotas)

			--ACTUALIZACION DE LAS TABLAS
			update Movimientos set FechaMovimiento=GETDATE(),MontoMovimiento=@monto,Observacion=@observacion where IdMovimiento=@IdMovimiento

			update Cuotas set IdEstado=2 where IdCuotas=@IdCuotas

			--SI ES LA ULTIMA CUOTA ACTUALIZO LA FACTURA A 'PAGADA' 
			if @nrocuotas_facturas=@nrocuota_cuotas begin
				update Facturas set IdEstado=2 where IdFactura=@idfactura
			end

		commit transaction
	end try
	begin catch
		print error_message()
		rollback transaction
	end catch

end
go
