package blang.inits.internals

import blang.inits.Creator

class ExposedInternals {
  def static getDefault() {
    val Creator result = new CreatorImpl()
    DefaultParsers::setup(result)
    return result
  }
  def static getEmpty() { return new CreatorImpl() }
}