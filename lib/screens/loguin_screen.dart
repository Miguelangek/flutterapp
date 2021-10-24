import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animal_life_app/components/globals.dart';
import 'package:animal_life_app/components/loader_component.dart';

import 'package:animal_life_app/screens/home_screen.dart';
import 'package:animal_life_app/helpers/constans.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _user = '';
  String _userError = '';
  bool _rememberme = false;
  bool _userShowError = false;

  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _createWallpaper(context),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _loginForm(context),
              ],
            ),
          ),
          _showLoader
              ? LoaderComponent(text: 'Por favor espere...')
              : Container(),
        ],
      ),
    );
  }

  Widget _createWallpaper(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 0.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: FadeInImage(
                  placeholder: AssetImage('assets/Logo_AnimalLife.png'),
                  image: AssetImage('assets/Logo_AnimalLife.png'),
                  height: 450.0,
                ),
              ),
              SizedBox(height: 10.0, width: double.infinity),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
              height: 230.0,
            ),
          ),
          Container(
            width: size.width * 0.85,
            margin: EdgeInsets.symmetric(vertical: 30.0),
            padding: EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3.0,
                    offset: Offset(0.0, 5.0),
                    spreadRadius: 3.0)
              ],
            ),
            child: Column(
              children: <Widget>[
                Column(children: [SizedBox(height: 20.0), _showUser()]),
                _showPassword(),
                SizedBox(height: 10.0),
                _showRemember(),
                SizedBox(height: 10.0),
                _showButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _showUser() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        //keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa tu usuario...',
          labelText: 'usuario',
          errorText: _userShowError ? _userError : null,
          prefixIcon: Icon(Icons.supervised_user_circle_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _user = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: 'Ingresa tu contraseña...',
          labelText: 'Contraseña',
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showButton() {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RaisedButton(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
              child: Text('Ingresar'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 0.0,
            color: gcolorBlue,
            textColor: Colors.white,
            onPressed: () {
              _login();
            });
      },
    );
  }

  void _login() async {
    changeLoader();

    setState(() {
      _passwordShow = false;
    });
    if (!_validateFields()) {
      changeLoader();
      return;
    }
    if (!(await checkConection(context))) {
      changeLoader();
      return;
    }
    try {
      var url = Uri.parse(
          '${Constans.apiUrl}/LogIN?UserName=$_user&password=$_password');
      http.Response response = await http.post(url);

      if (!(await statusResponse(context, response))) return;

      String body = response.body;
      var decodedJson = jsonDecode(body);

//autenticacion de que ul usuario es valido
      if (decodedJson) {
        changeLoader();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        alertaWarning(
            context, 'Ha ocurrido un error, intenta de nuevo', 'Error');
        changeLoader();
        return;
      }
      changeLoader();
    } catch (e) {
      changeLoader();
    }
  }

  bool _validateFields() {
    bool isValid = true;

    if (_user.isEmpty) {
      isValid = false;
      _userShowError = true;
      _userError = 'Debes ingresar tu Usuario.';
    } else {
      _userShowError = false;
    }

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu contraseña.';
    } else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError =
          'Debes ingresar una contraseña de al menos 6 carácteres.';
    } else {
      _passwordShowError = false;
    }
    return isValid;
  }

  void changeLoader() {
    setState(() {
      _showLoader = !_showLoader;
    });
  }

  Widget _showRemember() {
    return CheckboxListTile(
      checkColor: Colors.white,
      tileColor: gcolorBlue,
      title: Text("Recuerdame",
          textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
      value: _rememberme,
      onChanged: (newValue) {
        setState(
          () {},
        );
      },
    );
  }
}
