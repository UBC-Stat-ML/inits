package blang.inits.internals

import blang.inits.parsing.Arguments
import blang.inits.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.inits.InputExceptions
import blang.inits.parsing.QualifiedName
import blang.inits.InitService
import java.lang.reflect.AnnotatedElement
import blang.inits.Creator

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
    } else if (childType.rawType == Creator) {
      return CreatorWithPrefix::build(creator, currentArguments.QName)
    } else {
      throw InputExceptions::malformedAnnotation("Annotation @" + InitService.simpleName + " can only be applied to the following type: " +
        #[
          QualifiedName.simpleName, 
          TypeLiteral.simpleName,
          Creator.simpleName
        ].join(", "), childType, parameter)
    }
  }
}