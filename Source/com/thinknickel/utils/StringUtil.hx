package com.thinknickel.utils;

import flash.globalization.DateTimeFormatter;

class StringUtil
{
    public function new()
    {
        super();
    }
    
    public static function replaceSpace(myString : String) : String
    {
        var reg : as3hx.Compat.Regex = new as3hx.Compat.Regex('\\s+', "g");
        var newStr : String = reg.replace(myString, "_");
        return newStr;
    }
    
    public static function formatNumber(num : Float) : String
    {
        var s : String = Std.string(num).replace(new as3hx.Compat.Regex('\\d{1,3}(?=(\\d{3})+(?!\\d))', "g"), "$&,");
        return s;
    }
    
    public static function formatDate(myDate : String) : String
    {
        var storedDate : Array<Dynamic> = myDate.split("-");
        var dString : String = storedDate[1] + "/" + storedDate[2].split(" ")[0] + "/" + storedDate[0];
        var d : Date = new Date(dString);
        var dtf : DateTimeFormatter = new DateTimeFormatter("en-US", "long", "none");
        dtf.setDateTimePattern("MMM d,YYYY");
        return dtf.format(d);
    }
}

