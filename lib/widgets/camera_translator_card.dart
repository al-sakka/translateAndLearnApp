import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translate_and_learn_app/constants.dart';
import 'package:translate_and_learn_app/cubit/cubit/favorites_cubit.dart';
import 'package:translate_and_learn_app/cubit/cubit/image_to_text_cubit.dart';
import 'package:translate_and_learn_app/cubit/gemini_api_cubit.dart';
import 'package:translate_and_learn_app/widgets/custom_drop_down_button.dart';
import 'package:translate_and_learn_app/widgets/floating_button.dart';

class CameraTranslatorCard extends StatefulWidget {
  final Color color;
  final String hint;

  const CameraTranslatorCard({
    super.key,
    required this.color,
    required this.hint,
  });

  @override
  State<CameraTranslatorCard> createState() => _CameraTranslatorCardState();
}

class _CameraTranslatorCardState extends State<CameraTranslatorCard> {
  String selectedValue = 'English';
  XFile? _image;
  String _text = 'Text will appear here';
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage(
      languageCodes[context.read<FavoritesCubit>().getLanguageFrom()] ??
          'en_EN',
    );
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: source);
    setState(() {
      _image = image;
    });
    if (image != null) {
      _sendImageToApi(File(image.path));
    }
  }

  void _sendImageToApi(File image) {
    context.read<ImageToTextCubit>().fetchTextFromImage(image);
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _text = 'Text will appear here';
    });
    context.read<GeminiApiCubit>().resetTranslation(); // Reset the translation
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageToTextCubit, ImageToTextState>(
      listener: (context, state) {
        if (state is ImageToTextSuccess) {
          setState(() {
            _text = state.response;
          });
          context.read<GeminiApiCubit>().translateText(state.response);
        } else if (state is ImageToTextError) {
          setState(() {
            _text = state.error;
          });
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: kGeminiColor,
              width: 1.5,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomDropDownButton(translation: 1),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.volumeHigh),
                      onPressed: () {
                        _speak(_text);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    if (_image == null)
                      FloatingImageButton(
                        onCameraPressed: () => _pickImage(ImageSource.camera),
                        onGalleryPressed: () => _pickImage(ImageSource.gallery),
                      )
                    else
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.file(File(_image!.path)),
                      ),
                    const Spacer(flex: 1),
                    const SizedBox(width: 22),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.trash,
                        color: kAppBarColor,
                      ),
                      onPressed: _clearImage, // Clear image and text
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const SizedBox(height: 26),
                Text(
                  _text,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingImageButton extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const FloatingImageButton({
    super.key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FloatingButton(
          color: kPrimaryColor,
          icon: FontAwesomeIcons.camera,
          onPressed: onCameraPressed,
        ),
        const SizedBox(width: 16),
        FloatingButton(
          color: kPrimaryColor,
          icon: FontAwesomeIcons.image,
          onPressed: onGalleryPressed,
        ),
      ],
    );
  }
}
