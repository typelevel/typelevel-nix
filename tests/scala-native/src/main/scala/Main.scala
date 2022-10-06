import java.util.zip._

object Main {
  def main(args: Array[String]): Unit = {
    // Encode a String into bytes
    val inputString = "blahblahblah"
    val input = inputString.getBytes("UTF-8")

    // Compress the bytes
    val output = new Array[Byte](100)
    val compresser = new Deflater()
    compresser.setInput(input)
    compresser.finish()
    val compressedDataLength = compresser.deflate(output)
    compresser.end()

    // Decompress the bytes
    val decompresser = new Inflater()
    decompresser.setInput(output, 0, compressedDataLength)
    val result = new Array[Byte](100)
    val resultLength = decompresser.inflate(result)

    // Decode the bytes into a String
    val outputString = new String(result, 0, resultLength, "UTF-8")
    println(outputString)
  }
}
