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
class ArchiveView: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {

	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	private var timer: Timer?
	private var dbchats: RLMResults = DBChat.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Archived Chats"

		tableView.register(UINib(nibName: "ArchiveCell", bundle: nil), forCellReuseIdentifier: "ArchiveCell")

		tableView.tableFooterView = UIView()

		loadChats()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(refreshTableView), userInfo: nil, repeats: true)

		refreshTableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		timer?.invalidate()
		timer = nil
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadChats() {

		var predicate = NSPredicate(format: "isArchived == YES AND isDeleted == NO")

		if let text = searchBar.text {
			if (text.count != 0) {
				predicate = NSPredicate(format: "isArchived == YES AND isDeleted == NO AND details CONTAINS[c] %@", text)
			}
		}

		dbchats = DBChat.objects(with: predicate).sortedResults(usingKeyPath: "lastMessageDate", ascending: false)

		refreshTableView()
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView() {

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatGroup(groupId: String) {

		let chatGroupView = ChatGroupView(groupId: groupId)
		navigationController?.pushViewController(chatGroupView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionChatPrivate(recipientId: String) {

		let chatPrivateView = ChatPrivateView(recipientId: recipientId)
		navigationController?.pushViewController(chatPrivateView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMore(index: Int) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Unarchive", style: .default, handler: { action in
			self.actionUnarchive(index: index)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionUnarchive(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat
		Chat.unarchiveItem(dbchat: dbchat)

		let indexPath = IndexPath(row: index, section: 0)
		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.refreshTableView()
		}

		NotificationCenterX.post(notification: NOTIFICATION_REFRESH_CHATS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionDelete(index: Int) {

		let dbchat = dbchats[UInt(index)] as! DBChat
		Chat.deleteItem(dbchat: dbchat)

		let indexPath = IndexPath(row: index, section: 0)
		tableView.deleteRows(at: [indexPath], with: .fade)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.refreshTableView()
		}
	}

	// MARK: - UIScrollViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		view.endEditing(true)
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return Int(dbchats.count)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath) as! ArchiveCell

		cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.red),
							 MGSwipeButton(title: "More", backgroundColor: UIColor.lightGray)]

		cell.delegate = self
		cell.tag = indexPath.row

		let dbchat = dbchats[UInt(indexPath.row)] as! DBChat
		cell.bindData(dbchat: dbchat)
		cell.loadImage(dbchat: dbchat, tableView: tableView, indexPath: indexPath)

		return cell
	}

	// MARK: - MGSwipeTableCellDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {

		if (index == 0) { actionDelete(index: cell.tag)	}
		if (index == 1) { actionMore(index: cell.tag)	}

		return true
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let dbchat = dbchats[UInt(indexPath.row)] as! DBChat

		if (dbchat.groupId.count != 0)		{	actionChatGroup(groupId: dbchat.groupId)			}
		if (dbchat.recipientId.count != 0)	{	actionChatPrivate(recipientId: dbchat.recipientId)	}
	}

	// MARK: - UISearchBarDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		loadChats()
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
		loadChats()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

		searchBar.resignFirstResponder()
	}
}
