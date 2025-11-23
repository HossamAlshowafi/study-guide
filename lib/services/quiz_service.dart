import '../services/database_service.dart';
import '../models/question_model.dart';

/// خدمة تهيئة الاختبار
/// هذه الدالة تقوم بتهيئة أسئلة الاختبار من قاعدة البيانات
/// ثم تحقق من وجود أسئلة قبل الانتقال إلى شاشة الاختبار
/// لا تسمح للـ loader بالبقاء إذا فشل التحميل
class QuizService {
  /// تهيئة الاختبار - جلب الأسئلة من قاعدة البيانات
  /// تُستخدم قبل الانتقال إلى شاشة الاختبار لضمان وجود بيانات
  /// ترجع Future ينتهي سواء نجح أو فشل
  static Future<List<QuestionModel>> prepareQuiz() async {
    try {
      print('QuizService: بدء تحميل الأسئلة...');
      
      // جلب جميع الأسئلة من قاعدة البيانات
      final questions = await DatabaseService.instance.getAllQuestions();
      
      print('QuizService: تم تحميل ${questions.length} سؤال');
      
      if (questions.isEmpty) {
        print('QuizService: تحذير - لا توجد أسئلة في قاعدة البيانات');
        throw Exception('لا توجد أسئلة في قاعدة البيانات. يرجى إضافة أسئلة من لوحة التحكم.');
      }
      
      return questions;
    } catch (e) {
      print('QuizService: خطأ في تحميل الأسئلة - $e');
      rethrow;
    }
  }
}




