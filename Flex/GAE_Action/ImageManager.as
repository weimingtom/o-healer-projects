//author Show=O=Healer

package{
	import flash.display.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.filters.*;
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class ImageManager{
		//==Font==
		private var myfont:MyFont;//フォントのEmbedに対応するためのダミーメンバ変数

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


		//#ゲームの枠

		static public const GAME_FRAME_W:int = 16;
		static public const GAME_FRAME_H:int = 16;

		[Embed(source='Frame.png')]
		 private static var Bitmap_Frame: Class;

		static public function CreateGameFrameImage(i_W:int, i_H:int):Image{
			var bmp_data:BitmapData = new BitmapData(i_W + 2*GAME_FRAME_W, i_H + 2*GAME_FRAME_H, true, 0x00000000);
			{
				var SrcBitmap:Bitmap = new Bitmap_Frame();

				var ct : ColorTransform = new ColorTransform();

				var mtx : Matrix = new Matrix(1,0,0,1, 0,0);

				var rect : Rectangle = new Rectangle(
					0,
					0,
					GAME_FRAME_W,
					GAME_FRAME_H
				);

				//UL
				{
					mtx.tx = 0;
					mtx.ty = 0;
					rect.x = 0;
					rect.y = 0;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//UR
				{
					mtx.tx = -GAME_FRAME_W*2 + i_W;
					mtx.ty = 0;
					rect.x = GAME_FRAME_W + i_W;
					rect.y = 0;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//DL
				{
					mtx.tx = 0;
					mtx.ty = -GAME_FRAME_H*2 + i_H;
					rect.x = 0;
					rect.y = GAME_FRAME_H + i_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//DR
				{
					mtx.tx = -GAME_FRAME_W*2 + i_W;
					mtx.ty = -GAME_FRAME_H*2 + i_H;
					rect.x = GAME_FRAME_W + i_W;
					rect.y = GAME_FRAME_H + i_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}

				//U
				{
					mtx.a = i_W / (2*GAME_FRAME_W);
					mtx.d = 1;
					mtx.tx = -GAME_FRAME_W * mtx.a + GAME_FRAME_W;
					mtx.ty = 0;
					rect.x = GAME_FRAME_W;
					rect.y = 0;
					rect.width  = i_W;
					rect.height = GAME_FRAME_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//D
				{
					mtx.a = i_W / (2*GAME_FRAME_W);
					mtx.d = 1;
					mtx.tx = -GAME_FRAME_W * mtx.a + GAME_FRAME_W;
					mtx.ty = -GAME_FRAME_H*2 + i_H;
					rect.x = GAME_FRAME_W;
					rect.y = GAME_FRAME_H + i_H;
					rect.width  = i_W;
					rect.height = GAME_FRAME_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//L
				{
					mtx.a = 1;
					mtx.d = i_H / (2*GAME_FRAME_H);
					mtx.tx = 0;
					mtx.ty = -GAME_FRAME_H * mtx.d + GAME_FRAME_H;
					rect.x = 0;
					rect.y = GAME_FRAME_H;
					rect.width  = GAME_FRAME_W;
					rect.height = i_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
				//R
				{
					mtx.a = 1;
					mtx.d = i_H / (2*GAME_FRAME_H);
					mtx.tx = -GAME_FRAME_W*2 + i_W;
					mtx.ty = -GAME_FRAME_H * mtx.d + GAME_FRAME_H;
					rect.x = GAME_FRAME_W + i_W;
					rect.y = GAME_FRAME_H;
					rect.width  = GAME_FRAME_W;
					rect.height = i_H;
					bmp_data.draw(SrcBitmap, mtx, ct, BlendMode.NORMAL, rect);
				}
			}

			var img:Image;
			{
				img = new Image();

				var bmp:Bitmap = new Bitmap(bmp_data);

				img.addChild(bmp);

				img.width  = i_W + GAME_FRAME_W*2;
				img.height = i_H + GAME_FRAME_H*2;
			}

			return img;
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

		static public const TAB_W:int = 24;//一文字当たりの幅
		static public const TAB_FRAME_W:int = 3;

		//ウィンドウ本体
		static public function CreateTabWindow(i_W:int, i_H:int):Image{
			var bmp_data:BitmapData = new BitmapData(i_W, i_H, true, 0x00000000);
			var tab_w:int = TAB_W;

			var bmp:Bitmap = new Bitmap(bmp_data);

			var img:Image = new Image();
			img.addChild(bmp);

			img.width  = i_W;
			img.height = i_H;

			return img;
		}

		//タブの部分
		static public function CreateTabImage(i_TabName:String, i_BaseColor:uint = 0x000000):Image{
			//基本的なタブの大きさはは1x5
			var bmp_data:BitmapData = new BitmapData(TAB_W, TAB_W*5, true, 0x00000000);

			//Draw Frame & BackColor
			{
				var frame_color:uint = Convert2FrameColor(i_BaseColor);
				var frame_highlightt_color:uint = Convert2FrameColor_Light(i_BaseColor);
				var back_color:uint  = Convert2BackColor(i_BaseColor);

				var sprite:Sprite = new Sprite();
				{
					var g:Graphics = sprite.graphics;

					g.lineStyle(TAB_FRAME_W, frame_color, 1.0);
					BeginGradatioForTabBackColor(g, i_BaseColor);
//					g.beginFill(back_color, 1.0);

					g.moveTo(TAB_W*1, TAB_FRAME_W/2);
					g.lineTo(TAB_FRAME_W/2, TAB_W*1);
					g.lineTo(TAB_FRAME_W/2, TAB_W*4);
					g.lineTo(TAB_W*1, TAB_W*5-TAB_FRAME_W/2);
					g.lineTo(TAB_W*2, TAB_W*5-TAB_FRAME_W/2);
					g.lineTo(TAB_W*2, TAB_FRAME_W);

					g.endFill();


					//さらに枠にハイライトの線を入れてみる
					g.lineStyle(1, frame_highlightt_color, 1.0);
					g.lineTo(TAB_W*1-TAB_FRAME_W/2, -99);
					g.moveTo(TAB_W*1-TAB_FRAME_W/2, TAB_FRAME_W/2);
					g.lineTo(TAB_FRAME_W/2, TAB_W*1);
					g.lineTo(TAB_FRAME_W/2, TAB_W*4);
					g.lineTo(TAB_W*1-TAB_FRAME_W/2, TAB_W*5-TAB_FRAME_W/2);
					g.lineTo(TAB_W*1-TAB_FRAME_W/2, TAB_W*5+99);
				}

				bmp_data.draw(sprite);
			}

			//Draw Label
			{
				const char_size:int = TAB_W - TAB_FRAME_W*2 - 2;
				const ori_size:int = 32;//このサイズで描画して、上のサイズに縮小する

				var text_frame_color:uint = Convert2TextFrameColor(i_BaseColor);

				var matrix : Matrix = new Matrix(1.0*char_size/ori_size,0,0,1.0*char_size/ori_size,0,0);
				matrix.ty += TAB_W;
				if(i_TabName.length == 2){matrix.ty += TAB_W/2;}

				var tf:TextField = new TextField();
				tf.selectable = false;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.filters = [
					new GlowFilter(
						text_frame_color,
						1,//alpha
						3,3,//x, y
						2,//Strength
						1//Quality
					),
				];

				for(var i:int = 0; i < i_TabName.length; i += 1){
/*
					tf.text = i_TabName.charAt(i);
/*/
					tf.embedFonts = true;
					tf.htmlText = "<font face='ume' size='" + ori_size.toString() + "'>" + i_TabName.charAt(i) + "</font>";
//*/
//					tf.width = tf.textWidth;
//					tf.height = tf.textHeight;
					matrix.tx = TAB_W/2 - char_size/2
		//			tf.setTextFormat( fmt );

					bmp_data.draw(tf, matrix);

					matrix.ty += TAB_W;
				}
	 		}

			var bmp:Bitmap = new Bitmap(bmp_data);

			var img:Image = new Image();
			img.addChild(bmp);

			return img;
		}

		//コンテナ（独自描画部分）の背景
		static public function CreateTabContentImage(i_BaseColor:uint = 0x000000):Image{
			const TAB_CONTAINER_W:uint = Game.TAB_WINDOW_W - TAB_W + TAB_FRAME_W;
			const TAB_CONTAINER_H:uint = Game.TAB_WINDOW_H;

			//生成と同時に背景色も描画してしまう
			var bmp_data:BitmapData = new BitmapData(TAB_CONTAINER_W, TAB_CONTAINER_H, false, Convert2BackColor(i_BaseColor));

			//Draw Frame & Back Color
			{
				var frame_color:uint = Convert2FrameColor(i_BaseColor);
				var frame_highlightt_color:uint = Convert2FrameColor_Light(i_BaseColor);

				var sprite:Sprite = new Sprite();
				{//グラデーションをかけてみる
					var g:Graphics = sprite.graphics;

					g.lineStyle(TAB_FRAME_W, frame_color, 1.0);
					BeginGradatioForTabBackColor(g, i_BaseColor);

					g.moveTo(TAB_FRAME_W/2, -99);
					g.lineTo(TAB_FRAME_W/2, TAB_CONTAINER_H+99);
					g.lineTo(TAB_CONTAINER_W+99, TAB_CONTAINER_H+99);
					g.lineTo(TAB_CONTAINER_W+99, -99);

					g.endFill();

					//さらに枠にハイライトの線を入れてみる
					g.lineStyle(1, frame_highlightt_color, 1.0);
					g.moveTo(TAB_FRAME_W/2, -99);
					g.lineTo(TAB_FRAME_W/2, TAB_CONTAINER_H+99);
				}

				bmp_data.draw(sprite);
			}

			var bmp:Bitmap = new Bitmap(bmp_data);
			bmp.x =  -TAB_FRAME_W;//枠の部分は外にはみ出させておく

			var img:Image = new Image();
			img.addChild(bmp);

			return img;
		}

		//元の色から、枠の色や背景色を求める
		//・枠の色
		static public function Convert2FrameColor(i_BaseColor:uint):uint{
			var r:uint = (i_BaseColor >> 16) & 0xFF;
			var g:uint = (i_BaseColor >>  8) & 0xFF;
			var b:uint = (i_BaseColor >>  0) & 0xFF;

			{//独自部分
				//彩度を落として暗めの色にする
				var ratio:Number = 0.5;

				r = MyMath.Lerp(r, 0x00, ratio);
				g = MyMath.Lerp(g, 0x00, ratio);
				b = MyMath.Lerp(b, 0x00, ratio);
			}

			return (r << 16) | (g << 8) | (b << 0);
		}
		static public function Convert2FrameColor_Light(i_BaseColor:uint):uint{//ハイライト
			var r:uint = (i_BaseColor >> 16) & 0xFF;
			var g:uint = (i_BaseColor >>  8) & 0xFF;
			var b:uint = (i_BaseColor >>  0) & 0xFF;

			{//独自部分
				//彩度を落として暗めの色にする
				var ratio:Number = 0.5;

				r = MyMath.Lerp(r, 0x80, ratio);
				g = MyMath.Lerp(g, 0x80, ratio);
				b = MyMath.Lerp(b, 0x80, ratio);
			}

			return (r << 16) | (g << 8) | (b << 0);
		}
		//・背景色
		static public function Convert2BackColor(i_BaseColor:uint):uint{
			var r:uint = (i_BaseColor >> 16) & 0xFF;
			var g:uint = (i_BaseColor >>  8) & 0xFF;
			var b:uint = (i_BaseColor >>  0) & 0xFF;

			{//独自部分
				//薄いパステルカラーにする
				var ratio:Number = 0.85;

				r = MyMath.Lerp(r, 0xFF, ratio);
				g = MyMath.Lerp(g, 0xFF, ratio);
				b = MyMath.Lerp(b, 0xFF, ratio);
			}

			return (r << 16) | (g << 8) | (b << 0);
		}
		static public function Convert2BackColor_Dst(i_BaseColor:uint):uint{
			var r:uint = (i_BaseColor >> 16) & 0xFF;
			var g:uint = (i_BaseColor >>  8) & 0xFF;
			var b:uint = (i_BaseColor >>  0) & 0xFF;

			{//独自部分
				//薄いパステルカラーにする
				var ratio:Number = 0.5;

				r = MyMath.Lerp(r, 0x88, ratio);
				g = MyMath.Lerp(g, 0x88, ratio);
				b = MyMath.Lerp(b, 0x88, ratio);
			}

			return (r << 16) | (g << 8) | (b << 0);
		}
		//・文字の枠の色
		static public function Convert2TextFrameColor(i_BaseColor:uint):uint{
			var r:uint = (i_BaseColor >> 16) & 0xFF;
			var g:uint = (i_BaseColor >>  8) & 0xFF;
			var b:uint = (i_BaseColor >>  0) & 0xFF;

			{//独自部分
				//彩度を落として暗めの色にする
				var ratio:Number = 0.95;

				r = MyMath.Lerp(r, 0xFF, ratio);
				g = MyMath.Lerp(g, 0xFF, ratio);
				b = MyMath.Lerp(b, 0xFF, ratio);
			}

			return (r << 16) | (g << 8) | (b << 0);
		}

		//グラデーションセッティング
		static public const mtx_for_gradation_of_tab:Matrix = new Matrix(0,1,1,0,0,0);
		static public function BeginGradatioForTabBackColor(g:Graphics, i_BaseColor:uint):void{
			var SrcColor:uint = Convert2BackColor(i_BaseColor);
			var DstColor:uint = Convert2BackColor_Dst(i_BaseColor);

			g.beginGradientFill(
				GradientType.LINEAR,//type
				[SrcColor, DstColor],//color
				[1.0, 1.0],//alpha
				[128, 255],//Ratio
				mtx_for_gradation_of_tab//mtx
			);
			//グラフィックス.beginGradientFill ( "種類" , [カラー] , [透明度] , [配分] , 行列 , "スプレッド" , "補完" , 焦点 );
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
				const HINT_FRAME_COLOR:uint = 0x000000;
				const HINT_FRAME_RAD:int = 10;

				var shape:Shape = new Shape();
				var g:Graphics = shape.graphics;

				var matrix:Matrix = new Matrix(1,0,0,1,0,0);
				const ct:ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
				const rect:Rectangle = new Rectangle(0,0,bmp_data.width,bmp_data.height);

				//枠
				{
					g.clear();
					g.lineStyle(3, HINT_FRAME_COLOR, 1.0);
					g.beginFill(HINT_FRAME_COLOR, 1.0);
					g.drawRect(HINT_FRAME_RAD, HINT_FRAME_RAD, 32, 32);
					g.endFill();

					bmp_data.draw(shape);
				}

				//画像
				{
					var img_block:Image = LoadBlockImage(i_Index);//やっぱりブロックのIndexはゲームのを流用。ヒント用に一通りの画像を揃える
//					img_block.x = img_block.y = PANEL_LEN/2;

					matrix.tx = HINT_FRAME_RAD + 16;
					matrix.ty = HINT_FRAME_RAD + 16;

					bmp_data.draw(img_block, matrix, ct, BlendMode.NORMAL, rect, true);
				}

				//枠：円
				{
					g.clear();
					g.beginFill(HINT_FRAME_COLOR, 1.0);
					g.drawCircle(HINT_FRAME_RAD, HINT_FRAME_RAD, HINT_FRAME_RAD);
					g.endFill();

					bmp_data.draw(shape);
				}

				//文字
				{
					var text_field:TextField = new TextField();
					{
						text_field.border = false;
						text_field.x = 0;
						text_field.y = 0;
						text_field.width = 999;
						text_field.height = 999;
						text_field.textColor = 0xFFFFFF;
					}

					//キー
					{
						text_field.text = INDEX_TO_CHAR[i_Index];

						matrix.tx = HINT_FRAME_RAD - text_field.textWidth/2  - 2;
						matrix.ty = HINT_FRAME_RAD - text_field.textHeight/2 - 2;

						bmp_data.draw(text_field, matrix, ct, BlendMode.NORMAL, rect, true);
					}
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
		[Embed(source='SizeButtonX_Base.png')]
		 private static var Bitmap_SizeButtonX_Base: Class;
		[Embed(source='SizeButtonY_Base.png')]
		 private static var Bitmap_SizeButtonY_Base: Class;

		static public var Bitmap_SizeButton_Base:Array = [
			new Bitmap_SizeButtonX_Base(),
			new Bitmap_SizeButtonY_Base(),
		];

		static public function CreateSettingImage_Base(i_Index:int):Image{
			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(Bitmap_SizeButton_Base[i_Index].bitmapData.clone());

				bmp.x = -bmp.width/2;
				bmp.y = -bmp.height/2;

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//値の表示（ここでは空のBMPを返すだけ）
		static public const SETTING_VAL_W:int = 32 * 2;
		static public const SETTING_VAL_H:int = 32 * 2;
		static public function CreateSettingBitmap_Val():Bitmap{
			var bmp_data:BitmapData = new BitmapData(SETTING_VAL_W, SETTING_VAL_H, true, 0x00000000);

			//Bitmapに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				return bmp;
			}
		}

		//値を増加させるボタン
		[Embed(source='SizeButtonX_Plus.png')]
		 private static var Bitmap_SizeButtonX_Plus: Class;
		[Embed(source='SizeButtonY_Plus.png')]
		 private static var Bitmap_SizeButtonY_Plus: Class;

		static public var Bitmap_SizeButton_Plus:Array = [
			new Bitmap_SizeButtonX_Plus(),
			new Bitmap_SizeButtonY_Plus(),
		];

		static public function CreateSettingImage_Button_Up(i_Index:int):Image{
			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(Bitmap_SizeButton_Plus[i_Index].bitmapData.clone());

				switch(i_Index){
				case 0://X
					bmp.y = -bmp.height/2;
					break;
				case 1://Y
					bmp.x = -bmp.width/2;
					break;
				}

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

		//値を減少させるボタン
		[Embed(source='SizeButtonX_Minus.png')]
		 private static var Bitmap_SizeButtonX_Minus: Class;
		[Embed(source='SizeButtonY_Minus.png')]
		 private static var Bitmap_SizeButtonY_Minus: Class;

		static public var Bitmap_SizeButton_Minus:Array = [
			new Bitmap_SizeButtonX_Minus(),
			new Bitmap_SizeButtonY_Minus(),
		];

		static public function CreateSettingImage_Button_Down(i_Index:int):Image{
			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(Bitmap_SizeButton_Minus[i_Index].bitmapData.clone());

				switch(i_Index){
				case 0://X
					bmp.x = -bmp.width;
					bmp.y = -bmp.height/2;
					break;
				case 1://Y
					bmp.x = -bmp.width/2;
					bmp.y = -bmp.height;
					break;
				}

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}

//*
		[Embed(source='Val_0.png')]
		 private static var Bitmap_Val_0: Class;
		[Embed(source='Val_1.png')]
		 private static var Bitmap_Val_1: Class;
		[Embed(source='Val_2.png')]
		 private static var Bitmap_Val_2: Class;
		[Embed(source='Val_3.png')]
		 private static var Bitmap_Val_3: Class;
		[Embed(source='Val_4.png')]
		 private static var Bitmap_Val_4: Class;
		[Embed(source='Val_5.png')]
		 private static var Bitmap_Val_5: Class;
		[Embed(source='Val_6.png')]
		 private static var Bitmap_Val_6: Class;
		[Embed(source='Val_7.png')]
		 private static var Bitmap_Val_7: Class;
		[Embed(source='Val_8.png')]
		 private static var Bitmap_Val_8: Class;
		[Embed(source='Val_9.png')]
		 private static var Bitmap_Val_9: Class;

		static public var Bitmap_Val_List:Array = [
			new Bitmap_Val_0(),
			new Bitmap_Val_1(),
			new Bitmap_Val_2(),
			new Bitmap_Val_3(),
			new Bitmap_Val_4(),
			new Bitmap_Val_5(),
			new Bitmap_Val_6(),
			new Bitmap_Val_7(),
			new Bitmap_Val_8(),
			new Bitmap_Val_9(),
		];

		static public function RedrawSettingBitmap_Val(i_Bitmap:Bitmap, i_Val:int):void{
			var bmp_data:BitmapData = i_Bitmap.bitmapData;

			//Clear
			{
				bmp_data.fillRect(bmp_data.rect, 0x00000000);
			}

			//Draw
			{
				var index:int;

				var matrix : Matrix = new Matrix(1,0,0,1, 0,16);

				//１０の位
				{
					matrix.tx += 16;

					index = (i_Val / 10) % 10;

					bmp_data.draw(Bitmap_Val_List[index], matrix);
				}

				//１の位
				{
					matrix.tx += 16;

					index = (i_Val / 1) % 10;

					bmp_data.draw(Bitmap_Val_List[index], matrix);
				}
			}
		}
/*/
		static public function RedrawSettingBitmap_Val(i_Bitmap:Bitmap, i_Val:int):void{
			var bmp_data:BitmapData = i_Bitmap.bitmapData;

			//Clear
			{
				bmp_data.fillRect(bmp_data.rect, 0x00000000);
			}

			//Draw
			{
				var matrix : Matrix = new Matrix(1,0,0,1,0,0);
				var color : ColorTransform = new ColorTransform(1,1,1,1,255,255,255,255);
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
//*/



		//#Tab : Save

		//サムネイルの枠
		static public function CreateThumbnailImage_Base():Image{
			return CreateGameFrameImage(SAVE_THUMBNAIL_W, SAVE_THUMBNAIL_H);
		}

		//ステージのサムネイル画像
		static public const SAVE_THUMBNAIL_W:int = 234;//32 * 12 * 0.6;//200
		static public const SAVE_THUMBNAIL_H:int = 196;//32 * 10 * 0.6;//200
		static public function CreateThumbnailImage_Thumbnail(i_Map:Array):Image{
			var bmp_data:BitmapData = new BitmapData(SAVE_THUMBNAIL_W, SAVE_THUMBNAIL_H, true, 0xFFFFFFFF);
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

				//縦横それぞれのフィット率を求める
				var RatioX:Number;
				var RatioY:Number;
				{
					RatioX = SAVE_THUMBNAIL_W / NumX;
					RatioY = SAVE_THUMBNAIL_H / NumY;
				}

				//それをサムネイルにフィットさせるための比率を求める
				var Ratio:Number;
				{
					//低い方に合わせる
					Ratio = MyMath.Min(RatioX, RatioY);
				}

				//その比率で実際のサムネイルに描画
				{
					bmp_data.draw(
						bmp_data_ori,
						new Matrix(
							Ratio, 0, 0, Ratio,
							NumX/2 * (RatioX - Ratio),
							NumY/2 * (RatioY - Ratio)
						)
					);
				}
			}

			//Imageに入れて返す
			{
				var bmp:Bitmap = new Bitmap(bmp_data);

				//枠に収まるように調整
				bmp.x = GAME_FRAME_W;
				bmp.y = GAME_FRAME_H;

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}


		//セーブボタン用の画像

		[Embed(source='SaveButton.png')]
		 private static var Bitmap_SaveButton: Class;
		[Embed(source='SaveButton.png')]
		 private static var Bitmap_SaveButton_New: Class;

		static public function CreateThumbnailImage_Button_Save(i_IsOverWrite:Boolean):Image{
			//Imageに入れて返す
			{
				var bmp:Bitmap;
				if(i_IsOverWrite){
					bmp = new Bitmap_SaveButton();
				}else{
					bmp = new Bitmap_SaveButton_New();
				}

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}


		//ロードボタン用の画像

		[Embed(source='LoadButton.png')]
		 private static var Bitmap_LoadButton: Class;
		[Embed(source='LoadButton.png')]
		 private static var Bitmap_LoadButton_Clear: Class;

		static public function CreateThumbnailImage_Button_Load(i_IsOverWrite:Boolean):Image{
			//Imageに入れて返す
			{
				var bmp:Bitmap;
				if(i_IsOverWrite){
					bmp = new Bitmap_LoadButton();
				}else{
					bmp = new Bitmap_LoadButton_Clear();
				}

				var img:Image = new Image();
				img.addChild(bmp);

				return img;
			}
		}
	}
}


