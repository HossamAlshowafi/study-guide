import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../services/database_service.dart';
import '../widgets/admin_sidebar.dart';
import 'admin_majors_screen.dart';
import 'admin_questions_screen.dart';
import 'admin_statistics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _majorsCount = 0;
  int _questionsCount = 0;
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
      print('AdminDashboard: بدء تحميل الإحصائيات...');
      setState(() => _isLoading = true);

      final majorsCount = await DatabaseService.instance.getMajorsCount();
      final questionsCount = await DatabaseService.instance.getQuestionsCount();

      print(
        'AdminDashboard: تم تحميل الإحصائيات - تخصصات: $majorsCount, أسئلة: $questionsCount',
      );

      setState(() {
        _majorsCount = majorsCount;
        _questionsCount = questionsCount;
        _isLoading = false;
      });
    } catch (e) {
      print('AdminDashboard: خطأ في تحميل الإحصائيات - $e');
      setState(() => _isLoading = false);
    }
  }

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const AdminMajorsScreen();
      case 2:
        return const AdminQuestionsScreen();
      case 3:
        return const AdminStatisticsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final screenHeight = MediaQuery.of(context).size.height;

        // توحيد ارتفاع البطاقات لتحسين التناسق في Portrait
        // استخدام نسبة من ارتفاع الشاشة بناءً على الاتجاه
        final cardHeight = orientation == Orientation.portrait
            ? screenHeight * 0.22
            : screenHeight * 0.4;

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الصفحة الرئيسية',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Statistics Cards
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'عدد التخصصات',
                            _majorsCount.toString(),
                            Icons.engineering,
                            AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'عدد الأسئلة',
                            _questionsCount.toString(),
                            Icons.quiz,
                            AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  // Quick Actions
                  const Text(
                    'الإجراءات السريعة',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // الأزرار بنفس الطول والعرض مع زيادة الارتفاع لإظهار النص كاملاً
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: cardHeight * 1.3, // زيادة الارتفاع لإظهار النص كاملاً
                          child: _buildActionCard(
                            'إدارة التخصصات',
                            Icons.engineering,
                            AppColors.darkBlue,
                            () => _onItemSelected(1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: cardHeight * 1.3, // نفس الارتفاع لزر إدارة التخصصات
                          child: _buildActionCard(
                            'إدارة الأسئلة',
                            Icons.quiz,
                            AppColors.green,
                            () => _onItemSelected(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              // استخدام Flexible مع Text لإظهار النص كاملاً
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // السماح بسطرين
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('لوحة التحكم'),
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
              ),
              drawer: Drawer(
                child: AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    _onItemSelected(index);
                    Navigator.pop(context);
                  },
                ),
              ),
              body: _buildCurrentScreen(),
            );
          } else {
            return Scaffold(
              body: Row(
                children: [
                  AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onItemSelected,
                  ),
                  Expanded(child: _buildCurrentScreen()),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
