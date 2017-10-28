package com.thinknickel.thecollector;

import haxe.Constraints.Function;
import flash.display.Sprite;
import flash.events.Event;

class FacebookConnector extends Sprite
{
    
    public static var instance : FacebookConnector;
    
    public static inline var GETTING_PERMS : String = "gettingperms";
    
    public static inline var GOT_PERMS : String = "gotperms";
    
    public static inline var PERMS_CANCELLED : String = "permscancelled";
    
    
    public var token : String;
    
    private var callback : Function;
    
    private var loggedIn : Bool = false;
    
    private var showingPerms : Bool = false;
    
    private var required : Bool = false;
    
    private var permissionString : String = "user_relationship_details,user_birthday,user_photos,user_posts,user_location,user_relationships";
    
    private var coverSprite : Sprite;
    
    private var appID : String;
    
    public function new(appID : String)
    {
        super();
        instance = this;
        this.appID = appID;
        this.addEventListener("addedToStage", added);
    }
    
    public static function getInstance() : FacebookConnector
    {
        return instance;
    }
    
    private function added(e : Event) : Void
    {
        var params : Dynamic = { };
        params.cookie = true;
        params.status = true;
        params.oauth = true;
        Facebook.init(appID, doneInit, params);
        coverSprite = new Sprite();
        coverSprite.graphics.beginFill(0, 0.4);
        coverSprite.graphics.drawRect(0, 0, 100, 100);
        coverSprite.graphics.endFill();
        coverSprite.visible = false;
        coverSprite.alpha = 0;
        this.addChild(coverSprite);
    }
    
    public function tryLogin(cb : Function = null, required : Bool = true) : Void
    {
        showingPerms = false;
        this.required = required;
        callback = cb;
        trace("loggedIn=" + loggedIn);
        if (this.loggedIn)
        {
            gotFBPerms();
            carryOn();
        }
        else
        {
            showingPerms = true;
            if (required)
            {
                gettingFBPerms();
            }
            Facebook.addJSEventListener("auth.sessionChange", gotLoginStatus2);
            Facebook.login(sessChanged, {
                        scope : permissionString
                    });
        }
    }
    
    private function gotPermissionCheck(response : Dynamic, fail : Dynamic) : Void
    {
        var permArray : Dynamic = null;
        var j : Int = 0;
        if (fail != null)
        {
            this.loggedIn = false;
            if (required)
            {
                gotFBPerms();
            }
            return;
        }
        var permissionList : Dynamic = try cast(Reflect.field(response, Std.string(0)), Dynamic) catch(e:Dynamic) null;
        if (permissionList == null)
        {
            this.loggedIn = false;
            if (required)
            {
                gotFBPerms();
            }
            return;
        }
        this.loggedIn = true;
        permArray = permissionString.split(",");
        if (required)
        {
            gotFBPerms();
        }
        carryOn();
    }
    
    private function sessChanged(response : Dynamic, fail : Dynamic = null) : Void
    {
        trace("sessChanged");
        trace("token=" + Facebook.getAuthResponse().accessToken);
        if (Facebook.getAuthResponse().accessToken)
        {
            gotLoginStatus2(response, fail);
        }
    }
    
    private function gotLoginStatus2(response : Dynamic, fail : Dynamic = null) : Void
    {
        trace("login response2=" + response);
        trace("login response2=" + fail);
        trace("uid" + Facebook.getAuthResponse().uid);
        if (Facebook.getAuthResponse().accessToken)
        {
            UserObj.getInstance().facebookID = Facebook.getAuthResponse().uid;
            UserObj.getInstance().userID = UserObj.getInstance().facebookID;
            Facebook.api("me/permissions", gotPermissionCheck);
        }
        else
        {
            if (!required)
            {
                if (required)
                {
                    gotFBPerms();
                }
                carryOn();
            }
            else
            {
                if (showingPerms)
                {
                    cancelledPerms();
                }
                else
                {
                    showingPerms = true;
                    trace("doing login");
                    Facebook.login(gotLoginStatus2, {
                                scope : permissionString
                            });
                }
            }
        }
    }
    
    public function getFriendList(cb : Function) : Void
    {
        trace("getting flist");
        var fql : String = "SELECT uid FROM user WHERE is_app_user = 1 AND uid IN (SELECT uid1 FROM friend WHERE uid2 = me())";
        Facebook.fqlQuery(fql, cb);
    }
    
    public function getFriendsThatUseApp(cb : Function) : Void
    {
        trace("getting flist");
        var fql : String = "SELECT uid,pic_square FROM user WHERE has_added_app = 1 AND uid IN (SELECT uid1 FROM friend WHERE uid2 = me())";
        Facebook.fqlQuery(fql, cb);
    }
    
    private function carryOn() : Void
    {
        if (callback != null)
        {
            Reflect.callMethod(null, callback, []);
            callback = null;
        }
    }
    
    public function doneInit(response : Dynamic, fail : Dynamic) : Void
    {
        trace("response=" + response);
        trace("fail=" + fail);
        trace("Facebook.getAuthResponse().uid=" + Facebook.getAuthResponse().uid);
        if (Facebook.getAuthResponse().accessToken != null)
        {
            this.loggedIn = true;
            UserObj.getInstance().facebookID = Facebook.getAuthResponse().uid;
            UserObj.getInstance().userID = UserObj.getInstance().facebookID;
            Facebook.api("me/permissions", gotPermissionCheck);
        }
        if (response != null)
        {
        }
    }
    
    private function gotFBPerms(event : Event = null) : Void
    {
        TweenMax.to(coverSprite, 0.3, {
                    autoAlpha : 0,
                    overwrite : true
                });
        this.dispatchEvent(new Event("fbclicked"));
    }
    
    private function cancelledPerms(event : Event = null) : Void
    {
        TweenMax.to(coverSprite, 0.3, {
                    autoAlpha : 0,
                    overwrite : true
                });
        this.dispatchEvent(new Event("permscancelled"));
    }
    
    private function gettingFBPerms(event : Event = null) : Void
    {
    }
}

