import 'dart:convert';

import 'package:ed25519_edwards/ed25519_edwards.dart';

void signAndVerify() {
  var keyPair = generateKey();
  var privateKey = keyPair.privateKey;
  var publicKey = keyPair.publicKey;
  var message = utf8.encode('test message');
  var sig = sign(privateKey, message);
  var result = verify(publicKey, message, sig);
  assert(result == true);

  var wrongMessage = utf8.encode('wrong message');
  var wrongResult = verify(publicKey, wrongMessage, sig);
  assert(wrongResult == false);
}