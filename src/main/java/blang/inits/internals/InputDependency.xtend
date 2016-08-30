package blang.inits.internals

import blang.inits.parsing.Arguments
import blang.inits.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import java.util.List
import java.util.Optional

@Data
package class InputDependency implements InitDependency {
  val boolean useList
  val boolean isOptional
  val String inputDescription
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    if (!currentArguments.argumentValue.present) {
      if (isOptional) {
        return Optional.empty
      } else {
        return null
      }
    }
    val List<String> list = currentArguments.argumentValue.get
    val Object object = if (useList) {
      list
    } else {
      list.join(" ").trim
    }
    if (isOptional) {
      return Optional.of(object)
    } else {
      return object
    }
  }
}