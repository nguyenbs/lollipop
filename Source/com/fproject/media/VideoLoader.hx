package com.fproject.media;
import Lambda;
import openfl.display.Sprite;
import openfl.media.Video;
import openfl.net.NetStream;
import openfl.events.Event;

class VideoLoader extends LoaderBase{
    public var netStream(get, never) : NetStream;
    public var videoPaused(get, set) : Bool;
    public var bufferProgress(get, never) : Float;
    public var playProgress(get, set) : Float;
    public var volume(get, set) : Float;
    public var videoTime(get, set) : Float;
    public var duration(get, never) : Float;

    /**
		 * When <code>bufferMode</code> is <code>true</code>, the loader will report its progress only in terms of the
		 * video's buffer instead of its overall file loading progress which has the following effects:
		 * <ul>
		 * 		<li>The <code>bytesTotal</code> will be calculated based on the NetStream's <code>duration</code>,
		 * 		<code>bufferLength</code>, and <code>bufferTime</code> meaning it may fluctuate in order to accurately reflect the overall <code>progress</code> ratio.</li>
		 * 		<li>Its <code>COMPLETE</code> event will be dispatched as soon as the buffer is full, so if the VideoLoader is
		 * 		nested in a LoaderMax, the LoaderMax will move on to the next loader in its queue at that point.
		 * 		However, the VideoLoader's NetStream will continue to load in the background, using up bandwidth.</li>
		 * </ul>
		 *
		 * <p>This can be very convenient if, for example, you want to display loading progress based on the video's buffer
		 * or if you want to load a series of loaders in a LoaderMax and have it fire its <code>COMPLETE</code> event
		 * when the buffer is full (as opposed to waiting for the entire video to load). </p>
		 **/
    public var bufferMode(get, set) : Bool;

    /** If <code>true</code> (the default), the NetStream will only be attached to the Video object
    * (the <code>rawContent</code>) when it is in the display list (on the stage).
     * This conserves memory but it can cause a very brief rendering delay when the content is initially added to the stage
     * (often imperceptible).
     * Also, if you add it to the stage when the videoTime is <i>after</i> its last encoded keyframe, it will render at that last keyframe. **/
    public var autoDetachNetStream(get, set) : Bool;


    /** An object containing optional configuration details, typically passed through a constructor parameter.
    * For example: <code>new SWFLoader("assets/file.swf", {name:"swf1", container:this, autoPlay:true, noCache:true})</code>.
    * See the constructor's documentation for details about what special properties are recognized. **/
    public var vars : Dynamic;

    /** @private **/
    private var _ns : NetStream;

    /** @private **/
    private var _video : Video;

    /** @private **/
    private var _sprite : Sprite;

    /** @private **/
    private var _pausePending : Bool;

    /** @private **/
    private var _forceTime : Float;



    /**
		 * Constructor
		 *
		 * @param urlOrRequest The url (<code>String</code>) or <code>URLRequest</code> from which the loader should get its content.
		 * @param vars An object containing optional configuration details. For example: <code>new VideoLoader("video/video.flv", {name:"myVideo", onComplete:completeHandler, onProgress:progressHandler})</code>.
		 *
		 * <p>The following special properties can be passed into the constructor via the <code>vars</code> parameter
		 * which can be either a generic object or a <code><a href="data/VideoLoaderVars.html">VideoLoaderVars</a></code> object:</p>
		 * <ul>
		 * 		<li><strong> name : String</strong> - A name that is used to identify the VideoLoader instance. This name can be fed to the <code>LoaderMax.getLoader()</code> or <code>LoaderMax.getContent()</code> methods or traced at any time. Each loader's name should be unique. If you don't define one, a unique name will be created automatically, like "loader21".</li>
		 * 		<li><strong> bufferTime : Number</strong> - The amount of time (in seconds) that should be buffered before the video can begin playing (set <code>autoPlay</code> to <code>false</code> to pause the video initially).</li>
		 * 		<li><strong> autoPlay : Boolean</strong> - By default, the video will begin playing as soon as it has been adequately buffered, but to prevent it from playing initially, set <code>autoPlay</code> to <code>false</code>.</li>
		 * 		<li><strong> smoothing : Boolean</strong> - When <code>smoothing</code> is <code>true</code> (the default), smoothing will be enabled for the video which typically leads to better scaling results.</li>
		 * 		<li><strong> container : DisplayObjectContainer</strong> - A DisplayObjectContainer into which the <code>ContentDisplay</code> should be added immediately.</li>
		 * 		<li><strong> width : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>width</code> property (applied before rotation, scaleX, and scaleY).</li>
		 * 		<li><strong> height : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>height</code> property (applied before rotation, scaleX, and scaleY).</li>
		 * 		<li><strong> centerRegistration : Boolean </strong> - if <code>true</code>, the registration point will be placed in the center of the <code>ContentDisplay</code> which can be useful if, for example, you want to animate its scale and have it grow/shrink from its center.</li>
		 * 		<li><strong> scaleMode : String </strong> - When a <code>width</code> and <code>height</code> are defined, the <code>scaleMode</code> controls how the video will be scaled to fit the area. The following values are recognized (you may use the <code>com.greensock.layout.ScaleMode</code> constants if you prefer):
		 * 			<ul>
		 * 				<li><code>"stretch"</code> (the default) - The video will fill the width/height exactly.</li>
		 * 				<li><code>"proportionalInside"</code> - The video will be scaled proportionally to fit inside the area defined by the width/height</li>
		 * 				<li><code>"proportionalOutside"</code> - The video will be scaled proportionally to completely fill the area, allowing portions of it to exceed the bounds defined by the width/height.</li>
		 * 				<li><code>"widthOnly"</code> - Only the width of the video will be adjusted to fit.</li>
		 * 				<li><code>"heightOnly"</code> - Only the height of the video will be adjusted to fit.</li>
		 * 				<li><code>"none"</code> - No scaling of the video will occur.</li>
		 * 			</ul></li>
		 * 		<li><strong> hAlign : String </strong> - When a <code>width</code> and <code>height</code> are defined, the <code>hAlign</code> determines how the video is horizontally aligned within that area. The following values are recognized (you may use the <code>com.greensock.layout.AlignMode</code> constants if you prefer):
		 * 			<ul>
		 * 				<li><code>"center"</code> (the default) - The video will be centered horizontally in the area</li>
		 * 				<li><code>"left"</code> - The video will be aligned with the left side of the area</li>
		 * 				<li><code>"right"</code> - The video will be aligned with the right side of the area</li>
		 * 			</ul></li>
		 * 		<li><strong> vAlign : String </strong> - When a <code>width</code> and <code>height</code> are defined, the <code>vAlign</code> determines how the video is vertically aligned within that area. The following values are recognized (you may use the <code>com.greensock.layout.AlignMode</code> constants if you prefer):
		 * 			<ul>
		 * 				<li><code>"center"</code> (the default) - The video will be centered vertically in the area</li>
		 * 				<li><code>"top"</code> - The video will be aligned with the top of the area</li>
		 * 				<li><code>"bottom"</code> - The video will be aligned with the bottom of the area</li>
		 * 			</ul></li>
		 * 		<li><strong> crop : Boolean</strong> - When a <code>width</code> and <code>height</code> are defined, setting <code>crop</code> to <code>true</code> will cause the video to be cropped within that area (by applying a <code>scrollRect</code> for maximum performance). This is typically useful when the <code>scaleMode</code> is <code>"proportionalOutside"</code> or <code>"none"</code> so that any parts of the video that exceed the dimensions defined by <code>width</code> and <code>height</code> are visually chopped off. Use the <code>hAlign</code> and <code>vAlign</code> special properties to control the vertical and horizontal alignment within the cropped area.</li>
		 * 		<li><strong> x : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>x</code> property (for positioning on the stage).</li>
		 * 		<li><strong> y : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>y</code> property (for positioning on the stage).</li>
		 * 		<li><strong> scaleX : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>scaleX</code> property.</li>
		 * 		<li><strong> scaleY : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>scaleY</code> property.</li>
		 * 		<li><strong> rotation : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>rotation</code> property.</li>
		 * 		<li><strong> alpha : Number</strong> - Sets the <code>ContentDisplay</code>'s <code>alpha</code> property.</li>
		 * 		<li><strong> visible : Boolean</strong> - Sets the <code>ContentDisplay</code>'s <code>visible</code> property.</li>
		 * 		<li><strong> blendMode : String</strong> - Sets the <code>ContentDisplay</code>'s <code>blendMode</code> property.</li>
		 * 		<li><strong> bgColor : uint </strong> - When a <code>width</code> and <code>height</code> are defined, a rectangle will be drawn inside the <code>ContentDisplay</code> immediately in order to ease the development process. It is transparent by default, but you may define a <code>bgAlpha</code> if you prefer.</li>
		 * 		<li><strong> bgAlpha : Number </strong> - Controls the alpha of the rectangle that is drawn when a <code>width</code> and <code>height</code> are defined.</li>
		 * 		<li><strong> volume : Number</strong> - A value between 0 and 1 indicating the volume at which the video should play (default is 1).</li>
		 * 		<li><strong> repeat : int</strong> - Number of times that the video should repeat. To repeat indefinitely, use -1. Default is 0.</li>
		 * 		<li><strong> stageVideo : StageVideo</strong> - By default, the NetStream gets attached to a <code>Video</code> object, but if you want to use StageVideo in Flash, you can define the <code>stageVideo</code> property and VideoLoader will attach its NetStream to that StageVideo instance instead of the regular Video instance (which is the <code>rawContent</code>). Please read Adobe's docs regarding StageVideo to understand the benefits, tradeoffs and limitations.</li>
		 * 		<li><strong> checkPolicyFile : Boolean</strong> - If <code>true</code>, the VideoLoader will check for a crossdomain.xml file on the remote host (only useful when loading videos from other domains - see Adobe's docs for details about NetStream's <code>checkPolicyFile</code> property). </li>
		 * 		<li><strong> estimatedDuration : Number</strong> - Estimated duration of the video in seconds. VideoLoader will only use this value until it receives the necessary metaData from the video in order to accurately determine the video's duration. You do not need to specify an <code>estimatedDuration</code>, but doing so can help make the playProgress and some other values more accurate (until the metaData has loaded). It can also make the <code>progress/bytesLoaded/bytesTotal</code> more accurate when a <code>estimatedDuration</code> is defined, particularly in <code>bufferMode</code>.</li>
		 * 		<li><strong> deblocking : int</strong> - Indicates the type of filter applied to decoded video as part of post-processing. The default value is 0, which lets the video compressor apply a deblocking filter as needed. See Adobe's <code>flash.media.Video</code> class docs for details.</li>
		 * 		<li><strong> bufferMode : Boolean </strong> - When <code>true</code>, the loader will report its progress only in terms of the video's buffer which can be very convenient if, for example, you want to display loading progress for the video's buffer or tuck it into a LoaderMax with other loaders and allow the LoaderMax to dispatch its <code>COMPLETE</code> event when the buffer is full instead of waiting for the whole file to download. When <code>bufferMode</code> is <code>true</code>, the VideoLoader will dispatch its <code>COMPLETE</code> event when the buffer is full as opposed to waiting for the entire video to load. You can toggle the <code>bufferMode</code> anytime. Please read the full <code>bufferMode</code> property ASDoc description below for details about how it affects things like <code>bytesTotal</code>.</li>
		 * 		<li><strong> autoAdjustBuffer : Boolean </strong> If the buffer becomes empty during playback and <code>autoAdjustBuffer</code> is <code>true</code> (the default), it will automatically attempt to adjust the NetStream's <code>bufferTime</code> based on the rate at which the video has been loading, estimating what it needs to be in order to play the rest of the video without emptying the buffer again. This can prevent the annoying problem of video playback start/stopping/starting/stopping on a system tht doesn't have enough bandwidth to adequately buffer the video. You may also set the <code>bufferTime</code> in the constructor's <code>vars</code> parameter to set the initial value.</li>
		 * 		<li><strong> autoDetachNetStream : Boolean</strong> - If <code>true</code>, the NetStream will only be attached to the Video object (the <code>rawContent</code>) when it is in the display list (on the stage). This conserves memory but it can cause a very brief rendering delay when the content is initially added to the stage (often imperceptible). Also, if you add it to the stage when the <code>videoTime</code> is <i>after</i> its last encoded keyframe, it will render at that last keyframe.</li>
		 * 		<li><strong> alternateURL : String</strong> - If you define an <code>alternateURL</code>, the loader will initially try to load from its original <code>url</code> and if it fails, it will automatically (and permanently) change the loader's <code>url</code> to the <code>alternateURL</code> and try again. Think of it as a fallback or backup <code>url</code>. It is perfectly acceptable to use the same <code>alternateURL</code> for multiple loaders (maybe a default image for various ImageLoaders for example).</li>
		 * 		<li><strong> noCache : Boolean</strong> - If <code>noCache</code> is <code>true</code>, a "gsCacheBusterID" parameter will be appended to the url with a random set of numbers to prevent caching (don't worry, this info is ignored when you <code>getLoader()</code> or <code>getContent()</code> by url and when you're running locally)</li>
		 * 		<li><strong> estimatedBytes : uint</strong> - Initially, the loader's <code>bytesTotal</code> is set to the <code>estimatedBytes</code> value (or <code>LoaderMax.defaultEstimatedBytes</code> if one isn't defined). Then, when the loader begins loading and it can accurately determine the bytesTotal, it will do so. Setting <code>estimatedBytes</code> is optional, but the more accurate the value, the more accurate your loaders' overall progress will be initially. If the loader will be inserted into a LoaderMax instance (for queue management), its <code>auditSize</code> feature can attempt to automatically determine the <code>bytesTotal</code> at runtime (there is a slight performance penalty for this, however - see LoaderMax's documentation for details).</li>
		 * 		<li><strong> requireWithRoot : DisplayObject</strong> - LoaderMax supports <i>subloading</i>, where an object can be factored into a parent's loading progress. If you want LoaderMax to require this VideoLoader as part of its parent SWFLoader's progress, you must set the <code>requireWithRoot</code> property to your swf's <code>root</code>. For example, <code>var loader:VideoLoader = new VideoLoader("myScript.php", {name:"textData", requireWithRoot:this.root});</code></li>
		 * 		<li><strong> allowMalformedURL : Boolean</strong> - Normally, the URL will be parsed and any variables in the query string (like "?name=test&amp;state=il&amp;gender=m") will be placed into a URLVariables object which is added to the URLRequest. This avoids a few bugs in Flash, but if you need to keep the entire URL intact (no parsing into URLVariables), set <code>allowMalformedURL:true</code>. For example, if your URL has duplicate variables in the query string like <code>http://www.greensock.com/?c=S&amp;c=SE&amp;c=SW</code>, it is technically considered a malformed URL and a URLVariables object can't properly contain all the duplicates, so in this case you'd want to set <code>allowMalformedURL</code> to <code>true</code>.</li>
		 * 		<li><strong> autoDispose : Boolean</strong> - When <code>autoDispose</code> is <code>true</code>, the loader will be disposed immediately after it completes (it calls the <code>dispose()</code> method internally after dispatching its <code>COMPLETE</code> event). This will remove any listeners that were defined in the vars object (like onComplete, onProgress, onError, onInit). Once a loader is disposed, it can no longer be found with <code>LoaderMax.getLoader()</code> or <code>LoaderMax.getContent()</code> - it is essentially destroyed but its content is not unloaded (you must call <code>unload()</code> or <code>dispose(true)</code> to unload its content). The default <code>autoDispose</code> value is <code>false</code>.
		 *
		 * 		<p>----EVENT HANDLER SHORTCUTS----</p></li>
		 * 		<li><strong> onOpen : Function</strong> - A handler function for <code>LoaderEvent.OPEN</code> events which are dispatched when the loader begins loading. Make sure your onOpen function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * 		<li><strong> onInit : Function</strong> - A handler function for <code>Event.INIT</code> events which will be called when the video's metaData has been received and the video is placed into the <code>ContentDisplay</code>. The <code>INIT</code> event can be dispatched more than once if the NetStream receives metaData more than once (which occasionally happens, particularly with F4V files - the first time often doesn't include the cuePoints). Make sure your <code>onInit</code> function accepts a single parameter of type <code>Event</code> (flash.events.Event).</li>
		 * 		<li><strong> onProgress : Function</strong> - A handler function for <code>LoaderEvent.PROGRESS</code> events which are dispatched whenever the <code>bytesLoaded</code> changes. Make sure your onProgress function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>). You can use the LoaderEvent's <code>target.progress</code> to get the loader's progress value or use its <code>target.bytesLoaded</code> and <code>target.bytesTotal</code>.</li>
		 * 		<li><strong> onComplete : Function</strong> - A handler function for <code>LoaderEvent.COMPLETE</code> events which are dispatched when the loader has finished loading successfully. Make sure your onComplete function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * 		<li><strong> onCancel : Function</strong> - A handler function for <code>LoaderEvent.CANCEL</code> events which are dispatched when loading is aborted due to either a failure or because another loader was prioritized or <code>cancel()</code> was manually called. Make sure your onCancel function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * 		<li><strong> onError : Function</strong> - A handler function for <code>LoaderEvent.ERROR</code> events which are dispatched whenever the loader experiences an error (typically an IO_ERROR). An error doesn't necessarily mean the loader failed, however - to listen for when a loader fails, use the <code>onFail</code> special property. Make sure your onError function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * 		<li><strong> onFail : Function</strong> - A handler function for <code>LoaderEvent.FAIL</code> events which are dispatched whenever the loader fails and its <code>status</code> changes to <code>LoaderStatus.FAILED</code>. Make sure your onFail function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * 		<li><strong> onIOError : Function</strong> - A handler function for <code>LoaderEvent.IO_ERROR</code> events which will also call the onError handler, so you can use that as more of a catch-all whereas <code>onIOError</code> is specifically for LoaderEvent.IO_ERROR events. Make sure your onIOError function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).</li>
		 * </ul>
		 * @see com.greensock.loading.data.VideoLoaderVars
		 */
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        this.vars = vars;
        _video = new Video(Lambda.has(vars, "width") ? this.vars.width : 320, Lambda.has(vars, "height") ? vars.height : 240);
        _video.smoothing = Lambda.has(vars, "smoothing") ? cast(vars.smoothing, Bool) : false;
        if(Lambda.has(vars, "deblocking"))
            _video.deblocking = as3hx.Compat.parseInt(vars.deblocking);
        _video.addEventListener(Event.ADDED_TO_STAGE, _videoAddedToStage, false, 0, true);
        _video.addEventListener(Event.REMOVED_FROM_STAGE, _videoRemovedFromStage, false, 0, true);

    }

    /** @private **/
    private function _setForceTime(time : Float) : Void
    {
        if (!(_forceTime || _forceTime == 0))
        {
            //if _forceTime is already set, the listener was already added (we remove it after 1 frame or after the buffer fills for the first time and metaData is received (whichever takes longer)
            _waitForRender();
        }
        _forceTime = time;
    }

    /** @protected **/
    private function _seek(time : Float) : Void
    {
        _ns.seek(time);
        _setForceTime(time);
        if (_bufferFull)
        {
            _bufferFull = false;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY, this));
        }
    }

    /** @private The video isn't decoded into memory fully until the NetStream is attached to the Video object. We only attach it when it is in the display list (thus can be seen) in order to conserve memory. **/
    private function _videoAddedToStage(event : Event) : Void
    {
        if (_autoDetachNetStream)
        {
            if (!_pausePending)
            {
                _seek(this.videoTime);
            }
            if (_stageVideo != null)
            {
                _stageVideo.attachNetStream(_ns);
            }
            else
            {
                _video.attachNetStream(_ns);
            }
        }
    }

    /** @private **/
    private function _videoRemovedFromStage(event : Event) : Void
    {
        if (_autoDetachNetStream)
        {
            _video.attachNetStream(null);
            _video.clear();
        }
    }

    private function get_netStream() : NetStream
    {
        return _ns;
    }

    /** The playback status of the video: <code>true</code> if the video's playback is paused, <code>false</code> if it isn't. **/
    private function get_videoPaused() : Bool
    {
        return _videoPaused;
    }
    private function set_videoPaused(value : Bool) : Bool
    {
        var changed : Bool = cast(value != _videoPaused, Bool);
        _videoPaused = value;
        if (_videoPaused)
        {
            //If we're trying to pause a NetStream that hasn't even been buffered yet, we run into problems where it won't load. So we need to set the _pausePending to true and then when it's buffered, it'll pause it at the beginning.
            if (!_renderedOnce)
            {
                _setForceTime(0);
                _pausePending = true;
                _sound.volume = 0;  //temporarily make it silent while buffering.
                _ns.soundTransform = _sound;
            }
            else
            {
                _pausePending = false;
                this.volume = _volume;  //Just resets the volume to where it should be in case we temporarily made it silent during the buffer.
                _ns.pause();
            }
            if (changed)
            {
                //previously, we included _sprite.removeEventListener(Event.ENTER_FRAME, _playProgressHandler) but discovered it was better to leave it running in order to work around a bug in Adobe's NetStream that causes it not to accurately report its time even when the NetStatusEvent is dispatched with the code "NetStream.Seek.Notify". Consequently, when the VideoLoader was paused and the videoProgress was changed or gotoVideoTime() was called, the PLAY_PROGRESS event would be dispatched before the NetStream.time arrived where it was supposed to be.
                dispatchEvent(new LoaderEvent(VIDEO_PAUSE, this));
            }
        }
        else
        {
            if (_pausePending || !_bufferFull)
            {
                if (_stageVideo != null)
                {
                    _stageVideo.attachNetStream(_ns);
                }
                else
                {
                    if (_video.stage != null)
                    {
                        _video.attachNetStream(_ns);
                    }
                }
                //if we don't seek() first, sometimes the NetStream doesn't attach to the video properly!
                //if we don't seek() first and the NetStream was previously rendered between its last keyframe and the end of the file, the "NetStream.Play.Stop" will have been called and it will refuse to continue playing even after resume() is called!
                //if we seek() before the metaData has been received (_initted==true), it typically prevents it from being received at all!
                //if we seek() before the NetStream has rendered once, it can lose audio completely!
                if (_initted && _renderedOnce)
                {
                    _seek(this.videoTime);
                }
                _pausePending = false;
            }
            this.volume = _volume;  //Just resets the volume to where it should be in case we temporarily made it silent during the buffer.
            _ns.resume();
            if (changed && _playStarted)
            {
                dispatchEvent(new LoaderEvent(VIDEO_PLAY, this));
            }
        }
        return value;
    }

    /** A value between 0 and 1 describing the progress of the buffer (0 = not buffered at all, 0.5 = halfway buffered, and 1 = fully buffered). The buffer progress is in relation to the <code>bufferTime</code> which is 5 seconds by default or you can pass a custom value in through the <code>vars</code> parameter in the constructor like <code>{bufferTime:20}</code>. **/
    private function get_bufferProgress() : Float
    {
        if (as3hx.Compat.parseInt(_ns.bytesTotal) < 5)
        {
            return 0;
        }
        return ((_ns.bufferLength > _ns.bufferTime)) ? 1 : _ns.bufferLength / _ns.bufferTime;
    }

    /** A value between 0 and 1 describing the playback progress where 0 means the virtual playhead is at the very beginning of the video, 0.5 means it is at the halfway point and 1 means it is at the end of the video. **/
    private function get_playProgress() : Float
    {
        //Often times the duration MetaData that gets passed in doesn't exactly reflect the duration, so after the FLV is finished playing, the time and duration wouldn't equal each other, so we'd get percentPlayed values of 99.26978. We have to use this _videoComplete variable to accurately reflect the status.
        //If for example, after an FLV has finished playing, we gotoVideoTime(0) the FLV and immediately check the playProgress, it returns 1 instead of 0 because it takes a short time to render the first frame and accurately reflect the _ns.time variable. So we use an interval to help us override the _ns.time value briefly.
        return ((_videoComplete)) ? 1 : (this.videoTime / _duration);
    }
    private function set_playProgress(value : Float) : Float
    {
        if (_duration != 0)
        {
            gotoVideoTime(value * _duration, !_videoPaused, true);
        }
        return value;
    }

    /** The volume of the video (a value between 0 and 1). **/
    private function get_volume() : Float
    {
        return _volume;
    }
    private function set_volume(value : Float) : Float
    {
        _sound.volume = _volume = value;
        _ns.soundTransform = _sound;
        return value;
    }

    /** The time (in seconds) at which the virtual playhead is positioned on the video. For example, if the virtual playhead is currently at the 3-second position (3 seconds from the beginning), this value would be 3. **/
    private function get_videoTime() : Float
    {
        if ((_forceTime != 0 && !Math.isNaN(_forceTime)) || _forceTime == 0)
        {
            return _forceTime;
        }
        else
        {
            if (_videoComplete)
            {
                return _duration;
            }
            else
            {
                if (_ns.time > _duration)
                {
                    return _duration * 0.995;
                }
                else
                {
                    return _ns.time;
                }
            }
        }
    }
    private function set_videoTime(value : Float) : Float
    {
        gotoVideoTime(value, !_videoPaused, true);
        return value;
    }

    /** The duration (in seconds) of the video. This value is only accurate AFTER the metaData has been received and the <code>INIT</code> event has been dispatched. **/
    private function get_duration() : Float
    {
        return _duration;
    }


    private function get_bufferMode() : Bool
    {
        return _bufferMode;
    }
    private function set_bufferMode(value : Bool) : Bool
    {
        _bufferMode = value;
        _preferEstimatedBytesInAudit = _bufferMode;
        _calculateProgress();
        if (_cachedBytesLoaded < _cachedBytesTotal && _status == LoaderStatus.COMPLETED)
        {
            _status = LoaderStatus.LOADING;
            _sprite.addEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
        }
        return value;
    }


    private function get_autoDetachNetStream() : Bool
    {
        return _autoDetachNetStream;
    }

    private function set_autoDetachNetStream(value : Bool) : Bool
    {
        _autoDetachNetStream = value;
        if (_autoDetachNetStream && _video.stage == null)
        {
            _video.attachNetStream(null);
            _video.clear();
        }
        else
        {
            if (_stageVideo != null)
            {
                _stageVideo.attachNetStream(_ns);
            }
            else
            {
                _video.attachNetStream(_ns);
            }
        }
        return value;
    }
}
