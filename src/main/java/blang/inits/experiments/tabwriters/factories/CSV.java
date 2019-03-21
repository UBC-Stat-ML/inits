package blang.inits.experiments.tabwriters.factories;

import java.io.File;

import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.CSVWriter;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.TidySerializer;

public class CSV implements TabularWriterFactory
{
  @Override
  public TabularWriter build(ExperimentResults root, String name) 
  {
    File descriptionFile = TidySerializer.descriptionFile(root.resultsFolder, name);
    return new CSVWriter(root.getAutoClosedBufferedWriter(name + ".csv"), descriptionFile); 
  }
}
