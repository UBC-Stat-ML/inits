package blang.inits.experiments.tabwriters.factories;

import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.CSVWriter;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;

public class CSV implements TabularWriterFactory
{
  @Override
  public TabularWriter build(ExperimentResults root, String name) 
  {
    name = name + ".csv";
    return new CSVWriter(root.getAutoClosedBufferedWriter(name)); 
  }
}
