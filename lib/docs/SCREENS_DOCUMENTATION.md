# 📱 توثيق واجهات التطبيق - Screens Documentation

## 🎯 واجهات الطالب (Student Screens)

### 1. **LoginScreen** - شاشة تسجيل الدخول
- **الموقع**: `lib/screens/login_screen.dart`
- **الوظيفة**: شاشة البداية - اختيار نوع الدخول (طالب أو إدمن)
- **المميزات**: 
  - شعار التطبيق
  - زر تسجيل دخول كطالب → ينتقل إلى `StudentInfoScreen`
  - زر تسجيل دخول كإدمن → ينتقل إلى `AdminPlaceholderScreen`

---

### 2. **StudentInfoScreen** - شاشة بيانات الطالب
- **الموقع**: `lib/screens/student_info_screen.dart`
- **الوظيفة**: إدخال بيانات الطالب قبل الدخول
- **الحقول**:
  - اسم الطالب (TextField)
  - الرقم التعريفي (TextField - أرقام فقط)
- **التحقق**: التحقق من عدم فراغ الحقول وصحة الرقم التعريفي
- **الانتقال**: بعد الحفظ → `HomeScreen`

---

### 3. **HomeScreen** - الصفحة الرئيسية للطالب
- **الموقع**: `lib/screens/home_screen.dart`
- **الوظيفة**: القائمة الرئيسية للطالب
- **الأزرار**:
  - التخصصات الهندسية → `MajorsScreen`
  - اختبار التخصص → `QuizScreen`
  - حساب النسبة الموزونة → `CalculatorScreen`
  - عن التطبيق → `AboutScreen`
- **الحماية**: التحقق من وجود جلسة طالب، وإلا العودة إلى `LoginScreen`
- **زر الرجوع**: العودة إلى `LoginScreen` مع مسح الجلسة

---

### 4. **MajorsScreen** - شاشة التخصصات
- **الموقع**: `lib/screens/majors_screen.dart`
- **الوظيفة**: عرض قائمة بجميع التخصصات الهندسية
- **المميزات**: 
  - بطاقات تفاعلية لكل تخصص
  - النقر على التخصص → `MajorDetailsScreen`
  - التحديث التلقائي عند تغيير البيانات

---

### 5. **MajorDetailsScreen** - تفاصيل التخصص
- **الموقع**: `lib/screens/major_details_screen.dart`
- **الوظيفة**: عرض معلومات تفصيلية عن تخصص معين
- **المعلومات المعروضة**:
  - صورة التخصص
  - الوصف
  - المتطلبات
  - المسارات المهنية
  - رابط الخطة الدراسية (PDF)
- **المميزات**: فتح رابط الخطة الدراسية في المتصفح

---

### 6. **QuizScreen** - شاشة الاختبار
- **الموقع**: `lib/screens/quiz_screen.dart`
- **الوظيفة**: عرض أسئلة اختبار التخصص
- **المميزات**:
  - عرض سؤال واحد في كل مرة
  - 4 خيارات لكل سؤال
  - شريط تقدم
  - زر التالي وزر الإنهاء
- **الانتقال**: بعد الانتهاء → `ResultScreen` مع قائمة الإجابات

---

### 7. **ResultScreen** - شاشة النتائج
- **الموقع**: `lib/screens/result_screen.dart`
- **الوظيفة**: عرض نتائج اختبار التخصص
- **المميزات**:
  - حساب النتيجة باستخدام نظام الأوزان
  - عرض التخصصين الأعلى نقاطاً
  - حفظ/تحديث نتيجة الطالب في قاعدة البيانات
  - النقر على التخصص → `MajorDetailsScreen`

---

### 8. **CalculatorScreen** - حاسبة النسبة الموزونة
- **الموقع**: `lib/screens/calculator_screen.dart`
- **الوظيفة**: حساب النسبة الموزونة للقبول
- **الحقول**:
  - نسبة الثانوية العامة (30%)
  - درجة القدرات (30%)
  - درجة التحصيلي (40%)
- **المخرجات**: النسبة الموزونة النهائية

---

### 9. **AboutScreen** - شاشة عن التطبيق
- **الموقع**: `lib/screens/about_screen.dart`
- **الوظيفة**: معلومات عن التطبيق
- **المحتوى**:
  - نظرة عامة
  - أهداف التطبيق
  - الأسئلة الشائعة (FAQ)

---

### 10. **AdminPlaceholderScreen** - شاشة تحويل الإدمن
- **الموقع**: `lib/screens/admin_placeholder_screen.dart`
- **الوظيفة**: تحويل تلقائي إلى `AdminLoginScreen`
- **الاستخدام**: نقطة انتقالية من `LoginScreen`

---

## 🔧 واجهات الإدمن (Admin Screens)

### 11. **AdminLoginScreen** - تسجيل دخول الإدمن
- **الموقع**: `lib/admin/screens/admin_login_screen.dart`
- **الوظيفة**: تسجيل دخول لوحة التحكم
- **الحقول**: اسم المستخدم وكلمة المرور
- **الانتقال**: بعد تسجيل الدخول → `AdminDashboardScreen`

---

### 12. **AdminDashboardScreen** - لوحة التحكم الرئيسية
- **الموقع**: `lib/admin/screens/admin_dashboard_screen.dart`
- **الوظيفة**: القائمة الرئيسية للإدمن
- **المكونات**:
  - Sidebar للتنقل
  - إحصائيات سريعة (عدد التخصصات والأسئلة)
- **الأقسام**:
  - إدارة التخصصات → `AdminMajorsScreen`
  - إدارة الأسئلة → `AdminQuestionsScreen`
  - الإحصائيات → `AdminStatisticsScreen`

---

### 13. **AdminMajorsScreen** - إدارة التخصصات
- **الموقع**: `lib/admin/screens/admin_majors_screen.dart`
- **الوظيفة**: إدارة التخصصات الهندسية (CRUD)
- **المميزات**:
  - عرض قائمة التخصصات
  - إضافة تخصص جديد
  - تعديل تخصص موجود
  - حذف تخصص
  - رفع صورة التخصص
  - إدخال رابط الخطة الدراسية

---

### 14. **AdminQuestionsScreen** - إدارة الأسئلة
- **الموقع**: `lib/admin/screens/admin_questions_screen.dart`
- **الوظيفة**: إدارة أسئلة الاختبار مع نظام الأوزان
- **المميزات**:
  - عرض قائمة الأسئلة
  - إضافة سؤال جديد مع 4 خيارات
  - تعديل سؤال موجود
  - حذف سؤال
  - **إدارة الأوزان**: لكل خيار (0-3) ولكل تخصص (0-3)
  - التحقق من صحة الأوزان (0، 1، 2، 3 فقط)

---

### 15. **AdminStatisticsScreen** - الإحصائيات
- **الموقع**: `lib/admin/screens/admin_statistics_screen.dart`
- **الوظيفة**: عرض إحصائيات التطبيق
- **المعلومات المعروضة**:
  - عدد الطلاب الفريدين (Unique Students)
  - أكثر التخصصات المختارة (Top 5)
- **المميزات**: التحديث التلقائي عند تغيير البيانات

---

## 📊 ملخص الواجهات

| # | الواجهة | النوع | الوظيفة الرئيسية |
|---|---------|------|------------------|
| 1 | LoginScreen | طالب/إدمن | اختيار نوع الدخول |
| 2 | StudentInfoScreen | طالب | إدخال بيانات الطالب |
| 3 | HomeScreen | طالب | القائمة الرئيسية |
| 4 | MajorsScreen | طالب | عرض التخصصات |
| 5 | MajorDetailsScreen | طالب | تفاصيل التخصص |
| 6 | QuizScreen | طالب | اختبار التخصص |
| 7 | ResultScreen | طالب | نتائج الاختبار |
| 8 | CalculatorScreen | طالب | حساب النسبة الموزونة |
| 9 | AboutScreen | طالب | معلومات التطبيق |
| 10 | AdminPlaceholderScreen | إدمن | تحويل للإدمن |
| 11 | AdminLoginScreen | إدمن | تسجيل دخول الإدمن |
| 12 | AdminDashboardScreen | إدمن | لوحة التحكم |
| 13 | AdminMajorsScreen | إدمن | إدارة التخصصات |
| 14 | AdminQuestionsScreen | إدمن | إدارة الأسئلة والأوزان |
| 15 | AdminStatisticsScreen | إدمن | الإحصائيات |

---

## 🔄 تدفق التنقل (Navigation Flow)

### تدفق الطالب:
```
LoginScreen → StudentInfoScreen → HomeScreen
    ↓
    ├─→ MajorsScreen → MajorDetailsScreen
    ├─→ QuizScreen → ResultScreen → MajorDetailsScreen
    ├─→ CalculatorScreen
    └─→ AboutScreen
```

### تدفق الإدمن:
```
LoginScreen → AdminPlaceholderScreen → AdminLoginScreen → AdminDashboardScreen
    ↓
    ├─→ AdminMajorsScreen
    ├─→ AdminQuestionsScreen
    └─→ AdminStatisticsScreen
```

---

**آخر تحديث**: تم إنشاء هذا الملف بناءً على بنية التطبيق الحالية.

