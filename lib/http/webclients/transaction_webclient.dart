import 'dart:convert';

import 'package:bytebank/http/webclient.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  final baseUrl = Uri.parse('http://192.168.0.104:8080/transactions');

  Future<List<Transaction>> findAll() async {
    final Response response = await client.get(baseUrl);
    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction> save(Transaction transaction, String password) async {
    final String transactionJson = jsonEncode(transaction.toJson());

    final Response response = await client.post(baseUrl,
        headers: {
          'Content-type': 'application/json',
          'password': password,
        },
        body: transactionJson);

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    throw new HttpException(_getResponseMessage(response.statusCode));
  }

  String _getResponseMessage(int statusCode) {
    if (_statusCodeResponses.containsKey(statusCode)) {
      return _statusCodeResponses[statusCode];
    }

    return 'Unknown error';
  }

  static final Map<int, String> _statusCodeResponses = {
    400: 'there was error on submitting transaction',
    401: 'authentication failed',
    409: 'transaction already exists',
  };
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);
}
