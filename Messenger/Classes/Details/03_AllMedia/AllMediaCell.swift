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
class AllMediaCell: UICollectionViewCell {

	@IBOutlet var imageItem: UIImageView!
	@IBOutlet var imageVideo: UIImageView!
	@IBOutlet var imageSelected: UIImageView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(dbmessage: DBMessage, selected: Bool) {

		imageItem.image = UIImage(named: "allmedia_blank")
		imageVideo.isHidden = (dbmessage.type == MESSAGE_PICTURE)

		if (dbmessage.type == MESSAGE_PICTURE) {
			bindPicture(dbmessage: dbmessage)
		}

		if (dbmessage.type == MESSAGE_VIDEO) {
			bindVideo(dbmessage: dbmessage)
		}

		imageSelected.isHidden = (selected == false)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindPicture(dbmessage: DBMessage) {

		if let path = DownloadManager.pathImage(dbmessage.objectId) {
			if let image = UIImage(contentsOfFile: path) {
				imageItem.image = Image.square(image: image, size: 320)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindVideo(dbmessage: DBMessage) {

		if let path = DownloadManager.pathVideo(dbmessage.objectId) {
			DispatchQueue(label: "bindVideo").async {
				let image = Video.thumbnail(path: path)
				DispatchQueue.main.async {
					self.imageItem.image = Image.square(image: image, size: 320)
				}
			}
		}
	}
}
