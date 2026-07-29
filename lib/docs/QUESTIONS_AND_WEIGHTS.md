# دليل بناء الأسئلة وربط الخيارات بالأوزان

## 📋 نظرة عامة

يتيح هذا النظام إضافة أسئلة مع خيارات متعددة وربط كل خيار بأوزان مختلفة للتخصصات الهندسية. عند إجابة الطالب على الأسئلة، يتم حساب النتيجة بناءً على الأوزان المرتبطة بكل خيار.

---

## 🏗️ بنية النظام

### 1. جداول قاعدة البيانات

#### جدول `questions`
```sql
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  questionText TEXT NOT NULL,
  option1 TEXT NOT NULL,
  option2 TEXT NOT NULL,
  option3 TEXT NOT NULL,
  option4 TEXT NOT NULL,
  majorId INTEGER NOT NULL
)
```

#### جدول `question_weights`
```sql
CREATE TABLE question_weights (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  questionId INTEGER NOT NULL,
  majorId INTEGER NOT NULL,
  optionIndex INTEGER NOT NULL,
  weight INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (questionId) REFERENCES questions (id),
  FOREIGN KEY (majorId) REFERENCES majors (id)
)
```

**شرح الحقول:**
- `questionId`: معرف السؤال
- `majorId`: معرف التخصص
- `optionIndex`: فهرس الخيار (0, 1, 2, 3) للخيارات الأربعة
- `weight`: قيمة الوزن (0, 1, 2, 3 فقط، حيث 3 = وزن عالي جداً، 2 = وزن عالي، 1 = وزن متوسط، 0 = لا يوجد وزن)

---

## 🔄 آلية العمل

### 1. إضافة سؤال جديد

عند إضافة سؤال جديد، يتم اتباع الخطوات التالية:

1. **حفظ السؤال في جدول `questions`**
   ```dart
   final questionModel = QuestionModel(
     questionText: "ما هي المواد الدراسية التي تفضل العمل عليها؟",
     option1: "الرياضيات والتحليل",
     option2: "الفيزياء والالكترونيات",
     option3: "التصميم والإبداع",
     option4: "الإدارة والتخطيط",
     majorId: 1, // قيمة افتراضية
   );
   final questionId = await DatabaseService.instance.insertQuestion(questionModel);
   ```

2. **حفظ الأوزان في جدول `question_weights`**
   ```dart
   // لكل خيار، لكل تخصص، احفظ الوزن
   for (int optionIndex = 0; optionIndex < 4; optionIndex++) {
     for (var major in majors) {
       final weight = getWeightForOption(optionIndex, major.id);
       if (weight > 0) {
         await DatabaseService.instance.insertQuestionWeight(
           questionId,
           major.id,
           optionIndex,
           weight,
         );
       }
     }
   }
   ```

### 2. تعديل سؤال موجود

عند تعديل سؤال، يتم:

1. **تحديث السؤال في جدول `questions`**
2. **حذف جميع الأوزان القديمة**
   ```dart
   await DatabaseService.instance.deleteQuestionWeights(questionId);
   ```
3. **إدخال الأوزان الجديدة**

### 3. حساب النتيجة

عند إجابة الطالب على جميع الأسئلة:

1. **جمع الأوزان لكل تخصص**
   ```dart
   final scores = await DatabaseService.instance.calculateScores(answers);
   // scores = {majorId1: totalWeight1, majorId2: totalWeight2, ...}
   ```

2. **ترتيب التخصصات حسب الوزن**
   ```dart
   final sortedMajors = allMajors.map((major) {
     final score = scores[major.id] ?? 0;
     return MapEntry(major, score);
   }).toList()
     ..sort((a, b) => b.value.compareTo(a.value));
   ```

3. **اختيار التخصصين الأعلى نقاطاً**

---

## 📝 مثال عملي: إضافة سؤال جديد

### السؤال:
"ما هي المواد الدراسية التي تفضل العمل عليها؟"

### الخيارات:
1. الرياضيات والتحليل
2. الفيزياء والالكترونيات
3. التصميم والإبداع
4. الإدارة والتخطيط

### ربط الخيارات بالأوزان:

#### الخيار 1: "الرياضيات والتحليل"
- الهندسة المدنية: وزن 2 (علاقة قوية)
- الهندسة الميكانيكية: وزن 1 (علاقة متوسطة)
- الهندسة الكهربائية: وزن 1 (علاقة متوسطة)
- الهندسة الصناعية: وزن 3 (علاقة قوية جداً)
- باقي التخصصات: وزن 0

#### الخيار 2: "الفيزياء والالكترونيات"
- الهندسة الكهربائية: وزن 3 (علاقة قوية جداً)
- الهندسة الميكانيكية: وزن 2 (علاقة قوية)
- هندسة الطاقة المتجددة: وزن 2 (علاقة قوية)
- باقي التخصصات: وزن 0

#### الخيار 3: "التصميم والإبداع"
- الهندسة المعمارية: وزن 3 (علاقة قوية جداً)
- الهندسة المدنية: وزن 1 (علاقة متوسطة)
- باقي التخصصات: وزن 0

#### الخيار 4: "الإدارة والتخطيط"
- الهندسة الصناعية: وزن 3 (علاقة قوية جداً)
- باقي التخصصات: وزن 0

### كود الإضافة:

```dart
// 1. حفظ السؤال
final questionModel = QuestionModel(
  questionText: "ما هي المواد الدراسية التي تفضل العمل عليها؟",
  option1: "الرياضيات والتحليل",
  option2: "الفيزياء والالكترونيات",
  option3: "التصميم والإبداع",
  option4: "الإدارة والتخطيط",
  majorId: 1,
);
final questionId = await DatabaseService.instance.insertQuestion(questionModel);

// 2. حفظ الأوزان للخيار 1
await DatabaseService.instance.insertQuestionWeight(questionId, 1, 0, 2); // مدنية
await DatabaseService.instance.insertQuestionWeight(questionId, 2, 0, 1); // ميكانيكية
await DatabaseService.instance.insertQuestionWeight(questionId, 3, 0, 1); // كهربائية
await DatabaseService.instance.insertQuestionWeight(questionId, 4, 0, 3); // صناعية

// 3. حفظ الأوزان للخيار 2
await DatabaseService.instance.insertQuestionWeight(questionId, 3, 1, 3); // كهربائية
await DatabaseService.instance.insertQuestionWeight(questionId, 2, 1, 2); // ميكانيكية
await DatabaseService.instance.insertQuestionWeight(questionId, 6, 1, 2); // طاقة متجددة

// 4. حفظ الأوزان للخيار 3
await DatabaseService.instance.insertQuestionWeight(questionId, 7, 2, 3); // معمارية
await DatabaseService.instance.insertQuestionWeight(questionId, 1, 2, 1); // مدنية

// 5. حفظ الأوزان للخيار 4
await DatabaseService.instance.insertQuestionWeight(questionId, 4, 3, 3); // صناعية
```

---

## 🎯 استراتيجية تحديد الأوزان

### معايير تحديد الأوزان:

1. **وزن 3 (عالٍ جداً):** عندما يكون الخيار مرتبطاً ارتباطاً وثيقاً جداً بالتخصص
   - مثال: خيار "تصميم مباني" → الهندسة المعمارية (وزن 3)

2. **وزن 2 (عالٍ):** عندما يكون الخيار مرتبطاً ارتباطاً وثيقاً بالتخصص
   - مثال: خيار "تصميم مباني" → الهندسة المدنية (وزن 2)

3. **وزن 1 (متوسط):** عندما يكون الخيار مرتبطاً بشكل جزئي بالتخصص
   - مثال: خيار "الرياضيات" → الهندسة الكهربائية (وزن 1)

4. **وزن 0 (لا يوجد):** عندما لا يكون هناك علاقة بين الخيار والتخصص
   - مثال: خيار "التصميم" → هندسة التعدين (وزن 0)

### نصائح:

- **لا تضع وزن 3 أو 2 لجميع التخصصات في خيار واحد:** هذا يجعل الاختبار غير دقيق
- **وازن الأوزان:** تأكد من أن كل خيار له تخصص واحد على الأقل بوزن 2 أو 3
- **استخدم الأوزان بشكل متدرج:** استخدم 3 للتخصصات الأكثر ارتباطاً، و2 للارتباط القوي، و1 للارتباط المتوسط
- **اختبر النتائج:** بعد إضافة سؤال، اختبر الاختبار وتحقق من صحة النتائج

---

## 🔍 كيفية عرض الأوزان

في لوحة التحكم، يمكنك:

1. **عرض جميع الأسئلة:** اذهب إلى "إدارة الأسئلة"
2. **تعديل سؤال:** اضغط على زر التعديل
3. **عرض الأوزان:** ستظهر الأوزان لكل خيار تحت اسم كل تخصص
4. **تعديل الأوزان:** غيّر القيمة في حقل "الوزن" ثم احفظ

---

## 📊 مثال حساب النتيجة

### الأسئلة والإجابات:
- السؤال 1: الخيار 1 (الرياضيات) → وزن 2 للمدنية، وزن 1 للميكانيكية
- السؤال 2: الخيار 2 (الفيزياء) → وزن 3 للكهربائية، وزن 2 للميكانيكية
- السؤال 3: الخيار 3 (التصميم) → وزن 3 للمعمارية

### النتيجة:
- الهندسة المدنية: 2 (من السؤال 1)
- الهندسة الميكانيكية: 1 + 2 = 3 (من السؤال 1 و 2)
- الهندسة الكهربائية: 3 (من السؤال 2)
- الهندسة المعمارية: 3 (من السؤال 3)

**الترتيب:** الكهربائية (3) = المعمارية (3) = الميكانيكية (3) > المدنية (2)

---

## ✅ الخلاصة

نظام الأوزان يسمح بإنشاء اختبار دقيق يربط إجابات الطالب بالتخصصات المناسبة. عند إضافة سؤال جديد:

1. أضف السؤال مع 4 خيارات
2. حدد الأوزان لكل خيار لكل تخصص
3. اختبر النتيجة للتأكد من صحتها
4. احفظ التغييرات

للحصول على أفضل النتائج، تأكد من:
- ربط كل خيار بتخصص واحد على الأقل بوزن عالي (2 أو 3)
- توزيع الأوزان بشكل متوازن باستخدام الأوزان الأربعة (0، 1، 2، 3)
- استخدام وزن 3 للتخصصات الأكثر ارتباطاً بالخيار
- اختبار النتائج بعد إضافة أي سؤال جديد

