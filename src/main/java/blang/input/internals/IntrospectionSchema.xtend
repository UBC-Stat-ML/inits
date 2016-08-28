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
import java.lang.reflect.Field
import java.util.Optional
import java.lang.annotation.Annotation
import ca.ubc.stat.blang.StaticUtils

@Data
package class IntrospectionSchema implements Schema {
  val TypeLiteral<?> type
  val Executable builder
  
  override List<InitDependency> dependencies() {
    val List<InitDependency> result = new ArrayList
    // parameters
    val List<Parameter> parameters = builder.parameters
    val List<TypeLiteral<?>> parameterTypes = type.getParameterTypes(builder)
    for (var int i = 0; i < parameters.size; i++) {
      result.add(InitStaticUtils::findDependency(parameterTypes.get(i), parameters.get(i), Optional.empty))
    }
    // fields
    for (Field field : fieldsToInstantiate()) {
      result.add(InitStaticUtils::findDependency(type.getFieldType(field), field, Optional.of(field.name)))
    }
    return result
  }
  
  def private List<Field> fieldsToInstantiate() {
    val List<Field> result = new ArrayList
    for (Class<? extends Annotation> annotationType : InitStaticUtils::possibleAnnotations) {
      for (Field field : type.rawType.fields.filter[it.getAnnotation(annotationType) !== null]) {
        result.add(field)
      }
    }
    return result
  }
  
  override Object build(List<Object> arguments) {
    // take a sublist of arg if need fields init (2)
    val int nBuilderArgs = builder.parameters.size
    val Object [] argArray = arguments.subList(0, nBuilderArgs)
    val Object result = switch (builder) {
      Constructor<?> : {
        builder.newInstance(argArray)
      }
      Method : {
        builder.invoke(null, argArray)
      }
      default : throw new RuntimeException
    }
    // init fields afterwards
    // TODO: check for finals
    var int index = nBuilderArgs
    for (Field field : fieldsToInstantiate()) {
      StaticUtils::setFieldValue(field, result, arguments.get(index++))
    }
    return result
  }
}