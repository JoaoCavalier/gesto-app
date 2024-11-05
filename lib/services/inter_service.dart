import 'package:http/http.dart' as http;
import 'inter_http_client.dart';

class InterService {

  final InterHttpClient httpClient;

  InterService(this.httpClient);

  Future<http.Response> obterBoletos() async {
    final url = Uri.parse('https://cdpj.partners.bancointer.com.br/banking/v2/extrato?dataInicio=2024-05-20&dataFim=2024-05-22');
    return await httpClient.get(url);
  }

  // Outros métodos para consumir API do banco inter
  
}
