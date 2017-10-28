package com.thinknickel.thecollector;

import assets.McOutro;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;

class OutroMC extends Sprite
{
    
    
    private var outro : McOutro;
    
    private var whitebk : Sprite;
    
    public function new()
    {
        super();
        TweenMax.from(this, 1, {
                    autoAlpha : 0
                });
        outro = new McOutro();
        this.addChild(outro);
        outro.mc_outrobk.alpha = 0;
        outro.mc_endlolly.alpha = 0;
        outro.mc_endtext.alpha = 0;
        this.addEventListener("addedToStage", added);
        whitebk = new Sprite();
        whitebk.graphics.beginFill(1048576, 1);
        whitebk.graphics.drawRect(0, 0, 100, 100);
        whitebk.graphics.endFill();
        this.addChildAt(whitebk, 0);
        outro.mc_endtext.txt_next.text = UserObj.getInstance().pickedFriend.toUpperCase() + " IS NEXT";
        outro.mc_endtext.mc_fbshare.addEventListener("click", showShare);
        outro.mc_endtext.mc_fbshare.addEventListener("rollOver", fbshareOver);
        outro.mc_endtext.mc_fbshare.addEventListener("rollOut", fbshareOut);
        outro.mc_endtext.mc_fbshare.buttonMode = true;
        outro.mc_endtext.mc_fbshare.alpha = 0.6;
    }
    
    private function fbshareOver(event : MouseEvent) : Void
    {
        TweenMax.to(outro.mc_endtext.mc_fbshare, 0.3, {
                    alpha : 1
                });
    }
    
    private function fbshareOut(event : MouseEvent) : Void
    {
        TweenMax.to(outro.mc_endtext.mc_fbshare, 0.3, {
                    alpha : 0.6
                });
    }
    
    private function noClicked(e : Event) : Void
    {
    }
    
    public function showLolly() : Void
    {
        var prefix : String = Main.getInstance().assetPath;
        var path : String = "loop3.mp3";
        var sound : MP3Loader = new MP3Loader(prefix + path, {
            name : "audio",
            autoPlay : true,
            repeat : -1,
            estimatedBytes : 504000,
            volume : 1
        });
        sound.load();
        outro.mc_endlolly.mc_endname.txt_name.text = UserObj.getInstance().senderFName.toUpperCase();
        TweenMax.to(outro.mc_endlolly, 1, {
                    autoAlpha : 1,
                    ease : Linear.easeNone,
                    delay : 1
                });
        TweenMax.to(outro.mc_outrobk, 1, {
                    autoAlpha : 1,
                    delay : 1,
                    ease : Linear.easeNone
                });
        TweenMax.to(outro.mc_endtext, 1.8, {
                    autoAlpha : 1,
                    delay : 1,
                    ease : Linear.easeNone
                });
        TweenMax.delayedCall(2, showLike);
    }
    
    private function showLike() : Void
    {
        ExternalInterface.call("showLike");
    }
    
    private function reset() : Void
    {
        Main.getInstance().restart();
    }
    
    private function added(e : Event) : Void
    {
        stage.addEventListener("resize", resized);
        resized(null);
    }
    
    private function resized(event : Event) : Void
    {
        outro.x = (stage.stageWidth - outro.width) / 2;
        outro.y = (stage.stageHeight - outro.height) / 2 - 100;
        whitebk.width = stage.stageWidth;
        whitebk.height = stage.stageHeight;
    }
    
    private function showShare(e : Event) : Void
    {
        ExternalInterface.call("postToFacebook");
    }
    
    private function showShare2(e : Event) : Void
    {
        TweenMax.to(outro.mc_endtext.mc_fbshare, 0.3, {
                    autoAlpha : 0
                });
        TweenMax.to(outro.mc_endtext.txt_next, 0.3, {
                    autoAlpha : 0
                });
    }
}

