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
	import flash.net.*;
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
		static public const O:int = 0;//空白
		static public const W:int = 1;//地形
		static public const P:int = 2;//プレイヤー位置（生成後は空白として扱われる）
		static public const G:int = 3;//ゴール位置（基本的には空白として扱われる）
		static public const Q:int = 4;//動かせるブロック（生成後は空白として扱われる）
		static public const S:int = 5;//赤青ブロック用の切り替えスイッチ
		static public const R:int = 6;//赤ブロック
		static public const B:int = 7;//青ブロック
		//system
		static public const C:int			= 8;
		static public const V:int			= 9;
		static public const SET_RANGE:int	= 10;
		static public const SET_DIR:int		= 11;

		//＃マップの要素を文字列化したときの値
		static public const MapIndex2Char:Array = [
			"O",
			"W",
			"P",
			"G",
			"Q",
			"S",
			"R",
			"B",
		];

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

		//＃Goal
		public var m_Goal:Goal;

		//＃BG
		public var m_BG_BitmapData:BitmapData;

		//＃マップ
		public var m_Map:Array = [
			[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, O, O, Q, O, O, W, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, W, W, W, W, O, W, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, O, W, O, O, O, O, W, O, O, W],
			[W, O, O, O, O, O, O, O, O, O, O, W, O, O, Q, O, O, W, O, G, W],
			[W, O, O, O, O, O, O, O, O, O, O, W, O, W, W, O, O, W, O, W, W],
			[W, O, O, O, Q, O, O, O, O, O, W, O, O, O, O, O, O, O, O, W, W],
			[W, O, O, W, W, W, O, O, O, O, W, O, O, O, Q, O, O, O, O, W, W],
			[W, O, O, O, O, O, O, O, O, O, W, W, W, W, W, W, O, W, W, W, W],
			[W, P, O, O, O, O, O, O, Q, O, W, W, W, W, W, W, O, W, W, W, W],
			[W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		];
		//Objectへの参照版
		public var m_ObjMap:Array;

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


		static public var InitFlag:Boolean = false;//どうもウィンドウとかの切り替えで再度Initが呼ばれてるような気がするので、必ず一度だけになるようにしておく

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init():void{
			//Check
			{
				if(InitFlag){
					return;
				}

				InitFlag = true;
			}

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
			var x:int;
			var y:int;

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

			//＃PhysManager
			{
				PhysManager.Reset();
			}

			//＃Map
			var PlayerX:int = ImageManager.PANEL_LEN * 1.5;
			var PlayerY:int = ImageManager.PANEL_LEN * 1.5;
			var GoalX:int = ImageManager.PANEL_LEN * 0.5;
			var GoalY:int = ImageManager.PANEL_LEN * 0.5;
			{
				//
				{
					var NumX:int = m_Map[0].length;
					var NumY:int = m_Map.length;

					//m_ObjMap
					{
						m_ObjMap = new Array(NumY);
						for(y = 0; y < NumY; y += 1){
							m_ObjMap[y] = new Array(NumX);
							//[NUM_Y][NUM_X] = null
						}
					}

					//Create from m_Map
					for(y = 0; y < NumY; y += 1){
						var pos_y:int = ImageManager.PANEL_LEN * (y + 0.5);

						for(x = 0; x < NumX; x += 1){
							var pos_x:int = ImageManager.PANEL_LEN * (x + 0.5);

							switch(m_Map[y][x]){
							case O:
								//空白なので何もしない
								break;
							case W:
								//CreateTerrainCollision()でまとめてやる
								break;
							case P:
								//プレイヤー位置として記憶
								{
									PlayerX = pos_x;
									PlayerY = pos_y;
								}
								break;
							case G:
								//ゴール位置として記憶
								{
									GoalX = pos_x;
									GoalY = pos_y;
								}
								break;
							case Q:
								//動かせるブロックを生成
								{
									var block_m:Block_Movable = new Block_Movable();
									block_m.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_m);
									GameObjectManager.Register(block_m);

									m_ObjMap[y][x] = block_m;
								}
								break;
							}
						}
					}
				}

				//Terrain
				{
					CreateTerrainCollision();
				}
			}

			//＃Player
			{
				m_Player = new Player();
				m_Player.SetInput(m_Input);
				m_Player.Reset(PlayerX, PlayerY);

				m_Root_Player.addChild(m_Player);
				GameObjectManager.Register(m_Player);
			}

			//＃Goal
			{
				m_Goal = new Goal();
				m_Goal.Reset(GoalX, GoalY);

				m_Root_Gimmick.addChild(m_Goal);
				GameObjectManager.Register(m_Goal);
			}

			//#Goal Text
			{
				m_GoalText = new TextField();
				{
					m_GoalText.border = false;
					m_GoalText.width = CAMERA_W;
					m_GoalText.autoSize = "center";
					m_GoalText.htmlText = <font size="30" color="#ffffff">GOAL</font>.toXMLString();
					m_GoalText.filters = [
						new GlowFilter(0x000000, 1, 4, 4, 16, 1),
						new DropShadowFilter(4, 45, 0x000000, 1, 4, 4, 16)
					];

					m_GoalText.x = CAMERA_W/2;
					m_GoalText.y = CAMERA_H/2;
				}
				m_Root.addChild(m_GoalText);//最前面に表示

				//最初は非表示
				m_GoalText.visible = false;
			}

			//#Goal Flag
			{
				m_GameEndType = -1;
			}

			//＃BG
			{
				var BG_W:int = m_Map[0].length * ImageManager.PANEL_LEN;
				var BG_H:int = m_Map.length * ImageManager.PANEL_LEN;

				//Init
				m_BG_BitmapData = new BitmapData(BG_W, BG_H, true, 0x88000000);

				//描画登録
				m_Root_BG.addChild(new Bitmap(m_BG_BitmapData));

				//描画内容更新
				ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_All());
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

		//指定範囲を更新するためのRectangleを返す
		public function GetMapRect_Area(i_X:int, i_Y:int, i_W:int, i_H:int):Rectangle{
			m_TempRect.x = i_X-1;
			m_TempRect.y = i_Y-1;
			m_TempRect.width  = i_W + 2;
			m_TempRect.height = i_H + 2;

			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			if(i_X <= 0){m_TempRect.x = i_X;}
			if(i_X+i_W+1 > NumX){m_TempRect.width = NumX - i_X + 1;}
			if(i_Y <= 0){m_TempRect.y = i_Y;}
			if(i_Y+i_H+1 > NumY){m_TempRect.height = NumY - i_Y + 1;}

			return m_TempRect;
		}


		//==Terrain==

		public var m_WallList:Array = [];
		public function CreateTerrainCollision():void{
			var x:int;
			var y:int;
			var iter_x:int;
			var iter_y:int;

			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			//Delete Old
			{
				var num:int = m_WallList.length;
				for(var i:int = 0; i < num; i += 1){
					m_WallList[i].Kill();
				}

				m_WallList = [];
			}

			var CopyMap:Array;
			{
				CopyMap = new Array(NumY);

				for(y = 0; y < NumY; y += 1){
					CopyMap[y] = new Array(NumX);

					for(x = 0; x < NumX; x += 1){
						CopyMap[y][x] = m_Map[y][x];
					}
				}
			}

			//左右に一列になってるブロックを探して連結
			//さらに、それらの下もブロックだったら連結
			for(y = 0; y < NumY; y += 1){

				var lx:int = -1;
				var rx:int = -1;

				for(x = -1; x < NumX+1; x += 1){

					//範囲外は空白とみなす
					var map:int;
					{
						if(x < 0){map = O;}
						else
						if(x >= NumX){map = O;}
						else
						{map = CopyMap[y][x];}
					}

					//必要な処理をしつつ、ブロックの生成が必要になったらフラグを立てて伝達
					var CreateBlockFlag:Boolean = true;
					{
						switch(map){
						case W:
							{
								if(lx < 0){lx = x;}
								rx = x;
							}

							//このブロックの上も元々ブロックであれば、横に長くせず、縦に長くする
							{
								//上がブロックじゃない時だけフラグを戻す。そうでなければ、下のブロック生成に移行する
								if(y == 0){CreateBlockFlag = false;}//マップの上辺なら上がブロックなわけはない
								else
								if(m_Map[y-1][x] != W){CreateBlockFlag = false;}//一つ上がブロックでなければすぐには生成しない
							}

							break;
						}
					}

					//必要ならブロックを生成
					{
						if(CreateBlockFlag)
						{
							//左右に連結してるのがあれば、下方向を連結した後、採用
							if(lx >= 0)
							{//yの段のlx～rxが連結されている
								//lx～rx, uy～dyを一つのブロックとみなす

								//uyとdyを求める

								var uy:int;
								{
									uy = y;//今の行が上辺
								}

								var dy:int;
								{
									var break_flag:Boolean = false;
									for(dy = uy+1; dy < NumY; dy += 1){
										for(iter_x = lx; iter_x <= rx; iter_x += 1){
											if(CopyMap[dy][iter_x] != W){
												break_flag = true;
											}

											if(break_flag){break;}
										}
										if(break_flag){break;}
									}
									dy -= 1;
								}

								//ブロックを実際に生成
								{
									var block:Block_Fix = new Block_Fix();
									block.Init(lx, rx, uy, dy);

									m_Root_Gimmick.addChild(block);
									GameObjectManager.Register(block);

									m_WallList.push(block);
								}

								//CopyMap上から、該当ブロックを消す
								{
									for(iter_y = uy; iter_y <= dy; iter_y += 1){
										for(iter_x = lx; iter_x <= rx; iter_x += 1){
											CopyMap[iter_y][iter_x] = O;
										}
									}
								}

								//reset
								{
									lx = rx = -1;
								}
							}//lx >= 0
						}//CreateBlockFlag
					}//Scope : Create Block
				}//loop x
			}//loop y
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

			//ゲーム終了時はここの処理まで
			{
				if(m_GameEndType >= 0){
					return;
				}
			}

			//GameObject
			{
				GameObjectManager.Update(deltaTime);
			}

			//Physics
			{
				PhysManager.Update(deltaTime);
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


		//==Goal==

		static public const GAME_END_GOAL:int	= 0;
		static public const GAME_END_DEAD:int	= 1;

		public var m_GameEndType:int = -1;//終了してなければマイナスの値にしておく

		//＃ゴール用テキスト
		public var m_GoalText:TextField;

		//ゴールOBJに触れたら呼ばれ、ゴール処理を開始する
		public function OnGoal():void{
			//ゴールしたので停止フラグをそれっぽくセット
			{
				m_GameEndType = GAME_END_GOAL;
			}

			//ゴール時の表示物を表示
			{
				m_GoalText.visible = true;
			}
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

		//タブウィンドウ
		public var m_TabWindow:TabWindow;

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

			//右側のタブウィンドウ
			{
				var TabWindowX:int = CAMERA_W;
				var TabWindowY:int = 0;
				var TabWindowW:int = 300;
				var TabWindowH:int = CAMERA_H;

				m_TabWindow = new TabWindow(TabWindowX, TabWindowY, TabWindowW, TabWindowH);
				m_TabWindow.AddTab(new Tab_Hint());
			//	m_TabWindow.AddTab(new Tab_Setting());
				m_TabWindow.AddTab(new Tab_Save());
			//	m_TabWindow.AddTab(new Tab_Upload());

				m_Root.addChild(m_TabWindow);
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

			//Objの状態を初期化
			{
				var NumX:int = m_Map[0].length;
				var NumY:int = m_Map.length;

				for(var y:int = 0; y < NumY; y += 1){
					var pos_y:int = (y + 0.5) * ImageManager.PANEL_LEN;

					for(var x:int = 0; x < NumX; x += 1){
						var pos_x:int = (x + 0.5) * ImageManager.PANEL_LEN;

						switch(m_Map[y][x]){
						case O://空白
							break;
						case W://地形
							break;
						case P://プレイヤー位置（生成後は空白として扱われる）
							m_Player.Reset(pos_x, pos_y);
							break;
						case G://ゴール位置（基本的には空白として扱われる）
							break;
						case Q://動かせるブロック（生成後は空白として扱われる）
							m_ObjMap[y][x].Reset(pos_x, pos_y);
							break;
						}
					}
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
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_B)){
						SetBlock(Q, m_CursorIndexX, m_CursorIndexY);
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
			SetBlocks([[i_BlockIndex]], i_X, i_Y);
		}
		public function SetBlocks(i_BlockIndexList:Array, i_X:int, i_Y:int):void{		
			var x:int;
			var y:int;
			var local_x:int;
			var local_y:int;
			var iter_x:int;
			var iter_y:int;

			var LocalNumX:int = i_BlockIndexList[0].length;
			var LocalNumY:int = i_BlockIndexList.length;
			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			//Set Blocks
			for(local_y = 0; local_y < LocalNumY; local_y += 1){
				//Calc Y
				{
					y = local_y + i_Y;
					if(y >= NumY){break;}
				}

				for(local_x = 0; local_x < LocalNumX; local_x += 1){
					//Calc X
					{
						x = local_x + i_X;

						if(x >= NumX){break;}
					}

					//セットしようとしている値
					var index:int = i_BlockIndexList[local_y][local_x];

					//Check
					{
						if(m_Map[y][x] == index){
							continue;//今セットされてる値と同じだったらいじらない
						}
					}

					//セット時の位置
					var pos_x:int = (x + 0.5) * ImageManager.PANEL_LEN;
					var pos_y:int = (y + 0.5) * ImageManager.PANEL_LEN;

					//Pre : Delete Old OBJ
					{
						switch(m_Map[y][x]){
						case Q://移動ブロック
							m_ObjMap[y][x].Kill();//ここにあったObjは削除する
							m_ObjMap[y][x] = null;
							break;
						}
					}

					//Pre : Delete Old Info
					{
						switch(index){
						case P:
						case G:
							for(iter_y = 0; iter_y < NumY; iter_y += 1){
								for(iter_x = 0; iter_x < NumX; iter_x += 1){
									if(m_Map[iter_y][iter_x] == index){
										m_Map[iter_y][iter_x] = O;//以前のものは空白にする
									}
								}
							}
						}
					}

					//Set
					{
						m_Map[y][x] = index;
					}

					//Post : Create New OBJ
					{
						switch(index){
						case P:
							m_Player.Reset(pos_x, pos_y);
							break;
						case G:
							m_Goal.Reset(pos_x, pos_y);
							break;

						case Q:
							//動かせるブロックを生成
							{
								var block_m:Block_Movable = new Block_Movable();
								block_m.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_m);
								GameObjectManager.Register(block_m);

								m_ObjMap[y][x] = block_m;
							}
							break;
						}
					}
				}
			}

			//ReDraw BG
			{
				ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_Area(i_X, i_Y, LocalNumX, LocalNumY));
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


		//=ステージの文字列化と逆変換=

		//Map→文字列
		static public function Map2String(i_Map:Array):String{
			var result:String = "";

			for(var y:int = 0; y < i_Map.length; y += 1){
				for(var x:int = 0; x < i_Map[y].length; x += 1){
					result = result + MapIndex2Char[i_Map[y][x]];
				}

				result = result + "_";
			}

			return result;
		}

		//文字列→Map
		static public function String2Map(i_MapString:String):Array{
			var NewMap:Array = [[]];

			var len:int = i_MapString.length;
			var y:int = 0;
			for(var i:int = 0; i < len; i += 1){
				switch(i_MapString.charAt(i)){
				case 'O': NewMap[y].push(O); break;
				case 'W': NewMap[y].push(W); break;
				case 'P': NewMap[y].push(P); break;
				case 'G': NewMap[y].push(G); break;
				case 'Q': NewMap[y].push(Q); break;
				case 'S': NewMap[y].push(S); break;
				case 'R': NewMap[y].push(R); break;
				case 'B': NewMap[y].push(B); break;
				case '_': NewMap.push([]); y += 1; break;
				}
			}

			//必要ならNewMapの出来をチェック

			return NewMap;
		}



		//=Local用セーブまわり=

		//data
		//-count	: セーブしてあるステージ数
		//-list		: ステージデータのリスト
		//--stage	: ステージを文字列で表現したもの
//		//--stage_name	: ステージ名

		//#Save
		//基本はi_Index番目のセーブデータに上書きセーブ。範囲外であれば新規セーブとみなす。
		public function Save(i_Index:int):void{
			//ローカルセーブを司るSharedObject
			var so:SharedObject = LoadSharedObject();

			//実際にセーブするデータ
			var save_data:Object = {
				stage:Map2String(m_Map)
				//stage_name:...
			};

			//Write
			{
				if(i_Index < 0 || so.data.count <= i_Index){
					//新規セーブ
					so.data.list.push(save_data);
					so.data.count += 1;
				}else{
					//上書きセーブ
					so.data.list[i_Index] = save_data;
				}
			}

			//反映
			so.data.flush();
		}

		//#Load
		//指定番号のセーブデータをロード（範囲外ならクリアとみなす）
		public function Load(i_Index:int):void{
			//ローカルセーブを司るSharedObject
			var so:SharedObject = LoadSharedObject();

			var NewMap:Array;
			if(i_Index < 0 || so.data.count <= i_Index){
				//クリア
				//!!
				return;
			}else{
				//ステージデータを文字列化したもの
				var stage_str:String = so.data.list[i_Index].stage;

				//文字列→実際のMap配列
				NewMap = String2Map(stage_str);
			}

			//ステージの再構築
			SetBlocks(NewMap, 0, 0);
		}


		//SharedObjectの取得（名称の統一と初期化場所の制限のため関数化）
		public function LoadSharedObject():SharedObject{
			var so:SharedObject = SharedObject.getLocal("ClassicActionGameEditor");

			//初期化が必要なら初期化する
			if(so.data.list == null){//hasOwnPropertyで判定した方が良い？
				//count
				{
					so.data.count = 0;
				}

				//list
				{
					so.data.list = [];
				}
			}

			//整合性の確保
			so.data.count = so.data.list.length;

			return so;
		}


		//=GAE用投稿まわり=

		//通信用のやつ
		private var m_NetConnection:NetConnection;

		//通信に応答するやつ
		private var m_Responder_Upload:Responder;

		//
		public function Upload():void{
			if(! m_NetConnection){
				m_NetConnection = new NetConnection();
/*
				m_NetConnection.connect("http://enen-pazzle.appspot.com/api/");
/*/
				m_NetConnection.connect("http://localhost:8080/api/");
//*/
			}

			if(! m_Responder_Upload){
				m_Responder_Upload = new Responder(
					//OnComplete
					function():void{
					},
					//OnFail
					function(results:*):void{
					}
				);
			}

			//投稿データはローカルのセーブデータと一部兼用
			var data:Object = {
				//id:
				stage:Map2String(m_Map)
			};

			//Upload
			m_NetConnection.call("save", m_Responder_Upload, data);//save(data)     
		}

	}
}
