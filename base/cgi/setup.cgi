#!/usr/bin/perl

#������������������������������������������������������������
#					�{CGI�t�@�C���̐���
#������������������������������������������������������������
# �{CGI�t�@�C���̓T�[�o�ɖ{���i���Z�b�g�A�b�v���邽�߂�CGI�ł��B
# �Z�b�g�A�b�v��͕s�v�ɂȂ�܂��̂ŁA�j�����Ă����\�ł��B
# 
# ���̃t�@�C���̈�s�ڂɏ�����Ă���u#!/usr/bin/perl�v�́APerl�̃p�X�ƂȂ�܂��B
# �Z�b�g�A�b�v����T�[�o�̊��ɍ��킹�ď��������Ă��������B
# ��ʓI�ȃT�[�o�ł͏�L�ȊO�̏ꍇ�A�u#!/usr/local/bin/perl�v�ƂȂ�ꍇ�������
# ���B
# 
# �܂��A�t�@�C���̃p�[�~�b�V������CGI�����s�ł���p�[�~�b�V�����ɕύX���Ă�����
# ���B
# �ʏ�u755�v�Ƃ���΂悢�̂ł����A�T�[�o�̊��ɂ���Ắu705�v���́u704�v�Ƃ�
# �Ȃ��Ǝ��s���Ȃ��ꍇ������܂��B
# �s���ȏꍇ�́A�T�[�o�Ǘ��҂ɂ��m�F���������B
#


#������������������������������������������������������������
#					���C�u�����̎擾
#������������������������������������������������������������
eval{
require "folder.pl";
require "conf.pl";

#������������������������������������������������������������
#					�����ݒ�
#������������������������������������������������������������
&setup_conf;

my $action = $ENV{'QUERY_STRING'};

#������������������������������������������������������������
#					���C������
#������������������������������������������������������������
if (!$action) {
	$return = &setup_form;
} elsif ($action eq 'setup=start') {
	$return = &setup;
}
};
($@) && (&lib'system_error('eval',"$@"));


print "Content-type: text/html\n\n";
print $return;
exit;

#������������������������������������������������������������
#������������������������������������������������������������

#-----------------------------------------------------------------------------1
#										�V�X�e���̃Z�b�g�A�b�v�t�H�[��
#------------------------------------------------------------------��2009.06.14
sub setup_form {
	if (-f "$LibDir") {
		&lib'system_error('',"���łɃZ�b�g�A�b�v�͊������Ă��܂��B");
	}
	$html = qq|
	<HTML>
	<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
	<META http-equiv="Content-Style-Type" content="text/css">
	<script src="$ImageDir/window.js" type="text/javascript"></script>
	<LINK rel="stylesheet" href="$ImageDir/font.css" type="text/css">
	<TITLE>�Z�b�g�A�b�v�̊J�n</TITLE>
	</HEAD>
	<BODY>
	<CENTER><BR>
	<BR>
	<TABLE border="0" width="600" cellpadding="4" cellspacing="1" bgcolor="#333333" class="font15">
	  <TR>
	    <TD colspan="2" bgcolor="#000080" class="white">�@���@�Z�b�g�A�b�v�̊J�n</TD>
	  </TR>
    <TR>
      <TD bgcolor="#ffcc00" rowspan="2"></TD>
      <TD bgcolor="#ffffff">���̂��т́ACGI-Park���i���_�E�����[�h���������A���肪�Ƃ��������܂��B<BR>
      ��CGI�𗘗p����ɂ͍ŏ��ɃV�X�e���̃Z�b�g�A�b�v��Ƃ��s�Ȃ��K�v������܂��B�Z�b�g�A�b�v��Ƃ��s�Ȃ��ƁA�ݒu����T�[�o�Ƀv���O�����t�@�C����e��ݒ�t�@�C�����쐬����܂��B<BR>
      <BR>
      �V�X�e���̃Z�b�g�A�b�v���s�Ȃ��O�ɕK�����L�̎g�p�����_�񏑂ɖڂ�ʂ��A���e�ɓ��ӂ�����ŃZ�b�g�A�b�v���J�n���Ă��������B�g�p�����_�񏑂ɓ��ӂł��Ȃ��ꍇ�̓Z�b�g�A�b�v���s�Ȃ�Ȃ��ł��������B<BR>
      <IFRAME width="575" height="300" frameborder="1" src="https://www.cgi-park.com/document/contract.txt" marginwidth="3" marginheight="5"></IFRAME><BR>
      </TD>
    </TR>
	  <TR>
	    <TD bgcolor="#ffffff" align="center">
	    <FORM class="FORM" action="setup.cgi" onsubmit="submitOnce(this);">
			<INPUT type="submit" value="��L�g�p�����_�񏑂ɓ��ӂ��Z�b�g�A�b�v�����s����" onclick="return confirm('�g�p�����_�񏑂ɓ��ӂ��A�Z�b�g�A�b�v�����s���܂��B��낵���ł����H');">
			<INPUT type="hidden" name="setup" value="start"></FORM>
	    </TD>
	  </TR>
	</TABLE>
	</CENTER>
	</BODY>
	</HTML>
	|;
	return $html;
}

# 1:2009.06.14 �K���SSL�ŕ\������悤�ɏC��

#-----------------------------------------------------------------------------0
#										�V�X�e���̃Z�b�g�A�b�v
#------------------------------------------------------------------��2005.09.27
sub setup {
	if (-f "$LibDir") {
		&lib'system_error('',"���łɃZ�b�g�A�b�v�͊������Ă��܂��B");
	}

	### ���O�t�@�C���̊g���q
	if ($log_ext ne 'log') {
		if ($log_ext eq 'htm' || $log_ext eq 'db' || $log_ext eq 'mail') {
			&lib'system_error('',"���O�t�@�C���̊g���q�̐ݒ肪�s���ł��B�g���q�Ɂu$log_ext�v�͗��p�o���܂���B");
		}
		&lib'opendir($LogDir,*DIR);
		foreach (@DIR) {
			my($name,$ext) = split(/\./);
			if ($ext eq 'log') {
				my $new_name = "$name\.$log_ext";
				rename "$LogDir/$_","$LogDir/$new_name";
			}
		}
		&lib'openfile("$LogDir/meijin.$log_ext",*MJ);
		($fckey,$apa,$mjnm,$fud,$lud,$cphp,$cpem) = split(/\t/,$MJ[0]);
	}
	
	### ���s�����̊m�F
	my $owner;
	my $this_file_name = 'setup.cgi';

	my $execuid = $<;	#��UID

	my @path_array = split(/\//, $ENV{'SCRIPT_FILENAME'});
	my $auto_find_file_name = pop @path_array;
	if($auto_find_file_name) {
		$this_file_name = $auto_find_file_name;
	}
	my ($par,$uid,$gid) = (stat($this_file_name))[2,4,5];

	#Windows�T�[�o
	if ($^O =~ /MSWin32/i) {
		$owner = 'win';
	#owner �����Ŏ��s
	} elsif($execuid eq $uid) {
		$owner = 'owner';
	#other �����Ŏ��s
	} else {
		$owner = 'other';
	}

	### �V�X�e���f�[�^�̓ǂݍ���
	&lib'openfile($system_log,*SYS);

	### �v���O�������̊m�F
	my $head = shift @SYS;
	$head =~ s/\0/,/g;
	my $check = "$fckey,$apa,$mjnm,$fud,$lud,$cphp,$cpem,";
	unless ($head =~ /^$check/) {
		&lib'system_error('er100',"�V�X�e����񂪈�v���܂���B<BR>$head<BR>$check<BR>");
	}

	### �t�@�C���̊m�F
	foreach (@SYS) {
		my($file) = split(/\0/);
		my($dir,$name) =split(/\//,$file);
		if (-e "$DIR{\"$dir\"}/$name") {
			&lib'system_error('er200',"�t�@�C���̓W�J�Ɏ��s���܂����B�t�@�C�������łɑ��݂��܂��B<BR>$file");
		}
	}

	### Perl�̃p�X�m�F
	&lib'openfile($this_file_name,*SU);
	my $perl_path = shift @SU;

	### �t�@�C���̓W�J
	my @MAKE;
	foreach (@SYS) {
		my($file,$ver,$data,$x) = split(/\0/);
		my($dir,$name) =split(/\//,$file);
		my $file_path = "$DIR{\"$dir\"}/$name";
		if ($name && !(-e "$DIR{\"$dir\"}")) {
			my($flag) = mkdir "$DIR{\"$dir\"}" , 777;
			if ($flag) {
				chmod 0777 , $DIR{"$dir"};
				($owner eq 'other') && (chown $uid, $gid, $DIR{"$dir"});
				unshift @MAKE,"$DIR{\"$dir\"}";
			} else {
				foreach $del (@MAKE) {unlink $del;}
				&lib'system_error('er300',"$file_path�V�X�e���ݒu�t�H���_�ɑ΂��ăA�N�Z�X����������܂���B�t�H���_�̃p�[�~�b�V�������m�F���Ă��������B");
			}
		}
		$data = reverse $data;
		$data =~ s/\[\\n\]/\n/g;

		### ���s�t�@�C��
		if ($name =~ /\.cgi$/) {
			if ($data =~ /^#!\// && $data !~ /^$perl_path/) {
				$data =~ s/^#!\/usr\/bin\/perl\n/$perl_path/;
			}
		}
		### ���ʃR�[�h�̖��ߍ���
		if ($file_path =~ /.pl$/ || $file_path =~ /.cgi$/ ) {
			$data .= "\n#$file\n#$ver\n\n";
		}
		
		### �t�@�C���̕ۑ�
		&lib'writefile($file_path,$data);
		unshift @MAKE,"$file_path";
		if ($owner eq 'other') {
			chown $uid, $gid, $file_path;
		}
		if ($file_path =~ /.cgi$/) {
			chmod "0$par" ,"$file_path";
		} else {
			chmod 0606, "$file_path";
		}
	}

	### �Z�b�g�A�b�v�̊���
	unlink "setup.cgi";

	$html = qq|
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
		<META http-equiv="Content-Style-Type" content="text/css">
		<TITLE>�Z�b�g�A�b�v�̊���</TITLE>
		<LINK rel="stylesheet" href="$ImageDir/font.css" type="text/css">
		</HEAD>
		<BODY bgcolor="#ffffff">
		<CENTER><BR>
		<TABLE border="0" width="600" cellpadding="4" cellspacing="1" bgcolor="#333333" class="font15">
			<TR>
			  <TD colspan="2" bgcolor="#000080" class="white">�@���@�Z�b�g�A�b�v�̊���</TD>
			</TR>
			<TR>
			  <TD bgcolor="#ffcc00" rowspan="2"></TD>
			  <TD bgcolor="#ffffff" align="center" height="200"><BR>
			  ���肪�Ƃ��������܂����B�Z�b�g�A�b�v������Ɋ������܂����B<BR>
			  ���L�̃{�^�����Ǘ���ʂɃ��O�C�����Ă��������B<BR>
			  </TD>
			</TR>
			<TR>
			  <TD bgcolor="#ffffff" align="center">
			  <FORM action="../index.cgi" method="POST"><INPUT type="submit" value="�Ǘ���ʂ�" class="FORM"></FORM>
			  </TD>
			</TR>
		</TABLE>
		</CENTER>
		</BODY>
		</HTML>
	|;
	return $html;
}


package lib;
#-----------------------------------------------------------------------------0
#										�t�@�C�����J���āA���g��z��ɑ������
#------------------------------------------------------------------��
sub openfile{
	local($filename, *buf) = @_;
	
	($filename) || &system_error("er102",'�t�@�C���ϐ���������܂���ł����B',"lib::openfile�����G���[�B�t�@�C�����s���B");
	(-e $filename) || return(0);
	
	open(FILE, "$filename") || &system_error("er202",'�p�[�~�b�V�����G���[',"�u$filename�v�̃p�[�~�b�V�������m�F���Ă��������B");
	flock(FILE, 1) or &system_error("er302",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	@buf = <FILE>;
	close(FILE);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���Ƀf�[�^������������
#------------------------------------------------------------------��
sub writefile {
	local($logfile,@buf) = @_;
	(-e $logfile) || &lib'makefile($logfile);
	chmod 0666,$logfile;
	
	open(FILE, "+<$logfile") or &system_error("er106",'�t�@�C���̏��������Ɏ��s���܂����B',"�u$logfile�v�̏��������Ɏ��s���܂����B�t�H���_�܂��̓p�[�~�b�V�������m�F���Ă��������B");
	flock(FILE, 2) or &system_error("er206",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	seek(FILE, 0, 0);
	print FILE @buf;
	truncate(FILE, tell(FILE));
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���Ƀf�[�^��ǉ�����(�X�g�b�N)
#------------------------------------------------------------------��
sub stokfile {
	local($logfile,$buf) = @_;
	chmod 0666,$logfile;

	if (!open (FILE, ">>$logfile")) {&system_error("er105",'�ǋL�G���[',"�u$logfile�v�̒ǋL�Ɏ��s���܂����B");}
	flock(FILE, 2) or &system_error("er205",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	seek(FILE, 0, 2);
	print FILE $buf;
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���̍쐬
#------------------------------------------------------------------��
sub makefile{
	local($filename) = @_;
	($filename) || &system_error("er103",'�t�@�C���ϐ���������܂���ł����B','lib::makefile�����G���[�B�t�@�C�����s���B');

	open(FILE, ">$filename") || &system_error("er203",'�t�@�C���쐬�G���[',"�u$filename�v���쐬���邱�Ƃ��o���܂���ł����B�t�H���_�܂��̓p�[�~�b�V�������m�F���Ă��������B");
	close(FILE);
	chmod 0666,$filename;
}

#-----------------------------------------------------------------------------0
#										�t�H���_���J���āA���g��z��ɑ������
#------------------------------------------------------------------��
sub opendir{
	local($dir, *buf) = @_;
	
	(-e $dir) || &system_error("er104",'�t�H���_�ϐ���������܂���ł����B','lib::opendir�����G���[�B�t�H���_���s���B');
	opendir (DIR, "$dir") || &system_error("er204",'�t�H���_�I�[�v���G���[',"�u$dir�v�t�H���_���J�����Ƃ��o���܂���ł����B");
	@buf = readdir(DIR);
	closedir(DIR);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										�V�X�e���G���[��
#------------------------------------------------------------------��
# &lib'system_error($error_code,$print_msg,$send_msg);
# $error_code -> �G���[���ʃR�[�h
# $print_msg  -> ��ʏo�͗p���b�Z�[�W
sub system_error {
	local($error_code,$print_msg) = @_;
	### �񍐃G���[�쐬
	my $ertime = &lib'get_time;
	my($env2,$form2);
	# ���ϐ�
	foreach (sort keys %ENV) {
		$env2 .= qq|$_=$ENV{"$_"}&|;
	}
	# FORM�ϐ�
	foreach (sort keys %main'FORM) {
		$form2 .= qq|$_=$main'FORM{"$_"}&|;
	}
	$env2 =~ s/\n//g;
	$form2 =~ s/\n//g;

	### �G���[���O�̋L�^
	my $er_log = "$ertime\t$error_code\t$main'time\t$print_msg\t$env2\t$form2\t\t0\n";
	open (FILE, ">>$main'LogDir/error.$main'log_ext");
	flock(FILE, 2);
	seek(FILE, 0, 2);
	print FILE $er_log;
	close(FILE);
	
	### �G���[��
	my $print_html = qq|
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
		<META http-equiv="Content-Style-Type" content="text/css">
		<TITLE>�G���[���������܂����I</TITLE>
		</HEAD>
		<BODY bgcolor="#ffffff">
		<CENTER>
		<TABLE border="0" width="400" cellpadding="2" cellspacing="1" bgcolor="#cccccc">
		    <TR>
		      <TD align="left" bgcolor="#cc0000">�@<B><FONT color="#ffffff" size="2">�G���[���������܂����I[ �G���[�R�[�h�F$error_code ]</FONT></B></TD>
		    </TR>
		    <TR>
		      <TD height="100" bgcolor="#ffffff"><FONT size="2">�ȉ��̓��e�ŃG���[���������܂����B<BR>
		      $print_msg</FONT><BR>
		      </TD>
		    </TR>
		    <TR>
		      <TD align="center" bgcolor="#ffffff"><INPUT type="button" value="�@�߂�@" onclick="history.back();"></TD>
		    </TR>
		</TABLE>
		</CENTER>
		</BODY>
		</HTML>
	|;

	print "Content-type: text/html\n\n";
	print $print_html;
	exit;
}
#-----------------------------------------------------------------------------0
#										���݂̎����𓾂�
#------------------------------------------------------------------��
sub get_time {
	my $tsec = time();
	my($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($tsec);
	$mon++;
	$year += 1900;
	return sprintf("$year�N$mon��$mday�� %02d:%02d:%02d", $hour, $min, $sec);
}


#-----------------------------------------------------------------------------0
#										�ϐ��`�F�b�N
#------------------------------------------------------------------��
sub check {
	local(@get) = @_;
	local($gettime,$check,$nul,$get);
	local($check_log) = "$ENV{'DOCUMENT_ROOT'}/cgi_check.htm";
	foreach (@get) {$get .= $_}

	$get =~ s/</&lt;/g;
	$get =~ s/>/&gt;/g;
	$get =~ s/\r\n/<FONT color="blue">\\r\\n<\/FONT><br>/g;
	$get =~ s/\r/<FONT color="blue">\\r<\/FONT><br>/g;
	$get =~ s/\n/<FONT color="blue">\\n<\/FONT><br>/g;

	$gettime = &lib'get_time;
	unless ($col) {
		$col = 1;
		$buf = "$gettime<BR><BR>";
		$buf .= "$col : $get<BR>";
		&lib'writefile($check_log,$buf);
	} else {
		$col++;
		$buf = "$col : $get<BR>";
		&lib'stokfile($check_log,$buf);
	}
}



#�O��X�V���F2005.09.27
#�ŏI�X�V���F2006.04.19


