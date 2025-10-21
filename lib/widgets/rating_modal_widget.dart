// lib/widgets/rating_modal_widget.dart

import 'package:flutter/material.dart';
import 'package:lector/core/constants/app_colors.dart'; // Accent rengi için
import 'package:lector/core/constants/app_constants.dart';

class RatingModal extends StatefulWidget {
  final int? initialRating;
  final String? initialNotes;

  const RatingModal({
    super.key,
    this.initialRating,
    this.initialNotes,
  });

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
    // Mevcut temayı alıyoruz
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Modal'ın arka plan rengini ve köşe yuvarlaklığını ayarlıyoruz
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppConstants.paddingLarge,
          AppConstants.paddingMedium,
          AppConstants.paddingLarge,
          MediaQuery.of(context).viewInsets.bottom + AppConstants.paddingLarge // Klavye için boşluk
      ),
      // Tema'nın yüzey rengini kullanıyoruz (Aydınlıkta beyaz, Karanlıkta gri)
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
          // Başlık (Tema metin stilini kullanıyor)
          Text(
            widget.initialRating == null ? 'Rate this book' : 'Edit your rating',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall, // Tema'dan headline3
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // Yıldızlar (Accent rengini kullanıyor)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() { _rating = index + 1; });
                },
                icon: Icon(
                  index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  // Accent rengini kullanıyoruz (Aydınlıkta siyah, Karanlıkta altın)
                  color: AppColors.accent, // Accent'i sabit tuttuk, daha iyi görünebilir.
                  size: 40, // Biraz daha büyük yıldızlar
                ),
              );
            }),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          // Not Alanı (Tema input stilini kullanıyor)
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Your notes (optional)', // HintText daha iyi
            ),
            style: textTheme.bodyLarge,
            maxLines: 3,
            // Klavye açıldığında yukarı kaydır
            scrollPadding: const EdgeInsets.only(bottom: 100),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          // Kaydet Butonu (Tema buton stilini kullanıyor)
          ElevatedButton(
            onPressed: _rating == 0 ? null : () {
              Navigator.pop(context, {
                'rating': _rating,
                'notes': _notesController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
            ),
            child: Text('Save Changes', style: textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}