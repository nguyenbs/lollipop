package com.thinknickel.thecollector;

import flash.display.BitmapData;
import flash.events.EventDispatcher;

class UserObj extends EventDispatcher
{
    
    public static var instance : UserObj;
    
    public static inline var DONE_SENDING_EMAIL : String = "donesendingemail";
    
    
    public var tid : String;
    
    public var facebookID : String = "1";
    
    public var bitly : String;
    
    public var key : String = "5!$%ajd9djf5930@jf0a9dkkakk%kf9zz";
    
    public var senderFName : String;
    
    public var senderLName : String;
    
    public var userID : String = "1";
    
    public var recipFName : String;
    
    public var recipLName : String;
    
    public var recipUID : String;
    
    public var recipEmail : String;
    
    public var recipName : String;
    
    public var senderName : String;
    
    public var sendCopy : Bool = false;
    
    public var birthday : String;
    
    public var work : Dynamic;
    
    public var education : Dynamic;
    
    public var hometown : Dynamic;
    
    public var fbimage : String;
    
    public var filefolder : String;
    
    public var picBig : String;
    
    public var profileimg : String;
    
    public var phoneType : String;
    
    public var answer1 : String;
    
    public var senderEmail : String = "testemail@test.com";
    
    public var state : String = "teststate";
    
    public var city : String = "testcity";
    
    public var region : String = "testregion";
    
    public var userInfo : FastXML;
    
    public var userPhoto : BitmapData;
    
    public var userPic : BitmapData;
    
    public var userFBPage : BitmapData;
    
    public var senderZip : String = "";
    
    public var registered : Bool = false;
    
    public var hasUploaded : Bool = false;
    
    public var category : String;
    
    public var phrase : String;
    
    public var tags : String;
    
    public var font : String = "Bembo Bold";
    
    public var location : Dynamic;
    
    public var significant : Dynamic;
    
    public var pickedFriend : String;
    
    public var pickedFriendID : Dynamic;
    
    public function new()
    {
        location = { };
        super();
        instance = this;
    }
    
    public static function getInstance() : UserObj
    {
        return instance;
    }
}

