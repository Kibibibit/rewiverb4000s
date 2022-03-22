

class Byte {

  late int _value;

  Byte(int value) {
    setValue(value);
  }

  int get value {return _value;}

  void setValue(int v) {
    _value = v % 256;
  }

  Byte add(int v) {
    setValue(_value + v);
    return this;
  }

  Byte sub(int v) {
    setValue(_value - v);
    return this;
  }

}