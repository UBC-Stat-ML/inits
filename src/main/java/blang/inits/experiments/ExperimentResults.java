package blang.inits.experiments;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;

public class ExperimentResults
{
  public final File resultsFolder;
  private List<Writer> writers = new ArrayList<>();
  private List<ExperimentResults> children = new ArrayList<>();

  public ExperimentResults(File resultsFolder)
  {
    this.resultsFolder = resultsFolder;
  }
  
  public File getFileInResultFolder(String name)
  {
    return new File(resultsFolder, name);
  }
  
  /**
   * Recall: main difference between PrintWriter and BufferedWriter is that the former swallows exceptions.
   * 
   * @param name
   * @returnA PrintWriter which is automatically closed when acquired via Experiment.start(..)
   */
  public PrintWriter getAutoClosedPrintWriter(String name)
  {
    return new PrintWriter(getAutoClosedBufferedWriter(name));
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
  
  public ExperimentResults child(String childName)
  {
    File childFile = getFileInResultFolder(childName);
    ExperimentResults result = new ExperimentResults(childFile);
    children.add(result);
    return result;
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