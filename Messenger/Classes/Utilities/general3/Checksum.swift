//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Checksum: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func md5HashOf(data: Data) -> String {

		var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
		_ = digestData.withUnsafeMutableBytes {digestBytes in
			data.withUnsafeBytes {messageBytes in
				CC_MD5(messageBytes, CC_LONG((data.count)), digestBytes)
			}
		}

		var md5 = ""
		for byte in digestData {
			md5 += String(format:"%02x", byte)
		}

		return md5
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func md5HashOf(path: String) -> String {

		if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
			return md5HashOf(data: data)
		}
		return ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func md5HashOf(string: String) -> String {

		if let data = string.data(using: .utf8) {
			return md5HashOf(data: data)
		}
		return ""
	}
}
