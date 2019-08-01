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
class CallsView: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView!

	private var timer: Timer?
	private var dbcallhistories: RLMResults = DBCallHistory.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(named: "tab_calls")
		tabBarItem.title = "Calls"

		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
		NotificationCenterX.addObserver(target: self, selector: #selector(refreshTableView), name: NOTIFICATION_REFRESH_CALLHISTORIES)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Calls"

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(actionClearAll))

		timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(refreshTableView), userInfo: nil, repeats: true)

		tableView.tableFooterView = UIView()

		loadCallHistories()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (FUser.currentId() != "") {
			if (FUser.isOnboardOk()) {
				refreshTableView()
			} else {
				OnboardUser(target: self)
			}
		} else {
			LoginUser(target: self)
		}
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadCallHistories() {

		let predicate = NSPredicate(format: "isDeleted == NO")
		dbcallhistories = DBCallHistory.objects(with: predicate).sortedResults(usingKeyPath: FCALLHISTORY_CREATEDAT, ascending: false)

		refreshTableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteCallHistory(dbcallhistory: DBCallHistory) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			dbcallhistory.isDeleted = true
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteCallHistories() {

		for i in 0..<dbcallhistories.count {
			let dbcallhistory = dbcallhistories[i] as! DBCallHistory
			CallHistory.deleteItem(objectId: dbcallhistory.objectId)
		}
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView() {

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionClearAll() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { action in
			self.deleteCallHistories()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCallAudio(userId: String) {

		let callAudioView = CallAudioView(userId: userId)
		present(callAudioView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCallVideo(userId: String) {

		let callVideoView = CallVideoView(userId: userId)
		present(callVideoView, animated: true)
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		refreshTableView()
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return min(Int(dbcallhistories.count), 25)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let dbcallhistory = dbcallhistories[UInt(indexPath.row)] as! DBCallHistory
		cell.textLabel?.text = dbcallhistory.text

		cell.detailTextLabel?.text = dbcallhistory.status
		cell.detailTextLabel?.textColor = UIColor.gray

		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
		label.text = TimeElapsed(timestamp: dbcallhistory.startedAt)
		label.textAlignment = .right
		label.textColor = UIColor.gray
		label.font = UIFont.systemFont(ofSize: 11)
		cell.accessoryView = label

		return cell
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		return true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		let dbcallhistory = dbcallhistories[UInt(indexPath.row)] as! DBCallHistory

		deleteCallHistory(dbcallhistory: dbcallhistory)

		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			CallHistory.deleteItem(objectId: dbcallhistory.objectId)
		}
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbcallhistory = dbcallhistories[UInt(indexPath.row)] as! DBCallHistory
		let userId = (dbcallhistory.recipientId == FUser.currentId()) ? dbcallhistory.initiatorId : dbcallhistory.recipientId

		if (dbcallhistory.type == CALLHISTORY_AUDIO) { actionCallAudio(userId: userId)	}
		if (dbcallhistory.type == CALLHISTORY_VIDEO) { actionCallVideo(userId: userId)	}
	}
}
