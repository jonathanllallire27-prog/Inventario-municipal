import 'package:flutter/material.dart';
import '../models/equipo.dart';
import 'agregar_equipo_screen.dart';

class DetalleEquipoScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detalles del Equipo'),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEditar ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AgregarEquipoScreen(equipo: equipo),
                          ),
                        );
                      },
                  tooltip: 'Editar Equipo',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _mostrarDialogoEliminar(context),
                  tooltip: 'Eliminar Equipo',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Especificaciones Técnicas
            _buildSpecsCard(),
            const SizedBox(height: 20),

            // Configuración y Periféricos
            _buildPeripheralsCard(),
            const SizedBox(height: 20),

            // Información Adicional
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
      floatingActionButton:
          isAdmin ? _buildFloatingActionButtons(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Eliminar
          FloatingActionButton.extended(
            heroTag: 'delete_btn',
            onPressed: onEliminar ??
                () {
                  _mostrarDialogoEliminar(context);
                },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.delete_outlined),
            label: const Text('ELIMINAR'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Botón Editar
          FloatingActionButton.extended(
            heroTag: 'edit_btn',
            onPressed: onEditar ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgregarEquipoScreen(equipo: equipo),
                    ),
                  );
                },
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('EDITAR'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmar Eliminación'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar el equipo:',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${equipo.tipo} - N° ${equipo.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Oficina: ${equipo.oficina}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                if (onEliminar != null) {
                  onEliminar!(); // Llamar al callback de eliminación
                } else {
                  // Si no hay callback, simplemente regresamos
                  Navigator.of(context)
                      .pop(); // Regresar a la pantalla anterior
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ELIMINAR'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${equipo.tipo} - ${equipo.oficina}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'N° ${equipo.numero}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getEstadoColor(equipo.estado).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getEstadoColor(equipo.estado)),
                ),
                child: Text(
                  equipo.estado,
                  style: TextStyle(
                    color: _getEstadoColor(equipo.estado),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderItem(Icons.business_outlined, equipo.sede, 'Sede'),
              const SizedBox(width: 20),
              _buildHeaderItem(Icons.language_outlined,
                  equipo.ip.isEmpty ? 'Sin IP' : equipo.ip, 'IP'),
              const SizedBox(width: 20),
              _buildHeaderItem(
                  Icons.scanner_outlined, equipo.escaner, 'Escáner'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory_outlined, color: Color(0xFF0D47A1), size: 20),
              SizedBox(width: 8),
              Text(
                'Especificaciones Técnicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSpecItem('🧠 Procesador', equipo.microprocesador),
          _buildSpecItem('💻 Sistema Operativo', equipo.sistemaOperativo),
          _buildSpecItem('🏷️ Marca', equipo.marca),
          _buildSpecItem('📊 Memoria RAM', equipo.memoriaRAM),
          _buildSpecItem('💾 Disco Duro', equipo.discoDuro),
          _buildSpecItem('🖥️ Monitor', equipo.monitor),
        ],
      ),
    );
  }

  Widget _buildPeripheralsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.print_outlined, color: Color(0xFF0D47A1), size: 20),
              SizedBox(width: 8),
              Text(
                'Periféricos y Red',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSpecItem(
              '🖨️ Impresoras',
              equipo.impresoras.isEmpty
                  ? 'No especificado'
                  : equipo.impresoras),
          _buildSpecItem('📡 Escáner', equipo.escaner),
          _buildSpecItem(
              '🌐 Dirección IP', equipo.ip.isEmpty ? 'No asignada' : equipo.ip),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0D47A1), size: 20),
              SizedBox(width: 8),
              Text(
                'Información Adicional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSpecItem('🏢 Oficina', equipo.oficina),
          _buildSpecItem('📍 Sede', equipo.sede),
          _buildSpecItem('🔧 Tipo', equipo.tipo),
          _buildSpecItem('📋 Número', equipo.numero),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'BUENO':
        return Colors.green;
      case 'REGULAR':
        return Colors.orange;
      case 'MALO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
