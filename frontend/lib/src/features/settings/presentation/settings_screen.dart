import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/networking/server_settings_provider.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentServerUrl = ref.watch(serverUrlProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.appearanceSection,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_medium_rounded),
            title: Text(l10n.themeOption),
            subtitle: Text(_themeModeLabel(currentThemeMode, l10n)),
            onTap: () => _showThemeDialog(context, ref, currentThemeMode, l10n),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.languageOption),
            subtitle: Text(_localeLabel(currentLocale)),
            onTap: () => _showLanguageDialog(context, ref, currentLocale, l10n),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              "CONNETTIVITÀ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dns_rounded),
            title: const Text("Indirizzo Server"),
            subtitle: Text(currentServerUrl),
            onTap: () => _showServerDialog(context, ref, currentServerUrl),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.infoSection,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.rewatchOnboarding),
            subtitle: Text(l10n.onboardingSubtitle),
            onTap: () => context.push('/onboarding'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      ),
    );
  }

  String _themeModeLabel(AppThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.themeSystem;
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
    }
  }

  String _localeLabel(Locale? locale) {
    if (locale == null) return "Sistema";
    switch (locale.languageCode) {
      case 'it':
        return "Italiano";
      case 'en':
        return "English";
      default:
        return locale.languageCode;
    }
  }

  void _showServerDialog(
    BuildContext context,
    WidgetRef ref,
    String currentUrl,
  ) {
    final controller = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("INDIRIZZO SERVER"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Inserisci l'indirizzo IP del server (es. http://192.168.1.171:8000)",
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "http://...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULLA"),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                ref.read(serverUrlProvider.notifier).setUrl(newUrl);
                Navigator.pop(context);
              }
            },
            child: const Text("SALVA"),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_themeModeLabel(mode, l10n)),
              value: mode,
              groupValue: currentMode,
              onChanged: (AppThemeMode? value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale? currentLocale,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text("Sistema"),
              value: null,
              groupValue: currentLocale?.languageCode,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String?>(
              title: const Text("Italiano"),
              value: 'it',
              groupValue: currentLocale?.languageCode,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('it'));
                Navigator.pop(context);
              },
            ),
            RadioListTile<String?>(
              title: const Text("English"),
              value: 'en',
              groupValue: currentLocale?.languageCode,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
