package blang.inits.internals

import blang.inits.parsing.Arguments
import blang.inits.parsing.QualifiedName
import com.google.inject.TypeLiteral
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import blang.inits.InputExceptions.InputException
import com.google.common.collect.ListMultimap
import com.google.common.collect.ArrayListMultimap
import java.util.LinkedHashSet
import java.util.ArrayList
import com.google.common.base.Splitter

package class Logger {
    
  val private Map<QualifiedName, TypeLiteral<?>> inputsTypeUsage = new LinkedHashMap
  val private Map<QualifiedName, String> inputsDescriptions = new LinkedHashMap
  val private Map<QualifiedName, String> dependencyDescriptions = new LinkedHashMap
  
  @Accessors(PUBLIC_GETTER)
  val private ListMultimap<QualifiedName,InputException> errors = ArrayListMultimap.create
  
  def private Set<QualifiedName> keysOfPossibleInputs() {
    return inputsTypeUsage.keySet
  }
  
  def void reportTypeUsage(TypeLiteral<?> typeOrOptional, Arguments argument, List<InitDependency> dependencies) {
    for (InitDependency dep : dependencies) {
      switch (dep) {
        InputDependency : {
          inputsTypeUsage.put(argument.QName, typeOrOptional)
          inputsDescriptions.put(argument.QName, dep.annotation.formatDescription)
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
    errors.put(name, exception)
  }
  
  def private String usage(QualifiedName qName) {
    val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
    val boolean isOptional = InitStaticUtils::isOptional(currentType)
    val TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(currentType)
    var String result = '''«formatArgName(qName, "--")» «typeFormatString(qName)» «IF isOptional»(optional)«ENDIF»'''
    if (dependencyDescriptions.containsKey(qName)) 
      result += '\n' + '''  description: «dependencyDescriptions.get(qName)»'''
    return result
  }
  
  def private String typeFormatString(QualifiedName qName) {
    val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
    val TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(currentType)
    val String formatDescription = inputsDescriptions.get(qName)
    return '''<«deOptionized.rawType.simpleName»«IF !formatDescription.empty» : «formatDescription»«ENDIF»>'''
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
    return errors.entries.map[formatArgName(it.key, "@ ") + ": " + it.value.message].join("\n")
  }
  
  /**
   * Reports the information, inputs and errors all in the one string.
   * Useful as the basis of config file, e.g. the first time a complex command is ran.
   */
  def String fullReport(Arguments arguments) {
    var List<String> result = new ArrayList
    val LinkedHashMap<QualifiedName,List<String>> argumentsAsMap = arguments.asMap
    val ListMultimap<QualifiedName,InputException> errorsCopy = ArrayListMultimap.create(errors)
    val Set<QualifiedName> possibleInputsCopy = new LinkedHashSet()
    if (keysOfPossibleInputs().contains(QualifiedName.root())) {
      possibleInputsCopy.add(QualifiedName.root()) // make sure to process the root first
    }
    for (QualifiedName key : keysOfPossibleInputs()) {
      possibleInputsCopy.add(key)
    }
    // start by reporting the known options
    for (QualifiedName qName : possibleInputsCopy) {
      val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
      val boolean isOptional = InitStaticUtils::isOptional(currentType)
      val TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(currentType)
      val List<String> readValue = argumentsAsMap.get(qName)
      val boolean present = readValue !== null
      val boolean commentedOut = !present && isOptional
      var String current = if (commentedOut) "# " else "  "
      current += if (qName.isRoot) "" else "--" + qName.toString
      if (present) {
        current += " " + readValue.join(" ") + "    #"
      }
      current += typeFormatString(qName)   
      if (isOptional) {
        current += " (optional)"
      }
      current += "\n"
      if (dependencyDescriptions.containsKey(qName)) {
        current += '''#   description: «dependencyDescriptions.get(qName)»''' + "\n"
      }
      if (!errors.get(qName).isEmpty()) {
        current += formatErrorBlock(errors.get(qName)) + "\n"
      }
      result += current
      errorsCopy.removeAll(qName)
    }
    // then the unassociated errors
    if (!errorsCopy.isEmpty()) {
      result += "### Additional errors:\n"
      for (QualifiedName qName : errorsCopy.keySet()) {
        var String current = "# error " + formatArgName(qName, "@ ") + "\n"
        current += formatErrorBlock(errorsCopy.get(qName)) + "\n"
        result += current
      }
    }
    return result.join("\n") 
  }
  
  def private String formatErrorBlock(List<InputException> exceptions) {
    val List<String> excFmtLines = new ArrayList
    for (InputException exception : exceptions) {
      val List<String> errorLines = Splitter.on("\n").splitToList(exception.message)
      for (var int i = 0; i < errorLines.size; i++) {
        var String current = ""
        current += "# "
        if (i == 0) {
          current += "! "
        } else {
          current += "  "
        }
        current += errorLines.get(i) 
        excFmtLines += current
      }
    }
    return excFmtLines.join("\n")
  }
  
}