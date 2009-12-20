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

	public class Game extends Box{
		//==Const==

		//＃表示画面の大きさ
		static public const CAMERA_W:Number = 32 * 12;//ImageManager.PANEL_LEN * 12;//400;
		static public const CAMERA_H:Number = 32 * 10;//ImageManager.PANEL_LEN * 10;//300;

		//＃マップの要素
		static public const O:int = 0;
		static public const W:int = 1;

		//==Var==

		//＃エディタとして実行するか
		public var m_ForEditor:Boolean =false;

		//＃画面構成
		public var m_Root:Image;//本体がBoxなので、BoxにaddChildすると縦に並ぶので、一段普通のImageをかます
		public var  m_Root_Game:Image;
		public var   m_Root_BG:Image;
		public var   m_Root_Obj:Image;
		public var    m_Root_Gimmick:Image;
		public var    m_Root_Player:Image;
		public var  m_Root_Intetrface:Image;

		//＃Player
		public var m_Player:Player;

		//＃BG
		public var m_BG_BitmapData:BitmapData;

		//＃Collision
		public var m_BG_Collision_BitmapData:BitmapData;

		//＃マップ
		public var m_Map:Array = [
			[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
			[W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, W, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, W, O, O, O, O, O, W],
			[W, O, O, O, W, O, O, O, W, O, W, O, O, O, O, O, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
			[W, O, O, O, O, O, W, O, O, O, O, O, O, O, O, O, O, O, W],
			[W, O, O, O, W, O, W, O, O, O, O, O, O, O, O, O, O, O, W],
			[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		];

		//＃Input
		public var m_Input:CInput_Keyboard;


		//==Singleton==
		private static var m_StaticInstance:Game;
		public static function Instance():Game{
			return m_StaticInstance;
		}


		//==Function==

		//!コンストラクタ
		public function Game(){
			//Singleton
			{
				m_StaticInstance = this;
			}
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init():void{
			//==Common Init==
			{
				//スクロールバーの表示はしないようにする
				this.horizontalScrollPolicy = "off";
				this.verticalScrollPolicy = "off";

				//自身の幅を設定しておく
				this.width  = CAMERA_W;
				this.height = CAMERA_H;
			}

			//毎フレームUpdateを呼ぶ
			{
				if(! m_ForEditor){
					addEventListener("enterFrame", function(event:Event):void {
						Update();
					});
				}else{
					addEventListener("enterFrame", function(event:Event):void {
						Update_ForEditor();
					});
				}
			}

			//キーボードのイベント取得
			{
				m_Input = new CInput_Keyboard(stage);
			}

			//残りはResetで
			{
				Reset();
			}
		}

		//リセット時に必要な処理（初期化の一部も兼ねる）
		public function Reset():void{
			//＃画面に相当する部分の初期化
			{
				//Reset
				while(numChildren > 0){
					removeChildAt(0);
				}

				//Root
				m_Root = new Image();
				addChild(m_Root);
				{
					//Game
					m_Root_Game = new Image();
					m_Root.addChild(m_Root_Game);
					{
						//BG
						m_Root_BG = new Image();
						m_Root_Game.addChild(m_Root_BG);

						//Obj
						m_Root_Obj = new Image();
						m_Root_Game.addChild(m_Root_Obj);
						{
							//Gimmick
							m_Root_Gimmick = new Image();
							m_Root_Obj.addChild(m_Root_Gimmick);

							//Player
							m_Root_Player = new Image();
							m_Root_Obj.addChild(m_Root_Player);
						}
					}

					//Interface
					m_Root_Intetrface = new Image();
					m_Root.addChild(m_Root_Intetrface);
				}
			}

			//＃GameObject
			{
				GameObjectManager.Reset();
			}

/*
			//＃Map
			{
				m_Map = [
					[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
					[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
					[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
					[W, W, O, O, O, O, O, O, O, O, O, O, O, O, O, W, O, O, W],
					[W, O, O, O, O, O, O, O, O, O, O, O, W, O, O, O, O, O, W],
					[W, O, O, O, W, O, O, O, W, O, W, O, O, O, O, O, O, O, W],
					[W, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, W],
					[W, O, O, O, O, O, W, O, O, O, O, O, O, O, O, O, O, O, W],
					[W, O, O, O, W, O, W, O, O, O, O, O, O, O, O, O, O, O, W],
					[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
				];
			}
//*/

//*
			//＃Player
			{
				var PlayerX:int = ImageManager.PANEL_LEN * 1.5;
				var PlayerY:int = ImageManager.PANEL_LEN * 1.5;

				m_Player = new Player();
				m_Player.Init(PlayerX, PlayerY, m_Input);

				m_Root_Player.addChild(m_Player);
				GameObjectManager.Register(m_Player);
			}
//*/

			//＃BG
			{
				var BG_W:int = m_Map[0].length * ImageManager.PANEL_LEN;
				var BG_H:int = m_Map.length * ImageManager.PANEL_LEN;

				//Init
				m_BG_BitmapData = new BitmapData(BG_W, BG_H, true, 0x88000000);
				m_BG_Collision_BitmapData = new BitmapData(BG_W, BG_H, true, 0x00000000);

				//描画登録
				m_Root_BG.addChild(new Bitmap(m_BG_BitmapData));
//				m_Root_BG.addChild(new Bitmap(m_BG_Collision_BitmapData));//コリジョンの可視化

				//描画内容更新
				ImageManager.DrawBG(m_BG_BitmapData, m_BG_Collision_BitmapData, m_Map, GetMapRect_All());
			}
		}


		///====

		protected var m_TempRect:Rectangle = new Rectangle(0, 0, 1, 1);//使いまわすためにメンバで保持

		//Map全体を更新するためのRectangleを返す
		public function GetMapRect_All():Rectangle{
			m_TempRect.x = 0;
			m_TempRect.y = 0;
			m_TempRect.width  = m_Map[0].length;
			m_TempRect.height = m_Map.length;

			return m_TempRect;
		}

		//一点を更新するためのRectangleを返す
		public function GetMapRect_Point(i_X:int, i_Y:int):Rectangle{
			m_TempRect.x = i_X-1;
			m_TempRect.y = i_Y-1;
			m_TempRect.width  = 3;
			m_TempRect.height = 3;

			if(i_X <= 0){m_TempRect.x = i_X;}
			if(i_X >= m_Map[0].length-1){m_TempRect.width = 2;}
			if(i_Y <= 0){m_TempRect.y = i_Y;}
			if(i_Y >= m_Map.length-1){m_TempRect.height = 2;}

			return m_TempRect;
		}


		//==更新まわり==

		public function GetDeltaTime():Number{
			return 1.0 / 24.0;
		}

		//!毎フレーム更新のために呼ばれる関数
		private function Update():void{
			var deltaTime:Number = GetDeltaTime();

			//Input
			{
				UpdateInput();

				CheckInput();
			}

			//GameObject
			{
				GameObjectManager.Update(deltaTime);
			}

			//Camera
			{
				UpdateCamera(deltaTime);
			}
		}


		//==入力==

		protected function UpdateInput():void{
			m_Input.Update();
		}

		protected function CheckInput():void{
			if(m_Input.IsPress_Edge(IInput.BUTTON_RESET)){
				Reset();
			}
		}


		//==カメラ==

		protected function UpdateCamera(i_DeltaTime:Number):void{
			//プレイヤー位置
			var PlayerX:int;
			var PlayerY:int;
			{
				PlayerX = m_Player.x;
				PlayerY = m_Player.y;
			}

			//プレイヤーを中心にした時の画面の左上の座標
			var TrgX:int;
			var TrgY:int;
			{
				TrgX = PlayerX - CAMERA_W/2;
				TrgY = PlayerY - CAMERA_H/2;
			}

			//カメラの左上の位置
			var CameraX:int;
			var CameraY:int;
			{
				CameraX = TrgX;
				CameraY = TrgY;

				//画面外を移さないようにする
				if(CameraX < 0){CameraX = 0;}
				if(CameraX + CAMERA_W > GetStageW()){CameraX = GetStageW() - CAMERA_W;}
				if(CameraY < 0){CameraY = 0;}
				if(CameraY + CAMERA_H > GetStageH()){CameraY = GetStageH() - CAMERA_H;}
			}

			//カメラ位置に合わせて、ステージの位置を変更する
			{
				m_Root_Game.x = -CameraX;
				m_Root_Game.y = -CameraY;
			}
		}

		public function GetStageW():int{
			return m_Map[0].length * ImageManager.PANEL_LEN;
		}

		public function GetStageH():int{
			return m_Map.length * ImageManager.PANEL_LEN;
		}


		//==BG Collision==

		public function IsCollision(i_X:int, i_Y:int):Boolean{
			//Check : Range
			{
				if(i_X < 0){return true;}
				if(i_X >= m_BG_Collision_BitmapData.width){return true;}
				if(i_Y < 0){return true;}
				if(i_Y >= m_BG_Collision_BitmapData.height){return true;}
			}

			return (m_BG_Collision_BitmapData.getPixel32(i_X, i_Y) != 0x00000000);
		}



		//==For Editor==

		//エディットモードか
		private var m_EditFlag:Boolean = true;

		//カーソル表示用レイヤー
		public var m_Root_Cursor:Image;

		//カーソル
		private var m_CursorImage:Image;
		private var m_CursorIndexX:int = 0;
		private var m_CursorIndexY:int = 0;

		public function Init_ForEditor():void{
			//Flag
			{
				m_ForEditor = true;
			}

			//通常時と同じ処理
			{
				Init();
			}

			//Resetと共通処理
			{
				Reset_ForEditor();
			}
		}

		public function Reset_ForEditor():void{
			//カーソル表示用レイヤー
			{
				m_Root_Cursor = new Image();
				m_Root_Game.addChild(m_Root_Cursor);
			}

			//カーソル
			{
				m_CursorImage = ImageManager.CreateCursorImage();
				m_Root_Cursor.addChild(m_CursorImage);
			}

			//一度Updateをまわす（位置などの設定のため）
			{
				//Cursor
				{//位置更新
					UpdateCursor(0.0);
				}

				//Camera
				{//位置更新
					UpdateCamera_ForEditor(0.0);
				}
			}
		}

		//Update
		private function Update_ForEditor():void{
			if(m_EditFlag){
				var deltaTime:Number = GetDeltaTime();

				//Input
				{
					UpdateInput();

					CheckInput_ForEditor();
				}

				//Cursor
				{
					UpdateCursor(deltaTime);
				}

				//Camera
				{
					UpdateCamera_ForEditor(deltaTime);
				}
			}else{
				//プレイを試みる
				Update();

				CheckInput_ForEditor();
			}
		}

		//Input
		protected function CheckInput_ForEditor():void{
			if(m_EditFlag){
				//Edit => Play
				if(m_Input.IsPress_Edge(IInput.BUTTON_GO_TO_PLAY)){
					GoToPlay();
				}

				//カーソル移動
				{
					if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_L)){
						m_CursorIndexX -= 1;
						if(m_CursorIndexX < 0){m_CursorIndexX = m_Map[0].length-1;}
					}
					if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_R)){
						m_CursorIndexX += 1;
						if(m_CursorIndexX >= m_Map[0].length){m_CursorIndexX = 0;}
					}
					if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_U)){
						m_CursorIndexY -= 1;
						if(m_CursorIndexY < 0){m_CursorIndexY = m_Map.length-1;}
					}
					if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_D)){
						m_CursorIndexY += 1;
						if(m_CursorIndexY >= m_Map.length){m_CursorIndexY = 0;}
					}
				}

				//ブロックのセット
				{
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_O)){
						SetBlock(O, m_CursorIndexX, m_CursorIndexY);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_W)){
						SetBlock(W, m_CursorIndexX, m_CursorIndexY);
					}
				}
			}else{
				//Play => Edit
				if(m_Input.IsPress_Edge(IInput.BUTTON_GO_TO_EDIT)){
					GoToEdit();
				}
			}
		}

		//Cursor
		private var m_AnimTimer:Number = 0.0;
		static private const CURSOR_ANIM_TIME:Number = 1.0;
		private function UpdateCursor(i_DeltaTime:Number):void{
			//Pos
			{
				m_CursorImage.x = m_CursorIndexX * ImageManager.PANEL_LEN;
				m_CursorImage.y = m_CursorIndexY * ImageManager.PANEL_LEN;
			}

			//Anim
			{
				//Time
				{
					m_AnimTimer += i_DeltaTime;
					if(m_AnimTimer >= CURSOR_ANIM_TIME){
						m_AnimTimer -= CURSOR_ANIM_TIME;
					}
				}

				//Alpha Anim
				{
					//0=>1, 0=>1, 0=>1, ...という流れ
					var Ratio:Number = m_AnimTimer/CURSOR_ANIM_TIME;

					//1=>0.6=>1=>0.6=>1=>...という流れ
					Ratio = 0.8 + 0.2*MyMath.Cos(2.0*MyMath.PI * Ratio);

					//アルファを使って明滅させる
					m_CursorImage.alpha = Ratio;
				}
			}
		}

		//Edit => Play
		public function GoToPlay():void{
			//Check
			{
				if(! m_EditFlag){
					return;
				}
			}

			//Reset
			{
				Reset();//!!要る？
			}

			m_EditFlag = false;
		}

		//Play => Edit
		public function GoToEdit():void{
			//Check
			{
				if(m_EditFlag){
					return;
				}
			}

			//Reset
			{
				Reset_ForEditor();
			}

			m_EditFlag = true;
		}

		//Block
		public function SetBlock(i_BlockIndex:int, i_X:int, i_Y:int):void{
			//Check
			{
				if(m_Map[i_Y][i_X] == i_BlockIndex){
					return;
				}
			}

			//Set Index
			{
				m_Map[i_Y][i_X] = i_BlockIndex;
			}

			//ReDraw
			{
				//描画内容更新
				ImageManager.DrawBG(m_BG_BitmapData, m_BG_Collision_BitmapData, m_Map, GetMapRect_Point(i_X, i_Y));
			}
		}

		//Camera
		protected function UpdateCamera_ForEditor(i_DeltaTime:Number):void{
			//カーソルの位置に合わせて移動させる

			//カーソル位置
			var CursorLX:int;
			var CursorRX:int;
			var CursorUY:int;
			var CursorDY:int;
			{
				CursorLX = (m_CursorIndexX + 0) * ImageManager.PANEL_LEN;
				CursorRX = (m_CursorIndexX + 1) * ImageManager.PANEL_LEN;
				CursorUY = (m_CursorIndexY + 0) * ImageManager.PANEL_LEN;
				CursorDY = (m_CursorIndexY + 1) * ImageManager.PANEL_LEN;
			}

			//現在のカメラ位置
			var CameraLX:int;
			var CameraRX:int;
			var CameraUY:int;
			var CameraDY:int;
			{
				CameraLX = -m_Root_Game.x;
				CameraRX = CameraLX + CAMERA_W;
				CameraUY = -m_Root_Game.y;
				CameraDY = CameraUY + CAMERA_H;
			}

			//カーソルが画面内に収まっていない場合に限り画面を移動させる
			{
				if(CursorLX < CameraLX){
					m_Root_Game.x = -CursorLX;
				}
				if(CursorRX > CameraRX){
					m_Root_Game.x = -CursorRX + CAMERA_W;
				}
				if(CursorUY < CameraUY){
					m_Root_Game.y = -CursorUY;
				}
				if(CursorDY > CameraDY){
					m_Root_Game.y = -CursorDY + CAMERA_H;
				}
			}
		}

	}
}
