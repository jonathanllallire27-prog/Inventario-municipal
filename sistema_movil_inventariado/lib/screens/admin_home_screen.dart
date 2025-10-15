import 'package:sistema_movil_inventariado/models/equipo.dart';
import 'package:flutter/material.dart';
import '../providers/inventario_provider.dart';
import '../widgets/equipo_card.dart';
import '../widgets/stats_card.dart';
import 'agregar_equipo_screen.dart';
import 'detalle_equipo_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
        title: Text('Panel de Administración'),
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
                        title: 'Total Equipos',
                        value: estadisticas['total']!.toString(),
                        icon: Icons.computer,
                        color: Color(0xFF0D47A1),
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'PC',
                        value: estadisticas['pc']!.toString(),
                        icon: Icons.desktop_windows,
                        color: Colors.green,
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'Laptops',
                        value: estadisticas['laptop']!.toString(),
                        icon: Icons.laptop,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 12),
                      StatsCard(
                        title: 'Servidores',
                        value: estadisticas['servidor']!.toString(),
                        icon: Icons.storage,
                        color: Colors.purple,
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
                        Icon(Icons.inventory_2_outlined,
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
                                isAdmin: true,
                              ),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgregarEquipoScreen(
                                equipo: equipo,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        onDelete: () {
                          _mostrarDialogoEliminar(equipo);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarEquipoScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.add, size: 28),
        elevation: 4,
      ),
    );
  }

  List<Equipo> _getEquiposFiltrados() {
    List<Equipo> equipos = _inventarioProvider.equipos;

    // Filtrar por oficina
    if (_filtroOficina != 'Todas') {
      equipos = equipos.where((e) => e.oficina == _filtroOficina).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      equipos = equipos.where((equipo) {
        return equipo.oficina
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            equipo.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            equipo.microprocesador
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            equipo.marca.toLowerCase().contains(_searchQuery.toLowerCase());
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

  void _mostrarDialogoEliminar(Equipo equipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Equipo'),
        content:
            Text('¿Está seguro de eliminar el equipo de ${equipo.oficina}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              _inventarioProvider.eliminarEquipo(equipo.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Equipo eliminado exitosamente'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
