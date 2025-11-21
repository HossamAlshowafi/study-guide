import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../services/database_service.dart';

/// شاشة الإحصائيات في لوحة التحكم
/// 
/// تعرض هذه الشاشة:
/// - عدد الطلاب الذين قاموا بالاختبار
/// - أكثر التخصصات المختارة (Top 5)
/// 
/// يتم تحديث الإحصائيات تلقائياً عند إضافة/حذف أسئلة أو تخصصات
class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  List<Map<String, dynamic>> _mostSelectedMajors = [];
  int _quizResultsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    
    // الاستماع لتغييرات قاعدة البيانات لتحديث الإحصائيات تلقائياً
    DatabaseService.instance.changes.listen((_) {
      if (mounted) {
        _loadStatistics();
      }
    });
  }

  /// تحميل الإحصائيات من قاعدة البيانات
  /// كل دالة CRUD يجب أن تستدعي notifyChanges() لضمان تزامن الواجهات
  Future<void> _loadStatistics() async {
    try {
      print('AdminStatisticsScreen: بدء تحميل الإحصائيات...');
      setState(() => _isLoading = true);
      
      final quizCount = await DatabaseService.instance.getQuizResultsCount();
      final mostSelected = await DatabaseService.instance.getMostSelectedMajors(limit: 5);
      
      print('AdminStatisticsScreen: تم تحميل الإحصائيات - عدد الاختبارات: $quizCount');
      
      setState(() {
        _quizResultsCount = quizCount;
        _mostSelectedMajors = mostSelected;
        _isLoading = false;
      });
    } catch (e) {
      print('AdminStatisticsScreen: خطأ في تحميل الإحصائيات - $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightBlue, Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإحصائيات',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStatistics,
                  tooltip: 'تحديث البيانات',
                ),
              ],
            ),
            const SizedBox(height: 32),
            // بطاقة عدد الطلاب في الوسط من أعلى الشاشة
            if (!_isLoading)
              Center(
                child: SizedBox(
                  width: 300, // عرض ثابت للبطاقة
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [AppColors.green, AppColors.green.withOpacity(0.7)],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, color: Colors.white, size: 50),
                          const SizedBox(height: 12),
                          const Text(
                            'عدد الطلاب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_quizResultsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // بطاقة أكثر التخصصات المختارة (تم حذف المخططات البيانية)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _mostSelectedMajors.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد بيانات للإحصاء',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'أكثر التخصصات المختارة',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ..._mostSelectedMajors.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final data = entry.value;
                                    final name = data['name'] as String;
                                    final count = data['count'] as int;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: AppColors.darkBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightBlue,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$count',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
