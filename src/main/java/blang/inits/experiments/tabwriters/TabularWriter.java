package blang.inits.experiments.tabwriters;

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
  /**
   * Create a tabular writer when the provided (key, value) indices
   * are always assumed as prefix. 
   */
  TabularWriter child(Object key, Object value);
  
//  default void write(Object key, Object value) {
//    write(Pair.of(key, value));
//  }
  
  void write(Pair<?, ?> ... entries);
  
  int depth();
}
