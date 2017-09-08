package blang.inits.experiments.tabwriters;

import java.io.Writer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import blang.inits.experiments.ExperimentResults;

/**
 * Hierarchical format used by spark, where prefixes of 
 * the form (key, value) are encoded as directories named
 * "key=value", recursively, until a leaf directory contains 
 * a csv file called "data.csv", in which all entries are 
 * prefixed by all parent "key=value" directories.
 *
 */
public class SparkWriter extends AbstractTabularWriter<SparkWriter>
{
  private final ExperimentResults result;
  private Writer out = null;
  private Map<Object, SparkWriter> children = new HashMap<>();
  
  public SparkWriter(ExperimentResults results)
  {
    this(results, null, null, null, 0);
  }

  public SparkWriter(ExperimentResults result, SparkWriter parent, Object key, Object value, int depth) {
    super(parent, key, value, depth);
    this.result = result;
  }

  @Override
  public SparkWriter child(Object key, Object value) 
  {
    if (children.containsKey(value))
      return children.get(value);
    SparkWriter child = new SparkWriter(result.child(key.toString(), value.toString()), this, key, value, depth() + 1); 
    children.put(value, child);
    return child;
  }

  @Override
  public void writeImplementation(List<Object> keys, List<Object> values, SparkWriter root) 
  {
    if (out == null)
    {
      out = result.getAutoClosedBufferedWriter(LEAF_CSV_NAME);
      root.lowLevelWrite(this.out, keys.subList(depth(), keys.size()));
    }
    root.lowLevelWrite(out, values.subList(depth(), values.size())); 
  }

  public static final String LEAF_CSV_NAME = "data.csv"; // Do not change, assumed by scala
}
