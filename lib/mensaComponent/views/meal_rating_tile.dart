import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

import '../../../../base/helpers/card_with_padding.dart';
import '../mensa_service.dart';
import '../model/meal.dart';

class MealRatingTile extends StatefulWidget {
  final Meal meal;
  final void Function(double newAverageStars) onRatingSubmitted;

  const MealRatingTile({super.key, required this.meal, required this.onRatingSubmitted});

  @override
  State<StatefulWidget> createState() {
    return _MealRatingTileState();
  }
}

class _MealRatingTileState extends State<MealRatingTile> {
  Uint8List? _selectedImage;
  double rating = 0;
  late TextEditingController _commentController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  Future<void> _sendRating() async {
    setState(() {
      _sending = true;
    });

    try {
      final newAverageStars = await sendRating(
          mealName: widget.meal.name, stars: rating, comment: _commentController.text, image: _selectedImage);
      widget.onRatingSubmitted(newAverageStars);
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary;
    return CardWithPadding(
        margin: const EdgeInsets.all(5),
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: RatingBar(
                  initialRating: rating,
                  minRating: 1,
                  maxRating: 5,
                  glow: false,
                  allowHalfRating: true,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: primary),
                    half: Icon(Icons.star_half_outlined, color: primary),
                    empty: Icon(Icons.star_border, color: primary.withOpacity(0.7)),
                  ),
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                )),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.send,
                    size: 25,
                  ),
                  onPressed: rating != 0 && !_sending
                      ? () {
                          _sendRating();
                        }
                      : null,
                  label: Text(AppLocalizations.of(context)!.mensaRate),
                )
              ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          TextField(
            controller: _commentController,
            enabled: !_sending,
            minLines: 1,
            maxLines: 10,
            //scrollPadding: EdgeInsets.only(bottom:850),

            decoration: InputDecoration(
              //fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              //filled: true,
              suffixIcon: IconButton(
                onPressed: () {
                  if (_selectedImage != null) {
                    setState(() {
                      _selectedImage = null;
                    });
                  } else {
                    ImagePicker()
                        .pickImage(source: ImageSource.camera)
                        .then((file) => file?.readAsBytes() ?? Future.value())
                        .then((value) => setState(() {
                              _selectedImage = value;
                            }));
                  }
                },
                icon: _selectedImage != null
                    ? SizedBox(
                        width: 55,
                        height: 55,
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.memory(
                                  _selectedImage!,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  color: Colors.black12,
                                  colorBlendMode: BlendMode.darken,
                                )),
                            const Center(
                                child: Icon(
                              Icons.cancel_outlined,
                              size: 30,
                              color: Colors.white,
                            )),
                          ],
                        ))
                    : const SizedBox(height: 55, child: Icon(Icons.add_a_photo)),
              ),
              labelText: AppLocalizations.of(context)!.mensaComment,
            ),
          ),
          //Divider(),
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }
}
