//author Show=O=Healer
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

	public class Tab_Hint extends ITab
	{
		//==Const==

		static public const PANEL_W:int = 32 * 2;
		static public const PANEL_H:int = 32 * 2;

		public const HINT_MESSAGE:Array = [
			"Oを押すとそこにあるものを削除します",//O:空白
			"Wを押すと壁をセットします",//W:地形
			"Pを押したところがプレイヤーの初期位置になります",//P:プレイヤー位置（生成後は空白として扱われる）
			"Gを押したところがゴールの位置になります",//G:ゴール位置（基本的には空白として扱われる）
			"Qを押すと動かせるブロックをセットします",//Q:動かせるブロック（生成後は空白として扱われる）
			"Sを押すと切り替えスイッチをセットします",//S:赤青ブロック用の切り替えスイッチ
			"Rを押すと赤ブロックをセットします",//R:赤ブロック
			"Bを押すと青ブロックをセットします",//B:青ブロック
			"TEST",
			"TEST",
			"TEST",
			"TEST",
			"TEST",
			"TEST",
			"TEST",
		];

		//==Function==

		//Init
		public function Tab_Hint(){
			//Tab
			{
				super("対応表", 0x00FF00);
			}

			//Content
			{
/*
				const CONTENT_NORMAL:Array = [
					Game.O,
					Game.W,
					Game.P,
					Game.G,
					Game.Q,
					Game.S,
					Game.R,
					Game.B,
				];
/*/
				//
				const TYPE_L:int = 0;
				const TYPE_R:int = 1;
				const TYPE_C:int = 2;

				const CONTENT_PARAM:Array = [
					[Game.O, TYPE_L], [Game.P, TYPE_R],
					[Game.W, TYPE_L], [Game.G, TYPE_R],
					[Game.Q, TYPE_L], [Game.S, TYPE_R],
					[Game.R, TYPE_L], [Game.B, TYPE_R],
					[Game.C, TYPE_L], [Game.V, TYPE_R],
					[Game.SET_RANGE, TYPE_C],
					[Game.SET_DIR, TYPE_C],
				];

				var x:int = 0;
				var y:int = 0;
				var w:int = PANEL_W;//32 * 3;
				var h:int = PANEL_H;//32 + 4;
				for(var i:int = 0; i < CONTENT_PARAM.length; i += 1){
					var map:int  = CONTENT_PARAM[i][0];
					var type:int = CONTENT_PARAM[i][1];

					//Pre
					{
						switch(type){
						case TYPE_L:
							x = 0;
							break;
						case TYPE_R:
							x = w;
							break;
						case TYPE_C:
							x = 0;
							break;
						}
					}

					//Create
					var img:Image;
					{
						img = ImageManager.CreateHintImage(map);
						img.x = x;
						img.y = y;
					}

					//Set Message Listener
					{
						img.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE[map]));
					}

					//Regist
					{
						m_Content.addChild(img);
					}

					//Post
					{
						switch(type){
						case TYPE_L:
							break;
						case TYPE_R:
							y += h;
							break;
						case TYPE_C:
							y += h;
							break;
						}
					}
				}
//*/
			}
		}
	}
}

