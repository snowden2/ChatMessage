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
func LogoutUser() {

	ResignOneSignalId()
	UpdateLastTerminate(fetch: false)

	if (FUser.logOut()) {
		CacheManager.cleanupManual(logout: true)
		RealmManager.cleanupDatabase()
		NotificationCenterX.post(notification: NOTIFICATION_USER_LOGGED_OUT)
	} else {
		ProgressHUD.showError("Logout error.")
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func LoginUser(target: Any) {

	let viewController = target as! UIViewController
	let welcomeView = WelcomeView()
	viewController.present(welcomeView, animated: true) {
		viewController.tabBarController?.selectedIndex = Int(DEFAULT_TAB)
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func OnboardUser(target: Any) {

	let viewController = target as! UIViewController
	let editProfileView = EditProfileView(isOnboard: true)
	let navController = NavigationController(rootViewController: editProfileView)
	viewController.present(navController, animated: true)
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UserLoggedIn(loginMethod: String) {

	UpdateUserSettings(loginMethod: loginMethod)
	UpdateOneSignalId()
	UpdateLastActive()

	LinkedId.createItem()

	if (FUser.isOnboardOk()) {
		ProgressHUD.showSuccess("Welcome back!")
	} else {
		ProgressHUD.showSuccess("Welcome!")
	}

	NotificationCenterX.post(notification: NOTIFICATION_USER_LOGGED_IN)
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UpdateUserSettings(loginMethod: String) {

	var update = false
	let user = FUser.currentUser()

	if (user[FUSER_LOGINMETHOD] as? String == nil)	{ update = true; user[FUSER_LOGINMETHOD] = loginMethod		}

	if (user[FUSER_KEEPMEDIA] as? Int == nil)		{ update = true; user[FUSER_KEEPMEDIA] = KEEPMEDIA_FOREVER	}
	if (user[FUSER_NETWORKIMAGE] as? Int == nil)	{ update = true; user[FUSER_NETWORKIMAGE] = NETWORK_ALL		}
	if (user[FUSER_NETWORKVIDEO] as? Int == nil)	{ update = true; user[FUSER_NETWORKVIDEO] = NETWORK_ALL		}
	if (user[FUSER_NETWORKAUDIO] as? Int == nil)	{ update = true; user[FUSER_NETWORKAUDIO] = NETWORK_ALL		}

	if (user[FUSER_LASTACTIVE] as? Int64 == nil)	{ update = true; user[FUSER_LASTACTIVE] = 0					}
	if (user[FUSER_LASTTERMINATE] as? Int64 == nil)	{ update = true; user[FUSER_LASTTERMINATE] = 0				}

	if (user[FUSER_PICTUREAT] as? Int64 == nil)		{ update = true; user[FUSER_PICTUREAT] = 0					}

	if (update) {
		user.saveInBackground()
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UpdateOneSignalId() {

	if (FUser.currentId() != "") {
		if (UserDefaultsX.string(key: ONESIGNALID) != nil) {
			AssignOneSignalId()
		} else {
			ResignOneSignalId()
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func AssignOneSignalId() {

	if let oneSignalId = UserDefaultsX.string(key: ONESIGNALID) {
		if (FUser.oneSignalId() != oneSignalId) {
			let user = FUser.currentUser()
			user[FUSER_ONESIGNALID] = oneSignalId
			user.saveInBackground()
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func ResignOneSignalId() {

	let oneSignalId = FUser.oneSignalId()
	if (oneSignalId.count != 0) {
		let user = FUser.currentUser()
		user[FUSER_ONESIGNALID] = ""
		user.saveInBackground()
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UpdateLastActive() {

	if (FUser.currentId() != "") {
		let user = FUser.currentUser()
		user[FUSER_LASTACTIVE] = ServerValue.timestamp()
		user.saveInBackground(block: { error in
			user.fetchInBackground()
		})
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UpdateLastTerminate(fetch: Bool) {

	if (FUser.currentId() != "") {
		let user = FUser.currentUser()
		user[FUSER_LASTTERMINATE] = ServerValue.timestamp()
		user.saveInBackground(block: { error in
			if (fetch) {
				user.fetchInBackground()
			}
		})
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
func UserLastActive(dbuser: DBUser) -> String {

	if (Blocker.isBlocker(userId: dbuser.objectId) == false) {
		if (dbuser.lastActive < dbuser.lastTerminate) {
			return "last active: \(TimeElapsed(timestamp: dbuser.lastTerminate))"
		}
		return "online now"
	}
	return ""
}
