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

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_final_locals
// ignore_for_file: omit_local_variable_types
// ignore_for_file: parameter_assignments

/// Provides locale-specific plural rules. Based on and modified from Intl package.
///

part of localison;

typedef PluralRule = LocalisonPlural Function();

/// The default rule in case we don't have anything more specific for a locale.
LocalisonPlural _defaultRule() => LocalisonPlural.other;

/// This must be called before evaluating a new rule, because we're using
/// library-global state to both keep the rules terse and minimize space.
void startRuleEvaluation(num howMany, [int precision = 0]) {
  _n = howMany;
  _precision = precision;
  _i = _n.round();
  _updateVF(_n, _precision);
  _updateWT(_f, _v);
}

/// The number whose [LocalisonPlural] we are trying to find.
///
// This is library-global state, along with the other variables. This allows us
// to avoid calculating parameters that the functions don't need and also
// not introduce a subclass per locale or have instance tear-offs which
// we can't cache. This is fine as long as these methods aren't async, which
// they should never be.
num _n;

/// The integer part of [_n]
int _i;
int _precision;

/// Returns the number of digits in the fractional part of a number
/// (3.1416 => 4)
///
/// Takes the item count [n] and a [precision].
/// That's because a just looking at the value of a number is not enough to
/// decide the plural form. For example "1 dollar" vs "1.00 dollars", the
/// value is 1, but how it is formatted also matters.
int _decimals(num n, int precision) {
  var str = _precision == null ? '$n' : n.toStringAsFixed(precision);
  var result = str.indexOf('.');
  return (result == -1) ? 0 : str.length - result - 1;
}

/// Calculates and sets the _v and _f as per CLDR plural rules.
///
/// The short names for parameters / return match the CLDR syntax and UTS #35
///     (https://unicode.org/reports/tr35/tr35-numbers.html#Plural_rules_syntax)
/// Takes the item count [n] and a [precision].
void _updateVF(num n, int precision) {
  var defaultDigits = 3;

  _v = precision ?? math.min(_decimals(n, precision), defaultDigits);
  int base = math.pow(10, _v).toInt();
  _f = (n * base).floor() % base;
}

/// Calculates and sets _w and _t as per CLDR plural rules.
///
/// The short names for parameters / return match the CLDR syntax and UTS #35
///     (https://unicode.org/reports/tr35/tr35-numbers.html#Plural_rules_syntax)
/// @param v Calculated previously.
/// @param f Calculated previously.
void _updateWT(int v, int f) {
  if (f == 0) {
    // Unused, for now _w = 0;
    _t = 0;
    return;
  }

  while ((f % 10) == 0) {
    f = (f / 10).floor();
    v--;
  }

  // Unused, for now _w = v;
  _t = f;
}

/// Number of visible fraction digits.
int _v = 0;

/// Number of visible fraction digits without trailing zeros.
// Unused, for now int _w = 0;

/// The visible fraction digits in n, with trailing zeros.
int _f = 0;

/// The visible fraction digits in n, without trailing zeros.
int _t = 0;

// An example, for precision n = 3.1415 and precision = 7)
//   n  : 3.1415
// str n: 3.1415000 (the "formatted" n, 7 fractional digits)
//   i  : 3         (the integer part of n)
//   f  :   1415000 (the fractional part of n)
//   v  : 7         (how many digits in f)
//   t  :   1415    (f, without trailing 0s)
//   w  : 4         (how many digits in t)

LocalisonPlural _fil_rule() {
  if (_v == 0 && (_i == 1 || _i == 2 || _i == 3) ||
      _v == 0 && _i % 10 != 4 && _i % 10 != 6 && _i % 10 != 9 ||
      _v != 0 && _f % 10 != 4 && _f % 10 != 6 && _f % 10 != 9) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _pt_PT_rule() {
  if (_n == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _br_rule() {
  if (_n % 10 == 1 && _n % 100 != 11 && _n % 100 != 71 && _n % 100 != 91) {
    return LocalisonPlural.one;
  }
  if (_n % 10 == 2 && _n % 100 != 12 && _n % 100 != 72 && _n % 100 != 92) {
    return LocalisonPlural.two;
  }
  if ((_n % 10 >= 3 && _n % 10 <= 4 || _n % 10 == 9) &&
      (_n % 100 < 10 || _n % 100 > 19) &&
      (_n % 100 < 70 || _n % 100 > 79) &&
      (_n % 100 < 90 || _n % 100 > 99)) {
    return LocalisonPlural.few;
  }
  if (_n != 0 && _n % 1000000 == 0) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _sr_rule() {
  if (_v == 0 && _i % 10 == 1 && _i % 100 != 11 ||
      _f % 10 == 1 && _f % 100 != 11) {
    return LocalisonPlural.one;
  }
  if (_v == 0 &&
          _i % 10 >= 2 &&
          _i % 10 <= 4 &&
          (_i % 100 < 12 || _i % 100 > 14) ||
      _f % 10 >= 2 && _f % 10 <= 4 && (_f % 100 < 12 || _f % 100 > 14)) {
    return LocalisonPlural.few;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _ro_rule() {
  if (_i == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  if (_v != 0 || _n == 0 || _n != 1 && _n % 100 >= 1 && _n % 100 <= 19) {
    return LocalisonPlural.few;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _hi_rule() {
  if (_i == 0 || _n == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _fr_rule() {
  if (_i == 0 || _i == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _cs_rule() {
  if (_i == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  if (_i >= 2 && _i <= 4 && _v == 0) {
    return LocalisonPlural.few;
  }
  if (_v != 0) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _pl_rule() {
  if (_i == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  if (_v == 0 &&
      _i % 10 >= 2 &&
      _i % 10 <= 4 &&
      (_i % 100 < 12 || _i % 100 > 14)) {
    return LocalisonPlural.few;
  }
  if (_v == 0 && _i != 1 && _i % 10 >= 0 && _i % 10 <= 1 ||
      _v == 0 && _i % 10 >= 5 && _i % 10 <= 9 ||
      _v == 0 && _i % 100 >= 12 && _i % 100 <= 14) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _lv_rule() {
  if (_n % 10 == 0 ||
      _n % 100 >= 11 && _n % 100 <= 19 ||
      _v == 2 && _f % 100 >= 11 && _f % 100 <= 19) {
    return LocalisonPlural.zero;
  }
  if (_n % 10 == 1 && _n % 100 != 11 ||
      _v == 2 && _f % 10 == 1 && _f % 100 != 11 ||
      _v != 2 && _f % 10 == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _he_rule() {
  if (_i == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  if (_i == 2 && _v == 0) {
    return LocalisonPlural.two;
  }
  if (_v == 0 && (_n < 0 || _n > 10) && _n % 10 == 0) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _mt_rule() {
  if (_n == 1) {
    return LocalisonPlural.one;
  }
  if (_n == 0 || _n % 100 >= 2 && _n % 100 <= 10) {
    return LocalisonPlural.few;
  }
  if (_n % 100 >= 11 && _n % 100 <= 19) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _si_rule() {
  if ((_n == 0 || _n == 1) || _i == 0 && _f == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _cy_rule() {
  if (_n == 0) {
    return LocalisonPlural.zero;
  }
  if (_n == 1) {
    return LocalisonPlural.one;
  }
  if (_n == 2) {
    return LocalisonPlural.two;
  }
  if (_n == 3) {
    return LocalisonPlural.few;
  }
  if (_n == 6) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _da_rule() {
  if (_n == 1 || _t != 0 && (_i == 0 || _i == 1)) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _ru_rule() {
  if (_v == 0 && _i % 10 == 1 && _i % 100 != 11) {
    return LocalisonPlural.one;
  }
  if (_v == 0 &&
      _i % 10 >= 2 &&
      _i % 10 <= 4 &&
      (_i % 100 < 12 || _i % 100 > 14)) {
    return LocalisonPlural.few;
  }
  if (_v == 0 && _i % 10 == 0 ||
      _v == 0 && _i % 10 >= 5 && _i % 10 <= 9 ||
      _v == 0 && _i % 100 >= 11 && _i % 100 <= 14) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _be_rule() {
  if (_n % 10 == 1 && _n % 100 != 11) {
    return LocalisonPlural.one;
  }
  if (_n % 10 >= 2 && _n % 10 <= 4 && (_n % 100 < 12 || _n % 100 > 14)) {
    return LocalisonPlural.few;
  }
  if (_n % 10 == 0 ||
      _n % 10 >= 5 && _n % 10 <= 9 ||
      _n % 100 >= 11 && _n % 100 <= 14) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _mk_rule() {
  if (_v == 0 && _i % 10 == 1 || _f % 10 == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _ga_rule() {
  if (_n == 1) {
    return LocalisonPlural.one;
  }
  if (_n == 2) {
    return LocalisonPlural.two;
  }
  if (_n >= 3 && _n <= 6) {
    return LocalisonPlural.few;
  }
  if (_n >= 7 && _n <= 10) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _pt_rule() {
  if (_n >= 0 && _n <= 2 && _n != 2) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _es_rule() {
  if (_n == 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _is_rule() {
  if (_t == 0 && _i % 10 == 1 && _i % 100 != 11 || _t != 0) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _ar_rule() {
  if (_n == 0) {
    return LocalisonPlural.zero;
  }
  if (_n == 1) {
    return LocalisonPlural.one;
  }
  if (_n == 2) {
    return LocalisonPlural.two;
  }
  if (_n % 100 >= 3 && _n % 100 <= 10) {
    return LocalisonPlural.few;
  }
  if (_n % 100 >= 11 && _n % 100 <= 99) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _sl_rule() {
  if (_v == 0 && _i % 100 == 1) {
    return LocalisonPlural.one;
  }
  if (_v == 0 && _i % 100 == 2) {
    return LocalisonPlural.two;
  }
  if (_v == 0 && _i % 100 >= 3 && _i % 100 <= 4 || _v != 0) {
    return LocalisonPlural.few;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _lt_rule() {
  if (_n % 10 == 1 && (_n % 100 < 11 || _n % 100 > 19)) {
    return LocalisonPlural.one;
  }
  if (_n % 10 >= 2 && _n % 10 <= 9 && (_n % 100 < 11 || _n % 100 > 19)) {
    return LocalisonPlural.few;
  }
  if (_f != 0) {
    return LocalisonPlural.many;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _en_rule() {
  if (_i == 1 && _v == 0) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

LocalisonPlural _ak_rule() {
  if (_n >= 0 && _n <= 1) {
    return LocalisonPlural.one;
  }
  return LocalisonPlural.other;
}

/// Selected Plural rules by locale.
final Map<String, PluralRule> pluralRules = {
  'af': _es_rule,
  'am': _hi_rule,
  'ar': _ar_rule,
  'az': _es_rule,
  'be': _be_rule,
  'bg': _es_rule,
  'bn': _hi_rule,
  'br': _br_rule,
  'bs': _sr_rule,
  'ca': _en_rule,
  'chr': _es_rule,
  'cs': _cs_rule,
  'cy': _cy_rule,
  'da': _da_rule,
  'de': _en_rule,
  'de_AT': _en_rule,
  'de_CH': _en_rule,
  'el': _es_rule,
  'en': _en_rule,
  'en_AU': _en_rule,
  'en_CA': _en_rule,
  'en_GB': _en_rule,
  'en_IE': _en_rule,
  'en_IN': _en_rule,
  'en_SG': _en_rule,
  'en_US': _en_rule,
  'en_ZA': _en_rule,
  'es': _es_rule,
  'es_419': _es_rule,
  'es_ES': _es_rule,
  'es_MX': _es_rule,
  'es_US': _es_rule,
  'et': _en_rule,
  'eu': _es_rule,
  'fa': _hi_rule,
  'fi': _en_rule,
  'fil': _fil_rule,
  'fr': _fr_rule,
  'fr_CA': _fr_rule,
  'ga': _ga_rule,
  'gl': _en_rule,
  'gsw': _es_rule,
  'gu': _hi_rule,
  'haw': _es_rule,
  'he': _he_rule,
  'hi': _hi_rule,
  'hr': _sr_rule,
  'hu': _es_rule,
  'hy': _fr_rule,
  'id': _defaultRule,
  'in': _defaultRule,
  'is': _is_rule,
  'it': _en_rule,
  'iw': _he_rule,
  'ja': _defaultRule,
  'ka': _es_rule,
  'kk': _es_rule,
  'km': _defaultRule,
  'kn': _hi_rule,
  'ko': _defaultRule,
  'ky': _es_rule,
  'ln': _ak_rule,
  'lo': _defaultRule,
  'lt': _lt_rule,
  'lv': _lv_rule,
  'mk': _mk_rule,
  'ml': _es_rule,
  'mn': _es_rule,
  'mo': _ro_rule,
  'mr': _hi_rule,
  'ms': _defaultRule,
  'mt': _mt_rule,
  'my': _defaultRule,
  'nb': _es_rule,
  'ne': _es_rule,
  'nl': _en_rule,
  'no': _es_rule,
  'no_NO': _es_rule,
  'or': _es_rule,
  'pa': _ak_rule,
  'pl': _pl_rule,
  'pt': _pt_rule,
  'pt_BR': _pt_rule,
  'pt_PT': _pt_PT_rule,
  'ro': _ro_rule,
  'ru': _ru_rule,
  'sh': _sr_rule,
  'si': _si_rule,
  'sk': _cs_rule,
  'sl': _sl_rule,
  'sq': _es_rule,
  'sr': _sr_rule,
  'sr_Latn': _sr_rule,
  'sv': _en_rule,
  'sw': _en_rule,
  'ta': _es_rule,
  'te': _es_rule,
  'th': _defaultRule,
  'tl': _fil_rule,
  'tr': _es_rule,
  'uk': _ru_rule,
  'ur': _en_rule,
  'uz': _es_rule,
  'vi': _defaultRule,
  'zh': _defaultRule,
  'zh_CN': _defaultRule,
  'zh_HK': _defaultRule,
  'zh_TW': _defaultRule,
  'zu': _hi_rule,
  'default': _defaultRule
};

/// Do we have plural rules specific to [locale]
bool localeHasPluralRules(String locale) => pluralRules.containsKey(locale);
