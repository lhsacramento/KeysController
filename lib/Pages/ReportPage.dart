import 'package:flutter/material.dart';
import '../repositories/keys_repository.dart';

class ReportPage extends StatefulWidget {
  ReportPage({Key? key, required this.keyCode}) : super(key: key);
  String keyCode;
  @override
  State<ReportPage> createState() => _ReportPageState(keyCode);
}

class _ReportPageState extends State<ReportPage> {
  _ReportPageState(this.keyCode);
  String keyCode;
  KeysRepository keysRepository = KeysRepository();
  late List<Map<String,dynamic>> keys;

  @override
  void initState(){
    super.initState();
    keysRepository.getKeys().then((value) {
      setState((){
        keys = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Relatório da Chave: ${keyCode}'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: showReport(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> showReport(){
    List<Widget> information = [];
    keys.forEach((element) {
      if(element['Codigo'] == keyCode){
        for(int i = 0; i < element['Entradas'].length;  i++){
          List infEntradas = element['Entradas'][i].split('|');
          List infSaidas = element['Saidas'][i].split('|');
          information.add(const Text('Saída:',style: TextStyle(fontWeight: FontWeight.w700),),);
          information.add(
            Text(
              'Data/Hora: ${infSaidas[0]}\n'
              'Quem Retirou: ${infSaidas[1]}'
            ),
          );
          information.add(const SizedBox(height: 20,));
          information.add(const Text('Entrada:',style: TextStyle(fontWeight: FontWeight.w700),),);
          information.add(
            Text(
              'Data/Hora: ${infEntradas[0]}\n'
              'Quem Entregou: ${infEntradas[1]}\n'
              'Quem Recebeu: ${infEntradas[2]}'
            ),
          );
          information.add(const SizedBox(height: 20,));
        }
      }
    });
    return information;
  }
}
