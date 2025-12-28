# Especificaciones Verifactu

## Reglamento Verifactu

https://sede.agenciatributaria.gob.es/Sede/iva/sistemas-informaticos-facturacion-verifactu/cuestiones-generales.html

  * SIF. Especificaciones técnicas y funcionales: https://sede.agenciatributaria.gob.es/Sede/iva/sistemas-informaticos-facturacion-verifactu.html

BOE:

  * Reglamento de facturación Noviembre 2012: https://www.boe.es/eli/es/rd/2012/11/30/1619/con
  * Aprobación del reglamento Diciembre 2023: https://www.boe.es/eli/es/rd/2023/12/05/1007
  * Modificación plazos Abril 2025: https://www.boe.es/eli/es/rd/2025/04/01/254
  * Modificación plazos Diciembre 2025: https://www.boe.es/eli/es/rd/2025/12/18/266

### Facturas según reglamento 2012

  * Factura simplificada cuando
    * importe < 400 eur. (iva incluido).
    * importe < 3000 eur. (iva incluido) y venta al por menor -a particulares-.

  * Contenido:
    * Número de factura (correlativo).
    * Fecha de expedición.
    * Razón social completa, NIF y domicilio fiscal de emisor.
    * Razón social completa, NIF y domicilio fiscal del destinatario (para facturas complestas).
    * Conceptos (descripción general de las operaciones).
    * Importe total.
    * Bases imponibles y tipos impositivos.
    * Indicar "Duplicado" (en el caso de duplicación de factura).
    * QR (sea simplificada o no). En las electrónicas, puede sustituirse el QR por el contenido (URL de validación).

  * Factura rectificativa cuando se modifican las cuotas impositivas de una factura (por ejemplo, devolución de artículos). Si la devolución implica una compra nueva, no es necesaria una rectificativa, sino que puede incluirse en la nueva factura.

  * La factura rectificativa debe indicar la información de la factura rectificada.

  * Las facturas electrónicas deben estar firmadas de acuerdo al artículo 2.2 de la directiva 1999/93/CE de 13 diciembre de 1999 de firma electrónica.

### Registros de facturación:

Son registros XML con los siguientes campos:

  * Identificación del software: Nombre, versión y fabricante del programa.
  * Datos del emisor: NIF, razón social, domicilio fiscal.
  * Datos del receptor: NIF, razón social, domicilio fiscal.)
  * Número de factura.
  * Fecha de expedición de la factura.
  * Tipo de factura (completa, simplificada, rectificativa).
  * Si la factura es rectificativa, indicación del tipo, características e identificación de las facturas rectificadas.
  * Descripción general de las operaciones.
  * Importe total.
  * Bases imponibles y tipos impositivos.
  * Indicacioń de si el destinatario es sujeto pasivo del IVA.
  * HASH del registro previo.
  * Código del SIS y otrso datos adicionales.
  * Fecha, hora, minuto y segundo del registro de facturación.

Ejemplo XML:

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:sum="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroL
R.xsd"
xmlns:sum1="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/Suministro
Informacion.xsd">
  <soapenv:Header/>
  <soapenv:Body>
    <sum:AltaFactuSistemaFacturacion>
      <sum1:Cabecera>
        <sum1:IDVersion>1.0</sum1:IDVersion>
        <sum1:ObligadoEmision>
          <sum1:NombreRazon>Empresa VeriFactu</sum1:NombreRazon>
          <sum1:NIF>NIF</sum1:NIF>
        </sum1:ObligadoEmision>
        <sum1:TipoRegistroAEAT>T0</sum1:TipoRegistroAEAT>
      </sum1:Cabecera>
      <sum:RegistroAltaFacturas>
        <sum:RegistroFacturacion>
          <sum1:IDFactura>
            <sum1:IDEmisorFactura>
              <sum1:NIF>NIF</sum1:NIF>
            </sum1:IDEmisorFactura>
            <sum1:NumSerieFacturaEmisor>12345</sum1:NumSerieFacturaEmisor>
            <sum1:FechaExpedicionFacturaEmisor>13-11-2023</sum1:FechaExpedicionFacturaEmisor>
          </sum1:IDFactura>
          <sum1:NombreRazonEmisor>certificado uno telematicas</sum1:NombreRazonEmisor>
          <sum1:TipoRegistroSIF>S0</sum1:TipoRegistroSIF>
          <sum1:TipoFactura>F1</sum1:TipoFactura>
          <sum1:DescripcionOperacion>Descripc</sum1:DescripcionOperacion>
          <sum1:Destinatarios>
            <sum1:IDDestinatario>
              <sum1:NombreRazon>Empresa VeriFactu</sum1:NombreRazon>
              <sum1:NIF>NIF</sum1:NIF>
            </sum1:IDDestinatario>
          </sum1:Destinatarios>
          <sum1:Desglose>
            <sum1:DetalleDesglose>
              <sum1:ClaveRegimen>01</sum1:ClaveRegimen>
              <sum1:CalificacionOperacion>S1</sum1:CalificacionOperacion>
              <sum1:TipoImpositivo>4</sum1:TipoImpositivo>
              <sum1:BaseImponibleOimporteNoSujeto>10</sum1:BaseImponibleOimporteNoSujeto>
              <sum1:CuotaRepercutida>0.4</sum1:CuotaRepercutida>
            </sum1:DetalleDesglose>
            <sum1:DetalleDesglose>
              <sum1:ClaveRegimen>01</sum1:ClaveRegimen>
              <sum1:CalificacionOperacion>S1</sum1:CalificacionOperacion>
              <sum1:TipoImpositivo>21</sum1:TipoImpositivo>
              <sum1:BaseImponibleOimporteNoSujeto>100</sum1:BaseImponibleOimporteNoSujeto>
              <sum1:CuotaRepercutida>21</sum1:CuotaRepercutida>
            </sum1:DetalleDesglose>
          </sum1:Desglose>
          <sum1:ImporteTotal>131.4</sum1:ImporteTotal>
          <sum1:EncadenamientoRegistroAnterior>
            <sum1:IDEmisorFacturaRegistroAnterior>
              <sum1:NIF>NIF</sum1:NIF>
            </sum1:IDEmisorFacturaRegistroAnterior>
            <sum1:NumSerieFacturaRegistroAnterior>44</sum1:NumSerieFacturaRegistroAnterior>
            <sum1:FechaExpedicionFacturaRegistroAnterior>13-02-2022</sum1:FechaExpedicionFacturaRegistroAnterior>
            <sum1:HuellaRegistroAnterior>HuellaRegistroAnterior</sum1:HuellaRegistroAnterior>
          </sum1:EncadenamientoRegistroAnterior>
          <sum1:SistemaInformatico>
            <sum1:NombreRazon>CERTIFICADO DOS TELEMATICAS</sum1:NombreRazon>
            <sum1:NIF>NIF</sum1:NIF>
            <sum1:NombreSistemaInformatico>NombreSistemaInformatico</sum1:NombreSistemaInformatico>
            <sum1:IdSistemaInformatico>77</sum1:IdSistemaInformatico>
            <sum1:Version>1.0.03</sum1:Version>
            <sum1:NumeroInstalacion>383</sum1:NumeroInstalacion>
            <sum1:TipoUsoPosibleSoloVerifactu>S</sum1:TipoUsoPosibleSoloVerifactu>
            <sum1:TipoUsoPosibleOtros>N</sum1:TipoUsoPosibleOtros>
            <sum1:TipoUsoPosibleMultiOT>N</sum1:TipoUsoPosibleMultiOT>
          </sum1:SistemaInformatico>
          <sum1:FechaGenRegistro>13-11-2023</sum1:FechaGenRegistro>
          <sum1:HoraGenRegistro>20:59:25</sum1:HoraGenRegistro>
          <sum1:HusoHorarioGenRegistro>02</sum1:HusoHorarioGenRegistro>
        </sum:RegistroFacturacion>
        <sum:DatosControl>
          <sum1:Huella>Huella</sum1:Huella>
          <sum1:TipoHash>01</sum1:TipoHash>
        </sum:DatosControl>
      </sum:RegistroAltaFacturas>
    </sum:AltaFactuSistemaFacturacion>
  </soapenv:Body>
</soapenv:Envelope>
```
  
### Requisitos SIF:

  * Integridad e inalterabilidad
  * Trazabilidad
  * Conservación, accesibilidad y legibilidad (cuando no funcionen en modo Verifactu)
  * Registro de eventos (cuando no funcionen en modo Verifactu)

### Cálculo del Hash (según especificaciones SIF)

https://sede.agenciatributaria.gob.es/Sede/iva/sistemas-informaticos-facturacion-verifactu/informacion-tecnica/algoritmo-calculo-codificacion-huella-hash.html

### URLs para la emisión de facturas

https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tikeV1.0/cont/ws/SistemaFacturacion.wsdl

```xml
<wsdl:service name="sfVerifactu">
<!--
  Sistemas que emiten facturas verificables. Entorno de PRODUCCION 
-->
<wsdl:port name="SistemaVerifactu" binding="sfWdsl:sfVerifactu">
<soap:address location="https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"/>
</wsdl:port>
<!--
  Sistemas que emiten facturas verificables. Entorno de PRODUCCION para acceso con certificado de sello 
-->
<wsdl:port name="SistemaVerifactuSello" binding="sfWdsl:sfVerifactu">
<soap:address location="https://www10.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"/>
</wsdl:port>
<!--
  Sistemas que emiten facturas verificables. Entorno de PRUEBAS 
-->
<wsdl:port name="SistemaVerifactuPruebas" binding="sfWdsl:sfVerifactu">
<soap:address location="https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"/>
</wsdl:port>
<!--
  Sistemas que emiten facturas verificables. Entorno de PRUEBAS para acceso con certificado de sello 
-->
<wsdl:port name="SistemaVerifactuSelloPruebas" binding="sfWdsl:sfVerifactu">
<soap:address location="https://prewww10.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"/>
</wsdl:port>
</wsdl:service>
<wsdl:service name="sfRequerimiento">
<!--
 Sistemas que emiten facturas NO verificables. (Remision bajo requerimiento). Entorno de PRODUCCION 
-->
<wsdl:port name="SistemaRequerimiento" binding="sfWdsl:sfRequerimiento">
<soap:address location="https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/RequerimientoSOAP"/>
</wsdl:port>
<!--
 Sistemas que emiten facturas NO verificables. (Remision bajo requerimiento). Entorno de PRODUCCION para acceso con certificado de sello 
-->
<wsdl:port name="SistemaRequerimientoSello" binding="sfWdsl:sfRequerimiento">
<soap:address location="https://www10.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/RequerimientoSOAP"/>
</wsdl:port>
<!--
 Sistemas que emiten facturas NO verificables. (Remision bajo requerimiento). Entorno de PRUEBAS 
-->
<wsdl:port name="SistemaRequerimientoPruebas" binding="sfWdsl:sfRequerimiento">
<soap:address location="https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/RequerimientoSOAP"/>
</wsdl:port>
<!--
 Sistemas que emiten facturas NO verificables. (Remision bajo requerimiento). Entorno de PRUEBAS para acceso con certificado de sello 
-->
<wsdl:port name="SistemaRequerimientoSelloPruebas" binding="sfWdsl:sfRequerimiento">
<soap:address location="https://prewww10.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/RequerimientoSOAP"/>
</wsdl:port>
```

### Certificados de sello para apps

  * https://www.cert.fnmt.es/componente/sello-entidad

## Declaración responsable

### Ejemplos

  * https://github.com/mdiago/VeriFactu/blob/main/NetFramework/Doc/Legal/Declaracion%20Responsable%20API%20REST-last-version.pdf
  * https://sede.agenciatributaria.gob.es/static_files/Sede/Tema/IVA/Verifactu/EjemplosDeclaracionResponsable(V0.5.1).pdf

## Otros proyectos Verifactu

  * Gema ruby: https://github.com/mybooking-es/verifactu-rb
  * Para C#, pero los ejemplos son interesantes: https://github.com/mdiago/VeriFactu

