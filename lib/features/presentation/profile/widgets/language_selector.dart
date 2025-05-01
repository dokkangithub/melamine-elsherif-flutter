import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/localization/language_provider.dart';
import '../../../../core/utils/extension/translate_extension.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return AlertDialog(
          title: Text('select_language'.tr(context)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languageProvider.languages.length,
              itemBuilder: (context, index) {
                final language = languageProvider.languages[index];
                final isSelected = languageProvider.locale.languageCode == language.languageCode;
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        language.code.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    language.name,
                    style: TextStyle(
                      color: isSelected ? Colors.red : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Colors.red)
                    : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    languageProvider.changeLanguage(
                      language.languageCode, 
                      language.countryCode
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr(context)),
            ),
          ],
        );
      },
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LanguageSelector();
      },
    );
  }
} 