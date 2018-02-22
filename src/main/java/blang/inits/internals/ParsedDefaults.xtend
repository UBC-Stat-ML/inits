package blang.inits.internals

import blang.inits.parsing.Arguments
import org.eclipse.xtend.lib.annotations.Data
import java.util.List

@Data
class ParsedDefaults {
  
  val Arguments arguments
  val List<String> values
  
  def static ParsedDefaults createRecursive(Arguments arguments) {
    return new ParsedDefaults(arguments, null)
  }
  
  def static ParsedDefaults createNonRecursive(List<String> values) {
    return new ParsedDefaults(null, values)
  }
  
  def static ParsedDefaults createEmpty() {
    return new ParsedDefaults(null, null)
  }
  
  private new(Arguments args, List<String> values) {
    this.arguments = args
    this.values = values
  }
  
  def isRecursivePresent() {
    return arguments !== null
  }
  
  def isNonRecursivePresent() {
    return values !== null
  }
  
  def isPresent() {
    return arguments !== null || values !== null
  }
  
  def isRecursive() {
    if (!isPresent()) {
      throw new RuntimeException
    }
    return arguments !== null
  }
  
  override String toString() {
    if (!isPresent) {
      return ""
    }
    if (isRecursive) {
      return arguments.toString
    } else {
      return values.join(" ")
    }
    
  }
  
}