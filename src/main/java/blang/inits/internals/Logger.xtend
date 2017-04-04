package blang.inits.internals

import blang.inits.parsing.Arguments
import blang.inits.parsing.QualifiedName
import com.google.inject.TypeLiteral
import java.util.LinkedHashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import blang.inits.InputExceptions.InputException
import com.google.common.collect.ListMultimap
import com.google.common.collect.ArrayListMultimap
import java.util.LinkedHashSet
import java.util.ArrayList
import com.google.common.base.Splitter
import blang.inits.InputExceptions.InputExceptionCategory
import java.util.Optional
import java.util.TreeMap
import java.util.SortedMap

package class Logger {
    
  val package Map<QualifiedName, TypeLiteral<?>> inputsTypeUsage = new LinkedHashMap
  val package Map<QualifiedName, String> inputsDescriptions = new LinkedHashMap
  val package Map<QualifiedName, String> dependencyDescriptions = new LinkedHashMap
  val package Map<QualifiedName, TypeLiteral<?>> allTypes = new LinkedHashMap
  val package Map<QualifiedName, String> defaultValues = new LinkedHashMap
  val package Map<QualifiedName, Boolean> defaultValuesRecursive = new LinkedHashMap
  val package Map<QualifiedName, List<String>> readValues = new LinkedHashMap
  
  def void addAll(Logger another) {
    inputsTypeUsage.putAll(another.inputsTypeUsage)
    inputsDescriptions.putAll(another.inputsDescriptions)
    dependencyDescriptions.putAll(another.dependencyDescriptions)
    allTypes.putAll(another.allTypes)
    defaultValues.putAll(another.defaultValues)
    defaultValuesRecursive.putAll(another.defaultValuesRecursive)
    readValues.putAll(another.readValues)
  }
  
  @Accessors(PUBLIC_GETTER)
  val private ListMultimap<QualifiedName,InputException> errors = ArrayListMultimap.create
  
  def boolean hasUnknownArgument() {
    for (error : errors.values) {
      if (error.category == InputExceptionCategory.UNKNOWN_INPUT) {
        return true
      }
    }
    return false
  }
  
  def void addError(QualifiedName name, InputException exception) {
    errors.put(name, exception)
  }
  
  def private String typeFormatString(QualifiedName qName) {
    val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
    val TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(currentType)
    val String formatDescription = inputsDescriptions.get(qName)
    return '''<«deOptionized.rawType.simpleName»«IF !formatDescription.empty»: «formatDescription»«ENDIF»>'''
  }
  
  def String usage() { 
    return fullReport(null)
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
  
  def boolean someParentOptional(QualifiedName qName) {
    val TypeLiteral<?> currentType = allTypes.get(qName)
    if (currentType != null) {
      val boolean isOptional = InitStaticUtils::isOptional(currentType)
      if (isOptional) {
        return true
      }
    }
    if (qName.isRoot) {
      return false
    } else {
      return someParentOptional(qName.parent)
    }
  }
  
  def Optional<String> someParentHasDefault(QualifiedName qName) {
    if (defaultValues.containsKey(qName) && defaultValuesRecursive.get(qName)) {
      return Optional.of("parent " + qName + " has default value: " + defaultValues.get(qName))
    }
    if (qName.isRoot) {
      return Optional.empty
    } else {
      return someParentHasDefault(qName.parent)
    }
  }
  
  def private LinkedHashSet<QualifiedName> sortedPossibleInputs() {
    val LinkedHashSet<QualifiedName> result = new LinkedHashSet()
    if (inputsTypeUsage.keySet.contains(QualifiedName.root())) {
      result.add(QualifiedName.root()) // make sure to process the root first
    }
    for (QualifiedName key : inputsTypeUsage.keySet) {
      result.add(key)
    }
    return result
  }
  
  def String enforcementString(QualifiedName qName) {
    val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
    val boolean isOptional = InitStaticUtils::isOptional(currentType)
    
    if (isOptional) {
      return "optional"
    }
    
    if (someParentOptional(qName)) {
      return "a parent is optional"
    }
    
    if (defaultValues.containsKey(qName)) {
      return "default value: " + defaultValues.get(qName)
    }
    
    val Optional<String> parentDefault = someParentHasDefault(qName)
    if (parentDefault.isPresent) {
      return parentDefault.get
    }
    
    return "mandatory"
  }
  
  def Map<String,String> asMap() {
    var Map<String,String> result = new LinkedHashMap
    val LinkedHashSet<QualifiedName> possibleInputsCopy = sortedPossibleInputs()
    for (QualifiedName qName : possibleInputsCopy) {
      val List<String> readValue = readValues.get(qName) //argumentsAsMap.get(qName)
      val TypeLiteral<?> currentType = inputsTypeUsage.get(qName)
      val boolean isOptional = InitStaticUtils::isOptional(currentType)
      val String value = 
        if (readValue != null) {
          readValue.join(" ")
        } else if (isOptional) {   
          "<optional>" 
        } else if (someParentOptional(qName)) {
          "<parent optional>"
        } else if (defaultValues.containsKey(qName)) {
          defaultValues.get(qName)
        } else if (someParentHasDefault(qName).isPresent) {
          someParentHasDefault(qName).get
        } else {
          "<missing>"
        }
      result.put(qName.toString, value)
    }
    return result
  }
  
  /**
   * Reports the information, inputs and errors all in the one string.
   * Useful as the basis of config file, e.g. the first time a complex command is ran.
   */
  def String fullReport(Arguments _arguments) {  // TODO: remove dep on _arg via readValues, use boolean switch instead
    
    val printDetails = _arguments != null
    val String on  = if (printDetails) " " else ""
    val String off = if (printDetails) "#" else ""
    val Arguments arguments = if (_arguments == null) {
      Arguments.createEmpty
    } else {
      _arguments
    }
    
    val SortedMap<String,String> entries = new TreeMap
    val LinkedHashMap<QualifiedName,List<String>> argumentsAsMap = arguments.asMap
    val ListMultimap<QualifiedName,InputException> errorsCopy = ArrayListMultimap.create(errors)
    val LinkedHashSet<QualifiedName> possibleInputsCopy = sortedPossibleInputs()
    // start by reporting the known options
    for (QualifiedName qName : possibleInputsCopy) {
      val List<String> readValue = argumentsAsMap.get(qName)
      val boolean present = readValue !== null
      val boolean commentedOut = !present 
      
      var String current = if (commentedOut) off else on
      current += if (qName.isRoot) "  " else " --" + qName.toString
      if (present) {
        current += " " + readValue.join(" ") + "    #"
      }
      current += " " + typeFormatString(qName)  
      current += " (" + enforcementString(qName) + ")"
      current += "\n"
      if (dependencyDescriptions.containsKey(qName)) {
        current += '''«off»   description: «dependencyDescriptions.get(qName)»''' + "\n"
      }
      if (printDetails) {
        if (!errors.get(qName).isEmpty()) {
          current += formatErrorBlock(errors.get(qName)) + "\n"
        }
      }
      
      entries.put(qName.toString, current)
      errorsCopy.removeAll(qName)
    }
    
    // make sure everything sorted by key
    var List<String> result = new ArrayList
    for (String key : entries.keySet()) {
      result += entries.get(key)
    }
    
    // then the unassociated errors
    if (!errorsCopy.isEmpty() && printDetails) {
      result += "### Errors:\n"
      for (QualifiedName qName : errorsCopy.keySet()) {
        var String current = "#   error " + formatArgName(qName, "@ ") + "\n"
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