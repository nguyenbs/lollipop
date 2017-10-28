package;

import com.fproject.media.events.LoaderEvent;
import com.fproject.media.VideoLoader;
import assets.McConnect;
import assets.McLollipop;
import assets.McPreloader2;

//import com.facebook.graph.Facebook;
//import com.greensock.TweenMax;
//import com.greensock.events.LoaderEvent;
//import com.greensock.loading.LoaderMax;
//import com.greensock.loading.VideoLoader;

import com.thinknickel.thecollector.FacebookConnector;
import com.thinknickel.thecollector.OutroMC;
import com.thinknickel.thecollector.TrackingManager;
import com.thinknickel.thecollector.UserObj;
import com.thinknickel.thecollector.fakepage.CarPhotoMC;
import com.thinknickel.thecollector.fakepage.DropDownMC;
import com.thinknickel.thecollector.fakepage.FakeFacebookPage;
import com.thinknickel.thecollector.fakepage.Zoom1MC;
//import com.thinknickel.thecollector.map.MapMC;
import com.thinknickel.utils.MouseCapture;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.LoaderInfo;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.external.ExternalInterface;
import openfl.system.Security;


class Main extends Sprite
{

	public static var instance : Main;

	public static var DONE_BUILD : String = "donebuild";


	public var myXML : FastXML;

	public var assetPath : String;

	public var mainPath : String;

	public var appPath : String;

	public var tabPath : String;

	public var picID : String;

	public var picPath : String;

	public var info : LoaderInfo;

	public var fbAPI : String;

	private var contentHolder : Sprite;

	private var user : UserObj;

	private var fbConnector : FacebookConnector;

	private var coverSprite : Sprite;

	private var vidID : String;

//	public var ldrMax : LoaderMax;

	private var introVidMC : VideoLoader;

	private var fbConnectBtn : McConnect;

	private var facebookPage : Bitmap;

	private var wallContainer : Sprite;

	private var wallHolder : MovieClip;

	private var lastIndex : Int;

	private var vertices : Array<Float>;

	private var uvt : Array<Float>;

	private var facebookPageBD : BitmapData;

	private var overlay : Bool;

	private var currCue : Int;

	private var startTime : Float;

	private var stopTime : Float;

	private var currCoords : Array<Dynamic>;

	private var tempBD : BitmapData;

	//private var mapMC : MapMC;

	private var dropDownMC : DropDownMC;

	private var carPhotoMC : CarPhotoMC;

	private var currBD : BitmapData;

	private var wallMask : Sprite;

	private var fbpage : FakeFacebookPage;

	private var dummyBD : BitmapData;

	private var vidHolder : Sprite;

	private var currMC : DisplayObject;

	private var zoom1MC : Zoom1MC;

	public var googleapi : String;

	private var outro : OutroMC;

	private var lolly : McLollipop;

	private var preloader : McPreloader2;

	private var currPerc : Int;

	private var percObj : Dynamic;

	private var mouseCapture : MouseCapture;

	private var lastTimeTrack : Float = -10;

	private var appID : String;

	public function new()
	{
		contentHolder = new Sprite();
		user = new UserObj();
		currCoords = [];
		percObj = { };
		super();
		instance = this;
		Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
		dummyBD = new BitmapData(100, 100, false, 16711680);
		uvt = new Array<Float>();
		uvt.push(0);
		uvt.push(0);

		uvt.push(1);
		uvt.push(0);

		uvt.push(0);
		uvt.push(1);

		uvt.push(1);
		uvt.push(0);

		uvt.push(1);
		uvt.push(1);

		uvt.push(0);
		uvt.push(1);

		this.addEventListener("addedToStage", init);
	}

	public static function getInstance() : Main
	{
		return instance;
	}

	public function init(e : Event = null) : Void
	{
		//ldrMax = new LoaderMax();
		this.removeEventListener("addedToStage", init);
		TrackingManager.init(this);
		info = stage.loaderInfo;
		if (info.parameters.fbapi != null)
		{
			fbAPI = info.parameters.fbapi;
		}
		assetPath = stage.loaderInfo.parameters.assetpath;
		mainPath = stage.loaderInfo.parameters.mainpath;
		appPath = stage.loaderInfo.parameters.apppath;
		tabPath = stage.loaderInfo.parameters.tabpath;
		picID = stage.loaderInfo.parameters.picid;
		vidID = stage.loaderInfo.parameters.vidid;
		picPath = stage.loaderInfo.parameters.picpath;
		googleapi = stage.loaderInfo.parameters.googleapi;
		appID = stage.loaderInfo.parameters.appid;
		stage.stageFocusRect = false;
		stage.tabChildren = false;
		LoaderMax.defaultAuditSize = false;
		this.addChild(contentHolder);
		vidHolder = new Sprite();
		contentHolder.addChildAt(vidHolder, 0);
		preloader = new McPreloader2();
		this.addChild(preloader);
		preloader.mc_loadbar.scaleX = 0;
		currPerc = 0;
		percObj.num = 0;
		preloader.alpha = 0;
		preloader.mouseChildren = false;
		var contxtMenu : ContextMenu = new ContextMenu();
		contxtMenu.hideBuiltInItems();
		var item : ContextMenuItem = new ContextMenuItem("Version 0.4, 10.31.11");
		contxtMenu.customItems.push(item);
		this.contextMenu = contxtMenu;
		UserObj.getInstance().userID = Std.string(as3hx.Compat.parseInt(Date.now().getTime()));
		wallContainer = new Sprite();
		wallHolder = new MovieClip();
		wallHolder.addChild(wallContainer);
		this.addChild(wallHolder);
		wallHolder.blendMode = "multiply";
		wallHolder.alpha = 0.8;
		fbConnector = new FacebookConnector(appID);
		this.addChild(fbConnector);
		fbConnector.addEventListener("permscancelled", cancelledPerms);
		if (!Math.isNaN(stage.color))
		{
			stage.color = 0;
		}
		coverSprite = new Sprite();
		coverSprite.graphics.beginFill(0, 0.4);
		coverSprite.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		coverSprite.graphics.endFill();
		coverSprite.visible = false;
		coverSprite.alpha = 0;
		this.addChild(coverSprite);
		stage.addEventListener("resize", resized);
		resized(null);
	}

	private function updateLoader(e : Event = null) : Void
	{
		preloader.alpha = 1;
		currPerc = as3hx.Compat.parseInt(currPerc + 1);
		var perc : Float = currPerc / 6;
		perc = Math.min(perc, 1);
		TweenMax.to(preloader.mc_loadbar, 0.3, {
			scaleX : perc
		});
		TweenMax.to(percObj, 0.3, {
			num : perc,
			onUpdate : updatePerc
		});
	}

	private function updatePerc() : Void
	{
		preloader.perc_txt.text = Math.round(percObj.num * 100) + "%";
		if (percObj.num >= 1)
		{
			TweenMax.to(preloader, 0.4, {
				autoAlpha : 0
			});
		}
	}

	private function resized(e : Event = null) : Void
	{
		if (stage == null)
		{
			return;
		}
		if (lolly != null)
		{
			lolly.x = stage.stageWidth / 2;
			lolly.y = stage.stageHeight / 2 - 200;
		}
		preloader.x = (stage.stageWidth - preloader.width) / 2;
		preloader.y = (stage.stageHeight - preloader.height) / 2 + 250;
		if (stage == null)
		{
			return;
		}
		var ratio : Float = 1.77777777777778;
		contentHolder.x = 0;
		contentHolder.y = 0;
		var targW : Int = Math.round(stage.stageWidth);
		var targH : Int = Math.round(targW / ratio);
		var bottomHeight : Int = 0;
		var offset : Int = 0;
		if (targH > stage.stageHeight - bottomHeight)
		{
			targH = Math.round(stage.stageHeight - bottomHeight);
			targW = Math.round(targH * ratio);
		}
		if (targW < stage.stageWidth)
		{
			contentHolder.x = Math.round((stage.stageWidth - targW) / 2);
		}
		if (targH < stage.stageHeight + bottomHeight)
		{
			contentHolder.y = Math.round((stage.stageHeight - bottomHeight - targH) / 2 + offset);
		}
		else
		{
			contentHolder.y = 0;
		}
		contentHolder.width = targW;
		contentHolder.scaleY = contentHolder.scaleX;
		var _loc7_ : Dynamic = contentHolder.scaleX;
		wallHolder.scaleY = _loc7_;
		wallHolder.scaleX = _loc7_;
		wallHolder.x = contentHolder.x;
		wallHolder.y = contentHolder.y;
		if (mapMC != null)
		{
			_loc7_ = contentHolder.scaleX;
			this.mapMC.scaleY = _loc7_;
			this.mapMC.scaleX = _loc7_;
		}
	}

	public function startMe(myXML : FastXML) : Void
	{
		this.myXML = myXML;
		startTime = myXML.nodes.cue.get(0).node.start.innerData;
		stopTime = myXML.nodes.cue.get(0).node.stop.innerData;
		overlay = false;
		currCue = 0;
		lolly = new McLollipop();
		this.addChild(lolly);
		lolly.addEventListener("click", fbClicked);
		lolly.buttonMode = true;
		lolly.alpha = 0;
		TweenMax.to(lolly, 0.4, {
			autoAlpha : 1
		});
		var prefix : String = Main.getInstance().assetPath;
		trace("prefix=" + prefix);
		var vidXML : FastXMLList = myXML.node.video.innerData;
		var vidFile : String = vidXML.get(0).node.src.innerData;
		introVidMC = new VideoLoader(prefix + vidFile, {
			width : 1280,
			height : 720,
			autoPlay : false,
			smoothing : true,
			bufferTime : 2,
			container : vidHolder,
			volume : 1
		});
		introVidMC.load();
		introVidMC.content.visible = false;
		introVidMC.content.mouseEnabled = false;
		introVidMC.addEventListener("playProgress", checkTime);
		introVidMC.addEventListener("videoBufferFull", bufferFull);
		introVidMC.addEventListener("videoComplete", introVidDone);
		resized(null);
	}

	private function fbClicked(event : Event) : Void
	{
		FacebookConnector.getInstance().tryLogin(buildPage, true);
		TweenMax.delayedCall(1, trackFBClick);
	}

	private function trackFBClick() : Void
	{
		ExternalInterface.call("_gaq.push", ["_trackEvent", "event", "button", "fbconnect"]);
	}

	private function buildPage() : Void
	{
		trace("build page");
		fbpage = new FakeFacebookPage();
		fbpage.addEventListener("donecreating", doneCreatingFBPage);
		fbpage.addEventListener(FakeFacebookPage.GOT_PROFILE_PIC, createDropDown);
		fbpage.addEventListener(FakeFacebookPage.UPDATE_LOADER, updateLoader);
		updateLoader();
		lolly.mouseEnabled = false;
	}

	private function createDropDown(event : Event) : Void
	{
		updateLoader();
		trace("create");
		dropDownMC = new DropDownMC();
		contentHolder.addChild(dropDownMC);
		dropDownMC.visible = false;
		dropDownMC.blendMode = "multiply";
		dropDownMC.alpha = 0.8;
		createCarPhoto();
	}

	private function createCarPhoto() : Void
	{
		updateLoader();
		trace("create car photo");
		carPhotoMC = new CarPhotoMC();
		contentHolder.addChild(carPhotoMC);
		carPhotoMC.visible = false;
		carPhotoMC.alpha = 0.8;
	}

	private function doneCreatingFBPage(event : Event) : Void
	{
		updateLoader();
		trace("done creating");
		//mapMC = new MapMC();
		this.addChild(mapMC);
		mapMC.visible = false;
		mouseCapture = new MouseCapture();
		wallHolder.addChild(mouseCapture);
		pageBuilt();
	}

	private function pageBuilt() : Void
	{
		updateLoader();
		contentHolder.addEventListener("click", skipAhead);
		introVidMC.resume();
		ExternalInterface.call("_gaq.push", ["_trackPageview", "video"]);
		this.dispatchEvent(new Event(Main.DONE_BUILD));
		ExternalInterface.call("hideLike");
		TweenMax.to(lolly, 0.4, {
			autoAlpha : 0,
			delay : 1,
			onComplete : startVideo
		});
		resized(null);
	}

	private function bufferFull(event : Event) : Void
	{
		trace("bufferfull");
		resized(null);
	}

	private function startVideo() : Void
	{
		introVidMC.content.alpha = 1;
		introVidMC.content.visible = true;
		introVidMC.content.mouseEnabled = true;
		introVidMC.playVideo();
		resized(null);
	}

	private function introVidDone(e : LoaderEvent) : Void
	{
		outro = new OutroMC();
		this.addChild(outro);
		outro.showLolly();
	}

	private function skipAhead(e : Event) : Void
	{
		if (contentHolder.mouseX < 15 && contentHolder.mouseY < 15)
		{
			introVidMC.gotoVideoTime(introVidMC.videoTime + 10);
		}
		else
		{
			if (introVidMC.videoPaused)
			{
				introVidMC.playVideo();
				TweenMax.resumeAll();
			}
			else
			{
				introVidMC.pauseVideo(null);
				TweenMax.pauseAll();
			}
		}
	}

	private function checkTime(e : LoaderEvent = null) : Void
	{
		var cueXML : Dynamic = null;
		var animFunc : Dynamic = null;
		var list : Dynamic = null;
		var myTime : Float = introVidMC.videoTime;
		if (overlay)
		{
			if (myTime >= stopTime)
			{
				overlay = false;
				currCoords = [];
				wallContainer.graphics.clear();
				currCue = as3hx.Compat.parseInt(currCue + 1);
				mouseCapture.visible = false;
				if (currCue > myXML.nodes.cue.length() - 1)
				{
					trace("-----------STOP ALL");
					startTime = 99999;
				}
				else
				{
					startTime = myXML.nodes.cue.get(currCue).node.start.innerData;
					stopTime = myXML.nodes.cue.get(currCue).node.stop.innerData;
					if (currMC != null)
					{
						currMC.mask = null;
						currMC.visible = false;
					}
				}
			}
			else
			{
				if (currCoords.length > 0)
				{
					drawTrigs([{
						list : currCoords,
						img : currBD
					}], startTime);
				}
			}
		}
		if (!overlay)
		{
			if (myTime >= startTime - 0.02)
			{
				wallContainer.blendMode = "normal";
				overlay = true;
				cueXML = myXML.nodes.cue.get(currCue);
				animFunc = cueXML.anim;
				list = [];
				if (cueXML.att.id == "dropdown")
				{
					currMC = dropDownMC;
					currMC.visible = true;
				}
				else
				{
					if (cueXML.att.id == "upclose")
					{
						currCoords = [];
						list = Std.string(cueXML.topleft).split(",");
						list = list.concat(Std.string(cueXML.topright).split(","));
						list = list.concat(Std.string(cueXML.botright).split(","));
						list = list.concat(Std.string(cueXML.botleft).split(","));
						zoom1MC = new Zoom1MC();
						zoom1MC.addChild(fbpage.zoom1BM);
						zoom1MC.width = 1158;
						zoom1MC.scaleY = zoom1MC.scaleX;
						zoom1MC.alpha = 0.9;
						currMC = zoom1MC;
						currMC.visible = true;
						drawMCWithMask(list, zoom1MC, animFunc);
					}
					else
					{
						if (cueXML.att.id == "map")
						{
							currCoords = [];
							list = Std.string(cueXML.topleft).split(",");
							list = list.concat(Std.string(cueXML.topright).split(","));
							list = list.concat(Std.string(cueXML.botright).split(","));
							list = list.concat(Std.string(cueXML.botleft).split(","));
							mapMC.alpha = 0.7;
							currMC = mapMC;
							currMC.visible = true;
							drawMCWithMask(list, mapMC, animFunc);
						}
						else
						{
							if (cueXML.att.id == "car")
							{
								wallContainer.blendMode = "overlay";
								currCoords = Std.string(cueXML.coords).split(",");
								currBD = carPhotoMC.bd;
								drawTrigs([{
									list : currCoords,
									img : currBD
								}], startTime);
							}
							else
							{
								if (Std.string(cueXML.coords).length == 0)
								{
									currCoords = [];
									list = Std.string(cueXML.topleft).split(",");
									list = list.concat(Std.string(cueXML.topright).split(","));
									list = list.concat(Std.string(cueXML.botright).split(","));
									list = list.concat(Std.string(cueXML.botleft).split(","));
									fbpage.alpha = 0.9;
									currMC = fbpage;
									currMC.visible = true;
									drawMCWithMask(list, fbpage, animFunc);
								}
								else
								{
									currCoords = Std.string(cueXML.coords).split(",");
									currBD = this.facebookPageBD;
									drawTrigs([{
										list : currCoords,
										img : currBD
									}], startTime);
								}
							}
						}
					}
				}
				if (Std.string(cueXML.mouse).length > 0)
				{
					mouseCapture.startTracking(cueXML.mouse);
				}
			}
		}
	}

	private function drawTrigs(drawlist : Array<Dynamic>, timeOffset : Float = 0) : Void
	{
		var coords : Dynamic = null;
		var myImg : Dynamic = null;
		var i : Int = 0;
		var index : Int = as3hx.Compat.parseInt(Math.round((this.introVidMC.videoTime - timeOffset) * 24) * 8);
		if (index == lastIndex)
		{
			return;
		}
		lastIndex = index;
		wallContainer.graphics.clear();
		i = 0;
		while (i < drawlist.length)
		{
			coords = drawlist[i].list;
			myImg = drawlist[i].img;
			vertices = new Array<Float>();
			vertices.push(Reflect.field(coords, Std.string(index)));
			vertices.push(Reflect.field(coords, Std.string(index + 1)));

			vertices.push(Reflect.field(coords, Std.string(index + 2)));
			vertices.push(Reflect.field(coords, Std.string(index + 3)));

			vertices.push(Reflect.field(coords, Std.string(index + 6)));
			vertices.push(Reflect.field(coords, Std.string(index + 7)));

			vertices.push(Reflect.field(coords, Std.string(index + 2)));
			vertices.push(Reflect.field(coords, Std.string(index + 3)));

			vertices.push(Reflect.field(coords, Std.string(index + 4)));
			vertices.push(Reflect.field(coords, Std.string(index + 5)));

			vertices.push(Reflect.field(coords, Std.string(index + 6)));
			vertices.push(Reflect.field(coords, Std.string(index + 7)));

			wallContainer.graphics.beginBitmapFill(myImg, null, false, true);
			wallContainer.graphics.drawTriangles(vertices, null, uvt, "none");
			i++;
		}
	}

	private function drawMCWithMask(coords : Array<Dynamic>, mc : DisplayObject, animFunc : String) : Void
	{
		wallContainer.graphics.clear();
		vertices = new Array<Float>();
		vertices.push(coords[0]);
		vertices.push(coords[1]);

		vertices.push(coords[2]);
		vertices.push(coords[3]);

		vertices.push(coords[6]);
		vertices.push(coords[7]);

		vertices.push(coords[2]);
		vertices.push(coords[3]);

		vertices.push(coords[4]);
		vertices.push(coords[5]);

		vertices.push(coords[6]);
		vertices.push(coords[7]);

		wallContainer.graphics.beginBitmapFill(dummyBD, null, false, true);
		wallContainer.graphics.drawTriangles(vertices, null, uvt, "none");
		wallHolder.addChild(mc);
		wallHolder.setChildIndex(this.mouseCapture, wallHolder.numChildren - 1);
		mc.visible = true;
		mc.mask = wallContainer;
		mc.x = coords[0];
		mc.y = coords[1];
		Reflect.field(mc, animFunc)();
	}

	private function gotFBPerms(event : Event = null) : Void
	{
		TweenMax.to(coverSprite, 0.3, {
			autoAlpha : 0,
			overwrite : true
		});
		TweenMax.to(lolly.mc_connect, 0.2, {
			autoAlpha : 0
		});
		this.dispatchEvent(new Event("fbclicked"));
	}

	private function cancelledPerms(event : Event) : Void
	{
		TweenMax.to(coverSprite, 0.3, {
			autoAlpha : 0,
			overwrite : true
		});
		TweenMax.to(lolly.mc_connect, 0.2, {
			autoAlpha : 1
		});
		lolly.mouseEnabled = true;
		ExternalInterface.call("_gaq.push", ["_trackEvent", "event", "button", "fbcancel"]);
	}

	private function gettingFBPerms(event : Event) : Void
	{
	}

	public function doneInit(response : Dynamic, fail : Dynamic) : Void
	{
		if (Facebook.getAuthResponse().uid == null)
		{
			UserObj.getInstance().facebookID = Facebook.getAuthResponse().uid;
			UserObj.getInstance().userID = UserObj.getInstance().facebookID;
		}
		trace("done init=" + response);
		var _loc5_ : Int = 0;
		var _loc4_ : Dynamic = response;
		for (i in Reflect.fields(response))
		{
			trace(i + ":" + response);
		}
	}

	private function gotFault(e : IOErrorEvent) : Void
	{
		trace("error=" + e.text);
	}

	public function debug(msg : String) : Void
	{
	}

	public function restart() : Void
	{
		introVidMC.gotoVideoTime(0);
		introVidMC.content.visible = false;
		startTime = myXML.nodes.cue.get(0).node.start.innerData;
		stopTime = myXML.nodes.cue.get(0).node.stop.innerData;
		overlay = false;
		currCue = 0;
		lolly.mouseEnabled = true;
		lolly.removeEventListener("click", fbClicked);
		lolly.addEventListener("click", startVideoAgain);
		this.dispatchEvent(new Event("reset"));
		TweenMax.to(lolly, 0.4, {
			autoAlpha : 1,
			delay : 0.6
		});
	}

	private function startVideoAgain(event : MouseEvent) : Void
	{
		introVidMC.playVideo(null);
		introVidMC.content.alpha = 1;
		introVidMC.content.visible = true;
		TweenMax.to(lolly, 0.4, {
			autoAlpha : 0,
			delay : 0.6
		});
		this.dispatchEvent(new Event(Main.DONE_BUILD));
	}
}

