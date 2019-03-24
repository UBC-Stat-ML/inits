package blang

import com.google.common.base.Stopwatch

class Formats {
  
  def dispatch String format(Object o) {
    return o.toString
  }
  
  def dispatch String format(Pair<?,?> pair) {
    return format(pair.key) + "=" + format(pair.value)
  }
  
  def dispatch String format(Stopwatch watch) {
    return watch.toString.replace(" ", "")
  }
}