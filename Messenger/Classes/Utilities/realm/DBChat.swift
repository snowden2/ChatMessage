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
class DBChat: RLMObject {

	@objc dynamic var chatId = ""

	@objc dynamic var recipientId = ""
	@objc dynamic var groupId = ""

	@objc dynamic var pictureAt: Int64 = 0
	@objc dynamic var initials = ""
	@objc dynamic var details = ""

	@objc dynamic var lastMessage = ""
	@objc dynamic var lastMessageDate: Int64 = 0
	@objc dynamic var lastIncoming: Int64 = 0

	@objc dynamic var isArchived = false
	@objc dynamic var isDeleted = false

	@objc dynamic var createdAt: Int64 = 0
	@objc dynamic var updatedAt: Int64 = 0

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override static func primaryKey() -> String? {

		return "chatId"
	}
}
