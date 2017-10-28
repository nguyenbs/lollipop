package com.thinknickel.thecollector.fakepage;

import assets.McHalftone;
import com.thinknickel.thecollector.UserObj;
import com.thinknickel.utils.Reloader;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.system.LoaderContext;

class CarPhotoMC extends Sprite
{
    
    
    private var profilePic : ImageLoader;
    
    public var bd : BitmapData;
    
    private var overlay : McHalftone;
    
    public function new()
    {
        super();
        var lc : LoaderContext = new LoaderContext(true);
        profilePic = new ImageLoader(UserObj.getInstance().picBig, {
                    width : 85,
                    height : 133,
                    scaleMode : "proportionalOutside",
                    crop : true,
                    container : this,
                    onComplete : picBigLoaded,
                    context : lc,
                    allowMalformedURL : true
                });
        profilePic.load();
        profilePic.content.alpha = 0.55;
        overlay = new McHalftone();
        this.addChild(overlay);
        overlay.alpha = 0.2;
        overlay.blendMode = "screen";
        overlay.width = 85;
        overlay.height = 133;
        TweenMax.to(overlay, 0, {
                    blurFilter : {
                        blurX : 1.2,
                        blurY : 1.2
                    }
                });
    }
    
    private function picBigLoaded(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        TweenMax.to(profilePic.content, 0, {
                    blurFilter : {
                        blurX : 1.1,
                        blurY : 1.1
                    }
                });
        profilePic.content.x = 0;
        profilePic.content.y = 0;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        trace("car pic=" + ldr.scriptAccessDenied);
        if (ldr.scriptAccessDenied)
        {
            reloader = new Reloader(ldr, ldr.content.parent);
            reloader.addEventListener("donereload", finishDraw);
        }
        else
        {
            as3hx.Compat.setTimeout(finishDraw, 2000);
        }
    }
    
    private function finishDraw(e : Event = null) : Void
    {
        TweenMax.to(this, 0, {
                    colorMatrixFilter : {
                        amount : 1,
                        saturation : 0.9
                    }
                });
        bd = new BitmapData(this.width, this.height, true, 16711680);
        bd.draw(this);
    }
}

