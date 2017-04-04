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
  val ParsedDefaults defaultArguments
  
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    if (defaultArguments.isRecursivePresent && currentArguments.child(name).isNull) {
      val CreatorWithPrefix defaultCreator = CreatorWithPrefix::build(creator, currentArguments.QName.child(name))
      val Object instantiated = try {
        defaultCreator.init(type, defaultArguments.arguments)
      } catch (Exception e) {
        throw InputExceptions.faultyDefaultValue(defaultCreator.errorReport)
      }
      creator.logger.addAll(defaultCreator.delegate.logger)
      return instantiated
    } else if (defaultArguments.isNonRecursivePresent && !currentArguments.child(name).argumentValue.isPresent) {
      return creator._init(type, currentArguments.child(name).withValue(defaultArguments.values))
    } else {
      return creator._init(type, currentArguments.child(name))
    }
  }
}