import 'package:flutter/material.dart';
import 'package:sistema_movil_inventariado/models/equipo.dart';
import '../providers/inventario_provider.dart';
import '../widgets/equipo_card.dart';
import '../widgets/stats_card.dart';
import 'detalle_equipo_screen.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final InventarioProvider _inventarioProvider = InventarioProvider();
  String _filtroOficina = 'Todas';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final equipos = _getEquiposFiltrados();
    final estadisticas = _inventarioProvider.getEstadisticas();
    final oficinas = ['Todas', ..._inventarioProvider.getOficinas()];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Inventario Municipal'),
        backgroundColor: Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _mostrarBusqueda,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _inventarioProvider.logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header de Usuario
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.visibility_outlined, color: Colors.green),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario Visualizador',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Permisos de solo lectura',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filtros y Estadísticas
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Filtro por Oficina
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: _filtroOficina,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: oficinas.map((String oficina) {
                      return DropdownMenuItem<String>(
                        value: oficina,
                        child: Text(
                          oficina,
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _filtroOficina = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Estadísticas
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StatsCard(
                        title: 'Total',
                        value: estadisticas['total']!.toString(),
                        icon: Icons.inventory_2,
                        color: Color(0xFF0D47A1),
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'Buen Estado',
                        value: estadisticas['bueno']!.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'Regular',
                        value: estadisticas['regular']!.toString(),
                        icon: Icons.info,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'Por Reparar',
                        value: estadisticas['malo']!.toString(),
                        icon: Icons.build,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de Equipos
          Expanded(
            child: equipos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron equipos',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Intente cambiar los filtros de búsqueda',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: equipos.length,
                    itemBuilder: (context, index) {
                      final equipo = equipos[index];
                      return EquipoCard(
                        equipo: equipo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleEquipoScreen(
                                equipo: equipo,
                                isAdmin: false,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Equipo> _getEquiposFiltrados() {
    List<Equipo> equipos = _inventarioProvider.equipos;

    if (_filtroOficina != 'Todas') {
      equipos = equipos.where((e) => e.oficina == _filtroOficina).toList();
    }

    if (_searchQuery.isNotEmpty) {
      equipos = equipos.where((equipo) {
        return equipo.oficina
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            equipo.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            equipo.microprocesador
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return equipos;
  }

  void _mostrarBusqueda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buscar Equipos'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar por oficina, tipo, procesador...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
