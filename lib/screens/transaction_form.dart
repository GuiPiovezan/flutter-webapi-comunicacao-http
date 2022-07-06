import 'dart:async';

import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transactions_auth_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionForm extends StatefulWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _valueController = TextEditingController();
  final TransactionWebClient _webClient = TransactionWebClient();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  widget.contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      final double value =
                          double.tryParse(_valueController.text);
                      final transactionCreated =
                          Transaction(value, widget.contact);
                      showDialog(
                        context: context,
                        builder: (_) => TransactionAuthDialog(
                          onConfirm: (String password) {
                            _save(transactionCreated, password);
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _save(Transaction transactionCreated, String password) async {
    Transaction transaction = await _send(transactionCreated, password);

    _showSuccessfulMessage(transaction);
  }

  Future<Transaction> _send(
      Transaction transactionCreated, String password) async {
    Transaction transaction =
        await _webClient.save(transactionCreated, password).catchError((ex) {
      _showFailureMessage(message: ex.message);
    }, test: (ex) => ex is HttpException).catchError((ex) {
      _showFailureMessage(message: 'timeout submitting the transaction');
    }, test: (ex) => ex is TimeoutException).catchError((ex) {
      _showFailureMessage();
    }, test: (ex) => ex is Exception);
    return transaction;
  }

  Future<void> _showSuccessfulMessage(Transaction transaction) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextSuccessful) {
            return SuccessDialog('successful transaction');
          });

      Navigator.pop(context);
    }
  }

  void _showFailureMessage({message = 'Unknown Error'}) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }
}
