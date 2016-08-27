package blang.inits

import java.util.List
import java.lang.reflect.Field
import java.lang.reflect.Type
import java.lang.reflect.ParameterizedType
import com.google.inject.TypeLiteral
import java.util.Arrays

class TestTypeLiteral {
  
  var public Test<String> myTest 
  
  static class Test<T> {
    var public  List<T> field
  }
  
  def public static void main(String [] args) {
    println(TestTypeLiteral.getFields.size)
    val Field f1 = TestTypeLiteral.getDeclaredField("myTest")
//    val ParameterizedType t = f1.genericType as ParameterizedType
//    t.

    val TypeLiteral lit = TypeLiteral.get(f1.genericType)
    println(lit)
    println(lit.getFieldType(lit.rawType.getDeclaredField("field")))
  }
}