package blang.inits

import blang.inits.parsing.Arguments
import blang.inits.parsing.Posix

class Inits {
  
  public val static String HELP_STRING = "help"
  
  def static <T extends Runnable> T parseAndRun(Class<T> mainClass, String [] args) {
    return parseAndRun(mainClass, Posix.parse(args))
  }
  
  def static <T extends Runnable> T parseAndRun(Class<T> mainClass, Arguments arguments) {
    return parseAndRun(mainClass, arguments, Creators::conventional)
  }
  
  def static <T extends Runnable> T parseAndRun(Class<T> mainClass, Arguments arguments, Creator creator) {
    val T result = try {
      creator.init(mainClass, arguments)
    } catch (Exception e) {
      if (arguments.childrenKeys.contains(HELP_STRING)) {
        System.out.println(creator.usage)
      } else {
        System.err.println(creator.fullReport)
      }
      return null
    }
    result.run
    return result
  }
}