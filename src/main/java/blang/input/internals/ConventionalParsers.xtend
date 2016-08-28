package blang.input.internals

import java.util.List
import blang.input.Creator
import blang.input.Parser

package class ConventionalParsers {
  
  def static void setup(Creator c) {
    c.parsers => [
      put(String,  convert[it])
      
      put(Integer, convert(intParser))
      put(int,     convert(intParser))
      
      put(Double,  convert(doubleParser))
      put(double,  convert(doubleParser))
      
      put(Boolean, convert(booleanParser))
      put(boolean, convert(booleanParser))
      
      put(Long,    convert(longParser))
      put(long,    convert(longParser)) 
    ]
  }
  
  static interface ParserFromString {
    def Object parse(String string)
  }
  
  val public static final String INF_STR = "INF"
  val static ParserFromString intParser = [String s |
    if (s == INF_STR) return Integer.MAX_VALUE
    return Integer.parseInt(s)
  ]
  val static ParserFromString doubleParser = [String s |
    if (s == INF_STR) return Double.POSITIVE_INFINITY
    return Double.parseDouble(s)
  ]
  val static ParserFromString booleanParser = [String s |
    if      (s == "true") return true
    else if (s == "false") return false
    else throw new RuntimeException("Could not parse as boolean: '" + s + "'; should be 'true' or 'false'")
  ]
  val static ParserFromString longParser = [String s |
    if (s == INF_STR) return Long.MAX_VALUE
    return Long.parseLong(s)
  ]
  
  /**
   * Converts a ParserFromString into a Parser, by 
   * parsing the concatenation of the provided list of strings
   */
  def static Parser convert(ParserFromString p) {
    return [List<String> list | p.parse(list.join(" ").trim)]
  }
  
}