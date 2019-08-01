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
class Chat: NSObject {

	// MARK: - Update methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateChat(chatId: String) {

		let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
		let dbmessages = DBMessage.objects(with: predicate).sortedResults(usingKeyPath: FMESSAGE_CREATEDAT, ascending: true)

		if let dbmessage = dbmessages.lastObject() as? DBMessage {
			updateItem(dbmessage: dbmessage)
		} else {
			removeChat(chatId: chatId)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func removeChat(chatId: String) {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		if let dbchat = DBChat.objects(with: predicate).firstObject() as? DBChat {
			deleteItem(dbchat: dbchat)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateItem(dbmessage: DBMessage) {
		
		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()

			let dbchat = fetchOrCreateItem(chatId: dbmessage.chatId)

			let outgoing = (dbmessage.senderId == FUser.currentId())
			let incoming = (dbmessage.senderId != FUser.currentId())

			if (dbmessage.recipientId.count != 0) {
				dbchat.groupId		= ""
				dbchat.recipientId	= outgoing ? dbmessage.recipientId			: dbmessage.senderId
				dbchat.pictureAt	= outgoing ? dbmessage.recipientPictureAt	: dbmessage.senderPictureAt
				dbchat.initials		= outgoing ? dbmessage.recipientInitials	: dbmessage.senderInitials
				dbchat.details		= outgoing ? dbmessage.recipientName		: dbmessage.senderName
			}

			if (dbmessage.groupId.count != 0) {
				dbchat.recipientId	= ""
				dbchat.groupId		= dbmessage.groupId
				dbchat.pictureAt	= 0
				dbchat.initials		= String(dbmessage.groupName.prefix(1))
				dbchat.details		= dbmessage.groupName
			}

			dbchat.lastMessage = dbmessage.text
			dbchat.lastMessageDate = dbmessage.createdAt
			if (incoming) {
				dbchat.lastIncoming = dbmessage.createdAt
			}

			dbchat.isArchived = false
			dbchat.isDeleted = false

			dbchat.createdAt = Date().timestamp()
			dbchat.updatedAt = Date().timestamp()

			realm.addOrUpdate(dbchat)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func fetchOrCreateItem(chatId: String) -> DBChat {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		if let dbchat = DBChat.objects(with: predicate).firstObject() as? DBChat {
			return dbchat
		}

		let dbchat = DBChat()
		dbchat.chatId = chatId
		return dbchat
	}

	// MARK: - Delete, Archive methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(dbchat: DBChat) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			dbchat.isDeleted = true
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func archiveItem(dbchat: DBChat) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			dbchat.isArchived = true
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func unarchiveItem(dbchat: DBChat) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			dbchat.isArchived = false
			try realm.commitWriteTransaction()

		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: - ChatId methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(recipientId: String) -> String {

		let currentId = FUser.currentId()
		let members = [currentId, recipientId]
		let sorted = members.sorted{$0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
		return Checksum.md5HashOf(string: sorted.joined(separator: ""))
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func chatId(groupId: String) -> String {

		return Checksum.md5HashOf(string: groupId)
	}
}
