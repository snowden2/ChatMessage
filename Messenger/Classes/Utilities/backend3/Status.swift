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
class Status: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateLastRead(chatId: String) {

		let lastRead = ServerValue.timestamp()
		let mutedUntil = self.mutedUntil(chatId: chatId)

		let object = FObject(path: FSTATUS_PATH, subpath: FUser.currentId())

		object[FSTATUS_OBJECTID] = chatId
		object[FSTATUS_CHATID] = chatId
		object[FSTATUS_LASTREAD] = lastRead
		object[FSTATUS_MUTEDUNTIL] = mutedUntil

		object.saveInBackground(block: { error in
			if (error == nil) {
				object.fetchInBackground(block: { error in
					let firebase = Database.database().reference(withPath: FLASTREAD_PATH).child(chatId)
					firebase.updateChildValues([FUser.currentId(): lastRead])
				})
			} else {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateMutedUntil(chatId: String, mutedUntil: Int64) {

		let lastRead = self.lastRead(chatId: chatId)

		let object = FObject(path: FSTATUS_PATH, subpath: FUser.currentId())

		object[FSTATUS_OBJECTID] = chatId
		object[FSTATUS_CHATID] = chatId
		object[FSTATUS_LASTREAD] = lastRead
		object[FSTATUS_MUTEDUNTIL] = mutedUntil

		object.saveInBackground(block: { error in
			if (error == nil) {
				let firebase = Database.database().reference(withPath: FMUTEDUNTIL_PATH).child(chatId)
				firebase.updateChildValues([FUser.currentId(): mutedUntil])
			} else {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func lastRead(chatId: String) -> Int64 {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		let dbstatus = DBStatus.objects(with: predicate).firstObject() as? DBStatus

		return dbstatus?.lastRead ?? 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func mutedUntil(chatId: String) -> Int64 {

		let predicate = NSPredicate(format: "chatId == %@", chatId)
		let dbstatus = DBStatus.objects(with: predicate).firstObject() as? DBStatus

		return dbstatus?.mutedUntil ?? 0
	}
}
