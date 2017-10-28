package com.thinknickel.thecollector.fakepage;

import com.fproject.media.events.LoaderEvent;
import com.fproject.media.ImageLoader;
import assets.McAlbumview;
import assets.McComment;
import assets.McFacebookwall;
import assets.McFbwallpost;
import com.thinknickel.thecollector.UserObj;
import com.thinknickel.utils.Reloader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.LoaderContext;
import flash.text.TextFormat;

class FakeFacebookPage extends McFacebookwall
{
    
    public static inline var DONE_UPLOADING : String = "doneuploading";
    
    public static inline var DONE_CREATING : String = "donecreating";
    
    public static var GOT_PROFILE_PIC : String = "gotprofilepic";
    
    public static var UPDATE_LOADER : String = "updateloader";
    
    
    private var postArray : Array<Dynamic>;
    
    private var picBig : ImageLoader;
    
    private var uid : String;
    
    private var pageBuildTimeout : Float;
    
    private var connectAttempt : Int = 0;
    
    private var profilePic : ImageLoader;
    
    private var fbImg : BitmapData;
    
    public var zoom1BD : BitmapData;
    
    public var zoom1BM : Bitmap;
    
    private var photoHolder : Sprite;
    
    private var topPhotos : Sprite;
    
    private var sigHolder : Sprite;
    
    private var skipPhotos : Bool = false;
    
    private var albumbk : McAlbumview;
    
    public function new()
    {
        super();
        connectAttempt = 0;
        this.name_txt.text = "";
        createPage();
    }
    
    public function createPage() : Void
    {
        uid = UserObj.getInstance().userID;
        this.mouseChildren = false;
        this.mouseEnabled = false;
        photoHolder = new Sprite();
        this.addChild(photoHolder);
        topPhotos = new Sprite();
        this.addChild(topPhotos);
        topPhotos.x = 257;
        topPhotos.y = 144;
        sigHolder = new Sprite();
        this.addChild(sigHolder);
        sigHolder.visible = false;
        photoHolder.visible = false;
        getProfilePic();
        getFriendList();
        getPhotos();
        doneLoadingAll();
    }
    
    private function getFriendList() : Void
    {
        var uid : String = UserObj.getInstance().userID;
        Facebook.api("me/friends", gotFriendList);
    }
    
    private function getPhotos() : Void
    {
        var uid : String = UserObj.getInstance().userID;
        Facebook.api("me/photos?limit=50&fields=id,name,picture,source,comments,from,created_time,height,width&", gotPhotos);
    }
    
    private function getAlbums() : Void
    {
        Facebook.api("me/albums?fields=id,count&", gotAlbums);
    }
    
    private function gotAlbums(response : Dynamic, fail : Dynamic) : Void
    {
        var i : Int = 0;
        var pick : Int = 0;
        var id : Dynamic = null;
        id = null;
        var arr : Array<Dynamic> = [];
        if (fail != null)
        {
            this.dispatchEvent(new Event(UPDATE_LOADER));
            return;
        }
        var photos : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (photos == null)
        {
            photos = [];
        }
        var pool : Array<Dynamic> = [];
        i = 0;
        while (i < photos.length)
        {
            if (photos[i].count > 10)
            {
                pool.push(photos[i]);
            }
            i++;
        }
        if (pool.length > 0)
        {
            pick = Math.floor(Math.random() * pool.length);
            id = pool[pick].id;
        }
        else
        {
            id = "me";
        }
        Facebook.api(id + "/photos?limit=50&fields=id,name,picture,source,comments,from,created_time,height,width&", gotPhotos);
    }
    
    private function gotPhotos2(response : Dynamic, fail : Dynamic) : Void
    {
        var i : Int = 0;
        var src : Dynamic = null;
        var lc : Dynamic = null;
        var ldr : Dynamic = null;
        var j : Int = 0;
        var pick : Int = 0;
        var pic : Dynamic = null;
        i = 0;
        lc = null;
        ldr = null;
        if (fail != null)
        {
            this.dispatchEvent(new Event(UPDATE_LOADER));
            return;
        }
        var photos : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (photos == null)
        {
            photos = [];
        }
        trace("-----------------" + photos.length);
        if (photos.length < 6)
        {
            if (skipPhotos)
            {
                this.dispatchEvent(new Event(UPDATE_LOADER));
                return;
            }
            skipPhotos = true;
            ExternalInterface.addCallback("gotPhotos1", gotPhotos);
            ExternalInterface.call("getPhotos");
            return;
        }
        i = 0;
        while (i < 5)
        {
            src = photos[i].src_big;
            lc = new LoaderContext(true);
            ldr = new ImageLoader(src, {
                        width : 105,
                        height : 75,
                        crop : true,
                        scaleMode : "proportionalOutside",
                        container : topPhotos,
                        onComplete : doneLoading2,
                        context : lc,
                        allowMalformedURL : true
                    });
            ldr.load();
            ldr.content.x = i * 110;
            i++;
        }
        var pool : Array<Dynamic> = [];
        var len : Int = Math.min(6, photos.length);
        j = 0;
        while (j < len)
        {
            pick = Math.floor(Math.random() * photos.length);
            pic = photos[pick];
            photos.splice(pick, 1);
            pool.push(pic);
            j++;
        }
        i = 0;
        while (i < pool.length)
        {
            lc = new LoaderContext(true);
            ldr = new ImageLoader(pool[i].src_big, {
                        container : photoHolder,
                        onComplete : doneLoading2,
                        context : lc,
                        allowMalformedURL : true
                    });
            ldr.load();
            ldr.content.visible = false;
            i++;
        }
        this.dispatchEvent(new Event(UPDATE_LOADER));
    }
    
    private function gotPhotos(response : Dynamic, fail : Dynamic) : Void
    {
        var i : Int = 0;
        var src : Dynamic = null;
        var lc : Dynamic = null;
        var ldr : Dynamic = null;
        var j : Int = 0;
        var pick : Int = 0;
        var pic : Dynamic = null;
        i = 0;
        var albumPhoto : Dynamic = null;
        if (fail != null)
        {
            this.dispatchEvent(new Event(UPDATE_LOADER));
            return;
        }
        var photos : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (photos == null)
        {
            photos = [];
        }
        trace("-----------------" + photos.length);
        if (photos.length < 6)
        {
            if (skipPhotos)
            {
                this.dispatchEvent(new Event(UPDATE_LOADER));
                return;
            }
            skipPhotos = true;
            getAlbums();
            return;
        }
        i = 0;
        while (i < 5)
        {
            src = photos[i].picture;
            lc = new LoaderContext(true);
            ldr = new ImageLoader(src, {
                        width : 105,
                        height : 75,
                        crop : true,
                        scaleMode : "proportionalOutside",
                        container : topPhotos,
                        onComplete : doneLoading2,
                        context : lc,
                        allowMalformedURL : true
                    });
            ldr.load();
            ldr.content.x = i * 110;
            i++;
        }
        var pool : Array<Dynamic> = [];
        var len : Int = Math.min(6, photos.length);
        j = 0;
        while (j < len)
        {
            pick = Math.floor(Math.random() * photos.length);
            pic = photos[pick];
            photos.splice(pick, 1);
            pool.push(pic);
            j++;
        }
        i = 0;
        while (i < pool.length)
        {
            albumPhoto = new AlbumPhoto(pool[i]);
            photoHolder.addChild(albumPhoto);
            i++;
        }
        this.dispatchEvent(new Event(UPDATE_LOADER));
    }
    
    private function doneLoading2(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        if (ldr.scriptAccessDenied)
        {
            trace("ldr.scriptAccessDenied");
            reloader = new Reloader(ldr, ldr.content.parent);
        }
    }
    
    private function gotSignificant(response : Dynamic, fail : Dynamic) : Void
    {
        var i : Int = 0;
        var lc : Dynamic = null;
        var ldr : Dynamic = null;
        if (fail != null)
        {
            return;
        }
        var photos : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (photos == null)
        {
            photos = [];
        }
        i = 0;
        while (i < photos.length)
        {
            trace("photos[i].src_big=" + photos[i].src_big);
            lc = new LoaderContext(true);
            ldr = new ImageLoader(photos[i].src_big, {
                        container : sigHolder,
                        onComplete : doneLoading2,
                        context : lc,
                        allowMalformedURL : true
                    });
            ldr.load();
            ldr.content.visible = false;
            i++;
        }
    }
    
    private function gotFriendList(response : Dynamic, fail : Dynamic) : Void
    {
        var j : Int = 0;
        var pick : Int = 0;
        var pic : Dynamic = null;
        var prev : Dynamic = null;
        var i : Int = 0;
        var friendMC : Dynamic = null;
        if (fail != null)
        {
            return;
        }
        var details : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (details.length == 0)
        {
            this.dispatchEvent(new Event(UPDATE_LOADER));
            return;
        }
        var pick1 : Int = Math.floor(Math.random() * details.length);
        UserObj.getInstance().pickedFriend = details[pick1].name;
        UserObj.getInstance().pickedFriendID = details[pick1].id;
        var pool : Array<Dynamic> = [];
        var len : Int = Math.min(details.length, 10);
        j = 0;
        while (j < len)
        {
            pick = Math.floor(Math.random() * details.length);
            pic = details[pick];
            details.splice(pick, 1);
            pool.push(pic);
            j++;
        }
        i = 0;
        while (i < pool.length)
        {
            friendMC = new FriendIconMC(pool[i].id, pool[i].name);
            this.addChild(friendMC);
            friendMC.x = 38;
            if (i == 0)
            {
                friendMC.y = 445;
            }
            else
            {
                friendMC.y = prev.y + prev.height + 10;
            }
            prev = friendMC;
            i++;
        }
        this.dispatchEvent(new Event(UPDATE_LOADER));
    }
    
    private function getProfilePic() : Void
    {
        ExternalInterface.addCallback("gotProfilePic", gotProfilePic);
        ExternalInterface.call("getProfilePic");
    }
    
    private function gotProfilePic(response : String) : Void
    {
        trace("profilepic=" + response);
        UserObj.getInstance().picBig = response;
        getName();
    }
    
    private function getName() : Void
    {
        var uid : String = UserObj.getInstance().userID;
        ExternalInterface.addCallback("gotName1", gotName);
        ExternalInterface.call("getName");
        trace("UID=" + uid);
    }
    
    private function gotName(response : Dynamic) : Void
    {
        var details : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        var fname : String = details[0].first_name;
        var lname : String = details[0].last_name;
        UserObj.getInstance().senderFName = fname;
        UserObj.getInstance().senderLName = lname;
        UserObj.getInstance().location = details[0].current_location;
        UserObj.getInstance().birthday = details[0].birthday;
        UserObj.getInstance().work = Reflect.field(details[0], "work");
        UserObj.getInstance().education = Reflect.field(details[0], "education");
        UserObj.getInstance().hometown = Reflect.field(details[0], "hometown_location");
        UserObj.getInstance().significant = Reflect.field(details[0], "significant_other_id");
        var _loc8_ : Int = 0;
        var _loc7_ : Dynamic = details[0];
        for (val in Reflect.fields(details[0]))
        {
            trace(Reflect.field(details[0], val), val);
        }
        name_txt.text = fname + " " + lname;
        this.friends_txt.text = "Friends (" + details[0].friend_count + ")";
        friends_txt.y = 420;
        var lc : LoaderContext = new LoaderContext(true);
        profilePic = new ImageLoader(UserObj.getInstance().picBig, {
                    container : this,
                    onComplete : picBigLoaded,
                    context : lc,
                    allowMalformedURL : true
                });
        profilePic.load();
        this.dispatchEvent(new Event(FakeFacebookPage.GOT_PROFILE_PIC));
    }
    
    private function picBigLoaded(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        profilePic.content.x = 232 - profilePic.content.width;
        profilePic.content.y = 76;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        if (ldr.scriptAccessDenied)
        {
            reloader = new Reloader(ldr, ldr.content.parent);
        }
    }
    
    private function gotPosts(response : Dynamic, fail : Dynamic) : Void
    {
        var i : Dynamic = 0;
        var friend : Dynamic = null;
        if (fail != null)
        {
            createPage();
            return;
        }
        var postArray : Array<Dynamic> = try cast(response.data, Array<Dynamic>) catch(e:Dynamic) null;
        var friendsIds : Array<Dynamic> = [];
        postArray = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        var l : Int = postArray.length;
        i = 0;
        while (i < l)
        {
            friend = Reflect.field(postArray, Std.string(i));
            if (friend.actor_id != uid && friend.actor_id != UserObj.getInstance().recipUID)
            {
                friendsIds.push(friend.actor_id);
            }
            i++;
        }
    }
    
    private function gotFeed(response : Dynamic, fail : Dynamic) : Void
    {
        var prev : Dynamic = null;
        var detailsObj : Dynamic = null;
        var i : Dynamic = 0;
        var postmc : Dynamic = null;
        var tf2 : Dynamic = null;
        var picPath : Dynamic = null;
        var lc : Dynamic = null;
        var picLoader : Dynamic = null;
        var tf : Dynamic = null;
        var ind2 : Int = 0;
        tf = null;
        ind2 = 0;
        var cTime : Dynamic = null;
        var minutes : Int = 0;
        var diff : Int = 0;
        var comments : Dynamic = null;
        var prevComment : Dynamic = null;
        var k : Int = 0;
        var comment : Dynamic = null;
        picPath = null;
        lc = null;
        picLoader = null;
        var tf3 : Dynamic = null;
        var ind : Int = 0;
        cTime = null;
        minutes = 0;
        diff = 0;
        lc = null;
        picPath = null;
        picLoader = null;
        trace("got results");
        if (fail != null)
        {
            connectAttempt = as3hx.Compat.parseInt(connectAttempt + 1);
            if (connectAttempt < 4)
            {
                createPage();
            }
            return;
        }
        as3hx.Compat.clearTimeout(pageBuildTimeout);
        var friendDetails : Array<Dynamic> = try cast(response, Array<Dynamic>) catch(e:Dynamic) null;
        if (friendDetails == null)
        {
            doneLoadingAll();
            return;
        }
        var l : Int = friendDetails.length;
        var mainLoader : LoaderMax = new LoaderMax({
            onComplete : doneLoadingAll
        });
        var friendCounter : Int = 0;
        i = 0;
        while (i < friendDetails.length)
        {
            postmc = new McFbwallpost();
            this.addChild(postmc);
            postmc.x = 263;
            if (i == 0)
            {
                postmc.y = 330;
            }
            else
            {
                postmc.y = prev.y + prev.height + 10;
            }
            prev = postmc;
            detailsObj = Reflect.field(friendDetails, Std.string(i));
            postmc.name1_txt.text = detailsObj.from.name;
            tf2 = postmc.name1_txt.getTextFormat();
            tf2.bold = true;
            postmc.name1_txt.setTextFormat(tf2);
            picPath = "https://graph.facebook.com/" + detailsObj.from.id + "/picture";
            lc = new LoaderContext(true);
            picLoader = new ImageLoader(picPath, {
                        container : postmc,
                        width : 50,
                        height : 50,
                        onComplete : doneLoading2,
                        context : lc,
                        allowMalformedURL : true
                    });
            mainLoader.append(picLoader);
            picLoader.content.x = 0;
            picLoader.content.y = 0;
            postmc.post_txt.y = 16;
            if (detailsObj.message != null)
            {
                postmc.post_txt.text = detailsObj.message;
                if (detailsObj.message_tags != null)
                {
                    tf = postmc.post_txt.getTextFormat();
                    var _loc30_ : Int = 0;
                    var _loc29_ : Dynamic = detailsObj.message_tags;
                    for (j in Reflect.fields(detailsObj.message_tags))
                    {
                        ind2 = detailsObj.message.indexOf(detailsObj.message_tags[j][0].name);
                        tf.color = 4742791;
                        postmc.post_txt.setTextFormat(tf, ind2, detailsObj.message_tags[j][0].name.length + ind2);
                    }
                }
            }
            else
            {
                if (detailsObj.story != null)
                {
                    postmc.post_txt.text = detailsObj.story;
                    tf = postmc.post_txt.getTextFormat();
                    var _loc32_ : Int = 0;
                    var _loc31_ : Dynamic = detailsObj.message_tags;
                    for (j in Reflect.fields(detailsObj.message_tags))
                    {
                        ind2 = detailsObj.message.indexOf(detailsObj.story);
                        tf.color = 4742791;
                        postmc.post_txt.setTextFormat(tf, ind2, detailsObj.story.length + ind2);
                    }
                }
            }
            postmc.post_txt.multiline = true;
            postmc.post_txt.wordWrap = true;
            postmc.post_txt.width = 481;
            postmc.post_txt.autoSize = "left";
            postmc.post_txt.height = postmc.post_txt.height + 5;
            postmc.time_txt.autoSize = "left";
            postmc.like_txt.autoSize = "left";
            cTime = DateUtil.parseW3CDTF(detailsObj.created_time);
            minutes = Math.floor((Date.now().getTime() - cTime.getTime()) / 1000 / 60);
            diff = Math.floor(minutes / 60);
            if (diff < 1)
            {
                if (minutes == 1)
                {
                    postmc.time_txt.text = Std.string(minutes) + " minute ago";
                }
                else
                {
                    postmc.time_txt.text = Std.string(minutes) + " minutes ago";
                }
            }
            else
            {
                if (diff == 1)
                {
                    postmc.time_txt.text = Std.string(diff) + " hour ago";
                }
                else
                {
                    postmc.time_txt.text = Std.string(diff) + " hours ago";
                }
            }
            postmc.time_txt.y = postmc.post_txt.y + postmc.post_txt.height;
            postmc.like_txt.y = postmc.time_txt.y;
            postmc.mc_peopleicon.y = postmc.like_txt.y;
            postmc.mc_peopleicon.x = postmc.time_txt.x + postmc.time_txt.width + 5;
            if (detailsObj.comments != null)
            {
                comments = detailsObj.comments.data;
                if (comments != null)
                {
                    k = 0;
                    while (k < comments.length)
                    {
                        comment = new McComment();
                        postmc.addChild(comment);
                        picPath = "https://graph.facebook.com/" + Reflect.field(comments, Std.string(k)).from.id + "/picture";
                        lc = new LoaderContext(true);
                        picLoader = new ImageLoader(picPath, {
                                    container : comment,
                                    width : 32,
                                    height : 32,
                                    onComplete : doneLoading2,
                                    context : lc,
                                    allowMalformedURL : true
                                });
                        picLoader.content.x = 3;
                        picLoader.content.y = 3;
                        mainLoader.append(picLoader);
                        comment.name1_txt.text = Reflect.field(comments, Std.string(k)).from.name + " " + Reflect.field(comments, Std.string(k)).message;
                        comment.name1_txt.autoSize = "left";
                        tf3 = comment.name1_txt.getTextFormat();
                        tf3.size = 11;
                        tf3.bold = true;
                        tf3.color = 4742791;
                        ind = Std.string(postmc.time_txt.text).indexOf(Reflect.field(comments, Std.string(k)).from.name);
                        comment.name1_txt.setTextFormat(tf3, 0, ind);
                        tf3.color = 0;
                        tf3.bold = false;
                        comment.name1_txt.setTextFormat(tf3, ind + Reflect.field(comments, Std.string(k)).from.name.length + 1, comment.name1_txt.length - 1);
                        comment.x = 60;
                        if (k == 0)
                        {
                            comment.y = postmc.time_txt.y + postmc.time_txt.height + 3;
                        }
                        else
                        {
                            comment.y = prevComment.y + prevComment.height;
                        }
                        comment.time_txt.autoSize = "left";
                        cTime = DateUtil.parseW3CDTF(Reflect.field(comments, Std.string(k)).created_time);
                        minutes = Math.floor((Date.now().getTime() - cTime.getTime()) / 1000 / 60);
                        diff = Math.floor(minutes / 60);
                        if (diff < 1)
                        {
                            if (minutes == 1)
                            {
                                comment.time_txt.text = Std.string(minutes) + " minute ago";
                            }
                            else
                            {
                                comment.time_txt.text = Std.string(minutes) + " minutes ago";
                            }
                        }
                        else
                        {
                            if (diff == 1)
                            {
                                comment.time_txt.text = Std.string(diff) + " hour ago";
                            }
                            else
                            {
                                comment.time_txt.text = Std.string(diff) + " hours ago";
                            }
                        }
                        comment.time_txt.text = comment.time_txt.text + "·";
                        comment.time_txt.autoSize = "left";
                        comment.like_txt.autoSize = "left";
                        comment.time_txt.y = comment.name1_txt.y + comment.name1_txt.height - 4;
                        comment.like_txt.y = comment.time_txt.y;
                        comment.like_txt.x = comment.time_txt.x + comment.time_txt.width + 5;
                        comment.mc_peopleicon.x = comment.like_txt.x + comment.like_txt.width + 5;
                        comment.mc_peopleicon.y = comment.like_txt.y;
                        prevComment = comment;
                        if (k < comments.length - 1)
                        {
                            comment.mc_commentbottom.visible = false;
                            comment.mc_commentbottom.y = comment.name1_txt.y;
                            comment.mc_commentbk.height = comment.name1_txt.height + 27;
                        }
                        else
                        {
                            comment.mc_commentbottom.y = comment.name1_txt.y + comment.name1_txt.height + 14;
                            comment.mc_commentbk.height = comment.mc_commentbottom.y + comment.name1_txt.height + 10;
                        }
                        k++;
                    }
                }
                if (comments != null)
                {
                    postmc.mc_line.y = comment.y + comment.height + 3;
                }
                else
                {
                    postmc.mc_line.y = postmc.time_txt.y + postmc.time_txt.height + 3;
                }
            }
            postmc.mc_line.alpha = 0.5;
            if (postmc.y > 1200)
            {
                break;
            }
            i++;
        }
        this.name_txt.text = UserObj.getInstance().senderFName + " " + UserObj.getInstance().senderLName;
        this.txt_topname.text = this.name_txt.text;
        txt_topname.autoSize = "right";
        txt_topname.y = txt_topname.y - 2;
        lc = new LoaderContext(true);
        picPath = "https://graph.facebook.com/" + UserObj.getInstance().userID + "/picture";
        picLoader = new ImageLoader(picPath, {
                    container : this,
                    width : 32,
                    height : 32,
                    onComplete : doneLoading2,
                    context : lc,
                    allowMalformedURL : true
                });
        mainLoader.append(picLoader);
        picLoader.content.x = txt_topname.x - 32 - 5;
        picLoader.content.y = txt_topname.y - 5;
        var uo : UserObj = UserObj.getInstance();
        var output : String = (uo.work != null) ? uo.work.position + " at " + uo.work.employer + " - " : "";
        output = output + ((uo.education != null) ? "Studies at " + uo.education.school + " - " : "");
        output = output + ((uo.location != null) ? "Lives in " + uo.location.city + ", " + uo.location.state + " - " : "");
        output = output + ((uo.birthday != null) ? "Born on " + uo.birthday + " - " : "");
        output = output + ((uo.hometown != null) ? "From " + uo.hometown.city + ", " + uo.hometown.state + " - " : "");
        this.info_txt.text = output.substring(0, output.length - 3);
        this.dispatchEvent(new Event(UPDATE_LOADER));
        mainLoader.load();
    }
    
    private function doneLoadingAll(e : LoaderEvent = null) : Void
    {
        fbImg = new BitmapData(this.width, this.height, false, 16777215);
        TweenMax.to(this, 0.1, {
                    blurFilter : {
                        blurX : 1.2,
                        blurY : 1.2,
                        quality : 3
                    }
                });
        TweenMax.to(this, 0, {
                    colorMatrixFilter : {
                        amount : 1,
                        saturation : 0.7
                    }
                });
        as3hx.Compat.setTimeout(finishDraw, 2000);
    }
    
    private function finishDraw() : Void
    {
        fbImg.draw(this);
        this.cacheAsBitmap = true;
        UserObj.getInstance().userFBPage = fbImg;
        createZoom1();
        this.dispatchEvent(new Event("donecreating"));
    }
    
    private function createZoom1() : Void
    {
        var myRect : Rectangle = new Rectangle(8, 301, 735, 800);
        zoom1BD = new BitmapData(myRect.width, myRect.height);
        zoom1BD.copyPixels(fbImg, myRect, new Point(0, 0));
        zoom1BM = new Bitmap(zoom1BD);
        zoom1BM.blendMode = "multiply";
        zoom1BM.alpha = 0.8;
    }
    
    public function animation1() : Void
    {
        var tl : TimelineLite = new TimelineLite();
        tl.append(TweenMax.to(this, 1.5, {
                            y : "-400",
                            ease : Quad.easeInOut
                        }), 1);
        tl.append(TweenMax.to(this, 1.2, {
                            y : "-300",
                            ease : Quad.easeInOut
                        }));
        tl.append(TweenMax.to(this, 1.5, {
                            y : "-100",
                            ease : Quad.easeInOut
                        }), 0.3);
    }
    
    public function animation2() : Void
    {
    }
    
    public function animation3() : Void
    {
        var i : Int = 0;
        var photo : Dynamic = null;
        var whitebk : Sprite = new Sprite();
        this.addChild(whitebk);
        whitebk.graphics.beginFill(16777215, 0.3);
        whitebk.graphics.drawRect(0, 0, this.width, this.height);
        whitebk.graphics.endFill();
        albumbk = new McAlbumview();
        this.addChild(albumbk);
        albumbk.x = (1280 - albumbk.width) / 2;
        albumbk.y = 20;
        this.setChildIndex(photoHolder, this.numChildren - 1);
        photoHolder.visible = true;
        this.y = 10;
        i = 0;
        while (i < photoHolder.numChildren - 2)
        {
            photo = cast((photoHolder.getChildAt(i)), AlbumPhoto);
            TweenMax.to(photo, 0, {
                        autoAlpha : 1,
                        delay : i * 1.5,
                        onStart : updatePhotoSize,
                        onStartParams : [photo]
                    });
            TweenMax.to(photo, 0, {
                        autoAlpha : 0,
                        delay : (i + 1) * 1.5,
                        overwrite : false
                    });
            i++;
        }
    }
    
    public function animation4() : Void
    {
        this.setChildIndex(photoHolder, this.numChildren - 1);
        photoHolder.visible = true;
        this.y = 10;
        var photo : AlbumPhoto = cast((photoHolder.getChildAt(photoHolder.numChildren - 2)), AlbumPhoto);
        TweenMax.to(photo, 0, {
                    autoAlpha : 1,
                    delay : 0,
                    onStart : updatePhotoSize,
                    onStartParams : [photo]
                });
        TweenMax.to(photo, 0, {
                    autoAlpha : 0,
                    delay : 4,
                    overwrite : false
                });
    }
    
    public function animationend() : Void
    {
        trace("UserObj.getInstance().significant=" + UserObj.getInstance().significant);
        var photo : AlbumPhoto = cast((photoHolder.getChildAt(photoHolder.numChildren - 1)), AlbumPhoto);
        photo.visible = true;
        updatePhotoSize(photo);
    }
    
    private function updatePhotoSize(myPhoto : AlbumPhoto) : Void
    {
        albumbk.mc_photobk.width = myPhoto.width + 30;
        albumbk.mc_photobk.height = myPhoto.height + 30;
        myPhoto.imgHolder.x = (albumbk.mc_photobk.width - myPhoto.imgHolder.width) / 2;
        myPhoto.x = albumbk.x + albumbk.mc_photobk.x + 10;
        myPhoto.y = 30;
        myPhoto.updateBtns();
    }
    
    private function updateSigSize() : Void
    {
        sigHolder.x = (this.width - sigHolder.width) / 2;
        sigHolder.y = 70;
    }
    
    public function animationmap() : Void
    {
    }
    
    private function doneUploading(e : Event) : Void
    {
        this.dispatchEvent(new Event("doneuploading"));
    }
    
    private function ioError(e : IOErrorEvent) : Void
    {
        trace("error = " + e.text);
    }
    
    private function error(e : IOErrorEvent) : Void
    {
        trace("error=" + e.text);
    }
}

