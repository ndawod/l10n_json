// The MIT License
//
// Copyright 2020 Noor Dawod. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

part of localison;

/// A utility class to load localization texts from a JSON resource file.
///
class Localison {
  /// Instantiates a new [Localison] instance using the specified [locale].
  ///
  /// Parameters:
  ///
  /// [separator] separator character between a key name, gender value, and plural count value,
  /// defaults to the underscore "_" character.
  ///
  /// [quantities] enables you to represent a quantity as we, humans, understand it and not
  /// following the plural rules of a specific language.
  ///
  Localison(
    this.locale, {
    String separator,
    Map<LocalisonQuantity, int> quantities,
  })  : assert(null != locale, 'Locale cannot be null.'),
        assert(true != quantities?.isEmpty, 'Quantities cannot be empty.'),
        separator = separator ?? '_',
        quantities = quantities ?? defaultQuantities;

  /// The [Locale] currently in use in this instance.
  final Locale locale;

  /// Separator character between a key name, gender value, and plural count value.
  final String separator;

  /// Rules to represent a quantity that doesn't follow the plural rules of [locale]'s language.
  final Map<LocalisonQuantity, int> quantities;

  /// Localized messages bucket.
  Map<String, dynamic> _messages;

  /// Returns a translated message matching the specified [key].
  ///
  /// If [gender] is provided, then the appropriate message is picked by looking for a key that
  /// evaluates to [key] + [separator] + [gender] String value.
  ///
  /// If [count] is provided, then it'll be substituted in the final localization message.
  ///
  /// If [args] is provided, then the localized message is transformed by substituting the
  /// placeholder parameters with [args] in a fashion similar to C's sprintf(). Note that the
  /// first argument (%0$s) evaluates to the localized message with the placeholders, so your
  /// localizations is expected to start counting at (%1), which points to for the 1st argument.
  ///
  /// If the key has not been defined in the JSON file, and [fallback] is defined, then it will
  /// be returned instead. Otherwise, the key itself is returned.
  ///
  String localize(
    String key, {
    num count,
    LocalisonGender gender,
    List<dynamic> args,
    String fallback,
    bool quantify,
  }) {
    assert(null != key, 'Localization key must not be null.');
    assert(key.isNotEmpty, 'Localization key must not be empty.');

    // The effective key to look for.
    final resolvedKey = _resolveKey(key, count, gender, quantify);

    // Are we looking for a pluralized message?
    final dynamic localization =
        null == count ? _messages[resolvedKey] : _pluralize(resolvedKey, count);

    // The final message is guaranteed to never be null.
    final message = null == localization ? (fallback ?? key) : localization.toString();

    // If arguments were provided, apply them in the message.
    //
    // Note about the 3rd-party sprintf() implementation for Dart:
    // For some reason the author decided to have %0$s point to the first argument, which in
    // languages inherited from C should point to the string itself. Since this library can exist
    // in other apps, it's decided to follow the C notation here.
    // So we'll plug in the message string as a first argument and the user-supplied ones follow.
    return (true == args?.isNotEmpty ? sprintf(message, <dynamic>[message, ...args]) : message)
        .trim();
  }

  /// Returns true if the passed key is part of the localized keys, false otherwise.
  ///
  /// The same decisions for the final key name apply here just as in [localize] method.
  ///
  bool contains(
    String key, {
    num count,
    LocalisonGender gender,
    bool quantify,
  }) =>
      _messages.containsKey(_resolveKey(key, count, gender, quantify));

  /// Asynchronously loads the JSON file associated with the configured [locale]. If
  /// [cachable] is not false, and the localized messages have previously been loaded into
  /// memory, then they'll be reused.
  ///
  Future<void> load({bool cachable}) async {
    if (false != cachable && _cache.containsKey(locale)) {
      _messages?.clear();
      _messages = _cache[locale];
    } else {
      final localeFile = _resolveLocaleFile(locale);
      var jsonString = await rootBundle.loadString('$_baseDirectory/$localeFile.json');

      assert(jsonString.isNotEmpty);
      jsonString = jsonString.trim();
      assert(8 < jsonString.length);
      assert('{' == jsonString[0] && '}' == jsonString[jsonString.length - 1]);

      final l10n = (json.decode(jsonString) as Map).cast<String, dynamic>();

      _messages?.clear();
      _messages = l10n;

      // We always cache the localizations.
      _cache[locale] = _messages;
    }
  }

  String _resolveLocaleFile(Locale locale) =>
      locale.languageCode == _baseLocale.languageCode ? 'base' : locale.toString().toLowerCase();

  String _resolveKey(String key, num count, LocalisonGender gender, bool quantify) {
    // The effective key to look for.
    final effectiveKey = null == gender ? key : '$key$separator${gender.name}';

    // Are we looking for a pluralized message?
    return null == count ? effectiveKey : _pluralizeKey(effectiveKey, count, quantify);
  }

  String _pluralizeKey(String key, num count, bool quantify) {
    final pluralRule = null == quantities || true != quantify
        ? pluralLogic(count, locale)
        : quantitiesLogic(count, locale, quantities);
    assert(null != pluralRule);

    return '$key$separator${pluralRule.name}';
  }

  dynamic _pluralize(String resolvedKey, num count, [int precision = 0]) {
    final dynamic pluralValue = _messages[resolvedKey];
    assert(null != pluralValue, 'Plural key \'$resolvedKey\' not found for count ($count).');
    final pluralMessage = pluralValue.toString();
    assert(pluralMessage.isNotEmpty, 'Plural key \'$resolvedKey\' for count ($count) is empty.');

    return sprintf(pluralMessage, <num>[count, count]);
  }

  /// Implements the logic for plural selection.
  ///
  static LocalisonPlural pluralLogic(num count, Locale locale, [int precision = 0]) {
    assert(null != count);
    assert(null != locale);

    startRuleEvaluation(count, precision);

    final localeToString = locale.toString();

    final pluralRuleFn = pluralRules.containsKey(localeToString)
        ? pluralRules[localeToString]
        : pluralRules['default'];

    return pluralRuleFn();
  }

  /// Implements the quantities logic.
  ///
  static LocalisonPlural quantitiesLogic(
    num count,
    Locale locale,
    Map<LocalisonQuantity, int> quantities,
  ) {
    assert(null != count);
    assert(null != locale);
    assert(null != quantities);

    if (0 == count) {
      return LocalisonPlural.zero;
    }
    if (1 == count) {
      return LocalisonPlural.one;
    }
    if (2 == count) {
      return LocalisonPlural.two;
    }
    if ((quantities[LocalisonQuantity.few] ?? 0) >= count) {
      return LocalisonPlural.few;
    }
    if ((quantities[LocalisonQuantity.many] ?? 0) >= count) {
      return LocalisonPlural.many;
    }
    return LocalisonPlural.other;
  }

  /// Returns the closest [Localison] instance to the passed [context].
  ///
  static Localison of(BuildContext context) => Localizations.of<Localison>(context, Localison);

  /// Returns the base directory where JSON files are loaded from, defaults to 'res/l10n'.
  ///
  static String get baseDirectory => _baseDirectory;

  /// Sets a new base directory where JSON files are loaded from.
  ///
  /// This will cause the internal cache to be cleared when value is indeed different than
  /// the current one.
  ///
  static set baseDirectory(String path) {
    assert(null != path);
    assert(Directory(path).existsSync());

    var normalizedValue = (path ?? '').trim();
    assert(normalizedValue.isNotEmpty);

    // Must not be an absolute path, at least on Linux/macOS.
    assert(Platform.pathSeparator != normalizedValue[0]);

    // Trim trailing path separator from end of string.
    var length = normalizedValue.length;
    do {
      length--;
    } while (0 < length && Platform.pathSeparator == normalizedValue[length]);
    assert(0 < length);

    normalizedValue = normalizedValue.substring(0, length);
    if (normalizedValue != _baseDirectory) {
      _cache.clear();
      _baseDirectory = normalizedValue.substring(0, length);
    }
  }

  /// Returns the base [Locale] of the app, defaults to English with no associated country.
  ///
  static Locale get baseLocale => _baseLocale;

  /// Sets a new base [Locale] of the app.
  ///
  /// This will cause the internal cache to be cleared when value is indeed different than
  /// the current one.
  ///
  static set baseLocale(Locale locale) {
    assert(null != locale);

    if (locale != _baseLocale) {
      _cache.clear();
      _baseLocale = locale;
    }
  }

  /// Localison's default [Locale] is English with no specific associated country.
  ///
  static const Locale defaultLocale = Locale('en');

  static final _cache = <Locale, Map<String, dynamic>>{};

  static String _baseDirectory = 'res/l10n';

  static Locale _baseLocale = defaultLocale;
}
