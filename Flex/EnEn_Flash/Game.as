//author Show=O=Healer

/*
GAEとの通信について
・ルートはメインページの表示に使う
・APIフォルダ以下に、仮想的にAPIのコマンドが置いてあるものとする
　・FlashはAPIにつなぐ
　・GAE側は、API以下のアクセスにはAPI用のPythonファイルをアタッチする


ToDo
・レイアウト
　・ランキングを右に表示
　・色とかをCSSで
・ゲームオーバーでもランキングを随時更新したい
・ユーザ名に「@～」が入ってしまう件
　・gmail.comならOKっぽいc

*/


package{
	//flash
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.filters.*;
	import flash.net.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class Game extends Box{
		//==Const==

		//マスの大きさ
		static public const PANEL_LEN:uint = 16;

		//マスの枚数
		static public const PANEL_NUM_X:int = 12;
		static public const PANEL_NUM_Y:int = 16;

		//右の情報ウィンドウの幅
		static public const INFO_W:int = 100;//右の幅
		static public const INFO_H:int = 30;//上の幅

		//表示画面の大きさ
		static public const CAMERA_W:Number = PANEL_LEN * PANEL_NUM_X + INFO_W;//PANEL_LEN * PANEL_NUM_X;//400;
		static public const CAMERA_H:Number = PANEL_LEN * PANEL_NUM_Y + INFO_H;//300;

		//落下ブロックの初期位置
		static public const INIT_BLOCK_X:uint = ((PANEL_NUM_X-2)/2) * PANEL_LEN;
		static public const INIT_BLOCK_Y:uint = 0;


		//==Var==

		//＃メイン画面
		public var m_Root:Image;//本体がBoxなので、BoxにaddChildすると縦に並ぶので、一段普通のImageをかます
		public var m_GraphicParent_Game:Image;
		private var m_GraphicParent_Interface:Image;

		//＃背景画像
		public var m_ImageBG:Image;
		public var m_BG_BitmapData:BitmapData;

		//＃インフォ背景画像
		public var m_ImageInfo:Image;
		public var m_Info_BitmapData:BitmapData;
		//＃スコア用テキスト
		public var m_ScoreText:TextField;
		//＃炎数用テキスト
		public var m_FireCountText:TextField;
		//＃ユーザ名用テキスト
		public var m_UserNameText:TextField;

		//＃マスの管理
		//各マスのグラフィック
		public var m_GraphicMap:Array;//[NUM_Y][NUM_X] = COLOR_～
		//落下距離のうち最長のもの（全部落下するのを待つために記憶）
		public var m_FallLen:int;

		//＃Input
		public var m_Input:CInput_Keyboard;

		//＃落下ブロック
		public var m_Target:Block;

		//＃火種
		public var m_Fire:Array = [];//vector<CFire>
		public var m_OldFireMap:Array;//

		//＃ゲームオーバーフラグ
		public var m_GameOver:Boolean = false;

		//＃ゲームオーバー表示
		public var m_GameOverText:TextField;


		//==Singleton==
		private static var m_StaticInstance:Game;
		public static function Instance():Game{
			return m_StaticInstance;
		}


		//==Function==

		//!ステージの大きさを仮で返す：ひとまず表示と同じ大きさとしておく
		public function GetStageW():Number{
			return CAMERA_W;
		}
		public function GetStageH():Number{
			return CAMERA_H;
		}

		//!コンストラクタ
		public function Game(){
			//Singleton
			{
				m_StaticInstance = this;
			}
		}

		//!stageなどの初期化が終了した後に呼んでもらう
		public function Init():void{
			var x:int;
			var y:int;

			//==Common Init==
			{
				//スクロールバーの表示はしないようにする
				this.horizontalScrollPolicy = "off";
				this.verticalScrollPolicy = "off";

				//自身の幅を設定しておく
				this.width  = CAMERA_W;
				this.height = CAMERA_H;
			}

			//==画面に相当する部分の初期化==
			{
				//Root
				m_Root = new Image();
				addChild(m_Root);

				//オブジェクトが動き回る用
				m_GraphicParent_Game = new Image();
				m_Root.addChild(m_GraphicParent_Game);

				//インターフェースの表示など用
				m_GraphicParent_Interface = new Image();
//				m_GraphicParent_Interface.width = CAMERA_W;
//				m_GraphicParent_Interface.height = CAMERA_H;
				m_Root.addChild(m_GraphicParent_Interface);

				//ゲームオーバーの文字もここで作ってしまう
				{
					m_GameOverText = new TextField();
					{
						m_GameOverText.border = false;
						m_GameOverText.width = CAMERA_W;
						m_GameOverText.autoSize = "center";
						m_GameOverText.htmlText = <font size="30" color="#ffffff">GAME OVER</font>.toXMLString();
						m_GameOverText.filters = [
							new GlowFilter(0x000000, 1, 4, 4, 16, 1),
							new DropShadowFilter(4, 45, 0x000000, 1, 4, 4, 16)
						];

//						m_GameOverText.x = CAMERA_W/2;// - m_GameOverText.width/2;
						m_GameOverText.y = CAMERA_H/2 - m_GameOverText.height/2;
					}
					m_Root.addChild(m_GameOverText);
				}
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

			//Fireを使いまわすための２次元配列を確保しておく
			{//[NUM_Y][NUM_X] = null
				m_OldFireMap = [];
				for(y = 0; y < PANEL_NUM_Y; y += 1){
					m_OldFireMap.push([]);
					for(x = 0; x < PANEL_NUM_X; x += 1){
						m_OldFireMap[y].push(null);
					}
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

			//Screen
			{
//				m_GraphicParent_Game.removeAllChildren();
				while(m_GraphicParent_Game.numChildren > 0){
					m_GraphicParent_Game.removeChildAt(0);
				}
			}

			//Info
			{//BGの裏に用意する
				//BitmapData
				m_Info_BitmapData = new BitmapData(CAMERA_W, CAMERA_H, false, 0x000044);
				//=>Bitmap
				var bmp_info:Bitmap = new Bitmap( m_Info_BitmapData , PixelSnapping.AUTO , true);
				//=>Image
				m_ImageInfo = new Image(); m_ImageInfo.addChild(bmp_info);
				//=>Display
				m_GraphicParent_Game.addChild(m_ImageInfo);
			}

			//BG
			{
				//BitmapData
				m_BG_BitmapData = new BitmapData(PANEL_LEN * PANEL_NUM_X, PANEL_LEN * PANEL_NUM_Y, true, 0x88888888);
				//=>Bitmap
				var bmp:Bitmap = new Bitmap( m_BG_BitmapData , PixelSnapping.AUTO , true);
				//=>Image
				m_ImageBG = new Image(); m_ImageBG.addChild(bmp);
				//=>Display
				m_GraphicParent_Game.addChild(m_ImageBG);

				//Centering
//				m_ImageBG.x = CAMERA_W/2 - m_BG_BitmapData.width/2;

				//Layout
				m_ImageBG.y = INFO_H;

				//Draw
//				ImageManager.DrawBG(m_BG_BitmapData, m_GraphicMap);
			}

			//Info Text
			{
				//Score
				{
					m_ScoreText = new TextField();
					{
						m_ScoreText.border = false;
						m_ScoreText.width = CAMERA_W;
						m_ScoreText.autoSize = "left";
						m_ScoreText.htmlText = <font face="ume" size="12" color="#ffffff">Score : 000000</font>.toXMLString();
						m_ScoreText.filters = [
							new GlowFilter(0x000000, 1, 4, 4, 16, 1),
//							new DropShadowFilter(1, 45, 0x000000, 1, 4, 4, 16)
						];

						m_ScoreText.x = m_BG_BitmapData.width + 10;
						m_ScoreText.y = INFO_H + 2;
					}
					m_ImageInfo.addChild(m_ScoreText);
				}
				//FireCount
				{
					m_FireCountText = new TextField();
					{
						m_FireCountText.border = false;
						m_FireCountText.width = CAMERA_W;
						m_FireCountText.autoSize = "left";
						m_FireCountText.htmlText = <font face="ume" size="12" color="#ffffff">Fire : 000000</font>.toXMLString();
						m_FireCountText.filters = [
							new GlowFilter(0x000000, 1, 4, 4, 16, 1),
//							new DropShadowFilter(1, 45, 0x000000, 1, 4, 4, 16)
						];

						m_FireCountText.x = m_BG_BitmapData.width + 10;
						m_FireCountText.y = 50;
					}
					m_ImageInfo.addChild(m_FireCountText);
				}
				//m_UserNameText
				{
					m_UserNameText = new TextField();
					{
						m_UserNameText.border = false;
						m_UserNameText.width = CAMERA_W;
						m_UserNameText.autoSize = "left";
						m_UserNameText.htmlText = <font face="ume" size="16" color="#ffffff"></font>.toXMLString();
						m_UserNameText.filters = [
							new GlowFilter(0x000000, 1, 4, 4, 16, 1),
//							new DropShadowFilter(1, 45, 0x000000, 1, 4, 4, 16)
						];

						m_UserNameText.x = 10;
						m_UserNameText.y = 2;
					}
					m_ImageInfo.addChild(m_UserNameText);
				}
			}

			//マスの管理
			{
				//m_GraphicMap
				{
					//Reset
					m_GraphicMap = [];

					//Create [NUM_Y][NUM_X]
					for(y = 0; y < PANEL_NUM_Y; y += 1){
						m_GraphicMap.push([]);

						for(x = 0; x < PANEL_NUM_X; x += 1){
							if(y < PANEL_NUM_Y-1){
								m_GraphicMap[y].push(ImageManager.GRAPHIC_INDEX_EMPTY);
							}else{
								m_GraphicMap[y].push(ImageManager.GRAPHIC_INDEX_WHITE);
							}
						}
					}
				}
			}

			//火種
			{
				var SrcX:int = PANEL_NUM_X-1;
				var SrcY:int = PANEL_NUM_Y-1;
				var DstX:int = PANEL_NUM_X-2;
				var DstY:int = PANEL_NUM_Y-1;

				//火種の作成
				{
					var fire:CFire = new CFire();
					fire.Init(SrcX, SrcY, DstX, DstY);
					m_ImageBG.addChild(fire);
					m_Fire = [fire];
				}

				//火種の位置を対応する状態にしておく
				{
					m_GraphicMap[SrcY][SrcX] = ImageManager.GRAPHIC_INDEX_BLACK;
				}
			}

			//m_Target
			{
				if(m_Target){m_Target.parent.removeChild(m_Target);}
				m_Target = CreateNextTarget();
				m_ImageBG.addChild(m_Target);
			}

			//
			{
				m_VanishCount = 0;
			}

			//m_GameOver
			{
				m_GameOver = false;

				m_GameOverText.visible = false;
			}

			//スコア
			{
				ResetScore();
				RefreshFireCountText();
			}

			//ユーザ名
			{
				LoadUserName();
			}

			{//火種の位置とかのリセットのため、仮で一度まわす
				DoVanish(0.0);
			}
		}


		//=更新まわり=

		//!毎フレーム更新のために呼ばれる関数
		private function Update():void{
			var deltaTime:Number = 1.0 / 24.0;

			//Input
			{
				UpdateInput();
			}

			//m_GameOver
			{
				if(m_GameOver){
					return;
				}
			}

			//Rot
			{
				UpdateRotate();
			}

			//ブロックを動かす
			{
				UpdateMove(deltaTime);
			}

			//火種の更新
			{
				DoVanish(deltaTime);
			}

			//情報表示更新
			{
				RefreshFireCountText();
			}
		}


		//=Input=

		private function UpdateInput():void{
			//Update
			{
				m_Input.Update();
			}

			//Check:Reset
			{
				if(m_Input.IsPress_Edge(IInput.BUTTON_RESET)){
					Reset();
				}
			}
		}


		//=Rotate=

		private function UpdateRotate():void{
			//必要ならm_Modeのチェック（今はVanish中に先行入力で回転できるようになっている）

			var x:int;
			var y:int;

			var PosX:int;
			var PosY:int;

			//回転ボタンが押されていたら回転させる
			if(m_Input.IsPress_Edge(IInput.BUTTON_ROTATE)){
				var RotFlag:Boolean = true;
				{
					var BaseX:int = m_Target.x / PANEL_LEN;
					var BaseY:int = m_Target.y / PANEL_LEN;

					var Pattern:Array = m_Target.GetPattern_Rot_Next();

					for(y = 0; y < Pattern.length; y += 1){
						for(x = 0; x < Pattern[y].length; x += 1){
							if(Pattern[y][x] != 0){
								PosX = BaseX + x;
								PosY = BaseY + y;

								if(IsThereBlock(PosX, PosY)){
									RotFlag = false;

									break;//できれば外側のループまで飛ばしたい
								}
							}
						}
					}
				}

				if(RotFlag){
					m_Target.Rotate();
				}
			}
		}

		//=Move=

		//落下速度：「移動距離/秒数」
		static public const FALL_V:Number     = PANEL_LEN / 1.0;
		static public const FALL_V_MAX:Number = PANEL_LEN / 0.08;//十字キー下を押してる時の処理

		//接地してもしばらくは動けるようにするためのタイマ
		public var m_GroundStopTimer:Number = 0.0;
		static public const GROUND_STOP_TIME:Number = 0.1;

		private function UpdateMove(i_DeltaTime:Number):void{
			//ブロックの左下がブロックの原点という前提

			var x:int;
			var y:int;

			var PosX:int;
			var PosY:int;

			var Pattern:Array = m_Target.GetPattern_Now();

			//Check
			{
				//End
				var InitX:int = INIT_BLOCK_X / PANEL_LEN;
				var InitY:int = INIT_BLOCK_Y / PANEL_LEN;

				for(y = 0; y < Pattern.length; y += 1){
					for(x = 0; x < Pattern[y].length; x += 1){
						if(Pattern[y][x] != 0){
							PosX = InitX + x;
							PosY = InitY + y;

							if(IsThereBlock(PosX, PosY)){
								//スタート位置にブロックがすでに積まれていたら、それが燃えてなくなるまで移動できない
								return;
							}
						}
					}
				}
			}

			//Check : Input
			{//横移動
				var BaseX:int = m_Target.x / PANEL_LEN;
				var BaseY:int = m_Target.y / PANEL_LEN;

				var TrgX:int = BaseX;
				{
					if(m_Input.IsPress_Edge(IInput.BUTTON_L)){
						TrgX -= 1;
					}
					if(m_Input.IsPress_Edge(IInput.BUTTON_R)){
						TrgX += 1;
					}
				}

				var MoveFlag:Boolean = true;
				var StopFlag_ForSideMove:Boolean = false;//めりこまないように補正（応急処置的なので、再設計した方が良い）
				{
					if(BaseX != TrgX){
						for(y = 0; y < Pattern.length; y += 1){
							for(x = 0; x < Pattern[y].length; x += 1){
								if(Pattern[y][x] != 0){
									PosX = TrgX  + x;
									PosY = BaseY + y;

									//StopFlag_ForSideMove
									if(IsThereBlock(PosX, PosY+1)){
										StopFlag_ForSideMove = true;
									}

									if(IsThereBlock(PosX, PosY)){
										MoveFlag = false;

										break;//できれば外側のループまで飛ばしたい
									}
								}
							}
						}
					}else{
						MoveFlag = false;//trueでも良いけど一応
					}
				}

				if(MoveFlag){
					m_Target.x = TrgX * PANEL_LEN;

					if(StopFlag_ForSideMove){
						//Yが行き過ぎないように補正
						m_Target.y = ((int)(m_Target.y / PANEL_LEN)) * PANEL_LEN;
					}
				}
			}

			//Fall
			{//下移動
				var VY:Number = FALL_V;

				if(m_Input.IsPress(IInput.BUTTON_D)){
					VY = FALL_V_MAX;
				}
				m_Target.y += VY * i_DeltaTime;
			}

			//Check : Ground
			{//下移動：衝突チェック
				var StopFlag:Boolean;
				{
					StopFlag = false;

					for(y = 0; y < Pattern.length; y += 1){
						for(x = 0; x < Pattern[y].length; x += 1){
							if(Pattern[y][x] != 0){
								PosX = m_Target.x / PANEL_LEN + x;
								PosY = m_Target.y / PANEL_LEN + y + 1;

								if(IsThereBlock(PosX, PosY)){
									StopFlag = true;

									//Yが行き過ぎないように補正
									m_Target.y = ((int)(m_Target.y / PANEL_LEN)) * PANEL_LEN;

									break;//できれば外側のループまで飛ばしたい
								}
							}
						}
					}
				}

				if(StopFlag){
					//接地してもしばらくはそのまま
					if(m_GroundStopTimer >= GROUND_STOP_TIME){
						//接地してから一定時間過ぎたら次に移る
						PosX = m_Target.x / PANEL_LEN;
						PosY = m_Target.y / PANEL_LEN;

						//Regist
						{
							for(y = 0; y < Pattern.length; y += 1){
								for(x = 0; x < Pattern[y].length; x += 1){
									if(Pattern[y][x] != 0){
										m_GraphicMap[PosY + y][PosX + x] = m_Target.m_Color;//!!範囲チェックがちゃんとしてる前提
									}
								}
							}
						}

						//Refresh BG Color
						{
							ImageManager.DrawBG(m_BG_BitmapData, m_GraphicMap);
						}

						//Next Block
						{
							if(m_Target){m_Target.parent.removeChild(m_Target);}
							m_Target = CreateNextTarget();
							m_ImageBG.addChild(m_Target);
						}
					}

					//接地タイマーを進める
					m_GroundStopTimer += i_DeltaTime;
				}else{
					//接地してないならタイマーをリセット
					m_GroundStopTimer = 0.0;
				}
			}
		}


		//=Vanish=

		private function CheckVanish():void{
			//Check : Vanish

			var x:int;
			var y:int;
			var i:int;
			var fire:CFire;

//			var DestroyCount:uint = 0;

			//前回のFireを使いまわせるようにしておく
			{
				var FireNum:int = m_Fire.length;
				for(i = 0; i < FireNum; i += 1){
					fire = m_Fire[i];
					x = fire.DstX;
					y = fire.DstY;

					if(! m_OldFireMap[y][x] && ! fire.EndFlag){
						//使いまわすためにセット
						m_OldFireMap[y][x] = fire;
					}else{
						//すでに別のが使いまわしようにセットされていたら、こいつは削除する
						fire.parent.removeChild(fire);
					}
				}
			}

			//Reset FIre List
			{
				m_Fire = [];
			}

			//現在の炎から、上下左右に移動できるようなら移動させる
			{
				var CheckAndCreateFire:Function = function(i_SrcX:int, i_SrcY:int, i_DstX:int, i_DstY:int):void{
					if(IsTherePaper(i_DstX, i_DstY)){//移動先が燃やせる
						//動かす炎の作成（使いまわせるものがあったら、そっちを採用）
						var fire:CFire;
						{
							if(m_OldFireMap[i_SrcY][i_SrcX]){
								fire = m_OldFireMap[i_SrcY][i_SrcX];
								m_OldFireMap[i_SrcY][i_SrcX] = null;//使い回しが決定したので、もうこいつは使いまわさない
							}else{
								fire = new CFire();
								m_ImageBG.addChild(fire);
							}
						}

						//
						{
							fire.Init(i_SrcX, i_SrcY, i_DstX, i_DstY);
						}

						//
						{
							m_Fire.push(fire);
						}

//						//
//						{
//							DestroyCount += 1;
//						}
					}
				}

				for(y = 0; y < PANEL_NUM_Y; y += 1){
					for(x = 0; x < PANEL_NUM_X; x += 1){
						if(m_OldFireMap[y][x]){//火種がある
							CheckAndCreateFire(x, y, x, y-1);//上
							CheckAndCreateFire(x, y, x, y+1);//下
							CheckAndCreateFire(x, y, x-1, y);//左
							CheckAndCreateFire(x, y, x+1, y);//右
						}
					}
				}
			}

			//使いまわされなかったものは削除
			{
				for(y = 0; y < PANEL_NUM_Y; y += 1){
					for(x = 0; x < PANEL_NUM_X; x += 1){
						if(m_OldFireMap[y][x]){//移動しない火種があり、
							if(! m_OldFireMap[y][x].EndFlag){//消失中でなければ
								m_OldFireMap[y][x].EndFlag = true;//消失中にして
								m_Fire.push(m_OldFireMap[y][x]);//消失の実行に移る
							}else{//すでに消失中であったなら
								m_OldFireMap[y][x].parent.removeChild(m_OldFireMap[y][x]);//消失させる
							}
							m_OldFireMap[y][x] = null;
						}
					}
				}
			}

			if(m_Fire.length == 0){//DestroyCount
				//火種が消えてしまったのでゲームオーバーにする
				m_GameOver = true;
				m_GameOverText.visible = true;

				Save();
			}else{
				//この時点での火種の数をスコアに加算する
				AddScore(m_Fire.length);
			}
		}


		static public const VANISH_TIME_FIRST:Number = 2.0;
		static public const VANISH_TIME_HALF_COUNT:int = 2000;
		public var m_VanishTimer:Number = 0.0;
		public var m_VanishCount:int = 0;
		private function DoVanish(i_DeltaTime:Number):void{
			var i:int;

			//Timer
			{
				m_VanishTimer += i_DeltaTime;
			}

			//Time
			var VanishTime:Number;
			{
				VanishTime = VANISH_TIME_FIRST / (1.0 + 1.0*m_VanishCount/VANISH_TIME_HALF_COUNT);
				m_VanishCount += 1;
			}

			var ratio:Number;
			{
				ratio = m_VanishTimer / VanishTime;
				if(ratio > 1.0){ratio = 1.0;}
			}

			//
			{
				var FireNum:int = m_Fire.length;
				for(i = 0; i < FireNum; i += 1){
					var fire:CFire = m_Fire[i];

					//炎のグラフィックとかの更新
					{

						fire.Update(i_DeltaTime);
					}

					if(! fire.EndFlag){
						//移動中

						//Fire Pos
						{
							fire.x = (MyMath.Lerp(fire.SrcX, fire.DstX, ratio) + 0.5) * PANEL_LEN;
							fire.y = (MyMath.Lerp(fire.SrcY, fire.DstY, ratio) + 0.5) * PANEL_LEN;
						}

						//Src:Black=>Empty
						{
							m_GraphicMap[fire.SrcY][fire.SrcX] = MyMath.Lerp(ImageManager.GRAPHIC_INDEX_BLACK, ImageManager.GRAPHIC_INDEX_EMPTY, ratio);
						}

						//Dst:White=>Black
						{
							m_GraphicMap[fire.DstY][fire.DstX] = MyMath.Lerp(ImageManager.GRAPHIC_INDEX_WHITE, ImageManager.GRAPHIC_INDEX_BLACK, ratio);
						}
					}else{
						//行き先がないので消失中

						//Fire Ratio
						{
							fire.SetRatio(1.0 - ratio);
						}

						//Dst:Black=>Empty
						{
							m_GraphicMap[fire.DstY][fire.DstX] = MyMath.Lerp(ImageManager.GRAPHIC_INDEX_BLACK, ImageManager.GRAPHIC_INDEX_EMPTY, ratio);
						}
					}
				}
			}

			//
			{
				if(m_VanishTimer >= VanishTime){
/*
					GoToMode(MODE_VANISH_CHECK);
/*/
					m_VanishTimer -= VanishTime;
					CheckVanish();
					DoVanish(0.0);
//*/
				}
			}

			//
			{
				//Draw
				ImageManager.DrawBG(m_BG_BitmapData, m_GraphicMap);
			}
		}


		//=Fall=

		private function CheckFall():void{
			//Check : Fall
			//!!不要
		}

		private function DoFall(i_DeltaTime:Number):void{
			//Do : Fall
			//!!不要
		}


		//=Block=

		private function CreateNextTarget():Block{
			var result:Block;
			{
				result = new Block();

				var Type:int = MyMath.RandomRange(Block.TYPE_NUM);
				result.Init(ImageManager.GRAPHIC_INDEX_WHITE, Type);

				result.x = INIT_BLOCK_X;
				result.y = INIT_BLOCK_Y;
			}

			return result;
		}

		public function IsThereBlock(i_X:int, i_Y:int):Boolean{
			//Check : Range
			{
				if(i_X < 0){return true;}
				if(i_X >= PANEL_NUM_X){return true;}
				if(i_Y < 0){return true;}
				if(i_Y >= PANEL_NUM_Y){return true;}
			}

			//完全に透明になるまでは壁として扱う
			return m_GraphicMap[i_Y][i_X] > ImageManager.GRAPHIC_INDEX_EMPTY;
		}

		//このマスは燃やせるか
		public function IsTherePaper(i_X:int, i_Y:int):Boolean{
			//Check : Range
			{
				if(i_X < 0){return false;}
				if(i_X >= PANEL_NUM_X){return false;}
				if(i_Y < 0){return false;}
				if(i_Y >= PANEL_NUM_Y){return false;}
			}

			//
			return m_GraphicMap[i_Y][i_X] == ImageManager.GRAPHIC_INDEX_WHITE;
		}


		//=スコアまわり=

		public var m_Score:int = 1;//s0;

		public function AddScore(i_Val:int):void{
			m_Score += i_Val;

			ResetScoreText();
		}

		public function ResetScore():void{
			m_Score = 1;//0;

			ResetScoreText();
		}

		public function ResetScoreText():void{
			m_ScoreText.htmlText = "<font face='ume' size='12' color='#FFFFFF'>Score : " + m_Score + "</font>";
		}

		public function RefreshFireCountText():void{
			m_FireCountText.htmlText = "<font face='ume' size='12' color='#FFFFFF'>Fire : " + m_Fire.length + "</font>";
		}


		//=セーブまわり=

		private var m_NetConnection:NetConnection;

		private var m_Responder_Save:Responder;

		private var m_Responder_LoadUserName:Responder;

		public function Save():void{
			if(! m_NetConnection){
				m_NetConnection = new NetConnection();
				m_NetConnection.connect("http://enen-pazzle.appspot.com/api/");
			}
/*
			//接続失敗なら戻る
			{
				if(! m_NetConnection.connected){
					m_NetConnection = null;//次回また接続を試みる
					return;
				}
			}
//*/
			if(! m_Responder_Save){
				m_Responder_Save = new Responder(
					//OnComplete
					function():void{
					},
					//OnFail
					function(results:*):void{
					}
				);
			}

			var data:Object = {
				score:""+m_Score,//文字列化する
				name:m_UserName
			};

			//Save
			m_NetConnection.call("save", m_Responder_Save, data);//save(data)     
		}

		//=ユーザネームまわり=

		public var m_UserName:String = "NO NAME";

		public function LoadUserName():void{
			if(! m_NetConnection){
				m_NetConnection = new NetConnection();
//				m_NetConnection.connect("http://localhost:8080/");
				m_NetConnection.connect("http://enen-pazzle.appspot.com/api/");
			}
/*
			//接続失敗なら戻る
			{
				if(! m_NetConnection.connected){
					m_NetConnection = null;//次回また接続を試みる

					ResetUserName(m_UserName);//現在の名前を採用

					return;
				}
			}
//*/
			if(! m_Responder_LoadUserName){
				m_Responder_LoadUserName = new Responder(
					//OnComplete
					function(i_UserName:String):void{
						ResetUserName(i_UserName);
					},
					//OnFail
					function(results:*):void{
/*
						ResetUserName("NO NAME");
/*/
						for each (var thisResult:String in results){
							ResetUserName(thisResult);
						}
//*/
					}
				);
			}

			//Save
			m_NetConnection.call("load_user_name", m_Responder_LoadUserName);//load_user_name()
		}

		public function ResetUserName(i_UserName:String):void{
			m_UserName = i_UserName;

			m_UserNameText.htmlText = "<font face='ume' size='16' color='#FFFFFF'>Name : " + m_UserName + "</font>";
		}
	}
}


//flash
import flash.display.*;
import flash.events.*;
import flash.utils.*;
import flash.geom.*;
//mxml
import mx.core.*;
import mx.containers.*;
import mx.controls.*;


class CFire extends Image
{
	public var SrcX:int;
	public var SrcY:int;
	public var DstX:int;
	public var DstY:int;

	public var EndFlag:Boolean = false;

	public var m_Fire:TeraFire;

	public function CFire(){
		m_Fire = ImageManager.CreateFire();
		addChild(m_Fire);
	}

	public function Init(i_SrcX:int, i_SrcY:int, i_DstX:int, i_DstY:int):void{
		{
			SrcX = i_SrcX;
			SrcY = i_SrcY;
			DstX = i_DstX;
			DstY = i_DstY;
		}
	}

	public function SetRatio(i_Ratio:Number):void{
		this.alpha = i_Ratio;
	}

	public function Update(i_DeltaTime:Number):void{
		m_Fire.loop();
	}
}

