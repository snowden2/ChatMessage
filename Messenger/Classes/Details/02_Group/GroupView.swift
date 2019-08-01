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
class GroupView: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, SelectUsersDelegate {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var cellDetails: UITableViewCell!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var cellMedia: UITableViewCell!
	@IBOutlet var cellLeave: UITableViewCell!
	@IBOutlet var viewFooter: UIView!
	@IBOutlet var labelFooter1: UILabel!
	@IBOutlet var labelFooter2: UILabel!

	private var groupId = ""
	private var dbgroup: DBGroup = DBGroup()
	private var dbusers: RLMResults = DBUser.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(groupId groupId_: String) {

		super.init(nibName: nil, bundle: nil)

		groupId = groupId_
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Group"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "group_more"), style: .plain, target: self, action: #selector(actionMore))

		tableView.tableFooterView = viewFooter

		loadGroup()
		loadUsers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		NotificationCenterX.addObserver(target: self, selector: #selector(loadGroup), name: NOTIFICATION_REFRESH_GROUPS)
		NotificationCenterX.addObserver(target: self, selector: #selector(loadUsers), name: NOTIFICATION_REFRESH_GROUPS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		NotificationCenterX.removeObserver(target: self)
	}

	// MARK: - Realm actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadGroup() {

		let predicateGroup = NSPredicate(format: "objectId == %@", groupId)
		dbgroup = DBGroup.objects(with: predicateGroup).firstObject() as! DBGroup

		labelName.text = dbgroup.name

		let predicateUser = NSPredicate(format: "objectId == %@", dbgroup.userId)
		let dbuser = DBUser.objects(with: predicateUser).firstObject() as! DBUser

		labelFooter1.text = "Created by \(dbuser.fullname)"
		labelFooter2.text = Date2MediumTime(date: Date.date(timestamp: dbgroup.createdAt))
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadUsers() {

		let members = dbgroup.members.components(separatedBy: ",")
		let predicate = NSPredicate(format: "objectId IN %@", members)

		dbusers = DBUser.objects(with: predicate).sortedResults(usingKeyPath: FUSER_FULLNAME, ascending: true)

		tableView.reloadData()
	}

	// MARK: - Backend actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveGroupName(name: String) {

		Group.updateName(groupId: groupId, name: name) { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		}
	}

	// MARK: - Backend actions (members)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func addGroupMembers(userIds: [String]) {

		var members = dbgroup.members.components(separatedBy: ",")

		for userId in userIds {
			if (members.contains(userId) == false) {
				members.append(userId)
			}
		}

		Group.updateMembers(groupId: groupId, members: members) { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func delGroupMember(userId: String) {

		var members = dbgroup.members.components(separatedBy: ",")

		if let index = members.index(of: userId) {
			members.remove(at: index)
		}

		Group.updateMembers(groupId: groupId, members: members) { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func leaveGroup() {

		ProgressHUD.show(nil, interaction: false)

		var members = dbgroup.members.components(separatedBy: ",")

		if let index = members.index(of: FUser.currentId()) {
			members.remove(at: index)
		}

		Group.updateMembers(groupId: groupId, members: members) { error in
			if (error == nil) {
				ProgressHUD.dismiss()
				self.navigationController?.popToRootViewController(animated: true)
				NotificationCenterX.post(notification: NOTIFICATION_CLEANUP_CHATVIEW)
			} else {
				ProgressHUD.showError("Network error.")
			}
		}
	}

	// MARK: - Backend actions (delete)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func deleteGroup() {

		ProgressHUD.show(nil, interaction: false)

		Group.deleteItem(groupId: groupId) { error in
			if (error == nil) {
				ProgressHUD.dismiss()
				self.navigationController?.popToRootViewController(animated: true)
				NotificationCenterX.post(notification: NOTIFICATION_CLEANUP_CHATVIEW)
			} else {
				ProgressHUD.showError("Network error.")
			}
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMore() {

		if isGroupOwner() { actionMoreOwner() } else { actionMoreMember() }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreOwner() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Add Members", style: .default, handler: { action in
			self.actionAddMembers()
		}))
		alert.addAction(UIAlertAction(title: "Rename Group", style: .default, handler: { action in
			self.actionRenameGroup()
		}))
		alert.addAction(UIAlertAction(title: "Delete Group", style: .destructive, handler: { action in
			self.deleteGroup()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMoreMember() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive, handler: { action in
			self.leaveGroup()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAddMembers() {

		let selectUsersView = SelectUsersView()
		selectUsersView.delegate = self
		let navController = NavigationController(rootViewController: selectUsersView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionRenameGroup() {

		let alert = UIAlertController(title: "Rename Group", message: "Enter a new name for this Group", preferredStyle: .alert)

		alert.addTextField(configurationHandler: { textField in
			textField.text = self.dbgroup.name
			textField.placeholder = "Name"
		})

		alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
			let textField = alert.textFields![0]
			if let name = textField.text {
				if (name.count != 0) {
					self.saveGroupName(name: name)
				} else {
					ProgressHUD.showError("Group name must be specified.")
				}
			}
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let chatId = Chat.chatId(groupId: groupId)

		let allMediaView = AllMediaView(chatId: chatId)
		navigationController?.pushViewController(allMediaView, animated: true)
	}

	// MARK: - SelectUsersDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUsers(users: [DBUser]) {

		var userIds: [String] = []

		for dbuser in users {
			userIds.append(dbuser.objectId)
		}

		addGroupMembers(userIds: userIds)
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 4
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 						}
		if (section == 1) { return 1 						}
		if (section == 2) { return Int(dbusers.count)		}
		if (section == 3) {	return isGroupOwner() ? 0 : 1	}

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 0) { return nil						}
		if (section == 1) { return nil						}
		if (section == 2) { return titleForHeaderMembers()	}
		if (section == 3) { return nil 						}

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) {
			return cellDetails
		}

		if (indexPath.section == 1) && (indexPath.row == 0) {
			return cellMedia
		}

		if (indexPath.section == 2) {
			var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
			if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

			let dbuser = dbusers[UInt(indexPath.row)] as! DBUser
			cell.textLabel?.text = dbuser.fullname

			return cell
		}

		if (indexPath.section == 3) && (indexPath.row == 0) {
			return cellLeave
		}

		return UITableViewCell()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

		if (indexPath.section == 2) {
			if (isGroupOwner()) {
				let dbuser = dbusers[UInt(indexPath.row)] as! DBUser
				return (dbuser.objectId != FUser.currentId())
			}
		}

		return false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

		let dbuser = dbusers[UInt(indexPath.row)] as! DBUser
		delGroupMember(userId: dbuser.objectId)
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 1) && (indexPath.row == 0) {
			actionMedia()
		}

		if (indexPath.section == 2) {
			let dbuser = dbusers[UInt(indexPath.row)] as! DBUser
			if (dbuser.objectId != FUser.currentId()) {
				let profileView = ProfileView(userId: dbuser.objectId, chat: true)
				navigationController?.pushViewController(profileView, animated: true)
			} else {
				ProgressHUD.showSuccess("This is you.")
			}
		}

		if (indexPath.section == 3) && (indexPath.row == 0) {
			actionMoreMember()
		}
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func titleForHeaderMembers() -> String? {

		let text = (dbusers.count > 1) ? "MEMBERS" : "MEMBER"
		return "\(dbusers.count) \(text)"
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func isGroupOwner() -> Bool {

		return (dbgroup.userId == FUser.currentId())
	}
}
