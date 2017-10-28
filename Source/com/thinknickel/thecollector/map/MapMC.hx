package com.thinknickel.thecollector.map;

import assets.McMap;
//import com.google.maps.LatLng;
//import com.google.maps.Map;
//import com.google.maps.MapType;
//import com.google.maps.controls.MapTypeControl;
//import com.google.maps.controls.PositionControl;
//import com.google.maps.controls.ZoomControl;
//import com.google.maps.interfaces.IPolyline;
//import com.google.maps.overlays.Marker;
//import com.google.maps.overlays.MarkerOptions;
//import com.google.maps.services.ClientGeocoder;
//import com.google.maps.services.Directions;
//import com.google.maps.services.DirectionsEvent;
//import com.google.maps.services.GeocodingEvent;
//import com.greensock.TweenMax;
import com.thinknickel.thecollector.UserObj;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;

class MapMC extends Sprite
{
    
    
    private static inline var apikey : String = "d605f8896dfdb9305317eef7f6c82645";
    
    private var map : Map;
    
    private var geocoder : ClientGeocoder;
    
    private var streetaddress : String;
    
    private var city : String;
    
    private var state : String;
    
    private var fulladdress : String;
    
    private var latlong : LatLng;
    
    private var bk : McMap;
    
    private var startLatLng : LatLng;
    
    private var endLatLng : LatLng;
    
    private var polyline : IPolyline;
    
    private var returnedDirection : Directions;
    
    private var startPoint : LatLng;
    
    public function new()
    {
        super();
        bk = new McMap();
        this.addChild(bk);
        var fbloc : Dynamic = UserObj.getInstance().location;
        if (fbloc == null)
        {
            getGeoLocation();
        }
        else
        {
            if (fbloc.city != null)
            {
                city = fbloc.city;
                state = fbloc.state;
                getAddress(city, state);
            }
            else
            {
                getGeoLocation();
            }
        }
        this.blendMode = "multiply";
        this.alpha = 0.8;
        ExternalInterface.addCallback("gotLoc", gotIPLoc);
    }
    
    private static function gotError(event : IOErrorEvent) : Void
    {
    }
    
    private static function onIOError(event : IOErrorEvent) : Void
    {
        trace("IO Error sending to server=" + event.text);
    }
    
    private function getGeoLocation() : Void
    {
        trace("trying to get location");
        ExternalInterface.call("getLoc");
    }
    
    private function gotIPLoc(info : Dynamic) : Void
    {
        trace("info=" + info.city.names.en);
        trace("state=" + info.subdivisions[0].names.en);
        city = info.city.names.en;
        state = info.subdivisions[0].names.en;
        getAddress(city, state);
    }
    
    private function gotIPLoc2(e : Event) : Void
    {
        var result : String = e.target.data;
        city = result.split(",")[2];
        state = result.split(",")[1];
        getAddress(city, state);
    }
    
    private function getAddress(city : String, state : String) : Void
    {
        fulladdress = city + ", " + state;
        map = new Map();
        map.x = 376;
        map.y = 65;
        map.key = Main.getInstance().googleapi;
        map.setSize(new Point(903, 641));
        map.addEventListener("mapevent_mapready", onMapReady);
        this.addChild(map);
        map.addControl(new ZoomControl());
        map.addControl(new PositionControl());
        map.addControl(new MapTypeControl());
        this.addChildAt(map, 0);
    }
    
    public function onMapReady(event : Event) : Void
    {
        this.geocoder = new ClientGeocoder();
        this.geocoder.addEventListener("geocodingsuccess", onGeocodingSuccess);
        this.geocoder.addEventListener("geocodingfailure", onGeocodingFailure);
        geocoder.geocode(fulladdress);
        map.setCenter(new LatLng(42.228517, -98.876953), 4, MapType.NORMAL_MAP_TYPE);
    }
    
    private function onGeocodingSuccess(event : GeocodingEvent) : Void
    {
        startPoint = event.response.placemarks[0].point;
        latlong = event.response.placemarks[0].point;
        getDirections();
    }
    
    private function showStart() : Void
    {
        map.setCenter(startPoint, 15, MapType.NORMAL_MAP_TYPE);
        var marker : Marker = new Marker(startPoint, new MarkerOptions({
            fillRGB : 16384,
            name : UserObj.getInstance().senderFName + " " + UserObj.getInstance().senderLName,
            description : fulladdress
        }));
        map.addOverlay(marker);
    }
    
    public function animationmap() : Void
    {
        this.visible = true;
        trace("ANIMATINGMAP");
        var typing : Typing = new Typing(bk.txt_address, fulladdress);
        TweenMax.delayedCall(1, showStart);
        TweenMax.delayedCall(2, showDirections);
    }
    
    private function getDirections() : Void
    {
        var dir : Directions = new Directions();
        var endLatLng2 : LatLng = new LatLng(latlong.lat() - 0.001, latlong.lng() - 0.002);
        dir.addEventListener("directionssuccess", onDirectionsLoaded);
        dir.addEventListener("directionsfailure", onDirectionsFailed);
        dir.load(Std.string(endLatLng2.lat()) + "," + Std.string(endLatLng2.lng()) + " to " + Std.string(latlong.lat()) + "," + Std.string(latlong.lng()));
    }
    
    private function onDirectionsFailed(event : DirectionsEvent) : Void
    {
        trace("directions failed");
    }
    
    private function onDirectionsLoaded(event : DirectionsEvent) : Void
    {
        returnedDirection = event.directions;
        startLatLng = latlong;
        endLatLng = returnedDirection.getRoute(returnedDirection.numRoutes - 1).endLatLng;
        trace("endLatLng=" + endLatLng);
        polyline = returnedDirection.createPolyline();
    }
    
    private function showDirections() : Void
    {
        map.clearOverlays();
        map.addOverlay(polyline);
        map.addOverlay(new Marker(startLatLng));
        map.addOverlay(new Marker(endLatLng));
        map.setCenter(returnedDirection.bounds.getCenter(), map.getBoundsZoomLevel(returnedDirection.bounds));
    }
    
    private function onGeocodingFailure(event : GeocodingEvent) : Void
    {
        trace("Geocoding error. Try to refresh the page or another search " + event);
    }
}

