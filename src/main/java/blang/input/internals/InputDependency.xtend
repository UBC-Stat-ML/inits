package blang.input.internals

import blang.inits.Arguments
import blang.input.internals.CreatorImpl

package class InputDependency implements InitDependency {
  // val boolean optional
  // TODO: later, optional input so that we can have Optional<List<String>>
  // TODO: later, allow also String, Optional<String>
  override Object resolve(CreatorImpl creator, Arguments currentArguments) {
    // TODO: report parsing error if missing
    currentArguments.argumentValue.orElse(null)
  }
  
}