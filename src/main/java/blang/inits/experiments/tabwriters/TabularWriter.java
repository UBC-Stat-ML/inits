package blang.inits.experiments.tabwriters;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.xtext.xbase.lib.Pair;

/**
 * By tabular, we mean that all rows must be of the form
 * of an ordered list of (key, value) such that the list of 
 * keys is constant. These keys are named columns while each 
 * call of write(..) creates a row.
 * 
 * To get an instance:
 * 
 * - Add field "@GlobalArg ExperimentResults results;" to your class
 * - invoke results.getTabularWriter("a-table");
 */
public interface TabularWriter 
{
  String name();
  
  /**
   * Create a tabular writer when the provided (key, value) indices
   * are always assumed as prefix. 
   */
  TabularWriter child(Object key, Object value);
  
  void write(Pair<?, ?> ... entries);
  
  int depth();
  
  @SuppressWarnings({"unchecked", "rawtypes"})
  public default void printAndWrite(Pair ... pairs) 
  {
    List formatted = new ArrayList<>();
    formatted.addAll(Arrays.asList(name(), "["));
    for (Pair pair : pairs)
      formatted.add(pair);
    formatted.add("]");
    blang.System.out.formatln(formatted.toArray());
    write(pairs);
  }
}
