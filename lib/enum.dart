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

// ignore_for_file: public_member_api_docs

part of localison;

/// Plural rules when dealing with quantities.
///
enum LocalisonQuantity { few, many, other }

/// Default values for quantities defined in [LocalisonQuantity].
///
final defaultQuantities = <LocalisonQuantity, int>{
  LocalisonQuantity.few: 6,
  LocalisonQuantity.many: 10,
};

/// Plural rules according to Unicode plural rules:
/// https://www.unicode.org/cldr/charts/34/supplemental/language_plural_rules.html
///
enum LocalisonPlural { zero, one, two, few, many, other }

/// Extension functions for [LocalisonPlural] class.
///
extension ExtendedLocalisonPlural on LocalisonPlural {
  /// Returns the English representation of this [LocalisonPlural] instance.
  ///
  String get name {
    switch (this) {
      case LocalisonPlural.one:
        return 'one';
      case LocalisonPlural.two:
        return 'two';
      case LocalisonPlural.few:
        return 'few';
      case LocalisonPlural.many:
        return 'many';
      case LocalisonPlural.other:
        return 'other';
      case LocalisonPlural.zero:
      default:
        return 'zero';
    }
  }
}

/// Gender types that Localison supports. If you'd like to see more types, please submit a pr.
///
enum LocalisonGender {
  male,
  female,
  trans,
  agender,
  bigender,
  fluid,
  variant,
  other
}

/// Extension functions for [LocalisonGender] class.
///
extension ExtendedLocalisonGender on LocalisonGender {
  /// Returns the English representation of this [LocalisonGender] instance.
  ///
  String get name {
    switch (this) {
      case LocalisonGender.male:
        return 'male';
      case LocalisonGender.female:
        return 'female';
      case LocalisonGender.agender:
        return 'agender';
      case LocalisonGender.bigender:
        return 'bigender';
      case LocalisonGender.fluid:
        return 'fluid';
      case LocalisonGender.variant:
        return 'variant';
      case LocalisonGender.trans:
        return 'trans';
      case LocalisonGender.other:
      default:
        return 'other';
    }
  }
}
