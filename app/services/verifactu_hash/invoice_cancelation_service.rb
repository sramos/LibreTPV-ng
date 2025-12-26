class VerifactuHash::InvoiceCancelationService < VerifactuHashService

  private
  # Fields incluided in invoice cancelation hash:
  #  * IDEmisorFacturaAnulada (IDFactura/IDEmisorFacturaAnulada)
  #  * NumSerieFacturaAnulada (IDFactura/NumSerieFacturaAnulada)
  #  * FechaExpedicionFacturaAnulada (IDFactura/FechaExpedicionFacturaAnulada)
  #  * Huella (RegistroAnterior/Huella)
  #  * FechaHoraHusoGenRegistro (FechaHoraHusoGenRegistro)
  def complete_included_fields(emisor_code, invoice, previous_hash)
    @included_fields['IDEmisorFacturaAnulada'] = emisor_code
    @included_fields['NumSerieFacturaAnulada'] = invoice.code
    @included_fields['FechaExpedicionFacturaAnulada'] = invoice.date.strftime('%d-%m-%Y')
    @included_fields['Huella'] = previous_hash || ''
    @included_fields['FechaHoraHusoGenRegistro'] = invoice.created_at.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
end