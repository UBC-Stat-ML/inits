package blang.input.internals

import blang.inits.Arguments
import blang.inits.QualifiedName
import blang.input.internals.InputExceptions.InputException
import com.google.inject.TypeLiteral
import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Set
import blang.input.internals.CreatorImpl.RecursiveDependency
import org.eclipse.xtend.lib.annotations.Accessors

class Logger {
    
  val private Map<QualifiedName, TypeLiteral<?>> inputsTypeUsage = new LinkedHashMap
  val private Map<QualifiedName, String> dependencyDescriptions = new LinkedHashMap
  
  @Accessors(PUBLIC_GETTER)
  val private List<Pair<QualifiedName,InputException>> errors = new ArrayList
  
  def Set<QualifiedName> keysOfPossibleInputs() {
    return inputsTypeUsage.keySet
  }
  
  def reportTypeUsage(TypeLiteral<?> typeOrOptional, Arguments argument, List<InitDependency> dependencies) {
    for (InitDependency dep : dependencies) {
      switch (dep) {
        InputDependency : {
          inputsTypeUsage.put(argument.QName, typeOrOptional)
        }
        RecursiveDependency : {
          if (dep.description.present) 
            dependencyDescriptions.put(argument.QName.child(dep.name), dep.description.get)
        }
        default : throw new RuntimeException
      }
    }
  }
  
  def void addError(QualifiedName name, InputException exception) {
    errors.add(Pair.of(name, exception))
  }
  
  def String usage(QualifiedName qName) {
    var String result = '''«formatArgName(qName)» <«inputsTypeUsage.get(qName).rawType.simpleName»>'''
    if (dependencyDescriptions.containsKey(qName)) 
      result += '\n' + '''  description: «dependencyDescriptions.get(qName)»'''
    return result
  }
  
  def String usage() { 
    keysOfPossibleInputs.map[usage(it)].join("\n")
  }
  
  def String formatArgName(QualifiedName qName) {
    if (qName.root)
      return "<root>"
    else
      return "--" + qName
  }
}