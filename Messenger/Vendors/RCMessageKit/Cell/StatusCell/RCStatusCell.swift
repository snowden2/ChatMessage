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
class RCStatusCell: UITableViewCell {

	var viewBubble: UIView!
	var textView: UITextView!

	private var indexPath: IndexPath!
	private var messagesView: RCMessagesView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func bindData(_ indexPath_: IndexPath, messagesView messagesView_: RCMessagesView) {

		indexPath = indexPath_
		messagesView = messagesView_

		let rcmessage = messagesView.rcmessage(indexPath)

		backgroundColor = UIColor.clear

		if (viewBubble == nil) {
			viewBubble = UIView()
			viewBubble.backgroundColor = RCMessages().statusBubbleColor
			viewBubble.layer.cornerRadius = RCMessages().statusBubbleRadius
			contentView.addSubview(viewBubble)
			bubbleGestureRecognizer()
		}

		if (textView == nil) {
			textView = UITextView()
			textView.font = RCMessages().statusFont
			textView.textColor = RCMessages().statusTextColor
			textView.isEditable = false
			textView.isSelectable = false
			textView.isScrollEnabled = false
			textView.isUserInteractionEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
			textView.textContainerInset = RCMessages().statusInset
			viewBubble.addSubview(textView)
		}

		textView.text = rcmessage.text
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		super.layoutSubviews()

		let widthTable = messagesView.tableView.frame.size.width

		let size = RCStatusCell.size(indexPath, messagesView: messagesView)

		let yBubble = RCMessages().sectionHeaderMargin
		let xBubble = (widthTable - size.width) / 2
		viewBubble.frame = CGRect(x: xBubble, y: yBubble, width: size.width, height: size.height)

		textView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc class func height(_ indexPath: IndexPath, messagesView: RCMessagesView) -> CGFloat {
		
		let size = self.size(indexPath, messagesView: messagesView)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ indexPath: IndexPath, messagesView: RCMessagesView) -> CGSize {

		let rcmessage = messagesView.rcmessage(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		let maxwidth = (0.95 * widthTable) - RCMessages().statusInsetLeft - RCMessages().statusInsetRight

		let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCMessages().statusFont], context: nil)

		let width = rect.size.width + RCMessages().statusInsetLeft + RCMessages().statusInsetRight
		let height = rect.size.height + RCMessages().statusInsetTop + RCMessages().statusInsetBottom

		return CGSize(width: width, height: height)
	}

	// MARK: - Gesture recognizer methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bubbleGestureRecognizer() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RCStatusCell.actionTapBubble))
		viewBubble.addGestureRecognizer(tapGesture)
		tapGesture.cancelsTouchesInView = false
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionTapBubble() {

		messagesView.view.endEditing(true)
		messagesView.actionTapBubble(indexPath)
	}
}
