/// A zero-cost replacement for `Number` from adaptive_number on platforms
/// with 64-bit `int`. It has the same members that this package uses, but it
/// does not allocate an object for each arithmetic operation.
extension type const Number._(int intValue) {
  static const Number zero = Number._(0);
  static const Number one = Number._(1);
  static const Number two = Number._(2);

  const Number(int value) : this._(value);

  Number operator +(Number other) => Number._(intValue + other.intValue);
  Number operator -(Number other) => Number._(intValue - other.intValue);
  Number operator -() => Number._(-intValue);
  Number operator *(Number other) => Number._(intValue * other.intValue);
  Number operator &(Number other) => Number._(intValue & other.intValue);
  Number operator |(Number other) => Number._(intValue | other.intValue);
  Number operator ^(Number other) => Number._(intValue ^ other.intValue);
  Number operator >>(int shift) => Number._(intValue >> shift);
  Number operator <<(int shift) => Number._(intValue << shift);
  bool operator <(Number other) => intValue < other.intValue;
}
