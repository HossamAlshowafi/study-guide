import 'package:flutter/material.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/app_colors.dart';
import '../widgets/info_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MajorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> major;

  const MajorDetailsScreen({super.key, required this.major});

  String _getMajorField(String key) {
    return major[key] as String? ?? '';
  }

  Widget _buildImageWidget() {
    final imagePathValue = _getMajorField('imagePath');
    final imageValue = _getMajorField('image');
    final imagePath = imagePathValue.isNotEmpty
        ? imagePathValue
        : (imageValue.isNotEmpty ? imageValue : 'assets/images/logo.jpg');

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            color: AppColors.lightBlue,
            child: const Icon(Icons.image, size: 60, color: AppColors.darkBlue),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            color: AppColors.lightBlue,
            child: const Icon(Icons.image, size: 60, color: AppColors.darkBlue),
          );
        },
      );
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    if (url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الخطة الدراسية غير متوفر'),
            backgroundColor: AppColors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Check internet connection
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة.'),
              backgroundColor: AppColors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      // Continue anyway, let url_launcher handle it
    }

    // Launch URL
    try {
      final uri = Uri.parse(url);
      
      // Check if URL can be launched
      if (!await canLaunchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح الرابط. يرجى التحقق من الاتصال بالإنترنت.'),
              backgroundColor: AppColors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Launch URL with external application mode for mobile
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل فتح الرابط'),
              backgroundColor: AppColors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح الرابط: ${e.toString()}'),
            backgroundColor: AppColors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل التخصص'),
          backgroundColor: AppColors.darkBlue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImageWidget(),
              ),
              const SizedBox(height: 24),
              // Title
              Center(
                child: Text(
                  _getMajorField('name'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Info Tiles
              InfoTile(
                icon: Icons.info_outline,
                title: 'نبذة عن التخصص',
                content: _getMajorField('description'),
              ),
              InfoTile(
                icon: Icons.build,
                title: 'المتطلبات التقنية',
                content: _getMajorField('requirements'),
              ),
              InfoTile(
                icon: Icons.work_outline,
                title: 'فرص العمل المستقبلية',
                content: _getMajorField('careers'),
              ),
              const SizedBox(height: 24),
              // Study Plan Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchURL(context, _getMajorField('planLink'));
                  },
                  icon: const Icon(FontAwesomeIcons.graduationCap, size: 24),
                  label: const Text(
                    'عرض الخطة الدراسية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
