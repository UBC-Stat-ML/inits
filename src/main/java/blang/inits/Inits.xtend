package blang.inits

import blang.inits.parsing.Arguments
import blang.inits.parsing.Posix

class Inits {
  
  def void parseAndRun(Class<Runnable> mainClass, String [] args) {
    parseAndRun(mainClass, Posix.parse(args))
  }
  
  def void parseAndRun(Class<Runnable> mainClass, Arguments arguments) {
    parseAndRun(mainClass, arguments, Creators::conventional)
  }
  
  def void parseAndRun(Class<Runnable> mainClass, Arguments arguments, Creator creator) {
    val Runnable result = try {
      creator.init(mainClass, arguments)
    } catch (Exception e) {
      System.err.println(creator.fullReport)
      return
    }
    if (arguments.childrenKeys.contains("help")) {
      println(creator.usage)
    } else {
      result.run
    }
  }
}