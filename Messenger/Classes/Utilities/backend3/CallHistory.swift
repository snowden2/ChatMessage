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
class CallHistory: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId: String, recipientId: String, name: String, details: SINCallDetails) {

		let orientation = (userId == recipientId) ? "↘️" : "↗️"
		let type = details.isVideoOffered ? "Video" : "Audio"

		var status = "None"
		if (details.endCause == SINCallEndCause.timeout)				{ status = "Unreachable"			}
		if (details.endCause == SINCallEndCause.denied)					{ status = "Rejected"				}
		if (details.endCause == SINCallEndCause.noAnswer)				{ status = "No answer"				}
		if (details.endCause == SINCallEndCause.error)					{ status = "Error"					}
		if (details.endCause == SINCallEndCause.hungUp)					{ status = "Succeed"				}
		if (details.endCause == SINCallEndCause.canceled)				{ status = "Canceled"				}
		if (details.endCause == SINCallEndCause.otherDeviceAnswered)	{ status = "Other device answered"	}

		var duration = 0
		if (details.endCause == SINCallEndCause.hungUp) {
			if let establishedTime = details.establishedTime {
				duration = Int(details.endedTime.timeIntervalSince(establishedTime))
			}
		}

		let object = FObject(path: FCALLHISTORY_PATH, subpath: userId)

		object[FCALLHISTORY_INITIATORID] = FUser.currentId()
		object[FCALLHISTORY_RECIPIENTID] = recipientId
		object[FCALLHISTORY_TYPE] = details.isVideoOffered ? CALLHISTORY_VIDEO : CALLHISTORY_AUDIO
		object[FCALLHISTORY_TEXT] = name
		object[FCALLHISTORY_STATUS] = "\(orientation) \(type) - \(status)"
		object[FCALLHISTORY_DURATION] = duration

		object[FCALLHISTORY_STARTEDAT]		= 0
		object[FCALLHISTORY_ESTABLISHEDAT]	= 0
		object[FCALLHISTORY_ENDEDAT]		= 0

		if let started = details.startedTime		 { object[FCALLHISTORY_STARTEDAT]		= started.timestamp()		}
		if let established = details.establishedTime { object[FCALLHISTORY_ESTABLISHEDAT]	= established.timestamp()	}
		if let ended = details.endedTime			 { object[FCALLHISTORY_ENDEDAT]			= ended.timestamp()			}

		object[FCALLHISTORY_ISDELETED] = false

		object.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(objectId: String) {

		let object = FObject(path: FCALLHISTORY_PATH, subpath: FUser.currentId())

		object[FCALLHISTORY_OBJECTID] = objectId
		object[FCALLHISTORY_ISDELETED] = true

		object.updateInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}
}
