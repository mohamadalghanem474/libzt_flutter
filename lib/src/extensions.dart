import 'dart:typed_data';

extension BigIntEx on BigInt {
  int toIntBitwise() {
    if (this == BigInt.zero) {
      return 0;
    }
    var number = this;
    int byteCount = (number.bitLength + 7) >> 3;
    var b256 = BigInt.from(256);
    var result = Uint8List(byteCount);
    for (int i = 0; i < byteCount; i++) {
      result[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    if (result.length < 8) {
      var padded = Uint8List(8);
      padded.setRange(0, result.length, result);
      return padded.buffer.asInt64List().single;
    }
    return result.buffer.asInt64List().single;
  }
}

extension IntEx on int {
  BigInt toBigIntBitwise() {
    var bytes = Uint8List(8);
    bytes.buffer.asByteData().setInt64(0, this, Endian.big);
    BigInt resultValue = BigInt.zero;
    for (final byte in bytes) {
      resultValue = (resultValue << 8) | BigInt.from(byte & 0xff);
    }
    return resultValue;
  }
}
