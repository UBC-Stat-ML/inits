package blang.input.internals

import blang.inits.Arguments

package interface InitDependency {
  /**
   * return null if missing or error
   * (NOT optional, since it may be used by the user)
   */
  def Object resolve(CreatorImpl creator, Arguments currentArguments)
}