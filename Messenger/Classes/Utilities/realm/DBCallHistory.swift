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
class DBCallHistory: RLMObject {

	@objc dynamic var objectId = ""

	@objc dynamic var initiatorId = ""
	@objc dynamic var recipientId = ""
	@objc dynamic var phoneNumber = ""

	@objc dynamic var type = ""
	@objc dynamic var text = ""

	@objc dynamic var status = ""
	@objc dynamic var duration: Int = 0

	@objc dynamic var startedAt: Int64 = 0
	@objc dynamic var establishedAt: Int64 = 0
	@objc dynamic var endedAt: Int64 = 0

	@objc dynamic var isDeleted = false

	@objc dynamic var createdAt: Int64 = 0
	@objc dynamic var updatedAt: Int64 = 0

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func lastUpdatedAt() -> Int64 {

		let dbcallhistory = DBCallHistory.allObjects().sortedResults(usingKeyPath: "updatedAt", ascending: true).lastObject() as? DBCallHistory
		return dbcallhistory?.updatedAt ?? 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override static func primaryKey() -> String? {

		return FCALLHISTORY_OBJECTID
	}
}
