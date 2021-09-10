import 'package:ed25519_edwards/src/number/number.dart';

class IntNumber implements Number {
  final int _value ;

  IntNumber(this._value);

  @override
  IntNumber operator +(Number value) {
    return IntNumber(_value + (value.val as int));
  }

  @override
  IntNumber operator -(Number value) {
    return IntNumber(_value - (value.val as int));
  }

  @override
  IntNumber operator -() {
    return IntNumber(-(val as int));
  }

  @override
  IntNumber operator *(Number value) {
    return IntNumber(_value * (value.val as int));
  }

  @override
  IntNumber operator &(Number value) {
    return IntNumber(_value & (value.val as int));
  }

  @override
  IntNumber operator >>(int value) {
    return IntNumber(_value >> value);
  }

  @override
  IntNumber operator <<(int value) {
    return IntNumber(_value << value);
  }

  @override
  IntNumber operator ^(Number value) {
    return IntNumber(_value ^ (value.val as int));
  }

  @override
  IntNumber operator |(Number value) {
    return IntNumber(_value | (value.val as int));
  }

  @override
  bool operator <(Number value) {
    return (intValue < value.intValue);
  }

  @override
  bool operator >(Number value) {
    return (intValue > value.intValue);
  }

  @override
  int get val => _value;

  @override
  int get intValue  => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntNumber &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return _value.toString();
  }
}

Number createNumber(int val) => IntNumber(val);
