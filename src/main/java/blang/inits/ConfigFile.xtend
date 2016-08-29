package blang.inits

import java.util.ArrayList
import java.util.List
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.io.File

import static extension com.google.common.io.CharStreams.*
import java.io.FileReader

/**
 * A format very similar to the one read in Posix, but tailored at reading from 
 * a file instead of command line. The syntax is the same, with the exception of the 
 * addition of comments of the form "--key value # rest of the line ignored"
 */
class ConfigFile {
  
  def static Arguments parse(File f) {
    return parse(new FileReader(f).readLines())
  }
  
  def static Arguments parse(Iterable<String> lines) {
    val List<String> tokens = new ArrayList
    for (String line : lines) {
      tokens.addAll(tokenize(stripComments(line)))
    }
    return Posix.parse(tokens)
  }
  
  def private static String stripComments(String line) {
    val int commentSignIndex = line.indexOf(comment)
    if (commentSignIndex != -1) {
      return line.substring(0, commentSignIndex)
    } else {
      return line
    }
  }
  
  def private static List<String> tokenize(String lineWithoutComments) {
    val List<String> result = new ArrayList
    val Matcher regexMatcher = regex.matcher(lineWithoutComments)
    while (regexMatcher.find()) {
      val String current = regexMatcher.group().replace("\\ ", " ")
      val String processed = 
        if (current.length > 1 && current.charAt(0) == quote && current.charAt(current.length - 1) == quote) {
          current.substring(1, current.length - 1)
        } else {
          current
        }
      if (!processed.empty) {
        result.add(processed)
      }
    }
    return result
  }
  
  // Split by space, escaped using \ or ".."
  val static final Pattern regex = Pattern.compile( "(\"[^\"]*\"|'[^']*'|\\S+?(?:\\\\\\s+\\S*)+|\\S+)" )
  val static final char quote = '\"'
  val static final char comment = '#'

}