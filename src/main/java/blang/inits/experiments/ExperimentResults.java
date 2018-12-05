package blang.inits.experiments;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.LinkedHashMap;
import java.util.Map;

import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.factories.CSV;

public class ExperimentResults
{
  public final File resultsFolder;
  private final TabularWriterFactory defaultTabularWriterFactory;
  
  public ExperimentResults()
  {
    this(new File("."));
  }
  
  public ExperimentResults(File resultsFolder)
  {
    this(resultsFolder, new CSV());
  }
  
  public ExperimentResults(File resultsFolder, TabularWriterFactory defaultTabularWriterFactory)
  {
    resultsFolder.mkdirs();
    this.resultsFolder = resultsFolder;
    this.defaultTabularWriterFactory = defaultTabularWriterFactory;
  }
  
  public File getFileInResultFolder(String name)
  {
    return new File(resultsFolder, name);
  }
  
  private Map<String,BufferedWriter> writers = new LinkedHashMap<>();

  /**
   * @param name
   * @return A BufferedWriter which is automatically closed when acquired via Experiment.start(..)
   */
  public BufferedWriter getAutoClosedBufferedWriter(String name)
  {
    if (writers.containsKey(name))
      return writers.get(name);
    try
    {
      BufferedWriter writer = new BufferedWriter(new FileWriter(getFileInResultFolder(name)));
      writers.put(name, writer);
      return writer;
    } 
    catch (IOException e)
    {
      throw new RuntimeException(e);
    }
  }
  
  /**
   * Discouraged except for quick prototyping.
   * 
   * Recall: main difference between PrintWriter and BufferedWriter is that the former swallows exceptions.
   * 
   * @param name
   * @returnA PrintWriter which is automatically closed when acquired via Experiment.start(..)
   */
  @Deprecated
  public PrintWriter getAutoClosedPrintWriter(String name)
  {
    return new PrintWriter(getAutoClosedBufferedWriter(name));
  }
  
  private Map<String, ExperimentResults> children = new LinkedHashMap<>();
  public ExperimentResults child(String childName)
  {
    if (children.containsKey(childName))
      return children.get(childName);
    File childFile = getFileInResultFolder(childName);
    ExperimentResults result = new ExperimentResults(childFile, this.defaultTabularWriterFactory);
    children.put(childName, result);
    return result;
  }
  
  public ExperimentResults child(String key, String value)
  {
    return child(key + "=" + value);
  }
  
  public ExperimentResults child(String key, Number value)
  {
    return child(key + "=" + value);
  }
  
  private Map<String, TabularWriter> tabularWriters = new LinkedHashMap<>();
  public TabularWriter getTabularWriter(String name)
  {
    return getTabularWriter(name, defaultTabularWriterFactory);
  }
  
  public TabularWriter getTabularWriter(String name, TabularWriterFactory factory)
  {
    if (tabularWriters.containsKey(name))
      return tabularWriters.get(name);
    TabularWriter result = factory.build(this, name);
    tabularWriters.put(name, result);
    return result;
  }
  
  // called by Experiment.start(..), but in certain scenarios might have to call manually, 
  // e.g. if calling programmatically an Experiment
  public void closeAll()
  {
    for (Writer writer : writers.values())
      try
      {
        writer.close();
      } 
      catch (IOException e)
      {
        e.printStackTrace();
      }
    for (ExperimentResults child : children.values())
      child.closeAll();
  }
}