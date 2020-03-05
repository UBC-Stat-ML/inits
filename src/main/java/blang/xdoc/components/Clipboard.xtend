package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data

@Data
class Clipboard {
  val String contents
  
  def String id() { "clip_" + Math::abs(hashCode) }
}