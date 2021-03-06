//
//  Constants.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

// FILE CONTAINING ALL THE CONSTANTS NEEDED TO MAKE CALLS TO DATABASE

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

public var recentBadgeHandler: ListenerRegistration?
let userDefaults = UserDefaults.standard

//NOTIFICATIONS
// Variable that can use auto complete instead of typing out " " everytime
public let USER_DID_LOGIN_NOTIFICATION = "UserDidLoginNotification"
public let APP_STARTED_NOTIFICATION = "AppStartedNotification"



//IDS and Keys
// Firebase reference key
public let kFILEREFERENCE = "gs://slate-ce521.appspot.com"
// app ID
//public let kONESIGNALAPPID = "f9e87345-1edd-4b3f-bc5a-62f17892f27d"
// key for call function (if needed)
public let kSINCHKEY = ""
public let kSINCHSECRET = ""
// URL on appstore
public let kAPPURL = "https://www.slateofficial.com"



//Firebase Headers
// General headers for firebase store directory
public let kUSER_PATH = "User"
public let kTYPINGPATH_PATH = "Typing"
public let kRECENT_PATH = "Recent"
public let kMESSAGE_PATH = "Message"
public let kGROUP_PATH = "Group"
public let kCALL_PATH = "Call"

//FUser
// All variables that will be saved into firebase database
// variables used for safety to avoid mispelling
public let kOBJECTID = "objectId"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kPHONE = "phone"
public let kCOUNTRYCODE = "countryCode"
public let kFACEBOOK = "facebook"
public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kFULLNAME = "fullname"
public let kAVATAR = "avatar"
public let kCURRENTUSER = "currentUser"
public let kISONLINE = "isOnline"
public let kVERIFICATIONCODE = "firebase_verification"
public let kCITY = "city"
public let kCOUNTRY = "country"
public let kBLOCKEDUSERID = "blockedUserId"
public let kFRIENDLISTIDS = "friendListIds"

//
public let kBACKGROUNDIMAGE = "backgroundImage"
public let kSHOWAVATAR = "showAvatar"
public let kPASSWORDPROTECT = "passwordProtect"
public let kFIRSTRUN = "firstRun"
// duration of video or audio message
public let kMAXDURATION = 120.0
public let kAUDIOMAXDURATION = 120.0
public let kSUCCESS = 2

//recent
// variables linked to recent chats in databse
public let kCHATROOMID = "chatRoomId"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kMESSAGE = "message"
public let kMEMBERSTOPUSH = "membersToPush"
public let kDISCRIPTION = "discription"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"
public let kISDELETED = "isDeleted"

//Contacts
public let kCONTACT = "contact"
public let kCONTACTID = "contactId"

//message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kPHOTO = "photo"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

//coordinates
public let kLATITUDE = "latitude"
public let kLONGITUDE = "longitude"


//message status
public let kDELIVERED = "Delivered"
public let kREADDATE = "readDate"
public let kDELETED = "deleted"
public let kSENT = "Sent"
public let kREAD = "Read"
public let kNUMBEROFMESSAGES = 12

//push
public let kDEVICEID = "deviceId"



//Call
public let kISINCOMING = "isIncoming"
public let kCALLERID = "callerId"
public let kCALLERFULLNAME = "callerFullName"
public let kCALLSTATUS = "callStatus"
public let kWITHUSERFULLNAME = "withUserFullName"
public let kCALLERAVATAR = "callerAvatar"
public let kWITHUSERAVATAR = "withUserAvatar"

//translation
public let kLANGUAGE = "language"
public let kTMESSAGE = "tMessage"

enum CustomColor {
    
    static let customBackgroundColor  = UIColor(named: "BackgroundColor")
    static let settingsBackgroundColor = UIColor(named: "SettingsColor")
//    static let customButtonColor      = UIColor(named: "ButtonBackgroundColor")
//    static let customLabelColor       = UIColor(named: "LabelColor")
}
