import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عن التطبيق'),
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
                const Text(
                  'دليلك الدراسي',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'University Study Guide',
                  style: TextStyle(fontSize: 20, color: AppColors.gray),
                ),
                const SizedBox(height: 40),
                // App Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نظرة عامة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'تطبيق دليلك الدراسي هو تطبيق ذكي مصمم لمساعدة طلاب الثانوية في اكتشاف التخصص الهندسي الأنسب لهم في جامعة بيشة. يوفر التطبيق معلومات شاملة عن جميع التخصصات الهندسية المتاحة ويساعدك في اتخاذ القرار الصحيح.',
                          style: TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Goals Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أهدافنا',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildGoalItem('🎯 توجيه الطلاب للتخصص المناسب'),
                        _buildGoalItem('📚 توفير معلومات شاملة عن التخصصات'),
                        _buildGoalItem('🧪 مساعدة في تقييم الميول والقدرات'),
                        _buildGoalItem('📊 حساب النسبة الموزونة بسهولة'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // FAQ Section
                const Text(
                  'الأسئلة الشائعة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFAQItem(
                  'ما هو التطبيق؟',
                  'تطبيق دليلك الدراسي يساعدك في التعرف على التخصصات الهندسية في جامعة بيشة واختيار التخصص المناسب لك.',
                ),
                _buildFAQItem(
                  'كيف يعمل اختبار التخصص؟',
                  'الاختبار يتكون من 15 سؤال لقياس اهتماماتك وميولك، ويعطيك توصية بخصوص التخصصات المناسبة لك.',
                ),
                _buildFAQItem(
                  'كيف أحسب النسبة الموزونة؟',
                  'أدخل درجاتك في الثانوية والقدرات والتحصيلي، وسيقوم التطبيق بحساب النسبة الموزونة تلقائياً.',
                ),
                _buildFAQItem(
                  'هل يمكنني تعديل النتائج؟',
                  'التطبيق يعمل على وضع الاستطلاع حالياً، حيث يمكنك تصفح التخصصات والاطلاع على تفاصيلها.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, color: AppColors.gray),
            ),
          ),
        ],
      ),
    );
  }
}
