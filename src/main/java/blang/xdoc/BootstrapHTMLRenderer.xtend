package blang.xdoc

import java.io.File
import java.util.Collection
import briefj.BriefIO
import java.util.List
import java.util.ArrayList
import blang.xdoc.components.Code.Language
import blang.xdoc.components.LinkTarget.LinkURL
import java.util.LinkedHashMap
import briefj.BriefMaps
import blang.xdoc.Renderer
import blang.xdoc.components.Document
import blang.xdoc.components.DownloadButton
import blang.xdoc.components.Bullets
import blang.xdoc.components.Link
import blang.xdoc.components.DocElement
import blang.xdoc.components.Section
import blang.xdoc.components.Code
import blang.xdoc.components.MiniDoc
import static extension org.apache.commons.lang3.StringEscapeUtils.escapeHtml4
import blang.xdoc.components.Embed
import com.google.common.collect.Table
import blang.xdoc.components.KeyValues
import blang.xdoc.components.Box
import blang.xdoc.components.Clipboard

class BootstrapHTMLRenderer implements Renderer  {
  
  val String siteName
  public val Collection<Document> documents = new ArrayList
  var State state = null
  
  new(String siteName) {
    this.siteName = siteName
  }
  
  def void renderInto(File folder) {
    for (Document document : documents) {
      val File file = new File(folder, document.fileName)
      BriefIO.write(file, document.render(this).replaceAll("\\s*" + NO_TRAILING_SPACE, "\n"))  // replaceAll("\\s*" + NO_TRAILING_SPACE + "[^\n]", "")
    }
  } 
  
  static private class State {
    var int currentSectionDepth = 0
    var int currentOrderedListDepth = 0
    var int currentUnorderedListDepth = 0
    // var boolean usesMathJax = false // always load; since they recommend placing the tag early 
    val List<Language> codeModes = new ArrayList
    val List<DownloadButton> downloadButtons = new ArrayList
    val List<Clipboard> clipboards = new ArrayList
  }
  
  def String container() { "container" }
  def String htmlSupportFilesPrefix() { "." }
  
  def dispatch String render(Document document) {
    state = new State
    return '''
      <!DOCTYPE html>
      <!-- Warning This page was generated by «this.class.name». Do not edit directly! -->
      <html lang="en">
        «header(document)»
        <body>
          <div class="«container»">
            «navBar(document)»
            «recurse(document).join("\n")»
          </div>
          <!-- Placed at the end of the document so the pages load faster -->
          <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
          <script>window.jQuery || document.write('<script src="«htmlSupportFilesPrefix»/assets/js/vendor/jquery.min.js"><\/script>')</script>
          <script src="«htmlSupportFilesPrefix»/dist/js/bootstrap.min.js"></script>
          
          «IF !state.clipboards.empty»
          <script>
            «FOR c : state.clipboards»
              function «c.id»() {
                var copyText = document.getElementById("«c.id»");
                copyText.select();
                copyText.setSelectionRange(0, 99999); 
                document.execCommand("copy");
              }
            «ENDFOR»
          </script>
          «ENDIF»
          
          «IF !state.downloadButtons.empty»
          <script>
            «FOR i : 0 ..< state.downloadButtons.size»
              function DownloadAndRedirect«i»()
              {
                «IF state.downloadButtons.get(i).redirect !== null»
                  var RedirectURL«i» = "«resolveLink(state.downloadButtons.get(i).redirect)»";
                «ENDIF»
                var RedirectPauseSeconds = 2;
                location.href = "«resolveLink(state.downloadButtons.get(i).file)»";
                «IF state.downloadButtons.get(i).redirect !== null»
                  setTimeout("DoTheRedirect«i»('"+RedirectURL«i»+"')",parseInt(RedirectPauseSeconds*1000));
                «ENDIF»
              }
              function DoTheRedirect«i»(url) { window.location=url; }
            «ENDFOR»
          </script>
          «ENDIF»
          
          «IF !state.codeModes.empty»
            <script src="ace/ace.js" type="text/javascript" charset="utf-8"></script>
            <script>
              «FOR i : 0 ..< state.codeModes.size»
                var editor«i» = ace.edit("editor«i»");
                editor«i».setTheme("ace/theme/gruvbox");
                editor«i».session.setMode("ace/mode/«state.codeModes.get(i)»");
                editor«i».setOptions({
                  readOnly: true,
                  showPrintMargin: false
                });
              «ENDFOR»
            </script>
          «ENDIF»
        </body>
      </html>
    '''
  }
  
  static final List<String> orderedStyles = #["1", "a", "i", "A", "I"]
  static final List<String> unorderedStyles = #["disc", "square", "circle"]
  def dispatch String render(Bullets bullets) {
    val String tag = if (bullets.ordered) "ol" else "ul"
    val int styleIndex = if (bullets.ordered) state.currentOrderedListDepth++ else state.currentUnorderedListDepth++
    val List<String> styleList = if (bullets.ordered) orderedStyles else unorderedStyles
    val String style = styleList.get(styleIndex % styleList.size)
    val String styleString = if (bullets.ordered) '''type="«style»"''' else '''style="list-style-type:«style»"'''
    var int i = 0
    val String result = '''
    <«tag» «styleString»>
      «FOR child : recurse(bullets)»
        «IF !(bullets.children.get(i) instanceof Bullets)»<li>«ENDIF»
          «child»
        «IF !(bullets.children.get(i++) instanceof Bullets)»</li>«ENDIF»
      «ENDFOR»
    </«tag»>
    '''
    if (bullets.ordered) state.currentOrderedListDepth-- else state.currentUnorderedListDepth--
    return result
  }
  
  def dispatch String render(DownloadButton button) {
    state.downloadButtons.add(button)
    return '''
      <div class="text-center"> 
        <br/>
        <a href="javascript:DownloadAndRedirect«state.downloadButtons.size - 1»()" role="button" class="btn-success btn-lg">
          «button.label»
        </a>
        <br/>
      </div> 
    '''
  }
  
  def dispatch String render(Clipboard clip) {
    state.clipboards.add(clip)
    return '''
      <div class="text-center"> 
        <br/>
        <div class="input-group">
          <span class="input-group-btn">
            <button onclick="«clip.id»()" class="btn btn-default" type="button"><span class="glyphicon glyphicon-copy" aria-hidden="true"></span></button>
          </span>
          <input type="text" class="form-control" id="«clip.id»" value="«clip.contents»">
        </div>
        <br/>
      </div>
    '''
  }
  
  def dispatch String render(Embed embed) {
    val type = if (embed.file.name.endsWith("pdf")) "application/pdf" else "text/plain"
    return '''
      <div class="panel panel-default">
        <div class="panel-heading">
          <h3 class="panel-title">«render(embed.title)»</h3>
        </div>
        <div class="panel-body text-center">
          <embed src="«embed.file»" type="«type»" width="«embed.width»" height="«embed.height»">
        </div>
      </div>
    '''
  }
  
  def dispatch String render(blang.xdoc.components.Table table) {
    if (table.rows.empty) return ""
    return '''
      <table class="table table-hover table-condensed "> 
        <thead> 
          <tr> 
            «FOR c : table.rows.get(0).keySet»
            <th>«render(c)»</th> 
            «ENDFOR»
          </tr> 
        </thead> 
        <tbody> 
          «FOR r : table.rows»
          <tr> 
            «IF r.keySet.size === 1 && r.keySet.get(0) === null»
              <td colspan="«table.rows.get(0).keySet.size»">«render(r.values.get(0))»</td>
            «ELSE»
              «FOR v : r.values»
              <td>«render(v)»</td> 
              «ENDFOR»
            «ENDIF»
          </tr> 
          «ENDFOR»
        </tbody> 
      </table>
    '''
  }
  
  def dispatch String render(Table<?,?,?> table) {
    return '''
      <table class="table table-hover table-condensed "> 
        <thead> 
          <tr> 
            <th></th> 
            «FOR c : table.columnKeySet»
            <th>«render(c)»</th> 
            «ENDFOR»
          </tr> 
        </thead> 
        <tbody> 
          «FOR r : table.rowKeySet»
          <tr> 
            <th scope="row">«render(r)»</th> 
            «FOR c : table.columnKeySet»
            <td>«render(table.get(r,c))»</td> 
            «ENDFOR»
          </tr> 
          «ENDFOR»
        </tbody> 
      </table>
    '''
  }
  
  def dispatch String render(KeyValues keyVals) {
    return '''
      <table class="table table-hover"> 
        <tbody> 
          «FOR keyVal : keyVals.items»
          <tr> 
            <th scope="row">«render(keyVal.key)»</th> 
            <td>«render(keyVal.value)»</td> 
          </tr> 
          «ENDFOR»
        </tbody> 
      </table>
    '''
  }
  
  def dispatch String render(Link link) {
    '''<a href="«resolveLink(link.target)»">'''
  }
  
  def dispatch String render(Object object) {
    switch (object) {
      case DocElement._SYMB : "<code>"
      case DocElement._ENDSYMB : "</code>"
      case DocElement._MATH : "\\( "
      case DocElement._ENDMATH : " \\)"
      case DocElement._EQN : "\\[\\begin{align} "
      case DocElement._ENDEQN : " \\end{align}\\]"
      case DocElement._EMPH : "<em>"
      case DocElement._ENDEMPH : "</em>"
      case DocElement._ENDLINK : "</a>"
      default :
        '''
          «FOR segment : object.toString.split("\\R\\s*\\R")»
            <p>
              «segment»
            </p>
          «ENDFOR»
        '''
    }
  }
  
  var firstDepth = 2
  def dispatch String render(Section section) {
    val int depth = state.currentSectionDepth++
    val int hDepth = firstDepth + depth
    if (hDepth >= 5 || hDepth < 1) {
      throw new RuntimeException("Invalid hX level: " + hDepth)
    }
    val String result = '''
      <h«hDepth+1»«IF depth == 1» class="page-header"«ENDIF»>«section.name»</h«hDepth+1»>
      «recurse(section).join("\n")»
      '''
    state.currentSectionDepth--
    return result
  }
  
  def dispatch String render(Box box) {
    return '''
      <div class="panel panel-default">
        <div class="panel-heading">
          <h3 class="panel-title">«box.name»</h3>
        </div>
        <div class="panel-body">
          «recurse(box).join("\n")»
        </div>
      </div>
    '''
  }
  
  def dispatch String render(Code code) {
    state.codeModes += code.language
    val String processedCode = noTrailingSpace(code.contents.escapeHtml4)
    return '''
      <div id="editor«state.codeModes.size - 1»" style="height: «codeHeight(code.contents)»em;">«processedCode»</div>
      <br />
    '''
  }
  
  def dispatch String render(MiniDoc miniDoc) {
    return '''
      <p>
        <strong>«miniDoc.declaration.escapeHtml4»</strong>: «miniDoc.doc.escapeHtml4»
        «IF !miniDoc.children.empty»
          <ul>
            «FOR children : miniDoc.children»
              <li>
                <code>«children.declaration.escapeHtml4»</code>«IF !children.doc.matches("\\s*")»: «children.doc.escapeHtml4»«ENDIF»
              </li>
            «ENDFOR»
          </ul>
        «ENDIF»
      </p>
    '''
  }
  
  def String codeHeight(String contents) {
    val int n = (contents.split("\\R").size * 1.4) as int
    return "" + (n+1)
  }
  
  public static val String NO_TRAILING_SPACE = "____NO_TRAILING_SPACE"
  def public static String noTrailingSpace(String text) {
    return text.split("\\R").map[NO_TRAILING_SPACE + it].join('\n').replaceFirst(NO_TRAILING_SPACE, "")
  }
  
  def protected List<String> recurse(DocElement element) {
    return element.children.map[it |
      if (it instanceof DocElement) {
        it.render(this)
      } else {
        render(it)
      }
    ]
  }
  
  def private navBar(Document document) {
    val NavStructure navStructure = new NavStructure(documents)
    return '''
      <div class="header clearfix">
        <nav>
          <ul class="nav nav-pills pull-right">
            «FOR heading : navStructure.headings»
              «IF navStructure.isCategory(heading)»
                «navLinkCategory(heading, navStructure.documentsInCategory(heading))»
              «ELSE»
                «navLink(navStructure.document(heading), navStructure.document(heading) === document)»
              «ENDIF»
            «ENDFOR»
            «navAdditionalLogos»
          </ul>
        </nav>
        <h3 class="text-muted">«siteName»</h3>
      </div>
    '''
  }
  
  def protected String navAdditionalLogos() { "" }
  
  def private navLink(Document menuItem, boolean isActive) {
    '''
      <li role="presentation"«IF isActive» class="active"«ENDIF»>
        <a href="«menuItem.fileName»">«menuItem.name»</a>
      </li>
    '''
  }
  
  def private navLinkCategory(String categoryName, List<Document> documents) {
    val String id = "category" + categoryName.hashCode
    return '''
      <li>
        <a id="«id»" data-target="#" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
          «categoryName»
          <span class="caret"></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-right" aria-labelledby="«id»">
          «FOR document : documents»
            <li><a href="«document.fileName»">«document.name»</a></li>
          «ENDFOR»
        </ul>
      </li>
    '''
  }
  
  static class NavStructure {
    val LinkedHashMap map = new LinkedHashMap
    new(Collection<Document> documents) {
      for (Document doc : documents) {
        if (doc.category === null) {
          if (map.containsKey(doc.name)) {
            throw new RuntimeException("Two pages with same name not allowed.")
          }
          map.put(doc.name, doc)
        } else {
          BriefMaps.getOrPutList(map, doc.category).add(doc)
        }
      }
    }
    def Collection<String> headings() {
      map.keySet
    }
    def boolean isCategory(String heading) {
      map.get(heading) instanceof Collection
    }
    def List<Document> documentsInCategory(String heading) {
      map.get(heading) as List
    }
    def Document document(String heading) {
      map.get(heading) as Document
    }
  }
  
  def private header(Document document) {
    '''
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <meta name="description" content="Blang documentation">
    
        <title>«document.name»</title>
        
«««        <!-- note: keep \\( below as used in MATH annotations -->
        <script type="text/x-mathjax-config">
          MathJax.Hub.Config({
            tex2jax: {
              inlineMath: [ ['$','$'], ["\\(","\\)"] ], 
              processEscapes: true
            }
          });
        </script>
        
        <script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_CHTML'></script>
    
        <!-- Bootstrap core CSS -->
        <link href="«htmlSupportFilesPrefix»/dist/css/bootstrap.min.css" rel="stylesheet">
    
        <!-- Custom styles for this template -->
        <link href="«htmlSupportFilesPrefix»/jumbotron-narrow.css" rel="stylesheet">
    
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
      </head>
    '''
  }
  
  def protected dispatch String resolveLink(LinkURL link) { 
    link.url
  }
  
  def protected dispatch String resolveLink(Document document) {
    fileName(document)
  }
  
  def static String fileName(Document document) {
    if (document.isIndex) return "index.html"
    document.name.replaceAll(" ", "_") + ".html"
  }
}