package blang.inits

import blang.inits.experiments.Experiment

class ImplementationTest implements Runnable {
  
  @Implementations(MyImpl1, MyImpl2)
  static interface MyInterface {
    
  }
  
  static class MyImpl1 implements MyInterface {
    
  }
  
  static class MyImpl2 implements MyInterface {
    
  }
  
  @Arg
  MyInterface interf
  
  def static void main(String [] args) {
    Inits.parseAndRun(ImplementationTest, args)
  }
  
  override run() {
  }
  
}