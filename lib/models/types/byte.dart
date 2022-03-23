class Byte {
  late int _value;

  Byte(int value) {
    setValue(value);
  }

  int get value {
    return _value;
  }

  void setValue(int v) {
    if (v >= 0) {
      _value = v % 256;
    } else {
      add(256);
    }
    
  }

  Byte add(int v) {
    setValue(_value + v);
    return this;
  }

  Byte sub(int v) {
    setValue(_value - v);
    return this;
  }

  @override
  bool operator ==(other) => other is Byte && (other.value == _value);

  @override
  int get hashCode => _value;
}
