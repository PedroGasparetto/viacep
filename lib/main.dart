import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Construindo MyApp');
    return MaterialApp(
      title: 'CEP App',
      home: CepListScreen(),
    );
  }
}

class CepListScreen extends StatefulWidget {
  @override
  _CepListScreenState createState() => _CepListScreenState();
}

class _CepListScreenState extends State<CepListScreen> {
  List<String> ceps = [];
  String currentCep = "";
  TextEditingController cepController = TextEditingController();
  Map<String, dynamic> cepData = {};
  String error = "";
  bool _isLoading = false;

  Future<void> fetchCep() async {
    print('Iniciando fetchCep');

    if (currentCep.isEmpty || currentCep.length != 8) {
      print('CEP inválido');
      setState(() {
        error = "Por favor, insira um CEP válido.";
        _isLoading = false;
      });
      return; // Isso interromperá a execução de fetchCep se o CEP for inválido
    }

    setState(() {
      _isLoading = true;
      error = "";
    });

    try {
      print('Realizando chamada de rede para CEP: $currentCep');
      final response = await http
          .get(Uri.parse('https://viacep.com.br/ws/$currentCep/json/'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('Resposta recebida. Conteúdo: ${response.body}');
        final data = json.decode(response.body);
        cepData = data;
        ceps.add(data['cep']);
      } else {
        print(
            'Erro na resposta da API. Código de status: ${response.statusCode}');
        setState(() {
          error = "Erro na resposta da API";
        });
      }
    } catch (e) {
      print('Erro na chamada de rede: $e');
      setState(() {
        error = "Erro na chamada de rede: $e";
      });
    } finally {
      print('Finalizando fetchCep');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Construindo CepListScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('CEP App'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: cepController,
              decoration: InputDecoration(labelText: 'Digite um CEP'),
              keyboardType: TextInputType.number,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Adicionado async aqui
              print('Botão pressionado');
              setState(() {
                currentCep = cepController.text;
                cepController.clear();
              });
              await fetchCep(); // Adicionado await aqui
            },
            child: Text('Consultar CEP'),
          ),
          if (error.isNotEmpty)
            Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
          if (ceps.isNotEmpty)
            Column(
              children: <Widget>[
                Text('CEP Consultado: ${cepData['cep']}'),
                Text('Logradouro: ${cepData['logradouro']}'),
                Text('Bairro: ${cepData['bairro']}'),
                Text('Cidade: ${cepData['localidade']}'),
                Text('Estado: ${cepData['uf']}'),
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: ceps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ceps[index]),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
