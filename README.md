# Ed25519

Dart port of ed25519 from [Golang ed25519](https://github.com/golang/crypto/tree/master/ed25519)

## Usage
```dart

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

    void signAndVerify() {
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
    }
```

## APIs
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

## Benchmark

Simulate from [pinenacl-dart Benchmark](https://github.com/ilap/pinenacl-dart/blob/master/benchmark/README.md)

MacBook Pro (16-inch, 2019), macOS Big Sur, with 2.4GHz i9 32GB

#### JiT (Dart VM) Benchmark


> $ pub get  
> $ pub run benchmark/ed25519_benchmark.dart

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 47.10 MB/s | 236 iterations | 5010 ms | 236.00 MB |
| Ed25519 - verify | 99.31 MB/s | 497 iterations | 5004 ms | 497.00 MB |

#### AoT (native binary)

> $ pub get  
> $ dart2native benchmark/ed25519_benchmark.dart -o ed25519_benchmark  
> $ ./ed25519_benchmark

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 21.96 MB/s | 110 iterations | 5008 ms | 110.00 MB |
| Ed25519 - verify | 43.10 MB/s | 216 iterations | 5012 ms | 216.00 MB |


[Pub package](https://pub.dev/packages/ed25519_edwards)
