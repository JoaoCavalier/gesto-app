import 'package:http/http.dart' as http;
import 'inter_http_client.dart';

class InterService {
  final InterHttpClient httpClient;

  InterService(this.httpClient);

  Future<http.Response> obterBoletos() async {
    final url = Uri.parse(
        'https://cdpj.partners.bancointer.com.br/banking/v2/extrato?dataInicio=2025-02-11&dataFim=2025-02-11');
    return await httpClient.get(url);
  }
}
