package blang.inits.internals

import blang.inits.Creator

class ExposedInternals {
  def static getDefault() {
    val Creator result = new CreatorImpl()
    result.addFactories(DefaultParsers)
    return result
  } 
  def static getEmpty() { return new CreatorImpl() }
}