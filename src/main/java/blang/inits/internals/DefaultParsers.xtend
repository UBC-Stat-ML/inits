package blang.inits.internals

import java.util.Random
import java.io.File
import java.nio.file.Path
import java.nio.file.Paths
import blang.inits.ProvidesFactory
import blang.inits.Input
import java.util.List
import blang.inits.InitService
import com.google.inject.TypeLiteral
import blang.inits.Creator
import java.util.ArrayList
import java.lang.reflect.ParameterizedType
import blang.inits.SimpleParser

package class DefaultParsers {
  
  @ProvidesFactory
  def static String parseString(@Input String s) {
    return s
  }
  
  @ProvidesFactory
  def static <T> List<T> parseList(
    @Input List<String> strings,
    @InitService TypeLiteral<List<T>> actualType,
    @InitService Creator creator
  ) {
    val TypeLiteral<T> typeArgument = 
      TypeLiteral.get((actualType.type as ParameterizedType).actualTypeArguments.get(0))
      as TypeLiteral<T>
    val List<T> result = new ArrayList
    for (String string : strings) {
      result.add(creator.init(typeArgument, SimpleParser.parse(string)))
    }
    return result
  }
  
  @ProvidesFactory
  def static Random parseRandom(@Input String s) {
    return new Random(parse_long(s))
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
  def static int parse_int(@Input String s) {
    if (s == INF_STR) return Integer.MAX_VALUE
    return Integer.parseInt(s)
  }
  
  @ProvidesFactory
  def static Integer parseInteger(@Input String s) {
    return parse_int(s)
  }
  
  @ProvidesFactory
  def static double parse_double(@Input String s) {
    if (s == INF_STR) return Double.POSITIVE_INFINITY
    return Double.parseDouble(s)
  }
  
  @ProvidesFactory
  def static Double parseDouble(@Input String s) {
    return parse_double(s)
  }
  
  @ProvidesFactory
  def static boolean parse_boolean(@Input String s) {
    if      (s == "true") return true
    else if (s == "false") return false
    else throw new RuntimeException("Could not parse as boolean: '" + s + "'; should be 'true' or 'false'")
  }
  
  @ProvidesFactory
  def static Boolean parseBoolean(@Input String s) {
    return parse_boolean(s)
  }
  
  @ProvidesFactory
  def static long parse_long(@Input String s) {
    if (s == INF_STR) return Long.MAX_VALUE
    return Long.parseLong(s)
  }
  
    @ProvidesFactory
  def static Long parseLong(@Input String s) {
    return parse_long(s)
  }

  val public static final String INF_STR = "INF"

}