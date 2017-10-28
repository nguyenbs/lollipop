package com.thinknickel.thecollector.fakepage;

import assets.McAlbumphoto;
import assets.McComment;
import com.adobe.utils.DateUtil;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.ImageLoader;
import com.greensock.loading.LoaderMax;
import com.thinknickel.utils.Reloader;
import flash.display.Sprite;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;

class AlbumPhoto extends McAlbumphoto
{
    
    
    public var imgHolder : Sprite;
    
    public function new(info : Dynamic)
    {
        var comments : Dynamic = null;
        var prevComment : Dynamic = null;
        var k : Int = 0;
        var comment : Dynamic = null;
        var picPath : Dynamic = null;
        var picLoader : Dynamic = null;
        var tf3 : Dynamic = null;
        var ind : Int = 0;
        super();
        var mainLoader : LoaderMax = new LoaderMax();
        imgHolder = new Sprite();
        this.addChild(imgHolder);
        this.setChildIndex(imgHolder, 0);
        var lc : LoaderContext = new LoaderContext(true);
        var ldr : ImageLoader = new ImageLoader(info.source, {
            container : imgHolder,
            onComplete : doneLoading2,
            context : lc,
            allowMalformedURL : true
        });
        mainLoader.append(ldr);
        this.name1_txt.text = info.from.name;
        name1_txt.y = info.height + 10;
        like_txt.y = name1_txt.y + name1_txt.height + 5;
        picPath = "https://graph.facebook.com/" + info.from.id + "/picture";
        picLoader = new ImageLoader(picPath, {
                    container : this,
                    width : 32,
                    height : 32,
                    onComplete : doneLoading2,
                    context : lc,
                    allowMalformedURL : true
                });
        picLoader.content.y = name1_txt.y;
        mainLoader.append(picLoader);
        this.mc_photoleftbtns.y = info.height - mc_photoleftbtns.height - 5;
        this.mc_photorightbtn.y = mc_photoleftbtns.y;
        this.mc_phototext1.y = like_txt.y;
        formatTime(this.time_txt, info.created_time);
        time_txt.y = like_txt.y;
        var commentHolder : Sprite = new Sprite();
        this.addChild(commentHolder);
        commentHolder.x = 40;
        commentHolder.y = like_txt.y + like_txt.height + 5;
        if (info.comments != null)
        {
            comments = info.comments.data;
            trace("comments.length = " + comments.length);
            k = 0;
            while (k < comments.length)
            {
                comment = new McComment();
                commentHolder.addChild(comment);
                picPath = "https://graph.facebook.com/" + Reflect.field(comments, Std.string(k)).from.id + "/picture";
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
                ind = Std.string(time_txt.text).indexOf(Reflect.field(comments, Std.string(k)).from.name);
                comment.name1_txt.setTextFormat(tf3, 0, ind);
                tf3.color = 0;
                tf3.bold = false;
                comment.name1_txt.setTextFormat(tf3, ind + Reflect.field(comments, Std.string(k)).from.name.length + 1, comment.name1_txt.length - 1);
                if (k == 0)
                {
                    comment.y = 0;
                }
                else
                {
                    comment.y = prevComment.y + prevComment.height;
                }
                formatTime(comment.time_txt, Reflect.field(comments, Std.string(k)).created_time);
                comment.time_txt.text = comment.time_txt.text + "·";
                comment.time_txt.autoSize = "left";
                comment.like_txt.autoSize = "left";
                comment.time_txt.y = comment.name1_txt.y + comment.name1_txt.height - 4;
                comment.like_txt.y = comment.time_txt.y;
                comment.like_txt.x = comment.time_txt.x + comment.time_txt.width + 5;
                comment.mc_peopleicon.x = comment.like_txt.x + comment.like_txt.width + 5;
                comment.mc_peopleicon.y = comment.like_txt.y;
                prevComment = comment;
                k++;
            }
            comment.mc_commentbottom.y = comment.name1_txt.y + comment.name1_txt.height + 14;
            comment.mc_commentbk.height = comment.mc_commentbottom.y + comment.name1_txt.height + 10;
        }
        this.visible = false;
        mainLoader.load();
    }
    
    private function formatTime(field : TextField, time : String) : Void
    {
        field.autoSize = "left";
        var cTime : Date = DateUtil.parseW3CDTF(time);
        var minutes : Int = Math.floor((Date.now().getTime() - cTime.getTime()) / 1000 / 60);
        var diff : Int = Math.floor(minutes / 60);
        var days : Int = Math.floor(diff / 24);
        if (diff < 1)
        {
            if (minutes == 1)
            {
                field.text = Std.string(minutes) + " minute ago";
            }
            else
            {
                field.text = Std.string(minutes) + " minutes ago";
            }
        }
        else
        {
            if (diff == 1)
            {
                field.text = Std.string(diff) + " hour ago";
            }
            else
            {
                if (diff < 24)
                {
                    field.text = Std.string(diff) + " hours ago";
                }
                else
                {
                    if (days == 1)
                    {
                        field.text = Std.string(days) + " day ago";
                    }
                    else
                    {
                        field.text = Std.string(days) + " days ago";
                    }
                }
            }
        }
    }
    
    private function doneLoading2(e : LoaderEvent) : Void
    {
        var reloader : Dynamic = null;
        var ldr : ImageLoader = cast((e.target), ImageLoader);
        if (ldr.scriptAccessDenied)
        {
            reloader = new Reloader(ldr, ldr.content.parent);
        }
    }
    
    public function updateBtns() : Void
    {
        this.mc_photoleftbtns.x = imgHolder.x + 15;
        this.mc_photorightbtn.x = imgHolder.x + imgHolder.width - 15 - mc_photorightbtn.width;
    }
}

