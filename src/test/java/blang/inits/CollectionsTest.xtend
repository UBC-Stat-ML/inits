package blang.inits

import org.junit.Test
import java.util.List
import blang.inits.parsing.Posix

class CollectionsTest {
  
  static class MyClass {
    @Arg List<Integer> numbers
  }
  
  @Test
  def void test(){
    val Creator c = Creators::conventional()
    try { println(c.init(MyClass, Posix.parse("--numbers", "1", "2", "3", "5")).numbers) } catch (Exception e) {}
    println(c.errorReport)
  }
  
}