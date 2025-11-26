import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../models/major_model.dart';
import '../services/student_session.dart';
import 'major_details_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<int> answers;

  const ResultScreen({super.key, required this.answers});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<MajorModel> _topMajors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  /// حساب النتيجة بناءً على الإجابات
  /// 
  /// آلية العمل:
  /// 1. حساب النتيجة باستخدام الأوزان من قاعدة البيانات
  /// 2. جلب جميع التخصصات
  /// 3. ترتيب التخصصات حسب النتيجة (من الأعلى إلى الأدنى)
  /// 4. اختيار التخصصين الأعلى نقاطاً
  /// 5. حفظ نتيجة الاختبار (التخصص الأول) في قاعدة البيانات
  /// 
  /// [widget.answers]: قائمة بالإجابات (كل إجابة هي فهرس الخيار المختار)
  /// 
  /// مثال:
  /// answers = [0, 1, 2, 0, 1]
  /// scores = {1: 4, 2: 6, 3: 2}
  /// topMajors = [الميكانيكية (6), المدنية (4)]
  Future<void> _calculateResults() async {
    try {
      // 1. حساب النتيجة باستخدام الأوزان من قاعدة البيانات
      final scores = await DatabaseService.instance.calculateScores(widget.answers);
      
      // 2. جلب جميع التخصصات
      final allMajors = await DatabaseService.instance.getAllMajors();
      
      // 3. ترتيب التخصصات حسب النتيجة (من الأعلى إلى الأدنى)
      final sortedMajors = allMajors.map((major) {
        final score = scores[major.id] ?? 0;
        return MapEntry(major, score);
      }).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // 4. اختيار التخصصين الأعلى نقاطاً
      final topMajors = sortedMajors.take(2).map((e) => e.key).toList();
      
      // 5. حفظ نتيجة الاختبار (التخصص الأول) في سجل الطالب
      if (topMajors.isNotEmpty && topMajors.first.id != null) {
        final currentStudent = StudentSession.currentStudent;
        if (currentStudent != null) {
          try {
            await DatabaseService.instance.updateStudentResult(
              studentId: currentStudent.id,
              majorId: topMajors.first.id!,
            );
            StudentSession.setStudent(
              currentStudent.copyWith(
                lastResult: topMajors.first.id!,
                updatedAt: DateTime.now().toIso8601String(),
              ),
            );
            print('ResultScreen: تم تحديث نتيجة الطالب - ${currentStudent.id}');
          } catch (e) {
            print('ResultScreen: خطأ في تحديث نتيجة الطالب - $e');
          }
        } else {
          print('ResultScreen: لا يوجد طالب مسجل لحفظ النتيجة');
        }
      }
      
      setState(() {
        _topMajors = topMajors;
        _isLoading = false;
      });
    } catch (e) {
      print('ResultScreen: خطأ في حساب النتائج - $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('نتيجة الاختبار'),
            backgroundColor: AppColors.darkBlue,
            foregroundColor: Colors.white,
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نتيجة الاختبار'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Congratulations Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.darkBlue, AppColors.lightBlue],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.celebration,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'مبروك! 🎉',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'بناءً على إجاباتك، التخصصات التالية تناسبك:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // Top Majors
              ..._topMajors.asMap().entries.map((entry) {
                int index = entry.key;
                MajorModel major = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MajorDetailsScreen(major: major.toMap()),
                          ),
                        );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                child: Image.asset(
                                  major.imagePath,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: AppColors.lightBlue,
                                        child: const Icon(
                                          Icons.engineering,
                                          size: 80,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? AppColors.green
                                          : AppColors.darkBlue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      index == 0 ? 'الأول' : 'الثاني',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                major.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
