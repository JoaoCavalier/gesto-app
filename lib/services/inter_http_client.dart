import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/services.dart';

class InterHttpClient {
  static const String _crtFile = "assets/Inter API_Certificado.crt";
  static const String _keyFile = "assets/Inter API_Chave.key";
  static const String _passphrase =
      'your_passphrase'; // Troque pela senha (se houver)
  static const String _clientId =
      'f52154d4-de91-47ba-b8b8-b8bf02dba593'; // Troque pelo client_id
  static const String _clientSecret =
      '8dc1f647-f522-4300-9fa7-0198fd782175'; // Troque pela secret
  static const String _tokenUrl =
      'https://cdpj.partners.bancointer.com.br/oauth/v2/token';

  http.Client? _client;
  String? _accessToken;

  Future<http.Client> _createClient() async {
    if (_client == null) {
      final securityContext = SecurityContext(withTrustedRoots: true);

      // Carregar o certificado e a chave privada
      final crtData = await rootBundle.loadString(_crtFile);
      final crtBytes = crtData.codeUnits;
      final keyData = await rootBundle.load(_keyFile);

      securityContext.useCertificateChainBytes(crtBytes);
      securityContext.usePrivateKeyBytes(keyData.buffer.asUint8List(),
          password: _passphrase);

      final httpClient = HttpClient(context: securityContext);
      _client = IOClient(httpClient);
    }
    return _client!;
  }

  Future<void> authenticate() async {
    final client = await _createClient();

    final response = await client.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'client_credentials',
        'scope': 'extrato.read',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      _accessToken = jsonResponse['access_token'];
      print('Access Token obtido com sucesso: $_accessToken');
    } else {
      print(
          'Erro ao obter access token: ${response.statusCode} - ${response.body}');
      throw Exception(
          'Failed to obtain access token: ${response.reasonPhrase}');
    }
  }

  Future<http.Response> get(Uri url) async {
    await authenticate();
    final client = await _createClient();
    final response = await client.get(url, headers: {
      'Authorization': 'Bearer $_accessToken',
    });

    print('Resposta da API: ${response.statusCode} - ${response.body}');
    return response;
  }
}
