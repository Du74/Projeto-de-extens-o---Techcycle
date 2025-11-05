// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // LOGIN
  static Future<http.Response> login(String email, String senha) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // REGISTRO
  static Future<http.Response> register(String email, String senha) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({'email': email, 'senha': senha}),
      );
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // BUSCAR CHAMADOS
  static Future<http.Response> getChamados() async {
    try {
      return await http.get(
        Uri.parse('$baseUrl/chamados'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erro ao buscar chamados: $e');
    }
  }

  // CRIAR CHAMADO
  static Future<http.Response> createChamado(Map<String, dynamic> chamado) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/chamados'),
        headers: headers,
        body: jsonEncode(chamado),
      );
    } catch (e) {
      throw Exception('Erro ao criar chamado: $e');
    }
  }

  // DELETAR CHAMADO
  static Future<http.Response> deleteChamado(int id) async {
    try {
      return await http.delete(
        Uri.parse('$baseUrl/chamados/$id'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erro ao deletar chamado: $e');
    }
  }

  // LIMPAR TODOS CHAMADOS
  static Future<http.Response> deleteAllChamados() async {
    try {
      return await http.delete(
        Uri.parse('$baseUrl/chamados'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erro ao limpar chamados: $e');
    }
  }

  // BUSCAR ESTATÍSTICAS
  static Future<http.Response> getEstatisticas() async {
    try {
      return await http.get(
        Uri.parse('$baseUrl/estatisticas'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }
}