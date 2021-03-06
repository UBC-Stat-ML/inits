package blang.inits.experiments.doc

import blang.xdoc.BootstrapHTMLRenderer
import java.io.File
import blang.xdoc.components.Document
import briefj.BriefIO

import static briefj.run.ExecutionInfoFiles.*
import java.util.Date
import java.util.concurrent.TimeUnit
import briefj.BriefFiles
import blang.inits.experiments.Experiment
import java.nio.file.Files
import java.io.IOException
import briefj.run.Results
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.Functions.Function0
import java.util.Map
import java.util.LinkedHashMap
import au.com.bytecode.opencsv.CSVParser
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

class ExperimentHTMLDoc extends BootstrapHTMLRenderer {
  
  val extension ParsedExperiment parsed
  
  override container() { "container-fluid" }
  override htmlSupportFilesPrefix() { "../../../.html_support" }
  
  @Data
  static class ParsedExperiment {
    val File execDir
    
    /** The following return null if file not found or other errors */
    def Date startDate() { safe[new Date(epoch(START_TIME_FILE))] }
    def Date endDate() { safe[new Date(epoch(END_TIME_FILE))] }
    def String timing() { safe[getDurationBreakdown(epoch(END_TIME_FILE) - epoch(START_TIME_FILE))] }
    
    def mainClass() {
      safe[
        val split = execInfo(MAIN_CLASS_FILE).split(" ")
        val main = split.get(split.size - 1)
        if (main == "blang.runtime.Runner")
          arguments.get("model").replaceAll("[$]Builder","")
        else
          main
      ]
    }
    
    def Map<String,String> arguments() {
      safe[
        val result = new LinkedHashMap
        for (line : BriefIO::readLines(new File(execDir, Experiment::CSV_ARGUMENT_FILE)).splitCSV(new CSVParser("\t"))) {
          result.put(line.get(0), line.get(1))
        }
        return result
      ]
    }
    
    def String commit() { safe[commitInfo(2)] }
    def String repo() { safe[commitInfo(0)]}
    
    def String execInfo(String name) {
      val file = new File(execDir, infoFileDirectoryName + "/" + name)
      if (file.exists)
        BriefIO.fileToString(file)
      else
        null
    }
    
    def boolean hasNotes() {
      val notes = notes
      if (notes === null) return false
      return notes.length > 0
    }
    
    def String notes() {
      val file = new File(execDir, "notes.txt")
      if (file.exists) 
        BriefIO.fileToString(file)
      else
        return null
    }
    
    // private stuff 
    
    private def long epoch(String startOrEnd) { Long.parseLong(execInfo(startOrEnd)) }
      
    private def commitInfo(int i) {
      val info = execInfo(REPOSITORY_INFO)
      info.split("\n").get(i).split("\t").get(1)
    }
  }
  
  static def <T> T safe(Function0<T> p) {
    try { p.apply() } catch (Exception e) { null }
  }
  
  def Document summary() {
    new Document("Summary") [
      isIndex = true
      
      
      clipboard("open " + parsed.execDir.absolutePath.toString)
      keyValues(
        "Main class" -> mainClass,
        "Commit" -> (commit ?: missingGitInfo),
        "Repository" -> (repo ?: missingGitInfo),
        "Start time" -> startDate,
        "End time" -> endDate,
        "Execution time" -> timing
      )
      embed("../" + infoFileDirectoryName + "/" + STD_OUT_FILE)
      embed("../" + infoFileDirectoryName + "/" + STD_ERR_FILE)
      embed("../" + infoFileDirectoryName + "/" + JAVA_ARGUMENTS)
      embed("../" + infoFileDirectoryName + "/" + JVM_OPTIONS)
      embed("../" + infoFileDirectoryName + "/" + CLASSPATH_INFO)
      if (Results.getFileInResultFolder(infoFileDirectoryName + "/" + REPOSITORY_DIRTY_FILES).exists)
        embed("../" + infoFileDirectoryName + "/" + REPOSITORY_DIRTY_FILES)
    ]
  }
  
  static val missingGitInfo = "Use --experimentConfigs.recordGitInfo"
  
  def Document plotPage(File folder) {
    new Document(folder.name) [
      category = "Plots"
      for (File pdf : BriefFiles::ls(folder, "pdf")) {
        embed("../" + folder.name + "/" + pdf.name)
      }
    ]
  }
  
  def Document tablePage(File folder) {
    val limit = 20
    new Document(folder.name) [
      category = "Tables"
      for (File csv : BriefFiles::ls(folder, "csv")) {
        section(csv.name) [
          table(BriefIO::readLines(csv).indexCSV.limit(limit).toList)
          if (BriefIO::readLines(csv).indexCSV.limit(limit+1).size > limit)
            it += '''Skipping remaining rows...'''
        ]
      }
    ]
  }
  
  def Document argumentsPage() {
    new Document("Arguments") [
      val file = new File(execDir, Experiment::DETAILED_ARGUMENT_FILE_CSV)
      table(BriefIO.readLines(file).indexCSV.toList)
    ]
  }
  
  def static String id(File execDir) {
    execDir.name.replaceAll("[.]exec", "").replaceAll(".*[-]", "")
  }
  
  new(File experimentDirectory) {
    super("Execution " + id(experimentDirectory))
    this.parsed = new ParsedExperiment(experimentDirectory)
    documents => [
      add(summary)
      add(argumentsPage)
      for (subDir : BriefFiles::ls(experimentDirectory).filter[containsExt("pdf")])
        add(plotPage(subDir))
      for (subDir : BriefFiles::ls(experimentDirectory).filter[containsExt("csv")])
        add(tablePage(subDir))
    ]
  }
  
  
  def static boolean containsExt(File f, String ext) {
    if (!f.isDirectory) return false
    !BriefFiles::ls(f, ext).empty
  }

  def static void build(File execDir) {
    val destination = new File(execDir, "site")
    destination.mkdir
    val mkDoc = new ExperimentHTMLDoc(execDir)
    mkDoc.renderInto(destination)
    try { Files.createSymbolicLink(new File(execDir, "index.html").toPath(), execDir.toPath.relativize(new File(destination, "index.html").toPath())); } 
    catch (IOException e) {}
  }
  
  def static void main(String [] args) {
    lightMain(args, [build(it)], "One argument: path to .exec file (or invoke inside with no args)")
  }
  
  def static void lightMain(String [] args, Procedure1<File> builder, String error) {
    val file = 
      if (args.empty)
        new File(".").absoluteFile.canonicalFile
      else {
        if (args.length !== 1) {
          System.err.println(error)
          System.exit(1)
          throw new RuntimeException
        } else
          new File(args.get(0))
      }
    if (!file.exists || !file.directory) {
      System.err.println(error)
      System.exit(1)
    } else
      builder.apply(file)
  }
  
  def static String getDurationBreakdown(long millis) {
   val long days = TimeUnit.MILLISECONDS.toDays(millis)
   val long hours = TimeUnit.MILLISECONDS.toHours(millis) % 24
   val long minutes = TimeUnit.MILLISECONDS.toMinutes(millis) % 60
   val long seconds = TimeUnit.MILLISECONDS.toSeconds(millis) % 60
   val long milliseconds = millis % 1000

   return String.format("%d d %d h %d m %d s %d ms",
                        days, hours, minutes, seconds, milliseconds)
   }
}