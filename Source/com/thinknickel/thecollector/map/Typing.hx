package com.thinknickel.thecollector.map;

import assets.McCursor;
import com.greensock.TweenMax;
import flash.display.MovieClip;
import flash.text.TextField;

class Typing extends MovieClip
{
    
    
    private var linesArray : Array<Dynamic>;
    
    private var currLine : Int = 0;
    
    private var myText : TextField;
    
    private var lastText : TextField;
    
    private var typeInterval : Float;
    
    private var currChar : Int = 0;
    
    private var currString : String;
    
    private var myCursor : McCursor;
    
    private var loopCount : Int = 0;
    
    public function new(tf : TextField, myLine : String)
    {
        linesArray = [];
        myCursor = new McCursor();
        super();
        myText = tf;
        this.x = tf.x;
        this.y = tf.y;
        this.addChild(myCursor);
        linesArray.push(myLine);
        myCursor.x = 0;
        myCursor.y = 0;
        doNextLine();
    }
    
    private function doNextLine() : Void
    {
        currString = linesArray[currLine];
        currLine = as3hx.Compat.parseInt(currLine + 1);
        myCursor.x = myText.x;
        myCursor.y = myText.y;
        TweenMax.to(myCursor, 0, {
                    alpha : 1
                });
        currChar = 0;
        drawNextChar();
        lastText = myText;
    }
    
    private function drawNextChar() : Void
    {
        var interval : Int = 0;
        if (Math.random() > 0.1)
        {
            interval = as3hx.Compat.parseInt(Math.random() * 25 + 10);
        }
        else
        {
            interval = as3hx.Compat.parseInt(Math.random() * 100 + 50);
        }
        var myChar : String = currString.charAt(currChar);
        if (currString.charAt(currChar) == " ")
        {
            interval = as3hx.Compat.parseInt(interval + 30);
        }
        myText.appendText(myChar);
        currChar = as3hx.Compat.parseInt(currChar + 1);
        myCursor.x = myText.x + myText.width;
        if (currChar < currString.length)
        {
            as3hx.Compat.setTimeout(drawNextChar, interval);
        }
    }
    
    private function backup() : Void
    {
        myText.text = myText.text.substr(0, myText.length - 1);
        currChar = as3hx.Compat.parseInt(currChar - 1);
        myCursor.x = myText.x + myText.width;
        var interval : Int = as3hx.Compat.parseInt(Math.random() * 100 + 50);
        if (currChar == 33)
        {
            interval = 300;
            as3hx.Compat.setTimeout(drawNextChar, interval);
        }
        else
        {
            as3hx.Compat.setTimeout(backup, interval);
            currString = "";
        }
    }
    
    private function moveCursor() : Void
    {
        myCursor.x = 0;
    }
}

