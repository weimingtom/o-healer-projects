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
		static public const CAMERA_W:Number = 400;
		static public const CAMERA_H:Number = 300;

		//＃マップの要素
		static public const O:int = 0;
		static public const W:int = 1;

		//==Var==

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
		public var m_Map:Array;//[NUM_Y][NUM_X]

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
				addEventListener("enterFrame", function(event:Event):void {
					Update();
				});
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
	}
}
