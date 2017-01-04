package priori.view;

import priori.geom.PriGeomPoint;
import helper.browser.DomHelper;
import js.html.Window;
import js.Browser;
import js.html.DOMRect;
import priori.geom.PriGeomBox;
import helper.browser.BrowserEventEngine;
import js.html.Element;
import jQuery.Event;
import jQuery.JQuery;
import priori.style.border.PriBorderStyle;
import priori.style.shadow.PriShadowStyle;
import priori.style.filter.PriFilterStyle;
import priori.event.PriEvent;
import priori.event.PriSwipeEvent;
import priori.event.PriTapEvent;
import priori.view.container.PriContainer;
import priori.event.PriEventDispatcher;
import priori.app.PriApp;

class PriDisplay extends PriEventDispatcher {

    /**
    * Indicates the width of the PriDisplay object, in pixels. The scale or inner children are not affected.
    * If you set `null`, the PriDisplay object try to get the width of inner elements.
    *
    * `default value : 100`
    **/
    public var width(get, set):Float;

    /**
    * Indicates the width of the PriDisplay object, in pixels, after the scaleX effect applied.
    *
    * If you set a value for this property, the scaleX will change to render the object with the desired value.
    *
    **/
    public var widthScaled(get, set):Float;

    /**
    * Indicates the height of the PriDisplay object, in pixels. The scale or inner children are not affected.
    * If you set `null`, the PriDisplay object try to get the height of inner elements.
    *
    * `default value : 100`
    **/
    public var height(get, set):Float;

    /**
    * Indicates the height of the PriDisplay object, in pixels, after the scaleY effect applied.
    *
    * If you set a value for this property, the scaleY will change to render the object with the desired value.
    *
    **/
    public var heightScaled(get, set):Float;

    /**
    * Indicates the `x` coordinate of the PriDisplay instance relative to the local coordinates of the parent PriContainer.
    * The object's coordinates refer to the left most point.
    *
    * `default value : 0`
    **/
    public var x(get, set):Float;

    /**
    * Indicates the `y` coordinate of the PriDisplay instance relative to the local coordinates of the parent PriContainer.
    * The object's coordinates refer to the element´s top most point.
    *
    * `default value : 0`
    **/
    public var y(get, set):Float;

    public var centerX(get, set):Float;
    public var centerY(get, set):Float;
    public var maxX(get, set):Float;
    public var maxY(get, set):Float;

    public var parent(get, null):PriContainer;
    public var visible(get, set):Bool;

    public var disabled(get, set):Bool;
    private var _disabled:Bool = false;

    public var mouseEnabled(get, set):Bool;
    public var pointer(get, set):Bool;
    public var clipping(get, set):Bool;

    public var rotation(get, set):Float;


    /**
    * Indicates the alpha transparency value of the object specified.
    * Valid values are 0(fully transparent) to 1(fully opaque).
    *
    * `default value : 1`
    **/
    public var alpha(get, set):Float;
    private var _alpha:Float = 1;

    @:isVar public var corners(default, set):Array<Int>;
    @:isVar public var tooltip(default, set):String;

    @:isVar public var bgColor(default, set):Int;


    // STYLES PROPERTIES

    @:isVar public var border(default, set):PriBorderStyle;
    @:isVar public var shadow(default, set):Array<PriShadowStyle>;

    /**
    * Defines visual effects for the object.
    *
    * `default value : null`
    **/
    @:isVar public var filter(default, set):PriFilterStyle;


    public var anchorX(get, set):Float;
    public var anchorY(get, set):Float;

    private var _anchorX:Float = 0.5;
    private var _anchorY:Float = 0.5;
    private var _rotation:Float = 0;
    private var _scaleX:Float = 1;
    private var _scaleY:Float = 1;

    private var ___x:Float = 0;
    private var ___y:Float = 0;
    private var ___width:Float = 100;
    private var ___height:Float = 100;
    private var ___clipping:Bool = true;
    private var ___depth:Int = 1000;
    private var ___pointer:Bool = false;

    /**
    * Indicates the horizontal scale (percentage) of the object as applied from the anchorX point.
    *
    * This property only affects the rendering of the object, not the width itself. If you need to get the
    * scaled width, use the property `widthScaled`.
    *
    * `default value : 1`
    **/
    public var scaleX(get, set):Float;

    /**
    * Indicates the vertical scale (percentage) of the object as applied from the anchorY point.
    *
    * This property only affects the rendering of the object, not the height itself. If you need to get the
    * scaled height, use the property `heightScaled`.
    *
    * `default value : 1`
    **/
    public var scaleY(get, set):Float;

    private var _priId:String;
    private var _element:JQuery;
    private var _elementBorder:JQuery;
    private var _jselement:Element;

    private var _parent:PriContainer;

    private var __eventHelper:BrowserEventEngine;

    public function new() {
        super();

        // initialize display
        this._priId = this.getRandomId();
        this.createElement();

        this.__eventHelper = new BrowserEventEngine();
        this.__eventHelper.jqel = this._element;
        this.__eventHelper.jsel = this._jselement;
        this.__eventHelper.display = this;
        this.addEventListener(PriEvent.ADDED_TO_APP, this.__eventHelper.onAddedToApp);

        this.addEventListener(PriEvent.ADDED, __onAdded);
    }

    private function __onAdded(e:PriEvent):Void {
        this.updateDepth();
        this.updateBorderDisplay();
    }

    private function set_corners(value:Array<Int>):Array<Int> {
        this.corners = value;

        if (value == null) {
            this.getElement().css("border-radius", "");
        } else {

            var tempArray:Array<Int> = value.copy();

            var n:Int = tempArray.length;

            if (n == 0) {
                this.getElement().css("border-radius", "");
            } else {
                if (n > 4) tempArray = tempArray.splice(0, 4);

                this.getElement().css("border-radius", tempArray.join("px ") + "px");
            }
        }


        return value;
    }

    private function set_tooltip(value:String):String {
        this.tooltip = value;
        this.getElement().attr("title", value == "" ? null : value);
        return value;
    }

    private function set_border(value:PriBorderStyle):PriBorderStyle {
        this.border = value;

        if (value == null) {
            removeBorder();
        } else {
            applyBorder();
        }

        return value;
    }

    private function set_shadow(value:Array<PriShadowStyle>):Array<PriShadowStyle> {
        this.shadow = value;

        var shadowString:String = "";
        if (value != null && value.length > 0) shadowString = value.join(",");

        this.setCSS("-webkit-box-shadow", shadowString);
        this.setCSS("-moz-box-shadow", shadowString);
        this.setCSS("-o-box-shadow", shadowString);
        this.setCSS("box-shadow", shadowString);

        return value;
    }

    private function set_filter(value:PriFilterStyle):PriFilterStyle {
        this.filter = value;

        var filterString:String = "";
        if (value != null) filterString = value.toString();

        this.setCSS("-webkit-filter", filterString);
        this.setCSS("-ms-filter", filterString);
        this.setCSS("-o-filter", filterString);
        this.setCSS("filter", filterString);

        return value;
    }

    private function applyBorder():Void {
        if (this._elementBorder == null) {
            this._elementBorder = new JQuery('<div style="
                box-sizing:border-box !important;
                position:absolute;
                width:inherit;
                height:inherit;
                pointer-events:none;"></div>');

            this.getElement().append(this._elementBorder);

            this.addEventListener(PriEvent.SCROLL, onScrollUpdateBorder);
        }

        this._elementBorder.css("border", this.border.toString());

        this.updateBorderDisplay();
    }

    private function onScrollUpdateBorder(e:PriEvent):Void {
        this.updateBorderDisplay();
    }

    private function updateBorderDisplay():Void {
        if (this._elementBorder != null) {
            this._elementBorder.css("top", this.getElement().scrollTop() + "px");
            this._elementBorder.css("left", this.getElement().scrollLeft() + "px");
            this._elementBorder.css("border-radius", this.getElement().css("border-radius"));
            this._elementBorder.css("z-index", this.getElement().css("z-index"));
        }
    }

    private function removeBorder():Void {
        if (_elementBorder != null) {
            this.removeEventListener(PriEvent.SCROLL, onScrollUpdateBorder);

            this._elementBorder.remove();
            this._elementBorder = null;
        }
    }

    private function get_clipping():Bool return this.___clipping;
    private function set_clipping(value:Bool) {
        if (value) {
            this.___clipping = true;
            this._jselement.style.overflow = "hidden";
        } else {
            this.___clipping = false;
            this._jselement.style.overflow = "";
        }

        return value;
    }

    private function getRandomId(len:Int = 7):String {
        var length:Int = len;
        var charactersToUse:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var result:String = "";

        result = "";

        for (i in 0...length) {
            result += charactersToUse.charAt(Math.floor((charactersToUse.length * Math.random())));
        }

        result += "_" + Date.now().getTime();

        return result;
    }

    private function getOutDOMDimensions():{w:Float, h:Float} {
        var w:Float = 0;
        var h:Float = 0;

        var clone:JQuery = this._element.clone(false);

        var body:JQuery = new JQuery("body");
        body.append(clone);

        w = clone.width();
        h = clone.height();

        clone.remove();

        clone = null;

        return {
            w : w,
            h : h
        };
    }

    private function get_widthScaled():Float return this.width*this._scaleX;
    private function set_widthScaled(value:Float):Float {
        this.scaleX = value / this.width;
        return value;
    }

    private function get_heightScaled():Float return this.height*this._scaleY;
    private function set_heightScaled(value:Float):Float {
        this.scaleY = value / this.height;
        return value;
    }

    private function set_width(value:Float) {
        if (value == null) {
            this.___width = null;
            this._jselement.style.width = "";
        } else {
            this.___width = Math.max(0, value);
            this._jselement.style.width = this.___width + "px";
        }

        return value;
    }

    private function get_width():Float {
        var result:Float = this.___width;

        if (result == null) {
            result = this._element.width();
            if (result == 0 && !this.hasApp()) result = this.getOutDOMDimensions().w;
        }

        return result;
    }

    private function set_height(value:Float):Float {
        if (value == null) {
            this.___height = null;
            this._jselement.style.height = "";
        } else {
            this.___height = Math.max(0, value);
            this._jselement.style.height = this.___height + "px";
        }

        return value;
    }

    private function get_height():Float {
        var result:Float = this.___height;

        if (result == null) {
            result = this._element.height();
            if (result == 0 && !this.hasApp()) result = this.getOutDOMDimensions().h;
        }
        return result;
    }


    private function set_maxX(value:Float) {
        this.x = value - this.width;
        return value;
    }

    private function set_maxY(value:Float) {
        this.y = value - this.height;
        return value;
    }

    private function set_centerX(value:Float) {
        this.x = value - this.width/2;
        return value;
    }

    private function set_centerY(value:Float) {
        this.y = value - this.height/2;
        return value;
    }

    private function set_x(value:Float) {
        this.___x = value;
        this._jselement.style.left = value + "px";
        return value;
    }


    private function set_y(value:Float) {
        this.___y = value;
        this._jselement.style.top = value + "px";
        return value;
    }

    private function get_x():Float return this.___x;
    private function get_y():Float return this.___y;
    private function get_maxX():Float return this.x + this.width;
    private function get_maxY():Float return this.y + this.height;
    private function get_centerX():Float return this.x + this.width/2;
    private function get_centerY():Float return this.y + this.height/2;

    private function get_scaleX():Float return this._scaleX;
    private function set_scaleX(value:Float):Float {
        this._scaleX = value == null ? 1 : value;
        this.__applyMatrixTransformation();
        return value;
    }

    private function get_scaleY():Float return this._scaleY;
    private function set_scaleY(value:Float):Float {
        this._scaleY = value == null ? 1 : value;
        this.__applyMatrixTransformation();
        return value;
    }

    private function get_anchorX():Float return this._anchorX;
    private function set_anchorX(value:Float):Float {
        this._anchorX = value == null ? 0 : value;
        this.__applyMatrixTransformation();
        return value;
    }

    private function get_anchorY():Float return this._anchorY;
    private function set_anchorY(value:Float):Float {
        this._anchorY = value == null ? 0 : value;
        this.__applyMatrixTransformation();
        return value;
    }

    private function get_rotation():Float return this._rotation;
    private function set_rotation(value:Float):Float {
        this._rotation = value == null ? 0 : value;
        this.__applyMatrixTransformation();
        return value;
    }

    private function __applyMatrixTransformation():Void {

        /* matrix reference */
        // SCALE
        // x 0 0
        // 0 y 0
        // 0 0 1

        // ROTATE
        // cosX -sinX   0
        // sinX  cosX   0
        //  0     0     1

        var rot:Float = this._rotation*-1;
        var sx:Float = this._scaleX;
        var sy:Float = this._scaleY;

        var anchorX:Float = this._anchorX*100;
        var anchorY:Float = this._anchorY*100;

        var valOrigin:String = '';
        var valMatrix:String = '';

        if ((sx != 1 || sy != 1) && rot == 0) {

            valOrigin = '$anchorX% $anchorY%';
            valMatrix = 'matrix($sx, 0, 0, $sy, 0, 0)';

        } else if (sx != 1 || sy != 1 || rot != 0) {

            var angle:Float = rot * (Math.PI/180);
            var aSin:Float = Math.sin(angle);
            var aCos:Float = Math.cos(angle);

            var m1:Array<Array<Float>> = [[aCos, -aSin, 0], [aSin, aCos, 0], [0, 0, 1]];
            var m2:Array<Array<Float>> = [[sx, 0, 0], [0, sy, 0], [0, 0, 1]];

            var calc:Int->Int->Float = function(row:Int, col:Int):Float {
                return (
                    m1[row][0] * m2[0][col] +
                    m1[row][1] * m2[1][col] +
                    m1[row][2] * m2[2][col]
                );
            }

//            var m3:Array<Array<Float>> = [
//                [calc(0, 0), calc(0, 1), calc(0, 2)],
//                [calc(1, 0), calc(1, 1), calc(1, 2)],
//                [calc(2, 0), calc(2, 1), calc(2, 2)]
//            ];

            valOrigin = '$anchorX% $anchorY%';
            valMatrix = 'matrix(${calc(0, 0)}, ${calc(1, 0)}, ${calc(0, 1)}, ${calc(1, 1)}, ${calc(0, 2)}, ${calc(1, 2)})';
        }

        this.setCSS("-ms-transform-origin", valOrigin);
        this.setCSS("-webkit-transform-origin", valOrigin);
        this.setCSS("transform-origin", valOrigin);

        this.setCSS("-ms-transform", valMatrix);
        this.setCSS("-webkit-transform", valMatrix);
        this.setCSS("transform", valMatrix);
    }

    private function get_alpha():Float return this._alpha;
    private function set_alpha(value:Float) {
        this._alpha = value;
        if (this._alpha == 1) this.setCSS("opacity", "");
        else this.setCSS("opacity", Std.string(value));
        return value;
    }

    public function hasApp():Bool {
        var app:PriApp = PriApp.g();
        var tree:Array<PriDisplay> = this.getTreeList();

        if (tree[tree.length - 1] == app) return true;

        return false;
    }

    private function get_parent():PriContainer {
        return this._parent;
    }

    public function getPrid():String {
        return this._priId;
    }

    private function updateDepth():Void {
        this.___depth = this._parent.___depth - 1;
        this._jselement.style.zIndex = Std.string(this.___depth);

        if (this._elementBorder != null) this._elementBorder.css("z-index", this.___depth);

    }

    public function getJSElement():Element {
        return _jselement;
    }

    public function getElement():JQuery {
        return this._element;
    }

    private function setCSS(property:String, value:String):Void this._element.css(property, value);
    private function getCSS(property:String):String return this.getElement().css(property);

    private function set_bgColor(value:Int):Int {
        this.bgColor = value;

        if (value == null) {
            this._jselement.style.backgroundColor = "";
        } else {
            this._jselement.style.backgroundColor = "#" + StringTools.hex(value, 6);
        }

        return value;
    }

    override public function addEventListener(event:String, listener:Dynamic->Void):Void {

        this.__eventHelper.registerEvent(event);


        if (event == PriTapEvent.TAP) {
            this.pointer = true;
        }

        super.addEventListener(event, listener);
    }

    override public function removeEventListener(event:String, listener:Dynamic->Void):Void {
        super.removeEventListener(event, listener);

        if (event == PriTapEvent.TAP && this.hasEvent(PriTapEvent.TAP) == false) {
            this.pointer = false;
        }
    }

    private function createElement():Void {
        
        var jsElement:Element = js.Browser.document.createElement("div");
        jsElement.setAttribute("prioriid", this._priId);
        jsElement.id = this._priId;
        jsElement.className = "priori_stylebase";
        jsElement.style.cssText = 'left:0px;top:0px;width:${___width}px;height:${___height}px;overflow:hidden;';

        this._jselement = jsElement;
        this._element = new JQuery(jsElement);

    }

    public function removeFromParent():Void {
        if (this._parent != null) {
            this._parent.removeChild(this);
        }
    }

    override public function kill():Void {
        this.__eventHelper.kill();

        // remove todos os eventos do elemento
        this.getElement().off();
        this.getElement().find("*").off();

        super.kill();
    }

    private function get_visible():Bool {
        if (this.getCSS("visibility") == "hidden") return false;
        return true;
    }

    private function set_visible(value:Bool) {
        if (value == true) {
            this.setCSS("visibility", "");
        } else {
            this.setCSS("visibility", "hidden");
        }

        return value;
    }

    private function get_pointer():Bool return this.___pointer;
    private function set_pointer(value:Bool) {
        if (value == true) {
            this.___pointer = true;
            this._jselement.style.cursor = "pointer";
        } else {
            this.___pointer = false;
            this._jselement.style.cursor = "";
        }

        return value;
    }


    private function get_mouseEnabled():Bool {
        return (this.getElement().css("pointer-events") != "none");
    }

    private function set_mouseEnabled(value:Bool):Bool {
        if (!value) {
            this.getElement().css("pointer-events", "none");
        } else {
            this.getElement().css("pointer-events", "");
        }

        return value;
    }


    public function hasDisabledParent():Bool {
        if (this.parent != null) {
            if (this.parent.disabled) return true;
            else if (this.parent.hasDisabledParent()) return true;
        }
        return false;
    }

    private function get_disabled():Bool {
        if (this._disabled || this._jselement.hasAttribute("disabled")) return true;
        return false;
    }

    private function set_disabled(value:Bool) {
        this._disabled = value;

        if (value) {
            this._jselement.setAttribute("priori-disabled", "disabled");
            DomHelper.disableAll(this._jselement);
        } else {
            this._jselement.removeAttribute("priori-disabled");

            if (!this.hasDisabledParent()) {
                DomHelper.enableAllUpPrioriDisabled(this._jselement);
            }
        }

        return value;
    }


    public function getGlobalBox():PriGeomBox {
        var result:PriGeomBox = new PriGeomBox();

        if (this.hasApp()) {
            if (this._jselement.getBoundingClientRect != null) {
                var box:DOMRect = this._jselement.getBoundingClientRect();

                var body:Element = Browser.document.body;
                var docElem:Element = Browser.document.documentElement;
                var window:Window = Browser.window;

                var scrollTop:Int =
                    window.pageYOffset != null ? window.pageYOffset :
                    docElem.scrollTop != null ? docElem.scrollTop : body.scrollTop;

                var scrollLeft:Int =
                    window.pageXOffset != null ? window.pageXOffset :
                    docElem.scrollLeft != null ? docElem.scrollLeft : body.scrollLeft;

                var clientTop:Int =
                    docElem.clientTop != null ? docElem.clientTop :
                    body.clientTop != null ? body.clientTop : 0;

                var clientLeft:Int =
                    docElem.clientLeft != null ? docElem.clientLeft :
                    body.clientLeft != null ? body.clientLeft : 0;

                var top:Int  = Std.int(box.top +  scrollTop - clientTop);
                var left:Int = Std.int(box.left + scrollLeft - clientLeft);

                result.x = Math.fround(left);
                result.y = Math.fround(top);
            } else {
                var el:Element = this._jselement;

                var top:Int = 0;
                var left:Int = 0;

                while (el != null) {
                    top += el.offsetTop;
                    left += el.offsetLeft;

                    el = el.offsetParent;
                }

                result.x = top;
                result.y = top;
            }
        }

        result.width = this.width;
        result.height = this.height;

        return result;
    }


    public function getTreeList():Array<PriDisplay> {
        var result:Array<PriDisplay> = [];

        result.push(this);

        var p:PriDisplay = this.parent;

        while(p != null) {
            result.push(p);
            p = p.parent;
        }

        return result;
    }

    public function globalToLocal(point:PriGeomPoint):PriGeomPoint {
        var result:PriGeomPoint = point.clone();
        var list:Array<PriDisplay> = this.getTreeList();

        list.reverse();

        for (i in 0 ... list.length) {
            var el:PriDisplay = list[i];

            result.x -= el.x;
            result.y -= el.y;

        }

        return result;
    }

}
