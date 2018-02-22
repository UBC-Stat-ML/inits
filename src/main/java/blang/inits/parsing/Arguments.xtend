package blang.inits.parsing

import java.util.List
import java.util.Set
import java.util.Map
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Data
import java.util.ArrayList
import com.google.common.base.Joiner
import java.util.Optional
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.LinkedHashMap

/**
 * A tree of arguments. E.g. --node is parent of --node.child
 * 
 * Each node has a unique argument key, and optionally, an argument value, e.g. --key value.
 */
class Arguments {
  /**
   * The optional is non-null if and only if the switch --name appears in the command line.
   * Note that the node might still be needed in the tree when it does not occur, e.g. if the 
   * node has descendants that do appear in the command line.
   */
  var Optional<List<String>> argumentValue
  val Map<String, Arguments> children = new HashMap
  
  @Accessors(PUBLIC_GETTER)
  val QualifiedName qName
  
  public new(Optional<List<String>> argumentValue, QualifiedName qName) {
    this.argumentValue = argumentValue
    this.qName = qName
  }
  
  /**
   * A map where the set of keys are the nodes in the subtree rooted here 
   * such that the argumentValue is not empty
   */
  def LinkedHashMap<QualifiedName,List<String>> asMap() {
    val LinkedHashMap<QualifiedName,List<String>> result = new LinkedHashMap
    _asMap(result)
    return result
  }
  
  def private void _asMap(LinkedHashMap<QualifiedName,List<String>> result) {
    if (argumentValue.isPresent()) {
      result.put(qName, argumentValue.get())
    }
    for (Arguments child : children.values) {
      child._asMap(result)
    }
  }
  
  /**
   * Returns a deep copy rooted at the specified qualified name
   */
  def Arguments withQName(QualifiedName qName) {
    val Arguments result = new Arguments(this.argumentValue, qName)
    for (String name : children.keySet()) {
      val Arguments child = children.get(name).withQName(qName.child(name))
      result.children.put(name, child)    
    }
    return result
  }
  
  /**
   * Return a deep copy with the provided alternative value
   */
  def Arguments withValue(List<String> value) {
    val Arguments result = new Arguments(Optional.of(value), qName)
    result.children.putAll(this.children)
    return result
  }
  
  /**
   * Pops the first item in the list of strings at that node, 
   * returns a copy of the structure without that string, taking care 
   * of empty optionals and list in the obvious way.
   */
  def Pair<Arguments,Optional<String>> pop() {
    var Optional<String> popped
    var Optional<List<String>> remaining
    if (argumentValue.isPresent) {
      val List<String> list = argumentValue.get
      if (list.isEmpty) {
        popped = Optional.empty
        remaining = Optional.of(list)
      } else {
        popped = Optional.of(list.get(0))
        remaining = Optional.of(list.subList(1, list.size))
      }
    } else {
      popped = Optional.empty
      remaining = Optional.empty
    }
    
    val Arguments result = new Arguments(remaining, qName)
    result.children.putAll(this.children)
    return Pair.of(result, popped)
  }
  
  def Arguments getOrCreateDesc(List<String> path) {
    var Arguments result = this
    for (var int i = 0; i < path.size; i++) {
      val String currentChildName = path.get(i)
      if (result.childrenKeys.contains(currentChildName)) {
        result = result.child(currentChildName)
      } else {
        result = result.createChild(currentChildName, Optional.empty, true)
      }
    }
    return result
  }
  
  def static Arguments createEmpty() {
    return new Arguments(Optional.empty, QualifiedName.root())
  }
  
  def static Arguments parse(List<ArgumentItem> items) {
    val Arguments root = createEmpty()
    
    for (ArgumentItem item : items) {
      val Arguments node = root.getOrCreateDesc(item.fullyQualifiedName)
      if (node.argumentValue.present) {
        throw new RuntimeException("Argument duplicated: " + item.fullyQualifiedName.join("."))
      }
      node.argumentValue = Optional.of(item.value)
    }
    return root
  }
  
  @Data
  static class ArgumentItem {
    val List<String> fullyQualifiedName // root is empty list
    val List<String> value
  }
  
  def void setOrCreateChild(String name, List<String> value) {
    if (children.containsKey(name)) {
      val Arguments child = child(name)
      child.argumentValue = Optional.of(value)
    } else {
      createChild(name, Optional.of(value), true)
    }
  }

  def private Arguments createChild(String name, Optional<List<String>> value, boolean addToParent) {
    if (children.containsKey(name)) {
      throw new RuntimeException
    }
    val Arguments child = new Arguments(value, qName.child(name))
    if (addToParent) {
      children.put(name, child)
    }
    return child
  }
  
  def Arguments child(String string) {
    val Arguments result = children.get(string)
    if (result === null) {
      return new Arguments(Optional.empty, qName.child(string))
    } else {
      return result
    }
  }
  
  /**
   * We say the tree is null the corresponding switch did not occur, nor
   * any of its descendent
   */
  def boolean isNull() {
    return children.empty && !argumentValue.present
  }
  
  /**
   * null if the key was not inserted, i.e. the switch did not occur
   */
  def Optional<List<String>> argumentValue() {
    return argumentValue
  }
  
  def Set<String> childrenKeys() {
    return children.keySet
  }
  
  override String toString() {
    val List<String> result = new ArrayList
    toString(result)
    return Joiner.on(" ").join(result)
  }
  
  def private void toString(List<String> result) {
    if (argumentValue.present) {
      result.add((if (qName.isRoot()) "" else "--" + qName + " ") + Joiner.on(" ").join(argumentValue.get))
    }
    for (String key : children.keySet) {
      children.get(key).toString(result)
    }
  }
  
  def static void main(String [] args) {
    Posix.parse(args)
  }
  
}