//author Show=O=Healer
package{
	import flash.display.Stage;
	//Input
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	public class CInput_Keyboard extends IInput{
		//�L�[�{�[�h�̃L�[
		static public const KEY_R:int = 82;

		//�L�[�{�[�h�̓��͂��L�����Ă���
		private var m_Input:Array;//Boolean[BUTTON_NUM]
		private var m_Input_Old:Array;//�G�b�W���o�p
		private var m_Input_Old_Old:Array;//�G�b�W���o�p

		//������
		public function CInput_Keyboard(i_Stage:Stage):void{
			//�L�[�{�[�h�̓��͂�OnKeyDown�ȂǂŎ󂯎��
			{
				i_Stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
				i_Stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			}

			//�L����������
			{
				m_Input         = new Array(BUTTON_NUM);
				m_Input_Old     = new Array(BUTTON_NUM);
				m_Input_Old_Old = new Array(BUTTON_NUM);
				for(var i:int = 0; i < m_Input.length; i+=1){
					m_Input_Old_Old[i] = m_Input_Old[i] = m_Input[i] = false;
				}
			}
		}

		//�L�[�������ꂽ��A�Ή����镔����true�ɂ���
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

		//i_Button�����݉�����Ă��邩
		override public function IsPress(i_Button:int):Boolean{
			return m_Input[i_Button];
		}

		//i_Button�������ꂽ���i�G�b�W�j
		override public function IsPress_Edge(i_Button:int):Boolean{
			return m_Input[i_Button] && (m_Input_Old_Old[i_Button] != m_Input[i_Button]);
		}

		//���t���[���Ă�ŁA�K�v�Ȃ���̍X�V���s��
		override public function Update():void{
			var i:int;
			//Update_Post�Ƃ���������ǉ�����΁A�킴�킴OldOld�݂����Ȃ̂͗p�ӂ��Ȃ��Ă��������ǁA����͂����
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old_Old[i] = m_Input_Old[i];
			}
			for(i = 0; i < m_Input.length; i+=1){
				m_Input_Old[i] = m_Input[i];
			}
		}
	}
}

