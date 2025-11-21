import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/app_colors.dart';

class MajorCard extends StatefulWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const MajorCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<MajorCard> createState() => _MajorCardState();
}

class _MajorCardState extends State<MajorCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: Card(
          elevation: _isHovered ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // تقليل الحجم إلى الحد الأدنى
              children: [
                Expanded(
                  flex: 3, // نسبة 3 للصورة
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: widget.imagePath.startsWith('assets/')
                        ? Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightBlue,
                                child: const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: AppColors.darkBlue,
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightBlue,
                                child: const Icon(
                                  Icons.image,
                                  size: 60,
                                  color: AppColors.darkBlue,
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10, // تقليل الـ padding العمودي
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? AppColors.darkBlue : AppColors.gray,
                      height: 1.2, // تقليل ارتفاع السطر
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
