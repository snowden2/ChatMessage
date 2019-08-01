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
class Groups: NSObject {

	private var timer: Timer?
	private var refreshUIGroups = false
	private var refreshUIChats = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Groups = {
		let instance = Groups()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)

		timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(refreshUserInterface), userInfo: nil, repeats: true)
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				createObservers()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		let lastUpdatedAt = DBGroup.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FGROUP_PATH)
		let query = firebase?.queryOrdered(byChild: FGROUP_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let group = snapshot.value as! [String: Any]
			if (group[FGROUP_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Groups").async {
					self.updateRealm(group: group)
					self.updateChat(group: group)
					self.refreshUIGroups = true
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let group = snapshot.value as! [String: Any]
			if (group[FGROUP_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Groups").async {
					self.updateRealm(group: group)
					self.updateChat(group: group)
					self.refreshUIGroups = true
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(group: [String: Any]) {

		var temp = group

		let members = group[FGROUP_MEMBERS] as! [String]
		temp[FGROUP_MEMBERS] = members.joined(separator: ",")

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBGroup.createOrUpdate(in: realm, withValue: temp)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateChat(group: [String: Any]) {

		let members = group[FGROUP_MEMBERS] as! [String]
		let objectId = group[FGROUP_OBJECTID] as! String
		let isDeleted = group[FGROUP_ISDELETED] as! Bool

		let isMember = members.contains(FUser.currentId())

		if (isDeleted || !isMember) {
			let chatId = Chat.chatId(groupId: objectId)
			Chat.removeChat(chatId: chatId)
			refreshUIChats = true
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		firebase?.removeAllObservers()
		firebase = nil
	}

	// MARK: - Notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshUserInterface() {

		if (refreshUIGroups) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_GROUPS)
			refreshUIGroups = false
		}

		if (refreshUIChats) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_CHATS)
			refreshUIChats = false
		}
	}
}
