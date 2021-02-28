A Dart implementation of ed25519, inspired by [Go cryptography libraries](https://github.com/golang/crypto/tree/master/ed25519)

Usage
```dart

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

    void signAndVerify() {
      var keyPair = ed.generateKey();
        var privateKey = keyPair.privateKey!;
        var publicKey = keyPair.publicKey!;
        var message = utf8.encode('test message');
        var sig = ed.sign(privateKey, message as Uint8List);
        var result = ed.verify(publicKey, message, sig);
        assert(result == true);
      
        var wrongMessage = utf8.encode('wrong message');
        var wrongResult = ed.verify(publicKey, wrongMessage as Uint8List, sig);
        assert(wrongResult == false);
    }
```
| Ed25519 |
| :---: |
| public |
| seed |
| newKeyFromSeed |
| generateKey |
| sign |
| verify |

| Edwards25519 |
| :---: |
| FeZero |
| FeOne  |
| FeAdd |
| FeSub |
| FeCopy |
| FeCMove |
| FeFromBytes |
| FeToBytes |
| FeIsNegative |
| FeIsNonZero |
| FeNeg |
| FeCombine |
| FeMul |
| FeSqaure |
| FeSquare2 |
| FeInvert |
| GeDoubleScalarMultVartime |
| PreComputedGroupElementCMove |
| GeScalarMultBase |
| ScMulAdd |
| ScReduce |
| ScMinimal |

[Pub package](https://pub.dev/packages/ed25519_edwards)
