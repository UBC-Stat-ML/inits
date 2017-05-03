package blang.inits.parsing

import blang.inits.parsing.Arguments.ArgumentItem
import java.util.ArrayList
import java.util.List
import com.google.common.base.Splitter

/**
 * Read POSIX-style command line arguments.
 * 
 * Syntax: "<top level space value>* (--key(.subKey)* <value>*)*"
 * 
 * e.g:
 * 
 * blah blah --key.sub --key.another blah blah
 */
class Posix {
  
  def static Arguments parse(String ... args) {
    val List<ArgumentItem> items = new ArrayList
    
    var List<String> currentKey = new ArrayList // root
    var List<String> currentValue = new ArrayList
    
    for (String arg : args) {
      if (trim(arg).matches("[-][-].*")) {
        // process previous (unless it's the empty root)
        if (!currentKey.isEmpty || !currentValue.isEmpty) {
          items.add(new ArgumentItem(currentKey, currentValue))
        }
        // start next
        currentKey = readKey(trim(arg))
        currentValue = new ArrayList
      } else {
        currentValue += arg
      }
    }
    
    // don't forget to process last one too
    if (!currentKey.isEmpty || !currentValue.isEmpty) {
      items.add(new ArgumentItem(currentKey, currentValue))
    }
    
    return Arguments.parse(items)
  }
  
  def static String trim(String s) {
    var result = s.trim
    // handle cases like "\n--key .." which was found to arise frequently when 
    // pasting nextflow configs into eclipse 'run as'
    return result.replace("\n", "")
  }
  
  def static List<String> readKey(String string) {
    return Splitter.on(".").splitToList(string.replaceFirst("^[-][-]", ""))
  }
  
}