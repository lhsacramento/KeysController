import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class KeysRepository {
  KeysRepository() {
    SharedPreferences.getInstance().then((value) => sharedPreferences = value);
  }

  late SharedPreferences sharedPreferences;
  String keysRepository = "keysController";

  void saveKeys(List<Map<String, dynamic>> keys) {
    String keysJson = json.encode(keys);
    sharedPreferences.setString(keysRepository, keysJson);
  }

  Future<List<Map<String,dynamic>>> getKeys() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String jsonSavedKeysRepository = sharedPreferences.getString(keysRepository) ?? startRepository();
    final list =  List<Map<String,dynamic>>.from(json.decode(jsonSavedKeysRepository));
    return list;
  }

  String startRepository() {
    print('Iniciando Repositório');
    List<Map<String, dynamic>> keys = [
      {
          "Codigo": "A-01",
          "Setor": "Garagem",
          "Senha": 123,
          "PessoasAutorizadas": ["Pessoa1", "Pessoa2"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      },
      {
          "Codigo": "A-02",
          "Setor": "Prefeitura",
          "Senha": 456,
          "PessoasAutorizadas": ["Pessoa3", "Pessoa4"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      },
      {
          "Codigo": "A-03",
          "Setor": "Obra",
          "Senha": 789,
          "PessoasAutorizadas": ["Pessoa5", "Pessoa6"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      },
      {
          "Codigo": "A-04",
          "Setor": "Eletrica",
          "Senha": 987,
          "PessoasAutorizadas": ["Pessoa7", "Pessoa8"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      },
      {
          "Codigo": "A-05",
          "Setor": "Metalurgia",
          "Senha": 654,
          "PessoasAutorizadas": ["Pessoa9", "Pessoa10"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      },
      {
          "Codigo": "A-06",
          "Setor": "Pintura",
          "Senha": 321,
          "PessoasAutorizadas": ["Pessoa11", "Pessoa12"],
          "Available": true,
          "Entradas": [],
          "Saidas": [],
      }
    ];

    String jsonStartRepository = json.encode(keys);
    return jsonStartRepository;
  }
}
