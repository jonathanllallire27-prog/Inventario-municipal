import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/equipo.dart';

class ApiService {
  // URL del servidor backend
  // Usar la IP de la computadora para conectar desde dispositivos en la red local
  static const String baseUrl = 'http://200.37.187.246:3000/api';

  String? _token;
  Map<String, dynamic>? _currentUser;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _currentUser?['rol'] == 'admin';

  // Headers con autorización
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ==================== AUTENTICACIÓN ====================

  /// Login con usuario y contraseña
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['data']['token'];
        _currentUser = data['data']['user'];
        return {
          'success': true,
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error de autenticación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Cerrar sesión
  void logout() {
    _token = null;
    _currentUser = null;
  }

  /// Verificar si el token es válido
  Future<bool> verifyToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== EQUIPOS ====================

  /// Obtener todos los equipos
  Future<List<Equipo>> getEquipos({
    String? oficina,
    String? tipo,
    String? estado,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (oficina != null && oficina != 'Todas') {
        queryParams['oficina'] = oficina;
      }
      if (tipo != null) queryParams['tipo'] = tipo;
      if (estado != null) queryParams['estado'] = estado;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/equipos').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> equiposJson = data['data'];
          return equiposJson.map((json) => Equipo.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo equipos: $e');
      return [];
    }
  }

  /// Obtener estadísticas
  Future<Map<String, int>> getEstadisticas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final stats = data['data'];
          return {
            'total': stats['total'] ?? 0,
            'pc': stats['pc'] ?? 0,
            'laptop': stats['laptop'] ?? 0,
            'servidor': stats['servidor'] ?? 0,
            'bueno': stats['bueno'] ?? 0,
            'regular': stats['regular'] ?? 0,
            'malo': stats['malo'] ?? 0,
          };
        }
      }
      return {
        'total': 0,
        'pc': 0,
        'laptop': 0,
        'servidor': 0,
        'bueno': 0,
        'regular': 0,
        'malo': 0
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'total': 0,
        'pc': 0,
        'laptop': 0,
        'servidor': 0,
        'bueno': 0,
        'regular': 0,
        'malo': 0
      };
    }
  }

  /// Obtener lista de oficinas
  Future<List<String>> getOficinas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/oficinas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo oficinas: $e');
      return [];
    }
  }

  /// Obtener un equipo por ID
  Future<Equipo?> getEquipo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Equipo.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo equipo: $e');
      return null;
    }
  }

  /// Crear nuevo equipo
  Future<Map<String, dynamic>> crearEquipo(Equipo equipo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos'),
        headers: _headers,
        body: jsonEncode(equipo.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'equipo': Equipo.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear equipo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Actualizar equipo
  Future<Map<String, dynamic>> actualizarEquipo(int id, Equipo equipo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
        body: jsonEncode(equipo.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'equipo': Equipo.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar equipo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Eliminar equipo
  Future<Map<String, dynamic>> eliminarEquipo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': 'Equipo eliminado exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar equipo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Verificar conexión con el servidor
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
