import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void main() {
  test('testSignVerify', () {
    var keyPair = ed.generateKey();
    var privateKey = keyPair.privateKey;
    var publicKey = keyPair.publicKey;
    var message = utf8.encode('test message');
    var sig = ed.sign(privateKey, message as Uint8List);
    var result = ed.verify(publicKey, message, sig);
    assert(result == true);

    var wrongMessage = utf8.encode('wrong message');
    var wrongResult = ed.verify(publicKey, wrongMessage as Uint8List, sig);
    assert(wrongResult == false);
  });

  /// sign.input.gz is a selection of test cases from
  /// https://ed25519.cr.yp.to/python/sign.input
  test('test sign.input.gz', () async {
    var path = 'test/testdata/sign.input.gz';
    var index = 0;
    await File(path)
        .openRead()
        .transform(gzip.decoder)
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((l) {
      index++;
      print('line index: $index');

      var parts = l.split(':');
      assert(parts.length == 5);

      var privBytes = HEX.decode(parts[0]);
      var pubkey = HEX.decode(parts[1]);
      var msg = HEX.decode(parts[2]);
      var sig = HEX.decode(parts[3]);
      sig = sig.sublist(0, ed.SignatureSize);
      assert(pubkey.length == ed.PublicKeySize);

      var privkey = privBytes.sublist(0, ed.PrivateKeySize);
      pubkey = privkey.sublist(32);

      var sig2 = ed.sign(ed.PrivateKey(privkey), msg as Uint8List);
      assert(ListEquality().equals(sig, sig2));

      var verified = ed.verify(ed.PublicKey(pubkey), msg, sig2);
      assert(verified);

      var priv2 = ed.newKeyFromSeed(privkey.sublist(0, 32) as Uint8List);
      assert(ListEquality().equals(privkey, priv2.bytes));

      var pubkey2 = ed.public(priv2);
      assert(ListEquality().equals(pubkey, pubkey2.bytes));

      var seed = ed.seed(priv2);
      assert(ListEquality().equals(seed, privkey.sublist(0, 32)));
    });
  });
}
