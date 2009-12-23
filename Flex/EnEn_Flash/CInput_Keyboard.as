//author Show=O=Healer
package{
	import flash.display.Stage;
	//Input
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	public class CInput_Keyboard extends IInput{
		//キーボードのキー
		static public const KEY_R:int = 82;

		//キーボードの入力を記憶しておく
		private var m_Input:Array;//Boolean[BUTTON_NUM]
		private var m_Input_Old:Array;//エッジ検出用
		private var m_Input_Old_Old:Array;//エッジ検出用

		//初期化
		public function CInput_Keyboard(i_Stage:Stage):void{
			//キーボードの入力をOnKeyDownなどで受け取る
			{
				i_Stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
				i_Stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			}

			//記憶を初期化
			{
				m_Input         = new Array(BUTTON_NUM);
				m_Input_Old     = new Array(BUTTON_NUM);
				m_Input_Old_Old = new Array(BUTTON_NUM);
				for(var i:int = 0; i < m_Input.length; i+=1){
					m_Input_Old_Old[i] = m_Input_Old[i] = m_Input[i] = false;
				}
			}
		}

		//キーが押されたら、対応する部分をtrueにする
		private function OnKeyDown(event:KeyboardEvent):void{
			switch(event.keyCode){
			case Keyboard.LEFT:		m_Input[BUTTON_L] = true;		break;
			case Keyboard.RIGHT:	m_Input[BUTTON_R] = true;		break;
			case Keyboard.DOWN:		m_Input[BUTTON_D] = true;		break;
			case Keyboard.UP:		m_Input[BUTTON_U] = true;	break;
			case Keyboard.SPACE:	m_Input[BUTTON_ROTATE] = true;	break;

			case KEY_R:				m_Input[BUTTON_RESET] = true;	break;
			}
		}
		private function OnKeyUp(event:KeyboardEvent):void{
			switch(event.keyCode){
			case Keyboard.LEFT:		m_Input[BUTTON_L] = false;		break;
			case Keyboard.RIGHT:	m_Input[BUTTON_R] = false;		break;
			case Keyboard.DOWN:		m_Input[BUTTON_D] = false;		break;
			case Keyboard.UP:		m_Input[BUTTON_U] = false;	break;
			case Keyboard.SPACE:	m_Input[BUTTON_ROTATE] = false;	break;

			case KEY_R:				m_Input[BUTTON_RESET] = false;	break;
			}
		}

		//i_Buttonが現在押されているか
		override public function IsPress(i_Button:int):Boolean{
			return m_Input[i_Button];
		}

		//i_Buttonが押されたか（エッジ）
		override public function IsPress_Edge(i_Button:int):Boolean{
			return m_Input[i_Button] && (m_Input_Old_Old[i_Button] != m_Input[i_Button]);
		}

		//毎フレーム呼んで、必要なら情報の更新を行う
		override public function Update():void{
			var i:int;
			//Update_Postという処理を追加すれば、わざわざOldOldみたいなのは用意しなくてもいいけど、今回はこれで
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old_Old[i] = m_Input_Old[i];
			}
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old[i] = m_Input[i];
			}
		}
	}
}

