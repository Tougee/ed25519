
import 'package:ed25519_edwards/src/number/number.dart';
import 'package:fixnum/fixnum.dart';

class Int64Number implements Number {
  final Int64 _value;

  Int64Number(this._value);

  @override
  Int64Number operator +(Number value) {
    return Int64Number(_value + (value.val as Int64));
  }

  @override
  Int64Number operator -(Number value) {
    return Int64Number(_value - (value.val as Int64));
  }

  @override
  Int64Number operator -() {
    return Int64Number(-(val as Int64));
  }

  @override
  Int64Number operator *(Number value) {
    return Int64Number(_value * (value.val as Int64));
  }

  @override
  Int64Number operator &(Number value) {
    return Int64Number(_value & (value.val as Int64));
  }

  @override
  Int64Number operator >>(int value) {
    return Int64Number(_value >> value);
  }

  @override
  Int64Number operator <<(int value) {
    return Int64Number(_value << value);
  }

  @override
  Int64Number operator ^(Number value) {
    return Int64Number(_value ^ (value.val as Int64));
  }

  @override
  Int64Number operator |(Number value) {
    return Int64Number(_value | (value.val as Int64));
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
  Int64 get val => _value;

  @override
  int get intValue  => _value.toInt();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Int64Number &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return _value.toString();
  }
}

Number createNumber(int val) => Int64Number(Int64(val));
