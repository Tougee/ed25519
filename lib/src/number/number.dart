import 'package:ed25519_edwards/src/number/stub.dart'
// ignore: uri_does_not_exist
    if (dart.library.io) 'package:ed25519_edwards/src/number/int.dart'
// ignore: uri_does_not_exist
    if (dart.library.html) 'package:ed25519_edwards/src/number/int64.dart';

abstract class Number {
  dynamic get val;

  int get intValue;

  Number operator +(Number value);

  Number operator -(Number value);

  Number operator -();

  Number operator *(Number value);

  Number operator &(Number value);

  Number operator >>(int value);

  Number operator <<(int value);

  Number operator ^(Number value);

  Number operator |(Number value);

  bool operator <(Number value);

  bool operator >(Number value);

  factory Number(int val) => createNumber(val);

  static Number zero = Number(0);
  static Number one = Number(1);
  static Number two = Number(2);
  static Number v8 = Number(8);
  static Number v15 = Number(15);
  static Number v19 = Number(19);
  static Number v24 = Number(24);
  static Number v25 = Number(25);
  static Number v26 = Number(26);
  static Number v38 = Number(38);
  static Number v136657 = Number(136657);
  static Number v2097151 = Number(2097151);
  static Number v470296 = Number(470296);
  static Number v683901 = Number(683901);
  static Number v654183 = Number(654183);
  static Number v666643 = Number(666643);
  static Number v997805 = Number(997805);

}
