package blang.inits.internals

import blang.inits.Creator

class ExposedInternals {
  def static conventionalCreator() {
    val Creator result = new CreatorImpl()
    ConventionalParsers::setup(result)
    return result
  }
  def static bareBoneCreator() { return new CreatorImpl() }
}