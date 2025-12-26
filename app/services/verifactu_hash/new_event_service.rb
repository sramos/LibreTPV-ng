class VerifactuHash::NewEventService < VerifactuHashService

  private
  # Fields incluided in new event hash:
  #  * NIF (SistemaInformatico/NIF)
  #  * ID (SistemaInformation/IDOtro/ID)
  #  * IdSistemaInformatico (SistamInformatico/IdSistemaInformatico)
  #  * Version (SistemaInformatico/Version)
  #  * NumeroInstalacion (SistemaInformatico/NumeroInstalacion)
  #  * NIF (ObligadoEmision/NIF)
  #  * ImporteTotal (Evento/TipoEvento)
  #  * HuellaEvento (EventoAnterior/HuellaEvento)
  #  * FechaHoraHusoGenRegistro (Evento/FechaHoraHusoGenRegistro)
  def complete_included_fields(emisor_code, object, previous_hash)
    @included_fields['SystemNIF'] = Config.get_value('SYSTEM_NIF')
    @included_fields['ID'] = Config.get_value('SYSTEM_ID')
    @included_fields['FechaExpedicionFactura'] = invoice.date.strftime('%d-%m-%Y')
    @included_fields['TipoFactura'] = invoice.type_code
    @included_fields['CuotaTotal'] = invoice.vat
    @included_fields['ImporteTotal'] = invoice.total_amount
    @included_fields['Huella'] = previous_hash || ''
    @included_fields['FechaHoraHusoGenRegistro'] = object.created_at.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
 
  @included_fields = {
    'NIF' => nil,
    'ID' => nil,
    'IdSistemaInformatico' => nil,
    'Version' => nil,
    'NumeroInstalacion' => nil,
    'NIF' => nil,
    'TipoEvento' => nil,
    'HuellaEvento' => nil,
    'FechaHoraHusoGenRegistro' => nil
  }
end