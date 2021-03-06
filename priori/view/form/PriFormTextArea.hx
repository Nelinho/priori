package priori.view.form;

import priori.app.PriApp;
import js.jquery.Event;
import js.JQuery;
import priori.event.PriEvent;

class PriFormTextArea extends PriFormElementBase {

    @:isVar public var value(get, set):String;
    @:isVar public var placeholder(default, set):String;

    @:isVar public var margin(default, set):Float = 0;

    public function new() {
        super();

        this.placeholder = "";
        this.clipping = false;
    }

    private function set_margin(value:Float):Float {
        this.margin = value;

        this._baseElement.css("padding", value);

        return value;
    }

    override public function getComponentCode():String {
        return "<textarea style=\"width:100%;height:100%;resize:none;box-sizing:border-box;\"></textarea>";
    }

    override private function onAddedToApp():Void {
        PriApp.g().getBody().on("textarea", "[id=" + this.fieldId + "]", this._onChange);
    }

    override private function onRemovedFromApp():Void {
        PriApp.g().getBody().off("textarea", "[id=" + this.fieldId + "]", this._onChange);
    }

    @:noCompletion private function _onChange(event:Event):Void {
        this.dispatchEvent(new PriEvent(PriEvent.CHANGE));
    }

    @:noCompletion private function set_value(value:String):String {
        this.value = value;
        this._baseElement.val(value);

        return value;
    }

    @:noCompletion private function get_value():String {
        var result:String = this.value;

        var isDisabled:Bool = this.disabled;
        if (isDisabled) this.suspendDisabled();

        result = this._baseElement.val();

        if (isDisabled) this.reactivateDisable();

        return result;
    }

    @:noCompletion private function set_placeholder(value:String):String {
        this.placeholder = value;

        this._baseElement.attr("placeholder", value);

        return value;
    }

}
