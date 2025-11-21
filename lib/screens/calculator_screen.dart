import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _highschoolController = TextEditingController();
  final TextEditingController _aptitudeController = TextEditingController();
  final TextEditingController _achievementController = TextEditingController();
  double? _result;
  bool _showResult = false;

  void _calculate() {
    final highschool = double.tryParse(_highschoolController.text);
    final aptitude = double.tryParse(_aptitudeController.text);
    final achievement = double.tryParse(_achievementController.text);

    if (highschool == null || aptitude == null || achievement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال جميع الدرجات'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (highschool > 100 || aptitude > 100 || achievement > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الدرجات يجب أن تكون أقل من أو تساوي 100'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final result = (highschool * 0.3) + (aptitude * 0.3) + (achievement * 0.4);
    setState(() {
      _result = result;
      _showResult = true;
    });
  }

  @override
  void dispose() {
    _highschoolController.dispose();
    _aptitudeController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حساب النسبة الموزونة'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.darkBlue,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'النسبة الموزونة',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'درجة الثانوية × 30% + القدرات × 30% + التحصيلي × 40%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Input Fields
                _buildTextField(
                  controller: _highschoolController,
                  label: 'درجة الثانوية العامة',
                  icon: Icons.school,
                  hint: 'أدخل الدرجة (100 أو أقل)',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _aptitudeController,
                  label: 'درجة القدرات العامة',
                  icon: Icons.psychology,
                  hint: 'أدخل الدرجة (100 أو أقل)',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _achievementController,
                  label: 'درجة الاختبار التحصيلي',
                  icon: Icons.quiz,
                  hint: 'أدخل الدرجة (100 أو أقل)',
                ),
                const SizedBox(height: 32),
                // Calculate Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate, size: 28),
                    label: const Text(
                      'احسب النسبة الموزونة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Result Card - Centered
                if (_showResult && _result != null)
                  Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.darkBlue, AppColors.lightBlue],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 70,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'نسبتك الموزونة',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _result!.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getResultMessage(_result!),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.darkBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
          ),
        ),
      ),
    );
  }

  String _getResultMessage(double result) {
    if (result >= 90) {
      return 'ممتاز! تهانينا على هذه النسبة المتميزة 🎉';
    } else if (result >= 80) {
      return 'نسبة ممتازة! لديك فرصة كبيرة للقبول 👍';
    } else if (result >= 70) {
      return 'نسبة جيدة، استمر في التطوير 💪';
    } else {
      return 'حاول تحسين درجاتك في الامتحانات 📚';
    }
  }
}
