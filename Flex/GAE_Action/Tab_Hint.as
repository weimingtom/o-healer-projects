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
			"SPACEを押すとブロックを「削除」します",//O:空白
			"Ｗを押すと「かべ」をセットします",//W:地形
			"Ｐを押したところが「プレイヤーの初期位置」になります",//P:プレイヤー位置（生成後は空白として扱われる）
			"Ｇを押したところが「ゴールの位置」になります",//G:ゴール位置（基本的には空白として扱われる）
			"Ｑを押すと「動かせるブロック」をセットします",//Q:動かせるブロック（生成後は空白として扱われる）
			"Ｓを押すと「スイッチ」をセットします",//S:乗せるスイッチ（動かせるブロックをこれに乗せる）
			"Ｄを押すと「ドア」をセットします",//D:ドア（スイッチの上にブロックが乗っていれば通過可能）
			"Ｒを押すと「逆ドア」をセットします",//R:逆ドア（通常のドアとは逆の動作）
			"Ｍを押すと「往復ブロック」をセットします",//M:往復ブロック
			"Ｔを押すと「トランポリン」をセットします",//トランポリンブロック
			"Ａを押すと「ダッシュブロック」をセットします",//A:ダッシュブロック
			"Ｎを押すと「トゲブロック」をセットします",//N:トゲブロック
			"Ｅを押すと「エネミー」をセットします",//E:エネミー
			"TEST",//C:コピー
			"TEST",//V:ペースト
			"TEST",//SET_RANGE:
			"TEST",//SET_DIR:
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

			//Message
			{
				m_TabMessage = "キーボードに対応するブロックのリストを表示します";
			}

			//Content
			{
				//#Base

				const BASE_NUM_X:int = 6;
				const BASE_NUM_Y:int = 3;

				const BASE_OFFSET_X:int = PANEL_W;
				const BASE_OFFSET_Y:int = PANEL_H + 16;

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
					Game.N,//トゲブロック
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
								img.addEventListener(MouseEvent.MOUSE_OUT,  CreateHideMessagehandler(HINT_MESSAGE[block_type]));
							}

							//Regist
							{
								m_Content.addChild(img);
							}

							//Mark
							{
								//Dir
								{
									var mark_dir:Image;
									switch(block_type){
									case Game.A:
										mark_dir = ImageManager.CreateMarkDir();
										mark_dir.x = img.x + 9;
										mark_dir.y = img.y + 45;
										m_Content.addChild(mark_dir);
										break;
									}
								}

								//Dir
								{
									var mark_no:Image;
									switch(block_type){
									case Game.Q:
									case Game.S:
									case Game.D:
									case Game.R:
									case Game.T:
									case Game.A:
										mark_no = ImageManager.CreateMarkNo();
										mark_no.x = img.x + 28;
										mark_no.y = img.y + 45;
										m_Content.addChild(mark_no);
										break;
									}
								}
							}

							index += 1;
						}
					}
				}

				//#System

///				const SYSTEM_CONTENT:Array = [
//					Game.C,
//					Game.V,
//					Game.SET_RANGE,
//					Game.SET_DIR,
//				];

				const SYSTEM_OFFSET_Y:int = 3 * BASE_OFFSET_Y;

				var MARK_IMAGE:Array = [
					ImageManager.CreateMarkDir(),
					ImageManager.CreateMarkNo(),
				];

				const SYSTEM_STR:Array = [
					"Ctrl＋↑↓←→で方向指定",
					"1～9で値指定（0でリセット）",
				];

				const SYSTEM_HINT_MESSAGE:Array = [
					"ブロックの方向を指定します（対応してるものだけ）",
					"ブロックの値（種類）を指定します（対応してるものだけ）",
				];

				for(y = 0; y < SYSTEM_STR.length; y += 1){
					//mark
					{
						var mark:Image = MARK_IMAGE[y];

						mark.x = 8;
						mark.y = SYSTEM_OFFSET_Y + y * 32 + mark.height/2;

						m_Content.addChild(mark);
					}

					//text
					{
						var tf:TextField = new TextField();
						tf.selectable = false;
						tf.autoSize = TextFieldAutoSize.LEFT;
						tf.embedFonts = true;

						tf.htmlText = "<font face='system' size='20'>" + SYSTEM_STR[y] + "</font>";
	//					tf.textColor = 0xFFFFFF;

						tf.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(SYSTEM_HINT_MESSAGE[y]));
						tf.addEventListener(MouseEvent.MOUSE_OUT,  CreateHideMessagehandler(SYSTEM_HINT_MESSAGE[y]));

						tf.x = 32;
						tf.y = SYSTEM_OFFSET_Y + y * 32;

						m_Content.addChild(tf);
					}
				}
			}
		}
	}
}

