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
import EFColorPicker

class RCMessagesView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, RichEditorDelegate,StickersDelegate,EFColorSelectionViewControllerDelegate {
    
    func didSelectSticker(sticker: String) {
        
    }
    
    var isTextColor = false
    @IBOutlet weak var chatInputContentView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet var viewTitle: UIView!
	@IBOutlet var labelTitle1: UILabel!
	@IBOutlet var labelTitle2: UILabel!
	@IBOutlet var buttonTitle: UIButton!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var viewLoadEarlier: UIView!
	@IBOutlet var viewTypingIndicator: UIView!
	@IBOutlet var viewInput: UIView!
	@IBOutlet var buttonInputAttach: UIButton!
	@IBOutlet var textInput: RichEditorView!
	@IBOutlet var buttonInputSend: UIButton!
    @IBOutlet weak var emoticonBtn: UIButton!
    
    @IBOutlet weak var editorScrollView: UIScrollView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
	private var initialized = false
	private var centerView = CGPoint.zero
    private let scrollViewHeight:CGFloat = 50
	//---------------------------------------------------------------------------------------------------------------------------------------------
	convenience init() {

		self.init(nibName: "RCMessagesView", bundle: nil)
	}

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        inputPanelUpdate()
        
    }
    
    func presentColorPicker() {
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = UIColor.white
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.sourceView = editorScrollView
        navCtrl.popoverPresentationController?.sourceRect = editorScrollView.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = self.view.backgroundColor ?? UIColor.white
        colorSelectionController.setMode(mode: EFColorSelectionMode.all)
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItem.Style.done,
                target: self,
                action: #selector(ef_dismissViewController(sender:))
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        self.present(navCtrl, animated: true, completion: nil)

    }
    
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        let superSelf = self
        self.dismiss(animated: true) {
            [weak self] in
            if let _weakSelf = self, let selectedColor =  _weakSelf.view.backgroundColor{
                
                if (superSelf.isTextColor) {
                    superSelf.textInput.setTextColor(selectedColor)
                } else {
                    superSelf.textInput.setTextBackgroundColor(selectedColor)
                }
                
                _weakSelf.view.backgroundColor = UIColor.white
                // TODO: You can do something here when EFColorPicker close.
                print("EFColorPicker closed.")
            }
        }
    }
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        self.view.backgroundColor = color
        
        // TODO: You can do something here when color changed.
        print("New color: " + color.debugDescription)
    }

    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		navigationItem.titleView = viewTitle

		tableView.register(RCSectionHeaderCell.self, forCellReuseIdentifier: "RCSectionHeaderCell")
		tableView.register(RCBubbleHeaderCell.self, forCellReuseIdentifier: "RCBubbleHeaderCell")
		tableView.register(RCBubbleFooterCell.self, forCellReuseIdentifier: "RCBubbleFooterCell")
		tableView.register(RCSectionFooterCell.self, forCellReuseIdentifier: "RCSectionFooterCell")

		tableView.register(RCTextMessageCell.self, forCellReuseIdentifier: "RCTextMessageCell")
		tableView.register(RCEmojiMessageCell.self, forCellReuseIdentifier: "RCEmojiMessageCell")
		tableView.register(RCPictureMessageCell.self, forCellReuseIdentifier: "RCPictureMessageCell")
		tableView.register(RCVideoMessageCell.self, forCellReuseIdentifier: "RCVideoMessageCell")
		tableView.register(RCAudioMessageCell.self, forCellReuseIdentifier: "RCAudioMessageCell")
		tableView.register(RCLocationMessageCell.self, forCellReuseIdentifier: "RCLocationMessageCell")

		tableView.register(RCStatusCell.self, forCellReuseIdentifier: "RCStatusCell")

		tableView.tableHeaderView = viewLoadEarlier

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)

        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        chatInputContentView.layer.cornerRadius = 25;
        chatInputContentView.layer.masksToBounds = true;
        
        buttonInputAttach.layer.masksToBounds = true;
        
        textInput.delegate = self
        
		inputPanelInit()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLayoutSubviews() {

		super.viewDidLayoutSubviews()

		centerView = view.center

		inputPanelUpdate()
        
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		dismissKeyboard()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (initialized == false) {
			initialized = true
			scroll(toBottom: true)
		}

		centerView = view.center
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

    func insertEditorLink() {
        let alertController = UIAlertController(title: "Insert Link", message: "Insert link and description", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Link"
            textField.textColor = UIColor.blue
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Description"
            textField.textColor = UIColor.blue
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let textfields = alertController.textFields
            let linkfield = textfields?[0]
            let descriptionfiled = textfields?[1]
            if let linkText = linkfield?.text, let descriptionText = descriptionfiled?.text{
                self.textInput.insertLink(linkText, title: descriptionText)
                
            }
            
        }))
        present(alertController, animated: true)


    }
    @IBAction func editorBtnsTapped(_ sender: UIButton) {
        switch(sender.tag) {
        case 5000: //bold
            textInput.bold()
            break
        case 5001: //italic
            textInput.italic()
            break
        case 5002: //underline
            textInput.underline()
            break
        case 5003: //subscript
            textInput.subscriptText()
            break
        case 5004: //superscript
            textInput.superscript()
            break
        case 5005: //h1
            textInput.header(1)
            break
        case 5006: //h2
            textInput.header(2)
            break
        case 5007: //h3
            textInput.header(3)
            break
        case 5008: //h4
            textInput.header(4)
            break
        case 5009: //Strikethrough
            textInput.strikethrough()
            break
        case 5010: //link
            insertEditorLink()
            break
        case 5011: //image
//            textInput.insert
            break
        case 5012: //justify left
            textInput.alignLeft()
            break
        case 5013: //justify center
            textInput.alignCenter()
            break
        case 5014: //justify right
            textInput.alignRight()
            break
        case 5015: //undo
            textInput.undo()
            break
        case 5016: //undo
            textInput.redo()
            break
        case 5017: //text color
            isTextColor = true
            presentColorPicker()
            break
        case 5018: //text background color
            isTextColor = false
            presentColorPicker()
            break
        default:
            break
        }
        
    }
    
	// MARK: - Load earlier methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadEarlierShow(_ show: Bool) {

		viewLoadEarlier.isHidden = !show
		var frame: CGRect = viewLoadEarlier.frame
		frame.size.height = show ? 50 : 0
		viewLoadEarlier.frame = frame
		tableView.reloadData()
	}

	// MARK: - Message methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func rcmessage(_ indexPath: IndexPath) -> RCMessage {

		return RCMessage()
	}

	// MARK: - Avatar methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarInitials(_ indexPath: IndexPath) -> String {

		return ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarImage(_ indexPath: IndexPath) -> UIImage? {

		return nil
	}

	// MARK: - Header, Footer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textSectionHeader(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textBubbleHeader(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textBubbleFooter(_ indexPath: IndexPath) -> String? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textSectionFooter(_ indexPath: IndexPath) -> String? {

		return nil
	}

	// MARK: - Menu controller methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func menuItems(_ indexPath: IndexPath) -> [Any]? {

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

		return false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override var canBecomeFirstResponder: Bool {

		return true
	}

	// MARK: - Typing indicator methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorShow(_ show: Bool, animated: Bool) {

		if show {
			tableView.tableFooterView = viewTypingIndicator
			scroll(toBottom: animated)
		} else {
			UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
				self.tableView.tableFooterView = nil
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func typingIndicatorUpdate() {

	}

	// MARK: - Keyboard methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    @objc func didSelectColor() {
        
    }
	@objc func keyboardShow(_ notification: Notification?) {

		if let info = notification?.userInfo {
			if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
				let duration = TimeInterval(info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
				UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
					self.view.center = CGPoint(x: self.centerView.x, y: self.centerView.y - keyboard.size.height + self.view.safeAreaInsets.bottom)
				})
			}
		}
		UIMenuController.shared.menuItems = nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func keyboardHide(_ notification: Notification?) {

		if let info = notification?.userInfo {
			let duration = TimeInterval(info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
			UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
				self.view.center = self.centerView
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func dismissKeyboard() {

		view.endEditing(true)
	}

	// MARK: - Input panel methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputPanelInit() {

//        viewInput.backgroundColor = RCMessages().inputViewBackColor
//        textInput.backgroundColor = RCMessages().inputTextBackColor
        
//        textInput.font = RCMessages().inputFont
        
		textInput.setTextColor(RCMessages().inputTextTextColor)
        textInput.setFontSize(6)
//        textInput.textContainer.lineFragmentPadding = 0
//        textInput.textContainerInset = RCMessages().inputInset

//        textInput.layer.borderColor = RCMessages().inputBorderColor
//        textInput.layer.borderWidth = RCMessages().inputBorderWidth

//        textInput.layer.cornerRadius = RCMessages().inputRadius
//        textInput.clipsToBounds = true
        
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func inputPanelUpdate() {

//        let heightView: CGFloat = view.frame.size.height
//        let widthView: CGFloat = view.frame.size.width

//        let leftSafe: CGFloat = view.safeAreaInsets.left
//        let rightSafe: CGFloat = view.safeAreaInsets.right
        let bottomSafe: CGFloat = view.safeAreaInsets.bottom

		let widthText: CGFloat = textInput.frame.size.width
		var heightText: CGFloat
        let sizeText = textInput.sizeThatFits(CGSize(width: widthText, height: CGFloat.greatestFiniteMagnitude))

        
        heightText = CGFloat.maximum(RCMessages().inputTextHeightMin, sizeText.height)
        heightText = CGFloat.minimum(RCMessages().inputTextHeightMax, heightText)
        
        viewHeightConstraint.constant = heightText + 14
        viewBottomConstraint.constant = bottomSafe
        buttonInputAttach.layer.cornerRadius = heightText/2;
//        let heightInput: CGFloat = heightText + (RCMessages().inputViewHeightMin - RCMessages().inputTextHeightMin)
//
//        tableView.frame = CGRect(x: leftSafe, y: 0, width: widthView - leftSafe - rightSafe, height: heightView - bottomSafe - heightInput-scrollViewHeight)
//
//        var frameViewInput: CGRect = viewInput.frame
//        frameViewInput.origin.y = heightView - bottomSafe - heightInput
//        frameViewInput.size.height = heightInput
//        viewInput.frame = frameViewInput
//
//        var frameEditorView: CGRect = editorScrollView.frame
//        frameEditorView.origin.y = heightView - bottomSafe - heightInput - scrollViewHeight
//        editorScrollView.frame = frameEditorView
//
//        viewInput.layoutIfNeeded()


//        var frameTextInput: CGRect = textInput.frame
//        frameTextInput.size.height = heightText
//        textInput.frame = frameTextInput
//
//        var frameChatContainer: CGRect = chatInputContentView.frame
//        frameChatContainer.size.height = heightText
//        chatInputContentView.frame = frameChatContainer
//
//        var frameAttach: CGRect = buttonInputAttach.frame
//        frameAttach.origin.y = heightInput - frameAttach.size.height
//        buttonInputAttach.frame = frameAttach
//
//        var frameSend: CGRect = buttonInputSend.frame
//        frameSend.origin.y = heightInput - frameSend.size.height
//        buttonInputSend.frame = frameSend
//
//        var frameEmoticon: CGRect = emoticonBtn.frame
//        frameEmoticon.origin.y = heightInput - frameEmoticon.size.height
//        emoticonBtn.frame = frameEmoticon

		buttonInputSend.isEnabled = textInput.html.count != 0

//        let offset = CGPoint(x: 0, y: sizeText.height - heightText)
//        textInput.setContentOffset(offset, animated: false)

		scroll(toBottom: false)
	}

	// MARK: - User actions (title)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionTitle(_ sender: Any) {

		actionTitle()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTitle() {

	}

	// MARK: - User actions (load earlier)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoadEarlier(_ sender: Any) {

		actionLoadEarlier()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLoadEarlier() {

	}

	// MARK: - User actions (bubble tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTapBubble(_ indexPath: IndexPath) {

	}

	// MARK: - User actions (avatar tap)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTapAvatar(_ indexPath: IndexPath) {

	}

	// MARK: - User actions (input panel)
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionInputAttach(_ sender: Any) {

		actionAttachMessage()
	}

    @IBAction func actionEmoticon(_ sender: UIButton) {
        let stickersView = StickersView()
        stickersView.delegate = self
        let navController = NavigationController(rootViewController: stickersView)
        present(navController, animated: true)
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionInputSend(_ sender: Any) {

		if (textInput.html.count != 0) {
			actionSendMessage(textInput.html)
			dismissKeyboard()
            textInput.focus()
			textInput.html = ""
			inputPanelUpdate()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionAttachMessage() {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionSendMessage(_ text: String) {

	}

	// MARK: - UIScrollViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

		dismissKeyboard()
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 5
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

		return RCMessages().sectionHeaderMargin
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

		return RCMessages().sectionFooterMargin
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {

		view.tintColor = UIColor.clear
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		if (indexPath.row == 0) {
			return RCSectionHeaderCell.height(indexPath, messagesView: self)
		}

		if (indexPath.row == 1) {
			return RCBubbleHeaderCell.height(indexPath, messagesView: self)
		}

		if (indexPath.row == 2) {

			let rcmessage = self.rcmessage(indexPath)
			if (rcmessage.type == RC_TYPE_STATUS)	{ return RCStatusCell.height(indexPath, messagesView: self)				}
			if (rcmessage.type == RC_TYPE_TEXT)		{ return RCTextMessageCell.height(indexPath, messagesView: self)		}
			if (rcmessage.type == RC_TYPE_EMOJI)	{ return RCEmojiMessageCell.height(indexPath, messagesView: self)		}
			if (rcmessage.type == RC_TYPE_PICTURE)	{ return RCPictureMessageCell.height(indexPath, messagesView: self)		}
			if (rcmessage.type == RC_TYPE_VIDEO)	{ return RCVideoMessageCell.height(indexPath, messagesView: self)		}
			if (rcmessage.type == RC_TYPE_AUDIO)	{ return RCAudioMessageCell.height(indexPath, messagesView: self)		}
			if (rcmessage.type == RC_TYPE_LOCATION)	{ return RCLocationMessageCell.height(indexPath, messagesView: self)	}
		}

		if (indexPath.row == 3) {
			return RCBubbleFooterCell.height(indexPath, messagesView: self)
		}

		if (indexPath.row == 4) {
			return RCSectionFooterCell.height(indexPath, messagesView: self)
		}
		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.row == 0) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionHeaderCell", for: indexPath) as! RCSectionHeaderCell
			cell.bindData(indexPath, messagesView: self)
			return cell
		}

		if (indexPath.row == 1) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleHeaderCell", for: indexPath) as! RCBubbleHeaderCell
			cell.bindData(indexPath, messagesView: self)
			return cell
		}

		if (indexPath.row == 2) {
			let rcmessage = self.rcmessage(indexPath)
			if (rcmessage.type == RC_TYPE_STATUS) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCStatusCell", for: indexPath) as! RCStatusCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_TEXT) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCTextMessageCell", for: indexPath) as! RCTextMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_EMOJI) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCEmojiMessageCell", for: indexPath) as! RCEmojiMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_PICTURE) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCPictureMessageCell", for: indexPath) as! RCPictureMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_VIDEO) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCVideoMessageCell", for: indexPath) as! RCVideoMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_AUDIO) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCAudioMessageCell", for: indexPath) as! RCAudioMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
			if (rcmessage.type == RC_TYPE_LOCATION) {
				let cell = tableView.dequeueReusableCell(withIdentifier: "RCLocationMessageCell", for: indexPath) as! RCLocationMessageCell
				cell.bindData(indexPath, messagesView: self)
				return cell
			}
		}

		if (indexPath.row == 3) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleFooterCell", for: indexPath) as! RCBubbleFooterCell
			cell.bindData(indexPath, messagesView: self)
			return cell
		}

		if (indexPath.row == 4) {
			let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionFooterCell", for: indexPath) as! RCSectionFooterCell
			cell.bindData(indexPath, messagesView: self)
			return cell
		}

		return UITableViewCell()
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func scroll(toBottom animated: Bool) {

		if (tableView.numberOfSections > 0) {
			let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
			tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
		}
	}

	// MARK: - UITextViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

		return true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textViewDidChange(_ textView: UITextView) {

		inputPanelUpdate()
		typingIndicatorUpdate()
	}
}
