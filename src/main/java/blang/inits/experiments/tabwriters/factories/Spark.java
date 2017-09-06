package blang.inits.experiments.tabwriters.factories;

import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.SparkWriter;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;

public class Spark implements TabularWriterFactory
{
  @Override
  public TabularWriter build(ExperimentResults root, String name) 
  {
    return new SparkWriter(root.child(name));
  }
}
