package blang.input.internals

import blang.inits.Arguments
import blang.input.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.input.InputExceptions
import blang.inits.QualifiedName
import java.lang.reflect.Type
import blang.input.InitService
import java.lang.reflect.AnnotatedElement

/**
 * 
 */
@Data
package class InitServiceDependency implements InitDependency {
  val TypeLiteral<?> parentType
  val TypeLiteral<?> childType
  val AnnotatedElement parameter
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    if (childType.rawType == QualifiedName) {
      return currentArguments.QName
    } else if (childType.rawType == TypeLiteral) {
      return parentType
    } else if (childType.rawType == Class) {
      return parentType.rawType
    } else if (childType.rawType == Type) {
      return parentType.type
    } else {
      throw InputExceptions::malformedAnnotation("Annotation @" + InitService.simpleName + " can only be applied to the following type: " +
        #[QualifiedName.simpleName, TypeLiteral.simpleName, Class.simpleName, Type.simpleName].join(", "), childType, parameter)
    }
  }
}