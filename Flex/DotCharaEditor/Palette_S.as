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

	public class Palette_S extends IPalette
	{
		override public function GetInfoKeyName_X():String{return "S";}

		//
		override public function calc_color(in_BaseColor:uint, in_Ratio:Number):uint{
			var ratio:Number = 1 - in_Ratio;

			//外部から設定された色
			var r_ori:uint = (in_BaseColor >> 16) & 0xFF;
			var g_ori:uint = (in_BaseColor >>  8) & 0xFF;
			var b_ori:uint = (in_BaseColor >>  0) & 0xFF;

			//色の大きさ
			var ori_len:Number = (new Vector3D(r_ori, g_ori, b_ori)).length;
			var dst_val:uint = ori_len / Math.sqrt(3);

			//同じ大きさの灰色
			var r_dst:uint = dst_val;
			var g_dst:uint = dst_val;
			var b_dst:uint = dst_val;

			var r:uint = lerp(r_ori, r_dst, ratio);
			var g:uint = lerp(g_ori, g_dst, ratio);
			var b:uint = lerp(b_ori, b_dst, ratio);

			var color:uint = 0xFF000000 | (r << 16) | (g << 8) | (b << 0);

			return color;
		}
	}
}

