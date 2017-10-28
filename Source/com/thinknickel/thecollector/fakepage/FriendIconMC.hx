package com.thinknickel.thecollector.fakepage;

import assets.McFriendicon;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.ImageLoader;
import com.thinknickel.utils.Reloader;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

class FriendIconMC extends McFriendicon
{
    
    
    private var profilePic : ImageLoader;
    
    public function new(uid : String, myName : String)
    {
        super();
        var myPath : String = "https://graph.facebook.com/" + uid + "/picture";
        var lc : LoaderContext = new LoaderContext(true);
        profilePic = new ImageLoader(myPath, {
                    width : 55,
                    height : 55,
                    scaleMode : "proportionalOutside",
                    crop : true,
                    container : this,
                    onComplete : picBigLoaded,
                    context : lc,
                    allowMalformedURL : true
                });
        profilePic.load();
        friends_txt.multiline = true;
        friends_txt.wordWrap = true;
        friends_txt.width = 125;
        friends_txt.autoSize = "left";
        this.friends_txt.text = myName;
    }
    
    private function doneLoading2(e : LoaderEvent) : Void
    {
        var raw : Dynamic = null;
        var li : Dynamic = null;
        var ba : Dynamic = null;
        var reloader : Dynamic = null;
        if (profilePic.scriptAccessDenied)
        {
            raw = this.profilePic.rawContent;
            li = raw.contentLoaderInfo;
            ba = li.bytes;
            reloader = new Loader();
            reloader.contentLoaderInfo.addEventListener("ioError", error);
            reloader.contentLoaderInfo.addEventListener("complete", reloaderComplete);
            reloader.loadBytes(ba);
        }
    }
    
    private function error(e : IOErrorEvent) : Void
    {
        trace("error=" + e.text);
    }
    
    private function reloaderComplete(evt : Event) : Void
    {
        var imageInfo : LoaderInfo = cast((evt.target), LoaderInfo);
        var bmd : BitmapData = new BitmapData(imageInfo.width, imageInfo.height);
        bmd.draw(imageInfo.loader);
        var resultBitmap : Bitmap = new Bitmap(bmd, "auto", true);
        this.removeChild(profilePic.content);
        this.addChild(resultBitmap);
    }
    
    private function picBigLoaded(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        profilePic.content.x = 0;
        profilePic.content.y = 0;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        if (ldr.scriptAccessDenied)
        {
            reloader = new Reloader(ldr, ldr.content.parent);
        }
    }
}

