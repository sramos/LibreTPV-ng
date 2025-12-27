class VerifactuHash::NewEventService < VerifactuHashService

  private
  # Fields incluided in new event hash:
  #  * SystemNIF (from SYSTEM_NIF config)
  #  * ID (from SYSTEM_ID config)
  #  * FechaHoraHusoGenRegistro (from object.created_at)
  #  * Huella (from previous_hash)
  def complete_included_fields(emisor_code, object, previous_hash)
    @included_fields['SystemNIF'] = Config.value('SYSTEM_NIF')
    @included_fields['ID'] = Config.value('SYSTEM_ID')
    @included_fields['Huella'] = previous_hash || ''
    @included_fields['FechaHoraHusoGenRegistro'] = object.created_at.strftime('%Y-%m-%dT%H:%M:%SZ')
  end
end