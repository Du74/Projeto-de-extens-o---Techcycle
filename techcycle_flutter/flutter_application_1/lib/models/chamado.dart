// models/chamado.dart
class Chamado {
  final int id;
  final String nomeChamado;
  final String tipo;
  final String marca;
  final DateTime dataAbertura;
  final String dashboard;
  final String problema;
  final String status;
  final String prioridade;
  final String? solucao;

  Chamado({
    required this.id,
    required this.nomeChamado,
    required this.tipo,
    required this.marca,
    required this.dataAbertura,
    required this.dashboard,
    required this.problema,
    this.status = 'Aberto',
    this.prioridade = 'Média',
    this.solucao,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome_chamado': nomeChamado,
      'tipo': tipo,
      'marca': marca,
      'data_abertura': dataAbertura.toIso8601String().split('T')[0],
      'dashboard': dashboard,
      'problema': problema,
      'prioridade': prioridade,
      'status': status,
      if (solucao != null) 'solucao': solucao,
    };
  }

  // Criar a partir de JSON
  factory Chamado.fromJson(Map<String, dynamic> json) {
    return Chamado(
      id: json['id'] ?? 0,
      nomeChamado: json['nome_chamado'] ?? '',
      tipo: json['tipo'] ?? '',
      marca: json['marca'] ?? '',
      dataAbertura: DateTime.parse(json['data_abertura'] ?? DateTime.now().toIso8601String()),
      dashboard: json['dashboard'] ?? '',
      problema: json['problema'] ?? '',
      status: json['status'] ?? 'Aberto',
      prioridade: json['prioridade'] ?? 'Média',
      solucao: json['solucao'],
    );
  }

  Chamado copyWith({
    int? id,
    String? nomeChamado,
    String? tipo,
    String? marca,
    DateTime? dataAbertura,
    String? dashboard,
    String? problema,
    String? status,
    String? prioridade,
    String? solucao,
  }) {
    return Chamado(
      id: id ?? this.id,
      nomeChamado: nomeChamado ?? this.nomeChamado,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dashboard: dashboard ?? this.dashboard,
      problema: problema ?? this.problema,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      solucao: solucao ?? this.solucao,
    );
  }
}