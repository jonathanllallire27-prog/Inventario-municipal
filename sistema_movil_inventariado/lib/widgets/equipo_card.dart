import 'package:flutter/material.dart';
import '../models/equipo.dart';

class EquipoCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EquipoCard({
    required this.equipo,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con tipo y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getTipoColor(equipo.tipo).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTipoColor(equipo.tipo).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTipoIcon(equipo.tipo),
                              size: 14,
                              color: _getTipoColor(equipo.tipo),
                            ),
                            SizedBox(width: 4),
                            Text(
                              equipo.tipo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getTipoColor(equipo.tipo),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _getEstadoColor(equipo.estado).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _getEstadoColor(equipo.estado).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          equipo.estado,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getEstadoColor(equipo.estado),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Información principal
                  Text(
                    equipo.oficina,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // Microprocesador
                  Text(
                    equipo.microprocesador,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // Especificaciones
                  Row(
                    children: [
                      _buildSpecChip(Icons.memory_outlined, equipo.memoriaRAM),
                      SizedBox(width: 8),
                      _buildSpecChip(Icons.storage_outlined, equipo.discoDuro),
                      if (equipo.ip.isNotEmpty) ...[
                        SizedBox(width: 8),
                        _buildSpecChip(Icons.language_outlined, 'IP'),
                      ],
                    ],
                  ),

                  // Acciones (solo para admin)
                  if (onEdit != null || onDelete != null) ...[
                    SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[200]),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          _buildActionButton(
                            Icons.edit_outlined,
                            Colors.blue,
                            'Editar',
                            onEdit!,
                          ),
                        if (onDelete != null) ...[
                          SizedBox(width: 8),
                          _buildActionButton(
                            Icons.delete_outline,
                            Colors.red,
                            'Eliminar',
                            onDelete!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.all(6),
        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'PC':
        return Colors.blue;
      case 'LAPTOP':
        return Colors.green;
      case 'SERVIDOR':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'PC':
        return Icons.desktop_windows_outlined;
      case 'LAPTOP':
        return Icons.laptop_outlined;
      case 'SERVIDOR':
        return Icons.storage_outlined;
      default:
        return Icons.computer_outlined;
    }
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
