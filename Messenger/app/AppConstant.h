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
#define		ONESIGNAL_APPID						@"15cad58e-b84c-47e1-a29b-932e88457132"
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		SINCH_HOST							@"sandbox.sinch.com"
#define		SINCH_KEY							@"b515eb8b-dcaf-473d-982a-81c5a97a3a1e"
#define		SINCH_SECRET						@"mgnwHKZLIkahFoj90UsbCg=="
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DIALOGFLOW_ACCESS_TOKEN				@"bbf2a09367b948e49d44d5aaa97724f6"
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DEFAULT_TAB							0
#define		DEFAULT_COUNTRY						188
//---------------------------------------------------------------------------------
#define		VIDEO_LENGTH						5
#define		INSERT_MESSAGES						10
#define		DOWNLOAD_TIMEOUT					300
//---------------------------------------------------------------------------------
#define		STATUS_LOADING						1
#define		STATUS_SUCCEED						2
#define		STATUS_MANUAL						3
//---------------------------------------------------------------------------------
#define		MEDIA_IMAGE							1
#define		MEDIA_VIDEO							2
#define		MEDIA_AUDIO							3
//---------------------------------------------------------------------------------
#define		NETWORK_MANUAL						1
#define		NETWORK_WIFI						2
#define		NETWORK_ALL							3
//---------------------------------------------------------------------------------
#define		KEEPMEDIA_WEEK						1
#define		KEEPMEDIA_MONTH						2
#define		KEEPMEDIA_FOREVER					3
//---------------------------------------------------------------------------------
#define		CALLHISTORY_AUDIO					@"audio"
#define		CALLHISTORY_VIDEO					@"video"
//---------------------------------------------------------------------------------
#define		MESSAGE_STATUS						@"status"
#define		MESSAGE_TEXT						@"text"
#define		MESSAGE_EMOJI						@"emoji"
#define		MESSAGE_PICTURE						@"picture"
#define		MESSAGE_VIDEO						@"video"
#define		MESSAGE_AUDIO						@"audio"
#define		MESSAGE_LOCATION					@"location"
//---------------------------------------------------------------------------------
#define		LOGIN_EMAIL							@"Email"
#define		LOGIN_PHONE							@"Phone"
//---------------------------------------------------------------------------------
#define		TEXT_QUEUED							@"Queued"
#define		TEXT_SENT							@"Sent"
#define		TEXT_READ							@"Read"
//---------------------------------------------------------------------------------
#define		TEXT_SHARE_APP						@"Check out PremiumChat for your smartphone. Download it today."
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		FBLOCKED_PATH						@"Blocked"				//	Path name
#define		FBLOCKED_OBJECTID					@"objectId"				//	String

#define		FBLOCKED_BLOCKEDID					@"blockedId"			//	String
#define		FBLOCKED_ISDELETED					@"isDeleted"			//	Boolean

#define		FBLOCKED_CREATEDAT					@"createdAt"			//	Timestamp
#define		FBLOCKED_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FBLOCKER_PATH						@"Blocker"				//	Path name
#define		FBLOCKER_OBJECTID					@"objectId"				//	String

#define		FBLOCKER_BLOCKERID					@"blockerId"			//	String
#define		FBLOCKER_ISDELETED					@"isDeleted"			//	Boolean

#define		FBLOCKER_CREATEDAT					@"createdAt"			//	Timestamp
#define		FBLOCKER_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FCALLHISTORY_PATH					@"CallHistory"			//	Path name
#define		FCALLHISTORY_OBJECTID				@"objectId"				//	String

#define		FCALLHISTORY_INITIATORID			@"initiatorId"			//	String
#define		FCALLHISTORY_RECIPIENTID			@"recipientId"			//	String
#define		FCALLHISTORY_PHONENUMBER			@"phoneNumber"			//	String

#define		FCALLHISTORY_TYPE					@"type"					//	String
#define		FCALLHISTORY_TEXT					@"text"					//	String

#define		FCALLHISTORY_STATUS					@"status"				//	String
#define		FCALLHISTORY_DURATION				@"duration"				//	Number

#define		FCALLHISTORY_STARTEDAT				@"startedAt"			//	Timestamp
#define		FCALLHISTORY_ESTABLISHEDAT			@"establishedAt"		//	Timestamp
#define		FCALLHISTORY_ENDEDAT				@"endedAt"				//	Timestamp

#define		FCALLHISTORY_ISDELETED				@"isDeleted"			//	Boolean

#define		FCALLHISTORY_CREATEDAT				@"createdAt"			//	Timestamp
#define		FCALLHISTORY_UPDATEDAT				@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FFRIEND_PATH						@"Friend"				//	Path name
#define		FFRIEND_OBJECTID					@"objectId"				//	String

#define		FFRIEND_FRIENDID					@"friendId"				//	String
#define		FFRIEND_ISDELETED					@"isDeleted"			//	Boolean

#define		FFRIEND_CREATEDAT					@"createdAt"			//	Timestamp
#define		FFRIEND_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FGROUP_PATH							@"Group"				//	Path name
#define		FGROUP_OBJECTID						@"objectId"				//	String

#define		FGROUP_USERID						@"userId"				//	String
#define		FGROUP_NAME							@"name"					//	String
#define		FGROUP_MEMBERS						@"members"				//	Array

#define		FGROUP_ISDELETED					@"isDeleted"			//	Boolean

#define		FGROUP_CREATEDAT					@"createdAt"			//	Timestamp
#define		FGROUP_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FLASTREAD_PATH						@"LastRead"				//	Path name
//---------------------------------------------------------------------------------
#define		FMESSAGE_PATH						@"Message"				//	Path name
#define		FMESSAGE_OBJECTID					@"objectId"				//	String

#define		FMESSAGE_CHATID						@"chatId"				//	String
#define		FMESSAGE_MEMBERS					@"members"				//	Array

#define		FMESSAGE_SENDERID					@"senderId"				//	String
#define		FMESSAGE_SENDERNAME					@"senderName"			//	String
#define		FMESSAGE_SENDERINITIALS				@"senderInitials"		//	String
#define		FMESSAGE_SENDERPICTUREAT			@"senderPictureAt"		//	Timestamp

#define		FMESSAGE_RECIPIENTID				@"recipientId"			//	String
#define		FMESSAGE_RECIPIENTNAME				@"recipientName"		//	String
#define		FMESSAGE_RECIPIENTINITIALS			@"recipientInitials"	//	String
#define		FMESSAGE_RECIPIENTPICTUREAT			@"recipientPictureAt"	//	Timestamp

#define		FMESSAGE_GROUPID					@"groupId"				//	String
#define		FMESSAGE_GROUPNAME					@"groupName"			//	String

#define		FMESSAGE_TYPE						@"type"					//	String
#define		FMESSAGE_TEXT						@"text"					//	String

#define		FMESSAGE_PICTUREWIDTH				@"pictureWidth"			//	Number
#define		FMESSAGE_PICTUREHEIGHT				@"pictureHeight"		//	Number
#define		FMESSAGE_PICTUREMD5					@"pictureMD5"			//	String

#define		FMESSAGE_VIDEODURATION				@"videoDuration"		//	Number
#define		FMESSAGE_VIDEOMD5					@"videoMD5"				//	String

#define		FMESSAGE_AUDIODURATION				@"audioDuration"		//	Number
#define		FMESSAGE_AUDIOMD5					@"audioMD5"				//	String

#define		FMESSAGE_LATITUDE					@"latitude"				//	Number
#define		FMESSAGE_LONGITUDE					@"longitude"			//	Number

#define		FMESSAGE_STATUS						@"status"				//	String
#define		FMESSAGE_ISDELETED					@"isDeleted"			//	Boolean

#define		FMESSAGE_CREATEDAT					@"createdAt"			//	Timestamp
#define		FMESSAGE_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FMUTEDUNTIL_PATH					@"MutedUntil"			//	Path name
//---------------------------------------------------------------------------------
#define		FSTATUS_PATH						@"Status"				//	Path name
#define		FSTATUS_OBJECTID					@"objectId"				//	String

#define		FSTATUS_CHATID						@"chatId"				//	String

#define		FSTATUS_LASTREAD					@"lastRead"				//	Timestamp
#define		FSTATUS_MUTEDUNTIL					@"mutedUntil"			//	Timestamp

#define		FSTATUS_CREATEDAT					@"createdAt"			//	Timestamp
#define		FSTATUS_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FTYPING_PATH						@"Typing"				//	Path name
//---------------------------------------------------------------------------------
#define		FUSER_PATH							@"User"					//	Path name
#define		FUSER_OBJECTID						@"objectId"				//	String

#define		FUSER_EMAIL							@"email"				//	String
#define		FUSER_PHONE							@"phone"				//	String

#define		FUSER_FIRSTNAME						@"firstname"			//	String
#define		FUSER_LASTNAME						@"lastname"				//	String
#define		FUSER_FULLNAME						@"fullname"				//	String
#define		FUSER_COUNTRY						@"country"				//	String
#define		FUSER_LOCATION						@"location"				//	String
#define		FUSER_STATUS						@"status"				//	String

#define		FUSER_KEEPMEDIA						@"keepMedia"			//	Number
#define		FUSER_NETWORKIMAGE					@"networkImage"			//	Number
#define		FUSER_NETWORKVIDEO					@"networkVideo"			//	Number
#define		FUSER_NETWORKAUDIO					@"networkAudio"			//	Number
#define		FUSER_WALLPAPER						@"wallpaper"			//	String

#define		FUSER_LOGINMETHOD					@"loginMethod"			//	String
#define		FUSER_ONESIGNALID					@"oneSignalId"			//	String

#define		FUSER_LASTACTIVE					@"lastActive"			//	Timestamp
#define		FUSER_LASTTERMINATE					@"lastTerminate"		//	Timestamp

#define		FUSER_LINKEDIDS						@"linkedIds"			//	Dictionary

#define		FUSER_PICTUREAT						@"pictureAt"			//	Timestamp
#define		FUSER_CREATEDAT						@"createdAt"			//	Timestamp
#define		FUSER_UPDATEDAT						@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FUSERSTATUS_PATH					@"UserStatus"			//	Path name
#define		FUSERSTATUS_OBJECTID				@"objectId"				//	String

#define		FUSERSTATUS_NAME					@"name"					//	String

#define		FUSERSTATUS_CREATEDAT				@"createdAt"			//	Timestamp
#define		FUSERSTATUS_UPDATEDAT				@"updatedAt"			//	Timestamp
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		ONESIGNALID							@"OneSignalId"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NotificationAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NotificationUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NotificationUserLoggedOut"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_REFRESH_BLOCKEDS		@"NotificationRefreshBlockeds"
#define		NOTIFICATION_REFRESH_BLOCKERS		@"NotificationRefreshBlockers"
#define		NOTIFICATION_REFRESH_CALLHISTORIES	@"NotificationRefreshCallHistories"
#define		NOTIFICATION_REFRESH_CHATS			@"NotificationRefreshChats"
#define		NOTIFICATION_REFRESH_FRIENDS		@"NotificationRefreshFriends"
#define		NOTIFICATION_REFRESH_GROUPS			@"NotificationRefreshGroups"
#define		NOTIFICATION_REFRESH_MESSAGES1		@"NotificationRefreshMessages1"
#define		NOTIFICATION_REFRESH_MESSAGES2		@"NotificationRefreshMessages2"
#define		NOTIFICATION_REFRESH_STATUSES		@"NotificationRefreshStatuses"
#define		NOTIFICATION_REFRESH_USERS			@"NotificationRefreshUsers"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_CLEANUP_CHATVIEW		@"NotificationCleanupChatView"
//-------------------------------------------------------------------------------------------------------------------------------------------------
