class Equipo {
  final int? id;
  final String numero;
  final String oficina;
  final String tipo;
  final String microprocesador;
  final String sistemaOperativo;
  final String marca;
  final String memoriaRAM;
  final String discoDuro;
  final String estado;
  final String monitor;
  final String sede;
  final String escaner;
  final String impresoras;
  final String ip;

  Equipo({
    this.id,
    required this.numero,
    required this.oficina,
    required this.tipo,
    required this.microprocesador,
    required this.sistemaOperativo,
    required this.marca,
    required this.memoriaRAM,
    required this.discoDuro,
    required this.estado,
    required this.monitor,
    required this.sede,
    required this.escaner,
    required this.impresoras,
    required this.ip,
  });

  // Convertir a Map para almacenamiento local
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'oficina': oficina,
      'tipo': tipo,
      'microprocesador': microprocesador,
      'sistemaOperativo': sistemaOperativo,
      'marca': marca,
      'memoriaRAM': memoriaRAM,
      'discoDuro': discoDuro,
      'estado': estado,
      'monitor': monitor,
      'sede': sede,
      'escaner': escaner,
      'impresoras': impresoras,
      'ip': ip,
    };
  }

  // Crear desde Map (almacenamiento local)
  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? ''),
      numero: map['numero'] ?? '',
      oficina: map['oficina'] ?? '',
      tipo: map['tipo'] ?? '',
      microprocesador: map['microprocesador'] ?? '',
      sistemaOperativo: map['sistemaOperativo'] ?? '',
      marca: map['marca'] ?? '',
      memoriaRAM: map['memoriaRAM'] ?? '',
      discoDuro: map['discoDuro'] ?? '',
      estado: map['estado'] ?? '',
      monitor: map['monitor'] ?? '',
      sede: map['sede'] ?? '',
      escaner: map['escaner'] ?? '',
      impresoras: map['impresoras'] ?? '',
      ip: map['ip'] ?? '',
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero': numero,
      'oficina': oficina,
      'tipo': tipo,
      'microprocesador': microprocesador,
      'sistema_operativo': sistemaOperativo,
      'marca': marca,
      'memoria_ram': memoriaRAM,
      'disco_duro': discoDuro,
      'estado': estado,
      'monitor': monitor,
      'sede': sede,
      'escaner': escaner,
      'impresoras': impresoras,
      'ip': ip,
    };
  }

  // Crear desde JSON del backend (snake_case)
  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      numero: json['numero']?.toString() ?? '',
      oficina: json['oficina']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      microprocesador: json['microprocesador']?.toString() ?? '',
      sistemaOperativo: json['sistema_operativo']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      memoriaRAM: json['memoria_ram']?.toString() ?? '',
      discoDuro: json['disco_duro']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'BUENO',
      monitor: json['monitor']?.toString() ?? '',
      sede: json['sede']?.toString() ?? 'PRINCIPAL',
      escaner: json['escaner']?.toString() ?? 'NO',
      impresoras: json['impresoras']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
    );
  }

  // CopyWith para crear copias modificadas
  Equipo copyWith({
    int? id,
    String? numero,
    String? oficina,
    String? tipo,
    String? microprocesador,
    String? sistemaOperativo,
    String? marca,
    String? memoriaRAM,
    String? discoDuro,
    String? estado,
    String? monitor,
    String? sede,
    String? escaner,
    String? impresoras,
    String? ip,
  }) {
    return Equipo(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      oficina: oficina ?? this.oficina,
      tipo: tipo ?? this.tipo,
      microprocesador: microprocesador ?? this.microprocesador,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
      marca: marca ?? this.marca,
      memoriaRAM: memoriaRAM ?? this.memoriaRAM,
      discoDuro: discoDuro ?? this.discoDuro,
      estado: estado ?? this.estado,
      monitor: monitor ?? this.monitor,
      sede: sede ?? this.sede,
      escaner: escaner ?? this.escaner,
      impresoras: impresoras ?? this.impresoras,
      ip: ip ?? this.ip,
    );
  }

  @override
  String toString() {
    return 'Equipo{id: $id, numero: $numero, oficina: $oficina, tipo: $tipo}';
  }
}
