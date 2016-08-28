package blang.input

import org.eclipse.xtend.lib.annotations.Data
import blang.inits.Arg
import blang.inits.PosixParser

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
    val Creator c = Creator.conventionalCreator()
    c.addGlobal(GlobalType, new GlobalType("I am global"))
    val result = c.init(TopLevel, PosixParser.parse())
    println(result.under.global)
  }
  
}