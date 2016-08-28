package blang.input.internals

import java.util.List

interface Parser {
  def Object parse(List<String> inputs)
}