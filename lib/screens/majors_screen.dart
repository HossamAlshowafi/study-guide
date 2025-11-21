import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../models/major_model.dart';
import '../widgets/major_card.dart';
import 'major_details_screen.dart';

class MajorsScreen extends StatelessWidget {
  const MajorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التخصصات الهندسية'),
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
          // الاستماع لتغييرات قاعدة البيانات لتحديث الواجهة تلقائياً
          // كل دالة CRUD يجب أن تستدعي notifyChanges() لضمان تزامن الواجهات
          child: StreamBuilder<void>(
            stream: DatabaseService.instance.changes,
            initialData: null,
            builder: (context, snapshot) {
              return FutureBuilder<List<MajorModel>>(
                future: DatabaseService.instance.getAllMajors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    print('MajorsScreen: خطأ في تحميل التخصصات - ${snapshot.error}');
                    return Center(
                      child: Text('حدث خطأ: ${snapshot.error}'),
                    );
                  }

                  final majors = snapshot.data ?? [];

                  if (majors.isEmpty) {
                    return const Center(
                      child: Text('لا توجد تخصصات متاحة'),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final screenHeight = constraints.maxHeight;
                      final isPortrait = screenHeight > screenWidth;
                      
                      // Calculate responsive grid
                      int crossAxisCount = 2;
                      if (screenWidth > 1200) {
                        crossAxisCount = 4;
                      } else if (screenWidth > 800) {
                        crossAxisCount = 3;
                      } else if (screenWidth > 600) {
                        crossAxisCount = 2;
                      } else {
                        crossAxisCount = 1;
                      }

                      // Calculate card aspect ratio based on orientation
                      // تقليل aspectRatio لإزالة المساحات الفارغة
                      double aspectRatio = 0.65;
                      if (isPortrait) {
                        aspectRatio = 0.75; // زيادة الارتفاع نسبياً في Portrait
                      } else {
                        aspectRatio = 0.85;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: majors.length,
                          itemBuilder: (context, index) {
                            final major = majors[index];
                            return MajorCard(
                              name: major.name,
                              imagePath: major.imagePath,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MajorDetailsScreen(
                                      major: major.toMap(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
