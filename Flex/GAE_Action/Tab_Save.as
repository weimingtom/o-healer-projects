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

		static public const HINT_MESSAGE_BUTTON_SAVE_NEW:String = "今のデータを今までのとは別に新しく保存します";
		static public const HINT_MESSAGE_BUTTON_SAVE_OVERWRITE:String = "このデータに今のデータを上書きして保存します";

		static public const HINT_MESSAGE_BUTTON_LOAD_NEW:String = "今のデータを全て空にします";
		static public const HINT_MESSAGE_BUTTON_LOAD_OVERWRITE:String = "このデータをロードします（今のデータは消えます）";

		//==Function==

		//Init
		public function Tab_Save(){
			//Tab
			{
				super("セ｜ブ");//縦に表示するため、伸ばし棒は縦にしておく
			}

			//Content
			{
				InitThumbnails();
			}
		}

		//#
		//セーブデータの一覧をリストとして表示する処理
		public function InitThumbnails():void{
			//ローカルセーブを司るSharedObject
			var so:SharedObject = Game.Instance().LoadSharedObject();

			var save_num:int;
			{
				save_num = so.data.count;
			}

			//新規セーブ用のダミーサムネイルを作成
			{
				AddThumbnail(-1, {stage:"O"});
			}

			//セーブデータからサムネイルを作成
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
		}

		//セーブデータ一覧の一つあたりの処理
		public function AddThumbnail(i_Index:int, i_SaveData:Object):void{
			//Base
			var img_base:Image;
			{
				img_base = ImageManager.CreateThumbnailImage_Base();
				img_base.x = 0;
				img_base.y = (i_Index+1) * (32 * 3);
			}

			//Base : Child
			{
				//StageName
				//var img_stage_name:Image;
				//!!

				//Thumbnail
				{
					var img_thumbnail:Image;
					img_thumbnail = ImageManager.CreateThumbnailImage_Thumbnail(Game.String2Map(i_SaveData.stage));
					img_thumbnail.x = 32 * 2;
					img_thumbnail.y = 0;//32;

					img_base.addChild(img_thumbnail);
				}

				//Button_Save
				{
					var img_button_save:Image;
					img_button_save = ImageManager.CreateThumbnailImage_Button_Save(i_Index >= 0);//-1なら新規セーブボタン、そうでなければ上書きセーブボタン
					img_button_save.x = 0;
					img_button_save.y = 0;//32;

					//Click
					img_button_save.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{Game.Instance().Save(i_Index);}//セーブを実行する
					);

					//MouseOver
					if(i_Index < 0){
						img_button_save.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_SAVE_NEW));//新規保存用
					}else{
						img_button_save.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_SAVE_OVERWRITE));//上書き保存用
					}

					img_base.addChild(img_button_save);
				}

				//Button_Load
				{
					var img_button_load:Image;
					img_button_load = ImageManager.CreateThumbnailImage_Button_Load(i_Index >= 0);//-1ならクリアボタン、そうでなければロードボタン
					img_button_load.x = 0;
					img_button_load.y = 32 * 2;//32 * 3;

					//Click
					img_button_load.addEventListener(//クリック時の挙動を追加
						MouseEvent.CLICK,//クリックされたら
						function(e:Event):void{Game.Instance().Load(i_Index);}//ロードを実行する
					);

					//MouseOver
					if(i_Index < 0){
						img_button_load.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_LOAD_NEW));//クリア用
					}else{
						img_button_load.addEventListener(MouseEvent.MOUSE_OVER, CreateShowMessagehandler(HINT_MESSAGE_BUTTON_LOAD_OVERWRITE));//ロード用
					}

					img_base.addChild(img_button_load);
				}
			}

			//Regist
			m_Content.addChild(img_base);
		}
	}
}

