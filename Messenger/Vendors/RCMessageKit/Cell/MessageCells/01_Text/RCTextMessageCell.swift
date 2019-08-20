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
class RCTextMessageCell: RCMessageCell {

	var textView: UITextView!

	private var indexPath: IndexPath!
	private var messagesView: RCMessagesView!
    var htmlHeadStr = "<html><head><style type=\"text/css\">" +
    "body{font-size:20px;font-family: 'HelveticaNeue';h1{font-size: 36px;}h2{font-size: 32px;}h3{font-size: 28px;}h4{font-size: 24px;}}</style></head><body>"
    var htmlFoodStr = "</body></html>"
    var fontSize = 20
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc override func bindData(_ indexPath_: IndexPath, messagesView messagesView_: RCMessagesView) {

		indexPath = indexPath_
		messagesView = messagesView_

		let rcmessage = messagesView.rcmessage(indexPath)

		super.bindData(indexPath, messagesView: messagesView)

		viewBubble.backgroundColor = rcmessage.incoming ? RCMessages().textBubbleColorIncoming : RCMessages().textBubbleColorOutgoing

		if (textView == nil) {
			textView = UITextView()
			textView.font = RCMessages().textFont
			textView.isEditable = false
			textView.isSelectable = false
			textView.isScrollEnabled = false
			textView.isUserInteractionEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
			textView.textContainerInset = RCMessages().textInset
			viewBubble.addSubview(textView)
		}

		textView.textColor = rcmessage.incoming ? RCMessages().textTextColorIncoming : RCMessages().textTextColorOutgoing

        var htmlStr = htmlHeadStr
        htmlStr += rcmessage.text
        htmlStr += htmlFoodStr
        
        let htmlData = NSString(string: htmlStr).data(using: String.Encoding.unicode.rawValue)
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        
        textView.attributedText = attributedString

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc override func layoutSubviews() {

		let size = RCTextMessageCell.size(indexPath, messagesView: messagesView)

		super.layoutSubviews(size)

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

		let maxwidth = (0.75 * widthTable) - RCMessages().textInsetLeft - RCMessages().textInsetRight

        var fontSize = 20
        if rcmessage.text.contains("<h1>") {
            fontSize = 36
        } else if rcmessage.text.contains("<h2>") {
            fontSize = 32
        } else if rcmessage.text.contains("<h3>") {
            fontSize = 28
        } else if rcmessage.text.contains("<h4>") {
            fontSize = 24
        }
        let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesFontLeading, attributes: [NSAttributedString.Key.font: UIFont.init(name: "HelveticaNeue", size: CGFloat(fontSize)) ??  UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)

		let width = rect.size.width + RCMessages().textInsetLeft + RCMessages().textInsetRight
		let height = rect.size.height + RCMessages().textInsetTop + RCMessages().textInsetBottom

		return CGSize(width: CGFloat.maximum(width, RCMessages().textBubbleWidthMin), height: CGFloat.maximum(height, RCMessages().textBubbleHeightMin))
	}
}
