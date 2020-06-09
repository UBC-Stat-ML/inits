package xbinc

import binc.Command
import java.io.File
import briefj.BriefIO
import blang.inits.experiments.ExperimentResults

class Extensions {
  def static !(Command c) {
    Command::call(c)
  }
  def static >(Command c, File f) {
    c.saveOutputTo(f)
  }
  def static +(Command c, String args) {
    c.appendArg(args)
  }
  def static +(Command c, File f) {
    c.appendArg(f.absolutePath)
  }
  def static *(Command c, String args) {
    c.appendArgs(args)
  }
  def static <(Command c, String input) {
    c.callWithInputStreamContents(input)
  }
  
  def static File <(File f, String s) {
    BriefIO::stringToFile(f, s)
    return f
  }
  
  def static File /(File f, String s) {
    return new File(f, s)
  }
  def static File /(ExperimentResults result, String s) {
    return result.getFileInResultFolder(s)
  }
}