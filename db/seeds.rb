User.create([
  { name: 'Admin', email: 'admin@libreriaejemplo.com',
    password: 'password', password_confirmation: 'password',
    active: true }
]) if User.count == 0

if UserAccess.count == 0 && (user = User.find_by(email: 'admin@libreriaejemplo.com'))
  UserAccess.create([
    { section: 'sales', user: user },
    { section: 'products', user: user },
    { section: 'distributor', user: user},
    { section: 'accounting', user: user },
    { section: 'admin', user: user }
  ])
end

Vat.create([
  { name: 'IVA general (21%)', rate: 0.21 },
  { name: 'IVA reducido (10%)', rate: 0.10 },
  { name: 'IVA superreducido (4%)', rate: 0.04 },
  { name: 'Sin IVA (0%)', rate: 0.00 }
]) if Vat.count == 0

PaymentType.create([
  { name: 'Efectivo', cash: true },
  { name: 'Tarjeta', cash: false },
  { name: 'Transferencia', cash: false },
  { name: 'Domiciliacion', cash: false }
]) if PaymentType.count == 0

Supplier.create([
  { name: 'Timadores Sin Fronteras', code_id: 'A-88554345-J', discount: 0.30 }
]) if Supplier.count == 0

Client.create([
  { name: 'Caja 1', code_id: 'N/A', discount: 0.00 }
]) if Client.count == 0

ProductType.create([
  { name: 'Libros', vat: Vat.find_by(rate: 0.04) },
  { name: 'Entradas', vat: Vat.find_by(rate: 0.21) },
  { name: 'Revistas/Periódicos', vat: Vat.find_by(rate: 0.04) },
  { name: 'Material Escolar', vat: Vat.find_by(rate: 0.04) },
  { name: 'Papelería', vat: Vat.find_by(rate: 0.21) }
]) if ProductType.count == 0

if ProductSubtype.count == 0
  product_type_id = ProductType.find_by(name: 'Libros').id
  ProductSubtype.create([
    { name: 'Cómic', product_type_id: product_type_id },
    { name: 'Cuentos', product_type_id: product_type_id },
    { name: 'Formación/Materias', product_type_id: product_type_id },
    { name: 'Libros para colorear', product_type_id: product_type_id },
    { name: 'Literatura clásica', product_type_id: product_type_id },
    { name: 'Narrativa', product_type_id: product_type_id },
    { name: 'Narrativa breve', product_type_id: product_type_id },
    { name: 'Narrativa de humor', product_type_id: product_type_id },
    { name: 'Narrativa erótica', product_type_id: product_type_id },
    { name: 'Narrativa fantástica', product_type_id: product_type_id },
    { name: 'Narrativa histórica', product_type_id: product_type_id },
    { name: 'Narrativa idiomas', product_type_id: product_type_id },
    { name: 'Narrativa infantil', product_type_id: product_type_id },
    { name: 'Narrativa juvenil', product_type_id: product_type_id },
    { name: 'Narrativa romántica', product_type_id: product_type_id },
    { name: 'Narrativa terror', product_type_id: product_type_id },
    { name: 'Narrativa viajes', product_type_id: product_type_id },
    { name: 'Novela gráfica', product_type_id: product_type_id },
    { name: 'Novela negra', product_type_id: product_type_id },
    { name: 'Poesía', product_type_id: product_type_id },
    { name: 'Segunda mano', product_type_id: product_type_id },
    { name: 'Teatro', product_type_id: product_type_id },
    { name: 'Viajes', product_type_id: product_type_id },
    { name: 'Ensayo', product_type_id: product_type_id }
  ])
end

configs = [
  { name: 'ALLWAYS_PRINT_TICKET', value: 'TRUE' },
  { name: 'COMPANY_SHORT_NAME', value: 'Librería de ejemplo' },
  { name: 'COMPANY_FULL_NAME', value: 'Librería asociativa de ejemplo' },
  { name: 'COMPANY_ADDRESS', value: 'Calle de ejemplo, 123' },
  { name: 'COMPANY_POSTAL_CODE', value: '28053 Madrid' },
  { name: 'COMPANY_PHONE', value: '+34 912 345 678' },
  { name: 'COMPANY_EMAIL', value: 'contact@libreriaejemplo.com' },
  { name: 'COMPANY_LOGO_FOR_TICKET', value: 'storage/ticket_logo.png' },
  { name: 'COMPANY_LOGO_FOR_PDF', value: 'storage/logo.png' },
  { name: 'COMPANY_FISCAL_CODE', value: '88554345J' },
  { name: 'COMPANY_INVOICES_PREFIX', value: 'LIB/2025-' },
  { name: 'COMPANY_INVOICES_COUNT', value: '0' },
  { name: 'PAGINATE', value: '25' },
  { name: 'PRINTER_NAME', value: 'TM-T70' },
  { name: 'VERIFACTU_ENABLED', value: 'FALSE' },
  { name: 'VERIFACTU_API_KEY', value: '' },
  { name: 'VERIFACTU_API_SECRET', value: '' },
  # Entorno de produccion
  #{ name: 'VERIFACTU_API_URL', value: 'https://www1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP' },
  # Entorno de pruebas
  { name: 'VERIFACTU_API_URL', value: 'https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP' },
]

configs.each do |config|
  new_config = Config.create(config) if Config.find_by(name: config[:name]).blank?
  puts "[Seed] New config created: " + new_config.inspect if new_config
end
