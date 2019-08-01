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
class AddFriendsView: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	private var users: [FUser] = []
	private var sections: [[FUser]] = []
	private let collation = UILocalizedIndexedCollation.current()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Add Friends"

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		tableView.register(UINib(nibName: "AddFriendsCell", bundle: nil), forCellReuseIdentifier: "AddFriendsCell")

		tableView.tableFooterView = UIView()

		loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dismissKeyboard() {

		view.endEditing(true)
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadUsers() {

		let firebase = Database.database().reference(withPath: FUSER_PATH)

		firebase.observeSingleEvent(of: DataEventType.value, with: { snapshot in
			self.users.removeAll()

			if (snapshot.exists()) {
				let dictionary = snapshot.value as! [String: Any]
				for value in dictionary.values {
					let temp = value as! [String: Any]
					if (temp["fullname"] != nil) {
						let user = FUser(path: FUSER_PATH, dictionary: temp)
						self.users.append(user)
					}
				}
			}

			self.setObjects()
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func setObjects() {

		sections.removeAll()

		sections = Array(repeating: [], count: collation.sectionTitles.count)

		let sorted = users.sorted(by: { $0.fullname() < $1.fullname() })
		for user in sorted {

			let fullname = user.fullname() as NSString
			let firstChar = fullname.substring(to: 1).uppercased()

			if let index = collation.sectionTitles.index(of: firstChar) {
				sections[index].append(user)
			} else {
				sections[collation.sectionTitles.endIndex-1].append(user)
			}
		}

		refreshTableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createFriend(user: FUser) {

		let userId = user.objectId()

		if (Friend.isFriend(userId: userId) == false) {
			Friend.createItem(userId: userId)
			LinkedId.createItem(userId: userId)
			ProgressHUD.showSuccess("Friend added.")
		} else {
			ProgressHUD.showSuccess("Already added.")
		}
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func refreshTableView() {

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		dismiss(animated: true)
	}

	// MARK: - UIScrollViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		dismissKeyboard()
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return sections.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return sections[section].count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		return (sections[section].count != 0) ? collation.sectionTitles[section] : nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {

		return collation.sectionIndexTitles
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

		return collation.section(forSectionIndexTitle: index)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsCell", for: indexPath) as! AddFriendsCell

		let user = sections[indexPath.section][indexPath.row]

		cell.bindData(user: user)
		cell.loadImage(user: user, tableView: tableView, indexPath: indexPath)

		return cell
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let user = sections[indexPath.section][indexPath.row]

		if (user.isCurrent() == false) {
			createFriend(user: user)
		} else {
			ProgressHUD.showSuccess("This is you.")
		}
	}

	// MARK: - UISearchBarDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		//loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

		searchBar.setShowsCancelButton(true, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

		searchBar.setShowsCancelButton(false, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.text = ""
		searchBar.resignFirstResponder()
		//loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
