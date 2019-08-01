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
class UserStatuses: NSObject {

	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: UserStatuses = {
		let instance = UserStatuses()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				checkItems()
				createObservers()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func checkItems() {

		let reference = Database.database().reference(withPath: FUSERSTATUS_PATH)
		reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			if (snapshot.exists() == false) {
				UserStatus.createItems()
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		let lastUpdatedAt = DBUserStatus.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FUSERSTATUS_PATH)
		let query = firebase?.queryOrdered(byChild: FUSERSTATUS_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let userStatus = snapshot.value as! [String: Any]
			if (userStatus[FUSERSTATUS_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "UserStatuses").async {
					self.updateRealm(userStatus: userStatus)
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let userStatus = snapshot.value as! [String: Any]
			if (userStatus[FUSERSTATUS_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "UserStatuses").async {
					self.updateRealm(userStatus: userStatus)
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(userStatus: [String: Any]) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBUserStatus.createOrUpdate(in: realm, withValue: userStatus)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		firebase?.removeAllObservers()
		firebase = nil
	}
}
