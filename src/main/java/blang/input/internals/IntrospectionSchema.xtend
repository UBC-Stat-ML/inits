package blang.input.internals

import blang.input.internals.Schema
import com.google.inject.TypeLiteral
import java.lang.reflect.Constructor
import java.lang.reflect.Executable
import java.lang.reflect.Method
import java.lang.reflect.Parameter
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data
package class IntrospectionSchema implements Schema {
  val TypeLiteral<?> type
  val Executable builder
  
  override List<InitDependency> dependencies() {
    val List<InitDependency> result = new ArrayList
    val List<Parameter> parameters = builder.parameters
    val List<TypeLiteral<?>> parameterTypes = type.getParameterTypes(builder)
    for (var int i = 0; i < parameters.size; i++) {
      // create some function that takes into account whether it's a global, etc
      val InitDependency dep = InitStaticUtils::findDependency(parameterTypes.get(i), parameters.get(i))
      result.add(dep)
    }
    // TODO: add marked fields too? (1)
    return result
  }
  
  override Object build(List<Object> arguments) {
    // take a sublist of arg if need fields init (2)
    val Object [] argArray = arguments
    val Object result = switch (builder) {
      Constructor<?> : {
        builder.newInstance(argArray)
      }
      Method : {
        builder.invoke(null, argArray)
      }
      default : throw new RuntimeException
    }
    // init fields here (3)
    return result
  }
}