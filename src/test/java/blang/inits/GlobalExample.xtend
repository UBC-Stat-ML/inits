package blang.inits

import org.eclipse.xtend.lib.annotations.Data
import blang.inits.Arg
import blang.inits.PosixParser

/**
 * It is possible to add global objects which are accessible at all 
 * locations of the hierarchy. This is basically used to combine 
 * guice-style dependency injection.
 */
class GlobalExample {
  
  static class TopLevel {
    @Arg BotLevel under
  }
  
  static class BotLevel {
    @GlobalArg GlobalType global
  }
  
  @Data
  static class GlobalType {
    val String message
  }
  
  def static void main(String [] args) {
    val Creator c = Creators.conventional()
    c.addGlobal(GlobalType, new GlobalType("I am global"))
    val result = c.init(TopLevel, PosixParser.parse())
    println(result.under.global)
  }
  
}