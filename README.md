# Ed25519

Dart port of ed25519 from [Golang ed25519](https://github.com/golang/crypto/tree/master/ed25519)

This branch of code represents a capability used by dart2js. The benchmark shows that it performs about 22% slower than the [default implementation](https://github.com/Tougee/ed25519) when signing, and 30% to 60% slower when verifying.

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

#### JS (Dart2JS) benchmark
> $ pub get
> $ pub run benchmark/ed25519_benchmark.dart -p chrome

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 37.30 MB/s | 187 iterations | 5013 ms | 187.00 MB |
| Ed25519 - verify | 35.63 MB/s | 179 iterations | 5023 ms | 179.00 MB |


#### JiT (Dart VM) Benchmark


> $ pub get  
> $ pub run benchmark/ed25519_benchmark.dart

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 36.36 MB/s | 182 iterations | 5005 ms | 182.00 MB |
| Ed25519 - verify | 36.69 MB/s | 184 iterations | 5014 ms | 184.00 MB |

#### AoT (native binary)

> $ pub get  
> $ dart2native benchmark/ed25519_benchmark.dart -o ed25519_benchmark  
> $ ./ed25519_benchmark

| type |    rate    | iterations    |   time  | data throughput |
|----------|:----------:|---------------|:-------:|:---------------:|
| Ed25519 - sign | 18.57 MB/s | 93 iterations | 5009 ms | 93.00 MB |
| Ed25519 - verify | 22.42 MB/s | 113 iterations | 5039 ms | 113.00 MB |


[Pub package](https://pub.dev/packages/ed25519_edwards)
