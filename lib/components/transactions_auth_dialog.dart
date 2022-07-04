import 'package:flutter/material.dart';

class TransactionAuthDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Autenticate'),
      content: TextField(
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        style: TextStyle(
          fontSize: 64,
          letterSpacing: 32,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            print('cancel');
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            print('confirm');
          },
          child: Text('Confirm'),
        )
      ],
    );
  }
}
