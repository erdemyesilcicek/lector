// lib/widgets/rating_modal_widget.dart

import 'package:flutter/material.dart';

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
    // Eğer başlangıç değerleri gönderildiyse, state'i onlarla başlat
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the modal wrap its content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            // Başlığı dinamik hale getirdik
            widget.initialRating == null
                ? 'Rate this book'
                : 'Edit your rating',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Star Rating
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
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Notes TextField
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Your notes (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Save Button
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
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
