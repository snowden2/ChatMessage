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
class Blockeds: NSObject {

	private var timer: Timer?
	private var refreshUIBlockeds = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Blockeds = {
		let instance = Blockeds()
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

		let lastUpdatedAt = DBBlocked.lastUpdatedAt()

		firebase = Database.database().reference(withPath: FBLOCKED_PATH).child(FUser.currentId())
		let query = firebase?.queryOrdered(byChild: FBLOCKED_UPDATEDAT).queryStarting(atValue: lastUpdatedAt + 1)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let blocked = snapshot.value as! [String: Any]
			if (blocked[FBLOCKED_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Blockeds").async {
					self.updateRealm(blocked: blocked)
					self.refreshUIBlockeds = true
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let blocked = snapshot.value as! [String: Any]
			if (blocked[FBLOCKED_CREATEDAT] as? Int64 != nil) {
				DispatchQueue(label: "Blockeds").async {
					self.updateRealm(blocked: blocked)
					self.refreshUIBlockeds = true
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(blocked: [String: Any]) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBBlocked.createOrUpdate(in: realm, withValue: blocked)
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

		if (refreshUIBlockeds) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_BLOCKEDS)
			refreshUIBlockeds = false
		}
	}
}
