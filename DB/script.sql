USE [BD_ALMATRINCHERO_2020_NEW]
GO
/****** Object:  UserDefinedFunction [dbo].[F_CalcularTotalExoneradas_Gravadas_Ventas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[F_CalcularTotalExoneradas_Gravadas_Ventas](@id int,
@ex_gra bit)
returns money
as
begin
declare @total money = 0

if(@ex_gra = 0)
	begin
		set @total = (select sum(Total)
		from mst_Venta_det
		where IdVenta = @id and Igv <= 0 and Flag = 1 and Anulado = 0)
	end
else
	begin
		set @total = (select sum(Total)
		from mst_Venta_det
		where IdVenta = @id and Igv > 0 and Flag = 1 and Anulado = 0)
	end

set @total =isnull(@total,0)
return (@total)
end



















GO
/****** Object:  UserDefinedFunction [dbo].[F_GetUltimoCostoProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[F_GetUltimoCostoProductoDetalle](@idProductoDetalle int, @idAlmacen int)
returns money
as
begin
declare @costo money = 0
set @costo = (select top 1  Costo from (
---INVENTARIO--------
select
Id_Producto as 'IdProducto',
Costo as 'Costo',
i.FechaCrea as 'FechaCrea',
i.Id_Almacen 'IdAlmacen'
from mst_Inventario_Detalle id
inner join mst_Inventario i on id.Id_Inventario = i.Id
where i.Estado = 1 and i.Flag = 1
and id.Estado = 1 and id.Flag = 1
---INVENTARIO--------
union all
---COMPRAS--------
select
IdProducto,
Precio as 'Costo',
c.FechaCrea,
c.IdAlmacen 'IdAlmacen'
from mst_ComprasDetalles cd
inner join mst_Compras c on cd.IdCompra = c.Id
where c.Estado = 1 and c.Flag = 1 and cd.Estado = 1 and cd.Flag = 1
and c.IsClosed = 1
---COMPRAS--------
union all
---ENTRADAS--------
select 
idProducto as 'IdProducto',
precio as 'Costo',
m.fecha as 'FechaCrea',
m.idAlmacen 'IdAlmacen'
from mst_almacen_movimiento_detalle md
inner join mst_almacen_movimiento m on md.almacen_movimiento_id = m.id
where entrada = 1 and m.estado = 1 and m.flag = 1 and md.estado = 1 and md.flag = 1
---ENTRADAS--------
union all
---TRASLADOS--------
select
td.idProducto as 'IdProducto',
td.precio 'Costo',
t.fecha 'FechaCrea',
t.idAlmacenEntrada as 'IdAlmacen'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on td.almacen_traslado_id = t.id
where td.estado = 1 and td.flag = 1 and t.estado = 1 and t.flag = 1
---TRASLADOS--------
) as Temp
where Temp.IdProducto = @idProductoDetalle
and Temp.IdAlmacen = @idAlmacen
order by Temp.FechaCrea desc)

set @costo =isnull(@costo,0)
return (@costo)
end

GO
/****** Object:  UserDefinedFunction [dbo].[f_promedio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[f_promedio]
 (@palabra varchar(max))
 returns varchar(max)
 as
 begin 
   return Replace(@palabra, 'ñ', 'n')
 end;



















GO
/****** Object:  UserDefinedFunction [dbo].[F_SecuenciaDelivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[F_SecuenciaDelivery]
()
returns int
as
begin
declare @fecha_actual date = GETDATE()
return (select count(*) as 'Secuencia' from mst_Venta where delivery = 1 and CAST(FechaEmision as date) = CAST(@fecha_actual as date))+1;
end
GO
/****** Object:  UserDefinedFunction [dbo].[F_SecuenciaLlevar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[F_SecuenciaLlevar]
()
returns int
as
begin
declare @fecha_actual date = GETDATE()
return (select count(*) as 'Secuencia' from mst_Venta where llevar = 1 and cast(FechaEmision as date) = cast(@fecha_actual as DATE))+1;
end
GO
/****** Object:  UserDefinedFunction [dbo].[F_Trim]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[F_Trim](@valor varchar(max))
returns varchar(max)
as
begin

return ltrim(rtrim(replace(@valor, '   ', '')))
end



















GO
/****** Object:  UserDefinedFunction [dbo].[fn_ConvertirNumeroLetra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [dbo].[fn_ConvertirNumeroLetra]
 (
        @Numero     NUMERIC(18, 2),
        @Moneda     VARCHAR(100)
 )
 RETURNS VARCHAR(512)
 AS
 BEGIN
        DECLARE @lnEntero       INT,
                @lcRetorno      VARCHAR(512),
                @lnTerna        INT,
                @lcMiles        VARCHAR(512),
                @lcCadena       VARCHAR(512),
                @lnUnidades     INT,
                @lnDecenas      INT,
                @lnCentenas     INT,
                @lnFraccion     INT,
                @resultado      AS VARCHAR(512)
       
        SELECT @lnEntero = CAST(@Numero AS INT),
               @lnFraccion     = (@Numero - @lnEntero) * 100,
               @lcRetorno      = '',
               @lnTerna        = 1
       
        WHILE @lnEntero > 0
        BEGIN
            /* WHILE */
            -- Recorro terna por terna      
            SELECT @lcCadena = ''          
            SELECT @lnUnidades = @lnEntero % 10            
            SELECT @lnEntero = CAST(@lnEntero / 10 AS INT)          
            SELECT @lnDecenas = @lnEntero % 10      
            SELECT @lnEntero = CAST(@lnEntero / 10 AS INT)          
            SELECT @lnCentenas = @lnEntero % 10            
            SELECT @lnEntero = CAST(@lnEntero / 10 AS INT)
            -- Analizo las unidades        
            SELECT @lcCadena = CASE /* UNIDADES */
                                    WHEN @lnUnidades = 1 AND @lnTerna = 1 THEN
                                         'UNO ' + @lcCadena
                                    WHEN @lnUnidades = 1 AND @lnTerna <> 1 THEN
                                         'UN ' + @lcCadena
                                    WHEN @lnUnidades = 2 THEN 'DOS ' + @lcCadena
                                    WHEN @lnUnidades = 3 THEN 'TRES ' + @lcCadena
                                    WHEN @lnUnidades = 4 THEN 'CUATRO ' + @lcCadena
                                    WHEN @lnUnidades = 5 THEN 'CINCO ' + @lcCadena
                                    WHEN @lnUnidades = 6 THEN 'SEIS ' + @lcCadena
                                    WHEN @lnUnidades = 7 THEN 'SIETE ' + @lcCadena
                                    WHEN @lnUnidades = 8 THEN 'OCHO ' + @lcCadena
                                    WHEN @lnUnidades = 9 THEN 'NUEVE ' + @lcCadena
                                    ELSE @lcCadena
                               END /* UNIDADES */
            -- Analizo las decenas
            SELECT @lcCadena = CASE /* DECENAS */
                                    WHEN @lnDecenas = 1 THEN CASE @lnUnidades
                                                                  WHEN 0 THEN
                                                                       'DIEZ '
                                                                  WHEN 1 THEN
                                                                       'ONCE '
                                                                  WHEN 2 THEN
                                                                       'DOCE '
                                                                  WHEN 3 THEN
                                                                       'TRECE '
                                                                  WHEN 4 THEN
                                                                       'CATORCE '
                                                                  WHEN 5 THEN
                                                                       'QUINCE '
                                                                  ELSE 'DIECI' + @lcCadena
                                                             END
                                    WHEN @lnDecenas = 2 AND @lnUnidades = 0 THEN
                                         'VEINTE ' + @lcCadena
                                    WHEN @lnDecenas = 2 AND @lnUnidades <> 0 THEN
                                         'VEINTI' + @lcCadena
                                    WHEN @lnDecenas = 3 AND @lnUnidades = 0 THEN
                                         'TREINTA ' + @lcCadena
                                    WHEN @lnDecenas = 3 AND @lnUnidades <> 0 THEN
                                         'TREINTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 4 AND @lnUnidades = 0 THEN
                                         'CUARENTA ' + @lcCadena
                                    WHEN @lnDecenas = 4 AND @lnUnidades <> 0 THEN
                                         'CUARENTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 5 AND @lnUnidades = 0 THEN
                                         'CINCUENTA ' + @lcCadena
                                    WHEN @lnDecenas = 5 AND @lnUnidades <> 0 THEN
                                         'CINCUENTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 6 AND @lnUnidades = 0 THEN
                                         'SESENTA ' + @lcCadena
                                    WHEN @lnDecenas = 6 AND @lnUnidades <> 0 THEN
                                         'SESENTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 7 AND @lnUnidades = 0 THEN
                                         'SETENTA ' + @lcCadena
                                    WHEN @lnDecenas = 7 AND @lnUnidades <> 0 THEN
                                         'SETENTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 8 AND @lnUnidades = 0 THEN
                                         'OCHENTA ' + @lcCadena
                                    WHEN @lnDecenas = 8 AND @lnUnidades <> 0 THEN
                                         'OCHENTA Y ' + @lcCadena
                                    WHEN @lnDecenas = 9 AND @lnUnidades = 0 THEN
                                         'NOVENTA ' + @lcCadena
                                    WHEN @lnDecenas = 9 AND @lnUnidades <> 0 THEN
                                         'NOVENTA Y ' + @lcCadena
                                    ELSE @lcCadena
                               END /* DECENAS */
            -- Analizo las centenas        
            SELECT @lcCadena = CASE /* CENTENAS */
                                    WHEN @lnCentenas = 1 AND @lnUnidades = 0 AND @lnDecenas
                                         = 0 THEN 'CIEN ' +
                                         
                                         @lcCadena
                                    WHEN @lnCentenas = 1 AND NOT(@lnUnidades = 0 AND @lnDecenas = 0) THEN
                                         'CIENTO ' + @lcCadena
                                    WHEN @lnCentenas = 2 THEN 'DOSCIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 3 THEN 'TRESCIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 4 THEN 'CUATROCIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 5 THEN 'QUINIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 6 THEN 'SEISCIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 7 THEN 'SETECIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 8 THEN 'OCHOCIENTOS ' + @lcCadena
                                    WHEN @lnCentenas = 9 THEN 'NOVECIENTOS ' + @lcCadena
                                    ELSE @lcCadena
                               END /* CENTENAS */
            -- Analizo la terna
           
            SELECT @lcCadena = CASE /* TERNA */
                                    WHEN @lnTerna = 1 THEN @lcCadena
                                    WHEN @lnTerna = 2 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) THEN
                                         @lcCadena + ' MIL '
                                    WHEN @lnTerna = 3 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0)
                                         AND
                                         
                                         @lnUnidades = 1 AND @lnDecenas = 0 AND @lnCentenas
                                         = 0 THEN @lcCadena + 'MILLON '
                                    WHEN @lnTerna = 3 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0)
                                         AND
                                         NOT (@lnUnidades = 1 AND @lnDecenas = 0 AND @lnCentenas = 0) THEN
                                         @lcCadena
                                         + ' MILLONES '
                                    WHEN @lnTerna = 4 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) THEN
                                         @lcCadena + ' MIL MILLONES '
                                    ELSE ''
                               END /* TERNA */
            -- Armo el retorno terna a terna        
            SELECT @lcRetorno = @lcCadena + @lcRetorno      
            SELECT @lnTerna = @lnTerna + 1
        END /* WHILE */        
        IF @lnTerna = 1
            SELECT @lcRetorno = 'CERO'
       
        SELECT @resultado = RTRIM(@lcRetorno) + ' CON ' + LTRIM(STR(@lnFraccion, 2))
               + '/100 ' + @Moneda
       
        RETURN @resultado
 END























GO
/****** Object:  UserDefinedFunction [dbo].[getIcbAmount]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getIcbAmount]()
returns decimal(9,2)
as
begin
declare @date_init int = 2018, 
@date_now  int, 
@amount decimal(9,2) = 0, 
@diference decimal(9,2)

set @date_now  = year(getdate())
set @diference = CAST((@date_now - @date_init) as decimal)/10

if @date_now > @date_init
begin
set @amount = @amount + @diference
end
return @amount
end



GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[Split]
(
    @Texto VARCHAR(MAX),
    @Delimitador CHAR(1)
)
RETURNS @output TABLE(Datos VARCHAR(MAX)
)
BEGIN
    DECLARE @Empieza INT, @Termina INT
    SELECT @Empieza = 1, @Termina= CHARINDEX(@Delimitador , @Texto )
    WHILE @Empieza < LEN(@Texto ) + 1 BEGIN
        IF @Termina = 0  
            SET @Termina = LEN(@Texto ) + 1
      
        INSERT INTO @output (Datos)  
        VALUES(SUBSTRING(@Texto , @Empieza , @Termina - @Empieza ))
        SET @Empieza = @Termina + 1
        SET @Termina = CHARINDEX(@Delimitador , @Texto , @Empieza )
        
    END
    RETURN
END


















GO
/****** Object:  View [dbo].[ViewProductForApp]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ViewProductForApp]
as
SELECT pp.Id as Id, p.NombreProducto ProductName, g.Descripcion ProductGroup, pp.IdUnidad ProductUnitId, u.NombreUnidad ProductUnitName, pp.PrecioUnitario ProductPrice
FROM mst_Producto p
INNER JOIN mst_ProductoDetalle pd ON pd.idProducto = p.Id
INNER JOIN mst_ProductoPresentacion pp ON pp.idProductosDetalle = pd.Id
INNER JOIN mst_Grupo g ON g.Id = p.IdGrupo
INNER JOIN mst_UnidadMedida u ON u.Id = pp.idUnidad
WHERE 
(p.flag = 1 AND p.estado = 1) 
AND (pd.flag = 1 AND pd.estado = 1)
AND (pp.flag = 1 AND pp.estado = 1)

GO
/****** Object:  View [dbo].[ViewProductoVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[ViewProductoVenta]
as
select
p.Id as 'IdProducto',
pd.Id as 'IdProductoDetalle',
pp.Id as 'IdProductoPresentacion',
ISNULL(pp.Codigo, '') as 'CodigoBarra',
pd.codigoBarra as 'CodigoBarraDetalle',
CONCAT(p.nombreProducto, ' ', pd.descripcion, ' ', LTRIM(mmm.descripcion), 
LTRIM(mm.nombreMarca), '', LTRIM(t.descripcion), ' ', LTRIM(c.descripcion))
as 'NombreProducto',
um.id 'IdUnidad',
LTRIM(um.nombreUnidad) 'UnidadMedida',
um.factor Factor,
pro.nombre Proveedor,
stock.saldo 'Stock',
fechavencimiento as 'FechaVence',
CAST(pp.precioUnitario as decimal(18,2)) 'Precio',
stock.IdAlmacen 'IdAlmacen',
pp.principal 'IsPrincipal',
pd.checkstock 'CheckStock'
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor pro on p.idproveedor = pro.id
inner join stocks_acumulados stock on pd.id = stock.idproducto
where p.flag = 1 
and p.estado = 1
and pd.flag = 1 
and pd.estado = 1
and pp.flag = 1 
and pp.estado = 1


GO
/****** Object:  View [dbo].[vw_FiltroMstProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_FiltroMstProductos] AS select
pd.Id Id,
pd.codigoBarra Cod_Barra,
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
t.descripcion+' '+ 
c.descripcion  as 'Descripcion',
um.nombreUnidad U_Medida,
um.factor Factor,
ppp.nombre Proveedor,
iif(CONVERT(varchar,pd.fechavencimiento,1) IS NULL,'Sin definir',
datename(year,pd.fechavencimiento)+'-'+datename(month,pd.fechavencimiento))
F_Vence,
'' Imagen,
(pp.precioUnitario) Precio_Unit,
um.id Id_Unidad,
p.Id Id_Producto,
pd.estado Estado,
isnull(stock.Saldo,0) Stock,
pp.Id IdPresentacion,
stock.IdAlmacen,
g.Descripcion as Grupo,
g.id idGrupo,
pd.stockminimo,
pp.Codigo
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor ppp on p.idproveedor = ppp.id
left join Stocks_Acumulados stock on pd.id = stock.idproducto
inner join mst_Grupo g on p.IdGrupo = g.Id
where 
p.flag = 1 
and (p.estado = 1 OR P.estado = 0)
and (pd.estado = 1 OR pd.estado = 0)
and pp.estado = 1
and pp.flag = 1 
and pp.Principal = 1
GO
/****** Object:  View [dbo].[vw_FiltroProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FiltroProductos] AS select
pp.Id as Id,
pd.Id as C_Interno,
pd.codigoBarra as [Cod_Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
LTRIM(mmm.descripcion) + ' ' +
LTRIM(mm.nombreMarca) + ' ' + 
LTRIM(t.descripcion)+' '+ 
LTRIM(c.descripcion) as 'Descripcion',
LTRIM(um.nombreUnidad) [U_Medida],
um.factor [Factor],
'' Imagen,
pro.nombre [Proveedor],
stock.saldo [Stock_Actual],
fechavencimiento as [F_Vencimiento],
CAST(pp.precioUnitario as decimal(18,2)) [Precio_Unit],
um.id [Id_Unidad],
p.IdGrupo as 'idgrupo',
stock.IdAlmacen,
pd.idmedida,
pp.principal,
pp.idUnidad,
pd.checkstock,
CAST(ISNULL(PrincipalAlmacen, 0) as bit) 'PrincipalAlmacen',
pp.Codigo,
p.Id 'IdProducto',
pp.VerEnVentas
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor pro on p.idproveedor = pro.id
inner join stocks_acumulados stock on pd.id = stock.idproducto
where p.flag = 1 
and p.estado = 1
and pd.flag = 1 
and pd.estado = 1
and pp.flag = 1 
and pp.estado = 1
GO
/****** Object:  View [dbo].[vw_tbl_cab_cpe]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tbl_cab_cpe] AS SELECT
	a.Id AS id_cab_cpe,
	a.IdDocumento AS codigo,
CASE
		a.IdDocumento 
		WHEN '03' THEN
		'BOLETA ELECTRONICA' 
		WHEN '01' THEN
		'FACTURA ELECTRONICA' 
		WHEN '07' THEN
		'NOTA DE CREDITO' 
		WHEN '08' THEN
		'NOTA DE DEBITO' 
	END AS descri_doc,
	a.SerieDoc AS serie_doc_cpe,
	a.NumeroDoc AS nro_doc_cpe,
	a.SerieDoc + '-' + CAST ( a.NumeroDoc AS CHAR ( 15 ) ) AS serie_nro_doc_cpe,
	CAST(a.FechaEmision as DATE) AS fecha_emi_doc_cpe,
	'' AS nro_guia_remi,
	a.TipoMoneda AS tipo_moneda,
	CAST ( '20' AS CHAR ( 2 ) ) AS tipo_afec_igv,
	CAST ( a.CodigoTipoDoc AS CHAR ( 2 ) ) AS tipo_doc_cli,
	CAST ( a.DniRuc AS CHAR ( 15 ) ) AS ruc_cliente,
	CAST ( a.DniRuc AS CHAR ( 8 ) ) AS dni_cliente,
	CAST ( a.DniRuc AS CHAR ( 15 ) ) AS ruc_dni_cliente,
	a.RazonSocial AS nombre_cliente,
	a.Direccion,
	CAST ( 'PERÚ' AS CHAR ( 25 ) ) AS pais,
	ISNULL( a.Email, '' ) AS correo_cliente,
	CAST ( ISNULL( a.TipoNotCred, '' ) AS CHAR ( 2 ) ) AS tipo_not_crede,
	CAST ( ISNULL( a.DescripNotCred, '' ) AS CHAR ( 50 ) ) AS descri_not_crede,
	CAST ( ISNULL( a.TipoDocAfectado, '' ) AS CHAR ( 2 ) ) AS tipo_doc_afecta,
	CAST ( ISNULL( a.NumeroDocAfectado, '' ) AS CHAR ( 30 ) ) AS nro_doc_afecta,
	CAST ( a.SubTotal AS NUMERIC ( 12, 2 ) ) AS sub_total,
	dbo.F_CalcularTotalExoneradas_Gravadas_Ventas ( a.Id, 1 ) AS ope_gravada,
	dbo.F_CalcularTotalExoneradas_Gravadas_Ventas ( a.Id, 0 ) AS ope_exonerada,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS ope_inafecta,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS ope_gratuita,
	a.Descuento,
	a.Igv,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS isc,
	CAST ( a.TotalVenta AS NUMERIC ( 12, 2 ) ) AS total_cpe,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS m_percepcion,
	CAST ( A.TotalVenta AS NUMERIC ( 12, 2 ) ) AS total_cpe_pagar,
	CAST ( a.Total_Letras AS VARCHAR ) AS total_cpe_letras,
	CAST ( a.Anulado AS NUMERIC ( 1 ) ) AS estatus,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS cpe_ope_detraccion,
	CAST ( '' AS VARCHAR ) AS cta_bancaria,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS por_detraccion,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS monto_detraccion,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS cpe_con_guia,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS cpe_con_anticipos,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS cpe_con_reg_anticipos,
	CAST ( '' AS VARCHAR ) AS ant_tipo_doc_cpe,
	CAST ( '' AS VARCHAR ) AS ant_numero_doc_cpe,
	CAST ( '' AS VARCHAR ) AS ant_tipo_doc_cli,
	CAST ( '' AS VARCHAR ) AS ant_ruc_cli,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS ant_total_cpe,
	CAST ( 0 AS NUMERIC ( 12 ) ) AS cpe_emisor_itinerante,
	CAST ( 1 AS NUMERIC ( 12 ) ) AS id_usuario,
	CAST ( '' AS VARCHAR ) AS condi_doc_cpe,
	CAST ( '01/01/1900' AS DATE ) AS fe_vencimiento,
	CAST ( '' AS VARCHAR ) AS obs_cpe,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS oth_imp,
	ISNULL( dbo.tbl_info_cpe.doc_firma, 0 ) AS doc_firma,
	ISNULL( dbo.tbl_info_cpe.doc_cdr, 0 ) AS doc_cdr,
	ISNULL( dbo.tbl_info_cpe.doc_email, 0 ) AS doc_email,
	ISNULL( dbo.tbl_info_cpe.doc_publicado, 0 ) AS doc_publicado,
	ISNULL( dbo.tbl_info_cpe.cod_sunat, '' ) AS cod_sunat,
	ISNULL( dbo.tbl_info_cpe.des_cod_sunat, '' ) AS des_cod_sunat,
	ISNULL( dbo.tbl_info_cpe.hash_sunat, '' ) AS hash_sunat,
	ISNULL( dbo.tbl_info_cpe.com_baja, 0 ) AS com_baja,
	ISNULL( dbo.tbl_info_cpe.resu_boleta, 0 ) AS resu_boleta,
	ISNULL( dbo.tbl_info_cpe.estacion_pc, '' ) AS estacion_pc,
	ISNULL( dbo.tbl_info_cpe.doc_proceso, 0 ) AS doc_proceso,
	CAST ( a.Tipo_Operacion AS CHAR ( 5 ) ) AS tipo_operacion,
	CAST ( '' AS DATE ) AS fecha_guia_remision,
	CAST ( '' AS CHAR ( 80 ) ) AS contacto_emisor,
	CAST ( 0.00 AS NUMERIC ( 12, 2 ) ) AS total_ope_exportacion,
	a.Otro_Imp AS otros_impuestos,
	iif ( A.TipoMoneda = 'PEN', 'S/', '$' ) AS Simbolo,
	'X' AS 'IDENTIFICADOR',
	status_verificado,
	codigo_verificado,
	mensaje_verificado,
	observacion_verificado,
	IIF ( A.IdFormaPago = 1, 'Contado', 'Credito' ) forma_pago 
FROM
	dbo.mst_Venta AS a
	LEFT OUTER JOIN dbo.tbl_info_cpe ON a.Id = dbo.tbl_info_cpe.id_cab_cpe 
WHERE
	A.IdDocumento <> '99'
GO
/****** Object:  View [dbo].[vw_tbl_cronograma_cpe]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_tbl_cronograma_cpe]
as
SELECT
vc.id 'id_cronograma',
vc.idVenta 'id_cab_cpe',
CAST(vc.fecha AS varchar) 'fecha',
CONCAT('Cuota', RIGHT('000' + Ltrim(Rtrim(vc.nroCuota)), 3)) 'nro_cuota',
vc.monto 'monto'
FROM venta_cronograma vc
where vc.estado = 1 and vc.flag = 1


GO
/****** Object:  View [dbo].[vw_tbl_items_cab_cpe]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vw_tbl_items_cab_cpe]
AS
SELECT        a.Id AS id_item_cab_cpe, a.IdVenta AS id_cab_cpe, a.IdProducto AS id_producto, CAST(a.IdProducto AS char(25)) AS cve_producto, CAST('NIU' AS char(3)) AS unit_code, a.descripcion AS nom_producto, CAST('' AS char(254)) 
                         AS descri_item, CAST(a.Cantidad AS numeric(12, 2)) AS cantidad, CAST(a.PrecioUnit AS numeric(12, 2)) AS pre_unitario, CAST(a.Subtotal AS numeric(12, 2)) AS sub_total, CAST('' AS CHAR(2)) AS tipo_isc, CAST(0 AS numeric(3)) 
                         AS por_isc, CAST(0 AS numeric(12, 2)) AS monto_isc, CAST('20' AS CHAR(2)) AS tipo_afec_igv, CAST(a.Igv AS numeric(12, 2)) AS monto_igv, CAST(a.Total AS numeric(12, 2)) AS pre_total, d.IdProductoSunat, 
                         a.Adicional1 AS TipoAdicional, a.Adicional2 AS FechaAdicional, a.Adicional3 AS NumAdicional, a.Adicional4 as 'OtroAdicional',
						 iif(a.CodigoBarra = 'ICBPER', a.Total, 0) 'otros_impuestos',
						 'X' AS 'IDENTIFICADOR'
FROM            dbo.mst_Venta_det AS a LEFT JOIN
                         dbo.mst_ProductoPresentacion AS b ON a.IdProducto = b.Id LEFT JOIN
                         dbo.mst_ProductoDetalle AS c ON b.idProductosDetalle = c.Id LEFT JOIN
                         dbo.mst_Producto AS d ON c.idProducto = d.Id












GO
/****** Object:  StoredProcedure [dbo].[ActualizarPedidoConvenio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ActualizarPedidoConvenio]
@idventa int,
@ids_pedidos_convenio varchar(max)
as
declare @id int
declare temp cursor
for
(
select * from dbo.split(@ids_pedidos_convenio, ',')
)
open temp

fetch temp into @id;

while(@@FETCH_STATUS = 0)
begin
	update tabla_Pre_Venta_Convenio set IdVenta = @idventa, Pagado = 1
	where IdPedido = @id

	FETCH temp INTO @id
end
CLOSE temp
DEALLOCATE temp













































GO
/****** Object:  StoredProcedure [dbo].[BuscarConvenio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[BuscarConvenio]
@id int,
@buscar varchar(250),
@fecha date,
@fechafin date,
@bit bit
as
if(@bit = 0)
	begin
	select * from
	(
		select
			Id,
			Ruc,
			Razon,
			Direccion,
			Contrato,
			Descripcion,
			CAST(MontoLimite as decimal(18,2)) as 'MontoLimite',
			FechaInicio,
			FechaFin,
			UsuarioCrea,
			FechaCrea,
			UsuarioModifica,
			FechaModifica,
			Estado,
			IdCliente
			from mst_convenios
			where (FechaInicio between CAST(@fecha as date) and CAST(@fechafin as date) and Flag = 1)			
		)as temp
		where ((temp.Ruc + ' ' + temp.Razon + ' ' + cast(temp.Direccion as varchar(250)) + ' ' + temp.Contrato) like '%'+@buscar+'%')
		order by temp.Id desc
	end
else
	begin
	select
		Id,
		Ruc,
		Razon,
		Direccion,
		Contrato,
		Descripcion,
		CAST(MontoLimite as decimal(18,2)) as 'MontoLimite',
		FechaInicio,
		FechaFin,
		UsuarioCrea,
		FechaCrea,
		UsuarioModifica,
		FechaModifica,
		Estado,
		IdCliente
		from mst_convenios
		where Id = @id
	end

















































GO
/****** Object:  StoredProcedure [dbo].[CalcularNumeroApertura]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[CalcularNumeroApertura]
@idcaja int,
@idusuario int
as
select numero from mst_apertura
where idcaja = @idcaja and IdUsuario = @idusuario
GO
/****** Object:  StoredProcedure [dbo].[EliminarConvenio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[EliminarConvenio]
@id int
as
update mst_convenios set Estado = 0, Flag = 0
where id = @id

















































GO
/****** Object:  StoredProcedure [dbo].[Impresion_Items_Convenio_Factura]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Impresion_Items_Convenio_Factura]
@idventa int
as
select * from tabla_Pre_Venta_Convenio pc 
inner join tabla_Pre_Venta_Detalle_Convenio pdc on pc.IdPedido = pdc.IdPedido
where pc.IdVenta = @idventa









































GO
/****** Object:  StoredProcedure [dbo].[InsertarConvenio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[InsertarConvenio]
@id int,
@idcliente int,
@ruc varchar(11),
@razon varchar(250),
@direccion text,
@contrato varchar(50),
@descripcion text,
@montolimite money,
@fechainicio date,
@fechafin date,
@usuariocrea varchar(50),
@estado bit,
@bit bit
as
if @bit = 0
	begin
	insert into mst_convenios (idcliente, ruc, Razon, Direccion, Contrato, Descripcion, MontoLimite, FechaInicio, FechaFin, UsuarioCrea)
	values(@idcliente, @ruc, @razon, @direccion, @contrato, @descripcion, @montolimite, @fechainicio, @fechafin, @usuariocrea)
	end
else
	begin
	update mst_convenios 
	set idcliente = @idcliente, 
	Ruc = @ruc, 
	Razon = @razon,
	Direccion = @direccion,
	Contrato = @contrato,
	Descripcion = @descripcion,
	MontoLimite = @montolimite,
	FechaInicio = @fechainicio,
	FechaFin = @fechafin,
	UsuarioModifica = @usuariocrea,
	FechaModifica = GETDATE(),
	Estado = @estado
	where Id = @id
	end

















































GO
/****** Object:  StoredProcedure [dbo].[InsertarUsuarioItemsInicio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[InsertarUsuarioItemsInicio]
@idusuario int
as
insert into tabla_Usuarios_Menu (idmenu,idusuario)
select id,@idusuario from tabla_Menus;

insert into tabla_Usuario_SubMenu(idmenu,idsubmenu,idusuario)
select idmenu,id,@idusuario from tabla_SubMenus;























































GO
/****** Object:  StoredProcedure [dbo].[LiberarResumenes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[LiberarResumenes]
@numticket varchar(100)
as
update Tbl_Resumen_Det set NumTicket = '', Enviado = 0
where NumTicket = @numticket


















































GO
/****** Object:  StoredProcedure [dbo].[ModificarVentaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ModificarVentaDetalle]
@id int,
@idproducto int,
@preciounitario money,
@cantidad int,
@descuento money,
@idunidad int,
@factor int,
@subtotal money
as
update mst_Venta_det set
IdProducto = @idproducto,
PrecioUnit = @preciounitario,
Cantidad = @cantidad,
Descuento = @descuento,
IdUnidad = @idunidad,
Factor =@factor,
Subtotal = @subtotal
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[Reporte_Gastos_Operativos_Cierre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Reporte_Gastos_Operativos_Cierre]
@idapertura int,
@idcaja int,
@idusuario int
as

select g.*, t.Descripcion 'Tipo_de_Gasto' from mst_GastosOperativos g
inner join mst_tipoGasto t on g.IdTipoGasto = t.Id
where eliminado = 0 and IdApertura = @idapertura and idcaja = @idcaja and IdUsuario = @idusuario
order by g.id desc
GO
/****** Object:  StoredProcedure [dbo].[Reporte_Gastos_Operativos_Cierre_Totalizado_por_fecha]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Reporte_Gastos_Operativos_Cierre_Totalizado_por_fecha]
@fecha_ini date,
@fecha_fin date
as

select g.*, t.Descripcion 'Tipo_de_Gasto' from mst_GastosOperativos g
inner join mst_tipoGasto t on g.IdTipoGasto = t.Id
where cast(g.Fecha  as date) between  @fecha_ini and @fecha_fin
order by g.id desc
GO
/****** Object:  StoredProcedure [dbo].[sp_add_permisos_cobrador]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_add_permisos_cobrador]
@id int,
@check bit
as
update mst_Usuarios set is_cobrador = @check
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[sp_agregar_count_pecho_piera_textObs]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_agregar_count_pecho_piera_textObs]
@count_pecho int,
@count_pierna int,
@text_obs varchar(250),
@id_pedido int,
@mesa bit
as
--id_pedido es el id de la tabla pk
if(@mesa = 0)
	BEGIN
		update tabla_Pre_Venta set countPierna = @count_pierna, countPecho = @count_pecho,
		textObservation = @text_obs
		where id = @id_pedido AND Pagado = 0 and Eliminado = 0
	END
else
	BEGIN
		update tabla_Pre_Venta set countPierna = @count_pierna, countPecho = @count_pecho,
		textObservation = @text_obs
		where IdMesa = @id_pedido AND Pagado = 0 and Eliminado = 0
 	END

GO
/****** Object:  StoredProcedure [dbo].[sp_agregar_pagos_almacenMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_agregar_pagos_almacenMovimiento]
@monto decimal(9,3),
@fecha datetime,
@almacenmovimientoid int,
@tipopagoseguimientoid int,
@userid int,
@descripcion varchar(250),
@id int,
@idCaja int,
@idApertura int
as
if @id = 0
begin
	insert into api_almacen_pagos (monto, fecha, almacen_movimiento_id, tipo_pago_seguimiento_id, user_id, descripcion, idCaja, idApertura)
	values (@monto, @fecha, @almacenmovimientoid, @tipopagoseguimientoid, @userid, @descripcion, @idCaja, @idApertura)

select SCOPE_IDENTITY() as 'id';
end
else
begin
update api_almacen_pagos set monto = @monto, fecha = @fecha, tipo_pago_seguimiento_id = @tipopagoseguimientoid, descripcion = @descripcion
where id = @id

select @id as 'id';
end
GO
/****** Object:  StoredProcedure [dbo].[sp_buscar_almacen_traslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
CREATE proc [dbo].[sp_buscar_almacen_traslado]
@buscar varchar(max)
as
select T.id, a.Nombre  as 'almacen_salida', a.Nombre as 'almacen_entrada', t.fecha , 
t.descripcion, t.cerrado, t.estado, t.idAlmacenSalida, t.idAlmacenEntrada from mst_almacen_traslado t
inner join mst_Almacen a on t.idAlmacenSalida = a.Id and t.idAlmacenEntrada = a.Id
where t.flag = 1 and a.Nombre like '%'+@buscar+'%'


























GO
/****** Object:  StoredProcedure [dbo].[sp_buscar_compra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_buscar_compra]
@buscar varchar(250),
@fecha_ini date,
@fecha_fin date
as
select 
c.Id ,
c.FechaEmision,
c.FechaIngreso,
a.Nombre [Almacén],
d.Descripcion[Documento],
CAST(c.Serie as varchar) + '-' + CAST(c.Numero as varchar) [Serie],
p.nombre[Proveedor],
c.Direccion,
fp.FormadePago,
c.FechaVence,
c.Subtotal,
c.TotalIgv,
c.Totaldescuento,
c.Total,
c.Estado,
c.ImportePagado
from mst_Compras c 
inner join mst_Almacen a on c.IdAlmacen = a.Id
inner join mst_documentos d on c.TipoDoc = d.Codigo
inner join mst_Proveedor p on c.IdProveedor = p.id
inner join mst_FormaPago fp on c.FormaPago = fp.Id
where (CONCAT(RazonSocial, ' ', DniRuc, ' ') like CONCAT('%', @buscar, '%') OR CONCAT(C.Serie, '-', c.Numero) like CONCAT('%', @buscar, '%')) 
and FechaEmision between @fecha_ini and @fecha_fin and c.Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[sp_delete_almacen_traslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------
CREATE proc [dbo].[sp_delete_almacen_traslado]
@id int
as
update mst_almacen_traslado set estado = 0, flag = 0
where id = @id



























GO
/****** Object:  StoredProcedure [dbo].[sp_descontar_deuda]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_descontar_deuda]
@id_venta int
as

update tbl_Seguimiento set validado = 1
where IdVenta = @id_venta

declare @monto money = (select SUM(Monto) from tbl_Seguimiento where IdVenta = @id_venta)


update mst_Venta set ImportePagado = @monto
where id = @id_venta

GO
/****** Object:  StoredProcedure [dbo].[sp_descontar_pago_almacenMovimiento_by_idPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_descontar_pago_almacenMovimiento_by_idPago]
@id int
as
update api_almacen_pagos set validado = 1
where id = @id

declare @idalmacenmovimiento int = (select top 1 almacen_movimiento_id from api_almacen_pagos where id = @id)

declare @monto money = (select SUM(Monto) from api_almacen_pagos where almacen_movimiento_id = @idalmacenmovimiento and validado = 1)

update mst_almacen_movimiento set importe_pagado = @monto
where id = @idalmacenmovimiento

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_almacen_movimiento_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_eliminar_almacen_movimiento_by_id]
@id int
as
UPDATE mst_almacen_movimiento SET estado = 0, flag = 0, total = 0, importe_pagado = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_almacen_movimiento_detalle_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_eliminar_almacen_movimiento_detalle_by_id]
@id int
as
update mst_almacen_movimiento_detalle set estado = 0, flag = 0
where id = @id

declare @idAlmacen int = (select a.idAlmacen from mst_almacen_movimiento_detalle d inner join mst_almacen_movimiento a on d.almacen_movimiento_id = a.id where d.id=@id)
declare @idProducto int = (select idProducto from mst_almacen_movimiento_detalle where id=@id)
declare @idAlmacenMovimiento int = (select top 1 almacen_movimiento_id from mst_almacen_movimiento_detalle where id=@id)
exec spStockActualizarSaldoItem @idAlmacen, @idProducto

GO
/****** Object:  StoredProcedure [dbo].[sp_eliminar_pagos_almacenMovimiento_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_eliminar_pagos_almacenMovimiento_by_id]
@id int
as
delete from api_almacen_pagos 
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_almacen]
as
select
id,
nombre,
estado,
flag
from mst_Almacen
where Estado = 1 and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_get_almacen_by_id]
@id int
as
select
id,
nombre,
estado,
flag
from mst_Almacen
where Estado = 1 and Flag = 1 and id = @id

GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen_movimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_almacen_movimiento]
@fecha_ini date,
@fecha_fin date
as
select
am.id 'id',
am.estado 'estado',
CONCAT(serie,'-', CAST(numero as varchar)) as 'serie',
numero as 'numero',
credito 'credito',
total 'total',
documento 'documento',
c.razonSocial 'cliente',
am.idCliente 'id_cliente',
am.direccion 'direccion',
am.fecha 'fecha',
am.referencia 'referencia',
IIF(am.ajuste = 0, iif(am.entrada = 1, 'Entrada', 'Salida'), 'Ajuste') 'tipo',
a.Nombre 'almacen',
am.idAlmacen 'id_almacen',
am.doc_facturado 'doc_factura',
am.cerrado 'cerrado',
am.entrada 'entrada',
am.salida 'salida',
am.ajuste 'ajuste',
IIF(am.importe_pagado = am.total, cast(0 as bit), cast(1 as bit)) 'status_deuda',
am.idvendedor 'id_vendedor',
u.usuario 'vendedor',
AM.clasificadorId,
am.importe_pagado
from mst_almacen_movimiento am
left join mst_Cliente c on am.idCliente = c.Id
inner join mst_almacen a on am.idAlmacen = a.Id
inner join mst_Usuarios u on am.idvendedor = u.Id
where CAST(am.fecha as date) between @fecha_ini and @fecha_fin
order by am.id desc
GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen_movimiento_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_almacen_movimiento_by_id]
@id int
as
select
am.id 'id',
am.estado 'estado',
CONCAT(serie,'-', CAST(numero as varchar)) as 'serie',
numero as 'numero',
credito 'credito',
total 'total',
documento 'documento',
c.razonSocial 'cliente',
am.idCliente 'id_cliente',
am.direccion 'direccion',
am.fecha 'fecha',
am.referencia 'referencia',
IIF(am.ajuste = 0, iif(am.entrada = 1, 'Entrada', 'Salida'), 'Ajuste') 'tipo',
a.Nombre 'almacen',
am.idAlmacen 'id_almacen',
am.doc_facturado 'doc_factura',
am.cerrado 'cerrado',
am.entrada 'entrada',
am.salida 'salida',
am.ajuste 'ajuste',
IIF((select SUM(monto) from api_almacen_pagos ap where ap.almacen_movimiento_id = am.id) = am.total, cast(0 as bit), cast(1 as bit)) 'status_deuda',
am.idvendedor 'id_vendedor',
u.usuario 'vendedor',
am.clasificadorId,
am.importe_pagado
from mst_almacen_movimiento am
left join mst_Cliente c on am.idCliente = c.Id
inner join mst_almacen a on am.idAlmacen = a.Id
inner join mst_Usuarios u on am.idvendedor = u.Id
where am.id = @id
GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen_movimiento_detalle_by_id_almacen_movimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_almacen_movimiento_detalle_by_id_almacen_movimiento]
@idalmacenmovimiento int
as
select
id 'id',
idProducto 'id_producto',
nombreProducto 'nombre_producto',
idUnidad 'id_unidad',
nombreUnidad 'nombre_unidad',
factor 'factor',
cantidad 'cantidad',
precio 'precio',
total 'total',
almacen_movimiento_id 'almacen_movimiento_id'
from mst_almacen_movimiento_detalle
where almacen_movimiento_id = @idalmacenmovimiento and estado = 1 and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[sp_get_almacen_movimientos_salidas_pagos_by_almacen_movimiento_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_almacen_movimientos_salidas_pagos_by_almacen_movimiento_id]
@id int
as
select
ap.id,
monto,
ap.fecha,
almacen_movimiento_id,
tipo_pago_seguimiento_id,
user_id,
tp.Descripcion 'tipo_pago_text',
u.usuario 'usuario_text'
from api_almacen_pagos ap
inner join tbl_TipoPago_Seguimiento tp on ap.tipo_pago_seguimiento_id = tp.Id
inner join mst_Usuarios u on ap.user_id = u.Id
where almacen_movimiento_id = @id

GO
/****** Object:  StoredProcedure [dbo].[sp_get_apertura_by_numero_usuario_caja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_apertura_by_numero_usuario_caja]
@numero_apertura int,
@id_usuario int,
@id_caja int
as
select * from mst_Apertura
where Numero = @numero_apertura and IdUsuario = @id_usuario and IdCaja =  @id_caja

GO
/****** Object:  StoredProcedure [dbo].[sp_get_apertura_data]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_apertura_data]
@idcaja int,
@idusuario int
as
select * from mst_apertura
where idcaja = @idcaja and IdUsuario = @idusuario and Abierto_Cerrado = 0
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_cliente]
as
select
c.id 'id',
idDocumento 'documento',
numeroDocumento 'num_documento',
razonSocial 'razon_social',
nombreComercial 'nombre_comercial',
cd.Direccion 'direccion',
telefono 'telefono',
correo 'correo',
c.estado 'estado',
c.flag 'flag',
c.delivery 'delivery'
from mst_Cliente c
left join mst_Cliente_Direccion cd on cd.idcliente = c.id
where c.estado = 1 and c.flag = 1 and cd.Principal = 1
order by c.id

GO
/****** Object:  StoredProcedure [dbo].[sp_get_cobranza_por_dia_usuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_cobranza_por_dia_usuario]
@idusuario int
as
select
CONCAT(v.SerieDoc, '-', v.NumeroDoc) 'Serie',
v.FechaEmision 'FechaEmision',
v.TotalVenta 'TotalVenta'
from tbl_Seguimiento s
inner join mst_Venta v on s.IdVenta = v.Id
where v.IdUsuarioPreventa = @idusuario and s.FechaPago = CAST(GETDATE() as date)

GO
/****** Object:  StoredProcedure [dbo].[sp_get_datos_backup]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_get_datos_backup]
as
select ruta_copia_bd from tabla_configuracion_general

GO
/****** Object:  StoredProcedure [dbo].[sp_get_DatosAnexoEmpresa]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_get_DatosAnexoEmpresa]
as
select CodigoAnexo from tabla_configuracion_general

GO
/****** Object:  StoredProcedure [dbo].[sp_get_dedudas_almacenMovimiento_acumulado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_get_dedudas_almacenMovimiento_acumulado]
as
select
idusuario,
usuario as usuario,
fecha,
sum(total) as total,
sum(totalpagado) as totalpagado,
sum(efectivo) as efectivo,
sum(cheque) as cheque,
sum(transferencia) as transferencia,
sum(deposito) as deposito
from (
select
idusuario,
usuario,
fecha,
total,
(isnull(efectivo, 0) + isnull(cheque, 0) + isnull(transferencia, 0) + isnull(deposito, 0)) as totalpagado,
isnull(efectivo, 0) as efectivo,
isnull(cheque, 0) as cheque,
isnull(transferencia, 0) as transferencia,
isnull(deposito, 0) as deposito
from (
select
idvendedor as idusuario,
u.nombre as usuario,
CAST(s.fecha as date) as 'fecha',
am.total total,
isnull(sum(s.monto), 0) importe_pagado,
ts.descripcion as 'tipo_pago'
from mst_almacen_movimiento am
left join api_almacen_pagos s on s.almacen_movimiento_id = am.id
left join tbl_tipopago_seguimiento ts on s.tipo_pago_seguimiento_id = ts.id
inner join mst_usuarios u on am.idvendedor = u.id
where s.validado = 0
group by idvendedor, u.nombre, ts.descripcion, CAST(s.fecha as date), am.total
) as deudas
pivot (
sum(importe_pagado)
for tipo_pago in ([efectivo], [cheque], [transferencia], [deposito])
) as pivote_final
) as final
group by idusuario, usuario, fecha

GO
/****** Object:  StoredProcedure [dbo].[sp_get_menu]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_menu]
as
select * from menu

GO
/****** Object:  StoredProcedure [dbo].[sp_get_precios_by_id_detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_precios_by_id_detalle]
@idalmacen int,
@iddetalle int 
as
select
id 'id',
C_Interno 'codigo',
Cod_Barra 'codigo_barra',
RTRIM(LTRIM(Descripcion)) 'descripcion',
U_Medida 'unidad_medida',
Factor 'factor', 
Proveedor 'proveedor',
Stock_Actual 'stock',
F_Vencimiento 'fecha_vencimiento',
Precio_Unit 'precio',
IdAlmacen 'idalmacen',
Id_Unidad 'idunidad',
checkStock,
PrincipalAlmacen,
'' 'imagen'
from vw_FiltroProductos
where C_Interno = @iddetalle and IdAlmacen = @idalmacen
order by C_Interno desc
GO
/****** Object:  StoredProcedure [dbo].[sp_get_productos_by_almacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_productos_by_almacen]
@idalmacen int,
@text VARCHAR(250),
@isPrincipal bit = 0
as
select top 10
id 'id',
C_Interno 'codigo',
Cod_Barra 'codigo_barra',
RTRIM(LTRIM(Descripcion)) 'descripcion',
U_Medida 'unidad_medida',
Factor 'factor',
Imagen 'imagen',
Proveedor 'proveedor',
Stock_Actual 'stock',
F_Vencimiento 'fecha_vencimiento',
Precio_Unit 'precio',
IdAlmacen 'idalmacen',
idUnidad 'idunidad',
checkStock
from vw_FiltroProductos
where IdAlmacen = @idalmacen
and (Descripcion like CONCAT('%', @text, '%') or Cod_Barra = @text or Codigo = @text)
--and PrincipalAlmacen = @isPrincipal
GO
/****** Object:  StoredProcedure [dbo].[sp_get_reporte_almacenMovimiento_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_reporte_almacenMovimiento_by_id]
@id int
as
select
am.id,
CASE am.serie
WHEN 'S' THEN 'NOTA DE SALIDA'
WHEN 'E' THEN 'NOTA DE ENTRADA'
WHEN 'A' THEN 'AJUSTE'
END DescripDoc,
am.documento,
cast(am.fecha as date) as fecha,
am.referencia,
am.entrada,
am.salida,
am.ajuste,
am.serie,
am.numero,
am.credito,
am.doc_facturado,
a.Nombre 'almacen',
c.numeroDocumento,
c.razonSocial 'cliente',
am.direccion,
u.usuario 'vendedor',
am.total,
amd.*
from mst_almacen_movimiento am
inner join mst_almacen_movimiento_detalle amd on amd.almacen_movimiento_id = am.id
inner join mst_Almacen a on am.idAlmacen = a.Id
inner join mst_Cliente c on am.idCliente = c.Id
inner join mst_Usuarios u on am.idvendedor = u.Id
WHERE amd.estado = 1 and amd.flag = 1 AND 
AM.id = @id
GO
/****** Object:  StoredProcedure [dbo].[sp_get_reporte_cobranza_almacenMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_get_reporte_cobranza_almacenMovimiento]
@fecha date
as
SELECT * FROM 
(
SELECT 
am.idvendedor as CodVen,
u.usuario as VENDEDOR,
s.fecha,
c.idDocumento as Doc,
(am.serie +'-'+CAST(am.numero as varchar)) as NumDoc,
am.total,
ISNULL(s.Monto,0) AS Monto,
ts.Descripcion as tipo_pago 
FROM mst_almacen_movimiento am
INNER JOIN api_almacen_pagos s ON am.id = s.almacen_movimiento_id
INNER JOIN tbl_TipoPago_Seguimiento ts ON ts.Id = s.tipo_pago_seguimiento_id
INNER JOIN mst_Usuarios u ON u.Id = am.idvendedor
inner join mst_Cliente c on am.idCliente = c.Id
WHERE CAST(s.fecha as date) = @fecha and s.validado = 0
) as cobranzas
pivot (
sum(Monto)
for tipo_pago in ([EFECTIVO], [CHEQUE], [TRANSFERENCIA], [DEPOSITO])) PivotTable

GO
/****** Object:  StoredProcedure [dbo].[sp_get_reporte_cobranza_vendedor_almacenMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_get_reporte_cobranza_vendedor_almacenMovimiento]
@fecha_ini date,
@fecha_fin date,
@id_vendedor int
as
SELECT * FROM 
(
SELECT am.idvendedor as CodVen,
u.usuario as VENDEDOR,
s.fecha,
am.idCliente as Doc,
(am.serie+'-'+CAST(am.numero as varchar)) as NumDoc,
am.total,
ISNULL(s.Monto,0) AS Monto,
ts.Descripcion as tipo_pago,
c.RazonSocial as cliente
FROM mst_almacen_movimiento am
inner join mst_Cliente c on am.idCliente = c.Id
INNER JOIN api_almacen_pagos s ON am.id = s.almacen_movimiento_id
INNER JOIN tbl_TipoPago_Seguimiento ts ON ts.Id = s.tipo_pago_seguimiento_id
INNER JOIN mst_Usuarios u ON u.Id = AM.idvendedor
WHERE CAST(s.fecha as date) between @fecha_ini and @fecha_fin and am.idvendedor = @id_vendedor
) as cobranzas
pivot (
sum(Monto)
for tipo_pago in ([EFECTIVO], [CHEQUE], [TRANSFERENCIA], [DEPOSITO])) PivotTable

GO
/****** Object:  StoredProcedure [dbo].[sp_get_reporte_movimiento_emitidos_almacenMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_reporte_movimiento_emitidos_almacenMovimiento]
@fecha date
as
SELECT c.idDocumento,
(am.serie+'-'+CAST(am.numero AS varchar)) as NumDoc, 
c.RazonSocial, 
CAST(am.fecha AS date) AS fecha, 
am.total,
u.nombre
FROM mst_almacen_movimiento am
inner join mst_Cliente c on am.idCliente = c.Id
INNER JOIN mst_Usuarios u ON u.Id = am.idvendedor
WHERE CAST(am.fecha AS date) =  @fecha

GO
/****** Object:  StoredProcedure [dbo].[sp_get_reserva_cierre_caja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_reserva_cierre_caja]
@id_caja int,
@id_usuario int,
@id_apertura int
as
select reserva from mst_Apertura 
where Numero= @id_apertura and IdUsuario = @id_usuario and IdCaja = @id_caja

GO
/****** Object:  StoredProcedure [dbo].[sp_get_status_pago_almacen_movimiento_by_almacen_movimiento_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_status_pago_almacen_movimiento_by_almacen_movimiento_id]
@id int
as
SELECT am.total, ISNULL(SUM(p.monto), 0) 'monto_pagado', IIF(am.total = ISNULL(SUM(p.monto), 0), cast(0 as bit), cast(1 as bit)) 'success' FROM mst_almacen_movimiento  am 
left join api_almacen_pagos p on p.almacen_movimiento_id = am.id
where am.salida = 1 and am.id = @id
group by am.total

GO
/****** Object:  StoredProcedure [dbo].[sp_get_stock_by_id_detalle_and_id_almacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_stock_by_id_detalle_and_id_almacen]
@idalmacen int,
@idproducto int
as
select
id,
IdAlmacen 'idalmacen',
IdProducto 'idproducto',
Entradas 'entradas',
Salidas 'salidas',
Saldo 'saldo'
from Stocks_Acumulados
where IdAlmacen = @idalmacen and IdProducto = @idproducto

GO
/****** Object:  StoredProcedure [dbo].[sp_get_sub_menu]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_sub_menu]
as
select * from sub_menu

GO
/****** Object:  StoredProcedure [dbo].[sp_get_tipo_pago_movimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_tipo_pago_movimiento]
as
select 
id 'id',
Descripcion 'descripcion'
from tbl_TipoPago_Seguimiento
where Estado = 1 and Flag = 1
order by id asc

GO
/****** Object:  StoredProcedure [dbo].[sp_get_vendedores]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_get_vendedores]
as
select
u.id,
nombre,
dni,
direccion,
telefono,
usuario,
correo,
foto,
is_cobrador
from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where tu.descripcion = 'vendedor' or tu.descripcion = 'ventas' and u.estado = 1 and u.flag = 1

GO
/****** Object:  StoredProcedure [dbo].[sp_get_ventas_tarjetas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC	[dbo].[sp_get_ventas_tarjetas]
@id_apertura int,
@id_caja int,
@id_usuario int
as
SELECT CAST(v.FechaEmision as Date) as Fecha,
v.IdDocumento,
(v.SerieDoc+'-'+cast(v.NumeroDoc as varchar(20))) as Doc,
v.TotalVenta,
(tp.visa+tp.mastercard) as tarjetas,
tp.Efectivo
FROM mst_venta v
INNER JOIN tabla_FormaPago tp
ON v.Id = tp.IdVenta
WHERE (tp.visa+tp.mastercard)>0 and v.IdApertura= @id_apertura and v.IdCaja = @id_caja and v.IdUsuario = @id_usuario
ORDER BY v.SerieDoc, v.NumeroDoc

GO
/****** Object:  StoredProcedure [dbo].[sp_getIcbAmount]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_getIcbAmount]
as
select dbo.getIcbAmount()

GO
/****** Object:  StoredProcedure [dbo].[sp_guardar_almacen_movimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_guardar_almacen_movimiento]
@documento varchar(250),
@fecha datetime,
@referencia varchar(250),
@entrada bit,
@ajuste bit,
@direccion varchar(250),
@credito bit,
@idalmacen int,
@idvendedor int,
@idproveedor int,
@idcliente int,
@id bigint,
@salida bit,
@clasificadorId int,
@idApertura int,
@idUsuario int,
@idCaja int 
as

if @id = 0
begin
declare @serie varchar(10), @numero int
if @ajuste = 1 BEGIN set @numero = (select top 1 numero from mst_almacen_movimiento where ajuste = 1 order by id desc) set @serie = 'A' END
else if @entrada = 1 BEGIN set @numero = (select top 1 numero from mst_almacen_movimiento where entrada = 1 order by id desc) SET	@serie = 'E'  END
else BEGIN set @numero = (select top 1 numero from mst_almacen_movimiento where salida = 1 order by id desc) SET @serie = 'S' END
--
SET @numero = ISNULL(@numero, 0)
set @numero = @numero + 1
insert into mst_almacen_movimiento 
(documento, fecha, referencia, entrada, ajuste,direccion,credito,idAlmacen, idCliente,
idvendedor,idProveedor, salida, serie, numero, clasificadorId, IdApertura, idUsuario, idCaja)
values(@documento, @fecha, @referencia, @entrada, @ajuste, @direccion, @credito,
@idalmacen, @idcliente, @idvendedor, @idproveedor, @salida, @serie, @numero, @clasificadorId, @idApertura, @idUsuario, @idCaja)
select SCOPE_IDENTITY() as 'id';
end
else
begin
declare @total decimal(9,3) = (select SUM(total) from mst_almacen_movimiento_detalle where almacen_movimiento_id = @id and estado = 1 and flag = 1)
declare @importePagado decimal(9,3)
if @credito = 0
BEGIN
	set @importePagado = @total
end


update mst_almacen_movimiento set documento = @documento, fecha = @fecha,
referencia = @referencia, entrada = @entrada, ajuste = @ajuste, direccion = @direccion,
credito = @credito, idAlmacen = @idalmacen, idCliente=@idcliente, idvendedor = @idvendedor,
idProveedor = @idproveedor, total = @total, salida = @salida, clasificadorId = @clasificadorId,
importe_pagado = @importePagado
where id = @id
select @id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[sp_guardar_almacen_movimiento_detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_guardar_almacen_movimiento_detalle]
@idproducto int,
@nombreproducto varchar(250),
@idunidad int,
@nombreunidad varchar(250),
@factor numeric(9,3),
@cantidad numeric(9,3),
@precio numeric(9,3),
@total numeric(9,3),
@almacenmovimientoid int,
@id int
as
if @id = 0
begin
insert into mst_almacen_movimiento_detalle
(idProducto, nombreProducto, idUnidad, nombreUnidad,
factor, cantidad, precio, total, almacen_movimiento_id)
values(
@idproducto, @nombreproducto, @idunidad, @nombreunidad,
@factor, @cantidad, @precio, @total, @almacenmovimientoid)
select SCOPE_IDENTITY() as 'id';
end

else
begin
update mst_almacen_movimiento_detalle set 
idProducto = @idproducto, nombreProducto = @nombreproducto,
idUnidad = @idunidad, nombreUnidad = @nombreunidad,
factor = @factor, cantidad = @cantidad, precio=@precio, 
total = @total
where id = @id
select @id as 'id';
end

GO
/****** Object:  StoredProcedure [dbo].[sp_guardar_estado_caja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_guardar_estado_caja]
@numero int,
@idusuario int,
@idcaja int,
@contado DECIMAL(18,3),
@credito DECIMAL(18,3),
@tarjetas DECIMAL(18,3),
@otros_ingresos DECIMAL(18,3),
@gastos DECIMAL(18,3),
@total_efectivo DECIMAL(18,3),
@total_egreso DECIMAL(18,3),
@efectivo_declarado DECIMAL(18,3),
@diferencia DECIMAL(18,3),
@reserva DECIMAL(18,3)
as
update mst_apertura set
Contado = @contado, Credito = @credito, tarjetas = @tarjetas, otros_ingresos = @otros_ingresos,
gastos = @gastos, total_efectivo = @total_efectivo, total_egreso = @total_egreso, efectivo_declarado = @efectivo_declarado,
diferencia = @diferencia, reserva = @reserva 
where  numero = @numero and IdUsuario = @idusuario and IdCaja = @idcaja
GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_cortesia_venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [dbo].[sp_insertar_cortesia_venta]
@idventa int,
@cortesia bit
as
update mst_Venta set cortesia = @cortesia
where id = @idventa




GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_count_pecho_pierna_text_observation_venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_insertar_count_pecho_pierna_text_observation_venta]
@idVenta int,
@countPecho int,
@countPierna int,
@textObservation varchar(250)
as
update mst_Venta set countPecho = @countPecho,
countPierna = @countPierna,
textObservation = @textObservation
where Id = @idVenta

GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_credenciales_api_sunat]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_insertar_credenciales_api_sunat]
@id_api_sunat varchar(100),
@clave_api_sunat varchar(100)
as
update tabla_configuracion_general set id_api_sunat = @id_api_sunat,
clave_api_sunat = @clave_api_sunat



GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_datos_backup]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_datos_backup]
@ruta varchar(250)
as
update tabla_configuracion_general set ruta_copia_bd = @ruta

GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_delivery_pedido_restaurant]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_insertar_delivery_pedido_restaurant]
@id_mesa int,
@delivery bit
as
update tabla_Pre_Venta set is_delivery = @delivery
where IdMesa = @id_mesa



GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_fecha_apertura_venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_fecha_apertura_venta]
@idventa int,
@fecha date
as
update mst_Venta set fecha_apertura = @fecha
where id = @idventa

GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_llevar_pedido_restaurant]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_insertar_llevar_pedido_restaurant]
@id_mesa int,
@llevar bit
as
update tabla_Pre_Venta set is_llevar = @llevar
where IdMesa = @id_mesa



GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_llevar_venta_restaurant]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_llevar_venta_restaurant]
@id_venta int,
@llevar bit
as
update mst_Venta set llevar = @llevar
where id = @id_venta



GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_monedas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_monedas]
@m010 decimal(9, 3),
@m020 decimal(9, 3),
@m050 decimal(9, 3),
@m1 decimal(9, 3),
@m2 decimal(9, 3),
@m5 decimal(9, 3),
@m10 decimal(9, 3),
@m20 decimal(9, 3),
@m50 decimal(9, 3),
@m100 decimal(9, 3),
@m200 decimal(9, 3),
@idapertura int,
@idcaja int,
@idusuario int
as
update mst_Apertura set m010 = @m010,
m020 = @m020,
m050 = @m050,
m1 = @m1,
m2 = @m2,
m5 = @m5,
m10 = @m10,
m20 = @m20,
m50 = @m50,
m100 = @m100,
m200 = @m200
where Numero = @idapertura and IdCaja = @idcaja and IdUsuario = @idusuario

GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_venta_delivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_venta_delivery]
@id int,
@id_venta int,
@id_contacto int
as
if @id = 0
	begin
		
		declare @apertura int = (select IdApertura from mst_Venta where id = @id_venta)
		declare @idusuario int = (select IdUsuario from mst_Venta where id = @id_venta)
		declare @idcaja int = (select IdCaja from mst_Venta where id = @id_venta)		
		 
		UPDATE mst_Venta SET delivery = 1
		where id = @id_venta 
		
		--declare @countDelivery int = (select count(id) from mst_Venta where IdApertura = @apertura and IdUsuario = @idusuario and IdCaja = @idcaja and delivery = 1)
		declare @countDelivery int = dbo.F_SecuenciaDelivery()

		if @countDelivery = null or @countDelivery = 0
		BEGIN
			set @countDelivery = 1
		END
		
		if @id_contacto = 0 begin set @id_contacto = 1 end
		
		
		insert into venta_delivery (id_venta, id_contacto, estado, flag, num_correlative)
		values(@id_venta, @id_contacto, 1,1, @countDelivery)
		
		declare @id_despues int = SCOPE_IDENTITY();
		select @id_despues as 'id'
	end
else
	begin
	 
	update venta_delivery set id_venta = @id_venta, id_contacto = @id_contacto
	where id = @id
	end
GO
/****** Object:  StoredProcedure [dbo].[sp_insertar_venta_llevar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_insertar_venta_llevar]
@id int,
@id_venta int,
@id_contacto int
as
if @id = 0
	begin
		
		declare @apertura int = (select IdApertura from mst_Venta where id = @id_venta)
		declare @idusuario int = (select IdUsuario from mst_Venta where id = @id_venta)
		declare @idcaja int = (select IdCaja from mst_Venta where id = @id_venta)		
		 
		UPDATE mst_Venta SET llevar = 1
		where id = @id_venta 

		--declare @fecha_actual date = getDate();		
		--declare @countDelivery int = (select count(id) from mst_Venta where Fecha = @fecha_actual and delivery = 1)
		declare @countDelivery int = dbo.F_SecuenciaLlevar()

		if @countDelivery = null or @countDelivery = 0
		BEGIN
			set @countDelivery = 1
		END
		
	 
		
		
		insert into venta_delivery (id_venta, id_contacto, estado, flag, num_correlative)
		values(@id_venta, 0, 1,1, @countDelivery)
		
		declare @id_despues int = SCOPE_IDENTITY();
		select @id_despues as 'id'
	end
else
	begin
	 
	update venta_delivery set id_venta = @id_venta, id_contacto = 0
	where id = @id
	end
GO
/****** Object:  StoredProcedure [dbo].[sp_modificar_cpe_verificado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_modificar_cpe_verificado]
@id_cpe int,
@cod_verf varchar(10),
@msj_verf varchar(250),
@obs varchar(250)
as
update tbl_info_cpe set status_verificado = 1, codigo_verificado = @cod_verf, mensaje_verificado = @msj_verf, observacion_verificado = @obs
where id_cab_cpe = @id_cpe

GO
/****** Object:  StoredProcedure [dbo].[sp_modificar_pago_defecto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_modificar_pago_defecto]
@pago_defecto char(2)
as
update tabla_configuracion_general set pago_defecto = @pago_defecto



GO
/****** Object:  StoredProcedure [dbo].[sp_modificar_pago_venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_modificar_pago_venta]
@tipo_pago int,
@idventa int
as
if(@tipo_pago = 1)
begin
	update mst_Venta set IdFormaPago = @tipo_pago, ImportePagado = TotalVenta
	WHERE id = @idventa
end
else
begin
update mst_Venta set IdFormaPago = @tipo_pago, ImportePagado = 0
WHERE id = @idventa
end



GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_aperturas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_aperturas]
@numero_apertura int,
@id_usuario int,
@caja int
as
if @numero_apertura <> 0
	begin
		select a.Id, Numero, IdUsuario, u.usuario, Fecha, Abierto_Cerrado as Cerrado, IdCaja, fechacierre, caja_chica, contado, credito, tarjetas, otros_ingresos, gastos, total_efectivo, total_egreso, efectivo_declarado, diferencia, reserva from mst_Apertura a
		inner join mst_Usuarios u on a.IdUsuario = u.Id
		where Numero = @numero_apertura and IdUsuario = @id_usuario and IdCaja = @caja
		order by Fecha desc
	end
else
	if(@id_usuario = 0)
		select a.Id, Numero, IdUsuario, u.usuario, Fecha, Abierto_Cerrado as Cerrado, IdCaja, fechacierre, caja_chica, contado, credito, tarjetas, otros_ingresos, gastos, total_efectivo, total_egreso, efectivo_declarado, diferencia, reserva from mst_Apertura a
		INNER join mst_Usuarios u on a.IdUsuario = u.Id
		order by Fecha desc
	else
		select a.Id, Numero, IdUsuario, u.usuario, Fecha, Abierto_Cerrado as Cerrado, IdCaja, fechacierre, caja_chica, contado, credito, tarjetas, otros_ingresos, gastos, total_efectivo, total_egreso, efectivo_declarado, diferencia, reserva from mst_Apertura a
		inner join mst_Usuarios u on a.IdUsuario = u.Id
		where IdUsuario = @id_usuario and IdCaja = @caja
		order by Fecha desc
GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_caja_chica]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_caja_chica]
@numero int,
@id_usuario int,
@idCaja int
as
SELECT caja_chica as total FROM mst_Apertura
where IdUsuario = @id_usuario and Numero = @numero and IdCaja = @idCaja

GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_credenciales_api_sunat]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_credenciales_api_sunat]
as
select id_api_sunat, clave_api_sunat from tabla_configuracion_general



GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_detalles_deuda_acumulada]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_mostrar_detalles_deuda_acumulada]
@id_usuario int,
@fecha date	
as
--detalle
select
v.id as id,
CONCAT(V.SerieDoc, '-' , CAST(v.NumeroDoc as varchar)) as factura,
v.RazonSocial AS 'cliente',
v.TotalVenta as 'total_deuda',
SUM(s.monto) as 'importe_pagado'
from mst_Venta v
inner join tbl_Seguimiento s on s.IdVenta = v.Id
inner join mst_Usuarios u on v.IdUsuario = u.Id
where s.validado = 0 and v.Anulado = 0  AND v.IdUsuarioPreventa = @id_usuario and FechaPago = @fecha
group by  v.SerieDoc, v.NumeroDoc, V.RazonSocial, v.TotalVenta, v.Id
GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_detalles_deuda_acumulada_almacenMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_detalles_deuda_acumulada_almacenMovimiento]
@idusuario int,
@fecha date
as
select
am.id as id,
CONCAT(am.serie, '-' , CAST(am.numero as varchar)) as 'serie',
c.RazonSocial AS 'cliente',
am.total as 'total_deuda',
SUM(s.monto) as 'importe_pagado'
from mst_almacen_movimiento am
inner join mst_Cliente c on am.idCliente = c.Id
left join api_almacen_pagos s on s.almacen_movimiento_id = am.id
inner join mst_Usuarios u on am.idvendedor = u.Id
where s.validado = 0 AND am.idvendedor = @idusuario and CAST(s.fecha as date) = @fecha
group by am.serie, am.numero, c.razonSocial, am.total, am.id

GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_detalles_mesa_delivery_llevar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_detalles_mesa_delivery_llevar]
@fecha_ini date,
@fecha_fin date,
@op varchar(10),
@id_grupo int
as
if @id_grupo = 0
	begin
		if @op = 'mesa'
				begin
					select pd.IdProducto, g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa > 0 and IdMesa < 500 and delivery = 0 and llevar = 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end

			else if @op = 'delivery'
				begin
					select pd.IdProducto, g.descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa >= 1000 and delivery = 1 and llevar = 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end
 
			 else if @op = 'llevar'
				begin
					select  pd.IdProducto, g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa >= 500 and IdMesa < 1000 and delivery = 0 and llevar = 1 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end
	
			else if @op = 'todos'
			begin
				select pd.IdProducto, g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa > 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
			end
	end
else
--si vienen grupos
	begin
				if @op = 'mesa'
				begin
					select pd.IdProducto,g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa > 0 and IdMesa < 500 and delivery = 0 and llevar = 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1 and p.idgrupo = @id_grupo
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end

			else if @op = 'delivery'
				begin
					select pd.IdProducto, g.descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa >= 1000 and delivery = 1 and llevar = 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1 and p.idgrupo = @id_grupo
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end
 
			 else if @op = 'llevar'
				begin
					select  pd.IdProducto, g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa >= 500 and IdMesa < 1000 and delivery = 0 and llevar = 1 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and p.idgrupo = @id_grupo
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
				end
	
			else if @op = 'todos'
			begin
				select pd.IdProducto, g.Descripcion as 'Grupo', p.nombreProducto as 'Producto', sum(vd.Cantidad) as 'Cantidad', sum(vd.Total) as 'Total' from mst_Venta_det vd
					inner join mst_Venta v on vd.IdVenta = v.Id
					inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
					inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
					inner join mst_Producto p on pd.idProducto = p.Id
					inner join mst_Grupo g on p.IdGrupo = g.Id
					where IdMesa > 0 and CAST(fecha_apertura as date) between @fecha_ini and @fecha_fin and v.Anulado = 0 and vd.Anulado = 0 and vd.Flag = 1 and p.idgrupo = @id_grupo
					group by pd.IdProducto, p.nombreProducto, g.Descripcion
					order by p.nombreProducto asc
			end
	end
GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_deudas_acumuladas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_deudas_acumuladas]
as
select
idusuario,
usuario as usuario,
fecha_pago,
sum(total) as total,
sum(total_pagado) as total_pagado,
sum(efectivo) as efectivo,
sum(cheque) as cheque,
sum(transferencia) as transferencia,
sum(deposito) as deposito
from (
select
idusuario,
usuario,
fecha_pago,
total,
(isnull(efectivo, 0) + isnull(cheque, 0) + isnull(transferencia, 0) + isnull(deposito, 0)) as total_pagado,
isnull(efectivo, 0) as efectivo,
isnull(cheque, 0) as cheque,
isnull(transferencia, 0) as transferencia,
isnull(deposito, 0) as deposito
from (
select
idusuariopreventa as idusuario,
u.nombre as usuario,
s.FechaPago as 'fecha_pago',
SUM(totalventa) total,
isnull(sum(s.monto), 0) importe_pagado,
ts.descripcion as 'tipo_pago'
from mst_venta v
inner join tbl_seguimiento s on s.idventa = v.id
inner join tbl_tipopago_seguimiento ts on s.idtipopago = ts.id
inner join mst_usuarios u on v.idusuariopreventa = u.id
inner join mst_formapago fp on v.idformapago = fp.id
where s.validado = 0 and v.anulado = 0 --and v.idformapago = 2 
group by idusuariopreventa, u.nombre, ts.descripcion, s.FechaPago
) as deudas
pivot (
sum(importe_pagado)
for tipo_pago in ([efectivo], [cheque], [transferencia], [deposito])
) as pivote_final
) as final
group by idusuario, usuario, fecha_pago
GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_pago_defecto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_pago_defecto]
as
select pago_defecto from tabla_configuracion_general



GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_sumatoria_mesa_delivery_llevar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_sumatoria_mesa_delivery_llevar]
@fecha_ini DATE,
@fecha_fin DATE
as


SELECT SUM(Amorrrr.Mesa) AS 'MesaT',SUM(Amorrrr.Delivery) AS 'DeliveryT',SUM(Amorrrr.Llevar) AS 'LlevarT' FROM (
SELECT SUM(TotalVenta) as 'Mesa',0.00 as 'Delivery',0.00 as 'Llevar' FROM mst_Venta
WHERE CAST(FechaEmision as date) BETWEEN @fecha_ini AND @fecha_fin
AND IdMesa > 0 and Anulado = 0 AND delivery = 0 and llevar = 0
UNION ALL
SELECT 0.00 as 'Mesa',SUM(TotalVenta) as 'Delivery',0.00 as 'Llevar' FROM mst_Venta
WHERE CAST(FechaEmision as date) BETWEEN @fecha_ini AND @fecha_fin
AND IdMesa > 0 and Anulado = 0 AND delivery = 1
UNION ALL
SELECT 0.00 as 'Mesa',0.00 as 'Delivery',SUM(TotalVenta) as 'Llevar' FROM mst_Venta
WHERE CAST(FechaEmision as date) BETWEEN @fecha_ini AND @fecha_fin
AND IdMesa > 0 and Anulado = 0 AND llevar = 1
) Amorrrr


GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_tabla_dinero_aperturas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_tabla_dinero_aperturas]
@idapertura int,
@idcaja int,
@idusuario int
as
SELECT m010, m020, m050, m1, m2,m5,m10,m20,m50, m100, m200 FROM mst_Apertura 
where Numero = @idapertura and IdCaja = @idcaja and IdUsuario = @idusuario

GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_tipos_documentos_cliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_mostrar_tipos_documentos_cliente]
@codigo int
as
if @codigo = 0
	begin
		select * from mst_TipoDocumento
		where codigoSunat = 0
	end
else
	begin
		select * from mst_TipoDocumento
		where codigoSunat = @codigo
	end



GO
/****** Object:  StoredProcedure [dbo].[sp_mostrar_venta_delivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_mostrar_venta_delivery]
@idventa int
as
if @idventa = 0
	begin
		select * from venta_delivery
		where estado = 1 and flag = 1
	end
else
	begin
	select * from venta_delivery
	where estado = 1 and flag = 1 and id_venta = @idventa
	end



GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_cierre_denominaciones_por_fecha]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_cierre_denominaciones_por_fecha]
@fecha_ini date,
@fecha_fin date
as
SELECT a.Fecha, 
SUM(a.caja_chica) as caja_chica,
SUM(a.contado) as contado,
SUM(a.credito) as credito,
SUM(a.tarjetas) as tarjetas,
SUM(a.otros_ingresos) as otros_ingresos,
SUM(a.gastos) as gastos,
SUM(a.total_efectivo) as total_efectivo,
SUM(a.total_egreso) as total_egreso,
SUM(a.efectivo_declarado) as efectivo_declarado,
SUM(a.diferencia) as diferencia,
SUM(a.m010) as m010,
SUM(a.m020) as m020,
SUM(a.m050) as m050,
SUM(a.m1) as m1,
SUM(a.m2) as m2,
SUM(a.m5) as m5,
SUM(a.m10) as m10,
SUM(a.m20) as m20,
SUM(a.m50) as m50,
SUM(a.m100) as m100,
SUM(a.m200) as m200,
SUM(a.m010*0.10) as tm010,
SUM(a.m020*0.20) as tm020,
SUM(a.m050*0.50) as tm050,
SUM(a.m1*1.00) as tm1,
SUM(a.m2*2.00) as tm2,
SUM(a.m5*5.00) as tm5,
SUM(a.m10*10.00) as tm10,
SUM(a.m20*20.00) as tm20,
SUM(a.m50*50.00) as tm50,
SUM(a.m100*100.00) as tm100,
SUM(a.m200*200.00) as tm200
FROM mst_Apertura a
INNER JOIN mst_Usuarios u
ON a.IdUsuario = u.Id
WHERE CAST(a.Fecha as date) between @fecha_ini and @fecha_fin 
group by A.Fecha

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_cierre_suma_denominaciones_por_usuairo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_cierre_suma_denominaciones_por_usuairo]
@fecha_ini date,
@fecha_fin date
as
select u.nombre, a.total_efectivo from mst_Apertura a
INNER JOIN mst_Usuarios u
ON a.IdUsuario = u.Id
WHERE CAST(Fecha as date) between @fecha_ini and @fecha_fin

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_cobranza]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_cobranza]
@fecha date
as
SELECT * FROM 
(
SELECT v.IdUsuarioPreventa as CodVen, u.usuario as VENDEDOR,s.FechaPago,
v.IdDocumento as Doc,
(v.SerieDoc+'-'+CAST(v.NumeroDoc as varchar)) as NumDoc,
v.TotalVenta,
ISNULL(s.Monto,0) AS Monto,
ts.Descripcion as tipo_pago 
FROM mst_Venta v
INNER JOIN tbl_Seguimiento s
ON v.Id = s.IdVenta
INNER JOIN tbl_TipoPago_Seguimiento ts
ON ts.Id = s.IdTipoPago
INNER JOIN mst_Usuarios u
ON u.Id = v.IdUsuarioPreventa
WHERE s.FechaPago  = @fecha 
) as cobranzas
pivot (
sum(Monto)
for tipo_pago in ([EFECTIVO], [CHEQUE], [TRANSFERENCIA], [DEPOSITO])) PivotTable
GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_cobranza_vendedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_cobranza_vendedor]
@fecha_ini date,
@fecha_fin date,
@id_vendedor int,
@id_usuario_cajero int
as

declare @tipo_usuario int = (select idtipoUsuario from mst_Usuarios where id = @id_vendedor)
--1,admin
--2,cajero
--3,vendedor


if @tipo_usuario <> 2
begin
	SELECT * FROM 
	(
	SELECT v.IdUsuarioPreventa as CodVen, u.usuario as VENDEDOR,s.FechaPago,
	v.IdDocumento as Doc,
	(v.SerieDoc+'-'+CAST(v.NumeroDoc as varchar)) as NumDoc,
	v.TotalVenta,
	ISNULL(s.Monto,0) AS Monto,
	ts.Descripcion as tipo_pago,
	v.RazonSocial as cliente
	FROM mst_Venta v
	INNER JOIN tbl_Seguimiento s
	ON v.Id = s.IdVenta
	INNER JOIN tbl_TipoPago_Seguimiento ts
	ON ts.Id = s.IdTipoPago
	INNER JOIN mst_Usuarios u
	ON u.Id = v.IdUsuarioPreventa
	WHERE s.FechaPago between @fecha_ini and @fecha_fin and v.IdUsuarioPreventa = @id_vendedor
	) as cobranzas
	pivot (
	sum(Monto)
	for tipo_pago in ([EFECTIVO], [CHEQUE], [TRANSFERENCIA], [DEPOSITO])) PivotTable
end
else
begin
	SELECT * FROM 
	(
	SELECT v.IdUsuarioPreventa as CodVen, u.usuario as VENDEDOR,s.FechaPago,
	v.IdDocumento as Doc,
	(v.SerieDoc+'-'+CAST(v.NumeroDoc as varchar)) as NumDoc,
	v.TotalVenta,
	ISNULL(s.Monto,0) AS Monto,
	ts.Descripcion as tipo_pago,
	v.RazonSocial as cliente
	FROM mst_Venta v
	INNER JOIN tbl_Seguimiento s
	ON v.Id = s.IdVenta
	INNER JOIN tbl_TipoPago_Seguimiento ts
	ON ts.Id = s.IdTipoPago
	INNER JOIN mst_Usuarios u
	ON u.Id = v.IdUsuarioPreventa
	WHERE s.FechaPago between @fecha_ini and @fecha_fin and s.idUsuario = @id_usuario_cajero
	) as cobranzas
	pivot (
	sum(Monto)
	for tipo_pago in ([EFECTIVO], [CHEQUE], [TRANSFERENCIA], [DEPOSITO])) PivotTable
end

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_comprobantes_emitidos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_comprobantes_emitidos]
@fecha date
as
SELECT v.IdDocumento,(v.SerieDoc+'-'+CAST(v.NumeroDoc AS varchar)) as NumDoc, v.RazonSocial, CAST(v.FechaEmision AS date) AS FechaEmision, v.TotalVenta,p.FormadePago,u.nombre
FROM mst_Venta v
INNER JOIN mst_FormaPago p
ON v.IdFormaPago = p.Id
INNER JOIN mst_Usuarios u
ON u.Id = v.IdUsuarioPreventa
WHERE CAST(v.FechaEmision AS date) =  @fecha
GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_delivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_delivery]
@id_venta int
as
select v_d.Id_contacto,
v_d.num_correlative,
c.razonSocial as Contacto,
d.Direccion,
v.Id,
v.IdDocumento,
v.SerieDoc,
v.NumeroDoc,
cast(v.FechaEmision as date) as FechaEmision,
v.SubTotal as Importe,
v.Otro_Imp,
v.TotalVenta,
v.Total_Letras,
v.Anulado,
vd.IdProducto,
vd.descripcion,
vd.Cantidad,
vd.SubTotal,
vd.Total,
vd.Anulado,
v_d.estado,
v_d.flag,
v.countPecho,
v.countPierna,
v.textObservation,
c.telefono,
g.Descripcion 'grupo'
from mst_Venta v
inner join mst_Venta_det vd on vd.IdVenta = v.Id
inner JOIN venta_delivery v_d on v_d.id_venta = v.Id
left join mst_Cliente c on v_d.id_contacto = c.id
left join mst_Cliente_Direccion d ON c.Id = d.IdCliente 
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
inner join mst_Grupo g on p.IdGrupo = g.Id
where (v.Anulado = 0 and vd.Anulado = 0) and v.Id = @id_venta
GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_denominaciones]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_reporte_denominaciones]
@id_apertura int,
@id_caja int,
@id_usuario int
as
SELECT a.Id,a.Numero,a.IdUsuario,u.nombre,a.Fecha,a.Abierto_Cerrado,a.IdCaja,a.fechacierre,a.caja_chica,
a.contado,a.credito,a.tarjetas,a.otros_ingresos,a.gastos,a.total_efectivo,a.total_egreso,a.efectivo_declarado,
a.diferencia,a.m010,a.m020,a.m050,a.m1,a.m2,a.m5,a.m10,a.m20,a.m50,a.m100,a.m200,
(a.m010*0.10) as tm010,
(a.m020*0.20) as tm020,
(a.m050*0.50) as tm050,
(a.m1*1.00) as tm1,
(a.m2*2.00) as tm2,
(a.m5*5.00) as tm5,
(a.m10*10.00) as tm10,
(a.m20*20.00) as tm20,
(a.m50*50.00) as tm50,
(a.m100*100.00) as tm100,
(a.m200*200.00) as tm200
FROM mst_Apertura a
INNER JOIN mst_Usuarios u
ON a.IdUsuario = u.Id
WHERE a.Numero = @id_apertura and a.IdCaja = @id_caja and a.IdUsuario = @id_usuario

GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_general_pagos_facturacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROC [dbo].[sp_reporte_general_pagos_facturacion]
@fecha_ini date,
@fecha_fin date,
@IdCliente int,
@IdVendedor int
as
if @IdCliente = 0
begin
IF @IdVendedor = 0
BEGIN
	--REPORTE GENERAL DE PAGOS FACTURACION
	SELECT c.numeroDocumento,c.razonSocial,v.idDocumento,v.SerieDoc,v.NumeroDoc,CAST(v.FechaEmision AS Date) as FechaEmision,
	v.TotalVenta,ISNULL(s.IdTipoPago,' ') as IdTipoPago,ISNULL(ts.Descripcion,' ') as TipoPago,
	ISNULL(s.descripcion,' ') AS descripcion,ISNULL(s.monto,0.00) AS monto,ISNULL(s.FechaPago,' ') AS FechaPago,u.nombre,v.IdUsuarioPreventa as IdVendedor,
	n.nombre as nacionalidad
	FROM mst_Venta v
	INNER JOIN mst_Cliente c
	ON v.IdCliente = c.Id
	LEFT JOIN tbl_Seguimiento s
	ON v.Id = s.IdVenta
	LEFT JOIN tbl_TipoPago_Seguimiento ts
	ON ts.Id = s.IdTipoPago
	INNER JOIN mst_Usuarios u
	ON u.Id = v.IdUsuarioPreventa
	INNER JOIN nacionalidad n
	ON n.Id = c.nacionalidad
	WHERE v.IdFormaPago = 2 AND v.Anulado = 0 AND
	(c.estado = 1 and c.flag = 1) AND
	CAST(v.FechaEmision AS Date) BETWEEN @fecha_ini AND @fecha_fin
	ORDER BY c.razonSocial,v.SerieDoc,v.NumeroDoc
END

ELSE
	BEGIN
		--REPORTE GENERAL DE PAGOS FACTURACION
		SELECT c.numeroDocumento,c.razonSocial,v.idDocumento,v.SerieDoc,v.NumeroDoc,CAST(v.FechaEmision AS Date) as FechaEmision,
		v.TotalVenta,ISNULL(s.IdTipoPago,' ') as IdTipoPago,ISNULL(ts.Descripcion,' ') as TipoPago,
		ISNULL(s.descripcion,' ') AS descripcion,ISNULL(s.monto,0.00) AS monto,ISNULL(s.FechaPago,' ') AS FechaPago,u.nombre,v.IdUsuarioPreventa as IdVendedor,
		n.nombre as nacionalidad
		FROM mst_Venta v
		INNER JOIN mst_Cliente c
		ON v.IdCliente = c.Id
		LEFT JOIN tbl_Seguimiento s
		ON v.Id = s.IdVenta
		LEFT JOIN tbl_TipoPago_Seguimiento ts
		ON ts.Id = s.IdTipoPago
		INNER JOIN mst_Usuarios u
		ON u.Id = v.IdUsuarioPreventa
		INNER JOIN nacionalidad n
		ON n.Id = c.nacionalidad
		WHERE v.IdFormaPago = 2 AND v.Anulado = 0 AND
		(c.estado = 1 and c.flag = 1) AND
		CAST(v.FechaEmision AS Date) BETWEEN @fecha_ini AND @fecha_fin AND v.IdUsuarioPreventa = @IdVendedor
		ORDER BY c.razonSocial,v.SerieDoc,v.NumeroDoc
	END
End
else
begin
--REPORTE GENERAL DE PAGOS FACTURACION - AGREGADO JPUGA
SELECT c.numeroDocumento,c.razonSocial,v.idDocumento,v.SerieDoc,v.NumeroDoc,CAST(v.FechaEmision AS Date) as FechaEmision,
v.TotalVenta,ISNULL(s.IdTipoPago,' ') as IdTipoPago,ISNULL(ts.Descripcion,' ') as TipoPago,
ISNULL(s.descripcion,' ') AS descripcion,ISNULL(s.monto,0.00) AS monto,ISNULL(s.FechaPago,' ') AS FechaPago,u.nombre,v.IdUsuarioPreventa as IdVendedor,
n.nombre as nacionalidad
FROM mst_Venta v
INNER JOIN mst_Cliente c
ON v.IdCliente = c.Id
LEFT JOIN tbl_Seguimiento s
ON v.Id = s.IdVenta
LEFT JOIN tbl_TipoPago_Seguimiento ts
ON ts.Id = s.IdTipoPago
INNER JOIN mst_Usuarios u
ON u.Id = v.IdUsuarioPreventa
INNER JOIN nacionalidad n
ON n.Id = c.nacionalidad
WHERE v.IdFormaPago = 2 AND v.Anulado = 0 AND
(c.estado = 1 and c.flag = 1) AND c.Id = @IdCliente AND v.TotalVenta <> v.ImportePagado --AND ISNULL(s.monto,0.00)=0
ORDER BY c.razonSocial,v.SerieDoc,v.NumeroDoc
end
GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_general_pagos_notas_salidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_reporte_general_pagos_notas_salidas]
@fecha_ini date,
@fecha_fin date,
@IdCliente int
as
if @IdCliente = 0
begin
--REPORTE GENERAL DE PAGOS NOTAS DE SALIDAS
SELECT v.Id, c.numeroDocumento,c.razonSocial,'NS' as 'Documento',v.Serie,v.Numero,CAST(v.Fecha AS Date) as FechaEmision,
v.Total,ISNULL(s.tipo_pago_seguimiento_id,'') as IdTipoPago,ISNULL(ts.Descripcion,'') as TipoPago,
ISNULL(s.descripcion,'') AS descripcion,ISNULL(s.monto,0.00) AS monto,ISNULL(cast(s.Fecha as date),'') AS FechaPago 
FROM mst_almacen_movimiento v
INNER JOIN mst_Cliente c ON v.IdCliente = c.Id
LEFT JOIN api_almacen_pagos s ON v.Id = s.almacen_movimiento_id
LEFT JOIN tbl_TipoPago_Seguimiento ts ON ts.Id = s.tipo_pago_seguimiento_id
WHERE v.salida = 1 and (v.estado = 1 and v.flag = 1)
AND (c.estado = 1 and c.flag = 1) AND 
CAST(v.Fecha AS Date) BETWEEN @fecha_ini AND @fecha_fin
ORDER BY c.razonSocial,v.Serie,v.Numero
end
else
begin
SELECT v.Id, c.numeroDocumento,c.razonSocial,'NS' as 'Documento',v.Serie,v.Numero,CAST(v.Fecha AS Date) as FechaEmision,
v.Total,ISNULL(s.tipo_pago_seguimiento_id,'') as IdTipoPago,ISNULL(ts.Descripcion,'') as TipoPago,
ISNULL(s.descripcion,'') AS descripcion,ISNULL(s.monto,0.00) AS monto,ISNULL(cast(s.Fecha as date),'') AS FechaPago 
FROM mst_almacen_movimiento v
INNER JOIN mst_Cliente c ON v.IdCliente = c.Id
LEFT JOIN api_almacen_pagos s ON v.Id = s.almacen_movimiento_id
LEFT JOIN tbl_TipoPago_Seguimiento ts ON ts.Id = s.tipo_pago_seguimiento_id
WHERE v.salida = 1 and (v.estado = 1 and v.flag = 1)
AND (c.estado = 1 and c.flag = 1) AND c.Id = @IdCliente AND ISNULL(s.monto,0.00)=0
ORDER BY c.razonSocial,v.Serie,v.Numero
end
GO
/****** Object:  StoredProcedure [dbo].[sp_reporte_ticket_restaurant]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_reporte_ticket_restaurant]
@id int,
@idpiso int
as

select * from
(
select temp.*,
g.Descripcion as [Grupo],
g.id as [IdGrupo],
iif(temp.IdMesa >= 500,'Para Llevar N° ' + cast(temp.numsecuencia as varchar),'Mesa N° '+ ' ' + cast(temp.IdMesa as varchar)) as 'Mesa',
us.nombre as 'Mozo',
cast(temp.Descripcion as varchar) + ' ('+g.Descripcion+')' as 'Descripcion_Grupo'
from tabla_Pre_Venta_Detalle_Temp temp
inner join mst_ProductoPresentacion pp on temp.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
inner join mst_Grupo g on p.IdGrupo = g.Id
inner join mst_Usuarios us on temp.IdUsuario = us.Id
where temp.IdPiso = @idpiso and IdMesa = @id
and temp.Pagado = 0
and temp.Eliminado = 0
) as temporal


GO
/****** Object:  StoredProcedure [dbo].[sp_ReporteTopSecret]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_ReporteTopSecret]
@idpiso int,
@idapertura int
as
IF(@IDPISO = 0)
BEGIN
SELECT CONSULTA.DESCRIPCION AS DESCRIPCION,SUM(CONSULTA.CANTIDAD)AS CANTIDAD,SUM(CONSULTA.PRECIO) AS PRECIO,SUM(CONSULTA.TOTAL)AS TOTAL,CONSULTA.PISO AS PISO,CONSULTA.APERTURA AS APERTURA
FROM
(
SELECT 
b.Descripcion AS DESCRIPCION,
--a.Total,
b.Cantidad AS CANTIDAD,
b.Precio AS PRECIO,
b.total AS TOTAL,
'Todos' as PISO,
A.IDAPERTURA AS APERTURA
FROM tabla_venta_det_ext b
INNER JOIN TABLA_VENTA_EXT A ON B.IDVENTA = A.IDVENTA
--GROUP BY B.DESCRIPCION,B.CANTIDAD,B.PRECIO,B.TOTAL,A.IDAPERTURA
UNION ALL
SELECT
B.DESCRIPCION AS DESCRIPCION,
B.CANTIDAD AS CANTIDAD,
B.PRECIOUNIT AS PRECIO,
B.TOTAL TOTAL,
'Todos' As PISO,
A.IDAPERTURA AS APERTURA
FROM MST_VENTA_DET B
INNER JOIN MST_VENTA A ON B.IDVENTA = A.ID
WHERE B.Anulado = 0 AND B.Flag = 1
--GROUP BY B.DESCRIPCION,B.CANTIDAD,B.PRECIOUNIT,B.TOTAL,A.IDAPERTURA
) AS CONSULTA
WHERE CONSULTA.APERTURA = @IDAPERTURA
GROUP BY CONSULTA.DESCRIPCION,CONSULTA.PISO,CONSULTA.APERTURA
END

ELSE

BEGIN
SELECT CONSULTA.DESCRIPCION AS DESCRIPCION,SUM(CONSULTA.CANTIDAD)AS CANTIDAD,SUM(CONSULTA.PRECIO) AS PRECIO,SUM(CONSULTA.TOTAL)AS TOTAL,CONSULTA.PISO AS PISO, CONSULTA.APERTURA AS APERTURA
FROM
(
SELECT 
b.Descripcion AS DESCRIPCION,
--a.Total,
b.Cantidad AS CANTIDAD,
b.Precio AS PRECIO,
b.total AS TOTAL,
A.IDPISO as PISO,
A.IDAPERTURA AS APERTURA
FROM tabla_venta_det_ext b
INNER JOIN TABLA_VENTA_EXT A ON B.IDVENTA = A.IDVENTA
--GROUP BY B.DESCRIPCION,B.CANTIDAD,B.PRECIO,B.TOTAL,A.IDPISO,A.IDAPERTURA
UNION ALL
SELECT
B.DESCRIPCION AS DESCRIPCION,
B.CANTIDAD AS CANTIDAD,
B.PRECIOUNIT AS PRECIO,
B.TOTAL TOTAL,
A.IDPISO As PISO,
A.IDAPERTURA AS APERTURA
FROM MST_VENTA_DET B
INNER JOIN MST_VENTA A ON B.IDVENTA = A.ID
WHERE B.Anulado = 0 AND B.Flag = 1
--GROUP BY B.DESCRIPCION,B.CANTIDAD,B.PRECIOUNIT,B.TOTAL,A.IDPISO,A.IDAPERTURA
) AS CONSULTA
WHERE CONSULTA.PISO = @IDPISO AND CONSULTA.APERTURA = @IDAPERTURA
GROUP BY CONSULTA.DESCRIPCION,CONSULTA.PISO,CONSULTA.APERTURA
END























































GO
/****** Object:  StoredProcedure [dbo].[sp_serarch_client_addres_by_id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_serarch_client_addres_by_id]
@idcliente int
as
select * from mst_Cliente_Direccion
where IdCliente = @idcliente and Principal = 1



GO
/****** Object:  StoredProcedure [dbo].[sp_serarch_client_delivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_serarch_client_delivery]
@buscar varchar(200)
as
select
c.id,
c.numeroDocumento,
c.razonSocial,
cd.Direccion,
c.telefono,
c.idDocumento,
cd.Principal,
cd.Referencia
from mst_Cliente c
inner join mst_Cliente_Direccion cd on cd.IdCliente = c.Id
where (c.estado = 1 and c.flag = 1)  and ( c.numeroDocumento = @buscar or (cd.Direccion+' ' + c.razonSocial like '%'+@buscar+'%') or (c.razonSocial + ' '+ cd.Direccion like '%'+@buscar+'%') or (c.telefono like '%'+@buscar+'%') or (cd.Referencia like '%'+@buscar+'%')) and c.delivery = 1
GO
/****** Object:  StoredProcedure [dbo].[sp_validar_contrasenia_admin]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_validar_contrasenia_admin]
@pass varchar(250)
as
select * from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where pass = @pass and tu.descripcion = 'admin' or tu.descripcion = 'administrador'

GO
/****** Object:  StoredProcedure [dbo].[sp_validar_pago_almacenMovimiento_by_idMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_validar_pago_almacenMovimiento_by_idMovimiento]
@id int
as
update api_almacen_pagos set validado = 1
where almacen_movimiento_id = @id

declare @monto money = (select SUM(Monto) from api_almacen_pagos where almacen_movimiento_id = @id and validado = 1)
update mst_almacen_movimiento set importe_pagado = @monto
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[spActualizarFechaVentaManual]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spActualizarFechaVentaManual]
@id int,
@fecha datetime
as
update mst_Venta set FechaEmision = @fecha
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spActualizarTotales]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spActualizarTotales]
@id int,
@pm bit,
@idpiso int,
@esconvenio bit
as
exec spIngresarOtrosImpuestos_Preventa @id, @pm,@esconvenio

declare @subtotal money
declare @descuento money 
declare @igv money
declare @icbper money
declare @adicional money
if(@pm = 0)
begin
	if(@esconvenio = 0)
		begin
			set @subtotal  =  (select SUM(Subtotal) from tabla_Pre_Venta_Detalle  where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @descuento  =  (select SUM(Descuento) from tabla_Pre_Venta_Detalle where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @igv  = (select sum(igv) from tabla_Pre_Venta_Detalle  where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @icbper  = (select sum(Otro_Imp) from tabla_Pre_Venta  where IdPedido = @id and Pagado = 0 and Eliminado = 0)

			update tabla_Pre_Venta set sub_total = @subtotal,
			Descuento = @descuento,
			igv = @igv,
			total = ROUND(((@subtotal + @igv) - @descuento) + @icbper,2)
			where IdPedido = @id
		end
	else
		begin
			set @subtotal  =  (select SUM(ISNULL(Subtotal, 0)) from tabla_Pre_Venta_Detalle_Convenio  where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @descuento  =  (select SUM(ISNULL(Descuento, 0)) from tabla_Pre_Venta_Detalle_Convenio where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @igv  = (select sum(ISNULL(igv, 0)) from tabla_Pre_Venta_Detalle_Convenio  where IdPedido = @id and Pagado = 0 and Eliminado = 0)
			set @icbper  = (select sum(ISNULL(Otro_Imp, 0)) from tabla_Pre_Venta_Convenio  where Id = @id and Pagado = 0 and Eliminado = 0)
			print '-------'
			print @subtotal
			print @igv
			print @descuento
			print @icbper
			print '-------'
			print ROUND(((@subtotal + @igv) - @descuento) + @icbper,2)

			update tabla_Pre_Venta_Convenio set sub_total = @subtotal,
			Descuento = @descuento,
			igv = @igv,
			total = ROUND(((@subtotal + @igv) - @descuento) + @icbper,2)			
			where Id = @id				 
		end
end
else if(@pm = 1)
begin
set @subtotal  =  (select SUM(Subtotal) from tabla_Pre_Venta_Detalle  where IdMesa = @id and IdPiso = @idpiso and Pagado = 0 and Eliminado = 0)
set @descuento  =  (select SUM(Descuento) from tabla_Pre_Venta_Detalle where IdMesa = @id and IdPiso = @idpiso and Pagado = 0 and Eliminado = 0)
set @igv  = (select sum(igv) from tabla_Pre_Venta_Detalle  where IdMesa = @id and IdPiso = @idpiso  and Pagado = 0 and Eliminado = 0)
set @icbper  = (select sum(Otro_Imp) from tabla_Pre_Venta  where IdMesa = @id and IdPiso = @idpiso  and Pagado = 0 and Eliminado = 0)

set @subtotal = (@subtotal + 0)

update tabla_Pre_Venta set sub_total = @subtotal,
Descuento = @descuento,
igv = @igv,
total = ROUND(((@subtotal + @igv)-@descuento) + @icbper,2)
where IdMesa = @id and IdPiso = @idpiso
end
GO
/****** Object:  StoredProcedure [dbo].[spActualizarTotales_Compra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spActualizarTotales_Compra]
@id int
as
declare @subtotal money =  (select SUM(Subtotal) from mst_ComprasDetalles  where IdCompra = @id and Flag  = 1)
declare @descuento money =  (select SUM(Descuento) from mst_ComprasDetalles where IdCompra = @id and Flag = 1)
declare @igv money = 0

--update mst_Compras set Subtotal = @subtotal,
--Totaldescuento = @descuento,
--TotalIgv = @igv,
--total = ROUND((@subtotal + @igv) - @descuento,2)
--where Id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spActualizarTotales_Venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spActualizarTotales_Venta]
@id int
as

EXEC spIngresarOtrosImpuestos_Venta @id


declare @total money
declare @igv money = (select SUM(igv) from mst_Venta_det  where IdVenta = @id and Anulado = 0)
declare @subtotal money =  (select SUM(Subtotal) from mst_Venta_det  where IdVenta = @id and Anulado = 0)
declare @descuento money =  (select SUM(Descuento) from mst_Venta_det where IdVenta = @id and Anulado = 0)
declare @formapago int = ((select IdFormaPago from mst_Venta where Id = @id and Anulado = 0))
declare @tipomoneda varchar(10) = (select TipoMoneda from mst_Venta where id = @id)
DECLARE	@icbper money = (select SUM(Otro_Imp) from mst_Venta where Id = @id and Anulado = 0)
if(@tipomoneda = 'PEN')
	BEGIN
	SET @tipomoneda = 'SOLES'
	END
ELSE 
	BEGIN
	SET @tipomoneda = 'DOLARES'
	END
declare @totalletras varchar(max) = (select dbo.fn_ConvertirNumeroLetra( ROUND(( (@subtotal + @igv) -@descuento) + @icbper, 2),@tipomoneda))
set @total = ROUND(((@subtotal + @igv) -@descuento) + @icbper,2)
if(@formapago = 1)
begin
update mst_Venta set TotalVenta = ROUND(((@subtotal + @igv) -@descuento) + @icbper,2),
SubTotal = @subtotal,
Descuento = @descuento,
Igv = @igv,
ImportePagado = (((@subtotal + @igv) -@descuento) + @icbper),
Total_Letras = @totalletras
where Id = @id
----------
end
----------
else
begin
update mst_Venta set TotalVenta = ROUND(((@subtotal + @igv) -@descuento) + @icbper,2),
SubTotal = @subtotal,
Descuento = @descuento,
Igv = @igv ,
ImportePagado = 0,
Total_Letras = @totalletras
where Id = @id
end
-----
update tabla_Venta_Ext set
Total = @total
where IdVenta = @id


--nuevos campos, todo va estar igual solo para el envio se hace esto

















































GO
/****** Object:  StoredProcedure [dbo].[spActualizarTotalesProforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spActualizarTotalesProforma]
@id int
as
declare @subtotal money,@descuento money,@igv money
set @subtotal  =  (select SUM(Subtotal) from tabla_Proforma_Detalle  where IdProforma = @id and Pagado = 0 and Eliminado = 0)
set @descuento  =  (select SUM(Descuento) from tabla_Proforma_Detalle where IdProforma = @id and Pagado = 0 and Eliminado = 0)
set @igv  = (select sum(igv) from tabla_Proforma_Detalle  where IdProforma = @id and Pagado = 0 and Eliminado = 0)

update tabla_Proforma set sub_total = @subtotal,
Descuento = @descuento,
igv = @igv,
total = ROUND(((@subtotal + @igv)-@descuento), 2)
where Id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spAddAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAddAlmacen]
@id int,
@nombre varchar(250),
@ususarioCrea varchar(50),
@usuarioModifica varchar(50)
as
if @id = 0
begin
	insert into almacen (nombre, usuarioCrea)
	values(@nombre, @ususarioCrea)
	select CAST(SCOPE_IDENTITY() as int)
end
else
begin
	update almacen set nombre = @nombre, usuarioModifica = @usuarioModifica
	where id = @id
	select CAST(@id as int)
end

GO
/****** Object:  StoredProcedure [dbo].[SpAddAlmacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddAlmacenTraslado]
@id int,
@idalmacensalida int,
@idalmacenentrada int,
@fecha datetime,
@descripcion varchar(max),
@cerrado bit,
@estado bit ,
@serie varchar(max) = 'T',
@numero int,
@total decimal(8,2)
as
if @id = 0
	begin
	insert into mst_almacen_traslado (idAlmacenSalida, idAlmacenEntrada, fecha, descripcion, cerrado, serie, numero, total)
	values(@idalmacensalida, @idalmacenentrada, @fecha,@descripcion,@cerrado, @serie, @numero, @total)
	select CAST(SCOPE_IDENTITY() as int) as id;
	end

else
	begin
	update mst_almacen_traslado set idAlmacenSalida = @idalmacensalida, idAlmacenEntrada = @idalmacenentrada, fecha = @fecha, descripcion = @descripcion, cerrado = @cerrado,
	total = @total
	where id = @id
	select CAST(@id as int) as id;
	end
GO
/****** Object:  StoredProcedure [dbo].[SpAddAlmacenTrasladoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddAlmacenTrasladoDetalle]
@id int,
@idProducto int,
@nombreProducto varchar(250),
@idUnidad int,
@nombreUnidad varchar(250),
@factor numeric(9,3),
@cantidad numeric(9,3),
@almacenTrasladoId int,
@precio numeric(9,3),
@total numeric(9,3)
as
if @id = 0
	begin
		insert into mst_almacen_traslado_detalle (idProducto, nombreProducto, idUnidad, nombreUnidad, factor, cantidad, almacen_traslado_id, precio, total, estado, flag)
		values(@idProducto, @nombreProducto, @idUnidad, @nombreUnidad, @factor, @cantidad, @almacenTrasladoId, @precio, @total, 1, 1)
		select CAST(SCOPE_IDENTITY() as int);
	end

else
	begin
		update mst_almacen_traslado_detalle set @idProducto = @idProducto, idUnidad = @idUnidad, nombreUnidad = @nombreUnidad, factor = @factor, cantidad = @cantidad,
		almacen_traslado_id = @almacenTrasladoId, precio = @precio, total = @total
		where id = @id
		select CAST(@id as int);
	end
GO
/****** Object:  StoredProcedure [dbo].[SpAddClienteDireccion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpAddClienteDireccion]
@id int,
@idCliente int,
@direccion varchar(max),
@principal bit,
@referencia text
as
if @id = 0
begin
	insert into mst_Cliente_Direccion (IdCliente, Direccion, Estado, Flag, Principal, Referencia)
	values (@idCliente, @direccion, 1,1,@principal, @referencia)
	select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
	update mst_Cliente_Direccion set IdCliente = @idCliente, Direccion = @direccion,
	Principal = @principal, Referencia = @referencia
	where Id = @id
	select @id as 'id'
end

GO
/****** Object:  StoredProcedure [dbo].[SpAddCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddCompra]
@Id int,
@FechaEmision date,
@FechaIngreso datetime, 
@IdAlmacen int,
@TipoDoc char(2),
@Serie char(4),
@Numero char(8),
@IdProveedor int,
@FormaPago int,
@FechaVence date,
@Observacion text,
@Direccion varchar(100),
@Subtotal money,
@TotalIgv money,
@TotalDescuento money,
@Total money,
@ImportePagado money,
@UsuarioCrea varchar(50),
@FechaCrea datetime,
@UsuarioModifica varchar(50),
@FechaModifica datetime,
@Estado bit,
@Flag bit,
@CodigoTipoDoc int,
@DniRuc varchar(20),
@RazonSocial varchar(100),
@Email varchar(100),
@PorcIgv money,
@Telefono VARCHAR(20)
as
if @Id = 0
begin
	insert into mst_Compras (FechaEmision, FechaIngreso, IdAlmacen, TipoDoc, Serie, Numero, IdProveedor,
	FormaPago, FechaVence, Observacion, Direccion, Subtotal, TotalIgv, Totaldescuento, Total,
	ImportePagado, UsuarioCrea, FechaCrea, UsuarioModifica, FechaModifica, Estado, Flag, CodigoTipoDoc,
	DniRuc, RazonSocial, Email, Porc_Igv, Telefono)
	values(@FechaEmision, @FechaIngreso, @IdAlmacen, @TipoDoc, @Serie, @Numero, @IdProveedor,
	@FormaPago, @FechaVence, @Observacion, @Direccion, @Subtotal, @TotalIgv, @TotalDescuento, @Total,
	@ImportePagado, @UsuarioCrea, @FechaCrea, @UsuarioModifica, @FechaModifica, @Estado, @Flag, @CodigoTipoDoc,
	@DniRuc, @RazonSocial, @Email, @PorcIgv, @Telefono)
	select CAST(SCOPE_IDENTITY() as int) id
end
else
begin
update mst_Compras set FechaEmision = @FechaEmision, FechaIngreso = @FechaIngreso, IdAlmacen = @IdAlmacen,
TipoDoc = @TipoDoc, Serie = @Serie, Numero = @Numero, IdProveedor = @IdProveedor, FormaPago = @FormaPago,
FechaVence = @FechaVence, Observacion = @Observacion, Direccion= @Direccion, Subtotal = @Subtotal, TotalIgv = @TotalIgv,
Totaldescuento = @TotalDescuento, Total = @Total, ImportePagado = @ImportePagado, UsuarioCrea = @UsuarioCrea,
FechaCrea = @FechaCrea, UsuarioModifica = @UsuarioModifica, FechaModifica = @FechaModifica, Estado = @Estado, Flag = @Flag,
CodigoTipoDoc = @CodigoTipoDoc, DniRuc = @DniRuc, RazonSocial = @RazonSocial, Email = @Email, Porc_Igv = @PorcIgv,
Telefono = @Telefono
where id = @Id
select @id id
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddComprasDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddComprasDetalles]
@Id int,
@IdProducto int,
@Descripcion varchar(100),
@IdUnidad int,
@Cantidad int,
@Precio money,
@Subtotal money,
@Igv money,
@Descuento money,
@Total money,
@Usuariocrea varchar(50),
@IdCompra int,
@IgvIncluido bit,
@Lote varchar(50),
@FechaVencimiento date,
@RegistroSanitario varchar(100),
@CodigoBarra varchar(50),
@Unidad VARCHAR(50)
as
if @Id = 0
begin
	insert into mst_ComprasDetalles (IdProducto,Descripcion,IdUnidad,Cantidad,Precio,Subtotal,Igv,Descuento,Total,UsuarioCrea,Estado,Flag,IdCompra, igv_incluido, Lote, FechaVencimiento, RegistroSanitario, CodigoBarra, Unidad)
	values(@idproducto,@descripcion,@idunidad,@cantidad,@precio,@subtotal,@igv,@descuento,@total,@usuariocrea,1,1,@idcompra,@IgvIncluido, @Lote, @FechaVencimiento, @RegistroSanitario, @CodigoBarra, @Unidad)
	select CAST(SCOPE_IDENTITY() as int) as Id
end
else
	begin
	update mst_ComprasDetalles set IdProducto = @IdProducto, Descripcion = @Descripcion, @IdUnidad = @IdUnidad, Cantidad = @Cantidad, Precio = @Precio, Subtotal = @Subtotal, Igv = @Igv,
	Descuento = @Descuento, Total = @Total, UsuarioModifica = @Usuariocrea, IdCompra = @IdCompra, igv_incluido = @IgvIncluido, Lote = @Lote, FechaVencimiento = @FechaVencimiento,
	RegistroSanitario = @RegistroSanitario, CodigoBarra = @CodigoBarra, Unidad = @Unidad
	where Id = @Id
	select @Id as Id
	end
GO
/****** Object:  StoredProcedure [dbo].[spAddControlTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAddControlTransportista]
@id int,
@TransportistaId int,
@Nombre varchar(200),
@HoraSalida datetime,
@HoraLlegada datetime,
@Observacion text,
@isClosed bit,
@total float
as
if @id = 0
begin
	insert into ControlTransportistas (TransportistaId, TransportistaNombre, HoraSalida, HoraLlegada, Observacion, IsClosed, Total)
	values(@TransportistaId, @Nombre, @HoraSalida, null, @Observacion, @isClosed, @total)
	select CAST(SCOPE_IDENTITY() as int)
end
else
begin
	if @isClosed = 0 begin set @horallegada = null end
	update ControlTransportistas set TransportistaId = @TransportistaId, 
	TransportistaNombre = @Nombre, HoraLlegada = @HoraLlegada, Observacion = @Observacion, IsClosed = @isClosed,
	Total=  @total
	where id = @id
	select CAST(@id as int)
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddControlTransportistaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddControlTransportistaDetalle]
@id int,
@idControlTransportista int,
@idVenta int,
@serie varchar(10),
@numero int,
@tipoDocumento varchar(2),
@razonSocial VARCHAR(250),
@fecha datetime,
@monto float,
@importePagado float,
@idFormaPago int
as
if @id = 0
begin
	insert into ControlTransportistasDetalle(IdControlTransportista, IdVenta, Serie, Numero, TipoDocumento, RazonSocial, Fecha, Monto, ImportePagado, IdFormaPago)
	values(@idControlTransportista, @idVenta, @serie, @numero, @tipoDocumento, @razonSocial, @fecha, @monto, @importePagado, @idFormaPago)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update ControlTransportistasDetalle set Serie = @serie, Numero = @numero, TipoDocumento=@tipoDocumento,
	RazonSocial = @razonSocial, Fecha = @fecha, Monto=  @monto, ImportePagado = @importePagado,
	IdFormaPago = @idFormaPago
	where id = @id
	select @id 
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddDocumentoVentaDefecto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpAddDocumentoVentaDefecto]
@documento char(2)
as
update tabla_configuracion_general set 
DocumentoVentaDefecto = @documento

GO
/****** Object:  StoredProcedure [dbo].[SpAddEntradaDirectaProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[SpAddEntradaDirectaProducto]
@state bit
as
update tabla_configuracion_general set EntradaDirectaProducto = @state

GO
/****** Object:  StoredProcedure [dbo].[SpAddInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddInventario]
@id int,
@idAlmacen int,
@almacen VARCHAR(50),
@observacion varchar(max),
@tipoInventario int,
@fecha datetime,
@isClosed bit,
@usuarioCrea varchar(50),
@estado bit
as
if @id = 0
begin
	insert into Inventario (IdAlmacen, Almacen, Observacion,TipoInventario,
	Fecha, IsClosed, UsuarioCrea)
	values(@idAlmacen, @almacen,  @observacion,@tipoInventario,
	@fecha,@isClosed,@usuarioCrea)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update Inventario set IdAlmacen = @idAlmacen, Almacen = @almacen, Observacion = @observacion,
	TipoInventario = @tipoInventario, Fecha = @fecha, IsClosed = @isClosed,
	UsuarioModifica = @usuarioCrea, FechaModifica = GETDATE()
	where id = @id
	select @id 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddInventarioDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddInventarioDetalle]
@id int,
@idInventario int,
@idGrupo int,
@grupo varchar(100),
@idProducto int,
@nombreProducto VARCHAR(max),
@codigoBarra VARCHAR(50),
@cantidad money,
@costo money,
@total money,
@idUnidad int,
@unidad varchar(50),
@factor money,
@usuarioCrea varchar(50),
@estado bit
as
if @id = 0
begin
	insert into InventarioDetalle(IdInventario, IdGrupo,Grupo, IdProducto, NombreProducto, CodigoBarra, Cantidad, Costo, Total, IdUnidad, Unidad, Factor,
	UsuarioCrea, FechaCrea, Estado, Flag)
	values(@idInventario,@idGrupo,@grupo, @idProducto, @nombreProducto, @codigoBarra, @cantidad,@costo, @total, @idUnidad, @unidad,@factor,
	@usuarioCrea, GETDATE(), 1, 1)
end
else
begin
	update InventarioDetalle set IdInventario = @idInventario,IdGrupo = @idGrupo, Grupo = @grupo, IdProducto = @idProducto,
	NombreProducto = @nombreProducto, CodigoBarra = @codigoBarra,
	Cantidad = @cantidad, Costo = @costo, Total = @total, IdUnidad = @idUnidad, Unidad = @unidad, Factor = @factor,
	UsuarioModifica = @usuarioCrea, FechaModifica = GETDATE(), Estado= @estado
	where id = @id
	select @id 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddPedido]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------
CREATE proc [dbo].[SpAddPedido]
@id int,
@idPedido int,
@idMesa int,
@codigoDoc int,
@idCliente int,
@dniRuc varchar(20),
@razonSocial varchar(250),
@direccion varchar(250),
@email varchar(250),
@pagado bit,
@eliminado bit,
@idUsuario int,
@bolFac char(2),
@subTotal money,
@igv money,
@descuento money,
@total money,
@idAlmacen int,
@proforma bit,
@idPiso int,
@numSecuencia int,
@preCuenta bit,
@otrosImpuestos money,
@adicional varchar(max),
@beneficiario varchar(max),
@idConvenio int,
@idParentesco int,
@isLlevar bit,
@isDelivery bit,
@countPecho int,
@countPierna int,
@textObservacion varchar(max)
as
if @Id = 0
begin
	insert into tabla_Pre_Venta (IdPedido, IdMesa, CodigoDoc, IdCliente, DniRuc, RazonSocial, Direccion,
	Email, Pagado, Eliminado, IdUsuario, BolFac, sub_total, igv, Descuento, Total, Idalmacen, Proforma,
	IdPiso, NumSecuencia, PreCuenta, Otro_Imp, Adicional, Beneficiario, IdConvenio, Fecha, is_llevar,
	is_delivery, countPecho, countPierna, textObservation)
	values (@IdPedido, @IdMesa, @CodigoDoc, @IdCliente, @DniRuc, @RazonSocial, @Direccion,
	@Email, @Pagado, @Eliminado, @IdUsuario, @BolFac, @SubTotal, @Igv, @Descuento, @Total, @IdAlmacen, @Proforma,
	@IdPiso, @NumSecuencia, @PreCuenta, @OtrosImpuestos, @Adicional, @beneficiario, @IdConvenio, GETDATE(), @IsLlevar,
	@IsDelivery, @CountPecho, @CountPierna, @TextObservacion)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update tabla_Pre_Venta set IdPedido = @IdPedido, IdMesa = @IdMesa, CodigoDoc = @CodigoDoc, IdCliente = @IdCliente,
	DniRuc = @DniRuc, RazonSocial = @RazonSocial, Direccion = @Direccion, Email = @Email, Pagado = @Pagado, Eliminado = @Eliminado,
	IdUsuario = @IdUsuario, BolFac = @BolFac, sub_total = @SubTotal, igv = @Igv, Descuento = @Descuento, Total = @Total, Idalmacen = @IdAlmacen,
	Proforma = @Proforma, IdPiso = @IdPiso, NumSecuencia = @NumSecuencia, PreCuenta = @PreCuenta, Otro_Imp = @OtrosImpuestos, Adicional = @Adicional,
	Beneficiario = @beneficiario, IdConvenio = @IdConvenio, is_llevar = @IsLlevar, is_delivery = @IsDelivery, countPecho = @CountPecho,
	countPierna = @CountPierna, textObservation = @TextObservacion	
	where Id = @Id
	select @Id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddPedidoBusqueda]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpAddPedidoBusqueda]
@numPedido int,
@idPiso int,
@isCodBarraBusqueda bit
as
update tabla_Pre_Venta_Detalle set  isCodBarraBusqueda = @isCodBarraBusqueda
from tabla_Pre_Venta p where p.IdPedido = @numPedido and p.IdPiso = @idPiso
and p.Pagado = 0 and p.Eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[SpAddPedidosDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddPedidosDetalles]
@id int,
@idPedido int,
@idMesa int,
@idProducto int,
@descripcion varchar(max),
@codigoBarra varchar(50),
@unidad varchar(50),
@cantidad float,
@precio float,
@subtotal float,
@igv float,
@descuento float,
@total float,
@pagado bit,
@eliminado bit,
@factor float,
@idUnidad int,
@idPiso int,
@numSecuencia int,
@adicional1 varchar(max),
@adicional2 date,
@adicional3 varchar(max),
@adicional4 varchar(max),
@igvIncluido bit,
@isCodigoBarraBusqueda bit,
@idProductoDetalle int,
@operacionExonerada bit
as
if @id = 0
begin
	insert into tabla_Pre_Venta_Detalle(IdPedido, IdMesa, IdProducto, Descripcion, CodigoBarra, UMedida, Cantidad, Precio, Subtotal, igv, Descuento, total, Pagado, Eliminado, Factor,
	IdUnidad, IdPiso, NumSecuencia, Adicional1, Adicional2, Adicional3, Adicional4, igv_incluido, IsCodBarraBusqueda, IdProductoDetalle, OperacionExonerada)
	values (@idPedido, @idMesa, @idProducto, @descripcion, @codigoBarra, @unidad, @cantidad, @precio, @subtotal, @igv, @descuento, @total, @pagado, @eliminado, @factor,
	@idUnidad, @idPiso, @numSecuencia, @adicional1, @adicional2, @adicional3, @adicional4, @igvIncluido, @isCodigoBarraBusqueda, @idProductoDetalle, @operacionExonerada)

	select CAST(SCOPE_IDENTITY() as int)
end
else
begin
	update tabla_Pre_Venta_Detalle set IdPedido = @idPedido, IdMesa=@idMesa, IdProducto=@idProducto,Descripcion=@descripcion,CodigoBarra=@codigoBarra,UMedida=@unidad,Cantidad=@cantidad,
	Precio=@precio,Subtotal=@subtotal,igv=@igv,Descuento=@descuento,total=@total,Pagado=@pagado,Eliminado=@eliminado,Factor=@factor,IdUnidad=@idUnidad,IdPiso=@idPiso,NumSecuencia=@numSecuencia,
	Adicional1=@adicional1,Adicional2=@adicional2,Adicional3=@adicional3,Adicional4=@adicional4,igv_incluido=@igvIncluido,IsCodBarraBusqueda=@isCodigoBarraBusqueda, IdProductoDetalle=@idProductoDetalle,
	OperacionExonerada= @operacionExonerada
	where id= @id
	select @id
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddPedidostDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[SpAddPedidostDetalles]
@id int,
@idPedido int,
@idMesa int,
@idProducto int,
@descripcion varchar(max),
@codigoBarra varchar(50),
@unidad varchar(50),
@cantidad float,
@precio float,
@subtotal float,
@igv float,
@descuento float,
@total float,
@pagado bit,
@eliminado bit,
@factor float,
@idUnidad int,
@idPiso int,
@numSecuencia int,
@adicional1 varchar(max),
@adicional2 date,
@adicional3 varchar(max),
@adicional4 varchar(max),
@igvIncluido bit,
@isCodBarraBusqueda bit
as
if @id = 0
begin
	insert into tabla_Pre_Venta_Detalle(IdPedido, IdMesa, IdProducto, Descripcion, CodigoBarra, UMedida, Cantidad, Precio, Subtotal, igv, Descuento, total, Pagado, Eliminado, Factor,
	IdUnidad, IdPiso, NumSecuencia, Adicional1, Adicional2, Adicional3, Adicional4, igv_incluido, IsCodBarraBusqueda)
	values (@idPedido, @idMesa, @idProducto, @descripcion, @codigoBarra, @unidad, @cantidad, @precio, @subtotal, @igv, @descuento, @total, @pagado, @eliminado, @factor,
	@idUnidad, @idPiso, @numSecuencia, @adicional1, @adicional2, @adicional3, @adicional4, @igvIncluido, @isCodBarraBusqueda)

	select CAST(SCOPE_IDENTITY() as int)
end
else
begin
	update tabla_Pre_Venta_Detalle set IdPedido = @idPedido, IdMesa=@idMesa, IdProducto=@idProducto,Descripcion=@descripcion,CodigoBarra=@codigoBarra,UMedida=@unidad,Cantidad=@cantidad,
	Precio=@precio,Subtotal=@subtotal,igv=@igv,Descuento=@descuento,total=@total,Pagado=@pagado,Eliminado=@eliminado,Factor=@factor,IdUnidad=@idUnidad,IdPiso=@idPiso,NumSecuencia=@numSecuencia,
	Adicional1=@adicional1,Adicional2=@adicional2,Adicional3=@adicional3,Adicional4=@adicional4,igv_incluido=@igvIncluido,IsCodBarraBusqueda=@isCodBarraBusqueda
	where id= @id
	select @id
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddProducto]
@id int,
@nombreProducto varchar(max),
@idMarca int,
@idProveedor int,
@idTipoProducto varchar(50),
@idGrupo int,
@estado bit 
as
if @Id = 0
begin
	insert into mst_Producto(NombreProducto, idMarca, idproveedor, IdTipoProducto, IdGrupo, estado)
	values(@nombreProducto, @idMarca, @idProveedor, @idTipoProducto, @idGrupo, @estado)
	select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
	update mst_Producto set NombreProducto = @nombreProducto, IdMarca = @idMarca, IdProveedor = @idProveedor, IdTipoProducto=@idTipoProducto, IdGrupo=@idGrupo,
	Estado = @estado
	where Id = @Id
	select @id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddProductoDetalle]
@id int,
@idProducto int,
@idTalla int,
@idColor int,
@stockMinimo float,
@fechaVence date,
@descripcion varchar(max),
@codigoBarra varchar(100), 
@estado bit,
@idMedida int,
@checkStock bit
as
if @Id = 0
begin
	insert into mst_ProductoDetalle (idProducto, idTalla, idColores, stockminimo, fechavencimiento , descripcion, codigoBarra,  estado, idmedida, checkStock, fechaCrea)
	values(@IdProducto, @IdTalla, @IdColor, @StockMinimo, @fechaVence, @descripcion, @CodigoBarra, @estado, @IdMedida, @CheckStock, GETDATE())
	select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
	update mst_ProductoDetalle set idTalla = @IdTalla, idColores = @IdColor, fechavencimiento = @fechaVence,
	descripcion = @descripcion, stockminimo = @StockMinimo, codigoBarra = @CodigoBarra, fechaModifica = GETDATE(), estado = @Estado,
	idmedida = @IdMedida, checkStock = @CheckStock
	where Id = @Id
	select @Id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddProductoPresentacion]
@id int,
@idProductoDetalle int,
@idUnidad int,
@precio money,
@isPrincipal bit,
@codigoBarra varchar(200),
@isPrincipalAlmacen bit,
@verEnVentas bit
as
if @Id = 0
begin
	insert into mst_ProductoPresentacion(idProductosDetalle, IdUnidad, precioUnitario, Principal, Codigo, PrincipalAlmacen, VerEnVentas, fechaCrea)
	values(@idProductoDetalle, @idUnidad, @precio, @isPrincipal, @codigoBarra, @isPrincipalAlmacen, @verEnVentas, GETDATE())
	select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
	update mst_ProductoPresentacion set idUnidad = @idUnidad, precioUnitario = @precio, Principal = @isPrincipal, Codigo=@codigoBarra,
	PrincipalAlmacen=@isPrincipalAlmacen, VerEnVentas=@verEnVentas, fechaModifica=GETDATE()
	where id = @Id
	select @Id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddProductoPresentacionCodigoBarra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddProductoPresentacionCodigoBarra]
@id int,
@idProductoPresentacion int,
@codigoBarra varchar(50),
@estado bit
as
if @id = 0
begin
	insert into ProductoPresentacionCodigoBarra(IdProductoPresentacion, CodigoBarra, Estado, Flag)
	values(@idProductoPresentacion, @codigoBarra, 1,1)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update ProductoPresentacionCodigoBarra set IdProductoPresentacion = @idProductoPresentacion,
	CodigoBarra = @codigoBarra, Estado = @estado
	where id = @id
	select @id 'id'
end

GO
/****** Object:  StoredProcedure [dbo].[SpAddProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddProveedor]
@id int,
@nombre varchar(200),
@ruc varchar(20),
@direccion varchar(max),
@telefono varchar(20),
@email varchar(max)
as
if @id = 0
begin
	insert into mst_Proveedor (nombre, ruc,	direccion, telefono, email)
	values(@nombre, @ruc, @direccion, @telefono, @email)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update mst_Proveedor set nombre = @nombre, ruc = @ruc, direccion= @direccion,telefono=@telefono,
	email=@email
	where id=@id

	select @id 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddRestPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddRestPisos]
@id int,
@piso int,
@mesas int,
@inicio int
as
if @id = 0
begin
insert into tabla_RestPisos(NumPiso,CantMesas, numInicio)
values(@piso,@mesas,@inicio)
select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
update tabla_RestPisos set NumPiso = @piso, CantMesas = @mesas, numInicio = @inicio where id = @id
select @id as 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[SpAddSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpAddSeguimiento]
@id int,
@idVenta int,
@idTipoPago int,
@descripcion VARCHAR(max),
@monto float,
@fechaPago date,
@validado bit,
@idApertura int,
@idUsuario int,
@idCaja int,
@descontarDeuda bit
as
if @id = 0
begin
	INSERT into tbl_Seguimiento (IdVenta, IdTipoPago, descripcion, Monto, FechaPago, validado, IdApertura, IdUsuario, IdCaja)
	VALUES(@idVenta, @idtipoPago, @descripcion, @monto,@fechaPago, @validado, @idApertura, @idUsuario, @idCaja)
	select CAST(SCOPE_IDENTITY() as int)
end
else
begin
	update tbl_Seguimiento set IdVenta =@idVenta, IdTipoPago=@idtipoPago,descripcion=@descripcion,Monto=@monto, FechaPago=@fechaPago,
	validado=@validado,idApertura=@idApertura,idUsuario=@idUsuario,idCaja=@idCaja
	where id=@id
	select @id
end

if @descontarDeuda = 1 begin exec spIrCancelando_Deuda_Seguimiento @idVenta end
GO
/****** Object:  StoredProcedure [dbo].[SpAddUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpAddUsuario]
@id int,
@idTipoUsuario int,
@nombre varchar(max),
@dni varchar(8),
@direcion varchar(max),
@telefono varchar(20),
@usuario varchar(50),
@pass varchar(max),
@usuarioCrea varchar(50),
@correo varchar(100),
@foto image,
@isCobrador bit,
@verVentas bit
as
if @id = 0
begin
	insert into mst_Usuarios (idtipoUsuario, nombre, dni, Direccion, telefono, usuario, pass, Correo,Foto, is_cobrador, verVentas, usuarioCrea, fechaCrea)
	values (@idTipoUsuario,@nombre,@dni,@direcion,@telefono,@usuario,@pass,@correo,@foto,@isCobrador,@verVentas,@usuarioCrea,GETDATE())
	select CAST(SCOPE_IDENTITY() as int) as 'id'
end
else
begin
	update mst_Usuarios set idtipoUsuario = @idTipoUsuario, nombre = @nombre, dni = @dni, Direccion = @direcion,
	telefono = @telefono, usuario = @usuario, pass = @pass, Correo = @correo, Foto = @foto, is_cobrador = @isCobrador,
	verVentas = @verVentas, usuarioModifica = @usuarioCrea, fechaModifica= GETDATE()
	where Id = @id
	select @id as 'id'
end

GO
/****** Object:  StoredProcedure [dbo].[SpAddVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddVenta]
@Id int,
@IdDocumento int,
@SerieDoc varchar(20),
@NumeroDoc int,
@FechaEmision datetime,
@SubTotal money,
@Igv money,
@Descuento money,
@TotalVenta money,
@IdCliente int,
@CodigoTipoDoc varchar(2),
@DniRuc varchar(20),
@RazonSocial varchar(100),
@Direccion varchar(200),
@Email varchar(100),
@Anulado bit,
@Observacion text,
@TipoNotCred char(2),
@DescripNotCred varchar(50),
@TipoDocAfectado char(2),
@NumeroDocAfectado varchar(50),
@UsuarioCrea varchar(50),
@IdFormaPago int,
@IdUsuarioPreventa int,
@IdApertura int,
@IdCaja int,
@ImportePagado money,
@TotalLetras text,
@Hassh varchar(max),
@IdAlmacen int,
@IdGuia int,
@IdPiso int,
@IdMesa int,
@IdUsuario int,
@TipoMoneda varchar(10),
@OtroImp money,
@TipoOperacion varchar(4),
@Adicional varchar(250),
@Beneficiario varchar(250),
@IdConvenio int,
@IdParentesco int,
@Cortesia bit,
@Delivery bit,
@Llevar bit,
@CountPecho int,
@CountPierna int,
@TextObservation varchar(250),
@FechaApertura date
as
if @Id = 0
begin
	insert into mst_Venta 
	(IdDocumento,SerieDoc,NumeroDoc,FechaEmision,IdCliente,CodigoTipoDoc,DniRuc,RazonSocial,Direccion,Email,Anulado,Observacion,
	TipoNotCred,DescripNotCred,TipoDocAfectado,NumeroDocAfectado,UsuarioCrea,FechaCrea,IdFormaPago,IdUsuarioPreventa,Descuento,
	IdApertura,idcaja, importepagado, total_letras, hassh, IdAlmacen,IdGuia, idpiso,IdMesa,idusuario, TipoMoneda, tipo_operacion, 
	Adicional, Beneficiario, IdConvenio, IdParentesco)
	values(@CodigoTipoDoc,@serieDoc,@numeroDoc,GETDATE(),@idcliente,@CodigoTipoDoc,@dniRuc,@RazonSocial,@direccion,@email,0,@observacion,
	@TipoNotCred,@DescripNotCred,@TipoDocAfectado,@numerodocafectado,@UsuarioCrea,GETDATE(),@idformapago,@idusuariopreventa,@descuento,
	@idapertura,@idcaja,@importepagado,@TotalLetras,@Hassh,@idalmacen,0,@idpiso,@IdMesa,@idusuario,@tipomoneda,@TipoOperacion, 
	@adicional, @beneficiario, @idconvenio, @idparentesco)
	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update mst_Venta set 
	IdDocumento = @CodigoTipoDoc,
	SerieDoc = @serieDoc,
	NumeroDoc = @numeroDoc,
	IdCliente = @idcliente,
	CodigoTipoDoc = @CodigoTipoDoc,
	DniRuc = @dniRuc,
	RazonSocial = @RazonSocial,
	Direccion = @direccion,
	Email = @email,
	Anulado = @Anulado,
	Observacion = @observacion,
	TipoNotCred= @TipoNotCred,
	DescripNotCred = @DescripNotCred,
	TipoDocAfectado = @TipoDocAfectado,
	NumeroDocAfectado = @numerodocafectado,
	UsuarioModifica = @UsuarioCrea,
	FechaModifica = GETDATE(),
	IdFormaPago = @idformapago,
	importepagado = @importepagado,
	total_letras = @totalletras,
	Hassh = @Hassh,
	TipoMoneda = @tipomoneda
	where Id = @id
	
	EXEC spIngresarOtrosImpuestos_Venta @id

	select @id 'id'
end
GO
/****** Object:  StoredProcedure [dbo].[spAddVentaCronograma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAddVentaCronograma]
@id int,
@fecha date,
@idVenta int,
@nroCuota int,
@monto float
as
if @id = 0
begin
	insert into venta_cronograma (fecha, idVenta, nroCuota, monto)
	values(@fecha, @idVenta, @nroCuota, @monto)
	select cast(SCOPE_IDENTITY() as int);
end
else
begin
	update venta_cronograma set fecha = @fecha, idVenta = @idVenta, nroCuota = @nroCuota, monto = @monto
	where id = @id
	select cast(@id as int);
end

GO
/****** Object:  StoredProcedure [dbo].[SpAddVentaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAddVentaDetalle]
@id int,
@idProducto int,
@descripcion varchar(max),
@idVenta int,
@cantidad money,
@precio money,
@descuento money,
@subtotal money,
@igv money,
@total money,
@unidad varchar(50),
@idUnidad int,
@factor money,
@adicional1 varchar(max),
@adicional2 date,
@adicional3 varchar(max),
@adicional4 varchar(max),
@codigoBarra varchar(max),
@igvIncluido bit,
@countPecho int,
@countPierna int,
@textObservation text,
@isCodBarraBusqueda bit,
@idProductoDetalle int
as
if @id = 0
begin
	insert into mst_Venta_det (IdProducto, descripcion, IdVenta, Cantidad, PrecioUnit, Descuento, Subtotal, Igv, Total,
	IdUnidad, Factor, Adicional1, Adicional2, Adicional3, Adicional4, igv_incluido, countPecho, countPierna, textObservation, IsCodBarraBusqueda)
	values(@idProducto, @descripcion, @idVenta, @cantidad, @precio, @descripcion, @subtotal, @igv, @total,
	@idUnidad, @factor, @adicional1, @adicional2, @adicional3, @adicional4, @igvIncluido, @countPecho, @countPierna, @textObservation, @isCodBarraBusqueda)

	select CAST(SCOPE_IDENTITY() as int) 'id'
end
else
begin
	update mst_Venta_det set IdProducto = @idProducto, descripcion = @descripcion, IdVenta = @idVenta, Cantidad = @cantidad, PrecioUnit=@precio,
	Descuento=@descuento, Subtotal=@subtotal, Igv=@igv,Total=@total,IdUnidad=@idUnidad,Factor=@factor,Adicional1=@adicional1,Adicional2=@adicional2,
	Adicional3=@adicional3,Adicional4=@adicional4,igv_incluido=@igvIncluido,countPecho=@countPecho,countPierna=@countPierna,textObservation=@textObservation,
	IsCodBarraBusqueda=@isCodBarraBusqueda
	where Id=@id
end
GO
/****** Object:  StoredProcedure [dbo].[spAddVerVentasUsario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAddVerVentasUsario]
@id int,
@check bit
as
update mst_Usuarios set verVentas = @check
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[spAlmacenSaldo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAlmacenSaldo]
@idalmacen int, @fecha date
as

create table #tempSaldoAcumulado(id int, nombre varchar(250),almacen1 varchar(250), inicial decimal(18,2), entrada decimal(18,2), ap decimal(18,2), q decimal(18,2), n decimal(18,2), p decimal(18,2), c1 decimal(18,2), de decimal(18,2), c2 decimal(18,2), saldo decimal(18,2));
create table #tempSaldo(id int, nombre varchar(250),almacen1 varchar(250), inicial decimal(18,2), entrada decimal(18,2), ap decimal(18,2), q decimal(18,2), n decimal(18,2), p decimal(18,2), c1 decimal(18,2), de decimal(18,2), c2 decimal(18,2), saldo decimal(18,2));
 
DECLARE @fecha_anterior date 

 

set @fecha_anterior =  (select DATEADD(day, -1, @fecha))
 


set NOCOUNT ON
insert into #tempSaldoAcumulado

select tempfinal.Id,tempfinal.nombre,tempfinal.almacen1,SUM(tempfinal.inicial) AS Inicial,SUM(tempfinal.entrada) as entrada, sum(tempfinal.AI) as AP, sum(tempfinal.Q) as Q,sum(tempfinal.N) as N,sum(tempfinal.P) as P, sum(tempfinal.C1) as C1, sum(tempfinal.DE) as DE, sum(tempfinal.C2) as C2, sum(tempfinal.Saldo) as Saldo from (

select pivotexx.Id,pivotexx.inicial,pivotexx.nombre,pivotexx.almacen1,ISNULL(pivotexx.entrada,0) as entrada, 
ISNULL(pivotexx.[ALMACEN PRINCIPAL],0) AS AI,
ISNULL(pivotexx.QUINOÑES,0) AS Q,
ISNULL(pivotexx.NAPO,0) AS N,
ISNULL(pivotexx.PUNCHANA,0) AS P,
ISNULL(pivotexx.[CAMARA N°1],0) AS C1,
ISNULL(pivotexx.[DEVUELTOS],0) AS DE,
ISNULL(pivotexx.[CAMARA N°2],0) AS C2,
(pivotexx.inicial+pivotexx.entrada-isnull(pivotexx.[ALMACEN PRINCIPAL],0)-isnull(pivotexx.QUINOÑES,0)-isnull(pivotexx.NAPO,0)-isnull(pivotexx.PUNCHANA,0)-isnull(pivotexx.[CAMARA N°1],0)-isnull(pivotexx.[DEVUELTOS],0)-isnull(pivotexx.[CAMARA N°2],0)) as Saldo from (

select temp.id,temp.inicial,SUM(temp.entrada) as entrada, temp.nombre, SUM(temp.salida) as salida, temp.almacen1, temp.almacen2
from
(select
pd.Id,
p.nombreProducto + ' ' + pd.descripcion as nombre,
(id.Cantidad * id.Factor) as inicial,
cast(i.FechaCrea as date) as fecha,
0 as entrada,
0 as salida,
'Inicial' as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Inventario_Detalle id
inner join mst_inventario i on id.Id_Inventario = i.Id
inner join mst_ProductoDetalle pd on id.Id_Producto = pd.Id
inner join mst_producto p on pd.idproducto = p.id
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.Id_Almacen = @idalmacen and id.flag = 1 and i.Flag = 1
--------------------------------------------------------------------
union all
select
pd.Id,
cd.Descripcion as nombre,
0 as inicial,
cast(c.FechaEmision as date) as fecha,
(cd.Cantidad * um.factor) as entrada,
0 as salida,
cast(c.Serie as varchar)+ '-' + cast(c.Numero as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_ComprasDetalles cd
inner join mst_Compras c on cd.IdCompra = c.Id
inner join mst_ProductoPresentacion pp on cd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on cd.IdUnidad = um.Id
inner join mst_Almacen a on c.IdAlmacen = a.Id
where c.IdAlmacen = @idalmacen and cd. estado = 1 and cd.Flag = 1 and c.Estado = 0 and c.flag=1 and cast(c.FechaEmision as date) <= @fecha_anterior
--------------------------------------------------------------------
 
union all
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
0 as entrada,
(vd.Cantidad * vd.Factor) as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.IdAlmacen = @idalmacen and vd.Flag = 1 and cast(v.Observacion as varchar) = '' and cast(v.fecha as date) <= @fecha_anterior
AND v.IdDocumento <> '07'
UNION ALL
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
CASE v.TipoNotCred
WHEN '01' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '02' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '03' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '06' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '07' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '08' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
ELSE 0.00 END AS entrada,
0.00 as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.Anulado = 0 and v.IdAlmacen = @idalmacen and vd.Flag = 1 and cast(v.fecha as date) <= @fecha_anterior
AND v.IdDocumento = '07' AND (v.TipoNotCred<>'04' OR v.TipoNotCred<>'05' OR v.TipoNotCred<>'09' OR v.TipoNotCred<>'10')

--TRASLADOS--------------------------
UNION ALL
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
0 as entrada,
(td.cantidad * td.factor) as salida,
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenSalida = @idalmacen and td.flag = 1 and t.flag = 1 and cast(t.fecha as date) <= @fecha_anterior
--------------------------------------- 

union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
(td.cantidad * td.factor) as 'entrada',
0 as 'salida',
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenEntrada = @idalmacen and td.flag = 1 and t.flag = 1 and cast(t.fecha as date) <= @fecha_anterior

--TRASLADOS--------------------------

--MOVIMIENTOS----------------------------

UNION ALL

SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and entrada = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) <= @fecha_anterior
---------------------------------------------

UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
0 as 'entrada',
(md.cantidad * md.factor) as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and salida = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) <= @fecha_anterior

--MOVIMIENTOS----------------------------
--ajustes
UNION ALL

SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and m.ajuste = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) <= @fecha_anterior
---------------------------------------------

) as Temp
GROUP by temp.id,temp.nombre, temp.inicial, temp.almacen1, temp.almacen2
) as Temp2

pivot (sum(temp2.salida)
for temp2.almacen2 in ([ALMACEN PRINCIPAL], [QUINOÑES], [NAPO], [PUNCHANA],[CAMARA N°1],[DEVUELTOS],[CAMARA N°2])
) AS pivotexx

) AS tempfinal
GROUP BY tempfinal.Id,tempfinal.nombre,tempfinal.almacen1
order by tempfinal.nombre asc

set NOCOUNT ON
insert into #tempSaldo

select tempfinal.Id,tempfinal.nombre,tempfinal.almacen1,SUM(tempfinal.inicial) AS Inicial,SUM(tempfinal.entrada) as entrada, sum(tempfinal.AI) as AP, sum(tempfinal.Q) as Q,sum(tempfinal.N) as N,sum(tempfinal.P) as P, sum(tempfinal.C1) as C1, sum(tempfinal.DE) as DE, sum(tempfinal.C2) as C2, sum(tempfinal.Saldo) as Saldo from (

select pivotexx.Id,pivotexx.inicial,pivotexx.nombre,pivotexx.almacen1,ISNULL(pivotexx.entrada,0) as entrada, 
ISNULL(pivotexx.[ALMACEN PRINCIPAL],0) AS AI,
ISNULL(pivotexx.QUINOÑES,0) AS Q,
ISNULL(pivotexx.NAPO,0) AS N,
ISNULL(pivotexx.PUNCHANA,0) AS P,
ISNULL(pivotexx.[CAMARA N°1],0) AS C1,
ISNULL(pivotexx.[DEVUELTOS],0) AS DE,
ISNULL(pivotexx.[CAMARA N°2],0) AS C2,
(pivotexx.inicial+pivotexx.entrada-isnull(pivotexx.[ALMACEN PRINCIPAL],0)-isnull(pivotexx.QUINOÑES,0)-isnull(pivotexx.NAPO,0)-isnull(pivotexx.PUNCHANA,0)-isnull(pivotexx.[CAMARA N°1],0)-isnull(pivotexx.[DEVUELTOS],0)-isnull(pivotexx.[CAMARA N°2],0)) as Saldo from (

select temp.id,temp.inicial,SUM(temp.entrada) as entrada, temp.nombre, SUM(temp.salida) as salida, temp.almacen1, temp.almacen2
from
(select
pd.Id,
p.nombreProducto + ' ' + pd.descripcion as nombre,
(id.Cantidad * id.Factor) as inicial,
cast(i.FechaCrea as date) as fecha,
0 as entrada,
0 as salida,
'Inicial' as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Inventario_Detalle id
inner join mst_inventario i on id.Id_Inventario = i.Id
inner join mst_ProductoDetalle pd on id.Id_Producto = pd.Id
inner join mst_producto p on pd.idproducto = p.id
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.Id_Almacen = @idalmacen and id.flag = 1 and i.Flag = 1
--------------------------------------------------------------------
union all
select
pd.Id,
cd.Descripcion as nombre,
0 as inicial,
cast(c.FechaEmision as date) as fecha,
(cd.Cantidad * um.factor) as entrada,
0 as salida,
cast(c.Serie as varchar)+ '-' + cast(c.Numero as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_ComprasDetalles cd
inner join mst_Compras c on cd.IdCompra = c.Id
inner join mst_ProductoPresentacion pp on cd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on cd.IdUnidad = um.Id
inner join mst_Almacen a on c.IdAlmacen = a.Id
where c.IdAlmacen = @idalmacen and cd. estado = 1 and cd.Flag = 1 and c.Estado = 0 and c.flag=1 and cast(c.FechaEmision as date) = @fecha
--------------------------------------------------------------------

union all
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
0 as entrada,
(vd.Cantidad * vd.Factor) as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.IdAlmacen = @idalmacen and vd.Flag = 1 and  cast(v.fecha as date) = @fecha
AND v.IdDocumento <> '07'
UNION ALL
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
CASE v.TipoNotCred
WHEN '01' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '02' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '03' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '06' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '07' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '08' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
ELSE 0.00 END AS entrada,
0.00 as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.Anulado = 0 and v.IdAlmacen = @idalmacen and vd.Flag = 1 and   cast(v.fecha as date) = @fecha
AND v.IdDocumento = '07' 
AND (v.TipoNotCred<>'04' OR v.TipoNotCred<>'05' OR v.TipoNotCred<>'09' OR v.TipoNotCred<>'10')

--TRASLADOS--------------------------
union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
0 as entrada,
(td.cantidad * td.factor) as salida,
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenSalida = @idalmacen and td.flag = 1 and t.flag = 1 and cast(t.fecha as date) = @fecha
--------------------------------------- 

union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
(td.cantidad * td.factor) as 'entrada',
0 as 'salida',
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenEntrada = @idalmacen and td.flag = 1 and t.flag = 1 and cast(t.fecha as date) = @fecha
--TRASLADOS--------------------------

--MOVIMIENTOS----------------------------

UNION ALL

SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and entrada = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) = @fecha
---------------------------------------------

UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
0 as 'entrada',
(md.cantidad * md.factor) as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and salida = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) = @fecha

--MOVIMIENTOS----------------------------
--ajustes
UNION ALL

SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
a.Nombre as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and m.ajuste = 1 and md.flag = 1 and m.flag = 1 and cast(M.fecha as date) = @fecha
---------------------------------------------

) as Temp
GROUP by temp.id,temp.nombre, temp.inicial, temp.almacen1, temp.almacen2
) as Temp2

pivot (sum(temp2.salida)
for temp2.almacen2 in ([ALMACEN PRINCIPAL], [QUINOÑES], [NAPO], [PUNCHANA],[CAMARA N°1],[DEVUELTOS],[CAMARA N°2])
) AS pivotexx

) AS tempfinal
GROUP BY tempfinal.Id,tempfinal.nombre,tempfinal.almacen1
order by tempfinal.nombre asc
 

set NOCOUNT ON	
 update #tempSaldo set #tempSaldo.inicial = #tempSaldoAcumulado.saldo, #tempSaldo.saldo = (#tempSaldoAcumulado.saldo + #tempSaldo.entrada - #tempSaldo.ap - #tempSaldo.n - #tempSaldo.q - #tempSaldo.p - #tempSaldo.c1- #tempSaldo.de- #tempSaldo.c2)
 from #tempSaldoAcumulado where #tempSaldo.id = #tempSaldoAcumulado.id

 select * from #tempSaldo where #tempSaldo.entrada<>0 or #tempSaldo.ap<>0 or #tempSaldo.q<>0 or #tempSaldo.n<>0 or #tempSaldo.p<>0 or #tempSaldo.c1<>0 or #tempSaldo.de<>0 or #tempSaldo.c2<>0
GO
/****** Object:  StoredProcedure [dbo].[spAlmaceSaldo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAlmaceSaldo]
@idalmacen int, @fecha date
as
select * from (
select temp.id,temp.inicial,SUM(temp.entrada) as entrada, temp.nombre,cast(temp.fecha as date) as fecha, SUM(temp.salida) as salida, temp.almacen1, temp.almacen2, stok.Entradas,stok.Salidas,stok.Saldo
from
(select
pd.Id,
p.nombreProducto + ' ' + pd.descripcion as nombre,
(id.Cantidad * id.Factor) as inicial,
cast(i.FechaCrea as date) as fecha,
0 as entrada,
0 as salida,
'Inicial' as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Inventario_Detalle id
inner join mst_inventario i on id.Id_Inventario = i.Id
inner join mst_ProductoDetalle pd on id.Id_Producto = pd.Id
inner join mst_producto p on pd.idproducto = p.id
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.Id_Almacen = @idalmacen and id.flag = 1 and i.Flag = 1
--------------------------------------------------------------------
union all
select
pd.Id,
cd.Descripcion as nombre,
0 as inicial,
cast(c.FechaEmision as date) as fecha,
(cd.Cantidad * um.factor) as entrada,
0 as salida,
cast(c.Serie as varchar)+ '-' + cast(c.Numero as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_ComprasDetalles cd
inner join mst_Compras c on cd.IdCompra = c.Id
inner join mst_ProductoPresentacion pp on cd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on cd.IdUnidad = um.Id
inner join mst_Almacen a on c.IdAlmacen = a.Id
where c.IdAlmacen = @idalmacen and cd. estado = 1 and cd.Flag = 1 and c.Estado = 0 and c.flag=1
--------------------------------------------------------------------

union all
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
0 as entrada,
(vd.Cantidad * vd.Factor) as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.IdAlmacen = @idalmacen and vd.Flag = 1
AND v.IdDocumento <> '07'
UNION ALL
select 
pd.Id,
vd.descripcion as nombre,
0 as inicial,
cast(v.FechaEmision as date) as fecha,
CASE v.TipoNotCred
WHEN '01' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '02' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '03' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '06' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '07' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '08' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
ELSE 0.00 END AS entrada,
0.00 as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.Anulado = 0 and v.IdAlmacen = @idalmacen and vd.Flag = 1
AND v.IdDocumento = '07' AND 
(v.TipoNotCred<>'04' OR v.TipoNotCred<>'05' OR v.TipoNotCred<>'09' OR v.TipoNotCred<>'10')

--TRASLADOS--------------------------
union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
0 as entrada,
(td.cantidad * td.factor) as salida,
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenSalida = @idalmacen and td.flag = 1 and t.flag = 1
---------------------------------------

union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
0 as inicial,
t.fecha as 'fecha',
(td.cantidad * td.factor) as 'entrada',
0 as 'salida',
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenEntrada = @idalmacen and td.flag = 1 and t.flag = 1

--TRASLADOS--------------------------

--MOVIMIENTOS----------------------------
UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
'' as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and entrada = 1 and md.flag = 1 and m.flag = 1
---------------------------------------------

UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
0 as 'entrada',
(md.cantidad * md.factor) as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as 'doc',
a.Nombre as 'almacen1',
'' as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and entrada = 0 and md.flag = 1 and m.flag = 1

--MOVIMIENTOS----------------------------
UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
0 as inicial,
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
m.documento as 'doc',
a.Nombre as 'almacen1',
'' as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and m.ajuste = 1 and md.flag = 1 and m.flag = 1

) as Temp
inner join Stocks_Acumulados stok on Temp.id = stok.IdProducto
where stok.IdAlmacen = @idalmacen and cast(temp.fecha as date) = @fecha --and temp.id = @id
GROUP by temp.id,temp.nombre, temp.inicial, temp.fecha, temp.almacen1, temp.almacen2, stok.Entradas,stok.Salidas,stok.Saldo
) as Temp2

pivot (sum(temp2.salida)
for temp2.almacen2 in ([ALMACEN PRINCIPAL], [QUINOÑES], [NAPO], [PUNCHANA],[ALMACEN SECUNDARIO])
) AS pivotexx
GO
/****** Object:  StoredProcedure [dbo].[spAM_RestaurantPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAM_RestaurantPisos]
@numpiso int,
@canmesas int,
@descripcion varchar(100),
@num_inicio int
as
declare @cont int = (select COUNT(id) from tabla_RestPisos where NumPiso = @numpiso)
if(@cont >= 1)
begin
update tabla_RestPisos set CantMesas = @canmesas, numInicio = @num_inicio where NumPiso = @numpiso
end
else
begin
insert into tabla_RestPisos(NumPiso,CantMesas, numInicio)
values(@numpiso,@canmesas, @num_inicio)
end


GO
/****** Object:  StoredProcedure [dbo].[spAMProforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAMProforma]
@id int,
@codigodoc char(2),
@idcliente int,
@dniruc varchar(50),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@idusuario int,
@bolfac char(2),
@idalmacen int,
@fecha datetime
--@descuento money,
--@total money
as
if(@id = 0)
begin 
insert into tabla_Proforma(CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,Pagado,Eliminado,IdUsuario,bolfac,Idalmacen,fecha)--,Descuento,Total)
values(@codigodoc,@idcliente,@dniruc,@razonsocial,@direccion,@email,0,0,@idusuario,@bolfac,@idalmacen,GETDATE())--,@descuento,@total)
end
else begin
update tabla_Proforma set
CodigoDoc = @codigodoc,
IdCliente = @idcliente,
DniRuc = @dniruc,
RazonSocial = @razonsocial,
Direccion=@direccion,
Email = @email,
IdUsuario = @idusuario,
BolFac = @bolfac,
Idalmacen = @idalmacen
where id = @id
end



















































GO
/****** Object:  StoredProcedure [dbo].[spAMProformaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAMProformaDetalle]
@id int,
@idproforma int,
@idproducto int,
@descripcion  varchar(200),
@codigobarra varchar(50),
@umedida varchar(50),
@cantidad money,
@precio money,
@subtotal money,
@descuento money,
@factor int,
@idunidad int,
@igv money,
@total money,
@adicional1 varchar(max)
as
if(@id = 0)
begin
insert into tabla_Proforma_Detalle(IdProforma, IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,Pagado,Eliminado,Descuento,factor,idunidad,igv,total,Adicional1)
values(@idproforma, @idproducto,@descripcion,@codigobarra,@umedida,@cantidad,@precio,@subtotal,0,0,@descuento,@factor,@idunidad,@igv,@total,@adicional1)
end
else
begin
update tabla_Proforma_Detalle set idproducto = @idproducto,
Descripcion = @descripcion,
CodigoBarra=@codigobarra,
UMedida = @umedida,
Cantidad = @cantidad,
Precio= @precio,
Subtotal = @subtotal,
Descuento = @descuento,
Factor = @factor,
IdUnidad = @idunidad,
igv = @igv,
total = @total,
Adicional1=@adicional1
where id = @id
end



















































GO
/****** Object:  StoredProcedure [dbo].[SpAnularAlmacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAnularAlmacenTraslado]
@id int
as
update mst_almacen_traslado set estado = 0,
flag = 0, total = 0
where id = @id 
select 1;

GO
/****** Object:  StoredProcedure [dbo].[spAnularGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAnularGuia]
@id int,
@observacion text
as
update mst_Guia set Anulado = 1,
Observacion = @observacion
where Id = @id

update mst_Guia_det set Anulado = 1
where idguia = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spAnularVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAnularVenta]
@id int,
@observacion text
as
update  mst_Venta set Anulado = 1,
Subtotal = 0,
Igv = 0,
Descuento = 0,
TotalVenta = 0,
Total_Letras = 'CERO 0/100',
ImportePagado = 0,
Observacion = @observacion,
Otro_Imp = 0
where Id = @id

update mst_Venta_det set Anulado = 1
where IdVenta = @id

update mst_Venta_det set Anulado = 1, Total = 0, Subtotal = 0 where IdVenta = @id

exec spEliminarVenta_Ext @id

declare @idconvenio int = (select IdConvenio from mst_Venta where id = @id)
if(@idconvenio != 0)
	begin
		update tabla_Pre_Venta_Convenio set IdVenta = 0, Pagado = 0 where IdConvenio = @idconvenio and IdVenta = @id
	end

update tabla_FormaPago set Total = 0, Efectivo = 0,
Visa = 0, Mastercard = 0, Vuelto = 0
where IdVenta = @id
GO
/****** Object:  StoredProcedure [dbo].[SpAñadirHashh]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpAñadirHashh]
@id int,
@hash varchar(max)
as
update mst_Venta set Hassh = @hash
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spAperturar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spAperturar]
@idusuario int,
@numero int,
@fecha datetime,
@idcaja int,
@caja_chica DECIMAL(18,3)
as
insert into mst_apertura(idusuario, numero,fecha,Abierto_Cerrado,idcaja, caja_chica)
values(@idusuario,@numero,@fecha,0,@idcaja, @caja_chica)


GO
/****** Object:  StoredProcedure [dbo].[spAsignarDebitoCredito]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spAsignarDebitoCredito]
@visa bit,
@mastercard bit,
@idventa int,
@debitoVisa bit,
@debitoMastercard bit
as
if @visa = 1
	begin
		update tabla_FormaPago set DebitoVisa = @debitoVisa
		where IdVenta = @idventa	
	end
if @mastercard = 1
	begin
		update tabla_FormaPago set DebitoMastercard = @debitoMastercard
		where IdVenta = @idventa
	end

GO
/****** Object:  StoredProcedure [dbo].[spBusarPresentaciones_Det]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBusarPresentaciones_Det]
@idProductoDetalle int
as
select um.nombreUnidad Unidad,p.precioUnitario Precio, p.Id, p.Codigo as CodigoBarra
from mst_ProductoPresentacion p
inner join mst_UnidadMedida um on p.idUnidad = um.Id
where p.idProductosDetalle = @idProductoDetalle and p.estado = 1 and p.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spBuscarAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarAlmacen]
@buscar varchar(100)
as
select * from mst_Almacen
where Nombre like '%'+@buscar+'%'
order by id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spBuscarCliente]
@buscar varchar(200)
as
select top 200 c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N° Documento',
c.razonSocial as 'Razón',
c.nombreComercial as 'Nombre Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Teléfono',
c.correo as 'Correo',
c.usuarioCrea as 'Usuario Crea',
c.fechaCrea as 'Fecha Crea', 
c.usuarioModifica as 'Usuario Modifica', 
c.fechaModifica as 'Fecha Mod.',
c.estado as 'Estado',
TD.codigoSunat AS 'ID DOCUMENTO',
cd.referencia as "Referencia"
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.idcliente
where c.razonSocial like '%'+@buscar+'%' and cd.principal = 1
and c.flag = 1
order by c.id desc


GO
/****** Object:  StoredProcedure [dbo].[spBuscarClienteVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spBuscarClienteVenta]
@buscar varchar(100),
@bit bit
as
if(@bit = 0)
select c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N',
c.razonSocial as 'Razon'
,c.nombreComercial as 'Nombre_Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Telefono',
c.correo as 'Correo',
c.estado as 'Estado',
TD.codigoSunat AS 'ID_DOCUMENTO',
cd.Principal,
cd.referencia as "Referencia",
ISNULL(c.nacionalidad, 0) as 'nacionalidad'
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where c.flag = 1 and c.numeroDocumento =  @buscar
order by c.id desc
else
select top 100 c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N',
c.razonSocial as 'Razon'
,c.nombreComercial as 'Nombre_Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Telefono',
c.correo as 'Correo',
c.estado as 'Estado',
TD.codigoSunat AS 'ID_DOCUMENTO',
cd.Principal,
cd.referencia as "Referencia",
ISNULL(c.nacionalidad, 0) as 'nacionalidad'
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where c.flag = 1 and c.numeroDocumento+razonSocial like '%' + @buscar + '%'
order by c.id desc
GO
/****** Object:  StoredProcedure [dbo].[spBuscarColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarColor]
@buscar varchar(10)
as
select TOP 200
id as 'ID', 
descripcion as 'Descripción',
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación',
usuarioModifica as 'Usuario de Modificación',
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Color
where descripcion like '%' + @buscar + '%' and flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarDocumentos_Serie__idusuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarDocumentos_Serie__idusuario]
@idusuario int,
@idserie int
as
select cast(d.Codigo as varchar) + '-' + d.Descripcion Doc from mst_Doc_Serie ds
inner join mst_Doc_Serie_Usuario dsu on dsu.idserie = ds.IdSerie
inner join mst_Serie s on ds.IdSerie = s.Id
inner join mst_documentos d on ds.IdDoc = d.Codigo
where dsu.IdUsuario = @idusuario and ds.IdSerie = @idserie
and dsu.Estado = 1 and dsu.Flag = 1 and ds.Estado = 1 and ds.Flag = 1
and s.Estado = 1 and s.Flag = 1
order by d.id asc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarDuplicidadProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarDuplicidadProducto]
@buscar varchar(100)
as
select p.id,nombreproducto + ' ' + nombreMarca Descripcion,p.fechacrea,p.usuarioCrea from mst_Producto p
inner join mst_Marca m on p.idMarca = m.Id
where p.nombreProducto + ' ' + m.nombreMarca = @buscar
and p.flag = 1






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarFamilia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------
----------------------

---Procedimiento de Almacenado Buscar

CREATE procedure [dbo].[spBuscarFamilia]
@buscar varchar(100) 
as
select top 200 f.id as 'ID',
f.nombreFamilia as 'Nombre',
l.nombreLinea as 'Linea', 
f.usuarioCrea as 'Usuario Creador', 
f.fechaCrea as 'Fecha de Creación', 
f.usuarioModifica as 'Usuario Modifica', 
f.fechaModifica as 'Fecha Modificación', 
f.estado as 'Estado',
cast(l.Id as varchar) AS 'ID LINEA'
from mst_Familia f
inner join mst_Linea l on f.idLinea = l.id
where f.nombreFamilia like '%'+@buscar +'%' and f.flag = 1
order by id  desc
























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarGastos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarGastos]
@buscar VARCHAR(250),
@fecha_ini date,
@fecha_fin date
as
select *,cast(t.Id as varchar) + '-'+ t.Descripcion TipoGasto from mst_GastosOperativos g
inner join mst_tipoGasto t on g.IdTipoGasto = t.Id
where eliminado = 0 and g.Concepto + ' ' + g.Proveedor like '%' + @buscar+'%' and CAST(g.Fecha as date) BETWEEN @fecha_ini and @fecha_fin
--where descripcion like '%' + @buscar + '%' and flag = 1
order by g.id desc
GO
/****** Object:  StoredProcedure [dbo].[spBuscarGastosById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarGastosById]
@id int
as
select * from mst_GastosOperativos
where Id = @id
































GO
/****** Object:  StoredProcedure [dbo].[spBuscarGrupo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------
--BUSCAR GRUPO
CREATE procedure [dbo].[spBuscarGrupo]
@buscar varchar(100),
@id int
as
if(@id = 0)
select 
Id as 'ID',
descripcion as 'Nombre',
usuarioCrea 'Usuario de Creación',
fechaCrea as 'Fecha de Creación',
usuarioModifica as 'Usuario de Modificación',
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Grupo
where descripcion like '%'+@buscar +'%'
and flag = 1 
order by id desc
else
select 
Id as 'ID',
descripcion as 'Nombre',
usuarioCrea 'Usuario de Creación',
fechaCrea as 'Fecha de Creación',
usuarioModifica as 'Usuario de Modificación',
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Grupo
where CAST(id as varchar) = @buscar and Flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarInventario]
@id int
as
select i.id,
i.tipoinventario,
a.Nombre,
i.Observacion,
i.UsuarioCrea,
i.FechaCrea,
i.UsuarioModifica,
i.FechaModifica,
''Estado,
i.Estado [E],
a.Id
from mst_Inventario i
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.Id = @id
order by i.id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarInventario_Detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarInventario_Detalle]
@id int,
@buscar varchar(100)
as
select *
from
(select  
0 Aux,
id.Id,
id.Id_Producto as 'IdProducto',
pd.codigoBarra as [Cod/Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
LTRIM(mmm.descripcion) + ' ' +
LTRIM(mm.nombreMarca) + ' ' + 
LTRIM(t.descripcion)+' '+ 
LTRIM(c.descripcion) as 'Descripcion',
um.nombreUnidad [U. Medida],
um.factor [Factor],
um.Id [Id_Unidad],
id.Cantidad,
pd.codigoBarra as 'Cod_Barra',
ISNULL(Costo, 0) Costo,
ISNULL(Total, ISNULL(Costo * precioUnitario, 0)) Total,
id.Zona,
id.Stand
from mst_Inventario_Detalle id
inner join mst_ProductoDetalle pd on id.Id_Producto = pd.id
inner join mst_Producto p on pD.idProducto = p.Id
inner join mst_ProductoPresentacion pp on pp.idProductosDetalle = pd.Id
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where id.Id_Inventario = @id and
p.estado = 1 and
p.flag = 1 and
pd.estado = 1 and
pd.flag = 1 and
pp.Principal = 1 and
pp.estado = 1 and
pp.flag = 1
)
as temp
where (temp.descripcion+temp.Cod_Barra like '%'+@buscar+'%' or cast(temp.IdProducto as varchar) = @buscar)
order by temp.Id asc
GO
/****** Object:  StoredProcedure [dbo].[spBuscarLinea]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------
--BUSCAR LINEA
CREATE procedure [dbo].[spBuscarLinea]
@buscar varchar(100) 
as
select top 200 l.id as 'ID', 
l.nombreLinea as 'Nombre', 
g.nombregrupo as 'Grupo',
l.usuarioCrea as 'Usuario de Creación',
l.fechaCrea as 'Fecha de Creación',
l.usuarioModifica as 'Usuario de Modificación', 
l.fechaModifica as 'Fecha de Modificación', 
l.estado as 'Estado' ,
cast(g.id as varchar) AS 'ID GRUPO'
from mst_Linea l
inner join mst_Grupo g on l.idGrupo = g.id
where l.nombreLinea like '%'+@buscar +'%' and l.flag = 1
order by l.id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarMarca]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------

-------------------------Buscar---------------------------
CREATE procedure [dbo].[spBuscarMarca]
@buscar varchar(100)
as
select top 200 Id as 'ID', 
nombreMarca as 'Nombre Marca', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificacion',
fechaModifica as 'Fecha de Modificación', 
estado as 'Estado'
from mst_Marca 
where nombreMarca like '%'+@buscar+'%' and flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----
CREATE proc [dbo].[spBuscarMedidas]
@buscar varchar(100)
as
select TOP 200
m.id [Id],
m.descripcion [Medida],
m.usuariocrea [Usuario Crea.],
m.fechacrea [Fecha Crea],
m.usuariomodifica [Usuario Modifica],
m.fechamodifica [Fecha Modifica],
m.estado [Estado]
from mst_Medidas m
where m.flag = 1 and m.descripcion like '%' + @buscar + '%'
order by id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarPrecioPorIdPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarPrecioPorIdPresentacion]
@id int
as
--declare @idunidad int = (select id from mst_unidadmedida where nombreunidad = @unidad)
select pp.precioUnitario,pp.Id,um.factor,um.id as 'ID_UNIDAD', pd.Id as 'IdProductoDetalle' from mst_ProductoPresentacion pp
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on pp.idunidad = um.Id
where 
pp.Id = @id
AND pp.flag = 1 
and pp.estado = 1
and pd.estado = 1
and pd.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spBuscarPrecioPorUnidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarPrecioPorUnidad]
@codigobarra varchar(200),
@idunidad int
as
--declare @idunidad int = (select id from mst_unidadmedida where nombreunidad = @unidad)
select pp.precioUnitario,pp.Id,um.factor,um.id as 'ID_UNIDAD' from mst_ProductoPresentacion pp
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on pp.idunidad = um.Id
where 
((pd.codigoBarra = @codigobarra or pp.Codigo = @codigobarra) or cast(pd.Id as varchar) = @codigobarra) and 
pp.idUnidad = @idunidad
AND pp.flag = 1 
and pp.estado = 1
and pd.estado = 1
and pd.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spBuscarPresentacion_by_IdDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarPresentacion_by_IdDetalle]
@iddetalle int,
@idunidad int
as
select * from mst_ProductoPresentacion
where idProductosDetalle = @iddetalle and idUnidad = @idunidad







GO
/****** Object:  StoredProcedure [dbo].[spBuscarProducto_Barra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----------buscar por codigo barra---------------------
CREATE procedure [dbo].[spBuscarProducto_Barra]
@buscar varchar(100)
as
select
pp.Id Id,
pd.codigoBarra [Cod/Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
--g.nombreGrupo +' '+
--l.nombreLinea+' '+
--f.nombreFamilia+' ' +
t.descripcion+' '+ 
c.descripcion  as 'Descripcion',
um.nombreUnidad [U. Medida],
um.factor [Factor],
ppp.nombre [Proveedor],
pd.imagenProducto Imagen,
pp.precioUnitario Precio,
um.id [Id Unidad],
p.Id [Id Producto],
p.estado Estado
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor ppp on p.idproveedor = ppp.id
where  p.id = pd.IdProducto 
and pd.Id = pp.IdProductosDetalle 
and pd.codigoBarra =@buscar
and p.flag = 1 and pd.flag = 1 and pp.flag = 1
order by p.id asc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProducto_Barra_Pre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spBuscarProducto_Barra_Pre]
@buscar varchar(100)
as
select top 200 pd.id as 'ID' ,
pd.codigobarra as 'Codigo Barra',
p.nombreProducto +' '+m.nombreMarca+' '+t.descripcion+' '+c.descripcion +' ' + mmm.descripcion [Descripcion],
um.nombreUnidad as 'Unidad',
(pp.PrecioUnitario) as 'Precio',
cast(pro.id as varchar) + '-' + pro.nombre [Proveedor],
p.estado as 'Estado',
um.id [Id Unidad],
p.Id
from mst_producto p
inner join mst_ProductoDetalle pd on p.id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
inner join mst_Marca m on p.idMarca = m.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_proveedor pro on p.idproveedor = pro.id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where pd.codigoBarra =@buscar
and p.flag = 1 and pd.flag = 1 and pp.flag = 1
order by p.id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProducto_Nombre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarProducto_Nombre]
@idalmacen int,
@topin int,
@buscar varchar(100),
@anulados bit,
@idgrupo int
as
if(@anulados = 0)
if @idgrupo > 0
	begin
	select top (@topin)  *,
	dbo.F_GetUltimoCostoProductoDetalle(Id, @idalmacen) as 'Costo'
	from
	vw_FiltroMstProductos
	where idalmacen = @idalmacen and estado = 1 and idgrupo = @idgrupo and
	((Descripcion  like '%'+@buscar+'%') 
	or (iif(cast(F_Vence as varchar) is null,'Sin definir',cast(F_Vence as varchar)) like '%' + @buscar+'%' )
	or (cast(Id as varchar) = @buscar))
	or Cod_Barra = @buscar
	end
else
	begin
	select top (@topin)  * ,
	dbo.F_GetUltimoCostoProductoDetalle(Id, @idalmacen) as 'Costo'
	from
	vw_FiltroMstProductos
	where idalmacen = @idalmacen and estado = 1 and
	((Descripcion  like '%'+@buscar+'%') 
	or (iif(cast(F_Vence as varchar) is null,'Sin definir',cast(F_Vence as varchar)) like '%' + @buscar+'%' )
	or (cast(Id as varchar) = @buscar))
	 
	end

else
if @idgrupo > 0
	begin
	select top (@topin) * ,
	dbo.F_GetUltimoCostoProductoDetalle(Id, @idalmacen) as 'Costo'
	from vw_FiltroMstProductos
	where idalmacen = @idalmacen and estado = 0 and idgrupo = @idgrupo and
	((Descripcion like '%'+@buscar+'%') 
	or (iif(cast(F_Vence as varchar) is null,'Sin definir',cast(F_Vence as varchar)) like '%' + @buscar+'%')
	or (cast(Id as varchar) = @buscar))
	 
	end
else
	begin
	select top (@topin) * ,
	dbo.F_GetUltimoCostoProductoDetalle(Id, @idalmacen) as 'Costo'
	from vw_FiltroMstProductos
	where idalmacen = @idalmacen and estado = 0 and
	((Descripcion like '%'+@buscar+'%') 
	or (iif(cast(F_Vence as varchar) is null,'Sin definir',cast(F_Vence as varchar)) like '%' + @buscar+'%')
	or (cast(Id as varchar) = @buscar))
	 
	end
GO
/****** Object:  StoredProcedure [dbo].[spBuscarProducto_Nombre_Pre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------buscar por nombre---------------------
CREATE procedure [dbo].[spBuscarProducto_Nombre_Pre]
@buscar varchar(100)
as
select top 200 pp.id as 'ID' ,
pd.codigobarra as 'Codigo Barra',
p.nombreProducto +' '+m.nombreMarca+' '+t.descripcion+' '+c.descripcion +' ' + mmm.descripcion [Descripcion],
um.nombreUnidad as 'Unidad',
um.factor as 'Factor',
(pd.imagenProducto) as 'Imagen',
(pp.PrecioUnitario) as 'Precio',
um.id [Id Unidad]
from mst_producto p
inner join mst_ProductoDetalle pd on p.id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
inner join mst_Marca m on p.idMarca = m.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where p.id = pd.IdProducto 
and pd.Id = pp.IdProductosDetalle 
and (p.nombreProducto +' '+m.nombreMarca+' '+t.descripcion+' '+c.descripcion +' ' + mmm.descripcion)like '%'+@buscar+'%'
and p.flag = 1 and pd.flag = 1 and pp.flag = 1
order by p.id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--buscar
CREATE proc [dbo].[spBuscarProductoDetalle]
@id int
as
select pd.id as 'Id-Detalle',
cast(t.id as varchar)+ '-' + t.descripcion as 'Talla',
cast(c.Id as varchar) + '-' + c.descripcion as 'Color',
pd.codigoBarra as 'Codigo-Barra',
pd.imagenProducto as 'Imagen',
pd.estado as 'Estado'
from mst_ProductoDetalle pd
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
where pd.idProducto = @id
and pd.flag = 1
order by pd.Id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--buscar
CREATE proc [dbo].[spBuscarProductoPresentacion]
@id int
as
select pp.id as 'ID-P',
pp.idproductosdetalle as 'ID-D',
(select nombreunidad from mst_UnidadMedida um where um.id = pp.idunidad) as 'Unidad',
pp.preciounitario as 'Precio',
pp.estado as 'Estado'
from mst_ProductoPresentacion pp
where pp.idproductosdetalle = @id and pp.flag = 1
order by pp.id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProductoVentaBarra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarProductoVentaBarra]
@buscar varchar(100)
as
select 
pp.Id Id,
pd.codigoBarra [Cod/Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
--g.nombreGrupo +' '+
--l.nombreLinea+' '+
--f.nombreFamilia+' ' +
t.descripcion+' '+ 
c.descripcion  as 'Descripcion',
um.nombreUnidad [U. Medida],
um.factor [Factor],
pd.imagenProducto Imagen,
pp.precioUnitario Precio,
um.id [Id Unidad]
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where p.flag = 1 and p.estado = 1 and codigoBarra = @buscar
order by pp.Id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarProductoVentaBarraRapida]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarProductoVentaBarraRapida]
@buscar varchar(100),
@opcion int
as
if(@opcion=1)
begin
select 
pp.Id Id,
pd.codigoBarra 'CodBarra',
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
--g.nombreGrupo +' '+
--l.nombreLinea+' '+
--f.nombreFamilia+' ' +
t.descripcion+' '+ 
c.descripcion  as 'Descripcion',
um.nombreUnidad 'UnidadMedida',
um.factor [Factor],
pd.imagenProducto Imagen,
pp.precioUnitario Precio,
um.id 'IdUnidad',
pp.Principal,
p.IdGrupo as 'idgrupo',
pd.Id as 'IdProductoDetalle'
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where p.flag = 1 
and p.estado = 1 
and pd.estado = 1
and pd.flag  = 1
and pp.estado = 1
and pp.flag = 1
and (pd.codigoBarra = @buscar or pp.Codigo=@buscar) 
--or cast(pd.id as varchar) = @buscar)
--and pp.principal = 1
order by pp.id desc
end
else
begin
select 
pp.Id Id,
pd.codigoBarra 'CodBarra',
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
--g.nombreGrupo +' '+
--l.nombreLinea+' '+
--f.nombreFamilia+' ' +
t.descripcion+' '+ 
c.descripcion  as 'Descripcion',
um.nombreUnidad 'UnidadMedida',
um.factor [Factor],
pd.imagenProducto Imagen,
pp.precioUnitario Precio,
um.id 'IdUnidad',
pp.Principal,
p.IdGrupo as 'idgrupo',
pd.Id as 'IdProductoDetalle'
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
where p.flag = 1 
and p.estado = 1 
and pd.estado = 1
and pd.flag  = 1
and pp.estado = 1
and pp.flag = 1
and cast(pd.id as varchar) = @buscar
--and pp.principal = 1
order by pp.id desc
end
GO
/****** Object:  StoredProcedure [dbo].[spBuscarProductoVentaNombre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarProductoVentaNombre]
@buscar varchar(100),
@idalmacen int,
@idgrupo int,
@opcion int,
@compras bit = 0,
@esTienda int = 0
as
declare @toppp int = 100
if(@idgrupo = 0)
begin
if(@opcion = 1)
begin
select top (@toppp) * from vw_FiltroProductos 
where (Descripcion like '%' + @buscar + '%') and idalmacen = @idalmacen
and PrincipalAlmacen = case when @compras = 0 then PrincipalAlmacen else 1 end
and VerEnVentas = case when @esTienda = 0 then VerEnVentas else 1 end
order by idproducto,principal desc
end
else if(@opcion = 2)
begin
select top (@toppp) * 
from vw_FiltroProductos
where cast(C_Interno as varchar) = @buscar and idalmacen = @idalmacen
and PrincipalAlmacen = case when @compras = 0 then PrincipalAlmacen else 1 end
and VerEnVentas = case when @esTienda = 0 then VerEnVentas else 1 end
order by Id desc
end
else if(@opcion = 3)
begin
select top (@toppp) * 
from
vw_FiltroProductos
where cast(Cod_Barra as varchar) = @buscar and idalmacen = @idalmacen
and PrincipalAlmacen = case when @compras = 0 then PrincipalAlmacen else 1 end
and VerEnVentas = case when @esTienda = 0 then VerEnVentas else 1 end
order by Id desc
end
---
end
else
begin
select *
from vw_FiltroProductos
where (Descripcion like '%' + @buscar + '%' or Cod_Barra = @buscar) and idalmacen = @idalmacen and IdGrupo = @idgrupo and idmedida != 2
and PrincipalAlmacen = case when @compras = 0 then PrincipalAlmacen else 1 end
order by Descripcion desc
end
GO
/****** Object:  StoredProcedure [dbo].[spBuscarProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------
CREATE proc [dbo].[spBuscarProveedor]
@buscar varchar(100)
as
select id [Id],
nombre Nombre,
ruc Ruc,
direccion Direccion,
telefono Telefono,
email Email,
usuariocrea [Usuario Crea.],
fechacrea [Fecha Crea],
usuariomodifica [Usuario Modifica],
fechamodifica [fecha Modifica],
estado Estado
from mst_Proveedor
where nombre like '%' + @buscar+'%' and flag = 1
order by id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarSeries_Documentos__idusuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarSeries_Documentos__idusuario]
@idusuario int,
@iddoc char(2)
as
select s.id, s.Serie from mst_Doc_Serie_Usuario dsu
inner join mst_Doc_Serie ds on dsu.idserie = ds.Id
inner join mst_Serie s on ds.IdSerie = s.Id
inner join mst_documentos d on ds.IdDoc = d.Codigo
where dsu.IdUsuario = @idusuario and ds.IdDoc = @iddoc
and dsu.Estado = 1 and dsu.Flag = 1 and ds.Estado = 1 and ds.Flag = 1
and s.Estado = 1 and s.Flag = 1





















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarSiTienePecho]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spBuscarSiTienePecho]
@id int
as
declare @idtemp int = 
(select p.Id from mst_ProductoPresentacion pp 
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p  on pd.idProducto = p.Id
where pp.Id = @id
)
-----------------------------------------
-----------------------------------------
select temp.*
from
(select
pp.Id Id,
pd.codigoBarra [Cod_Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
LTRIM(mmm.descripcion) + ' ' +
LTRIM(mm.nombreMarca) + ' ' + 
LTRIM(t.descripcion)+' '+ 
LTRIM(c.descripcion) as 'Descripcion',
LTRIM(um.nombreUnidad) [U_Medida],
um.factor [Factor],
pd.imagenproducto Imagen,
pro.nombre [Proveedor],
stock.saldo [Stock_Actual],
iif(CONVERT(varchar,fechavencimiento,103) IS NULL,'Sin definir',cast(fechavencimiento as varchar))
[F_Vencimiento],
pp.precioUnitario [Precio_Unit],
um.id [Id_Unidad]
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor pro on p.idproveedor = pro.id
inner join stocks_acumulados stock on pd.id = stock.idproducto
where p.flag = 1 
and p.estado = 1
and pd.flag = 1 
and pd.estado = 1
and pp.flag = 1 
and pp.estado = 1
and p.Id = @idtemp
and pd.idmedida = 2
)
as Temp 
where temp.Descripcion collate Latin1_general_CI_AI like '%' + '' + '%'
order by temp.Id asc



















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarSoloBoleta_y_Factura]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarSoloBoleta_y_Factura]
@coddocumento char(2),
@serie varchar(4)
as
select m.id,
m.FechaEmision as 'Fecha Emision',
cast((m.SerieDoc) as varchar) + '-' + cast((m.NumeroDoc) as varchar) as 'Documento',
m.RazonSocial as 'Razón Social',
m.TotalVenta as 'Total'
from mst_Venta m
where (m.IdDocumento = @coddocumento) and m.iddocumento != 07
and m.Anulado = 0 
order by m.Id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarTalla]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--buscar
CREATE proc [dbo].[spBuscarTalla]
@buscar varchar(10)
as
select id as 'ID', 
descripcion as 'Descripción', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificación',  
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Talla
where descripcion like '%' + @buscar + '%' and flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarTipoUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarTipoUsuario]
@buscar varchar(100)
as
select id,descripcion,usuarioCrea,fechaCrea,usuarioModifica,fechaModifica,estado from mst_TipoUsuario
where descripcion like '%'+@buscar+'%'
and flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarTransportista]
@buscar varchar(100)
as
select
t.id,
nombre,
td.descripcion [DniRuc],
t.DniRuc [Numero],
t.Licencia,
t.Direccion,
t.Telefono,
t.Email,
t.UsuarioCrea,
t.FechaCrea,
t.UsuarioModifica,
t.FechaModifica,
t.CodidoTipoDoc
from mst_Transportistas t
inner join mst_TipoDocumento td on t.CodidoTipoDoc = td.codigoSunat
where Nombre+Licencia like '%' + @buscar + '%' and t.Flag = 1



















































GO
/****** Object:  StoredProcedure [dbo].[spBuscarUnidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------

---------buscar unidad---------------------------
CREATE procedure [dbo].[spBuscarUnidad]
@textobuscar varchar(100)
as
select id as 'ID', nombreUnidad as 'Nombre Unidad',factor as 'Factor' ,usuarioCrea as 'Usuario Creador', fechaCrea as 'Fecha de Registro', usuarioModifica as 'Usuario Modifica', fechaModifica as 'Fecha de Modificación' , estado as 'Estado'
from mst_UnidadMedida
where nombreUnidad like '%' + @textobuscar + '%' and flag = 1
Order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarUnidadesporCodBarra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarUnidadesporCodBarra]
@codbarra varchar(50),
@opcion int
as
-- or cast(pd.Id as varchar) = @codbarra) 
if(@opcion= 1)
begin
select
um.id as Id,
um.nombreUnidad as Descripcion,
pp.Principal as Principal,
pp.Id as 'id_presentacion',
pd.id as 'IdProductoDetalle',
pp.Codigo 'CodigoBarra',
pd.codigoBarra 'CodigoBarraDetalle'
from mst_productodetalle pd
 join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
 inner join mst_UnidadMedida um on pp.idUnidad = um.Id
 where 
 ((pd.codigoBarra = @codbarra or pp.Codigo = @codbarra)
 and pd.estado = 1 and pd.flag = 1 and pp.estado = 1 and pp.flag = 1)
end
else if(@opcion=2)
begin
select
um.id as Id,
um.nombreUnidad as Descripcion,
pp.Principal as Principal,
pp.Id as 'id_presentacion',
pd.id as 'IdProductoDetalle',
pp.Codigo 'CodigoBarra',
pd.codigoBarra 'CodigoBarraDetalle'
from mst_productodetalle pd
 join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
 inner join mst_UnidadMedida um on pp.idUnidad = um.Id
 where 
 (cast(pd.Id as varchar) = @codbarra 
 and pd.estado = 1 and pd.flag = 1 and pp.estado = 1 and pp.flag = 1)
end
GO
/****** Object:  StoredProcedure [dbo].[spBuscarUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarUsuario]
@buscar varchar(100)
as
select u.Id Id,tu.descripcion [Tipo de Usuario],u.nombre Nombre,u.dni Dni,u.direccion Direccion,u.telefono Telefono,u.correo Correo,u.usuario Usuario,u.pass Pass,u.usuarioCrea [Usuario Crea],u.fechaCrea [Fecha Crea],u.usuarioModifica [Usuario Modifica],u.fechaModifica [Fecha Modifica], u.Foto,u.estado Estado, tu.Id IDtipoUsuario from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where u.flag = 1 and tu.flag = 1 and u.nombre like '%' + @buscar + '%'
order by u.id desc























































GO
/****** Object:  StoredProcedure [dbo].[spBuscarVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spBuscarVentas]
@fechainicio date,
@fechafin date,
@tipodoc char(2),
@serienum varchar(100),
@buscar varchar(100),
@idusuario int,
@deudas bit,
@VerSinNotas bit=0
as
if(@idusuario = 0)
	begin	
		if(@deudas = 0)
			begin
						select * from
				(
				select
				 v.Id,
				case v.IdDocumento
				when '03' then 'BOLETA'
				when '01' then 'FACTURA'
				when '07' then 'NOTA DE CREDITO'
				when '08' then 'NOTA DE DÉBITO'
				when '99' then 'NOTA DE VENTA'
				END Documento,
				v.SerieDoc Serie,
				v.NumeroDoc N,
				v.RazonSocial RazonSocialCliente,
				V.SubTotal,
				V.Igv,
				Otro_Imp 'ICBPER',
				v.TotalVenta,
				v.FechaEmision FechaEmision,
				u.usuario Atendidopor,
				v.Anulado Estado,
				ISNULL(cpe.doc_firma, 0) Firma,
				isnull(cpe.doc_cdr ,0)  Cdr,
				v.IdGuia Guia,
				v.TipoMoneda,
				iif(TotalVenta>ImportePagado,CAST(0 AS BIT),CAST(1 AS BIT)) as 'EP',
				(select count(ss.id) from tbl_Seguimiento ss where (ss.IdVenta = v.Id and ss.validado = 0 and V.ImportePagado < v.TotalVenta) and v.IdFormaPago = 2) as 'Pintar',
				cast(iif(v.IdDocumento='99',0,1) as bit) as VerNotasVentas
				from mst_Venta v
				inner join mst_documentos d on v.IdDocumento = d.Codigo
				inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
				left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe			
				where
				cast(V.FechaEmision as date) BETWEEN @fechainicio AND @fechafin
				) as temp

				where 

				(temp.RazonSocialCliente LIKE '%' + @buscar + '%' OR  
				temp.Serie 
				+ '-' + cast(temp.[N] as varchar) 
				like '%' +  @buscar + '%') and temp.VerNotasVentas = CASE @VerSinNotas WHEN 0 THEN temp.VerNotasVentas ELSE 1 END
				

				order by temp.Id desc
		end


		else

			begin
				
				select * from
				(
				select
				 v.Id,
				case v.IdDocumento
				when '03' then 'BOLETA'
				when '01' then 'FACTURA'
				when '07' then 'NOTA DE CREDITO'
				when '08' then 'NOTA DE DÉBITO'
				when '99' then 'NOTA DE VENTA'
				END Documento,
				v.SerieDoc Serie,
				v.NumeroDoc N,
				v.RazonSocial RazonSocialCliente,
				V.SubTotal,
				V.Igv,
				Otro_Imp 'ICBPER',
				v.TotalVenta,
				v.FechaEmision FechaEmision,
				u.usuario Atendidopor,
				v.Anulado Estado,
				ISNULL(cpe.doc_firma, 0) Firma,
				isnull(cpe.doc_cdr ,0)  Cdr,
				v.IdGuia Guia,
				v.TipoMoneda,
				iif(TotalVenta>ImportePagado,CAST(0 AS BIT),CAST(1 AS BIT)) as 'EP',
				(select count(ss.id) from tbl_Seguimiento ss where (ss.IdVenta = v.Id and ss.validado = 0 and V.ImportePagado < v.TotalVenta) and v.IdFormaPago = 2) as 'Pintar',
				cast(iif(v.IdDocumento='99',0,1) as bit) as VerNotasVentas
				from mst_Venta v
				inner join mst_documentos d on v.IdDocumento = d.Codigo
				inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
				left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe
				where
				cast(V.FechaEmision as date) BETWEEN @fechainicio AND @fechafin
				) as temp

				where 

				(temp.RazonSocialCliente LIKE '%' + @buscar + '%' OR  
				temp.Serie 
				+ '-' + cast(temp.[N] as varchar) 
				like '%' +  @buscar + '%') and temp.VerNotasVentas = CASE @VerSinNotas WHEN 0 THEN temp.VerNotasVentas ELSE 1 END
				and temp.EP = 0
				order by temp.Id desc
			end
	end


else
	begin
		if(@deudas = 0)
			begin
				select * from
				(
				select
				 v.Id,
				case v.IdDocumento
				when '03' then 'BOLETA'
				when '01' then 'FACTURA'
				when '07' then 'NOTA DE CREDITO'
				when '08' then 'NOTA DE DÉBITO'
				when '99' then 'NOTA DE VENTA'
				END Documento,
				v.SerieDoc Serie,
				v.NumeroDoc N,
				v.RazonSocial RazonSocialCliente,
				V.SubTotal,
				V.Igv,
				Otro_Imp 'ICBPER',
				v.TotalVenta,
				v.FechaEmision FechaEmision,
				u.usuario Atendidopor,
				v.Anulado Estado,
				ISNULL(cpe.doc_firma, 0) Firma,
				isnull(cpe.doc_cdr ,0)  Cdr,
				v.IdGuia Guia,
				v.TipoMoneda,
				iif(TotalVenta>ImportePagado,CAST(0 AS BIT),CAST(1 AS BIT)) as 'EP',
				(select count(ss.id) from tbl_Seguimiento ss where (ss.IdVenta = v.Id and ss.validado = 0 and V.ImportePagado < v.TotalVenta) and v.IdFormaPago = 2) as 'Pintar',
				cast(iif(v.IdDocumento='99',0,1) as bit) as VerNotasVentas
				from mst_Venta v
				inner join mst_documentos d on v.IdDocumento = d.Codigo
				inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
				left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe
				where
				cast(V.FechaEmision as date) BETWEEN @fechainicio AND @fechafin and (v.idusuario = @idusuario or (V.IdUsuarioPreventa = @idusuario and u.is_cobrador = 1))
				) as temp

				where 

				(temp.RazonSocialCliente LIKE '%' + @buscar + '%' OR  
				temp.Serie 
				+ '-' + cast(temp.[N] as varchar) 
				like '%' +  @buscar + '%') and temp.VerNotasVentas = CASE @VerSinNotas WHEN 0 THEN temp.VerNotasVentas ELSE 1 END

				order by temp.Id desc

			end

		else
			begin

				select * from
				(
				select
				 v.Id,
				case v.IdDocumento
				when '03' then 'BOLETA'
				when '01' then 'FACTURA'
				when '07' then 'NOTA DE CREDITO'
				when '08' then 'NOTA DE DÉBITO'
				when '99' then 'NOTA DE VENTA'
				END Documento,
				v.SerieDoc Serie,
				v.NumeroDoc N,
				v.RazonSocial RazonSocialCliente,
				V.SubTotal,
				V.Igv,
				Otro_Imp 'ICBPER',
				v.TotalVenta,
				v.FechaEmision FechaEmision,
				u.usuario Atendidopor,
				v.Anulado Estado,
				ISNULL(cpe.doc_firma, 0) Firma,
				isnull(cpe.doc_cdr ,0)  Cdr,
				v.IdGuia Guia,
				v.TipoMoneda,
				iif(TotalVenta>ImportePagado,CAST(0 AS BIT),CAST(1 AS BIT)) as 'EP',
				(select count(ss.id) from tbl_Seguimiento ss where (ss.IdVenta = v.Id and ss.validado = 0 and V.ImportePagado < v.TotalVenta) and v.IdFormaPago = 2) as 'Pintar',
				cast(iif(v.IdDocumento='99',0,1) as bit) as VerNotasVentas
				from mst_Venta v
				inner join mst_documentos d on v.IdDocumento = d.Codigo
				inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
				left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe
				where
				cast(V.FechaEmision as date) BETWEEN @fechainicio AND @fechafin and (v.idusuario = @idusuario or (V.IdUsuarioPreventa = @idusuario and u.is_cobrador = 1))
				) as temp

				where 

				(temp.RazonSocialCliente LIKE '%' + @buscar + '%' OR  
				temp.Serie 
				+ '-' + cast(temp.[N] as varchar) 
				like '%' +  @buscar + '%') and temp.VerNotasVentas = CASE @VerSinNotas WHEN 0 THEN temp.VerNotasVentas ELSE 1 END
				and temp.EP = 0
				order by temp.Id desc

			end

	end
GO
/****** Object:  StoredProcedure [dbo].[spCalcularGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCalcularGuia]
as
select max(id) from mst_Guia



















































GO
/****** Object:  StoredProcedure [dbo].[spCalcularSecuenciaBoletaFacturaEtc]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCalcularSecuenciaBoletaFacturaEtc]
@codigodoc char(2),
@serie char(4),
@bit bit
as
if(@bit = 0)
select max(NumeroDoc) from mst_Venta
where IdDocumento = @codigodoc and SerieDoc  = @serie

else
select max(NumeroDoc) from mst_Venta
where SerieDoc  = @serie 























































GO
/****** Object:  StoredProcedure [dbo].[spCambiar_Servidor_Predeterminado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCambiar_Servidor_Predeterminado]
@id int
as
if((select count(id) from MST_SERVIDORES where id = @id) > 0)
begin
update mst_servidores set predeterminado= 0
update MST_SERVIDORES set Predeterminado = 1
where id = @id
end


















































GO
/****** Object:  StoredProcedure [dbo].[spCambiarEstadoStock]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCambiarEstadoStock](@iddetalle int, @check_stock bit)
as
update mst_ProductoDetalle set checkStock = @check_stock
where Id = @iddetalle

































GO
/****** Object:  StoredProcedure [dbo].[spCambiarPresentacionPrincipal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCambiarPresentacionPrincipal]
 @iddetalle int,
@id int,
@estado bit,
@bit bit
as
if(@bit =0)
begin
update mst_ProductoPresentacion set Principal = 0
where idProductosDetalle = @iddetalle
update mst_ProductoPresentacion set Principal = 1
where id = @id
end
else
update mst_ProductoDetalle set estado = @estado
where Id = @iddetalle
GO
/****** Object:  StoredProcedure [dbo].[spCambiarPresentacionPrincipalAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCambiarPresentacionPrincipalAlmacen]
@iddetalle int,
@id int,
@estado bit,
@bit bit
as
if(@bit =0)
begin
update mst_ProductoPresentacion set PrincipalAlmacen = 0
where idProductosDetalle = @iddetalle
update mst_ProductoPresentacion set PrincipalAlmacen = 1
where id = @id
end

GO
/****** Object:  StoredProcedure [dbo].[spCambiarVerEnVentasProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCambiarVerEnVentasProductoPresentacion]
@iddetalle int,
@id int,
@estado bit,
@bit bit
as
if(@bit =0)
begin
update mst_ProductoPresentacion set VerEnVentas = 0
where idProductosDetalle = @iddetalle
update mst_ProductoPresentacion set VerEnVentas = 1
where id = @id
end
GO
/****** Object:  StoredProcedure [dbo].[spCancelarPreVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------
CREATE proc [dbo].[spCancelarPreVenta]
@id int
as

update tabla_Pre_Venta set Eliminado = 1 where idmesa = @id
update tabla_Pre_Venta set Eliminado = 1 where idmesa = @id
























































GO
/****** Object:  StoredProcedure [dbo].[spCargaProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargaProductos]
@id int
as
select p.nombreProducto,
m.nombreMarca Marca,
g.Descripcion Grupo, 
l.Descripcion Linea,
f.Descripcion Familia,
pro.nombre,
p.estado,
p.idMarca,
p.idsegmento,
p.idfamilia,
p.idclase,
pro.id,
p.IdTipoProducto,
substring(p.idproductosunat,7,2) idprodsunat,
p.IdGrupo
from mst_Producto p 
inner join mst_Marca m on p.idMarca = m.Id
inner join mst_segmento g on p.IdSegmento = g.Codigo
inner join mst_Familia l on p.IdFamilia = l.Codigo
inner join mst_Clase f on p.IdClase = f.Codigo
inner join mst_Proveedor pro on p.idproveedor = pro.id
where p.id = @id and p.flag = 1 
order by p.Id desc























































GO
/****** Object:  StoredProcedure [dbo].[spCargarDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarDetalles]
@id int
as
select
'' [-],
''[x],
p.id Id,
p.codigoBarra,
p.descripcion,
t.descripcion Talla,
c.descripcion Color,
mmm.descripcion,
p.imagenProducto,
p.stockinicial,
p.stockminimo,
iif(CONVERT(varchar,p.fechavencimiento,103) IS NULL,'00/00/0000',CONVERT(varchar,p.fechavencimiento,103)) Fechavence,
p.idmedida,
p.idTalla,
p.idColores,
p.estado [Estado],
checkStock
from mst_ProductoDetalle p
inner join mst_Talla t on p.idTalla = t.Id
inner join mst_Color c on p.idColores = c.Id
inner join mst_medidas mmm on p.idmedida = mmm.id
where idProducto = @id and p.flag = 1






















































GO
/****** Object:  StoredProcedure [dbo].[spCargarPresentaciones]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarPresentaciones]
@id int
as
select 
'' [-],
''[x],
@id [Id detalle],
um.nombreUnidad Unidad,
um.factor,
p.precioUnitario,
p.Principal ,
p.Id [Id Pres],
um.Id,
p.PrincipalAlmacen,
Codigo,
VerEnVentas
from mst_ProductoPresentacion p
inner join mst_UnidadMedida um on p.idUnidad = um.Id
where idProductosDetalle = @id and p.flag = 1 and p.estado = 1
GO
/****** Object:  StoredProcedure [dbo].[spCargarProductoVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarProductoVenta]
@id int
as
select
pp.Id Id,
pd.codigoBarra as 'Cod_Barra',
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
LTRIM(mmm.descripcion) + ' ' +
LTRIM(mm.nombreMarca) + ' ' + 
LTRIM(t.descripcion)+' '+ 
LTRIM(c.descripcion) as 'Descripcion',
LTRIM(um.nombreUnidad) U_Medida,
um.factor 'Factor',
pd.imagenProducto Imagen,
pro.nombre 'Proveedor',
pd.stockactual 'Stock_Actual',
pd.fechavencimiento 'F_Vencimiento',
pp.precioUnitario Precio,
um.id 'Id_Unidad',
pd.Id cod_interno
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor pro on p.idproveedor = pro.id
where p.flag = 1 and 
p.estado = 1 and 
pd.flag = 1 and 
pd.estado = 1 and 
pp.estado = 1 and 
pp.flag = 1 and pp.id = @id
order by p.Id desc
GO
/****** Object:  StoredProcedure [dbo].[spCargarVentas_Id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarVentas_Id]
@id int,
@bit bit,
@fechainicio date,
@fechafinal date,
@idVendedor int = 0
as
if(@bit = 0)
select *,cast(d.codigoSunat as varchar) + '-'+d.descripcion TipoDoc,dc.descripcion as D_DOC, c.nacionalidad
from mst_Venta v 
inner join mst_TipoDocumento d on v.CodigoTipoDoc = d.codigoSunat
INNER join mst_documentos dc on v.IdDocumento = dc.Codigo
inner join mst_Cliente c on v.IdCliente = c.Id
inner join mst_Usuarios us on v.IdUsuarioPreventa = us.Id
where v.Id = @id and Anulado = 0
and v.IdUsuarioPreventa = CASe @idVendedor when 0 then v.IdUsuarioPreventa else @idVendedor end
else
select *,cast(d.codigoSunat as varchar) + '-'+d.descripcion TipoDoc,dc.descripcion as D_DOC, c.nacionalidad
from mst_Venta v 
inner join mst_TipoDocumento d on v.CodigoTipoDoc = d.codigoSunat
INNER join mst_documentos dc on v.IdDocumento = dc.Codigo
inner join mst_Cliente c on v.IdCliente = c.Id
inner join mst_Usuarios us on v.IdUsuarioPreventa = us.Id
where cast(FechaEmision as date) between @fechainicio
and @fechafinal
and v.IdUsuarioPreventa = CASe @idVendedor when 0 then v.IdUsuarioPreventa else @idVendedor end
GO
/****** Object:  StoredProcedure [dbo].[spCargarVentasDetalle_Id]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarVentasDetalle_Id]
@id int,
@bit bit
as
if(@bit = 0)
begin
select 
pp.Id,
pd.codigoBarra,
vd.descripcion,
um.nombreUnidad,
um.Factor,
vd.Cantidad,
vd.PrecioUnit,
vd.Descuento,
vd.Subtotal,
vd.Igv,
vd.Total,
cast(vd.IdUnidad as varchar )+ '-' + cast(vd.Id as varchar) IdUnidad_IdDetalle,
pd.Id as IdDetalle,
Adicional1,
Adicional2,
Adicional3,
Adicional4,
vd.igv_incluido,
vd.IsCodBarraBusqueda
from mst_Venta_det vd
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
----
--
inner join mst_UnidadMedida um on vd.IdUnidad = um.Id
where IdVenta = @id 
--and Anulado = 0 
and vd.Flag = 1 
--and pp.flag = 1
--and pd.flag = 1
--and pd.estado = 1
--and p.estado = 1
--and p.flag = 1
end
else
select 
vd.IdProducto as Id,
vd.CodigoBarra,
vd.descripcion,
um.nombreUnidad,
um.Factor,
vd.Cantidad,
vd.PrecioUnit,
vd.Descuento,
vd.Subtotal,
vd.Igv,
vd.Total,
cast(vd.IdUnidad as varchar )+ '-' + cast(vd.Id as varchar) IdUnidad_IdDetalle,
1 as IdDetalle,
Adicional1,
Adicional2,
Adicional3,
Adicional4,
vd.igv_incluido,
vd.IsCodBarraBusqueda
from mst_Venta_det vd
----
--
inner join mst_UnidadMedida um on vd.IdUnidad = um.Id
where IdVenta = @id 
--and Anulado = 0 
and vd.Flag = 1 
--and pp.flag = 1
--and pd.flag = 1
--and pd.estado = 1
--and p.estado = 1
--and p.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spCargarVentasEditar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCargarVentasEditar]
@id int
as
select 
v.FechaEmision,
CAST(d.Codigo as varchar) +'-'+ d.Descripcion,
v.SerieDoc,
v.NumeroDoc,
v.DescripNotCred,
v.NumeroDocAfectado,
CAST(td.Id as varchar) +'-'+ td.descripcion,
c.Id,
v.DniRuc,
v.RazonSocial,
v.Direccion,
v.Email,
v.Observacion,
CAST(fp.Id as varchar)+'-'+ fp.FormadePago,
v.TotalVenta
from mst_Venta v
inner join mst_documentos d on v.IdDocumento = d.Codigo
inner join mst_TipoDocumento td on v.CodigoTipoDoc = td.Id
inner join mst_Cliente c on v.IdCliente = c.Id
inner join mst_FormaPago fp on v.IdFormaPago = fp.Id
where v.id =@id























































GO
/****** Object:  StoredProcedure [dbo].[spCerrar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCerrar]
@numero int,
@fechacierre datetime,
@idusuario int,
@idcaja int,
@contado DECIMAL(18,3),
@credito DECIMAL(18,3),
@tarjetas DECIMAL(18,3),
@otros_ingresos DECIMAL(18,3),
@gastos DECIMAL(18,3),
@total_efectivo DECIMAL(18,3),
@total_egreso DECIMAL(18,3),
@efectivo_declarado DECIMAL(18,3),
@diferencia DECIMAL(18,3)
as
update mst_apertura set Abierto_Cerrado = 1,
fechacierre = @fechacierre, Contado = @contado, Credito = @credito, tarjetas = @tarjetas, otros_ingresos = @otros_ingresos,
gastos = @gastos, total_efectivo = @total_efectivo, total_egreso = @total_egreso, efectivo_declarado = @efectivo_declarado,
diferencia = @diferencia
where  numero = @numero and IdUsuario = @idusuario and IdCaja = @idcaja

GO
/****** Object:  StoredProcedure [dbo].[spCerrarCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCerrarCompra]
@id int,
@onof bit
as
if(@onof = 0)
update mst_Compras set Estado = 0
where id = @id
else
update mst_Compras set Estado = 1
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spCerrarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCerrarInventario]
@id int,
@bit bit
as
if(@bit= 0 )
update mst_Inventario set Estado = 0
where id = @id
else 
update mst_Inventario set Estado = 1
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[SpCheckComprobantesPorEnviar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpCheckComprobantesPorEnviar]
as
SELECT 
CASE v.iddocumento
WHEN '01' THEN 'FE'
WHEN '03' THEN 'BV'
WHEN '07' THEN 'NC'
WHEN '08' THEN 'ND'
END AS Documento, 
CAST(v.FechaEmision as date) AS Fecha,
COUNT(v.Id) AS Cantidad
FROM mst_Venta v
LEFT JOIN tbl_info_cpe cpe
ON v.Id = cpe.id_cab_cpe
WHERE id_cab_cpe IS NULL AND v.IdDocumento <>'99' AND v.Anulado = 0 
--AND cpe.doc_firma = 0 AND cpe.doc_cdr = 0 --AND CAST(v.FechaEmision as date) BETWEEN '2021-11-01' AND '2021-11-15'
GROUP BY v.iddocumento,CAST(v.FechaEmision as date),cpe.id_cab_cpe
ORDER BY CAST(v.FechaEmision as date)
GO
/****** Object:  StoredProcedure [dbo].[spCheckDeudaXCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spCheckDeudaXCliente]
@idCliente int
as
declare @fecha_primera_deuda date = (
select top 1 CAST(FechaEmision as date) fecha from mst_Venta where IdCliente = @idCliente
and TotalVenta > ImportePagado
order by FechaEmision asc
) 

DECLARE @result int = DATEDIFF(day,@fecha_primera_deuda, cast(getdate() as date)) 
select ISNULL(@result, 0) as 'dias_atrasados'

GO
/****** Object:  StoredProcedure [dbo].[SpCheckLote]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpCheckLote]
as
select
ActivarLote
from tabla_configuracion_general

GO
/****** Object:  StoredProcedure [dbo].[SpCloseCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpCloseCompra]
@Id int,
@close bit
as
update mst_Compras set isclosed = @close
where Id = @Id
select @id as id

GO
/****** Object:  StoredProcedure [dbo].[spCodigoBarraImpresion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spCodigoBarraImpresion]
@idPresentacion int,
@isPresentacion bit
as
select top 1 
pd.id Id,
iif(@isPresentacion = 1, pp.Codigo, pd.CodigoBarra) as 'CodigoBarra',
concat(p.nombreProducto, pd.descripcion) Descripcion, 
um.nombreUnidad U_Medida,
um.factor Factor,
proveedor.nombre Proveedor,
pd.fechavencimiento F_Vence,
pp.precioUnitario Precio_Unit,
pp.idUnidad Id_Unidad,
p.Id Id_Producto,
pd.estado Estado,
ISNULL(stock.Saldo, 0) Stock,
pp.Id IdPresentacion,
stock.IdAlmacen IdAlmacen,
g.Descripcion Grupo,
g.Id idGrupo,
pd.stockminimo
from mst_ProductoPresentacion pp 
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.id
inner join mst_Producto p on pd.idProducto = p.id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Proveedor proveedor on p.idproveedor = proveedor.id
left join Stocks_Acumulados stock on pd.id = stock.IdProducto
inner join mst_Grupo g on p.IdGrupo = g.Id
WHERE pp.id = @idPresentacion
GO
/****** Object:  StoredProcedure [dbo].[spContador]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT v.SerieDoc,v.NumeroDoc,v.FechaEmision,v.TotalVenta,vd.descripcion FROM mst_Venta v
--INNER JOIN mst_Venta_det vd
--ON v.Id=vd.IdVenta
--WHERE CONVERT(varchar,v.FechaEmision,103) BETWEEN '01/10/2018' AND '31/10/2018'

------------------------------------------

------------------------------------------
CREATE proc [dbo].[spContador]
@fechainicio date,
@fechafin date
as
SELECT 
case v.IdDocumento
when '03' then '1'
when '01' then '2'
when '07' then '3'
when '08' then '4'
END Documento,
RTRIM(v.SerieDoc) Serie,
--cast(v.NumeroDoc as varchar) AS [Num],
RIGHT(Ltrim(Rtrim(CAST(v.NumeroDoc as varchar))),10) AS [Num],
CAST(v.FechaEmision AS DATE) AS FechaEmision,
IIF(v.DniRuc='00000000','0002',IIF(v.Anulado=1,'00002',RTRIM(v.DniRuc))) AS DniRuc,
dbo.f_promedio(IIF(v.RazonSocial='PUBLICO GENERAL','VENTAS DEL DIA',IIF(v.Anulado=1,'ANULADO',RTRIM(UPPER(v.RazonSocial))))) AS razon,
RTRIM(UPPER(v.Direccion))[Direccion],
'1' as Valor,
IIF(v.Anulado=0,cast(v.TotalVenta as decimal(18,2)),0.00) as Importe,
IIF(v.Anulado=0,'F'+CAST(vd.descripcion AS VARCHAR),'T'+CAST(vd.descripcion AS VARCHAR)) AS Tag
FROM mst_Venta v
INNER JOIN mst_Venta_det vd
ON v.Id=vd.IdVenta
AND (vd.id= (SELECT MIN(Id) FROM mst_Venta_det WHERE IdVenta=vd.IdVenta))
where 
cast(V.FechaEmision as date) BETWEEN @fechainicio and @fechafin
--convert(varchar, v.FechaEmision,3) >= convert(varchar, @fechainicio,3) 
--and convert(varchar, v.FechaEmision,3) <= convert(varchar, @fechafin,3)
order by v.IdDocumento, v.FechaEmision asc



















































GO
/****** Object:  StoredProcedure [dbo].[spContadorPedidos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spContadorPedidos]
@esconvenio bit
as
if(@esconvenio = 0)
	begin
		select max(IdPedido) from tabla_Pre_Venta
		where Proforma = 0
	end
else
	begin
	select max(idpedido) from tabla_Pre_Venta_Convenio	
	end
















































GO
/****** Object:  StoredProcedure [dbo].[spDeleteAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spDeleteAlmacen]
@id int
as
update almacen set estado = 0, flag = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteCliente]
@id int
as
update mst_Cliente set estado = 0, flag = 0
where Id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteClienteDireccion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteClienteDireccion]
@id int
as
update mst_Cliente_Direccion set Estado = 0, Flag = 0
where Id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeleteCompra]
@id int
as
update mst_Compras set Estado = 0, Flag = 0
where id = @id
select @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteCompraDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeleteCompraDetalle]
@id int
as
update mst_ComprasDetalles set Estado = 0, Flag = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteControlTransportistaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpDeleteControlTransportistaDetalle]
@id int
as
delete from ControlTransportistasDetalle 
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteInventario]
@id int
as
update Inventario set Estado = 0, Flag = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteInventarioDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteInventarioDetalle]
@id int
as
update InventarioDetalle set Estado= 0, Flag= 0
where Id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeletePedido]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeletePedido]
@id int
as
update tabla_Pre_Venta set Eliminado = 1
where Id = @id

update tabla_Pre_Venta_Detalle set Eliminado = 1
where IdPedido = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeletePedidosDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeletePedidosDetalles]
@id int
as
update tabla_Pre_Venta_Detalle set Eliminado = 1
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteProducto]
@id int
as
update Producto set estado = 0, flag = 0
where Id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeleteProductoDetalle]
@id int
as
update mst_ProductoDetalle set estado = 0, flag = 0
where Id = @id


update mst_ProductoPresentacion set estado = 0, flag = 0
where idProductosDetalle = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeleteProductoPresentacion]
@id int
as
update mst_ProductoPresentacion set estado = 0, flag = 0
where Id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteProductoPresentacionCodigoBarra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteProductoPresentacionCodigoBarra]
@id int
as
update ProductoPresentacionCodigoBarra set estado = 0, flag = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpDeleteProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpDeleteProveedor]
@id int
as
update mst_Proveedor set estado = 0, flag = 0
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteRestPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteRestPisos]
@id int
as
delete from tabla_RestPisos
where Id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpDeleteSeguimiento]
@id int,
@idVenta int
as
update tbl_Seguimiento set Eliminado = 1
where id = @id

exec spIrCancelando_Deuda_Seguimiento @idVenta
SELECT @id
GO
/****** Object:  StoredProcedure [dbo].[SpDeleteUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpDeleteUsuario]
@id int
as
update mst_Usuarios set estado = 0, flag = 0
where Id = @id

GO
/****** Object:  StoredProcedure [dbo].[spDeleteVentaCronograma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spDeleteVentaCronograma]
@id int
as
update venta_cronograma set estado = 0, flag = 0
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[spEliminarAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE proc [dbo].[spEliminarAlmacen]
@id int
as
update mst_Almacen set estado = 0,flag=0
where id=@id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--eliminar
CREATE procedure [dbo].[spEliminarCliente]
@idCliente int
as
update mst_Cliente set
flag = 0, estado = 0
where id = @idCliente























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--eliminar
CREATE proc [dbo].[spEliminarColor]
@id int
as
update mst_Color set
estado = 0, flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------
CREATE proc [dbo].[spEliminarCompra]
@id int
as
update mst_Compras set Estado = 0, Flag = 0
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarCompraDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarCompraDetalle]
@id int
as
update mst_ComprasDetalles set Estado = 0, Flag = 0
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarDetalle]
@id int
as
declare @precio money
declare @idventa int
-------------------------------------------------------------------
update mst_Venta_det set
Flag = 0, Anulado = 1
where id = @id
-------------------------------------------------------------------
set @precio = (select Subtotal from mst_Venta_det where id = @id)
set @idventa = (select IdVenta from mst_Venta_det where id = @id)
update mst_Venta set
TotalVenta = TotalVenta - @precio
where Id = @idventa

update tabla_FormaPago set Total = Total - @precio
where IdVenta = @idventa

exec spEliminarVenta_Det_Ext @id

exec SpStockActualizarAlEliminarItemVenta @id

























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarDirecciones]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarDirecciones]
@id int
as
update mst_Cliente_Direccion set
Estado = 0,
Flag = 0
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarDoc_Serie_Usuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarDoc_Serie_Usuario]
@id int
as
update mst_Doc_Serie_Usuario set Estado = 0, flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarDocSerie]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarDocSerie]
@id int
as
update mst_Doc_Serie set Estado =0,Flag = 0
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarFamilia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------

---------------------------------------------------
---Procedimiento de Almacenado Eliminar 
CREATE procedure [dbo].[spEliminarFamilia]
@id int
as
update mst_Familia set flag = 0, estado = 0
where id=@id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarGasto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarGasto]
@id int
as
update mst_GastosOperativos set
eliminado = 1
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarGrupo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
--ELIMINAR GRUPO
CREATE procedure [dbo].[spEliminarGrupo]
@idGrupo int
as
update mst_Grupo
set flag = 0 , estado = 0
where id=@idGrupo























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarGuiaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarGuiaDetalle]
@id int
as
update mst_Guia_det set Anulado = 1, flag = 0
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE proc [dbo].[spEliminarInventario]
@id int
as
update mst_Inventario set estado = 0,flag=0
where id=@id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarInventario_Detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
--
CREATE proc [dbo].[spEliminarInventario_Detalle]
@id int
as
update mst_Inventario_Detalle set Flag=0
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarLinea]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
--ELIMINAR LINEA
CREATE procedure [dbo].[spEliminarLinea]
@idLinea int
as
update mst_Linea
set flag = 0 , estado = 0
where id=@idLinea























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarMarca]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------------

----------------------Eliminar----------------------------
CREATE procedure [dbo].[spEliminarMarca]
@idMarca int
as
update mst_Marca set
flag = 0, estado = 0
where id=@idMarca























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------
CREATE proc [dbo].[spEliminarMedidas]
@id int
as
update mst_Medidas set estado = 0,
flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarPiso]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarPiso]
@id int
as
delete from tabla_RestPisos
where NumPiso = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarPreDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarPreDetalle]
@id int,
@pm bit,
@esconvenio bit
as
declare @subtotal money
declare @idpedido int
declare @idmesa int

if(@esconvenio = 0)
	begin
		set @subtotal =  (select Subtotal from tabla_Pre_Venta_Detalle where Id = @id)
		set @idpedido = (select IdPedido from tabla_Pre_Venta_Detalle where id = @id)
		set @idmesa= (select idmesa from tabla_Pre_Venta_Detalle where id = @id)

		if(@pm = 0)
		begin
		update tabla_Pre_Venta set Total = (Total - @subtotal)
		where IdPedido = @idpedido
		end
		else
		begin
		update tabla_Pre_Venta set Total = (Total - @subtotal)
		where IdMesa = @idmesa
		end

		delete from tabla_Pre_Venta_Detalle where Id = @id
	end
else
	begin
	set @subtotal =  (select Subtotal from tabla_Pre_Venta_Detalle_Convenio where Id = @id)
	set @idpedido = (select IdPedido from tabla_Pre_Venta_Detalle_Convenio where id = @id)
	set @idmesa = (select idmesa from tabla_Pre_Venta_Detalle_Convenio where id = @id)

	if(@pm = 0)
	begin
	update tabla_Pre_Venta_Convenio set Total = (Total - @subtotal)
	where Id = @idpedido
	end
	 

	delete from tabla_Pre_Venta_Detalle_Convenio where Id = @id
	--update tabla_Pre_Venta_Detalle set Eliminado = 1
	--where Id = @id

	end



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarPreVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarPreVenta]
@id int,
@bit bit,
@idpiso int,
@esconvenio bit
as
if(@bit = 0)
begin
if(@esconvenio = 0)
	begin
		delete from tabla_Pre_Venta where idpedido = @id and Pagado = 0
		delete from tabla_Pre_Venta_Detalle where IdPedido = @id and Pagado = 0
	end
else
	begin
		delete from tabla_Pre_Venta_Convenio where Id = @id and Pagado = 0
		delete from tabla_Pre_Venta_Detalle_Convenio where IdPedido = @id and Pagado = 0
	end
end
else
delete from tabla_Pre_Venta where IdMesa = @id and IdPiso =@idpiso and Pagado = 0
delete from tabla_Pre_Venta_Detalle where IdMesa = @id and IdPiso = @idpiso and Pagado = 0



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------

-----------eliminar------------------
CREATE procedure [dbo].[spEliminarProducto]
@id int
as

update mst_Producto
set flag = 0,  estado = 0
where id = @id

update mst_ProductoDetalle
set flag = 0, estado = 0 
where idProducto = @id
--from mst_ProductoDetalle ppd
--inner join (select pd.id from mst_ProductoDetalle pd where pd.idProducto = @id) as tablaAux on
--tablaAux.id = ppd.id


update mst_ProductoPresentacion
set flag = 0, estado = 0 
from mst_ProductoPresentacion pp inner join (select id from mst_ProductoDetalle  where idProducto = @id) as tablaAux on
tablaAux.id = pp.idProductosDetalle























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--eliminar
CREATE proc [dbo].[spEliminarProductoDetalle]
@id int
as
update mst_ProductoDetalle set
estado = 0, flag = 0
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
---exec spModificarProductoPresentacion 2,'dede',22,'maick.davila',1,1
--exec spModificarProductoPresentacion 1,'cuarto',12,'maick.davila',0,1
--exec spBuscarProductoPresentacion 1
--eliminar
CREATE proc [dbo].[spEliminarProductoPresentacion]
@id int
as
update mst_ProductoPresentacion set
estado = 0,flag = 0
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarProforma]
@id int
as
update tabla_Proforma set Eliminado = 1
where Id = @id

update tabla_Proforma_Detalle 
set Eliminado = 1
where IdProforma = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProformaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarProformaDetalle]
@id int
as
delete from tabla_Proforma_Detalle 
where id = @id


















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------

CREATE proc [dbo].[spEliminarProveedor]
@id int
as
update mst_Proveedor set estado = 0, flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarPulso]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarPulso]
@nombre varchar(100)
as
delete from tabla_pulsos 
where NombreUsuario =@nombre



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spEliminarSeguimiento]
@id int,
@idventa int
as

delete from tbl_Seguimiento where Id = @id

exec spIrCancelando_Deuda_Seguimiento @idventa



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarSeguimientoCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarSeguimientoCompra]
@id int,
@idcompra int
as

delete from tbl_SeguimientoCompra where Id = @id

exec spIrCancelando_Deuda_SeguimientoCompra @idcompra
GO
/****** Object:  StoredProcedure [dbo].[spEliminarSerie]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spEliminarSerie]
@id int
as

update mst_Serie set Flag = 0 ,Estado = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarServidor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spEliminarServidor]
@id int
as
delete from MST_SERVIDORES
where id= @id


















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarTalla]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--eliminar
CREATE proc [dbo].[spEliminarTalla]
@id int
as
update mst_Talla set 
estado = 0, flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarTipoUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarTipoUsuario]
@id int
as
update mst_TipoUsuario set flag = 0,estado = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------
CREATE proc [dbo].[spEliminarTransportista]
@id int
as
update mst_Transportistas set estado = 0, flag = 0
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarUnidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------
-----------------eliminar unidad-------------
CREATE procedure [dbo].[spEliminarUnidad]
@id int
as
update mst_UnidadMedida set flag = 0, estado = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEliminarUsuario]
@id int
as
update mst_Usuarios set
estado = 0, flag = 0
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spEliminarVenta_Det_Ext]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spEliminarVenta_Det_Ext]
@idventadet int
as
delete from tabla_Venta_Det_Ext
where IdVenta_Det = @idventadet



















































GO
/****** Object:  StoredProcedure [dbo].[spEliminarVenta_Ext]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------
CREATE proc [dbo].[spEliminarVenta_Ext]
@idventa int
as
delete from tabla_Venta_Ext 
where idventa = @idventa

delete from tabla_venta_det_ext
where IdVenta = @idventa



















































GO
/****** Object:  StoredProcedure [dbo].[spEnviarPulsos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEnviarPulsos]
@nombre varchar(100),
@piso int,
@mesa int
as
if((select count(*) from tabla_pulsos where NombreUsuario = @nombre and IdPiso = @piso)>0)
	begin
	update tabla_pulsos set IdMesa = @mesa
	where NombreUsuario = @nombre and IdPiso = @piso
	end
	else
	begin
	insert into tabla_pulsos
	values(@nombre,@piso,@mesa)
	end



















































GO
/****** Object:  StoredProcedure [dbo].[SpFilterMasterProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpFilterMasterProductos]
@text varchar(max),
@idGrupo int,
@desactivados bit,
@idAlmacen int
as
select top 30
Id,
Id_Producto 'IdProducto',
IdPresentacion 'IdProductoPresentacion',
Cod_Barra 'CodigoBarra',
Descripcion 'NombreProducto',
U_Medida 'Unidad',
Factor,
Proveedor,
F_Vence 'FechaVence',
Precio_Unit 'Precio',
Estado,
Stock,
Grupo,
stockminimo 'StockMinimo'
from vw_FiltroMstProductos
where (Descripcion like '%'+@text+'%' or Cod_Barra like '%'+@text+'%')
and idGrupo = CASe @idgrupo when 0 then idGrupo else @idgrupo end
and Estado = CASe @desactivados when 0 then 1 else 0 end
and IdAlmacen = @idAlmacen
order by id desc
GO
/****** Object:  StoredProcedure [dbo].[SpFilterProductoVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpFilterProductoVenta]
@text varchar(max),
@idAlmacen int
as
select top 20 * from ViewProductoVenta
where NombreProducto like CONCAT('%', @text, '%')
and IdAlmacen = @idAlmacen
order by IsPrincipal desc
GO
/****** Object:  StoredProcedure [dbo].[SpFilterProductoVentaByCodigoBarraId]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpFilterProductoVentaByCodigoBarraId]
@codigoBarra varchar(max),
@idProductoPresentacion int,
@idAlmacen int
as
if @idProductoPresentacion = 0
begin
	select top 20 * from ViewProductoVenta
	where CodigoBarra = @codigoBarra
	and IdAlmacen = @idAlmacen
	order by IsPrincipal desc
end
else
begin
	select top 20 * from ViewProductoVenta
	where IdProductoPresentacion = @idProductoPresentacion
	and IdAlmacen = @idAlmacen
	order by IsPrincipal desc
end
GO
/****** Object:  StoredProcedure [dbo].[SpFilterProductoVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpFilterProductoVentas]
@text varchar(100),
@idAlmacen int,
@idProductoPresentacion int = 0
as
declare @top int = 25
if @idProductoPresentacion > 0
begin
	set @text = ''
	set @top = 1
end
select top (@top)
Id, 
C_Interno 'IdDetalle',
IdProducto,
Cod_Barra 'CodigoBarra',
Descripcion,
U_Medida 'Unidad',
Factor,
Proveedor,
Stock_Actual 'StockActual',
F_Vencimiento 'FechaVencimiento',
Precio_Unit 'Precio',
idUnidad 'IdUnidad',
IdAlmacen,
principal 'Principal'
from vw_FiltroProductos
where idalmacen = @idAlmacen and  
(Id = case @idProductoPresentacion when 0 then Id else @idProductoPresentacion end) 
and (Descripcion like '%'+@text+'%' or @text = Codigo)
order by Id, Descripcion, principal desc
GO
/****** Object:  StoredProcedure [dbo].[spFormato_Rest]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spFormato_Rest]
@id int,
@idpiso int
as

select * from
(
select temp.*,
g.Descripcion as [Grupo],
g.id as [IdGrupo],
iif(temp.IdMesa >= 500 and temp.IdMesa <1000,'Para Llevar N° ' + cast(temp.numsecuencia as varchar),'Mesa N° '+ ' ' + cast(temp.IdMesa as varchar)) as 'Mesa',
us.nombre as 'Mozo',
cast(temp.Descripcion as varchar) + ' ('+g.Descripcion+')' as 'Descripcion_Grupo',
pv.countPecho,
pv.countPierna,
pv.textObservation
from tabla_Pre_Venta_Detalle_Temp temp
inner join mst_ProductoPresentacion pp on temp.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
inner join mst_Grupo g on p.IdGrupo = g.Id
inner join mst_Usuarios us on temp.IdUsuario = us.Id
inner join tabla_Pre_Venta pv on temp.IdMesa = pv.IdMesa
where temp.IdPiso = @idpiso and temp.IdMesa = @id
and temp.Pagado = 0
and temp.Eliminado = 0
and pv.Pagado = 0 
and pv.Eliminado = 0
) as temporal
GO
/****** Object:  StoredProcedure [dbo].[spFormatoConvenio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spFormatoConvenio]
@id int
as
select c.Id,c.IdPedido,c.CodigoDoc,c.IdCliente,c.DniRuc,c.RazonSocial,
c.Direccion,u.nombre as IdUsuario,c.BolFac,c.sub_total,c.igv,c.Descuento,c.Total,
c.Beneficiario,c.IdConvenio,mc.Razon,c.IdParentesco,p.Descripcion as parentesco,c.Fecha,
dc.Descripcion,dc.Cantidad,dc.Precio,dc.Subtotal,dc.Total as TotalDet
from tabla_Pre_Venta_Convenio c
inner join mst_convenios mc on mc.Id = c.IdConvenio
inner join tabla_Pre_Venta_Detalle_Convenio dc on c.Id = dc.IdPedido
inner join Parentesco p on p.Id = c.IdParentesco
inner join mst_Usuarios u on u.Id = c.IdUsuario
where c.Id = @id
GO
/****** Object:  StoredProcedure [dbo].[spFormatoGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spFormatoGuia]
@id int
as
SELECT a.*,
b.CodigoBarra,
b.descripcion,
um.nombreUnidad,
b.Cantidad,
b.Peso,
d.Descripcion,
e.Nombre,
e.dniruc,
e.Licencia,
e.Direccion,
e.Telefono,
e.Email,
f.descripcion
FROM mst_Guia a
INNER JOIN mst_Guia_det b ON a.Id=b.IdGuia
inner join mst_UnidadMedida um on b.IdUnidad = um.Id
INNER JOIN mst_TipoDocumento c ON c.codigoSunat=a.CodigoTipoDoc
INNER JOIN mst_documentos d ON d.codigo=a.IdDocumento
INNER JOIN mst_Transportistas e ON e.Id=a.IdTrasnportista
inner join mst_motivo_guia f on f.id=a.IdMotivo
where a.Id = @id and a.Anulado = 0 and b.Anulado = 0
--and e.Estado = 1 and e.Flag = 1 and B.Anulado = 0
--and b.Anulado = 0




















































GO
/****** Object:  StoredProcedure [dbo].[spFormatoPreCuenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spFormatoPreCuenta]
@idmesa int,
@idpiso int
as
select a.IdPiso,a.IdMesa,a.Total,b.Cantidad,b.Descripcion,b.Precio,b.Total 
from tabla_Pre_Venta a
inner join tabla_Pre_Venta_Detalle b
on a.IdMesa=@idmesa and a.IdPiso = @idpiso and b.IdMesa = @idmesa and b.IdPiso = @idpiso and a.Pagado = 0 and a.Eliminado = 0 and b.Pagado = 0 and
b.Eliminado = 0


















































GO
/****** Object:  StoredProcedure [dbo].[spFormatoproforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spFormatoproforma]
@id int
as
SELECT *,dbo.fn_ConvertirNumeroLetra(a.Total,'Soles') as TotalLetras FROM tabla_Proforma a
INNER JOIN tabla_Proforma_Detalle b ON a.id=b.idproforma
INNER JOIN mst_TipoDocumento c ON c.codigoSunat=a.CodigoDoc
INNER JOIN mst_documentos d ON d.codigo=a.BolFac
inner join mst_Usuarios e on e.id = a.IdUsuario
where a.Id = @id and a.Eliminado = 0 and b.Eliminado = 0


















































GO
/****** Object:  StoredProcedure [dbo].[SpGetAllBarCodes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetAllBarCodes]
as
select 
Id 'IdProductoDetalle',
0 'IdProductoPresentacion',
codigoBarra
from mst_ProductoDetalle
where estado = 1 and flag = 1
union all
select
0 'IdProductoDetalle',
Id 'IdProductoPresentacion',
Codigo
from mst_ProductoPresentacion
where estado = 1 and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetAlmacen]
as
select * from mst_Almacen
where Estado = 1 and Flag = 1;
GO
/****** Object:  StoredProcedure [dbo].[SpGetAlmacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetAlmacenTraslado]
@dateini date,
@datefin date,
@text varchar(250)
as
select 
at.id,
fecha,
descripcion,
cerrado,
at.estado,
at.flag,
serie,
numero,
ass.Id 'IdAlmacenSalida',
ass.Nombre 'AlmacenSalidaNombre',
ae.Id 'IdAlmacenEntrada',
ae.Nombre 'AlmacenEntradaNombe',
at.total
from mst_almacen_traslado at
inner join mst_Almacen ae on at.idAlmacenEntrada = ae.Id
inner join mst_Almacen ass on at.idAlmacenSalida = ass.Id
where CAST(at.fecha as date) between @dateini and @datefin
and (ae.Nombre like CONCAT('%',@text,'%') or ass.Nombre like CONCAT('%',@text,'%'))
order by id desc
GO
/****** Object:  StoredProcedure [dbo].[SpGetAlmacenTrasladoById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetAlmacenTrasladoById]
@id int
as
select 
at.id,
fecha,
descripcion,
cerrado,
at.estado,
at.flag,
serie,
numero,
ae.Id 'IdAlmacenEntrada',
ae.Nombre 'AlmacenEntradaNombe',
ass.Id 'IdAlmacenSalida',
ass.Nombre 'AlmacenSalidaNombre',
at.total
from mst_almacen_traslado at
inner join mst_Almacen ae on at.idAlmacenEntrada = ae.Id
inner join mst_Almacen ass on at.idAlmacenSalida = ass.Id
where at.id = @id
order by id desc

GO
/****** Object:  StoredProcedure [dbo].[SpGetAlmacenTrasladoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetAlmacenTrasladoDetalle]
@idAlmacenTraslado int
as
select
id,
idProducto,
nombreProducto,
idUnidad,
nombreUnidad,
factor,
cantidad,
estado,
flag,
almacen_traslado_id 'IdAlmacenTraslado',
precio,
total
from mst_almacen_traslado_detalle
where almacen_traslado_id = @idAlmacenTraslado
and Estado =1 and Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spGetApertura]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetApertura]
as
select * from mst_Apertura

GO
/****** Object:  StoredProcedure [dbo].[SpGetBaseConfig]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetBaseConfig]
as
select * 
from BaseConfig
GO
/****** Object:  StoredProcedure [dbo].[SpGetCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetCliente]
@text varchar(max)
as
select top 20
c.Id,
idDocumento 'IdDocumento',
td.descripcion 'Documento',
numeroDocumento 'NumeroDocumento',
razonSocial 'RazonSocial',
cd.Direccion 'Direccion',
telefono 'Telefono',
correo 'Correo',
ISNULL(delivery, 0) 'Delivery',
ISNULL(nacionalidad, 1) 'Nacionalidad',
DefaultPago 'DefaultPago'
from mst_Cliente c 
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where CONCAT(razonSocial, ' ', numeroDocumento, '') like CONCAT('%',@text,'%')
and c.estado = 1 and c.flag = 1
and cd.Principal = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetClienteById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetClienteById]
@id int
as
select top 1
c.Id,
idDocumento 'IdDocumento',
td.descripcion 'Documento',
numeroDocumento 'NumeroDocumento',
razonSocial 'RazonSocial',
cd.Direccion 'Direccion',
telefono 'Telefono',
correo 'Correo',
ISNULL(delivery, 0) 'Delivery',
ISNULL(nacionalidad, 1) 'Nacionalidad',
DefaultPago 'DefaultPago'
from mst_Cliente c 
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where c.estado = 1 and c.flag = 1
and cd.Principal = 1
and c.id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpGetClienteByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetClienteByIdVenta]
@idVenta int
as
    select c.* from mst_Venta m
    inner join mst_cliente c on m.IdCliente = c.id
    where m.id = @idVenta
GO
/****** Object:  StoredProcedure [dbo].[SpGetClienteDireccionByIdCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetClienteDireccionByIdCliente]
@idCliente int
as
select * from mst_Cliente_Direccion
where IdCliente = @idCliente and Estado = 1 and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetCodigosBarrasByIdProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[SpGetCodigosBarrasByIdProducto]
@idProductoPresentacion int
as
select * from ProductoPresentacionCodigoBarra
where idProductoPresentacion = @idProductoPresentacion
and estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetColor]
as
select
Id,
descripcion
from mst_Color
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[SpGetCompras]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetCompras]
@text varchar(max),
@fechaInit date,
@fechaFin date
as
select
c.id as 'Id',
IIF(c.TipoDoc = '01', 'Factura', 'Boleta') as 'Documento',
a.Nombre as 'Almacen',
fp.FormadePago as 'FormaPago',
CONCAT(Serie, '-', Numero) as 'Serie',
c.RazonSocial as 'Proveedor',
c.Direccion,
c.Telefono,
c.FechaEmision,
c.Subtotal,
c.TotalIgv,
c.Totaldescuento as 'TotalDescuento',
c.Total,
c.ImportePagado,
c.UsuarioCrea,
IIF(c.Total > c.ImportePagado, cast(1 as bit), cast(0 as bit)) as 'Deuda',
c.isclosed as 'Closed'
from mst_Compras c
inner join mst_Almacen a on c.IdAlmacen = a.Id
inner join mst_FormaPago fp on c.FormaPago = fp.Id
where c.Estado = 1 and  c.Flag = 1
and FechaEmision between @fechaInit and @fechaFin
and 
(CONCAT(Serie, Numero) like CONCAT('%', @text, '%')
or c.RazonSocial like CONCAT('%', @text, '%'))
order by c.id desc
GO
/****** Object:  StoredProcedure [dbo].[SpGetComprasById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetComprasById]
@Id int
as
select * from mst_Compras
where id = @Id

GO
/****** Object:  StoredProcedure [dbo].[SpGetComprasDetallesByIdCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetComprasDetallesByIdCompra]
@idCompra int
as
select * from mst_ComprasDetalles
where IdCompra = @idCompra and Estado = 1 and Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetConfiguracionGeneral]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetConfiguracionGeneral]
as
select
Ruc,
razonsocial 'RazonSocial',
nombrecomercial 'NombreComercial',
direccion 'Direccion',
telefono 'Telefono',
celular 'Celular',
web 'Web',
correo 'Correo',
marca 'Marca',
grupo_linea_familia 'GrupoLineaFamilia',
talla 'Talla',
color 'Color',
medida 'Medida',
descripcion 'Descripcion',
f_vence 'FechaVence',
proveedor 'Proveedor',
visa 'Visa',
mastercard 'Mastercard',
Logo 'Logo',
impresora1 'Impresora1',
impresora2 'Impresora2',
ubigeo 'Ubigeo',
ciudad 'Ciudad',
distrito 'Distrito',
igv 'Igv',
Certificado_CPE 'CertificadoCpe',
ContraseniaCertificadoCpe,
UsuarioSecundarioSol,
ContraseniaUsuarioSecundarioSol,
Validar_Vendedor 'ValidarVendedor',
ModoRapido 'ModoRapido',
CodBarra 'CodigoBarra',
NumCopias 'NumeroCopias',
NumMesas 'NumeroMesas',
Produccion,
PassCorreo,
Met_Busqueda 'MetodoBusqueda',
UrlOse,
TipoOse,
UrlOseBeta,
UrlOseOtros,
UrlOseOtrosBeta,
UrlOseAux,
UrlOseAuxBeta,
TipoMoneda,
Puerto,
Ssl,
Servidor_Email 'ServidorEmail',
Nube,
Id,
hora_envio 'HoraEnvio',
pago_defecto 'PagoEfectivo',
id_api_sunat 'IdApiSunat',
clave_api_sunat 'ClaveApiSunat',
ruta_copia_bd 'RutaCopiaBd',
CodigoAnexo,
ActivarLote,
EntradaDirectaProducto,
DocumentoVentaDefecto,
ActivarBalanza,
AlertaSunat
from tabla_configuracion_general
GO
/****** Object:  StoredProcedure [dbo].[SpGetConrolTransportisaDetalleByIdControlTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetConrolTransportisaDetalleByIdControlTransportista]
@idControlTransportista int
as
select *, fp.FormadePago 'FormaPago' from ControlTransportistasDetalle cd
inner join mst_FormaPago fp on cd.IdFormaPago = fp.Id
where IdControlTransportista = @idControlTransportista
GO
/****** Object:  StoredProcedure [dbo].[spGetControlTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetControlTransportista]
@fecha date
as
select
ct.Id,
ct.TransportistaId,
t.DniRuc 'Dni',
t.Nombre,
ct.HoraSalida,
ct.HoraLlegada,
ct.Observacion,
ct.IsClosed,
ct.Total
from ControlTransportistas ct 
inner join mst_Transportistas t on ct.TransportistaId = t.Id
where CAST(HoraSalida as date) = cast(@fecha as date)
GO
/****** Object:  StoredProcedure [dbo].[SpGetControlTransportistaByDni]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetControlTransportistaByDni]
@dni int
as
select
ct.Id,
ct.TransportistaId,
t.DniRuc 'Dni',
t.Nombre,
ct.HoraSalida,
ct.HoraLlegada,
ct.Observacion,
ct.IsClosed,
ct.Total
from ControlTransportistas ct 
inner join mst_Transportistas t on ct.TransportistaId = t.Id
where t.DniRuc = @dni
GO
/****** Object:  StoredProcedure [dbo].[SpGetControlTransportistaById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetControlTransportistaById]
@id int
as
select
ct.Id,
ct.TransportistaId,
t.DniRuc 'Dni',
t.Nombre,
ct.HoraSalida,
ct.HoraLlegada,
ct.Observacion,
ct.IsClosed,
ct.Total
from ControlTransportistas ct 
inner join mst_Transportistas t on ct.TransportistaId = t.Id
where ct.id = @id
order by ct.IsClosed
GO
/****** Object:  StoredProcedure [dbo].[SpGetDocumentoClienteVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetDocumentoClienteVenta]
as
select
Id,
descripcion 'Descripcion',
codigoSunat 'Codigo'
from mst_TipoDocumento
where estado = 1 and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spGetDocumentoFacturacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetDocumentoFacturacion]
as
SELECT
id,
codigo,
descripcion,
estado
from mst_documentos
where Estado = 1 and Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetDocumentoVentaDefecto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetDocumentoVentaDefecto]
as
select * from tabla_configuracion_general

GO
/****** Object:  StoredProcedure [dbo].[SpGetEntradaDirectaProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetEntradaDirectaProducto]
as
select EntradaDirectaProducto from tabla_configuracion_general

GO
/****** Object:  StoredProcedure [dbo].[SpGetGrupos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetGrupos]
as
select 
id,
Descripcion
from mst_Grupo
where Estado = 1 and Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetIdDetalleByIdPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpGetIdDetalleByIdPresentacion]
@idProductoPresentacion int
as
select top 1 idProductosDetalle as 'IdProductoDetalle' from mst_ProductoPresentacion
where id = @idProductoPresentacion
GO
/****** Object:  StoredProcedure [dbo].[spGetIdentificacionGrupoProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetIdentificacionGrupoProducto]
as
select * from IdentificadorGrupoProducto
where estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetInventario]
@idAlmacen int
as
select * from Inventario
where Estado=1 and Flag = 1
and IdAlmacen = case when @idAlmacen > 0 then @idAlmacen else IdAlmacen end

GO
/****** Object:  StoredProcedure [dbo].[SpGetInventarioById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpGetInventarioById]
@id int
as
select * from Inventario
where id=@id and Estado = 1 and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetInventarioDetalleById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpGetInventarioDetalleById]
@id int
as
select * from InventarioDetalle
where IdInventario = @id and Estado = 1
and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetInventarioDetalleByIdInvenario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpGetInventarioDetalleByIdInvenario]
@idInventario int
as
select * from InventarioDetalle
where IdInventario = @idInventario and Estado = 1
and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[spGetListUsuariosAperturasDelDia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetListUsuariosAperturasDelDia]
as
SELECT
upper(u.usuario) as Usuario,
Numero,
IdUsuario,
IdCaja
FROM mst_Apertura a
inner join mst_Usuarios u on a.IdUsuario = u.Id
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where 
CAST(Fecha as date) <= CAST(GETDATE() as date)
and Abierto_Cerrado = 0 
and (LOWER(tu.descripcion) = 'cajero' or LOWER(tu.descripcion) = 'caja')
and u.verVentas = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetMarcas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetMarcas]
as
select
Id,
nombreMarca as 'Descripcion'
from mst_Marca
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[SpGetMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetMedidas]
as
select
Id,
descripcion
from mst_Medidas
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[SpGetNacionalidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetNacionalidad]
as
select * from nacionalidad

GO
/****** Object:  StoredProcedure [dbo].[SpGetNextNumeroForAlmacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetNextNumeroForAlmacenTraslado]
as
declare @count int = (select COUNT(id) from mst_almacen_traslado)
if @count = 0
begin
	select 1
end
else
begin
	select
	top 1
	ISNULL(numero+1, 1) as numero
	from mst_almacen_traslado
	order by id desc
end

GO
/****** Object:  StoredProcedure [dbo].[SpGetOses]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetOses]
as
select
Id,
NumOse 'Numero',
Nombre,
Url_1 'Url1',
Url_1_Beta 'Url1Beta',
Url_2 'Url2',
Url_2_Beta 'Url2Beta',
Url3 'Url3',
Url3_Beta 'Url3Beta'
from mst_Oses
GO
/****** Object:  StoredProcedure [dbo].[SpGetPedidos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetPedidos]
as
select
Id,
IdPedido,
IdMesa,
CodigoDoc,
IdCliente,
DniRuc,
RazonSocial,
Direccion,
Email,
Pagado,
Eliminado,
IdUsuario,
BolFac,
sub_total 'SubTotal',
igv 'Igv',
Descuento,
Total,
Idalmacen,
Proforma,
IdPiso,
NumSecuencia,
PreCuenta,
Otro_Imp 'OtrosImpuestos',
Adicional,
Beneficiario,
IdConvenio,
IdParentesco,
Fecha,
is_llevar 'IsLlevar',
is_delivery 'IsDelivery',
ISNULL(countPecho, 0) 'CountPecho',
ISNULL(countPierna, 0) 'CountPierna',
textObservation 'TextObservacion',
OperacionExonerada
from tabla_Pre_Venta
GO
/****** Object:  StoredProcedure [dbo].[SpGetPedidosById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetPedidosById]
@id int
as
select
Id,
IdPedido,
IdMesa,
CodigoDoc,
IdCliente,
DniRuc,
RazonSocial,
Direccion,
Email,
Pagado,
Eliminado,
IdUsuario,
BolFac,
sub_total 'SubTotal',
igv 'Igv',
Descuento,
Total,
Idalmacen,
Proforma,
IdPiso,
NumSecuencia,
PreCuenta,
Otro_Imp 'OtrosImpuestos',
Adicional,
Beneficiario,
IdConvenio,
IdParentesco,
Fecha,
is_llevar 'IsLlevar',
is_delivery 'IsDelivery',
ISNULL(countPecho, 0) 'CountPecho',
ISNULL(countPierna, 0) 'CountPierna',
textObservation 'TextObservacion',
OperacionExonerada
from tabla_Pre_Venta
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpGetPedidosDetallesByIdPedido]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetPedidosDetallesByIdPedido]
@idPedido int
as
select
Id,
IdPedido,
IdMesa,
IdProducto,
Descripcion,
CodigoBarra,
UMedida 'Unidad',
Cantidad,
Precio,
Subtotal,
igv 'Igv',
Descuento,
total 'Total',
Pagado,
Eliminado,
Factor,
IdUnidad,
IdPiso,
NumSecuencia,
Adicional1,
Adicional2,
Adicional3,
Adicional4,
igv_incluido 'IgvIncluido',
IsCodBarraBusqueda,
IdProductoDetalle
from tabla_Pre_Venta_Detalle pd
where Eliminado = 0 and Id = @idPedido
GO
/****** Object:  StoredProcedure [dbo].[SpGetPreciosByIdProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetPreciosByIdProductoDetalle]
@idProductoDetalle int
as
select
pp.Id,
pp.idProductosDetalle 'IdProductoDetalle',
pp.idUnidad 'IdUnidad',
iif(pp.Codigo = '' or pp.Codigo is null, pd.CodigoBarra, pp.Codigo) 'CodigoBarra',
um.nombreUnidad 'Unidad',
um.factor 'Factor',
pp.precioUnitario 'Precio',
pp.Principal 'IsPrincipal',
pp.PrincipalAlmacen 'IsPrincipalAlmacen'
from mst_ProductoPresentacion pp
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
where idProductosDetalle = @idProductoDetalle
and pp.estado = 1 and pp.flag = 1
order by pp.Principal desc

GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoById]
@id int
as
select
Id,
nombreProducto 'NombreProducto',
idMarca 'IdMarca',
idproveedor 'IdProveedor',
IdTipoProducto 'IdTipoProducto',
IdGrupo,
estado 'Estado'
from mst_Producto
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoByIdOldForImport]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoByIdOldForImport]
@idOldImport int
as
select * from Producto
where idOldImport = @idOldImport

GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoConstulasPrecio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoConstulasPrecio]
@text varchar(250)
as
SELECT top 20
Descripcion 'Nombre',
U_Medida 'Unidad',
Precio_Unit 'Precio'
FROM vw_FiltroProductos
where Descripcion like CONCAT('%', @text, '%')
ORDER BY IdProducto, principal DESC
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoDetalleById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoDetalleById]
@id int
as
select 
pd.Id,
idProducto 'IdProducto',
idTalla 'IdTalla',
t.descripcion 'Talla',
idColores 'IdColor',
c.descripcion 'Color',
stockminimo 'StockMinimo',
fechavencimiento 'FechaVence',
pd.descripcion 'Descripcion',
codigoBarra 'CodigoBarra',
pd.estado 'Estado',
idmedida 'IdMedida',
m.descripcion 'Medida',
checkStock 'CheckStock'
from mst_ProductoDetalle pd
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_Medidas m on pd.idmedida = m.id
where pd.Id = @id and pd.estado = 1 and pd.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoDetalleByIdProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoDetalleByIdProducto]
@idProducto int
as
select 
Id,
idProducto 'IdProducto',
idTalla 'IdTalla',
idColores 'IdColor',
stockminimo 'StockMinimo',
fechavencimiento 'FechaVence',
descripcion 'Descripcion',
codigoBarra 'CodigoBarra',
estado 'Estado',
idmedida 'IdMedida',
checkStock 'CheckStock'
from mst_ProductoDetalle
where idProducto = @idProducto and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoForImportToNew]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoForImportToNew]
as
select
pd.Id as 'Id',
p.nombreProducto as 'NombreProducto',
pd.descripcion as 'Descripcion',
p.IdGrupo as 'IdGrupo',
g.Descripcion 'Grupo',
p.IdTipoProducto as 'IdTipoProducto',
tp.Descripcion 'TipoProducto',
p.idMarca as 'IdMarca',
m.nombreMarca 'Marca',
p.idproveedor as 'IdProveedor',
proveedor.nombre 'Proveedor',
pd.idTalla as 'IdTalla',
t.descripcion 'Talla',
pd.idColores as 'IdColor',
c.descripcion 'Color',
pd.idmedida 'IdMedida',
medida.descripcion 'Medida',
pd.stockminimo as 'StockMinimo',
p.usuarioCrea as 'UsuaioCrea',
p.fechaCrea as 'FechaCrea',
pd.estado 'Estado'
from mst_Producto p
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_Grupo g on p.IdGrupo = g.Id
inner join mst_TipoProducto tp on p.IdTipoProducto = tp.Id
inner join mst_Marca m on  p.idMarca = m.Id
inner join mst_Proveedor proveedor on p.idproveedor = proveedor.id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_Medidas medida on pd.idmedida = medida.id
where p.flag = 1 and pd.flag = 1
order by p.nombreProducto asc
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoPresentacionById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoPresentacionById]
@id int
as
select
pp.id 'Id',
idProductosDetalle 'IdProductoDetalle',
pp.idUnidad 'IdUnidad',
um.nombreUnidad 'Unidad',
pp.precioUnitario 'Precio',
pp.Principal 'IsPrincipal',
pp.Codigo 'CodigoBarra',
pp.PrincipalAlmacen 'IsPrincipalAlmacen',
pp.VerEnVentas
from mst_ProductoPresentacion pp
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
where pp.id = @id and pp.estado = 1 and pp.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoPresentacionByIdProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoPresentacionByIdProductoDetalle]
@idProductoDetalle int
as
select
pp.id 'Id',
idProductosDetalle 'IdProductoDetalle',
pp.idUnidad 'IdUnidad',
um.nombreUnidad 'Unidad',
pp.precioUnitario 'Precio',
pp.Principal 'IsPrincipal',
pp.Codigo 'CodigoBarra',
pp.PrincipalAlmacen 'IsPrincipalAlmacen',
pp.VerEnVentas
from mst_ProductoPresentacion pp
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
where pp.idProductosDetalle = @idProductoDetalle and pp.estado = 1 and pp.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductoPresentacionForImportToNew]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductoPresentacionForImportToNew]
@idProducto int
as
select
pp.Id,
pp.idProductosDetalle as 'IdProducto',
pp.idUnidad as 'IdUnidad',
um.nombreUnidad as 'Unidad',
um.factor as 'Factor',
pp.precioUnitario 'Precio',
pp.Principal as 'IsPrincipal',
pp.usuarioCrea 'UsuarioCrea',
pp.fechaCrea 'FechaCrea',
pp.estado  'Estado'
from mst_ProductoPresentacion pp
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
where pp.flag = 1 and pp.idProductosDetalle = @idProducto

GO
/****** Object:  StoredProcedure [dbo].[SpGetProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProductos]
@text varchar(100),
@idGrupo int,
@verDeshabilitados bit,
@tope int = 50
as
if @tope = 0 begin set @tope = 100000 end
SELECT top (@tope)
*
FROM Producto
where IdGrupo = CASE WHEN @idGrupo > 0 THEN @idGrupo ELSE IdGrupo END
AND NombreProducto like CONCAT('%', @text, '%')
and Estado = CASE WHEN @verDeshabilitados = 0 THEN 1 ELSE 0 END 
and Flag = 1
order by Id desc
GO
/****** Object:  StoredProcedure [dbo].[SpGetProductosById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpGetProductosById]
@id int
as
select * from mst_Producto
where Id = @id and estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetProveedor]
@text varchar(250)
as
select top 50 
Id,
Nombre,
Ruc,
Direccion,
Telefono,
Email
from mst_Proveedor
where estado = 1 and flag = 1
and 
(nombre like CONCAT('%', @text, '%') or 
ruc like CONCAT('%', @text, '%'))
ORDER BY id desc
GO
/****** Object:  StoredProcedure [dbo].[SpGetProveedorById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpGetProveedorById]
@id int
as
select top 50 
Id,
Nombre,
Ruc,
Direccion,
Telefono,
Email
from mst_Proveedor
where estado = 1 and flag = 1
and id = @id
ORDER BY id desc
GO
/****** Object:  StoredProcedure [dbo].[SpGetReporteAlmacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetReporteAlmacenTraslado]
@id int
as
select * from mst_almacen_traslado
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[spGetReporteContadorForExcel]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spGetReporteContadorForExcel]
@fechaInicio date,
@fechaFin date,
@tipoDocumento varchar(02),
@enviado int
as
if @enviado < 2
begin
	if @enviado = 1
		begin
			if @tipoDocumento = '00'
				begin
					SELECT codigo
					,serie_doc_cpe
					,nro_doc_cpe
					,fecha_emi_doc_cpe
					,[ruc_dni_cliente]
					,[nombre_cliente]
					,[Direccion]
					,[ope_exonerada]
					,[otros_impuestos]
					,[total_cpe]
					FROM [vw_tbl_cab_cpe] 
					WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin and doc_cdr = 1
					ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
				end
			else
				begin
					SELECT codigo
					,serie_doc_cpe
					,nro_doc_cpe
					,fecha_emi_doc_cpe
					,[ruc_dni_cliente]
					,[nombre_cliente]
					,[Direccion]
					,[ope_exonerada]
					,[otros_impuestos]
					,[total_cpe]
					FROM [vw_tbl_cab_cpe] 
					WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin and doc_cdr = 1 and codigo = @tipoDocumento
					ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
				end
		end
	else
		begin
			if @tipoDocumento = '00'
				begin
					SELECT codigo
					,serie_doc_cpe
					,nro_doc_cpe
					,fecha_emi_doc_cpe
					,[ruc_dni_cliente]
					,[nombre_cliente]
					,[Direccion]
					,[ope_exonerada]
					,[otros_impuestos]
					,[total_cpe]
					FROM [vw_tbl_cab_cpe] 
					WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin and doc_cdr = 0
					ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
				end
			else
				begin
					SELECT codigo
					,serie_doc_cpe
					,nro_doc_cpe
					,fecha_emi_doc_cpe
					,[ruc_dni_cliente]
					,[nombre_cliente]
					,[Direccion]
					,[ope_exonerada]
					,[otros_impuestos]
					,[total_cpe]
					FROM [vw_tbl_cab_cpe] 
					WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin and doc_cdr = 0 and codigo = @tipoDocumento
					ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
				end
		end
end

else
	begin
		if @tipoDocumento = '00'
			begin
				SELECT codigo
				,serie_doc_cpe
				,nro_doc_cpe
				,fecha_emi_doc_cpe
				,[ruc_dni_cliente]
				,[nombre_cliente]
				,[Direccion]
				,[ope_exonerada]
				,[otros_impuestos]
				,[total_cpe]
				FROM [vw_tbl_cab_cpe] 
				WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin
				ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
			end
		else
			begin
				SELECT codigo
				,serie_doc_cpe
				,nro_doc_cpe
				,fecha_emi_doc_cpe
				,[ruc_dni_cliente]
				,[nombre_cliente]
				,[Direccion]
				,[ope_exonerada]
				,[otros_impuestos]
				,[total_cpe]
				FROM [vw_tbl_cab_cpe] 
				WHERE fecha_emi_doc_cpe BETWEEN @fechaInicio AND @fechaFin and codigo = @tipoDocumento
				ORDER BY [serie_doc_cpe],[nro_doc_cpe] ASC
			end
	end
GO
/****** Object:  StoredProcedure [dbo].[SpGetReporteRequerimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpGetReporteRequerimiento]
@numApertura int,
@idCaja int,
@idUsuario int
as
		SELECT NumApertura,Fecha,SUM(Cant) AS Cant,UMedida,Descripcion,grupo FROM (
		SELECT 
		g.Numero as 'NumApertura',
		CAST(g.Fecha AS DATE) as Fecha,
		b.Cantidad as Cant,
		um.nombreUnidad as UMedida,
		(p.nombreProducto + ' ' + pd.descripcion + ' ' + mmm.descripcion + ' ' +	mm.nombreMarca + ' ' + 
		t.descripcion+' '+ 	c.descripcion)  as 'Descripcion',
		gr.descripcion as grupo
		FROM mst_Venta a
		INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
		inner join mst_ProductoPresentacion pp on pp.Id= b.IdProducto
		inner join mst_ProductoDetalle pd on pd.Id = pp.IdProductosDetalle
		inner join mst_Producto p on p.Id = pd.IdProducto
		inner join mst_Marca mm on p.idMarca = mm.Id
		inner join mst_Talla t on pd.idTalla = t.Id
		inner join mst_Color c on pd.idColores = c.Id
		inner join mst_UnidadMedida um on pp.idUnidad = um.Id
		inner join mst_Medidas mmm on pd.idmedida = mmm.id
		inner join mst_Proveedor ppp on p.idproveedor = ppp.id
		inner join mst_Grupo gr on p.IdGrupo = gr.Id
		INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
		WHERE g.Numero = @numApertura and a.IdCaja = @idCaja and a.IdUsuario = @idUsuario
		and a.anulado = 0) as tmp
		GROUP BY NumApertura,Fecha,Descripcion,UMedida,grupo

GO
/****** Object:  StoredProcedure [dbo].[SpGetReporteVentaCronogramaByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetReporteVentaCronogramaByIdVenta]
@idVenta int
as
select
id idCronograma,
fecha fechaCronograma,
idVenta,
nroCuota,
monto montoCronograma
from venta_cronograma
where idVenta = @idVenta and estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetRestPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetRestPisos]
as
select
Id,
numpiso Piso,
cantmesas Mesas,
numInicio Inicio
from tabla_RestPisos
where Estado = 1
order by Piso asc
GO
/****** Object:  StoredProcedure [dbo].[spGetSeguimientoByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetSeguimientoByIdVenta]
@idVenta int
as
select ISNULL(s.Id, 0) as id
from tbl_Seguimiento s
inner join mst_Venta v on s.IdVenta = v.Id
where IdVenta = @idVenta
and Eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[spGetSeguimientoCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetSeguimientoCompra]
@idCompra int
as
select sc.*, tps.Descripcion TipoPagoText from tbl_SeguimientoCompra sc
inner join tbl_TipoPago_Seguimiento tps on sc.IdTipoPago = tps.Id
where sc.Flag = 1 and IdCompra = @idCompra
GO
/****** Object:  StoredProcedure [dbo].[spGetSeguimientoCompraById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetSeguimientoCompraById]
@id int
as
select sc.*, tps.Descripcion TipoPagoText from tbl_SeguimientoCompra sc
inner join tbl_TipoPago_Seguimiento tps on sc.IdTipoPago = tps.Id
where sc.Flag = 1 and  sc.id = @id

GO
/****** Object:  StoredProcedure [dbo].[SpGetSeguimientoVentaById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetSeguimientoVentaById]
@id int
as
select 
s.Id,
IdVenta,
IdTipoPago,
tp.Descripcion 'TipoPago',
s.descripcion 'Descripcion',
s.Monto,
s.FechaPago,
s.Validado,
s.idApertura 'IdApertura',
s.idUsuario 'IdUsuario',
s.idCaja 'IdCaja'
from tbl_Seguimiento s
inner join tbl_TipoPago_Seguimiento tp on s.IdTipoPago = tp.Id
where s.id = @id and Eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[SpGetSeguimientoVentaByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetSeguimientoVentaByIdVenta]
@idVenta int
as
select 
s.Id,
IdVenta,
IdTipoPago,
tp.Descripcion 'TipoPago',
s.descripcion 'Descripcion',
s.Monto,
s.FechaPago,
s.Validado,
s.idApertura 'IdApertura',
s.idUsuario 'IdUsuario',
s.idCaja 'IdCaja'
from tbl_Seguimiento s
inner join tbl_TipoPago_Seguimiento tp on s.IdTipoPago = tp.Id
where s.IdVenta = @idVenta and Eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[SpGetSerieDocumentoByIdUsuarioYDocumento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetSerieDocumentoByIdUsuarioYDocumento]
@idUsuario int,
@codigoDocumento varchar(2)
as 
select
s.Id 'IdSerie',
s.Serie 'Serie',
u.Id 'IdUsuario',
u.nombre 'Usuario',
d.Codigo 'CodigoDocumento',
d.Descripcion 'Documento'
from mst_Doc_Serie_Usuario dsu
inner join mst_Doc_Serie ds on dsu.idserie = ds.Id
inner join mst_Serie s on ds.IdSerie = s.Id
inner join mst_documentos d on ds.IdDoc = d.Codigo
inner join mst_usuarios u on dsu.idusuario = u.id
where dsu.IdUsuario = @idusuario 
and d.Codigo = @codigoDocumento
and dsu.Estado = 1 
and dsu.Flag = 1 
and ds.Estado = 1 
and ds.Flag = 1
and s.Estado = 1 
and s.Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetStock]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetStock]
@idProductoDetalle int,
@idUnidad int
as
declare @factor money = (select factor from mst_UnidadMedida where Id = @idUnidad)
select a.Nombre,(Saldo / @factor) saldo, s.IdProducto, pd.checkStock from Stocks_Acumulados s
inner join mst_Almacen a on s.IdAlmacen = a.Id
inner join mst_ProductoDetalle pd on s.IdProducto = pd.Id
where s.IdProducto = @idProductoDetalle

GO
/****** Object:  StoredProcedure [dbo].[spGetStockMinimoProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetStockMinimoProducto]
@IdDetalle int
as
SELECT stockminimo FROM mst_ProductoDetalle WHERE Id = @IdDetalle

GO
/****** Object:  StoredProcedure [dbo].[SpGetStocksByProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetStocksByProductoDetalle]
@idProductoDetalle int
as
select
stock.Id,
stock.IdAlmacen,
stock.IdProducto,
a.Nombre 'Almacen',
stock.Entradas,
stock.Salidas,
stock.Saldo
from Stocks_Acumulados stock 
inner join mst_Almacen a on stock.IdAlmacen = a.Id
where stock.IdProducto = @idProductoDetalle
GO
/****** Object:  StoredProcedure [dbo].[SpGetTallas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetTallas]
as
select
Id,
descripcion
from mst_Talla
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[spGetTblCronogramaCpeByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTblCronogramaCpeByIdVenta]
@idVenta int
as
select * from vw_tbl_cronograma_cpe
where id_cab_cpe = @idVenta

GO
/****** Object:  StoredProcedure [dbo].[SpGetTipoDocumento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetTipoDocumento]
as
select * from mst_TipoDocumento
where estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[spGetTipoPagoSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTipoPagoSeguimiento]
as
select * from tbl_TipoPago_Seguimiento
where Estado = 1 and Flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetTipoProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetTipoProducto]
as
select
Id,
Descripcion
from mst_TipoProducto
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalContadoMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTotalContadoMovimiento]
@idApertura int,
@idCaja int,
@idUsuario int
as
select
ISNULL(SUM(total), 0) total
from mst_almacen_movimiento
where credito = 0 and idUsuario = @idUsuario and idCaja = @idCaja and idApertura = @idApertura

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalContadoVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTotalContadoVentas]
@idApertura int,
@idUsuario int,
@idCaja int
as
select
SUM(v.totalventa)-(SUM(fp.visa)+SUM(fp.mastercard)) total
from mst_Venta v 
inner join tabla_FormaPago fp on v.Id = fp.IdVenta
where fp.Contado = 1 
and v.IdApertura = @idApertura
and v.IdUsuario = @idUsuario and v.IdCaja = @idCaja
and v.Anulado = 0
GO
/****** Object:  StoredProcedure [dbo].[spGetTotalCreditoMovimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetTotalCreditoMovimiento]
@idApertura int,
@idCaja int,
@idUsuario int
as
select
ISNULL(SUM(total), 0) total
from mst_almacen_movimiento
where credito = 1 and idUsuario = @idUsuario and idCaja = @idCaja and idApertura = @idApertura

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalCreditoVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spGetTotalCreditoVentas]
@idApertura int,
@idUsuario int,
@idCaja int
as
select
SUM(Total) total
from mst_Venta v 
inner join tabla_FormaPago fp on v.Id = fp.IdVenta
where fp.Credito = 1
and v.IdApertura = @idApertura
and v.IdUsuario = @idUsuario and v.IdCaja = @idCaja
and v.Anulado = 0

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalGastosOperativosCierre]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTotalGastosOperativosCierre]
@idapertura int,
@idcaja int,
@idusuario int
as
select ISNULL(SUM(Monto), 0) total  from mst_GastosOperativos 
where eliminado = 0 and IdApertura = @idapertura and idcaja = @idcaja and IdUsuario = @idusuario

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalPagadosAlDiaMovimientos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spGetTotalPagadosAlDiaMovimientos]
@idApertura int,
@idCaja int,
@idUsuario int
as
select
ISNULL(sum(monto), 0) total
from api_almacen_pagos
where idApertura = @idApertura and idCaja = @idCaja and user_id = @idUsuario

GO
/****** Object:  StoredProcedure [dbo].[spGetTotalPagadosAldiaVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTotalPagadosAldiaVentas]
@idApertura int,
@idUsuario int,
@idCaja int
as
select 
ISNULL(SUM(monto), 0) total
from tbl_Seguimiento s
INNER Join mst_Venta v on s.IdVenta = v.Id
where s.idCaja = @idCaja 
and s.idApertura = @idApertura 
and s.idUsuario = @idUsuario
and v.IdFormaPago = 2
and s.IdTipoPago = 1
GO
/****** Object:  StoredProcedure [dbo].[spGetTotalSalidasAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTotalSalidasAlmacen]
as
select
sum(importe_pagado) total
from mst_almacen_movimiento
where salida = 1 and CAST(fecha as date) = CAST(GETDATE() as date)
group by total, id
order by id desc
GO
/****** Object:  StoredProcedure [dbo].[spGetTotalTarjetasVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spGetTotalTarjetasVentas]
@idApertura int,
@idUsuario int,
@idCaja int
as
select
SUM(fp.Visa) + SUM(fp.Mastercard) total
from mst_Venta v 
inner join tabla_FormaPago fp on v.Id = fp.IdVenta
where 
v.IdApertura = @idApertura
and v.IdUsuario = @idUsuario 
and v.IdCaja = @idCaja
and v.Anulado = 0
and (fp.Visa > 0 OR FP.Mastercard > 0)
and fp.Contado = 1

GO
/****** Object:  StoredProcedure [dbo].[spGetTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetTransportista]
as
select 
t.id Id,
td.Id 'IdDocumento',
td.descripcion 'Documento',
DniRuc 'Numero',
Nombre,
Telefono,
Licencia,
Direccion
from mst_Transportistas t
inner join mst_TipoDocumento td on t.CodidoTipoDoc = td.codigoSunat
where t.Estado = 1 and t.Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetTransportistaByDni]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetTransportistaByDni]
@dni varchar(8)
as
select 
t.id Id,
td.Id 'IdDocumento',
td.descripcion 'Documento',
DniRuc 'Numero',
Nombre,
Telefono,
Licencia,
Direccion
from mst_Transportistas t
inner join mst_TipoDocumento td on t.CodidoTipoDoc = td.codigoSunat
where t.Estado = 1 and t.Flag = 1 and t.DniRuc = @dni
GO
/****** Object:  StoredProcedure [dbo].[SpGetUnidadesByIdProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetUnidadesByIdProductoDetalle]
@idProductoDetalle int
as
select
um.Id,
um.nombreUnidad 'Descripcion',
pp.Principal,
pp.Id 'id_presentacion',
pd.Id 'IdProductoDetalle',
pp.Codigo 'CodigoBarra',
pd.codigoBarra 'CodigoBarraDetalle'
from mst_ProductoDetalle pd
inner join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
where pd.Id = @idProductoDetalle and pp.estado = 1 and pp.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetUnidadesProductoVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetUnidadesProductoVenta]
@idProductoDetalle int
as
select
um.Id,
um.nombreUnidad 'Unidad',
um.factor 'Factor',
pp.precioUnitario 'Precio',
pp.Principal,
pd.idProducto 'IdProducto',
pd.Id 'IdProductoDetalle',
pp.Id 'IdProductoPresentacion',
pp.Codigo 'CodigoBarra',
pd.codigoBarra 'CodigoBarraDetalle'
from mst_ProductoDetalle pd
inner join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
where pd.Id = @idProductoDetalle and pp.estado = 1 and pp.flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetUnidadMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetUnidadMedidas]
as
select
Id,
nombreUnidad as 'Descripcion'
from mst_UnidadMedida
where Estado = 1 and Flag =1

GO
/****** Object:  StoredProcedure [dbo].[SpGetUsuarioById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpGetUsuarioById]
@id int
as
select * from mst_Usuarios
where id = @id and estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[SpGetUsuarios]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetUsuarios]
@text varchar(max)
as
select * from mst_Usuarios
where estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[spGetUsuariosVendedores]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetUsuariosVendedores]
as
select 
id,
nombre
from mst_Usuarios
where Estado = 1 and Flag = 1 and idtipoUsuario = 3
GO
/****** Object:  StoredProcedure [dbo].[SpGetVentaById]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetVentaById]
@id int

as
select
Id,
IdDocumento,
SerieDoc,
NumeroDoc,
FechaEmision,
SubTotal 'Subtotal',
Igv,
Descuento,
TotalVenta,
Total_Letras 'TotalLetras',
IdCliente,
CodigoTipoDoc,
DniRuc,
RazonSocial,
Direccion,
Email,
Anulado,
Observacion,
TipoNotCred,
DescripNotCred,
TipoDocAfectado,
NumeroDocAfectado,
IdFormaPago,
IdUsuarioPreventa,
IdApertura,
IdCaja,
ImportePagado,
Hassh,
IdAlmacen,
IdGuia,
IdPiso,
IdUsuario,
TipoMoneda,
Otro_Imp 'OtroImp',
Tipo_Operacion 'TipoOperacion',
Adicional,
Beneficiario,
IdConvenio,
IdParentesco,
cortesia 'Cortesia',
delivery 'Delivery',
llevar 'Llevar',
countPecho 'CountPecho',
countPierna 'CountPierna',
textObservation 'TextObservacion',
fecha_apertura 'FechaApertura'
from mst_Venta
where Id = @id
GO
/****** Object:  StoredProcedure [dbo].[spGetVentaCronograma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetVentaCronograma]
as
select * from venta_cronograma
where estado = 1 and flag = 1

GO
/****** Object:  StoredProcedure [dbo].[spGetVentaCronogramaByIdVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetVentaCronogramaByIdVenta]
@idVenta int
as
select * from venta_cronograma
where idVenta = @idVenta and estado = 1 and Flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpGetVentaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpGetVentaDetalle]
@idVenta int
as
select
vd.Id,
IdProducto,
descripcion 'Descripcion',
IdVenta, 
Cantidad,
PrecioUnit 'Precio',
Descuento,
Subtotal,
Igv,
Total,
um.nombreUnidad 'Unidad',
IdUnidad,
vd.Factor,
Adicional1,
Adicional2,
Adicional3,
Adicional4,
vd.CodigoBarra,
igv_incluido 'IgvIncluido',
countPecho 'CountPecho',
countPierna 'CountPierna',
textObservation 'TextObservation',
IsCodBarraBusqueda,
IdProductoDetalle
from mst_Venta_det vd 
inner join mst_UnidadMedida um on vd.IdUnidad = um.Id
where vd.IdVenta = @idVenta and vd.Anulado = 0
GO
/****** Object:  StoredProcedure [dbo].[spGetVentaForControlTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetVentaForControlTransportista]
@fecha date
as
SELECT top 50
Id,
CASE IdDocumento
when '03' then 'BOLETA'
WHEN '01' THEN 'FACTURA'
WHEN '07' THEN 'NOTA DE CREDITO'
WHEN '08' THEN 'NOTA DE DEBITO'
end TipoDocumento,
CONCAT(SerieDoc, '-', NumeroDoc) Documento,
FechaEmision,
TotalVenta,
IdUsuario
FROM mst_Venta
where Anulado = 0 and CAST(FechaEmision as date) = @fecha
order by id desc

GO
/****** Object:  StoredProcedure [dbo].[SpGetVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[SpGetVentas]
@fechaInicio date,
@fechaFin date
as
select
Id,
IdDocumento,
SerieDoc,
NumeroDoc,
FechaEmision,
SubTotal 'Subtotal',
Igv,
Descuento,
TotalVenta,
Total_Letras 'TotalLetras',
IdCliente,
CodigoTipoDoc,
DniRuc,
RazonSocial,
Direccion,
Email,
Anulado,
Observacion,
TipoNotCred,
DescripNotCred,
TipoDocAfectado,
NumeroDocAfectado,
IdFormaPago,
IdUsuarioPreventa,
IdApertura,
IdCaja,
ImportePagado,
Hassh,
IdAlmacen,
IdGuia,
IdPiso,
IdUsuario,
TipoMoneda,
Otro_Imp 'OtroImp',
Tipo_Operacion 'TipoOperacion',
Adicional,
Beneficiario,
IdConvenio,
IdParentesco,
cortesia 'Cortesia',
delivery 'Delivery',
llevar 'Llevar',
countPecho 'CountPecho',
countPierna 'CountPierna',
textObservation 'TextObservacion',
fecha_apertura 'FechaApertura'
from mst_Venta
where FechaEmision between @fechaInicio and @fechaFin
GO
/****** Object:  StoredProcedure [dbo].[spGetVerVentasUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spGetVerVentasUsuario]
@id int
as
select 
verVentas
from mst_Usuarios
where id = @id

GO
/****** Object:  StoredProcedure [dbo].[spGetVistaCabecera]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [dbo].[spGetVistaCabecera]
@fechaInicio date,
@fechaFin date
AS
SELECT
id_cab_cpe as id,
LTRIM(RTRIM(codigo)) as codigo,
cast(estatus as bit) as anulado,
fecha_emi_doc_cpe as fecha,
LTRIM(RTRIM(descri_doc)) documento,
LTRIM(RTRIM(serie_doc_cpe)) serie,
LTRIM(RTRIM(nro_doc_cpe)) numero,
LTRIM(RTRIM(ruc_dni_cliente)) ruc,
LTRIM(RTRIM(nombre_cliente)) cliente,		
direccion,	
tipo_moneda moneda,
sub_total subTotal,
igv,
otros_impuestos Icbper,
total_cpe importe,
cast(doc_firma as bit) xml,
cast(doc_cdr as bit) cdr,
cast(1 as bit) pdf,
cast(doc_email as bit) email,
cast(doc_publicado as bit) web,
des_cod_sunat respuestaSunat,
correo_cliente as correoCliente,
tipo_doc_cli tipoDocCliente,
status_verificado as statusVerificado,
codigo_verificado as codigoVerificado,
mensaje_verificado as mensajeVerificado,
observacion_verificado as observacionVerificado
FROM vw_tbl_cab_cpe
where cast(fecha_emi_doc_cpe as date) between @fechainicio and @fechafin 
order by fecha_emi_doc_cpe asc

GO
/****** Object:  StoredProcedure [dbo].[spInertarGastosOperativos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInertarGastosOperativos]
@idusuario int,
@idapertura int,
@idtipogasto int,
@num_bolfact varchar(100),
@ruc varchar(50),
@proveedor varchar(100),
@concepto varchar(50),
@monto money,
@idcaja int
as
insert into mst_GastosOperativos(idusuario,idapertura,idtipogasto,num_bolfact,ruc,proveedor,concepto,monto,idcaja)
values(@idusuario,@idapertura,@idtipogasto,@num_bolfact,@ruc,@proveedor,@concepto,@monto,@idcaja)























































GO
/****** Object:  StoredProcedure [dbo].[spIngresarOtrosImpuestos_Preventa]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spIngresarOtrosImpuestos_Preventa]
@id int,
@bit bit,
@esconvenio bit
as

DECLARE @total money = 0
if(@bit = 0)
	begin
		if(@esconvenio = 0)
			begin
				set @total = (select SUM(Cantidad) 
				from tabla_Pre_Venta_Detalle pvd
				inner join mst_ProductoPresentacion pp on pvd.IdProducto = pp.Id
				inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
				inner join mst_Producto p on pd.idProducto = p.Id
				inner join mst_Grupo g on p.IdGrupo = g.Id				 
				inner join tabla_Pre_Venta pedido on pvd.IdPedido = pedido.IdPedido
				where pvd.IdPedido = @id and pvd.Pagado = 0 and pvd.Eliminado = 0 and (g.Descripcion = 'BOLSA' or g.Descripcion = 'BOLSAS') and pedido.BolFac <> '99')
			end
		else
			begin
				set @total = (select SUM(Cantidad) 
				from tabla_Pre_Venta_Detalle_Convenio pvd
				inner join mst_ProductoPresentacion pp on pvd.IdProducto = pp.Id
				inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
				inner join mst_Producto p on pd.idProducto = p.Id
				inner join mst_Grupo g on p.IdGrupo = g.Id
				inner join tabla_Pre_Venta pedido on pvd.IdPedido = pedido.IdPedido
				where pvd.IdPedido = @id and pvd.Pagado = 0 and pvd.Eliminado = 0 and (g.Descripcion = 'BOLSA' or g.Descripcion = 'BOLSAS') and pedido.BolFac <> '99')
			end
	end
else
	begin
	set @total = (select SUM(Cantidad) 
		from tabla_Pre_Venta_Detalle pvd
		inner join mst_ProductoPresentacion pp on pvd.IdProducto = pp.Id
		inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
		inner join mst_Producto p on pd.idProducto = p.Id
		inner join mst_Grupo g on p.IdGrupo = g.Id
		inner join tabla_Pre_Venta pedido on pvd.IdPedido = pedido.IdPedido
		where pvd.IdMesa = @id and pvd.Pagado = 0 and pvd.Eliminado = 0 and (g.Descripcion = 'BOLSA' or g.Descripcion = 'BOLSAS') and pedido.BolFac <> '99')
	end

--set @total = @total * 0.20
set @total = @total * dbo.getIcbAmount()
set @total = ISNULL(@total,0)

if(@bit = 0)
	begin
		if(@esconvenio = 0)
			begin
				update tabla_Pre_Venta set Otro_Imp = @total where IdPedido = @id and Pagado = 0 and Eliminado = 0
			end
		else
			begin
				update tabla_Pre_Venta_Convenio set Otro_Imp = @total where IdPedido = @id and Pagado = 0 and Eliminado = 0
			end
	end
else if(@bit = 1)update tabla_Pre_Venta set Otro_Imp = @total where IdMesa = @id and Pagado = 0 and Eliminado = 0
else 
	begin
		if(@esconvenio = 0)
			begin
				update tabla_Pre_Venta set Otro_Imp = @total where Id = @id and Pagado = 0 and Eliminado = 0
			end
		else
			begin
				update tabla_Pre_Venta_Convenio set Otro_Imp = @total where IdPedido = @id and Pagado = 0 and Eliminado = 0
			end
	end
GO
/****** Object:  StoredProcedure [dbo].[spIngresarOtrosImpuestos_Venta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spIngresarOtrosImpuestos_Venta]
@id int
as

DECLARE @total money = 0 
set @total = (select
sum(Cantidad) cantidad
from mst_Venta_det vd
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
inner join mst_Grupo g on p.IdGrupo = g.Id
inner join mst_Venta v on vd.idventa = v.Id
where IdVenta = @id and vd.Anulado = 0 and (g.Descripcion = 'BOLSA' or g.Descripcion = 'BOLSAS')
and v.IdDocumento <> '99')


--set @total = (@total * 0.20)
set @total = (@total * dbo.getIcbAmount())
set @total = ISNULL(@total,0)
--print @total


update mst_Venta set Otro_Imp = @total,
TotalVenta = (SubTotal + @total)
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[spInsertar_Resultado_Envio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertar_Resultado_Envio]
@id bigint,
@docfirma bit,
@doccdr bit,
@codsunat char(10),
@descsunat char(254),
@hashsunat char(100)
as
if((select count(id_info_cpe) from tbl_info_cpe where id_cab_cpe = @id) > 0)
begin
update tbl_info_cpe set doc_firma =@docfirma, doc_cdr = @doccdr, cod_sunat= @codsunat, des_cod_sunat = @descsunat,
hash_sunat = @hashsunat
where id_cab_cpe = @id
end
else
begin
insert into tbl_info_cpe(id_cab_cpe,doc_firma,doc_cdr,cod_sunat,des_cod_sunat,hash_sunat)
values(@id,@docfirma,@doccdr,@codsunat,@descsunat,@hashsunat)
end



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertar_Resultados_Envio_otros]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spInsertar_Resultados_Envio_otros]
@id bigint,
@doc_email bit,
@doc_publicado bit
as
update tbl_info_cpe set doc_email = @doc_email, doc_publicado = @doc_publicado
where id_cab_cpe = @id


















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarAlacenTraslado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarAlacenTraslado]
@id int,
@id_almacen_salida int,
@id_almacen_entrada int,
@fecha datetime,
@descripcion nvarchar(max),
@cerrado bit,
@estado bit,
@op bit
as
if(@op = 0)
	begin
	insert into mst_almacen_traslado(idAlmacenSalida, idAlmacenEntrada, fecha, descripcion, cerrado, estado)
	values(@id_almacen_salida, @id_almacen_entrada, @fecha, @descripcion, @cerrado, @estado)
	select SCOPE_IDENTITY();
	end
else
	begin
	update mst_almacen_traslado set idAlmacenSalida = @id_almacen_salida, idAlmacenEntrada = @id_almacen_entrada, fecha = @fecha, descripcion = @descripcion, cerrado = @cerrado, estado = @estado
	where id = @id	
	end



























GO
/****** Object:  StoredProcedure [dbo].[spInsertarAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarAlmacen]
@nombre varchar(100),
@usuariocrea varchar(50)
as
insert into mst_Almacen(nombre, usuariocrea)
values(@nombre,@usuariocrea)

declare @id_almacen int = SCOPE_IDENTITY();



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarAnexoEmpresa]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarAnexoEmpresa]
@CodigoAnexo char(4)
as
update tabla_configuracion_general set CodigoAnexo = @CodigoAnexo

GO
/****** Object:  StoredProcedure [dbo].[spInsertarCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spInsertarCliente]
@id int,
@idDocumento int,
@numeroDocumento varchar(20),
@razonSocial varchar(200),
@nombreComercial varchar(200),
@telefono varchar(20),
@correo varchar(100),
@usuarioCrea varchar(50),
@nacionalidad int = 1,
@defaultPago char = 'C'
as
IF(@id != 1)
BEGIN
IF((select count(id) from mst_cliente where id = @id) >= 1)
BEGIN
    update mst_Cliente set idDocumento = @idDocumento,
    numerodocumento = @numeroDocumento, razonsocial = @razonsocial, nombrecomercial = @nombreComercial,
    telefono = @telefono,
    correo = @correo,
    usuarioModifica = @usuarioCrea,
    fechaModifica = getdate(),
    nacionalidad = @nacionalidad,
    DefaultPago = IIF(@defaultPago = '', defaultPago, @defaultPago)
    where id = @id
END
ELSE
BEGIN
    insert into mst_Cliente(idDocumento, numeroDocumento, razonSocial,nombreComercial,telefono, correo, usuarioCrea,nacionalidad, DefaultPago)
    values(@idDocumento, @numeroDocumento, @razonSocial,@nombreComercial,@telefono, @correo, @usuarioCrea, @nacionalidad, @defaultPago)
END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertarCliente_Delivery]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spInsertarCliente_Delivery]
@id int,
@idDocumento int,
@numeroDocumento varchar(20),
@razonSocial varchar(200),
@nombreComercial varchar(200),
@telefono varchar(20),
@correo varchar(100),
@usuarioCrea varchar(50)
as
IF(@id != 1)
BEGIN
IF((select count(id) from mst_cliente where id = @id) >= 1)
BEGIN
update mst_Cliente set idDocumento = @idDocumento, 
numerodocumento = @numeroDocumento, razonsocial = @razonsocial, nombrecomercial = @nombreComercial,
telefono = @telefono,
correo = @correo,
usuarioModifica = @usuarioCrea,
fechaModifica = getdate()
where id = @id
END
ELSE
BEGIN

insert into mst_Cliente(idDocumento, numeroDocumento, razonSocial,nombreComercial,telefono, correo, usuarioCrea, delivery)
values(@idDocumento, @numeroDocumento, @razonSocial,@nombreComercial,@telefono, @correo, @usuarioCrea, 1)

declare @id_despues int = SCOPE_IDENTITY();
select @id_despues as 'id'

END
END
GO
/****** Object:  StoredProcedure [dbo].[spInsertarClienteDireccion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarClienteDireccion]
@id int,
@idCliente int,
@direccion varchar(200),
@principal bit,
@referencia VARCHAR(MAX)
as
if((select count(id) from mst_cliente_direccion where id= @id) >= 1)
begin
update mst_cliente_direccion set Direccion = @direccion,
Estado = 1, Flag = 1, Principal = 0, Referencia = @referencia
where id = @id
end
else
begin
insert into mst_Cliente_Direccion
values(@idCliente,@direccion,1,1,@principal,@referencia)
end


GO
/****** Object:  StoredProcedure [dbo].[spInsertarColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---insertar
CREATE proc [dbo].[spInsertarColor]
@descripcion varchar(10),
@usuarioCrea varchar(50)
as
insert into mst_Color (descripcion, usuarioCrea)
values (@descripcion, @usuarioCrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----
CREATE proc [dbo].[spInsertarCompra]
@fechaemision date,
@fechaingreso datetime,
@idalmacen int,
@doc char(2),
@serie char(4),
@numero char(8),
@idproveedor int,
@codigotipodoc int,
@dniruc varchar(20),
@razon varchar(100),
@direccion varchar(100),
@email varchar(100),
@idformapago int,
@fechavence date,
@observacion text,
@subtotal money,
@totaligv money,
@totaldescuento money,
@totaltotal money,
@importepagado money,
@usuariocrea varchar(50),
@porc_igv money
as
insert into mst_Compras(FechaEmision,FechaIngreso,IdAlmacen,TipoDoc,Serie,Numero,IdProveedor,FormaPago,FechaVence,Observacion,Subtotal,TotalIgv,Totaldescuento,Total,ImportePagado,UsuarioCrea,estado, Flag,
codigotipodoc,dniruc,razonsocial,Direccion,email, porc_igv)
values(@fechaemision,@fechaingreso,@idalmacen,@doc,@serie,@numero,@idproveedor,@idformapago,@fechavence,@observacion,@subtotal,@totaligv,@totaldescuento,@totaltotal,@importepagado,@usuariocrea,1,1,
@codigotipodoc,@dniruc,@razon,@direccion,@email, @porc_igv)






















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarCompraDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------
CREATE proc [dbo].[spInsertarCompraDetalle]
@idproducto int,
@descripcion varchar(100),
@idunidad int,
@cantidad int,
@precio money,
@subtotal money,
@igv money,
@descuento money,
@total money,
@usuariocrea varchar(50),
@idcompra int,
@igv_incluido bit
as
insert into mst_ComprasDetalles (IdProducto,Descripcion,IdUnidad,Cantidad,Precio,Subtotal,Igv,Descuento,Total,UsuarioCrea,Estado,Flag,IdCompra, igv_incluido)
values(@idproducto,@descripcion,@idunidad,@cantidad,@precio,@subtotal,@igv,@descuento,@total,@usuariocrea,1,1,@idcompra,@igv_incluido)



declare @idalmacen int = (select idalmacen from mst_Compras where id = @idcompra)
declare @idproductodet int = (select idProductosDetalle from mst_ProductoPresentacion where Id =  @idproducto)
exec spStockActualizarSaldoItem @idalmacen,@idproductodet




















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarConfig]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spInsertarConfig]
@ruc varchar(20),
@razon varchar(100),
@nombrecomercial varchar(100),
@direccion varchar(100),
@telefono varchar(20),
@celular varchar(20),
@web varchar(100),
@correo varchar(100),
@marca bit,
@gruplinfam bit,
@talla bit,
@color bit,
@medidas bit,
@descripcion bit,
@fvence bit,
@proveedor bit,
@visa bit,
@mastercard bit,
@logo image,
@impresora1 varchar(100),
@impresora2 varchar(100),
@ubigeo varchar(100),
@ciudad varchar(100),
@distrito varchar(100),
@igv money,
@certificadocpe varchar(100),
@ContraseniaCertificadoCpe varchar(100),
@UsuarioSecundarioSol varchar(100),
@ContraseniaUsuarioSecundarioSol varchar(100),
@validar_vendedor bit,
@modrapido bit,
@codbarra bit,
@numcopias int,
@nummesas int,
@produccion bit,
@passcorreo varchar(50),
@met_busqueda char(2),
@urlose varchar(100),
@tipoose int,
@urlosebeta varchar(100),
@urloseotros varchar(100),
@urloseotrosbeta varchar(100),
@urloseaux varchar(100),
@urloseauxbeta varchar(100),
@tipomoneda varchar(10),
@puerto int,
@ssl bit,
@servidor_email varchar(50),
@nube bit
as
insert into tabla_configuracion_general (
ruc, 
razonsocial, 
nombrecomercial, 
direccion, 
telefono, 
celular, 
web, 
correo, 
marca, 
grupo_linea_familia, 
talla, 
color, 
medida,
descripcion,
f_vence,
proveedor,
visa,
mastercard,
Logo, 
impresora1, 
impresora2,
ubigeo, 
ciudad, 
distrito, 
igv, 
Certificado_CPE, 
ContraseniaCertificadoCpe, 
UsuarioSecundarioSol, 
ContraseniaUsuarioSecundarioSol, 
Validar_Vendedor, 
ModoRapido,
CodBarra, 
NumCopias, 
NumMesas, 
Produccion, 
PassCorreo,
Met_Busqueda, 
UrlOse, 
TipoOse, 
UrlOseBeta, 
UrlOseOtros,
UrlOseOtrosBeta,
UrlOseAux, 
UrlOseAuxBeta, 
TipoMoneda, 
Puerto, 
Ssl, 
Servidor_Email, 
Nube)
values(
@ruc,
@razon,
@nombrecomercial,
@direccion,
@telefono,
@celular,
@web,
@correo,
@marca,
@gruplinfam,
@talla,
@color,
@medidas,
@descripcion,
@fvence,
@proveedor, 
@visa, 
@mastercard,
@logo,
@impresora1,
@impresora2,
@ubigeo,
@ciudad,
@distrito,
@igv, 
@certificadocpe,
@ContraseniaCertificadoCpe,
@UsuarioSecundarioSol,
@ContraseniaUsuarioSecundarioSol,
@validar_vendedor,
@modrapido,
@codbarra, 
@numcopias,
@nummesas,
@produccion, 
@passcorreo,
@met_busqueda,
@urlose,
@tipoose,
@urlosebeta,
@urloseotros,
@urloseotrosbeta,
@urloseaux,
@urloseauxbeta,
@tipomoneda,
@puerto,
@ssl,
@servidor_email,
@nube)


GO
/****** Object:  StoredProcedure [dbo].[spinsertardescuento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spinsertardescuento]
@idgrupo int,
@des_subida decimal(18,2),
@des_bajada decimal(18,2)
as
if((select count(idgrupo) from descuentos where idgrupo = @idgrupo) > 0)
	update descuentos set desc_subida = @des_subida, desc_bajada = @des_bajada where idgrupo = @idgrupo
else
	insert into descuentos 
	values(@idgrupo,@des_subida,@des_bajada)


















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarDoc_Serie_Usuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarDoc_Serie_Usuario]
@idusuario int,
@idserie int
as
insert into mst_Doc_Serie_Usuario(idserie,IdUsuario,estado,flag)
values(@idserie,@idusuario,1,1)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarDocSerie]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarDocSerie]
@iddoc char(2),
@idserie int
as
insert into mst_doc_serie(IdDoc,IdSerie,Estado,Flag)
values(@iddoc,@idserie,1,1)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarGrupo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------
--INSERTAR GRUPO
CREATE procedure [dbo].[spInsertarGrupo]
@descripcion varchar(100),
@usuarioCrea varchar(50)
as
insert into mst_Grupo(Descripcion, usuarioCrea)
values (@descripcion, @usuarioCrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarGuia]
@codigoDoc char(2),
@seriedoc char(4),
@numerodoc int,
@idcliente int,
@codigotipodocsunat int,
@dniruc varchar(20),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@observacion text,
@usuariocrea varchar(50),
@fechainiciotraslado date,
@puntopartido varchar(100),
@puntollegada varchar(100),
@idtransportista int,
@placa varchar(10),
@idmotivo int,
@descripcionmotivo varchar(100),
@idventa int,
@idalmacen int
as
insert into mst_guia(IdDocumento,SerieDoc,NumeroDoc,FechaEmision,IdCliente,CodigoTipoDoc,DniRuc,RazonSocial,Direccion,Email,Anulado,Observacion,UsuarioCrea,FechaCrea,FechaInicioTraslado,PuntoPartido,PuntoLLegada, IdTrasnportista, Placa, idmotivo,DescripcionMotivo, idventa, IdAlmacen)
values(@codigoDoc,'0001',@numeroDoc,GETDATE(),@idcliente,@codigoTipoDocSunat,@dniRuc,@RazonSocial,@direccion,@email,0,@observacion,@usuariocrea,GETDATE(),@fechainiciotraslado,@puntopartido,@puntollegada, @idtransportista, @placa,@idmotivo,@descripcionmotivo,@idventa, @idalmacen)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarGuiaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------ahora los detalles
CREATE proc [dbo].[spInsertarGuiaDetalle]
@idproducto int,
@idguia int,
@cantidad money,
@idunidad int,
@factor int,
@descripcion text,
@peso decimal(18,2),
@codbarra varchar(100),
@adicional1 varchar(max)
as
insert into mst_Guia_det(IdProducto,idguia,Flag,anulado,cantidad,IdUnidad,Factor,descripcion, peso, codigobarra, Adicional1)
values(@idproducto,@idguia,1,0,@cantidad,@idunidad,@factor,@descripcion,@peso,@codbarra,@adicional1)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarGuiaVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarGuiaVenta]
@idguia int,
@idventa int
as
update mst_Venta set IdGuia = @idguia
where id = @idventa



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarIcons]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarIcons]
@nombre varchar(50),
@imagen image
as
insert into P_ICONS
values(@nombre,@imagen)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarInventario]
@idalmacen int,
@observacion varchar(100),
@usuariocrea varchar(50),
@tipoinventario varchar(50),
@fechacrea date
as
insert into mst_Inventario(Id_Almacen,Observacion, usuariocrea, TipoInventario, Estado, Flag, fechacrea)
values(@idalmacen,@observacion,@usuariocrea,@tipoinventario, 1, 1, @fechacrea)

























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarInventario_Detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE proc [dbo].[spInsertarInventario_Detalle]
@idinventario int,
@idproducto int,
@cantidad float,
@usuariocrea varchar(50),
@idunidad int,
@factor decimal,
@costo money,
@total money,
@zona varchar(100),
@stand varchar(100)
as
insert into mst_Inventario_Detalle(Id_Inventario,Id_Producto,Cantidad,usuariocrea,IdUnidad,Factor,Costo, Total, Zona, Stand)
values(@idinventario,@idproducto,@cantidad,@usuariocrea,@idunidad,@factor,@costo,@total,@zona,@stand)
GO
/****** Object:  StoredProcedure [dbo].[spInsertarLinea]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------
--select * from TablaLinea
--exec spBuscarGlobal 'spBuscarLinea','1'
--exec spmostrarlinea
--------------------------------------------
--INSERTAR LINEA
CREATE procedure [dbo].[spInsertarLinea]
@nombre varchar(100),
@idgrupo int,
@usuarioCrea varchar(50)
as
insert into mst_Linea(nombreLinea, idGrupo,usuarioCrea)
values (@nombre,@idgrupo, @usuarioCrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarMarca]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-------------------PROCEDIMIENTOS ALMACENADOS---------

------------------------Insertar Marca-------------------
CREATE procedure [dbo].[spInsertarMarca]
@nombre varchar(100),
@usuarioCrea varchar(50)
as
insert into mst_Marca(nombreMarca,usuarioCrea)
values(@nombre,@usuarioCrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spInsertarMedidas]
@descripcion varchar(100),
@usuariocrea varchar(50)
as
insert into mst_Medidas(descripcion, usuariocrea)
values(@descripcion,@usuariocrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarMesas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarMesas] 
@idpiso int,
@cantidad int,
@num_inicio int
as
declare @init int = @num_inicio
declare @cont int =1
if((select COUNT(id) from tabla_RestMesas where IdPiso = @idpiso)>=1)
begin
delete from tabla_RestMesas where IdPiso = @idpiso
while(@cont <= @cantidad)
begin
insert into tabla_RestMesas(IdPiso,NumMesa)
values(@idpiso,@init)
set @cont = @cont+1
set @init = @init+1
end
end

else
begin
while(@cont <= @cantidad)
begin
insert into tabla_RestMesas(IdPiso,NumMesa)
values(@idpiso,@init)
set @cont = @cont+1
set @init = @init+1
end
end


GO
/****** Object:  StoredProcedure [dbo].[spInsertarPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarPago]
@idventa int,
@contado bit,
@credito bit,
@efectivo money,
@visa money,
@mastercard money,
@total money,
@vuelto money
as
insert into tabla_formapago(idventa,contado,credito,efectivo,visa,mastercard,total, Vuelto)
values(@idventa,@contado,@credito,@efectivo,@visa,@mastercard,@total,@vuelto)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarPermisosVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarPermisosVenta]
@idusuario int,
@maximo money,
@minimo money
as
insert into mst_permisos_venta(idusuario,maximo,minimo)
values(@idusuario,@maximo,@minimo)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarPreCuenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spInsertarPreCuenta]
@idmesa int,
@idpiso int,
@bit bit
AS
if((select count(id) from tabla_Pre_Venta where IdMesa = @idmesa and IdPiso = @idpiso and Pagado = 0 and Eliminado = 0)>0)
begin
update tabla_Pre_Venta set precuenta = 1
where IdPiso = @idpiso and IdMesa = @idmesa and Pagado = 0 and Eliminado = 0
end


















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarPreVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarPreVenta]
@idprecontacto int,
@idpredetalle int,
@idmesa int,
@idusuario int
as
insert into mst_Pre_Venta(IdPre_Contacto,IdPre_Detalle,IdMesa,Pagado,Cancelado,idusuario)
VALUES(@idprecontacto,@idpredetalle,@idmesa,0,0,@idusuario)






















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spInsertarProducto]
@nombreProducto varchar(100),
@IdMarca int,
@idsegmento char(2),
@idfamilia char(2),
@idclase char(2),
@usuarioCrea varchar(50),
@idproveedor int,
@idtipo int,
@idproductosunat char(8),
@idgrupo int
as
insert into mst_Producto(nombreProducto, idMarca,IdSegmento,IdFamilia, IdClase, usuarioCrea, idproveedor, IdTipoProducto,idproductosunat,IdGrupo)
values(@nombreProducto,@IdMarca,@idsegmento,@idfamilia,@idclase, @usuarioCrea,@idproveedor, @idtipo,@idproductosunat,@idgrupo)




















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from TablaProductoDetalle
--insert into tablaProductoDetalle(idProducto,idTalla,idColores,codigoBarra,imagenProducto,usuariocrea,fechacrea, usuariomodifica, fechaModifica, estado,flag)
--values(0,0,0,'',null,'','','','',0,0);
--insertar
CREATE proc [dbo].[spInsertarProductoDetalle]
@idproducto int,
@Idtalla int,
@Idcolor int,
@descripcion varchar(100),
@codigobarra varchar(50),
@imagen image,
@usuariocrea varchar(50),
@stockinicial numeric(18,2),
@stockminimo numeric(18,2),
@fechavencimiento date,
@idmedida int,
@bit bit,
@estado bit,
@check_stock bit
as
if(@bit = 0)
insert into mst_ProductoDetalle(idProducto, idTalla, idColores,descripcion, codigoBarra, imagenProducto, usuarioCrea,
stockinicial,stockminimo,fechavencimiento, idmedida,estado, checkStock)
values((@idproducto),@Idtalla,@Idcolor,@descripcion, @codigobarra,@imagen,@usuariocrea,
@stockinicial,@stockminimo,@fechavencimiento,@idmedida,@estado, @check_stock)
else
insert into mst_ProductoDetalle(idProducto, idTalla, idColores,descripcion, codigoBarra, imagenProducto, usuarioCrea,
stockinicial,stockminimo,fechavencimiento, idmedida,estado, checkStock)
values((@idproducto),@Idtalla,@Idcolor,@descripcion, @codigobarra,@imagen,@usuariocrea,
@stockinicial,@stockminimo,@fechavencimiento,@idmedida,@estado,@check_stock)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarProductoPresentacion]
@idproductodetalle int,
@IdUnidad int,
@preciounitario money,
@usuariocrea varchar(50),
@principal bit,
@principalAlmacen bit = 0,
@codigoBarraPresentacion VARCHAR(100),
@verEnVentas bit
as
insert into mst_ProductoPresentacion (idProductosDetalle, idUnidad,precioUnitario, usuarioCrea,Principal, PrincipalAlmacen, Codigo, VerEnVentas)
values(@idproductodetalle, @IdUnidad,@preciounitario, @usuariocrea,@principal, @principalAlmacen, @codigoBarraPresentacion, @verEnVentas)
GO
/****** Object:  StoredProcedure [dbo].[spInsertarProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarProveedor]
@nombre varchar(100),
@ruc varchar(20),
@direccion varchar(100),
@telefono varchar(20),
@email varchar(100),
@usuariocrea varchar(50)
as
insert into mst_Proveedor(nombre, ruc,direccion,telefono,email, usuariocrea, fechacrea)
values(@nombre,@ruc,@direccion,@telefono,@email,@usuariocrea,GETDATE())























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarResumen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------
CREATE proc [dbo].[spInsertarResumen]
@id int,
@serie varchar(100),
@fecharef datetime,
@numticket varchar(100),
@hassunat varchar(100),
@respuesta varchar(100),
@numitems int,
@cod_sunat varchar(10),
@tipoproceso char(2),
@tipoprocesoaux char(2)
as
if(@id = 0)
insert into Tbl_Resumen(Serie,Fecha_Referencia,Fecha_Documento,NumTicket,Hash_Sunat,respuesta,numitems,cod_respuesta,tipoproceso,tipoprocesoaux)
values(@serie,@fecharef,getdate(),@numticket,@hassunat,@respuesta,@numitems,@cod_sunat,@tipoproceso,@tipoprocesoaux)
else
update Tbl_Resumen set Respuesta = @respuesta, hash_sunat = @hassunat, cod_respuesta = @cod_sunat
where id = @id and tipoproceso = @tipoproceso



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarResumen_Det]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarResumen_Det]
@id bigint,
@Fecha date,
@Tipo_Comprobante char(2),
@Num_Comprobante varchar(50),
@Tipo_Doc char(1),
@Numero_Doc varchar(20),
@Tipo_Comprobante_Ref char(2),
@Num_Comprobante_Ref varchar(50),
@Total money,
@Gravada money,
@Isc money,
@Igv money,
@Otros money,
@Cargo_X_Asignacion bit,
@Monto_Cargo_X_Asignacion money,
@Exonerado money,
@Inafecto money,
@Exportacion money,
@Gratuitas money,
@Cliente varchar(100),
@bit bit,
@descripcion varchar(100),
@Otro_Imp money
as
insert into Tbl_Resumen_Det(Fecha,Tipo_Comprobante,Num_Comprobante ,Tipo_Doc,Numero_Doc,Tipo_Comprobante_Ref,Num_Comprobante_Ref,
Total,Gravada,Isc,Igv,Otros,Cargo_X_Asignacion,Monto_Cargo_X_Asignacion,Exonerado,Inafecto,Exportacion,Gratuitas,Cliente,descripcion, Otro_Imp)
values(@Fecha,@Tipo_Comprobante,@Num_Comprobante,@Tipo_Doc,@Numero_Doc,@Tipo_Comprobante_Ref,@Num_Comprobante_Ref,
@Total,@Gravada,@Isc,@Igv,@Otros,@Cargo_X_Asignacion,@Monto_Cargo_X_Asignacion,@Exonerado,@Inafecto,@Exportacion,@Gratuitas,@cliente,@descripcion, @Otro_Imp)
------
if(@bit = 0)
begin
DECLARE @MENSAJE VARCHAR(100) = 'La Boleta numero '+@Num_Comprobante+', ha sido enviada para resumen diario'
exec spInsertar_Resultado_Envio @id,1,1,'',@MENSAJE,''
end
------



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------

CREATE PROC [dbo].[spInsertarSeguimiento]
@id int,
@idventa int,
@idtipopago int,
@descripcion varchar(100),
@monto money,
@fechapago date,
@usuariocrea varchar(50),
@bit bit,
@descontar bit,
@idApertura int,
@idCaja int,
@idUsuario int
as
if(@bit = 0)
begin
insert into tbl_Seguimiento(IdVenta, IdTipoPago, descripcion, monto, FechaPago, UsuarioCrea, idApertura, idCaja, idUsuario)
values(@idventa, @idtipopago, @descripcion, @monto,@fechapago,@usuariocrea, @idApertura, @idCaja, @idUsuario)
end
else
begin
update tbl_Seguimiento set IdTipoPago = @idtipopago, descripcion = @descripcion, Monto = @monto,

FechaPago = @fechapago
where id = @id
end

if @descontar = 1
begin
exec spIrCancelando_Deuda_Seguimiento @idventa
end
GO
/****** Object:  StoredProcedure [dbo].[spInsertarSeguimientoCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spInsertarSeguimientoCompra]
@id int,
@idcompra int,
@idtipopago int,
@descripcion varchar(100),
@monto money,
@fechapago date,
@usuariocrea varchar(50),
@descontar bit,
@idApertura int,
@idCaja int,
@idUsuario int
as
if(@id = 0)
begin
insert into tbl_SeguimientoCompra(IdCompra, IdTipoPago, descripcion, monto, FechaPago, UsuarioCrea, idApertura, idCaja, idUsuario)
values(@idcompra, @idtipopago, @descripcion, @monto,@fechapago,@usuariocrea, @idApertura, @idCaja, @idUsuario)
select CAST(SCOPE_IDENTITY() as int)
end
else
begin
update tbl_SeguimientoCompra set IdTipoPago = @idtipopago, descripcion = @descripcion, Monto = @monto,
FechaPago = @fechapago
where id = @id
select CAST(@id as int)
end

if @descontar = 1
begin
exec spIrCancelando_Deuda_SeguimientoCompra @idcompra
end
GO
/****** Object:  StoredProcedure [dbo].[spInsertarSerie]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarSerie]
@serie varchar(50),
@usuariocrea varchar(50)
as
insert into mst_Serie (Serie,Usuariocrea,FechaCrea,Estado,Flag)
values(@serie,@usuariocrea,GETDATE(),1,1)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarServidor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarServidor]
@id int,
@Descripcion varchar(100),
@Gestor varchar(50),
@Driver varchar(50),
@Servidor varchar(50),
@Puerto varchar(100),
@Usuario varchar(50),
@Contrasenia varchar(50),
@BaseDatos varchar(50),
@RutaScript varchar(50),
@RutaBaseDatos varchar(200),
@SeguridadDatos varchar(50),
@Logotipo image
as
if((select count(id) from MST_SERVIDORES where id = @id) > 0)
begin
update MST_SERVIDORES set 
Descripcion = @Descripcion,
Gestor = @Gestor,
Driver = @Driver,
Servidor = @Servidor,
Puerto = @Puerto,
Usuario = @Usuario,
Contrasenia = @Contrasenia,
BaseDatos = @BaseDatos,
RutaScript = @RutaScript,
RutaBaseDatos = @RutaBaseDatos,
SeguridadDatos = @SeguridadDatos,
Logotipo = @Logotipo
where id = @id
end
else
begin
insert into MST_SERVIDORES(Descripcion,Gestor,Driver,Servidor,Puerto,Usuario,Contrasenia,BaseDatos,RutaScript,RutaBaseDatos,SeguridadDatos,Logotipo)
values(@Descripcion,@Gestor,@Driver,@Servidor,@Puerto,@Usuario,@Contrasenia,@BaseDatos,@RutaScript,@RutaBaseDatos,@SeguridadDatos,@Logotipo)
end




















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarSotckItem]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarSotckItem]
@id int,
@idalmacen int
as
insert into Stocks_Acumulados (IdAlmacen, IdProducto, Entradas,Salidas,Saldo,Fecha_Crea,Usuario_Crea)
values(@idalmacen,@id,0,0,0,GETDATE(),'Admin')



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarTalla]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------
--insertar
CREATE proc [dbo].[spInsertarTalla]
@descripcion varchar(10),
@usuarioCrea varchar(50)
as
insert into mst_Talla (descripcion, usuarioCrea)
values (@descripcion, @usuariocrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarTipoUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarTipoUsuario]
@descripcion varchar(100),
@usuariocrea varchar(50)
as
insert into mst_TipoUsuario (descripcion,usuarioCrea,fechaCrea,estado,flag)
values(@descripcion,@usuariocrea,getdate(),1,1)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------
CREATE proc [dbo].[spInsertarTransportista]
@nombre varchar(100),
@codidoTipoDoc int,
@dniruc varchar(20),
@licencia varchar(20),
@direccion varchar(100),
@telefono varchar(20),
@email varchar(100),
@usuariocrea varchar(50)
as
insert into mst_Transportistas(Nombre,CodidoTipoDoc,DniRuc,Licencia,Direccion,Telefono,Email,UsuarioCrea)
values(@nombre,@codidoTipoDoc,@dniruc,@licencia,@direccion,@telefono,@email,@usuariocrea)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarUnidadMedida]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------insertar unidad---------
CREATE procedure [dbo].[spInsertarUnidadMedida]
@nombre varchar(100),
@factor decimal(18,2),
@usuarioCrea varchar(50)
as
insert into mst_UnidadMedida (nombreUnidad,factor, usuarioCrea)
values (@nombre, @factor, @usuarioCrea)























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarUsuario]
@idtipousuario int,
@nombre varchar(100),
@dni varchar(50),
@direccion varchar(200),
@telefono varchar(100),
@usuario varchar(50),
@pass varchar(50),
@usuariocrea varchar(50),
@correo varchar(200),
@foto image,
@docVentaDefecto VARCHAR(2)
as
insert into mst_Usuarios (idtipoUsuario,nombre,dni,direccion,telefono,usuario,pass,usuarioCrea,fechaCrea,estado,flag,correo,Foto,DocVentaDefecto)
values(@idtipousuario,@nombre,@dni,@direccion,@telefono,@usuario,@pass,@usuariocrea,GETDATE(),1,1,@correo,@foto,@docVentaDefecto)
GO
/****** Object:  StoredProcedure [dbo].[spInsertarUsuario_Items]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarUsuario_Items]
@opciones int,
@idusuario int,
@idmenu int,
@idsubmenu int,
@addmod bit,
@estado bit
as
if(@opciones = 0)
begin
if(@addmod=0)
begin
insert into tabla_Usuarios_Menu(idusuario,idmenu)
values(@idusuario,@idmenu)
end
else
begin
update tabla_Usuarios_Menu set Estado=@estado
where idusuario = @idusuario and idmenu = @idmenu
end
end
else if(@opciones = 1)
begin
if(@addmod = 0)
begin
insert into tabla_Usuario_SubMenu(idusuario,idmenu,idsubmenu)
values(@idusuario,@idmenu,@idsubmenu)
end
else
begin
update tabla_Usuario_SubMenu set Estado=@estado
where idusuario = @idusuario and idmenu = @idmenu and idsubmenu = @idsubmenu
end
end























































GO
/****** Object:  StoredProcedure [dbo].[spInsertarVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarVenta]
@codigoDoc char(2),
@seriedoc char(4),
@numerodoc int,
@idcliente int,
@codigotipodocsunat int,
@dniruc varchar(20),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@observacion text,
@codigotiponotcredito char(2),
@descripcionnotacred varchar(50),
@codigodocafectado char(2),
@numerodocafectado varchar(50),
@usuariocrea varchar(50),
@idformapago int,
@idusuariopreventa int,
@descuento money,
@idapertura int,
@idcaja int,
@importepagado money,
@totalletras text,
@Hassh varchar(max),
@idalmacen int,
@idpiso int,
@idmesa int,
@idusuario int,
@tipomoneda varchar(10),
@tipooperacion varchar(4),
@adicional varchar(250),
@beneficiario varchar(250),
@idconvenio int,
@idparentesco int
as
insert into mst_Venta(IdDocumento,SerieDoc,NumeroDoc,FechaEmision,IdCliente,CodigoTipoDoc,DniRuc,RazonSocial,Direccion,Email,Anulado,Observacion,TipoNotCred,DescripNotCred,TipoDocAfectado,NumeroDocAfectado,UsuarioCrea,FechaCrea,IdFormaPago,IdUsuarioPreventa,Descuento,IdApertura,idcaja, importepagado, total_letras, hassh, IdAlmacen,IdGuia, idpiso,IdMesa,idusuario, TipoMoneda, tipo_operacion, Adicional, Beneficiario, IdConvenio, IdParentesco)
values(@codigoDoc,@serieDoc,@numeroDoc,GETDATE(),@idcliente,@codigoTipoDocSunat,@dniRuc,@RazonSocial,@direccion,@email,0,@observacion,@codigotiponotcredito,@descripcionnotacred,@codigodocafectado,@numerodocafectado,@usuariocrea,GETDATE(),@idformapago,@idusuariopreventa,@descuento,@idapertura,@idcaja,@importepagado,@totalletras,@Hassh,@idalmacen,0,@idpiso,@idmesa,@idusuario,@tipomoneda,@tipooperacion, @adicional, @beneficiario, @idconvenio, @idparentesco)

declare @id_despues int
set @id_despues = SCOPE_IDENTITY();

select @id_despues as 'id'

SET NOCOUNT ON
if CAST(@observacion as varchar) <> ''
begin
declare @id int = (select id from mst_almacen_movimiento where serie+'-'+CAST(numero as varchar)=CAST(@observacion AS varchar))
update mst_almacen_movimiento set doc_facturado = @seriedoc + '-' + CAST(@numerodoc AS varchar)
where id = @id
end

--declare @idventa  int = (select MAX(id) FROM mst_Venta)
--exec spInsertarVenta_ext @idventa,@seriedoc,@numerodoc,@idpiso,@idmesa,@idapertura,@importepagado





















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarVenta_Ext]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarVenta_Ext]
@idcaja int,
@fecha date,
@total money,
@idpiso int,
@idmesa int,
@idapertura int
as
insert into tabla_Venta_Ext(idcaja,fecha,IdPiso,IdMesa,IdApertura, total)
values(@idcaja,@fecha,@idpiso,@idmesa,@idapertura,@total)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarVentaDet_Ext]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------
CREATE proc [dbo].[spInsertarVentaDet_Ext]
@idventa int,
@idventadet int,
@idproducto int,
@descripcion varchar(200),
@precio money,
@cantidad money,
@total money
as
insert into tabla_Venta_Det_Ext(idventa,idproducto, Descripcion,precio, cantidad,total)
values(@idventa,@idproducto,@descripcion,@precio, @cantidad,@total)



















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarVentaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------ahora los detalles
CREATE proc [dbo].[spInsertarVentaDetalle]
@idproducto int,
@preciounitario money,
@idventa int,
@cantidad money,
@descuento money,
@idunidad int,
@factor decimal,
@subtotal money,
@igv money,
@total money,
@descripcion text,
@adicional1 text,
@adicional2 date,
@adicional3 varchar(200),
@adicional4 varchar(200),
@codbarra varchar(100),
@igv_incluido bit
as
insert into mst_Venta_det(IdProducto,PrecioUnit,idventa,Flag,anulado,cantidad,Descuento,IdUnidad,Factor,Subtotal, igv,total,descripcion,Adicional1,Adicional2,Adicional3,Adicional4, codigoBarra, igv_incluido)
values(@idproducto,@preciounitario,@idventa,1,0,@cantidad,@descuento,@idunidad,@factor,@subtotal,@igv,@total,@descripcion,@adicional1,@adicional2,@adicional3,@adicional4,@codbarra, @igv_incluido)


declare @idalmacen int = (select idalmacen from mst_Venta where id = @idventa)
declare @idproductodet int = (select idProductosDetalle from mst_ProductoPresentacion where Id =  @idproducto)
exec spStockActualizarSaldoItem @idalmacen,@idproductodet

--declare @iddetalle int = (select max(id) from mst_Venta_det) 

--exec spInsertarVentaDet_Ext @idventa,@iddetalle,@idproducto,@descripcion,@preciounitario, @cantidad,@total

exec spIngresarOtrosImpuestos_Venta @idventa

















































GO
/****** Object:  StoredProcedure [dbo].[spInsertarVentaDetalle2]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spInsertarVentaDetalle2]
@idproducto int,
@preciounitario money,
@idventa int,
@cantidad money,
@descuento money,
@idunidad int,
@factor decimal,
@subtotal money
as
insert into mst_Venta_det(IdProducto,PrecioUnit,idventa,Flag,anulado,cantidad,Descuento,IdUnidad,Factor,Subtotal)
values(@idproducto,@preciounitario,@idventa,1,0,@cantidad,@descuento,@idunidad,@factor,@subtotal)

update mst_Venta set
TotalVenta = TotalVenta + @subtotal,
Descuento = Descuento + @descuento
where Id = @idventa

update tabla_FormaPago set Total = Total + @subtotal
where IdVenta = @idventa


declare @idalmacen int = (select idalmacen from mst_Venta where id = @idventa)
declare @idproductodet int = (select idProductosDetalle from mst_ProductoPresentacion where Id =  @idproducto)
exec spStockActualizarSaldoItem @idalmacen,@idproductodet

declare @iddetalle int = (select max(id) from mst_Venta_det) 























































GO
/****** Object:  StoredProcedure [dbo].[spIrCancelando_Deuda_Seguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------
CREATE proc [dbo].[spIrCancelando_Deuda_Seguimiento]
@idventa int
as
declare @monto money, @estado bit
set @monto = (select sum(Monto) from tbl_Seguimiento where Flag = 1 and IdVenta = @idventa)

UPDATE tbl_Seguimiento SET validado = 1 WHERE IdVenta = @idventa and Eliminado = 0

set @monto = isnull(@monto, 0)

update mst_Venta set ImportePagado = @monto
where Id = @idventa
GO
/****** Object:  StoredProcedure [dbo].[spIrCancelando_Deuda_SeguimientoCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spIrCancelando_Deuda_SeguimientoCompra]
@idcompra int
as
declare @monto money, @estado bit
set @monto = (select sum(Monto) from tbl_SeguimientoCompra where Flag = 1 and IdCompra = @idcompra)

UPDATE tbl_SeguimientoCompra SET validado = 1 WHERE IdCompra = @idcompra

set @monto = isnull(@monto, 0)

update mst_Compras set ImportePagado = @monto
where Id = @idcompra
GO
/****** Object:  StoredProcedure [dbo].[spIsertarFalatantes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spIsertarFalatantes]
@id int
as
insert into tabla_Usuarios_Menu(idmenu,idusuario,estado)
select m.id,@id,1 from tabla_Menus m
left join tabla_Usuarios_Menu um
on m.id = um.idmenu and um.idusuario = @id and um.Estado = 1
where um.idmenu IS NULL
--
insert into tabla_Usuario_SubMenu (idmenu,idsubmenu,idusuario,estado)
select sm.idmenu as 'idmenu' ,sm.id as 'idsubmenu',@id,1
from tabla_Menus m
inner join tabla_SubMenus sm
on m.id = sm.idmenu
left join tabla_Usuario_SubMenu usm
on usm.idmenu = sm.idmenu and usm.idsubmenu = sm.id and idusuario = @id
and usm.Estado = 1
where usm.id IS NULL
order by sm.idmenu,sm.id

--exec spIsertarFalatantes 1
GO
/****** Object:  StoredProcedure [dbo].[spKardexItem]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spKardexItem]
@id int,
@idalmacen int
as

declare @idproducto int, @nombre varchar(100),@fecha date,@entrada DECIMAL(18,2), @salida DECIMAL(18,2), @doc varchar(100), @almacen_salida int, @almacen1 varchar(200), @almacen2 varchar(200)
declare CCursor cursor
for
(
select temp.id,temp.nombre,temp.fecha, temp.entrada, temp.salida, temp.doc, temp.almacen1, temp.almacen2
from
(select
pd.Id,
p.nombreProducto + ' ' + pd.descripcion as nombre,
cast(i.FechaCrea as date) as fecha,
(id.Cantidad * id.Factor) as entrada,
0 as salida,
'Inicial' as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Inventario_Detalle id
inner join mst_inventario i on id.Id_Inventario = i.Id
inner join mst_ProductoDetalle pd on id.Id_Producto = pd.Id
inner join mst_producto p on pd.idproducto = p.id
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.Id_Almacen = @idalmacen and id.flag = 1 and i.flag = 1
--------------------------------------------------------------------
-------------------COMPRAS----------------------------
union all
select
pd.Id,
cd.Descripcion as nombre,
cast(c.FechaEmision as date) as fecha,
(cd.Cantidad * um.factor) as entrada,
0 as salida,
cast(c.Serie as varchar)+ '-' + cast(c.Numero as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_ComprasDetalles cd
inner join mst_Compras c on cd.IdCompra = c.Id
inner join mst_ProductoDetalle pd on cd.IdProducto = pd.Id
inner join mst_UnidadMedida um on cd.IdUnidad = um.Id
inner join mst_Almacen a on c.IdAlmacen = a.Id
where c.IdAlmacen = @idalmacen and cd. estado = 1 and cd.Flag = 1 and c.Estado = 1 and c.flag=1 AND C.IsClosed = 1
-------------------COMPRAS----------------------------
UNION ALL

select 
pd.Id,
vd.descripcion as nombre,
cast(v.FechaEmision as date) as fecha,
0 as entrada,
(vd.Cantidad * vd.Factor) as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.Anulado = 0 and v.IdAlmacen = @idalmacen and vd.Flag = 1 and cast(v.Observacion as varchar) = ''
AND v.IdDocumento <> '07'
UNION ALL
select 
pd.Id,
vd.descripcion as nombre,
cast(v.FechaEmision as date) as fecha,
CASE v.TipoNotCred
WHEN '01' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '02' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '03' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '06' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '07' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
WHEN '08' THEN ISNULL((vd.Cantidad * vd.Factor),0.00)
ELSE 0.00 END AS entrada,
0.00 as salida,
cast(v.SerieDoc as varchar) + '-' + cast(v.NumeroDoc as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
from mst_Venta_det vd
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Almacen a on v.IdAlmacen = a.Id
WHERE v.Anulado = 0 and v.IdAlmacen = @idalmacen and vd.Flag = 1
AND v.IdDocumento = '07' AND (v.TipoNotCred<>'04' OR v.TipoNotCred<>'05' OR v.TipoNotCred<>'09' OR v.TipoNotCred<>'10')

--TRASLADOS--------------------------
union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
t.fecha as 'fecha',
0 as entrada,
(td.cantidad * td.factor) as salida,
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenSalida = @idalmacen and td.flag = 1 and t.flag = 1
---------------------------------------

union all
select
td.idProducto as 'id',
td.nombreProducto as 'nombre',
t.fecha as 'fecha',
(td.cantidad * td.factor) as 'entrada',
0 as 'salida',
CAST(t.serie as varchar) + '-' + CAST(t.numero as varchar) as doc,
a.Nombre as 'almacen1',
b.Nombre as 'almacen2'
from mst_almacen_traslado_detalle td
inner join mst_almacen_traslado t on t.id = td.almacen_traslado_id
inner join mst_Almacen a on t.idAlmacenSalida = a.Id
inner join mst_Almacen b on t.idAlmacenEntrada = b.Id
where idAlmacenEntrada = @idalmacen and td.flag = 1 and t.flag = 1

--TRASLADOS--------------------------

--MOVIMIENTOS----------------------------
UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as doc,
a.Nombre as 'almacen1',
'' as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and entrada = 1 and md.flag = 1 and m.flag = 1
---------------------------------------------

UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
m.fecha as 'fecha',
0 as 'entrada',
(md.cantidad * md.factor) as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as 'doc',
a.Nombre as 'almacen1',
c.razonSocial as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
INNER JOIN mst_Cliente c ON c.Id = m.idCliente
WHERE idAlmacen = @idalmacen and salida = 1 and md.flag = 1 and m.flag = 1

--MOVIMIENTOS----------------------------
--AJUSTES
UNION ALL
SELECT
md.idProducto as 'id',
md.nombreProducto as 'nombre',
m.fecha as 'fecha',
(md.cantidad * md.factor) as 'entrada',
0 as 'salida',
CAST(m.serie as varchar) + '-' + CAST(m.numero as varchar) as 'doc',
a.Nombre as 'almacen1',
'' as 'almacen2'
FROM mst_almacen_movimiento_detalle md
INNER JOIN mst_almacen_movimiento m on m.id = md.almacen_movimiento_id
inner join mst_Almacen a on m.idAlmacen = a.Id
WHERE idAlmacen = @idalmacen and m.ajuste = 1 and md.flag = 1 and m.flag = 1

) as Temp
where temp.id = @id)
order by temp.fecha asc
for update

OPEN CCursor
FETCH CCursor INTO @idproducto,@nombre,@fecha,@entrada,@salida,@doc,@almacen1, @almacen2
declare @saldo money = 0
declare @suma money = 0
create table #temp(id int, doc varchar(100),fecha date,nombre varchar(100),entrada money,salida money,saldo money, Almacen1 varchar(200), Almacen2 varchar(200));

WHILE (@@FETCH_STATUS = 0)
BEGIN  
	
	if(@entrada != 0)
	begin
	set @saldo = @saldo + @entrada;
	--print cast(@idproducto as varchar) + '|' + @nombre + '|'+ cast(@entrada as varchar) + '|' + cast(@salida as varchar) + '|' + cast(@saldo as varchar) + '|' + @doc+'|'+cast(@fecha as varchar)
	end
	else	
	begin
	set @saldo = @saldo - @salida;
	--print cast(@idproducto as varchar) + '|' + @nombre + '|'+ cast(@entrada as varchar) + '|' + cast(@salida as varchar) + '|' + cast(@saldo as varchar) + '|' + @doc+'|'+cast(@fecha as varchar)
	end
	SET NOCOUNT ON
	insert into #temp values(@idproducto,@doc,@fecha,@nombre,@entrada,@salida,@saldo,@almacen1, @almacen2)
-- LECTURA DE LA SIGUIENTE FILA DEL CURSOR
   FETCH CCursor INTO @idproducto,@nombre,@fecha,@entrada,@salida,@doc,@almacen1, @almacen2
END
-- CIERRE DEL CURSOR
CLOSE CCursor

-- LIBERAR LOS RECURSOS
DEALLOCATE CCursor
select * from #temp
GO
/****** Object:  StoredProcedure [dbo].[spLimpiarPedidos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spLimpiarPedidos]
@id_usuario int
as

DELETE tabla_Pre_Venta_Detalle
       FROM tabla_Pre_Venta_Detalle pd INNER JOIN tabla_Pre_Venta p
            ON pd.IdMesa = p.IdMesa AND pd.IdPiso = p.IdPiso
       WHERE p.IdUsuario=@id_usuario

delete from tabla_Pre_Venta where IdUsuario = @id_usuario

--
declare @tipo_usuario varchar(250) = (
select tu.descripcion from mst_Usuarios u
inner  join mst_TipoUsuario tu on u.idtipoUsuario = tu.id
where u.id = @id_usuario
)

if @tipo_usuario = 'admin' or @tipo_usuario = 'administrador'
begin

delete from tabla_Pre_Venta 
delete from tabla_Pre_Venta_Detalle
DBCC CHECKIDENT ('[tabla_Pre_Venta]', RESEED, 0);
DBCC CHECKIDENT ('[tabla_Pre_Venta_detalle]', RESEED, 0);
end
GO
/****** Object:  StoredProcedure [dbo].[spListarResumenesFaltantes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-----------------------------------------------------
CREATE proc [dbo].[spListarResumenesFaltantes]
as
select
			LTRIM(RTRIM(TIPO_COMPROBANTE)) 'TIPO_COMPROBANTE',
			LTRIM(RTRIM(Num_Comprobante)) 'NRO_COMPROBANTE',
			LTRIM(RTRIM(Tipo_Comprobante_Ref)) 'TIPO_COMPROBANTE_REF',
			LTRIM(RTRIM(Num_Comprobante_Ref)) 'NRO_COMPROBANTE_REF',
			LTRIM(RTRIM(TIPO_DOC)) 'TIPO_DOCUMENTO',
			LTRIM(RTRIM(NUMERO_DOC)) 'NRO_DOCUMENTO',
			LTRIM(RTRIM(CLIENTE)) 'CLIENTE',
			format(Total,'N','es-pe') 'TOTAL',
			format(Gravada,'N','es-pe') 'GRAVADA',
			format(Isc,'N','es-pe') 'ISC',
			format(IGV,'N','es-pe')	'IGV',
			format(OTROS,'N','es-pe') 'OTROS',
			CARGO_X_ASIGNACION 'CARGO_X_ASIGNACION',
			format(Monto_Cargo_X_Asignacion,'N','es-pe') 'MONTO_CARGO_X_ASIG',
			format(Exonerado,'N','es-pe')	'EXONERADO',
			format(Inafecto,'N','es-pe') 'INAFECTO',
			format(Exportacion,'N','es-pe') 'EXPORTACION',
			format(GRATUITAS,'N','es-pe') 'GRATUITAS',
			Id as 'ID',
			DESCRIPCION AS 'DESCRIPCION',
			format(Otro_Imp,'N','es-pe') as 'OTROS_IMPUESTOS',
			Fecha,
			MONTH(Fecha) MES,
			DAY(Fecha) DIA,
			YEAR(Fecha) ANIO
			from Tbl_Resumen_Det
			where MONTH(Fecha) = 
			MONTH(GETDATE()) 			
			--4
			and Tipo_Comprobante = '03' and Enviado = 0
			order by Fecha



















































GO
/****** Object:  StoredProcedure [dbo].[spListarSeguimiento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------
CREATE proc [dbo].[spListarSeguimiento]
@id int,
@bit int
as
if(@bit = 0)--PARA MOSTRAR TODOS
begin
select
s.Id,
ts.Descripcion as 'Tipo',
s.descripcion,
s.Monto,
s.FechaPago,
s.UsuarioCrea as 'Usuario',
s.IdTipoPago,
v.TotalVenta,
s.idApertura,
s.idCaja,
s.idUsuario
from tbl_Seguimiento s
inner join tbl_TipoPago_Seguimiento ts on s.IdTipoPago = ts.Id
left join mst_Venta v on s.IdVenta = v.Id
where s.Flag = 1
end
else if(@bit = 1)--PARA FILTRAR POR VENTAS
begin
select
s.Id,
ts.Descripcion as 'Tipo',
s.descripcion,
s.Monto,
s.FechaPago,
s.UsuarioCrea as 'Usuario',
s.IdTipoPago,
v.TotalVenta,
s.idApertura,
s.idCaja,
s.idUsuario
from tbl_Seguimiento s
inner join tbl_TipoPago_Seguimiento ts on s.IdTipoPago = ts.Id
left join mst_Venta v on s.IdVenta = v.Id
where s.IdVenta = @id
end
else if(@bit = 2)--PARA FILTRAR POR ITEM
begin
select
s.Id,
ts.Descripcion as 'Tipo',
s.descripcion,
s.Monto,
s.FechaPago,
s.UsuarioCrea as 'Usuario',
s.IdTipoPago,
v.TotalVenta,
s.idApertura,
s.idCaja,
s.idUsuario
from tbl_Seguimiento s
inner join tbl_TipoPago_Seguimiento ts on s.IdTipoPago = ts.Id
left join mst_Venta v on s.IdVenta = v.Id
where s.Id = @id
end
GO
/****** Object:  StoredProcedure [dbo].[spListaStock]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spListaStock]
@idGrupo int,
@idAlmacen int = 1
as
IF @idGrupo > 0
begin
	SELECT s.IdAlmacen,a.Nombre, g.Descripcion as Grupo,
	pd.codigoBarra,g.descripcion,
	RTRIM((p.nombreProducto + ' ' + me.descripcion + ' '+ m.nombreMarca + ' ' + pd.descripcion)) as nombreProducto,
	u.nombreUnidad,
	m.nombreMarca,
	me.descripcion,
	(s.Saldo/u.factor) as Stock,
	pd.descripcion,
	pd.fechavencimiento,
	pp.precioUnitario
	FROM mst_ProductoPresentacion pp
	INNER JOIN mst_ProductoDetalle pd ON pd.Id = pp.idProductosDetalle
	INNER JOIN mst_Producto p ON p.Id = pd.idProducto
	INNER JOIN mst_UnidadMedida u ON u.Id = pp.idUnidad
	INNER JOIN mst_Grupo g ON g.Id = IdGrupo
	INNER JOIN mst_Marca m ON m.Id = p.idMarca
	INNER JOIN mst_Medidas me ON me.Id = pd.idmedida
	INNER JOIN Stocks_Acumulados s ON s.IdProducto = pd.Id
	INNER JOIN mst_Almacen a ON a.Id = s.IdAlmacen
	WHERE p.IdGrupo = @idGrupo and s.IdAlmacen = @idAlmacen and
	(pp.Principal = 1 AND pp.estado = 1 AND pp.flag = 1) AND
--	(pp.PrincipalAlmacen = 1 AND pp.estado = 1 AND pp.flag = 1) AND
	(pd.estado = 1 AND pd.flag = 1) AND
	(p.estado = 1 AND p.flag = 1) 
	ORDER BY RTRIM((p.nombreProducto + ' ' + pd.descripcion + ' '+ m.nombreMarca + ' ' + me.descripcion)) ASC
end

else
begin
	SELECT s.IdAlmacen,a.Nombre, g.Descripcion as Grupo,
	pd.codigoBarra,g.descripcion,
	RTRIM((p.nombreProducto + ' ' + me.descripcion + ' '+ m.nombreMarca + ' ' + pd.descripcion)) as nombreProducto,
	u.nombreUnidad,
	m.nombreMarca,
	me.descripcion,
	(s.Saldo/u.factor) as Stock,
	pd.descripcion,
	pd.fechavencimiento,
	pp.precioUnitario
	FROM mst_ProductoPresentacion pp
	INNER JOIN mst_ProductoDetalle pd ON pd.Id = pp.idProductosDetalle
	INNER JOIN mst_Producto p ON p.Id = pd.idProducto
	INNER JOIN mst_UnidadMedida u ON u.Id = pp.idUnidad
	INNER JOIN mst_Grupo g ON g.Id = IdGrupo
	INNER JOIN mst_Marca m ON m.Id = p.idMarca
	INNER JOIN mst_Medidas me ON me.Id = pd.idmedida
	INNER JOIN Stocks_Acumulados s ON s.IdProducto = pd.Id
	INNER JOIN mst_Almacen a ON a.Id = s.IdAlmacen
	WHERE s.IdAlmacen = @idAlmacen and
	(pp.Principal = 1 AND pp.estado = 1 AND pp.flag = 1) AND
	--(pp.PrincipalAlmacen = 1 AND pp.estado = 1 AND pp.flag = 1) AND
	(pd.estado = 1 AND pd.flag = 1) AND
	(p.estado = 1 AND p.flag = 1) 
	ORDER BY RTRIM((p.nombreProducto + ' ' + pd.descripcion + ' '+ m.nombreMarca + ' ' + me.descripcion)) ASC
end
GO
/****** Object:  StoredProcedure [dbo].[spLogin]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spLogin]
@usuario varchar(50),
@contrasenia varchar(50)
as
select u.Id,usuario,Foto,tu.descripcion from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where usuario = @usuario and pass = @contrasenia
and u.estado = 1 and u.flag = 1






















































GO
/****** Object:  StoredProcedure [dbo].[spMarcarEnviados_Resumen_Det]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spMarcarEnviados_Resumen_Det]
@fecha date,
@numticket varchar(100),
@idresumen int,
@bit bit
as
if(@bit = 0)
begin
update Tbl_Resumen_Det set
Enviado = 1,
NumTicket = @numticket,
IdResumen = @idresumen
where cast(fecha as date) = cast(@fecha as date) and 
enviado = 0
end
else
begin
update Tbl_Resumen_Det set
Enviado = 1,
NumTicketBajas = @numticket,
idbajas = @idresumen
where cast(fecha as date) = cast(@fecha as date) and 
enviado = 1
end

















































GO
/****** Object:  StoredProcedure [dbo].[spMigrarMesa]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMigrarMesa]
@idmesaan int,
@idmesanuevo int,
@idpiso int
as
update tabla_Pre_Venta set IdMesa = @idmesanuevo
where idmesa = @idmesaan and Eliminado = 0 and Pagado = 0 and IdPiso = @idpiso
update tabla_Pre_Venta_Detalle set IdMesa = @idmesanuevo
where IdMesa = @idmesaan and Pagado = 0 and Eliminado = 0 and IdPiso = @idpiso



















































GO
/****** Object:  StoredProcedure [dbo].[spModificar_Horario_Envio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificar_Horario_Envio]
@horario int
as
update tabla_configuracion_general set hora_envio = @horario


GO
/****** Object:  StoredProcedure [dbo].[spModificarAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarAlmacen]
@id int,
@nombre varchar(100),
@estado bit,
@usuariomodifica varchar(50)
as
update mst_Almacen set
nombre =@nombre,
estado = @estado,
usuariomodifica = @usuariomodifica,
fechamodifica = GETDATE()
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---modificar
CREATE procedure [dbo].[spModificarCliente]
@idCliente int,
@idDocumento int,
@numeroDocumento varchar(20),
@razonSocial varchar(200),
@nombreComercial varchar(200),
@estado bit,
@telefono varchar(20),
@correo varchar(100),
@usuarioModifica varchar(50)
as
if(@idCliente != 1)
begin
update mst_Cliente set 
idDocumento = @idDocumento, 
numeroDocumento = @numeroDocumento,
razonSocial = @razonSocial,
nombreComercial = @nombreComercial,
estado = @estado, 
telefono = @telefono, 
correo = @correo, 
usuarioModifica = @usuarioModifica, 
fechaModifica = GETDATE()
where Id = @idCliente
end






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarClienteDireccion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarClienteDireccion]
@id int,
@direccion varchar(200),
@principal bit
as
update mst_Cliente_Direccion set Principal = 0
where id = @id

update mst_Cliente_Direccion set Principal = @principal,
Direccion = @direccion
where Id = @id
























































GO
/****** Object:  StoredProcedure [dbo].[spModificarColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--modificar
CREATE proc [dbo].[spModificarColor]
@id int,
@descripcion varchar(10),
@estado bit,
@usuarioModifica varchar(50)
as
update mst_Color set
descripcion = @descripcion,
estado = @estado,
usuarioModifica = @usuarioModifica,
fechaModifica = getdate()
where Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----
CREATE proc [dbo].[spModificarCompra]
@id int,
@fechaemision date,
@fechaingreso datetime,
@idalmacen int,
@doc char(2),
@serie char(4),
@numero char(8),
@idproveedor int,
@codigotipodoc int,
@dniruc varchar(20),
@razon varchar(100),
@direccion varchar(100),
@email varchar(100),
@idformapago int,
@fechavence date,
@observacion text,
@subtotal money,
@totaligv money,
@totaldescuento money,
@totaltotal money,
@importepagado money,
@usuariocrea varchar(50),
@estado bit,
@porc_igv money
as
update mst_Compras set
FechaEmision = @fechaemision,
FechaIngreso = @fechaingreso,
IdAlmacen = @idalmacen,
TipoDoc = @doc,
Serie = @serie,
Numero = @numero,
IdProveedor = @idproveedor,
FormaPago = @idformapago,
FechaVence =@fechavence,
Observacion = @observacion,
Direccion = @direccion,
Subtotal = @subtotal,
TotalIgv = @totaligv,
Totaldescuento = @totaldescuento,
Total = @totaltotal,
ImportePagado = @importepagado,
UsuarioCrea = @usuariocrea,
FechaCrea =@id,
codigotipodoc = @codigotipodoc,
dniruc = @dniruc,
razonsocial = @razon,
email = @email,
porc_igv = @porc_igv
where  Id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarCompraDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spModificarCompraDetalle]
@id int,
@idproducto int,
@descripcion varchar(100),
@idunidad int,
@cantidad int,
@precio money,
@subtotal money,
@igv money,
@descuento money,
@total money,
@usuariocrea varchar(50),
@estado bit,
@igv_incluido bit
as
update mst_ComprasDetalles set
IdProducto = @idproducto,
Descripcion = @descripcion,
IdUnidad = @idunidad,
Cantidad = @cantidad,
Precio = @precio,
Subtotal = @subtotal,
Igv = @igv,
Descuento = @descuento,
Total = @total,
UsuarioCrea = @usuariocrea,
Estado = @estado,
igv_incluido = @igv_incluido
where id = @id






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarConfig]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarConfig]
@ruc varchar(20),
@razon varchar(100),
@nombrecomercial varchar(100),
@direccion varchar(100),
@telefono varchar(20),
@celular varchar(20),
@web varchar(100),
@correo varchar(100),
@marca bit,
@gruplinfam bit,
@talla bit,
@color bit,
@medidas bit,
@descripcion bit,
@fvence bit,
@proveedor bit,
@visa bit,
@mastercard bit,
@logo image,
@impresora1 varchar(100),
@impresora2 varchar(100),
@ubigeo varchar(100),
@ciudad varchar(100),
@distrito varchar(100),
@igv money,
@certificadocpe varchar(100),
@ContraseniaCertificadoCpe varchar(100),
@UsuarioSecundarioSol varchar(100),
@ContraseniaUsuarioSecundarioSol varchar(100),
@validar_vendedor bit,
@modrapido bit,
@codbarra bit,
@numcopias int,
@nummesas int,
@produccion bit,
@passcorreo varchar(50),
@met_busqueda char(2),
@urlose varchar(100),
@tipoose int,
@urlosebeta varchar(100),
@urloseotros varchar(100),
@urloseotrosbeta varchar(100),
@urloseaux varchar(100),
@urloseauxbeta varchar(100),
@tipomoneda varchar(10),
@puerto int,
@ssl bit,
@servidor_email varchar(50),
@nube bit
as
update tabla_configuracion_general set
ruc = @ruc,
razonsocial = @razon,
nombrecomercial = @nombrecomercial,
direccion = @direccion,
telefono = @telefono,
celular = @celular,
web = @web,
correo = @correo,
marca = @marca,
grupo_linea_familia = @gruplinfam,
talla = @talla,
color = @color,
medida = @medidas,
descripcion = @descripcion,
f_vence = @fvence,
proveedor = @proveedor,
visa = @visa,
mastercard = @mastercard,
Logo= @logo,
impresora1= @impresora1,
impresora2 = @impresora2,
ubigeo = @ubigeo,
ciudad = @ciudad,
distrito = @distrito,
igv= @igv,
Certificado_CPE = @certificadocpe,
ContraseniaCertificadoCpe  = @ContraseniaCertificadoCpe,
UsuarioSecundarioSol = @UsuarioSecundarioSol,
ContraseniaUsuarioSecundarioSol = @ContraseniaUsuarioSecundarioSol,
Validar_Vendedor = @validar_vendedor,
ModoRapido = @modrapido,
CodBarra = @codbarra,
numcopias = @numcopias,
numMesas = @nummesas,
Produccion = @produccion,
PassCorreo = @passcorreo,
Met_Busqueda = @met_busqueda,
UrlOse = @urlose,
TipoOse = @tipoose,
urlosebeta = @urlosebeta ,
urloseotros = @urloseotros,
urloseotrosbeta = @urloseotrosbeta,
urloseaux = @urloseaux,
urloseauxbeta = @urloseauxbeta,
TipoMoneda = @tipomoneda,
Puerto = @puerto,
Ssl = @ssl,
Servidor_Email = @servidor_email,
nube = @nube

















































GO
/****** Object:  StoredProcedure [dbo].[spModificarDireccionPrincipal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarDireccionPrincipal]
@iddireccion int,
@direccion varchar(100),
@referencia varchar(MAX)
as
update mst_Cliente_Direccion set Direccion = @direccion, Referencia = @referencia
where id = @iddireccion


GO
/****** Object:  StoredProcedure [dbo].[spModificarGastosOperativos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarGastosOperativos]
@id int,
@idtipogasto int,
@num_bolfact varchar(100),
@ruc varchar(50),
@proveedor varchar(100),
@concepto varchar(50),
@monto money,
@idcaja int
as
update mst_GastosOperativos set
IdTipoGasto = @idtipogasto,
Num_BolFact = @num_bolfact,
Ruc = @ruc,
Proveedor = @proveedor,
Concepto = @concepto,
Monto = @monto,
idcaja = @idcaja
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarGrupo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
--EDITAR GRUPO
CREATE procedure [dbo].[spModificarGrupo]
@id int ,
@descripcion varchar(100),
@estado bit,
@usuarioModifica varchar(50)
as
update mst_Grupo
set Descripcion=@descripcion,
estado = @estado,
usuarioModifica = @usuarioModifica,
fechaModifica = getdate()
where id=@id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarGuia]
@id int,
@codigoDoc char(2),
@seriedoc char(4),
@numerodoc int,
@idcliente int,
@codigotipodocsunat int,
@dniruc varchar(20),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@observacion text,
@usuariomodifica varchar(50),
@fechainiciotraslado date,
@puntopartido varchar(100),
@puntollegada varchar(100),
@idtrasnportista int,
@placa varchar(20),
@idmotivo int,
@descripcionmotivo varchar(100),
@idventa int,
@idalmacen int
as
update mst_Guia set 
IdDocumento = @codigoDoc,
SerieDoc = @serieDoc,
NumeroDoc = @numeroDoc,
IdCliente = @idcliente,
CodigoTipoDoc = @codigoTipoDocSunat,
DniRuc = @dniRuc,
RazonSocial = @RazonSocial,
Direccion = @direccion,
Email = @email,
Anulado = 0,
Observacion = @observacion,
UsuarioModifica = @usuariomodifica,
FechaModifica = GETDATE(),
FechaInicioTraslado = @fechainiciotraslado,
PuntoPartido = @puntopartido,
PuntoLLegada = @puntollegada,
idtrasnportista = @idtrasnportista,
Placa = @placa,
IdMotivo = @idmotivo,
DescripcionMotivo = @descripcionmotivo,
IdAlmacen=@idalmacen
where Id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarGuiaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarGuiaDetalle]
@id int,
@idproducto int,
@cantidad money,
@idunidad int,
@factor decimal,
@descripcion text,
@peso decimal(18,2),
@codbarra varchar(100),
@adicional1 varchar(MAX)
as
update mst_guia_det set
IdProducto = @idproducto,
Cantidad = @cantidad,
IdUnidad = @idunidad,
Factor = @factor,
descripcion = @descripcion,
Peso = @peso,
CodigoBarra = @codbarra,
Adicional1 = @adicional1
where Id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarIcons]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarIcons]
@idmenu int,
@idsub int,
@imagen image
as
update tabla_SubMenus set icon = @imagen
where idmenu = @idmenu and id = @idsub



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarIconsMenu]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarIconsMenu]
@id int,
@imagen image
as
update tabla_Menus set Icono = @imagen
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarImagenProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarImagenProducto]
@id int,
@imagen image
as
update mst_ProductoDetalle set imagenProducto = @imagen
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarInventario]
@id int,
@idalmacen int,
@observacion varchar(100),
@estado bit,
@usuariomodifica varchar(50),
@tipoinventario varchar(50),
@fecha datetime
as
update mst_Inventario set
Id_Almacen = @idalmacen,
Observacion = @observacion,
Estado=  @estado,
usuariomodifica = @usuariomodifica,
FechaCrea = @fecha,
FechaModifica  = GETDATE(),
TipoInventario = @tipoinventario,
flag = 1
where id = @id





















































GO
/****** Object:  StoredProcedure [dbo].[spModificarInventario_Detalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarInventario_Detalle]
@id int,
@idinventario int,
@idproducto int,
@cantidad float,
@usuariomodifica varchar(50),
@idunidad int,
@factor decimal,
@costo money,
@total money,
@zona VARCHAR(100),
@stand VARCHAR(100)
as
update mst_Inventario_Detalle set
Id_Inventario = @idinventario,
Id_Producto = @idproducto,
Cantidad= @cantidad,
UsuarioModifica = @usuariomodifica,
FechaModifica = GETDATE(),
IdUnidad = @idunidad,
Factor = @factor,
costo = @costo,
total = @total,
zona = @zona,
stand = @stand
where id = @id
GO
/****** Object:  StoredProcedure [dbo].[spModificarLinea]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
--EDITAR LINEA
CREATE procedure [dbo].[spModificarLinea]
@idLinea int ,
@nombre varchar(100),
@estado bit,
@idgrupo int,
@usuarioModifica varchar(50)
as
update mst_Linea
set nombreLinea=@nombre,
estado = @estado,
idGrupo = @idgrupo,
usuarioModifica = @usuarioModifica,
fechaModifica = getdate()
where id=@idLinea























































GO
/****** Object:  StoredProcedure [dbo].[spModificarMarca]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------

-------------------Modificar-----------------------------
CREATE procedure [dbo].[spModificarMarca]
@idMarca int,
@nombreMarca varchar(100),
@estado bit,
@usuarioModifica varchar(50)
as
update mst_Marca set
nombreMarca=@nombreMarca,
estado = @estado,
usuarioModifica = @usuarioModifica,
fechaModifica = GETDATE()
where id=@idMarca























































GO
/****** Object:  StoredProcedure [dbo].[spModificarMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spModificarMedidas]
@id int,
@descripcion varchar(100),
@estado bit,
@usuariomodifica varchar(50)
as
update mst_Medidas set descripcion = @descripcion,
estado = @estado,
usuariomodifica = @usuariomodifica
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarPago]
@idventa int,
@contado bit,
@credito bit,
@efectivo money,
@visa money,
@mastercard money,
@total money,
@vuelto money,
@debitoVisa bit,
@debitoMastercard bit
as
update tabla_FormaPago set 
Contado = @contado,
Credito = @credito,
Efectivo = @efectivo,
visa = @visa,
Mastercard = @mastercard,
Total = @total,
Vuelto = @vuelto,
DebitoVisa = @debitoVisa,
DebitoMastercard = @debitoMastercard
where IdVenta = @idventa
GO
/****** Object:  StoredProcedure [dbo].[spModificarPermisosVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarPermisosVenta]
@idusuario int,
@maximo money,
@minimo money,
@estado bit
as
update mst_permisos_venta set
maximo = @maximo,
minimo = @minimo,
estado = @estado
where idusuario = @idusuario























































GO
/****** Object:  StoredProcedure [dbo].[spModificarPreContacto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarPreContacto]
@id int,
@codigodoc char(2),
@idcliente int,
@dniruc varchar(50),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@idusuario int,
@bolfac char(2),
@pm bit,
@idalmacen int,
@idpiso int,
@adicional varchar(250),
@beneficiario varchar(250),
@idconvenio int,
@esconvenio bit,
@idparentesco int
as
if(@pm = 0)
begin
	if(@esconvenio = 0)
		begin
			update tabla_Pre_Venta set
			CodigoDoc = @codigodoc,
			IdCliente = @idcliente,
			DniRuc = @dniruc,
			RazonSocial = @razonsocial,
			Direccion = @direccion,
			Email = @email,
			IdUsuario = @idusuario,
			bolfac = @bolfac,
			Idalmacen = @idalmacen,
			Adicional = @adicional,
			Beneficiario =@beneficiario,
			IdConvenio = @idconvenio,
			IdParentesco = @idparentesco
			where IdPedido = @id
			and Pagado = 0 and Eliminado = 0
		end
	else
		begin
			update tabla_Pre_Venta_Convenio set
			CodigoDoc = @codigodoc,
			IdCliente = @idcliente,
			DniRuc = @dniruc,
			RazonSocial = @razonsocial,
			Direccion = @direccion,
			Email = @email,
			IdUsuario = @idusuario,
			bolfac = @bolfac,
			Idalmacen = @idalmacen,
			Adicional = @adicional,
			Beneficiario = @beneficiario,
			IdConvenio = @idconvenio,
			IdParentesco = @idparentesco
			where Id = @id			
		end
end
else if (@pm = 1) begin
update tabla_Pre_Venta set
CodigoDoc = @codigodoc,
IdCliente = @idcliente,
DniRuc = @dniruc,
RazonSocial = @razonsocial,
Direccion = @direccion,
Email = @email,
IdUsuario = @idusuario,
bolfac = @bolfac,
Idalmacen = @idalmacen
where IdMesa = @id and IdPiso = @idpiso
and Pagado = 0 and Eliminado = 0
end

exec spIngresarOtrosImpuestos_Preventa @id, @pm,@esconvenio


















































GO
/****** Object:  StoredProcedure [dbo].[spModificarPreContacto_Normal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarPreContacto_Normal]
@id int,
@codigodoc char(2),
@idcliente int,
@dniruc varchar(50),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@idusuario int,
@bolfac char(2),
@pm bit
as
if(@pm = 0)
begin
update tabla_Pre_Venta set
CodigoDoc = @codigodoc,
IdCliente = @idcliente,
DniRuc = @dniruc,
RazonSocial = @razonsocial,
Direccion = @direccion,
Email = @email,
IdUsuario = @idusuario,
bolfac = @bolfac
where IdPedido = @id
and Pagado = 0 and Eliminado = 0
end
else
begin
update tabla_Pre_Venta set
CodigoDoc = @codigodoc,
IdCliente = @idcliente,
DniRuc = @dniruc,
RazonSocial = @razonsocial,
Direccion = @direccion,
Email = @email,
IdUsuario = @idusuario,
bolfac = @bolfac
where IdMesa = @id
and Pagado = 0 and Eliminado = 0
end

exec spIngresarOtrosImpuestos_Preventa @id, @pm
















































GO
/****** Object:  StoredProcedure [dbo].[spModificarProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------
-----------------------

----------------modificar------------
CREATE procedure [dbo].[spModificarProducto]
@idProducto int,
@nombreProducto varchar(100),
@IdMarca int,
@idsegmento char(2),
@idfamilia char(2),
@idclase char(2),
@usuarioModifica varchar(50),
@estado bit,
@idproveedor int,
@idtipo int,
@idproductosunat char(8),
@idgrupo int
as
update mst_Producto
set nombreProducto = @nombreProducto,
idMarca = @IdMarca,
IdSegmento = @idsegmento,
idfamilia = @idfamilia,
IdClase = @idclase,
usuarioModifica = @usuarioModifica, 
fechaModifica = GETDATE(),
estado = @estado,
idproveedor = @idproveedor,
IdTipoProducto = @idtipo,
IdProductoSunat = @idproductosunat,
idgrupo = @idgrupo
where id = @idproducto























































GO
/****** Object:  StoredProcedure [dbo].[spModificarProductoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------
--exec spInsertarProductoDetalle 'laptop','ddd','aaa','01010101101011',null,'maick'
--select * from TablaColor
--------------------------------------------------
--modificar
CREATE proc [dbo].[spModificarProductoDetalle]
@idproductodetalle int,
@Idtalla int,
@Idcolor int,
@descripcion varchar(100),
@codigobarra varchar(50),
@imagen image,
@usuariomodifica varchar(50),
@estado bit,
--
@stockinicial int,
@stockminimo int,
@fechavencimiento date,
@idmedida int,
@bit bit
as
if(@bit = 0)
update mst_ProductoDetalle
set idTalla = @Idtalla,
idColores = @Idcolor ,
descripcion = @descripcion,
codigoBarra = @codigobarra,
imagenProducto =  @imagen, 
usuarioModifica =  @usuariomodifica,
estado = @estado,
stockinicial = @stockinicial,
stockminimo = @stockminimo,
fechavencimiento = @fechavencimiento,
idmedida = @idmedida,
fechaModifica = GETDATE()
where Id = @idproductodetalle
else
update mst_ProductoDetalle
set idTalla = @Idtalla,
idColores = @Idcolor ,
descripcion = @descripcion,
codigoBarra = @codigobarra,
imagenProducto =  @imagen, 
usuarioModifica =  @usuariomodifica,
estado = @estado,
stockinicial = @stockinicial,
stockminimo = @stockminimo,
idmedida = @idmedida
where Id = @idproductodetalle






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarProductoPresentacion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarProductoPresentacion]
@idproductoPresentacion int,
@IdUnidad int,
@preciounitario money,
@usuariomodifica varchar(50),
@principal bit,
@estado bit,
@principalAlmacen bit,
@codigoBarraPresentacion varchar(100),
@verEnVentas bit
as
update mst_ProductoPresentacion set 
idUnidad = @IdUnidad,
precioUnitario = @preciounitario,
usuarioModifica = @usuariomodifica,
estado = @estado,
Principal = @principal,
fechaModifica = GETDATE(),
principalAlmacen = @principalAlmacen,
Codigo = @codigoBarraPresentacion,
VerEnVentas = @verEnVentas
where Id = @idproductoPresentacion
GO
/****** Object:  StoredProcedure [dbo].[spModificarProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------
CREATE proc [dbo].[spModificarProveedor]
@id int,
@nombre varchar(100),
@ruc varchar(20),
@direccion varchar(100),
@telefono varchar(20),
@email varchar(100),
@estado bit,
@usuariomodifica varchar(50)
as
update mst_Proveedor set
nombre = @nombre,
ruc = @ruc,
direccion = @direccion,
telefono = @telefono,
email = @email,
estado = @estado,
usuariomodifica = @usuariomodifica,
fechamodifica = GETDATE()
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarSerie]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarSerie]
@id int,
@serie varchar(50),
@usuariomodifica varchar(50)
as
update mst_Serie set
Serie = @serie,
UsuarioModifica =@usuariomodifica,
fechamodifica = GETDATE()
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarTalla]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--modificar
CREATE proc [dbo].[spModificarTalla]
@id int,
@descripcion varchar(10),
@estado bit,
@usuarioModifica varchar(50)
as
update mst_Talla set 
descripcion  = @descripcion,
usuarioModifica = @usuariomodifica,
estado = @estado,
fechaModifica = GETDATE()
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarTipoUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarTipoUsuario]
@id int,
@descripcion varchar(100),
@usuariomodifica varchar(50),
@estado bit
as
update mst_TipoUsuario set
descripcion = @descripcion,
usuarioModifica = @usuariomodifica,
fechaModifica = GETDATE(),
estado = @estado
where id = @id
























































GO
/****** Object:  StoredProcedure [dbo].[spModificarTransportista]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------
CREATE proc [dbo].[spModificarTransportista]
@id int,
@nombre varchar(100),
@codidoTipoDoc int,
@dniruc varchar(20),
@licencia varchar(20),
@direccion varchar(100),
@telefono varchar(20),
@email varchar(100),
@usuariomodifica varchar(50)
as
update mst_Transportistas set
Nombre = @nombre,
CodidoTipoDoc = @codidoTipoDoc,
DniRuc = @dniruc,
licencia = @licencia,
Direccion = @direccion,
Telefono =@telefono,
Email = @email,
UsuarioModifica = @usuariomodifica,
FechaModifica = GETDATE()
where id = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarUnidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------

----------------------modificar unidad--------------
CREATE procedure [dbo].[spModificarUnidad]
@id int,
@nombre varchar(100),
@factor decimal(18,2),
@usuarioModifica varchar(50),
@estado bit 
as
update mst_UnidadMedida set nombreUnidad = @nombre,
factor = @factor, usuarioModifica = @usuarioModifica, fechaModifica = getdate(), estado = @estado
where id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spModificarUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarUsuario]
@idusuario int,
@idtipousuario int,
@nombre varchar(100),
@dni varchar(50),
@direccion varchar(200),
@telefono varchar(100),
@usuario varchar(50),
@pass varchar(50),
@usuariomodifica varchar(50),
@estado bit,
@correo varchar(200),
@foto image,
@docVentaDefecto VARCHAR(2)
as
update mst_Usuarios set
idtipoUsuario = @idtipousuario,
nombre = @nombre,
dni = @dni,
direccion = @direccion,
telefono = @telefono,
usuario = @usuario,
pass = @pass,
usuariomodifica = @usuariomodifica,
fechamodifica =  GETDATE(),
estado = @estado,
correo = @correo,
Foto = @foto,
DocVentaDefecto = @docVentaDefecto
where id = @idusuario
GO
/****** Object:  StoredProcedure [dbo].[spModificarVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarVenta]
@id int,
@codigoDoc char(2),
@seriedoc char(4),
@numerodoc int,
@idcliente int,
@codigotipodocsunat int,
@dniruc varchar(20),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@observacion text,
@codigotiponotcredito char(2),
@descripcionnotacred varchar(50),
@codigodocafectado char(2),
@numerodocafectado varchar(50),
@usuariomodifica varchar(50),
@idformapago int,
@importepagado money,
@totalletras text,
@Hassh varchar(max),
@tipomoneda varchar(10)
as
update mst_Venta set 
IdDocumento = @codigoDoc,
SerieDoc = @serieDoc,
NumeroDoc = @numeroDoc,
IdCliente = @idcliente,
CodigoTipoDoc = @codigoTipoDocSunat,
DniRuc = @dniRuc,
RazonSocial = @RazonSocial,
Direccion = @direccion,
Email = @email,
Anulado = 0,
Observacion = @observacion,
TipoNotCred= @codigotiponotcredito,
DescripNotCred = @descripcionnotacred,
TipoDocAfectado = @codigotiponotcredito,
NumeroDocAfectado = @numerodocafectado,
UsuarioModifica = @usuariomodifica,
FechaModifica = GETDATE(),
IdFormaPago = @idformapago,
importepagado = @importepagado,
total_letras = @totalletras,
Hassh = @Hassh,
TipoMoneda = @tipomoneda
where Id = @id

EXEC spIngresarOtrosImpuestos_Venta @id






















































GO
/****** Object:  StoredProcedure [dbo].[spModificarVentaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarVentaDetalle]
@id int,
@idproducto int,
@preciounitario money,
@cantidad money,
@descuento money,
@idunidad int,
@factor decimal,
@subtotal money,
@idventa int,
@igv money,
@total money,
@descripcion text,
@adicional1 text,
@adicional2 date,
@adicional3 varchar(200),
@adicional4 varchar(200),
@codbarra varchar(100),
@igv_incluido bit
as
declare @igvaux money = (select igv from mst_Venta_det where Id = @id)
declare @subaux money = (select Subtotal from mst_Venta_det where Id = @id)
declare @descaux money = (select descuento from mst_Venta_det where Id = @id)

--update mst_Venta set 
--TotalVenta = TotalVenta - @subaux,
--Descuento = Descuento - @descaux
--where Id = @idventa

update mst_Venta_det set
IdProducto = @idproducto,
PrecioUnit = @preciounitario,
Cantidad = @cantidad,
Descuento = @descuento,
IdUnidad = @idunidad,
Factor = @factor,
Subtotal = @subtotal,
igv = @igv,
total = @total,
descripcion = @descripcion,
Adicional1 = @adicional1,
Adicional2=  @adicional2,
Adicional3 = @adicional3,
Adicional4 = @adicional4,
codigoBarra = @codbarra,
igv_incluido = @igv_incluido
where Id = @id

--update mst_Venta set
--TotalVenta = TotalVenta + @subtotal,
--Descuento = Descuento + @descuento
--where Id = @idventa

update tabla_FormaPago set
Total = Total - @subaux
where IdVenta = @idventa

update tabla_FormaPago set
Total = Total + @subtotal
where IdVenta = @idventa

exec spModificarVentaDetalle_Ext @id,@idproducto,@descripcion,@preciounitario, @cantidad,@total

exec spIngresarOtrosImpuestos_Venta @id

declare @idalmacen int = (select top 1 IdAlmacen from mst_Venta where Id = @idventa)

declare @iddetalle int = (select idProductosDetalle from mst_ProductoPresentacion where id = @idproducto)

exec spStockActualizarSaldoItem @idalmacen,@iddetalle



















































GO
/****** Object:  StoredProcedure [dbo].[spModificarVentaDetalle_Ext]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spModificarVentaDetalle_Ext]
@idventa_det int,
@idproducto int,
@descripcion varchar(200),
@precio money,
@cantidad money,
@total money
as
update tabla_venta_det_ext set 
idproducto = @idproducto,
descripcion = @descripcion,
precio = @precio,
cantidad = @cantidad,
total = @total
where idventa_det = @idventa_det



















































GO
/****** Object:  StoredProcedure [dbo].[spMopstrarDatosPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMopstrarDatosPago]
@idpedido int,
@idpiso int,
@bit bit
as

if(@bit = 0)
select 
IdPedido,
IdMesa, 
RazonSocial,
DniRuc,
d.Descripcion,
Total,
BolFac,
Descuento, 
u.usuario,
p.IdPiso
from tabla_Pre_Venta p
inner join mst_documentos d on p.BolFac = d.Codigo
inner join mst_Usuarios u on p.IdUsuario = u.Id
where Pagado = 0 and Eliminado = 0 and IdPedido = @idpedido
else

declare @adicional money
set @adicional = (select SUM(cast(Adicional4 as money)) from tabla_Pre_Venta_Detalle where Pagado = 0 and Eliminado = 0 and IdMesa = @idpedido and IdPiso = @idpiso)

select 
IdPedido,
IdMesa, 
RazonSocial,
DniRuc,
d.Descripcion,
(Total + @adicional) Total,
BolFac,
Descuento, 
u.usuario,
p.IdPiso
from tabla_Pre_Venta p
inner join mst_documentos d on p.BolFac = d.Codigo
inner join mst_Usuarios u on p.IdUsuario = u.Id
where Pagado = 0 and Eliminado = 0 and IdMesa = @idpedido and IdPiso = @idpiso
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrar]
@tbl varchar(100),
@tops varchar(5)
as
Declare @tabla nvarchar(max);
declare @top nvarchar(500);
set @top = '@tops varchar(5)';
if(@tops != 0)
Set @tabla = 'SELECT top '+@tops+' * from ' + @tbl + ' where flag = 1 order by id asc'
else
Set @tabla = 'SELECT * from ' + @tbl + ' where flag = 1 order by id asc'
exec sp_executesql @tabla






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrar_Horario_envio]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spMostrar_Horario_envio]
as
select hora_envio from tabla_configuracion_general



GO
/****** Object:  StoredProcedure [dbo].[spMostrarAlmacen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
CREATE proc [dbo].[spMostrarAlmacen]
as
select * from mst_Almacen
order by id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCierreCaja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarCierreCaja]
@idapertura int,
@efectivoocredito bit,
@idusuario int,
@idcaja int
as 
declare @gastos money =  (select sum(Monto) from mst_GastosOperativos where IdApertura = @idapertura and IdUsuario = @idusuario and idcaja = @idcaja)
if(@efectivoocredito = 0)
begin
select sum(Fp.Total) Efectivo, (sum(Visa) + sum(Mastercard)) Tarjetas from tabla_FormaPago fp
inner join mst_Venta v on fp.IdVenta = v.Id
where v.IdApertura = @idapertura and v.Anulado = 0 and Contado = 1 and v.IdCaja = @idcaja and v.IdUsuario = @idusuario
end
else
begin
select sum(fp.Total) Credito from tabla_FormaPago fp
inner join mst_Venta v on fp.IdVenta = v.Id
where v.IdApertura = @idapertura and v.Anulado = 0 and Credito = 1 and v.IdCaja = @idcaja and v.IdUsuario = @idusuario
end




























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarClase_Familia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spMostrarClase_Familia]
@id char(4),
@bit bit
as
if(@bit = 0)
select c.Codigo,cod_segfam+codigo+ ' - ' + Descripcion [descripcion] from mst_Clase c
where cod_segfam = @id and c.flag = 1
else
declare @idaux char(2) = (select top 1 CodFamilia from mst_clase where Codigo = @id)
select codigo,Descripcion [descripcion] from mst_Clase
where Codigo = @idaux and flag = 1






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spMostrarCliente]
@top bit
as
if(@top = 0)
select top 200 c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N° Documento',
c.razonSocial as 'Razón',
c.nombreComercial as 'Nombre Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Teléfono',
c.correo as 'Correo',
c.usuarioCrea as 'Usuario Crea',
c.fechaCrea as 'Fecha Crea', 
c.usuarioModifica as 'Usuario Modifica', 
c.fechaModifica as 'Fecha Mod.',
c.estado as 'Estado',
TD.codigoSunat AS 'ID DOCUMENTO',
ISNULL(c.nacionalidad, 0) as 'nacionalidad',
c.DefaultPago
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.idcliente
where c.flag = 1 and cd.principal = 1
order by c.Id desc
else
select
c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N° Documento',
c.razonSocial as 'Razón',
c.nombreComercial as 'Nombre Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Teléfono',
c.correo as 'Correo',
c.usuarioCrea as 'Usuario Crea',
c.fechaCrea as 'Fecha Crea', 
c.usuarioModifica as 'Usuario Modifica', 
c.fechaModifica as 'Fecha Mod.',
c.estado as 'Estado',
TD.codigoSunat AS 'ID DOCUMENTO',
ISNULL(c.nacionalidad, 0) as 'nacionalidad',
       c.DefaultPago
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.idcliente
where c.flag = 1 and cd.principal = 1
order by c.Id desc
GO
/****** Object:  StoredProcedure [dbo].[spMostrarClienteVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spMostrarClienteVenta]
@id int
as
if(@id != 0)
begin
select top 100  c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N',
c.razonSocial as 'Razon'
,c.nombreComercial as 'Nombre_Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Telefono',
c.correo as 'Correo',
c.estado as 'Estado',
TD.codigoSunat AS 'ID_DOCUMENTO',
cd.Principal,
ISNULL(c.nacionalidad, 0) as 'nacionalidad',
               isnull(c.DefaultPago, 'C') as 'DefaultPago'
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where c.flag = 1 and c.Id = @id
order by c.id ASC
end
else
begin
select top 100  c.id as 'ID',
td.descripcion as 'Documento',
c.numeroDocumento as 'N',
c.razonSocial as 'Razon'
,c.nombreComercial as 'Nombre_Comercial',
cd.Direccion as 'Direccion',
c.telefono as 'Telefono',
c.correo as 'Correo',
c.estado as 'Estado',
TD.codigoSunat AS 'ID_DOCUMENTO',
cd.Principal,
ISNULL(c.nacionalidad, 0) as 'nacionalidad',
               isnull(c.DefaultPago, 'C') as 'DefaultPago'
from mst_Cliente c
inner join mst_TipoDocumento td on c.idDocumento = td.codigoSunat
inner join mst_Cliente_Direccion cd on c.Id = cd.IdCliente
where c.flag = 1 
order by c.id ASC
end
GO
/****** Object:  StoredProcedure [dbo].[spMostrarColor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--mostrar
CREATE proc [dbo].[spMostrarColor]
@top bit
as
if(@top=0)
select TOP 200
 id as 'ID', 
descripcion as 'Descripción',
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación',
usuarioModifica as 'Usuario de Modificación',
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Color
where flag = 1
order by id desc
else
select
 id as 'ID', 
descripcion as 'Descripción',
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación',
usuarioModifica as 'Usuario de Modificación',
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from mst_Color
where flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCombo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[spMostrarCombo]
(
 @nombreTabla nvarchar(max),
 @columna varchar(max),
 @columna2 varchar(max),
 @columna3 varchar(max)
)

As

Declare @tabla nvarchar(max);

declare @columnas nvarchar(max);

set @columnas = '@columna varchar(max)';

if(@columna3='0')
Set @tabla = 'SELECT '+ cast(@columna as varchar)+',' + cast(@columna2 as varchar)+ ' FROM ' + QUOTENAME(@nombreTabla) + ' where flag=1 and estado=1';
else 
Set @tabla = 'SELECT '+ cast(@columna as varchar)+', cast(' +@columna2 + ' as varchar) + '' - '' + cast('+ @columna3 + ' as varchar)'+@columna2 +' FROM ' + QUOTENAME(@nombreTabla) + ' where flag=1 and estado=1 ';
exec sp_executesql @tabla
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCompra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----
CREATE proc [dbo].[spMostrarCompra]
@top bit
as
if(@top= 0)
select 
c.Id ,
c.FechaEmision,
c.FechaIngreso,
a.Nombre [Almacén],
d.Descripcion[Documento],
CAST(c.Serie as varchar) + '-' + CAST(c.Numero as varchar) [Serie],
p.nombre[Proveedor],
c.Direccion,
fp.FormadePago,
c.FechaVence,
c.Subtotal,
c.TotalIgv,
c.Totaldescuento,
c.Total,
c.Estado
from mst_Compras c
inner join mst_Almacen a on c.IdAlmacen = a.Id
inner join mst_documentos d on c.TipoDoc = d.Codigo
inner join mst_Proveedor p on c.IdProveedor = p.id
inner join mst_FormaPago fp on c.FormaPago = fp.Id
where c.Flag = 1

else

select 
c.Id ,
c.FechaEmision,
c.FechaIngreso,
CAST(a.Id as varchar) + '-' + a.Nombre [Id-Almacén],
CAST( d.Codigo as varchar) +'-' + d.Descripcion[Documento],
CAST(c.Serie as varchar) + '-' + CAST(c.Numero as varchar) [Serie],
cast(p.id as varchar)[IdProveedor],
c.CodigoTipoDoc,
c.DniRuc,
c.RazonSocial,
c.Direccion,
c.Email,
CAST(fp.id as varchar) + '-' + fp.FormadePago,
c.FechaVence,
c.Subtotal,
c.TotalIgv,
c.Totaldescuento,
c.Total,
c.Estado,
c.Observacion,
c.porc_igv
from mst_Compras c
inner join mst_Almacen a on c.IdAlmacen = a.Id
inner join mst_documentos d on c.TipoDoc = d.Codigo
inner join mst_Proveedor p on c.IdProveedor = p.id
inner join mst_FormaPago fp on c.FormaPago = fp.Id
where c.Flag = 1

























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCompraDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spMostrarCompraDetalle]
@id int
as
select cd.IdProducto, pd.codigoBarra, cd.Descripcion, um.nombreUnidad, um.factor,
cd.Cantidad, cd.Precio, cd.Descuento, cd.Subtotal, CAST( cd.IdUnidad as varchar) + '-' +CAST( cd.Id as varchar),
cd.Igv, cd.Total,
cd.Igv_incluido
from mst_ComprasDetalles cd 
inner join mst_ProductoPresentacion pp on cd.IdProducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_UnidadMedida um on cd.IdUnidad = um.Id
where IdCompra = @id and cd.Flag = 1






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarConfig]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spMostrarConfig]
as
select * from tabla_configuracion_general























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarCPE]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarCPE]
@fechainicio date,
@fechafin date,
@doc char(2),
@id int,
@estado int,
@serienum CHAR(4),
@idusuario int
AS
declare @enviado bit,@sinenviar bit
if(@estado=2)
	begin
	set @enviado = 1
	set @sinenviar = 0
	end
else if(@estado = 1)
	begin
	set @enviado = 1
	set @sinenviar = 1
	end
else if(@estado = 0)
	begin
	set @enviado = 0
	set @sinenviar = 0
	end
if(@id = 0)
begin
	if(@estado != 2)
		begin
		if(@doc != '00')
			begin
			SELECT
			id_cab_cpe as Id,
			LTRIM(RTRIM(codigo)) as Codigo,
			cast(estatus as bit) as anulado,
			fecha_emi_doc_cpe as Fecha,
			LTRIM(RTRIM(descri_doc)) Documento,
			LTRIM(RTRIM(serie_doc_cpe)) Serie,
			LTRIM(RTRIM(nro_doc_cpe)) Numero,
			LTRIM(RTRIM(ruc_dni_cliente)) RUC_DNI,
			LTRIM(RTRIM(nombre_cliente)) Cliente,		
			direccion,	
			tipo_moneda Moneda,
			sub_total SubTotal,
			igv,
			otros_impuestos ICBPER,
			total_cpe Importe,
			cast(doc_firma as bit) [XML],
			cast(doc_cdr as bit) [CDR],
			cast(1 as bit) [PDF],
			cast(doc_email as bit) [EMAIL],
			cast(doc_publicado as bit) [WEB],
			des_cod_sunat [RESPUESTA SUNAT],
			correo_cliente as 'CORREO_CLIENTE',
			tipo_doc_cli 'Tipo_Doc_cliente',
			status_verificado,
			codigo_verificado,
			mensaje_verificado,
			observacion_verificado
			FROM vw_tbl_cab_cpe
			where ((cast(fecha_emi_doc_cpe as date) between @fechainicio and @fechafin) and codigo = @doc
			and doc_cdr = @enviado and doc_cdr = @sinenviar 
			OR serie_doc_cpe like '%'+@serienum+'%')
			--and id_usuario = @idusuario
			order by fecha_emi_doc_cpe asc
			end
			else
			begin
			SELECT 
			id_cab_cpe Id,
			codigo Codigo,
			cast(estatus as bit) anulado,
			fecha_emi_doc_cpe Fecha,
			LTRIM(RTRIM(descri_doc)) Documento,
			LTRIM(RTRIM(serie_doc_cpe)) Serie,
			LTRIM(RTRIM(nro_doc_cpe)) Numero,
			LTRIM(RTRIM(ruc_dni_cliente)) RUC_DNI,
			LTRIM(RTRIM(nombre_cliente)) Cliente,
			direccion,
			tipo_moneda Moneda,
			sub_total SubTotal,
			igv,
			otros_impuestos ICBPER,
			total_cpe Importe,
			cast(doc_firma as bit) [XML],
			cast(doc_cdr as bit) [CDR],
			cast(1 as bit) [PDF],
			cast(doc_email as bit) [EMAIL],
			cast(doc_publicado as bit) [WEB],
			des_cod_sunat [RESPUESTA SUNAT],
			correo_cliente as 'CORREO_CLIENTE',
			tipo_doc_cli 'Tipo_Doc_cliente',
			status_verificado,
			codigo_verificado,
			mensaje_verificado,
			observacion_verificado
			FROM vw_tbl_cab_cpe
			where ((cast(fecha_emi_doc_cpe as date) between @fechainicio and @fechafin)
			and doc_cdr = @enviado and doc_cdr = @sinenviar
			OR serie_doc_cpe like '%'+@serienum+'%') 
			--and id_usuario = @idusuario
			order by fecha_emi_doc_cpe asc
			end
		end
	else
		begin
		if(@doc != '00')
			begin
			SELECT
			id_cab_cpe as Id,
			LTRIM(RTRIM(codigo)) as Codigo,
			cast(estatus as bit) as anulado,
			fecha_emi_doc_cpe as Fecha,
			LTRIM(RTRIM(descri_doc)) Documento,
			LTRIM(RTRIM(serie_doc_cpe)) Serie,
			LTRIM(RTRIM(nro_doc_cpe)) Numero,
			LTRIM(RTRIM(ruc_dni_cliente)) RUC_DNI,
			LTRIM(RTRIM(nombre_cliente)) Cliente,
			direccion,
			tipo_moneda Moneda,
			sub_total SubTotal,
			igv,
			otros_impuestos ICBPER,
			total_cpe Importe,
			cast(doc_firma as bit) [XML],
			cast(doc_cdr as bit) [CDR],
			cast(1 as bit) [PDF],
			cast(doc_email as bit) [EMAIL],
			cast(doc_publicado as bit) [WEB],
			des_cod_sunat [RESPUESTA SUNAT],
			correo_cliente as 'CORREO_CLIENTE',
			tipo_doc_cli 'Tipo_Doc_cliente',
			status_verificado,
			codigo_verificado,
			mensaje_verificado,
			observacion_verificado
			FROM vw_tbl_cab_cpe
			where ((cast(fecha_emi_doc_cpe as date) between @fechainicio and @fechafin) and codigo = @doc
			OR serie_doc_cpe like '%'+@serienum+'%')
			--and id_usuario = @idusuario
			order by fecha_emi_doc_cpe asc
			end
			else
			begin
			SELECT 
			id_cab_cpe Id,
			codigo Codigo,
			cast(estatus as bit) anulado,
			fecha_emi_doc_cpe Fecha,
			LTRIM(RTRIM(descri_doc)) Documento,
			LTRIM(RTRIM(serie_doc_cpe)) Serie,
			LTRIM(RTRIM(nro_doc_cpe)) Numero,
			LTRIM(RTRIM(ruc_dni_cliente)) RUC_DNI,
			LTRIM(RTRIM(nombre_cliente)) Cliente,
			direccion,
			tipo_moneda Moneda,
			sub_total SubTotal,
			igv,			
			otros_impuestos ICBPER,
			total_cpe Importe,
			cast(doc_firma as bit) [XML],
			cast(doc_cdr as bit) [CDR],
			cast(1 as bit) [PDF],
			cast(doc_email as bit) [EMAIL],
			cast(doc_publicado as bit) [WEB],
			des_cod_sunat [RESPUESTA SUNAT],
			correo_cliente as 'CORREO_CLIENTE',
			tipo_doc_cli 'Tipo_Doc_cliente',
			status_verificado,
			codigo_verificado,
			mensaje_verificado,
			observacion_verificado
			FROM vw_tbl_cab_cpe
			where ((cast(fecha_emi_doc_cpe as date) between @fechainicio and @fechafin)
			OR serie_doc_cpe like '%'+@serienum+'%')
			--and id_usuario = @idusuario
			order by fecha_emi_doc_cpe asc
			end
		end
end
else
begin
SELECT 
tipo_moneda 'TIPO_MONEDA',
'0.00',
'0.00',
'0.00',
format(ope_exonerada,'N','es-pe') 'TOTAL_VENTA',
LTRIM(RTRIM(tipo_afec_igv))  'TIPO_IGV',
format(18,'N','es-pe') 'PORC_IGV',
total_cpe_letras 'TOTAL_LETRAS',
CAST(cast(fecha_emi_doc_cpe as date) as varchar(10)) 'FECHA_EMISION',
'' 'RUC_EMISOR',
'' 'RAZON_EMPRESA',
'' 'GUIA_REMISION',
'' 'RUC_EMISOR',
'' 'RAZON_EMISOR',
'' 'UBIGEO',
'' 'DIRECCION',
'' 'CIUDAD',
'' 'DISTRITO',
LTRIM(RTRIM(ruc_dni_cliente)) 'DNI_RUC',
LTRIM(RTRIM(TIPO_DOC_CLI)) 'CODIGO_TIPO_DOC',
LTRIM(RTRIM(nombre_cliente)) 'RAZON_SOCIAL',
LTRIM(RTRIM(direccion)) 'DIRECCION_CLIENTE',
LTRIM(RTRIM(tipo_moneda)) 'TIPO_MONEDA2',
format(igv,'N','es-pe')  'IGV2',
format(descuento,'N','es-pe') 'DESCUENTO',
format(sub_total,'N','es-pe')  'SUB_TOTAL',
format(total_cpe,'N','es-pe')  'TOTAL',
LTRIM(RTRIM(serie_nro_doc_cpe)) 'SERIE_NUMERO',
LTRIM(RTRIM(nro_doc_afecta)) 'DOC_AFECTA',
LTRIM(RTRIM(TIPO_NOT_CREDE)) 'TIPO_NOT_CRED',
LTRIM(RTRIM(descri_not_crede)) 'DESCRIP_NOT_CRED',
LTRIM(RTRIM(tipo_doc_afecta)) 'TIPO_DOC_AFECTADO',
LTRIM(RTRIM(codigo)) 'ID_COCUMENTO',
'' 'NOMBRE_COMERCIAL',
'' 'USUARIO_SOL',
'' 'CONTRA_SOL',
'' 'CONTRA_FIRMA',
otros_impuestos,
tipo_operacion 'TIPO_OPERACION',
ope_gravada 'TOTAL_VENTA_GRAVADA',
ope_exonerada 'TOTAL_VENTA_EXONERADA',
forma_pago 'FORMA_PAGO'
FROM vw_tbl_cab_cpe
where id_cab_cpe = @ID
end
GO
/****** Object:  StoredProcedure [dbo].[spMostrarCPE_DETALLE]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarCPE_DETALLE]
@id int
AS
select
ROW_NUMBER() OVER(ORDER BY id_item_cab_cpe DESC) AS Row,
format(cantidad,'N','es-pe') 'CANTIDAD',
format(sub_total,'N','es-pe') 'SUB_TOTAL',
format(pre_total,'N','es-pe') 'TOTAL',
format(MONTO_IGV,'N','es-pe') 'IGV',
nom_producto 'DESCRIPCION',
id_producto 'ID_PRODUCTO',
format(pre_unitario,'N','es-pe')  'PRECIO_UNIT',
IdProductoSunat 'ID_PRODUCTO_SUNAT',
TipoAdicional 'TIPO_ADICIONAL',
NumAdicional 'NUMERO_ADICIONAL',
convert(date,FechaAdicional,103) 'FECHA_ADICIONAL',
OtroAdicional 'OTRO_ADICIONAL',
otros_impuestos
from vw_tbl_items_cab_cpe 
where id_cab_cpe = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarDescripcion]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarDescripcion]
as
select isnull(descripcion,'') as 'nombre' from mst_ProductoDetalle



















































GO
/****** Object:  StoredProcedure [dbo].[spmostrardescuentos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------
CREATE proc [dbo].[spmostrardescuentos]
@idgrupo int
as
if(@idgrupo = 0)
	select * from descuentos
else
	select * from descuentos where idgrupo = @idgrupo


















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarDetalles]
@id int
as
select * from mst_Producto p
inner join mst_Proveedor pd on p.idproveedor =pd.id
where p.Id = @id























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarDirecciones]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarDirecciones]
@idcliente int
as
select Id,Direccion,Principal, Referencia from mst_Cliente_Direccion 
where flag = 1 and Estado = 1 and IdCliente = @idcliente


GO
/****** Object:  StoredProcedure [dbo].[spMostrarDocumentos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarDocumentos]
as
select  Codigo, Descripcion from mst_documentos 
where flag = 1
order by id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarFamilia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---Procedimiento de Almacenado Mostrar
CREATE procedure [dbo].[spMostrarFamilia]
@top bit
as
if(@top = 0)
select top 200 f.Id as 'ID',
f.nombreFamilia as 'Nombre',
l.nombreLinea as 'Linea', 
f.usuarioCrea as 'Usuario Creador', 
f.fechaCrea as 'Fecha de Creación', 
f.usuarioModifica as 'Usuario Modifica', 
f.fechaModifica as 'Fecha Modificación', 
f.estado as 'Estado',
cast(l.Id as varchar) as 'ID LINEA'
from  mst_Familia f
inner join  mst_Linea l on f.idLinea = l.Id
where f.flag = 1
order by f.id desc
else
select 
f.Id as 'ID',
f.nombreFamilia as 'Nombre',
l.nombreLinea as 'Linea', 
f.usuarioCrea as 'Usuario Creador', 
f.fechaCrea as 'Fecha de Creación', 
f.usuarioModifica as 'Usuario Modifica', 
f.fechaModifica as 'Fecha Modificación', 
f.estado as 'Estado',
cast(l.Id as varchar) as 'ID LINEA'
from  mst_Familia f
inner join  mst_Linea l on f.idLinea = l.Id
where f.flag = 1
order by f.id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarFamilia_Segmento]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarFamilia_Segmento]
@id char(2),
@bit bit
as
if(@bit = 0)
select codigo,codsegmento+codigo+' - ' + Descripcion [descripcion] from mst_familia
where CodSegmento = @id and flag = 1
else
select codigo,codigo+' - ' + Descripcion [descripcion] from mst_segmento
where flag = 1



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarFormaPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarFormaPago]
@id int
as
select * from tabla_FormaPago
where IdVenta = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarGastos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarGastos]
@idapertura int
as
select *,cast(t.Id as varchar) + '-'+ t.Descripcion TipoGasto from mst_GastosOperativos g
inner join mst_tipoGasto t on g.IdTipoGasto = t.Id
where eliminado = 0
order by g.id desc
GO
/****** Object:  StoredProcedure [dbo].[spMostrarGlobal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure  [dbo].[spMostrarGlobal]
(
 @nombreTabla varchar(100)
)

As

Declare @tabla nvarchar(max);

Set @tabla = 'SELECT * FROM ' + QUOTENAME(@nombreTabla) + ' where flag = 1 ORDER BY ID DESC'
exec sp_executesql @tabla





















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarGuia]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select*from mst_Guia
CREATE proc [dbo].[spMostrarGuia]
@bit bit,
@id int
as
if(@bit = 0)
begin
select 
g.Id,
v.SerieDoc + '-' + LTRIM(str(v.NumeroDoc)) [Doc. Ref.],
d.Descripcion [Documento],
g.SerieDoc [Serie],
g.NumeroDoc [Numero],
g.FechaEmision [Fecha Emision],
g.razonSocial [Razón Social],
g.DniRuc [RUC],
g.direccion [Direccion],
g.FechaInicioTraslado [Fecha  Traslado],
g.PuntoPartido [Punto Partida],
g.PuntoLLegada [Punto Llegada],
g.anulado Anulado
from mst_Guia g
inner join mst_documentos d on g.IdDocumento = d.Codigo
inner join mst_Cliente c on g.idcliente = c.id
left join mst_Venta v on g.IdVenta = v.Id
order by g.Id desc
end
else
begin
	if(@id = 0)
		begin
						select 
				g.Id,
				d.Descripcion Documento,
				g.SerieDoc Serie,
				g.NumeroDoc Numero,
				g.FechaInicioTraslado FechaInicioTraslado,
				g.CodigoTipoDoc,
				g.dniruc,
				g.RazonSocial,
				g.PuntoPartido,
				g.PuntoLLegada,
				g.IdMotivo,
				g.DescripcionMotivo,
				t.DniRuc DniTransportista,
				t.Nombre Nombre_Transportista,
				g.Placa,
				t.Licencia,
				dd.Descripcion Doc_Ref,
				v.SerieDoc Serie_Ref,
				v.NumeroDoc Numero_Ref,
				G.IdTrasnportista,				
				ISNULL(v.id , 0) idventa,
				G.IdCliente
				from mst_Guia g
				inner join mst_documentos d on g.IdDocumento = d.Codigo
				inner join mst_Cliente c on g.idcliente = c.id
				inner join mst_Transportistas t on g.IdTrasnportista = t.Id
				left join mst_Venta v on g.idventa = v.Id
				LEFT join mst_documentos dd on v.IdDocumento = dd.Codigo
				order by g.Id desc
		end
	else
		begin
						select 
				g.Id,
				d.Descripcion Documento,
				g.SerieDoc Serie,
				g.NumeroDoc Numero,
				g.FechaInicioTraslado FechaInicioTraslado,
				g.CodigoTipoDoc,
				g.dniruc,
				g.RazonSocial,
				g.PuntoPartido,
				g.PuntoLLegada,
				g.IdMotivo,
				g.DescripcionMotivo,
				t.DniRuc DniTransportista,
				t.Nombre Nombre_Transportista,
				g.Placa,
				t.Licencia,
				dd.Descripcion Doc_Ref,
				v.SerieDoc Serie_Ref,
				v.NumeroDoc Numero_Ref,
				G.IdTrasnportista,
				ISNULL(v.id , 0) idventa,
				G.IdCliente
				from mst_Guia g
				inner join mst_documentos d on g.IdDocumento = d.Codigo
				inner join mst_Cliente c on g.idcliente = c.id
				inner join mst_Transportistas t on g.IdTrasnportista = t.Id
				left join mst_Venta v on g.idventa = v.Id
				LEFT join mst_documentos dd on v.IdDocumento = dd.Codigo
				where g.id = @id
				order by g.Id desc
		end
end



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarGuiaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarGuiaDetalle]
@id int
as
select IdProducto,
gd.CodigoBarra,
descripcion Descripcion,
Cantidad,
um.nombreUnidad Unidad,
um.factor,
Peso,
cast(IdUnidad as varchar) + '-' + cast(gd.Id as varchar) as 'IdUnidad_Detalle',
gd.Adicional1
from mst_Guia_det gd
inner join mst_unidadmedida um on gd.IdUnidad = um.id
where IdGuia= @id and gd.Flag = 1  and Anulado = 0



















































GO
/****** Object:  StoredProcedure [dbo].[spmostrarIds_Productos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spmostrarIds_Productos]
@id int,
@bit int
as
if(@bit = 0)
begin
select
p.Id as 'IdProducto',
pd.Id as 'IdProductoDet',
pp.Id as 'IdProductoPres',
p.IdGrupo as 'IdGrupo'
from mst_ProductoPresentacion pp
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.id
inner join mst_Producto p on pd.idProducto = p.Id
where p.Id = @id
end

else if(@bit = 1)
begin
select
p.Id as 'IdProducto',
pd.Id as 'IdProductoDet',
pp.Id as 'IdProductoPres',
p.IdGrupo as 'IdGrupo'
from mst_ProductoPresentacion pp
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.id
inner join mst_Producto p on pd.idProducto = p.Id
where pd.Id = @id
end


if(@bit = 2)
begin
select
p.Id as 'IdProducto',
pd.Id as 'IdProductoDet',
pp.Id as 'IdProductoPres',
p.IdGrupo as 'IdGrupo'
from mst_ProductoPresentacion pp
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.id
inner join mst_Producto p on pd.idProducto = p.Id
where pp.Id = @id
end



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarInventario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarInventario]
as
select i.id,
i.tipoinventario,
a.Nombre,
i.Observacion,
i.UsuarioCrea,
i.FechaCrea,
i.UsuarioModifica,
i.FechaModifica,
''Estado,
i.Estado [E],
a.Id as 'IdAlmacen'
from mst_Inventario i
inner join mst_Almacen a on i.Id_Almacen = a.Id
where i.flag = 1
order by i.id desc
GO
/****** Object:  StoredProcedure [dbo].[spMostrarLinea]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---
--MOSTRAR LINEA
CREATE procedure [dbo].[spMostrarLinea]
@top bit
as
if(@top = 0)
select top 200 l.id as 'ID', 
l.nombreLinea as 'Nombre', 
g.nombreGrupo as 'Grupo',
l.usuarioCrea as 'Usuario de Creación',
l.fechaCrea as 'Fecha de Creación',
l.usuarioModifica as 'Usuario de Modificación', 
l.fechaModifica as 'Fecha de Modificación', 
l.estado as 'Estado',
CAST(g.Id AS varchar) as 'ID GRUPO'
from  mst_Linea l
inner join  mst_Grupo g on l.idGrupo = g.id
where l.flag = 1
order by l.id desc
else
select
l.id as 'ID', 
l.nombreLinea as 'Nombre', 
g.nombreGrupo as 'Grupo',
l.usuarioCrea as 'Usuario de Creación',
l.fechaCrea as 'Fecha de Creación',
l.usuarioModifica as 'Usuario de Modificación', 
l.fechaModifica as 'Fecha de Modificación', 
l.estado as 'Estado',
CAST(g.Id AS varchar) as 'ID GRUPO'
from  mst_Linea l
inner join  mst_Grupo g on l.idGrupo = g.id
where l.flag = 1
order by l.id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarLinea_Grupo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarLinea_Grupo]
@id int
as
select id,nombreLinea from mst_Linea
where idGrupo = @id and flag = 1
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarMarcas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------

-----------------------Mostrar----------------------------
CREATE procedure [dbo].[spMostrarMarcas]
@top bit
as
if(@top = 0)
select top 200 Id as 'ID', 
nombreMarca as 'Nombre Marca', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificacion',
fechaModifica as 'Fecha de Modificación', 
estado as 'Estado' 
from  mst_Marca
where flag = 1
order by id desc
else
select
Id as 'ID', 
nombreMarca as 'Nombre Marca', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificacion',
fechaModifica as 'Fecha de Modificación', 
estado as 'Estado' 
from  mst_Marca
where flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarMedidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------
CREATE proc [dbo].[spMostrarMedidas]
@top bit
as
if(@top = 0)
select TOP 200
m.id [Id],
m.descripcion [Medida],
m.usuariocrea [Usuario Crea.],
m.fechacrea [Fecha Crea],
m.usuariomodifica [Usuario Modifica],
m.fechamodifica [Fecha Modifica],
m.estado [Estado]
from mst_Medidas m
where m.flag = 1
order by id desc

else
 select
m.id [Id],
m.descripcion [Medida],
m.usuariocrea [Usuario Crea.],
m.fechacrea [Fecha Crea],
m.usuariomodifica [Usuario Modifica],
m.fechamodifica [Fecha Modifica],
m.estado [Estado]
from mst_Medidas m
where m.flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarMenus]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarMenus]
as
select * from tabla_Menus























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarOses]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarOses]
@numero int
as
if(@numero = 0)
begin
select * from mst_oses
end
else 
begin
select * from mst_oses
where numose = @numero
end


















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarPedido]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPedido]
@id int,
@bit bit,
@esconvenio bit
as
if(@bit = 0)
	begin
		if @esconvenio = 0
			begin
				select 
				IdPedido,
				p.IdCliente,
				CodigoDoc,
				DniRuc,
				p.RazonSocial,
				p.Direccion,
				Email,
				BolFac,
				u.Id,
				u.usuario,
				IdPiso,
				Adicional,
				Beneficiario,
				IdConvenio,
				co.Razon,
				p.IdParentesco,
				c.nacionalidad,
				isnull(p.Idalmacen,1) as 'IdAlmacen'
				from tabla_Pre_Venta p
				inner join mst_TipoDocumento td on p.CodigoDoc = td.codigoSunat
				inner join mst_Usuarios u on IdUsuario = u.Id
				left join mst_convenios co on p.IdConvenio = co.Id
				left join mst_Cliente c on p.IdCliente = c.Id
				where p.IdPedido = @id and p.pagado = 0 and p.eliminado = 0
			end
		else
			begin
				select 
				p.Id,
				p.IdCliente,
				CodigoDoc,
				DniRuc,
				p.RazonSocial,
				p.Direccion,
				Email,
				BolFac,
				u.Id,
				u.usuario,
				IdPiso,
				Adicional,
				Beneficiario,
				IdConvenio,
				co.Razon,
				p.IdParentesco,
				c.nacionalidad,
				isnull(p.Idalmacen,1) as 'IdAlmacen'
				from tabla_Pre_Venta_Convenio p
				inner join mst_TipoDocumento td on p.CodigoDoc = td.codigoSunat
				inner join mst_Usuarios u on IdUsuario = u.Id
				left join mst_convenios co on p.IdConvenio = co.Id
				left join mst_Cliente c on p.IdCliente = c.Id
				where p.Id = @id and p.pagado = 0 and p.eliminado = 0	
			end
	end
else if (@bit = 1)
select 
idmesa,
p.IdCliente,
CodigoDoc,
DniRuc,
p.RazonSocial,
p.Direccion,
Email,
BolFac,
u.Id,
u.usuario,
IdPiso,
Adicional,
Beneficiario,
IdConvenio,
co.Razon,
p.countPecho,
p.countPierna,
p.textObservation,
c.nacionalidad,
isnull(p.Idalmacen,1) as 'IdAlmacen'
from tabla_Pre_Venta p
inner join mst_TipoDocumento td on p.CodigoDoc = td.codigoSunat
inner join mst_Usuarios u on IdUsuario = u.Id
left join mst_convenios co on p.IdConvenio = co.Id
left join mst_Cliente c on p.IdCliente = c.Id
where p.IdMesa = @id and p.pagado = 0 and p.eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[spMostrarPedidoVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPedidoVenta]
@id int,
@pm bit
as
if(@pm = 0)
select CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,IdUsuario,Idalmacen,0 as IdMesa, Adicional, Beneficiario, IdConvenio, IdParentesco, countPecho, countPierna, textObservation
from tabla_Pre_Venta
where IdPedido = @id and Pagado = 0 and Eliminado = 0
else
select CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,IdUsuario,Idalmacen, IdMesa, Adicional, Beneficiario, IdConvenio, IdParentesco, countPecho, countPierna, textObservation
from tabla_Pre_Venta
where IdMesa = @id and Pagado = 0 and Eliminado = 0
GO
/****** Object:  StoredProcedure [dbo].[spMostrarPermisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPermisos]
@id int
as
select * from mst_permisos_venta
where IdUsuario = @id























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPisos]
as
select * from tabla_RestPisos
where estado = 1 and flag =1



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarPreVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPreVenta]
@pm bit,
@idpiso int
as
if(@pm = 0) 
select *
from tabla_Pre_Venta
where Eliminado = 0 and pagado = 0 and IdMesa = 0
order by IdPedido asc

else

select *
from tabla_Pre_Venta
where IdPiso = @idpiso and Pagado = 0 and Eliminado = 0



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarProducto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------
------------------------------------

--------------mostrar-----------------
CREATE procedure [dbo].[spMostrarProducto]
as
select top 200 pd.id as 'ID' ,
pd.codigobarra as 'Codigo Barra',
p.nombreProducto + ' ' + pd.descripcion + ' ' + m.nombreMarca +' ' +t.descripcion+' '+ c.descripcion as 'Nombre',
um.nombreUnidad as 'Unidad',
(pp.PrecioUnitario) as 'Precio',
cast(pro.id as varchar) + '-' + pro.nombre [Proveedor],
p.estado as 'Estado',
um.id [Id Unidad],
p.Id
from mst_producto p
inner join mst_ProductoDetalle pd on p.id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id = pp.idProductosDetalle
inner join mst_Marca m on p.idMarca = m.Id
--inner join mst_Grupo g on p.idGrupo = g.Id
--inner join mst_Linea l on p.idLinea = l.Id
--inner join mst_Familia f on p.idFamilia = f.Id
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_proveedor pro on p.idproveedor = pro.id
where p.id = pd.IdProducto 
and pd.Id = pp.IdProductosDetalle
and p.flag = 1 and pd.flag = 1 and pp.flag = 1 and pp.Principal  =1
order by pp.Id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarProducto_Clase]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarProducto_Clase]
@id char(6),
@bit bit
as
if(@bit = 0)
select codigo,cod_segfamclas+codigo+' - ' + Descripcion [descripcion] from mst_ProductoSunat
where cod_segfamclas = @id and flag = 1
else
declare @idaux char(2) = (select top 1 codclase from mst_ProductoSunat where Codigo = @id)
select codigo,descripcion [descripcion] from mst_Familia
where codigo = @idaux and flag = 1



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarProductosTodos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarProductosTodos]
@buscar varchar(100)
as
select
'0'[Aux],
0 as 'Id',
pd.Id IdProducto,
pd.codigoBarra [Cod/Barra],
p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
LTRIM(mmm.descripcion) + ' ' +
LTRIM(mm.nombreMarca) + ' ' + 
LTRIM(t.descripcion)+' '+ 
LTRIM(c.descripcion) as 'Descripcion',
LTRIM(um.nombreUnidad) 'U. Medida',
um.factor [Factor],
um.id Id_Unidad,
'0' as 'Cantidad',
pd.codigoBarra 'Cod_Barra',
0.000 as Costo,
0.000 as Total,
'' AS 'Zona',
'' as 'Stand'
from mst_Producto p 
inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
inner join mst_Marca mm on p.idMarca = mm.Id
--inner join mst_Segmento g on p.IdSegmento = g.Codigo
--inner join mst_Familia l on p.IdFamilia = l.Codigo
--inner join mst_Clase f on p.IdClase = f.Codigo
inner join mst_Talla t on pd.idTalla = t.Id
inner join mst_Color c on pd.idColores = c.Id
inner join mst_UnidadMedida um on pp.idUnidad = um.Id
inner join mst_Medidas mmm on pd.idmedida = mmm.id
inner join mst_Proveedor pro on p.idproveedor = pro.id
--inner join mst_productosunat ps on p.idproductosunat = ps.Cod_SegFamClas + ps.Codigo
where 
P.IdTipoProducto = 1 AND
p.flag = 1 and 
p.estado = 1 and 
--pd.estado = 1 and 
pd.flag = 1 and 
pp.estado = 1 and 
pp.flag = 1 and 
pp.Principal = 1 
and
(p.nombreProducto + ' ' + 
pd.descripcion + ' ' + 
mmm.descripcion + ' ' +
mm.nombreMarca + ' ' + 
--g.nombreGrupo +' '+
--l.nombreLinea+' '+
--f.nombreFamilia+' ' +
t.descripcion+' '+ 
c.descripcion + ' ' + 
pd.codigoBarra + ' ' +
iif(cast(fechavencimiento as  varchar) is null,'Sin definir',cast(fechavencimiento as varchar))) collate Latin1_general_CI_AI like '%'+@buscar+'%' 
order by pd.Id DESC
GO
/****** Object:  StoredProcedure [dbo].[spMostrarProformaDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarProformaDetalle]
@id int
as
select
cast(IdProducto as varchar)IdProducto
,CodigoBarra,
Descripcion,
UMedida,
Factor,
Cantidad,
Precio,
Descuento,
Subtotal,
cast(IdUnidad as varchar) + '-' + cast(Id as varchar)IdUnidaD_IdDetalle,
igv,
total,
Adicional1 adicional1,
getdate() adicional2,
'' adicional3,
'' adicional4,
CAST('0' AS bit) igv_incluido,
CAST('0' AS bit) IsCodBarraBusqueda
from tabla_Proforma_Detalle
where Pagado = 0 and Eliminado = 0 and IdProforma = @id
GO
/****** Object:  StoredProcedure [dbo].[spMostrarProformaNew]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarProformaNew]
@id int
as
if(@id = 0)
begin
select 
c.Id N,
C.fecha,
d.Descripcion Doc,
c.RazonSocial,
c.Direccion,
u.nombre Atendio,
c.sub_total as 'Sub_Total',
0.00 as 'ICBPER',
c.igv as 'Igv',
c.Total,
BolFac,
cl.nacionalidad,
isnull(c.Idalmacen,1) as 'IdAlmacen',
c.Id
from tabla_Proforma c 
inner join mst_Usuarios u on c.IdUsuario = u.Id
inner join mst_documentos d on c.BolFac = d.Codigo
left join mst_Cliente cl on c.IdCliente = cl.id
where c.Pagado = 0 and c.Eliminado = 0 
and BolFac  != '07' and BolFac != '08'
order by c.Id desc
end
else
begin
select 
c.Id,
c.IdCliente,
c.CodigoDoc,
c.dniruc,
c.RazonSocial,
c.Direccion,
c.Email,
c.BolFac,
c.IdUsuario,
u.usuario,
0 as 'IdPiso',
'' as Adicional,
'' as Beneficiario,
0 as IdConvenio,
'' as 'Razon',
0 as 'IdParentesco',
cl.nacionalidad,
isnull(c.Idalmacen,1) as 'IdAlmacen',
c.Id
from tabla_Proforma c 
inner join mst_Usuarios u on c.IdUsuario = u.Id
inner join mst_documentos d on c.BolFac = d.Codigo
left join mst_Cliente cl on c.IdCliente = cl.id
where c.Id = @id and c.Pagado = 0 and c.Eliminado = 0 
and BolFac  != '07' and BolFac != '08'
order by c.Id desc
end
GO
/****** Object:  StoredProcedure [dbo].[spMostrarProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------
CREATE proc [dbo].[spMostrarProveedor]
@top bit
as
if(@top =0)
select TOP 200
 id [Id],
nombre Nombre,
ruc Ruc,
direccion Direccion,
telefono Telefono,
email Email,
usuariocrea [Usuario Crea.],
fechacrea [Fecha Crea],
usuariomodifica [Usuario Modifica],
fechamodifica [fecha Modifica],
estado Estado
from mst_Proveedor
where flag= 1
order by id desc

else
select
 id [Id],
nombre Nombre,
ruc Ruc,
direccion Direccion,
telefono Telefono,
email Email,
usuariocrea [Usuario Crea.],
fechacrea [Fecha Crea],
usuariomodifica [Usuario Modifica],
fechamodifica [fecha Modifica],
estado Estado
from mst_Proveedor
where flag= 1
order by id desc






















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarPulsos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarPulsos]
@idpiso int
as
select * from tabla_pulsos where IdPiso = @idpiso



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarRestPisos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarRestPisos]
as
select
id,
numpiso Piso,
cantmesas Cant_Mesas,
numInicio Inicio
from tabla_RestPisos
where Estado = 1


GO
/****** Object:  StoredProcedure [dbo].[spMostrarResumen]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spMostrarResumen '09','2019','RA'
CREATE proc [dbo].[spMostrarResumen]
@fecha char(2),
@anio char(4),
@tipoproceso char(2)
as
declare @tpaux char(2) = 'RC'
if(@tipoproceso = 'RA')
	begin
	SET @tipoproceso = 'RC'
	SET @tpaux = 'RA'
end

if(@fecha = '')
begin
select * from Tbl_Resumen
where (tipoproceso = @tipoproceso AND TipoProcesoAux = @tpaux) and (tipoproceso = @tpaux and TipoProcesoAux = @tpaux)
end
else
begin
select * 
from Tbl_Resumen
where MOnth(Fecha_Documento) = @fecha
and YEAR(Fecha_Documento) = @anio and (tipoproceso = @tipoproceso AND TipoProcesoAux = @tpaux) 
and (tipoproceso = @tpaux and TipoProcesoAux = @tpaux)
order by Fecha_Referencia desc
end



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarResumen_Det]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------
CREATE proc [dbo].[spMostrarResumen_Det]
@fecha date,
@doc char(2),
@bit bit,
@tipoproceso char(2)
as
declare @enviado_ bit, @doc_ char(2), @otro bit

if(@tipoproceso = 'RC')
	begin
		set @enviado_ = 0
		set @doc_ = '03'
		set @otro = 0
	end
else
	begin
		set @enviado_ = 1
		set @doc_ = @doc
		set @otro = 1
end

if(@bit = 0)
begin
	if(@otro = 0)
		begin
			select
			ID,
			FECHA 'F_EMISION',
			TIPO_COMPROBANTE 'TIPO_CPE',
			Num_Comprobante 'NRO_CPE',
			Tipo_Comprobante_Ref 'D_AF',
			Num_Comprobante_Ref 'NRO_AFEC',
			TIPO_DOC 'TD_CLI',
			NUMERO_DOC 'RUC_DNI',
			CLIENTE 'CLIENTE',
			Total 'TOTAL',
			descripcion 'DESCRIPCION'
			from Tbl_Resumen_Det
			where Fecha = @fecha and Enviado = @enviado_ and Tipo_Comprobante = @doc_
		end
	else
		begin
			select
			id_cab_cpe 'ID',
			fecha_emi_doc_cpe 'F_EMISION',
			codigo 'TIPO_CPE',
			serie_nro_doc_cpe 'NRO_CPE',
			tipo_doc_afecta 'D_AF',
			nro_doc_afecta 'NRO_AFEC',
			tipo_doc_cli 'TD_CLI',
			ruc_dni_cliente 'RUC_DNI',
			nombre_cliente 'CLIENTE',
			total_cpe 'TOTAL',
			'' 'DESCRIPCION'
			from vw_tbl_cab_cpe 
			where fecha_emi_doc_cpe = @fecha and doc_firma = 1 and doc_cdr = 1 and codigo = @doc_
		end
		
end
else
begin
	if(@otro = 0)
		begin
			select
			LTRIM(RTRIM(TIPO_COMPROBANTE)) 'TIPO_COMPROBANTE',
			LTRIM(RTRIM(Num_Comprobante)) 'NRO_COMPROBANTE',
			LTRIM(RTRIM(Tipo_Comprobante_Ref)) 'TIPO_COMPROBANTE_REF',
			LTRIM(RTRIM(Num_Comprobante_Ref)) 'NRO_COMPROBANTE_REF',
			LTRIM(RTRIM(TIPO_DOC)) 'TIPO_DOCUMENTO',
			LTRIM(RTRIM(NUMERO_DOC)) 'NRO_DOCUMENTO',
			LTRIM(RTRIM(CLIENTE)) 'CLIENTE',
			format(Total,'N','es-pe') 'TOTAL',
			format(Gravada,'N','es-pe') 'GRAVADA',
			format(Isc,'N','es-pe') 'ISC',
			format(IGV,'N','es-pe')	'IGV',
			format(OTROS,'N','es-pe') 'OTROS',
			CARGO_X_ASIGNACION 'CARGO_X_ASIGNACION',
			format(Monto_Cargo_X_Asignacion,'N','es-pe') 'MONTO_CARGO_X_ASIG',
			format(Exonerado,'N','es-pe')	'EXONERADO',
			format(Inafecto,'N','es-pe') 'INAFECTO',
			format(Exportacion,'N','es-pe') 'EXPORTACION',
			format(GRATUITAS,'N','es-pe') 'GRATUITAS',
			Id as 'ID',
			DESCRIPCION AS 'DESCRIPCION',
			format(Otro_Imp,'N','es-pe') as 'OTROS_IMPUESTOS'
			from Tbl_Resumen_Det
			where Fecha = @fecha and Enviado = @enviado_ and Tipo_Comprobante = @doc_
		end
	else
		begin
			select
			LTRIM(RTRIM(codigo)) 'TIPO_COMPROBANTE',
			LTRIM(RTRIM(serie_nro_doc_cpe)) 'NRO_COMPROBANTE',
			LTRIM(RTRIM(tipo_doc_afecta)) 'TIPO_COMPROBANTE_REF',
			LTRIM(RTRIM(nro_doc_afecta)) 'NRO_COMPROBANTE_REF',
			LTRIM(RTRIM(tipo_doc_cli)) 'TIPO_DOCUMENTO',
			LTRIM(RTRIM(ruc_dni_cliente)) 'NRO_DOCUMENTO',
			LTRIM(RTRIM(nombre_cliente)) 'CLIENTE',
			format(total_cpe,'N','es-pe') 'TOTAL',
			format(ope_gravada,'N','es-pe') 'GRAVADA',
			format(Isc,'N','es-pe') 'ISC',
			format(IGV,'N','es-pe')	'IGV',
			format(0,'N','es-pe') 'OTROS',
			0 'CARGO_X_ASIGNACION',
			format(0,'N','es-pe') 'MONTO_CARGO_X_ASIG',
			format(0,'N','es-pe')	'EXONERADO',
			format(0,'N','es-pe') 'INAFECTO',
			format(0,'N','es-pe') 'EXPORTACION',
			format(0,'N','es-pe') 'GRATUITAS',
			id_cab_cpe as 'ID',
			'' AS 'DESCRIPCION',
			format(otros_impuestos,'N','es-pe') AS 'OTROS_IMPUESTOS'
			from vw_tbl_cab_cpe
			where fecha_emi_doc_cpe = @fecha and doc_firma = 1 and doc_cdr = 1 and codigo = @doc_
		end
end



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarSalidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarSalidas]
@buscar varchar(max)
as
select
m.id, fecha, referencia, serie, numero,doc_facturado, cerrado, direccion, idCliente, c.razonSocial, direccion
from mst_almacen_movimiento m
inner join mst_Cliente c on m.idCliente = c.Id
where  serie = 'S' 
AND ((serie + '-' + CAST(numero as varchar)) LIKE '%'+@buscar+'%')










GO
/****** Object:  StoredProcedure [dbo].[spMostrarSalidasDetalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spMostrarSalidasDetalles]
@id int
as
select * from mst_almacen_movimiento_detalle where almacen_movimiento_id = @id










GO
/****** Object:  StoredProcedure [dbo].[spMostrarSeriesDoc]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarSeriesDoc]
@iddoc char(2)
as
Select s.Serie,s.Id [Id Serie],ds.Id [Id Serie Doc] from mst_doc_serie ds
inner join mst_Serie s on ds.idserie = s.Id
where ds.IdDoc = @iddoc and ds.Estado = 1 and ds.Flag = 1 and s.Estado = 1 and s.Flag = 1
order by ds.id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarSeriesDocTodos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarSeriesDocTodos]
as
Select s.Serie,ds.Id [Id Serie Doc] from mst_doc_serie ds
inner join mst_Serie s on ds.idserie = s.Id
where ds.Estado = 1 and ds.Flag = 1
order by ds.id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarSeriesTodos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarSeriesTodos]
as
select s.Id,s.Serie from mst_Serie s
where s.Estado = 1 and s.Flag = 1
order by s.Serie asc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarSerieUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarSerieUsuario]
@idusuario int
as
select dsu.Id,s.Serie,s.Id IdSerie from mst_Doc_Serie_Usuario dsu
inner join mst_Doc_Serie ds on dsu.IdSerie = ds.Id
inner join mst_Serie s on ds.IdSerie = s.Id
where dsu.IdUsuario = @idusuario and 
dsu.Estado = 1 and 
dsu.Flag = 1
order by s.Serie asc





















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarServidores]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarServidores]
as
select * from MST_SERVIDORES




















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarStock]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarStock]
@idproducto int,
@bit bit
as
if(@bit = 0)
begin
select a.Nombre,saldo, s.IdProducto, pd.checkStock from Stocks_Acumulados s
inner join mst_Almacen a on s.IdAlmacen = a.Id
inner join mst_ProductoDetalle pd on s.IdProducto = pd.Id
where s.IdProducto = @idproducto
end
else
begin
declare @id int = (select idProductosDetalle from mst_Productopresentacion where Id = @idproducto);
select a.Nombre,saldo, s.IdProducto, pd.checkStock from Stocks_Acumulados s
inner join mst_Almacen a on s.IdAlmacen = a.Id
inner join mst_ProductoDetalle pd on s.IdProducto = pd.Id
where s.IdProducto = @id
end



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarTalla]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--mostrar
CREATE proc [dbo].[spMostrarTalla]
@top bit
as
if(@top = 0)
select TOP 200
 id as 'ID', 
descripcion as 'Descripción', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificación',  
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from  mst_Talla
where flag = 1
order by id desc
else
select
 id as 'ID', 
descripcion as 'Descripción', 
usuarioCrea as 'Usuario de Creación',
fechaCrea as 'Fecha de Creación', 
usuarioModifica as 'Usuario de Modificación',  
fechaModifica as 'Fecha de Modificación',
estado as 'Estado'
from  mst_Talla
where flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarTiposDoc]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spMostrarTiposDoc]
AS
SELECT codigoSunat,descripcion FROM mst_TipoDocumento 
WHERE estado = 1 AND flag = 1























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarTipoUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarTipoUsuario]
as
select id Id,descripcion Descripcion,usuarioCrea [Usuario Crea],fechaCrea [Fecha Crea],usuarioModifica[Usuario Modifica],fechaModifica [Fecha Modifica],estado Estado from mst_TipoUsuario
where flag = 1
order by id desc























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarTransportita]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------
CREATE proc [dbo].[spMostrarTransportita]
as
select
t.id,
nombre,
td.descripcion [DniRuc],
t.DniRuc [Numero],
t.Licencia,
t.Direccion,
t.Telefono,
t.Email,
t.UsuarioCrea,
t.FechaCrea,
t.UsuarioModifica,
t.FechaModifica,
t.CodidoTipoDoc
from mst_Transportistas t
inner join mst_TipoDocumento td on t.CodidoTipoDoc = td.codigoSunat
where t.Flag = 1



















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarUnidad]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------

------------------mostrar unidad-------------
CREATE procedure [dbo].[spMostrarUnidad]
@top bit
as
if(@top = 0)
select top 100 
id as 'ID', 
nombreUnidad as 'Nombre Unidad',
factor as 'Factor' ,
usuarioCrea as 'Usuario Creador', 
fechaCrea as 'Fecha de Registro', 
usuarioModifica as 'Usuario Modifica', 
fechaModifica as 'Fecha de Modificación' , 
estado as 'Estado'
from  mst_UnidadMedida
where flag = 1
order by id desc

else
select 
id as 'ID', 
nombreUnidad as 'Nombre Unidad',
factor as 'Factor' ,
usuarioCrea as 'Usuario Creador', 
fechaCrea as 'Fecha de Registro', 
usuarioModifica as 'Usuario Modifica', 
fechaModifica as 'Fecha de Modificación' , 
estado as 'Estado'
from  mst_UnidadMedida
where flag = 1
order by id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarUsuarioItems]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarUsuarioItems]
@idusuario int,
@opcion int,
@hay bit
as
if(@hay != 0)
begin
if(@opcion= 0)
begin
select cast(mm.id as varchar),nombre,text,Estado,mm.Icono Icono from tabla_Usuarios_Menu m
inner join tabla_Menus mm on m.idmenu = mm.id
where idusuario = @idusuario and m.idmenu = mm.id
end
else if(@opcion = 1)
begin
select cast(sm.idmenu as varchar) + '.'+cast(sm.id as varchar),nombre,text,Estado,sm.icon from tabla_Usuario_SubMenu m
inner join tabla_SubMenus sm on m.idsubmenu = sm.id
where idusuario = @idusuario and sm.idmenu = m.idmenu
end
end
else
begin
if(@opcion= 0)
begin
select * from tabla_Menus
end
else if(@opcion = 1)
begin
select cast(idmenu as varchar) + '.'+cast(id as varchar),text from tabla_SubMenus
end
end























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarVenta_Cpe]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarVenta_Cpe]
@id int
as
declare @rucemisor varchar(11) = (select ruc from tabla_configuracion_general);
declare @razonemisor varchar(100) = (select RazonSocial from tabla_configuracion_general);
declare @direccion varchar(100)=(select direccion from tabla_configuracion_general)
declare @ubigeo varchar(100) = (select ubigeo from tabla_configuracion_general)
declare @ciudad varchar(100) = (select ciudad from tabla_configuracion_general)
declare @distrito varchar(100) = (select distrito from tabla_configuracion_general)
declare @nombrecom varchar(100) = (select nombrecomercial from tabla_configuracion_general)
declare @usuariosol varchar(200) = (select UsuarioSecundarioSol from tabla_configuracion_general)
declare @contrassol varchar(200) = (select ContraseniaUsuarioSecundarioSol from tabla_configuracion_general)
declare @contrafirma varchar(200) = (select ContraseniaCertificadoCpe from tabla_configuracion_general)
select  
'PEN' 'TIPO_MONEDA',
'0.00',
'0.00',
'0.00',
format(TotalVenta,'N','es-pe') as 'TOTAL_VENTA',
'20' 'TIPO_IGV',
'0.00' 'PORC_IGV',
Total_Letras 'TOTAL_LETRAS',
CAST(cast(FechaEmision as date) as varchar(10)) as 'FECHA_EMISION',
@rucemisor 'RUC_EMISOR',
@razonemisor 'RAZON_EMPRESA',
'' 'GUIA_REMISION',
@rucemisor 'RUC_EMISOR',
@razonemisor 'RAZON_EMISOR',
@ubigeo 'UBIGEO',
@direccion 'DIRECCION',
@ciudad 'CIUDAD',
@distrito 'DISTRITO',
DniRuc 'DNI_RUC',
CodigoTipoDoc 'CODIGO_TIPO_DOC',
RazonSocial 'RAZON_SOCIAL',
Direccion 'DIRECCION_CLIENTE',
'PE' 'TIPO_MONEDA2',
format(Igv,'N','es-pe') 'IGV2',
format(Descuento,'N','es-pe') 'DESCUENTO',
format(SubTotal,'N','es-pe') 'SUB_TOTAL',
format(TotalVenta,'N','es-pe') 'TOTAL',
SerieDoc + '-' + cast(NumeroDoc as varchar) 'SERIE_NUMERO',
NumeroDocAfectado 'DOC_AFECTA',
TipoNotCred 'TIPO_NOT_CRED',
DescripNotCred 'DESCRIP_NOT_CRED',
TipoDocAfectado 'TIPO_DOC_AFECTADO',
IdDocumento 'ID_DOCUMENTO',
@nombrecom 'NOMBRE_COMERCIAL',
@usuariosol 'USUARIO_SOL',
@contrassol 'CONTRA_SOL',
@contrafirma 'CONTRA_FIRMA'
from mst_Venta
where id = @id and Anulado = 0


--EXEC SPMOSTRARCPE '','','',1


















































GO
/****** Object:  StoredProcedure [dbo].[spMostrarVentaDetalle_Cpe]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarVentaDetalle_Cpe]
@id int
as
select
ROW_NUMBER() OVER(ORDER BY vt.ID DESC) AS Row,
format(Cantidad,'N','es-pe') as 'CANTIDAD',
format(Subtotal,'N','es-pe') as 'SUBTOTAL',
format(Total,'N','es-pe') as 'TOTAL',
format(Igv, 'N','es-pe') as 'IGV',
vt.descripcion 'DESCRIPCION',
vt.IdProducto 'ID_PRODUCTO',
format(PrecioUnit,'N','es-pe') as 'PRECIO_UNIT',
p.IdProductoSunat 'ID_PRODUCTO_SUNAT'
from mst_Venta_det vt
inner join mst_ProductoPresentacion pp on vt.idproducto = pp.Id
inner join mst_ProductoDetalle pd on pp.idProductosDetalle = pd.Id
inner join mst_Producto p on pd.idProducto = p.Id
where IdVenta = @id























































GO
/****** Object:  StoredProcedure [dbo].[spMostrarVentas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMostrarVentas]
@id int
as
if(@id = 0)
select
TOP 200
 v.Id,
case v.IdDocumento
when '03' then 'BOLETA'
when '01' then 'FACTURA'
when '07' then 'NOTA DE CREDITO'
when '08' then 'NOTA DE DÉBITO'
END Documento,
v.SerieDoc Serie,
v.NumeroDoc [N°],
v.RazonSocial [Razon Social - Cliente],
v.TotalVenta,
v.FechaEmision [Fecha Emisión],
u.usuario [Atendido por],
v.Anulado Estado,
ISNULL(cpe.doc_firma, 0) Firma,
isnull(cpe.doc_cdr ,0)  Cdr,
v.IdGuia Guia
from mst_Venta v
inner join mst_documentos d on v.IdDocumento = d.Codigo
inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe
order by Id desc

else

select
 v.Id,
case v.IdDocumento
when '03' then 'BOLETA'
when '01' then 'FACTURA'
when '07' then 'NOTA DE CREDITO'
when '08' then 'NOTA DE DÉBITO'
END Documento,
v.SerieDoc Serie,
v.NumeroDoc [N°],
v.RazonSocial [Razon Social - Cliente],
v.TotalVenta,
v.FechaEmision [Fecha Emisión],
u.usuario [Atendido por],
v.Anulado Estado,
ISNULL(cpe.doc_firma, 0) Firma,
isnull(cpe.doc_cdr ,0)  Cdr,
v.IdCliente,
v.Direccion
from mst_Venta v
inner join mst_documentos d on v.IdDocumento = d.Codigo
inner join mst_Usuarios u on v.IdUsuarioPreventa = u.Id
left join tbl_info_cpe cpe on v.Id = cpe.id_cab_cpe
where v.id = @id
order by Id desc
























































GO
/****** Object:  StoredProcedure [dbo].[spMostraUsuario]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---
CREATE proc [dbo].[spMostraUsuario]
@top bit
as
if(@top = 0)
select TOP 200
 u.Id Id,tu.descripcion [Tipo de Usuario],u.nombre Nombre,u.dni Dni,u.direccion Direccion,u.telefono Telefono,
 u.correo Correo,u.usuario Usuario,u.pass Pass,u.usuarioCrea [Usuario Crea],u.fechaCrea [Fecha Crea],u.usuarioModifica [Usuario Modifica],
 u.fechaModifica [Fecha Modifica],u.Foto ,u.estado Estado, tu.Id IDtipoUsuario, is_cobrador,verVentas, u.DocVentaDefecto from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where u.flag = 1 and tu.flag = 1
order by u.id desc
else
select
 u.Id Id,tu.descripcion [Tipo de Usuario],u.nombre Nombre,u.dni Dni,u.direccion Direccion,u.telefono Telefono,u.correo Correo,
 u.usuario Usuario,u.pass Pass,u.usuarioCrea [Usuario Crea],u.fechaCrea [Fecha Crea],u.usuarioModifica [Usuario Modifica],u.fechaModifica [Fecha Modifica],
 u.Foto ,u.estado Estado, tu.Id IDtipoUsuario,is_cobrador, verVentas, u.DocVentaDefecto from mst_Usuarios u
inner join mst_TipoUsuario tu on u.idtipoUsuario = tu.Id
where u.flag = 1 and tu.flag = 1
order by u.id desc
GO
/****** Object:  StoredProcedure [dbo].[spMotivos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spMotivos]
@id char(2)
as
select
Codigo id,
Descripcion descripcion
from mst_motivo_nc
where iddoc = @id



















































GO
/****** Object:  StoredProcedure [dbo].[spPagarPreVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPagarPreVenta]
@id int,
@mesaoid bit,
@idpiso int
as
if(@mesaoid = 0)
	begin
		update tabla_Pre_Venta set Pagado = 1 where IdPedido = @id
		update tabla_Pre_Venta_Detalle set Pagado = 1 where IdPedido = @id
		
	end
else
	begin
	update tabla_Pre_Venta set Pagado = 1 where IdMesa = @id and IdPiso = @idpiso and Pagado = 0
		update tabla_Pre_Venta_Detalle set Pagado = 1 where IdMesa = @id and IdPiso = @idpiso and pagado = 0 
		end 























































GO
/****** Object:  StoredProcedure [dbo].[spPedirProforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPedirProforma]
@id int
as
declare @idpedido int = (select (isnull(max(IdPedido),0)+1) as Cant from tabla_Pre_Venta)
insert into tabla_Pre_Venta(IdPedido,CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,pagado,Eliminado,IdUsuario,BolFac,sub_total,igv,Descuento,Total,Idalmacen)
select @idpedido,temp.CodigoDoc,temp.idcliente,temp.dniruc,temp.RazonSocial,temp.direccion,temp.email,temp.pagado,temp.eliminado,temp.idusuario,temp.bolfac,temp.sub_total,temp.igv,temp.descuento,temp.total,temp.idalmacen
from
(
	select CodigoDoc, IdCliente,DniRuc,RazonSocial,Direccion,Email,0 as Pagado,0 as Eliminado,IdUsuario,'03' as bolfac,sub_total,igv,Descuento,Total,Idalmacen
	from tabla_Proforma
	where Id = @id and Pagado = 0 and Eliminado = 0
) as temp
---
insert into tabla_Pre_Venta_Detalle(IdPedido,IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,igv,Descuento,total,Pagado,Eliminado,Factor,IdUnidad,Adicional1)
select @idpedido,temp.idproducto,temp.descripcion,temp.codigobarra,temp.umedida,temp.cantidad,temp.precio,temp.subtotal,temp.igv,temp.descuento,temp.total,temp.pagado,temp.eliminado,temp.factor,temp.idunidad,temp.Adicional1
from
(
	select IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,igv,Descuento,total,0 AS Pagado,0 as eliminado,Factor,IdUnidad,Adicional1
	from tabla_Proforma_Detalle
	where idproforma = @id and Pagado = 0 and Eliminado = 0
) as temp








 











































GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Contacto_Insertar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Contacto_Insertar]
@idmesa int,
@idpedido int,
@codigodoc char(2),
@idcliente int,
@dniruc varchar(50),
@razonsocial varchar(200),
@direccion varchar(200),
@email varchar(200),
@idusuario int,
@bolfac char(2),
@idalmacen int,
@idpiso int,
@adicional varchar(250),
@beneficiario varchar(250),
@idconvenio int,
@esconvenio bit,
@idparentesco int
as 
declare @id_antes int = 0, @id_despues int;

IF(@esconvenio = 0)
begin
set @id_antes = ISNULL((select MAX(id) from tabla_Pre_Venta),0)
end
else
begin
set @id_antes = ISNULL((select MAX(id) from tabla_Pre_Venta_Convenio),0)
end


declare @id_pedido_despues int = 0


if(@id_antes > 0)
	begin
		if @esconvenio = 0
			begin
			set @id_pedido_despues = (select idpedido from tabla_Pre_Venta where Id = @id_antes)
			end
		else
			begin
			set @id_pedido_despues = (select idpedido from tabla_Pre_Venta_Convenio where Id = @id_antes)
			end
	end


if(@esconvenio = 0)
	begin
		declare @secuencia int
		if (@idmesa>=500 and @idmesa < 1000)set @secuencia = dbo.F_SecuenciaLlevar()
		else set @secuencia = dbo.F_SecuenciaDelivery()
		if(@idmesa < 500) set @secuencia = 0
		else
		begin
		if(@secuencia = 0)
		begin set @secuencia = 1 end
		end
		insert into tabla_Pre_Venta(IdMesa, CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,Pagado,Eliminado,IdUsuario,bolfac,Idalmacen,idpiso,numSecuencia, Adicional, Beneficiario, IdConvenio, IdParentesco)
		values(@idmesa,@codigodoc,@idcliente,@dniruc,@razonsocial,@direccion,@email,0,0,@idusuario,@bolfac,@idalmacen,@idpiso,@secuencia, @adicional,@beneficiario, @idconvenio,@idparentesco)
	end
else
	begin	 	 
	insert into tabla_Pre_Venta_Convenio(IdMesa, CodigoDoc,IdCliente,DniRuc,RazonSocial,Direccion,Email,Pagado,Eliminado,IdUsuario,bolfac,Idalmacen,idpiso,numSecuencia, Adicional, Beneficiario, IdConvenio, IdParentesco)
	values(@idmesa,@codigodoc,@idcliente,@dniruc,@razonsocial,@direccion,@email,0,0,@idusuario,@bolfac,@idalmacen,@idpiso,@secuencia, @adicional,@beneficiario, @idconvenio, @idparentesco)
	end


set @id_despues = SCOPE_IDENTITY();

--select @id_antes as 'idpedido',  @id_despues as 'xxx'

if(@id_despues > @id_antes)
	begin						 
		if @esconvenio = 0
			begin
			SET @id_pedido_despues = @id_pedido_despues + 1
			update tabla_Pre_Venta set IdPedido = @id_pedido_despues where Id = @id_despues
			select @id_pedido_despues as 'id'
			end
		else
		begin		 
		SET @id_pedido_despues = @id_pedido_despues + 1
		update tabla_Pre_Venta_Convenio set IdPedido = @id_pedido_despues where Id = @id_despues
		select @id_despues as 'id'
		end
	end
else
	begin
		select 0 as 'id';
	end




































GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Detalle_Insertar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Detalle_Insertar]
@idmesa int,
@idcontacto int,
@idproducto int,
@descripcion  varchar(200),
@codigobarra varchar(50),
@umedida varchar(50),
@cantidad money,
@precio money,
@subtotal money,
@descuento money,
@factor decimal,
@idunidad int,
@igv money,
@total money,
@idpiso int,
@adicional1 text,
@adicional2 date,
@adicional3 varchar(200),
@adicional4 varchar(200),
@igv_incluido bit,
@esconvenio bit,
@isCodBarraBusqueda bit = 1
as
declare @subtotalBD money
declare @totalBD money
declare @secuencia int

if @esconvenio = 0
	begin		
		set @subtotalBD = (@cantidad * @precio)
		set @totalBD = ROUND(((@cantidad * @precio)+@igv) - @descuento,2)
		set @secuencia = (select max(numsecuencia) from tabla_Pre_Venta)
		if(@idmesa < 500) set @secuencia = 0
		insert into tabla_Pre_Venta_Detalle(IdMesa,IdPedido,IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,Pagado,Eliminado,Descuento,factor,idunidad,igv,total,IdPiso,NumSecuencia,adicional1,adicional2,adicional3,Adicional4,igv_incluido, IsCodBarraBusqueda)
		values(@idmesa,@idcontacto,@idproducto,@descripcion,@codigobarra,@umedida,@cantidad,@precio,@subtotalBD,0,0,@descuento,@factor,@idunidad,@igv,@totalBD,@idpiso,@secuencia,@adicional1,@adicional2,@adicional3,@adicional4,@igv_incluido, @isCodBarraBusqueda)
		declare @idaux int = @idmesa, @bit bit = 1
		if(@idmesa = 0) begin
		set @idaux = @idcontacto 
		set @bit = 0
		end

		exec spIngresarOtrosImpuestos_Preventa @idaux, @bit, 0
	end
else
	begin
		set @subtotalBD = (@cantidad * @precio)
		set @totalBD = ROUND(((@cantidad * @precio)+@igv) - @descuento,2)
		set @secuencia = 0
		if(@idmesa < 500) set @secuencia = 0
		insert into tabla_Pre_Venta_Detalle_Convenio(IdMesa,IdPedido,IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,Pagado,Eliminado,Descuento,factor,idunidad,igv,total,IdPiso,NumSecuencia,adicional1,adicional2,adicional3,Adicional4,igv_incluido)
		values(@idmesa,@idcontacto,@idproducto,@descripcion,@codigobarra,@umedida,@cantidad,@precio,@subtotalBD,0,0,@descuento,@factor,@idunidad,@igv,@totalBD,@idpiso,@secuencia,@adicional1,@adicional2,@adicional3,@adicional4,@igv_incluido)

		exec spIngresarOtrosImpuestos_Preventa @idaux, @bit, 1
	end
GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Detalle_Insertar_Temp]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--alter TABLE [dbo].[tabla_Pre_Venta_Detalle_Temp](
--	[Id] [int] IDENTITY(1,1) NOT NULL,
--	[IdPedido] [int] NULL,
--	[IdMesa] [int] NULL,
--	[IdProducto] [int] NULL,
--	[Descripcion] [varchar](200) NULL,
--	[CodigoBarra] [varchar](50) NULL,
--	[UMedida] [varchar](50) NULL,
--	[Cantidad] [money] NULL,
--	[Precio] [money] NULL,
--	[Subtotal] [money] NULL,
--	[igv] [money] NULL,
--	[Descuento] [money] NULL,
--	[total] [money] NULL,
--	[Pagado] [bit] NULL default 0,
--	[Eliminado] [bit] NULL default 0,
--	[Factor] [int] NULL,
--	[IdUnidad] [int] NULL,
--  [IdPiso] [int] NULL
--)
--go
-------
CREATE proc [dbo].[spPreVenta_Detalle_Insertar_Temp]
@idmesa int,
@idcontacto int,
@idproducto int,
@descripcion  varchar(200),
@codigobarra varchar(50),
@umedida varchar(50),
@cantidad money,
@precio money,
@subtotal money,
@descuento money,
@factor decimal,
@idunidad int,
@igv money,
@total money,
@idpiso int,
@idusuario int
as
declare @secuencia int = (select top 1 numsecuencia from tabla_Pre_Venta where IdMesa = @idmesa and IdPiso = @idpiso and Pagado = 0 and Eliminado = 0)
if(@idmesa < 500) set @secuencia = 0
insert into tabla_Pre_Venta_Detalle_Temp(IdMesa,IdPedido,IdProducto,Descripcion,CodigoBarra,UMedida,Cantidad,Precio,Subtotal,Pagado,Eliminado,Descuento,factor,idunidad,igv,total, IdPiso, idusuario,NumSecuencia)
values(@idmesa,@idcontacto,@idproducto,@descripcion,@codigobarra,@umedida,@cantidad,@precio,@subtotal,0,0,@descuento,@factor,@idunidad,@igv,@total,@idpiso,@idusuario,@secuencia)
GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Detalle_Modificar_Contacto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Detalle_Modificar_Contacto]
@id int,
@idproducto int,
@descripcion  varchar(200),
@codigobarra varchar(50),
@umedida varchar(50),
@cantidad money,
@precio money,
@subtotal money,
@descuento money,
@factor decimal,
@idunidad int,
@igv money,
@total money,
@idpiso int,
@adicional1 text,
@adicional2 date,
@adicional3 varchar(200),
@adicional4 varchar(200),
@igv_incluido bit,
@esconvenio bit,
@isCodBarraBusqueda bit = 1
as
declare @subtotalBD money = (@cantidad * @precio)
declare @totalBD MONEY = ((@CANTIDAD * @PRECIO) + @IGV) - @DESCUENTO
if(@esconvenio = 0)
	begin
		update tabla_Pre_Venta_Detalle set
		IdProducto = @idproducto,
		Descripcion = @descripcion,
		CodigoBarra = @codigobarra,
		UMedida = @umedida,
		Cantidad = @cantidad,
		Precio = @precio,
		Subtotal = @subtotalBD,
		Descuento = @descuento,
		Factor = @factor,
		idunidad = @idunidad,
		igv = @igv,
		total = @totalBD,
		adicional1 = @adicional1,
		adicional2 = @adicional2,
		adicional3 = @adicional3,
		Adicional4 = @adicional4,
		igv_incluido = @igv_incluido,
		IsCodBarraBusqueda = @isCodBarraBusqueda
		where Id = @id and IdPiso = @idpiso
	end
else
	begin
		update tabla_Pre_Venta_Detalle_Convenio set
		IdProducto = @idproducto,
		Descripcion = @descripcion,
		CodigoBarra = @codigobarra,
		UMedida = @umedida,
		Cantidad = @cantidad,
		Precio = @precio,
		Subtotal = @subtotalBD,
		Descuento = @descuento,
		Factor = @factor,
		idunidad = @idunidad,
		igv = @igv,
		total = @totalBD,
		adicional1 = @adicional1,
		adicional2 = @adicional2,
		adicional3 = @adicional3,
		Adicional4 = @adicional4,
		igv_incluido = @igv_incluido		 
		where Id = @id and IdPiso = @idpiso
	end
GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Detalle_Modificar_Mesa]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Detalle_Modificar_Mesa]
@idmesa int,
@idcontacto int,
@idproducto int,
@descripcion  varchar(200),
@codigobarra varchar(50),
@umedida varchar(50),
@cantidad money,
@precio money,
@subtotal money,
@descuento money,
@factor decimal,
@idunidad int
as
update tabla_Pre_Venta_Detalle set
IdProducto = @idproducto,
Descripcion = @descripcion,
CodigoBarra = @codigobarra,
UMedida = @umedida,
Cantidad = @cantidad,
Precio = @precio,
Subtotal = @subtotal,
Descuento = @descuento,
Factor = @factor,
idunidad = @idunidad
where IdMesa = @idmesa and IdProducto = @idproducto























































GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Mostrar_Normal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Mostrar_Normal]
@esconvenio bit,
@fechaini date,
@fechafin date,
@esconfecha bit,
@idconvenio int,
@opcion int
as
if (@esconfecha = 0)
	begin
		if(@esconvenio = 0)
			begin
				select TOP 200
				c.IdPedido N,
				c.Fecha,
				d.Descripcion Doc,
				c.RazonSocial,
				c.Direccion,
				u.nombre Atendio,
				c.sub_total as Sub_Total,
				c.Otro_Imp as 'ICBPER',
				c.igv as 'Igv',
				c.Total,
				BolFac,
				c.Id
				from tabla_Pre_Venta c 
				inner join mst_Usuarios u on c.IdUsuario = u.Id
				inner join mst_documentos d on c.BolFac = d.Codigo
				where c.Pagado = 0 
				and c.Eliminado = 0 
				and c.IdMesa = 0 
				and BolFac  != '07' and BolFac != '08'
				order by c.id desc
			end
		else
			begin
				select TOP 200
				c.IdPedido N,
				c.Fecha,
				d.Descripcion Doc,
				c.RazonSocial,
				c.Direccion,
				u.nombre Atendio,
				c.sub_total as Sub_Total,
				c.Otro_Imp as 'ICBPER',
				c.igv as 'Igv',
				c.Total,
				BolFac,
				Pagado as Estado,
				c.Id
				from tabla_Pre_Venta_Convenio c 
				inner join mst_Usuarios u on c.IdUsuario = u.Id
				inner join mst_documentos d on c.BolFac = d.Codigo
				where c.Pagado = 0 
				and c.Eliminado = 0 
				and c.IdMesa = 0 
				and BolFac  != '07' and BolFac != '08'
				order by c.id desc
			end

	end
else
	begin
		if(@esconvenio = 1)
			begin
				if(@opcion = 1)
					begin
						select 
						c.IdPedido N,
						c.Fecha,
						d.Descripcion Doc,
						c.RazonSocial,
						c.Direccion,
						u.nombre Atendio,
						c.sub_total as Sub_Total,
						c.Otro_Imp as 'ICBPER',
						c.igv as 'Igv',
						c.Total,
						BolFac,
						Pagado as Estado,
						c.Id
						from tabla_Pre_Venta_Convenio c 
						inner join mst_Usuarios u on c.IdUsuario = u.Id
						inner join mst_documentos d on c.BolFac = d.Codigo
						where c.Pagado = 0 
						and c.Eliminado = 0 
						and c.IdMesa = 0 
						and BolFac  != '07' and BolFac != '08' and cast(c.fecha as date) between @fechaini and @fechafin and c.idconvenio = @idconvenio 
						order by c.id desc		
					end
				else if (@opcion = 2)
					begin
						select
						c.IdPedido N,
						c.Fecha,
						d.Descripcion Doc,
						c.RazonSocial,
						c.Direccion,
						u.nombre Atendio,
						c.sub_total as Sub_Total,
						c.Otro_Imp as 'ICBPER',
						c.igv as 'Igv',
						c.Total,
						BolFac,
						Pagado as Estado,
						c.Id
						from tabla_Pre_Venta_Convenio c 
						inner join mst_Usuarios u on c.IdUsuario = u.Id
						inner join mst_documentos d on c.BolFac = d.Codigo
						where c.Pagado = 1 
						and c.Eliminado = 0 
						and c.IdMesa = 0 
						and BolFac  != '07' and BolFac != '08' and cast(c.fecha as date) between @fechaini and @fechafin and c.IdConvenio = @idconvenio 
						order by c.id desc		
					end
				else 
					begin
						select TOP 200
							c.IdPedido N,
							c.Fecha,
							d.Descripcion Doc,
							c.RazonSocial,
							c.Direccion,
							u.nombre Atendio,
							c.sub_total as Sub_Total,
							c.Otro_Imp as 'ICBPER',
							c.igv as 'Igv',
							c.Total,
							BolFac,
							Pagado as Estado,
							c.Id
							from tabla_Pre_Venta_Convenio c 
							inner join mst_Usuarios u on c.IdUsuario = u.Id
							inner join mst_documentos d on c.BolFac = d.Codigo
							where 
							c.Eliminado = 0 
							and c.IdMesa = 0 
							and BolFac  != '07' and BolFac != '08' and cast(c.fecha as date) between @fechaini and @fechafin and c.IdConvenio = @idconvenio 
							order by c.id desc		
					end
			end
			
	end
GO
/****** Object:  StoredProcedure [dbo].[spPreVenta_Mostrar_Normal_Detalles]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spPreVenta_Mostrar_Normal_Detalles]
@idpedido int, --1
@bit bit, --0
@idpiso int, --1
@esconvenio bit --1
as
if(@bit = 0)
	begin
		if(@esconvenio = 0)
			begin
				select cast(IdProducto as varchar)IdProducto
				,CodigoBarra,
				Descripcion,
				UMedida,
				Factor,
				Cantidad,
				Precio,
				Descuento,
				Subtotal,
				cast(IdUnidad as varchar) + '-' + cast(Id as varchar)IdUnidaD_IdDetalle,
				igv,
				total,
				adicional1,
				Adicional2,
				Adicional3,
				Adicional4,
				igv_incluido,
				IsCodBarraBusqueda
				from tabla_Pre_Venta_Detalle
				where IdPedido = @idpedido and Pagado=  0 and Eliminado = 0
			end
		else
			begin
				select cast(IdProducto as varchar)IdProducto
				,CodigoBarra,
				Descripcion,
				UMedida,
				Factor,
				Cantidad,
				Precio,
				Descuento,
				Subtotal,
				cast(IdUnidad as varchar) + '-' + cast(Id as varchar)IdUnidaD_IdDetalle,
				igv,
				total,
				adicional1,
				Adicional2,
				Adicional3,
				Adicional4,
				igv_incluido,
				0
				From tabla_Pre_Venta_Detalle_Convenio
				where IdPedido = @idpedido and Pagado =  0 and Eliminado = 0	
			end

	end
else if(@bit = 1)
	begin
		select cast(IdProducto as varchar)IdProducto
				,CodigoBarra,
				Descripcion,
				UMedida,
				Factor,
				Cantidad,
				Precio,
				Descuento,
				Subtotal,
				cast(IdUnidad as varchar) + '-' + cast(Id as varchar)IdUnidaD_IdDetalle,
				igv,
				total,
				IdPiso,
				adicional1,
				Adicional2,
				Adicional3,
				Adicional4,
				igv_incluido,
				IsCodBarraBusqueda
				from tabla_Pre_Venta_Detalle
				where IdMesa = @idpedido and IdPiso = @idpiso and Pagado=  0 and Eliminado = 0
	end
GO
/****** Object:  StoredProcedure [dbo].[spProcedimientoX]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spProcedimientoX]
@id int,
@idcaja int,
@total money,
@idpiso int,
@idmesa int,
@idapertura int
as
if(@id = 0)
begin
insert into tabla_Venta_Ext(IdCaja,Fecha,Total,IdPiso,IdMesa,IdApertura)
values(@idcaja,getdate(),@total,@idpiso,@idmesa, @idapertura)
end
else
begin
update tabla_Venta_Ext set Total = @total
where IdVenta = @id
end

















































GO
/****** Object:  StoredProcedure [dbo].[spProcedimientoX_Det]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spProcedimientoX_Det]
@id int,
@idventa int,
@idproducto int,
@descripcion varchar(200),
@precio money,
@cantidad money,
@total money
as
if(@id = 0)
begin
insert into tabla_Venta_Det_Ext (IdVenta,IdProducto,Descripcion,Precio,Cantidad,Total)
values(@idventa,@idproducto, @descripcion,@precio,@cantidad,@total)
end
else
begin
update tabla_Venta_Det_Ext set idproducto = @idproducto,
descripcion = @descripcion, precio = @precio, cantidad = @cantidad, total = @total
where IdVenta_Det = @id
end


















































GO
/****** Object:  StoredProcedure [dbo].[sppruebadoblereporte]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sppruebadoblereporte]
@id int,
@fechainicio date,
@fechafinal date
as
select * from mst_GastosOperativos
where CAST(Fecha as date) between @fechainicio and @fechafinal



















































GO
/****** Object:  StoredProcedure [dbo].[spReaperturarCaja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReaperturarCaja]
@idapertura int,
@idCaja int,
@idUsuario int
as
update mst_Apertura set Abierto_Cerrado = 0
where numero = @idapertura and IdCaja = @idCaja
and IdUsuario = @idUsuario
GO
/****** Object:  StoredProcedure [dbo].[SpRemoveAlmacenTrasladoDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpRemoveAlmacenTrasladoDetalle]
@id int
as
update mst_almacen_traslado_detalle set estado=0,Flag=0
where id = @id
select 1;
GO
/****** Object:  StoredProcedure [dbo].[spReporteClienteVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteClienteVenta]
@fechaInit date,
@fechaFin date
as
SELECT CAST(v.FechaEmision AS date) as FechaEmision,v.DniRuc,v.RazonSocial,SUM(d.Cantidad) AS Cantidad,u.nombreUnidad,d.descripcion,
us.usuario
FROM mst_Venta v
INNER JOIN mst_Venta_det d
ON v.Id = d.IdVenta
INNER JOIN mst_UnidadMedida u
ON u.Id = d.IdUnidad
inner join mst_Usuarios us on v.IdUsuarioPreventa = us.Id
WHERE v.Anulado = 0 AND CAST(v.FechaEmision AS date) BETWEEN @fechaInit AND @fechaFin
GROUP BY v.DniRuc,v.RazonSocial,CAST(v.FechaEmision AS date),u.nombreUnidad,d.descripcion, us.usuario
ORDER BY v.RazonSocial

GO
/****** Object:  StoredProcedure [dbo].[spReporteClienteVentaProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteClienteVentaProductos]
@fechaInit date,
@fechaFin date
as
SELECT v.DniRuc,v.RazonSocial,v.SerieDoc,v.NumeroDoc,CAST(v.FechaEmision AS date) as FechaEmision,v.SubTotal,v.Otro_Imp,v.TotalVenta,
d.Cantidad,u.nombreUnidad,d.descripcion,d.PrecioUnit,d.Total,
us.usuario
FROM mst_Venta v
INNER JOIN mst_Venta_det d
ON v.Id = d.IdVenta
INNER JOIN mst_UnidadMedida u
ON u.Id = d.IdUnidad
inner join mst_Usuarios us on v.IdUsuarioPreventa = us.Id
WHERE v.Anulado = 0 AND CAST(v.FechaEmision AS date) BETWEEN @fechaInit AND @fechaFin
ORDER BY v.RazonSocial, CAST(v.FechaEmision AS date)

GO
/****** Object:  StoredProcedure [dbo].[spReporteComprobante]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteComprobante]
@id int,
@bit bit
as
if(@bit = 0)
SELECT a.Id AS IdCabCpe,
CASE a.IdDocumento
WHEN '01' THEN 'FACTURA ELECTRÓNICA'
WHEN '03' THEN 'BOLETA DE VENTA ELECTRÓNICA'
WHEN '07' THEN 'NOTA DE CREDITO ELECTRÓNICA'
WHEN '08' THEN 'NOTA DE DEBITO ELECTRÓNICA'
WHEN '99' THEN 'NOTA DE VENTA'
END AS TipoDocumento, 

CASE l.codigoSunat
WHEN 6 THEN 'RAZON SOCIAL'
ELSE 'CLIENTE'
END AS TipoGlosa,
a.SerieDoc+'-'+ cast(a.NumeroDoc as varchar(15)) as SerieNum,
(CASE a.IdDocumento
WHEN '01' THEN 'FACTURA ELECTRÓNICA'
WHEN '03' THEN 'BOLETA DE VENTA ELECTRÓNICA'
WHEN '07' THEN 'NOTA DE CREDITO ELECTRÓNICA'
WHEN '08' THEN 'NOTA DE DEBITO ELECTRÓNICA'
WHEN '99' THEN 'NOTA DE VENTA'
END +': '+
a.SerieDoc+'-'+ cast(a.NumeroDoc as varchar(15))) as Documento, a.FechaEmision,a.SubTotal as SubTotalC, a.TotalVenta,a.Total_Letras, RTRIM((e.nombreProducto + ' ' + d.descripcion + ' '+ g.nombreMarca + ' ' + f.descripcion)) + ' ' + LTRIM(cast(b.Adicional1 as varchar(250))) AS NomPoducto, a.IdCliente, 

IIF(l.descripcion='OTROS','DOC',l.descripcion) AS descripcion, 
                         a.DniRuc, a.RazonSocial, a.Direccion, a.Email, a.Anulado AS Estatus, a.Observacion, a.TipoNotCred, a.DescripNotCred, a.TipoDocAfectado, a.NumeroDocAfectado, a.UsuarioCrea, a.FechaCrea, a.UsuarioModifica, 
                         a.FechaModifica, a.IdFormaPago, k.FormadePago, a.IdUsuarioPreventa, a.Descuento AS Descto, a.IdApertura, a.IdCaja, a.ImportePagado, b.Id AS IdVentaDet, 
						 b.IdProducto AS fkProducto, b.PrecioUnit, b.IdVenta, b.Flag AS FlagVentaDet, 
                         b.Anulado, b.Cantidad, b.Descuento, b.Subtotal,b.Total, h.nombreUnidad AS UnidDet, b.Factor, e.Id AS IdProductoPres, e.idMarca AS IdMarcaProductoPres, e.idsegmento, e.idfamilia, e.idclase, e.estado AS StatusVentaDet, e.flag AS FlagPresen, 
                         e.idproveedor, d.Id AS IdProductoDet, d.idProducto AS IdProductDetalles, d.idTalla, d.idColores, d.stockinicial, d.stockactual, d.stockminimo, 
						 '' fechavencimiento, 
						 d.codigoBarra, '' imagenProducto, d.estado AS StatusProdDet, 
                         d.flag AS FlagProdDet, d.idmedida AS MediProducDet, c.Id AS IdProducto, c.idProductosDetalle, c.idUnidad, c.precioUnitario, c.estado AS StatusPresent, c.flag AS FlagPresent, c.Principal, f.id AS IdMedida, f.descripcion, f.estado, 
                         f.flag, g.Id AS IdMarca, g.nombreMarca, g.estado AS StatusMarca, g.flag AS FlagMarca, a.hassh, i.usuario as Vendedor, j.Efectivo,j.Vuelto,
						 iif(a.IdMesa >= 500 and a.idmesa < 1000,'Para Llevar',iif(a.idmesa >= 1000 and a.idmesa < 2000, 'Delivery' , cast(a.idmesa as varchar))) as IdMesa,
						 a.idpiso,
						 iif(a.tipomoneda = 'PEN','PENS/','USD$') AS Simbolo,
						 '' as 'Grado',
						 a.Otro_Imp,						 
						 (a.TotalVenta + a.Otro_Imp) as 'Importe_Total',
						 b.Igv,
						 DBO.F_CalcularTotalExoneradas_Gravadas_Ventas(@id,0) total_exonerada,
						 DBO.F_CalcularTotalExoneradas_Gravadas_Ventas(@id,1) total_gravada,
						 j.Visa,
						 j.Mastercard,

						 v_d.estado,
						 v_d.flag,
						 a.countPecho,
						 a.countPierna,
						 a.textObservation,
						 cl.telefono,
						 cl.razonSocial as Contacto,
                         di.Direccion,
						 v_d.num_correlative,
						 a.delivery,
						 a.llevar,
						 IIF(a.delivery =1, 'D-'+cast(v_d.num_correlative as varchar), iif(a.llevar =1, 'LL-'+cast(v_d.num_correlative as varchar),'')) as 'correlativo2',
						 a.IdDocumento						  
FROM            dbo.mst_Venta AS a INNER JOIN
                         dbo.mst_Venta_det AS b ON a.Id = b.IdVenta INNER JOIN
                         dbo.mst_ProductoPresentacion AS c ON c.Id = b.IdProducto INNER JOIN
                         dbo.mst_ProductoDetalle AS d ON d.Id = c.idProductosDetalle INNER JOIN
                         dbo.mst_Producto AS e ON e.Id = d.idProducto INNER JOIN
                         dbo.mst_Medidas AS f ON f.id = d.idmedida INNER JOIN
                         dbo.mst_Marca AS g ON g.Id = e.idMarca INNER JOIN 
						 dbo.mst_UnidadMedida AS h ON h.Id = b.IdUnidad INNER JOIN 
						 dbo.mst_Usuarios AS i ON i.Id=a.IdUsuarioPreventa INNER JOIN
						 dbo.tabla_FormaPago AS j ON j.IdVenta=a.Id INNER JOIN
						 dbo.mst_FormaPago k ON k.Id = a.IdFormaPago INNER JOIN
						 dbo.mst_TipoDocumento l ON l.codigoSunat=a.CodigoTipoDoc LEFT JOIN
						 dbo.venta_delivery v_d ON v_d.id_venta = a.Id LEFT JOIN
						 dbo.mst_Cliente cl on v_d.id_contacto = cl.id LEFT JOIN
						 dbo.mst_Cliente_Direccion di ON cl.Id = di.IdCliente 						  
						 where b.Flag=1  and
						 a.Id = @id						  
else
------------------------------------------------------------------------------------------------------------

SELECT 
a.Id AS IdCabCpe,
CASE a.IdDocumento
WHEN '01' THEN 'FACTURA ELECTRÓNICA'
WHEN '03' THEN 'BOLETA DE VENTA ELECTRÓNICA'
WHEN '07' THEN 'NOTA DE CREDITO ELECTRÓNICA'
WHEN '08' THEN 'NOTA DE DEBITO ELECTRÓNICA'
WHEN '99' THEN 'NOTA DE VENTA'
END AS 
TipoDocumento, 
CASE l.codigoSunat
WHEN 6 THEN 'RAZON SOCIAL'
ELSE 'CLIENTE'
END AS 
TipoGlosa,
a.SerieDoc+'-'+ cast(a.NumeroDoc as varchar(15)) as SerieNum,
(CASE a.IdDocumento
WHEN '01' THEN 'FACTURA ELECTRÓNICA'
WHEN '03' THEN 'BOLETA DE VENTA ELECTRÓNICA'
WHEN '07' THEN 'NOTA DE CREDITO ELECTRÓNICA'
WHEN '08' THEN 'NOTA DE DEBITO ELECTRÓNICA'
WHEN '99' THEN 'NOTA DE VENTA'
END +': '+
a.SerieDoc+'-'+ cast(a.NumeroDoc as varchar(15))) as Documento, 
a.FechaEmision, 
a.SubTotal as SubTotalC,
a.TotalVenta,
a.Total_Letras, 
rtrim(B.descripcion) + ' ' + CAST(B.Adicional1 as varchar(250)) AS NomPoducto, 
a.IdCliente, 
IIF(l.descripcion='OTROS','DOC',l.descripcion) AS descripcion, 
a.DniRuc, 
a.RazonSocial, 
a.Direccion, 
a.Email, 
a.Anulado AS Estatus, 
a.Observacion, 
a.TipoNotCred, 
a.DescripNotCred, 
a.TipoDocAfectado, 
a.NumeroDocAfectado, 
a.UsuarioCrea, 
a.FechaCrea, 
a.UsuarioModifica, 
a.FechaModifica, 
a.IdFormaPago, 
--'Contado' FormadePago, 
CASE a.IdFormaPago
WHEN 1 THEN 'CONTADO'
WHEN 2 THEN 'CREDITO'
END AS FormadePago, 
a.IdUsuarioPreventa, 
a.Descuento AS Descto, 
a.IdApertura, 
a.IdCaja, 
a.ImportePagado, 
b.Id AS IdVentaDet, 
b.IdProducto AS fkProducto, 
b.PrecioUnit, 
b.IdVenta, 
b.Flag AS FlagVentaDet, 
b.Anulado, 
b.Cantidad, 
b.Descuento, 
b.Subtotal,
b.Total, 
'NIU' AS UnidDet, 
b.Factor, 
0 AS IdProductoPres, 
0 AS IdMarcaProductoPres, 
0 idsegmento, 
0 idfamilia, 
0 idclase, 
B.Flag AS StatusVentaDet, 
1 AS FlagPresen, 
0 idproveedor, 
b.IdProducto AS IdProductoDet, 
b.IdProducto AS IdProductDetalles, 
0 idTalla, 
0 idColores, 
0 stockinicial, 
0 stockactual, 
0 stockminimo, 
'' fechavencimiento, 
'' codigoBarra, 
'' imagenProducto, 
1 AS StatusProdDet, 
1 AS FlagProdDet, 
0 AS MediProducDet, 
b.IdProducto AS IdProducto, 
b.IdProducto as idProductosDetalle,
1 idUnidad, 
b.PrecioUnit precioUnitario, 
1 AS StatusPresent, 
1 AS FlagPresent, 
0 Principal, 
1 AS IdMedida, 
'' descripcion, 
1 estado, 
1 flag, 
1 AS IdMarca, 
'' nombreMarca, 
1 AS StatusMarca, 
1 AS FlagMarca, 
a.hassh, 
i.usuario as Vendedor, 
0 Efectivo,
0 Vuelto,
iif(a.IdMesa >= 500 and a.idmesa < 1000,'Para Llevar',iif(a.idmesa >= 1000 and a.idmesa < 2000, 'Delivery' , cast(a.idmesa as varchar))) as IdMesa,
a.idpiso,
iif(a.tipomoneda = 'PEN','PENS/','USD$') AS Simbolo,
'' as 'Grado',
a.Otro_Imp,
(a.TotalVenta + a.Otro_Imp) as 'Importe_Total',
b.Igv,
DBO.F_CalcularTotalExoneradas_Gravadas_Ventas(@id,0) total_exonerada,
DBO.F_CalcularTotalExoneradas_Gravadas_Ventas(@id,1) total_gravada,
0 Visa,
0 Mastercard,

v_d.estado,
v_d.flag,
a.countPecho,
a.countPierna,
a.textObservation,
cl.telefono,
cl.razonSocial as Contacto,
di.Direccion,
v_d.num_correlative,
a.delivery,
a.llevar,
IIF(a.delivery =1, 'D-'+cast(v_d.num_correlative as varchar), iif(a.llevar =1, 'LL-'+cast(v_d.num_correlative as varchar),'')) as 'correlativo2',
a.IdDocumento 
FROM
dbo.mst_Venta AS a INNER JOIN
dbo.mst_Venta_det AS b ON a.Id = b.IdVenta INNER JOIN
dbo.mst_Usuarios AS i ON i.Id=a.IdUsuarioPreventa INNER JOIN
dbo.mst_TipoDocumento l ON l.codigoSunat=a.CodigoTipoDoc LEFT JOIN
dbo.venta_delivery v_d ON v_d.id_venta = a.Id LEFT JOIN
dbo.mst_Cliente cl on v_d.id_contacto = cl.id LEFT JOIN
dbo.mst_Cliente_Direccion di ON cl.Id = di.IdCliente 
where b.Flag=1  and
a.Id = @id
GO
/****** Object:  StoredProcedure [dbo].[spReporteComprobante_aux]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteComprobante_aux]
@id int
as 
SELECT cpe.id_cab_cpe AS IdCabCpe,
cpe.descri_doc AS TipoDocumento,
iif(cpe.ant_tipo_doc_cli = 6,'RAZON SOCIAL','CLIENTE') AS TipoGlosa,
cpe.serie_nro_doc_cpe as SerieNum,
cpe.fecha_emi_doc_cpe as FechaEmision, 
cpe.total_cpe as TotalVenta,
cpe.total_cpe_letras as Total_Letras, 
cpe_detalle.nom_producto AS NomPoducto, 
IIF(CPE.tipo_doc_cli = 0, 'OTROS','DOC') AS descripcion,
CPE.ruc_dni_cliente AS DniRuc, 
CPE.nombre_cliente AS RazonSocial, 
CPE.Direccion AS Direccion,  
CPE.tipo_not_crede AS TipoNotCred, 
CPE.descri_not_crede AS DescripNotCred, 
CPE.tipo_doc_afecta AS TipoDocAfectado, 
CPE.nro_doc_afecta AS NumeroDocAfectado, 
cpe_detalle.id_item_cab_cpe AS IdVentaDet, 
CPE_DETALLE.pre_unitario AS PrecioUnit, 
cpe_detalle.cantidad AS Cantidad, 
0 AS Descuento, 
CPE_DETALLE.sub_total AS Subtotal,
CPE_DETALLE.sub_total AS Total, 
CPE_DETALLE.UNIT_CODE AS UnidDet,
CPE.HASH_SUNAT AS hassh,
cpe_detalle.monto_igv igv_detalle,
cpe.igv igv_cabecera
FROM vw_tbl_cab_cpe cpe
inner join vw_tbl_items_cab_cpe cpe_detalle on cpe.id_cab_cpe = cpe_detalle.id_cab_cpe
where cpe.id_cab_cpe = @id


















































GO
/****** Object:  StoredProcedure [dbo].[SpReporteConcar]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpReporteConcar]
@fechaInicio date,
@fechaFin date
as
SELECT 
Concar.Restricciones,Concar.SubDiario,
Concar.NumComprobante,
FORMAT(Concar.FechaComprobante,'dd/MM/yyyy') as FechaComprobante,
Concar.Cod_Moneda,
SUBSTRING(Concar.Glosa,1,40) as Glosa,
Concar.TipoCambio,
Concar.TipoConversion,Concar.FlagConversion,
FORMAT(Concar.FechaTipoCambio,'dd/MM/yyyy') as FechaTipoCambio,
Concar.CuentaContable,Concar.CodigoAnexo,Concar.CodigoCentroCosto,
Concar.Debe_Haber,Concar.ImporteOriginal,Concar.ImporteDolar,Concar.ImporteSoles,Concar.TipoDoc,Concar.NumDocumento,
FORMAT(Concar.FechaDocumento,'dd/MM/yyyy') as FechaDocumento,
FORMAT(Concar.FechaVencimiento,'dd/MM/yyyy') as FechaVencimiento,
Concar.CodigoArea,
Concar.GlosaDetalle,
Concar.AnexoAuxiliar,
Concar.MedioPago,
Concar.TipoDocReferencia,
Concar.NumDocReferencia,
Concar.FechaDocReferencia,
Concar.MaqRegistradora,
Concar.BaseDocReferencia,
Concar.IgvDocprevison,
Concar. Mq,
Concar.NumCajaReg,
Concar.FechaOperacion,
Concar.Tipotasa,
Concar.TasaDetrac,
Concar.ImporteDetracDol,
Concar.ImporteDetracSol,
Concar.TipCambioF,
Concar.ImporteSinIgv
FROM (
SELECT
'' as Restricciones,
'05' as SubDiario,
(RIGHT('00' + Ltrim(Rtrim(cast(MONTH(a.fecha_emi_doc_cpe) as varchar(2)))),2)) as [NumComprobante],
a.fecha_emi_doc_cpe as FechaComprobante,
IIF(a.tipo_moneda='PEN', 'MN','ME') as Cod_Moneda,
IIF(a.estatus=1,'ANULADO',a.nombre_cliente) as Glosa,
'' as TipoCambio,
'F' as TipoConversion,
'S' as FlagConversion,
a.fecha_emi_doc_cpe as FechaTipoCambio,
'121201' as CuentaContable,--LA SIGUIENTE LINEA ES CUENTA HABER 121201
'0000' as CodigoAnexo,
'' as CodigoCentroCosto,
'D' as Debe_Haber,-- D Y H
a.total_cpe as ImporteOriginal,
'' as ImporteDolar,
a.total_cpe as ImporteSoles,
CASE a.codigo
WHEN '01' THEN 'FT'
WHEN '03' THEN 'BV'
WHEN '07' THEN 'NC'
ELSE
''
END as TipoDoc,
a.serie_nro_doc_cpe as NumDocumento,
a.fecha_emi_doc_cpe as FechaDocumento,
a.fecha_emi_doc_cpe as FechaVencimiento,
'' as CodigoArea,
'' as GlosaDetalle,
'' as AnexoAuxiliar,
'' as MedioPago,
'' as TipoDocReferencia,
'' as NumDocReferencia,
'' as FechaDocReferencia,
'' as MaqRegistradora,
'' as BaseDocReferencia,
'' as IgvDocprevison,
'' as Mq,
'' as NumCajaReg,
'' as FechaOperacion,
'' as Tipotasa,
'' as TasaDetrac,
'' as ImporteDetracDol,
'' as ImporteDetracSol,
'V' As TipCambioF,
'' as ImporteSinIgv,
serie_doc_cpe,
nro_doc_cpe
FROM vw_tbl_cab_cpe a
WHERE a.codigo <> '00'
UNION ALL
SELECT
'' as Restricciones,
'05' as SubDiario,
(RIGHT('00' + Ltrim(Rtrim(cast(MONTH(a.fecha_emi_doc_cpe) as varchar(2)))),2)) as [NumComprobante],
a.fecha_emi_doc_cpe as FechaComprobante,
IIF(a.tipo_moneda='PEN', 'MN','ME') as Cod_Moneda,
IIF(a.estatus=1,'ANULADO',a.nombre_cliente) as Glosa,
'' as TipoCambio,
'F' as TipoConversion,
'S' as FlagConversion,
a.fecha_emi_doc_cpe as FechaTipoCambio,
'701211' as CuentaContable,--LA SIGUIENTE LINEA ES CUENTA HABER 121201
'0000' as CodigoAnexo,
'' as CodigoCentroCosto,
'H' as Debe_Haber,-- D Y H
a.ope_exonerada as ImporteOriginal,
'' as ImporteDolar,
a.ope_exonerada as ImporteSoles,
CASE a.codigo
WHEN '01' THEN 'FT'
WHEN '03' THEN 'BV'
WHEN '07' THEN 'NC'
ELSE
''
END as TipoDoc,
a.serie_nro_doc_cpe as NumDocumento,
a.fecha_emi_doc_cpe as FechaDocumento,
a.fecha_emi_doc_cpe as FechaVencimiento,
'' as CodigoArea,
'' as GlosaDetalle,
'' as AnexoAuxiliar,
'' as MedioPago,
'' as TipoDocReferencia,
'' as NumDocReferencia,
'' as FechaDocReferencia,
'' as MaqRegistradora,
'' as BaseDocReferencia,
'' as IgvDocprevison,
'' as Mq,
'' as NumCajaReg,
'' as FechaOperacion,
'' as Tipotasa,
'' as TasaDetrac,
'' as ImporteDetracDol,
'' as ImporteDetracSol,
'V' As TipCambioF,
'' as ImporteSinIgv,
serie_doc_cpe,
nro_doc_cpe
FROM vw_tbl_cab_cpe a
WHERE a.codigo <> '00'
UNION ALL
SELECT
'' as Restricciones,
'05' as SubDiario,
(RIGHT('00' + Ltrim(Rtrim(cast(MONTH(a.fecha_emi_doc_cpe) as varchar(2)))),2)) as [NumComprobante],
a.fecha_emi_doc_cpe as FechaComprobante,
IIF(a.tipo_moneda='PEN', 'MN','ME') as Cod_Moneda,
IIF(a.estatus=1,'ANULADO',a.nombre_cliente) as Glosa,
'' as TipoCambio,
'F' as TipoConversion,
'S' as FlagConversion,
a.fecha_emi_doc_cpe as FechaTipoCambio,
'401891' as CuentaContable,--LA SIGUIENTE LINEA ES CUENTA HABER 121201
'0000' as CodigoAnexo,
'' as CodigoCentroCosto,
'H' as Debe_Haber,-- D Y H
a.otros_impuestos as ImporteOriginal,
'' as ImporteDolar,
a.otros_impuestos as ImporteSoles,
CASE a.codigo
WHEN '01' THEN 'FT'
WHEN '03' THEN 'BV'
WHEN '07' THEN 'NC'
ELSE
''
END as TipoDoc,
a.serie_nro_doc_cpe as NumDocumento,
a.fecha_emi_doc_cpe as FechaDocumento,
a.fecha_emi_doc_cpe as FechaVencimiento,
'' as CodigoArea,
'' as GlosaDetalle,
'' as AnexoAuxiliar,
'' as MedioPago,
'' as TipoDocReferencia,
'' as NumDocReferencia,
'' as FechaDocReferencia,
'' as MaqRegistradora,
'' as BaseDocReferencia,
'' as IgvDocprevison,
'' as Mq,
'' as NumCajaReg,
'' as FechaOperacion,
'' as Tipotasa,
'' as TasaDetrac,
'' as ImporteDetracDol,
'' as ImporteDetracSol,
'V' As TipCambioF,
'' as ImporteSinIgv,
serie_doc_cpe,
nro_doc_cpe
FROM vw_tbl_cab_cpe a
WHERE a.codigo <> '00' AND a.otros_impuestos>0
) AS Concar
WHERE Concar.FechaComprobante BETWEEN @fechaInicio AND @fechaFin
ORDER BY Concar.serie_doc_cpe,Concar.nro_doc_cpe
GO
/****** Object:  StoredProcedure [dbo].[spReporteDetalladoTotal]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteDetalladoTotal]
@id int,
@idpiso int,
@idcaja int,
@idusuario int
as
IF @idpiso = 0
	begin
		SELECT 
		g.Numero as 'NumApertura',
		a.IdDocumento as 'IdDocumento',
		a.serieDoc as 'SerieDoc',
		a.NumeroDoc as 'NumeroDoc',
		CAST(g.Fecha AS DATE) as Fecha,
		b.Cantidad as Cant,
		f.nombreProducto,
		b.PrecioUnit,
		iif(a.anulado=0,b.Total,0.00) As ImporteTotal,
		iif(a.anulado=0,c.efectivo,0.00) as 'Efectivo',
		iif(a.anulado=0,c.visa+c.Mastercard,0.00) as 'Tarjeta',
		u.Nombre,
		a.UsuarioCrea
		FROM mst_Venta a
		INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
		INNER JOIN tabla_FormaPago c ON c.IdVenta = a.Id
		INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
		INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
		INNER JOIN mst_Producto f ON f.Id=e.idProducto
		INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
		INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
		INNER JOIN mst_Usuarios u ON u.Id=a.IdUsuarioPreventa
		WHERE g.Numero = @id and a.IdCaja = @idcaja and a.IdUsuario = @idusuario  
		ORDER BY a.IdDocumento,a.serieDoc,a.NumeroDoc
	end
else
	begin
		SELECT 
		g.Numero as 'NumApertura',
		a.IdDocumento as 'IdDocumento',
		a.serieDoc as 'SerieDoc',
		a.NumeroDoc as 'NumeroDoc',
		CAST(g.Fecha AS DATE) as Fecha,
		b.Cantidad as Cant,
		f.nombreProducto,
		b.PrecioUnit,
		iif(a.anulado=0,b.Total,0.00) As ImporteTotal,
		iif(a.anulado=0,c.efectivo,0.00) as 'Efectivo',
		iif(a.anulado=0,c.visa+c.Mastercard,0.00) as 'Tarjeta',
		u.Nombre,
		a.UsuarioCrea
		FROM mst_Venta a
		INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
		INNER JOIN tabla_FormaPago c ON c.IdVenta = a.Id
		INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
		INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
		INNER JOIN mst_Producto f ON f.Id=e.idProducto
		INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
		INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
		INNER JOIN mst_Usuarios u ON u.Id=a.IdUsuarioPreventa
		WHERE g.Numero = @id and a.IdCaja = @idcaja and a.IdUsuario = @idusuario and a.IdPiso = @idpiso
		ORDER BY a.IdDocumento,a.serieDoc,a.NumeroDoc
	end
GO
/****** Object:  StoredProcedure [dbo].[spReporteDetalladoTotal_FormaPago]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteDetalladoTotal_FormaPago]
@id int,
@idpiso int,
@idcaja int,
@idusuario int
as
if @idpiso = 0
	select fp.* from tabla_FormaPago fp
	inner join mst_Venta v on fp.IdVenta = v.Id
	WHERE v.IdApertura = @id and v.IdCaja = @idcaja and v.IdUsuario = @idusuario  
	ORDER BY v.IdDocumento,v.serieDoc,v.NumeroDoc

else
	select fp.* from tabla_FormaPago fp
	inner join mst_Venta v on fp.IdVenta = v.Id
	WHERE v.IdApertura = @id and v.IdCaja = @idcaja and v.IdUsuario = @idusuario and v.IdPiso = @idpiso
	ORDER BY v.IdDocumento,v.serieDoc,v.NumeroDoc






























GO
/****** Object:  StoredProcedure [dbo].[spReporteResumenProductos_CierreCaja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spReporteResumenProductos_CierreCaja]
@id int,
@idpiso int,
@idcaja int,
@idusuario int
as
SELECT 
	g.Numero as NumApertura,
	sum(b.Cantidad) as Cant,
	f.nombreProducto,
	SUM(iif(a.anulado=0,b.Total,0.00)) As ImporteTotal
	FROM mst_Venta a
	INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
	INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
	INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
	INNER JOIN mst_Producto f ON f.Id=e.idProducto
	INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura
	WHERE g.Numero = @id and a.IdCaja = @idcaja and a.IdUsuario = @idusuario
	GROUP BY g.Numero,f.nombreProducto



























GO
/****** Object:  StoredProcedure [dbo].[spReporteResumenVendedor_CierreCaja]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [dbo].[spReporteResumenVendedor_CierreCaja]
@id int,
@idpiso int,
@idcaja int,
@idusuario int
as
SELECT u.usuario,SUM(v.TotalVenta) AS TotalVenta 
FROM mst_Venta v
INNER JOIN mst_Usuarios u
ON v.IdUsuarioPreVenta = u.Id
WHERE v.IdApertura = @id and v.IdCaja = @idcaja and v.IdUsuario = @idusuario 
GROUP BY u.usuario



























GO
/****** Object:  StoredProcedure [dbo].[spReporteSalidaClientes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spReporteSalidaClientes]
@fecha_inicio date,
@fecha_fin date
as
SELECT ma.Id,(ma.serie+'-'+cast(ma.numero as varchar(10))) as serie_num, ma.fecha,mc.numeroDocumento,mc.razonSocial,ma.direccion,
SUM(mad.total) as Total, iif(ma.credito=1,'CREDITO','CONTADO') as credito, ma.documento, ma.referencia
FROM mst_almacen_movimiento ma
INNER JOIN mst_almacen_movimiento_detalle mad
ON ma.Id = mad.almacen_movimiento_id
INNER JOIN mst_Cliente mc
ON mc.Id = ma.IdCliente
WHERE ma.entrada=0 AND (mad.estado = 1 AND mad.flag = 1) AND (ma.estado=1 AND ma.flag=1) AND 
ma.fecha BETWEEN @fecha_inicio AND @fecha_fin--and ma.Id = 10030
GROUP BY ma.Id,ma.serie,ma.numero, ma.fecha,mc.numeroDocumento,mc.razonSocial,ma.direccion,ma.credito, ma.documento, ma.referencia













GO
/****** Object:  StoredProcedure [dbo].[spResetearTemp]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spResetearTemp]
@id int,
@idpiso int
as
delete from tabla_Pre_Venta_Detalle_Temp
where IdMesa = @id and IdPiso = @idpiso
if((select count(id)from tabla_Pre_Venta_Detalle_Temp)=0)
begin
DBCC CHECKIDENT ('[tabla_Pre_Venta_Detalle_Temp]', RESEED, 0)
end




















































GO
/****** Object:  StoredProcedure [dbo].[spResumenVentasProductos]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spResumenVentasProductos]
@id int,
@idpiso int,
@idcaja int,
@idusuario int,
@detallado bit--solo 0-1
AS
if(@detallado = 1)
	begin

	if(@idpiso = 0)
	begin 
		SELECT g.Numero,
		CAST(g.Fecha AS DATE) as Fecha,
		SUM(b.Cantidad) as Cant,
		f.nombreProducto,
		b.PrecioUnit,
		SUM(b.Total) as ImporteTotal ,
		'Todos' as Piso,
		0 as 'Num_Ini',
		0 as 'Num_Max',
		'xxx' as 'SerieDoc',
		'xxx' as 'IdDocumento'
		FROM mst_Venta a
		INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
		INNER JOIN tabla_FormaPago c ON c.IdVenta = a.id
		INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
		INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
		INNER JOIN mst_Producto f ON f.Id=e.idProducto
		INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
		INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
		WHERE a.Anulado=0 and (b.Flag=1 and b.Anulado=0) and g.Numero = @id and a.IdCaja = @idcaja 		and a.IdUsuario = @idusuario
		GROUP BY g.Numero,g.Fecha,f.nombreProducto,b.PrecioUnit,h.Descripcion
		ORDER BY h.Descripcion asc
	end
	else
	SELECT g.Numero,CAST(g.Fecha AS DATE) as Fecha,SUM(b.Cantidad) as Cant,f.nombreProducto,b.PrecioUnit,SUM(b.Total) as ImporteTotal ,
	CAST(@idpiso AS varchar(50)) as Piso,
	0 as 'Num_Ini',
	0 as 'Num_Max',
	'xxx' as 'SerieDoc',
	'xxx' as 'IdDocumento'
	FROM mst_Venta a
	INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
	INNER JOIN tabla_FormaPago c ON c.IdVenta = a.id
	INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
	INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
	INNER JOIN mst_Producto f ON f.Id=e.idProducto
	INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
	INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
	WHERE a.Anulado=0 and (b.Flag=1 and b.Anulado=0) and g.Numero = @id and a.IdPiso = @idpiso and a.IdCaja = @idcaja and a.IdUsuario = @idusuario
	GROUP BY g.Numero,g.Fecha,f.nombreProducto,b.PrecioUnit,h.Descripcion
	ORDER BY h.Descripcion asc

	end
else 
	begin
		if @idpiso = 0
			begin
				SELECT g.Numero,
				CAST(g.Fecha AS DATE) as Fecha,
				0.00 as 'Cant',
				'XXX' as 'nombreProducto',
				0.00 as 'PrecioUnit',
				SUM(b.Total) as ImporteTotal ,
				'Todos' as Piso,
				MIN(A.NumeroDoc) as 'Num_Ini',
				MAX(a.NumeroDoc) AS 'Num_Max'
				,a.SerieDoc,
				A.IdDocumento
				FROM mst_Venta a
				INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
				INNER JOIN tabla_FormaPago c ON c.IdVenta = a.id
				INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
				INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
				INNER JOIN mst_Producto f ON f.Id=e.idProducto
				INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
				INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
				WHERE a.Anulado=0 and (b.Flag=1 and b.Anulado=0) and g.Numero =@id and a.IdCaja = @idcaja and a.IdUsuario = @idusuario
				GROUP BY g.Numero,g.Fecha,A.SerieDoc, a.IdDocumento
			end
		else
			begin
				SELECT g.Numero,
				CAST(g.Fecha AS DATE) as Fecha,
				0.00 as 'Cant',
				'XXX' as 'nombreProducto',
				0.00 as 'PrecioUnit',
				SUM(b.Total) as ImporteTotal ,
				'Todos' as Piso,
				MIN(A.NumeroDoc) as 'Num_Ini',
				MAX(a.NumeroDoc) AS 'Num_Max'
				,a.SerieDoc,
				A.IdDocumento
				FROM mst_Venta a
				INNER JOIN mst_Venta_det b ON a.Id=b.IdVenta
				INNER JOIN tabla_FormaPago c ON c.IdVenta = a.id
				INNER JOIN mst_ProductoPresentacion d ON d.Id=b.IdProducto
				INNER JOIN mst_ProductoDetalle e ON e.Id=d.idProductosDetalle
				INNER JOIN mst_Producto f ON f.Id=e.idProducto
				INNER JOIN mst_Apertura g ON g.Numero=a.IdApertura and g.IdUsuario = a.IdUsuario and g.IdCaja = a.IdCaja
				INNER JOIN mst_Grupo h ON h.Id=f.IdGrupo
				WHERE a.Anulado=0 and (b.Flag=1 and b.Anulado=0) and g.Numero =@id and a.IdCaja = @idcaja and a.IdUsuario = @idusuario and a.IdPiso = @idpiso
				GROUP BY g.Numero,g.Fecha,A.SerieDoc, a.IdDocumento
			end
	end
GO
/****** Object:  StoredProcedure [dbo].[SpSearchProductByCodigoBarraOrIdDetalle]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpSearchProductByCodigoBarraOrIdDetalle]
@codigoBarra varchar(100),
@idDetalle int
as
if @idDetalle = 0
begin
	select 
	pp.Id Id,
	pd.codigoBarra 'CodBarra',
	p.nombreProducto + ' ' + 
	pd.descripcion + ' ' + 
	mmm.descripcion + ' ' +
	mm.nombreMarca + ' ' + 
	t.descripcion+' '+ 
	c.descripcion  as 'Descripcion',
	um.nombreUnidad 'UnidadMedida',
	um.factor [Factor],
	pd.imagenProducto Imagen,
	pp.precioUnitario Precio,
	um.id 'IdUnidad',
	pp.Principal,
	p.IdGrupo as 'idgrupo',
	pd.Id as 'IdProductoDetalle',
	pp.PrincipalAlmacen
	from mst_Producto p 
	inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
	inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
	inner join mst_Marca mm on p.idMarca = mm.Id
	inner join mst_Talla t on pd.idTalla = t.Id
	inner join mst_Color c on pd.idColores = c.Id
	inner join mst_UnidadMedida um on pp.idUnidad = um.Id
	inner join mst_Medidas mmm on pd.idmedida = mmm.id
	where p.flag = 1 
	and p.estado = 1 
	and pd.estado = 1
	and pd.flag  = 1
	and pp.estado = 1
	and pp.flag = 1
	and (pd.codigoBarra = @codigoBarra or pp.Codigo = @codigoBarra)
	order by pp.id desc
end
else
begin
	select 
	pp.Id Id,
	pd.codigoBarra 'CodBarra',
	p.nombreProducto + ' ' + 
	pd.descripcion + ' ' + 
	mmm.descripcion + ' ' +
	mm.nombreMarca + ' ' + 
	t.descripcion+' '+ 
	c.descripcion  as 'Descripcion',
	um.nombreUnidad 'UnidadMedida',
	um.factor [Factor],
	pd.imagenProducto Imagen,
	pp.precioUnitario Precio,
	um.id 'IdUnidad',
	pp.Principal,
	p.IdGrupo as 'idgrupo',
	pd.Id as 'IdProductoDetalle',
	pp.PrincipalAlmacen
	from mst_Producto p 
	inner join mst_ProductoDetalle pd on p.Id = pd.idProducto
	inner join mst_ProductoPresentacion pp on pd.Id=  pp.idProductosDetalle
	inner join mst_Marca mm on p.idMarca = mm.Id
	inner join mst_Talla t on pd.idTalla = t.Id
	inner join mst_Color c on pd.idColores = c.Id
	inner join mst_UnidadMedida um on pp.idUnidad = um.Id
	inner join mst_Medidas mmm on pd.idmedida = mmm.id
	where p.flag = 1 
	and p.estado = 1 
	and pd.estado = 1
	and pd.flag  = 1
	and pp.estado = 1
	and pp.flag = 1
	and (pd.Id = @idDetalle)
	order by pp.id desc
end
GO
/****** Object:  StoredProcedure [dbo].[spSecuenciaId]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[spSecuenciaId]
(
 @nombreTabla nvarchar(100),
 @columna varchar(100)
)

As

Declare @tabla nvarchar(max);

declare @columnas nvarchar(500);

set @columnas = '@columna varchar(100)';

Set @tabla = 'SELECT cast(max(' + @columna+') as varchar) FROM ' + QUOTENAME(@nombreTabla);
exec sp_executesql @tabla





















































GO
/****** Object:  StoredProcedure [dbo].[spSecuenciaIdProforma]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spSecuenciaIdProforma]
as
select max(id) id from tabla_Proforma




















































GO
/****** Object:  StoredProcedure [dbo].[spSecuenciaIdResumenes]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spSecuenciaIdResumenes]
@fecha date,
@tipoproceso char(2)
as
select count(id) 'items' from Tbl_Resumen
where cast(Fecha_Documento as date)  = @fecha and TipoProceso = @tipoproceso


















































GO
/****** Object:  StoredProcedure [dbo].[spStockActualizarAcumulado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spStockActualizarAcumulado]
@idalmacen int
as
INSERT INTO Stocks_Acumulados
 select 
 @idalmacen as IdAlmacen,
 id as IdProducto,
 0.00 as Entradas,
 0.00 as Salidas,
 0.00 as Saldo,
 '2019-03-10' as Fecha_Crea,
 NULL as Fecha_Modifica,
 'ADMIN' AS Usuario_Crea,
 NULL AS Usuario_Modifica
 from mst_ProductoDetalle
 where flag = 1



















































GO
/****** Object:  StoredProcedure [dbo].[SpStockActualizarAlEliminarItemVenta]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[SpStockActualizarAlEliminarItemVenta]
@id int
as
declare @total money, @idproduct int, @idalmacen int
set @idalmacen = (select top 1 v.IdAlmacen from mst_Venta_det vd inner join mst_Venta v on vd.IdVenta = v.Id where vd.Id = @id)

declare Lista cursor
for
(
select temp.tot, temp.idproducto from
(
select (vd.Cantidad * vd.Factor) tot, pp.idProductosDetalle as 'idproducto' from mst_Venta_det vd
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
where vd.Id = @id and vd.Anulado  = 1
)
as temp
)
for update

open Lista

FETCH Lista INTO @total,@idproduct


WHILE (@@FETCH_STATUS = 0)
BEGIN
   
   UPDATE Stocks_Acumulados SET Salidas=(Salidas - @total),Saldo=(Saldo + @total)
   WHERE IdProducto=@idproduct and IdAlmacen=@IdAlmacen
   
   --print @total
   --print @idventadetalle

   delete from mst_Venta_det where id = @id
-- LECTURA DE LA SIGUIENTE FILA DEL CURSOR
   FETCH Lista INTO @total,@idproduct
END

-- CIERRE DEL CURSOR
CLOSE Lista

-- LIBERAR LOS RECURSOS
DEALLOCATE Lista

















































GO
/****** Object:  StoredProcedure [dbo].[spStockActualizarSaldo]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockActualizarSaldo]
@idalmacen int
as
DECLARE @IdProducto INT,@Entrada DECIMAL(18,2) = 0,@Salida DECIMAL(18,2) = 0,@Saldo DECIMAL(18,2) = 0

DECLARE CStockAcumulado CURSOR
FOR
(SELECT TEMP.Id_Almacen,TEMP.Id,(SUM(TEMP.Inicial)+SUM(TEMP.Compras)) as Entrada,SUM(TEMP.Ventas) as Salida, (SUM(TEMP.Inicial)+SUM(TEMP.Compras)-SUM(TEMP.Ventas)) as Saldo
FROM
(
-----------INVENTARIO---------
SELECT a.Id_Almacen,c.Id,b.IdUnidad,d.nombreUnidad,(b.Cantidad*d.factor) as Inicial,0 as Compras,0 as Ventas
FROM mst_Inventario a
INNER JOIN mst_Inventario_Detalle b ON a.Id = b.Id_Inventario
INNER JOIN mst_productodetalle c ON c.Id = b.Id_Producto
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Estado=0 and a.Flag=1 and b.Estado=1 and b.Flag=1
-----------INVENTARIO---------
UNION ALL
-----------COMPRAS---------
SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,(b.Cantidad*d.factor) as Compras, 0 as Ventas
FROM mst_Compras a
INNER JOIN mst_ComprasDetalles b ON a.Id = b.IdCompra
INNER JOIN mst_productodetalle c ON c.Id = b.IdProducto
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where b.estado = 1 and b.Flag = 1 and a.Estado = 1 and a.flag=1 and a.isClosed = 1
-----------COMPRAS---------
UNION ALL

SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,0 as Compras,(b.Cantidad*d.factor) as Ventas
FROM mst_Venta a
INNER JOIN mst_Venta_det b ON a.Id = b.IdVenta
INNER JOIN mst_ProductoPresentacion pp on b.IdProducto = pp.Id
INNER JOIN mst_productodetalle c ON c.Id = pp.idProductosDetalle
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Anulado=0 and b.Flag=1 
AND a.IdDocumento <>'07'
UNION ALL

SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,
CASE a.TipoNotCred
WHEN '01' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '02' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '03' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '06' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '07' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '08' THEN ISNULL((b.Cantidad*d.factor),0.00)
ELSE 0.00 END AS Compras,
0 as Ventas
FROM mst_Venta a
INNER JOIN mst_Venta_det b ON a.Id = b.IdVenta
INNER JOIN mst_ProductoPresentacion pp on b.IdProducto = pp.Id
INNER JOIN mst_productodetalle c ON c.Id = pp.idProductosDetalle
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Anulado=0 and b.Flag=1 
AND a.IdDocumento = '07' AND 
(a.TipoNotCred<>'04' OR a.TipoNotCred<>'05' OR a.TipoNotCred<>'09' OR a.TipoNotCred<>'10')

-----------TRASLADOS---------
UNION ALL
SELECT t.idAlmacenEntrada, td.idProducto , td.idUnidad, td.nombreUnidad,0 as Inicial, (td.cantidad * td.factor) as 'Compras', 0 as 'Ventas' FROM mst_almacen_traslado t
INNER JOIN mst_almacen_traslado_detalle td on t.id = td.almacen_traslado_id
WHERE t.flag = 1 and td.flag = 1 and t.idAlmacenEntrada = @idalmacen
-----------
UNION ALL
SELECT t.idAlmacenSalida, td.idProducto , td.idUnidad, td.nombreUnidad,0 as Inicial, 0 as 'Compras', (td.cantidad * td.factor) as 'Ventas' FROM mst_almacen_traslado t
INNER JOIN mst_almacen_traslado_detalle td on t.id = td.almacen_traslado_id
WHERE t.flag = 1 and td.flag = 1 and t.idAlmacenSalida = @idalmacen
-----------TRASLADOS---------

-----------MOVIMIENTOS ENTRADA---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, (md.cantidad * md.factor) as 'Compras', 0 as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and entrada = 1
-----------MOVIMIENTOS ENTRADA---------


-----------MOVIMIENTOS SALIDA---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, 0 as 'Compras', (md.cantidad * md.factor) as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and salida = 1
-----------MOVIMIENTOS SALIDA---------

-----------MOVIMIENTOS AJUSTES---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, (md.cantidad * md.factor) as 'Compras', 0 as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and m.ajuste = 1
-----------MOVIMIENTOS AJUSTES---------

) AS TEMP 
GROUP BY TEMP.Id_Almacen,TEMP.Id
HAVING TEMP.Id_Almacen=@idalmacen
) ORDER BY TEMP.Id DESC
FOR UPDATE

OPEN CStockAcumulado
FETCH CStockAcumulado INTO @IdAlmacen,@IdProducto,@Entrada,@Salida,@Saldo 

declare @exist int = 0
WHILE (@@FETCH_STATUS = 0)
BEGIN
	
	set @exist = isnull((select count(Id) from Stocks_Acumulados where IdProducto = @IdProducto and IdAlmacen = @idalmacen), 0)
	PRINT '-------------'
	PRINT @exist
	PRINT @IdProducto
	PRINT @idalmacen
	PRINT '-------------'
	set NOCOUNT ON	
	if @exist = 0
	begin
		insert into Stocks_Acumulados (IdAlmacen, IdProducto, Entradas, Salidas, Saldo, Fecha_Crea)
		values(@idalmacen, @IdProducto, @Entrada, @Salida, @Saldo, GETDATE())
	end
	else	
	begin
		UPDATE Stocks_Acumulados SET Entradas=@Entrada,Salidas=@Salida,Saldo=@Saldo
		WHERE IdProducto = @IdProducto and IdAlmacen = @IdAlmacen	  
	end 
-- LECTURA DE LA SIGUIENTE FILA DEL CURSOR
   FETCH CStockAcumulado INTO @IdAlmacen,@IdProducto,@Entrada,@Salida,@Saldo
END

-- CIERRE DEL CURSOR
CLOSE CStockAcumulado

-- LIBERAR LOS RECURSOS
DEALLOCATE CStockAcumulado
--
select * from Stocks_Acumulados
where IdAlmacen = @idalmacen
GO
/****** Object:  StoredProcedure [dbo].[spStockActualizarSaldoItem]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockActualizarSaldoItem]
@idalmacen int,@idproductoentrada int
as
DECLARE @IdProducto INT,@Entrada DECIMAL(18,2) = 0,@Salida DECIMAL(18,2) = 0,@Saldo DECIMAL(18,2) = 0
DECLARE CStockAcumulado CURSOR
FOR
(SELECT TEMP.Id_Almacen,TEMP.Id,(SUM(TEMP.Inicial)+SUM(TEMP.Compras)) as Entrada,SUM(TEMP.Ventas) as Salida, (SUM(TEMP.Inicial)+SUM(TEMP.Compras)-SUM(TEMP.Ventas)) as Saldo
FROM
(
----
-----------INVENTARIO---------
SELECT a.Id_Almacen,c.Id,b.IdUnidad,d.nombreUnidad,(b.Cantidad*d.factor) as Inicial,0 as Compras,0 as Ventas
FROM mst_Inventario a
INNER JOIN mst_Inventario_Detalle b ON a.Id = b.Id_Inventario
INNER JOIN mst_productodetalle c ON c.Id = b.Id_Producto
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Estado = 0 and a.Flag = 1 and b.Estado = 1 and b.Flag = 1 AND a.Id_Almacen = @idalmacen
-----------INVENTARIO---------
-----------COMPRAS---------
UNION ALL
SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,(b.Cantidad*d.factor) as Compras, 0 as Ventas
FROM mst_Compras a
INNER JOIN mst_ComprasDetalles b ON a.Id = b.IdCompra
INNER JOIN mst_productodetalle c ON c.Id = b.IdProducto
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Estado=1 and a.flag=1 AND a.isClosed = 1 and b.Estado=1 and b.Flag=1 and a.IdAlmacen = @idalmacen and a.IsClosed = 1
-----------COMPRAS---------

UNION ALL
SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,0 as Compras,(b.Cantidad*d.factor) as Ventas
FROM mst_Venta a
INNER JOIN mst_Venta_det b ON a.Id = b.IdVenta
INNER JOIN mst_ProductoPresentacion pp on b.IdProducto = pp.Id
INNER JOIN mst_productodetalle c ON c.Id = pp.idProductosDetalle
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Anulado=0 and b.Flag = 1 and b.Anulado = 0 and cast(a.Observacion as varchar) = ''
AND a.IdDocumento <> '07' and a.IdAlmacen = @idalmacen

UNION ALL

SELECT a.IdAlmacen,c.Id,b.IdUnidad,d.nombreUnidad,0 as Inicial,
CASE a.TipoNotCred
WHEN '01' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '02' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '03' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '06' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '07' THEN ISNULL((b.Cantidad*d.factor),0.00)
WHEN '08' THEN ISNULL((b.Cantidad*d.factor),0.00)
ELSE 0.00 END AS Compras,
0 as Ventas
FROM mst_Venta a
INNER JOIN mst_Venta_det b ON a.Id = b.IdVenta
INNER JOIN mst_ProductoPresentacion pp on b.IdProducto = pp.Id
INNER JOIN mst_productodetalle c ON c.Id = pp.idProductosDetalle
INNER JOIN mst_UnidadMedida d ON d.Id = b.IdUnidad 
where a.Anulado=0 and b.Flag = 1 and b.Anulado = 0 
AND a.IdDocumento = '07' AND 
(a.TipoNotCred<>'04' OR a.TipoNotCred<>'05' OR a.TipoNotCred<>'09' OR a.TipoNotCred<>'10') and a.IdAlmacen = @idalmacen

-----------TRASLADOS---------
UNION ALL
SELECT t.idAlmacenEntrada, td.idProducto , td.idUnidad, td.nombreUnidad,0 as Inicial, (td.cantidad * td.factor) as 'Compras', 0 as 'Ventas' FROM mst_almacen_traslado t
INNER JOIN mst_almacen_traslado_detalle td on t.id = td.almacen_traslado_id
WHERE t.flag = 1 and td.flag = 1 and t.idAlmacenEntrada = @idalmacen
-----------
UNION ALL
SELECT t.idAlmacenSalida, td.idProducto , td.idUnidad, td.nombreUnidad,0 as Inicial, 0 as 'Compras', (td.cantidad * td.factor) as 'Ventas' FROM mst_almacen_traslado t
INNER JOIN mst_almacen_traslado_detalle td on t.id = td.almacen_traslado_id
WHERE t.flag = 1 and td.flag = 1 and t.idAlmacenSalida = @idalmacen
-----------TRASLADOS---------

-----------MOVIMIENTOS ENTRADA---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, (md.cantidad * md.factor) as 'Compras', 0 as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and entrada = 1 and m.idAlmacen = @idalmacen
-----------MOVIMIENTOS ENTRADA---------


-----------MOVIMIENTOS SALIDA---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, 0 as 'Compras', (md.cantidad * md.factor) as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and salida = 1 and m.idAlmacen = @idalmacen
-----------MOVIMIENTOS SALIDA---------

-----------MOVIMIENTOS AJUSTES---------
UNION ALL
SELECT m.idAlmacen, md.idProducto, md.idUnidad, md.nombreUnidad,0 as Inicial, (md.cantidad * md.factor) as 'Compras', 0 as 'Ventas' from mst_almacen_movimiento m 
INNER JOIN mst_almacen_movimiento_detalle md on m.id = md.almacen_movimiento_id
WHERE m.flag = 1 and md.flag = 1 and m.ajuste = 1 and m.idAlmacen = @idalmacen
-----------MOVIMIENTOS AJUSTES---------

) AS TEMP
where temp.Id = @idproductoentrada
GROUP BY TEMP.Id_Almacen,TEMP.Id
HAVING TEMP.Id_Almacen=@idalmacen)
FOR UPDATE

OPEN CStockAcumulado
FETCH CStockAcumulado INTO @IdAlmacen,@IdProducto,@Entrada,@Salida,@Saldo
set NOCOUNT ON

declare @exist int = isnull((select count(Id) from Stocks_Acumulados where IdProducto = @idproductoentrada and IdAlmacen = @idalmacen), 0)
if @exist = 0
begin
	insert into Stocks_Acumulados (IdAlmacen, IdProducto, Entradas, Salidas, Saldo, Fecha_Crea)
	values(@idalmacen, @idproductoentrada, @Entrada, @Salida, @Saldo, GETDATE())
end

UPDATE Stocks_Acumulados SET Entradas=@Entrada,Salidas=@Salida,Saldo=@Saldo
WHERE IdProducto=@idproductoentrada and IdAlmacen=@IdAlmacen

WHILE (@@FETCH_STATUS = 0)
BEGIN
set NOCOUNT ON	
   UPDATE Stocks_Acumulados SET Entradas=@Entrada,Salidas=@Salida,Saldo=@Saldo
   WHERE IdProducto=@idproductoentrada and IdAlmacen=@IdAlmacen
   --print 'almacen = ' + cast(@idalmacen as varchar)
   --print 'idproducto = ' + cast(@IdProducto as varchar)
   --print 'entradas = ' + cast(@entrada as varchar)
   --print 'salidas = ' + cast(@salida as varchar)
   --print 'saldo = ' + cast(@saldo as varchar)
-- LECTURA DE LA SIGUIENTE FILA DEL CURSOR
   FETCH CStockAcumulado INTO @IdAlmacen,@IdProducto,@Entrada,@Salida,@Saldo
END

-- CIERRE DEL CURSOR
CLOSE CStockAcumulado

-- LIBERAR LOS RECURSOS
DEALLOCATE CStockAcumulado

select
id 'id',
IdAlmacen 'id_almacen' ,
IdProducto 'id_producto',
Entradas 'entradas',
Salidas 'salidas',
Saldo 'saldo'
from Stocks_Acumulados where IdProducto = @idproductoentrada
and idAlmacen = @idalmacen
GO
/****** Object:  StoredProcedure [dbo].[spStockAnular]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockAnular]
@idcompraventa int,
@bit int
as
declare @idprod int
declare @cantidad money
declare @factor int 
declare @valor money
declare @idalmacen int
declare @salir bit = 0
if(@bit=1)
begin
declare Temp cursor
FOR
(select pp.idProductosDetalle,cantidad,um.factor,v.IdAlmacen from mst_Venta_det vd
inner join mst_unidadmedida um on vd.idunidad= um.id
inner join mst_Venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
where idventa = @idcompraventa) 
open Temp
fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
way:	
	set @valor = @cantidad  * CAST(@factor as money);
	update Stocks_Acumulados set 
	entradas = Entradas - @valor ,
	saldo = entradas - (Salidas - @valor)
	where IdProducto = @idprod and idalmacen = @idalmacen;
	fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
	if(@@FETCH_STATUS = 0) set @salir = 0
	else set @salir = 1
if(@salir = 0)
	goto way;
		close Temp;
	DEALLOCATE Temp;
end
else if(@bit = 2)
begin
declare Temp cursor
FOR
(select pp.idProductosDetalle,cantidad,um.factor,v.IdAlmacen from mst_ComprasDetalles vd
inner join mst_unidadmedida um on vd.idunidad= um.id
inner join mst_Compras v on vd.IdCompra = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
where IdCompra = @idcompraventa) 
open Temp
fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
way2:	
	set @valor = @cantidad  * CAST(@factor as money);
	update Stocks_Acumulados set 
	Entradas = Entradas - @valor,
	Saldo = (entradas - @valor) - Salidas
	where IdProducto = @idprod and idalmacen = @idalmacen;
	fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
	if(@@FETCH_STATUS = 0) set @salir = 0
	else set @salir = 1
if(@salir = 0)
	goto way2;
		close Temp;
	DEALLOCATE Temp;
end



















































GO
/****** Object:  StoredProcedure [dbo].[spStockEliminarItemSalidaEntrada]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockEliminarItemSalidaEntrada]
@idproducto int,
@bit bit,
@idcompraventa bit
as
declare @iddetalle int = (select idProductosDetalle from mst_ProductoPresentacion where Id = @idproducto);
declare @idalmacenaux int;
if(@bit = 0)
begin
set @idalmacenaux = (select idalmacen from mst_Venta where id = @idcompraventa);
declare @cantidad money = (select Cantidad from mst_Venta_det where id = @idproducto)
declare @factor money = (select um.Factor from mst_Venta_det vd inner join mst_UnidadMedida um on vd.idunidad = um.id where vd.Id = @idproducto)
declare @valor money = @cantidad * @factor
update Stocks_Acumulados set Salidas = Salidas - @valor, 
saldo = saldo - @valor
where idproducto = @iddetalle and IdAlmacen = @idalmacenaux
end
else if(@bit = 1)
begin
set @idalmacenaux = (select IdAlmacen from mst_Compras where id=@idcompraventa);
declare @cantidad2 money = (select Cantidad from mst_ComprasDetalles where id = @idproducto)
declare @factor2 money = (select um.Factor from mst_ComprasDetalles vd inner join mst_UnidadMedida um on vd.idunidad = um.id where vd.id = @idproducto)
declare @valor2 money = @cantidad * @factor
update Stocks_Acumulados set Entradas = Entradas - @valor,
saldo = saldo - @valor
where idproducto = @iddetalle  and IdAlmacen = @idalmacenaux
end



















































GO
/****** Object:  StoredProcedure [dbo].[spStockEntradas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockEntradas]
@idcompra int
as
declare @idprod int
declare @cantidad money
declare @factor int 
declare @valor money
declare @idalmacen int

declare Temp cursor
FOR
(select pp.idProductosDetalle,cantidad,um.factor,v.IdAlmacen from mst_ComprasDetalles vd
inner join mst_unidadmedida um on vd.idunidad= um.id
inner join mst_compras v on vd.IdCompra = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.id
where IdCompra = @idcompra) 
open Temp
fetch Temp into @idprod,@cantidad,@factor,@idalmacen;

while(@@fetch_status = 0)
begin		
	set @valor = @cantidad  * CAST(@factor as money);
	update Stocks_Acumulados set 
	Entradas = Entradas + @valor,
	saldo = (entradas + @valor) - Salidas
	where IdProducto = @idprod and IdAlmacen = @idalmacen;
	fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
	end
	close Temp;
	DEALLOCATE Temp;



















































GO
/****** Object:  StoredProcedure [dbo].[SpStockNuevoRegistro]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpStockNuevoRegistro]
@idAlmacen int,
@idProducto int,
@entrada numeric,
@salida numeric,
@saldo numeric
as
declare @hay int = (select COUNT(Id) from Stocks_Acumulados
where IdAlmacen = @idalmacen and IdProducto = @idproducto)

if @hay = 0
begin
SET NOCOUNT ON
INSERT INTO Stocks_Acumulados
values (@idalmacen,
 @idproducto,
 @entrada,
 @salida,
 @saldo,
 GETDATE(),
 NULL,
 'ADMIN',
 NULL)

SELECT CAST(SCOPE_IDENTITY() AS INT);
end
else select 0
GO
/****** Object:  StoredProcedure [dbo].[spStockSalidas]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spStockSalidas]
@idventa int,
@bit int
as
declare @idprod int
declare @cantidad money
declare @factor int 
declare @valor money
declare @idalmacen int
if(@bit=1)
declare Temp cursor
FOR
(select pp.idProductosDetalle,cantidad,um.factor,v.IdAlmacen from mst_venta_det vd
inner join mst_unidadmedida um on vd.idunidad= um.id
inner join mst_venta v on vd.IdVenta = v.Id
inner join mst_ProductoPresentacion pp on vd.IdProducto = pp.Id
where idventa = @idventa) 
open Temp
fetch Temp into @idprod,@cantidad,@factor,@idalmacen;

while(@@fetch_status = 0)
begin		
	set @valor = @cantidad  * CAST( @factor as money);
	update Stocks_Acumulados set 
	salidas = salidas + @valor ,
	saldo = entradas - (Salidas + @valor)
	where IdProducto = @idprod and idalmacen = @idalmacen;
	fetch Temp into @idprod,@cantidad,@factor,@idalmacen;
	end
	close Temp;
	DEALLOCATE Temp;




















































GO
/****** Object:  StoredProcedure [dbo].[SpUpdateBaseConfig]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpUpdateBaseConfig]
@id int,
@nombre varchar(50),
@serverSql varchar(50),
@databaseName varchar(50),
@databaseUser varchar(50),
@databasePassword text
as
update BaseConfig set Nombre = @nombre,
ServerSql = @serverSql, DatabaseName=@databaseName,
DatabaseUser=@databaseUser,DatabasePassword=@databasePassword
where Id=@id
GO
/****** Object:  StoredProcedure [dbo].[SpUpdateConfiguracionGeneral]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpUpdateConfiguracionGeneral]
@ruc varchar(11),
@razonSocial varchar(max),
@nombreComercial varchar(max),
@direccion varchar(max),
@telefono varchar(11),
@celular varchar(11),
@web varchar(100),
@correo varchar(100),
@marca bit,
@grupoLineaFamilia bit,
@talla bit,
@color bit,
@medida bit,
@descripcion bit,
@fechaVence bit,
@proveedor bit,
@visa bit,
@mastercard bit,
@logo image,
@impresora1 varchar(100),
@impresora2 varchar(100),
@ubigeo varchar(11),
@ciudad varchar(100),
@distrito varchar(100),
@igv money,
@certificadoCpe varchar(100),
@contraseniaCertificadoCpe varchar(100),
@usuarioSecundarioSol varchar(100),
@contraseniaUsuarioSecundarioSol varchar(100),
@validarVendedor bit,
@modoRapido bit,
@codigoBarra VARCHAR(250),
@numeroCopias int,
@numeroMesas int,
@produccion bit,
@passCorreo varchar(100),
@metodoBusqueda char(2),
@urlOse varchar(100),
@tipoOse int,
@urlOseBeta varchar(100),
@urlOseOtros varchar(100),
@urlOseOtrosBeta varchar(100),
@urlOseAux varchar(100),
@urlOseAuxBeta varchar(100),
@tipoMoneda varchar(5),
@puerto int,
@ssl bit,
@servidorEmail varchar(100),
@nube bit,
@id int,
@horaEnvio int,
@pagoEfectivo varchar(5),
@idApiSunat varchar(100),
@claveApiSunat varchar(100),
@rutaCopiaBd varchar(100),
@codigoAnexo varchar(10),
@activarLote bit,
@entradaDirectaProducto bit,
@documentoVentaDefecto char(2),
@activarBalanza bit,
@alertaSunat bit
as
update tabla_configuracion_general
set
ruc=@ruc,
razonsocial = @razonSocial,
nombrecomercial = @nombreComercial,
direccion = @direccion,
telefono = @telefono,
celular = @celular,
web = @web,
correo = @correo,
marca = @marca,
grupo_linea_familia = @grupoLineaFamilia,
talla = @talla,
color = @color,
medida = @medida,
descripcion = @descripcion,
f_vence = @fechaVence,
proveedor = @proveedor,
visa = @visa,
mastercard = @mastercard,
Logo = @logo,
impresora1 = @impresora1,
impresora2 = @impresora2,
ubigeo = @ubigeo,
ciudad = @ciudad,
distrito = @distrito,
igv=@igv,
Certificado_CPE = @certificadoCpe,
ContraseniaCertificadoCpe = @contraseniaCertificadoCpe,
UsuarioSecundarioSol = @usuarioSecundarioSol,
ContraseniaUsuarioSecundarioSol = @contraseniaUsuarioSecundarioSol,
Validar_Vendedor = @validarVendedor,
ModoRapido = @modoRapido,
CodBarra = @codigoBarra,
NumCopias = @numeroCopias,
NumMesas = @numeroMesas,
Produccion = @produccion,
PassCorreo = @passCorreo,
Met_Busqueda = @metodoBusqueda,
UrlOse = @urlOse,
TipoOse=@tipoOse,
UrlOseBeta = @urlOseBeta,
UrlOseOtros = @urlOseOtros,
UrlOseOtrosBeta=@urlOseOtrosBeta,
UrlOseAux=@urlOseAux,
UrlOseAuxBeta=@urlOseAuxBeta,
TipoMoneda=@tipoMoneda,
Puerto=@puerto,
Ssl = @ssl,
Servidor_Email=@servidorEmail,
Nube=@nube, 
hora_envio=@horaEnvio,
pago_defecto=@pagoEfectivo,
id_api_sunat=@idApiSunat,
clave_api_sunat=@claveApiSunat,
ruta_copia_bd=@rutaCopiaBd,
CodigoAnexo=@codigoAnexo,
ActivarLote=@activarLote,
EntradaDirectaProducto=@entradaDirectaProducto,
DocumentoVentaDefecto=@documentoVentaDefecto,
ActivarBalanza = @activarBalanza,
AlertaSunat = @alertaSunat
where id =@id
select @id as 'id'
GO
/****** Object:  StoredProcedure [dbo].[SpUpdateLote]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SpUpdateLote]
@state bit
as
update tabla_configuracion_general set ActivarLote = @state

GO
/****** Object:  StoredProcedure [dbo].[spValidar_Res]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spValidar_Res]
@id int,
@idproducto int,
@cantidad money
as
select * from tabla_Pre_Venta_Detalle 
where id = @id and IdProducto = @idproducto and Cantidad = @cantidad
and Pagado = 0 and Eliminado = 0



















































GO
/****** Object:  StoredProcedure [dbo].[spValidarManuales]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spValidarManuales]
@serie varchar(4),
@numero int
as
select * from mst_Venta
where SerieDoc = @serie and NumeroDoc = @numero






















































GO
/****** Object:  StoredProcedure [dbo].[SpValidarNumeroDocumentoCliente]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpValidarNumeroDocumentoCliente]
@numeroDocumento varchar(20)
as
select * from mst_Cliente
where numeroDocumento = @numeroDocumento
and estado = 1 and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[SpValidateDniProveedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SpValidateDniProveedor]
@ruc varchar(20)
as
select * from mst_Proveedor
where ruc = @ruc and estado = 1 and flag = 1
GO
/****** Object:  StoredProcedure [dbo].[spVerConexionPredeterminada]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spVerConexionPredeterminada]
as
select * from MST_SERVIDORES
where Predeterminado = 1


















































GO
/****** Object:  StoredProcedure [dbo].[spverificarcodbarra]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spverificarcodbarra]
@codigo varchar(100)
as
select pd.id, pp.Id as 'IdProductoPresentacion' from mst_ProductoDetalle pd 
inner join mst_ProductoPresentacion pp on pd.id = pp.idProductosDetalle
where (codigoBarra = @codigo and pd.flag = 1) or (pp.Codigo = @codigo and pp.flag = 1)
GO
/****** Object:  StoredProcedure [dbo].[spVerificarInventarioAbierto]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spVerificarInventarioAbierto]
@id int
as
select * from mst_Inventario 
where Id_Almacen = @id and Estado = 1



















































GO
/****** Object:  StoredProcedure [dbo].[spVerificarPulso]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spVerificarPulso]
@nombre varchar(100),
@piso int,
@mesa int
as
select * from tabla_pulsos 
where NombreUsuario = @nombre and IdPiso = @piso and IdMesa = @mesa



















































GO
/****** Object:  StoredProcedure [dbo].[spVerificarVendedor]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spVerificarVendedor]
@idvendedor int,
@idmesa int,
@idpiso int
as
select * from tabla_Pre_Venta
where IdMesa = @idmesa and IdPiso = @idpiso and Pagado=0and Eliminado = 0
and IdUsuario = @idvendedor



















































GO
/****** Object:  StoredProcedure [dbo].[spVersiHay]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spVersiHay]
@idventa int
as
select * from tbl_info_cpe
where id_cab_cpe = @idventa























































GO
/****** Object:  StoredProcedure [dbo].[VerSiestaAperturado]    Script Date: 28/11/2021 20:53:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[VerSiestaAperturado]
@idcaja int,
@idusuario int
as
select a.*, U.Id as 'user_id', u.usuario from mst_apertura a
inner join mst_Usuarios u on a.IdUsuario = u.Id
where idcaja = @idcaja  and Abierto_Cerrado = 0 and IdUsuario = @idusuario
--and year(fecha) = year(GETDATE())

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[9] 4[7] 2[67] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1[75] 4) )"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2) )"
      End
      ActivePaneConfig = 14
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tbl_info_cpe"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      PaneHidden = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_tbl_cab_cpe'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_tbl_cab_cpe'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[61] 4[1] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2) )"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 285
               Bottom = 136
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 532
               Bottom = 136
               Right = 741
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 12
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 13' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_tbl_items_cab_cpe'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'50
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_tbl_items_cab_cpe'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_tbl_items_cab_cpe'
GO
