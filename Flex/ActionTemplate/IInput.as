//author Show=O=Healer
package{
	public class IInput{

		//i_Button�Ƃ��Ďw�肷�����(enum�~����)
		//Player
		static public const BUTTON_L:int = 0;
		static public const BUTTON_R:int = 1;
		static public const BUTTON_U:int = 2;
		static public const BUTTON_D:int = 3;
		static public const BUTTON_DECIDE:int = 4;
		static public const BUTTON_CANCEL:int = 5;
		//System
		static public const BUTTON_RESET:int = 6;
		//Num
		static public const BUTTON_NUM:int  = 7;


		//i_Button�����݉�����Ă��邩
		public function IsPress(i_Button:int):Boolean{
			//�p������ĂȂ���΁A���false��Ԃ�
			return false;
		}

		//i_Button�������ꂽ���i�G�b�W�j
		public function IsPress_Edge(i_Button:int):Boolean{
			//�p������ĂȂ���΁A���false��Ԃ�
			return false;
		}

		//���t���[���Ă�ŁA�K�v�Ȃ���̍X�V���s��
		public function Update():void{
		}
	}
}
