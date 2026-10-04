import 'package:flutter/material.dart';
import 'package:delego/Theme/design_tokens.dart';
import 'package:delego/Widgets/cards.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        radius: AppRadii.md,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sectionName.toUpperCase(),
                      style: AppType.eyebrow(AppColors.textTertiary).copyWith(fontSize: 10.5)),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.edit_outlined, color: AppColors.hotPink, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
