import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:translate_and_learn_app/widgets/custom_drop_down_button.dart';
import 'package:translate_and_learn_app/widgets/custom_text_field.dart';
import 'package:translate_and_learn_app/widgets/translator_card_icons.dart';

class TranslatorCard extends StatefulWidget {
  final Color color;

  const TranslatorCard({
    super.key,
    required this.color,
    required this.hint,
  });

  final String hint;

  @override
  State<TranslatorCard> createState() => _TranslatorCardState();
}

class _TranslatorCardState extends State<TranslatorCard> {
  String selectedValue = 'English';
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomDropDownButton(
              translation: 1,
            ),
            Row(children: [
              Expanded(
                child: CustomTextField(hint: widget.hint),
              ),
              const SizedBox(width: 10),
              const TranslatorCardicons(
                icon1: FontAwesomeIcons.trash,
                icon2: FontAwesomeIcons.star,
                icon3: FontAwesomeIcons.volumeHigh,
              ),
            ])
          ],
        ),
      ),
    );
  }
}
