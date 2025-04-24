import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cadastro.db');

    return await openDatabase(path,
     version: 1,
      onCreate: _onCreate
      );
  }

  //criacao da tabela cadastro
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cadastro (
        id_cadastro INTEGER PRIMARY KEY AUTOINCREMENT,
        texto VARCHAR(250) NOT NULL,
        numero INTEGER UNIQUE NOT NULL CHECK (numero > 0)
      )
    ''');
    await db.execute('''
      CREATE TABLE log_operacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
         operacao VARCHAR(10) NOT NULL,
        data_hora TEXT UNIQUE NOT NULL
       )
     ''');

    //trigger para insert, update, delete

    await _createTriggers(db);
  }

  Future<void> _createTriggers(Database db) async {
  await db.execute('''
    CREATE TRIGGER operacaoInsert
    AFTER INSERT ON cadastro
    FOR EACH ROW
    BEGIN
      INSERT INTO log_operacoes (data_hora, operacao)
      VALUES (datetime('now'), "INSERT");
    END;
  ''');

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS operacaoEdit
    AFTER UPDATE ON cadastro
    FOR EACH ROW
    BEGIN
      INSERT INTO log_operacoes (data_hora, operacao)
      VALUES (datetime('now'), "UPDATE");
    END;
  ''');

  await db.execute('''
    CREATE TRIGGER IF NOT EXISTS operacaoDelete
    AFTER DELETE ON cadastro
    FOR EACH ROW
    BEGIN
      INSERT INTO log_operacoes (data_hora, operacao)
      VALUES (datetime('now'), "DELETE");
    END;
  ''');
}

  //insert novo cadastro 
   Future<int> cadastroInsert(Map<String, dynamic> dados) async {
    Database db = await _instance.database;
    return await db.insert('cadastro', dados);
  }

 //editar um cadastro 
  Future<int> cadastroEdit(int id, Map<String, dynamic> dadoEdit) async {
    Database db = await _instance.database;
    return await db.update(
      'cadastro',
      dadoEdit,
      where: 'id_cadastro = ?',
      whereArgs: [id],
    );
  }
   //Deleta um cadastro já existente
  Future<int> deleteCadastro(int idCadastro) async {
    Database db = await _instance.database;
    return await db.delete(
      'cadastro',
      where: 'id = ?',
      whereArgs: [idCadastro],
    );
  }

  //Consulta todos os cadastros
  Future<List<Map<String, dynamic>>> todosCadastros() async {
    Database db = await _instance.database;
    return await db.query('cadastro');
  }
}
