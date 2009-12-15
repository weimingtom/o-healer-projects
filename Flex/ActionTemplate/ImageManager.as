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

		//==Function==

		//＃BG

		[Embed(source='Dangeon.png')]
		 private static var Bitmap_BG: Class;

		static public var m_BitmapBG:Bitmap = new Bitmap_BG();
		static public var m_color_transform : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);

		static public const BG_INDEX_TO_XY:Array = [
			//O
			[0, 0],
			//W
			[0, PANEL_LEN],
		];

		static public const PLAYER_COLLISION_W:int = 8;

		static public function DrawBG(o_BG_BitmapData:BitmapData, o_BG_Collision_BitmapData:BitmapData, i_Map:Array, i_Rect:Rectangle):void{
			var x:int;
			var y:int;

			var dst_rect : Rectangle = new Rectangle(0,0,PANEL_LEN,PANEL_LEN);
			var dst_rect_col : Rectangle = new Rectangle(0,0, PANEL_LEN + 2*PLAYER_COLLISION_W, PANEL_LEN + 2*PLAYER_COLLISION_W);

			//clear
			//o_BG_Collision_BitmapData
			{
				var clear_rect : Rectangle = new Rectangle(i_Rect.x * PANEL_LEN, i_Rect.y * PANEL_LEN, i_Rect.width * PANEL_LEN, i_Rect.height * PANEL_LEN);
				o_BG_Collision_BitmapData.fillRect(clear_rect, 0x00000000);
			}

			//draw
			for(y = i_Rect.y; y < i_Rect.height; y += 1){
				dst_rect.y = y * PANEL_LEN;
				dst_rect_col.y = y * PANEL_LEN - PLAYER_COLLISION_W;

				for(x = i_Rect.x; x < i_Rect.width; x += 1){
					dst_rect.x = x * PANEL_LEN;
					dst_rect_col.x = x * PANEL_LEN - PLAYER_COLLISION_W;

					var index:int = i_Map[y][x];

					//o_BG_BitmapData
					var matrix : Matrix = new Matrix(1,0,0,1, -BG_INDEX_TO_XY[index][0] + dst_rect.left, -BG_INDEX_TO_XY[index][1] + dst_rect.top);
					o_BG_BitmapData.draw(m_BitmapBG, matrix, m_color_transform, BlendMode.NORMAL, dst_rect, true);

					//o_BG_Collision_BitmapData
					if(index == Game.W){
						o_BG_Collision_BitmapData.fillRect(dst_rect_col, 0x88FFFFFF);
					}
				}
			}
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
		static public function LoadCharaImage(i_Name:String, i_Index:int):Array{
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

				var base_offset_x:int = int(i_Index % 4) * CHARA_GRAPHIC_LEN_X*3;
				var base_offset_y:int = int(i_Index / 4) * CHARA_GRAPHIC_LEN_Y*4;

				var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);

				for(y = 0; y < 4; y += 1){
					var offset_y:int = y * CHARA_GRAPHIC_LEN_Y;

					for(x = 0; x < 3; x += 1){
						var offset_x:int = x * CHARA_GRAPHIC_LEN_X;

						var bmp_data:BitmapData = new BitmapData(CHARA_GRAPHIC_LEN_X, CHARA_GRAPHIC_LEN_Y, true, 0x00000000);
						{
							var matrix : Matrix = new Matrix(1,0,0,1,-base_offset_x - offset_x,-base_offset_y - offset_y);

							var rect : Rectangle = new Rectangle(
								0,//base_offset_x + offset_x,
								0,//base_offset_y + offset_y,
								CHARA_GRAPHIC_LEN_X,
								CHARA_GRAPHIC_LEN_Y
							);

							bmp_data.draw(bmp, matrix, color, BlendMode.NORMAL, rect, true);
						}

						//取り込んだビットマップデータを表示
						var bmp_obj:Bitmap = new Bitmap( bmp_data , PixelSnapping.AUTO , true);
						{
							bmp_obj.x = -CHARA_GRAPHIC_LEN_X*0.5;
							bmp_obj.y = -CHARA_GRAPHIC_LEN_Y + PLAYER_COLLISION_W;
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

	}
}


