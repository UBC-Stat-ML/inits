package blang.input.internals

import java.util.Collections
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import blang.input.ParserFromList

/**
   * A plan based on a single "@Input" SimpleDependency, 
   * passed to a parser
   */
 @Data
package class ParserSchema implements Schema {
  val ParserFromList parser
  override List<InitDependency> dependencies() {
    return Collections.singletonList(new InputDependency(true))
  }
  
  override Object build(List<Object> arguments) {
    return parser.parse(arguments.get(0) as List<String>)
  }
}