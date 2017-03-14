package blang.inits

import blang.inits.parsing.Posix

class DefaultTest {
  
  
  static class MyTest {
    
    @Arg(description = "some description") @DefaultValue("66")
    int test
    
    @Arg @DefaultValue("some input")
    CustomType t1
    
    @Arg @DefaultValue("--subArg", "true")
    ComplexType t2
  }
  
  static class CustomType {
    
    @DesignatedConstructor
    new(@Input(formatDescription = "anything!") String in) {
    }
    
  }
  
  static class ComplexType {
    
    @Arg 
    boolean subArg
    
  }
  
  def static void main(String [] args) {
    val Creator c = Creators::conventional
    val MyTest instance = try {
      c.init(MyTest, Posix.parse(
//        "--test", "123", 
//        "--t1", "blah", 
//        "--t2.subArg", "true"
        ))
    } catch (Exception e) {
      throw new RuntimeException(c.errorReport)
    }
//    println(instance.t2.subArg)
    println(c.usage)
    
  }
  
}