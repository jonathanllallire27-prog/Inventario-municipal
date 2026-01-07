import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/equipo.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ReportesPdfScreen extends StatefulWidget {
  const ReportesPdfScreen({super.key});

  @override
  State<ReportesPdfScreen> createState() => _ReportesPdfScreenState();
}

class _ReportesPdfScreenState extends State<ReportesPdfScreen> {
  final ApiService _apiService = ApiService();

  String _selectedOficina = 'Todas';
  String _selectedTipo = 'Todos';
  String _selectedEstado = 'Todos';

  List<String> _oficinas = [];
  List<Equipo> _equipos = [];
  Map<String, int> _estadisticas = {};
  bool _isLoading = true;
  bool _isGenerating = false;

  final List<String> _tipos = ['Todos', 'PC', 'LAPTOP', 'SERVIDOR'];
  final List<String> _estados = ['Todos', 'BUENO', 'REGULAR', 'MALO'];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final equipos = await _apiService.getEquipos();
      final oficinas = await _apiService.getOficinas();
      final estadisticas = await _apiService.getEstadisticas();

      if (mounted) {
        setState(() {
          _equipos = equipos;
          _oficinas = oficinas;
          _estadisticas = estadisticas;
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

  List<Equipo> _getEquiposFiltrados() {
    return _equipos.where((equipo) {
      bool matchOficina =
          _selectedOficina == 'Todas' || equipo.oficina == _selectedOficina;
      bool matchTipo = _selectedTipo == 'Todos' || equipo.tipo == _selectedTipo;
      bool matchEstado =
          _selectedEstado == 'Todos' || equipo.estado == _selectedEstado;
      return matchOficina && matchTipo && matchEstado;
    }).toList();
  }

  Map<String, int> _getEstadisticasFiltradas(List<Equipo> equipos) {
    int pcs = equipos.where((e) => e.tipo.toUpperCase() == 'PC').length;
    int laptops = equipos.where((e) => e.tipo.toUpperCase() == 'LAPTOP').length;
    int servidores =
        equipos.where((e) => e.tipo.toUpperCase() == 'SERVIDOR').length;
    int buenos = equipos.where((e) => e.estado.toUpperCase() == 'BUENO').length;
    int regulares =
        equipos.where((e) => e.estado.toUpperCase() == 'REGULAR').length;
    int malos = equipos.where((e) => e.estado.toUpperCase() == 'MALO').length;

    return {
      'total': equipos.length,
      'pc': pcs,
      'laptop': laptops,
      'servidor': servidores,
      'bueno': buenos,
      'regular': regulares,
      'malo': malos,
    };
  }

  /// Limpia caracteres especiales no soportados por la fuente PDF
  String _sanitizeText(String text) {
    return text
        .replaceAll('®', '')
        .replaceAll('™', '')
        .replaceAll('©', '(c)')
        .replaceAll('°', 'o')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('"', '"')
        .replaceAll('"', '"')
        .replaceAll(''', "'")
        .replaceAll(''', "'")
        .replaceAll('…', '...')
        .replaceAll('  ', ' ')
        .trim();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceLight,
        body: _isLoading
            ? _buildLoadingState()
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFiltersCard(),
                          const SizedBox(height: 24),
                          _buildReportTypesSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.accentBlue,
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentBlue,
                AppTheme.primaryBlue,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reportes PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Genera y descarga informes',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  color: AppTheme.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filtros para Reporte',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filtro Oficina
          _buildDropdownField(
            label: 'Oficina',
            value: _selectedOficina,
            items: ['Todas', ..._oficinas],
            onChanged: (value) => setState(() => _selectedOficina = value!),
          ),

          const SizedBox(height: 16),

          // Filtros Tipo y Estado en fila
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Tipo',
                  value: _selectedTipo,
                  items: _tipos,
                  onChanged: (value) => setState(() => _selectedTipo = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Estado',
                  value: _selectedEstado,
                  items: _estados,
                  onChanged: (value) =>
                      setState(() => _selectedEstado = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textSecondary),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item.length > 25 ? '${item.substring(0, 25)}...' : item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipos de Reportes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Reporte de Equipos
        _buildReportCard(
          icon: Icons.description_rounded,
          iconColor: AppTheme.accentCyan,
          title: 'Reporte de Equipos',
          subtitle: 'Lista de equipos según los filtros seleccionados',
          onTap: () => _generarReporteEquipos(),
        ),

        const SizedBox(height: 12),

        // Informe Completo
        _buildReportCard(
          icon: Icons.folder_copy_rounded,
          iconColor: AppTheme.successGreen,
          title: 'Informe Completo',
          subtitle: 'Estadísticas por oficina y listado completo de equipos',
          onTap: () => _generarInformeCompleto(),
        ),

        const SizedBox(height: 12),

        // Informe Estadístico
        _buildReportCard(
          icon: Icons.bar_chart_rounded,
          iconColor: AppTheme.infoPurple,
          title: 'Informe Estadístico',
          subtitle: 'Distribución por tipo, estado y marcas más frecuentes',
          onTap: () => _generarInformeEstadistico(),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.subtleShadow,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGenerating ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.successGreen,
                          ),
                        )
                      : const Icon(
                          Icons.download_rounded,
                          color: AppTheme.successGreen,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.accentBlue, AppTheme.primaryBlue],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 24),
            Text(
              'Cargando datos...',
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

  // ==================== GENERACIÓN DE PDFs ====================

  Future<void> _generarReporteEquipos() async {
    setState(() => _isGenerating = true);

    try {
      final equiposFiltrados = _getEquiposFiltrados();

      if (equiposFiltrados.isEmpty) {
        _showErrorSnackbar('No hay equipos con los filtros seleccionados');
        setState(() => _isGenerating = false);
        return;
      }

      final stats = _getEstadisticasFiltradas(equiposFiltrados);
      final pdf = pw.Document();

      // Construir filtros aplicados
      List<String> filtrosAplicados = [];
      if (_selectedOficina != 'Todas')
        filtrosAplicados.add('Oficina: $_selectedOficina');
      if (_selectedTipo != 'Todos')
        filtrosAplicados.add('Tipo: $_selectedTipo');
      if (_selectedEstado != 'Todos')
        filtrosAplicados.add('Estado: $_selectedEstado');
      String filtrosTexto = filtrosAplicados.isEmpty
          ? 'Sin filtros'
          : filtrosAplicados.join(' | ');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            _buildPdfHeader(),
            pw.SizedBox(height: 10),
            _buildPdfTitulo('REPORTE DE INVENTARIO DE EQUIPOS'),
            pw.SizedBox(height: 5),
            _buildPdfSubtitulo('Filtros: $filtrosTexto'),
            _buildPdfFechaGeneracion(),
            pw.SizedBox(height: 20),
            _buildPdfResumen(stats),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Detalle de Equipos:'),
            pw.SizedBox(height: 10),
            _buildEquiposTableCompleta(equiposFiltrados),
          ],
          footer: (context) => _buildPdfFooter(context),
        ),
      );

      await _savePdf(pdf, 'reporte_inventario_equipos');
    } catch (e) {
      _showErrorSnackbar('Error al generar PDF: $e');
    }

    setState(() => _isGenerating = false);
  }

  Future<void> _generarInformeCompleto() async {
    setState(() => _isGenerating = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            _buildPdfHeader(),
            pw.SizedBox(height: 10),
            _buildPdfTitulo('INFORME COMPLETO DE INVENTARIO'),
            _buildPdfFechaGeneracion(),
            pw.SizedBox(height: 20),
            _buildPdfResumen(_estadisticas),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Distribución por Oficina:'),
            pw.SizedBox(height: 10),
            _buildEquiposPorOficinaTable(),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Listado Completo de Equipos:'),
            pw.SizedBox(height: 10),
            _buildEquiposTableCompleta(_equipos),
          ],
          footer: (context) => _buildPdfFooter(context),
        ),
      );

      await _savePdf(pdf, 'informe_completo_inventario');
    } catch (e) {
      _showErrorSnackbar('Error al generar PDF: $e');
    }

    setState(() => _isGenerating = false);
  }

  Future<void> _generarInformeEstadistico() async {
    setState(() => _isGenerating = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            _buildPdfHeader(),
            pw.SizedBox(height: 10),
            _buildPdfTitulo('INFORME ESTADÍSTICO'),
            _buildPdfFechaGeneracion(),
            pw.SizedBox(height: 20),
            _buildPdfResumen(_estadisticas),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Distribución por Tipo de Equipo:'),
            pw.SizedBox(height: 10),
            _buildDistribucionTipoTable(),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Distribución por Estado:'),
            pw.SizedBox(height: 10),
            _buildDistribucionEstadoTable(),
            pw.SizedBox(height: 20),
            _buildPdfSeccionTitulo('Marcas más Frecuentes:'),
            pw.SizedBox(height: 10),
            _buildMarcasFrecuentesTable(),
          ],
          footer: (context) => _buildPdfFooter(context),
        ),
      );

      await _savePdf(pdf, 'informe_estadistico');
    } catch (e) {
      _showErrorSnackbar('Error al generar PDF: $e');
    }

    setState(() => _isGenerating = false);
  }

  // ==================== COMPONENTES DEL PDF ====================

  pw.Widget _buildPdfHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'MUNICIPALIDAD SAN JUAN BAUTISTA',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1E3A8A'),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Sistema de Inventario de Equipos',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          height: 2,
          color: PdfColor.fromHex('#1E3A8A'),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTitulo(String titulo) {
    return pw.Center(
      child: pw.Text(
        titulo,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.Widget _buildPdfSubtitulo(String subtitulo) {
    return pw.Center(
      child: pw.Text(
        subtitulo,
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  pw.Widget _buildPdfFechaGeneracion() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy, hh:mm a.');
    return pw.Center(
      child: pw.Text(
        'Generado: ${formatter.format(now)}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey500,
        ),
      ),
    );
  }

  pw.Widget _buildPdfResumen(Map<String, int> stats) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Total de equipos: ${stats['total'] ?? 0} | PCs: ${stats['pc'] ?? 0} | Laptops: ${stats['laptop'] ?? 0} | Servidores: ${stats['servidor'] ?? 0}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            'Estado Bueno: ${stats['bueno'] ?? 0} | Regular: ${stats['regular'] ?? 0} | Malo: ${stats['malo'] ?? 0}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSeccionTitulo(String titulo) {
    return pw.Text(
      titulo,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey800,
      ),
    );
  }

  pw.Widget _buildEquiposTableCompleta(List<Equipo> equipos) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellHeight: 22,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
        7: pw.Alignment.center,
      },
      headers: [
        'N',
        'Oficina',
        'Tipo',
        'Marca',
        'Procesador',
        'RAM',
        'Estado',
        'IP'
      ],
      data: equipos.map((e) {
        String oficina = _sanitizeText(e.oficina);
        String marca = _sanitizeText(e.marca);
        String procesador = _sanitizeText(e.microprocesador);

        return [
          e.numero,
          oficina.length > 20 ? '${oficina.substring(0, 20)}...' : oficina,
          e.tipo,
          marca.length > 15 ? '${marca.substring(0, 15)}...' : marca,
          procesador.length > 18
              ? '${procesador.substring(0, 18)}...'
              : procesador,
          e.memoriaRAM,
          e.estado,
          e.ip,
        ];
      }).toList(),
    );
  }

  pw.Widget _buildEquiposPorOficinaTable() {
    final equiposPorOficina = <String, int>{};
    for (var equipo in _equipos) {
      equiposPorOficina[equipo.oficina] =
          (equiposPorOficina[equipo.oficina] ?? 0) + 1;
    }

    final sortedOficinas = equiposPorOficina.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 22,
      headers: ['Oficina', 'Cantidad de Equipos'],
      data: sortedOficinas
          .take(20)
          .map((e) => [e.key, e.value.toString()])
          .toList(),
    );
  }

  pw.Widget _buildDistribucionTipoTable() {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellHeight: 25,
      headers: ['Tipo de Equipo', 'Cantidad', 'Porcentaje'],
      data: [
        [
          'PC',
          '${_estadisticas['pc'] ?? 0}',
          '${((_estadisticas['pc'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
        [
          'LAPTOP',
          '${_estadisticas['laptop'] ?? 0}',
          '${((_estadisticas['laptop'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
        [
          'SERVIDOR',
          '${_estadisticas['servidor'] ?? 0}',
          '${((_estadisticas['servidor'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
      ],
    );
  }

  pw.Widget _buildDistribucionEstadoTable() {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellHeight: 25,
      headers: ['Estado', 'Cantidad', 'Porcentaje'],
      data: [
        [
          'BUENO',
          '${_estadisticas['bueno'] ?? 0}',
          '${((_estadisticas['bueno'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
        [
          'REGULAR',
          '${_estadisticas['regular'] ?? 0}',
          '${((_estadisticas['regular'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
        [
          'MALO',
          '${_estadisticas['malo'] ?? 0}',
          '${((_estadisticas['malo'] ?? 0) / (_estadisticas['total'] ?? 1) * 100).toStringAsFixed(1)}%'
        ],
      ],
    );
  }

  pw.Widget _buildMarcasFrecuentesTable() {
    final marcas = <String, int>{};
    for (var equipo in _equipos) {
      if (equipo.marca.isNotEmpty) {
        marcas[equipo.marca] = (marcas[equipo.marca] ?? 0) + 1;
      }
    }

    final sortedMarcas = marcas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellHeight: 22,
      headers: ['Marca', 'Cantidad', 'Porcentaje'],
      data: sortedMarcas
          .take(10)
          .map((e) => [
                e.key,
                e.value.toString(),
                '${(e.value / _equipos.length * 100).toStringAsFixed(1)}%',
              ])
          .toList(),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  Future<void> _savePdf(pw.Document pdf, String fileName) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File(
        '${output.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    _showSuccessSnackbar('PDF guardado exitosamente');

    // Abrir el PDF
    await OpenFilex.open(file.path);
  }
}
