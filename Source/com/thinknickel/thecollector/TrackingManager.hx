package com.thinknickel.thecollector;

import com.thinknickel.utils.StringUtil;
import flash.display.DisplayObject;
import flash.external.ExternalInterface;

class TrackingManager
{
    
    private static var _isInit : Bool = false;
    
    private static var TRACKING_IS_ON : Bool = true;
    
    
    public function new()
    {
        super();
    }
    
    public static function init(display : DisplayObject) : Void
    {
        _isInit = true;
        if (true)
        {
            trace("tracking is on");
        }
        else
        {
            trace("tracking is off");
        }
    }
    
    public static function isInit() : Bool
    {
        return _isInit;
    }
    
    public static function gaTrackPage(pageName : String) : Void
    {
        if (true)
        {
            ExternalInterface.call("_gaq.push", ["_trackPageview", StringUtil.replaceSpace(pageName)]);
        }
    }
    
    public static function gaTrackEvent(category : String, action : String, label : String = "", value : Float = Math.NaN) : Void
    {
        if (true)
        {
            ExternalInterface.call("_gaq.push", ["_trackEvent", StringUtil.replaceSpace(category), StringUtil.replaceSpace(action), StringUtil.replaceSpace(label)]);
        }
    }
    
    public static function gaTrackCustom(index : Int, name : String, value : String, opt : Int = 1) : Void
    {
        if (true)
        {
            ExternalInterface.call("_gaq.push", ["_setCustomVar", index, StringUtil.replaceSpace(name), StringUtil.replaceSpace(value), opt]);
        }
    }
    
    public static function trackCustom(mySection : String, videoName : String) : Void
    {
        if (true)
        {
            ExternalInterface.call("_gaq.push", ["_setCustomVar", 1, "Section", StringUtil.replaceSpace(mySection), 3], ["_setCustomVar", 2, "Video_Name", StringUtil.replaceSpace(videoName), 3]);
        }
    }
}

