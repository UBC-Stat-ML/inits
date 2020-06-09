package blang.inits.experiments.tabwriters;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.util.List;

public class CSVWriter extends AbstractTabularWriter<CSVWriter> 
{
  private final Writer out;
  private boolean wroteFirstLine = false;
  
  public CSVWriter(String name, Writer out, File descriptionFile)
  {
    this(name, out, null, null, null, 0, descriptionFile);
  }

  private CSVWriter(String name, Writer out, CSVWriter parent, Object key, Object value, int depth, File descriptionFile) 
  {
    super(name, parent, key, value, depth, descriptionFile);
    this.out = out;
  }

  @Override
  public CSVWriter child(Object key, Object value) 
  {
    return new CSVWriter(name, null, this, key, value, depth() + 1, null);
  }

  @Override
  public void writeImplementation(List<Object> keys, List<Object> values, CSVWriter root) 
  { 
    if (!root.wroteFirstLine)
    {
      root.lowLevelWrite(root.out, keys);
      root.wroteFirstLine = true;
    }
    root.lowLevelWrite(root.out, values);
  }

  @Override
  public void close() {
    try {
      out.close();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  @Override
  public void flush() {
    try {
      out.flush();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }
}
