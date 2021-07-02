import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart';

import 'rate_benchmark.dart';

class Ed25519Benchmark extends RateBenchmark {
  Ed25519Benchmark(bool forSigning, [int dataLength = 1024 * 1024])
      : _forSigning = forSigning,
        _data = Uint8List(dataLength),
        super('Ed25519 - ${forSigning ? 'sign' : 'verify'}');

  final Uint8List _data;
  final bool _forSigning;
  late final KeyPair _keyPair;
  Uint8List? _signature;

  @override
  void setup() {
    _keyPair = generateKey();
    _signature = sign(_keyPair.privateKey, _data);
  }

  @override
  void run() {
    if (_forSigning) {
      sign(_keyPair.privateKey, _data);
    } else if (_signature != null) {
      verify(_keyPair.publicKey, _data, _signature!);
    }
    addSample(_data.length);
  }
}

void main() {
  Ed25519Benchmark(true).report();
  Ed25519Benchmark(false).report();
}
