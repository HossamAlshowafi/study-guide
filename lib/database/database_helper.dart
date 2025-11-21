import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/major_model.dart';
import '../models/question_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // زيادة الإصدار لإضافة quiz_results
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add displayOrder column
      await db.execute('ALTER TABLE majors ADD COLUMN displayOrder INTEGER DEFAULT 0');
      
      // Create question_weights table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS question_weights (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          questionId INTEGER NOT NULL,
          majorId INTEGER NOT NULL,
          optionIndex INTEGER NOT NULL,
          weight INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (questionId) REFERENCES questions (id),
          FOREIGN KEY (majorId) REFERENCES majors (id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Create quiz_results table لتتبع نتائج الاختبارات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          majorId INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (majorId) REFERENCES majors (id)
        )
      ''');
      
      // إضافة الأسئلة الافتراضية إذا لم تكن موجودة
      await _insertDefaultQuestions(db);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create majors table
    await db.execute('''
      CREATE TABLE majors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        requirements TEXT NOT NULL,
        careers TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        planLink TEXT NOT NULL,
        displayOrder INTEGER DEFAULT 0
      )
    ''');

    // Create questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionText TEXT NOT NULL,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL,
        option4 TEXT NOT NULL,
        majorId INTEGER NOT NULL,
        FOREIGN KEY (majorId) REFERENCES majors (id)
      )
    ''');

    // Create question_weights table
    await db.execute('''
      CREATE TABLE question_weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionId INTEGER NOT NULL,
        majorId INTEGER NOT NULL,
        optionIndex INTEGER NOT NULL,
        weight INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (questionId) REFERENCES questions (id),
        FOREIGN KEY (majorId) REFERENCES majors (id)
      )
    ''');

    // Create quiz_results table لتتبع نتائج الاختبارات
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        majorId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (majorId) REFERENCES majors (id)
      )
    ''');

    // Insert default majors
    await _insertDefaultMajors(db);
    
    // Insert default questions
    await _insertDefaultQuestions(db);
  }

  Future<void> _insertDefaultMajors(Database db) async {
    final defaultMajors = [
      {
        'name': 'الهندسة المدنية',
        'description': 'الهندسة المدنية هي أحد فروع الهندسة التي تتخصص في تصميم وتنفيذ المنشآت والبنى التحتية مثل الطرق والجسور والمباني والسدود والمطارات والموانئ.',
        'requirements': 'دراسة الرياضيات والفيزياء بشكل متقدم، والقدرة على التحليل والتصميم، والمهارات التقنية في استخدام البرمجيات الهندسية.',
        'careers': 'مهندس مدني، مهندس إنشاءات، مهندس طرق وجسور، مهندس بيئة، مستشار هندسي، إدارة المشاريع الهندسية.',
        'imagePath': 'assets/images/Civil Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/1/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A%D8%A9.pdf',
      },
      {
        'name': 'الهندسة الميكانيكية',
        'description': 'الهندسة الميكانيكية هي أحد أوسع فروع الهندسة التي تتناول تصميم وتطوير وتصنيع النظم الميكانيكية والآلات.',
        'requirements': 'مهارات رياضية وفيزيائية قوية، التفكير التحليلي، القدرة على تصميم النظم المعقدة، معرفة ببرامج التصميم الميكانيكي.',
        'careers': 'مهندس ميكانيكي، مهندس تصنيع، مهندس صيانة، مهندس روافع، مهندس أنظمة الطاقة، مهندس سيارات.',
        'imagePath': 'assets/images/Mechanical Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/5/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D9%8A%D9%83%D8%A7%D9%86%D9%8A%D9%83%D9%8A%D8%A9.pdf',
      },
      {
        'name': 'الهندسة الكهربائية',
        'description': 'الهندسة الكهربائية تهتم بدراسة وتطبيق الكهرباء والإلكترونيات والكهرومغناطيسية.',
        'requirements': 'قدرة عالية في الرياضيات والفيزياء، فهم عميق للمبادئ الكهربائية، مهارات البرمجة، إتقان برامج المحاكاة والتصميم.',
        'careers': 'مهندس كهربائي، مهندس أنظمة الطاقة، مهندس إلكترونيات، مهندس اتصالات، مهندس تحكم، مهندس أمن المعلومات.',
        'imagePath': 'assets/images/Electrical Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/3/Electrical%20Courses%20%20Syllabus.pdf',
      },
      {
        'name': 'الهندسة الصناعية',
        'description': 'الهندسة الصناعية تركز على تحسين النظم المعقدة والعمليات والمنظمات.',
        'requirements': 'مهارات تحليلية قوية، فهم عمليات الإنتاج، القدرة على تحسين النظم، مهارات إدارة المشاريع، إتقان أدوات التحليل الإحصائي.',
        'careers': 'مهندس صناعي، مهندس جودة، مهندس عمليات، مهندس سلسلة التوريد، محلل نظم، مستشار إداري.',
        'imagePath': 'assets/images/Industrial Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/2/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D8%B5%D9%86%D8%A7%D8%B9%D9%8A%D8%A9.pdf',
      },
      {
        'name': 'هندسة التعدين',
        'description': 'هندسة التعدين تهتم بالبحث والتطوير في مجال استخراج المعادن والمعالجة.',
        'requirements': 'معرفة بعلوم الأرض والجيولوجيا، فهم عمليات الاستخراج، السلامة المهنية، إدارة المخاطر، مهارات بيئية.',
        'careers': 'مهندس تعدين، مهندس جيولوجيا، مهندس صيانة مناجم، أخصائي سلامة، مهندس بيئة تعدينية، مدير موارد طبيعية.',
        'imagePath': 'assets/images/Mining Engineering.jpg',
        'planLink': 'https://uob.edu.sa/ar/content.php?id=26',
      },
      {
        'name': 'هندسة الطاقة المتجددة',
        'description': 'هندسة الطاقة المتجددة تختص بتصميم وتطوير أنظمة الطاقة النظيفة مثل الطاقة الشمسية وطاقة الرياح.',
        'requirements': 'خلفية قوية في الفيزياء والكيمياء، فهم أنظمة الطاقة، مهارات تصميم النظم الكهربائية، الوعي البيئي.',
        'careers': 'مهندس طاقة متجددة، مهندس أنظمة شمسية، مهندس توربينات رياح، مستشار طاقة، مهندس استدامة، باحث في الطاقة النظيفة.',
        'imagePath': 'assets/images/Renewable Energy Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/4/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D8%B7%D8%A7%D9%82%D8%A9%20%D8%A7%D9%84%D9%85%D8%AA%D8%AC%D8%AF%D8%AF%D8%A9.pdf',
      },
      {
        'name': 'الهندسة المعمارية',
        'description': 'الهندسة المعمارية تجمع بين الفن والهندسة لتصميم المباني والمنشآت.',
        'requirements': 'مهارات تصميمية وإبداعية، فهم المعايير الإنشائية، إتقان برامج التصميم المعماري، الوعي الجمالي والبيئي.',
        'careers': 'مهندس معماري، مهندس إنشاءات، مصمم مباني مستدامة، مستشار هندسي معماري، مخطط حضري، مدير مشاريع عمرانية.',
        'imagePath': 'assets/images/Architectural Engineering.jpg',
        'planLink': 'https://www.ub.edu.sa/ENG/Lists/ProgramsDept/Attachments/6/%D8%A7%D9%84%D8%AE%D8%B7%D8%A9%20%D8%A7%D9%84%D8%AF%D8%B1%D8%A7%D8%B3%D9%8A%D8%A9%20%D9%84%D9%84%D9%87%D9%86%D8%AF%D8%B3%D8%A9%20%D8%A7%D9%84%D9%85%D8%B9%D9%85%D8%A7%D8%B1%D9%8A%D8%A9.pdf',
      },
    ];

    for (var major in defaultMajors) {
      await db.insert('majors', major);
    }
  }

  /// إدراج الأسئلة الافتراضية الـ15 مع الأوزان
  Future<void> _insertDefaultQuestions(Database db) async {
    // التحقق من وجود أسئلة بالفعل
    final existingQuestions = await db.query('questions');
    if (existingQuestions.isNotEmpty) {
      print('DatabaseHelper: توجد أسئلة بالفعل، لن يتم إدراج أسئلة جديدة');
      return;
    }

    // الحصول على التخصصات
    final majors = await db.query('majors');
    if (majors.isEmpty) {
      print('DatabaseHelper: لا توجد تخصصات، لن يتم إدراج أسئلة');
      return;
    }

    // إنشاء خريطة للتخصصات
    final majorMap = <String, int>{};
    for (var major in majors) {
      final name = major['name'] as String;
      final id = major['id'] as int;
      majorMap[name] = id;
    }

    // الأسئلة الـ15
    final defaultQuestions = [
      {
        'questionText': 'ما هي المواد الدراسية التي تفضل العمل عليها؟',
        'option1': 'الرياضيات والتحليل',
        'option2': 'الفيزياء والالكترونيات',
        'option3': 'التصميم والإبداع',
        'option4': 'الإدارة والتخطيط',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ماذا تفضل في العمل؟',
        'option1': 'تصميم مباني وهياكل',
        'option2': 'صنع الآلات والأنظمة',
        'option3': 'برمجة وتحليل البيانات',
        'option4': 'تحسين العمليات',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هو اهتمامك الأساسي؟',
        'option1': 'الاستدامة والبيئة',
        'option2': 'التصنيع والإنتاج',
        'option3': 'التقنيات الحديثة',
        'option4': 'الإدارة والتنظيم',
        'majorId': majorMap['هندسة الطاقة المتجددة'] ?? majors.first['id'],
      },
      {
        'questionText': 'كيف تتعامل مع التحديات؟',
        'option1': 'حل المشكلات المعقدة',
        'option2': 'الابتكار والتطوير',
        'option3': 'التخطيط المسبق',
        'option4': 'العمل الجماعي',
        'majorId': majorMap['الهندسة الصناعية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما نوع المشاريع التي تجذبك؟',
        'option1': 'مشاريع كبيرة وضخمة',
        'option2': 'أنظمة مبتكرة',
        'option3': 'تطوير مستمر',
        'option4': 'تحسين الكفاءة',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هي نقاط قوتك؟',
        'option1': 'التحليل الدقيق',
        'option2': 'الإبداع والابتكار',
        'option3': 'التفكير الاستراتيجي',
        'option4': 'التنظيم والإدارة',
        'majorId': majorMap['الهندسة الصناعية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هو مجالك المفضل للعمل؟',
        'option1': 'تشييد المباني',
        'option2': 'صناعة الآلات',
        'option3': 'الطاقة والكهرباء',
        'option4': 'تحسين النظم',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'كيف تفضل العمل؟',
        'option1': 'في فريق كبير',
        'option2': 'بشكل مستقل',
        'option3': 'مع أجهزة الحاسوب',
        'option4': 'مع البيانات والأرقام',
        'majorId': majorMap['الهندسة الصناعية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هو هدفك المهني؟',
        'option1': 'بناء البنية التحتية',
        'option2': 'صناعة المستقبل',
        'option3': 'تطوير التقنيات',
        'option4': 'تحسين الإنتاجية',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما الذي يهمك في التخصص؟',
        'option1': 'التطبيق العملي',
        'option2': 'الابتكار التقني',
        'option3': 'التطوير المستمر',
        'option4': 'الكفاءة الاقتصادية',
        'majorId': majorMap['الهندسة الصناعية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هو نوع البيئة التي تفضلها؟',
        'option1': 'المواقع الإنشائية',
        'option2': 'المختبرات التكنولوجية',
        'option3': 'الأماكن المكتبية',
        'option4': 'مناطق الإنتاج',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هي مهارتك الأساسية؟',
        'option1': 'الرسم والتخطيط',
        'option2': 'البرمجة والحوسبة',
        'option3': 'التحليل الهندسي',
        'option4': 'إدارة العمليات',
        'majorId': majorMap['الهندسة المعمارية'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هي اهتماماتك الجانبية؟',
        'option1': 'التصميم والفن',
        'option2': 'العلوم والتكنولوجيا',
        'option3': 'الرياضيات والإحصائيات',
        'option4': 'الإدارة والقيادة',
        'majorId': majorMap['الهندسة المعمارية'] ?? majors.first['id'],
      },
      {
        'questionText': 'كيف ترى مستقبل الهندسة؟',
        'option1': 'بناء مدن ذكية',
        'option2': 'تقنيات مستقبلية',
        'option3': 'طاقة نظيفة',
        'option4': 'نظم متطورة',
        'majorId': majorMap['هندسة الطاقة المتجددة'] ?? majors.first['id'],
      },
      {
        'questionText': 'ما هو حلمك في المهنة؟',
        'option1': 'بناء مشاريع ضخمة',
        'option2': 'ابتكار تقنيات جديدة',
        'option3': 'تطوير أنظمة حديثة',
        'option4': 'قيادة فرق العمل',
        'majorId': majorMap['الهندسة المدنية'] ?? majors.first['id'],
      },
    ];

    // إدراج الأسئلة
    for (var questionData in defaultQuestions) {
      final questionId = await db.insert('questions', questionData);
      
      // إدراج الأوزان الافتراضية
      // كل خيار له وزن 2 للتخصص المقابل، ووزن 0 للباقي
      final majorIds = majors.map((m) => m['id'] as int).toList();
      
      // خيار 1 -> تخصص 1 (المدنية) - وزن 2
      if (majorIds.isNotEmpty) {
        await db.insert('question_weights', {
          'questionId': questionId,
          'majorId': majorIds[0],
          'optionIndex': 0,
          'weight': 2,
        });
      }
      
      // خيار 2 -> تخصص 2 (الميكانيكية) - وزن 2
      if (majorIds.length > 1) {
        await db.insert('question_weights', {
          'questionId': questionId,
          'majorId': majorIds[1],
          'optionIndex': 1,
          'weight': 2,
        });
      }
      
      // خيار 3 -> تخصص 3 (الكهربائية) - وزن 2
      if (majorIds.length > 2) {
        await db.insert('question_weights', {
          'questionId': questionId,
          'majorId': majorIds[2],
          'optionIndex': 2,
          'weight': 2,
        });
      }
      
      // خيار 4 -> تخصص 4 (الصناعية) - وزن 2
      if (majorIds.length > 3) {
        await db.insert('question_weights', {
          'questionId': questionId,
          'majorId': majorIds[3],
          'optionIndex': 3,
          'weight': 2,
        });
      }
    }
    
    print('DatabaseHelper: تم إدراج ${defaultQuestions.length} سؤال افتراضي');
  }

  // ==================== Major CRUD operations ====================
  
  /// إدراج تخصص جديد في قاعدة البيانات
  /// [major]: نموذج التخصص المراد إدراجه
  /// Returns: معرف التخصص المُدرج
  Future<int> insertMajor(MajorModel major) async {
    final db = await database;
    return await db.insert('majors', major.toMap());
  }

  /// جلب جميع التخصصات من قاعدة البيانات
  /// Returns: قائمة بجميع التخصصات مرتبة حسب displayOrder ثم الاسم
  Future<List<MajorModel>> getAllMajors() async {
    final db = await database;
    final maps = await db.query('majors', orderBy: 'displayOrder, name');
    return List.generate(maps.length, (i) => MajorModel.fromMap(maps[i]));
  }

  /// جلب تخصص معين بواسطة المعرف
  /// [id]: معرف التخصص
  /// Returns: نموذج التخصص أو null إذا لم يوجد
  Future<MajorModel?> getMajorById(int id) async {
    final db = await database;
    final maps = await db.query('majors', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return MajorModel.fromMap(maps.first);
    }
    return null;
  }

  /// تحديث تخصص موجود في قاعدة البيانات
  /// [major]: نموذج التخصص المحدث
  /// Returns: عدد الصفوف المحدثة
  Future<int> updateMajor(MajorModel major) async {
    final db = await database;
    return await db.update(
      'majors',
      major.toMap(),
      where: 'id = ?',
      whereArgs: [major.id],
    );
  }

  /// حذف تخصص من قاعدة البيانات
  /// [id]: معرف التخصص المراد حذفه
  /// ملاحظة: يتم حذف الأسئلة المرتبطة به أولاً
  /// Returns: عدد الصفوف المحذوفة
  Future<int> deleteMajor(int id) async {
    final db = await database;
    // Delete related questions first
    await db.delete('questions', where: 'majorId = ?', whereArgs: [id]);
    return await db.delete('majors', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Question CRUD operations ====================
  
  /// إدراج سؤال جديد في قاعدة البيانات
  /// [question]: نموذج السؤال المراد إدراجه
  /// Returns: معرف السؤال المُدرج
  Future<int> insertQuestion(QuestionModel question) async {
    final db = await database;
    return await db.insert('questions', question.toMap());
  }

  /// جلب جميع الأسئلة من قاعدة البيانات
  /// Returns: قائمة بجميع الأسئلة مرتبة حسب المعرف
  Future<List<QuestionModel>> getAllQuestions() async {
    final db = await database;
    final maps = await db.query('questions', orderBy: 'id');
    return List.generate(maps.length, (i) => QuestionModel.fromMap(maps[i]));
  }

  /// جلب الأسئلة المرتبطة بتخصص معين
  /// [majorId]: معرف التخصص
  /// Returns: قائمة بالأسئلة المرتبطة بالتخصص
  Future<List<QuestionModel>> getQuestionsByMajorId(int majorId) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'majorId = ?',
      whereArgs: [majorId],
    );
    return List.generate(maps.length, (i) => QuestionModel.fromMap(maps[i]));
  }

  /// جلب سؤال معين بواسطة المعرف
  /// [id]: معرف السؤال
  /// Returns: نموذج السؤال أو null إذا لم يوجد
  Future<QuestionModel?> getQuestionById(int id) async {
    final db = await database;
    final maps = await db.query('questions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return QuestionModel.fromMap(maps.first);
    }
    return null;
  }

  /// تحديث سؤال موجود في قاعدة البيانات
  /// [question]: نموذج السؤال المحدث
  /// Returns: عدد الصفوف المحدثة
  Future<int> updateQuestion(QuestionModel question) async {
    final db = await database;
    return await db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  /// حذف سؤال من قاعدة البيانات
  /// [id]: معرف السؤال المراد حذفه
  /// ملاحظة: يتم حذف الأوزان المرتبطة به تلقائياً (CASCADE DELETE)
  /// Returns: عدد الصفوف المحذوفة
  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Statistics ====================
  
  /// جلب عدد التخصصات في قاعدة البيانات
  /// Returns: عدد التخصصات
  Future<int> getMajorsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM majors');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// جلب عدد الأسئلة في قاعدة البيانات
  /// Returns: عدد الأسئلة
  Future<int> getQuestionsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM questions');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// جلب عدد الأسئلة لكل تخصص
  /// Returns: قائمة بكل تخصص وعدد أسئلته
  Future<List<Map<String, dynamic>>> getQuestionsCountByMajor() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.id, m.name, COUNT(q.id) as questionCount
      FROM majors m
      LEFT JOIN questions q ON m.id = q.majorId
      GROUP BY m.id, m.name
      ORDER BY questionCount DESC
    ''');
  }

  // ==================== Question Weights operations ====================
  
  /// إدراج وزن جديد لخيار في سؤال
  /// [questionId]: معرف السؤال
  /// [majorId]: معرف التخصص
  /// [optionIndex]: فهرس الخيار (0, 1, 2, 3)
  /// [weight]: قيمة الوزن (عادة 0, 1, 2)
  /// Returns: معرف السجل المُدرج
  Future<int> insertQuestionWeight(
    int questionId,
    int majorId,
    int optionIndex,
    int weight,
  ) async {
    final db = await database;
    return await db.insert('question_weights', {
      'questionId': questionId,
      'majorId': majorId,
      'optionIndex': optionIndex,
      'weight': weight,
    });
  }

  /// جلب جميع الأوزان المرتبطة بسؤال معين
  /// [questionId]: معرف السؤال
  /// Returns: قائمة بجميع الأوزان المرتبطة بالسؤال
  Future<List<Map<String, dynamic>>> getQuestionWeights(int questionId) async {
    final db = await database;
    return await db.query(
      'question_weights',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
  }

  /// حذف جميع الأوزان المرتبطة بسؤال معين
  /// [questionId]: معرف السؤال
  /// تُستخدم عند تحديث السؤال لحذف الأوزان القديمة وإدخال جديدة
  /// Returns: عدد الصفوف المحذوفة
  Future<int> deleteQuestionWeights(int questionId) async {
    final db = await database;
    return await db.delete(
      'question_weights',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
  }

  /// حساب النتيجة بناءً على الإجابات
  /// [answers]: قائمة بالإجابات (كل إجابة هي فهرس الخيار المختار: 0, 1, 2, 3)
  /// Returns: خريطة بمعرف التخصص والنتيجة الإجمالية {majorId: totalScore}
  /// 
  /// آلية العمل:
  /// 1. جلب جميع الأسئلة من قاعدة البيانات
  /// 2. لكل سؤال، جلب الأوزان المرتبطة بالخيار المختار
  /// 3. جمع الأوزان لكل تخصص
  /// 4. إرجاع النتائج النهائية
  Future<Map<int, int>> calculateScores(List<int> answers) async {
    final db = await database;
    final scores = <int, int>{};
    
    // Get all questions
    final questions = await getAllQuestions();
    
    // For each answer, get weights and accumulate
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      final questionId = questions[i].id;
      if (questionId == null) continue;
      
      final optionIndex = answers[i];
      final weights = await db.query(
        'question_weights',
        where: 'questionId = ? AND optionIndex = ?',
        whereArgs: [questionId, optionIndex],
      );
      
      for (var weight in weights) {
        final majorId = weight['majorId'] as int;
        final weightValue = weight['weight'] as int;
        scores[majorId] = (scores[majorId] ?? 0) + weightValue;
      }
    }
    
    return scores;
  }

  // ==================== Quiz Results operations ====================
  // لتتبع نتائج الاختبارات والإحصائيات
  
  /// حفظ نتيجة اختبار في قاعدة البيانات
  /// [majorId]: معرف التخصص الذي تم اختياره
  /// يتم استدعاؤها بعد انتهاء الاختبار وحساب النتيجة
  /// Returns: معرف السجل المُدرج
  Future<int> insertQuizResult(int majorId) async {
    final db = await database;
    return await db.insert('quiz_results', {
      'majorId': majorId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// جلب عدد الطلاب الذين قاموا بالاختبار
  /// Returns: عدد نتائج الاختبارات المحفوظة
  Future<int> getQuizResultsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM quiz_results');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// جلب أكثر التخصصات التي تم اختيارها
  /// [limit]: عدد التخصصات المطلوبة (افتراضياً 5)
  /// Returns: قائمة بالتخصصات مرتبة حسب عدد الاختيارات
  /// 
  /// مثال على النتيجة:
  /// [
  ///   {'id': 1, 'name': 'الهندسة المدنية', 'count': 10},
  ///   {'id': 2, 'name': 'الهندسة الميكانيكية', 'count': 8},
  ///   ...
  /// ]
  Future<List<Map<String, dynamic>>> getMostSelectedMajors({int limit = 5}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.id, m.name, COUNT(qr.id) as count
      FROM majors m
      LEFT JOIN quiz_results qr ON m.id = qr.majorId
      GROUP BY m.id, m.name
      ORDER BY count DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}


