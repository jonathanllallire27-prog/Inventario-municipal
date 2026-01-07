import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/equipo.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AgregarEquipoScreen extends StatefulWidget {
  final Equipo? equipo;

  const AgregarEquipoScreen({super.key, this.equipo});

  @override
  State<AgregarEquipoScreen> createState() => _AgregarEquipoScreenState();
}

class _AgregarEquipoScreenState extends State<AgregarEquipoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controladores para campos de texto libre
  late TextEditingController _numeroController;
  late TextEditingController _microprocesadorController;
  late TextEditingController _monitorController;
  late TextEditingController _impresorasController;
  late TextEditingController _ipController;

  // Valores para dropdowns
  String _tipoSeleccionado = 'PC';
  String _estadoSeleccionado = 'BUENO';
  String _oficinaSeleccionada = 'Informática';
  String _sistemaOperativoSeleccionado = 'Windows 11 Pro';
  String _marcaSeleccionada = 'HP';
  String _memoriaRAMSeleccionada = '8 GB';
  String _discoDuroSeleccionado = '500 GB HDD';
  String _sedeSeleccionada = 'PRINCIPAL';
  String _escanerSeleccionado = 'NO';

  // Opciones para dropdowns - DEBEN coincidir con los CHECK constraints de PostgreSQL
  final List<String> _tipos = ['PC', 'LAPTOP', 'SERVIDOR', 'IMPRESORA'];
  final List<String> _estados = ['BUENO', 'REGULAR', 'MALO'];

  final List<String> _oficinas = [
    'Abastecimiento',
    'Alcaldía',
    'ATM (Área Técnica Municipal)',
    'Caja',
    'Contabilidad',
    'DEMUNA',
    'Desarrollo Urbano',
    'Gerencia Municipal',
    'Imagen Institucional',
    'Informática',
    'Infraestructura',
    'Mantenimiento de Maquinaria',
    'Mesa de Partes',
    'Obras',
    'Oficina de Enlace',
    'Planificación y Presupuesto',
    'Programas Sociales (PVL)',
    'Registro Civil',
    'Secretaría General',
    'Tesorería',
    'Unidad Formuladora',
  ];

  final List<String> _sistemasOperativos = [
    'Windows 11 Pro',
    'Windows 11 Home',
    'Windows 10 Pro',
    'Windows 10 Home',
    'Windows Server 2022',
    'Windows Server 2019',
    'Windows Server 2016',
    'Ubuntu Server 22.04',
    'Ubuntu Server 20.04',
    'Ubuntu Desktop 22.04',
    'macOS Ventura',
    'macOS Sonoma',
    'Linux (Otro)',
    'Otro',
  ];

  final List<String> _marcas = [
    'HP',
    'Dell',
    'Lenovo',
    'ASUS',
    'Acer',
    'Apple',
    'Samsung',
    'MSI',
    'Toshiba',
    'Sony',
    'LG',
    'DELL EMC',
    'Ensamblado',
    'Otra',
  ];

  final List<String> _memoriasRAM = [
    '2 GB',
    '4 GB',
    '8 GB',
    '12 GB',
    '16 GB',
    '24 GB',
    '32 GB',
    '48 GB',
    '64 GB',
    '128 GB',
  ];

  final List<String> _discosDuros = [
    '128 GB SSD',
    '256 GB SSD',
    '512 GB SSD',
    '1 TB SSD',
    '2 TB SSD',
    '250 GB HDD',
    '500 GB HDD',
    '1 TB HDD',
    '2 TB HDD',
    '4 TB HDD',
    '1 TB SAS',
    '2 TB SAS',
    '4 TB SAS RAID',
    'Otro',
  ];

  final List<String> _sedes = [
    'PRINCIPAL',
    'SUCURSAL',
  ];

  final List<String> _escanerOpciones = ['SI', 'NO'];

  // Animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get _isEditing => widget.equipo != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    // Si es un nuevo equipo, cargar el siguiente número de inventario
    if (!_isEditing) {
      _cargarSiguienteNumero();
    }
  }

  Future<void> _cargarSiguienteNumero() async {
    final siguienteNumero = await _apiService.getSiguienteNumero();
    if (mounted) {
      setState(() {
        _numeroController.text = siguienteNumero;
      });
    }
  }

  void _initControllers() {
    final equipo = widget.equipo;

    // Controladores de texto libre
    _numeroController = TextEditingController(text: equipo?.numero ?? '');
    _microprocesadorController =
        TextEditingController(text: equipo?.microprocesador ?? '');
    _monitorController = TextEditingController(text: equipo?.monitor ?? '');
    _impresorasController =
        TextEditingController(text: equipo?.impresoras ?? '');
    _ipController = TextEditingController(text: equipo?.ip ?? '');

    // Inicializar dropdowns si estamos editando
    if (equipo != null) {
      // Convertir tipo y estado a mayúsculas para coincidir con las opciones del dropdown
      String tipoUpper = equipo.tipo.toUpperCase();
      String estadoUpper = equipo.estado.toUpperCase();

      _tipoSeleccionado = _tipos.contains(tipoUpper) ? tipoUpper : 'PC';
      _estadoSeleccionado =
          _estados.contains(estadoUpper) ? estadoUpper : 'BUENO';
      _oficinaSeleccionada =
          _oficinas.contains(equipo.oficina) ? equipo.oficina : _oficinas.first;
      _sistemaOperativoSeleccionado =
          _sistemasOperativos.contains(equipo.sistemaOperativo)
              ? equipo.sistemaOperativo
              : 'Otro';
      _marcaSeleccionada =
          _marcas.contains(equipo.marca) ? equipo.marca : 'Otra';
      _memoriaRAMSeleccionada =
          _memoriasRAM.contains(equipo.memoriaRAM) ? equipo.memoriaRAM : '8 GB';
      _discoDuroSeleccionado =
          _discosDuros.contains(equipo.discoDuro) ? equipo.discoDuro : 'Otro';
      _sedeSeleccionada =
          _sedes.contains(equipo.sede) ? equipo.sede : 'PRINCIPAL';
      _escanerSeleccionado = equipo.escaner.toUpperCase() == 'SI' ? 'SI' : 'NO';
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _microprocesadorController.dispose();
    _monitorController.dispose();
    _impresorasController.dispose();
    _ipController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final equipo = Equipo(
      id: widget.equipo?.id,
      numero: _numeroController.text,
      oficina: _oficinaSeleccionada,
      tipo: _tipoSeleccionado.toUpperCase(),
      microprocesador: _microprocesadorController.text,
      sistemaOperativo: _sistemaOperativoSeleccionado,
      marca: _marcaSeleccionada,
      memoriaRAM: _memoriaRAMSeleccionada,
      discoDuro: _discoDuroSeleccionado,
      estado: _estadoSeleccionado.toUpperCase(),
      monitor: _monitorController.text,
      sede: _sedeSeleccionada,
      escaner: _escanerSeleccionado,
      impresoras: _impresorasController.text,
      ip: _ipController.text,
    );

    try {
      Map<String, dynamic> result;

      if (_isEditing && widget.equipo?.id != null) {
        result = await _apiService.actualizarEquipo(widget.equipo!.id!, equipo);
      } else {
        result = await _apiService.crearEquipo(equipo);
      }

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessSnackbar(_isEditing
            ? 'Equipo actualizado correctamente'
            : 'Equipo guardado correctamente');
        // Devolver true para indicar que hay cambios que refrescar
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(result['message'] ?? 'Error al guardar');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Información básica
                      _buildSection(
                        icon: Icons.info_rounded,
                        title: 'Información Básica',
                        color: AppTheme.accentBlue,
                        children: [
                          _buildTextField(
                            controller: _numeroController,
                            label: 'Número de Inventario',
                            icon: Icons.tag_rounded,
                            required: true,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Oficina',
                            value: _oficinaSeleccionada,
                            items: _oficinas,
                            onChanged: (value) {
                              setState(() => _oficinaSeleccionada = value!);
                            },
                            icon: Icons.business_rounded,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Tipo',
                                  value: _tipoSeleccionado,
                                  items: _tipos,
                                  onChanged: (value) {
                                    setState(() => _tipoSeleccionado = value!);
                                  },
                                  icon: Icons.devices_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Estado',
                                  value: _estadoSeleccionado,
                                  items: _estados,
                                  onChanged: (value) {
                                    setState(
                                        () => _estadoSeleccionado = value!);
                                  },
                                  icon: Icons.health_and_safety_rounded,
                                  getItemColor: _getEstadoColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Especificaciones técnicas
                      _buildSection(
                        icon: Icons.memory_rounded,
                        title: 'Especificaciones Técnicas',
                        color: AppTheme.infoPurple,
                        children: [
                          _buildTextField(
                            controller: _microprocesadorController,
                            label: 'Microprocesador',
                            icon: Icons.developer_board_rounded,
                            hint: 'Ej: Intel Core i7-12700 2.1GHz',
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Sistema Operativo',
                            value: _sistemaOperativoSeleccionado,
                            items: _sistemasOperativos,
                            onChanged: (value) {
                              setState(
                                  () => _sistemaOperativoSeleccionado = value!);
                            },
                            icon: Icons.computer_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Marca',
                            value: _marcaSeleccionada,
                            items: _marcas,
                            onChanged: (value) {
                              setState(() => _marcaSeleccionada = value!);
                            },
                            icon: Icons.build_rounded,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Memoria RAM',
                                  value: _memoriaRAMSeleccionada,
                                  items: _memoriasRAM,
                                  onChanged: (value) {
                                    setState(
                                        () => _memoriaRAMSeleccionada = value!);
                                  },
                                  icon: Icons.memory_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Disco Duro',
                                  value: _discoDuroSeleccionado,
                                  items: _discosDuros,
                                  onChanged: (value) {
                                    setState(
                                        () => _discoDuroSeleccionado = value!);
                                  },
                                  icon: Icons.storage_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Periféricos
                      _buildSection(
                        icon: Icons.devices_other_rounded,
                        title: 'Periféricos y Red',
                        color: AppTheme.accentCyan,
                        children: [
                          _buildTextField(
                            controller: _monitorController,
                            label: 'Monitor',
                            icon: Icons.monitor_rounded,
                            hint: 'Ej: HP 24" Full HD',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: 'Escáner',
                                  value: _escanerSeleccionado,
                                  items: _escanerOpciones,
                                  onChanged: (value) {
                                    setState(
                                        () => _escanerSeleccionado = value!);
                                  },
                                  icon: Icons.scanner_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildIPTextField(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _impresorasController,
                            label: 'Impresoras',
                            icon: Icons.print_rounded,
                            hint: 'Ej: HP LaserJet Pro',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Ubicación
                      _buildSection(
                        icon: Icons.location_on_rounded,
                        title: 'Ubicación',
                        color: AppTheme.warningOrange,
                        children: [
                          _buildDropdown(
                            label: 'Sede',
                            value: _sedeSeleccionada,
                            items: _sedes,
                            onChanged: (value) {
                              setState(() => _sedeSeleccionada = value!);
                            },
                            icon: Icons.location_city_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Botón Guardar
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(38),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isLoading)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.save_rounded, color: Colors.white, size: 22),
            ),
            onPressed: _guardar,
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_isEditing
                            ? AppTheme.warningOrange
                            : AppTheme.successGreen)
                        .withAlpha(38),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing ? 'Editar Equipo' : 'Nuevo Equipo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isEditing
                                    ? 'Modificar información del equipo'
                                    : 'Agregar equipo al inventario',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(179),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: color.withAlpha(26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withAlpha(20),
                  color.withAlpha(5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppTheme.textMuted.withAlpha(150),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.5),
        ),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es requerido';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildIPTextField() {
    return TextFormField(
      controller: _ipController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        _IPInputFormatter(),
      ],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(
        labelText: 'Dirección IP',
        hintText: '192.168.1.1',
        labelStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: AppTheme.textMuted.withAlpha(150),
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.language_rounded,
            color: AppTheme.textSecondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentBlue, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    Color Function(String)? getItemColor,
  }) {
    // Asegurarse de que el valor esté en la lista
    final safeValue = items.contains(value) ? value : items.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentBlue, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppTheme.textSecondary,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
      menuMaxHeight: 300,
      items: items.map((String item) {
        final itemColor = getItemColor?.call(item);
        return DropdownMenuItem<String>(
          value: item,
          child: Row(
            children: [
              if (itemColor != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: itemColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withAlpha(77),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _guardar,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditing ? Icons.save_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isEditing ? 'Actualizar Equipo' : 'Guardar Equipo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'bueno':
        return AppTheme.successGreen;
      case 'regular':
        return AppTheme.warningOrange;
      case 'malo':
        return AppTheme.errorRed;
      default:
        return AppTheme.textMuted;
    }
  }
}

/// Formateador de entrada para direcciones IP
/// Permite escribir puntos manualmente sin forzar 3 dígitos
class _IPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo permitir dígitos y puntos
    String text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Evitar puntos consecutivos
    text = text.replaceAll(RegExp(r'\.+'), '.');

    // Evitar que empiece con punto
    if (text.startsWith('.')) {
      text = text.substring(1);
    }

    // Validar la estructura de la IP
    List<String> parts = text.split('.');

    // Limitar a 4 partes máximo
    if (parts.length > 4) {
      parts = parts.sublist(0, 4);
    }

    // Validar cada parte
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];

      // Limitar cada parte a 3 dígitos
      if (part.length > 3) {
        parts[i] = part.substring(0, 3);
      }

      // Validar que el valor no exceda 255
      if (part.isNotEmpty) {
        int? value = int.tryParse(parts[i]);
        if (value != null && value > 255) {
          parts[i] = '255';
        }
      }
    }

    // Reconstruir el texto
    String formatted = parts.join('.');

    // Mantener la posición del cursor correctamente
    int cursorOffset = formatted.length;
    if (newValue.selection.baseOffset <= formatted.length) {
      cursorOffset = newValue.selection.baseOffset;
      if (cursorOffset > formatted.length) {
        cursorOffset = formatted.length;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
