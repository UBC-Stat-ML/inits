package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data
import java.io.File

@Data
class Embed {
  val File file
  def width() { "100%" }
  def height() { "450px" }
  def title() { file.name }
}
