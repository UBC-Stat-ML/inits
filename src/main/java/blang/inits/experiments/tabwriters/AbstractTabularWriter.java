package blang.inits.experiments.tabwriters;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.xtext.xbase.lib.Pair;

import com.google.common.base.Joiner;

import briefj.BriefIO;
import briefj.CSV;

abstract class AbstractTabularWriter<T extends AbstractTabularWriter<T>> implements TabularWriter
{
  public final String name;
  
  private final int depth;
  
  // block 1: root
  protected List<Object> referenceKeys = null; // null only until a first write is done
  private File descriptionFile; // null when not wanted/already done
  
  // block 2: non-root
  protected final T parent;
  protected final Object key;
  protected final Object value;
  
  public AbstractTabularWriter(String name, T parent, Object key, Object value, int depth, File descriptionFile) {
    this.name = name;
    this.parent = parent;
    this.key = key;
    this.value = value;
    this.depth = depth;
    this.descriptionFile = descriptionFile;
  }
  
  @Override
  public String name() 
  {
    return name;
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
    writer.writeDescription(keys, values);
  }
  
  protected void writeDescription(List<Object> keys, List<Object> values) 
  {
    if (descriptionFile == null)
      return;
    List<String> description = new ArrayList<>();
    for (int i = 0; i < keys.size(); i++) 
      description.add(keys.get(i) + "\t" + values.get(i).getClass().getTypeName());
    BriefIO.write(descriptionFile, Joiner.on("\n").join(description));
    descriptionFile = null; // signal that the job is done
  }

  protected void lowLevelWrite(Writer out, List<Object> strings) 
  {
    try 
    {
      out.append(CSV.toCSV(strings) + "\n");
    } 
    catch (IOException e) 
    {
      throw new RuntimeException();
    }
  }
  
  public int depth() { return depth; }
  
  public abstract void writeImplementation(List<Object> keys, List<Object> values, T root);
}
