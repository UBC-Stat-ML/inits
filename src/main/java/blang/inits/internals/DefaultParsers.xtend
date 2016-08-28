package blang.inits.internals

import blang.inits.Creator
import java.util.Random
import java.io.File
import java.nio.file.Path
import java.nio.file.Paths
import blang.inits.Parser

package class DefaultParsers {
  
  def static void setup(Creator c) {
    c => [
      addParser(String, [it])
      
      addParser(Integer, intParser)
      addParser(int,     intParser)
      
      addParser(Double,  doubleParser)
      addParser(double,  doubleParser)
      
      addParser(Boolean, booleanParser)
      addParser(boolean, booleanParser)
      
      addParser(Long,    longParser)
      addParser(long,    longParser)
      
      addParser(Random,  [String input | new Random(Long.parseLong(input))])
      addParser(File,    [String input | new File(input)])
      addParser(Path,    [String input | Paths.get(input)])
    ]
  }
  
  val public static final String INF_STR = "INF"
  val static Parser<Integer> intParser = [String s |
    if (s == INF_STR) return Integer.MAX_VALUE
    return Integer.parseInt(s)
  ]
  val static Parser<Double> doubleParser = [String s |
    if (s == INF_STR) return Double.POSITIVE_INFINITY
    return Double.parseDouble(s)
  ]
  val static Parser<Boolean> booleanParser = [String s |
    if      (s == "true") return true
    else if (s == "false") return false
    else throw new RuntimeException("Could not parse as boolean: '" + s + "'; should be 'true' or 'false'")
  ]
  val static Parser<Long> longParser = [String s |
    if (s == INF_STR) return Long.MAX_VALUE
    return Long.parseLong(s)
  ]
}