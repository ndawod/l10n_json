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

/// A [LocalizationsDelegate] that loads a JSON file from local resources directory
/// for a list of supported [Locale]s.
///
class LocalisonDelegate extends LocalizationsDelegate<Localison> {
  /// Instantiates a new [LocalisonDelegate] with support for the specified [locales].
  ///
  const LocalisonDelegate(this.locales, {this.cachable});

  /// Supported [locales][Locale].
  final Iterable<Locale> locales;

  /// Whether to cache localizations for this delegate.
  final bool cachable;

  @override
  bool isSupported(Locale locale) => locales.contains(locale);

  @override
  Future<Localison> load(Locale locale) async {
    final instance = Localison(locale);
    await instance.load(cachable: cachable);
    return instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localison> old) => false;
}

/// A [LocalizationsDelegate] that loads a JSON file from local resources directory
/// for a supported language derived from a list of [Locale]s.
///
class LocalisonByLanguageDelegate extends LocalisonDelegate {
  /// Instantiates a new [LocalisonByLanguageDelegate] with support for the specified
  /// [locales].
  ///
  LocalisonByLanguageDelegate(Iterable<Locale> locales, {bool cachable})
      : languages = locales.map((locale) => locale.languageCode.toLowerCase()),
        super(locales, cachable: cachable);

  /// Supported list of (2-letter) languages.
  final Iterable<String> languages;

  @override
  bool isSupported(Locale locale) => languages.contains(locale.languageCode);

  @override
  Future<Localison> load(Locale locale) async {
    try {
      // Try to load using only the language code alone.
      final instance = Localison(Locale(locale.languageCode));
      await instance.load(cachable: cachable);
      return instance;
      // ignore: avoid_catching_errors
    } on FlutterError catch (_) {
      // When failed, try loading using the full locale representation.
      return super.load(locale);
    }
  }
}
