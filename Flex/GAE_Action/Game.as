//author Show=O=Healer

/*
	反省点
	・ブロックの追加がしにくい
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

	public class Game extends Canvas{
		//==Const==

		//＃表示画面の大きさ
		static public const CAMERA_W:Number = 32 * 12 + 16;//ImageManager.PANEL_LEN * 12;//400;
		static public const CAMERA_H:Number = 32 * 10;//ImageManager.PANEL_LEN * 10;//300;

		//＃マップのマスの数の制限
		static public const MAP_W_MIN:int = 13;
		static public const MAP_W_MAX:int = 99;
		static public const MAP_H_MIN:int = 10;
		static public const MAP_H_MAX:int = 99;

		//＃マップの要素
		static public var BLOCK_INDEX_COUNTER:int = 0;
		static public const O:int = BLOCK_INDEX_COUNTER++;//空白
		static public const W:int = BLOCK_INDEX_COUNTER++;//地形
		static public const P:int = BLOCK_INDEX_COUNTER++;//プレイヤー位置（生成後は空白として扱われる）
		static public const G:int = BLOCK_INDEX_COUNTER++;//ゴール位置（基本的には空白として扱われる）
		static public const Q:int = BLOCK_INDEX_COUNTER++;//動かせるブロック（生成後は空白として扱われる）
		static public const S:int = BLOCK_INDEX_COUNTER++;//乗せるスイッチ（動かせるブロックをこれに乗せる）
		static public const D:int = BLOCK_INDEX_COUNTER++;//ドア（スイッチの上にブロックが乗っていれば通過可能）
		static public const R:int = BLOCK_INDEX_COUNTER++;//逆ドア（通常のドアとは逆の動作）
		static public const M:int = BLOCK_INDEX_COUNTER++;//往復ブロック
		static public const T:int = BLOCK_INDEX_COUNTER++;//トランポリンブロック
		static public const A:int = BLOCK_INDEX_COUNTER++;//ダッシュブロック
		static public const N:int = BLOCK_INDEX_COUNTER++;//トゲブロック
		static public const L:int = BLOCK_INDEX_COUNTER++;//連結ブロック
		static public const E:int = BLOCK_INDEX_COUNTER++;//エネミー
		//system
		static public const C:int			= BLOCK_INDEX_COUNTER++;
		static public const V:int			= BLOCK_INDEX_COUNTER++;
		static public const SET_RANGE:int	= BLOCK_INDEX_COUNTER++;
		static public const SET_DIR:int		= BLOCK_INDEX_COUNTER++;
		//Val
		static public const VAL_OFFSET:int	= 100;//これで割った数の１桁目が指定された数字になる
		//Dir
		static public const DIR_OFFSET:int	= 1000;//

		//＃マップの要素を文字列化したときの値
		static public const MapIndex2Char:Array = [
			"O",
			"W",
			"P",
			"G",
			"Q",
			"S",
			"D",
			"R",
			"M",
			"T",
			"A",
			"N",
			"L",
			"E",
		];

		//＃セットできるマップの数の上限
		static public const MAP_NUM_MAX_X:int = 100;
		static public const MAP_NUM_MAX_Y:int = 100;

		//==Var==

		//＃エディタとして実行するか
		public var m_ForEditor:Boolean =false;

		//＃画面構成
		public var m_Root:Image;
		public var  m_Root_Zoom:Image;
		public var   m_Root_Game:Image;
		public var    m_Root_BG:Image;
		public var    m_Root_Obj:Image;
		public var     m_Root_Gimmick:Image;
		public var     m_Root_Player:Image;
		public var  m_Root_Intetrface:Image;

		//＃Player
		public var m_Player:Player;

		//＃Goal
		public var m_Goal:Goal;

		//＃BG
		public var m_BG_BitmapData:BitmapData;

		//＃マップ
		public var m_Map:Array = [
			[W, W, W, W, W, W, W, W, W, A, A, A, W],
			[W, W, W, O, O, O, O, O, O, O, O, O, W],
			[W, W, W, O, Q, O, O, O, O, O, O, O, W],
			[W, G, O, S, W, W, D, D, W, W, W, O, W],
			[W, R, O, O, O, O, O, O, O, O, O, O, W],
			[W, R, R, O, O, O, O, O, O, O, O, O, W],
			[W, R, R, R, O, O, O, O, O, O, O, T, W],
			[W, O, O, O, W, W, W, O, O, O, O, W, W],
			[W, P, O, O, W, W, W, O, O, E, T, W, W],
			[W, W, W, W, W, W, W, W, W, W, W, W, W],
		];
		//Objectへの参照版
		public var m_ObjMap:Array;
		public var m_ObjList:Array = [];
		static public function GetMapIndex(i_Val:int):int{return (i_Val % VAL_OFFSET);}
		static public function GetMapVal(i_Val:int):int{return (int(i_Val / VAL_OFFSET) % 10);}
		static public function GetMapDir(i_Val:int):int{return (int(i_Val / DIR_OFFSET) % 10);}

		//＃Update：差し替えられるようにメンバ変数化
		public var m_UpdateFunc:Function = function():void{};

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

		static public var m_PauseFlag:Boolean = false;//普通のプレイでも最初の部分は表示することにしたので、普通のInitならPauseを立てて、UnPauseされるまで待機
		public function Pause():void{m_PauseFlag = true;}
		public function UnPause():void{m_PauseFlag = false;}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init(in_MapStr:String = null):void{
			//Check
			{
				if(InitFlag){
					return;
				}

				InitFlag = true;
			}

			//Flag
			{
				Pause();
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
/*
				if(! m_ForEditor){
					addEventListener("enterFrame", function(event:Event):void {
						Update();
					});
				}else{
					addEventListener("enterFrame", function(event:Event):void {
						Update_ForEditor();
					});
				}
/*/
				Init_Update();

				if(m_ForEditor){
					Init_UpdateForEditor();
				}

				addEventListener("enterFrame", function(event:Event):void {
					Update();
				});
//*/
			}

			//キーボードのイベント取得
			{
				m_Input = new CInput_Keyboard(stage);
			}

			//レイヤーはトップ付近だけは保持したままにするのでここで作成
			{
				//Root
				m_Root = new Image();
				addChild(m_Root);
			}

			//
			{
				if(in_MapStr){
					m_Map = String2Map(in_MapStr);
				}
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

			var g:Graphics;

			//＃画面に相当する部分の初期化
			{
				//Reset
				while(m_Root.numChildren > 0){
					m_Root.removeChildAt(0);
				}

				//プレイヤーキャラ「リバーサー」で画面反転時に後ろが見えるため、黒く塗りつぶしておく
				{
					var black_bg:Shape = new Shape();
					{
						g = black_bg.graphics;
						g.beginFill(0x000000, 1.0);
						g.drawRect(0, 0, CAMERA_W, CAMERA_H);
					}

					m_Root.addChild(black_bg);
				}

				//Root：RootはInitで作成したまま
				{
					//Zoom
					m_Root_Zoom = new Image();
					m_Root.addChild(m_Root_Zoom);
					{
						//Game
						m_Root_Game = new Image();
						m_Root_Zoom.addChild(m_Root_Game);
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
					}

					//Interface
					m_Root_Intetrface = new Image();
					m_Root.addChild(m_Root_Intetrface);
				}
			}

			//Mask
			{
				var root_mask:Sprite = new Sprite();
				{
					g = root_mask.graphics;
					g.beginFill(0x000000, 1.0);
					g.drawRect(0, 0, CAMERA_W, CAMERA_H);
				}
				m_Root.mask = root_mask;
				m_Root.addChild(root_mask);
			}

			//＃GameObject
			{
				GameObjectManager.Reset();
			}

			//＃PhysManager
			{
				PhysManager.Reset();
			}

			//#Switch
			{
				SwitchCounter.Reset();
			}

			//＃Map
			var PlayerX:int = ImageManager.PANEL_LEN * 1.5;
			var PlayerY:int = ImageManager.PANEL_LEN * 1.5;
			var PlayerType:int = Player.TYPE_NORMAL;//!!
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

							switch(GetMapIndex(m_Map[y][x])){
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

									PlayerType = (m_Map[y][x] / VAL_OFFSET) % 10;
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
									var block_q:Block_Movable = new Block_Movable();
									block_q.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_q.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_q);
									GameObjectManager.Register(block_q);

									m_ObjMap[y][x] = block_q;
								}
								break;
							case S:
								//スイッチを生成
								{
									var block_s:Block_Switch = new Block_Switch();
									block_s.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_s.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_s);
									GameObjectManager.Register(block_s);

									m_ObjMap[y][x] = block_s;
								}
								break;
							case D:
								//ドアを生成
								{
									var block_d:Block_Door = new Block_Door(false);
									block_d.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_d.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_d);
									GameObjectManager.Register(block_d);

									m_ObjMap[y][x] = block_d;
								}
								break;
							case R:
								//逆ドアを生成
								{
									var block_r:Block_Door = new Block_Door(true);
									block_r.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_r.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_r);
									GameObjectManager.Register(block_r);

									m_ObjMap[y][x] = block_r;
								}
								break;
							case M:
								//往復ブロックを生成
								{
									var block_m:Block_Move = new Block_Move();
									block_m.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_m.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_m);
									GameObjectManager.Register(block_m);

									m_ObjMap[y][x] = block_m;
								}
								break;
							case T:
								//トランポリンブロックを生成
								{
									var block_t:Block_Trampoline = new Block_Trampoline();
									block_t.SetVal((m_Map[y][x] / VAL_OFFSET) % 10);
									block_t.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_t);
									GameObjectManager.Register(block_t);

									m_ObjMap[y][x] = block_t;
								}
								break;
							case A:
								//ダッシュブロックを生成
								{
									var block_a:Block_Accel = new Block_Accel();
									block_a.SetVal(GetMapVal(m_Map[y][x]));
									block_a.SetDir(GetMapDir(m_Map[y][x]));
									block_a.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_a);
									GameObjectManager.Register(block_a);

									m_ObjMap[y][x] = block_a;
								}
								break;
/*
							case N:
								//トゲブロックを生成
								{
									var block_n:Block_Needle = new Block_Needle();
									block_n.SetVal(GetMapVal(m_Map[y][x]));
									block_n.SetDir(GetMapDir(m_Map[y][x]));
									block_n.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(block_n);
									GameObjectManager.Register(block_n);

									m_ObjMap[y][x] = block_n;
								}
								break;
//*/
							case L:
								//CreateTerrainCollision()でまとめてやる
								break;
							case E:
								//エネミーを生成
								{
									var enemy:Enemy_Rolling = new Enemy_Rolling();
									enemy.Reset(pos_x, pos_y);

									m_Root_Gimmick.addChild(enemy);
									GameObjectManager.Register(enemy);

									m_ObjMap[y][x] = enemy;
								}
								break;
							}
						}
					}
				}

				//Terrain
				{
					CreateTerrainCollision();

					CreateClusterBlock();
				}
			}

			//＃Player
			{
				m_Player = new Player();
				m_Player.SetVal(PlayerType);
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

			//#Goal Flag
			{
				m_GameOverType = -1;
				m_GameOverImage = null;
			}

			//＃BG
			{
				//最初から最大数分確保しておく
				var BG_W:int = MAP_NUM_MAX_X * ImageManager.PANEL_LEN;
				var BG_H:int = MAP_NUM_MAX_Y * ImageManager.PANEL_LEN;

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
			if(i_X+i_W+1 > NumX){m_TempRect.width = NumX - m_TempRect.x;}//{m_TempRect.width = NumX - i_X + 1;}
			if(i_Y <= 0){m_TempRect.y = i_Y;}
			if(i_Y+i_H+1 > NumY){m_TempRect.height = NumY - m_TempRect.y;}//{m_TempRect.height = NumY - i_Y + 1;}

			return m_TempRect;
		}


		//==Terrain==

		public var m_WallList:Array = [];
		public function CreateTerrainCollision():void{
			var x:int;
			var y:int;
			var iter_x:int;
			var iter_y:int;
			var lx:int;
			var rx:int;
			var uy:int;
			var dy:int;
			var map:int;
			var CreateBlockFlag:Boolean;
			var break_flag:Boolean;

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

			//m_Mapの内容をコピーして、連結したものは消せるようにしておく
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

				lx = -1;
				rx = -1;

				for(x = -1; x < NumX+1; x += 1){

					//範囲外は空白とみなす
					//var map:int;
					{
						if(x < 0){map = O;}
						else
						if(x >= NumX){map = O;}
						else
						{map = CopyMap[y][x];}
					}

					//必要な処理をしつつ、ブロックの生成が必要になったらフラグを立てて伝達
					//var CreateBlockFlag:Boolean = true;//Wなどでなかったらクラスタリング終了とみなし、生成に移るためデフォはtrue
					CreateBlockFlag = true;
					{
						switch(map){
						case W:
							{
								if(lx < 0){lx = x;}
								rx = x;
							}

							//横に伸ばす状況ならまだ生成に移らないのでfalseにする
							{//このブロックの上も元々ブロックであれば、横に長くせず、縦に長くする
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

								//var uy:int;
								{
									uy = y;//今の行が上辺
								}

								//var dy:int;
								{
									//var break_flag:Boolean = false;
									break_flag = false;
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
									var block_f:Block_Fix = new Block_Fix();
									block_f.Init(lx, rx, uy, dy);

									m_Root_Gimmick.addChild(block_f);
									GameObjectManager.Register(block_f);

									m_WallList.push(block_f);
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

			//Needleも同様の処理
			for(y = 0; y < NumY; y += 1){

				lx = -1;
				rx = -1;

				for(x = -1; x < NumX+1; x += 1){

					//範囲外は空白とみなす
					//var map:int;
					{
						if(x < 0){map = O;}
						else
						if(x >= NumX){map = O;}
						else
						{map = CopyMap[y][x];}
					}

					//必要な処理をしつつ、ブロックの生成が必要になったらフラグを立てて伝達
					//var CreateBlockFlag:Boolean = true;//Wなどでなかったらクラスタリング終了とみなし、生成に移るためデフォはtrue
					CreateBlockFlag = true;
					{
						switch(map){
						case N:
							{
								if(lx < 0){lx = x;}
								rx = x;
							}

							//横に伸ばす状況ならまだ生成に移らないのでfalseにする
							{//このブロックの上も元々ブロックであれば、横に長くせず、縦に長くする
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

								//var uy:int;
								{
									uy = y;//今の行が上辺
								}

								//var dy:int;
								{
									//var break_flag:Boolean = false;
									break_flag = false;
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
									var block_n:Block_Needle = new Block_Needle();
									block_n.Init(lx, rx, uy, dy);

									m_Root_Gimmick.addChild(block_n);
									GameObjectManager.Register(block_n);

									m_WallList.push(block_n);
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

		public function CreateClusterBlock():void{
			var x:int;
			var y:int;

			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			//Delete Old
			{
				var num:int = m_ObjList.length;
				for(var i:int = 0; i < num; i += 1){
//					if(m_ObjList[i].parent){
//						m_ObjList[i].parent.removeChild(m_ObjList[i]);
//						m_ObjList[i].parent = null;
//					}
					m_ObjList[i].Kill();
				}

				if(num > 0){
					m_ObjList = [];
				}
			}

			//m_Mapの内容をコピーして、連結したものは消せるようにしておく
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

			//連結ブロック
			{
				var link_info:Array = [];

				var link_lx:int = MAP_W_MAX;
				var link_rx:int = 0;
				var link_uy:int = MAP_H_MAX;
				var link_dy:int = 0;

				const gather_link_block:Function = function(in_X:int, in_Y:int):void{
					//Check
					{//L以外は飛ばす
						if(GetMapIndex(CopyMap[in_Y][in_X]) != L){
							return;
						}
					}

					//Lがあったので、これと連結しているLを全て集めて連結ブロックを生成

					//まずは自分を追加
					{
						link_info.push(new Point(in_X, in_Y));
					}

					//ここは確認したので消す
					{
						CopyMap[in_Y][in_X] = O;
					}

					//Lのある範囲を求める
					{
						if(in_X < link_lx){link_lx = in_X;}
						if(link_rx < in_X){link_rx = in_X;}
						if(in_Y < link_uy){link_uy = in_Y;}
						if(link_dy < in_Y){link_dy = in_Y;}
					}

					//上下左右について確認
					{
						if(in_Y > 0){gather_link_block(in_X, in_Y-1);}
						if(in_Y < NumY-1){gather_link_block(in_X, in_Y+1);}
						if(in_X > 0){gather_link_block(in_X-1, in_Y);}
						if(in_X < NumX-1){gather_link_block(in_X+1, in_Y);}
					}
				};

				for(y = 0; y < NumY; y += 1){
					for(x = 0; x < NumX; x += 1){
						//
						gather_link_block(x, y);

						//
						if(link_info.length > 0){
//*
							//Create
							{
								var block_l:Block_Cluster = new Block_Cluster();
								block_l.Init(link_info, link_lx, link_rx, link_uy, link_dy);

								m_Root_Gimmick.addChild(block_l);
								GameObjectManager.Register(block_l);

								m_ObjList.push(block_l);
							}
//*/
							//Reset
							{
								link_info = [];

								link_lx = MAP_W_MAX;
								link_rx = 0;
								link_uy = MAP_H_MAX;
								link_dy = 0;
							}
						}
					}
				}
			}
		}

		public function IsWall(i_X:int, i_Y:int):Boolean{
			var NumX:int = m_Map[0].length;
			var NumY:int = m_Map.length;

			//Check：範囲外は壁とみなす
			{
				if(i_X < 0){return true;}
				if(i_X >= NumX){return true;}
				if(i_Y < 0){return true;}
				if(i_Y >= NumY){return true;}
			}

			//新規に追加するやつは当たり判定ありのやつだと思うので、空間のみチェックして、それ以外は壁とする
			switch(GetMapIndex(m_Map[i_Y][i_X])){
			case O:
			case P:
			case G:
			case E:
			case Q:
				return false;
			}

			//ドア系は、オフの状態の時のみ空間とみなす
			switch(GetMapIndex(m_Map[i_Y][i_X])){
			case D:
			case R:
				//該当スイッチがオン→普通のドアであれば開いている
				if(SwitchCounter.Get(GetMapVal(m_Map[i_Y][i_X])).IsOn() == (GetMapIndex(m_Map[i_Y][i_X]) == D)){
					return false;
				}
			}

			//空間でなければ壁とみなす
			return true;
		}


		//==更新まわり==

		public function GetDeltaTime():Number{
			return 1.0 / 24.0;
		}

		//!毎フレーム更新のために呼ばれる関数
		private function Update():void{
			m_UpdateFunc();
		}

		//!通常用Update関数の設定
		private function Init_Update():void{
			m_UpdateFunc = function():void{
				var deltaTime:Number = GetDeltaTime();

				//Check
				{
					if(m_PauseFlag){
						return;
					}
				}

				//Input
				{
					UpdateInput();

					CheckInput();
				}

				//ゲーム終了時はここの処理まで
				{
					if(m_GameOverType >= 0){
						//GameOver表示のアニメーショhんをしてみる
						{
							if(m_GameOverImage){
								const src:Number = 0.1;
								const dst:Number = 0.8;
								m_GameOverImage.alpha = src + (dst - src)/dst * m_GameOverImage.alpha;
							}
						}
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

				//GameObject : Post
				{
					GameObjectManager.Update_AfterPhys(deltaTime);
				}
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


		//==GameOver==

		static public const GAME_OVER_GOAL:int		= 0;
		static public const GAME_OVER_DAMAGE:int	= 1;
		static public const GAME_OVER_FALL:int		= 2;
		static public const GAME_OVER_PRESS:int		= 3;

		public var m_GameOverType:int = -1;//終了してなければマイナスの値にしておく

		//＃ゴール用テキスト
//		public var m_GoalText:TextField;
		public var m_GameOverImage:Image;

		//ゴールOBJに触れたら呼ばれ、ゴール処理を開始する
		public function OnGoal():void{
			OnGameOver(GAME_OVER_GOAL);
		}

		//死亡時、クリア時、ミッション失敗時などに、これを呼ぶ
		public function OnGameOver(in_GameOverType:int):void{
			//フラグ相当を立てる
			{
				m_GameOverType = in_GameOverType;
			}

			//画面の表示
			{
				m_GameOverImage = ImageManager.CreateGameOverImage(in_GameOverType);
				{
					m_GameOverImage.filters = [
						new GlowFilter(0x000000, 1, 4, 4, 16, 1),
						new DropShadowFilter(4, 45, 0x000000, 1, 4, 4, 16)
					];

					m_GameOverImage.x = CAMERA_W/2;
					m_GameOverImage.y = CAMERA_H/2;
				}
				m_Root.addChild(m_GameOverImage);//最前面に表示

				m_GameOverImage.alpha = 0.0;
			}
		}



		//==For Editor==

		//エディットモードか
		private var m_EditFlag:Boolean = true;

		//レイヤー
		public var m_EditRoot:Image;//エディタ用ルート
		public var  m_GameLayer:Image;//ゲーム画面まわりのレイヤー
//		public var   m_Game_Root:Imagge;//ゲーム画面のレイヤー（上にあるやつを使う）
		public var    m_Game_Cursor:Image;//カーソル表示用レイヤー
		public var   m_Game_Frame:Image;//ゲーム画面まわりの額縁用レイヤー
		public var   m_Game_Instruction:Image;//プレイ説明画像用レイヤー
		public var  m_TabWindowLayer:Image;

		//ゲームの枠
		public var m_GameFrameImage:Image;

		//Enter用テキスト
		public var m_Text4Enter:TextField;

		//カーソル
		private var m_CursorShape:Shape;
		private var m_CursorIndexSrcX:int = 0;
		private var m_CursorIndexDstX:int = 0;
		private var m_CursorIndexSrcY:int = 0;
		private var m_CursorIndexDstY:int = 0;

		//タブウィンドウ
		public var m_TabWindow:TabWindow;

		//タブウィンドウの大きさまわり
		static public const TAB_WINDOW_W:uint = 400;
		static public const TAB_WINDOW_H:uint = 400;

		public function Init_ForEditor(i_W:int, i_H:int):void{
			//Flag
			{
				m_ForEditor = true;
			}

			//通常時と同じ処理
			{
				Init();
			}

			//サイズ設定
			{
				this.width  = i_W;
				this.height = i_H;
			}

			//Initのみの処理
			{
				//レイヤー構築
				{
					//m_EditRoot
					m_EditRoot = new Image();
					addChild(m_EditRoot);
					{
						//m_GameLayer
						m_GameLayer = new Image();
						m_EditRoot.addChild(m_GameLayer);
						{
							//m_Game_Root (= m_Root)
							removeChild(m_Root);//m_Rootの接続先を変更
							m_GameLayer.addChild(m_Root);
							m_Root.x = ImageManager.GAME_FRAME_W;
							m_Root.y = ImageManager.GAME_FRAME_H;
							{
								//（さらにゲームの方にくっつける）
								//m_Game_Cursor
								m_Game_Cursor = new Image();
//								m_Root_Game.addChild(m_Game_Cursor);
							}

							//m_Game_Frame
							m_Game_Frame = new Image();
							m_GameLayer.addChild(m_Game_Frame);

							//m_Game_Instruction
							m_Game_Instruction = new Image();
							m_GameLayer.addChild(m_Game_Instruction);
							m_Game_Instruction.x = CAMERA_W + 2*ImageManager.GAME_FRAME_W + 50 + ImageManager.TAB_W;
						}

						//m_TabWindowLayer
						m_TabWindowLayer = new Image();
						m_EditRoot.addChild(m_TabWindowLayer);
					}
				}

				//ゲームの枠
				{
					m_GameFrameImage = ImageManager.CreateGameFrameImage(CAMERA_W, CAMERA_H);
					m_Game_Frame.addChild(m_GameFrameImage);
				}

				//インスト（操作説明）
				{
					var GameInstImage:Image = ImageManager.CreatePlayStartImage(TAB_WINDOW_W-ImageManager.TAB_W, this.height);
					m_Game_Instruction.addChild(GameInstImage);
				}

				//
				{
					m_Text4Enter = new TextField();

					m_Text4Enter.border = false;
					m_Text4Enter.selectable = false;
					m_Text4Enter.autoSize = TextFieldAutoSize.LEFT;
					m_Text4Enter.embedFonts = true;

					m_Text4Enter.x = 8;
					m_Text4Enter.y = m_GameFrameImage.y + m_GameFrameImage.height + 8;

					m_Text4Enter.htmlText = "<font face='system' size='16'>" + "Enter：テストプレイ" + "</font>";
					m_Text4Enter.textColor = 0xFFFFFF;

					m_GameLayer.addChild(m_Text4Enter);
				}

				//カーソル
				{
					m_CursorShape = new Shape();
					m_Game_Cursor.addChild(m_CursorShape);
				}

				//右側のタブウィンドウ
				{
					var TabWindowX:int = CAMERA_W + 2*ImageManager.GAME_FRAME_W + 50;
					var TabWindowY:int = 0;
					var TabWindowW:int = TAB_WINDOW_W;
					var TabWindowH:int = TAB_WINDOW_H;

					m_TabWindow = new TabWindow(TabWindowX, TabWindowY, TabWindowW, TabWindowH);
					m_TabWindowLayer.addChild(m_TabWindow);

					m_TabWindow.AddTab(new Tab_Hint());
					m_TabWindow.AddTab(new Tab_Setting());
					m_TabWindow.AddTab(new Tab_Save());
					m_TabWindow.AddTab(new Tab_Upload());
				}

				//ヒントメッセージ
				{
					var HintMessageImage:Image = HintMessage.Instance().GetImage();
					HintMessageImage.x = m_TabWindow.x+22;//0;
					HintMessageImage.y = m_GameFrameImage.y + m_GameFrameImage.height + 8;
					m_TabWindowLayer.addChild(HintMessageImage);
				}
			}

			//Resetと共通処理
			{
				Reset_ForEditor();
			}

			//ログインチェック
			{
				CheckLogin();
			}
		}

		public function Reset_ForEditor():void{
			//レイヤー：Resetの度に構築するもの
			{
				//m_Root_Gameが再構築されるので、再登録
				m_Root_Game.addChild(m_Game_Cursor);
			}

			//#Switch
			{
				SwitchCounter.Reset();
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
			{//m_ObjMap
				var NumX:int = m_Map[0].length;
				var NumY:int = m_Map.length;

				for(var y:int = 0; y < NumY; y += 1){
					var pos_y:int = (y + 0.5) * ImageManager.PANEL_LEN;

					for(var x:int = 0; x < NumX; x += 1){
						var pos_x:int = (x + 0.5) * ImageManager.PANEL_LEN;

						switch(GetMapIndex(m_Map[y][x])){
						case P://プレイヤー位置（生成後は空白として扱われる）
							m_Player.Reset(pos_x, pos_y);
							break;
						}

						if(m_ObjMap[y][x]){
							if(m_ObjMap[y][x].parent == null){//Klllされている
								//再生成：やや適当な処理
								var map_val:int = m_Map[y][x];
								m_Map[y][x] = 0;//同じ値だと再セットされないので、別の値にしておく
								SetBlocks([[map_val]], x, y);
							}else{
								m_ObjMap[y][x].Reset(pos_x, pos_y);
							}
						}
					}
				}
			}
			{//m_ObjList
//*
				var Num:int = m_ObjList.length;
				for(var i:int = 0; i < Num; i++){
					m_ObjList[i].Reset(0, 0);//ひとまず「連結ブロック」だけなのでこれで上手くいくようにしとく
				}
/*/
				CreateClusterBlock();
//*/
			}

			//GameOver表示のリセット
			{
				if(m_GameOverImage){
					m_GameOverImage.parent.removeChild(m_GameOverImage);
				}
			}
		}

		//Update
		private var m_UpdateFunc_Action:Function;
		private function Init_UpdateForEditor():void{
			//通常のアクション用は別で確保
			m_UpdateFunc_Action = m_UpdateFunc;

			//新しくUpdateを設定
			m_UpdateFunc = function():void{
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

					//Menu
					{
						m_TabWindow.Update(deltaTime);
					}
				}else{
					//プレイを試みる
					m_UpdateFunc_Action();

					CheckInput_ForEditor();
				}
			}
		}

		//Input
		protected function CheckInput_ForEditor():void{
			var i:int;

			if(m_EditFlag){
				//Edit => Play
				if(m_Input.IsPress_Edge(IInput.BUTTON_GO_TO_PLAY)){
					GoToPlay();
				}

				//カーソル移動
				{
					var MoveFlag:Boolean = false;

					if(! m_Input.IsPress(IInput.BUTTON_DIR)){
						//カーソル移動

						//Dstを普通に更新
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_L)){
							m_CursorIndexDstX -= 1;
							if(m_CursorIndexDstX < 0){m_CursorIndexDstX = m_Map[0].length-1;}
							MoveFlag = true;
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_R)){
							m_CursorIndexDstX += 1;
							if(m_CursorIndexDstX >= m_Map[0].length){m_CursorIndexDstX = 0;}
							MoveFlag = true;
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_U)){
							m_CursorIndexDstY -= 1;
							if(m_CursorIndexDstY < 0){m_CursorIndexDstY = m_Map.length-1;}
							MoveFlag = true;
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_D)){
							m_CursorIndexDstY += 1;
							if(m_CursorIndexDstY >= m_Map.length){m_CursorIndexDstY = 0;}
							MoveFlag = true;
						}

						//範囲選択でなければSrcにも反映
						if(MoveFlag && ! m_Input.IsPress(IInput.BUTTON_RANGE)){
							m_CursorIndexSrcX = m_CursorIndexDstX;
							m_CursorIndexSrcY = m_CursorIndexDstY;
						}
					}
				}

				var lx:int;
				var rx:int;
				var uy:int;
				var dy:int;
				{
					if(m_CursorIndexSrcX < m_CursorIndexDstX){
						lx = m_CursorIndexSrcX;
						rx = m_CursorIndexDstX;
					}else{
						lx = m_CursorIndexDstX;
						rx = m_CursorIndexSrcX;
					}

					if(m_CursorIndexSrcY < m_CursorIndexDstY){
						uy = m_CursorIndexSrcY;
						dy = m_CursorIndexDstY;
					}else{
						uy = m_CursorIndexDstY;
						dy = m_CursorIndexSrcY;
					}
				}

				//値の指定
				{
					const ValButtonList:Array = [
						IInput.BUTTON_0,
						IInput.BUTTON_1,
						IInput.BUTTON_2,
						IInput.BUTTON_3,
						IInput.BUTTON_4,
						IInput.BUTTON_5,
						IInput.BUTTON_6,
						IInput.BUTTON_7,
						IInput.BUTTON_8,
						IInput.BUTTON_9,
					];

					for(i = 0; i < 10; i += 1){
						if(m_Input.IsPress_Edge(ValButtonList[i])){
							ChangeVal(i, lx, rx, uy, dy);
						}
					}
				}

				//方向指定
				{
					if(m_Input.IsPress(IInput.BUTTON_DIR)){
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_L)){
							ChangeDir(IGameObject.DIR_L, lx, rx, uy, dy);
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_R)){
							ChangeDir(IGameObject.DIR_R, lx, rx, uy, dy);
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_U)){
							ChangeDir(IGameObject.DIR_U, lx, rx, uy, dy);
						}
						if(m_Input.IsPress_Edge(IInput.BUTTON_CURSOR_D)){
							ChangeDir(IGameObject.DIR_D, lx, rx, uy, dy);
						}
					}
				}

				//ブロックのセット
				{
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_O)){
						SetBlock(O, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_W)){
						SetBlock(W, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_Q)){
						SetBlock(Q, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_S)){
						SetBlock(S, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_D)){
						SetBlock(D, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_R)){
						SetBlock(R, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_M)){
//						SetBlock(M, lx, rx, uy, dy);//未完成なのでまだセットできない
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_T)){
						SetBlock(T, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_A)){
						SetBlock(A, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_N)){
						SetBlock(N, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_L)){
						SetBlock(L, lx, rx, uy, dy);
					}
					if(m_Input.IsPress(IInput.BUTTON_BLOCK_E)){
						SetBlock(E, lx, rx, uy, dy);
					}
				}

				//位置の変更
				{//ブロックと同じ処理なので同じ関数を使う
					//ただし、範囲セットはできないのでDstの位置にセットする
					if(m_Input.IsPress(IInput.BUTTON_PLAYER_POS)){
						SetBlock(P, m_CursorIndexDstX, m_CursorIndexDstX, m_CursorIndexDstY, m_CursorIndexDstY);
					}
					if(m_Input.IsPress(IInput.BUTTON_GOAL_POS)){
						SetBlock(G, m_CursorIndexDstX, m_CursorIndexDstX, m_CursorIndexDstY, m_CursorIndexDstY);
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
			//Check : Range
			{
				if(m_CursorIndexSrcX >= m_Map[0].length){m_CursorIndexSrcX = m_Map[0].length-1;}
				if(m_CursorIndexDstX >= m_Map[0].length){m_CursorIndexDstX = m_Map[0].length-1;}
				if(m_CursorIndexSrcY >= m_Map.length){m_CursorIndexSrcY = m_Map.length-1;}
				if(m_CursorIndexDstY >= m_Map.length){m_CursorIndexDstY = m_Map.length-1;}
			}

			//Draw
			{
				ImageManager.DrawCursor(m_CursorShape, m_CursorIndexSrcX, m_CursorIndexDstX, m_CursorIndexSrcY, m_CursorIndexDstY, m_AnimTimer/CURSOR_ANIM_TIME);
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

				UnPause();//Initを呼ぶとPauseがかかっているので（一応毎回呼んでみる）
			}

			//表示切替
			{
				m_TabWindowLayer.visible = false;

				m_Text4Enter.htmlText = "<font face='system' size='16'>" + "Enter：エディットに戻る" + "</font>";
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

			//表示切替
			{
				m_TabWindowLayer.visible = true;

				m_Text4Enter.htmlText = "<font face='system' size='16'>" + "Enter：テストプレイ" + "</font>";
			}

			m_EditFlag = true;
		}

		//Block
		public function SetBlock(i_BlockIndex:int, i_LX:int, i_RX:int, i_UY:int, i_DY:int):void{
			var NumX:int = i_RX - i_LX + 1;
			var NumY:int = i_DY - i_UY + 1;

			var BlockIndexList:Array;
			{
				BlockIndexList = new Array(NumY);
				for(var y:int = 0; y < NumY; y += 1){
					BlockIndexList[y] = new Array(NumX);
					for(var x:int = 0; x < NumX; x += 1){
						BlockIndexList[y][x] = i_BlockIndex;
					}
				}
			}
			SetBlocks(BlockIndexList, i_LX, i_UY);
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

			var reset_cluster:Boolean = false;

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
						if(GetMapIndex(m_Map[y][x]) == index){
							continue;//今セットされてる値と同じだったらいじらない
						}
					}

					//reset_cluster
					{
						if(GetMapIndex(m_Map[y][x]) == L){
							reset_cluster = true;
						}
						if(index == L){
							reset_cluster = true;
						}
					}

					//セット時の位置
					var pos_x:int = (x + 0.5) * ImageManager.PANEL_LEN;
					var pos_y:int = (y + 0.5) * ImageManager.PANEL_LEN;

					//Pre : Delete Old OBJ
					{
						DeleteObjMap(x, y);
					}

					//Pre : Delete Old Info
					{
						switch(index){
						case P:
						case G:
							for(iter_y = 0; iter_y < NumY; iter_y += 1){
								for(iter_x = 0; iter_x < NumX; iter_x += 1){
									if(GetMapIndex(m_Map[iter_y][iter_x]) == index){
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
						switch(index % VAL_OFFSET){
						case P:
							m_Player.SetVal((index / VAL_OFFSET) % 10);
							m_Player.Reset(pos_x, pos_y);
							break;
						case G:
							m_Goal.Reset(pos_x, pos_y);
							break;

						case Q:
							//動かせるブロックを生成
							{
								var block_q:Block_Movable = new Block_Movable();
								block_q.SetVal((index / VAL_OFFSET) % 10);
								block_q.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_q);
								GameObjectManager.Register(block_q);

								m_ObjMap[y][x] = block_q;
							}
							break;
						case S:
							//スイッチを生成
							{
								var block_s:Block_Switch = new Block_Switch();
								block_s.SetVal((index / VAL_OFFSET) % 10);
								block_s.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_s);
								GameObjectManager.Register(block_s);

								m_ObjMap[y][x] = block_s;
							}
							break;
						case D:
							//ドアを生成
							{
								var block_d:Block_Door = new Block_Door(false);
								block_d.SetVal((index / VAL_OFFSET) % 10);
								block_d.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_d);
								GameObjectManager.Register(block_d);

								m_ObjMap[y][x] = block_d;
							}
							break;
						case R:
							//逆ドアを生成
							{
								var block_r:Block_Door = new Block_Door(true);
								block_r.SetVal((index / VAL_OFFSET) % 10);
								block_r.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_r);
								GameObjectManager.Register(block_r);

								m_ObjMap[y][x] = block_r;
							}
							break;
						case M:
							//往復ブロックを生成
							{
								var block_m:Block_Move = new Block_Move();
								block_m.SetVal((index / VAL_OFFSET) % 10);
								block_m.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_m);
								GameObjectManager.Register(block_m);

								m_ObjMap[y][x] = block_m;
							}
							break;
						case T:
							//トランポリンブロックを生成
							{
								var block_t:Block_Trampoline = new Block_Trampoline();
								block_t.SetVal((index / VAL_OFFSET) % 10);
								block_t.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_t);
								GameObjectManager.Register(block_t);

								m_ObjMap[y][x] = block_t;
							}
							break;
						case A:
							//ダッシュブロックを生成
							{
								var block_a:Block_Accel = new Block_Accel();
								block_a.SetVal(GetMapVal(index));
								block_a.SetDir(GetMapDir(index));
								block_a.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_a);
								GameObjectManager.Register(block_a);

								m_ObjMap[y][x] = block_a;
							}
							break;
/*
						case N:
							//トゲブロックを生成
							{
								var block_n:Block_Needle = new Block_Needle();
								block_n.SetVal(GetMapVal(index));
								block_n.SetDir(GetMapDir(index));
								block_n.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(block_n);
								GameObjectManager.Register(block_n);

								m_ObjMap[y][x] = block_n;
							}
							break;
//*/
						case E:
							//エネミーを生成
							{
								var enemy:Enemy_Rolling = new Enemy_Rolling();
								enemy.Reset(pos_x, pos_y);

								m_Root_Gimmick.addChild(enemy);
								GameObjectManager.Register(enemy);

								m_ObjMap[y][x] = enemy;
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

			//連結ブロック用
			{
				if(reset_cluster){
					CreateClusterBlock();
				}
			}

			//Killしたやつの表示をすぐに消す
			{
				GameObjectManager.Update_KillCheck();
			}
		}

		//指定範囲のセットの「指定値」をin_Valに変更する
		public function ChangeVal(in_Val:int, i_LX:int, i_RX:int, i_UY:int, i_DY:int):void{
			for(var y:int = i_UY; y <= i_DY; y += 1){
				var pos_y:int = ImageManager.PANEL_LEN * (y + 0.5);
				for(var x:int = i_LX; x <= i_RX; x += 1){
					var pos_x:int = ImageManager.PANEL_LEN * (x + 0.5);

					var map_index:int = GetMapIndex(m_Map[y][x]);

					//値制限
					switch(map_index){
					case Q:
					case S:
					case D:
					case R:
						if(in_Val >= 4){
							continue;
						}
						break;
					case P:
						if(in_Val >= Player.TYPE_NUM){
							continue;
						}
						break;
					}

					switch(map_index){
					case Q:
					case S:
					case D:
					case R:
					case M:
					case T:
					case A:
					case P:
						m_Map[y][x] = map_index + (in_Val * VAL_OFFSET) + (GetMapDir(m_Map[y][x]) * DIR_OFFSET);
						if(map_index != P){
							m_ObjMap[y][x].SetVal(in_Val);
							m_ObjMap[y][x].Reset(pos_x, pos_y);
						}else{
							m_Player.SetVal(in_Val);
							m_Player.Reset(pos_x, pos_y);
						}
						break;
					}
				}
			}
		}

		//指定範囲のセットの「指定方向」をin_Dirに変更する
		public function ChangeDir(in_Dir:int, i_LX:int, i_RX:int, i_UY:int, i_DY:int):void{
			for(var y:int = i_UY; y <= i_DY; y += 1){
				var pos_y:int = ImageManager.PANEL_LEN * (y + 0.5);
				for(var x:int = i_LX; x <= i_RX; x += 1){
					var pos_x:int = ImageManager.PANEL_LEN * (x + 0.5);

					switch(GetMapIndex(m_Map[y][x])){
					case A:
						m_Map[y][x] = GetMapIndex(m_Map[y][x]) + (GetMapVal(m_Map[y][x]) * VAL_OFFSET) + (in_Dir * DIR_OFFSET);
						m_ObjMap[y][x].SetDir(in_Dir);
						m_ObjMap[y][x].Reset(pos_x, pos_y);
						break;
					}
				}
			}
		}


		public function DeleteObjMap(i_X:int, i_Y:int):void{
			//Check
			{
				if(m_ObjMap[i_Y][i_X] == null){
					return;
				}
			}

			m_ObjMap[i_Y][i_X].Kill();//ここにあったObjは削除する
			m_ObjMap[i_Y][i_X] = null;
		}

		public function ResizeMap(i_W:int, i_H:int):void{
			var x:int;
			var y:int;

			var OldNumX:int = m_Map[0].length;
			var OldNumY:int = m_Map.length;

			//狭める場合、消える位置にあるOBJを削除する
			{
				//横の列
				for(y = i_H; y < OldNumY; y += 1){
					for(x = 0; x < OldNumX; x += 1){
						DeleteObjMap(x, y);
					}
				}

				//縦の列
				for(x = i_W; x < OldNumX; x += 1){
					for(y = 0; y < OldNumY; y += 1){
						DeleteObjMap(x, y);
					}
				}
			}

			//新しいMapの計算
			var NewMap:Array;
			var NewObjMap:Array;
			{
				NewMap = new Array(i_H);
				NewObjMap = new Array(i_H);

				for(y = 0; y < i_H; y += 1){
					NewMap[y] = new Array(i_W);
					NewObjMap[y] = new Array(i_W);

					for(x = 0; x < i_W; x += 1){
						if(x < OldNumX && y < OldNumY){
							NewMap[y][x] = m_Map[y][x];
							NewObjMap[y][x] = m_ObjMap[y][x];
						}else{
							NewMap[y][x] = O;//新しく追加された分は空白にする
							NewObjMap[y][x] = null;
						}
					}
				}
			}

			//今のMapを新しいMapで置き換え（この段階では内部データだけ）
			{
				m_Map = NewMap;
				m_ObjMap = NewObjMap;
			}

			//新しい背景用BMPの生成
			//→最初から最大数確保しているので必要なし

			//変更した部分とその隣の部分を再描画
			{
				//横
				if(OldNumY < i_H){//増やしたとき
					ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_Area(0, OldNumY-1, i_W, i_H - OldNumY));
				}
				if(OldNumY > i_H){//減らしたとき
					ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_Area(0, i_H-1, i_W, 1));
				}

				//縦
				if(OldNumX < i_W){//増やしたとき
					ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_Area(OldNumX-1, 0, i_W - OldNumX, i_H));
				}
				if(OldNumX > i_W){//減らしたとき
					ImageManager.DrawBG(m_BG_BitmapData, m_Map, GetMapRect_Area(i_W-1, 0, 1, i_H));
				}
			}

			//!!ObjMapまわりがまだ不完全かもしれない
			//プレイヤー位置とかはそのままで良いのだろうか
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
				CursorLX = (m_CursorIndexDstX + 0) * ImageManager.PANEL_LEN;
				CursorRX = (m_CursorIndexDstX + 1) * ImageManager.PANEL_LEN;
				CursorUY = (m_CursorIndexDstY + 0) * ImageManager.PANEL_LEN;
				CursorDY = (m_CursorIndexDstY + 1) * ImageManager.PANEL_LEN;
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

			//「設定」で動的にサイズを変更した時のために、マイナス方向への移動チェック
			{
				var MapRX:int = m_Map[0].length * ImageManager.PANEL_LEN;
				if(MapRX < CameraRX){
					m_Root_Game.x = -MapRX + CAMERA_W;
				}
				if(m_Root_Game.x > 0){//マップの左上が必ず左上の隅になるように補正
					m_Root_Game.x = 0;
				}

				var MapDY:int = m_Map.length * ImageManager.PANEL_LEN;
				if(MapDY < CameraDY){
					m_Root_Game.y = -MapDY + CAMERA_H;
				}
				if(m_Root_Game.y > 0){//マップの左上が必ず左上の隅になるように補正
					m_Root_Game.y = 0;
				}
			}
		}


		//=ステージの文字列化と逆変換=

		//Map→文字列
		static public function Map2String(i_Map:Array):String{
			var result:String = "";

			const Number2Char:Array = [
				"0",
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
				"7",
				"8",
				"9",
			];

			const Dir2Char:Array = [
				"u",
				"d",
				"l",
				"r",
			];

			for(var y:int = 0; y < i_Map.length; y += 1){
				for(var x:int = 0; x < i_Map[y].length; x += 1){
					result = result + MapIndex2Char[i_Map[y][x] % VAL_OFFSET];

					var val:int = GetMapVal(i_Map[y][x]);
					if(val > 0){
						result = result + Number2Char[val];
					}

					var dir:int = GetMapDir(i_Map[y][x]);
					if(dir > 0){
						result = result + Dir2Char[dir];
					}
				}

				if(y < i_Map.length-1){
					result = result + "_";
				}
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
				case 'D': NewMap[y].push(D); break;
				case 'R': NewMap[y].push(R); break;
				case 'M': NewMap[y].push(M); break;
				case 'T': NewMap[y].push(T); break;
				case 'A': NewMap[y].push(A); break;
				case 'N': NewMap[y].push(N); break;
				case 'L': NewMap[y].push(L); break;
				case 'E': NewMap[y].push(E); break;
				case '0': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*0; break;
				case '1': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*1; break;
				case '2': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*2; break;
				case '3': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*3; break;
				case '4': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*4; break;
				case '5': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*5; break;
				case '6': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*6; break;
				case '7': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*7; break;
				case '8': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*8; break;
				case '9': NewMap[y][NewMap[y].length-1] += VAL_OFFSET*9; break;
				case 'l': NewMap[y][NewMap[y].length-1] += DIR_OFFSET*IGameObject.DIR_L; break;
				case 'r': NewMap[y][NewMap[y].length-1] += DIR_OFFSET*IGameObject.DIR_R; break;
				case 'u': NewMap[y][NewMap[y].length-1] += DIR_OFFSET*IGameObject.DIR_U; break;
				case 'd': NewMap[y][NewMap[y].length-1] += DIR_OFFSET*IGameObject.DIR_D; break;
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
			so.flush();

			//セーブが完了したので、セーブ後に呼ぶべき処理を呼ぶ
			CallChangeSaveLisetener();
		}

		//#Load
		//指定番号のセーブデータをロード（範囲外ならクリアとみなす）
		static public var CLEAR_MAP:Array;
		public function Load(i_Index:int):void{
			//ローカルセーブを司るSharedObject
			var so:SharedObject = LoadSharedObject();

			var NewMap:Array;
			if(i_Index < 0 || so.data.count <= i_Index){
				//クリア
				if(! CLEAR_MAP){
					CLEAR_MAP = new Array(MAP_H_MIN);
					for(var y:int = 0; y < MAP_H_MIN; y += 1){
						CLEAR_MAP[y] = new Array(MAP_W_MIN);
						for(var x:int = 0; x < MAP_W_MIN; x += 1){
							CLEAR_MAP[y][x] = O;
						}
					}
				}
				NewMap = CLEAR_MAP;
			}else{
				//ステージデータを文字列化したもの
				var stage_str:String = so.data.list[i_Index].stage;

				//文字列→実際のMap配列
				NewMap = String2Map(stage_str);
			}

			//ステージの再構築
			ResizeMap(NewMap[0].length, NewMap.length);//サイズを変更して
			SetBlocks(NewMap, 0, 0);//全てのブロックを再セット
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

		//セーブデータ変更後に行う処理まわり

		//リスナのリスト
		private var m_ChangeSaveListener:Array = [];

		//リスナの追加
		public function AddChangeSaveListener(in_Func:Function):void{
			m_ChangeSaveListener.push(in_Func);
		}

		//リスナの呼び出し
		public function CallChangeSaveLisetener():void{
			var Size:int = m_ChangeSaveListener.length;

			for(var i:int = 0; i < Size; i += 1){
				m_ChangeSaveListener[i]();
			}
		}

		//=GAE用投稿まわり=

		//通信用のやつ
		public var m_NetConnection:NetConnection;

		//通信に応答するやつ
		private var m_Responder_Upload:Responder;
		private var m_Responder_IsLogin:Responder;

		//
		private var m_IsLogin:Boolean = false;

		//
		public function Connect():void{
			if(! m_NetConnection){
				m_NetConnection = new NetConnection();
//*
				m_NetConnection.connect("https://first-lab.appspot.com/cage/api");
/*/
				m_NetConnection.connect("./api");
//*/
			}
		}

		//
		public function Upload():void{
			//Connect
			Connect();

			//Create Responder
			if(! m_Responder_Upload){
				m_Responder_Upload = new Responder(
					//OnComplete
					function(key_name:String):void{
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

		//
		public function CheckLogin():void{
			//Connect
			Connect();

			//Create Responder
			if(! m_Responder_IsLogin){
				m_Responder_IsLogin = new Responder(
					//OnComplete
					function(nick_name:String):void{
						if(nick_name.length > 0){
							m_IsLogin = true;
						}
					},
					//OnFail
					function(results:*):void{
					}
				);
			}

			//Upload
			m_NetConnection.call("is_login", m_Responder_IsLogin);//is_login()
		}

		//
		public function IsLogin():Boolean{
			return m_IsLogin;
		}

		//
		public function OnUploadComplete():void{
			var so:SharedObject = LoadSharedObject();

			var date:Date = new Date();

			so.data.date = {y:date.getFullYear(), m:date.getMonth(), d:date.getDate()};
		}

		//アップロード制限中か
		public function IsUploadLimited():Boolean{
			var so:SharedObject = LoadSharedObject();

			//まだ投稿してないようなら制限なし
			if(so.data.date == null){
				return false;
			}

			//今の日付と違えば制限なし
			{
				var date:Date = new Date();

				if(date.getFullYear() != so.data.date.y){
					return false;
				}
				if(date.getMonth() != so.data.date.m){
					return false;
				}
				if(date.getDate() != so.data.date.d){
					return false;
				}
			}

			//「制限なし」の条件にひっかからなかったので制限あり
			{
				return true;
			}
		}
	}
}
