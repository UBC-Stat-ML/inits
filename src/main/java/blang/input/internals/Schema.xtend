package blang.input.internals

import java.util.List

/**
 * A plan to create instances of a class
 */
interface Schema {
  def Object build(List<Object> arguments)
  def List<InitDependency> dependencies()
}