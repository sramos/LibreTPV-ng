class VerifactuHashService < ApplicationService
  # From: https://www.agenciatributaria.es/static_files/AEAT_Desarrolladores/EEDD/IVA/VERI-FACTU/Veri-Factu_especificaciones_huella_hash_registros.pdf

  def call(emisor_code, object, previous_hash)
    @included_fields = {}
    complete_included_fields(emisor_code, object, previous_hash)
    return success(generate_code)
  rescue => e
    failure(e)
  end

  private

  def generate_code
    included_fields_string = @included_fields.map { |field, value| "#{field}=#{value}" }.join("&")
    Rails.logger.info "[VerifactuHashService.generate_code] Generando codigo para los campos " + included_fields_string
    output = Digest::SHA256.hexdigest(included_fields_string) unless included_fields_string.blank?
    Rails.logger.info "[VerifactuHashService.generate_code] Hash generado: #{output}"
    return output
  end
end
