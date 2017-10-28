package com.thinknickel.thecollector.fakepage;

import assets.McDropdown;

import com.thinknickel.thecollector.UserObj;
import com.thinknickel.utils.Reloader;
import flash.system.LoaderContext;

class DropDownMC extends McDropdown
{
    
    
    private var profilePic : ImageLoader;
    
    public function new()
    {
        super();
        this.name_txt.text = UserObj.getInstance().senderFName + " " + UserObj.getInstance().senderLName;
        TweenMax.to(name_txt, 0.1, {
                    blurFilter : {
                        blurX : 5.1,
                        blurY : 5.1,
                        quality : 3
                    }
                });
        var lc : LoaderContext = new LoaderContext(false);
        profilePic = new ImageLoader(UserObj.getInstance().picBig, {
                    width : 261,
                    height : 261,
                    scaleMode : "proportionalOutside",
                    crop : true,
                    container : this,
                    onComplete : picBigLoaded,
                    context : lc,
                    allowMalformedURL : true
                });
        profilePic.load();
    }
    
    private function picBigLoaded(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        profilePic.content.x = 239;
        profilePic.content.y = 381;
        this.name_txt.text = UserObj.getInstance().senderFName + " " + UserObj.getInstance().senderLName;
        TweenMax.to(name_txt, 0.1, {
                    blurFilter : {
                        blurX : 5.1,
                        blurY : 5.1,
                        quality : 3
                    }
                });
        this.cacheAsBitmap = true;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        if (ldr.scriptAccessDenied)
        {
            reloader = new Reloader(ldr, ldr.content.parent);
        }
    }
}

