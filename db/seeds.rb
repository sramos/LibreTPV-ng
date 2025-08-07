Vat.create([
    {name: "IVA general (21%)", rate: 0.21},
    {name: "IVA reducido (10%)", rate: 0.10},
    {name: "IVA superreducido (4%)", rate: 0.04},
    {name: "Sin IVA (0%)", rate: 0.00}
]) if Vat.count == 0

ProductType.create([
    { name: 'Libros', vat: Vat.find_by_rate(0.04) },
    { name: 'Entradas', vat: Vat.find_by_rate(0.21) },
    { name: 'Revistas/Periódicos', vat: Vat.find_by_rate(0.04) },
    { name: 'Material Escolar', vat: Vat.find_by_rate(0.04) },
    { name: 'Papelería', vat: Vat.find_by_rate(0.21) }
]) if ProductType.count == 0

PaymentType.create([
    { name: 'Efectivo', cash: true},
    { name: 'Tarjeta', cash: false},
    { name: 'Transferencia', cash: false },
    { name: 'Domiciliacion', cash: false }
]) if PaymentType.count == 0

Supplier.create([
    { name: 'Timadores Sin Fronteras', code_id: 'A-88554345-J', discount: 0.30 }
]) if Supplier.count == 0

Client.create([
    { name: 'Caja 1', code_id: 'N/A', discount: 0.00 }
]) if Client.count == 0

