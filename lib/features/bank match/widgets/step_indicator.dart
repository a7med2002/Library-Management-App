import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  static const List<String> _labels = ['رفع الملف', 'المعالجة', 'النتائج'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: List.generate(3, (index) {
          final step = 3 - index; // RTL: 3,2,1
          final label = _labels[step - 1];
          final isActive = step == currentStep;
          final isDone = step < currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index != 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone || isActive ? kAccentColor : kDividerColor,
                    ),
                  ),
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? kAccentColor
                            : isDone
                            ? kSuccessColor
                            : kDividerColor,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                color: kWhiteColor,
                                size: 16,
                              )
                            : Text(
                                step.toString(),
                                style: AppTextStyles.caption.copyWith(
                                  color: isActive
                                      ? kWhiteColor
                                      : kSecondaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive ? kAccentColor : kSecondaryTextColor,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
