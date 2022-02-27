import 'package:flutter/material.dart';
///commenti 
///test
class TextFieldCustomized extends StatefulWidget {
  final TextEditingController controller;
  final Color primaryColor;
  final bool isPassword;
  final IconData iconPrefix;
  final String labelText;
  final Function onChanged;
  final Function validator;

  const TextFieldCustomized(
      {Key key,
      this.controller,
      this.primaryColor = const Color(0xFF1B5E20),
      this.isPassword = false,
      this.iconPrefix,
      this.labelText = "",
      this.onChanged,
      this.validator})
      : super(key: key);

  @override
  State<TextFieldCustomized> createState() => _TextFieldCustomizedState();
}

class _TextFieldCustomizedState extends State<TextFieldCustomized> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        cursorColor: widget.primaryColor,
        onChanged: widget.onChanged,
        controller: widget.controller,
        validator: widget.validator != null
            ? (value) {
                return widget.validator(value);
              }
            : null,
        obscureText: _hidePassword && widget.isPassword,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(color: widget.primaryColor),
          prefixIcon: widget.iconPrefix == null
              ? null
              : Icon(widget.iconPrefix, color: widget.primaryColor),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: _hidePassword
                      ? Icon(Icons.visibility_off, color: widget.primaryColor)
                      : Icon(Icons.visibility, color: widget.primaryColor),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.primaryColor),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ));
  }
}
