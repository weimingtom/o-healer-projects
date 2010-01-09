//author Show=O=Healer

package{
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class ImageManager{
		//==Const==

		//パネルの一辺の長さ
		static public const PANEL_LEN:int = 32;

		//Alias
		static public const O:int = Game.O;
		static public const W:int = Game.W;


		//==Function==

		//＃BG

		[Embed(source='Dangeon.png')]
		 private static var Bitmap_BG: Class;

		static public var m_BitmapBG:Bitmap = new Bitmap_BG();
		static public var m_color_transform : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);

		//一つのブロックを４つに分割して描く
		static public function DrawBG(o_BG_BitmapData:BitmapData, i_Map:Array, i_Rect:Rectangle):void{
			var x:int;
			var y:int;

			var dst_rect_lu : Rectangle = new Rectangle(0,0,PANEL_LEN/2,PANEL_LEN/2);
			var dst_rect_ru : Rectangle = new Rectangle(0,0,PANEL_LEN/2,PANEL_LEN/2);
			var dst_rect_ld : Rectangle = new Rectangle(0,0,PANEL_LEN/2,PANEL_LEN/2);
			var dst_rect_rd : Rectangle = new Rectangle(0,0,PANEL_LEN/2,PANEL_LEN/2);

			//draw
			for(y = i_Rect.y; y < i_Rect.y + i_Rect.height; y += 1){
				dst_rect_lu.y = dst_rect_ru.y = y * PANEL_LEN;
				dst_rect_ld.y = dst_rect_rd.y = y * PANEL_LEN + PANEL_LEN/2;

				for(x = i_Rect.x; x < i_Rect.x + i_Rect.width; x += 1){
					dst_rect_lu.x = dst_rect_ld.x = x * PANEL_LEN;
					dst_rect_ru.x = dst_rect_rd.x = x * PANEL_LEN + PANEL_LEN/2;


					var id_c:int = GetIndex(x, y, i_Map);

					//o_BG_BitmapData
					{
						var id_l:int = GetIndex(x-1, y, i_Map);
						var id_r:int = GetIndex(x+1, y, i_Map);
						var id_u:int = GetIndex(x, y-1, i_Map);
						var id_d:int = GetIndex(x, y+1, i_Map);
						var id_lu:int = GetIndex(x-1, y-1, i_Map);
						var id_ru:int = GetIndex(x+1, y-1, i_Map);
						var id_ld:int = GetIndex(x-1, y+1, i_Map);
						var id_rd:int = GetIndex(x+1, y+1, i_Map);

						//LU
						DrawBG_Quarter(o_BG_BitmapData, dst_rect_lu, POS_LU, id_c, id_l, id_u, id_lu);
						//RU
						DrawBG_Quarter(o_BG_BitmapData, dst_rect_ru, POS_RU, id_c, id_r, id_u, id_ru);
						//LD
						DrawBG_Quarter(o_BG_BitmapData, dst_rect_ld, POS_LD, id_c, id_l, id_d, id_ld);
						//RD
						DrawBG_Quarter(o_BG_BitmapData, dst_rect_rd, POS_RD, id_c, id_r, id_d, id_rd);
					}
				}
			}
		}

		static public function GetIndex(x:int, y:int, i_Map:Array):int{
			//Check : Range
			{
				if(x < 0){return W;}
				if(x >= i_Map[0].length){return W;}
				if(y < 0){return W;}
				if(y >= i_Map.length){return W;}
			}

			return i_Map[y][x];
		}

		//４隅のうちどこを描くか
		static public const POS_LU:int = 0;
		static public const POS_RU:int = 1;
		static public const POS_LD:int = 2;
		static public const POS_RD:int = 3;
		static public const POS_NUM:int = 4;

		//指定された隅を描く
		static public function DrawBG_Quarter(o_BG_BitmapData:BitmapData, i_DstRect:Rectangle, i_Pos:int, i_ID_C:int, i_ID_X:int, i_ID_Y:int, i_ID_XY:int):void{
			//Indexx
			var index_xy:Array = [0, 0];
			{
				switch(i_ID_C){
				case W:
					if(i_ID_X != W){
						//O
						if(i_ID_Y != W){
							//OO
							index_xy = [[0, 0], [2, 0], [0, 2], [2, 2]][i_Pos];//LU. RU, LD, RD
						}else{
							//OW
							index_xy = [[0, 1], [2, 1], [0, 1], [2, 1]][i_Pos];//LU. RU, LD, RD
						}
					}else{
						//W
						if(i_ID_Y != W){
							//WO
							index_xy = [[1, 0], [1, 0], [1, 2], [1, 2]][i_Pos];//LU. RU, LD, RD
						}else{
							//WW
							if(i_ID_XY != W){
								//WWO
								index_xy = [[0, 3], [1, 3], [0, 4], [1, 4]][i_Pos];//LU. RU, LD, RD
							}else{
								//WWW
								index_xy = [1, 1];
							}
						}
					}
					break;
				default://O, P, B
					index_xy = [3, 2];
					break;
				}
			}

			//Draw
			{
				//indexの位置の画像を、DstRectの枠に入るように移動
				var matrix : Matrix = new Matrix(1,0,0,1, -index_xy[0]*PANEL_LEN/2 + i_DstRect.left, -index_xy[1]*PANEL_LEN/2 + i_DstRect.top);

				o_BG_BitmapData.draw(m_BitmapBG, matrix, m_color_transform, BlendMode.NORMAL, i_DstRect, true);
			}
		}


		//＃Block

		[Embed(source='Block_Move.png')]
		 private static var Bitmap_Block_Move: Class;//BLOCK_INDEX_MOVE
		[Embed(source='Goal.png')]
		 private static var Bitmap_Goal: Class;//BLOCK_INDEX_GOAL

		private static var m_BlockList:Array = [
			new Bitmap_Block_Move(),//O:空白
			new Bitmap_Block_Move(),//W:地形
			new Bitmap_Block_Move(),//P:プレイヤー位置（生成後は空白として扱われる）
			new Bitmap_Goal(),//G:ゴール位置（基本的には空白として扱われる）
			new Bitmap_Block_Move(),//Q:動かせるブロック（生成後は空白として扱われる）
			new Bitmap_Block_Move(),//S:赤青ブロック用の切り替えスイッチ
			new Bitmap_Block_Move(),//R:赤ブロック
			new Bitmap_Block_Move(),//B:青ブロック
			//system
			new Bitmap_Block_Move(),//C:
			new Bitmap_Block_Move(),//V:
			new Bitmap_Block_Move(),//SET_RANGE:
			new Bitmap_Block_Move(),//SET_DIR:
		];

		static public function LoadBlockImage(i_BlockIndex:int):Image{
			var result:Image = new Image();

			var src_bmp:Bitmap = m_BlockList[i_BlockIndex];
			var dst_bmp:Bitmap = new Bitmap(src_bmp.bitmapData.clone());

			//centering
			dst_bmp.x = -dst_bmp.width/2;
			dst_bmp.y = -dst_bmp.height/2;

			result.addChild(dst_bmp);

			return result;
		}


		//＃Character

		[Embed(source='Player.png')]
		 private static var Bitmap_Player: Class;

		private static var m_EmbedMap:Object = {
			"Player":(new Bitmap_Player())
		};

		public static const CHARA_GRAPHIC_LEN_X:int = 24;
		public static const CHARA_GRAPHIC_LEN_Y:int = 32;

		//=Array<Image>=
		static public function LoadCharaImage(i_Name:String):Array{
			var packed_image:Array = new Array();

			var x:int;
			var y:int;

			//Init
			{
				for(y = 0; y < 4; y += 1){
					packed_image.push(new Array());

					for(x = 0; x < 3; x += 1){
						packed_image[y].push(new Image());
					}
				}
			}

			//Load
			{
				var bmp:Bitmap = m_EmbedMap[i_Name];

				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);

				for(y = 0; y < 4; y += 1){
					var offset_y:int = y * CHARA_GRAPHIC_LEN_Y;

					for(x = 0; x < 3; x += 1){
						var offset_x:int = x * CHARA_GRAPHIC_LEN_X;

						var bmp_data:BitmapData = new BitmapData(CHARA_GRAPHIC_LEN_X, CHARA_GRAPHIC_LEN_Y, true, 0x00000000);
						{
							var matrix : Matrix = new Matrix(1,0,0,1, -offset_x,-offset_y);

							var rect : Rectangle = new Rectangle(
								0,
								0,
								CHARA_GRAPHIC_LEN_X,
								CHARA_GRAPHIC_LEN_Y
							);

							bmp_data.draw(bmp, matrix, color, BlendMode.NORMAL, rect, true);
						}

						//取り込んだビットマップデータを表示
						var bmp_obj:Bitmap = new Bitmap( bmp_data , PixelSnapping.AUTO , true);
						{
							bmp_obj.x = -CHARA_GRAPHIC_LEN_X*0.5;
							bmp_obj.y = -CHARA_GRAPHIC_LEN_Y + CHARA_GRAPHIC_LEN_X*0.5;//-CHARA_GRAPHIC_LEN_Y*0.5;
						}

						//AddChild
						{
							packed_image[y][x].addChild(bmp_obj);
						}
					}
				}
			}

			return packed_image;
		}


		//#Cursor（白い枠）

		static public function CreateCursorImage():Image{
			var shape:Shape = new Shape();
			var graphic:Graphics = shape.graphics;

			var W:int = 5;
			var Color:uint = 0xFFFFFF;
			graphic.lineStyle(W, Color, 1.0);
//			graphic.beginFill(COLOR_WHITE);

			//Draw
			var len:int = PANEL_LEN;
			graphic.drawRect(0, 0, len, len);

			//Result
			var Result:Image = new Image();
			Result.addChild(shape);
			return Result;
		}


		//#タブウィンドウまわり

		//ウィンドウ本体
		static public function CreateTabWindow(i_W:int, i_H:int):Image{
			var bmp_data:BitmapData = new BitmapData(i_W, i_H, true, 0xFF888888);
			var tab_w:int = TabWindow.TAB_W;
			bmp_data.fillRect(new Rectangle(tab_w, 0, i_W - tab_w, i_H), 0xFFFFFFFF);

			var bmp:Bitmap = new Bitmap(bmp_data);

			var img:Image = new Image();
			img.addChild(bmp);

			return img;
		}

		//タブの部分
		static public function CreateTabImage(i_TabName:String):Image{
			var bmp_data:BitmapData = new BitmapData(TabWindow.TAB_W, TabWindow.TAB_H * (i_TabName.length + 2), true, 0x00000000);
			bmp_data.fillRect(new Rectangle(0, TabWindow.TAB_H, TabWindow.TAB_W, TabWindow.TAB_H * i_TabName.length), 0xFFFFFFFF);

			//Draw Label
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				matrix.ty += TabWindow.TAB_H;

				var tf:TextField = new TextField();
				tf.selectable = false;
				tf.autoSize = TextFieldAutoSize.LEFT;

				for(var i:int = 0; i < i_TabName.length; i += 1){
					tf.text = i_TabName.charAt(i);
					tf.width = tf.textWidth;
					tf.height = tf.textHeight;
		//			tf.setTextFormat( fmt );

					bmp_data.draw(tf, matrix);

					matrix.ty += TabWindow.TAB_H;
				}
	 		}

			var bmp:Bitmap = new Bitmap(bmp_data);

			var img:Image = new Image();
			img.addChild(bmp);

			return img;
		}

		//#Tab : Hint

		//ヒントの「文字：画像」のパーツひとまとめ
		private static var INDEX_TO_CHAR:Array = [
			"Ｏ",//O:空白
			"Ｗ",//W:地形
			"Ｐ",//P:プレイヤー位置（生成後は空白として扱われる）
			"Ｇ",//G:ゴール位置（基本的には空白として扱われる）
			"Ｑ",//Q:動かせるブロック（生成後は空白として扱われる）
			"Ｓ",//S:赤青ブロック用の切り替えスイッチ
			"Ｒ",//R:赤ブロック
			"Ｂ",//B:青ブロック
			//system
			"Ｃ",//C:
			"Ｖ",//V:
			"Shift",//SET_RANGE:
			"Ctrl",//SET_DIR:
		];
		static public function CreateHintImage(i_Index:int):Image{
			var bmp_data:BitmapData = new BitmapData(Tab_Hint.PANEL_W, Tab_Hint.PANEL_H, true, 0x00000000);
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					text_field.text = INDEX_TO_CHAR[i_Index];

					matrix.tx = 0;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}

				//「：」
				{
					text_field.text = ":";

					matrix.tx = 32;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}

				//画像
				{
					var img_block:Image = LoadBlockImage(i_Index);//やっぱりブロックのIndexはゲームのを流用。ヒント用に一通りの画像を揃える
//					img_block.x = img_block.y = PANEL_LEN/2;

					matrix.tx = 55;
					matrix.ty = ImageManager.PANEL_LEN/2;

					bmp_data.draw(img_block, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}


		//#Tab : Setting

		//ベース画像
		static public const SETTING_BASE_W:int = 32 * 5;
		static public const SETTING_BASE_H:int = 32 * 3;
		static public function CreateSettingImage_Base():Image{
			var bmp_data:BitmapData = new BitmapData(SETTING_BASE_W, SETTING_BASE_H, true, 0xFF444488);

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//値の表示（ここでは空のBMPを返すだけ）
		static public const SETTING_VAL_W:int = 32 * 3;
		static public const SETTING_VAL_H:int = 32 * 1;
		static public function CreateSettingBitmap_Val():Bitmap{
			var bmp_data:BitmapData = new BitmapData(SETTING_VAL_W, SETTING_VAL_H, true, 0x00000000);

			//Bitmapに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				return bmp;
			}
		}

		//値を増加させるボタン
		static public const BUTTON_SETTING_UP_W:int = 32 * 3;
		static public const BUTTON_SETTING_UP_H:int = 32;
		static public function CreateSettingImage_Button_Up():Image{
			var bmp_data:BitmapData = new BitmapData(BUTTON_SETTING_UP_W, BUTTON_SETTING_UP_H, true, 0xFFFFFFFF);
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					text_field.text = "↑";

					matrix.tx = 0;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//値を減少させるボタン
		static public const BUTTON_SETTING_DOWN_W:int = 32 * 3;
		static public const BUTTON_SETTING_DOWN_H:int = 32;
		static public function CreateSettingImage_Button_Down():Image{
			var bmp_data:BitmapData = new BitmapData(BUTTON_SETTING_DOWN_W, BUTTON_SETTING_DOWN_H, true, 0xFFFFFFFF);
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					text_field.text = "↓";

					matrix.tx = 0;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		static public function RedrawSettingBitmap_Val(i_Bitmap:Bitmap, i_Val:int):void{
			var bmp_data:BitmapData = i_Bitmap.bitmapData;

			//Clear
			{
				bmp_data.fillRect(bmp_data.rect, 0x00000000);
			}

			//Draw
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = bmp_data.rect;

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					text_field.text = i_Val.toString();

					matrix.tx = (3 - text_field.text.length) * 32;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}
		}


		//#Tab : Save

		//セーブデータひとかたまり用のベース画像
		static public const SAVE_BASE_W:int = 32 * 5;
		static public const SAVE_BASE_H:int = 32 * 3;
		static public function CreateThumbnailImage_Base():Image{
			var bmp_data:BitmapData = new BitmapData(SAVE_BASE_W, SAVE_BASE_H, true, 0xFF444444);

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//ステージのサムネイル画像
		static public const SAVE_THUMBNAIL_W:int = 32 * 3;
		static public const SAVE_THUMBNAIL_H:int = 32 * 3;
		static public const SAVE_THUMBNAIL_FRAME_W:int = 1;
		static public function CreateThumbnailImage_Thumbnail(i_Map:Array):Image{
			var bmp_data:BitmapData = new BitmapData(SAVE_THUMBNAIL_W, SAVE_THUMBNAIL_H, true, 0xFF444444);
			//枠の描画
			{
				//実際には枠の色は上の生成時の色。ここでは透明色で抜くだけ
				bmp_data.setPixel(0,					0,					0x00000000);
				bmp_data.setPixel(SAVE_THUMBNAIL_W-1,	0,					0x00000000);
				bmp_data.setPixel(0,					SAVE_THUMBNAIL_H-1,	0x00000000);
				bmp_data.setPixel(SAVE_THUMBNAIL_W-1,	SAVE_THUMBNAIL_H-1,	0x00000000);
			}

			//マップの描画
			{
				var NumX:int = i_Map[0].length;
				var NumY:int = i_Map.length;

				//まずはMapを同じ比率のBMPに描く
				var bmp_data_ori:BitmapData = new BitmapData(NumX, NumY, false, 0x000000);
				{
					for(var y:int = 0; y < NumY; y += 1){
						for(var x:int = 0; x < NumX; x += 1){
							//マップの種類に応じた色を設定して
							var color:uint = 0x000000;
							{
								switch(i_Map[y][x]){
								case Game.O: color = 0xFFFFFF; break;
								case Game.W: color = 0x000000; break;
								case Game.P: color = 0xFF8800; break;
								case Game.G: color = 0xDDDD00; break;
								case Game.Q: color = 0x888888; break;
								case Game.S: color = 0xFF00FF; break;
								case Game.R: color = 0xFF0000; break;
								case Game.B: color = 0x0000FF; break;
								}
							}

							//ドットをうつ
							bmp_data_ori.setPixel(x, y, color);
						}
					}
				}

				//それをサムネイルにフィットさせるための比率を求める
				var Ratio:Number;
				{
					//縦横それぞれのフィット率を求める
					var RatioX:Number = (SAVE_THUMBNAIL_W - SAVE_THUMBNAIL_FRAME_W*2) / NumX;
					var RatioY:Number = (SAVE_THUMBNAIL_H - SAVE_THUMBNAIL_FRAME_W*2) / NumY;

					//低い方に合わせる
					Ratio = MyMath.Min(RatioX, RatioY);
				}

				//その比率で実際のサムネイルに描画
				{
					bmp_data.draw(
						bmp_data_ori,
						new Matrix(Ratio, 0, 0, Ratio, SAVE_THUMBNAIL_FRAME_W, SAVE_THUMBNAIL_FRAME_W)
					);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//セーブボタン用の画像
		static public const BUTTON_SAVE_W:int = 32 * 2;
		static public const BUTTON_SAVE_H:int = 32;
		static public function CreateThumbnailImage_Button_Save(i_IsOverWrite:Boolean):Image{
			var bmp_data:BitmapData = new BitmapData(BUTTON_SAVE_W, BUTTON_SAVE_H, true, 0xFFFFFFFF);
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					if(! i_IsOverWrite){
						text_field.text = "=> 新規保存";//新規
					}else{
						text_field.text = "=> 上書き";//上書き
					}

					matrix.tx = 0;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}


		//ロードボタン用の画像
		static public const BUTTON_LOAD_W:int = 32 * 2;
		static public const BUTTON_LOAD_H:int = 32;
		static public function CreateThumbnailImage_Button_Load(i_IsOverWrite:Boolean):Image{
			var bmp_data:BitmapData = new BitmapData(BUTTON_LOAD_W, BUTTON_LOAD_H, true, 0xFFFFFFFF);
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				var rect : Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				var text_field:TextField = new TextField();
				{
					text_field.border = false;
					text_field.x = 0;
					text_field.y = 0;
					text_field.width = 999;
					text_field.height = 999;
				}

				//キー
				{
					if(! i_IsOverWrite){
						text_field.text = "<= クリア";//新規
					}else{
						text_field.text = "<= ロード";//上書き
					}

					matrix.tx = 0;

					bmp_data.draw(text_field, matrix, color, BlendMode.NORMAL, rect, true);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}
	}
}


