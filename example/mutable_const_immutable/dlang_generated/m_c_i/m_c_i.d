module m_c_i.m_c_i;

import std.conv;
import std.stdio;

alias string[string] TextMap;
struct A {
  string[string] aArr;

  // custom <struct public A>
  
  // end <struct public A>

}

struct B {
  A a;

  // custom <struct public B>
  // end <struct public B>

}

struct C {
  B b;

  // custom <struct public C>

  public const {
    void show() {
      writeln(text("Contents: ", b));
    }

    void read() {
      writeln(text("Contents: ", b));
    }
  }

  // end <struct public C>

}


// custom <module public m_c_i>
void main() {
  auto c = immutable C(B(A([ "a":"b" ])));
  writeln(c);
  c.show();
  c.read();
}
// end <module public m_c_i>

version(unittest) {
  import specd.specd;
}
