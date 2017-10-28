/**
 * VERSION: 1.937
 * DATE: 2014-06-26
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com/loadermax/
 **/
package com.fproject.media;

import Reflect;
import openfl.events.EventDispatcher;
import openfl.errors.Error;
import com.fproject.media.events.LoaderEvent;
import com.fproject.media.LoaderStatus;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.net.URLVariables;

/** Dispatched when the loader experiences an IO_ERROR while loading or auditing its size. **/
@:meta(Event(name="ioError",type="com.greensock.events.LoaderEvent"))

/**
 * Serves as the base class for all individual loaders (not LoaderMax) like <code>ImageLoader, 
 * XMLLoader, SWFLoader, MP3Loader</code>, etc. There is no reason to use this class on its own. 
 * Please see the documentation for the other classes.
 * 
 * <p><strong>Copyright 2010-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in
 * <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a>
 * or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class LoaderBase extends EventDispatcher
{
    public var paused(get, set) : Bool;

    /** Integer code indicating the loader's status; options are <code>LoaderStatus.READY,
    * LoaderStatus.LOADING, LoaderStatus.COMPLETED, LoaderStatus.PAUSED,</code> and <code>LoaderStatus.DISPOSED</code>. **/
    public var status(get, never) : Int;

    /** Bytes loaded **/
    public var bytesLoaded(get, never) : Int;

    /** Total bytes that are to be loaded by the loader. Initially, this value is set to the <code>estimatedBytes</code>
    * if one was defined in the <code>vars</code> object via the constructor, or it defaults to
    * <code>LoaderMax.defaultEstimatedBytes</code>.
    * When the loader loads enough of the content to accurately determine the bytesTotal, it will do so automatically. **/
    public var bytesTotal(get, never) : Int;

    /** A value between 0 and 1 indicating the overall progress of the loader.
    * When nothing has loaded, it will be 0; when it is halfway loaded,
    * <code>progress</code> will be 0.5, and when it is fully loaded it will be 1. **/
    public var progress(get, never) : Float;


    /**
     * The content that was loaded by the loader which varies by the type of loader:
     * <ul>
     * 		<li><strong> ImageLoader </strong> - A <code>com.greensock.loading.display.ContentDisplay</code>
     * 		(a Sprite) which contains the ImageLoader's <code>rawContent</code> (a <code>flash.display.Bitmap</code>
     * 		unless script access was denied in which case <code>rawContent</code> will be a <code>flash.display.Loader</code>
     * 		to avoid security errors). For Flex users, you can set <code>LoaderMax.defaultContentDisplay</code> to
     * 		<code>FlexContentDisplay</code> in which case ImageLoaders, SWFLoaders, and VideoLoaders will return a
     * 		<code>com.greensock.loading.display.FlexContentDisplay</code> instance instead.</li>
     * 		<li><strong> SWFLoader </strong> - A <code>com.greensock.loading.display.ContentDisplay</code>
     * 		(a Sprite) which contains the SWFLoader's <code>rawContent</code> (the swf's <code>root</code>
     * 		DisplayObject unless script access was denied in which case <code>rawContent</code> will be a
     * 		<code>flash.display.Loader</code> to avoid security errors). For Flex users, you can set
     * 		<code>LoaderMax.defaultContentDisplay</code> to <code>FlexContentDisplay</code> in which case
     * 		ImageLoaders, SWFLoaders, and VideoLoaders will return a <code>com.greensock.loading.display.FlexContentDisplay</code> instance instead.</li>
     * 		<li><strong> VideoLoader </strong> - A <code>com.greensock.loading.display.ContentDisplay</code>
     * 		(a Sprite) which contains the VideoLoader's <code>rawContent</code>
     * 		(a Video object to which the NetStream was attached).
     * 		For Flex users, you can set <code>LoaderMax.defaultContentDisplay</code> to
     * 		<code>FlexContentDisplay</code> in which case ImageLoaders, SWFLoaders, and
     * 		VideoLoaders will return a <code>com.greensock.loading.display.FlexContentDisplay</code> instance instead.</li>
     * 		<li><strong> XMLLoader </strong> - XML</li>
     * 		<li><strong> DataLoader </strong>
     * 			<ul>
     * 				<li><code>String</code> if the DataLoader's <code>format</code> vars property is <code>"text"</code> (the default).</li>
     * 				<li><code>flash.utils.ByteArray</code> if the DataLoader's <code>format</code> vars property is <code>"binary"</code>.</li>
     * 				<li><code>flash.net.URLVariables</code> if the DataLoader's <code>format</code> vars property is <code>"variables"</code>.</li>
     * 			</ul></li>
     * 		<li><strong> CSSLoader </strong> - <code>flash.text.StyleSheet</code></li>
     * 		<li><strong> MP3Loader </strong> - <code>flash.media.Sound</code></li>
     * 		<li><strong> LoaderMax </strong> - an array containing the content objects from each of its child loaders.</li>
     * </ul>
     **/
    public var content(get, never) : Dynamic;

    /**
     * Indicates whether or not the loader's <code>bytesTotal</code> value has been set by any of the following:
     * <ul>
     * 		<li>Defining an <code>estimatedBytes</code> in the <code>vars</code> object passed to the constructor</li>
     * 		<li>Calling <code>auditSize()</code> and getting a response (an error is also considered a response)</li>
     * 		<li>When a LoaderMax instance begins loading, it will automatically force a call to <code>auditSize()</code>
     * 		for any of its children that don't have an <code>estimatedBytes</code> defined.
     * 		You can disable this behavior by passing <code>auditSize:false</code> through the constructor's <code>vars</code> object.</li>
     * </ul>
     **/
    public var auditedSize(get, never) : Bool;

    /**
     * The number of seconds that elapsed between when the loader began and when it either completed, failed,
     * or was canceled. You may check a loader's <code>loadTime</code> anytime, not just after it completes. For
     * example, you could access this value in an onProgress handler and you'd see it steadily increase as the loader
     * loads and then when it completes, <code>loadTime</code> will stop increasing. LoaderMax instances ignore
     * any pauses when calculating this value, so if a LoaderMax begins loading and after 1 second it gets paused,
     * and then 10 seconds later it resumes and takes an additional 14 seconds to complete, its <code>loadTime</code>
     * would be 15, <strong>not</strong> 25.
     **/
    public var loadTime(get, never) : Float;

    public var url(get, set) : String;
    public var request(get, never) : URLRequest;
    public var httpStatus(get, never) : Int;
    public var scriptAccessDenied(get, never) : Bool;

    /**
    * @private used to store timing information.
    * When the loader begins loading, the startTime is stored here.
    * When it completes or fails, it is set to the total elapsed time between when it started and ended.
    * We reuse this variable like this in order to minimize size. **/
    private var _time : Int = 0;

    /** @private **/
    private static var _cacheID : Float = Date.now().getTime();
    /** @private **/
    private static var _underlineExp : as3hx.Compat.Regex = new as3hx.Compat.Regex('%5f', "gi");

    /** @private **/
    private static var _isLocal : Bool;

    /** @private **/
    private var _cacheIsDirty : Bool;

    /** @private **/
    private var _scriptAccessDenied : Bool;
    /** @private used in auditSize() just to preload enough of the file to determine bytesTotal. **/
    private var _auditStream : URLStream;
    /** @private For certain types of loaders like SWFLoader and XMLLoader where there may be nested loaders found, it's better to prioritize the estimatedBytes if one is defined. Otherwise, the file size will be used which may be MUCH smaller than all the assets inside of it (like an XML file with a bunch of VideoLoaders).**/
    private var _preferEstimatedBytesInAudit : Bool;

    /** @private used to prevent problems that could occur if an audit is in process and load() is called on a bad URL - the audit could fail first and swap the URL and then when the real load fails just after that, we couldn't just do if (url != this.vars.alternateURL) because the audit would have already changed it.  **/
    private var _skipAlternateURL : Bool;

    /** @private **/
    private var _prePauseStatus : Int = 0;

    /** @private **/
    private var _cachedBytesLoaded : Int = 0;

    /** @private **/
    private var _cachedBytesTotal : Int = 0;

    /** @private **/
    private var _dispatchProgress : Bool;

    /** @private **/
    private static var _listenerTypes = {
        onOpen : "open",
        onInit : "init",
        onComplete : "complete",
        onProgress : "progress",
        onCancel : "cancel",
        onFail : "fail",
        onError : "error",
        onSecurityError : "securityError",
        onHTTPStatus : "httpStatus",
        onHTTPResponseStatus : "httpResponseStatus",
        onIOError : "ioError",
        onScriptAccessDenied : "scriptAccessDenied",
        onChildOpen : "childOpen",
        onChildCancel : "childCancel",
        onChildComplete : "childComplete",
        onChildProgress : "childProgress",
        onChildFail : "childFail",
        onRawLoad : "rawLoad",
        onUncaughtError : "uncaughtError"
    };
    /**
		 * Constructor
		 * 
		 * @param urlOrRequest The url (<code>String</code>) or <code>URLRequest</code> from which the loader should get its content
		 * @param vars An object containing optional parameters like <code>estimatedBytes, name, autoDispose, onComplete, onProgress, onError</code>, etc. For example, <code>{estimatedBytes:2400, name:"myImage1", onComplete:completeHandler}</code>.
		 */
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(vars);
        request = ((Std.is(urlOrRequest, URLRequest))) ? try cast(urlOrRequest, URLRequest) catch(e:Dynamic) null : new URLRequest(urlOrRequest);
        url = request.url;
        _setRequestURL(request, url);
    }
    
    /** @private **/
    private function _prepRequest() : Void
    {
        _scriptAccessDenied = false;
        httpStatus = 0;
        _closeStream();
        if (this.vars.noCache && (!_isLocal || url.substr(0, 4) == "http"))
        {
            _setRequestURL(request, url, "gsCacheBusterID=" + (_cacheID++));
        }
    }
    
    /** @private Flash doesn't properly apply extra GET url parameters when the URL contains them already (like "http://www.greensock.com?id=2") - it ends up missing an "&" delimiter so this method splits any that exist out into a URLVariables object and optionally adds extra parameters like gsCacheBusterID, etc. **/
    private function _setRequestURL(request : URLRequest, url : String, extraParams : String = "") : Void
    {
        var a : Array<Dynamic> = ((this.vars.allowMalformedURL)) ? [url] : url.split("?");
        
        //in order to avoid a VERY strange bug in certain versions of the Flash Player (like 10.0.12.36), we must loop through each character and rebuild a separate String variable instead of just using a[0], otherwise the "?" delimiter will be omitted when GET parameters are appended to the URL by Flash! Performing any String manipulations on the url will cause the issue as long as there is a "?" in the url. Like url.split("?") or url.substr(0, url.indexOf("?"), etc. Absolutely baffling. Definitely a bug in the Player - it was fixed in 10.1.
        var s : String = a[0];
        var parsedURL : String = "";
        for (i in 0...s.length)
        {
            parsedURL += s.charAt(i);
        }
        
        request.url = parsedURL;
        if (a.length >= 2)
        {
            (extraParams != null += (extraParams == "")) ? a[1] : "&" + a[1];
        }
        if (extraParams != "")
        {
            var data : URLVariables = new URLVariables((((Std.is(request.data, URLVariables))) ? Std.string(request.data) : null));
            a = extraParams.split("&");
            var i = a.length;
            var pair : Array<Dynamic>;
            while (--i > -1)
            {
                pair = a[i].split("=");
                data[pair.shift()] = pair.join("=");
            }
            request.data = Std.string(data).replace(_underlineExp, "_");
        }
        if (_isLocal && this.vars.allowMalformedURL != true && request.data != null && request.url.substr(0, 4) != "http")
        {
            request.method = "POST";
        }
    }
    
    /** @private scrubLevel: 0 = cancel, 1 = unload, 2 = dispose, 3 = flush **/
    private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        _closeStream();
        content = null;
        var isLoading : Bool = cast(status == LoaderStatus.LOADING, Bool);
        if (status == LoaderStatus.PAUSED && newStatus != LoaderStatus.PAUSED && newStatus != LoaderStatus.FAILED)
        {
            _prePauseStatus = newStatus;
        }
        else
        {
            if (status != LoaderStatus.DISPOSED)
            {
                status = newStatus;
            }
        }
        if (isLoading)
        {
            _time = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - _time);
        }
        _cachedBytesLoaded = 0;
        if (status < LoaderStatus.FAILED)
        {
            /*if (Std.is(this, LoaderMax))
            {
                _calculateProgress();
            }*/
            if (_dispatchProgress && !suppressEvents)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
            }
        }
        if (!suppressEvents)
        {
            if (isLoading)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
            }
            if (scrubLevel != 2)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.UNLOAD, this));
            }
        }
        if (newStatus == LoaderStatus.DISPOSED)
        {
            if (!suppressEvents)
            {
                dispatchEvent(new Event("dispose"));
            }
            for (p in Reflect.fields(_listenerTypes))
            {
                if (Lambda.has(this.vars, p) && Reflect.isFunction(this.vars[p]))
                {
                    this.removeEventListener(Reflect.field(_listenerTypes, p), this.vars[p]);
                }
            }
        }
    }
    
    /** @inheritDoc **/
    public function auditSize() : Void
    {
        if (_auditStream == null)
        {
            _auditStream = new URLStream();
            _auditStream.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener("ioError", _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener("securityError", _auditStreamHandler, false, 0, true);
            var request : URLRequest = new URLRequest();
            request.data = request.data;
            request.method = request.method;
            _setRequestURL(request, url, ((!_isLocal || url.substr(0, 4) == "http")) ? "gsCacheBusterID=" + (_cacheID++) + "&purpose=audit" : "");
            _auditStream.load(request);
        }
    }
    
    /** @private **/
    private function _closeStream() : Void
    {
        if (_auditStream != null)
        {
            _auditStream.removeEventListener(ProgressEvent.PROGRESS, _auditStreamHandler);
            _auditStream.removeEventListener(Event.COMPLETE, _auditStreamHandler);
            _auditStream.removeEventListener("ioError", _auditStreamHandler);
            _auditStream.removeEventListener("securityError", _auditStreamHandler);
            try
            {
                _auditStream.close();
            }
            catch (error : Error)
            {
            }
            _auditStream = null;
        }
    }
    
    //---- EVENT HANDLERS ------------------------------------------------------------------------------------
    
    /** @private **/
    private function _auditStreamHandler(event : Event) : Void
    {
        if (Std.is(event, ProgressEvent))
        {
            _cachedBytesTotal = (try cast(event, ProgressEvent) catch(e:Dynamic) null).bytesTotal;
            if (_preferEstimatedBytesInAudit && as3hx.Compat.parseInt(this.vars.estimatedBytes) > _cachedBytesTotal)
            {
                _cachedBytesTotal = as3hx.Compat.parseInt(this.vars.estimatedBytes);
            }
        }
        else
        {
            if (event.type == "ioError" || event.type == "securityError")
            {
                if (this.vars.alternateURL != null && this.vars.alternateURL != "" && this.vars.alternateURL != url)
                {
                    _errorHandler(event);
                    if (status != LoaderStatus.DISPOSED)
                    {
                        //it is conceivable that the user disposed the loader in an onError handler
                        url = this.vars.alternateURL;
                        _setRequestURL(request, url);
                        var request : URLRequest = new URLRequest();
                        request.data = request.data;
                        request.method = request.method;
                        _setRequestURL(request, url, ((!_isLocal || url.substr(0, 4) == "http")) ? "gsCacheBusterID=" + (_cacheID++) + "&purpose=audit" : "");
                        _auditStream.load(request);
                    }
                    return;
                }
                else
                {
                    //note: a CANCEL event won't be dispatched because technically the loader wasn't officially loading -
                    // we were only briefly checking the bytesTotal with a URLStream.
                    _dispatchFail(event);
                }
            }
        }
        auditedSize = true;
        _closeStream();
        dispatchEvent(new Event("auditedSize"));
    }
    
    private function _failHandler(event : Event, dispatchError : Bool = true) : Void
    {
        if (this.vars.alternateURL != null && this.vars.alternateURL != "" && !_skipAlternateURL)
        {
            //don't do (url != vars.alternateURL) because the audit could have changed it already - that's the whole purpose of _skipAlternateURL.
            _errorHandler(event);
            _skipAlternateURL = true;
            url = "temp" + (Date.now().getTime());  //in case the audit already changed the url to vars.alternateURL, we temporarily make it something different in order to force the refresh in the url setter which skips running the code if the url is set to the same value as it previously was. Don't use Math.random() because for some reason, Google Display Network disallows it (citing security reasons).
            this.url = this.vars.alternateURL;
        }
        else
        {
            _dispatchFail(event, dispatchError);
        }
    }

    private function _dispatchFail(event : Event, dispatchError : Bool = true) : Void
    {
        _dump(0, LoaderStatus.FAILED, true);
        if (dispatchError)
        {
            _errorHandler(event);
        }
        else
        {
            var target : Dynamic = event.target;
        }

        dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, (((Std.is(event, LoaderEvent) && Reflect.hasField(this, "getChildren"))) ? event.target : this),
            Std.string(this) + " > " + (try cast(event, Dynamic) catch(e:Dynamic) null).text, event));
        dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
    }
    
    /** @private **/
    private function _httpStatusHandler(event : Event) : Void
    {
        httpStatus = (try cast(event, Dynamic) catch(e:Dynamic) null).status;
        dispatchEvent(new LoaderEvent(event.type, this, Std.string(httpStatus), event));
    }

    /** @private **/
    private function _errorHandler(event : Event) : Void
    {
        var target : Dynamic = event.target;  //trigger the LoaderEvent's target getter once first in order to ensure that it reports properly - see the notes in LoaderEvent.target for more details.
        target = ((Std.is(event, LoaderEvent) && Reflect.hasField(this, "getChildren"))) ? event.target : this;
        var text : String = "";
        if (Reflect.hasField(event, "error") && Std.is(Reflect.field(event,"error"), Error))
        {
            text = Reflect.field(event,"error").message;
        }
        else
        {
            if (Reflect.hasField(event, "text"))
            {
                text = Reflect.field(event,"text");
            }
        }
        if (event.type != LoaderEvent.ERROR && event.type != LoaderEvent.FAIL && this.hasEventListener(event.type))
        {
            dispatchEvent(new LoaderEvent(event.type, target, text, event));
        }
        if (event.type != "uncaughtError")
        {
            trace("----\nError on " + Std.string(this) + ": " + text + "\n----");
            if (this.hasEventListener(LoaderEvent.ERROR))
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, target, Std.string(this) + " > " + text, event));
            }
        }
    }

    /** @private **/
    private function _calculateProgress() : Void
    {  //override in subclasses if necessary

    }

    //---- GETTERS / SETTERS -------------------------------------------------------------------------

    private function get_status() : Int
    {
        return status;
    }

    /** If a loader is paused, its progress will halt and any LoaderMax instances to which it belongs will either skip over it or stop when its position is reached in the queue (depending on whether or not the LoaderMax's <code>skipPaused</code> property is <code>true</code>). **/
    private function get_paused() : Bool
    {
        return cast(status == LoaderStatus.PAUSED, Bool);
    }
    private function set_paused(value : Bool) : Bool
    {
        if (value && status != LoaderStatus.PAUSED)
        {
            _prePauseStatus = status;
            if (status == LoaderStatus.LOADING)
            {
                _dump(0, LoaderStatus.PAUSED);
            }
            status = LoaderStatus.PAUSED;
        }
        else
        {
            if (!value && status == LoaderStatus.PAUSED)
            {
                if (_prePauseStatus == LoaderStatus.LOADING)
                {
                    load(false);
                }
                else
                {
                    status = _prePauseStatus || LoaderStatus.READY;
                }
            }
        }
        return value;
    }

    /** The url from which the loader should get its content. **/
    private function get_url() : String
    {
        return url;
    }

    private function set_url(value : String) : String
    {
        if (url != value)
        {
            url = value;
            _setRequestURL(request, url);
            var isLoading : Bool = cast(status == LoaderStatus.LOADING, Bool);
            _dump(1, LoaderStatus.READY, true);
            auditedSize = cast(as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0 && this.vars.auditSize != true, Bool);
            _cachedBytesTotal = ((as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0)) ? as3hx.Compat.parseInt(this.vars.estimatedBytes) : LoaderMax.defaultEstimatedBytes;
            _cacheIsDirty = true;
            if (isLoading)
            {
                _load();
            }
        }
        return value;
    }
    
    /** The <code>URLRequest</code> associated with the loader. **/
    private function get_request() : URLRequest
    {
        return request;
    }
    
    /** The httpStatus code of the loader. You may listen for <code>LoaderEvent.HTTP_STATUS</code> events on certain types of loaders to be notified when it changes, but in some environments the Flash player cannot sense httpStatus codes in which case the value will remain <code>0</code>. **/
    private function get_httpStatus() : Int
    {
        return httpStatus;
    }
    
    /**
		 * If the loaded content is denied script access (because of security sandbox restrictions,
		 * a missing crossdomain.xml file, etc.), <code>scriptAccessDenied</code> will be set to <code>true</code>.
		 * In the case of loaded images or swf files, this means that you should not attempt to perform 
		 * BitmapData operations on the content. An image's <code>smoothing</code> property cannot be set 
		 * to <code>true</code> either. Even if script access is denied for particular content, LoaderMax will still
		 * attempt to load it.
		 **/
    private function get_scriptAccessDenied() : Bool
    {
        return _scriptAccessDenied;
    }

    /** Bytes loaded **/
    private function get_bytesLoaded() : Int
    {
        if (_cacheIsDirty)
        {
            _calculateProgress();
        }
        return _cachedBytesLoaded;
    }

    /** Total bytes that are to be loaded by the loader. Initially, this value is set to the <code>estimatedBytes</code> if one was defined in the <code>vars</code> object via the constructor, or it defaults to <code>LoaderMax.defaultEstimatedBytes</code>. When the loader loads enough of the content to accurately determine the bytesTotal, it will do so automatically. **/
    private function get_bytesTotal() : Int
    {
        if (_cacheIsDirty)
        {
            _calculateProgress();
        }
        return _cachedBytesTotal;
    }


    private function get_progress() : Float
    {
        return ((this.bytesTotal != 0)) ? _cachedBytesLoaded / _cachedBytesTotal : ((status == LoaderStatus.COMPLETED)) ? 1 : 0;
    }


    private function get_content() : Dynamic
    {
        return content;
    }


    private function get_auditedSize() : Bool
    {
        return auditedSize;
    }


    private function get_loadTime() : Float
    {
        if (status == LoaderStatus.READY)
        {
            return 0;
        }
        else
        {
            if (status == LoaderStatus.LOADING)
            {
                return (Math.round(haxe.Timer.stamp() * 1000) - _time) / 1000;
            }
            else
            {
                return _time / 1000;
            }
        }
    }
}
