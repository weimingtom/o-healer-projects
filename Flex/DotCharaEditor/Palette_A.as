//author Show=O=Healer

/*
*/


package{
	//
	import flash.display.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class Palette_A extends IPalette
	{
		override public function GetInfoKeyName_X():String{return "A";}
		override public function IsUseBackgroundAnim():Boolean{return true;}

		//
		override public function calc_color(in_BaseColor:uint, in_Ratio:Number):uint{
			var a:uint = 0xFF * in_Ratio;
			var color:uint = (a << 24) | (in_BaseColor & 0x00FFFFFF);

			return color;
		}
	}
}

