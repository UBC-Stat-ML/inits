package blang.xdoc.components

import org.eclipse.xtend.lib.annotations.Data

interface LinkTarget {
  
  def static LinkURL url(String url) {
    return new LinkURL(url)
  }
  
  @Data
  static class LinkURL implements LinkTarget {
    val String url
    override toString() { url }
  }
}