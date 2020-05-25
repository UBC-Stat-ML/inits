package blang.inits.experiments.tabwriters.factories;

import java.io.File;

import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.CSVWriter;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.TidySerializer;

public class CSV implements TabularWriterFactory
{
  @Arg         @DefaultValue("false")
  public boolean compressed = false;
  
  @Override
  public TabularWriter build(ExperimentResults root, String name) 
  {
    if (name.endsWith(".csv")) 
      throw new RuntimeException("Names of TabularWriter should not include the .csv suffix");
    File descriptionFile = TidySerializer.descriptionFile(root.resultsFolder, name);
    return new CSVWriter(name, root.getAutoClosedBufferedWriter(name + ".csv" + (compressed ? ".gz" : "")), descriptionFile); 
  }
  
  /**
   * Use when a file was created using a TabularWriterFactory so 
   * we are not sure if the file has a .gz extension.
   * 
   * First see directory/[name].csv if exists, if so return that.
   * Then try directory/[name].csv.gz and null otherwise
   */
  public static File csvFile(File directory, String name) 
  {
    {
      File nameDotCSV = new File(directory, name + ".csv");
      if (nameDotCSV.exists()) return nameDotCSV;
    }
    {
      File nameDotCSVDotGz = new File(directory, name + ".csv.gz");
      if (nameDotCSVDotGz.exists()) return nameDotCSVDotGz;
    }
    return null;
  }
}
