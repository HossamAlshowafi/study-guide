/// إدارة الأسئلة مع نظام الأوزان
///
/// هذا الملف يحتوي على شاشة إدارة الأسئلة مع نظام الأوزان المرتبط بكل خيار.
///
/// آلية العمل:
/// 1. عند إضافة سؤال جديد:
///    - يتم حفظ السؤال في جدول questions
///    - يتم استرجاع questionId
///    - يتم حفظ الأوزان في جدول question_weights (questionId, majorId, optionIndex, weight)
///
/// 2. عند تعديل سؤال:
///    - يتم تحديث السؤال في جدول questions
///    - يتم حذف الأوزان القديمة من question_weights
///    - يتم إدخال الأوزان الجديدة
///
/// 3. عند الحذف:
///    - يتم حذف السؤال من questions
///    - يتم حذف الأوزان المرتبطة تلقائياً (CASCADE DELETE)
///
/// مثال عملي:
/// - السؤال: "هل تحب العمل مع الدوائر الكهربائية؟"
/// - الخيار 1: "نعم" => weights: (Electrical Engineering: 2, Mechanical Engineering: 0)
/// - الخيار 2: "لا"  => weights: (Electrical Engineering: 0, Mechanical Engineering: 0)
///
/// عند حفظ السؤال، نحفظ السؤال ثم نحفظ الأوزان في جدول question_weights.

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../utils/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/question_model.dart';
import '../../models/major_model.dart';

class AdminQuestionsScreen extends StatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  List<QuestionModel> _questions = [];
  List<MajorModel> _majors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // الاستماع لتغييرات قاعدة البيانات لتحديث الواجهة تلقائياً
    DatabaseService.instance.changes.listen((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  /// تحميل البيانات من قاعدة البيانات
  /// كل دالة CRUD يجب أن تستدعي notifyChanges() لضمان تزامن الواجهات
  Future<void> _loadData() async {
    try {
      print('AdminQuestionsScreen: بدء تحميل البيانات...');
      setState(() => _isLoading = true);

      final questions = await DatabaseService.instance.getAllQuestions();
      final majors = await DatabaseService.instance.getAllMajors();

      print(
        'AdminQuestionsScreen: تم تحميل ${questions.length} سؤال و ${majors.length} تخصص',
      );

      setState(() {
        _questions = questions;
        _majors = majors;
        _isLoading = false;
      });
    } catch (e) {
      print('AdminQuestionsScreen: خطأ في تحميل البيانات - $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل البيانات: ${e.toString()}'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  /// عرض نافذة إضافة/تعديل سؤال مع نظام الأوزان
  Future<void> _showAddEditDialog([QuestionModel? question]) async {
    final questionController = TextEditingController(
      text: question?.questionText ?? '',
    );
    final option1Controller = TextEditingController(
      text: question?.option1 ?? '',
    );
    final option2Controller = TextEditingController(
      text: question?.option2 ?? '',
    );
    final option3Controller = TextEditingController(
      text: question?.option3 ?? '',
    );
    final option4Controller = TextEditingController(
      text: question?.option4 ?? '',
    );
    // ملاحظة: حقل majorId لم يعد مستخدماً بعد نظام الأوزان الجديد
    // لكن نحتفظ به للتوافق مع قاعدة البيانات (يستخدم قيمة افتراضية)

    // جلب الأوزان الحالية إذا كان تعديل
    Map<int, Map<int, int>> weightsMap =
        {}; // optionIndex -> {majorId -> weight}
    if (question?.id != null) {
      try {
        final weights = await DatabaseService.instance.getQuestionWeights(
          question!.id!,
        );
        for (var weight in weights) {
          final optionIndex = weight['optionIndex'] as int;
          final majorId = weight['majorId'] as int;
          final weightValue = weight['weight'] as int;

          if (!weightsMap.containsKey(optionIndex)) {
            weightsMap[optionIndex] = {};
          }
          weightsMap[optionIndex]![majorId] = weightValue;
        }
      } catch (e) {
        print('خطأ في جلب الأوزان: $e');
      }
    }

    // Controllers للأوزان لكل خيار
    final List<Map<int, TextEditingController>> weightControllers = [
      {}, // Option 0
      {}, // Option 1
      {}, // Option 2
      {}, // Option 3
    ];

    // تهيئة Controllers للأوزان الموجودة
    for (int optionIndex = 0; optionIndex < 4; optionIndex++) {
      if (weightsMap.containsKey(optionIndex)) {
        for (var major in _majors) {
          final weight = weightsMap[optionIndex]![major.id] ?? 0;
          weightControllers[optionIndex][major.id!] = TextEditingController(
            text: weight.toString(),
          );
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => LayoutBuilder(
          builder: (context, constraints) {
            final dialogWidth = constraints.maxWidth > 600
                ? 600.0
                : constraints.maxWidth * 0.95;

            return Dialog(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                  maxWidth: dialogWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            question == null ? 'إضافة سؤال جديد' : 'تعديل سؤال',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: questionController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'نص السؤال',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // الخيارات
                            ...List.generate(4, (index) {
                              final controllers = [
                                option1Controller,
                                option2Controller,
                                option3Controller,
                                option4Controller,
                              ];
                              return Column(
                                children: [
                                  TextField(
                                    controller: controllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'الخيار ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // الأوزان لهذا الخيار
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGray,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الأوزان للخيار ${index + 1}:',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._majors.map((major) {
                                          if (!weightControllers[index]
                                              .containsKey(major.id)) {
                                            weightControllers[index][major
                                                .id!] = TextEditingController(
                                              text: '0',
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(major.name),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  flex: 1,
                                                  child: TextField(
                                                    controller:
                                                        weightControllers[index][major
                                                            .id],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText: 'الوزن',
                                                      border:
                                                          const OutlineInputBorder(),
                                                      isDense: true,
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
                                  const SizedBox(height: 16),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (questionController.text.isNotEmpty &&
                                  option1Controller.text.isNotEmpty) {
                                try {
                                  print(
                                    'AdminQuestionsScreen: بدء حفظ السؤال...',
                                  );

                                  // ========== الخطوة 1: حفظ السؤال ==========
                                  // ملاحظة: majorId يستخدم قيمة افتراضية (أول تخصص)
                                  // لأن نظام الأوزان الجديد يستخدم question_weights بدلاً منه
                                  final questionModel = QuestionModel(
                                    id: question?.id,
                                    questionText: questionController.text,
                                    option1: option1Controller.text,
                                    option2: option2Controller.text,
                                    option3: option3Controller.text,
                                    option4: option4Controller.text,
                                    majorId:
                                        _majors.firstOrNull?.id ??
                                        1, // قيمة افتراضية
                                  );

                                  int questionId;
                                  if (question == null) {
                                    // إضافة سؤال جديد
                                    questionId = await DatabaseService.instance
                                        .insertQuestion(questionModel);
                                    print(
                                      'AdminQuestionsScreen: تم إضافة السؤال برقم $questionId',
                                    );
                                  } else {
                                    // تحديث سؤال موجود
                                    // حذف الأوزان القديمة قبل التحديث
                                    await DatabaseService.instance
                                        .deleteQuestionWeights(question.id!);
                                    await DatabaseService.instance
                                        .updateQuestion(questionModel);
                                    questionId = question.id!;
                                    print(
                                      'AdminQuestionsScreen: تم تحديث السؤال برقم $questionId',
                                    );
                                  }

                                  // ========== الخطوة 2: حفظ الأوزان ==========
                                  // لكل خيار (0, 1, 2, 3)، لكل تخصص، احفظ الوزن إذا كان > 0
                                  // هذا يسمح بربط كل خيار بتخصصات متعددة بأوزان مختلفة
                                  print(
                                    'AdminQuestionsScreen: بدء حفظ الأوزان...',
                                  );
                                  for (
                                    int optionIndex = 0;
                                    optionIndex < 4;
                                    optionIndex++
                                  ) {
                                    for (var major in _majors) {
                                      if (major.id != null) {
                                        final weightText =
                                            weightControllers[optionIndex][major
                                                    .id]
                                                ?.text ??
                                            '0';
                                        final weight =
                                            int.tryParse(weightText) ?? 0;

                                        // حفظ الوزن فقط إذا كان > 0 لتوفير المساحة
                                        if (weight > 0) {
                                          await DatabaseService.instance
                                              .insertQuestionWeight(
                                                questionId,
                                                major.id!,
                                                optionIndex,
                                                weight,
                                              );
                                        }
                                      }
                                    }
                                  }
                                  print(
                                    'AdminQuestionsScreen: تم حفظ الأوزان بنجاح',
                                  );

                                  // ========== الخطوة 3: تحديث الواجهات ==========
                                  // notifyChanges() يتم استدعاؤه تلقائياً في DatabaseService
                                  // هذا يضمن تحديث جميع الواجهات تلقائياً

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _loadData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          question == null
                                              ? 'تم إضافة السؤال والأوزان بنجاح'
                                              : 'تم تحديث السؤال والأوزان بنجاح',
                                        ),
                                        backgroundColor: AppColors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print(
                                    'AdminQuestionsScreen: خطأ في حفظ السؤال - $e',
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'حدث خطأ أثناء الحفظ: ${e.toString()}',
                                        ),
                                        backgroundColor: AppColors.red,
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يرجى ملء جميع الحقول المطلوبة',
                                      ),
                                      backgroundColor: AppColors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('حفظ'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// حذف سؤال مع التأكيد
  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'هل أنت متأكد من حذف هذا السؤال؟ سيتم حذف جميع الأوزان المرتبطة به أيضاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && question.id != null) {
      try {
        print('AdminQuestionsScreen: بدء حذف السؤال ${question.id}...');
        await DatabaseService.instance.deleteQuestion(question.id!);
        // notifyChanges() يتم استدعاؤه تلقائياً في DatabaseService

        print('AdminQuestionsScreen: تم حذف السؤال بنجاح');

        if (mounted) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف السؤال بنجاح'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        print('AdminQuestionsScreen: خطأ في حذف السؤال - $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء الحذف: ${e.toString()}'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.lightBlue, Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isPortrait ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'إدارة الأسئلة',
                        style: TextStyle(
                          fontSize: isPortrait ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                    if (!isPortrait)
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة سؤال جديد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        color: AppColors.darkBlue,
                        tooltip: 'إضافة سؤال جديد',
                      ),
                  ],
                ),
                if (isPortrait)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة سؤال جديد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _questions.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد أسئلة مسجلة',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: AutoSizeText(
                                  question.questionText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: const Text(
                                  'اضغط للتوسيع لعرض الخيارات',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('1. ${question.option1}'),
                                        Text('2. ${question.option2}'),
                                        Text('3. ${question.option3}'),
                                        Text('4. ${question.option4}'),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: AppColors.darkBlue,
                                              ),
                                              onPressed: () =>
                                                  _showAddEditDialog(question),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: AppColors.red,
                                              ),
                                              onPressed: () =>
                                                  _deleteQuestion(question),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
