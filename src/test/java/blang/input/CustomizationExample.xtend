package blang.input

import org.eclipse.xtend.lib.annotations.Data
import blang.inits.DesignatedConstructor
import blang.inits.Input
import blang.inits.Arg
import blang.inits.PosixParser

class CustomizationExample {
  
  static class MyWeirdTypes {
    
    @Arg Temperature temperature
    
    @Arg MyEnum myEnum
     
  }
  
  static enum MyEnum {
    TARS, CASE
  }
  
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
  
  def static void main(String [] args) {
    val Creator creator = Creator.conventionalCreator()
    val MyWeirdTypes object = creator.init(
      MyWeirdTypes, 
      PosixParser.parse(
        "--temperature", "25K",
        "--myEnum", "CASE")
    )
    println(object.temperature)
    println(object.myEnum)
  }
  
}