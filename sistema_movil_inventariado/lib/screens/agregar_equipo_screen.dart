import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../providers/inventario_provider.dart';

class AgregarEquipoScreen extends StatefulWidget {
  final Equipo? equipo;

  const AgregarEquipoScreen({super.key, this.equipo});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarEquipoScreenState createState() => _AgregarEquipoScreenState();
}

class _AgregarEquipoScreenState extends State<AgregarEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _monitorController = TextEditingController();
  final _impresorasController = TextEditingController();
  final _ipController = TextEditingController();

  String _tipoSeleccionado = 'PC';
  String _estadoSeleccionado = 'BUENO';
  String _sedeSeleccionada = 'PRINCIPAL';
  String _escanerSeleccionado = 'NO';
  String _microprocesadorSeleccionado = 'Intel Core i3';
  String _sistemaOperativoSeleccionado = 'Windows 10';
  String _marcaSeleccionada = 'HP';
  String _memoriaRAMSeleccionada = '8 GB';
  String _discoDuroSeleccionado = '500 GB HDD';
  String _oficinaSeleccionada = 'CATASTRO';

  final List<String> _tipos = ['PC', 'LAPTOP', 'SERVIDOR'];
  final List<String> _estados = ['BUENO', 'REGULAR', 'MALO'];
  final List<String> _sedes = ['PRINCIPAL', 'SUCURSAL'];
  final List<String> _escaneres = ['SI', 'NO'];

  // Lista de procesadores actualizados
  final List<String> _microprocesadores = [
    'Intel Core i3',
    'Intel Core i5',
    'Intel Core i7',
    'Intel Core i9',
    'Intel Xeon',
    'AMD Ryzen 3',
    'AMD Ryzen 5',
    'AMD Ryzen 7',
    'AMD Ryzen 9',
    'AMD EPYC',
    'Apple M1',
    'Apple M2',
    'Apple M3',
    'Otro'
  ];

  // Lista de sistemas operativos
  final List<String> _sistemasOperativos = [
    'Windows 10',
    'Windows 11',
    'Windows 8.1',
    'Windows 7',
    'Linux Ubuntu',
    'Linux Debian',
    'Linux CentOS',
    'macOS',
    'Sin Sistema Operativo'
  ];

  // Lista de marcas
  final List<String> _marcas = [
    'HP',
    'Dell',
    'Lenovo',
    'Apple',
    'Asus',
    'Acer',
    'Toshiba',
    'Sony',
    'Samsung',
    'Otro'
  ];

  // Lista de memorias RAM
  final List<String> _memoriasRAM = [
    '2 GB',
    '4 GB',
    '8 GB',
    '16 GB',
    '32 GB',
    '64 GB',
    '128 GB'
  ];

  // Lista de discos duros - CORREGIDO: agregado '500 GB HDD'
  final List<String> _discosDuros = [
    '128 GB SSD',
    '256 GB SSD',
    '500 GB HDD', // Agregado este valor
    '512 GB SSD',
    '1 TB HDD',
    '1 TB SSD',
    '2 TB HDD',
    '2 TB SSD',
    '4 TB HDD',
    '4 TB SSD'
  ];

  final List<String> _oficinas = [
    'CATASTRO',
    'PROCURADURÍA PÚBLICA MUNICIPAL',
    'ASESORIA JURIDICA',
    'INFRAESTRUCTURA',
    'PAD',
    'RECURSOS HUMANOS',
    'ABASTECIMIENTO',
    'PROGRAMA VASO DE LECHE (PVL)',
    'PATRIMONIO',
    'SUPERVISIÓN Y LIQUIDACIÓN',
    'UNIDAD DE TESORERIA Y CAJA',
    'TRANSPORTE',
    'SERVICIOS Y PROGRAMA SOCIAL',
    'DESARROLLO ECONOMICO SOCIAL',
    'CONTABILIDAD Y ADMINIST',
    'PRESUPUESTO',
    'ADMINISTRACIÓN',
    'DEMUNA',
    'DEFENSA CIVIL',
    'IMAGEN',
    'RENTA',
    'MESA DE PARTES',
    'ADMINISTRACIÓN TRIBUTARIA',
    'COACTIVO',
    'SERVICIOS MUNICIPALES',
    'SIAM',
    'OMAPED',
    'SISFO',
    'CAJA',
    'ARCHIVOS',
    'REGISTRO CIVIL',
    'SECRETARIA GENERAL',
    'GERENCIA GENERAL',
    'OFICINA DE IMAGEN INSTITUCIONAL',
    'AREA DE INFORMATICA',
  ];

  final InventarioProvider _inventarioProvider = InventarioProvider();

  @override
  void initState() {
    super.initState();
    if (widget.equipo != null) {
      _cargarDatosEquipo();
    }
  }

  void _cargarDatosEquipo() {
    final equipo = widget.equipo!;
    _numeroController.text = equipo.numero;
    _oficinaSeleccionada = equipo.oficina;
    _tipoSeleccionado = equipo.tipo;
    _microprocesadorSeleccionado = equipo.microprocesador;
    _sistemaOperativoSeleccionado = equipo.sistemaOperativo;
    _marcaSeleccionada = equipo.marca;
    _memoriaRAMSeleccionada = equipo.memoriaRAM;
    _discoDuroSeleccionado = equipo.discoDuro;
    _estadoSeleccionado = equipo.estado;
    _monitorController.text = equipo.monitor;
    _sedeSeleccionada = equipo.sede;
    _escanerSeleccionado = equipo.escaner;
    _impresorasController.text = equipo.impresoras;
    _ipController.text = equipo.ip;

    // Validar que los valores existan en las listas
    _validarYCorregirValores();
  }

  void _validarYCorregirValores() {
    // Validar microprocesador
    if (!_microprocesadores.contains(_microprocesadorSeleccionado)) {
      _microprocesadorSeleccionado = 'Intel Core i3';
    }

    // Validar sistema operativo
    if (!_sistemasOperativos.contains(_sistemaOperativoSeleccionado)) {
      _sistemaOperativoSeleccionado = 'Windows 10';
    }

    // Validar marca
    if (!_marcas.contains(_marcaSeleccionada)) {
      _marcaSeleccionada = 'HP';
    }

    // Validar memoria RAM
    if (!_memoriasRAM.contains(_memoriaRAMSeleccionada)) {
      _memoriaRAMSeleccionada = '8 GB';
    }

    // Validar disco duro
    if (!_discosDuros.contains(_discoDuroSeleccionado)) {
      _discoDuroSeleccionado = '500 GB HDD';
    }

    // Validar oficina
    if (!_oficinas.contains(_oficinaSeleccionada)) {
      _oficinaSeleccionada = 'CATASTRO';
    }
  }

  void _guardarEquipo() {
    if (!_formKey.currentState!.validate()) return;

    final equipo = Equipo(
      id: widget.equipo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      numero: _numeroController.text,
      oficina: _oficinaSeleccionada,
      tipo: _tipoSeleccionado,
      microprocesador: _microprocesadorSeleccionado,
      sistemaOperativo: _sistemaOperativoSeleccionado,
      marca: _marcaSeleccionada,
      memoriaRAM: _memoriaRAMSeleccionada,
      discoDuro: _discoDuroSeleccionado,
      estado: _estadoSeleccionado,
      monitor: _monitorController.text,
      sede: _sedeSeleccionada,
      escaner: _escanerSeleccionado,
      impresoras: _impresorasController.text,
      ip: _ipController.text,
    );

    if (widget.equipo == null) {
      _inventarioProvider.agregarEquipo(equipo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Equipo agregado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _inventarioProvider.editarEquipo(equipo.id, equipo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Equipo actualizado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.equipo == null ? '➕ Agregar Equipo' : '✏️ Editar Equipo',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _guardarEquipo,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información Básica
              _buildSectionHeader('📋 Información Básica'),
              _buildTextField(_numeroController, 'Número',
                  Icons.confirmation_number_outlined),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _oficinaSeleccionada,
                label: 'Oficina',
                icon: Icons.work_outline,
                items: _oficinas,
                onChanged: (value) =>
                    setState(() => _oficinaSeleccionada = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _tipoSeleccionado,
                label: 'Tipo de Equipo',
                icon: Icons.computer_outlined,
                items: _tipos,
                onChanged: (value) =>
                    setState(() => _tipoSeleccionado = value!),
              ),

              // Especificaciones Técnicas
              const SizedBox(height: 24),
              _buildSectionHeader('⚙️ Especificaciones Técnicas'),
              _buildDropdownField(
                value: _microprocesadorSeleccionado,
                label: 'Microprocesador',
                icon: Icons.memory_outlined,
                items: _microprocesadores,
                onChanged: (value) =>
                    setState(() => _microprocesadorSeleccionado = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _sistemaOperativoSeleccionado,
                label: 'Sistema Operativo',
                icon: Icons.settings_outlined,
                items: _sistemasOperativos,
                onChanged: (value) =>
                    setState(() => _sistemaOperativoSeleccionado = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _marcaSeleccionada,
                label: 'Marca',
                icon: Icons.branding_watermark_outlined,
                items: _marcas,
                onChanged: (value) =>
                    setState(() => _marcaSeleccionada = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      value: _memoriaRAMSeleccionada,
                      label: 'Memoria RAM',
                      icon: Icons.memory_outlined,
                      items: _memoriasRAM,
                      onChanged: (value) =>
                          setState(() => _memoriaRAMSeleccionada = value!),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _buildDropdownField(
                      value: _discoDuroSeleccionado,
                      label: 'Disco Duro',
                      icon: Icons.storage_outlined,
                      items: _discosDuros,
                      onChanged: (value) =>
                          setState(() => _discoDuroSeleccionado = value!),
                    ),
                  ),
                ],
              ),

              // Estado y Ubicación
              const SizedBox(height: 24),
              _buildSectionHeader('📍 Estado y Ubicación'),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      value: _estadoSeleccionado,
                      label: 'Estado',
                      icon: Icons.info_outline,
                      items: _estados,
                      onChanged: (value) =>
                          setState(() => _estadoSeleccionado = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      value: _sedeSeleccionada,
                      label: 'Sede',
                      icon: Icons.location_city_outlined,
                      items: _sedes,
                      onChanged: (value) =>
                          setState(() => _sedeSeleccionada = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  _monitorController, 'Monitor', Icons.monitor_outlined),

              // Periféricos y Red
              const SizedBox(height: 24),
              _buildSectionHeader('🖨️ Periféricos y Red'),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      value: _escanerSeleccionado,
                      label: 'Escáner',
                      icon: Icons.scanner_outlined,
                      items: _escaneres,
                      onChanged: (value) =>
                          setState(() => _escanerSeleccionado = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                        _ipController, 'Dirección IP', Icons.language_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_impresorasController, 'Impresoras/Periféricos',
                  Icons.print_outlined),

              // Botón Guardar
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _guardarEquipo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.equipo == null
                            ? 'AGREGAR EQUIPO'
                            : 'ACTUALIZAR EQUIPO',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _monitorController.dispose();
    _impresorasController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
