package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

@Data
class Box extends DocElement {
  val String name
  
  new(String name, Procedure1<? extends Box> init) {
    super(init)
    this.name = name
  }
}