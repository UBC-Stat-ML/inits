package blang.inits.experiments.tabwriters

import blang.inits.GlobalArg
import blang.inits.experiments.ExperimentResults
import blang.inits.experiments.tabwriters.TabularWriter
import java.util.Collection
import java.util.Map
import blang.inits.DesignatedConstructor

class TidySerializer {
  
  val ExperimentResults result
  
  @DesignatedConstructor
  new(@GlobalArg ExperimentResults result) {
    this.result = result
  }
  
  def void serialize(Object object, String name) {
    serializeImplementation(object, result.getTabularWriter(name))
  }
  
  def dispatch protected void serializeImplementation(Object object, TabularWriter writer) {
    writer.write("value", object.toString)
  }
  
  def dispatch protected void serializeImplementation(Object [] array, TabularWriter writer) {
    for (var int i = 0; i < array.length; i++) {
      recurse(array.get(i), "array_index_" + writer.depth, i, writer)
    }
  }
  
  def dispatch protected void serializeImplementation(double [] array, TabularWriter writer) {
    for (var int i = 0; i < array.length; i++) {
      recurse(array.get(i), "array_index_" + writer.depth, i, writer)
    }
  }
  
  def dispatch protected void serializeImplementation(int [] array, TabularWriter writer) {
    for (var int i = 0; i < array.length; i++) {
      recurse(array.get(i), "array_index_" + writer.depth, i, writer)
    }
  }
  
  def dispatch protected void serializeImplementation(Collection<?> collection, TabularWriter writer) {
    var int i = 0
    for (Object item : collection) {
      recurse(item, "list_index_" + writer.depth, i++, writer)
    }
  }
  
  def dispatch protected void serializeImplementation(Map<?,?> map, TabularWriter writer) {
    for (key : map.keySet) { 
      recurse(map.get(key), "map_key_" + writer.depth, key, writer)
    }
  }
  
  def protected void recurse(Object child, Object key, Object value, TabularWriter writer) {
    serializeImplementation(child, writer.child(key, value))
  }
  
}