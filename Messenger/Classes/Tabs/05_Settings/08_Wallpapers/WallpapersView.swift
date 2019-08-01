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
class WallpapersView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet var collectionView: UICollectionView!

	private var wallpapers: [String] = []

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Wallpapers"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))

		collectionView.register(UINib(nibName: "WallpapersCell", bundle: nil), forCellWithReuseIdentifier: "WallpapersCell")

		loadWallpapers()
	}

	// MARK: - Load stickers
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadWallpapers() {

		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.application()) {
			for file in files.sorted() {
				if (file.contains("wallpapers")) {
					wallpapers.append(file)
				}
			}
		}
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func saveUser(path: String) {

		let user = FUser.currentUser()
		user[FUSER_WALLPAPER] = path
		user.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionDone() {

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionPhoto(_ sender: Any) {

		PresentPhotoLibrary(target: self, edit: false)
	}

	// MARK: - UIImagePickerControllerDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		if let image = info[.originalImage] as? UIImage {
			if let data = image.jpegData(compressionQuality: 0.6) {
				let path = File.temp(ext: "jpg")
				try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
				saveUser(path: path)
			}
		}

		picker.dismiss(animated: true) {
			self.actionDone()
		}
	}

	// MARK: - UICollectionViewDataSource
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return wallpapers.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpapersCell", for: indexPath) as! WallpapersCell

		cell.bindData(path: Dir.application(wallpapers[indexPath.item]))

		return cell
	}

	// MARK: - UICollectionViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)
		collectionView.reloadData()

		saveUser(path: Dir.application(wallpapers[indexPath.item]))

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.actionDone()
		}
	}
}
