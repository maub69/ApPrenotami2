import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mia_prima_app/TextFieldCustomized.dart';
import 'package:mia_prima_app/model.dart';
import 'package:mia_prima_app/utility/endpoint.dart';
import 'package:mia_prima_app/utility/utility.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordState();
  }
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailController = TextEditingController();
  bool _isNotDisabled = false;
  BuildContext _buildContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return Model(
      textAppBar: "Reset password",
      body: ListView(
        children: [
          Padding(
              padding: EdgeInsets.only(top: 15),
              child: CachedNetworkImage(
                imageUrl:
                    EndPoint.getUrl(EndPoint.LOGO) + Utility.idApp + ".png",
                height: 200,
                fadeInDuration: Duration(seconds: 0),
              )),
          Container(
            padding: EdgeInsets.only(top: 25, left: 10, right: 10),
            child: Text(
                "Inserisci la mail con cui è stata effettuata la registrazione.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.justify),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
            child: TextFieldCustomized(
              controller: _emailController,
              iconPrefix: Icons.mail,
              isPassword: false,
              labelText: "Email",
              onChanged: (value) {
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = new RegExp(pattern);
                setState(() {
                  _isNotDisabled = regex.hasMatch(value.trim());
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
            child: Text(
                "Ti verranno inviate le istruzioni per il reset della password.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.justify),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.green[900],
                    textStyle: TextStyle(color: Colors.white)),
                child: Text('Richiesta reset'),
                onPressed: _isNotDisabled
                    ? () {
                        http.post(
                            Uri.parse(EndPoint.getUrl(EndPoint.RESET_PASSWORD)),
                            body: {
                              "email": _emailController.text.trim(),
                            });
                        Utility.displaySnackBar(
                            "Richiesta di reset inviata",
                            _buildContext);
                        Navigator.pop(_buildContext);
                      }
                    : null),
          ),
        ],
      ),
    );
  }
}
