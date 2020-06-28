# Localison

Provides localization support to a Flutter app using JSON files without too many bells
and whistles. It relies on simple JSON files to represent the different localizations
for texts written in a base language, and includes support for plural (ISO standard),
plural support using quantities (non-ISO standard) and gender support.

The default locale in Localison is English (`Localisoin.defaultLocale`), and the
initial base locale points to it. You can change it easily if you need to by calling
`Localison.baseLocale(...);` in your `main()` function.

The plugin provides all that a `MaterialApp` needs in order to properly load localizations
from JSON files.

## Getting Started

A multi-lingual MaterialApp has at least the following structure:

```dart
const Iterable<Locale> supportedLocales = /* list of supported locales */

Locale currentLocale = /* the current locale for a user/device */

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: supportedLocales,
  locale: currentLocale,
  ...
);
```

To add Localison support, create your simple JSON files (or download them from your
online localization service's website) in `res/l10n/` directory.

The directory can be changed by calling `Localison.baseDirectory(...)` in your
`main()` function.

*Note: the JSON file associated with the base locale **must be** called `base.json`.*

The JSON file's structure is easy:

```json
{
  "btn_send": "Send",
  "btn_join": "Join",
  "btn_Cancel": "Cancel",

  "items_zero": "You have no items.",
  "items_one": "You have one item.",
  "items_two": "You have two items.",
  "items_few": "You have few items.",
  "items_many": "You have many items.",
  "items_other": "You have %d items.",

  "quantified_items_zero": "You have no items.",
  "quantified_items_one": "You have one item.",
  "quantified_items_two": "You have two items.",
  "quantified_items_few": "You have %d items.",
  "quantified_items_many": "You have %d items.",
  "quantified_items_other": "You have %d items.",

  "close_male": "Your male friend is here.",
  "close_female": "Your female friend is here.",
  "close_trans": "Your transgender friend is here.",
  "close_other": "Your friend is here."
}
```

Finally, you can alter the `MaterialApp` to look like this:

```dart
const Iterable<Locale> supportedLocales = /* list of supported locales */

Locale currentLocale = /* the current locale for a user/device */

final localison = Localison(supportedLocales); // Add this

MaterialApp(
  localizationsDelegates: [
    localison, // Add this
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: localison.locales, // Add this
  locale: currentLocale,
  ...
);
```

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  localison: any
```

Update Flutter's dependencies: `flutter pub get`

Finally, load it in your Dart code: `import 'package:localison/localison.dart';`
