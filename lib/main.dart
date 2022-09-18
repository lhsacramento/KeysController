import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keys_controller/repositories/keys_repository.dart';
import 'package:date_format/date_format.dart';
import 'Pages/ReportPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp( const MaterialApp(
    home: Home(),
  )));


}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> keys = [];
  KeysRepository keysRepository = KeysRepository();
  late List<Map<String, dynamic>> keysAvailable;

  TextEditingController keyCode = TextEditingController();
  TextEditingController keyPassword = TextEditingController();
  TextEditingController accessPassword = TextEditingController();
  TextEditingController personRemovingKey = TextEditingController();
  TextEditingController personPuttingKey = TextEditingController();
  TextEditingController personReceivingKey = TextEditingController();

  String? keyCodeErrorText;
  String? keyPasswordErrorText;
  String? accessPasswordErrorText;
  String? personRemovingKeyErrorText;
  String? personPuttingKeyErrorText;
  String? personReceivingKeyErrorText;


  late String keyWithdrawalDate;

  @override
  void initState() {
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
          centerTitle: true,
          title: const Text('Controle de Chaves', style: TextStyle()),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ElevatedButton(onPressed: showDialogRemoveKey, child: const Text('Retirar chave')),
          ElevatedButton(onPressed: showDialogPutKey, child: const Text('Entregar chave')),
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child:
                        Text('Chaves Disponíveis', textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: drawAvailableKeys(keys),
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                border: Border.all(
                  width: 2,
                  color: Colors.black,
                ),
              ),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child:
                        Text('Chaves Retiradas', textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: drawUnavailableKeys(keys),
                    ),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(onPressed: generateReportKey, child: Text('Relatório de Chaves')),
        ]),
      ),
    );
  }

  void generateReportKey(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context,setState) {
              return AlertDialog(
                title: const Text(
                  'Gerar Relatório',
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children:  [
                      Text(
                        'Data do Relátório:\n${getDateTime()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                        ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: keyCode,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Código da Chave',
                          hintText: 'ex: A-01',
                          errorText: keyCodeErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: accessPassword,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Senha de acesso',
                          hintText: '',
                          errorText: accessPasswordErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPage(keyCode: keyCode.text)));
                          },
                          child: const Text(
                            'Gerar Relatório da Chave',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ))
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  List<Container> drawAvailableKeys(List<Map<String, dynamic>> keys) {
    List<Container> containers = [];

    keys.forEach((element) {
      if (element['Available'] == true) {
        containers.add(Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 30,
          color: Colors.green,
          alignment: Alignment.center,
          child: Text(
            '${element['Codigo']} | ${element['Setor']}',
            textAlign: TextAlign.center,
          ),
        ));
      }
    });

    return containers;
  }

  List<Container> drawUnavailableKeys(List<Map<String, dynamic>> keys) {
    List<Container> containers = [];

    keys.forEach((element) {
      if (element['Available'] == false) {
        containers.add(Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 35,
          color: Colors.redAccent,
          alignment: Alignment.center,
          child: Text(
            '${element['Codigo']} | ${element['Setor']}\n${element['Saidas'].last}',
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
    return containers;
  }

  void putKey(){
    for(Map<String,dynamic> key in keys){
      if(key['Codigo'] == keyCode.text){
        if(!key['Available']){
          key['Available'] = true;
          key['Entradas'].add('${keyWithdrawalDate} | '
              '${personPuttingKey.text.toUpperCase()} | '
              '${personReceivingKey.text.toUpperCase()}');
          keysRepository.saveKeys(keys);
          clearFields();
          showSnackBar('Chave entregue com sucesso!', true);
          attScreen();
          return;
        }else{
          showSnackBar('Não há saída para esta chave!', false);
          return;
        }
      }
    }
  }

  void showDialogPutKey(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context,setState) {
              return AlertDialog(
                title: const Text(
                  'Entregar Chave',
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children:  [
                      Text(
                        getDateTime(),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: keyCode,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Código da Chave',
                          hintText: 'ex: A-01',
                          errorText: keyCodeErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: personPuttingKey,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Quem está entregando',
                          hintText: 'ex: SO - Ivan',
                          errorText: personPuttingKeyErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: personReceivingKey,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Quem está recebendo',
                          hintText: '',
                          errorText: personReceivingKeyErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                          onPressed: (){
                            if(testFields('put')){
                              Navigator.of(context).pop();
                              putKey();
                            }else{
                              setState((){
                                attScreen();
                              });
                            }
                          },
                          child: const Text(
                            'Confirmar Entrega da Chave',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ))
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void removeKey(){
    for(Map<String,dynamic> key in keys){
      if(key['Codigo'] == keyCode.text){
        if(key['Available']){
          key['Available'] = false;
          key['Saidas'].add('${keyWithdrawalDate} | ${personRemovingKey.text.toUpperCase()}');
          keysRepository.saveKeys(keys);
          clearFields();
          showSnackBar('Chave retirada com sucesso!', true);
          attScreen();
          return;
        }else{
          clearFields();
          showSnackBar('Chave já retirada', false);
          return;
        }
      }

      if(key == keys.last){
        showSnackBar('Chave não registrada!', false);
        return;
      }
    }
  }

  void showSnackBar(String text, bool done){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            text,
            style: const TextStyle(
              color: Colors. white,
              fontSize: 12,
            ),
          ),
        backgroundColor: done ? Colors.green : Colors.red,
        duration: const Duration(seconds: 5),
      )
    );
  }

  void showDialogRemoveKey(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context,setState) {
              return AlertDialog(
                title: const Text(
                  'Retirar Chave',
                  textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children:  [
                      Text(
                        getDateTime(),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: keyCode,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Código da Chave',
                          hintText: 'ex: A-01',
                          errorText: keyCodeErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: personRemovingKey,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Pessoa que está retirando',
                          hintText: 'ex: SO - Ivan',
                          errorText: personRemovingKeyErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: keyPassword,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Senha caso precise',
                          hintText: '',
                          errorText: keyPasswordErrorText,
                        ),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton(
                          onPressed: (){
                            if(testFields('remove')){
                              Navigator.of(context).pop();
                              removeKey();
                            }
                            else{
                              setState((){
                                attScreen();
                              });
                            }
                          },
                          child: const Text(
                            'Confirmar Retirada da Chave',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ))
                    ],
                  ),
                ),
              );
            },
          );
    });
  }

  bool testFields(String action, {bool? password}){
    int n = 0;

    keyCodeErrorText = null;
    keyPasswordErrorText = null;
    personRemovingKeyErrorText = null;
    personPuttingKeyErrorText = null;
    personReceivingKeyErrorText = null;

    if(action == 'put'){
      if(keyCode.text.trim().isEmpty){
        keyCodeErrorText = 'Este campo não pode estar vazio';
        n++;
      }
      if(personPuttingKey.text.trim().isEmpty) {
        personPuttingKeyErrorText = 'Este campo não pode estar vazio';
        n++;
      }
      if(personReceivingKey.text.trim().isEmpty) {
        personReceivingKeyErrorText = 'Este campo não pode estar vazio';
        n++;
      }
    }else if(action == 'remove'){
      if(keyCode.text.trim().isEmpty){
        keyCodeErrorText = 'Este campo não pode estar vazio';
        n++;
      }
      if(personRemovingKey.text.trim().isEmpty) {
        personRemovingKeyErrorText = 'Este campo não pode estar vazio';
        n++;
      }
      if(password != null){
        if(keyPassword.text.trim().isEmpty){
          keyPasswordErrorText = 'Este campo não pode estar vazio';
        }
      }
    }

    if(n > 0){
      return false;
    }
    return true;
  }

  void attScreen(){
    setState((){
      print('Tela Atualizada');
    });
  }

  void clearFields(){
    keyCode.text = '';
    keyPassword.text = '';
    personRemovingKey.text = '';
    personPuttingKey.text = '';
    personReceivingKey.text = '';

    keyWithdrawalDate = '';
  }

  String getDateTime(){
    keyWithdrawalDate = formatDate(DateTime.now(), [dd,'/',mm,'/',yy,' - ',HH,':',nn,':',ss]);
    return keyWithdrawalDate;
  }
}
