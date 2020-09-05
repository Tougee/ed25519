A Dart implementation of ed25519, inspired by [Go cryptography libraries](https://github.com/golang/crypto/tree/master/ed25519)

Usage
```dart
    test('testSignVerify', () {
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
      });
```

| Exports |
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
