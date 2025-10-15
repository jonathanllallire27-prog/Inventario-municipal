import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../providers/inventario_provider.dart';

class AgregarEquipoScreen extends StatefulWidget {
  final Equipo? equipo;

  const AgregarEquipoScreen({this.equipo});

  @override
  _AgregarEquipoScreenState createState() => _AgregarEquipoScreenState();
}

class _AgregarEquipoScreenState extends State<AgregarEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _oficinaController = TextEditingController();
  final _tipoController = TextEditingController();
  final _microprocesadorController = TextEditingController();
  final _sistemaOperativoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _memoriaRAMController = TextEditingController();
  final _discoDuroController = TextEditingController();
  final _estadoController = TextEditingController();
  final _monitorController = TextEditingController();
  final _sedeController = TextEditingController();
  final _escanerController = TextEditingController();
  final _impresorasController = TextEditingController();
  final _ipController = TextEditingController();

  String _tipoSeleccionado = 'PC';
  String _estadoSeleccionado = 'BUENO';
  String _sedeSeleccionada = 'PRINCIPAL';
  String _escanerSeleccionado = 'NO';

  final List<String> _tipos = ['PC', 'LAPTOP', 'SERVIDOR'];
  final List<String> _estados = ['BUENO', 'REGULAR', 'MALO'];
  final List<String> _sedes = ['PRINCIPAL', 'SUCURSAL'];
  final List<String> _escaneres = ['SI', 'NO'];
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
    _oficinaController.text = equipo.oficina;
    _tipoSeleccionado = equipo.tipo;
    _microprocesadorController.text = equipo.microprocesador;
    _sistemaOperativoController.text = equipo.sistemaOperativo;
    _marcaController.text = equipo.marca;
    _memoriaRAMController.text = equipo.memoriaRAM;
    _discoDuroController.text = equipo.discoDuro;
    _estadoSeleccionado = equipo.estado;
    _monitorController.text = equipo.monitor;
    _sedeSeleccionada = equipo.sede;
    _escanerSeleccionado = equipo.escaner;
    _impresorasController.text = equipo.impresoras;
    _ipController.text = equipo.ip;
  }

  void _guardarEquipo() {
    if (!_formKey.currentState!.validate()) return;

    final equipo = Equipo(
      id: widget.equipo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      numero: _numeroController.text,
      oficina: _oficinaController.text,
      tipo: _tipoSeleccionado,
      microprocesador: _microprocesadorController.text,
      sistemaOperativo: _sistemaOperativoController.text,
      marca: _marcaController.text,
      memoriaRAM: _memoriaRAMController.text,
      discoDuro: _discoDuroController.text,
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
        SnackBar(
          content: Text('✅ Equipo agregado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _inventarioProvider.editarEquipo(equipo.id, equipo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.equipo == null ? '➕ Agregar Equipo' : '✏️ Editar Equipo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save_outlined),
            onPressed: _guardarEquipo,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información Básica
              _buildSectionHeader('📋 Información Básica'),
              _buildTextField(_numeroController, 'Número',
                  Icons.confirmation_number_outlined),
              SizedBox(height: 16),
              _buildDropdownField(
                value: _oficinaController.text.isEmpty
                    ? null
                    : _oficinaController.text,
                label: 'Oficina',
                icon: Icons.work_outline,
                items: _oficinas,
                onChanged: (value) => _oficinaController.text = value!,
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                value: _tipoSeleccionado,
                label: 'Tipo de Equipo',
                icon: Icons.computer_outlined,
                items: _tipos,
                onChanged: (value) =>
                    setState(() => _tipoSeleccionado = value!),
              ),

              // Especificaciones Técnicas
              SizedBox(height: 24),
              _buildSectionHeader('⚙️ Especificaciones Técnicas'),
              _buildTextField(_microprocesadorController, 'Microprocesador',
                  Icons.memory_outlined),
              SizedBox(height: 16),
              _buildTextField(_sistemaOperativoController, 'Sistema Operativo',
                  Icons.settings_outlined),
              SizedBox(height: 16),
              _buildTextField(
                  _marcaController, 'Marca', Icons.branding_watermark_outlined),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_memoriaRAMController, 'Memoria RAM',
                        Icons.memory_outlined),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(_discoDuroController, 'Disco Duro',
                        Icons.storage_outlined),
                  ),
                ],
              ),

              // Estado y Ubicación
              SizedBox(height: 24),
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
                  SizedBox(width: 16),
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
              SizedBox(height: 16),
              _buildTextField(
                  _monitorController, 'Monitor', Icons.monitor_outlined),

              // Periféricos y Red
              SizedBox(height: 24),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                        _ipController, 'Dirección IP', Icons.language_outlined),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField(_impresorasController, 'Impresoras/Periféricos',
                  Icons.print_outlined),

              // Botón Guardar
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0D47A1).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
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
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        widget.equipo == null
                            ? 'AGREGAR EQUIPO'
                            : 'ACTUALIZAR EQUIPO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF0D47A1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF0D47A1).withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: TextStyle(
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
        prefixIcon: Icon(icon, color: Color(0xFF0D47A1)),
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
          borderSide: BorderSide(color: Color(0xFF0D47A1), width: 2),
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
    required String? value,
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
          prefixIcon: Icon(icon, color: Color(0xFF0D47A1)),
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
            borderSide: BorderSide(color: Color(0xFF0D47A1), width: 2),
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
    _oficinaController.dispose();
    _microprocesadorController.dispose();
    _sistemaOperativoController.dispose();
    _marcaController.dispose();
    _memoriaRAMController.dispose();
    _discoDuroController.dispose();
    _monitorController.dispose();
    _impresorasController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
