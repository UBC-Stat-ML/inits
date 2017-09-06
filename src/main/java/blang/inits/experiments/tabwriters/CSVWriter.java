package blang.inits.experiments.tabwriters;

import java.io.Writer;
import java.util.List;

public class CSVWriter extends AbstractTabularWriter<CSVWriter> 
{
  private final Writer out;
  private boolean wroteFirstLine = false;
  
  public CSVWriter(Writer out)
  {
    this(out, null, null, null);
  }

  private CSVWriter(Writer out, CSVWriter parent, Object key, Object value) 
  {
    super(parent, key, value);
    this.out = out;
  }

  @Override
  public CSVWriter child(Object key, Object value) 
  {
    return new CSVWriter(null, this, key, value);
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
}
