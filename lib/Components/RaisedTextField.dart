import 'package:flutter/material.dart';


class RaisedTextField extends StatelessWidget {

  final Color colour;
  final String textForField;
  final Function onTap;

  RaisedTextField(this.colour, this.textForField, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: onTap,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            textForField,
            style: TextStyle(
              color: Colors.white
            )
          ),
        ),
      ),
    );
  }
}