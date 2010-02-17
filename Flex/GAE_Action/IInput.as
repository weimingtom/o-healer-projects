//author Show=O=Healer
package{
	public class IInput{

		//i_Buttonとして指定するもの(enum欲しい)
		static public var INPUT_COUNTER:int = 0;//enum代わり
		//Player
		static public const BUTTON_L:int = INPUT_COUNTER++;
		static public const BUTTON_R:int = INPUT_COUNTER++;
		static public const BUTTON_U:int = INPUT_COUNTER++;
		static public const BUTTON_D:int = INPUT_COUNTER++;
		//System
		static public const BUTTON_RESET:int = INPUT_COUNTER++;
		//Editor
		static public const BUTTON_CURSOR_L:int		= INPUT_COUNTER++;
		static public const BUTTON_CURSOR_R:int		= INPUT_COUNTER++;
		static public const BUTTON_CURSOR_U:int		= INPUT_COUNTER++;
		static public const BUTTON_CURSOR_D:int		= INPUT_COUNTER++;
		static public const BUTTON_GO_TO_PLAY:int	= INPUT_COUNTER++;
		static public const BUTTON_GO_TO_EDIT:int	= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_O:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_W:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_Q:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_S:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_D:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_R:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_M:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_T:int		= INPUT_COUNTER++;
		static public const BUTTON_BLOCK_E:int		= INPUT_COUNTER++;
		static public const BUTTON_PLAYER_POS:int	= INPUT_COUNTER++;
		static public const BUTTON_GOAL_POS:int		= INPUT_COUNTER++;
		//System
		static public const BUTTON_RANGE:int		= INPUT_COUNTER++;
		static public const BUTTON_0:int			= INPUT_COUNTER++;
		static public const BUTTON_1:int			= INPUT_COUNTER++;
		static public const BUTTON_2:int			= INPUT_COUNTER++;
		static public const BUTTON_3:int			= INPUT_COUNTER++;
		static public const BUTTON_4:int			= INPUT_COUNTER++;
		static public const BUTTON_5:int			= INPUT_COUNTER++;
		static public const BUTTON_6:int			= INPUT_COUNTER++;
		static public const BUTTON_7:int			= INPUT_COUNTER++;
		static public const BUTTON_8:int			= INPUT_COUNTER++;
		static public const BUTTON_9:int			= INPUT_COUNTER++;
		//Num
		static public const BUTTON_NUM:int  = INPUT_COUNTER++;


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

