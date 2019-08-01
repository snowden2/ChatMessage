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
@objc protocol StickersDelegate: class {

	func didSelectSticker(sticker: String)
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
class StickersView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var delegate: StickersDelegate?

	@IBOutlet var collectionView: UICollectionView!

	private var stickers1: [String] = []
	private var stickers2: [String] = []

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Stickers"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))

		collectionView.register(UINib(nibName: "StickersCell", bundle: nil), forCellWithReuseIdentifier: "StickersCell")

		loadStickers()
	}

	// MARK: - Load stickers
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadStickers() {

		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.application()) {
			for file in files.sorted() {
				if (file.contains("stickerlocal")) {
					stickers1.append(file)
				}
				if (file.contains("stickersend")) {
					stickers2.append(file)
				}
			}
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		dismiss(animated: true)
	}

	// MARK: - UICollectionViewDataSource
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return stickers1.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickersCell", for: indexPath) as! StickersCell

		cell.bindData(file: stickers1[indexPath.item])

		return cell
	}

	// MARK: - UICollectionViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let file = stickers2[indexPath.item]
		let sticker = file.replacingOccurrences(of: "@2x.png", with: "")

		delegate?.didSelectSticker(sticker: sticker)

		dismiss(animated: true)
	}
}
