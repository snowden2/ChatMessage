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
class Messages: NSObject {

	var chatId = ""

	private var timer: Timer?
	private var refreshUIChats = false
	private var refreshUIMessages1 = false
	private var refreshUIMessages2 = false
	private var playMessageIncoming = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Messages = {
		let instance = Messages()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func assignChatId(chatId: String) {

		shared.chatId = chatId
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func resignChatId() {

		shared.chatId = ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)

		timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(refreshUserInterface), userInfo: nil, repeats: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				createObservers()
			}
		}
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		let lastUpdatedAt = DBMessage.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FMESSAGE_PATH).child(FUser.currentId())
		let query = firebase?.queryOrdered(byChild: FMESSAGE_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let message = snapshot.value as! [String: Any]
			if (message[FMESSAGE_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Messages").async {
					self.updateRealm(message: message)
					self.updateChat(message: message)
					self.playMessageIncoming(message: message)
					self.refreshUserInterface1(message: message)
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let message = snapshot.value as! [String: Any]
			if (message[FMESSAGE_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Messages").async {
					self.updateRealm(message: message)
					self.updateChat(message: message)
					self.refreshUserInterface2(message: message)
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(message: [String: Any]) {

		var temp = message

		let members = message[FMESSAGE_MEMBERS] as! [String]
		let chatId = message[FMESSAGE_CHATID] as! String
		let text = message[FMESSAGE_TEXT] as! String

		temp[FMESSAGE_MEMBERS] = members.joined(separator: ",")
		temp[FMESSAGE_TEXT] = Cryptor.decrypt(text: text, chatId: chatId)

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBMessage.createOrUpdate(in: realm, withValue: temp)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateChat(message: [String: Any]) {

		let chatId = message[FMESSAGE_CHATID] as! String

		Chat.updateChat(chatId: chatId)
		refreshUIChats = true
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		firebase?.removeAllObservers()
		firebase = nil
	}

	// MARK: - Notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUserInterface1(message: [String: Any]) {

		if (message[FMESSAGE_CHATID] as! String == chatId) {
			refreshUIMessages1 = true
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshUserInterface2(message: [String: Any]) {

		if (message[FMESSAGE_CHATID] as! String == chatId) {
			refreshUIMessages2 = true
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func playMessageIncoming(message: [String: Any]) {

		if (message[FMESSAGE_CHATID] as! String == chatId) {
			if (message[FMESSAGE_ISDELETED] as! Bool == false) {
				if (message[FMESSAGE_TYPE] as! String != MESSAGE_STATUS) {
					if (message[FMESSAGE_SENDERID] as! String != FUser.currentId()) {
						playMessageIncoming = true
					}
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshUserInterface() {

		if (refreshUIChats) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_CHATS)
			refreshUIChats = false
		}

		if (refreshUIMessages1) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_MESSAGES1)
			refreshUIMessages1 = false
		}

		if (refreshUIMessages2) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_MESSAGES2)
			refreshUIMessages2 = false
		}

		if (playMessageIncoming) {
			Audio.playMessageIncoming()
			playMessageIncoming = false
		}
	}
}
