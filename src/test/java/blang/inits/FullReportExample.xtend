package blang.inits

import java.util.Optional
import blang.inits.parsing.Posix

class FullReportExample {
  
  static class MyClass {
    
    @Arg(description = "blah blah") int test
    
    @Arg(description = "blah blah") Optional<Long> another
    
    @Arg Hierarchy h
    
    @Arg Number n 
    
    @Arg boolean boo
    
    @Arg MyEnum myEnum
    
    @DesignatedConstructor
    new(@Input String in) {
      
    }
    
  }
  
  static enum MyEnum {
    EARTH, MARS, KOBZ
  }
  
  static class Hierarchy {
    @Arg String anotherOne
    
    @DesignatedConstructor
    def static void test() {}
    
//    @DesignatedConstructor
//    def static void test2() {}
  }
  
  
  
  def static void main(String [] args) {
    val Creator c = Creators::conventional()
    try { c.init(MyClass, Posix.parse("--another", "23a", "--boo", "true", "--non", "asd")) } catch (Exception e) {}
    println(c.fullReport())
  }
  
}