import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class QuizOption extends StatefulWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<QuizOption> createState() => _QuizOptionState();
}

class _QuizOptionState extends State<QuizOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.darkBlue
              : _isHovered
              ? AppColors.lightBlue
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected ? AppColors.darkBlue : AppColors.gray,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: widget.isSelected ? null : widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? Colors.white : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.darkBlue,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.darkBlue,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isSelected
                        ? AppColors.white
                        : AppColors.darkBlue,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
