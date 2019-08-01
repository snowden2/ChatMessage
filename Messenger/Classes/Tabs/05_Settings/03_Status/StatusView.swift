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
class StatusView: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var cellStatus: UITableViewCell!
	@IBOutlet var cellClear: UITableViewCell!

	private var dbuserstatuses: RLMResults = DBUserStatus.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Status"

		loadStatuses()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		loadUser()
	}

	// MARK: - Backend actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadStatuses() {

		dbuserstatuses = DBUserStatus.allObjects().sortedResults(usingKeyPath: FUSERSTATUS_CREATEDAT, ascending: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUser() {

		cellStatus.textLabel?.text = FUser.status()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser(status: String) {

		let user = FUser.currentUser()
		user[FUSER_STATUS] = status
		user.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return (dbuserstatuses.count == 0) ? 1 : 3
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1							}
		if (section == 1) { return Int(dbuserstatuses.count)	}
		if (section == 2) { return 1							}

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 0) { return "Your current status is"	}
		if (section == 1) { return "Select your new status"	}

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) {
			return cellStatus
		}

		if (indexPath.section == 1) {
			var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
			if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

			let dbuserstatus = dbuserstatuses[UInt(indexPath.row)] as! DBUserStatus
			cell.textLabel?.text = dbuserstatus.name

			return cell
		}

		if (indexPath.section == 2) && (indexPath.row == 0) {
			return cellClear
		}

		return UITableViewCell()
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) {
			let customStatusView = CustomStatusView()
			let navController = NavigationController(rootViewController: customStatusView)
			present(navController, animated: true)
		}

		if (indexPath.section == 1) {
			let dbuserstatus = dbuserstatuses[UInt(indexPath.row)] as! DBUserStatus
			saveUser(status: dbuserstatus.name)
			updateStatus(status: dbuserstatus.name)
		}

		if (indexPath.section == 2) {
			saveUser(status: "")
			updateStatus(status: "")
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateStatus(status: String) {

		cellStatus.textLabel?.text = status
		tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
	}
}
