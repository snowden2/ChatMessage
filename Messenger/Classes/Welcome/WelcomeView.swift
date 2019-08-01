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
class WelcomeView: UIViewController, LoginPhoneDelegate, LoginEmailDelegate, RegisterEmailDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
	}

	// MARK: - Phone login methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoginPhone(_ sender: Any) {

		let loginPhoneView = LoginPhoneView()
		loginPhoneView.delegate = self
		let navController = NavigationController(rootViewController: loginPhoneView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didLoginPhone() {

		dismiss(animated: true) {
			UserLoggedIn(loginMethod: LOGIN_PHONE)
		}
	}

	// MARK: - Email login methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionLoginEmail(_ sender: Any) {

		let loginEmailView = LoginEmailView()
		loginEmailView.delegate = self
		present(loginEmailView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didLoginEmail() {

		dismiss(animated: true) {
			UserLoggedIn(loginMethod: LOGIN_EMAIL)
		}
	}

	// MARK: - Email register methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionRegisterEmail(_ sender: Any) {

		let registerEmailView = RegisterEmailView()
		registerEmailView.delegate = self
		present(registerEmailView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func didRegisterUser() {

		dismiss(animated: true) {
			UserLoggedIn(loginMethod: LOGIN_EMAIL)
		}
	}
}
