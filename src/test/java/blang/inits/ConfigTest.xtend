package blang.inits

import org.eclipse.xtend.lib.annotations.Data
import org.junit.Test
import com.google.common.base.Splitter
import org.junit.Assert
import blang.inits.parsing.Posix
import blang.inits.parsing.ConfigFile

class ConfigTest {
  
  @Data
  static class MyTest {
    val int test
    val Inner inner 
    @DesignatedConstructor
    def static MyTest build(
      @ConstructorArg(value="test", description = "Some descr") int test,
      @ConstructorArg("inner") Inner inner
    ) {
      new MyTest(test, inner)
    }
  }
  
  @Data
  static class Inner {
    val String str
    @DesignatedConstructor
    def static Inner build(
      @ConstructorArg("str") String str
    ) {
      new Inner(str)
    }
  }
  
  @Test
  def void test() {
    println("ConfigTest")
    val Creator c = Creators::conventional()
    val MyTest o1 = c.init(MyTest, Posix.parse(
      "--test", "5",
      "--inner.str", "Baba!"
      ))
    val Iterable<String> lines = Splitter.on("\n").split(println(c.fullReport()))
    println(o1)
    println("###")
    val MyTest o2 = c.init(MyTest, ConfigFile.parse(lines))
    println(o2)
    Assert.assertEquals(o1, o2)
  }
  
}