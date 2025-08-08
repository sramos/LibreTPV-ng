Vat.create([
  { name: 'IVA general (21%)', rate: 0.21 },
  { name: 'IVA reducido (10%)', rate: 0.10 },
  { name: 'IVA superreducido (4%)', rate: 0.04 },
  { name: 'Sin IVA (0%)', rate: 0.00 }
]) if Vat.count == 0

ProductType.create([
  { name: 'Libros', vat: Vat.find_by(rate: 0.04) },
  { name: 'Entradas', vat: Vat.find_by(rate: 0.21) },
  { name: 'Revistas/Periódicos', vat: Vat.find_by(rate: 0.04) },
  { name: 'Material Escolar', vat: Vat.find_by(rate: 0.04) },
  { name: 'Papelería', vat: Vat.find_by(rate: 0.21) }
]) if ProductType.count == 0

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
