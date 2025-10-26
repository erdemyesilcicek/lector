// lib/widgets/rating_modal_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart';
import 'package:lector/core/constants/app_constants.dart';

class RatingModal extends StatefulWidget {
  final int? initialRating;
  final String? initialNotes;

  const RatingModal({super.key, this.initialRating, this.initialNotes});

  @override
  State<RatingModal> createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _rating = 0;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRating != null) {
      _rating = widget.initialRating!;
    }
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.initialRating == null
                ? 'Rate this book'
                : 'Edit your rating',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.star,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Your notes (optional)',
            ),
            style: textTheme.bodyLarge,
            maxLines: 1,
            scrollPadding: const EdgeInsets.only(bottom: 100),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(
            onPressed: _rating == 0
                ? null
                : () {
                    Navigator.pop(context, {
                      'rating': _rating,
                      'notes': _notesController.text,
                    });
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingMedium,
              ),
              backgroundColor: _rating == 0 ? null : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Text(
              'Save Rating',
              style: textTheme.headlineSmall?.copyWith(
                color: _rating == 0 ? null : AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
