//author Show=O=Healer
package{
	//mxml
	import mx.core.*;
	import mx.containers.*;
	import mx.controls.*;

	public class Block extends Image{

		//ブロックの種類
		static public const TYPE_I:uint = 0;
		static public const TYPE_O:uint = 1;
		static public const TYPE_L:uint = 2;
		static public const TYPE_R:uint = 3;
		static public const TYPE_T:uint = 4;
		static public const TYPE_S:uint = 5;
		static public const TYPE_Z:uint = 6;

		static public const TYPE_NUM:uint = 7;

		public var m_Type:uint = TYPE_I;//一応、適当に初期化

		//
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
/*
		static public const PATTERN:Array = [
			//I
			[
				[1],
				[1],
				[1],
				[1],
			],
			//O
			[
				[1, 1],
				[1, 1],
			],
			//L
			[
				[1, 0],
				[1, 0],
				[1, 1],
			],
			//R
			[
				[0, 1],
				[0, 1],
				[1, 1],
			],
			//T
			[
				[1, 1, 1],
				[0, 1, 0],
			],
			//S
			[
				[0, 1, 1],
				[1, 1, 0],
			],
			//Z
			[
				[1, 1, 0],
				[0, 1, 1],
			],
		];
/*/
		static public const PATTERN:Array = [
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
//*/

		//回転量（時計回り方向）
		static public const ROT_0:uint   = 0;
		static public const ROT_90:uint  = 1;
		static public const ROT_180:uint = 2;
		static public const ROT_270:uint = 3;
		static public const ROT_NUM:uint = 4;

		public var m_Rot:uint = ROT_0;

		//色

		public var m_Color:int = ImageManager.GRAPHIC_INDEX_EMPTY;//一応、適当に初期化

		//画像
		public var m_Image:Image;

		//初期化処理
		public function Init(i_Color:int, i_Type:uint):void{
			//Color
			{
				m_Color = i_Color;
			}

			//Type
			{
				m_Type = i_Type;
			}

			//Rot
			{
				m_Rot = ROT_0;
			}

			//Image
			{
				m_Image = ImageManager.LoadImage_Block(m_Color, GetPattern_Now());
				addChild(m_Image);
			}
		}

		//
		public function GetPattern_Now():Array{
			return GetPattern(m_Type, m_Rot);
		}

		//
		public function GetPattern_Rot_Next():Array{
			return GetPattern(m_Type, (m_Rot+1)%ROT_NUM);
		}

		//
		public function GetPattern_Rot_Prev():Array{
			return GetPattern(m_Type, (m_Rot+ROT_NUM-1)%ROT_NUM);
		}

		//
		static public function GetPattern(i_Type:int, i_Rot:int):Array{
			var Result:Array = new Array();

			var x:int;
			var y:int;
/*
			switch(i_Rot){
			case ROT_0:
				for(y = 0; y < PATTERN[i_Type].length; y += 1){
					Result.push(new Array());

					for(x = 0; x < PATTERN[i_Type][y].length; x += 1){
						Result[Result.length-1].push(PATTERN[i_Type][y][x]);
					}
				}
				break;
			case ROT_90:
				for(x = 0; x < PATTERN[i_Type][0].length; x += 1){
					Result.push(new Array());

					for(y = PATTERN[i_Type].length-1; y >= 0; y -= 1){
						Result[Result.length-1].push(PATTERN[i_Type][y][x]);
					}
				}
				break;
			case ROT_180:
				for(y = PATTERN[i_Type].length-1; y >= 0; y -= 1){
					Result.push(new Array());

					for(x = PATTERN[i_Type][y].length-1; x >= 0; x -= 1){
						Result[Result.length-1].push(PATTERN[i_Type][y][x]);
					}
				}
				break;
			case ROT_270:
				for(x = PATTERN[i_Type][0].length-1; x >= 0; x -= 1){
					Result.push(new Array());

					for(y = 0; y < PATTERN[i_Type].length; y += 1){
						Result[Result.length-1].push(PATTERN[i_Type][y][x]);
					}
				}
				break;
			}
/*/
			for(y = 0; y < PATTERN[i_Type][i_Rot].length; y += 1){
				Result.push(new Array());

				for(x = 0; x < PATTERN[i_Type][i_Rot][y].length; x += 1){
					Result[Result.length-1].push(PATTERN[i_Type][i_Rot][y][x]);
				}
			}
//*/

			return Result;
		}

		//回転処理
		public function Rotate():void{
			//４分の１回転する（向きを変える）

			//remove
			{
				removeChild(m_Image);
			}

			//rot
			{
				m_Rot += 1;
				if(m_Rot >= ROT_NUM){
					m_Rot = 0;
				}
			}

			//add
			{
				m_Image = ImageManager.LoadImage_Block(m_Color, GetPattern_Now());
				addChild(m_Image);
			}
		}


		//=Vanish=

		public var m_DestroyFlag:Boolean = false;

		//消えるように指定
		public function Destroy():void{
			m_DestroyFlag = true;
		}

		//消えてる最中か
		public function IsVanishing():Boolean{
			return m_DestroyFlag;
		}


		//=Fall=

		public var m_FallY:int = -1;//落下先の高さを指定。-1の時は落下しない

		//落下位置を指定
		public function FallTo(i_Y:int):void{
			m_FallY = i_Y;
		}

		//落下しないようにリセット
		public function ResetFall():void{
			m_FallY = -1;
		}

		//落下中か
		public function IsFalling():Boolean{
			return m_FallY >= 0;
		}
	}
}

