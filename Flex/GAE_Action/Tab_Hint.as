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
			"Sを押すとスイッチをセットします",//S:乗せるスイッチ（動かせるブロックをこれに乗せる）
			"Dを押すとドアをセットします",//D:ドア（スイッチの上にブロックが乗っていれば通過可能）
			"Rを押すと逆ドアをセットします",//R:逆ドア（通常のドアとは逆の動作）
			"Mを押すと往復ブロックをセットします",//M:往復ブロック
			"Tを押すとトランポリンをセットします",//トランポリンブロック
			"Aを押すとダッシュブロックをセットします",//A:ダッシュブロック
			"Eを押すとエネミーをセットします",//E:エネミー
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
				//#Base

				const BASE_NUM_X:int = 6;
				const BASE_NUM_Y:int = 3;

				const BASE_OFFSET_X:int = PANEL_W;
				const BASE_OFFSET_Y:int = PANEL_H;

				const BASE_CONTENT:Array = [
					Game.O,//空白
					Game.W,//地形
					Game.P,//プレイヤー位置（生成後は空白として扱われる）
					Game.G,//ゴール位置（基本的には空白として扱われる）
					Game.Q,//動かせるブロック（生成後は空白として扱われる）
					Game.S,//乗せるスイッチ（動かせるブロックをこれに乗せる）
					Game.D,//ドア（スイッチの上にブロックが乗っていれば通過可能）
					Game.R,//逆ドア（通常のドアとは逆の動作）
//					Game.M,//往復ブロック
					Game.T,//トランポリンブロック
					Game.A,//ダッシュブロック
					Game.E,//エネミー
				];

				var x:int;
				var y:int;

				var img:Image;

				var index:int;
				var block_type:int;

				index = 0;
				for(y = 0; y < BASE_NUM_Y; y += 1){
					for(x = 0; x < BASE_NUM_X; x += 1){
						if(index < BASE_CONTENT.length){
							block_type = BASE_CONTENT[index];

							//Create
							//var img:Image;
							{
								img = ImageManager.CreateHintImage(block_type);
								img.x = x * BASE_OFFSET_X;
								img.y = y * BASE_OFFSET_Y;
							}

							//Set Message Listener
							{
								img.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE[block_type]));
							}

							//Regist
							{
								m_Content.addChild(img);
							}

							index += 1;
						}
					}
				}

				//#System

				const SYSTEM_CONTENT:Array = [
					Game.C,
					Game.V,
					Game.SET_RANGE,
					Game.SET_DIR,
				];
			}
		}
	}
}

