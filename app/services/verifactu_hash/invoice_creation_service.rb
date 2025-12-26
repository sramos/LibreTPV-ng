class VerifactuHash::InvoiceCreationService < VerifactuHashService

  private
  # Fields incluided in invoice creation hash:
  #  * IDEmisorFactura (IDFactura/IDEmisorFactura)
  #  * NumSerieFactura (IDFactura/NumSerieFactura)
  #  * FechaExpedicionFactura (IDFactura/FechaExpedicionFactura)
  #  * TipoFactura (TipoFactura)
  #  * CuotaTotal (CuotaTotal)
  #  * ImporteTotal (ImporteTotal)
  #  * Huella (RegistroAnterior/Huella)
  #  * FechaHoraHusoGenRegistro (FechaHoraHusoGenRegistro)
  def complete_included_fields(emisor_code, invoice, previous_hash)
    @included_fields['IDEmisorFactura'] = emisor_code
    @included_fields['NumSerieFactura'] = invoice.code
    @included_fields['FechaExpedicionFactura'] = invoice.date.strftime('%d-%m-%Y')
    @included_fields['TipoFactura'] = invoice.type_code
    @included_fields['CuotaTotal'] = invoice.total_vat
    @included_fields['ImporteTotal'] = invoice.total_amount
    @included_fields['Huella'] = previous_hash || ''
    @included_fields['FechaHoraHusoGenRegistro'] = invoice.created_at.strftime('%Y-%m-%dT%H:%M:%SZ')
  end  
end