package blang.input.internals

import blang.inits.Arguments
import blang.input.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import java.util.List

@Data
package class InputDependency implements InitDependency {
  val boolean useList
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    if (!currentArguments.argumentValue.present) {
      return null
    }
    val List<String> list = currentArguments.argumentValue.get
    if (useList) {
      return list
    } else {
      return list.join(" ").trim
    }
  }
}