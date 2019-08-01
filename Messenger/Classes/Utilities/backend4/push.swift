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
func SendPushNotification1(message: FObject) {

	let type = message[FMESSAGE_TYPE] as! String
	var text = message[FMESSAGE_SENDERNAME] as! String
	let chatId = message[FMESSAGE_CHATID] as! String

	if (type == MESSAGE_TEXT)		{ text = text + (" sent you a text message.")	}
	if (type == MESSAGE_EMOJI)		{ text = text + (" sent you an emoji.")			}
	if (type == MESSAGE_PICTURE)	{ text = text + (" sent you a picture.")		}
	if (type == MESSAGE_VIDEO)		{ text = text + (" sent you a video.")			}
	if (type == MESSAGE_AUDIO) 		{ text = text + (" sent you an audio.")			}
	if (type == MESSAGE_LOCATION)	{ text = text + (" sent you a location.")		}

	let firebase = Database.database().reference(withPath: FMUTEDUNTIL_PATH).child(chatId)
	firebase.observeSingleEvent(of: DataEventType.value, with: { snapshot in
		var userIds = message[FMESSAGE_MEMBERS] as! [String]

		if (snapshot.exists()) {
			let dictionary = snapshot.value as! [String: Int64]
			for userId in message[FMESSAGE_MEMBERS] as! [String] {
				if let mutedUntil = dictionary[userId] {
					if mutedUntil > Date().timestamp() {
						if let index = userIds.index(of: userId) {
							userIds.remove(at: index)
						}
					}
				}
			}
		}

		if let index = userIds.index(of: FUser.currentId()) {
			userIds.remove(at: index)
		}

		SendPushNotification2(userIds: userIds, text: text)
	})
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func SendPushNotification2(userIds: [String], text: String) {

	let predicate = NSPredicate(format: "objectId IN %@", userIds)
	let dbusers = DBUser.objects(with: predicate).sortedResults(usingKeyPath: FUSER_FULLNAME, ascending: true)

	var oneSignalIds:[String] = []

	for i in 0..<dbusers.count {
		let dbuser = dbusers[i] as! DBUser
		if (dbuser.oneSignalId.count != 0) {
			oneSignalIds.append(dbuser.oneSignalId)
		}
	}

	OneSignal.postNotification(["contents": ["en": text], "include_player_ids": oneSignalIds])
}
