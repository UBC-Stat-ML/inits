package blang.input.internals

import blang.inits.Arguments
import blang.input.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral

@Data
package class GlobalDependency implements InitDependency {
  val TypeLiteral<?> type
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    return creator.globals.get(type.rawType)
  }
}