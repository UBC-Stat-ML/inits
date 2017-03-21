package blang.inits.internals

import blang.inits.internals.Schema
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
import java.lang.reflect.Modifier
import blang.inits.InputExceptions
import briefj.ReflexionUtils

@Data
package class IntrospectionSchema implements Schema {
  val TypeLiteral<?> typeToBuild
  val TypeLiteral<?> typeDeclaringBuilder
  val Executable builder
  
  override List<InitDependency> dependencies() {
    val List<InitDependency> result = new ArrayList
    // parameters
    val List<Parameter> parameters = builder.parameters
    val List<TypeLiteral<?>> parameterTypes = typeDeclaringBuilder.getParameterTypes(builder)
    for (var int i = 0; i < parameters.size; i++) {
      result.add(InitStaticUtils::findDependency(typeToBuild, parameterTypes.get(i), parameters.get(i), Optional.empty))
    }
    // fields
    if (typeToBuild == typeDeclaringBuilder) {
      for (Field field : fieldsToInstantiate()) {
        result.add(InitStaticUtils::findDependency(typeToBuild, typeToBuild.getFieldType(field), field, Optional.of(field.name)))
      }
    }
    return result
  }
  
  def private List<Field> fieldsToInstantiate() {
    val List<Field> result = new ArrayList
    for (Class<? extends Annotation> annotationType : InitStaticUtils::possibleAnnotations) {
      for (Field field : ReflexionUtils::getAnnotatedDeclaredFields(typeToBuild.rawType, annotationType, true)) {
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
        if (!Modifier.isStatic(builder.modifiers)) {
          throw InputExceptions::nonStaticBuilder(typeDeclaringBuilder)
        }
        builder.invoke(null, argArray)
      }
      default : throw new RuntimeException
    }
    // init fields afterwards
    // TODO: check for finals? maybe ok
    var int index = nBuilderArgs
    for (Field field : fieldsToInstantiate()) {
      StaticUtils::setFieldValue(field, result, arguments.get(index++))
    }
    return result
  }
}