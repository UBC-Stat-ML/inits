package blang.inits

import java.util.List

interface ParserFromList<T> {
  def T parse(List<String> inputs)
}