/*
　「ウォール＋ホール＝フォール」
　・ブロックではなくスペースを配置するパズル
　・画面上の「CLEAR」の文字を並べたらクリア

　操作方法（画面を２回ぐらいクリックしないと動かせないようです）
　・← →：左右移動
　・↓：加速
　・SPACE(半角)：回転
　・R：リスタート

　補足
　・スペースで文字を消しても、また上から出てきます
*/

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.filters.*;
	import flash.ui.*;
	import flash.system.*;

	public class GameMain extends Sprite {
		//==Const==

		//移動時のパラメータ
		static public const MOVE_VY_NORMAL:Number = 10.0;
		static public const MOVE_VY_MIN:Number = 5.0;
		static public const MOVE_VY_MAX:Number = 150.0;

		//落下時のパラメータ
		static public const FALL_GRAVITY:Number = 200.0;

		//モード
		static public var ModeIter:int = 0;//enumもどき
		static public const MODE_CREATE_BLOCK:int	= ModeIter++;//次のブロックを生成
		static public const MODE_MOVE:int			= ModeIter++;//ブロックを操作中
		static public const MODE_SET:int			= ModeIter++;//ブロックをセット中
		static public const MODE_CHECK:int			= ModeIter++;//消えるものがあるかチェック中
//		static public const MODE_VANISH:int			= ModeIter++;//消し中
		static public const MODE_FALL:int			= ModeIter++;//落下中
		static public const MODE_CHECK_CLEAR:int	= ModeIter++;//クリアチェック
		static public const MODE_GAME_CLEAR:int		= ModeIter++;//クリア
		static public const MODE_GAME_OVER:int		= ModeIter++;//ゲームオーバー

		//汎用定数
		static public const POS_ZERO:Point = new Point(0,0);


		//==Var==

		//#レイヤー
		//- ルート
		public var m_Layer_Root:Sprite = new Sprite();
		//-- ブロック（登録不要だが、デバッグ用に一応隠して表示）
		public var  m_Layer_Block:Sprite = new Sprite();
		//-- 壁（削られてるように見える部分。実は一番奥に表示）
		public var  m_Layer_Wall:Sprite = new Sprite();
		//-- 壁枠（壁とスペースの境界部分。壁の上に重ねて表示）
		public var  m_Layer_WallLine:Sprite = new Sprite();
		//-- 背景（スペースで透けて見えるやつ。実は一番手前に表示）
		public var  m_Layer_BG:Sprite = new Sprite();
		//-- インターフェース
		public var  m_Layer_Interface:Sprite = new Sprite();

		//#Bitmap
		//- 実際に表示に使われる壁画像
		public var m_BitmapData_Wall:BitmapData;
		//- 実際に表示に使われる壁枠画像
		public var m_BitmapData_WallLine:BitmapData;
		//- 壁枠画像を初期化するための画像
		public var m_BitmapData_WallLine_Ori:BitmapData;
		//- 壁枠に重ねて陰を表現するための画像
		public var m_BitmapData_WallLineShade:BitmapData;
		//- 実際に表示に使われる背景画像
		public var m_BitmapData_BG:BitmapData;
		//- 背景画像を初期化するための画像
		public var m_BitmapData_BG_Ori:BitmapData;
		//- インターフェース（主にクリア表現時のみで使う）
		public var m_BitmapData_Interface:BitmapData;
		//- 汎用
		public var m_BitmapData_Util:BitmapData;

		//#ブロック（プレイヤーが操作するやつ）
		//- 本体
		public var m_Block:Block;
		//- ブロックの落下速度
		public var m_FallVY:Number = MOVE_VY_NORMAL;

		//#マップ（現在の壁・空白の状況）
		public var m_MapInfo:MapInfo;

		//#落下するブロックとかの情報
		public var m_FallGroupList:Array = [];

		//#現在のモード
		public var m_Mode:int = 0;//最初のモードから開始
		public var m_ModeTimer:Number = 0.0;
		public function GoToMode(in_Mode:int):void{
			m_Mode = in_Mode;
			m_ModeTimer = 0.0;
		}


		//==Function==


		//#Init

		public function GameMain() {
/*
			//Init Later (for Using "stage" etc.)
			addEventListener(Event.ADDED_TO_STAGE, Init);
/*/
			addEventListener(
				Event.ADDED_TO_STAGE,//ステージに追加されたら
				function(e:Event):void{
					var loader:Loader = new Loader();
					loader.load(new URLRequest(ImageCreator.BITMAP_URL), new LoaderContext(true));//画像のロードを開始して
					loader.contentLoaderInfo.addEventListener(
						Event.COMPLETE,//ロードが完了したら
						function(e:Event):void{
							ImageCreator.Ready(loader.content);//それを加工して保持した後

							Init();//初期化に入る
						}
					);
				}
			);
//*/
		}

		public function Init(e:Event = null):void{
			var W:int = stage.stageWidth;
			var H:int = stage.stageHeight;

			//Init Once Only
			{
				removeEventListener(Event.ADDED_TO_STAGE, Init);
			}

			//画面外
			{
				//画面外は真っ暗にする
				{
					addChild(new Bitmap(new BitmapData(W, H, false, 0x000000)));
				}

				//画面外に表示がはみ出ないようにマスクする
				{
					var mask_root:Bitmap = new Bitmap(new BitmapData(ImageCreator.BMP_W, ImageCreator.BMP_H, false, 0x000000));
					m_Layer_Root.addChild(mask_root);
					m_Layer_Root.mask = mask_root;
				}
			}

			//Layer
			{
				m_Layer_Root.x = W/2 - ImageCreator.BMP_W/2;
				addChild(m_Layer_Root);
				{
					m_Layer_Root.addChild(m_Layer_Block);
					m_Layer_Root.addChild(m_Layer_Wall);
					m_Layer_Root.addChild(m_Layer_WallLine);
					m_Layer_Root.addChild(m_Layer_BG);
					m_Layer_Root.addChild(m_Layer_Interface);
				}
			}

			//Map
			{
				m_MapInfo = new MapInfo();
			}

			//Bitmap
			{
				const BitmapW:int = MapInfo.NUM_X * ImageCreator.PANEL_LEN;
				const BitmapH:int = MapInfo.NUM_Y * ImageCreator.PANEL_LEN;

				//壁画像：m_MapInfoを元に描いて登録
				m_BitmapData_Wall = ImageCreator.CreateWallBitmapData(m_MapInfo.m_BitmapData);
				var bmp_wall:Bitmap = new Bitmap(m_BitmapData_Wall);
				bmp_wall.y = -ImageCreator.BMP_H;
				m_Layer_Wall.addChild(bmp_wall);

				//壁枠の陰画像：黒いのを用意して登録
				m_BitmapData_WallLineShade = new BitmapData(BitmapW, BitmapH, true, 0xFF000000);
				m_Layer_WallLine.addChild(new Bitmap(m_BitmapData_WallLineShade));

				//壁枠の画像：描いて登録
				m_BitmapData_WallLine = ImageCreator.CreateWallLine();
				m_Layer_WallLine.addChild(new Bitmap(m_BitmapData_WallLine));

				//壁枠の画像_初期化用：壁枠の画像をコピー
				m_BitmapData_WallLine_Ori = m_BitmapData_WallLine.clone();

				//背景の画像：描いて登録
				m_BitmapData_BG = ImageCreator.CreateBG();
				m_Layer_BG.addChild(new Bitmap(m_BitmapData_BG));

				//背景の画像_初期化用：背景の画像をコピー
				m_BitmapData_BG_Ori = m_BitmapData_BG.clone();

				//インターフェース（主にクリア表現時のみで使う）
				m_BitmapData_Interface = new BitmapData(BitmapW, BitmapH, true, 0x00000000);
				m_Layer_Interface.addChild(new Bitmap(m_BitmapData_Interface));

				//汎用：サイズだけ同じにして値は適当
				m_BitmapData_Util = new BitmapData(BitmapW, BitmapH, true, 0x00000000);
				//Debug
				//m_Layer_Root.addChild(new Bitmap(m_BitmapData_Util));
			}

			//Key
			{
				//Func
				var keyFunc:Function = function(event:KeyboardEvent, in_IsDown:Boolean):void{
					//Move : LR
					if(in_IsDown){
						switch(event.keyCode){
						case Keyboard.LEFT:		TryToMove(-1, 0); break;
						case Keyboard.RIGHT:	TryToMove( 1, 0); break;
						}
					}

					//Move : UD
					if(in_IsDown){
						switch(event.keyCode){
						case Keyboard.DOWN:		m_FallVY = MOVE_VY_MAX; break;
						case Keyboard.UP:		m_FallVY = MOVE_VY_MIN; break;
						}
					}
					if(! in_IsDown){
						switch(event.keyCode){
						case Keyboard.DOWN:		m_FallVY = MOVE_VY_NORMAL; break;
						case Keyboard.UP:		m_FallVY = MOVE_VY_NORMAL; break;
						}
					}

					//Rot
					if(in_IsDown){
						switch(event.keyCode){
						case Keyboard.SPACE:	TryToRot(true); break;
						}
					}

					//Restart
					if(in_IsDown){
						const KEY_R:int = 82;
						switch(event.keyCode){
						case KEY_R:	Reset(); break;
						}
					}
				};

				//Down
				stage.addEventListener(
					KeyboardEvent.KEY_DOWN,
					function(event:KeyboardEvent):void{
						keyFunc(event, true);
					}
				);

				//UP
				stage.addEventListener(
					KeyboardEvent.KEY_UP,
					function(event:KeyboardEvent):void{
						keyFunc(event, false);
					}
				);
			}

			//Call "Update"
			{
				addEventListener(Event.ENTER_FRAME, Update);
			}
		}

		public function Reset():void{
			//m_MapInfo
			{
				m_MapInfo.Reset();
			}

			//m_Block
			{
				VanishBlock();
			}

			//Mode
			{
				GoToMode(0);//最初の状態から始める
			}

			//Redraw
			{
				ImageCreator.RedrawWallBitmapData(m_BitmapData_Wall, m_MapInfo.m_BitmapData);
				m_BitmapData_Interface.fillRect(m_BitmapData_Interface.rect, 0x00000000);
			}
		}


		//#Update

		public function Update(e:Event=null):void{
			const DeltaTime:Number = 1/24.0;

			//モードごとの処理
			{
				m_ModeTimer += DeltaTime;

				switch(m_Mode){
				case MODE_CREATE_BLOCK://操作するブロックを生成
					Update_CreateBlock(DeltaTime);
					break;
				case MODE_MOVE://ブロックを操作中
					Update_Move(DeltaTime);
					break;
				case MODE_SET://ブロックをセット中
					Update_Set(DeltaTime);
					break;
				case MODE_CHECK://落下するものがあるかチェック中
					Update_Check(DeltaTime);
					break;
				//case MODE_VANISH://消し中
				//	Update_Vanish(DeltaTime);
				//	break;
				case MODE_FALL://落下中
					Update_Fall(DeltaTime);
					break;
				case MODE_CHECK_CLEAR://クリアチェック
					Update_CheckClear(DeltaTime);
					break;
				case MODE_GAME_CLEAR://クリア
					Update_GameClear(DeltaTime);
					break;
				case MODE_GAME_OVER://ゲームオーバー
					Update_GameOver(DeltaTime);
					break;
				}
			}

			//Redraw
			{
				Redraw();
			}
		}

		//Update : CreateBlock
		public function Update_CreateBlock(in_DeltaTime:Number):void{
			//操作するブロックを生成
			{
				CreateNextBlock();
			}

			//そのブロックが他のブロックにめり込んでたらゲームオーバー
			{
				if(! CheckMove(0,0)){
					GoToMode(MODE_GAME_OVER);

					return;
				}
			}

			//問題なければ操作モードに移行
			{
				GoToMode(MODE_MOVE);
			}
		}

		//Update : Move
		public function Update_Move(in_DeltaTime:Number):void{
			//ブロックを徐々に落下させる
			{
				var block_y_old:int = m_Block.y / ImageCreator.PANEL_LEN;

				//Move : Fall
				{
					m_Block.y += m_FallVY * in_DeltaTime;
				}

				var block_y_new:int = m_Block.y / ImageCreator.PANEL_LEN;

				if(block_y_old < block_y_new){//１マス次に進んだか
					//一度に２マス以上進むことは考慮していない
					var offset_y:int = -1;
					{
						if(!CheckMove(0, 0)){offset_y = 0;}
						if(!CheckMove(0, 1)){offset_y = 1;}
					}

					if(offset_y >= 0){//今の位置に壁などがあるか（マスをまたぎながら移動するので２マス分調べる）
						//あるなら今のブロックを設置させて次のブロックを生成する

						//セット位置にブロックを移動
						m_Block.y = ImageCreator.PANEL_LEN * (block_y_old + offset_y);

						GoToMode(MODE_SET);
					}
				}
			}
		}

		//Update : Set
		public function Update_Set(in_DeltaTime:Number):void{
			var block_parent:DisplayObjectContainer = m_Block.parent;

			//設置
			{
				m_MapInfo.AddBlock(
					m_Block.GetBlockArray(),
					m_Block.x / ImageCreator.PANEL_LEN,
					m_Block.y / ImageCreator.PANEL_LEN//block_y_old + offset_y
				);
			}

			//Redraw
			{
//				m_BitmapData_Wall = ImageCreator.CreateWallBitmapData(m_MapInfo.m_BitmapData);
				ImageCreator.RedrawWallBitmapData(m_BitmapData_Wall, m_MapInfo.m_BitmapData);
			}

			//落下処理のため、ブロックを消しておく
			{
				VanishBlock();
			}

			//特に問題なければ、消えるものがないかチェックする
			{
				GoToMode(MODE_CHECK);
			}
		}

		//Update : Check
		public function Update_Check(in_DeltaTime:Number):void
		{
			var x:int, y:int;

			//Map => Wall or Space
			var BitmapData_WeqFF_SeqFE:BitmapData;
			{//Mapの値はCLEARのIndexが壁とは別なので、それを壁と同じにしつつ、以降の処理がやりやすいように値を変更する
				BitmapData_WeqFF_SeqFE = new BitmapData(MapInfo.NUM_X, 2*MapInfo.NUM_Y, false, 0x000000);//毎回生成せずに保持しておいたほうが良さそうだが

				//W(0x000000)を0xFFに、S(0x000001)を0xFEにするための処理(B:*-1+0xFF)＋CLEARと壁の差をなくす処理(G:*0+0)
				const CT_WeqFF_SeqFE:ColorTransform = new ColorTransform(0,0,-1,1, 0,0,0xFF,0);

				//実際に作成
				BitmapData_WeqFF_SeqFE.draw(m_MapInfo.m_BitmapData, null, CT_WeqFF_SeqFE);

				//Debug
				//addChild(new Bitmap(BitmapData_WeqFF_SeqFE));
			}

			//グルーピング
			var BitmapData_Group:BitmapData;
			//var GroupList:Array = [];//vec<FallGroup>
			m_FallGroupList = [];
			{
				//上の「壁or空間」BitmapDataを元に、
				BitmapData_Group = BitmapData_WeqFF_SeqFE.clone();

				//壁(0xFF)の部分にグループIDを当てはめていく
				var GroupIndex:int = 0;
				for(y = 0; y < 2*MapInfo.NUM_Y; y++){
					for(x = 0; x < MapInfo.NUM_X; x++){
						if(BitmapData_Group.getPixel(x, y) == 0xFF){
							//隣接する全ての壁をグルーピング
							BitmapData_Group.floodFill(x, y, GroupIndex++);

							//グループデータを追加
							var group:FallGroup = new FallGroup();
							{
								group.m_SamplingX = x;//この位置の値を全てのグループに適用する
								group.m_SamplingY = y;
							}
							m_FallGroupList.push(group);
						}
					}
				}
			}

			//各グループの落下距離を計算
			var BitmapData_FallVal:BitmapData;
			{
				//「壁or空間」BitmapDataを元にする。落下距離の初期値も、最大=0xFFであれば十分なはず。
				BitmapData_FallVal = BitmapData_WeqFF_SeqFE.clone();

				for(;;){//更新がある限り何度も処理するので、無限ループにしておく
					var ReCalcFlag:Boolean = false;//処理があったらTrueにしてもう一度処理を行う

					for(x = 0; x < MapInfo.NUM_X; x++){//各列を
						var FallVal:int = 0;
						for(y = 2*MapInfo.NUM_Y-1; y >= 0; y--){//下から順に見ていって
							if(BitmapData_WeqFF_SeqFE.getPixel(x, y) == 0xFE){//空間なら落下距離＋＋
								FallVal++;
							}else{//壁なら落下距離を適用
								if(FallVal >= BitmapData_FallVal.getPixel(x, y)){//ただし、すでに設定してあるものの方が小さければスキップ
									FallVal = BitmapData_FallVal.getPixel(x, y);//そして、上にはこの小さい方を採用させる
								}else{
									BitmapData_FallVal.floodFill(x, y, FallVal);
									ReCalcFlag = true;//更新したので、他への伝搬を考慮し、もう一度全体のチェックを促す
								}
							}
						}
					}

					if(! ReCalcFlag){
						break;//更新がなくなったらここで終了
					}
				}
			}

			//各グループの落下距離チェック＆セット
			var FallValMax:int = 0;
			{
				m_FallGroupList.forEach(function(group:FallGroup, index:int, arr:Array):void{
					//落下距離セット
					group.m_FallVal = BitmapData_FallVal.getPixel(group.m_SamplingX, group.m_SamplingY) * ImageCreator.PANEL_LEN;

					//グループ全体のうち落下距離が最大のものを求める
					if(FallValMax < group.m_FallVal){
						FallValMax = group.m_FallVal;
					}
				});
			}

			//どのグループも落下距離が０なら、落下処理はせずに戻る
			{
				if(FallValMax <= 0){
					m_FallGroupList = [];

					GoToMode(MODE_CREATE_BLOCK);

					return;
				}
			}

			//落下するグループがあるなら、落下処理に移る
			{
				//まずはそのまえに落下用画像作成
				m_FallGroupList.forEach(function(group:FallGroup, index:int, arr:Array):void{
					group.m_BitmapData = ImageCreator.CreateWallBitmapData(
						m_MapInfo.m_BitmapData,//落下前の各要素
						BitmapData_Group,//グループを示すBitmapData
						BitmapData_Group.getPixel(group.m_SamplingX, group.m_SamplingY)//描画するグループのIndex
					);
				});

				//さらに今のうちに落下後の状況になるようにm_MapInfoを更新
				{
					var NewMapInfo:BitmapData = new BitmapData(MapInfo.NUM_X, 2*MapInfo.NUM_Y, false, MapInfo.MAP_SPACE);//これもMAP_SPACEで毎回リセットするだけで、新規作成の必要なし
					for(y = 0; y < 2*MapInfo.NUM_Y; y++){
						for(x = 0; x < MapInfo.NUM_X; x++){
							var MapIndex:int = m_MapInfo.m_BitmapData.getPixel(x, y);//元の位置の要素が
							if(MapIndex != MapInfo.MAP_SPACE){//空白でなければ
								var OffsetY:int = BitmapData_FallVal.getPixel(x, y);//落下距離分だけ下に移動させて
								NewMapInfo.setPixel(x, y+OffsetY, MapIndex);//セット
							}
						}
					}

					m_MapInfo.m_BitmapData.copyPixels(NewMapInfo, NewMapInfo.rect, POS_ZERO);
				}

				//そして落下処理に移行
				GoToMode(MODE_FALL);
			}
		}


//		//Update : Vanish
//		public function Update_Vanish(in_DeltaTime:Number):void{
//		}

		//Update : Fall
		public function Update_Fall(in_DeltaTime:Number):void{
			var Mtx:Matrix = new Matrix();

			//ここまでの落下量
			var FallVal:int = 0.5*FALL_GRAVITY*m_ModeTimer*m_ModeTimer;

			//壁の表示をリセットして
			m_BitmapData_Wall.fillRect(m_BitmapData_Wall.rect, 0x00000000);

			//それぞれのグループを移動させて描画
			var StillFalling:Boolean = false;
			m_FallGroupList.forEach(function(group:FallGroup, index:int, arr:Array):void{
				//移動先の位置を計算
				if(FallVal < group.m_FallVal){//まだ目的地に到達してない
					Mtx.ty = FallVal;
					StillFalling = true;
				}else{//すでに到達している
					Mtx.ty = group.m_FallVal;
				}

				//移動先にこのグループを描画
				m_BitmapData_Wall.draw(group.m_BitmapData, Mtx);
			});

			//落下中のものがもうなければ、クリアチェックする
			if(! StillFalling){
				//その前に今のグループをリセットしておこう
				m_FallGroupList = [];

				//モード移行
				GoToMode(MODE_CHECK_CLEAR);
			}
		}

		//Update : CheckClear
		public function Update_CheckClear(in_DeltaTime:Number):void{
			var x:int;
			var y:int;

			var IsClear:Boolean;
			{
				//まずは左端の「C」の位置を求める
				var IndexY:int = -1;
				{
					for(y = MapInfo.NUM_Y; y < 2*MapInfo.NUM_Y; y++){//Mapの下半分（見えてる部分）から探す
						if(m_MapInfo.m_BitmapData.getPixel(0,y) == MapInfo.MAP_C){
							IndexY = y;
							break;
						}
					}
				}

				//それと同じ高さに「LEAR」の文字が並んでいたらクリア
				if(IndexY >= 0){
					//まずはTrueにしておいて、並んでないものが見つかったら条件未達成とする
					IsClear = true;

					for(x = 1; x < MapInfo.NUM_X; x++){
						//CLEARの文字の判定は、RGBのGに相当する部分に何か書いてあればOKとする
						if(((m_MapInfo.m_BitmapData.getPixel(x,IndexY) >> 8) & 0xFF) == 0){
							IsClear = false;
							break;
						}
					}
				}else{
					//そもそもCが見える位置になければクリアじゃない
					IsClear = false;
				}
			}

			if(IsClear){
				//クリア条件を満たしていたらクリアにする
				GoToMode(MODE_GAME_CLEAR);
			}else{
				//そうでなければ次のブロック操作に移る
				GoToMode(MODE_CREATE_BLOCK);
			}
		}

		//Update : GameClear
		public function Update_GameClear(in_DeltaTime:Number):void{
			const GLOW_W:int = 8;

			//Reset
			{
				m_BitmapData_Interface.fillRect(m_BitmapData_Interface.rect, 0x00000000);
			}

			//文字部分
			var bmp_data_text:BitmapData;
			{
				bmp_data_text = new BitmapData(ImageCreator.BMP_W, 2*ImageCreator.BMP_H, true, 0x00000000);

				ImageCreator.RedrawWallTextBitmapData(bmp_data_text, m_MapInfo.m_BitmapData);
			}

			//Draw
			{
				//まずは文字部分を白く描画
				{
					const mtx:Matrix = new Matrix(1,0,0,1, 0, -ImageCreator.BMP_H);
					const ct_force_white:ColorTransform = new ColorTransform(1,1,1,1, 0xFF,0xFF,0xFF,0);
					m_BitmapData_Interface.draw(bmp_data_text, mtx, ct_force_white);
				}

				//さらにそこにGlowで発光っぽくする
				{
					const glow_filter:GlowFilter = new GlowFilter(0xFFFF00,1.0, GLOW_W,GLOW_W);
					m_BitmapData_Interface.applyFilter(m_BitmapData_Interface, m_BitmapData_Interface.rect, POS_ZERO, glow_filter);
				}
			}
		}

		//Update : GameOver
		public function Update_GameOver(in_DeltaTime:Number):void{
		}


		//#Block

		//ブロックを生成
		public function CreateNextBlock():void{
			//Delete Old
			{
				VanishBlock();
			}

			//Create New
			{
				const BLOCK_INIT_X:int = 1*ImageCreator.PANEL_LEN;
				const BLOCK_INIT_Y:int = 0;//ImageCreator.BMP_H;

				m_Block = new Block(Block.BLOCK_TYPE_NUM * Math.random());
				m_Block.x = BLOCK_INIT_X;
				m_Block.y = BLOCK_INIT_Y;
				m_Layer_Block.addChild(m_Block);
			}
		}

		//ブロックを消去（落下処理中など）
		public function VanishBlock():void{
			if(m_Block){
				m_Layer_Block.removeChild(m_Block);
				m_Block = null;
			}
		}


		//#Move & Rot

		public function TryToMove(in_MoveX:int, in_MoveY:int):Boolean{
			//Check
			{
				if(m_Block == null){
					return false;
				}

				if(m_Mode == MODE_GAME_OVER){
					return false;
				}
			}

			//移動方向に壁があれば移動不可
			if(!CheckMove(in_MoveX, in_MoveY) || !CheckMove(in_MoveX, in_MoveY+1)){//縦にラインをまたぐので、２マス分チェック
				return false;
			}

			//移動可能なようなので移動する
			m_Block.x += ImageCreator.PANEL_LEN * in_MoveX;
			m_Block.y += ImageCreator.PANEL_LEN * in_MoveY;

			return true;//壁にはぶつからなかった
		}

		public function CheckMove(in_MoveX:int, in_MoveY:int):Boolean{
			//Check
			{
				if(m_Block == null){
					return false;
				}
			}

			//指定方向に移動可能か
			{
				var block_x:int = m_Block.x / ImageCreator.PANEL_LEN;
				var block_y:int = m_Block.y / ImageCreator.PANEL_LEN;
				if(m_MapInfo.IsHit(m_Block.GetBlockArray(), block_x+in_MoveX, block_y+in_MoveY)){
					//移動先に壁があるので移動は諦める
					return false;
				}
			}

			return true;
		}


		public function TryToRot(in_IsNext:Boolean):Boolean{
			//回転後の形状
			var BlockArray:Array;
			{
				if(in_IsNext){
					BlockArray = m_Block.GetBlockArray_Next();
				}else{
					BlockArray = m_Block.GetBlockArray_Prev();
				}
			}

			//回転後の形状が他の壁に当たるようなら回転不可
			{
				var block_x:int = m_Block.x / ImageCreator.PANEL_LEN;
				var block_y:int = m_Block.y / ImageCreator.PANEL_LEN;
				if(m_MapInfo.IsHit(BlockArray, block_x, block_y) || m_MapInfo.IsHit(BlockArray, block_x, block_y+1)){
					//壁があって回転できない
					return false;
				}
			}

			//回転できるようなので回転
			m_Block.Rot(in_IsNext);

			return true;
		}


		//#Redraw

		public function Redraw():void{
			const ct_force_black:ColorTransform = new ColorTransform(0,0,0,1);

			//まずはBGのαを計算
			{//RGBでαの値を計算した後、それをαにコピーする
				//まずは白（表示）でリセット
				m_BitmapData_Util.fillRect(m_BitmapData_Util.rect, 0xFFFFFFFF);

				//壁のある部分は黒（非表示）にする
//*
				const mtx:Matrix = new Matrix(1,0,0,1, 0,-ImageCreator.BMP_H);
				m_BitmapData_Util.draw(m_BitmapData_Wall, mtx, ct_force_black);
/*/
				//こっちの方が速そうなんだけど、うまく動かない
				const rect:Rectangle = new Rectangle(0,ImageCreator.BMP_H, ImageCreator.BMP_W,ImageCreator.BMP_H);
				m_BitmapData_Util.copyChannel(m_BitmapData_Wall, rect, POS_ZERO, BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
//*/
				//ブロックがあれば、その部分を白（表示）にする
				if(m_Block){
					m_BitmapData_Util.draw(m_Layer_Block);//元の画像を白にしておくこと
				}

				//黒（非表示）の部分を実際に表示しないように（α＝０）する
				m_BitmapData_Util.copyChannel(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, BitmapDataChannel.RED, BitmapDataChannel.ALPHA)

				//一度背景の画像を初期化してから
				m_BitmapData_BG.copyPixels(m_BitmapData_BG_Ori, m_BitmapData_BG_Ori.rect, POS_ZERO);

				//表示・非表示の値を反映
				m_BitmapData_BG.copyChannel(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}

			//計算結果を活かしつつ、枠の描画に入る
			{
				const SHADE_W:int = 2;//4
				const LINE_W:int = 10;//24

				//まずは白だった部分を黒にする
				{
					m_BitmapData_Util.draw(m_BitmapData_Util, null, ct_force_black);
				}

				//枠を作るためにブラー(Glow)を適用
				{
					//R：枠全体の表示領域、GB：枠の絵の表示領域（ここ以外は陰が表示される）
					//内陰用
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFF0000,1.0, SHADE_W,0, 255));
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFF0000,1.0, 0,SHADE_W, 255));
					//枠内部用
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFFFFFF,1.0, LINE_W-2*SHADE_W,0, 255));
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFFFFFF,1.0, 0,LINE_W-2*SHADE_W, 255));
					//外陰用
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFF0000,1.0, SHADE_W,0, 255));
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new GlowFilter(0xFF0000,1.0, 0,SHADE_W, 255));
					//なんというGlowFilterの大盤振る舞い
					//もしかしてBitmapに入れてfiltersに突っ込んでから描画した方が早かったりするのだろうか
					//これで重いようなら、縮小Bitmapでブラーをかけた後、拡大して使うとか
				}


				//#陰
				{
					//赤い部分を表示領域と捉え、表示領域全体に陰を表示する（この上に枠の絵が重ねられる）
					m_BitmapData_WallLineShade.copyChannel(
						m_BitmapData_Util,
						m_BitmapData_Util.rect,
						POS_ZERO,
						BitmapDataChannel.RED,
						BitmapDataChannel.ALPHA
					);
				}


				//#枠の絵
				{
					//毎回リセットする必要があるらしい
					   m_BitmapData_WallLine.copyPixels(m_BitmapData_WallLine_Ori, m_BitmapData_WallLine_Ori.rect, POS_ZERO);

					//陰と馴染ませるためにブラーで境界をぼかす
					m_BitmapData_Util.applyFilter(m_BitmapData_Util, m_BitmapData_Util.rect, POS_ZERO, new BlurFilter(SHADE_W,SHADE_W));

					//青い部分を絵の表示領域と捉え、絵のαとして採用
					m_BitmapData_WallLine.copyChannel(
						m_BitmapData_Util,
						m_BitmapData_Util.rect,
						POS_ZERO,
						BitmapDataChannel.GREEN,
						BitmapDataChannel.ALPHA
					);
				}
			}
		}

	}
}


import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.text.*;
import flash.filters.*;


//Map
class MapInfo{
	//==Const==

	//マス数
	static public const NUM_X:int = 5;
	static public const NUM_Y:int = 13;

	//要素（RGBとして記述：B=0x00なら壁グループと認識）（ブロックの01と一致するように）
	static public const MAP_WALL:int	 = 0x000000;//壁
	static public const MAP_SPACE:int	 = 0x000001;//空間
	static public const MAP_C:int		 = 0x000100;//CLEARの文字（壁と同じグループ）
	static public const MAP_L:int		 = 0x000200;
	static public const MAP_E:int		 = 0x000300;
	static public const MAP_A:int		 = 0x000400;
	static public const MAP_R:int		 = 0x000500;


	//==Var==

	//各マスの要素（塗りつぶしてグルーピングなどがしやすいように、配列ではなくBitmapで保持）
	public var m_BitmapData:BitmapData;


	//==Function==

	//Init
	public function MapInfo(){
		//m_BitmapData
		{//ここではCreateだけ
			m_BitmapData = new BitmapData(NUM_X, 2*NUM_Y, false, MAP_WALL);
		}

		//残りはResetに統合
		{
			Reset();
		}
	}

	public function Reset():void{
		const rect_up:Rectangle = new Rectangle(0,0,NUM_X,NUM_Y);
		const rect_down:Rectangle = new Rectangle(0,NUM_Y,NUM_X,NUM_Y);

		//m_BitmapData
		{//下半分（見えている部分）は全て壁、上半分は全て空間にする
			m_BitmapData.fillRect(rect_down, MAP_WALL);
			m_BitmapData.fillRect(rect_up,   MAP_SPACE);

			//さらに、CLEARの文字を並べる
			m_BitmapData.setPixel(0, NUM_Y + 1, MAP_C);
			m_BitmapData.setPixel(1, NUM_Y + 3, MAP_L);
			m_BitmapData.setPixel(2, NUM_Y + 1, MAP_E);
			m_BitmapData.setPixel(3, NUM_Y + 3, MAP_A);
			m_BitmapData.setPixel(4, NUM_Y + 1, MAP_R);
		}
	}

	//Add Block
	public function AddBlock(in_Block:Array, in_LX:int, in_UY:int):void{
		var NumX:int = in_Block[0].length;
		var NumY:int = in_Block.length;

		//ブロックで指定された部分を空白化（空白にされた部分は画面外上部に積む）
		for(var y:int = NumY-1; y >= 0; y--){//下のやつから上に積むため、下から探していく
			for(var x:int = 0; x < NumX; x++){
				if(in_Block[y][x] != 0){
					var PixelX:int = in_LX+x;
					var PixelY:int = in_UY+y+NUM_Y;//画面下半分の座標と捉えてオフセット

					//今あるやつを画面上部に積む
					var val:int = m_BitmapData.getPixel(PixelX, PixelY);
					if(val != MAP_SPACE){//ないとは思うけど一応判定
						for(var iter_y:int = NUM_Y-1; iter_y >= 0; iter_y--){//上半分の空きスペースを下から探していく
							if(m_BitmapData.getPixel(PixelX, iter_y) == MAP_SPACE){//スペースが見つかったら
								m_BitmapData.setPixel(PixelX, iter_y, val);//そこに移動
								break;
							}
						}
					}

					//そして元の位置は空白化
					m_BitmapData.setPixel(PixelX, PixelY, MAP_SPACE);
				}
			}
		}

		//Redrawが必要だが、その処理は呼び出し側に任せる
	}

	//IsHit
	public function IsHit(in_Block:Array, in_BlockX:int, in_BlockY:int):Boolean{
		var w:int = in_Block[0].length;
		var h:int = in_Block.length;

		for(var y:int = 0; y < h; y++){
			for(var x:int = 0; x < w; x++){
				//この部分にブロックがなければスキップ
				if(in_Block[y][x] == 0){
					continue;
				}

				var PixelX:int = in_BlockX+x;
				var PixelY:int = in_BlockY+y+NUM_Y;//画面下半分の座標と捉えてオフセット

				//この部分がマップの範囲外であれば壁として扱う
				if(PixelX < 0){return true;}
				if(PixelX >= NUM_X){return true;}
				if(PixelY < 0){return true;}//全部透明の場合に備えて、Yもここで判定
				if(PixelY >= 2*NUM_Y){return true;}

				//この部分に地形(ブロックが衝突するのはSPACEなのでSPACE)があればヒット
				if(m_BitmapData.getPixel(PixelX, PixelY) == MAP_SPACE){
					return true;
				}
			}
		}

		//ヒットするものがなかったので無ヒット
		return false;
	}
}


//Block
class Block extends Sprite{
	//==Const==

/*
		■：I
		■
		■
		■

		■■：O
		■■

		■
		■
		■■：L

		　■
		　■
		■■：R

		■■■：T
		　■

		　■■：S
		■■

		■■
		　■■：Z
*/

	static public var BlockTypeIter:int = 0;
	static public const BLOCK_TYPE_I:int = BlockTypeIter++;
	static public const BLOCK_TYPE_O:int = BlockTypeIter++;
	static public const BLOCK_TYPE_L:int = BlockTypeIter++;
	static public const BLOCK_TYPE_R:int = BlockTypeIter++;
	static public const BLOCK_TYPE_T:int = BlockTypeIter++;
	static public const BLOCK_TYPE_S:int = BlockTypeIter++;
	static public const BLOCK_TYPE_Z:int = BlockTypeIter++;
	static public const BLOCK_TYPE_NUM:int = BlockTypeIter;

	//回転量（時計回り方向）
	static public var RotIter:int = 0;
	static public const ROT_0:uint   = RotIter++;
	static public const ROT_90:uint  = RotIter++;
	static public const ROT_180:uint = RotIter++;
	static public const ROT_270:uint = RotIter++;
	static public const ROT_NUM:uint = RotIter;


	static public const BLOCK_FORM:Array = [
		//I
		[
			//ROT_0
			[
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
			],
			//ROT_90
			[
				[0, 0, 0, 0],
				[0, 0, 0, 0],
				[1, 1, 1, 1],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
			],
			//ROT_270
			[
				[0, 0, 0, 0],
				[0, 0, 0, 0],
				[1, 1, 1, 1],
				[0, 0, 0, 0],
			],
		],
		//O
		[
			//ROT_0
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_270
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
		],
		//L
		[
			//ROT_0
			[
				[0, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[0, 0, 0, 0],
				[0, 1, 1, 1],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 0, 1, 0],
				[0, 0, 1, 0],
			],
			//ROT_270
			[
				[0, 0, 0, 0],
				[0, 0, 1, 0],
				[1, 1, 1, 0],
				[0, 0, 0, 0],
			],
		],
		//R
		[
			//ROT_0
			[
				[0, 0, 1, 0],
				[0, 0, 1, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[0, 0, 0, 0],
				[0, 1, 0, 0],
				[0, 1, 1, 1],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 0, 0],
				[0, 1, 0, 0],
			],
			//ROT_270
			[
				[0, 0, 0, 0],
				[1, 1, 1, 0],
				[0, 0, 1, 0],
				[0, 0, 0, 0],
			],
		],
		//T
		[
			//ROT_0
			[
				[0, 0, 0, 0],
				[1, 1, 1, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[0, 1, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 1, 0, 0],
				[1, 1, 1, 0],
				[0, 0, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_270
			[
				[0, 1, 0, 0],
				[0, 1, 1, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
		],
		//S
		[
			//ROT_0
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[1, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[1, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 0, 0, 0],
				[0, 1, 1, 0],
				[1, 1, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_270
			[
				[1, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 0, 0],
				[0, 0, 0, 0],
			],
		],
		//Z
		[
			//ROT_0
			[
				[0, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_90
			[
				[0, 1, 0, 0],
				[1, 1, 0, 0],
				[1, 0, 0, 0],
				[0, 0, 0, 0],
			],
			//ROT_180
			[
				[0, 0, 0, 0],
				[1, 1, 0, 0],
				[0, 1, 1, 0],
				[0, 0, 0, 0],
			],
			//ROT_270
			[
				[0, 1, 0, 0],
				[1, 1, 0, 0],
				[1, 0, 0, 0],
				[0, 0, 0, 0],
			],
		],
	];


	//==Var==

	//ブロックはどういう形状か
	public var m_BlockType:int = BLOCK_TYPE_I;

	//ブロックは今どれだけ回転しているか
	public var m_Rot:uint = ROT_0;

	//画像
	public var m_Bitmap:Bitmap;


	//==Function==

	public function Block(in_BlockType:int){
		//m_BlockType
		{
			m_BlockType = in_BlockType;
		}

		//Graphic
		{
			m_Bitmap = ImageCreator.CreateBlockBitmap(GetBlockArray());
			addChild(m_Bitmap);
		}
	}

	public function GetBlockArray():Array{
		return BLOCK_FORM[m_BlockType][m_Rot];
	}

	public function GetBlockArray_Next():Array{
		return BLOCK_FORM[m_BlockType][(m_Rot+1)%ROT_NUM];
	}

	public function GetBlockArray_Prev():Array{
		return BLOCK_FORM[m_BlockType][(m_Rot+ROT_NUM-1)%ROT_NUM];
	}


	public function Rot(in_IsNext:Boolean):void{
		//m_Rot
		{
			if(in_IsNext){
				m_Rot = (m_Rot+1)%ROT_NUM;
			}else{
				m_Rot = (m_Rot+ROT_NUM-1)%ROT_NUM;
			}
		}

		//Graphic
		{
			ImageCreator.RedrawBlockBitmap(GetBlockArray(), m_Bitmap.bitmapData);
		}
	}
}


//画像
class ImageCreator{
	//==File==
/*
	[Embed(source='Blocks.png')]
	 private static var Bitmap_Blocks: Class;

	static public var m_Bitmap_Blocks:Bitmap = new Bitmap_Blocks();
/*/
//	static public const BITMAP_URL:String = "http://assets.wonderfl.net/images/related_images/3/37/37f1/37f116ea874448150a54d2e41b8638aeebab52a5m";
	static public const BITMAP_URL:String = "Blocks.png";

	static public function Ready(in_Bitmap:DisplayObject):void{
		var bmp_data:BitmapData = m_Bitmap_Blocks.bitmapData;

		//まずは普通に描画
		{
			bmp_data.draw(in_Bitmap);
		}

		//「元画像＋マスク」によりアルファ付きの画像に変換する
		{
			var src_rect:Rectangle = new Rectangle(0,0, 32,32);
			var dst_pos:Point = new Point();

			//C
			src_rect.x = 32*0;
			src_rect.y = 32*2;
			dst_pos.x = 32*3;
			dst_pos.y = 32*0;
			bmp_data.copyChannel(bmp_data, src_rect, dst_pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			//L
			src_rect.x = 32*1;
			src_rect.y = 32*2;
			dst_pos.x = 32*0;
			dst_pos.y = 32*1;
			bmp_data.copyChannel(bmp_data, src_rect, dst_pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			//E
			src_rect.x = 32*2;
			src_rect.y = 32*2;
			dst_pos.x = 32*1;
			dst_pos.y = 32*1;
			bmp_data.copyChannel(bmp_data, src_rect, dst_pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			//A
			src_rect.x = 32*3;
			src_rect.y = 32*2;
			dst_pos.x = 32*2;
			dst_pos.y = 32*1;
			bmp_data.copyChannel(bmp_data, src_rect, dst_pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			//R
			src_rect.x = 32*0;
			src_rect.y = 32*3;
			dst_pos.x = 32*3;
			dst_pos.y = 32*1;
			bmp_data.copyChannel(bmp_data, src_rect, dst_pos, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
		}
	}

	static public var m_Bitmap_Blocks:Bitmap = new Bitmap(new BitmapData(32*4, 32*4, true, 0x00000000));
//*/
	//==Const==

	//１マスの大きさ
	static public const PANEL_LEN:int = 32;

	//Bitmapの大きさ
	static public const BMP_W:int = MapInfo.NUM_X * PANEL_LEN;//初期化順序的に怖い
	static public const BMP_H:int = MapInfo.NUM_Y * PANEL_LEN;


	//==Function==

	//#Block

	//Create：最初の生成時向け
	static public function CreateBlockBitmap(in_Block:Array):Bitmap{
		var w:int = in_Block[0].length;
		var h:int = in_Block.length;

		var bmp_data:BitmapData = new BitmapData(PANEL_LEN*w, PANEL_LEN*h, true, 0x00000000);

		RedrawBlockBitmap(in_Block, bmp_data);

		return new Bitmap(bmp_data);
	}

	//Redraw：新しくブロックを積んだときや、ブロックを回転させたとき向け
	static public function RedrawBlockBitmap(in_Block:Array, out_BitmapData:BitmapData):void{
		const OffsetX:int = -3*16;
		const OffsetY:int = -2*16;

		var w:int = in_Block[0].length;
		var h:int = in_Block.length;

		var mtx:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);

		for(var y:int = 0; y < h; y++){
			rect.y = PANEL_LEN*y;
			for(var x:int = 0; x < w; x++){
				rect.x = PANEL_LEN*x;
				mtx.tx = rect.x + OffsetX;
				mtx.ty = rect.y + OffsetY;
				if(in_Block[y][x] != 0){
					out_BitmapData.fillRect(rect, 0xFFFFFFFF);
				}else{
					out_BitmapData.fillRect(rect, 0x00000000);
				}
			}
		}
	}


	//#BG

	static public function CreateBG():BitmapData{
		//return new Bitmap(new BitmapData(PANEL_LEN*in_W, PANEL_LEN*in_H, false, 0x000000));
		const OffsetX:int = -2*32;
		const OffsetY:int = -0*32;

		var bmp_data:BitmapData = new BitmapData(BMP_W, BMP_H, true, 0x00000000);
		var mtx:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);
		for(rect.y = 0; rect.y < BMP_H; rect.y += PANEL_LEN){
			for(rect.x = 0; rect.x < BMP_W; rect.x += PANEL_LEN){
				mtx.tx = rect.x + OffsetX;
				mtx.ty = rect.y + OffsetY;
				bmp_data.draw(m_Bitmap_Blocks, mtx, null, null, rect);
			}
		}

		return bmp_data;
	}


	//#Wall（落下用のそれぞれの壁の描画も兼ねる）

	//in_GroupMapのグループのうち、in_GroupIndexで指定された部分だけを、in_Mapの中身に応じた画像にして返す
	static public function CreateWallBitmapData(in_Map:BitmapData, in_GroupMap:BitmapData=null, in_GroupIndex:int=0):BitmapData{
		var bmp_data:BitmapData = new BitmapData(BMP_W, 2*BMP_H, true, 0x00000000);
		RedrawWallBitmapData(bmp_data, in_Map, in_GroupMap, in_GroupIndex);
		return bmp_data;
	}
	static public function RedrawWallBitmapData(out_BitmapData:BitmapData, in_Map:BitmapData, in_GroupMap:BitmapData=null, in_GroupIndex:int=0):void{
		var mtx:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);

		//Reset
		out_BitmapData.fillRect(out_BitmapData.rect, 0x00000000);

		//in_Mapの中身に応じてDraw
		for(var y:int = 0; y < 2*MapInfo.NUM_Y; y++){
			rect.y = y*PANEL_LEN;
			for(var x:int = 0; x < MapInfo.NUM_X; x++){
				rect.x = x*PANEL_LEN;

				//指定グループでなければスキップ
				if(in_GroupMap){
					if(in_GroupMap.getPixel(x, y) != in_GroupIndex){
						continue;
					}
				}

				//あとはin_Mapの中身に応じて描画
				switch(in_Map.getPixel(x, y) & 0x0000FF){
				case MapInfo.MAP_SPACE:
					//out_BitmapData.fillRect(rect, 0x00000000);
					break;
				case MapInfo.MAP_WALL:
					mtx.tx = rect.x -0*PANEL_LEN;
					mtx.ty = rect.y -0*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				}
			}
		}

		//文字は壁の上に書くので別処理
		RedrawWallTextBitmapData(out_BitmapData, in_Map, in_GroupMap, in_GroupIndex);
	}

	//Redraw：文字部分
	static public function RedrawWallTextBitmapData(out_BitmapData:BitmapData, in_Map:BitmapData, in_GroupMap:BitmapData=null, in_GroupIndex:int=0):void{
		var mtx:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);

		//Reset
		//out_BitmapData.fillRect(out_BitmapData.rect, 0x00000000);//はしない

		//in_Mapの中身に応じてDraw
		for(var y:int = 0; y < 2*MapInfo.NUM_Y; y++){
			rect.y = y*PANEL_LEN;
			for(var x:int = 0; x < MapInfo.NUM_X; x++){
				rect.x = x*PANEL_LEN;

				//指定グループでなければスキップ
				if(in_GroupMap){
					if(in_GroupMap.getPixel(x, y) != in_GroupIndex){
						continue;
					}
				}

				//あとはin_Mapの中身に応じて描画
				switch(in_Map.getPixel(x, y)){
				case MapInfo.MAP_SPACE:
				case MapInfo.MAP_WALL:
					break;
				case MapInfo.MAP_C:
					mtx.tx = rect.x -3*PANEL_LEN;
					mtx.ty = rect.y -0*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				case MapInfo.MAP_L:
					mtx.tx = rect.x -0*PANEL_LEN;
					mtx.ty = rect.y -1*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				case MapInfo.MAP_E:
					mtx.tx = rect.x -1*PANEL_LEN;
					mtx.ty = rect.y -1*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				case MapInfo.MAP_A:
					mtx.tx = rect.x -2*PANEL_LEN;
					mtx.ty = rect.y -1*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				case MapInfo.MAP_R:
					mtx.tx = rect.x -3*PANEL_LEN;
					mtx.ty = rect.y -1*PANEL_LEN;
					out_BitmapData.draw(m_Bitmap_Blocks.bitmapData, mtx, null, null, rect);
					break;
				}
			}
		}
	}


	//#WallLine

	static public function CreateWallLine():BitmapData{
		const OffsetX:int = -1*32;
		const OffsetY:int = 0;

		var bmp_data:BitmapData = new BitmapData(BMP_W, BMP_H, true, 0x00000000);
		var mtx:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0,0, PANEL_LEN,PANEL_LEN);
		for(rect.y = 0; rect.y < BMP_H; rect.y += PANEL_LEN){
			for(rect.x = 0; rect.x < BMP_W; rect.x += PANEL_LEN){
				mtx.tx = rect.x + OffsetX;
				mtx.ty = rect.y + OffsetY;
				bmp_data.draw(m_Bitmap_Blocks, mtx, null, null, rect);
			}
		}

		return bmp_data;
	}
}


//落下する部分をまとめるためのもの。ローカルクラスにしたいところだが。
class FallGroup
{
	//==Var==

	//落下値をBitmapDataから参照したりする時のための座標
	public var m_SamplingX:int = 0;
	public var m_SamplingY:int = 0;

	//落下させるグラフィック
	public var m_BitmapData:BitmapData;

	//このグループの落下距離
	public var m_FallVal:int = 0;
}




