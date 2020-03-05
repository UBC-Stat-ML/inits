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
import blang.xdoc.components.Table

class MakeExperimentHTMLDoc extends BootstrapHTMLRenderer {
  
  val File execDir
  
  override container() { "container-fluid" }
  override htmlSupportFilesPrefix() { "../../../.html_support" }
  
  def Document summary() {
    new Document("Summary") [
      isIndex = true
      
      clipboard("open " + execDir.absolutePath.toString)
            
      val start = Long.parseLong(execInfo(START_TIME_FILE))
      val end = try { Long.parseLong(execInfo(END_TIME_FILE)) } catch (Exception e) { null }
      val delta = try { getDurationBreakdown(end - start) } catch (Exception e) { null }
      
      keyValues(
        "Main class" -> (execInfo(MAIN_CLASS_FILE) ?: missingExecInfo),
        "Commit" -> (execInfo(REPOSITORY_INFO) ?: "Use --experimentConfigs.recordGitInfo"),
        "Start time" -> (new Date(start) ?: missingExecInfo),
        "End time" -> (new Date(end) ?: missingExecInfo + " or not completed"),
        "Execution time" -> (delta ?: missingExecInfo + " or not completed")
      )
      embed("../" + infoFileDirectoryName + "/" + STD_OUT_FILE)
      embed("../" + infoFileDirectoryName + "/" + STD_ERR_FILE)
      embed("../" + infoFileDirectoryName + "/" + JVM_OPTIONS)
      embed("../" + infoFileDirectoryName + "/" + CLASSPATH_INFO)
    ]
  }
  
  static val missingExecInfo = "Use --experimentConfigs.recordExecutionInfo"
  
  def Document plotPage(File folder) {
    new Document(folder.name) [
      category = "Plots"
      for (File pdf : BriefFiles::ls(folder, "pdf")) {
        embed(pdf)
      }
    ]
  }
  
  def Document argumentsPage() {
    new Document("Arguments") [
      val file = new File(execDir, Experiment::DETAILED_ARGUMENT_FILE_CSV)
      val table = new Table(BriefIO.readLines(file).indexCSV.toList)
      table(table) 
    ]
  }
  
  def String execInfo(String name) {
    val file = new File(execDir, infoFileDirectoryName + "/" + name)
    if (file.exists)
      BriefIO.fileToString(file)
    else
      null
  }
  
  new(File experimentDirectory) {
    super("Execution " + experimentDirectory.name.replaceAll("[.]exec", ""). replaceAll(".*[-]", ""))
    this.execDir = experimentDirectory
    documents => [
      add(summary)
      add(argumentsPage)
      for (subDir : BriefFiles::ls(experimentDirectory).filter[containsPDF])
        add(plotPage(subDir))
    ]
  }
  
  def static boolean containsPDF(File f) {
    if (!f.isDirectory) return false
    !BriefFiles::ls(f, "pdf").empty
  }

  def static void buildExperimentWebsite(File execDir) {
    if (!execDir.exists || !execDir.directory) throw new RuntimeException("Invalid exec dir: " + execDir.path)
    val destination = new File(execDir, "site")
    destination.mkdir
    val mkDoc = new MakeExperimentHTMLDoc(execDir)
    mkDoc.renderInto(destination)
  }
  
  def static void main(String [] args) {
    if (args.length !== 1) {
      System.err.println("One argument: path to .exec file")
      System.exit(1)
    }
    buildExperimentWebsite(new File(args.get(0)))
  }
  
  def static String getDurationBreakdown(long millis) {
       if (millis < 0) {
          throw new IllegalArgumentException("Duration must be greater than zero!");
       }

       val long days = TimeUnit.MILLISECONDS.toDays(millis);
       val long hours = TimeUnit.MILLISECONDS.toHours(millis) % 24;
       val long minutes = TimeUnit.MILLISECONDS.toMinutes(millis) % 60;
       val long seconds = TimeUnit.MILLISECONDS.toSeconds(millis) % 60;
       val long milliseconds = millis % 1000;

       return String.format("%d Days %d Hours %d Minutes %d Seconds %d Milliseconds",
                            days, hours, minutes, seconds, milliseconds);
   }
}