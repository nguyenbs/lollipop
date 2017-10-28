package com.thinknickel.utils;

import assets.McArrow;
//import com.greensock.TweenMax;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;

class MouseCapture extends Sprite
{
    
    
    private var keyCoords : Array<Dynamic>;
    
    private var capturing : Bool = false;
    
    private var debugMode : Bool = false;
    
    private var mouseCoords : Array<Dynamic>;
    
    private var currFrame : Int;
    
    private var cursor : McArrow;
    
    public function new()
    {
        keyCoords = [];
        super();
        this.addEventListener("addedToStage", added);
        cursor = new McArrow();
        this.addChild(cursor);
        this.visible = false;
        TweenMax.to(cursor, 0.1, {
                    blurFilter : {
                        blurX : 1.1,
                        blurY : 1.1,
                        quality : 3
                    }
                });
    }
    
    private function added(e : Event) : Void
    {
        if (debugMode)
        {
            stage.addEventListener("keyDown", keyDown);
        }
    }
    
    private function keyDown(e : KeyboardEvent) : Void
    {
        var myKey : Int = e.keyCode;
        if (capturing)
        {
            trace(Std.string(keyCoords));
            trace("---------");
            stage.removeEventListener("enterFrame", enterFrame);
        }
        else
        {
            if (myKey == 32)
            {
                trace("--capturing-------");
                keyCoords = [];
                stage.addEventListener("enterFrame", enterFrame);
            }
        }
        capturing = !capturing;
    }
    
    public function startTracking(coords : String) : Void
    {
        this.visible = true;
        mouseCoords = coords.split(",");
        currFrame = 0;
        stage.addEventListener("enterFrame", tracking);
    }
    
    private function tracking(event : Event) : Void
    {
        currFrame = as3hx.Compat.parseInt(currFrame + 2);
        if (currFrame >= mouseCoords.length - 1)
        {
            stage.removeEventListener("enterFrame", tracking);
            this.visible = false;
        }
        else
        {
            cursor.x = mouseCoords[currFrame];
            cursor.y = mouseCoords[currFrame + 1];
        }
    }
    
    private function enterFrame(e : Event) : Void
    {
        keyCoords.push(this.mouseX);
        keyCoords.push(this.mouseY);
    }
}

