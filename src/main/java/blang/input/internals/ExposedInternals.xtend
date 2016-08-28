package blang.input.internals

import blang.input.Creator

class ExposedInternals {
  def static conventionalCreator() {
    val Creator result = new CreatorImpl()
    ConventionalParsers::setup(result)
    return result
  }
  def static bareBoneCreator() { return new CreatorImpl() }
}