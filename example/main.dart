import 'dart:convert';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

void signAndVerify() {
  var keyPair = ed.generateKey();
  var privateKey = keyPair.privateKey;
  var publicKey = keyPair.publicKey;
  var message = utf8.encode('test message');
  var sig = ed.sign(privateKey, message);
  var result = ed.verify(publicKey, message, sig);
  assert(result == true);

  var wrongMessage = utf8.encode('wrong message');
  var wrongResult = ed.verify(publicKey, wrongMessage, sig);
  assert(wrongResult == false);
}