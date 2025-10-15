import 'package:flutter/foundation.dart';
import '../models/equipo.dart';

class InventarioProvider with ChangeNotifier {
  static final InventarioProvider _instance = InventarioProvider._internal();
  factory InventarioProvider() => _instance;
  InventarioProvider._internal() {
    _cargarDatosIniciales();
  }

  List<Equipo> _equipos = [];
  bool _isAdmin = false;
  String _usuarioActual = '';

  List<Equipo> get equipos => _equipos;
  bool get isAdmin => _isAdmin;
  String get usuarioActual => _usuarioActual;

  void _cargarDatosIniciales() {
    _equipos = [
      Equipo(
        id: '1',
        numero: '1',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel® Core™ i9 -14900 3.2 GHz',
        sistemaOperativo: 'Windows 11 Pro',
        marca: 'FURY',
        memoriaRAM: '32 GB',
        discoDuro: '1 TB SSD',
        estado: 'BUENO',
        monitor: 'Teros 27"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: 'Multifuncional Epson EcoTank L5590',
        ip: '182.18.8.44',
      ),
      Equipo(
        id: '2',
        numero: '2',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel® Core™ i7 -8700 3.2GHz',
        sistemaOperativo: 'Windows 10 Pro',
        marca: 'Antrix',
        memoriaRAM: '16 GB',
        discoDuro: '930 GB HDD',
        estado: 'REGULAR',
        monitor: 'LG 24"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: '',
        ip: '182.18.8.204',
      ),
      Equipo(
        id: '3',
        numero: '3',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel® Core™ i7-13700 2.1GHz',
        sistemaOperativo: 'Windows 11 Pro',
        marca: 'ALLWIYA',
        memoriaRAM: '32 GB',
        discoDuro: '1.5 TB HDD',
        estado: 'REGULAR',
        monitor: 'SAMSUNG 32"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: 'Multifuncional Epson EcoTank L5590',
        ip: '182.18.8.156',
      ),
      Equipo(
        id: '35',
        numero: '35',
        oficina: 'INFRAESTRUCTURA',
        tipo: 'LAPTOP',
        microprocesador: 'Intel® Core™ i9-13900 2.00GHz',
        sistemaOperativo: 'Windows 11 Pro',
        marca: 'HP OMEN',
        memoriaRAM: '32 GB',
        discoDuro: '950 GB SSD',
        estado: 'BUENO',
        monitor: 'LG 15.6"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: 'XEROX 350',
        ip: '182.18.8.120',
      ),
      Equipo(
        id: '176',
        numero: '176',
        oficina: 'AREA DE INFORMATICA',
        tipo: 'SERVIDOR',
        microprocesador: 'Intel(R) xeon(R) Silver 4208 CPU@ 2.1 Ghz',
        sistemaOperativo: 'Windows Server 2016',
        marca: 'DELLEMC',
        memoriaRAM: '32 GB',
        discoDuro: '1 TB SAS',
        estado: 'BUENO',
        monitor: 'SAMSUNG 22"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: '',
        ip: '8',
      ),
    ];
  }

  void login(String usuario, String contrasena) {
    if (usuario == 'admin' && contrasena == 'admin123') {
      _isAdmin = true;
      _usuarioActual = 'Administrador';
    } else if (usuario == 'usuario' && contrasena == 'user123') {
      _isAdmin = false;
      _usuarioActual = 'Usuario Visualizador';
    } else {
      throw Exception('Credenciales incorrectas');
    }
    notifyListeners();
  }

  void logout() {
    _isAdmin = false;
    _usuarioActual = '';
    notifyListeners();
  }

  void agregarEquipo(Equipo equipo) {
    _equipos.add(equipo);
    notifyListeners();
  }

  void editarEquipo(String id, Equipo equipoActualizado) {
    final index = _equipos.indexWhere((equipo) => equipo.id == id);
    if (index != -1) {
      _equipos[index] = equipoActualizado;
      notifyListeners();
    }
  }

  void eliminarEquipo(String id) {
    _equipos.removeWhere((equipo) => equipo.id == id);
    notifyListeners();
  }

  List<Equipo> buscarEquipos(String query) {
    if (query.isEmpty) return _equipos;
    return _equipos.where((equipo) {
      return equipo.oficina.toLowerCase().contains(query.toLowerCase()) ||
          equipo.tipo.toLowerCase().contains(query.toLowerCase()) ||
          equipo.microprocesador.toLowerCase().contains(query.toLowerCase()) ||
          equipo.marca.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Equipo> getEquiposPorOficina(String oficina) {
    return _equipos.where((equipo) => equipo.oficina == oficina).toList();
  }

  List<String> getOficinas() {
    return _equipos.map((e) => e.oficina).toSet().toList();
  }

  Map<String, int> getEstadisticas() {
    return {
      'total': _equipos.length,
      'pc': _equipos.where((e) => e.tipo == 'PC').length,
      'laptop': _equipos.where((e) => e.tipo == 'LAPTOP').length,
      'servidor': _equipos.where((e) => e.tipo == 'SERVIDOR').length,
      'bueno': _equipos.where((e) => e.estado == 'BUENO').length,
      'regular': _equipos.where((e) => e.estado == 'REGULAR').length,
      'malo': _equipos.where((e) => e.estado == 'MALO').length,
    };
  }
}
