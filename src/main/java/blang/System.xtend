package blang

import java.io.PrintStream
import java.io.OutputStream
import java.util.LinkedList
import org.apache.commons.lang3.StringUtils
import com.google.common.base.Stopwatch

class System {
  
  static LinkedList<Level> stack = new LinkedList
  public static HierarchicalPrintStream out = setup(true)
  public static HierarchicalPrintStream err = setup(false)
  
  def private static HierarchicalPrintStream setup(boolean out) {
    val result = new HierarchicalPrintStream(if (out) java.lang.System.out else java.lang.System.err, stack, !out)
    if (out) java.lang.System.setOut(result) else java.lang.System.setErr(result)
    return result
  }
  
  static class HierarchicalPrintStream extends PrintStream {
    
    public Formats formats = new Formats
    
    val LinkedList<Level> stack
    val boolean isError
  
    public String indentString = "  "
    public int maxIndentationToPrint = Integer.MAX_VALUE;
    
    def void silence() {
      maxIndentationToPrint = -1
    }
    
    def void verbose() {
      maxIndentationToPrint = Integer.MAX_VALUE
    }
    
    private new(OutputStream out, LinkedList<Level> stack, boolean isError) {
      super(out)
      this.stack = stack
      this.isError = isError
    }
    
    override void println(String string) {
      this.println(string as Object)
    }
    
    override void println(Object object) {
      val currentIndent = stack.size
      if (currentIndent > maxIndentationToPrint) {
        return
      }
      if (currentIndent == 0) 
        super.println(object)
      else {
        if (isError) stack.last.nErrors++
        val indent = StringUtils::repeat(indentString, currentIndent)
        super.println(indent + object.toString.replace("\n", "\n" + indent))
      }
    }
    
    def void formatlnJoinedBy(String sep, Object ... objects) {
      println(objects.map[formats.format(it)].join(sep))
    }
    
    def void formatln(Object ... objects) {
      formatlnJoinedBy(" ", objects)
    }
    
    def void indent(Level level) {
      stack.add(level)
    }
    
    def void indent() {
      indent(new Level)
    }
    
    def void indentWithTiming(String blockName) {
      println(blockName + " {")
      indent(new Level() {
        override void reportPop() {
          formatln("}", 
            "[",
              "endingBlock" -> blockName,
              "blockTime" -> watch,
              "blockNErrors" -> nErrors,
            "]"
          )
        }
      })
    }
    
    def Level indent(Runnable block) {
      indentWithTiming(null, block)
    }
    
    def Level indentWithTiming(String blockName, Runnable block) {
      if (blockName === null) indent else indentWithTiming(blockName)
      var Level result = null
      try { block.run }
      finally { result = popIndent }
      return result
    }
    
    def int currentIndentLevel() { return stack.size }
    
    def Level popIndent() {
      return if (stack.empty) {
        java.lang.System.err.println("Encountered negative indentation")
        null
      } else {
        val level = stack.pollLast
        level.watch.stop
        if (!stack.empty)
          stack.last.nErrors += level.nErrors
        level.reportPop
        return level
      }
    }
    
    def void popAll() {
      while (currentIndentLevel > 0)
        popIndent
    }
  }
  
  static class Level {
    public val Stopwatch watch = Stopwatch::createStarted
    public var int nErrors = 0
    def void reportPop() {}
  }
  
  def static currentTimeMillis() { return java.lang.System.currentTimeMillis }
  def static nanoTime() { return java.lang.System.nanoTime }
  def static exit(int code) { 
    out.popAll
    out.flush
    err.flush
    java.lang.System.exit(code)
  }
  
}