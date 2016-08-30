package blang.inits.internals

import blang.inits.parsing.Arguments
import com.google.inject.TypeLiteral
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Data

@Data
package class RecursiveDependency implements InitDependency {
  val TypeLiteral<?> type
  val String name
  val Optional<String> description
  
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    return creator._init(type, currentArguments.child(name))
  }
}