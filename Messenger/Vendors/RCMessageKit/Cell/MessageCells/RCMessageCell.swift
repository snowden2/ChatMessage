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
class RCMessageCell: UITableViewCell {

	var viewBubble: UIView!
    var timeLabel: UILabel!
    var sendStatusImageView: UIImageView!
	var imageAvatar: UIImageView!
	var labelAvatar: UILabel!

	private var indexPath: IndexPath!
	private var messagesView: RCMessagesView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func bindData(_ indexPath_: IndexPath, messagesView messagesView_: RCMessagesView) {

		indexPath = indexPath_
		messagesView = messagesView_

		backgroundColor = UIColor.clear

		if (viewBubble == nil) {
            let rcmessage = messagesView.rcmessage(indexPath)
            
            timeLabel = UILabel()
            timeLabel.textColor = UIColor.gray
            timeLabel.textAlignment = .center
            timeLabel.text = rcmessage.insertedTime
            timeLabel.font = timeLabel.font.withSize(10)

            sendStatusImageView = UIImageView()
            
            sendStatusImageView.image = rcmessage.sendStatus == "" ? UIImage() : rcmessage.sendStatus == TEXT_READ ? UIImage(named: "double_check") : UIImage(named: "one_check")
            
			viewBubble = UIView()
			viewBubble.layer.cornerRadius = RCMessages().bubbleRadius
            viewBubble.addSubview(timeLabel)
            
            if (rcmessage.outgoing) {
                viewBubble.addSubview(sendStatusImageView)
            }
			contentView.addSubview(viewBubble)
			bubbleGestureRecognizer()
		}
        

//        if (imageAvatar == nil) {
//            imageAvatar = UIImageView()
//            imageAvatar.layer.masksToBounds = true
//            imageAvatar.layer.cornerRadius = RCMessages().avatarDiameter / 2
//            imageAvatar.backgroundColor = RCMessages().avatarBackColor
//            imageAvatar.isUserInteractionEnabled = true
//            contentView.addSubview(imageAvatar)
//            avatarGestureRecognizer()
//        }
//        imageAvatar.image = messagesView.avatarImage(indexPath)
//
//        if (labelAvatar == nil) {
//            labelAvatar = UILabel()
//            labelAvatar.font = RCMessages().avatarFont
//            labelAvatar.textColor = RCMessages().avatarTextColor
//            labelAvatar.textAlignment = .center
//            contentView.addSubview(labelAvatar)
//        }
//        labelAvatar.text = (imageAvatar.image == nil) ? messagesView.avatarInitials(indexPath) : nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func layoutSubviews(_ size: CGSize) {

		super.layoutSubviews()

		let rcmessage = messagesView.rcmessage(indexPath)

		let widthTable = messagesView.tableView.frame.size.width
        let bubbleWidth = rcmessage.incoming ? size.width : size.width > 80 ? size.width : 80
        
		let xBubble = rcmessage.incoming ? RCMessages().bubbleMarginLeft : (widthTable - RCMessages().bubbleMarginRight - bubbleWidth)
		viewBubble.frame = CGRect(x: xBubble, y: 0, width: bubbleWidth, height: size.height+25)

        timeLabel.frame = CGRect(x: 0, y: size.height, width: size.width, height: 20)
        if (rcmessage.outgoing) {
            sendStatusImageView.frame = CGRect(x: bubbleWidth-30, y: size.height, width: 25, height: 15)
        }
        
//        let diameter = RCMessages().avatarDiameter
//        let xAvatar = rcmessage.incoming ? RCMessages().avatarMarginLeft : (widthTable - RCMessages().avatarMarginRight - diameter)
//        imageAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
//        labelAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
	}

	// MARK: - Gesture recognizer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bubbleGestureRecognizer() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RCMessageCell.actionTapBubble))
		viewBubble.addGestureRecognizer(tapGesture)
		tapGesture.cancelsTouchesInView = false

		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongBubble(_:)))
		viewBubble.addGestureRecognizer(longGesture)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func avatarGestureRecognizer() {

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapAvatar))
//        imageAvatar.addGestureRecognizer(tapGesture)
//        tapGesture.cancelsTouchesInView = false
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapBubble() {

		messagesView.view.endEditing(true)
		messagesView.actionTapBubble(indexPath)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapAvatar() {

//        messagesView.view.endEditing(true)
//        messagesView.actionTapAvatar(indexPath)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer) {

		switch gestureRecognizer.state {
			case .began:
				actionMenu()
			case .changed:
				break
			case .ended:
				break
			case .possible:
				break
			case .cancelled:
				break
			case .failed:
				break
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMenu() {

		if (messagesView.textInput.isFirstResponder == false) {
			let menuController = UIMenuController.shared
			menuController.menuItems = messagesView.menuItems(indexPath) as? [UIMenuItem]
			menuController.setTargetRect(viewBubble.frame, in: contentView)
			menuController.setMenuVisible(true, animated: true)
		} else {
			messagesView.textInput.resignFirstResponder()
		}
	}
}
