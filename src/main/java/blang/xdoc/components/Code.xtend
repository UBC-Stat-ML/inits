package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data

@Data
class Code {
  val Language language
  val String contents
  static enum Language { blang, java, sh, text, xtend }
}