import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/equipo.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/equipo_card.dart';
import '../widgets/stats_card.dart';
import 'agregar_equipo_screen.dart';
import 'detalle_equipo_screen.dart';
import 'login_screen.dart';
import 'reportes_pdf_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _filtroOficina = 'Todas';
  String _filtroTipo = 'Todos';
  String _filtroEstado = 'Todos';
  String _searchQuery = '';
  bool _isSearching = false;

  List<Equipo> _equipos = [];
  Map<String, int> _estadisticas = {};
  List<String> _oficinas = [];
  bool _isLoading = true;

  final List<String> _tipos = [
    'Todos',
    'PC',
    'LAPTOP',
    'SERVIDOR',
    'IMPRESORA'
  ];
  final List<String> _estados = ['Todos', 'BUENO', 'REGULAR', 'MALO'];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _initAnimations();
  }

  void _initAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    );
    // Mostrar FAB después de cargar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final equipos = await _apiService.getEquipos();
      final estadisticas = await _apiService.getEstadisticas();
      final oficinas = await _apiService.getOficinas();

      if (mounted) {
        setState(() {
          _equipos = equipos;
          _estadisticas = estadisticas;
          _oficinas = oficinas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error al cargar datos: $e');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final equiposFiltrados = _getEquiposFiltrados();
    final oficinas = ['Todas', ..._oficinas];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Mostrar diálogo de confirmación para cerrar sesión
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.exit_to_app_rounded, color: AppTheme.warningOrange),
                SizedBox(width: 12),
                Text('¿Cerrar sesión?'),
              ],
            ),
            content: const Text('¿Deseas cerrar sesión y volver al inicio?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningOrange,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
          _apiService.logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppTheme.surfaceLight,
          body: _isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: _cargarDatos,
                  color: AppTheme.accentBlue,
                  child: CustomScrollView(
                    slivers: [
                      // AppBar personalizada
                      _buildSliverAppBar(),

                      // Header con estadísticas
                      SliverToBoxAdapter(
                        child: _buildStatsSection(),
                      ),

                      // Filtros
                      SliverToBoxAdapter(
                        child: _buildFiltersSection(oficinas),
                      ),

                      // Lista de equipos
                      equiposFiltrados.isEmpty
                          ? SliverFillRemaining(
                              child: _buildEmptyState(),
                            )
                          : SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final equipo = equiposFiltrados[index];
                                    return EquipoCard(
                                      equipo: equipo,
                                      onTap: () => _navigateToDetail(equipo),
                                      onEdit: () => _navigateToEdit(equipo),
                                      onDelete: () =>
                                          _mostrarDialogoEliminar(equipo),
                                    );
                                  },
                                  childCount: equiposFiltrados.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
          floatingActionButton: ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              onPressed: _navigateToAdd,
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              elevation: 8,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Nuevo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              // Decoraciones de fondo
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentCyan.withOpacity(0.1),
                  ),
                ),
              ),
              // Contenido
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Panel de Administración',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
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
      actions: [
        // Botón de búsqueda
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(_isSearching),
            ),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
        ),
        // Botón de refrescar
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _cargarDatos,
        ),
        // Menú
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          offset: const Offset(0, 50),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'reportes',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppTheme.accentBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reportes PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppTheme.errorRed,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'reportes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportesPdfScreen(),
                ),
              );
            } else if (value == 'logout') {
              _logout();
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda animada
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearching ? 56 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isSearching ? 1 : 0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.subtleShadow,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar por oficina, tipo, procesador...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Título de estadísticas
          const Text(
            'Resumen del Inventario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Cards de estadísticas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StatsCard(
                  title: 'Total',
                  value: (_estadisticas['total'] ?? 0).toString(),
                  icon: Icons.inventory_2_rounded,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                StatsCard(
                  title: 'PC',
                  value: (_estadisticas['pc'] ?? 0).toString(),
                  icon: Icons.desktop_windows_rounded,
                  color: AppTheme.accentBlue,
                ),
                const SizedBox(width: 12),
                StatsCard(
                  title: 'Laptops',
                  value: (_estadisticas['laptop'] ?? 0).toString(),
                  icon: Icons.laptop_rounded,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: 12),
                StatsCard(
                  title: 'Servidores',
                  value: (_estadisticas['servidor'] ?? 0).toString(),
                  icon: Icons.dns_rounded,
                  color: AppTheme.infoPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(List<String> oficinas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Equipos (${_getEquiposFiltrados().length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              // Botón para limpiar filtros
              if (_filtroOficina != 'Todas' ||
                  _filtroTipo != 'Todos' ||
                  _filtroEstado != 'Todos')
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filtroOficina = 'Todas';
                      _filtroTipo = 'Todos';
                      _filtroEstado = 'Todos';
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila de filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro por Oficina
                _buildFilterDropdown(
                  label: 'Oficina',
                  value: oficinas.contains(_filtroOficina)
                      ? _filtroOficina
                      : 'Todas',
                  items: oficinas,
                  onChanged: (value) => setState(() => _filtroOficina = value!),
                  icon: Icons.business_rounded,
                  width: 150,
                ),
                const SizedBox(width: 10),

                // Filtro por Tipo
                _buildFilterDropdown(
                  label: 'Tipo',
                  value: _filtroTipo,
                  items: _tipos,
                  onChanged: (value) => setState(() => _filtroTipo = value!),
                  icon: Icons.devices_rounded,
                  width: 120,
                ),
                const SizedBox(width: 10),

                // Filtro por Estado
                _buildFilterDropdown(
                  label: 'Estado',
                  value: _filtroEstado,
                  items: _estados,
                  onChanged: (value) => setState(() => _filtroEstado = value!),
                  icon: Icons.health_and_safety_rounded,
                  width: 120,
                  getItemColor: _getEstadoColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required double width,
    Color Function(String)? getItemColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          isDense: true,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (getItemColor != null && item != 'Todos')
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: getItemColor(item),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      item.length > 15 ? '${item.substring(0, 15)}...' : item,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'BUENO':
        return AppTheme.successGreen;
      case 'REGULAR':
        return AppTheme.warningOrange;
      case 'MALO':
        return AppTheme.errorRed;
      default:
        return AppTheme.textMuted;
    }
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cargando inventario...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No se encontraron equipos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros de búsqueda\no agrega un nuevo equipo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar Equipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Equipo> _getEquiposFiltrados() {
    List<Equipo> equipos = _equipos;

    // Filtro por oficina
    if (_filtroOficina != 'Todas') {
      equipos = equipos.where((e) => e.oficina == _filtroOficina).toList();
    }

    // Filtro por tipo
    if (_filtroTipo != 'Todos') {
      equipos =
          equipos.where((e) => e.tipo.toUpperCase() == _filtroTipo).toList();
    }

    // Filtro por estado
    if (_filtroEstado != 'Todos') {
      equipos = equipos
          .where((e) => e.estado.toUpperCase() == _filtroEstado)
          .toList();
    }

    // Búsqueda por texto
    if (_searchQuery.isNotEmpty) {
      equipos = equipos.where((equipo) {
        return equipo.oficina
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            equipo.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            equipo.microprocesador
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            equipo.marca.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            equipo.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            equipo.ip.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return equipos;
  }

  void _navigateToDetail(Equipo equipo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetalleEquipoScreen(
          equipo: equipo,
          isAdmin: true,
          onEditar: () => _navigateToEdit(equipo),
          onEliminar: () => _eliminarEquipo(equipo),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    ).then((_) => _cargarDatos()); // Refrescar al volver del detalle
  }

  void _navigateToEdit(Equipo equipo) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarEquipoScreen(equipo: equipo),
      ),
    );
    // Si hubo cambios, recargar los datos
    if (result == true) {
      _cargarDatos();
    }
  }

  void _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AgregarEquipoScreen(),
      ),
    );
    // Si se creó un equipo, recargar los datos
    if (result == true) {
      _cargarDatos();
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _apiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(Equipo equipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppTheme.errorRed,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Equipo'),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar el equipo de "${equipo.oficina}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarEquipo(equipo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarEquipo(Equipo equipo) async {
    if (equipo.id == null) return;

    final result = await _apiService.eliminarEquipo(equipo.id!);

    if (mounted) {
      if (result['success'] == true) {
        _showSuccessSnackbar('Equipo eliminado exitosamente');
        _cargarDatos();
      } else {
        _showErrorSnackbar(result['message'] ?? 'Error al eliminar');
      }
    }
  }
}
