package blang.inits.internals

import blang.inits.parsing.Arguments

package interface InitDependency {
  /**
   * return null if missing or error
   * (NOT optional, since it may be used by the user)
   */
  def Object resolve(CreatorImpl creator, Arguments currentArguments)
}