package blang.inits

import org.junit.Test
import java.util.Optional
import blang.inits.parsing.Posix

class OptionalInputTest {
  
  static class MyClass {
    @Arg MyType t
  }
  static class MyType {
    @Input Optional<String> input
  }
  
  @Test
  def void test() {
    val Creator c = Creators::conventional
    val result = c.init(MyClass, Posix.parse())
    println(result.t.input) 
  }
  
}