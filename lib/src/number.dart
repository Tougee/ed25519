// On native platforms `int` is 64-bit, so [Number] is a zero-cost wrapper of
// `int`. On the web, it falls back to the `Int64` based adaptive_number.
export 'package:adaptive_number/adaptive_number.dart'
    if (dart.library.io) 'number_native.dart';
