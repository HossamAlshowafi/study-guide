import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../models/question_model.dart';
import '../widgets/quiz_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> _questions = [];
  int currentQuestion = 0;
  final List<int> selectedAnswers = [];
  int? selectedOptionIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  /// تحميل الأسئلة من قاعدة البيانات
  /// مع معالجة الأخطاء وإظهار رسائل واضحة للمستخدم
  Future<void> _loadQuestions() async {
    try {
      print('QuizScreen: بدء تحميل الأسئلة...');
      final questions = await DatabaseService.instance.getAllQuestions();
      print('QuizScreen: تم تحميل ${questions.length} سؤال');
      
      if (!mounted) return;
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      
      // إذا لم توجد أسئلة، إظهار رسالة خطأ
      if (questions.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا توجد أسئلة في قاعدة البيانات. يرجى إضافة أسئلة من لوحة التحكم.'),
            backgroundColor: AppColors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('QuizScreen: خطأ في تحميل الأسئلة - $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تحميل الأسئلة: ${e.toString()}'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// اختيار إجابة والانتقال للسؤال التالي
  /// 
  /// [answerIndex]: فهرس الخيار المختار (0, 1, 2, 3)
  /// 
  /// آلية العمل:
  /// 1. حفظ الإجابة في قائمة selectedAnswers
  /// 2. إذا لم يكن هذا آخر سؤال، الانتقال للسؤال التالي
  /// 3. إذا كان هذا آخر سؤال، الانتقال إلى شاشة النتائج
  /// 
  /// ملاحظة: يتم استخدام تأخير بسيط (300ms) لتحسين تجربة المستخدم
  void _selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswers.add(answerIndex);
      selectedOptionIndex = answerIndex;
    });

    if (currentQuestion < _questions.length - 1) {
      // الانتقال للسؤال التالي
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          currentQuestion++;
          selectedOptionIndex = null; // Reset for next question
        });
      });
    } else {
      // الانتقال إلى شاشة النتائج
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(answers: selectedAnswers),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _questions.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('اختبار التخصص'),
            backgroundColor: AppColors.darkBlue,
            foregroundColor: Colors.white,
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final question = _questions[currentQuestion];
    final options = [question.option1, question.option2, question.option3, question.option4];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختبار التخصص'),
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.lightBlue, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Progress Bar
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'السؤال ${currentQuestion + 1} من ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${((currentQuestion + 1) / _questions.length * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value:
                            (currentQuestion + 1) /
                            _questions.length,
                        backgroundColor: AppColors.lightGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.darkBlue,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Question Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return QuizOption(
                                  option: options[index],
                                  isSelected: selectedOptionIndex == index,
                                  onTap: () {
                                    if (selectedOptionIndex == null) {
                                      _selectAnswer(index);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
