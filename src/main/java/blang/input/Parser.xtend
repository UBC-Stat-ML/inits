package blang.input

import java.util.List

interface Parser {
  def Object parse(List<String> inputs)
}