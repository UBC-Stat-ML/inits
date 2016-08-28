package blang.inits.internals

import blang.inits.Arguments
import blang.inits.QualifiedName
import com.google.inject.TypeLiteral
import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import blang.inits.InputExceptions.InputException
import blang.inits.InitService

package class Logger {
    
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
        // do not report the other ones
      }
    }
  }
  
  def void addError(QualifiedName name, InputException exception) {
    errors.add(Pair.of(name, exception))
  }
  
  def String usage(QualifiedName qName) {
    var String result = '''«formatArgName(qName, "--")» <«inputsTypeUsage.get(qName).rawType.simpleName»>'''
    if (dependencyDescriptions.containsKey(qName)) 
      result += '\n' + '''  description: «dependencyDescriptions.get(qName)»'''
    return result
  }
  
  def String usage() { 
    keysOfPossibleInputs.map[usage(it)].join("\n")
  }
  
  def String formatArgName(QualifiedName qName, String prefix) {
    if (qName.root)
      return "<root>"
    else
      return prefix + qName
  }
  
  def String errorReport() {
    return errors.map[formatArgName(it.key, "@ ") + ": " + it.value.message].join("\n")
  }
  
}