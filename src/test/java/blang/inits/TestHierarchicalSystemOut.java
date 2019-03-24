package blang.inits;

import blang.System;

public class TestHierarchicalSystemOut {

  
  public static void main(String [] args) 
  {
    System.out.println("ok");
    
    System.out.indent(); {
      
      System.out.println("child");
      IgnorantChild.test();
      
    } System.out.popIndent();
  }
}
