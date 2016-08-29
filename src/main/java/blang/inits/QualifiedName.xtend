package blang.inits

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import java.util.ArrayList
import com.google.common.base.Joiner
import org.eclipse.xtend.lib.annotations.Accessors

@Data // important to keep: used in hash maps
class QualifiedName {
  @Accessors(PUBLIC_GETTER)
  val List<String> path
  
  val static String SEPARATOR = '.'
  val static String ROOT_STRING = "<root>"
  
  def String simpleName() {
    if (isRoot()) {
      return ROOT_STRING
    } else {
      return path.get(path.size() - 1)
    }
  }
  
  def static QualifiedName root() {
    return new QualifiedName(new ArrayList)
  }
  
  def QualifiedName child(String name) {
    val List<String> newPath = new ArrayList(path)
    newPath += name
    return new QualifiedName(newPath)
  }
  
  def String toString(String rootString) {
    return 
      if (path.isEmpty) {
        rootString
      } else {
        Joiner.on(SEPARATOR).join(path)
      }
  }
  
  override String toString() {
    return toString(ROOT_STRING)
  }
  
  def isRoot() {
    return path.isEmpty
  }
  
}