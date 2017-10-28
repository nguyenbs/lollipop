package com.thinknickel.utils;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;

class Reloader extends Sprite
{
    
    
    private var myLoader : ImageLoader;
    
    private var holder : Sprite;
    
    public function new(myLoader : ImageLoader, holder : Sprite)
    {
        var raw : Dynamic = null;
        var li : Dynamic = null;
        var ba : Dynamic = null;
        var reloader : Dynamic = null;
        super();
        this.myLoader = myLoader;
        this.holder = holder;
        if (myLoader.scriptAccessDenied)
        {
            raw = myLoader.rawContent;
            li = raw.contentLoaderInfo;
            ba = li.bytes;
            reloader = new Loader();
            reloader.contentLoaderInfo.addEventListener("ioError", error);
            reloader.contentLoaderInfo.addEventListener("complete", reloaderComplete);
            reloader.loadBytes(ba);
        }
    }
    
    private function reloaderComplete(evt : Event) : Void
    {
        var imageInfo : LoaderInfo = cast((evt.target), LoaderInfo);
        var bmd : BitmapData = new BitmapData(imageInfo.width, imageInfo.height);
        bmd.draw(imageInfo.loader);
        var resultBitmap : Bitmap = new Bitmap(bmd, "auto", true);
        resultBitmap.width = myLoader.content.width;
        resultBitmap.height = myLoader.content.height;
        resultBitmap.x = myLoader.content.x;
        resultBitmap.y = myLoader.content.y;
        holder.removeChild(myLoader.content);
        holder.addChild(resultBitmap);
        this.dispatchEvent(new Event("donereload"));
    }
    
    private function error(e : IOErrorEvent) : Void
    {
        trace("error=" + e.text);
    }
}

