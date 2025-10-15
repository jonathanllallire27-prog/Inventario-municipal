class Equipo {
  final String id;
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
    required this.id,
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

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'],
      numero: map['numero'],
      oficina: map['oficina'],
      tipo: map['tipo'],
      microprocesador: map['microprocesador'],
      sistemaOperativo: map['sistemaOperativo'],
      marca: map['marca'],
      memoriaRAM: map['memoriaRAM'],
      discoDuro: map['discoDuro'],
      estado: map['estado'],
      monitor: map['monitor'],
      sede: map['sede'],
      escaner: map['escaner'],
      impresoras: map['impresoras'],
      ip: map['ip'],
    );
  }
}
