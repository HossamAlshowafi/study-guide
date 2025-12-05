import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../services/student_session.dart';
import 'home_screen.dart';

class RegisterStudentScreen extends StatefulWidget {
  final String? preFilledStudentId;

  const RegisterStudentScreen({
    super.key,
    this.preFilledStudentId,
  });

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preFilledStudentId != null) {
      _studentIdController.text = widget.preFilledStudentId!;
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    final studentId = _studentIdController.text.trim();
    final studentName = _studentNameController.text.trim();

    // Validate studentName
    if (studentName.isEmpty) {
      _showMessage('يرجى إدخال اسم الطالب');
      return;
    }

    // Validate studentName contains letters only (Arabic and English)
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(studentName)) {
      _showMessage('اسم الطالب يجب أن يحتوي على أحرف فقط');
      return;
    }

    // Validate studentId
    if (studentId.isEmpty) {
      _showMessage('يرجى إدخال الرقم التعريفي');
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(studentId)) {
      _showMessage('الرقم التعريفي يجب أن يحتوي على أرقام فقط');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Check if ID already exists
      final existingStudent = await DatabaseService.instance.getStudentById(studentId);
      if (existingStudent != null) {
        _showMessage('الرقم التعريفي مستخدم مسبقًا. الرجاء إدخال رقم جديد.');
        setState(() => _isSubmitting = false);
        return;
      }

      // Create new student
      final student = await DatabaseService.instance.createOrGetStudent(
        studentId: studentId,
        name: studentName,
      );
      StudentSession.setStudent(student);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showMessage('حدث خطأ أثناء حفظ البيانات. حاول مرة أخرى.');
      print('RegisterStudentScreen: خطأ أثناء حفظ بيانات الطالب - $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkBlue, AppColors.lightBlue],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تسجيل طالب جديد',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _studentNameController,
                      label: 'اسم الطالب',
                      hint: 'أدخل اسم الطالب',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _studentIdController,
                      label: 'الرقم التعريفي',
                      hint: 'أدخل الرقم التعريفي',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: AppColors.darkBlue,
                              )
                            : const Text(
                                'تسجيل',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}


