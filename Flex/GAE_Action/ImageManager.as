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

		static public var BLOCK_INDEX_MOVE:int	= 0;

		[Embed(source='Block_Move.png')]
		 private static var Bitmap_Block_Move: Class;//BLOCK_INDEX_MOVE

		private static var m_BlockList:Array = [
			new Bitmap_Block_Move(),//BLOCK_INDEX_MOVE
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
	}
}


