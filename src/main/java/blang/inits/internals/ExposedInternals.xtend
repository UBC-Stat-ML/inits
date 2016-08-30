package blang.inits.internals

import blang.inits.Creator

class ExposedInternals {
  def static Creator getEmpty() { 
    return new CreatorImpl()
  }
}