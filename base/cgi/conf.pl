#$au = 's000meijin';
#-------------------------------------------------------------------------------
#	�V�X�e���̊�{�ݒ�t�@�C���ł��B
#-------------------------------------------------------------------------------


#������ ���O�t�@�C���̊g���q ������
#���O�t�@�C���̕ۑ��t�H���_��WEB���J�̈�i�u���E�U����A�N�Z�X���邱�Ƃ��o����t�H
#���_�j�ɒu���ꍇ�͊g���q��K���ucgi�v���̎��s�`���̊g���q�ɕύX���Ă��������B
#�ulog�v�̂܂܂ɂ��Ă����ƁA�u���E�U���璼�ڃ��O�t�@�C���ɃA�N�Z�X���ꂽ�ہA���O
#�t�@�C���̒��g���\������Ă��܂��A��؂Ȍl��񓙂��R�k���Ă��܂��\���������
#���B

	$log_ext = 'log';


#������ �N�b�L�[�l�[�� ������
#�Ǘ���ʂ̃��O�C���p�N�b�L�[�̕ۑ����ł��B
#�ʏ�͕ύX����K�v�͂���܂���
#���А��i�𕡐��ŗ��p����ꍇ�́A���ׂĂ̏��i�œ���̃N�b�L�[�l�[����ݒ肵�Ă���
#�����B

	$cookie_name = 'meijin';


#������ ���O�C������\������ ������
#�Ǘ���ʂ̃��O�C������\���̍ۂ�1�y�[�W�ɕ\�����郍�O�̌������w�肵�Ă��������B

	$alog_scale = '40';


#������ admin.cgi�܂ł̃t���p�X ������
#���p���Ԃ̊J�n�⃉�C�Z���X�̓o�^�����܂������Ȃ��ꍇ�ɐݒ���s�Ȃ��܂��B
#���SSL�̈�ɖ{CGI��ݒu�����ꍇ�ɐݒ肪�K�v�ɂȂ�܂��B
#�ݒ���s���ꍇ�́Ahttp://�܂���https://����n�܂�admin.cgi�܂ł̃p�X���w�肵�Ă��������B
# ��j�@$admin_cgi_path = 'https://www.hogehoge.com/cgi-bin/cgi/admin.cgi';

	$admin_cgi_path = '';


#-------------------------------------------------------------------------------
#	����ȍ~�͐ݒ��ύX����K�v�͂���܂���B
#	�ݒ��ύX����Ɛ��������삵�����Ȃ�\��������܂��B
#-------------------------------------------------------------------------------
($CoLogDir) || ($CoLogDir = $LogDir);

###---------------------------------
###�@�@�t�@�C���ϐ��i�ύX�s�v�j
###---------------------------------
### ���ݒ�
$conf_log = "$LogDir/conf.$log_ext";
$conf_db = "$DataDir/conf.db";

### �A�J�E���g���
$account_log = "$CoLogDir/account.$log_ext";
$account_db = "$DataDir/account.db";

### ���O�C���L�^���
$login_log = "$CoLogDir/login.$log_ext";
$login_db = "$DataDir/login.db";

### ���j���[���
$menu_dat = "$LogDir/menu.$log_ext";

### ��{HTML�t�@�C��
$main_html = "$HtmlDir/main.htm";


###---------------------------------
###�@�@�V�X�e����{���i�ύX�s�v�j
###---------------------------------
### ���[�J��
$lh = '127.0.0.1,localhost';
### �Í�Key
$crypt_key = 'ys';
### ���ԕϐ�
$time = time;

open(FILE, "$LogDir/meijin.$log_ext");
flock(FILE, 1);
my @buf = <FILE>;
close(FILE);
($fckey,$apa,$mjnm,$fud,$lud,$cphp,$cpem) = split(/\t/,@buf[0]);
($lc1,$lc2,$lc3,$lc4,$lc5) = split(/\0/,@buf[1]);


sub setup_conf {
	$system_log = "$LogDir/system.$log_ext";
	$meijin_log = "$LogDir/meijin.$log_ext";
	$up_record_log = "$LogDir/up_record.$log_ext";
	$up_record_db = "$DataDir/up_record.db";
	
	$DIR{''} = '..';
	$DIR{'cgi'} = '.';
	$DIR{'lib'} = $LibDir;
	$DIR{'data'} = $DataDir;
	$DIR{'log'} = $LogDir;
	$DIR{'html'} = $HtmlDir;
	$DIR{'image'} = $ImageDir;
}
1;
