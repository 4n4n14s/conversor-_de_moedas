import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=1010117a';

void main() async {
  runApp(MaterialApp(
    home: const HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            hintStyle: TextStyle(color: Colors.amber),
            labelStyle: TextStyle(color: Colors.amber))),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final realContoler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _realchanged(String text) {
    double real = double.parse(text);
    
    dolarControler.text = (real / dolar!).toStringAsFixed(2);
    euroController.text = (real / euro!).toStringAsFixed(2);

    if (text.isEmpty) {
      _clearAll();
      return;
    }
  }

  void _dolarchanged(String text) {
    
    double dolar = double.parse(text);
    realContoler.text = (dolar / this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);

    if (text.isEmpty) {
      _clearAll();
      return;
    }
  }

  void _eurochanged(String text) {
    
    double euro = double.parse(text);
    realContoler.text = (euro * this.euro!).toStringAsFixed(2);
    dolarControler.text = (euro * this.euro! / dolar!).toStringAsFixed(2);

    if (text.isEmpty) {
      _clearAll();
      return;
    }
  }

  _clearAll() {
    realContoler.text = '';
    dolarControler.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Coversor de Moedas',
          style: TextStyle(color: Colors.amber),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                    child: Text(
                  'Carregando Dados',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'Erro ao Carregar os Dados',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                  euro = snapshot.data!['results']['currencies']['EUR']['buy'];
                  return Container(
                    padding: const EdgeInsets.all(25),
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.amber,
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          buildTextFil(
                              'Reais', 'R\$ ', realContoler, _realchanged),
                          const SizedBox(height: 10),
                          buildTextFil(
                              'Dolar', 'USD ', dolarControler, _dolarchanged),
                          const SizedBox(height: 10),
                          buildTextFil(
                              'Euro', '€ ', euroController, _eurochanged),
                        ],
                      ),
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFil(String label, String prefix, TextEditingController control,
    void Function(String) calculaValores) {
  return TextField(
    controller: control,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelStyle: const TextStyle(color: Colors.amber),
      labelText: label,
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    onChanged: calculaValores,
  );
}
