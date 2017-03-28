package blang.inits.parsing

import java.io.File
import org.apache.commons.csv.CSVParser
import java.nio.charset.StandardCharsets
import org.apache.commons.csv.CSVFormat
import org.apache.commons.csv.CSVRecord
import blang.inits.parsing.Arguments.ArgumentItem
import java.util.List
import java.util.ArrayList

class CSVFile {
  
  def static Arguments parseTSV(File f) {
    return parseCSV(f, CSVFormat.TDF)
  }
  
  def static Arguments parseCSV(File f) {
    return parseCSV(f, CSVFormat.RFC4180)
  }
  
  def static Arguments parseCSV(File f, CSVFormat format) {
    val List<ArgumentItem> items = new ArrayList
    val CSVParser parser = CSVParser.parse(f, StandardCharsets.UTF_8, format)
    for (CSVRecord csvRecord : parser) {
      val key = csvRecord.get(0).split("[.]")
      val value = csvRecord.get(1).split("\\s+")
      items.add(new ArgumentItem(key, value))
    }
    return Arguments.parse(items)
  }
  
}