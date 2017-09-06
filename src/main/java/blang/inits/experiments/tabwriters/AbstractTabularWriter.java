package blang.inits.experiments.tabwriters;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.xtext.xbase.lib.Pair;

import com.google.common.base.Joiner;

abstract class AbstractTabularWriter<T extends AbstractTabularWriter<T>> implements TabularWriter
{
  private final int depth;
  
  // block 1: root
  protected List<Object> referenceKeys = null; // null only until a first write is done
  
  // block 2: non-root
  protected final T parent;
  protected final Object key;
  protected final Object value;
  
  public AbstractTabularWriter(T parent, Object key, Object value, int depth) {
    this.parent = parent;
    this.key = key;
    this.value = value;
    this.depth = depth;
  }

  @Override
  public void write(Object key, Object value) 
  {
    write(Pair.of(key, value));
  }
  
  @Override
  public void write(Pair<?, ?>... entries) {
    // prepare the string to be written 
    List<Object> 
      values = new ArrayList<>(),
      keys = new ArrayList<>();
    @SuppressWarnings("unchecked")
    T writer = (T) this; 
    loop : while (true)
      if (writer.parent == null)
        break loop;
      else 
      {
        values.add(writer.value);
        keys.add(writer.key);
        writer = writer.parent;
      }
    Collections.reverse(values);
    Collections.reverse(keys);
    for (Pair<?,?> entry : entries)
    {
      keys.add(entry.getKey());
      values.add(entry.getValue());
    }
    
    if (writer.referenceKeys == null)
      writer.referenceKeys = keys;
    else if (!writer.referenceKeys.equals(keys))
      throw new RuntimeException("Set of keys inconsistent with a tabular format: " + writer.referenceKeys + " vs " + keys);
    writeImplementation(keys, values, writer);
  }
  
  protected void lowLevelWrite(Writer out, List<Object> strings) 
  {
    try 
    {
      // TODO: add option to process for quotations etc (via briefj's CSV for example)
      out.append(Joiner.on(",").join(strings) + "\n");
    } catch (IOException e) {
      throw new RuntimeException();
    }
  }
  
  public int depth() { return depth; }
  
  public abstract void writeImplementation(List<Object> keys, List<Object> values, T root);
}
