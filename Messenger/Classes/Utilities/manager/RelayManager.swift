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
class RelayManager: NSObject {

	private var timer: Timer?
	private var inProgress = false
	private var dbmessages: RLMResults = DBMessage.objects(with: NSPredicate(value: false))

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: RelayManager = {
		let instance = RelayManager()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(relayMessages), userInfo: nil, repeats: true)

		inProgress = false

		let predicate = NSPredicate(format: "status == %@", TEXT_QUEUED)
		dbmessages = DBMessage.objects(with: predicate).sortedResults(usingKeyPath: FMESSAGE_CREATEDAT, ascending: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func relayMessages() {

		if (FUser.currentId() != "") {
			if (Connection.isReachable()) {
				if (inProgress == false) {
					relayNextMessage()
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func relayNextMessage() {

		if let dbmessage = dbmessages.firstObject() as? DBMessage {
			inProgress = true
			MessageRelay.send(dbmessage: dbmessage) { error in
				if (error == nil) {
					do {
						let realm = RLMRealm.default()
						realm.beginWriteTransaction()
						dbmessage.status = TEXT_SENT
						try realm.commitWriteTransaction()
					} catch {
						ProgressHUD.showError("Realm commit error.")
					}
				}
				self.inProgress = false
			}
		}
	}
}
