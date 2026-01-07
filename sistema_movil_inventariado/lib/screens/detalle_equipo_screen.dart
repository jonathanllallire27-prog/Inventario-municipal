import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/equipo.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'agregar_equipo_screen.dart';

class DetalleEquipoScreen extends StatefulWidget {
  final Equipo equipo;
  final bool isAdmin;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const DetalleEquipoScreen({
    super.key,
    required this.equipo,
    required this.isAdmin,
    this.onEditar,
    this.onEliminar,
  });

  @override
  State<DetalleEquipoScreen> createState() => _DetalleEquipoScreenState();
}

class _DetalleEquipoScreenState extends State<DetalleEquipoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Equipo mutable para poder actualizarlo
  late Equipo _equipo;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _equipo = widget.equipo; // Inicializar con el equipo pasado

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DetalleEquipoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.equipo != oldWidget.equipo) {
      _equipo = widget.equipo;
    }
  }

  // Función para recargar el equipo desde la API
  Future<void> _recargarEquipo() async {
    if (_equipo.id != null) {
      final equipoActualizado = await _apiService.getEquipo(_equipo.id!);
      if (equipoActualizado != null && mounted) {
        setState(() {
          _equipo = equipoActualizado;
        });
      }
    }
  }

  // Función para editar y refrescar los datos
  Future<void> _editarEquipo() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarEquipoScreen(equipo: _equipo),
      ),
    );

    // Si hubo cambios, recargar el equipo
    if (result == true) {
      await _recargarEquipo();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tipoColor = AppTheme.getTypeColor(_equipo.tipo);
    final estadoColor = AppTheme.getStatusColor(_equipo.estado);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceLight,
        body: CustomScrollView(
          slivers: [
            // Header con información principal
            _buildSliverHeader(tipoColor, estadoColor),

            // Contenido
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        16, 24, 16, widget.isAdmin ? 100 : 24),
                    child: Column(
                      children: [
                        _buildSpecsCard(),
                        const SizedBox(height: 16),
                        _buildPeripheralsCard(),
                        const SizedBox(height: 16),
                        _buildAdditionalInfoCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:
            widget.isAdmin ? _buildFloatingActionButtons(context) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildSliverHeader(Color tipoColor, Color estadoColor) {
    return SliverAppBar(
      expandedHeight: 260,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: widget.isAdmin
          ? [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 20),
                ),
                onPressed: _editarEquipo,
              ),
              const SizedBox(width: 8),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              // Decoraciones
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tipoColor.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Contenido del header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _buildBadge(
                            icon: AppTheme.getTypeIcon(_equipo.tipo),
                            label: _equipo.tipo,
                            color: tipoColor,
                          ),
                          const SizedBox(width: 10),
                          _buildStatusBadge(estadoColor),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Oficina (título principal)
                      Text(
                        _equipo.oficina,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Número y procesador
                      Row(
                        children: [
                          _buildHeaderChip(
                            icon: Icons.tag_rounded,
                            text: 'N° ${_equipo.numero}',
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildHeaderChip(
                              icon: Icons.memory_rounded,
                              text: _equipo.microprocesador,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Información rápida
                      Row(
                        children: [
                          _buildQuickInfo(
                            icon: Icons.business_rounded,
                            value: _equipo.sede,
                            label: 'Sede',
                          ),
                          const SizedBox(width: 24),
                          _buildQuickInfo(
                            icon: Icons.language_rounded,
                            value:
                                _equipo.ip.isEmpty ? 'No asignada' : _equipo.ip,
                            label: 'IP',
                          ),
                          const SizedBox(width: 24),
                          _buildQuickInfo(
                            icon: Icons.scanner_rounded,
                            value: _equipo.escaner,
                            label: 'Escáner',
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

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _equipo.estado,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsCard() {
    return _buildCard(
      icon: Icons.memory_rounded,
      title: 'Especificaciones Técnicas',
      color: AppTheme.accentBlue,
      children: [
        _buildSpecRow(
          icon: Icons.developer_board_rounded,
          label: 'Procesador',
          value: _equipo.microprocesador,
        ),
        _buildSpecRow(
          icon: Icons.computer_rounded,
          label: 'Sistema Operativo',
          value: _equipo.sistemaOperativo,
        ),
        _buildSpecRow(
          icon: Icons.build_rounded,
          label: 'Marca',
          value: _equipo.marca,
        ),
        _buildSpecRow(
          icon: Icons.memory_rounded,
          label: 'Memoria RAM',
          value: _equipo.memoriaRAM,
        ),
        _buildSpecRow(
          icon: Icons.storage_rounded,
          label: 'Disco Duro',
          value: _equipo.discoDuro,
        ),
        _buildSpecRow(
          icon: Icons.monitor_rounded,
          label: 'Monitor',
          value: _equipo.monitor,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildPeripheralsCard() {
    return _buildCard(
      icon: Icons.devices_rounded,
      title: 'Periféricos y Red',
      color: AppTheme.infoPurple,
      children: [
        _buildSpecRow(
          icon: Icons.print_rounded,
          label: 'Impresoras',
          value: _equipo.impresoras.isEmpty
              ? 'No especificado'
              : _equipo.impresoras,
        ),
        _buildSpecRow(
          icon: Icons.scanner_rounded,
          label: 'Escáner',
          value: _equipo.escaner,
        ),
        _buildSpecRow(
          icon: Icons.language_rounded,
          label: 'Dirección IP',
          value: _equipo.ip.isEmpty ? 'No asignada' : _equipo.ip,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoCard() {
    return _buildCard(
      icon: Icons.info_rounded,
      title: 'Información Adicional',
      color: AppTheme.accentCyan,
      children: [
        _buildSpecRow(
          icon: Icons.business_rounded,
          label: 'Oficina',
          value: _equipo.oficina,
        ),
        _buildSpecRow(
          icon: Icons.location_on_rounded,
          label: 'Sede',
          value: _equipo.sede,
        ),
        _buildSpecRow(
          icon: Icons.category_rounded,
          label: 'Tipo',
          value: _equipo.tipo,
        ),
        _buildSpecRow(
          icon: Icons.numbers_rounded,
          label: 'Número',
          value: _equipo.numero,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withOpacity(0.08),
                  color.withOpacity(0.02),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Botón Eliminar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.2),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _mostrarDialogoEliminar(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          color: AppTheme.errorRed,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botón Editar
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _editarEquipo,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Editar Equipo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de advertencia
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 40,
                  color: AppTheme.errorRed,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                'Eliminar Equipo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Descripción
              Text(
                '¿Estás seguro de eliminar este equipo?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Info del equipo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.getTypeColor(widget.equipo.tipo)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppTheme.getTypeIcon(widget.equipo.tipo),
                        color: AppTheme.getTypeColor(widget.equipo.tipo),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.equipo.tipo} - N° ${widget.equipo.numero}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            widget.equipo.oficina,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Advertencia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.errorRed.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.errorRed,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer',
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      if (widget.onEliminar != null) {
                        widget.onEliminar!();
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }
}
