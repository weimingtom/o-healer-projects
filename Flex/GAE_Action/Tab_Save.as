//author Show=O=Healer
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

	public class Tab_Save extends ITab
	{
		//==Const==

		//#Message

		static public const HINT_MESSAGE_BUTTON_SAVE_NEW:String = "今のデータを今までのとは別に新しく保存します";
		static public const HINT_MESSAGE_BUTTON_SAVE_OVERWRITE:String = "このデータに今のデータを上書きして保存します";

		static public const HINT_MESSAGE_BUTTON_LOAD_NEW:String = "今のデータを全て空にします";
		static public const HINT_MESSAGE_BUTTON_LOAD_OVERWRITE:String = "このデータをロードします（今のデータは消えます）";

		//#State

		static public const STATE_LIST:int		= 0;//一覧表示中
		static public const STATE_ZOOM_IN:int	= 1;//ズームインの最中
		static public const STATE_SELECTED:int	= 2;//選択したものを表示中
		static public const STATE_ZOOM_OUT:int	= 3;//ズームアウトの最中

		//#Zoom

		static public const ZOOM_OUT_SCALE:Number = 0.3;

		static public const ZOOM_IN_TIME:Number  = 0.5;
		static public const ZOOM_OUT_TIME:Number = 0.5;

		//#Thumbnail

		static public const THUMBNAIL_NUM_X:int = 3;

		static public const THUMBNAIL_OFFSET_INIT_X:int = 32;
		static public const THUMBNAIL_OFFSET_INIT_Y:int = 32;
		static public const THUMBNAIL_OFFSET_X:int = (200 + 16*2) + (32*5);
		static public const THUMBNAIL_OFFSET_Y:int = (200 + 16*2) + (32*2);

		//#Data

		static public const DefaultStageData:Object = {stage:"O"};


		//#Pos

		static public const ZOOM_OUT_OFFSET_X:int = 80;
		static public const ZOOM_OUT_OFFSET_Y:int = 5;

		static public const SAVE_BUTTON_X:int = ZOOM_OUT_OFFSET_X - 64;
		static public const SAVE_BUTTON_Y:int = ZOOM_OUT_OFFSET_Y;

		static public const LOAD_BUTTON_X:int = ZOOM_OUT_OFFSET_X - 64;
		static public const LOAD_BUTTON_Y:int = ZOOM_OUT_OFFSET_Y + (200 + 16*2) - 32;


		//==Var==

		//#ズームアップしたときにマスクをかけるためのImage
		private var m_MaskImage:Image;

		//#全体をズームイン・アウトさせるためのImage
		private var m_ZoomImage:Image;

		//#セーブ＆ロードのボタン
		private var m_SaveButton:Image;
		private var m_SaveButton_New:Image;
		private var m_LoadButton:Image;
		private var m_LoadButton_New:Image;

		//#選択したデータまわり
		private var m_SelectedData:Image;//選択したもの
		private var m_SelectedIndex:int = -1;//選択されているやつの番号（マイナスなら新規扱い）
		private var OnSave:Function;//セーブした後に呼ばれるので、これに「サムネイルの更新」などの処理を入れる

		//#State
		private var m_State:int = STATE_LIST;
		private var m_StateTimer:Number = 0.0;

		//#Num
		private var m_ThumbnailCount:int = 0;


		//==Function==

		//Init
		public function Tab_Save(){
			//Tab
			{
				super("セ｜ブ", 0x0000FF);//縦に表示するため、伸ばし棒は縦にしておく
			}

			//Content
			{
				InitButtons();

				InitThumbnails();
			}
		}

		//#
		//
		public function InitButtons():void{
			//SaveButton
			{
				//OverWrite
				{
					//Create
					m_SaveButton = ImageManager.CreateThumbnailImage_Button_Save(true);

					//Pos
					m_SaveButton.x = SAVE_BUTTON_X;
					m_SaveButton.y = SAVE_BUTTON_Y;

					//Click
					m_SaveButton.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{
							//ここに上書き保存
							Game.Instance().Save(m_SelectedIndex);
							//サムネイルの更新など
							OnSave();
						}//セーブを実行する
					);

					//MouseOver
					m_SaveButton.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_SAVE_OVERWRITE));//上書き保存用

					//Register
					m_Content.addChild(m_SaveButton);

					//Hide
					m_SaveButton.visible = false;
				}

				//New
				{
					//Create
					m_SaveButton_New = ImageManager.CreateThumbnailImage_Button_Save(false);

					//Pos
					m_SaveButton_New.x = SAVE_BUTTON_X;
					m_SaveButton_New.y = SAVE_BUTTON_Y;

					//Click
					m_SaveButton_New.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{
							//新規保存
							Game.Instance().Save(-1);
							//サムネイルの更新など
							OnSave();
						}//セーブを実行する
					);

					//MouseOver
					m_SaveButton_New.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_SAVE_NEW));//新規保存用

					//Register
					m_Content.addChild(m_SaveButton_New);

					//Hide
					m_SaveButton_New.visible = false;
				}
			}

			//LoadButton
			{
				//OverWrite
				{
					//Create
					m_LoadButton = ImageManager.CreateThumbnailImage_Button_Load(true);

					//Pos
					m_LoadButton.x = LOAD_BUTTON_X;
					m_LoadButton.y = LOAD_BUTTON_Y;

					//Click
					m_LoadButton.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{Game.Instance().Load(m_SelectedIndex);}//ロードを実行する
					);

					//MouseOver
					m_LoadButton.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_LOAD_OVERWRITE));//上書き保存用

					//Register
					m_Content.addChild(m_LoadButton);

					//Hide
					m_LoadButton.visible = false;
				}

				//New
				{
					//Create
					m_LoadButton_New = ImageManager.CreateThumbnailImage_Button_Load(false);

					//Pos
					m_LoadButton_New.x = LOAD_BUTTON_X;
					m_LoadButton_New.y = LOAD_BUTTON_Y;

					//Click
					m_LoadButton_New.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{Game.Instance().Load(-1);}//クリアを実行する
					);

					//MouseOver
					m_LoadButton_New.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_LOAD_NEW));//新規保存用

					//Register
					m_Content.addChild(m_LoadButton_New);

					//Hide
					m_LoadButton_New.visible = false;
				}
			}
		}

		//#
		//セーブデータの一覧をリストとして表示する処理
		public function InitThumbnails():void{
			//ズームアップした時用のマスクのためのImage作成
			{
				m_MaskImage = new Image();
				m_Content.addChild(m_MaskImage);

				//mask
				var mask_shape:Shape = new Shape();
				var g:Graphics = mask_shape.graphics;
				g.beginFill(0x000000, 1.0);
				g.drawRect(0, 0, Game.TAB_WINDOW_W - ImageManager.TAB_W, Game.TAB_WINDOW_H);
				m_MaskImage.mask = mask_shape;
				m_MaskImage.addChild(mask_shape);
			}

			//ズームイン、アウトのための土台Image作成
			{
				m_ZoomImage = new Image();
				m_MaskImage.addChild(m_ZoomImage);

				UpdateZoom();//初期段階のスケールを計算しておく
			}

			//中身を作成
			{
				//ローカルセーブを司るSharedObject
				var so:SharedObject = Game.Instance().LoadSharedObject();

				var save_num:int;
				{
					save_num = so.data.count;
				}

				//セーブデータからサムネイルを作成
				m_ThumbnailCount = 0;
				for(var i:int = 0; i < save_num; i += 1){
					//一つずつ追加
					{
						AddThumbnail(i, so.data.list[i]);
					}

					//最初の奴は自動でロードしてみる
					{//!!タブじゃなくて本体でやるべき
						if(i == 0){
							Game.Instance().Load(i);
						}
					}
				}

				//新規セーブ用のダミーサムネイルを作成
				{
					AddThumbnail(-1, DefaultStageData);
				}
			}
		}

		//セーブデータ一覧の一つあたりの処理
		public function AddThumbnail(i_Index:int, i_SaveData:Object):void{
			//Base
			var img_base:Image;
			{
				//Create
				{
					img_base = ImageManager.CreateThumbnailImage_Base();
				}

				//Index
				var Index:int;
				{
					Index = (i_Index >= 0)? i_Index: m_ThumbnailCount;
				}

				//Pos
				{
					img_base.x = THUMBNAIL_OFFSET_INIT_X + int(Index % THUMBNAIL_NUM_X) * THUMBNAIL_OFFSET_X;
					img_base.y = THUMBNAIL_OFFSET_INIT_Y + int(Index / THUMBNAIL_NUM_X) * THUMBNAIL_OFFSET_Y;
				}
			}

			//Base : Child
			var img_thumbnail:Image;
			{
				//StageName
				//var img_stage_name:Image;
				//!!

				//Thumbnail
				{
					img_thumbnail = ImageManager.CreateThumbnailImage_Thumbnail(Game.String2Map(i_SaveData.stage));
					img_base.addChild(img_thumbnail);
				}
			}

			//Base : Mouse
			{
				//Mouse
				{
					img_base.addEventListener(
						MouseEvent.MOUSE_DOWN,
						function(e:MouseEvent):void{
							if(m_State == STATE_LIST){//一覧状態でクリックされたら
								//Select This
								{
									m_SelectedData = img_base;
									m_SelectedIndex = i_Index;
								}

								//State
								{
									m_State = STATE_ZOOM_IN;
									m_StateTimer = 0.0;
								}

								//OnSave
								{
									OnSave = function():void{
										//サムネイルの更新
										{
											//remove old
											img_base.removeChild(img_thumbnail);

											//register new
											{
												//現在のステージをセーブしたはずなので、現在のステージのサムネイルを作る
												img_thumbnail = ImageManager.CreateThumbnailImage_Thumbnail(Game.Instance().m_Map);
												img_base.addChild(img_thumbnail);
											}
										}

										//新規保存→次の新規保存用サムネイルを追加
										{
											if(i_Index < 0){
												AddThumbnail(-1, DefaultStageData);
											}
										}

										//新規保存の場合、新しく割り振られたIndexにする
										{
											i_Index = Index;
											m_SelectedIndex = i_Index;
										}

										//ボタンの内容の更新
										{//「新規保存→上書き保存」という表示の変更。新規の場合のみ必要だが、とりあえずどっちの時も呼ぶ
											RefreshButton();
										}
									}
								}
							}
							if(m_State == STATE_SELECTED){//アップ状態でクリックされたら
								//State
								{
									m_State = STATE_ZOOM_OUT;
									m_StateTimer = 0.0;
								}

								//Hide Button
								{
									RefreshButton();
								}
							}
						}
					);
				}
			}

			//Regist
			m_ZoomImage.addChild(img_base);

			//Count++
			m_ThumbnailCount += 1;
		}


		//Update
		override public function Update(i_DeltaTime:Number):void{
			UpdateState(i_DeltaTime);

			UpdateZoom();
		}

		//Update : State
		public function UpdateState(i_DeltaTime:Number):void{
			//Timer
			{
				m_StateTimer += i_DeltaTime;
			}

			//State : 自動遷移するタイプの処理
			{
				switch(m_State){
				case STATE_LIST:
					break;
				case STATE_ZOOM_IN:
					if(m_StateTimer >= ZOOM_IN_TIME){//時間が過ぎたら
						m_State = STATE_SELECTED;//選択表示画面に遷移
						m_StateTimer -= ZOOM_IN_TIME;

						RefreshButton();
					}
					break;
				case STATE_SELECTED:
					break;
				case STATE_ZOOM_OUT:
					if(m_StateTimer >= ZOOM_OUT_TIME){//時間が過ぎたら
						m_State = STATE_LIST;//一覧表示画面に遷移
						m_StateTimer -= ZOOM_OUT_TIME;
					}
					break;
				}
			}
		}

		//Update : Zoom
		public function UpdateZoom():void{
			const calc_val:Function = function(in_Src:Number, in_Dst:Number, in_TotalTime:Number):Number{
				var ratio:Number = m_StateTimer / in_TotalTime;
				ratio = MyMath.Sin(0.5*Math.PI * ratio);
				return (in_Src * (1 - ratio)) + (in_Dst * ratio);
			};

			//Scale
			{
				switch(m_State){
				case STATE_LIST://全体表示
					m_ZoomImage.scaleX = ZOOM_OUT_SCALE;
					m_ZoomImage.scaleY = ZOOM_OUT_SCALE;
					break;
				case STATE_ZOOM_IN:
					m_ZoomImage.scaleX = calc_val(ZOOM_OUT_SCALE, 1, ZOOM_IN_TIME);
					m_ZoomImage.scaleY = calc_val(ZOOM_OUT_SCALE, 1, ZOOM_IN_TIME);
					break;
				case STATE_SELECTED://等倍
					m_ZoomImage.scaleX = 1;
					m_ZoomImage.scaleY = 1;
					break;
				case STATE_ZOOM_OUT:
					m_ZoomImage.scaleX = calc_val(1, ZOOM_OUT_SCALE, ZOOM_OUT_TIME);
					m_ZoomImage.scaleY = calc_val(1, ZOOM_OUT_SCALE, ZOOM_OUT_TIME);
					break;
				}
			}

			//TrgPos
			{
				var trgX:Number;
				var trgY:Number;
				{
					if(m_SelectedData){
						trgX = -m_SelectedData.x + ZOOM_OUT_OFFSET_X;
						trgY = -m_SelectedData.y + ZOOM_OUT_OFFSET_Y;
					}else{
						trgX = 0;
						trgY = 0;
					}
				}

				switch(m_State){
				case STATE_LIST://位置をリセット
					m_ZoomImage.x = 0;
					m_ZoomImage.y = 0;
					break;
				case STATE_ZOOM_IN:
					m_ZoomImage.x = calc_val(0, trgX, ZOOM_IN_TIME);
					m_ZoomImage.y = calc_val(0, trgY, ZOOM_IN_TIME);
					break;
				case STATE_SELECTED://ターゲットを所定位置に
					m_ZoomImage.x = trgX;
					m_ZoomImage.y = trgY;
					break;
				case STATE_ZOOM_OUT:
					m_ZoomImage.x = calc_val(trgX, 0, ZOOM_OUT_TIME);
					m_ZoomImage.y = calc_val(trgY, 0, ZOOM_OUT_TIME);
					break;
				}
			}
		}

		//ボタンの表示・非表示などの更新
		public function RefreshButton():void{
			switch(m_State){
			case STATE_LIST:
			case STATE_ZOOM_IN:
			case STATE_ZOOM_OUT:
				m_SaveButton.visible = false;
				m_SaveButton_New.visible = false;
				m_LoadButton.visible = false;
				m_LoadButton_New.visible = false;
				break;
			case STATE_SELECTED:
				m_SaveButton.visible = (m_SelectedIndex >= 0);
				m_SaveButton_New.visible = !m_SaveButton.visible;
				m_LoadButton.visible = (m_SelectedIndex >= 0);
				m_LoadButton_New.visible = !m_LoadButton.visible;
				break;
			}
		}
	}
}

