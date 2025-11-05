import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chamado.dart';

class StorageService {
  static const String _chamadosKey = 'chamados';

  // Salvar lista de chamados
  static Future<void> salvarChamados(List<Chamado> chamados) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chamadosJson = chamados.map((chamado) => json.encode(chamado.toJson())).toList();
    await prefs.setStringList(_chamadosKey, chamadosJson);
  }

  // Carregar lista de chamados
  static Future<List<Chamado>> carregarChamados() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? chamadosJson = prefs.getStringList(_chamadosKey);
    
    if (chamadosJson == null) return [];
    
    return chamadosJson.map((jsonString) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return Chamado.fromJson(jsonMap);
    }).toList();
  }

  // Adicionar um chamado
  static Future<void> adicionarChamado(Chamado chamado) async {
    final List<Chamado> chamados = await carregarChamados();
    chamados.insert(0, chamado);
    await salvarChamados(chamados);
  }

  // Remover todos os chamados
  static Future<void> limparChamados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chamadosKey);
  }

  // Deletar um chamado específico
  static Future<void> deletarChamado(int id) async {
    final List<Chamado> chamados = await carregarChamados();
    chamados.removeWhere((chamado) => chamado.id == id);
    await salvarChamados(chamados);
  }
}