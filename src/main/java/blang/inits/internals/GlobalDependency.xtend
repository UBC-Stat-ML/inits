package blang.inits.internals

import blang.inits.Arguments
import blang.inits.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.inits.InputExceptions

@Data
/**
 * Note: we do not want to use RecursionDep here because it makes no sense 
 * to recurse the argument.
 */
package class GlobalDependency implements InitDependency {
  val TypeLiteral<?> type
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    val Object result = creator.globals.get(type.rawType)
    if (result === null) {
      throw InputExceptions::missingGlobal(type)
    }
    return result
  }
}