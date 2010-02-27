//author Show=O=Healer
package{
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.filters.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class HintMessage{
		//=Const=

		//枠の大きさ
		static public const FRAME_W:int = 380;//432;
		static public const FRAME_H:int = 32;

		//文字の大きさ
		static public const TEXT_W:int = 13;//16;

		//=Singleton=

		private static var m_StaticInstance:HintMessage = new HintMessage();

		static public function Instance():HintMessage{
			return m_StaticInstance;
		}


		//=Message=

		private var m_Message:String = "";

		//Show
		public function PushMessage(i_Message:String):void{
			m_Message = i_Message;

			m_TextField.htmlText = "<font face='system' size='"+TEXT_W.toString()+"'>" + m_Message + "</font>";
			m_TextField.textColor = 0x000000;
		}

		//Hide
		public function PopMessage(i_Message:String):void{
			if(m_Message == i_Message){
				m_Message = "マウスを合わせたものの内容がここに表示されます";

				m_TextField.htmlText = "<font face='system' size='"+TEXT_W.toString()+"'>" + m_Message + "</font>";
				m_TextField.textColor = 0x888888;
			}
		}


		//=Image=

		private var m_Image:Image;
		private var m_TextField:TextField = new TextField();

		public function GetImage():Image{
			//まだ作ってなかったら今作る
			if(! m_Image){
				m_Image = new Image();
				{
					//Shape : 枠
					{
						var shape:Shape = new Shape();
						var g:Graphics = shape.graphics;

						const line_w:int = 3;
						const line_color:uint = 0x444444;
						const line_alpha:Number = 0.2;
						const line_hinting:Boolean = true;
						const line_scale_mode:String = "normal";
						const line_caps:String = "round";
						const line_joints:String = "round";

						const fill_color:uint = 0xFFFFFF;
						const fill_alpha:Number = 0.9;

						const round_rad:uint = 10;

						g.lineStyle(line_w, line_color, line_alpha, line_hinting, line_scale_mode, line_caps, line_joints);

						g.beginFill(fill_color, fill_alpha);
//						g.drawRect(line_w, line_w, FRAME_W-2*line_w, FRAME_H-2*line_w);
						g.drawRoundRect(line_w, line_w, FRAME_W-2*line_w, FRAME_H-2*line_w, round_rad);
						g.endFill();

						m_Image.addChild(shape);
					}

					//TextField : 文字
					{
						m_TextField.border = false;
						m_TextField.selectable = false;
						m_TextField.autoSize = TextFieldAutoSize.LEFT;
						m_TextField.embedFonts = true;

						m_TextField.x = FRAME_H/2 - TEXT_W/2;
						m_TextField.y = FRAME_H/2 - TEXT_W;

						//何もカーソルを合わせてない状態に強制設定
						PushMessage("");
						PopMessage("");

						m_Image.addChild(m_TextField);
					}
				}
			}

			return m_Image;
		}
	}
}

