class DashboardData {
  final int totalChamados;
  final int chamadosPendentes;
  final int chamadosConcluidos;
  final double taxaSucesso;

  DashboardData({
    required this.totalChamados,
    required this.chamadosPendentes,
    required this.chamadosConcluidos,
    required this.taxaSucesso,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalChamados: json['total'] ?? 0,
      chamadosPendentes: json['pendentes'] ?? 0,
      chamadosConcluidos: json['concluidos'] ?? 0,
      taxaSucesso: (json['taxaSucesso'] ?? 0).toDouble(),
    );
  }

  // Para quando a API não estiver disponível
  factory DashboardData.empty() {
    return DashboardData(
      totalChamados: 0,
      chamadosPendentes: 0,
      chamadosConcluidos: 0,
      taxaSucesso: 0,
    );
  }
}