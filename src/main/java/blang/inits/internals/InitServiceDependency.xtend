package blang.inits.internals

import blang.inits.Arguments
import blang.inits.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.inits.InputExceptions
import blang.inits.QualifiedName
import blang.inits.InitService
import java.lang.reflect.AnnotatedElement
import blang.inits.Creator
import org.eclipse.xtend.lib.annotations.Delegate

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
      val CreatorImpl result = new CreatorImpl()
      result.globals.putAll(creator.globals)
      result.factories.putAll(creator.factories)
      return new CreatorWithPrefix(result, currentArguments.QName)
    } else {
      throw InputExceptions::malformedAnnotation("Annotation @" + InitService.simpleName + " can only be applied to the following type: " +
        #[
          QualifiedName.simpleName, 
          TypeLiteral.simpleName,
          Creator.simpleName
        ].join(", "), childType, parameter)
    }
  }
  
  @Data
  static class CreatorWithPrefix implements Creator {
    @Delegate
    val Creator delegate
    
    val QualifiedName prefix
    
    override <T> T init(TypeLiteral<T> type, Arguments args) {
      return delegate.init(type, args.withQName(prefix))
    }
    
    override <T> T init(Class<T> type, Arguments args) {
      return delegate.init(type, args.withQName(prefix))
    }
  }
}