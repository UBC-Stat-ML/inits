package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data
import java.util.Map
import java.util.List

@Data
class Table {
  val List<Map<String,String>> rows
}