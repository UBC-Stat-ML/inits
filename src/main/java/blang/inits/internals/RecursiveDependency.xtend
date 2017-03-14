package blang.inits.internals

import blang.inits.parsing.Arguments
import com.google.inject.TypeLiteral
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Data
import blang.inits.InputExceptions

@Data
package class RecursiveDependency implements InitDependency {
  val TypeLiteral<?> type
  val String name
  val Optional<String> description
  val Optional<Arguments> defaultArguments
  
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    if (defaultArguments.isPresent && currentArguments.isNull) {
      val CreatorWithPrefix defaultCreator = CreatorWithPrefix::build(creator, currentArguments.QName.child(name))
      val Object instantiated = try {
        defaultCreator.init(type, defaultArguments.get)
      } catch (Exception e) {
        throw InputExceptions.faultyDefaultValue(defaultCreator.errorReport)
      }
      creator.logger.addAll(defaultCreator.delegate.logger)
      return instantiated
    }
    
    return creator._init(type, currentArguments.child(name))
  }
}