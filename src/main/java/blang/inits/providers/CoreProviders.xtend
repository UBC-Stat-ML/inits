package blang.inits.providers

import java.util.Random
import java.io.File
import java.nio.file.Path
import java.nio.file.Paths
import blang.inits.ProvidesFactory
import blang.inits.Input


class CoreProviders {
  
  @ProvidesFactory
  def static String parseString(@Input String s) {
    return s
  }
  
  @ProvidesFactory
  def static Character parseCharacter(@Input String s) {
    return new Character(parse_char(s))
  }
  
  @ProvidesFactory
  def static char parse_char(@Input String s) {
    val String trimmed = s.trim
    if (trimmed.length != 1) {
      throw new RuntimeException("This should be a single character: " + trimmed)
    }
    return s.charAt(0)
  }
  
  @ProvidesFactory
  def static Random parseRandom(@Input String s) {
    return new Random(parse_long(s))
  }
  
  @ProvidesFactory
  def static bayonet.distributions.Random parseBayonetRandom(@Input String s) {
    return new bayonet.distributions.Random(parse_long(s))
  }
  
  @ProvidesFactory
  def static File parseFile(@Input String s) {
    return new File(s)
  }
  
  @ProvidesFactory
  def static Path parsePath(@Input String s) {
    return Paths.get(s)
  }
  
  @ProvidesFactory
  def static int parse_int(@Input String _s) {
    val s = _s.trim.toLowerCase
    if (s == INF_STR) return Integer.MAX_VALUE
    try { return Integer.parseInt(s.replace("_", "")) }
    catch (Exception e) {
      // try for thing like 5e10 that look like doubles
      val double asDouble = Double.parseDouble(s)
      if ((asDouble == Math.floor(asDouble))) {
        return Math.floor(asDouble).intValue
      } else {
        throw new RuntimeException("Not an integer:" + s)
      }
    }
  }
  
  @ProvidesFactory
  def static Integer parseInteger(@Input String s) {
    return parse_int(s)
  }
  
  @ProvidesFactory
  def static double parse_double(@Input String _s) {
    val s = _s.trim.toLowerCase
    if (s == INF_STR) return Double.POSITIVE_INFINITY
    return Double.parseDouble(s.replace("_", ""))
  }
  
  @ProvidesFactory
  def static Double parseDouble(@Input String s) {
    return parse_double(s)
  }
  
  @ProvidesFactory
  def static boolean parse_boolean(@Input String _s) {
    val s = _s.trim.toLowerCase
    if      (s == "true") return true
    else if (s == "false") return false
    else throw new RuntimeException("Could not parse as boolean: '" + s + "'; should be 'true' or 'false'")
  }
  
  @ProvidesFactory
  def static Boolean parseBoolean(@Input String s) {
    return parse_boolean(s)
  }
  
  @ProvidesFactory
  def static long parse_long(@Input String _s) {
    val s = _s.trim.toLowerCase
    if (s == INF_STR) return Long.MAX_VALUE
    return Long.parseLong(s.replace("_", ""))
  }
  
  @ProvidesFactory
  def static Long parseLong(@Input String s) {
    return parse_long(s)
  }

  val public static final String INF_STR = "inf"
  
}