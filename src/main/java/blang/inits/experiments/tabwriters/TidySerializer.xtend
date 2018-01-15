package blang.inits.experiments.tabwriters

import blang.inits.GlobalArg
import blang.inits.experiments.ExperimentResults
import blang.inits.experiments.tabwriters.TabularWriter
import java.util.Map
import blang.inits.DesignatedConstructor
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.HashMap

class TidySerializer {
  
  val ExperimentResults result
  val Map<String,TabularWriter> tabularWriters = new HashMap 
  
  @DesignatedConstructor
  new(@GlobalArg ExperimentResults result) {
    this.result = result
  }
  
  def void serialize(Object object, String name, Pair<Object,Object> ... globalContext) {
    var TabularWriter tabularWriter = tabularWriters.get(name)
    if (tabularWriter === null) {
      tabularWriter = result.getTabularWriter(name)
      tabularWriters.put(name, tabularWriter)
    }
    if (!globalContext.empty) {
      tabularWriter = new TabularWriterWithGlobals(tabularWriter, globalContext) 
    }
    serializeImplementation(object, tabularWriter)
  }
  
  @Data
  private static class TabularWriterWithGlobals implements TabularWriter {
    
    val TabularWriter enclosed
    val Pair<Object,Object> [] globalContext
    
    override child(Object key, Object value) {
      return new TabularWriterWithGlobals(enclosed.child(key, value), globalContext)
    }
    
    override depth() {
      return enclosed.depth
    }
    
    override write(Pair<?, ?>... entries) {
      val Pair<Object,Object> [] extendedEntries = newArrayOfSize(entries.size + globalContext.size) 
      var int i = 0;
      for (Pair<Object,Object> p : globalContext) {
        extendedEntries.set(i++, p)
      }
      for (Pair p : entries) {
        extendedEntries.set(i++, p)
      }
      enclosed.write(extendedEntries)
    }
  }
  
  @Data
  public static class Context {
    @Accessors(NONE) val TidySerializer serializer
    @Accessors(NONE) val TabularWriter writer
    def void recurse(Object child, Object key, Object value) {
      serializer.recurse(child, key, value, writer) 
    }
  } 
  
  def dispatch protected void serializeImplementation(TidilySerializable object, TabularWriter writer) {
    object.serialize(new Context(this, writer)) 
  }
  
  def dispatch protected void serializeImplementation(Object object, TabularWriter writer) {
    writer.write(Pair.of("value", object.toString))
  }
  
  def dispatch protected void serializeImplementation(Object [] array, TabularWriter writer) {
    serializeIterable(array, writer)
  }
  
  def dispatch protected void serializeImplementation(double [] array, TabularWriter writer) {
    serializeIterable(array, writer)
  }
  
  def dispatch protected void serializeImplementation(int [] array, TabularWriter writer) {
    serializeIterable(array, writer)
  }
  
  def dispatch protected void serializeImplementation(Iterable<?> collection, TabularWriter writer) {
    serializeIterable(collection, writer)
  }
  
  def dispatch protected void serializeImplementation(Map<?,?> map, TabularWriter writer) {
    for (key : map.keySet) { 
      recurse(map.get(key), "map_key_" + writer.depth, key, writer)
    }
  }
  
  def protected void recurse(Object child, Object key, Object value, TabularWriter writer) {
    serializeImplementation(child, writer.child(key, value))
  }
  
  // RATIONALE: non-dispatch used to avoid repeating array code
  def private void serializeIterable(Iterable<?> collection, TabularWriter writer) {
    var int i = 0
    for (Object item : collection) {
      recurse(item, "index_" + writer.depth, i++, writer)
    }
  }
}