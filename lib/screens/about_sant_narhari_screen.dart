import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/language_service.dart';
import 'about_sant_narhari_content.dart';

/// About Sant Narhari — leader image and goal/objectives/rules content (EN/MR).
class AboutSantNarhariScreen extends StatelessWidget {
  const AboutSantNarhariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final isEn = lang.isEnglish;
        final body = isEn ? AboutSantNarhariContent.bodyEn : AboutSantNarhariContent.bodyMr;
        final boldPhrase = isEn ? AboutSantNarhariContent.boldPhraseEn : AboutSantNarhariContent.boldPhraseMr;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              lang.pick(AboutSantNarhariContent.appBarTitleEn, AboutSantNarhariContent.appBarTitleMr),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    AboutSantNarhariContent.leaderImageAsset,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AboutSantNarhariContent.leaderImageFallback,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 100,
                        color: AppTheme.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBodyWithBold(
                  body: body,
                  boldPhrase: boldPhrase,
                  baseStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.55,
                  ),
                  boldStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Renders body text with one phrase in slightly bold. If phrase not found, returns plain text.
  static Widget _buildBodyWithBold({
    required String body,
    required String boldPhrase,
    required TextStyle baseStyle,
    required TextStyle boldStyle,
  }) {
    if (boldPhrase.isEmpty || !body.contains(boldPhrase)) {
      return SelectableText(body, style: baseStyle);
    }
    final parts = body.split(boldPhrase);
    if (parts.length < 2) {
      return SelectableText(body, style: baseStyle);
    }
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(text: parts[0], style: baseStyle),
          TextSpan(text: boldPhrase, style: boldStyle),
          TextSpan(text: parts.sublist(1).join(boldPhrase), style: baseStyle),
        ],
      ),
    );
  }
}
