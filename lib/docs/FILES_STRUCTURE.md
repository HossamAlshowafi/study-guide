# هيكل الملفات والتوثيق

## 📁 نظرة عامة على المشروع

هذا المشروع هو تطبيق Flutter لتطبيق "دليلك الدراسي" الذي يساعد الطلاب على اختيار التخصص الهندسي المناسب.

---

## 🗂️ هيكل المجلدات الرئيسية

### `lib/`
المجلد الرئيسي الذي يحتوي على جميع ملفات الكود المصدري.

#### `lib/models/`
نماذج البيانات (Data Models)

- **`major_model.dart`**: نموذج بيانات التخصص الهندسي
  - يحتوي على: `id`, `name`, `description`, `requirements`, `careers`, `imagePath`, `planLink`, `displayOrder`
  - دوال: `toMap()`, `fromMap()`, `copyWith()`

- **`question_model.dart`**: نموذج بيانات السؤال
  - يحتوي على: `id`, `questionText`, `option1`, `option2`, `option3`, `option4`, `majorId`
  - دوال: `toMap()`, `fromMap()`, `copyWith()`

- **`question_weight_model.dart`**: نموذج بيانات وزن السؤال
  - يحتوي على: `id`, `questionId`, `majorId`, `optionIndex`, `weight`
  - دوال: `toMap()`, `fromMap()`, `copyWith()`

#### `lib/database/`
قاعدة البيانات (Database)

- **`database_helper.dart`**: مساعد قاعدة البيانات SQLite
  - **الدوال الرئيسية:**
    - `_initDB()`: تهيئة قاعدة البيانات
    - `_createDB()`: إنشاء الجداول
    - `_onUpgrade()`: تحديث قاعدة البيانات
    - `_insertDefaultMajors()`: إدراج التخصصات الافتراضية
    - `_insertDefaultQuestions()`: إدراج الأسئلة الافتراضية
    - `insertMajor()`, `getAllMajors()`, `updateMajor()`, `deleteMajor()`: عمليات CRUD للتخصصات
    - `insertQuestion()`, `getAllQuestions()`, `updateQuestion()`, `deleteQuestion()`: عمليات CRUD للأسئلة
    - `insertQuestionWeight()`, `getQuestionWeights()`, `deleteQuestionWeights()`: عمليات الأوزان
    - `calculateScores()`: حساب النتائج بناءً على الإجابات
    - `insertQuizResult()`, `getQuizResultsCount()`, `getMostSelectedMajors()`: عمليات نتائج الاختبارات

#### `lib/services/`
الخدمات (Services)

- **`database_service.dart`**: خدمة قاعدة البيانات
  - **الدوال الرئيسية:**
    - `insertMajor()`, `getAllMajors()`, `updateMajor()`, `deleteMajor()`: عمليات CRUD للتخصصات
    - `insertQuestion()`, `getAllQuestions()`, `updateQuestion()`, `deleteQuestion()`: عمليات CRUD للأسئلة
    - `insertQuestionWeight()`, `getQuestionWeights()`, `deleteQuestionWeights()`: عمليات الأوزان
    - `calculateScores()`: حساب النتائج
    - `insertQuizResult()`, `getQuizResultsCount()`, `getMostSelectedMajors()`: عمليات نتائج الاختبارات
    - `notifyChanges()`: إشعار التغييرات للواجهات
    - `changes`: Stream للتغييرات

- **`quiz_service.dart`**: خدمة الاختبار
  - **الدوال الرئيسية:**
    - `prepareQuiz()`: تهيئة الاختبار وجلب الأسئلة

#### `lib/screens/`
الشاشات (Screens)

- **`home_screen.dart`**: الشاشة الرئيسية
  - عرض قائمة بالخيارات: التخصصات، الاختبار، الحاسبة، عن التطبيق
  - **الدوال الرئيسية:**
    - `_prepareAndNavigateToQuiz()`: تهيئة الاختبار والانتقال إليه

- **`majors_screen.dart`**: شاشة عرض التخصصات
  - عرض جميع التخصصات في GridView
  - **الدوال الرئيسية:**
    - استخدام `StreamBuilder` للاستماع للتغييرات

- **`major_details_screen.dart`**: شاشة تفاصيل التخصص
  - عرض معلومات التخصص (الوصف، المتطلبات، فرص العمل)
  - زر لعرض الخطة الدراسية (PDF)
  - **الدوال الرئيسية:**
    - `_launchURL()`: فتح رابط PDF

- **`quiz_screen.dart`**: شاشة الاختبار
  - عرض الأسئلة واحدة تلو الأخرى
  - شريط التقدم
  - **الدوال الرئيسية:**
    - `_loadQuestions()`: تحميل الأسئلة
    - `_selectAnswer()`: اختيار إجابة والانتقال للسؤال التالي

- **`result_screen.dart`**: شاشة النتائج
  - عرض التخصصين الأعلى نقاطاً
  - **الدوال الرئيسية:**
    - `_calculateResults()`: حساب النتائج وحفظها

- **`calculator_screen.dart`**: شاشة الحاسبة
  - حساب النسبة الموزونة

- **`about_screen.dart`**: شاشة عن التطبيق
  - معلومات عن التطبيق

#### `lib/admin/`
لوحة التحكم (Admin Panel)

##### `lib/admin/screens/`
شاشات لوحة التحكم

- **`admin_dashboard_screen.dart`**: لوحة التحكم الرئيسية
  - عرض الإحصائيات (عدد التخصصات، عدد الأسئلة)
  - أزرار الإجراءات السريعة (إدارة التخصصات، إدارة الأسئلة)
  - **الدوال الرئيسية:**
    - `_loadStatistics()`: تحميل الإحصائيات
    - `_buildStatCard()`: بناء بطاقة إحصائية
    - `_buildActionCard()`: بناء بطاقة إجراء

- **`admin_majors_screen.dart`**: شاشة إدارة التخصصات
  - عرض جميع التخصصات
  - إضافة/تعديل/حذف تخصصات
  - رفع صور التخصصات
  - **الدوال الرئيسية:**
    - `_loadMajors()`: تحميل التخصصات
    - `_showAddEditDialog()`: عرض نافذة إضافة/تعديل
    - `_deleteMajor()`: حذف تخصص
    - `_requestStoragePermission()`, `_requestCameraPermission()`: طلب الصلاحيات
    - `_saveImageToDevice()`: حفظ الصورة

- **`admin_questions_screen.dart`**: شاشة إدارة الأسئلة
  - عرض جميع الأسئلة
  - إضافة/تعديل/حذف أسئلة
  - ربط الخيارات بالأوزان
  - **الدوال الرئيسية:**
    - `_loadData()`: تحميل البيانات
    - `_showAddEditDialog()`: عرض نافذة إضافة/تعديل مع الأوزان
    - `_deleteQuestion()`: حذف سؤال

- **`admin_statistics_screen.dart`**: شاشة الإحصائيات
  - عرض عدد الطلاب الذين قاموا بالاختبار
  - عرض أكثر التخصصات المختارة
  - **الدوال الرئيسية:**
    - `_loadStatistics()`: تحميل الإحصائيات

##### `lib/admin/widgets/`
عناصر واجهة لوحة التحكم

- **`admin_sidebar.dart`**: القائمة الجانبية
  - قائمة التنقل في لوحة التحكم

##### `lib/admin/utils/`
أدوات لوحة التحكم

- **`app_colors.dart`**: ألوان التطبيق
  - تعريف الألوان المستخدمة في التطبيق

#### `lib/widgets/`
العناصر المشتركة (Shared Widgets)

- **`custom_button.dart`**: زر مخصص
  - زر قابل للتخصيص مع أيقونة ونص

- **`major_card.dart`**: بطاقة التخصص
  - عرض تخصص في بطاقة مع صورة واسم

- **`quiz_option.dart`**: خيار الاختبار
  - عرض خيار في الاختبار مع إمكانية الاختيار

- **`info_tile.dart`**: بلاط معلومات
  - عرض معلومة في شكل بلاط

#### `lib/utils/`
الأدوات المساعدة (Utilities)

- **`app_colors.dart`**: ألوان التطبيق
  - تعريف الألوان المستخدمة

#### `lib/docs/`
التوثيق (Documentation)

- **`QUESTIONS_AND_WEIGHTS.md`**: دليل بناء الأسئلة وربط الخيارات بالأوزان
- **`FILES_STRUCTURE.md`**: هذا الملف - هيكل الملفات

---

## 🔧 الملفات الرئيسية

### `lib/main.dart`
نقطة الدخول الرئيسية للتطبيق
- تهيئة التطبيق
- تحديد الشاشة الأولى

### `pubspec.yaml`
ملف التبعيات والإعدادات
- قائمة الحزم المستخدمة
- إعدادات التطبيق
- الموارد (الصور، الخطوط)

---

## 📊 تدفق البيانات

### 1. تحميل التخصصات
```
MajorsScreen → DatabaseService → DatabaseHelper → SQLite → MajorsScreen
```

### 2. إضافة سؤال جديد
```
AdminQuestionsScreen → DatabaseService → DatabaseHelper → SQLite
→ notifyChanges() → Stream → AdminQuestionsScreen (تحديث تلقائي)
```

### 3. حساب النتيجة
```
QuizScreen → ResultScreen → DatabaseService.calculateScores()
→ DatabaseHelper.calculateScores() → SQLite → ResultScreen
→ DatabaseService.insertQuizResult() → SQLite
```

---

## 🗄️ قاعدة البيانات

### الجداول:
1. **`majors`**: التخصصات الهندسية
2. **`questions`**: الأسئلة
3. **`question_weights`**: الأوزان المرتبطة بالخيارات
4. **`quiz_results`**: نتائج الاختبارات

### العلاقات:
- `questions.majorId` → `majors.id` (قيمة افتراضية)
- `question_weights.questionId` → `questions.id`
- `question_weights.majorId` → `majors.id`
- `quiz_results.majorId` → `majors.id`

---

## 🎨 الواجهات

### شاشات الطالب:
1. HomeScreen: الشاشة الرئيسية
2. MajorsScreen: عرض التخصصات
3. MajorDetailsScreen: تفاصيل التخصص
4. QuizScreen: الاختبار
5. ResultScreen: النتائج
6. CalculatorScreen: الحاسبة
7. AboutScreen: عن التطبيق

### شاشات المسؤول:
1. AdminDashboardScreen: لوحة التحكم
2. AdminMajorsScreen: إدارة التخصصات
3. AdminQuestionsScreen: إدارة الأسئلة
4. AdminStatisticsScreen: الإحصائيات

---

## 🔐 الصلاحيات

### Android:
- `INTERNET`: للوصول إلى الإنترنت
- `READ_EXTERNAL_STORAGE`: لقراءة الصور
- `READ_MEDIA_IMAGES`: لقراءة الصور (Android 13+)
- `CAMERA`: للكاميرا

### iOS:
- `NSPhotoLibraryUsageDescription`: للوصول إلى الصور
- `NSCameraUsageDescription`: للكاميرا
- `NSPhotoLibraryAddUsageDescription`: لحفظ الصور

---

## 📱 الميزات

### للمستخدم:
- عرض التخصصات الهندسية
- إجراء اختبار لتحديد التخصص المناسب
- حساب النسبة الموزونة
- عرض تفاصيل كل تخصص
- عرض الخطة الدراسية (PDF)

### للمسؤول:
- إدارة التخصصات (إضافة/تعديل/حذف)
- إدارة الأسئلة (إضافة/تعديل/حذف)
- ربط الخيارات بالأوزان
- عرض الإحصائيات
- رفع صور التخصصات

---

## 🚀 كيفية البدء

1. **تثبيت التبعيات:**
   ```bash
   flutter pub get
   ```

2. **تشغيل التطبيق:**
   ```bash
   flutter run
   ```

3. **بناء APK:**
   ```bash
   flutter build apk
   ```

---

## 📝 ملاحظات

- جميع الشاشات تدعم RTL (Right-to-Left)
- قاعدة البيانات SQLite محلية على الجهاز
- التحديثات تظهر تلقائياً باستخدام Stream
- الصور المحملة تُحفظ في مجلد التطبيق
- نتائج الاختبارات تُحفظ لتتبع الإحصائيات

---

## 🔄 التحديثات المستقبلية

- إضافة نظام المصادقة
- إضافة نظام الإشعارات
- إضافة نظام النسخ الاحتياطي
- إضافة نظام التصدير/الاستيراد
- إضافة نظام التقييمات

---

## ✅ الخلاصة

هذا المشروع مبني على Flutter ويستخدم SQLite لتخزين البيانات محلياً. النظام يدعم إدارة التخصصات والأسئلة مع نظام أوزان متقدم لحساب النتائج بدقة.

