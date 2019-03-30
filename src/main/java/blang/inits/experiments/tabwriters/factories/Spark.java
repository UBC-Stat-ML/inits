package blang.inits.experiments.tabwriters.factories;

import java.io.File;

import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.SparkWriter;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.TidySerializer;

public class Spark implements TabularWriterFactory
{
  @Override
  public TabularWriter build(ExperimentResults root, String name) 
  {
    File descriptionFile = TidySerializer.descriptionFile(root.resultsFolder, name);
    return new SparkWriter(name, root.child(name), descriptionFile);
  }
}
