package blang.inits

import blang.inits.internals.ExposedInternals

class Creators {
  
  /**
   * Creates a creator that knows how to parse conventional types such 
   * as primitives and things in java.lang (see blang.inits.internals.DefaultParsers).
   */
  def static Creator conventional() {
    return ExposedInternals::getDefault()
  }
  
}