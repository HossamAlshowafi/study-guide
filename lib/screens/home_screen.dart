import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../services/quiz_service.dart';
import 'majors_screen.dart';
import 'quiz_screen.dart';
import 'calculator_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingQuiz = false;

  /// تهيئة الاختبار والانتقال إلى شاشة الاختبار
  /// 
  /// هذه الدالة تقوم بتهيئة أسئلة الاختبار من قاعدة البيانات
  /// ثم تنتقل إلى شاشة الاختبار
  /// لا تسمح للـ loader بالبقاء إذا فشل التحميل
  /// تستخدم timeout آمن (10 ثوانٍ) لعدم بقاء شاشة التحميل للأبد
  /// 
  /// آلية العمل:
  /// 1. التحقق من عدم وجود تحميل جاري (منع الضغط المتكرر)
  /// 2. عرض شاشة التحميل
  /// 3. جلب الأسئلة من قاعدة البيانات مع timeout
  /// 4. الانتقال إلى شاشة الاختبار
  /// 5. إخفاء شاشة التحميل في حالة النجاح أو الفشل
  /// 
  /// في حالة الفشل:
  /// - إظهار رسالة خطأ واضحة للمستخدم
  /// - إخفاء شاشة التحميل
  /// - منع الانتقال إلى شاشة الاختبار
  Future<void> _prepareAndNavigateToQuiz() async {
    if (_isLoadingQuiz) return; // منع الضغط المتكرر

    setState(() => _isLoadingQuiz = true);

    try {
      // تهيئة الاختبار مع timeout آمن
      await QuizService.prepareQuiz().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('انتهت مهلة تحميل الاختبار. يرجى المحاولة مرة أخرى.');
        },
      );

      if (!mounted) return;

      // الانتقال إلى شاشة الاختبار
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizScreen(),
        ),
      );
    } catch (e) {
      print('خطأ في تحميل الاختبار: $e');
      if (!mounted) return;

      // إظهار رسالة خطأ للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('لا توجد أسئلة')
                ? 'لا توجد أسئلة في قاعدة البيانات. يرجى إضافة أسئلة من لوحة التحكم.'
                : 'حدث خطأ أثناء تحميل الاختبار. حاول مرة أخرى.',
          ),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuiz = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('دليلك الدراسي'),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.school,
                            size: 60,
                            color: AppColors.darkBlue,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Welcome Message
                  const Text(
                    'مرحبًا بك في تطبيق دليلك الدراسي 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اكتشف تخصصك الهندسي الأنسب!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.gray),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'التخصصات الهندسية',
                      icon: Icons.engineering,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MajorsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoadingQuiz
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : CustomButton(
                            text: 'اختبار التخصص',
                            icon: Icons.quiz,
                            onPressed: _prepareAndNavigateToQuiz,
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'حساب النسبة الموزونة',
                      icon: Icons.calculate,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CalculatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'عن التطبيق',
                      icon: Icons.info,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
