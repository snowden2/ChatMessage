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
class Blockers: NSObject {

	private var timer: Timer?
	private var refreshUIBlockers = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Blockers = {
		let instance = Blockers()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
		//-----------------------------------------------------------------------------------------------------------------------------------------
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

		let lastUpdatedAt = DBBlocker.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FBLOCKER_PATH).child(FUser.currentId())
		let query = firebase?.queryOrdered(byChild: FBLOCKER_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let blocker = snapshot.value as! [String: Any]
			if (blocker[FBLOCKER_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Blockers").async {
					self.updateRealm(blocker: blocker)
					self.refreshUIBlockers = true
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let blocker = snapshot.value as! [String: Any]
			if (blocker[FBLOCKER_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Blockers").async {
					self.updateRealm(blocker: blocker)
					self.refreshUIBlockers = true
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(blocker: [String: Any]) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBBlocker.createOrUpdate(in: realm, withValue: blocker)
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

	// MARK: - Notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshUserInterface() {

		if (refreshUIBlockers) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_BLOCKERS)
			refreshUIBlockers = false
		}
	}
}
