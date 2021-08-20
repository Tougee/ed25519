import 'dart:typed_data';

import 'const.dart';

class FieldElement {
  late List<int> innerList;
  FieldElement() {
    innerList = List<int>.generate(10, (index) => 0);
  }
  FieldElement.fromList(List<int> list) {
    innerList = list;
  }

  int operator [](int index) {
    return innerList[index];
  }

  void operator []=(int index, int value) {
    innerList[index] = value;
  }

  int get length => innerList.length;

  @override
  String toString() => innerList.toString();
}

void fieldElementCopy(
    FieldElement src, int srcPos, FieldElement dest, int destPos, int length) {
  dest.innerList.setRange(destPos, length + destPos, src.innerList, srcPos);
}

void fieldElementFullCopy(FieldElement src, FieldElement dest) {
  fieldElementCopy(src, 0, dest, 0, dest.length);
}

var zero = FieldElement();

void FeZero(FieldElement fe) {
  fieldElementFullCopy(zero, fe);
}

void FeOne(FieldElement fe) {
  FeZero(fe);
  fe[0] = 1;
}

void FeAdd(FieldElement dst, FieldElement a, FieldElement b) {
  dst[0] = a[0] + b[0];
  dst[1] = a[1] + b[1];
  dst[2] = a[2] + b[2];
  dst[3] = a[3] + b[3];
  dst[4] = a[4] + b[4];
  dst[5] = a[5] + b[5];
  dst[6] = a[6] + b[6];
  dst[7] = a[7] + b[7];
  dst[8] = a[8] + b[8];
  dst[9] = a[9] + b[9];
}

void FeSub(FieldElement dst, FieldElement a, FieldElement b) {
  dst[0] = a[0] - b[0];
  dst[1] = a[1] - b[1];
  dst[2] = a[2] - b[2];
  dst[3] = a[3] - b[3];
  dst[4] = a[4] - b[4];
  dst[5] = a[5] - b[5];
  dst[6] = a[6] - b[6];
  dst[7] = a[7] - b[7];
  dst[8] = a[8] - b[8];
  dst[9] = a[9] - b[9];
}

void FeCopy(FieldElement dst, FieldElement src) {
  fieldElementFullCopy(src, dst);
}

/// Replace (f,g) with (g,g) if b == 1;
/// replace (f,g) with (f,g) if b == 0.
///
/// Preconditions: b in {0,1}.
void FeCMove(FieldElement f, FieldElement g, int b) {
  var bb = BigInt.from(-b);

  var h0 = BigInt.from(f[0]) ^ BigInt.from(g[0]);
  var h1 = BigInt.from(f[1]) ^ BigInt.from(g[1]);
  var h2 = BigInt.from(f[2]) ^ BigInt.from(g[2]);
  var h3 = BigInt.from(f[3]) ^ BigInt.from(g[3]);
  var h4 = BigInt.from(f[4]) ^ BigInt.from(g[4]);
  var h5 = BigInt.from(f[5]) ^ BigInt.from(g[5]);
  var h6 = BigInt.from(f[6]) ^ BigInt.from(g[6]);
  var h7 = BigInt.from(f[7]) ^ BigInt.from(g[7]);
  var h8 = BigInt.from(f[8]) ^ BigInt.from(g[8]);
  var h9 = BigInt.from(f[9]) ^ BigInt.from(g[9]);

  var f0 = bb & h0;
  var f1 = bb & h1;
  var f2 = bb & h2;
  var f3 = bb & h3;
  var f4 = bb & h4;
  var f5 = bb & h5;
  var f6 = bb & h6;
  var f7 = bb & h7;
  var f8 = bb & h8;
  var f9 = bb & h9;

  f[0] = (BigInt.from(f[0]) ^ f0).toInt();
  f[1] = (BigInt.from(f[1]) ^ f1).toInt();
  f[2] = (BigInt.from(f[2]) ^ f2).toInt();
  f[3] = (BigInt.from(f[3]) ^ f3).toInt();
  f[4] = (BigInt.from(f[4]) ^ f4).toInt();
  f[5] = (BigInt.from(f[5]) ^ f5).toInt();
  f[6] = (BigInt.from(f[6]) ^ f6).toInt();
  f[7] = (BigInt.from(f[7]) ^ f7).toInt();
  f[8] = (BigInt.from(f[8]) ^ f8).toInt();
  f[9] = (BigInt.from(f[9]) ^ f9).toInt();
}

BigInt load3(Uint8List input) {
  BigInt r;
  r = BigInt.from(input[0]);
  r |= BigInt.from(input[1] << 8);
  r |= BigInt.from(input[2] << 16);
  return r;
}

BigInt load4(Uint8List input) {
  BigInt r;
  r = BigInt.from(input[0]);
  r |= BigInt.from(input[1] << 8);
  r |= BigInt.from(input[2] << 16);
  r |= BigInt.from(input[3] << 24);
  return r;
}

void FeFromBytes(FieldElement dst, Uint8List src) {
  var h0 = load4(src.sublist(0, src.length));
  var h1 = load3(src.sublist(4, src.length)) << 6;
  var h2 = load3(src.sublist(7, src.length)) << 5;
  var h3 = load3(src.sublist(10, src.length)) << 3;
  var h4 = load3(src.sublist(13, src.length)) << 2;
  var h5 = load4(src.sublist(16, src.length));
  var h6 = load3(src.sublist(20, src.length)) << 7;
  var h7 = load3(src.sublist(23, src.length)) << 5;
  var h8 = load3(src.sublist(26, src.length)) << 4;
  var h9 = (load3(src.sublist(29, src.length)) & BigInt.from(8388607)) << 2;

  FeCombine(dst, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9);
}

/// FeToBytes marshals h to s.
/// Preconditions:
///   |h| bounded by 1.1*2^25,1.1*2^24,1.1*2^25,1.1*2^24,etc.
///
/// Write p=2^255-19; q=floor(h/p).
/// Basic claim: q = floor(2^(-255)(h + 19 2^(-25)h9 + 2^(-1))).
///
/// Proof:
///   Have |h|<=p so |q|<=1 so |19^2 2^(-255) q|<1/4.
///   Also have |h-2^230 h9|<2^230 so |19 2^(-255)(h-2^230 h9)|<1/4.
///
///   Write y=2^(-1)-19^2 2^(-255)q-19 2^(-255)(h-2^230 h9).
///   Then 0<y<1.
///
///   Write r=h-pq.
///   Have 0<=r<=p-1=2^255-20.
///   Thus 0<=r+19(2^-255)r<r+19(2^-255)2^255<=2^255-1.
///
///   Write x=r+19(2^-255)r+y.
///   Then 0<x<2^255 so floor(2^(-255)x) = 0 so floor(q+2^(-255)x) = q.
///
///   Have q+2^(-255)x = 2^(-255)(h + 19 2^(-25) h9 + 2^(-1))
///   so floor(2^(-255)(h + 19 2^(-25) h9 + 2^(-1))) = q.
void FeToBytes(Uint8List s, FieldElement h) {
  var carry = List<int>.filled(10, 0);

  var q = BigInt.from(19 * h[9] + (1 << 24)) >> 25;
  q = (BigInt.from(h[0]) + q) >> 26;
  q = (BigInt.from(h[1]) + q) >> 25;
  q = (BigInt.from(h[2]) + q) >> 26;
  q = (BigInt.from(h[3]) + q) >> 25;
  q = (BigInt.from(h[4]) + q) >> 26;
  q = (BigInt.from(h[5]) + q) >> 25;
  q = (BigInt.from(h[6]) + q) >> 26;
  q = (BigInt.from(h[7]) + q) >> 25;
  q = (BigInt.from(h[8]) + q) >> 26;
  q = (BigInt.from(h[9]) + q) >> 25;

  // Goal: Output h-(2^255-19)q, which is between 0 and 2^255-20.
  h[0] += (BigInt.from(19) * q).toInt();
  // Goal: Output h-2^255 q, which is between 0 and 2^255-20.

  carry[0] = (BigInt.from(h[0]) >> 26).toInt();
  h[1] += carry[0];
  h[0] -= (BigInt.from(carry[0]) << 26).toInt();
  carry[1] = (BigInt.from(h[1]) >> 25).toInt();
  h[2] += carry[1];
  h[1] -= (BigInt.from(carry[1]) << 25).toInt();
  carry[2] = (BigInt.from(h[2]) >> 26).toInt();
  h[3] += carry[2];
  h[2] -= (BigInt.from(carry[2]) << 26).toInt();
  carry[3] = (BigInt.from(h[3]) >> 25).toInt();
  h[4] += carry[3];
  h[3] -= (BigInt.from(carry[3]) << 25).toInt();
  carry[4] = (BigInt.from(h[4]) >> 26).toInt();
  h[5] += carry[4];
  h[4] -= (BigInt.from(carry[4]) << 26).toInt();
  carry[5] = (BigInt.from(h[5]) >> 25).toInt();
  h[6] += carry[5];
  h[5] -= (BigInt.from(carry[5]) << 25).toInt();
  carry[6] = (BigInt.from(h[6]) >> 26).toInt();
  h[7] += carry[6];
  h[6] -= (BigInt.from(carry[6]) << 26).toInt();
  carry[7] = (BigInt.from(h[7]) >> 25).toInt();
  h[8] += carry[7];
  h[7] -= (BigInt.from(carry[7]) << 25).toInt();
  carry[8] = (BigInt.from(h[8]) >> 26).toInt();
  h[9] += carry[8];
  h[8] -= (BigInt.from(carry[8]) << 26).toInt();
  carry[9] = (BigInt.from(h[9]) >> 25).toInt();
  h[9] -= (BigInt.from(carry[9]) << 25).toInt();
  // h10 = carry9

  // Goal: Output h[0]+...+2^255 h10-2^255 q, which is between 0 and 2^255-20.
  // Have h[0]+...+2^230 h[9] between 0 and 2^255-1;
  // evidently 2^255 h10-2^255 q = 0.
  // Goal: Output h[0]+...+2^230 h[9].

  s[0] = h[0] >> 0;
  s[1] = h[0] >> 8;
  s[2] = h[0] >> 16;
  s[3] = (h[0] >> 24) | (h[1] << 2);
  s[4] = h[1] >> 6;
  s[5] = h[1] >> 14;
  s[6] = (h[1] >> 22) | (h[2] << 3);
  s[7] = h[2] >> 5;
  s[8] = h[2] >> 13;
  s[9] = (h[2] >> 21) | (h[3] << 5);
  s[10] = h[3] >> 3;
  s[11] = h[3] >> 11;
  s[12] = (h[3] >> 19) | (h[4] << 6);
  s[13] = h[4] >> 2;
  s[14] = h[4] >> 10;
  s[15] = h[4] >> 18;
  s[16] = h[5] >> 0;
  s[17] = h[5] >> 8;
  s[18] = h[5] >> 16;
  s[19] = (h[5] >> 24) | (h[6] << 1);
  s[20] = h[6] >> 7;
  s[21] = h[6] >> 15;
  s[22] = (h[6] >> 23) | (h[7] << 3);
  s[23] = h[7] >> 5;
  s[24] = h[7] >> 13;
  s[25] = (h[7] >> 21) | (h[8] << 4);
  s[26] = h[8] >> 4;
  s[27] = h[8] >> 12;
  s[28] = (h[8] >> 20) | (h[9] << 6);
  s[29] = h[9] >> 2;
  s[30] = h[9] >> 10;
  s[31] = h[9] >> 18;
}

int FeIsNegative(FieldElement f) {
  var s = Uint8List(32);
  FeToBytes(s, f);
  return s[0] & 1;
}

int FeIsNonZero(FieldElement f) {
  var s = Uint8List(32);
  FeToBytes(s, f);
  var x = 0;
  for (var i = 0; i < s.length; i++) {
    x |= s[i];
  }
  x |= x >> 4;
  x |= x >> 2;
  x |= x >> 1;
  return x & 1;
}

/// FeNeg sets h = -f
///
/// Preconditions:
///    |f| bounded by 1.1*2^25,1.1*2^24,1.1*2^25,1.1*2^24,etc.
///
/// Postconditions:
///    |h| bounded by 1.1*2^25,1.1*2^24,1.1*2^25,1.1*2^24,etc.
void FeNeg(FieldElement h, FieldElement f) {
  h[0] = -f[0];
  h[1] = -f[1];
  h[2] = -f[2];
  h[3] = -f[3];
  h[4] = -f[4];
  h[5] = -f[5];
  h[6] = -f[6];
  h[7] = -f[7];
  h[8] = -f[8];
  h[9] = -f[9];
}

void FeCombine(FieldElement h, BigInt h0, BigInt h1, BigInt h2, BigInt h3,
    BigInt h4, BigInt h5, BigInt h6, BigInt h7, BigInt h8, BigInt h9) {
  var c0 = BigInt.one;
  var c1 = BigInt.one;
  var c2 = BigInt.one;
  var c3 = BigInt.one;
  var c4 = BigInt.one;
  var c5 = BigInt.one;
  var c6 = BigInt.one;
  var c7 = BigInt.one;
  var c8 = BigInt.one;
  var c9 = BigInt.one;

  /*
      |h0| <= (1.1*1.1*2^52*(1+19+19+19+19)+1.1*1.1*2^50*(38+38+38+38+38))
        i.e. |h0| <= 1.2*2^59; narrower ranges for h2, h4, h6, h8
      |h1| <= (1.1*1.1*2^51*(1+1+19+19+19+19+19+19+19+19))
        i.e. |h1| <= 1.5*2^58; narrower ranges for h3, h5, h7, h9
    */

  c0 = (h0 + BigInt.from(1 << 25)) >> 26;
  h1 += c0;
  h0 -= c0 << 26;
  c4 = (h4 + BigInt.from(1 << 25)) >> 26;
  h5 += c4;
  h4 -= c4 << 26;
  /* |h0| <= 2^25 */
  /* |h4| <= 2^25 */
  /* |h1| <= 1.51*2^58 */
  /* |h5| <= 1.51*2^58 */

  c1 = (h1 + BigInt.from(1 << 24)) >> 25;
  h2 += c1;
  h1 -= c1 << 25;
  c5 = (h5 + BigInt.from(1 << 24)) >> 25;
  h6 += c5;
  h5 -= c5 << 25;
  /* |h1| <= 2^24; from now on fits into int32 */
  /* |h5| <= 2^24; from now on fits into int32 */
  /* |h2| <= 1.21*2^59 */
  /* |h6| <= 1.21*2^59 */

  c2 = (h2 + BigInt.from(1 << 25)) >> 26;
  h3 += c2;
  h2 -= c2 << 26;
  c6 = (h6 + BigInt.from(1 << 25)) >> 26;
  h7 += c6;
  h6 -= c6 << 26;
  /* |h2| <= 2^25; from now on fits into int32 unchanged */
  /* |h6| <= 2^25; from now on fits into int32 unchanged */
  /* |h3| <= 1.51*2^58 */
  /* |h7| <= 1.51*2^58 */

  c3 = (h3 + BigInt.from(1 << 24)) >> 25;
  h4 += c3;
  h3 -= c3 << 25;
  c7 = (h7 + BigInt.from(1 << 24)) >> 25;
  h8 += c7;
  h7 -= c7 << 25;
  /* |h3| <= 2^24; from now on fits into int32 unchanged */
  /* |h7| <= 2^24; from now on fits into int32 unchanged */
  /* |h4| <= 1.52*2^33 */
  /* |h8| <= 1.52*2^33 */

  c4 = (h4 + BigInt.from(1 << 25)) >> 26;
  h5 += c4;
  h4 -= c4 << 26;
  c8 = (h8 + BigInt.from(1 << 25)) >> 26;
  h9 += c8;
  h8 -= c8 << 26;
  /* |h4| <= 2^25; from now on fits into int32 unchanged */
  /* |h8| <= 2^25; from now on fits into int32 unchanged */
  /* |h5| <= 1.01*2^24 */
  /* |h9| <= 1.51*2^58 */

  c9 = (h9 + BigInt.from(1 << 24)) >> 25;
  h0 += c9 * BigInt.from(19);
  h9 -= c9 << 25;
  /* |h9| <= 2^24; from now on fits into int32 unchanged */
  /* |h0| <= 1.8*2^37 */

  c0 = (h0 + BigInt.from(1 << 25)) >> 26;
  h1 += c0;
  h0 -= c0 << 26;
  /* |h0| <= 2^25; from now on fits into int32 unchanged */
  /* |h1| <= 1.01*2^24 */

  h[0] = h0.toInt();
  h[1] = h1.toInt();
  h[2] = h2.toInt();
  h[3] = h3.toInt();
  h[4] = h4.toInt();
  h[5] = h5.toInt();
  h[6] = h6.toInt();
  h[7] = h7.toInt();
  h[8] = h8.toInt();
  h[9] = h9.toInt();
}

/// FeMul calculates h = f * g
/// Can overlap h with f or g.
///
/// Preconditions:
///    |f| bounded by 1.1*2^26,1.1*2^25,1.1*2^26,1.1*2^25,etc.
///    |g| bounded by 1.1*2^26,1.1*2^25,1.1*2^26,1.1*2^25,etc.
///
/// Postconditions:
///    |h| bounded by 1.1*2^25,1.1*2^24,1.1*2^25,1.1*2^24,etc.
///
/// Notes on implementation strategy:
///
/// Using schoolbook multiplication.
/// Karatsuba would save a little in some cost models.
///
/// Most multiplications by 2 and 19 are 32-bit precomputations;
/// cheaper than 64-bit postcomputations.
///
/// There is one remaining multiplication by 19 in the carry chain;
/// one *19 precomputation can be merged into this,
/// but the resulting data flow is considerably less clean.
///
/// There are 12 carries below.
/// 10 of them are 2-way parallelizable and vectorizable.
/// Can get away with 11 carries, but then data flow is much deeper.
///
/// With tighter constraints on inputs, can squeeze carries into int32.
void FeMul(FieldElement h, FieldElement f, FieldElement g) {
  var f0 = BigInt.from(f[0]);
  var f1 = BigInt.from(f[1]);
  var f2 = BigInt.from(f[2]);
  var f3 = BigInt.from(f[3]);
  var f4 = BigInt.from(f[4]);
  var f5 = BigInt.from(f[5]);
  var f6 = BigInt.from(f[6]);
  var f7 = BigInt.from(f[7]);
  var f8 = BigInt.from(f[8]);
  var f9 = BigInt.from(f[9]);

  var f1_2 = BigInt.from(2 * f[1]);
  var f3_2 = BigInt.from(2 * f[3]);
  var f5_2 = BigInt.from(2 * f[5]);
  var f7_2 = BigInt.from(2 * f[7]);
  var f9_2 = BigInt.from(2 * f[9]);

  var g0 = BigInt.from(g[0]);
  var g1 = BigInt.from(g[1]);
  var g2 = BigInt.from(g[2]);
  var g3 = BigInt.from(g[3]);
  var g4 = BigInt.from(g[4]);
  var g5 = BigInt.from(g[5]);
  var g6 = BigInt.from(g[6]);
  var g7 = BigInt.from(g[7]);
  var g8 = BigInt.from(g[8]);
  var g9 = BigInt.from(g[9]);

  var g1_19 = BigInt.from(19 * g[1]); /* 1.4*2^29 */
  var g2_19 = BigInt.from(19 * g[2]); /* 1.4*2^30); still ok */
  var g3_19 = BigInt.from(19 * g[3]);
  var g4_19 = BigInt.from(19 * g[4]);
  var g5_19 = BigInt.from(19 * g[5]);
  var g6_19 = BigInt.from(19 * g[6]);
  var g7_19 = BigInt.from(19 * g[7]);
  var g8_19 = BigInt.from(19 * g[8]);
  var g9_19 = BigInt.from(19 * g[9]);

  var h0 = f0 * g0 +
      f1_2 * g9_19 +
      f2 * g8_19 +
      f3_2 * g7_19 +
      f4 * g6_19 +
      f5_2 * g5_19 +
      f6 * g4_19 +
      f7_2 * g3_19 +
      f8 * g2_19 +
      f9_2 * g1_19;
  var h1 = f0 * g1 +
      f1 * g0 +
      f2 * g9_19 +
      f3 * g8_19 +
      f4 * g7_19 +
      f5 * g6_19 +
      f6 * g5_19 +
      f7 * g4_19 +
      f8 * g3_19 +
      f9 * g2_19;
  var h2 = f0 * g2 +
      f1_2 * g1 +
      f2 * g0 +
      f3_2 * g9_19 +
      f4 * g8_19 +
      f5_2 * g7_19 +
      f6 * g6_19 +
      f7_2 * g5_19 +
      f8 * g4_19 +
      f9_2 * g3_19;
  var h3 = f0 * g3 +
      f1 * g2 +
      f2 * g1 +
      f3 * g0 +
      f4 * g9_19 +
      f5 * g8_19 +
      f6 * g7_19 +
      f7 * g6_19 +
      f8 * g5_19 +
      f9 * g4_19;
  var h4 = f0 * g4 +
      f1_2 * g3 +
      f2 * g2 +
      f3_2 * g1 +
      f4 * g0 +
      f5_2 * g9_19 +
      f6 * g8_19 +
      f7_2 * g7_19 +
      f8 * g6_19 +
      f9_2 * g5_19;
  var h5 = f0 * g5 +
      f1 * g4 +
      f2 * g3 +
      f3 * g2 +
      f4 * g1 +
      f5 * g0 +
      f6 * g9_19 +
      f7 * g8_19 +
      f8 * g7_19 +
      f9 * g6_19;
  var h6 = f0 * g6 +
      f1_2 * g5 +
      f2 * g4 +
      f3_2 * g3 +
      f4 * g2 +
      f5_2 * g1 +
      f6 * g0 +
      f7_2 * g9_19 +
      f8 * g8_19 +
      f9_2 * g7_19;
  var h7 = f0 * g7 +
      f1 * g6 +
      f2 * g5 +
      f3 * g4 +
      f4 * g3 +
      f5 * g2 +
      f6 * g1 +
      f7 * g0 +
      f8 * g9_19 +
      f9 * g8_19;
  var h8 = f0 * g8 +
      f1_2 * g7 +
      f2 * g6 +
      f3_2 * g5 +
      f4 * g4 +
      f5_2 * g3 +
      f6 * g2 +
      f7_2 * g1 +
      f8 * g0 +
      f9_2 * g9_19;
  var h9 = f0 * g9 +
      f1 * g8 +
      f2 * g7 +
      f3 * g6 +
      f4 * g5 +
      f5 * g4 +
      f6 * g3 +
      f7 * g2 +
      f8 * g1 +
      f9 * g0;

  FeCombine(h, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9);
}

List<BigInt> feSquare(FieldElement f) {
  var f0 = BigInt.from(f[0]);
  var f1 = BigInt.from(f[1]);
  var f2 = BigInt.from(f[2]);
  var f3 = BigInt.from(f[3]);
  var f4 = BigInt.from(f[4]);
  var f5 = BigInt.from(f[5]);
  var f6 = BigInt.from(f[6]);
  var f7 = BigInt.from(f[7]);
  var f8 = BigInt.from(f[8]);
  var f9 = BigInt.from(f[9]);
  var f0_2 = BigInt.from(2 * f[0]);
  var f1_2 = BigInt.from(2 * f[1]);
  var f2_2 = BigInt.from(2 * f[2]);
  var f3_2 = BigInt.from(2 * f[3]);
  var f4_2 = BigInt.from(2 * f[4]);
  var f5_2 = BigInt.from(2 * f[5]);
  var f6_2 = BigInt.from(2 * f[6]);
  var f7_2 = BigInt.from(2 * f[7]);
  var f5_38 = BigInt.from(38) * f5; // 1.31*2^30
  var f6_19 = BigInt.from(19) * f6; // 1.31*2^30
  var f7_38 = BigInt.from(38) * f7; // 1.31*2^30
  var f8_19 = BigInt.from(19) * f8; // 1.31*2^30
  var f9_38 = BigInt.from(38) * f9; // 1.31*2^30

  var h0 = f0 * f0 +
      f1_2 * f9_38 +
      f2_2 * f8_19 +
      f3_2 * f7_38 +
      f4_2 * f6_19 +
      f5 * f5_38;
  var h1 = f0_2 * f1 + f2 * f9_38 + f3_2 * f8_19 + f4 * f7_38 + f5_2 * f6_19;
  var h2 = f0_2 * f2 +
      f1_2 * f1 +
      f3_2 * f9_38 +
      f4_2 * f8_19 +
      f5_2 * f7_38 +
      f6 * f6_19;
  var h3 = f0_2 * f3 + f1_2 * f2 + f4 * f9_38 + f5_2 * f8_19 + f6 * f7_38;
  var h4 = f0_2 * f4 +
      f1_2 * f3_2 +
      f2 * f2 +
      f5_2 * f9_38 +
      f6_2 * f8_19 +
      f7 * f7_38;
  var h5 = f0_2 * f5 + f1_2 * f4 + f2_2 * f3 + f6 * f9_38 + f7_2 * f8_19;
  var h6 = f0_2 * f6 +
      f1_2 * f5_2 +
      f2_2 * f4 +
      f3_2 * f3 +
      f7_2 * f9_38 +
      f8 * f8_19;
  var h7 = f0_2 * f7 + f1_2 * f6 + f2_2 * f5 + f3_2 * f4 + f8 * f9_38;
  var h8 =
      f0_2 * f8 + f1_2 * f7_2 + f2_2 * f6 + f3_2 * f5_2 + f4 * f4 + f9 * f9_38;
  var h9 = f0_2 * f9 + f1_2 * f8 + f2_2 * f7 + f3_2 * f6 + f4_2 * f5;

  return [h0, h1, h2, h3, h4, h5, h6, h7, h8, h9];
}

/// FeSquare calculates h = f*f. Can overlap h with f.
///
/// Preconditions:
///    |f| bounded by 1.1*2^26,1.1*2^25,1.1*2^26,1.1*2^25,etc.
///
/// Postconditions:
///    |h| bounded by 1.1*2^25,1.1*2^24,1.1*2^25,1.1*2^24,etc.
void FeSquare(FieldElement h, FieldElement f) {
  var fs = feSquare(f);
  var h0 = fs[0];
  var h1 = fs[1];
  var h2 = fs[2];
  var h3 = fs[3];
  var h4 = fs[4];
  var h5 = fs[5];
  var h6 = fs[6];
  var h7 = fs[7];
  var h8 = fs[8];
  var h9 = fs[9];
  FeCombine(h, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9);
}

/// FeSquare2 sets h = 2 * f * f
///
/// Can overlap h with f.
///
/// Preconditions:
///    |f| bounded by 1.65*2^26,1.65*2^25,1.65*2^26,1.65*2^25,etc.
///
/// Postconditions:
///    |h| bounded by 1.01*2^25,1.01*2^24,1.01*2^25,1.01*2^24,etc.
/// See fe_mul.c for discussion of implementation strategy.
void FeSquare2(FieldElement h, FieldElement f) {
  var fs = feSquare(f);
  var h0 = fs[0];
  var h1 = fs[1];
  var h2 = fs[2];
  var h3 = fs[3];
  var h4 = fs[4];
  var h5 = fs[5];
  var h6 = fs[6];
  var h7 = fs[7];
  var h8 = fs[8];
  var h9 = fs[9];

  h0 += h0;
  h1 += h1;
  h2 += h2;
  h3 += h3;
  h4 += h4;
  h5 += h5;
  h6 += h6;
  h7 += h7;
  h8 += h8;
  h9 += h9;

  FeCombine(h, h0, h1, h2, h3, h4, h5, h6, h7, h8, h9);
}

void FeInvert(FieldElement out, FieldElement z) {
  var t0 = FieldElement();
  var t1 = FieldElement();
  var t2 = FieldElement();
  var t3 = FieldElement();
  var i = 0;

  FeSquare(t0, z); // 2^1
  FeSquare(t1, t0); // 2^2
  for (i = 1; i < 2; i++) {
    // 2^3
    FeSquare(t1, t1);
  }
  FeMul(t1, z, t1); // 2^3 + 2^0
  FeMul(t0, t0, t1); // 2^3 + 2^1 + 2^0
  FeSquare(t2, t0); // 2^4 + 2^2 + 2^1
  FeMul(t1, t1, t2); // 2^4 + 2^3 + 2^2 + 2^1 + 2^0
  FeSquare(t2, t1); // 5,4,3,2,1
  for (i = 1; i < 5; i++) {
    // 9,8,7,6,5
    FeSquare(t2, t2);
  }
  FeMul(t1, t2, t1); // 9,8,7,6,5,4,3,2,1,0
  FeSquare(t2, t1); // 10..1
  for (i = 1; i < 10; i++) {
    // 19..10
    FeSquare(t2, t2);
  }
  FeMul(t2, t2, t1); // 19..0
  FeSquare(t3, t2); // 20..1
  for (i = 1; i < 20; i++) {
    // 39..20
    FeSquare(t3, t3);
  }
  FeMul(t2, t3, t2); // 39..0
  FeSquare(t2, t2); // 40..1
  for (i = 1; i < 10; i++) {
    // 49..10
    FeSquare(t2, t2);
  }
  FeMul(t1, t2, t1); // 49..0
  FeSquare(t2, t1); // 50..1
  for (i = 1; i < 50; i++) {
    // 99..50
    FeSquare(t2, t2);
  }
  FeMul(t2, t2, t1); // 99..0
  FeSquare(t3, t2); // 100..1
  for (i = 1; i < 100; i++) {
    // 199..100
    FeSquare(t3, t3);
  }
  FeMul(t2, t3, t2); // 199..0
  FeSquare(t2, t2); // 200..1
  for (i = 1; i < 50; i++) {
    // 249..50
    FeSquare(t2, t2);
  }
  FeMul(t1, t2, t1); // 249..0
  FeSquare(t1, t1); // 250..1
  for (i = 1; i < 5; i++) {
    // 254..5
    FeSquare(t1, t1);
  }
  FeMul(out, t1, t0); // 254..5,3,1,0
}

void fePow22523(FieldElement out, FieldElement z) {
  var t0 = FieldElement();
  var t1 = FieldElement();
  var t2 = FieldElement();
  var i = 0;

  FeSquare(t0, z);
  for (i = 1; i < 1; i++) {
    FeSquare(t0, t0);
  }
  FeSquare(t1, t0);
  for (i = 1; i < 2; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t1, z, t1);
  FeMul(t0, t0, t1);
  FeSquare(t0, t0);
  for (i = 1; i < 1; i++) {
    FeSquare(t0, t0);
  }
  FeMul(t0, t1, t0);
  FeSquare(t1, t0);
  for (i = 1; i < 5; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t0, t1, t0);
  FeSquare(t1, t0);
  for (i = 1; i < 10; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t1, t1, t0);
  FeSquare(t2, t1);
  for (i = 1; i < 20; i++) {
    FeSquare(t2, t2);
  }
  FeMul(t1, t2, t1);
  FeSquare(t1, t1);
  for (i = 1; i < 10; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t0, t1, t0);
  FeSquare(t1, t0);
  for (i = 1; i < 50; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t1, t1, t0);
  FeSquare(t2, t1);
  for (i = 1; i < 100; i++) {
    FeSquare(t2, t2);
  }
  FeMul(t1, t2, t1);
  FeSquare(t1, t1);
  for (i = 1; i < 50; i++) {
    FeSquare(t1, t1);
  }
  FeMul(t0, t1, t0);
  FeSquare(t0, t0);
  for (i = 1; i < 2; i++) {
    FeSquare(t0, t0);
  }
  FeMul(out, t0, z);
}

/// Group elements are members of the elliptic curve -x^2 + y^2 = 1 + d * x^2 *
/// y^2 where d = -121665/121666.
///
/// Several representations are used:
///   ProjectiveGroupElement: (X:Y:Z) satisfying x=X/Z, y=Y/Z
///   ExtendedGroupElement: (X:Y:Z:T) satisfying x=X/Z, y=Y/Z, XY=ZT
///   CompletedGroupElement: ((X:Z),(Y:T)) satisfying x=X/Z, y=Y/T
///   PreComputedGroupElement: (y+x,y-x,2dxy)
class ProjectiveGroupElement {
  FieldElement X = FieldElement();
  FieldElement Y = FieldElement();
  FieldElement Z = FieldElement();

  void Zero() {
    FeZero(X);
    FeOne(Y);
    FeOne(Z);
  }

  void Double(CompletedGroupElement r) {
    var t0 = FieldElement();

    FeSquare(r.X, X);
    FeSquare(r.Z, Y);
    FeSquare2(r.T, Z);
    FeAdd(r.Y, X, Y);
    FeSquare(t0, r.Y);
    FeAdd(r.Y, r.Z, r.X);
    FeSub(r.Z, r.Z, r.X);
    FeSub(r.X, t0, r.Y);
    FeSub(r.T, r.T, r.Z);
  }

  void ToBytes(Uint8List s) {
    var recip = FieldElement();
    var x = FieldElement();
    var y = FieldElement();

    FeInvert(recip, Z);
    FeMul(x, X, recip);
    FeMul(y, Y, recip);
    FeToBytes(s, y);
    s[31] ^= FeIsNegative(x) << 7;
  }
}

class ExtendedGroupElement {
  FieldElement X = FieldElement();
  FieldElement Y = FieldElement();
  FieldElement Z = FieldElement();
  FieldElement T = FieldElement();

  void Zero() {
    FeZero(X);
    FeOne(Y);
    FeOne(Z);
    FeZero(T);
  }

  void Double(CompletedGroupElement r) {
    var q = ProjectiveGroupElement();
    ToProjective(q);
    q.Double(r);
  }

  void ToCached(CachedGroupElement r) {
    FeAdd(r.yPlusX, Y, X);
    FeSub(r.yMinusX, Y, X);
    FeCopy(r.Z, Z);
    FeMul(r.T2d, T, d2);
  }

  void ToProjective(ProjectiveGroupElement r) {
    FeCopy(r.X, X);
    FeCopy(r.Y, Y);
    FeCopy(r.Z, Z);
  }

  void ToBytes(Uint8List s) {
    var recip = FieldElement();
    var x = FieldElement();
    var y = FieldElement();

    FeInvert(recip, Z);
    FeMul(x, X, recip);
    FeMul(y, Y, recip);
    FeToBytes(s, y);
    s[31] ^= FeIsNegative(x) << 7;
  }

  bool FromBytes(Uint8List s) {
    var u = FieldElement();
    var v = FieldElement();
    var v3 = FieldElement();
    var vxx = FieldElement();
    var check = FieldElement();

    FeFromBytes(Y, s);
    FeOne(Z);
    FeSquare(u, Y);
    FeMul(v, u, d);
    FeSub(u, u, Z); // y = y^2-1
    FeAdd(v, v, Z); // v = dy^2+1

    FeSquare(v3, v);
    FeMul(v3, v3, v); // v3 = v^3
    FeSquare(X, v3);
    FeMul(X, X, v);
    FeMul(X, X, u); // x = uv^7

    fePow22523(X, X); // x = (uv^7)^((q-5)/8)
    FeMul(X, X, v3);
    FeMul(X, X, u); // x = uv^3(uv^7)^((q-5)/8)

    var tmpX = Uint8List(32);
    var tmp2 = Uint8List(32);

    FeSquare(vxx, X);
    FeMul(vxx, vxx, v);
    FeSub(check, vxx, u); // vx^2-u
    if (FeIsNonZero(check) == 1) {
      FeAdd(check, vxx, u); // vx^2+u
      if (FeIsNonZero(check) == 1) {
        return false;
      }
      FeMul(X, X, SqrtM1);

      FeToBytes(tmpX, X);
      for (var i = 0; i < tmp2.length; i++) {
        tmp2[31 - i] = tmp2[i];
      }
    }

    if (FeIsNegative(X) != (s[31] >> 7)) {
      FeNeg(X, X);
    }

    FeMul(T, X, Y);
    return true;
  }
}

class CompletedGroupElement {
  FieldElement X = FieldElement();
  FieldElement Y = FieldElement();
  FieldElement Z = FieldElement();
  FieldElement T = FieldElement();

  void ToProjective(ProjectiveGroupElement r) {
    FeMul(r.X, X, T);
    FeMul(r.Y, Y, Z);
    FeMul(r.Z, Z, T);
  }

  void ToExtended(ExtendedGroupElement r) {
    FeMul(r.X, X, T);
    FeMul(r.Y, Y, Z);
    FeMul(r.Z, Z, T);
    FeMul(r.T, X, Y);
  }
}

class PreComputedGroupElement {
  FieldElement yPlusX = FieldElement();
  FieldElement yMinusX = FieldElement();
  FieldElement xy2d = FieldElement();

  PreComputedGroupElement();

  PreComputedGroupElement.fromList(
      FieldElement ypx, FieldElement ymx, FieldElement xy2d) {
    yPlusX = ypx;
    yMinusX = ymx;
    this.xy2d = xy2d;
  }

  void Zero() {
    FeOne(yPlusX);
    FeOne(yMinusX);
    FeZero(xy2d);
  }
}

class CachedGroupElement {
  FieldElement yPlusX = FieldElement();
  FieldElement yMinusX = FieldElement();
  FieldElement Z = FieldElement();
  FieldElement T2d = FieldElement();
}

void geAdd(
    CompletedGroupElement r, ExtendedGroupElement p, CachedGroupElement q) {
  var t0 = FieldElement();

  FeAdd(r.X, p.Y, p.X);
  FeSub(r.Y, p.Y, p.X);
  FeMul(r.Z, r.X, q.yPlusX);
  FeMul(r.Y, r.Y, q.yMinusX);
  FeMul(r.T, q.T2d, p.T);
  FeMul(r.X, p.Z, q.Z);
  FeAdd(t0, r.X, r.X);
  FeSub(r.X, r.Z, r.Y);
  FeAdd(r.Y, r.Z, r.Y);
  FeAdd(r.Z, t0, r.T);
  FeSub(r.T, t0, r.T);
}

void geSub(
    CompletedGroupElement r, ExtendedGroupElement p, CachedGroupElement q) {
  var t0 = FieldElement();

  FeAdd(r.X, p.Y, p.X);
  FeSub(r.Y, p.Y, p.X);
  FeMul(r.Z, r.X, q.yMinusX);
  FeMul(r.Y, r.Y, q.yPlusX);
  FeMul(r.T, q.T2d, p.T);
  FeMul(r.X, p.Z, q.Z);
  FeAdd(t0, r.X, r.X);
  FeSub(r.X, r.Z, r.Y);
  FeAdd(r.Y, r.Z, r.Y);
  FeSub(r.Z, t0, r.T);
  FeAdd(r.T, t0, r.T);
}

void geMixedAdd(CompletedGroupElement r, ExtendedGroupElement p,
    PreComputedGroupElement q) {
  var t0 = FieldElement();

  FeAdd(r.X, p.Y, p.X);
  FeSub(r.Y, p.Y, p.X);
  FeMul(r.Z, r.X, q.yPlusX);
  FeMul(r.Y, r.Y, q.yMinusX);
  FeMul(r.T, q.xy2d, p.T);
  FeAdd(t0, p.Z, p.Z);
  FeSub(r.X, r.Z, r.Y);
  FeAdd(r.Y, r.Z, r.Y);
  FeAdd(r.Z, t0, r.T);
  FeSub(r.T, t0, r.T);
}

void geMixedSub(CompletedGroupElement r, ExtendedGroupElement p,
    PreComputedGroupElement q) {
  var t0 = FieldElement();

  FeAdd(r.X, p.Y, p.X);
  FeSub(r.Y, p.Y, p.X);
  FeMul(r.Z, r.X, q.yMinusX);
  FeMul(r.Y, r.Y, q.yPlusX);
  FeMul(r.T, q.xy2d, p.T);
  FeAdd(t0, p.Z, p.Z);
  FeSub(r.X, r.Z, r.Y);
  FeAdd(r.Y, r.Z, r.Y);
  FeSub(r.Z, t0, r.T);
  FeAdd(r.T, t0, r.T);
}

void slide(Int8List r, Uint8List a) {
  for (var i = 0; i < r.length; i++) {
    r[i] = 1 & (a[i >> 3] >> (i & 7));
  }

  for (var i = 0; i < r.length; i++) {
    if (r[i] != 0) {
      for (var b = 1; b <= 6 && i + b < 256; b++) {
        if (r[i + b] != 0) {
          if (r[i] + (r[i + b] << b) <= 15) {
            r[i] += r[i + b] << b;
            r[i + b] = 0;
          } else if (r[i] - (r[i + b] << b) >= -15) {
            r[i] -= r[i + b] << b;
            for (var k = i + b; k < 256; k++) {
              if (r[k] == 0) {
                r[k] = 1;
                break;
              }
              r[k] = 0;
            }
          } else {
            break;
          }
        }
      }
    }
  }
}

/// GeDoubleScalarMultVartime sets r = a*A + b*B
/// where a = a[0]+256*a[1]+...+256^31 a[31].
/// and b = b[0]+256*b[1]+...+256^31 b[31].
/// B is the Ed25519 base point (x,4/5) with x positive.
void GeDoubleScalarMultVartime(ProjectiveGroupElement r, Uint8List a,
    ExtendedGroupElement A, Uint8List b) {
  var aSlide = Int8List(256);
  var bSlide = Int8List(256);
  var Ai = List.generate(
      8, (index) => CachedGroupElement()); // A,3A,5A,7A,9A,11A,13A,15A
  var t = CompletedGroupElement();
  var u = ExtendedGroupElement();
  var A2 = ExtendedGroupElement();
  int i;

  slide(aSlide, a);
  slide(bSlide, b);

  A.ToCached(Ai[0]);
  A.Double(t);
  t.ToExtended(A2);

  for (i = 0; i < 7; i++) {
    geAdd(t, A2, Ai[i]);
    t.ToExtended(u);
    u.ToCached(Ai[i + 1]);
  }

  r.Zero();

  for (i = 255; i >= 0; i--) {
    if (aSlide[i] != 0 || bSlide[i] != 0) {
      break;
    }
  }

  for (; i >= 0; i--) {
    r.Double(t);

    if (aSlide[i] > 0) {
      t.ToExtended(u);
      geAdd(t, u, Ai[aSlide[i] ~/ 2]);
    } else if (aSlide[i] < 0) {
      t.ToExtended(u);
      geSub(t, u, Ai[(-aSlide[i]) ~/ 2]);
    }

    if (bSlide[i] > 0) {
      t.ToExtended(u);
      geMixedAdd(t, u, bi[bSlide[i] ~/ 2]);
    } else if (bSlide[i] < 0) {
      t.ToExtended(u);
      geMixedSub(t, u, bi[(-bSlide[i]) ~/ 2]);
    }

    t.ToProjective(r);
  }
}

/// equal returns 1 if b == c and 0 otherwise, assuming that b and c are
/// non-negative.
int equal(int b, int c) {
  if (b == c) {
    return 1;
  } else {
    return 0;
  }
//  var x = b ^ c;
//  x--;
//  return x >> 31;
}

/// negative returns 1 if b < 0 and 0 otherwise.
int negative(int b) {
  if (b < 0) {
    return 1;
  } else {
    return 0;
  }
//  return (b >> 31) & 1;
}

void PreComputedGroupElementCMove(
    PreComputedGroupElement t, PreComputedGroupElement u, int b) {
  FeCMove(t.yPlusX, u.yPlusX, b);
  FeCMove(t.yMinusX, u.yMinusX, b);
  FeCMove(t.xy2d, u.xy2d, b);
}

void selectPoint(PreComputedGroupElement t, int pos, int b) {
  var minusT = PreComputedGroupElement();
  var bNegative = negative(b);
  var bb = BigInt.from(b);
  var bAbs = (bb - ((BigInt.from(-bNegative) & bb) << 1)).toInt();

  t.Zero();
  for (var i = 0; i < 8; i++) {
    PreComputedGroupElementCMove(t, base[pos][i], equal(bAbs, i + 1));
  }
  FeCopy(minusT.yPlusX, t.yMinusX);
  FeCopy(minusT.yMinusX, t.yPlusX);
  FeNeg(minusT.xy2d, t.xy2d);
  PreComputedGroupElementCMove(t, minusT, bNegative);
}

/// GeScalarMultBase computes h = a*B, where
///   a = a[0]+256*a[1]+...+256^31 a[31]
///   B is the Ed25519 base point (x,4/5) with x positive.
///
/// Preconditions:
///   a[31] <= 127
void GeScalarMultBase(ExtendedGroupElement h, Uint8List a) {
  var e = List<int>.filled(64, 0);

  for (var i = 0; i < a.length; i++) {
    var v = a[i];
    e[2 * i] = v & 15;
    e[2 * i + 1] = (v >> 4) & 15;
  }

  // each e[i] is between 0 and 15 and e[63] is between 0 and 7.

  var carry = 0;
  for (var i = 0; i < 63; i++) {
    e[i] += carry;
    carry = (e[i] + 8) >> 4;
    e[i] -= carry << 4;
  }
  e[63] += carry;
  // each e[i] is between -8 and 8.

  h.Zero();
  var t = PreComputedGroupElement();
  var r = CompletedGroupElement();
  for (var i = 1; i < 64; i += 2) {
    selectPoint(t, i ~/ 2, e[i]);
    geMixedAdd(r, h, t);
    r.ToExtended(h);
  }

  var s = ProjectiveGroupElement();

  h.Double(r);
  r.ToProjective(s);
  s.Double(r);
  r.ToProjective(s);
  s.Double(r);
  r.ToProjective(s);
  s.Double(r);
  r.ToExtended(h);

  for (var i = 0; i < 64; i += 2) {
    selectPoint(t, i ~/ 2, e[i]);
    geMixedAdd(r, h, t);
    r.ToExtended(h);
  }
}

/// The scalars are GF(2^252 + 27742317777372353535851937790883648493).

/// Input:
///   a[0]+256*a[1]+...+256^31*a[31] = a
///   b[0]+256*b[1]+...+256^31*b[31] = b
///   c[0]+256*c[1]+...+256^31*c[31] = c
///
/// Output:
///   s[0]+256*s[1]+...+256^31*s[31] = (ab+c) mod l
///   where l = 2^252 + 27742317777372353535851937790883648493.
void ScMulAdd(Uint8List s, Uint8List a, Uint8List b, Uint8List c) {
  var a0 = BigInt.from(2097151) & load3(a.sublist(0, a.length));
  var a1 = BigInt.from(2097151) & (load4(a.sublist(2, a.length)) >> 5);
  var a2 = BigInt.from(2097151) & (load3(a.sublist(5, a.length)) >> 2);
  var a3 = BigInt.from(2097151) & (load4(a.sublist(7, a.length)) >> 7);
  var a4 = BigInt.from(2097151) & (load4(a.sublist(10, a.length)) >> 4);
  var a5 = BigInt.from(2097151) & (load3(a.sublist(13, a.length)) >> 1);
  var a6 = BigInt.from(2097151) & (load4(a.sublist(15, a.length)) >> 6);
  var a7 = BigInt.from(2097151) & (load3(a.sublist(18, a.length)) >> 3);
  var a8 = BigInt.from(2097151) & load3(a.sublist(21, a.length));
  var a9 = BigInt.from(2097151) & (load4(a.sublist(23, a.length)) >> 5);
  var a10 = BigInt.from(2097151) & (load3(a.sublist(26, a.length)) >> 2);
  var a11 = load4(a.sublist(28, a.length)) >> 7;

  var b0 = BigInt.from(2097151) & load3(b.sublist(0, b.length));
  var b1 = BigInt.from(2097151) & (load4(b.sublist(2, b.length)) >> 5);
  var b2 = BigInt.from(2097151) & (load3(b.sublist(5, b.length)) >> 2);
  var b3 = BigInt.from(2097151) & (load4(b.sublist(7, b.length)) >> 7);
  var b4 = BigInt.from(2097151) & (load4(b.sublist(10, b.length)) >> 4);
  var b5 = BigInt.from(2097151) & (load3(b.sublist(13, b.length)) >> 1);
  var b6 = BigInt.from(2097151) & (load4(b.sublist(15, b.length)) >> 6);
  var b7 = BigInt.from(2097151) & (load3(b.sublist(18, b.length)) >> 3);
  var b8 = BigInt.from(2097151) & load3(b.sublist(21, b.length));
  var b9 = BigInt.from(2097151) & (load4(b.sublist(23, b.length)) >> 5);
  var b10 = BigInt.from(2097151) & (load3(b.sublist(26, b.length)) >> 2);
  var b11 = load4(b.sublist(28, b.length)) >> 7;

  var c0 = BigInt.from(2097151) & load3(c.sublist(0, c.length));
  var c1 = BigInt.from(2097151) & (load4(c.sublist(2, c.length)) >> 5);
  var c2 = BigInt.from(2097151) & (load3(c.sublist(5, c.length)) >> 2);
  var c3 = BigInt.from(2097151) & (load4(c.sublist(7, c.length)) >> 7);
  var c4 = BigInt.from(2097151) & (load4(c.sublist(10, c.length)) >> 4);
  var c5 = BigInt.from(2097151) & (load3(c.sublist(13, c.length)) >> 1);
  var c6 = BigInt.from(2097151) & (load4(c.sublist(15, c.length)) >> 6);
  var c7 = BigInt.from(2097151) & (load3(c.sublist(18, c.length)) >> 3);
  var c8 = BigInt.from(2097151) & load3(c.sublist(21, c.length));
  var c9 = BigInt.from(2097151) & (load4(c.sublist(23, c.length)) >> 5);
  var c10 = BigInt.from(2097151) & (load3(c.sublist(26, c.length)) >> 2);
  var c11 = load4(c.sublist(28, c.length)) >> 7;

  var carry = List<BigInt>.filled(23, BigInt.zero);

  var s0 = c0 + a0 * b0;
  var s1 = c1 + a0 * b1 + a1 * b0;
  var s2 = c2 + a0 * b2 + a1 * b1 + a2 * b0;
  var s3 = c3 + a0 * b3 + a1 * b2 + a2 * b1 + a3 * b0;
  var s4 = c4 + a0 * b4 + a1 * b3 + a2 * b2 + a3 * b1 + a4 * b0;
  var s5 = c5 + a0 * b5 + a1 * b4 + a2 * b3 + a3 * b2 + a4 * b1 + a5 * b0;
  var s6 =
      c6 + a0 * b6 + a1 * b5 + a2 * b4 + a3 * b3 + a4 * b2 + a5 * b1 + a6 * b0;
  var s7 = c7 +
      a0 * b7 +
      a1 * b6 +
      a2 * b5 +
      a3 * b4 +
      a4 * b3 +
      a5 * b2 +
      a6 * b1 +
      a7 * b0;
  var s8 = c8 +
      a0 * b8 +
      a1 * b7 +
      a2 * b6 +
      a3 * b5 +
      a4 * b4 +
      a5 * b3 +
      a6 * b2 +
      a7 * b1 +
      a8 * b0;
  var s9 = c9 +
      a0 * b9 +
      a1 * b8 +
      a2 * b7 +
      a3 * b6 +
      a4 * b5 +
      a5 * b4 +
      a6 * b3 +
      a7 * b2 +
      a8 * b1 +
      a9 * b0;
  var s10 = c10 +
      a0 * b10 +
      a1 * b9 +
      a2 * b8 +
      a3 * b7 +
      a4 * b6 +
      a5 * b5 +
      a6 * b4 +
      a7 * b3 +
      a8 * b2 +
      a9 * b1 +
      a10 * b0;
  var s11 = c11 +
      a0 * b11 +
      a1 * b10 +
      a2 * b9 +
      a3 * b8 +
      a4 * b7 +
      a5 * b6 +
      a6 * b5 +
      a7 * b4 +
      a8 * b3 +
      a9 * b2 +
      a10 * b1 +
      a11 * b0;
  var s12 = a1 * b11 +
      a2 * b10 +
      a3 * b9 +
      a4 * b8 +
      a5 * b7 +
      a6 * b6 +
      a7 * b5 +
      a8 * b4 +
      a9 * b3 +
      a10 * b2 +
      a11 * b1;
  var s13 = a2 * b11 +
      a3 * b10 +
      a4 * b9 +
      a5 * b8 +
      a6 * b7 +
      a7 * b6 +
      a8 * b5 +
      a9 * b4 +
      a10 * b3 +
      a11 * b2;
  var s14 = a3 * b11 +
      a4 * b10 +
      a5 * b9 +
      a6 * b8 +
      a7 * b7 +
      a8 * b6 +
      a9 * b5 +
      a10 * b4 +
      a11 * b3;
  var s15 = a4 * b11 +
      a5 * b10 +
      a6 * b9 +
      a7 * b8 +
      a8 * b7 +
      a9 * b6 +
      a10 * b5 +
      a11 * b4;
  var s16 =
      a5 * b11 + a6 * b10 + a7 * b9 + a8 * b8 + a9 * b7 + a10 * b6 + a11 * b5;
  var s17 = a6 * b11 + a7 * b10 + a8 * b9 + a9 * b8 + a10 * b7 + a11 * b6;
  var s18 = a7 * b11 + a8 * b10 + a9 * b9 + a10 * b8 + a11 * b7;
  var s19 = a8 * b11 + a9 * b10 + a10 * b9 + a11 * b8;
  var s20 = a9 * b11 + a10 * b10 + a11 * b9;
  var s21 = a10 * b11 + a11 * b10;
  var s22 = a11 * b11;
  var s23 = BigInt.zero;

  carry[0] = (s0 + BigInt.from(1 << 20)) >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[2] = (s2 + BigInt.from(1 << 20)) >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[4] = (s4 + BigInt.from(1 << 20)) >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[6] = (s6 + BigInt.from(1 << 20)) >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[8] = (s8 + BigInt.from(1 << 20)) >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[10] = (s10 + BigInt.from(1 << 20)) >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;
  carry[12] = (s12 + BigInt.from(1 << 20)) >> 21;
  s13 += carry[12];
  s12 -= carry[12] << 21;
  carry[14] = (s14 + BigInt.from(1 << 20)) >> 21;
  s15 += carry[14];
  s14 -= carry[14] << 21;
  carry[16] = (s16 + BigInt.from(1 << 20)) >> 21;
  s17 += carry[16];
  s16 -= carry[16] << 21;
  carry[18] = (s18 + BigInt.from(1 << 20)) >> 21;
  s19 += carry[18];
  s18 -= carry[18] << 21;
  carry[20] = (s20 + BigInt.from(1 << 20)) >> 21;
  s21 += carry[20];
  s20 -= carry[20] << 21;
  carry[22] = (s22 + BigInt.from(1 << 20)) >> 21;
  s23 += carry[22];
  s22 -= carry[22] << 21;

  carry[1] = (s1 + BigInt.from(1 << 20)) >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[3] = (s3 + BigInt.from(1 << 20)) >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[5] = (s5 + BigInt.from(1 << 20)) >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[7] = (s7 + BigInt.from(1 << 20)) >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[9] = (s9 + BigInt.from(1 << 20)) >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[11] = (s11 + BigInt.from(1 << 20)) >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;
  carry[13] = (s13 + BigInt.from(1 << 20)) >> 21;
  s14 += carry[13];
  s13 -= carry[13] << 21;
  carry[15] = (s15 + BigInt.from(1 << 20)) >> 21;
  s16 += carry[15];
  s15 -= carry[15] << 21;
  carry[17] = (s17 + BigInt.from(1 << 20)) >> 21;
  s18 += carry[17];
  s17 -= carry[17] << 21;
  carry[19] = (s19 + BigInt.from(1 << 20)) >> 21;
  s20 += carry[19];
  s19 -= carry[19] << 21;
  carry[21] = (s21 + BigInt.from(1 << 20)) >> 21;
  s22 += carry[21];
  s21 -= carry[21] << 21;

  s11 += s23 * BigInt.from(666643);
  s12 += s23 * BigInt.from(470296);
  s13 += s23 * BigInt.from(654183);
  s14 -= s23 * BigInt.from(997805);
  s15 += s23 * BigInt.from(136657);
  s16 -= s23 * BigInt.from(683901);
  s23 = BigInt.zero;

  s10 += s22 * BigInt.from(666643);
  s11 += s22 * BigInt.from(470296);
  s12 += s22 * BigInt.from(654183);
  s13 -= s22 * BigInt.from(997805);
  s14 += s22 * BigInt.from(136657);
  s15 -= s22 * BigInt.from(683901);
  s22 = BigInt.zero;

  s9 += s21 * BigInt.from(666643);
  s10 += s21 * BigInt.from(470296);
  s11 += s21 * BigInt.from(654183);
  s12 -= s21 * BigInt.from(997805);
  s13 += s21 * BigInt.from(136657);
  s14 -= s21 * BigInt.from(683901);
  s21 = BigInt.zero;

  s8 += s20 * BigInt.from(666643);
  s9 += s20 * BigInt.from(470296);
  s10 += s20 * BigInt.from(654183);
  s11 -= s20 * BigInt.from(997805);
  s12 += s20 * BigInt.from(136657);
  s13 -= s20 * BigInt.from(683901);
  s20 = BigInt.zero;

  s7 += s19 * BigInt.from(666643);
  s8 += s19 * BigInt.from(470296);
  s9 += s19 * BigInt.from(654183);
  s10 -= s19 * BigInt.from(997805);
  s11 += s19 * BigInt.from(136657);
  s12 -= s19 * BigInt.from(683901);
  s19 = BigInt.zero;

  s6 += s18 * BigInt.from(666643);
  s7 += s18 * BigInt.from(470296);
  s8 += s18 * BigInt.from(654183);
  s9 -= s18 * BigInt.from(997805);
  s10 += s18 * BigInt.from(136657);
  s11 -= s18 * BigInt.from(683901);
  s18 = BigInt.zero;

  carry[6] = (s6 + BigInt.from(1 << 20)) >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[8] = (s8 + BigInt.from(1 << 20)) >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[10] = (s10 + BigInt.from(1 << 20)) >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;
  carry[12] = (s12 + BigInt.from(1 << 20)) >> 21;
  s13 += carry[12];
  s12 -= carry[12] << 21;
  carry[14] = (s14 + BigInt.from(1 << 20)) >> 21;
  s15 += carry[14];
  s14 -= carry[14] << 21;
  carry[16] = (s16 + BigInt.from(1 << 20)) >> 21;
  s17 += carry[16];
  s16 -= carry[16] << 21;

  carry[7] = (s7 + BigInt.from(1 << 20)) >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[9] = (s9 + BigInt.from(1 << 20)) >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[11] = (s11 + BigInt.from(1 << 20)) >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;
  carry[13] = (s13 + BigInt.from(1 << 20)) >> 21;
  s14 += carry[13];
  s13 -= carry[13] << 21;
  carry[15] = (s15 + BigInt.from(1 << 20)) >> 21;
  s16 += carry[15];
  s15 -= carry[15] << 21;

  s5 += s17 * BigInt.from(666643);
  s6 += s17 * BigInt.from(470296);
  s7 += s17 * BigInt.from(654183);
  s8 -= s17 * BigInt.from(997805);
  s9 += s17 * BigInt.from(136657);
  s10 -= s17 * BigInt.from(683901);
  s17 = BigInt.zero;

  s4 += s16 * BigInt.from(666643);
  s5 += s16 * BigInt.from(470296);
  s6 += s16 * BigInt.from(654183);
  s7 -= s16 * BigInt.from(997805);
  s8 += s16 * BigInt.from(136657);
  s9 -= s16 * BigInt.from(683901);
  s16 = BigInt.zero;

  s3 += s15 * BigInt.from(666643);
  s4 += s15 * BigInt.from(470296);
  s5 += s15 * BigInt.from(654183);
  s6 -= s15 * BigInt.from(997805);
  s7 += s15 * BigInt.from(136657);
  s8 -= s15 * BigInt.from(683901);
  s15 = BigInt.zero;

  s2 += s14 * BigInt.from(666643);
  s3 += s14 * BigInt.from(470296);
  s4 += s14 * BigInt.from(654183);
  s5 -= s14 * BigInt.from(997805);
  s6 += s14 * BigInt.from(136657);
  s7 -= s14 * BigInt.from(683901);
  s14 = BigInt.zero;

  s1 += s13 * BigInt.from(666643);
  s2 += s13 * BigInt.from(470296);
  s3 += s13 * BigInt.from(654183);
  s4 -= s13 * BigInt.from(997805);
  s5 += s13 * BigInt.from(136657);
  s6 -= s13 * BigInt.from(683901);
  s13 = BigInt.zero;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = (s0 + BigInt.from(1 << 20)) >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[2] = (s2 + BigInt.from(1 << 20)) >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[4] = (s4 + BigInt.from(1 << 20)) >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[6] = (s6 + BigInt.from(1 << 20)) >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[8] = (s8 + BigInt.from(1 << 20)) >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[10] = (s10 + BigInt.from(1 << 20)) >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;

  carry[1] = (s1 + BigInt.from(1 << 20)) >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[3] = (s3 + BigInt.from(1 << 20)) >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[5] = (s5 + BigInt.from(1 << 20)) >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[7] = (s7 + BigInt.from(1 << 20)) >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[9] = (s9 + BigInt.from(1 << 20)) >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[11] = (s11 + BigInt.from(1 << 20)) >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = s0 >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[1] = s1 >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[2] = s2 >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[3] = s3 >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[4] = s4 >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[5] = s5 >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[6] = s6 >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[7] = s7 >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[8] = s8 >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[9] = s9 >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[10] = s10 >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;
  carry[11] = s11 >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = s0 >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[1] = s1 >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[2] = s2 >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[3] = s3 >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[4] = s4 >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[5] = s5 >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[6] = s6 >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[7] = s7 >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[8] = s8 >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[9] = s9 >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[10] = s10 >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;

  s[0] = (s0 >> 0).toInt();
  s[1] = (s0 >> 8).toInt();
  s[2] = ((s0 >> 16) | (s1 << 5)).toInt();
  s[3] = (s1 >> 3).toInt();
  s[4] = (s1 >> 11).toInt();
  s[5] = ((s1 >> 19) | (s2 << 2)).toInt();
  s[6] = (s2 >> 6).toInt();
  s[7] = ((s2 >> 14) | (s3 << 7)).toInt();
  s[8] = (s3 >> 1).toInt();
  s[9] = (s3 >> 9).toInt();
  s[10] = ((s3 >> 17) | (s4 << 4)).toInt();
  s[11] = (s4 >> 4).toInt();
  s[12] = (s4 >> 12).toInt();
  s[13] = ((s4 >> 20) | (s5 << 1)).toInt();
  s[14] = (s5 >> 7).toInt();
  s[15] = ((s5 >> 15) | (s6 << 6)).toInt();
  s[16] = (s6 >> 2).toInt();
  s[17] = (s6 >> 10).toInt();
  s[18] = ((s6 >> 18) | (s7 << 3)).toInt();
  s[19] = (s7 >> 5).toInt();
  s[20] = (s7 >> 13).toInt();
  s[21] = (s8 >> 0).toInt();
  s[22] = (s8 >> 8).toInt();
  s[23] = ((s8 >> 16) | (s9 << 5)).toInt();
  s[24] = (s9 >> 3).toInt();
  s[25] = (s9 >> 11).toInt();
  s[26] = ((s9 >> 19) | (s10 << 2)).toInt();
  s[27] = (s10 >> 6).toInt();
  s[28] = ((s10 >> 14) | (s11 << 7)).toInt();
  s[29] = (s11 >> 1).toInt();
  s[30] = (s11 >> 9).toInt();
  s[31] = (s11 >> 17).toInt();
}

/// Input:
///   s[0]+256*s[1]+...+256^63*s[63] = s
///
/// Output:
///   s[0]+256*s[1]+...+256^31*s[31] = s mod l
///   where l = 2^252 + 27742317777372353535851937790883648493.
void ScReduce(Uint8List out, Uint8List s) {
  var s0 = BigInt.from(2097151) & load3(s.sublist(0, s.length));
  var s1 = BigInt.from(2097151) & (load4(s.sublist(2, s.length)) >> 5);
  var s2 = BigInt.from(2097151) & (load3(s.sublist(5, s.length)) >> 2);
  var s3 = BigInt.from(2097151) & (load4(s.sublist(7, s.length)) >> 7);
  var s4 = BigInt.from(2097151) & (load4(s.sublist(10, s.length)) >> 4);
  var s5 = BigInt.from(2097151) & (load3(s.sublist(13, s.length)) >> 1);
  var s6 = BigInt.from(2097151) & (load4(s.sublist(15, s.length)) >> 6);
  var s7 = BigInt.from(2097151) & (load3(s.sublist(18, s.length)) >> 3);
  var s8 = BigInt.from(2097151) & load3(s.sublist(21, s.length));
  var s9 = BigInt.from(2097151) & (load4(s.sublist(23, s.length)) >> 5);
  var s10 = BigInt.from(2097151) & (load3(s.sublist(26, s.length)) >> 2);
  var s11 = BigInt.from(2097151) & (load4(s.sublist(28, s.length)) >> 7);
  var s12 = BigInt.from(2097151) & (load4(s.sublist(31, s.length)) >> 4);
  var s13 = BigInt.from(2097151) & (load3(s.sublist(34, s.length)) >> 1);
  var s14 = BigInt.from(2097151) & (load4(s.sublist(36, s.length)) >> 6);
  var s15 = BigInt.from(2097151) & (load3(s.sublist(39, s.length)) >> 3);
  var s16 = BigInt.from(2097151) & load3(s.sublist(42, s.length));
  var s17 = BigInt.from(2097151) & (load4(s.sublist(44, s.length)) >> 5);
  var s18 = BigInt.from(2097151) & (load3(s.sublist(47, s.length)) >> 2);
  var s19 = BigInt.from(2097151) & (load4(s.sublist(49, s.length)) >> 7);
  var s20 = BigInt.from(2097151) & (load4(s.sublist(52, s.length)) >> 4);
  var s21 = BigInt.from(2097151) & (load3(s.sublist(55, s.length)) >> 1);
  var s22 = BigInt.from(2097151) & (load4(s.sublist(57, s.length)) >> 6);
  var s23 = (load4(s.sublist(60, s.length)) >> 3);

  s11 += s23 * BigInt.from(666643);
  s12 += s23 * BigInt.from(470296);
  s13 += s23 * BigInt.from(654183);
  s14 -= s23 * BigInt.from(997805);
  s15 += s23 * BigInt.from(136657);
  s16 -= s23 * BigInt.from(683901);
  s23 = BigInt.zero;

  s10 += s22 * BigInt.from(666643);
  s11 += s22 * BigInt.from(470296);
  s12 += s22 * BigInt.from(654183);
  s13 -= s22 * BigInt.from(997805);
  s14 += s22 * BigInt.from(136657);
  s15 -= s22 * BigInt.from(683901);
  s22 = BigInt.zero;

  s9 += s21 * BigInt.from(666643);
  s10 += s21 * BigInt.from(470296);
  s11 += s21 * BigInt.from(654183);
  s12 -= s21 * BigInt.from(997805);
  s13 += s21 * BigInt.from(136657);
  s14 -= s21 * BigInt.from(683901);
  s21 = BigInt.zero;

  s8 += s20 * BigInt.from(666643);
  s9 += s20 * BigInt.from(470296);
  s10 += s20 * BigInt.from(654183);
  s11 -= s20 * BigInt.from(997805);
  s12 += s20 * BigInt.from(136657);
  s13 -= s20 * BigInt.from(683901);
  s20 = BigInt.zero;

  s7 += s19 * BigInt.from(666643);
  s8 += s19 * BigInt.from(470296);
  s9 += s19 * BigInt.from(654183);
  s10 -= s19 * BigInt.from(997805);
  s11 += s19 * BigInt.from(136657);
  s12 -= s19 * BigInt.from(683901);
  s19 = BigInt.zero;

  s6 += s18 * BigInt.from(666643);
  s7 += s18 * BigInt.from(470296);
  s8 += s18 * BigInt.from(654183);
  s9 -= s18 * BigInt.from(997805);
  s10 += s18 * BigInt.from(136657);
  s11 -= s18 * BigInt.from(683901);
  s18 = BigInt.zero;

  var carry = List<BigInt>.filled(64, BigInt.zero);

  carry[6] = (s6 + BigInt.from(1 << 20)) >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[8] = (s8 + BigInt.from(1 << 20)) >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[10] = (s10 + BigInt.from(1 << 20)) >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;
  carry[12] = (s12 + BigInt.from(1 << 20)) >> 21;
  s13 += carry[12];
  s12 -= carry[12] << 21;
  carry[14] = (s14 + BigInt.from(1 << 20)) >> 21;
  s15 += carry[14];
  s14 -= carry[14] << 21;
  carry[16] = (s16 + BigInt.from(1 << 20)) >> 21;
  s17 += carry[16];
  s16 -= carry[16] << 21;

  carry[7] = (s7 + BigInt.from(1 << 20)) >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[9] = (s9 + BigInt.from(1 << 20)) >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[11] = (s11 + BigInt.from(1 << 20)) >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;
  carry[13] = (s13 + BigInt.from(1 << 20)) >> 21;
  s14 += carry[13];
  s13 -= carry[13] << 21;
  carry[15] = (s15 + BigInt.from(1 << 20)) >> 21;
  s16 += carry[15];
  s15 -= carry[15] << 21;

  s5 += s17 * BigInt.from(666643);
  s6 += s17 * BigInt.from(470296);
  s7 += s17 * BigInt.from(654183);
  s8 -= s17 * BigInt.from(997805);
  s9 += s17 * BigInt.from(136657);
  s10 -= s17 * BigInt.from(683901);
  s17 = BigInt.zero;

  s4 += s16 * BigInt.from(666643);
  s5 += s16 * BigInt.from(470296);
  s6 += s16 * BigInt.from(654183);
  s7 -= s16 * BigInt.from(997805);
  s8 += s16 * BigInt.from(136657);
  s9 -= s16 * BigInt.from(683901);
  s16 = BigInt.zero;

  s3 += s15 * BigInt.from(666643);
  s4 += s15 * BigInt.from(470296);
  s5 += s15 * BigInt.from(654183);
  s6 -= s15 * BigInt.from(997805);
  s7 += s15 * BigInt.from(136657);
  s8 -= s15 * BigInt.from(683901);
  s15 = BigInt.zero;

  s2 += s14 * BigInt.from(666643);
  s3 += s14 * BigInt.from(470296);
  s4 += s14 * BigInt.from(654183);
  s5 -= s14 * BigInt.from(997805);
  s6 += s14 * BigInt.from(136657);
  s7 -= s14 * BigInt.from(683901);
  s14 = BigInt.zero;

  s1 += s13 * BigInt.from(666643);
  s2 += s13 * BigInt.from(470296);
  s3 += s13 * BigInt.from(654183);
  s4 -= s13 * BigInt.from(997805);
  s5 += s13 * BigInt.from(136657);
  s6 -= s13 * BigInt.from(683901);
  s13 = BigInt.zero;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = (s0 + BigInt.from(1 << 20)) >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[2] = (s2 + BigInt.from(1 << 20)) >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[4] = (s4 + BigInt.from(1 << 20)) >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[6] = (s6 + BigInt.from(1 << 20)) >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[8] = (s8 + BigInt.from(1 << 20)) >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[10] = (s10 + BigInt.from(1 << 20)) >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;

  carry[1] = (s1 + BigInt.from(1 << 20)) >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[3] = (s3 + BigInt.from(1 << 20)) >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[5] = (s5 + BigInt.from(1 << 20)) >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[7] = (s7 + BigInt.from(1 << 20)) >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[9] = (s9 + BigInt.from(1 << 20)) >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[11] = (s11 + BigInt.from(1 << 20)) >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = s0 >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[1] = s1 >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[2] = s2 >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[3] = s3 >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[4] = s4 >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[5] = s5 >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[6] = s6 >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[7] = s7 >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[8] = s8 >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[9] = s9 >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[10] = s10 >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;
  carry[11] = s11 >> 21;
  s12 += carry[11];
  s11 -= carry[11] << 21;

  s0 += s12 * BigInt.from(666643);
  s1 += s12 * BigInt.from(470296);
  s2 += s12 * BigInt.from(654183);
  s3 -= s12 * BigInt.from(997805);
  s4 += s12 * BigInt.from(136657);
  s5 -= s12 * BigInt.from(683901);
  s12 = BigInt.zero;

  carry[0] = s0 >> 21;
  s1 += carry[0];
  s0 -= carry[0] << 21;
  carry[1] = s1 >> 21;
  s2 += carry[1];
  s1 -= carry[1] << 21;
  carry[2] = s2 >> 21;
  s3 += carry[2];
  s2 -= carry[2] << 21;
  carry[3] = s3 >> 21;
  s4 += carry[3];
  s3 -= carry[3] << 21;
  carry[4] = s4 >> 21;
  s5 += carry[4];
  s4 -= carry[4] << 21;
  carry[5] = s5 >> 21;
  s6 += carry[5];
  s5 -= carry[5] << 21;
  carry[6] = s6 >> 21;
  s7 += carry[6];
  s6 -= carry[6] << 21;
  carry[7] = s7 >> 21;
  s8 += carry[7];
  s7 -= carry[7] << 21;
  carry[8] = s8 >> 21;
  s9 += carry[8];
  s8 -= carry[8] << 21;
  carry[9] = s9 >> 21;
  s10 += carry[9];
  s9 -= carry[9] << 21;
  carry[10] = s10 >> 21;
  s11 += carry[10];
  s10 -= carry[10] << 21;

  out[0] = (s0 >> 0).toInt();
  out[1] = (s0 >> 8).toInt();
  out[2] = ((s0 >> 16) | (s1 << 5)).toInt();
  out[3] = (s1 >> 3).toInt();
  out[4] = (s1 >> 11).toInt();
  out[5] = ((s1 >> 19) | (s2 << 2)).toInt();
  out[6] = (s2 >> 6).toInt();
  out[7] = ((s2 >> 14) | (s3 << 7)).toInt();
  out[8] = (s3 >> 1).toInt();
  out[9] = (s3 >> 9).toInt();
  out[10] = ((s3 >> 17) | (s4 << 4)).toInt();
  out[11] = (s4 >> 4).toInt();
  out[12] = (s4 >> 12).toInt();
  out[13] = ((s4 >> 20) | (s5 << 1)).toInt();
  out[14] = (s5 >> 7).toInt();
  out[15] = ((s5 >> 15) | (s6 << 6)).toInt();
  out[16] = (s6 >> 2).toInt();
  out[17] = (s6 >> 10).toInt();
  out[18] = ((s6 >> 18) | (s7 << 3)).toInt();
  out[19] = (s7 >> 5).toInt();
  out[20] = (s7 >> 13).toInt();
  out[21] = (s8 >> 0).toInt();
  out[22] = (s8 >> 8).toInt();
  out[23] = ((s8 >> 16) | (s9 << 5)).toInt();
  out[24] = (s9 >> 3).toInt();
  out[25] = (s9 >> 11).toInt();
  out[26] = ((s9 >> 19) | (s10 << 2)).toInt();
  out[27] = (s10 >> 6).toInt();
  out[28] = ((s10 >> 14) | (s11 << 7)).toInt();
  out[29] = (s11 >> 1).toInt();
  out[30] = (s11 >> 9).toInt();
  out[31] = (s11 >> 17).toInt();
}

/// order is the order of Curve25519 in little-endian form.
var order = List<BigInt>.from(
  [
    BigInt.parse('0x5812631a5cf5d3ed'),
    BigInt.parse('0x14def9dea2f79cd6'),
    BigInt.zero,
    BigInt.parse('0x1000000000000000')
  ],
);

/// ScMinimal returns true if the given scalar is less than the order of the
/// curve.
bool ScMinimal(Uint8List scalar) {
  for (var i = 3;; i--) {
    // var v = binary.LittleEndian.Uint64(scalar[i*8:]);
    var v = Uint64(scalar.sublist(i * 8, scalar.length));
    if (v > order[i].toInt()) {
      return false;
    } else if (v < order[i].toInt()) {
      break;
    } else if (i == 0) {
      return false;
    }
  }

  return true;
}

int Uint64(Uint8List b) {
  return b[0] |
      b[1] << 8 |
      b[2] << 16 |
      b[3] << 24 |
      b[4] << 32 |
      b[5] << 40 |
      b[6] << 48 |
      b[7] << 56;
}
