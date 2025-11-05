import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/chamado.dart';

class NovoChamadoPage extends StatefulWidget {
  final Function(Chamado) onChamadoCriado;

  const NovoChamadoPage({super.key, required this.onChamadoCriado});

  @override
  State<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

class _NovoChamadoPageState extends State<NovoChamadoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _dashboardController = TextEditingController();
  final _problemaController = TextEditingController();
  final _solucaoController = TextEditingController();

  String _tipoSelecionado = 'Computador';
  String _prioridadeSelecionada = 'Média';
  DateTime _dataSelecionada = DateTime.now();

  final List<String> _tipos = [
    'Computador', 'Notebook', 'Impressora', 'Monitor', 
    'Roteador', 'Servidor', 'Periférico', 'Outro'
  ];

  final List<String> _prioridades = ['Baixa', 'Média', 'Alta', 'Urgente'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: const Color(0xFF282828),
        foregroundColor: Colors.white,
        title: const Text('Novo Chamado - TechCycle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: 800,
            decoration: BoxDecoration(
              color: const Color(0xFF323232),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_circle, color: AppColors.tertiary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrar Novo Chamado',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tertiary,
                          ),
                        ),
                        Text(
                          'Preencha os dados do equipamento para descarte',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Formulário
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Linha 1: Nome e Tipo
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              'Nome do Equipamento',
                              'Ex: Impressora LaserJet',
                              _nomeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, digite o nome do equipamento';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              'Tipo',
                              _tipoSelecionado,
                              _tipos,
                              (value) => setState(() => _tipoSelecionado = value!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Linha 2: Marca e Modelo
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              'Marca',
                              'Ex: HP, Dell, Samsung',
                              _marcaController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, digite a marca';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField(
                              'Modelo',
                              'Ex: LaserJet Pro MFP',
                              _modeloController,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Linha 3: Data e Prioridade
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              'Prioridade',
                              _prioridadeSelecionada,
                              _prioridades,
                              (value) => setState(() => _prioridadeSelecionada = value!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Localização
                      _buildFormField(
                        'Localização/Dashboard',
                        'Ex: Setor TI - Andar 2',
                        _dashboardController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite a localização';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Problema/Descrição
                      _buildTextArea(
                        'Problema/Descrição',
                        'Descreva detalhadamente o problema ou motivo do descarte...',
                        _problemaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, descreva o problema';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Solução Proposta
                      _buildTextArea(
                        'Solução Proposta (Opcional)',
                        'Descreva a solução proposta...',
                        _solucaoController,
                        lines: 2,
                      ),

                      const SizedBox(height: 32),

                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF464646),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back),
                                  SizedBox(width: 8),
                                  Text('Voltar'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _registrarChamado,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiary,
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registrar Chamado',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint, TextEditingController controller, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color(0xFF464646),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data do Descarte',
          style: TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.calendar_today, color: AppColors.tertiary),
            onTap: _selecionarData,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint, TextEditingController controller, {String? Function(String?)? validator, int lines = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF464646),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: lines,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.tertiary,
              onPrimary: Colors.black,
              surface: Color(0xFF323232),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF323232),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _registrarChamado() {
    if (_formKey.currentState!.validate()) {
      // Criar novo chamado
      final novoChamado = Chamado(
        id: DateTime.now().millisecondsSinceEpoch,
        nomeChamado: _nomeController.text,
        tipo: _tipoSelecionado,
        marca: _marcaController.text,
        dataAbertura: _dataSelecionada,
        dashboard: _dashboardController.text,
        problema: _problemaController.text,
        prioridade: _prioridadeSelecionada,
        solucao: _solucaoController.text.isNotEmpty ? _solucaoController.text : null,
      );

      // Chamar callback para adicionar o chamado
      widget.onChamadoCriado(novoChamado);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chamado registrado com sucesso!'),
          backgroundColor: AppColors.tertiary,
        ),
      );

      // Voltar para o dashboard
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _dashboardController.dispose();
    _problemaController.dispose();
    _solucaoController.dispose();
    super.dispose();
  }
}