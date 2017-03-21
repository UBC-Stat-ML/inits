package blang.inits

import blang.inits.parsing.Arguments
import blang.inits.parsing.Posix

class Inits {
  
  def static Runnable parseAndRun(Class<? extends Runnable> mainClass, String [] args) {
    return parseAndRun(mainClass, Posix.parse(args))
  }
  
  def static Runnable parseAndRun(Class<? extends Runnable> mainClass, Arguments arguments) {
    return parseAndRun(mainClass, arguments, Creators::conventional)
  }
  
  def static Runnable parseAndRun(Class<? extends Runnable> mainClass, Arguments arguments, Creator creator) {
    val Runnable result = try {
      creator.init(mainClass, arguments)
    } catch (Exception e) {
      if (arguments.childrenKeys.contains("help")) {
        println(creator.usage)
      } else {
        System.err.println(creator.fullReport)
      }
      return null
    }
    result.run
    return result
  }
}