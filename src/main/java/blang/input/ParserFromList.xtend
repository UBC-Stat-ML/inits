package blang.input

import java.util.List

interface ParserFromList<T> {
  def T parse(List<String> inputs)
}