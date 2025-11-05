import 'package:flutter/material.dart';
import 'dart:convert';
import '../../utils/constants.dart';
import '../../models/chamado.dart';
import '../../models/dashboard_data.dart';
import '../../services/api_service.dart';
import 'novo_chamado_page.dart';
import '../auth/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Chamado> _chamados = [];
  DashboardData _dashboardData = DashboardData.empty();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarDadosReais();
  }

  void _carregarDadosReais() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Carregar chamados da API
      final responseChamados = await ApiService.getChamados();
      if (responseChamados.statusCode == 200) {
        final List<dynamic> data = json.decode(responseChamados.body);
        _chamados = data.map((json) => Chamado.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao carregar chamados');
      }

      // Carregar estatísticas da API
      final responseEstatisticas = await ApiService.getEstatisticas();
      if (responseEstatisticas.statusCode == 200) {
        final data = json.decode(responseEstatisticas.body);
        _dashboardData = DashboardData.fromJson(data);
      } else {
        throw Exception('Erro ao carregar estatísticas');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
      });
      // Fallback para dados locais se API falhar
      _carregarDadosLocais();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _carregarDadosLocais() {
    // Dados de exemplo caso a API não esteja disponível
    _chamados = [
      Chamado(
        id: 1,
        nomeChamado: 'Impressora LaserJet',
        tipo: 'Impressora',
        marca: 'HP',
        dataAbertura: DateTime.now().subtract(const Duration(days: 2)),
        dashboard: 'Setor TI - Andar 2',
        problema: 'Não está imprimindo',
        status: 'Aberto',
        prioridade: 'Alta',
      ),
    ];
    _atualizarEstatisticas();
  }

  void _adicionarChamado(Chamado novoChamado) async {
    try {
      final response = await ApiService.createChamado(novoChamado.toJson());
      
      if (response.statusCode == 200) {
        _carregarDadosReais(); // ← CORRIGIDO: removido await
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamado registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erro ao criar chamado');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar chamado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _atualizarEstatisticas() {
    setState(() {
      _dashboardData = DashboardData(
        totalChamados: _chamados.length,
        chamadosPendentes: _chamados.where((c) => c.status == 'Aberto').length,
        chamadosConcluidos: _chamados.where((c) => c.status == 'Concluído').length,
        taxaSucesso: _chamados.isNotEmpty ? (_chamados.where((c) => c.status == 'Concluído').length / _chamados.length * 100) : 0,
      );
    });
  }

  void _limparTodosChamados() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF323232),
        title: const Text(
          'Confirmar Limpeza',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          'Tem certeza que deseja deletar TODOS os ${_chamados.length} chamados? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.deleteAllChamados();
        
        if (response.statusCode == 200) {
          _carregarDadosReais(); // ← CORRIGIDO: removido await
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todos os chamados foram removidos!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Erro ao limpar chamados');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar chamados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deletarChamado(int id) async {
    try {
      final response = await ApiService.deleteChamado(id);
      
      if (response.statusCode == 200) {
        _carregarDadosReais(); // ← CORRIGIDO: removido await
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamado deletado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erro ao deletar chamado');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar chamado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // MANTENHA TODO O RESTO DO CÓDIGO DO DASHBOARD ORIGINAL
  // _buildSidebar, _buildHeader, _buildContent, etc...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.tertiary))
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, color: Colors.red, size: 50),
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _carregarDadosReais,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.tertiary,
                                        foregroundColor: AppColors.primary,
                                      ),
                                      child: const Text('Tentar Novamente'),
                                    ),
                                  ],
                                ),
                              )
                            : _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // COLE AQUI TODAS AS OUTRAS FUNÇÕES DO SEU DASHBOARD ORIGINAL:
  // _buildSidebar, _buildMenuItem, _buildHeader, _buildContent,
  // _buildStatsGrid, _buildStatCard, _buildChamadoForm, 
  // _buildChamadosRecentes, _buildChamadoItem, etc.

  // EXEMPLO (substitua pelas suas funções originais):
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(right: BorderSide(color: AppColors.tertiary.withOpacity(0.3))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.tertiary.withOpacity(0.3))),
            ),
            child: Column(
              children: [
                const Icon(Icons.recycling, size: 40, color: AppColors.tertiary),
                const SizedBox(height: 8),
                const Text(
                  'TechCycle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiary,
                  ),
                ),
                Text(
                  '${_chamados.length} chamados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMenuItem(Icons.dashboard, 'Dashboard', true),
                  _buildMenuItem(Icons.add_circle, 'Novo Chamado', false, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovoChamadoPage(onChamadoCriado: _adicionarChamado),
                      ),
                    );
                  }),
                  _buildMenuItem(Icons.list, 'Meus Chamados', false, onTap: _mostrarTodosChamados),
                  _buildMenuItem(Icons.bar_chart, 'Relatórios', false),
                  _buildMenuItem(Icons.settings, 'Configurações', false),
                  const Spacer(),
                  _buildMenuItem(Icons.cleaning_services, 'Limpar Chamados', false, 
                    color: Colors.orange,
                    onTap: _limparTodosChamados,
                  ),
                  _buildMenuItem(Icons.exit_to_app, 'Sair', false, onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, bool isActive, {Color? color, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? (isActive ? AppColors.tertiary : Colors.white70)),
        title: Text(
          text,
          style: TextStyle(
            color: color ?? (isActive ? AppColors.tertiary : Colors.white70),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isActive ? AppColors.tertiary.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }

  void _mostrarTodosChamados() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF323232),
        title: const Text(
          'Todos os Chamados',
          style: TextStyle(color: AppColors.tertiary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _chamados.length,
            itemBuilder: (context, index) {
              final chamado = _chamados[index];
              return _buildChamadoItemCompleto(chamado);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildChamadoItemCompleto(Chamado chamado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chamado.nomeChamado,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${chamado.tipo} • ${chamado.marca} • ${_formatarData(chamado.dataAbertura)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  chamado.problema,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildStatusChip(chamado.status, chamado.id),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: () => _deletarChamado(chamado.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, int chamadoId) {
    Color statusColor = Colors.orange;
    
    if (status == 'Concluído') statusColor = Colors.green;
    if (status == 'Processando') statusColor = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        border: Border(bottom: BorderSide(color: AppColors.tertiary.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard de Gestão',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                _buildHeaderStat('Total', _dashboardData.totalChamados.toString()),
                _buildHeaderStat('Pendentes', _dashboardData.chamadosPendentes.toString()),
                _buildHeaderStat('Concluídos', _dashboardData.chamadosConcluidos.toString()),
                _buildHeaderStat('Sucesso', '${_dashboardData.taxaSucesso.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.tertiary.withOpacity(0.4)),
            ),
            child: const Icon(Icons.person, color: AppColors.tertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.tertiary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildStatsGrid(),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildChamadoForm(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: _buildChamadosRecentes(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      children: [
        _buildStatCard('Total de Chamados', _dashboardData.totalChamados.toString(), Icons.assignment, AppColors.tertiary),
        _buildStatCard('Pendentes', _dashboardData.chamadosPendentes.toString(), Icons.pending, Colors.orange),
        _buildStatCard('Concluídos', _dashboardData.chamadosConcluidos.toString(), Icons.check_circle, Colors.green),
        _buildStatCard('Taxa de Sucesso', '${_dashboardData.taxaSucesso.toStringAsFixed(1)}%', Icons.trending_up, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChamadoForm() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Novo Chamado de Descarte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildFormField('Nome do Equipamento', 'Ex: Impressora LaserJet'),
                const SizedBox(height: 16),
                _buildDropdownField('Tipo', ['Computador', 'Notebook', 'Impressora', 'Monitor', 'Outro']),
                const SizedBox(height: 16),
                _buildFormField('Marca', 'Ex: HP, Dell, Samsung'),
                const SizedBox(height: 16),
                _buildFormField('Localização', 'Ex: Setor TI - Andar 2'),
                const SizedBox(height: 16),
                _buildTextArea('Problema/Descrição', 'Descreva detalhadamente o problema...'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NovoChamadoPage(onChamadoCriado: _adicionarChamado),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Abrir Formulário Completo',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.first,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {},
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color(0xFF464646),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildChamadosRecentes() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF323232),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chamados Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _chamados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum chamado encontrado',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _chamados.length,
                    itemBuilder: (context, index) {
                      final chamado = _chamados[index];
                      return _buildChamadoItem(chamado);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChamadoItem(Chamado chamado) {
    Color statusColor = Colors.orange;
    if (chamado.status == 'Concluído') statusColor = Colors.green;
    if (chamado.status == 'Processando') statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getChamadoIcon(chamado.tipo),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chamado.nomeChamado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chamado.tipo} • ${chamado.marca}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusChip(chamado.status, chamado.id),
              const SizedBox(height: 4),
              Text(
                _formatarData(chamado.dataAbertura),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getChamadoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'computador':
        return Icons.computer;
      case 'notebook':
        return Icons.laptop;
      case 'impressora':
        return Icons.print;
      case 'monitor':
        return Icons.monitor;
      default:
        return Icons.devices_other;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }
}