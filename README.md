# Ed25519

Dart port of ed25519 from [Golang ed25519](https://github.com/golang/crypto/tree/master/ed25519)


[Pub package](https://pub.dev/packages/ed25519_edwards)

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

> dart test test/benchmark/ed25519_benchmark.dart

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 50.54 MB/s | 254 iterations | 5025 ms | 254.00 MB |
| Ed25519 - verify | 97.38 MB/s | 487 iterations | 5001 ms | 487.00 MB |

#### AoT (native binary)

> dart2native test/benchmark/ed25519_benchmark.dart -o ed25519_benchmark  
> ./ed25519_benchmark

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 21.64 MB/s | 109 iterations | 5036 ms | 109.00 MB |
| Ed25519 - verify | 37.20 MB/s | 187 iterations | 5027 ms | 187.00 MB |

#### JS (Dart2JS) benchmark (too slow, suggest using other libs for dart2js and flutter web)

> dart test test/benchmark/ed25519_benchmark.dart -p chrome

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 797.03 KB/s | 4 iterations | 5139 ms | 4.00 MB |
| Ed25519 - verify | 1.53 MB/s | 8 iterations | 5231 ms | 8.00 MB |

