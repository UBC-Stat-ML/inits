package blang.input.internals

import blang.inits.Arguments
import blang.input.internals.CreatorImpl
import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.input.InputExceptions
import blang.inits.QualifiedName
import blang.input.InitService
import java.lang.reflect.AnnotatedElement
import blang.input.Creator
import blang.input.ParserFromList

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
      result.parsersIndexedByRawTypes.putAll(creator.parsersIndexedByRawTypes)
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
    val Creator delegate
    val QualifiedName prefix
    
    override <T> addParser(Class<T> type, ParserFromList<T> parser) {
      delegate.addParser(type, parser)
    }
    
    override <T> addGlobal(Class<T> type, T object) {
      delegate.addGlobal(type, object)
    }
    
    override <T> T init(TypeLiteral<T> type, Arguments args) {
      return delegate.init(type, args.withQName(prefix))
    }
    
    override <T> T init(Class<T> type, Arguments args) {
      return delegate.init(type, args.withQName(prefix))
    }
    
    override usage() {
      return delegate.usage()
    }
    
    override errorReport() {
      return delegate.errorReport()
    }
    
    override errors() {
      return delegate.errors()
    }
  }
}