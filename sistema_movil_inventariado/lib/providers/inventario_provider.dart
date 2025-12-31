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
  int _nextId = 200;

  List<Equipo> get equipos => _equipos;
  bool get isAdmin => _isAdmin;
  String get usuarioActual => _usuarioActual;

  void _cargarDatosIniciales() {
    _equipos = [
      Equipo(
        id: 1,
        numero: '1',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel Core i9',
        sistemaOperativo: 'Windows 11',
        marca: 'HP',
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
        id: 2,
        numero: '2',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel Core i7',
        sistemaOperativo: 'Windows 10',
        marca: 'Dell',
        memoriaRAM: '16 GB',
        discoDuro: '500 GB HDD',
        estado: 'REGULAR',
        monitor: 'LG 24"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: '',
        ip: '182.18.8.204',
      ),
      Equipo(
        id: 3,
        numero: '3',
        oficina: 'CATASTRO',
        tipo: 'PC',
        microprocesador: 'Intel Core i7',
        sistemaOperativo: 'Windows 11',
        marca: 'Lenovo',
        memoriaRAM: '32 GB',
        discoDuro: '1 TB HDD',
        estado: 'REGULAR',
        monitor: 'SAMSUNG 32"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: 'Multifuncional Epson EcoTank L5590',
        ip: '182.18.8.156',
      ),
      Equipo(
        id: 35,
        numero: '35',
        oficina: 'INFRAESTRUCTURA',
        tipo: 'LAPTOP',
        microprocesador: 'Intel Core i9',
        sistemaOperativo: 'Windows 11',
        marca: 'HP',
        memoriaRAM: '32 GB',
        discoDuro: '512 GB SSD',
        estado: 'BUENO',
        monitor: 'LG 15.6"',
        sede: 'PRINCIPAL',
        escaner: 'NO',
        impresoras: 'XEROX 350',
        ip: '182.18.8.120',
      ),
      Equipo(
        id: 176,
        numero: '176',
        oficina: 'AREA DE INFORMATICA',
        tipo: 'SERVIDOR',
        microprocesador: 'Intel Xeon',
        sistemaOperativo: 'Windows 10',
        marca: 'Dell',
        memoriaRAM: '32 GB',
        discoDuro: '1 TB SSD',
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
    final nuevoEquipo = Equipo(
      id: _nextId++,
      numero: equipo.numero,
      oficina: equipo.oficina,
      tipo: equipo.tipo,
      microprocesador: equipo.microprocesador,
      sistemaOperativo: equipo.sistemaOperativo,
      marca: equipo.marca,
      memoriaRAM: equipo.memoriaRAM,
      discoDuro: equipo.discoDuro,
      estado: equipo.estado,
      monitor: equipo.monitor,
      sede: equipo.sede,
      escaner: equipo.escaner,
      impresoras: equipo.impresoras,
      ip: equipo.ip,
    );
    _equipos.add(nuevoEquipo);
    notifyListeners();
  }

  void editarEquipo(int id, Equipo equipoActualizado) {
    final index = _equipos.indexWhere((equipo) => equipo.id == id);
    if (index != -1) {
      _equipos[index] = equipoActualizado;
      notifyListeners();
    }
  }

  void eliminarEquipo(int id) {
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
