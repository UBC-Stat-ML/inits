package blang.inits.experiments;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;

import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.factories.CSV;

public class ExperimentResults
{
  public final File resultsFolder;
  private final TabularWriterFactory defaultTabularWriterFactory;
  
  private List<Writer> writers = new ArrayList<>();
  private List<ExperimentResults> children = new ArrayList<>();

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
  
  /**
   * @param name
   * @return A BufferedWriter which is automatically closed when acquired via Experiment.start(..)
   */
  public BufferedWriter getAutoClosedBufferedWriter(String name)
  {
    try
    {
      BufferedWriter writer = new BufferedWriter(new FileWriter(getFileInResultFolder(name)));
      writers.add(writer);
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
  public PrintWriter getAutoClosedPrintWriter(String name)
  {
    return new PrintWriter(getAutoClosedBufferedWriter(name));
  }
  
  public ExperimentResults child(String childName)
  {
    File childFile = getFileInResultFolder(childName);
    ExperimentResults result = new ExperimentResults(childFile, this.defaultTabularWriterFactory);
    children.add(result);
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
  
  public TabularWriter getTabularWriter(String name)
  {
    return getTabularWriter(name, defaultTabularWriterFactory);
  }
  
  public TabularWriter getTabularWriter(String name, TabularWriterFactory factory)
  {
    return factory.build(this, name);
  }
  
  // called by Experiment.start(..)
  void closeAll()
  {
    for (Writer writer : writers)
      try
      {
        writer.close();
      } 
      catch (IOException e)
      {
        e.printStackTrace();
      }
    for (ExperimentResults child : children)
      child.closeAll();
  }
}