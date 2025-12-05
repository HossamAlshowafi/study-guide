import '../models/student_model.dart';

/// تخزين بيانات الطالب الحالي خلال الجلسة
class StudentSession {
  static StudentModel? _currentStudent;

  static StudentModel? get currentStudent => _currentStudent;

  static void setStudent(StudentModel student) {
    _currentStudent = student;
  }

  static void clear() {
    _currentStudent = null;
  }
}






