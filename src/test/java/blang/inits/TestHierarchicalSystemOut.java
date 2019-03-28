package blang.inits;

import blang.System;
import blang.inits.experiments.Experiment;

public class TestHierarchicalSystemOut extends Experiment {

  
  public static void main(String [] args) 
  {
    Experiment.start(args);
  }

  @Override
  public void run() {
    System.out.println("ok");
    
    System.out.indent(); {
      
      System.out.println("child");
      IgnorantChild.test();
      
    } System.out.popIndent();
    
    System.out.println("back down");
    
    System.out.indentWithTiming("interrupted block"); {
      
      System.out.println("child");
      IgnorantChild.test();
      if (true) throw new RuntimeException();
      
    } System.out.popIndent();
  }
}
