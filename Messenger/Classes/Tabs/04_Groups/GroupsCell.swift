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
class GroupsCell: UITableViewCell {

	@IBOutlet var imageGroup: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelMembers: UILabel!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(dbgroup: DBGroup) {

		imageGroup.image = UIImage(named: "groups_blank")
		imageGroup.layer.cornerRadius = imageGroup.frame.size.width / 2
		imageGroup.layer.masksToBounds = true

		labelInitials.text = String(dbgroup.name.prefix(1))
		labelName.text = dbgroup.name

		let members = dbgroup.members.components(separatedBy: ",")
		labelMembers.text = "\(members.count) members"
	}
}
