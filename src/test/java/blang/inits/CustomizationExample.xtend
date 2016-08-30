package blang.inits

import org.eclipse.xtend.lib.annotations.Data
import blang.inits.DesignatedConstructor
import blang.inits.Input
import blang.inits.Arg
import blang.inits.parsing.Posix

class CustomizationExample {
  
  static class MyWeirdTypes {
    @Arg Temperature temperature
    @Arg MyEnum myEnum
    @Arg OutOfControl outOfControl
  }
  
  // enums are supported automatically
  static enum MyEnum {
    TARS, CASE
  }
  
  /**
   * Example how to create custom parsing code for a type you are developing:
   */
  @Data
  static class Temperature {
    val String unit
    val double value
    
    @DesignatedConstructor
    def static Temperature parseTemperature(@Input String string) {
      return new Temperature(
        string.substring(string.length - 1, string.length),
        Double.parseDouble(string.substring(0, string.length - 1))
      )
    }
  }
  
  /**
   * Suppose now we have a class 'out of our control', i.e. where we cannot 
   * add the "@DesignatedConstructor" in it. 
   * See below in the main(..) method how this is handled.
   */
  @Data
  static class OutOfControl {
    val String string
  }
  
  static class CustomParsers {
    
    @ProvidesFactory
    def static OutOfControl parseOoC(@Input String input) {
      return new OutOfControl(input)
    }
  }
  
  def static void main(String [] args) {
    val Creator creator = Creators.conventional()
    creator.addFactories(CustomParsers)
    try {
    val MyWeirdTypes object = creator.init(
      MyWeirdTypes, 
      Posix.parse(
        "--temperature", "25K",
        "--myEnum", "CASE",
        "--outOfControl", "ok!")
    )
    println(object.temperature)
    println(object.myEnum)
    println(object.outOfControl) } catch (Exception e) {}
    println(creator.errorReport)
  }
  
}