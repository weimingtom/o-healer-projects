//author Show=O=Healer
package{
	public class IInput{

		//i_Buttonとして指定するもの(enum欲しい)
		//Player
		static public const BUTTON_L:int = 0;
		static public const BUTTON_R:int = 1;
		static public const BUTTON_U:int = 2;
		static public const BUTTON_D:int = 3;
		//System
		static public const BUTTON_RESET:int = 4;
		//Editor
		static public const BUTTON_CURSOR_L:int = 5;
		static public const BUTTON_CURSOR_R:int = 6;
		static public const BUTTON_CURSOR_U:int = 7;
		static public const BUTTON_CURSOR_D:int = 8;
		static public const BUTTON_GO_TO_PLAY:int = 9;
		static public const BUTTON_GO_TO_EDIT:int = 10;
		static public const BUTTON_BLOCK_O:int = 11;
		static public const BUTTON_BLOCK_W:int = 12;
		static public const BUTTON_BLOCK_Q:int = 13;
		static public const BUTTON_PLAYER_POS:int = 14;
		static public const BUTTON_GOAL_POS:int = 15;
		//Num
		static public const BUTTON_NUM:int  = 16;


		//i_Buttonが現在押されているか
		public function IsPress(i_Button:int):Boolean{
			//継承されてなければ、常にfalseを返す
			return false;
		}

		//i_Buttonが押されたか（エッジ）
		public function IsPress_Edge(i_Button:int):Boolean{
			//継承されてなければ、常にfalseを返す
			return false;
		}

		//毎フレーム呼んで、必要なら情報の更新を行う
		public function Update():void{
		}
	}
}

