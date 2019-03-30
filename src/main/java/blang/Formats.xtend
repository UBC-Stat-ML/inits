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
  
  def dispatch String format(Double x) {
    if (x == 0.0)
      return "0.0"
    if (Math.abs(x) < 1e-3) // Scientific notation (close to 0)
      return String.format("%.2e", x)
    return String.format("%.3f", x);
  }
}