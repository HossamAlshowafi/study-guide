import 'dart:async';
import '../database/database_helper.dart';
import '../models/major_model.dart';
import '../models/question_model.dart';

/// خدمة قاعدة البيانات الرئيسية
/// 
/// هذه الخدمة توفر واجهة موحدة للوصول إلى قاعدة البيانات
/// وتضمن التزامن بين الواجهات المختلفة باستخدام Stream
/// 
/// آلية العمل:
/// - جميع عمليات CRUD تستدعي notifyChanges() بعد الانتهاء
/// - الواجهات تستمع إلى changes stream لتحديث نفسها تلقائياً
/// - هذا يضمن أن التغييرات تظهر فوراً في جميع الشاشات
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  final _changesController = StreamController<void>.broadcast();

  DatabaseService._init();

  /// Stream للتغييرات في قاعدة البيانات
  /// الواجهات تستمع إلى هذا Stream لتحديث نفسها تلقائياً
  Stream<void> get changes => _changesController.stream;

  /// إشعار الواجهات بالتغييرات في قاعدة البيانات
  /// يجب استدعاء هذه الدالة بعد كل عملية CRUD (Create, Update, Delete)
  /// لضمان تحديث جميع الواجهات تلقائياً
  void notifyChanges() {
    _changesController.add(null);
  }

  // ==================== Major operations ====================
  
  /// إدراج تخصص جديد في قاعدة البيانات
  /// [major]: نموذج التخصص المراد إدراجه
  /// Returns: معرف التخصص المُدرج
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  Future<int> insertMajor(MajorModel major) async {
    final id = await DatabaseHelper.instance.insertMajor(major);
    notifyChanges();
    return id;
  }

  /// جلب جميع التخصصات من قاعدة البيانات
  /// Returns: قائمة بجميع التخصصات
  Future<List<MajorModel>> getAllMajors() async {
    return await DatabaseHelper.instance.getAllMajors();
  }

  /// جلب تخصص معين بواسطة المعرف
  /// [id]: معرف التخصص
  /// Returns: نموذج التخصص أو null إذا لم يوجد
  Future<MajorModel?> getMajorById(int id) async {
    return await DatabaseHelper.instance.getMajorById(id);
  }

  /// تحديث تخصص موجود في قاعدة البيانات
  /// [major]: نموذج التخصص المحدث
  /// Returns: عدد الصفوف المحدثة
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  Future<int> updateMajor(MajorModel major) async {
    final result = await DatabaseHelper.instance.updateMajor(major);
    notifyChanges();
    return result;
  }

  /// حذف تخصص من قاعدة البيانات
  /// [id]: معرف التخصص المراد حذفه
  /// Returns: عدد الصفوف المحذوفة
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  Future<int> deleteMajor(int id) async {
    final result = await DatabaseHelper.instance.deleteMajor(id);
    notifyChanges();
    return result;
  }

  // ==================== Question operations ====================
  
  /// إدراج سؤال جديد في قاعدة البيانات
  /// [question]: نموذج السؤال المراد إدراجه
  /// Returns: معرف السؤال المُدرج
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  /// 
  /// مهم: بعد إدراج السؤال، يجب إدراج الأوزان المرتبطة بكل خيار
  /// انظر: insertQuestionWeight()
  Future<int> insertQuestion(QuestionModel question) async {
    final id = await DatabaseHelper.instance.insertQuestion(question);
    notifyChanges();
    return id;
  }

  /// جلب جميع الأسئلة من قاعدة البيانات
  /// Returns: قائمة بجميع الأسئلة
  Future<List<QuestionModel>> getAllQuestions() async {
    return await DatabaseHelper.instance.getAllQuestions();
  }

  /// جلب الأسئلة المرتبطة بتخصص معين
  /// [majorId]: معرف التخصص
  /// Returns: قائمة بالأسئلة المرتبطة بالتخصص
  /// ملاحظة: هذا الدالة لم تعد مستخدمة بشكل كبير بعد نظام الأوزان الجديد
  Future<List<QuestionModel>> getQuestionsByMajorId(int majorId) async {
    return await DatabaseHelper.instance.getQuestionsByMajorId(majorId);
  }

  /// جلب سؤال معين بواسطة المعرف
  /// [id]: معرف السؤال
  /// Returns: نموذج السؤال أو null إذا لم يوجد
  Future<QuestionModel?> getQuestionById(int id) async {
    return await DatabaseHelper.instance.getQuestionById(id);
  }

  /// تحديث سؤال موجود في قاعدة البيانات
  /// [question]: نموذج السؤال المحدث
  /// Returns: عدد الصفوف المحدثة
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  /// 
  /// مهم: عند تحديث السؤال، يجب حذف الأوزان القديمة وإدخال جديدة
  /// انظر: deleteQuestionWeights(), insertQuestionWeight()
  Future<int> updateQuestion(QuestionModel question) async {
    final result = await DatabaseHelper.instance.updateQuestion(question);
    notifyChanges();
    return result;
  }

  /// حذف سؤال من قاعدة البيانات
  /// [id]: معرف السؤال المراد حذفه
  /// Returns: عدد الصفوف المحذوفة
  /// ملاحظة: يتم استدعاء notifyChanges() تلقائياً لتحديث الواجهات
  /// ملاحظة: يتم حذف الأوزان المرتبطة به تلقائياً (CASCADE DELETE)
  Future<int> deleteQuestion(int id) async {
    final result = await DatabaseHelper.instance.deleteQuestion(id);
    notifyChanges();
    return result;
  }

  // ==================== Statistics ====================
  
  /// جلب عدد التخصصات في قاعدة البيانات
  /// Returns: عدد التخصصات
  Future<int> getMajorsCount() async {
    return await DatabaseHelper.instance.getMajorsCount();
  }

  /// جلب عدد الأسئلة في قاعدة البيانات
  /// Returns: عدد الأسئلة
  Future<int> getQuestionsCount() async {
    return await DatabaseHelper.instance.getQuestionsCount();
  }

  /// جلب عدد الأسئلة لكل تخصص
  /// Returns: قائمة بكل تخصص وعدد أسئلته
  /// ملاحظة: هذه الدالة لم تعد مستخدمة بشكل كبير بعد نظام الأوزان الجديد
  Future<List<Map<String, dynamic>>> getQuestionsCountByMajor() async {
    return await DatabaseHelper.instance.getQuestionsCountByMajor();
  }

  // Question Weights
  /// إدخال وزن جديد لخيار في سؤال
  /// questionId: معرف السؤال
  /// majorId: معرف التخصص
  /// optionIndex: فهرس الخيار (0, 1, 2, 3)
  /// weight: قيمة الوزن (0, 1, 2, 3 فقط)
  Future<int> insertQuestionWeight(
    int questionId,
    int majorId,
    int optionIndex,
    int weight,
  ) async {
    final id = await DatabaseHelper.instance.insertQuestionWeight(
      questionId,
      majorId,
      optionIndex,
      weight,
    );
    notifyChanges();
    return id;
  }

  /// جلب جميع الأوزان المرتبطة بسؤال معين
  Future<List<Map<String, dynamic>>> getQuestionWeights(int questionId) async {
    return await DatabaseHelper.instance.getQuestionWeights(questionId);
  }

  /// حذف جميع الأوزان المرتبطة بسؤال معين
  /// تُستخدم عند تحديث السؤال لحذف الأوزان القديمة وإدخال جديدة
  Future<int> deleteQuestionWeights(int questionId) async {
    final result = await DatabaseHelper.instance.deleteQuestionWeights(questionId);
    notifyChanges();
    return result;
  }

  /// حساب النتيجة بناءً على الإجابات
  /// [answers]: قائمة بالإجابات (كل إجابة هي فهرس الخيار المختار: 0, 1, 2, 3)
  /// Returns: خريطة بمعرف التخصص والنتيجة الإجمالية {majorId: totalScore}
  /// 
  /// مثال:
  /// answers = [0, 1, 2, 0, 1]
  /// returns = {1: 4, 2: 6, 3: 2}
  /// 
  /// آلية العمل:
  /// 1. جلب جميع الأسئلة من قاعدة البيانات
  /// 2. لكل سؤال، جلب الأوزان المرتبطة بالخيار المختار
  /// 3. جمع الأوزان لكل تخصص
  /// 4. إرجاع النتائج النهائية
  Future<Map<int, int>> calculateScores(List<int> answers) async {
    return await DatabaseHelper.instance.calculateScores(answers);
  }

  // Quiz Results operations
  /// حفظ نتيجة اختبار - يُستدعى بعد انتهاء الاختبار
  Future<int> insertQuizResult(int majorId) async {
    final id = await DatabaseHelper.instance.insertQuizResult(majorId);
    notifyChanges();
    return id;
  }

  /// جلب عدد الطلاب الذين قاموا بالاختبار
  Future<int> getQuizResultsCount() async {
    return await DatabaseHelper.instance.getQuizResultsCount();
  }

  /// جلب أكثر التخصصات التي تم اختيارها
  Future<List<Map<String, dynamic>>> getMostSelectedMajors({int limit = 5}) async {
    return await DatabaseHelper.instance.getMostSelectedMajors(limit: limit);
  }

  void dispose() {
    _changesController.close();
  }
}





