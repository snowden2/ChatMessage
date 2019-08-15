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
class ChatPrivateView: RCMessagesView, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioDelegate,  SelectUsersDelegate {

	private var recipientId = ""
	private var chatId = ""
	private var isBlocker = false
    private var avatarImage = UIImage(named: "people_blank")
	private var dbmessages: RLMResults = DBMessage.objects(with: NSPredicate(value: false))
	private var rcmessages: [String: RCMessage] = [:]
	private var avatarImages: [String: UIImage] = [:]
	private var avatarIds: [String] = []

	private var insertCounter: Int = 0
	private var typingCounter: Int = 0
	private var lastRead: Int64 = 0

	private var firebase1: DatabaseReference?
	private var firebase2: DatabaseReference?

	private var timer: Timer?
	private var indexForward: IndexPath?

	//---------------------------------------------------------------------------------------------------------------------------------------------
    init(recipientId recipientId_: String, avatarImage: UIImage?) {

		super.init(nibName: "RCMessagesView", bundle: nil)

		recipientId = recipientId_

		chatId = Chat.chatId(recipientId: recipientId)
		isBlocker = Blocker.isBlocker(userId: recipientId)
        
        if (avatarImage != nil) {
            self.avatarImage = avatarImage
        }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationController?.interactivePopGestureRecognizer?.delegate = self

		let buttonBack = UIBarButtonItem(image: UIImage(named: "chat_back"), style: .plain, target: self, action: #selector(actionBack))
		let buttonCallAudio = UIBarButtonItem(image: UIImage(named: "chat_callaudio"), style: .plain, target: self, action: #selector(actionCallAudio))
		let buttonCallVideo = UIBarButtonItem(image: UIImage(named: "chat_callvideo"), style: .plain, target: self, action: #selector(actionCallVideo))

		navigationItem.leftBarButtonItem = buttonBack
		navigationItem.rightBarButtonItems = [buttonCallVideo, buttonCallAudio]

		if (isBlocker) {
			navigationItem.rightBarButtonItems = nil
			buttonInputAttach.isUserInteractionEnabled = false
			buttonInputSend.isUserInteractionEnabled = false
			textInput.isUserInteractionEnabled = false
		}

		let wallpaper = FUser.wallpaper()
		if (wallpaper.count != 0) {
			tableView.backgroundView = UIImageView(image: UIImage(named: wallpaper))
		}

		NotificationCenterX.addObserver(target: self, selector: #selector(refreshTableView1), name: NOTIFICATION_REFRESH_MESSAGES1)
		NotificationCenterX.addObserver(target: self, selector: #selector(refreshTableView2), name: NOTIFICATION_REFRESH_MESSAGES2)

		insertCounter = Int(INSERT_MESSAGES)

		loadMessages()
		refreshTableView2()

		typingIndicatorObserver()
		createLastReadObservers()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateTitleDetails), userInfo: nil, repeats: true)

		Messages.assignChatId(chatId: chatId)

		Status.updateLastRead(chatId: chatId)

        self.avatarImageView.image = self.avatarImage
		updateTitleDetails()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidDisappear(_ animated: Bool) {

		super.viewDidDisappear(animated)

		timer?.invalidate()
		timer = nil

		if (isMovingFromParent) {
			actionCleanup()
		}
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadMessages() {

		let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
		dbmessages = DBMessage.objects(with: predicate).sortedResults(usingKeyPath: FMESSAGE_CREATEDAT, ascending: true)
	}

	// MARK: - DBMessage methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func index(_ indexPath: IndexPath) -> Int {

		let count = min(insertCounter, Int(dbmessages.count))
		let offset = Int(dbmessages.count) - count

		return (indexPath.section + offset)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dbmessage(_ indexPath: IndexPath) -> DBMessage {

		let index = self.index(indexPath)
		return dbmessages[UInt(index)] as! DBMessage
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dbmessageAbove(_ indexPath: IndexPath) -> DBMessage? {

		if (indexPath.section > 0) {
			let indexAbove = IndexPath(row: 0, section: indexPath.section-1)
			return dbmessage(indexAbove)
		}
		return nil
	}

	// MARK: - Message methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func rcmessage(_ indexPath: IndexPath) -> RCMessage {

		let dbmessage = self.dbmessage(indexPath)
		let messageId = dbmessage.objectId

		if (rcmessages[messageId] == nil) {

			var rcmessage: RCMessage!
			let incoming = (dbmessage.senderId != FUser.currentId())
            var sentStatus = ""
            if (!incoming) {
                sentStatus = (dbmessage.createdAt > lastRead) ? dbmessage.status : TEXT_READ
            }
            
            let date = Date.date(timestamp: dbmessage.createdAt)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let createdAt = dateFormatter.string(from: date)
            
			if (dbmessage.type == MESSAGE_STATUS) {
				rcmessage = RCMessage(status: dbmessage.text, insertedTime: createdAt, sendStatus: sentStatus)
			}

			if (dbmessage.type == MESSAGE_TEXT) {
				rcmessage = RCMessage(text: dbmessage.text, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus)
			}

			if (dbmessage.type == MESSAGE_EMOJI) {
				rcmessage = RCMessage(emoji: dbmessage.text, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus)
			}

			if (dbmessage.type == MESSAGE_PICTURE) {
				rcmessage = RCMessage(picture: nil, width: dbmessage.pictureWidth, height: dbmessage.pictureHeight, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus)
				MediaLoader.loadPicture(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
			}

			if (dbmessage.type == MESSAGE_VIDEO) {
				rcmessage = RCMessage(video: nil, duration: dbmessage.videoDuration, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus)
				MediaLoader.loadVideo(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
			}

			if (dbmessage.type == MESSAGE_AUDIO) {
				rcmessage = RCMessage(audio: nil, duration: dbmessage.audioDuration, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus)
				MediaLoader.loadAudio(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
			}

			if (dbmessage.type == MESSAGE_LOCATION) {
				rcmessage = RCMessage(latitude: dbmessage.latitude, longitude: dbmessage.longitude, incoming: incoming, insertedTime: createdAt, sendStatus: sentStatus) {
					self.tableView.reloadData()
				}
			}

			rcmessages[messageId] = rcmessage
		}

		return rcmessages[messageId]!
	}

	// MARK: - Avatar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarInitials(_ indexPath: IndexPath) -> String {

		let dbmessage = self.dbmessage(indexPath)
		return dbmessage.senderInitials
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		let dbmessage = self.dbmessage(indexPath)

		if (avatarImages[dbmessage.senderId] == nil) {
			loadAvatarImage(dbmessage)
		}

		return avatarImages[dbmessage.senderId]
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadAvatarImage(_ dbmessage: DBMessage) {

		let userId = dbmessage.senderId

		if (avatarIds.contains(userId)) { return } else { avatarIds.append(userId) }

		DownloadManager.startUser(dbmessage.senderId, pictureAt: dbmessage.senderPictureAt) { path, error, network in
			if (error == nil) {
				if let image = UIImage(contentsOfFile: path!) {
					self.avatarImages[userId] = image
				}
				self.tableView.reloadData()
			} else if ((error! as NSError).code != 100) {
				if let index = self.avatarIds.index(of: userId) {
					self.avatarIds.remove(at: index)
				}
			}
		}
	}

	// MARK: - Header, Footer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textSectionHeader(_ indexPath: IndexPath) -> String? {

//        if (indexPath.section % 3 == 0) {
//            let dbmessage = self.dbmessage(indexPath)
//            let date = Date.date(timestamp: dbmessage.createdAt)
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "dd MMMM, HH:mm"
//            return dateFormatter.string(from: date)
//        } else {
//            return nil
//        }
        return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textBubbleHeader(_ indexPath: IndexPath) -> String? {

		let rcmessage = self.rcmessage(indexPath)
		if (rcmessage.incoming) {
			let dbmessage = self.dbmessage(indexPath)
			if let dbmessageAbove = self.dbmessageAbove(indexPath) {
				if (dbmessage.senderId == dbmessageAbove.senderId) {
					return nil
				}
			}
			return dbmessage.senderName
		}
		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textBubbleFooter(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func textSectionFooter(_ indexPath: IndexPath) -> String? {
		
//        let rcmessage = self.rcmessage(indexPath)
//        if (rcmessage.outgoing) {
//            let dbmessage = self.dbmessage(indexPath)
//            return (dbmessage.createdAt > lastRead) ? dbmessage.status : TEXT_READ
//        }
		return nil
	}

	// MARK: - Menu controller methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func menuItems(_ indexPath: IndexPath) -> [Any]? {

		let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(actionMenuCopy(_:)))
		let menuItemSave = RCMenuItem(title: "Save", action: #selector(actionMenuSave(_:)))
		let menuItemDelete = RCMenuItem(title: "Delete", action: #selector(actionMenuDelete(_:)))
		let menuItemForward = RCMenuItem(title: "Forward", action: #selector(actionMenuForward(_:)))

		menuItemCopy.indexPath = indexPath
		menuItemSave.indexPath = indexPath
		menuItemDelete.indexPath = indexPath
		menuItemForward.indexPath = indexPath

		let rcmessage = self.rcmessage(indexPath)

		var array: [RCMenuItem] = []

		if (rcmessage.type == RC_TYPE_TEXT)		{ array.append(menuItemCopy) 	}
		if (rcmessage.type == RC_TYPE_EMOJI)	{ array.append(menuItemCopy)	}

		if (rcmessage.type == RC_TYPE_PICTURE)	{ array.append(menuItemSave)	}
		if (rcmessage.type == RC_TYPE_VIDEO)	{ array.append(menuItemSave)	}
		if (rcmessage.type == RC_TYPE_AUDIO)	{ array.append(menuItemSave)	}

		array.append(menuItemDelete)
		array.append(menuItemForward)

		return array
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		if (action == #selector(actionMenuCopy(_:)))	{ return true	}
		if (action == #selector(actionMenuSave(_:)))	{ return true	}
		if (action == #selector(actionMenuDelete(_:)))	{ return true 	}
		if (action == #selector(actionMenuForward(_:)))	{ return true	}

		return false
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorObserver() {

		firebase1 = Database.database().reference(withPath: FTYPING_PATH).child(chatId)
		firebase1?.observe(DataEventType.childChanged, with: { snapshot in
			if (snapshot.key != FUser.currentId()) {
				
				let typing = snapshot.value as! Bool
				self.typingIndicatorShow(typing, animated: true)
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func typingIndicatorUpdate() {

		typingCounter += 1
		typingIndicatorSave(true)

		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			self.typingIndicatorStop()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorStop() {

		typingCounter -= 1
		if (typingCounter == 0) {
			typingIndicatorSave(false)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorSave(_ typing: Bool) {

		firebase1?.updateChildValues([FUser.currentId(): typing])
	}

	// MARK: - LastRead methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createLastReadObservers() {

		firebase2 = Database.database().reference(withPath: FLASTREAD_PATH).child(chatId)
		firebase2?.observe(DataEventType.value, with: { snapshot in
			if (snapshot.exists()) {
				let dictionary = snapshot.value as! [String: Any]
				for userId in dictionary.keys {
					if (userId != FUser.currentId()) {
						let lastTemp = dictionary[userId] as! Int64
						if (lastTemp > self.lastRead) {
							self.lastRead = lastTemp
						}
					}
				}
				self.tableView.reloadData()
			}
		})
	}

	// MARK: - Title details methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func updateTitleDetails() {

		let predicate = NSPredicate(format: "objectId == %@", recipientId)
		let dbuser = DBUser.objects(with: predicate).firstObject() as! DBUser

		labelTitle1.text = dbuser.fullname
		labelTitle2.text = UserLastActive(dbuser: dbuser)
	}

	// MARK: - Refresh methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView1() {

		refreshTableView2()
		scroll(toBottom: true)
		Status.updateLastRead(chatId: chatId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshTableView2() {

		let show = (insertCounter < dbmessages.count)
		loadEarlierShow(show)

		tableView.reloadData()
	}

	// MARK: - Message send methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageSend(_ text: String?, picture: UIImage?, video: URL?, audio: String?) {

		MessageQueue.send(chatId: chatId, recipientId: recipientId, status: nil, text: text, picture: picture, video: video, audio: audio)

		Shortcut.update(userId: recipientId)
	}

	// MARK: - Message delete methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func messageDelete(_ indexPath: IndexPath) {

		let dbmessage = self.dbmessage(indexPath)
		Message.deleteItem(dbmessage: dbmessage)
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionBack() {

		navigationController?.popViewController(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTitle() {

		let profileView = ProfileView(userId: recipientId, chat: false)
		navigationController?.pushViewController(profileView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCallAudio() {

		let callAudioView = CallAudioView(userId: recipientId)
		present(callAudioView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCallVideo() {

		let callVideoView = CallVideoView(userId: recipientId)
		present(callVideoView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionAttachMessage() {

		view.endEditing(true)

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let alertCamera = UIAlertAction(title: "Camera", style: .default, handler: { action in
			PresentMultiCamera(target: self, edit: true)
		})
		let alertPicture = UIAlertAction(title: "Picture", style: .default, handler: { action in
			PresentPhotoLibrary(target: self, edit: true)
		})
		let alertVideo = UIAlertAction(title: "Video", style: .default, handler: { action in
			PresentVideoLibrary(target: self, edit: true)
		})
		let alertAudio = UIAlertAction(title: "Audio", style: .default, handler: { action in
			self.actionAudio()
		})
		let alertStickers = UIAlertAction(title: "Sticker", style: .default, handler: { action in
			self.actionStickers()
		})
		let alertLocation = UIAlertAction(title: "Location", style: .default, handler: { action in
			self.actionLocation()
		})

		alertCamera.setValue(UIImage(named: "chat_camera"), forKey: "image"); 		alert.addAction(alertCamera)
		alertPicture.setValue(UIImage(named: "chat_picture"), forKey: "image");		alert.addAction(alertPicture)
		alertVideo.setValue(UIImage(named: "chat_video"), forKey: "image");			alert.addAction(alertVideo)
		alertAudio.setValue(UIImage(named: "chat_audio"), forKey: "image");			alert.addAction(alertAudio)
		alertStickers.setValue(UIImage(named: "chat_sticker"), forKey: "image");	alert.addAction(alertStickers)
		alertLocation.setValue(UIImage(named: "chat_location"), forKey: "image");	alert.addAction(alertLocation)

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionSendMessage(_ text: String) {

		messageSend(text, picture: nil, video: nil, audio: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAudio() {

		let audioView = AudioView()
		audioView.delegate = self
		let navController = NavigationController(rootViewController: audioView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionStickers() {

		let stickersView = StickersView()
		stickersView.delegate = self
		let navController = NavigationController(rootViewController: stickersView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLocation() {

		messageSend(nil, picture: nil, video: nil, audio: nil)
	}

	// MARK: - UIImagePickerControllerDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		let video = info[.mediaURL] as? URL
		let picture = info[.editedImage] as? UIImage

		messageSend(nil, picture: picture, video: video, audio: nil)

		picker.dismiss(animated: true)
	}

	// MARK: - AudioDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didRecordAudio(path: String) {

		messageSend(nil, picture: nil, video: nil, audio: path)
	}

	// MARK: - StickersDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
    override func didSelectSticker(sticker: String) {

		let picture = UIImage(named: sticker)
		messageSend(nil, picture: picture, video: nil, audio: nil)
	}

	// MARK: - User actions (load earlier)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionLoadEarlier() {

		insertCounter += Int(INSERT_MESSAGES)
		refreshTableView2()
	}

	// MARK: - User actions (bubble tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapBubble(_ indexPath: IndexPath) {

		let dbmessage = self.dbmessage(indexPath)
		let rcmessage = self.rcmessage(indexPath)

		if (rcmessage.type == RC_TYPE_STATUS) {

		}

		if (rcmessage.type == RC_TYPE_PICTURE) {
			if (rcmessage.status == RC_STATUS_MANUAL) {
				MediaLoader.loadPictureManual(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
				tableView.reloadData()
			}
			if (rcmessage.status == RC_STATUS_SUCCEED) {
				let dictionary = PictureView.photos(messageId: dbmessage.objectId, chatId: chatId)
				let photoItems = dictionary["photoItems"] as! [NYTPhoto]
				let initialPhoto = dictionary["initialPhoto"] as! NYTPhoto

				let pictureView = PictureView(photos: photoItems, initialPhoto: initialPhoto)
				pictureView.setMessages(messages: true)
				present(pictureView, animated: true)
			}
		}

		if (rcmessage.type == RC_TYPE_VIDEO) {
			if (rcmessage.status == RC_STATUS_MANUAL) {
				MediaLoader.loadVideoManual(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
				tableView.reloadData()
			}
			if (rcmessage.status == RC_STATUS_SUCCEED) {
				let url = URL(fileURLWithPath: rcmessage.video_path)
				let videoView = VideoView(url: url)
				present(videoView, animated: true)
			}
		}

		if (rcmessage.type == RC_TYPE_AUDIO) {
			if (rcmessage.status == RC_STATUS_MANUAL) {
				MediaLoader.loadAudioManual(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
				tableView.reloadData()
			}
			if (rcmessage.status == RC_STATUS_SUCCEED) {
				if (rcmessage.audio_status == RC_AUDIOSTATUS_STOPPED) {
					if let sound = Sound(contentsOfFile: rcmessage.audio_path) {
						sound.completionHandler = { didFinish in
							rcmessage.audio_status = Int(RC_AUDIOSTATUS_STOPPED)
							self.tableView.reloadData()
						}
						SoundManager.shared().playSound(sound)
						rcmessage.audio_status = Int(RC_AUDIOSTATUS_PLAYING)
						tableView.reloadData()
					}
				} else if (rcmessage.audio_status == RC_AUDIOSTATUS_PLAYING) {
					SoundManager.shared().stopAllSounds(false)
					rcmessage.audio_status = Int(RC_AUDIOSTATUS_STOPPED)
					tableView.reloadData()
				}
			}
		}

		if (rcmessage.type == RC_TYPE_LOCATION) {
			let location = CLLocation(latitude: rcmessage.latitude, longitude: rcmessage.longitude)
			let mapView = MapView(location: location)
			let navController = NavigationController(rootViewController: mapView)
			present(navController, animated: true)
		}
	}

	// MARK: - User actions (avatar tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func actionTapAvatar(_ indexPath: IndexPath) {

		let dbmessage = self.dbmessage(indexPath)
		let senderId = dbmessage.senderId

		if (senderId != FUser.currentId()) {
			let profileView = ProfileView(userId: senderId, chat: false)
			navigationController?.pushViewController(profileView, animated: true)
		}
	}

	// MARK: - User actions (menu)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuCopy(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			let rcmessage = self.rcmessage(indexPath)
			UIPasteboard.general.string = rcmessage.text
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuSave(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			let rcmessage = self.rcmessage(indexPath)

			if (rcmessage.type == RC_TYPE_PICTURE) {
				if (rcmessage.status == RC_STATUS_SUCCEED) {
					UIImageWriteToSavedPhotosAlbum(rcmessage.picture_image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
				}
			}

			if (rcmessage.type == RC_TYPE_VIDEO) {
				if (rcmessage.status == RC_STATUS_SUCCEED) {
					UISaveVideoAtPathToSavedPhotosAlbum(rcmessage.video_path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
				}
			}

			if (rcmessage.type == RC_TYPE_AUDIO) {
				if (rcmessage.status == RC_STATUS_SUCCEED) {
					let path = File.temp(ext: "mp4")
					File.copy(src: rcmessage.audio_path, dest: path, overwrite: true)
					UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuDelete(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			messageDelete(indexPath)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionMenuForward(_ sender: Any?) {

		if let indexPath = RCMenuItem.indexPath(sender as! UIMenuController) {
			indexForward = indexPath

			let selectUsersView = SelectUsersView()
			selectUsersView.delegate = self
			let navController = NavigationController(rootViewController: selectUsersView)
			present(navController, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {

		if (error != nil) { ProgressHUD.showError("Saving failed.") } else { ProgressHUD.showSuccess("Successfully saved.") }
	}

	// MARK: - SelectUsersDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didSelectUsers(users: [DBUser]) {

		if let indexPath = indexForward {
			let dbmessage = self.dbmessage(indexPath)

			for dbuser in users {
				let recipientId = dbuser.objectId
				let chatId = Chat.chatId(recipientId: recipientId)
				MessageQueue.forward(chatId: chatId, recipientId: recipientId, dbmessage: dbmessage)
			}

			Audio.playMessageOutgoing()
			indexForward = nil
		}
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return min(insertCounter, Int(dbmessages.count))
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCleanup() {

		Messages.resignChatId()

		typingIndicatorSave(false)

		firebase1?.removeAllObservers(); firebase1 = nil
		firebase2?.removeAllObservers(); firebase2 = nil

		NotificationCenterX.removeObserver(target: self)
	}
}
