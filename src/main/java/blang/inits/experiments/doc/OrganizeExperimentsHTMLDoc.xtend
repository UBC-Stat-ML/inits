package blang.inits.experiments.doc

import blang.xdoc.BootstrapHTMLRenderer
import java.io.File
import java.nio.file.Files
import java.io.IOException
import briefj.BriefFiles
import blang.inits.experiments.doc.ExperimentHTMLDoc.ParsedExperiment
import java.util.Map
import blang.xdoc.components.Document
import java.util.ArrayList
import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.Multimap
import java.util.LinkedHashMap
import com.google.common.collect.LinkedHashMultimap
import blang.xdoc.components.DocElement

class OrganizeExperimentsHTMLDoc extends BootstrapHTMLRenderer {
  val File execPool
  val Multimap<String,ParsedExperiment> organized
  
  new(File execPool) {
    super(execPool.parentFile.name)
    this.execPool = execPool
    
    // efficiency idea: only do it for the past week; to do full list run the command manually
    // also, make it calleable with just one main
    // main: list of all the mains with link to main-specific page (# in each, last ran)
    // for each main:
    // commit, start, end, time + args inter + key_outputs
    organized = ArrayListMultimap.create
    for (exec : BriefFiles.ls(new File(execPool, "all"), "exec")) {
      val parsed = new ParsedExperiment(exec)
      if (parsed.mainClass !== null)
        organized.put(parsed.mainClass, parsed)
    }
    
    documents => [
      val Map<String,Document> links = new LinkedHashMap
      for (main : organized.keySet) {
        val doc = execs(main)
        links.put(main, doc)
        add(doc)
      }
      add(mains(links))
    ]
  }
  
  def Document execs(String main) {
    val argMultiMap = LinkedHashMultimap.create
    for (exec : organized.get(main)) {
      val args = exec.arguments
      if (args !== null)
        for (key : args.keySet)
          argMultiMap.put(key, args.get(key))
    }
    val variableKeys = argMultiMap.keySet.filter[argMultiMap.get(it).size > 1]
    
    new Document(main) [
      category = "Executions"
      val list = new ArrayList<Map<String,String>>
      var Map<String,String> prev = null
      for (exec : organized.get(main)) {
        val row = new LinkedHashMap()
        row.put("Exec", ExperimentHTMLDoc::id(exec.execDir))
        row.put("Start time", "" + (exec.startDate ?: ""))
        row.put("End time", "" + (exec.endDate ?: ""))
        row.put("Execution time", exec.timing ?: "")
        row.put("Commit", exec.commit ?: "")
        val args = exec.arguments
        for (key : variableKeys)
          row.put(key, if (args === null) "" else formatArg(it, key, args, prev))
        if (args !== null)
          prev = args
        list.add(row)
      }
      table(list)
    ]
  }
  
  def static String formatArg(DocElement it, String key, Map<String,String> args, Map<String,String> prev) {
    val value = args.get(key)
    if (value === null) return ""
    if (prev === null || prev.get(key) == args.get(key)) return value
    return EMPH + value + ENDEMPH
  }
  
  def Document mains(Map<String,Document> links) {
    new Document("Summary") [
      isIndex = true
      val list = new ArrayList<Map<String,String>>
      for (main : organized.keySet) {
        val row = new LinkedHashMap()
        row.put("Main class", LINK(links.get(main)) + main + ENDLINK)
        row.put("Number of executions", "" + organized.get(main).size)
        list.add(row)
      }
      table(list)
    ]
  }
  
  override container() { "container-fluid" }
  override htmlSupportFilesPrefix() { "../.html_support" }
  
  def static void build(File poolDir) {
    if (!poolDir.exists || !poolDir.directory) throw new RuntimeException("Invalid pool dir: " + poolDir.path)
    val destination = new File(poolDir, "site")
    destination.mkdir
    val mkDoc = new OrganizeExperimentsHTMLDoc(poolDir) 
    mkDoc.renderInto(destination)
    try { Files.createSymbolicLink(new File(poolDir, "index.html").toPath(), poolDir.toPath.relativize(new File(destination, "index.html").toPath())); } 
    catch (IOException e) {}
  }
  
  def static void main(String [] args) {
    if (args.length !== 1) {
      System.err.println("One argument: path to execution pool")
      System.exit(1)
    }
    build(new File(args.get(0)))
  }
  
}