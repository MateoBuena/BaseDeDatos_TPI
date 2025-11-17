USE TPI_BaseDeDatosII
GO
--EN ESTE ARCHIVO SE ENCUENTRAN 2 TRIGGERS PARA CUMPLIR CON LA CONDICION DEL TP INTEGRADOR DE QUE LA BD TIENE QUE TENER 2 TRIGGERS

--TRIGGER QUE NO PERMITE UNA INSERCION DE LIMITESALDO A UN PROVEEDOR Y QUE NO SE PERMITA LA CONDICION FISCAL DE CONSUMIDOR FINAL A UN PROVEEDOR.
CREATE TRIGGER TR_Validaciones_Proveedor_INSERT ON Personas
instead of INSERT
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION

		--DECLARACION DE VARIABLES
		declare @idpersona int
		DECLARE @IDROL TINYINT --1 ->PROVEEDOR-- 2->CLIENTE
		declare @limitesaldo MONEY
		declare @idcondicionfiscal tinyint

		--INSERCION DE DATOS EN VARIABLES
		select @idpersona=(select IdPersona from inserted)
		select @IDROL=(select IdRol from inserted where IdPersona=@idpersona)
		select @limitesaldo=(select LimiteSaldo from inserted where IdRol=@IDROL AND IdPersona=@idpersona)
		select @idcondicionfiscal=(select IdCondicionFiscal from inserted where IdPersona=@idpersona)
		
		--VALIDACION SI LA PERSONA ES PROVEEDOR Y CONSUMIDOR FINAL(ESTA COMBINACION NO DEBERIA DE EXISTIR)
		if @IDROL=1 and @limitesaldo>=0 begin
			raiserror('No se puede insertar un limite de saldo a un proveedor',16,10)
		end
		if @idrol=1 and @idcondicionfiscal=3 begin
				raiserror('Un proveedor nunca puede ser consumidor final',16,10)
		end
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		print error_message()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

--MISMO TRIGGER QUE EL DE INSERT SOLAMENTE CAMBIANDO LA ACCION A UPDATE
CREATE TRIGGER TR_Validaciones_Proveedor_UPDATE ON Personas
instead of UPDATE
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
	
		--DECLARACION DE VARIABLES
		declare @idpersona int
		DECLARE @IDROL TINYINT --1 ->PROVEEDOR-- 2->CLIENTE
		declare @limitesaldo MONEY
		declare @idcondicionfiscal tinyint

		--INSERCION DE DATOS EN VARIABLES
		select @idpersona=(select IdPersona from inserted)
		select @IDROL=(select IdRol from Personas where IdPersona=@idpersona)
		select @limitesaldo=(select LimiteSaldo from inserted where IdRol=@IDROL AND IdPersona=@idpersona)
		select @idcondicionfiscal=(select IdCondicionFiscal from inserted where IdPersona=@idpersona)
		
		--VALIDACION SI LA PERSONA ES PROVEEDOR Y CONSUMIDOR FINAL(ESTA COMBINACION NO DEBERIA DE EXISTIR)
		if @IDROL=1 AND @limitesaldo>=0 begin
			raiserror('No se puede insertar un limite de saldo a un proveedor',16,10)
		end
		if @idrol=1 and @idcondicionfiscal=3 begin
			raiserror('Un proveedor nunca puede ser consumidor final',16,10)
		end
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		print error_message()
		ROLLBACK TRANSACTION
	END CATCH
END
GO

update Personas set LimiteSaldo=1000 where IdPersona=1
go

update Personas set IdCondicionFiscal=3 where IdPersona=1
go

insert into Personas(IdRol,IdCondicionFiscal,LimiteSaldo)
values (1,1,1000)
go

insert into Personas(IdRol,IdCondicionFiscal)
values (1,3)
go

drop trigger TR_Validaciones_Proveedor_UPDATE
go

drop trigger TR_Validaciones_Proveedor_INSERT
go
----------------------------------------------------------------------------------------------------------------

--FIN TRIGGERS QUE NO PERMITEN LA INCERSION DE UN LIMITESALDO A UN PROVEEDOR

--TRIGGER PARA ACTUALIZAR UN MOVIMIENTO A LA HORA DE QUE SE PAGUE
--ACTUALIZAR EL ESTADO DE LA FACTURA VINCULADA 
--ACTUALIZAR EL SALDO DE LA CUENTA AFECTADA.
CREATE TRIGGER TR_Actualizacion_Cuentas ON Movimientos
instead of update
AS
begin
	begin try
		begin transaction
		--DECLARACION DE VARIABLES
			declare @montoMovimiento MONEY
			declare @idmovimiento INT
			declare @tipomovimiento TINYINT
			declare @idfactura INT
			declare @cuenta INT
			declare @saldocuenta MONEY
			declare @observacion varchar(150)

		-- INSERTANDO DATOS A LAS VARIABLES
			select @montoMovimiento=(select MontoMovimiento from inserted)
			select @idmovimiento=(select IdMovimiento from inserted)
			select @idfactura=(select IdFactura from Movimientos where IdMovimiento=@idmovimiento)
			select @cuenta=(select IdCuenta from Facturas where IdFactura=@idfactura)
			select @saldocuenta=(select Saldo from Cuentas where IdCuenta=@cuenta)
			select @tipomovimiento=(select IdTipo from Facturas where IdFactura=@idfactura)
			select @observacion=(select Observacion from inserted)

		--LOGICA
			--VERIFICO QUE SEA UN MOVIMIENTO DE EGRESO
			if @tipomovimiento=1 begin
				--VERIFICO DE QUE LA CUENTA NO QUEDE EN NEGATIVO PARA PODER REALIZAR EL MOVIMIENTO
				if @saldocuenta-@montoMovimiento<0 begin
					raiserror('la cuenta no tiene actualmente el fondo para realizar esta transaccion',16,10)
				end
				else begin
					-- SI LA CUENTA TIENE EL SALDO SUFICIENTE PARA HACER EL MOVIMIENTO, ACTUALIZO EL SALDO DE LA CUENTA, LA FECHA DEL MOVIMIENTO Y EL ESTADO DE LA CUOTA RELACIONADA
					update Cuentas set Saldo=Saldo-@montoMovimiento where IdCuenta=@cuenta

					update Movimientos set FechaMovimiento=GETDATE(),Observacion=@observacion where IdMovimiento=@idmovimiento

					update Cuotas set IdEstado=2 where IdMovimiento=@idmovimiento
				end
			end
			else begin
				update Cuentas set Saldo=Saldo+@montoMovimiento where IdCuenta=@cuenta

				update Movimientos set FechaMovimiento=GETDATE(),Observacion=@observacion where IdMovimiento=@idmovimiento

				update Cuotas set IdEstado=2 where IdMovimiento=@idmovimiento
			end
			
			print 'Movimiento realizado, Saldo de la cuenta actualizado'
		commit transaction
	end try
	begin catch
		print error_message()
		rollback transaction
	end catch
end
GO