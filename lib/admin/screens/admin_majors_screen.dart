import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:auto_size_text/auto_size_text.dart';
import '../utils/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/major_model.dart';
import 'package:image_picker/image_picker.dart';

class AdminMajorsScreen extends StatefulWidget {
  const AdminMajorsScreen({super.key});

  @override
  State<AdminMajorsScreen> createState() => _AdminMajorsScreenState();
}

class _AdminMajorsScreenState extends State<AdminMajorsScreen> {
  List<MajorModel> _majors = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMajors();
  }

  Future<void> _loadMajors() async {
    setState(() => _isLoading = true);
    final majors = await DatabaseService.instance.getAllMajors();
    setState(() {
      _majors = majors;
      _isLoading = false;
    });
  }

  /// طلب صلاحية الوصول إلى الصور (المعرض)
  /// 
  /// هذه الدالة تطلب صلاحية الوصول إلى الصور حسب نوع النظام:
  /// - Android 13+ (API 33+): استخدام photos permission
  /// - Android الأقدم: استخدام storage permission
  /// - iOS: استخدام photos permission
  /// 
  /// Returns: true إذا تم منح الصلاحية، false إذا لم يتم منحها
  Future<bool> _requestStoragePermission() async {
    if (kIsWeb) {
      return true; // Web doesn't need permissions
    }

    try {
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use photos permission
        // For older versions, use storage permission
        // image_picker handles this internally, but we check anyway
        if (await Permission.photos.isGranted || 
            await Permission.storage.isGranted) {
          return true;
        }
        
        // Try photos first (Android 13+)
        var status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }
        
        // Fallback to storage for older Android versions
        if (status.isPermanentlyDenied) {
          // User permanently denied, might need to open settings
          return false;
        }
        
        status = await Permission.storage.request();
        return status.isGranted;
      } else if (Platform.isIOS) {
        // For iOS, request photo library permission
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }
    } catch (e) {
      print('Error requesting storage permission: $e');
      // If permission request fails, try to proceed anyway
      // image_picker might handle it
      return true;
    }
    
    return true;
  }

  /// طلب صلاحية الوصول إلى الكاميرا
  /// 
  /// هذه الدالة تطلب صلاحية الوصول إلى الكاميرا للتقاط الصور
  /// 
  /// Returns: true إذا تم منح الصلاحية، false إذا لم يتم منحها
  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    
    return true;
  }

  /// حفظ الصورة على الجهاز
  /// 
  /// هذه الدالة تحفظ الصورة في مجلد majors داخل مجلد التطبيق
  /// وتولّد اسم ملف فريد لتجنب التعارض
  /// 
  /// [imageFile]: ملف الصورة المراد حفظه
  /// Returns: المسار الكامل للصورة المحفوظة
  /// 
  /// مثال على المسار:
  /// /data/user/0/com.example.app/app_flutter/majors/major_1234567890.jpg
  Future<String> _saveImageToDevice(File imageFile) async {
    try {
      print('AdminMajorsScreen: بدء حفظ الصورة...');
      
      // الحصول على مجلد التطبيق
      final appDir = await getApplicationDocumentsDirectory();
      final majorsDir = Directory('${appDir.path}/majors');
      
      // إنشاء المجلد إذا لم يكن موجوداً
      if (!await majorsDir.exists()) {
        await majorsDir.create(recursive: true);
        print('AdminMajorsScreen: تم إنشاء مجلد majors');
      }
      
      // توليد اسم ملف فريد لتجنب التعارض
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'major_$timestamp$extension';
      final savedImage = await imageFile.copy('${majorsDir.path}/$fileName');
      
      print('AdminMajorsScreen: تم حفظ الصورة في: ${savedImage.path}');
      
      return savedImage.path;
    } catch (e) {
      print('AdminMajorsScreen: خطأ في حفظ الصورة - $e');
      rethrow;
    }
  }

  /// عرض نافذة إضافة/تعديل تخصص
  /// 
  /// [major]: نموذج التخصص المراد تعديله (null للإضافة)
  /// 
  /// هذه الدالة تعرض نافذة dialog لإضافة أو تعديل تخصص
  /// وتدعم:
  /// - إدخال بيانات التخصص (الاسم، الوصف، المتطلبات، فرص العمل، رابط الخطة)
  /// - رفع صورة من المعرض أو الكاميرا
  /// - حفظ الصورة على الجهاز
  /// - عرض معاينة الصورة
  /// 
  /// ملاحظة: يتم استخدام LayoutBuilder وMediaQuery لضمان التخطيط الصحيح في Portrait
  Future<void> _showAddEditDialog([MajorModel? major]) async {
    final nameController = TextEditingController(text: major?.name ?? '');
    final descController = TextEditingController(
      text: major?.description ?? '',
    );
    final reqController = TextEditingController(
      text: major?.requirements ?? '',
    );
    final careersController = TextEditingController(text: major?.careers ?? '');
    final planLinkController = TextEditingController(
      text: major?.planLink ?? '',
    );
    String imagePath = major?.imagePath ?? 'assets/images/logo.jpg';

    await showDialog(
      context: context,
      // استخدام isScrollControlled لتجنب مشاكل الكيبورد في Portrait
      // هذا يسمح للـ Dialog بالتمرير عند ظهور الكيبورد
      builder: (context) => Dialog(
        child: StatefulBuilder(
          builder: (context, setDialogState) => LayoutBuilder(
            builder: (context, constraints) {
              // تحديد العرض بناءً على حجم الشاشة
              final dialogWidth = constraints.maxWidth > 600
                  ? 500.0
                  : constraints.maxWidth * 0.9;
              final isPortrait =
                  MediaQuery.of(context).orientation == Orientation.portrait;

              return Container(
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
                            major == null ? 'إضافة تخصص جديد' : 'تعديل تخصص',
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
                    // Content - قابل للتمرير
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'اسم التخصص',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'الوصف',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: reqController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'المتطلبات التقنية',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: careersController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'فرص العمل',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: planLinkController,
                              decoration: const InputDecoration(
                                labelText: 'رابط الخطة الدراسية',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // استخدام Wrap لضمان ظهور الأزرار بشكل صحيح في Portrait
                            // Wrap يلف العناصر تلقائياً عند عدم وجود مساحة كافية
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      // Request permission first
                                      final hasPermission =
                                          await _requestStoragePermission();
                                      if (!hasPermission) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'يجب منح صلاحية الوصول إلى الصور',
                                              ),
                                              backgroundColor: AppColors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // Pick image from gallery
                                      final image = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 85,
                                      );

                                      if (image != null && context.mounted) {
                                        try {
                                          final file = File(image.path);
                                          final savedPath =
                                              await _saveImageToDevice(file);
                                          setDialogState(() {
                                            imagePath = savedPath;
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'تم تحميل الصورة بنجاح',
                                                ),
                                                backgroundColor:
                                                    AppColors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error saving image: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'خطأ في حفظ الصورة: ${e.toString()}',
                                                ),
                                                backgroundColor: AppColors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      print('Error picking image: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'خطأ في اختيار الصورة: ${e.toString()}',
                                            ),
                                            backgroundColor: AppColors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.image),
                                  label: const Text('من المعرض'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      // Request camera permission first
                                      final hasPermission =
                                          await _requestCameraPermission();
                                      if (!hasPermission) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'يجب منح صلاحية الوصول إلى الكاميرا',
                                              ),
                                              backgroundColor: AppColors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }

                                      // Pick image from camera
                                      final image = await _picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 85,
                                      );

                                      if (image != null && context.mounted) {
                                        try {
                                          final file = File(image.path);
                                          final savedPath =
                                              await _saveImageToDevice(file);
                                          setDialogState(() {
                                            imagePath = savedPath;
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'تم التقاط الصورة بنجاح',
                                                ),
                                                backgroundColor:
                                                    AppColors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          print('Error saving image: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'خطأ في حفظ الصورة: ${e.toString()}',
                                                ),
                                                backgroundColor: AppColors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      print('Error capturing image: $e');
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'خطأ في التقاط الصورة: ${e.toString()}',
                                            ),
                                            backgroundColor: AppColors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('من الكاميرا'),
                                ),
                              ],
                            ),
                            if (imagePath.isNotEmpty &&
                                !imagePath.startsWith('assets/'))
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath),
                                    height: isPortrait ? 80 : 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, size: 50);
                                    },
                                  ),
                                ),
                              ),
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
                              if (nameController.text.isNotEmpty &&
                                  descController.text.isNotEmpty) {
                                final majorModel = MajorModel(
                                  id: major?.id,
                                  name: nameController.text,
                                  description: descController.text,
                                  requirements: reqController.text,
                                  careers: careersController.text,
                                  imagePath: imagePath,
                                  planLink: planLinkController.text,
                                );

                                if (major == null) {
                                  await DatabaseService.instance.insertMajor(
                                    majorModel,
                                  );
                                } else {
                                  await DatabaseService.instance.updateMajor(
                                    majorModel,
                                  );
                                }

                                if (mounted) {
                                  Navigator.pop(context);
                                  _loadMajors();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        major == null
                                            ? 'تم إضافة التخصص بنجاح'
                                            : 'تم تحديث التخصص بنجاح',
                                      ),
                                      backgroundColor: AppColors.green,
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
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteMajor(MajorModel major) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${major.name}"؟'),
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

    if (confirm == true && major.id != null) {
      await DatabaseService.instance.deleteMajor(major.id!);
      if (mounted) {
        _loadMajors();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التخصص بنجاح'),
            backgroundColor: AppColors.green,
          ),
        );
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
                // استخدام AutoSizeText للعنوان في Portrait لتجنب القص
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        'إدارة التخصصات',
                        style: TextStyle(
                          fontSize: isPortrait ? 20 : 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 2,
                        minFontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isPortrait)
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة تخصص جديد'),
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
                        tooltip: 'إضافة تخصص جديد',
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
                        label: const Text('إضافة تخصص جديد'),
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
                      : _majors.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد تخصصات مسجلة',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _majors.length,
                          itemBuilder: (context, index) {
                            final major = _majors[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      major.imagePath.startsWith('assets/')
                                      ? AssetImage(major.imagePath)
                                            as ImageProvider
                                      : FileImage(File(major.imagePath)),
                                  radius: isPortrait ? 25 : 30,
                                ),
                                // استخدام AutoSizeText لمنع قص النص في الشاشات الضيقة
                                // AutoSizeText يقلل حجم الخط تلقائياً ليتناسب مع المساحة المتاحة
                                title: AutoSizeText(
                                  major.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                subtitle: AutoSizeText(
                                  major.description,
                                  maxLines: 2,
                                  minFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppColors.darkBlue,
                                      ),
                                      onPressed: () =>
                                          _showAddEditDialog(major),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppColors.red,
                                      ),
                                      onPressed: () => _deleteMajor(major),
                                    ),
                                  ],
                                ),
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
