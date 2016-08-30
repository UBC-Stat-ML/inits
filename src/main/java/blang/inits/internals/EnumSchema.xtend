package blang.inits.internals

import blang.inits.internals.Schema
import java.util.List
import java.util.Collections
import org.eclipse.xtend.lib.annotations.Data

@Data
class EnumSchema implements Schema {
  val Class<?> enumType
  
  override Object build(List<Object> arguments) {
    val String stringRep = arguments.get(0) as String
    return Enum.valueOf(enumType as Class<Enum>, stringRep)
  }
  
  override List<InitDependency>  dependencies() {
    val String description = enumType.enumConstants.map[toString].join("|")
    return Collections.singletonList(new InputDependency(false, false, description))
  }
}