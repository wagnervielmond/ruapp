class Acesso {
  final int id;
  final DateTime dataHora;
  final String status;
  final double custo;
  final String metodoPagamento;
  final String? turnoRefeicao;

  Acesso({
    required this.id,
    required this.dataHora,
    required this.status,
    required this.custo,
    required this.metodoPagamento,
    this.turnoRefeicao,
  });

  factory Acesso.fromJson(Map<String, dynamic> json) {
    return Acesso(
      id: json['id'] as int,
      dataHora: DateTime.parse(json['data_hora_requisicao'] as String),
      status: json['status'] as String,
      custo: double.parse(json['custo_cobrado'].toString()),
      metodoPagamento: json['metodo_pagamento'] as String,
      turnoRefeicao: json['turno_refeicao'] as String?,
    );
  }

  // Método para converter para Map (útil para debug)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_hora_requisicao': dataHora.toIso8601String(),
      'status': status,
      'custo_cobrado': custo,
      'metodo_pagamento': metodoPagamento,
      'turno_refeicao': turnoRefeicao,
    };
  }
}