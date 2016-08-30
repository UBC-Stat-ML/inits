package blang.inits

import blang.inits.internals.ExposedInternals
import blang.inits.providers.CoreProviders
import blang.inits.providers.CollectionsProviders

class Creators {
  
  /**
   * Creates a creator that knows how to parse conventional types such 
   * as primitives and things in java.lang (see blang.inits.internals.DefaultParsers).
   */
  def static Creator conventional() {
    val Creator c = ExposedInternals::empty
    c.addFactories(CoreProviders)
    c.addFactories(CollectionsProviders)
    return c
  }
  
}