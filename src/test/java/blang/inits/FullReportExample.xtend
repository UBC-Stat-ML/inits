package blang.inits

import java.util.Optional
import blang.inits.parsing.Posix
import org.junit.Test
import org.junit.Assert

class FullReportExample {
  
  static class MyClass {
    
    @Arg(description = "blah blah") int test
    
    @Arg(description = "blah blah") Optional<Long> another
    
    @Arg Optional<String> thisOneMissing
    
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
  
  static class TwoThings {
    @Arg String first
    @Arg String second
  }
  
  static class Hierarchy {
    
    @Arg @DefaultValue("--first", "F", "--second", "S") TwoThings stuff
    
    @Arg String anotherOne
    
    @Arg @DefaultValue("blah") String andMore
    
    @DesignatedConstructor
    def static void test() {}
    
//    @DesignatedConstructor
//    def static void test2() {}
  }
  

  
  @Test
  def testFullReport() {
    val Creator c = Creators::conventional()
    try { c.init(MyClass, Posix.parse("--another", "23a", "--boo", "true", "--non", "asd")) } catch (Exception e) {}
    val actual =  println(c.fullReport())
    Assert.assertEquals(reference, actual)
  }
  
  val reference = '''
  #   <MyClass>
  # ! Did not instantiate <blang.inits.FullReportExample$MyClass> because of missing input
  
    --another 23a    # <Long> (optional)
  #   description: blah blah
  # ! Failed to build type <java.lang.Long>, possibly a parsing error
  #     input: 23a
  #     cause: NumberFormatException: For input string: "23a"
  
    --boo true    # <boolean>
  
  # --h.andMore <String> (default value: blah)
  
  # --h.anotherOne <String>
  # ! Did not instantiate <java.lang.String> because of missing input
  
  # --h.stuff.first <String> (parent h.stuff has default value: --first F --second S)
  
  # --h.stuff.second <String> (parent h.stuff has default value: --first F --second S)
  
  # --myEnum <MyEnum: EARTH|MARS|KOBZ>
  # ! Did not instantiate <blang.inits.FullReportExample$MyEnum> because of missing input
  
  # --n <Number: fully qualified>
  # ! The input should point to an implementation of java.lang.Number
  #     specified either with a fully qualified string
  
  # --test <int>
  #   description: blah blah
  # ! Did not instantiate <int> because of missing input
  
  # --thisOneMissing <String> (optional)
  
  ### Errors:
  
  #   error @ non
  # ! Unknown input
  '''
  
}