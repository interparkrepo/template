#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����admin.pl [Ver.2009.06.14] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F2009.02.02
#|���������ŏI�X�V���F2009.06.14
#|��
#|������������������������������������������������������������������������������


#-----------------------------------------------------------------------------1
#										�Ǘ���ʂ̍쐬
#------------------------------------------------------------------��2005.09.03
sub subroutine {
	&setup_conf;
	$title_bar = '���C�Z���X�o�^';

	#-----------------------------------------
	# ���C�Z���X�o�^�t�H�[��
	if ($lcs eq $html && !$action) {GO1:
		($au eq "$fckey\meijin") && (&print_flame);
		$return_html = &init_form($html{1});
		
	#-----------------------------------------
	# �e�X�g���p�J�n�iCGI-Park����̉𓚁j
	} elsif ($action eq 'test_start') {
		&test_start;
		print"Location: ./admin.cgi?c=no\n\n";
		exit;
		
	#-----------------------------------------
	# ���C�Z���X�o�^�t�H�[���i�����؂�j
	} elsif ($action eq 'lcs_form') {GO2:
		($au eq "$fckey\meijin") && (&print_flame);
		$return_html = &init_form($html{2});
		
	#-----------------------------------------
	# ���C�Z���X�o�^�iCGI-Park����̉𓚁j
	} elsif ($action eq 'license') {
		&set_license;
		print"Location: ./admin.cgi?c=no\n\n";
		exit;
		
	#-----------------------------------------
	# �X�e�[�^�X�m�F�iCGI-Park����̉𓚁j
	} elsif ($action eq 'status_check') {
		&status_check;
		
	#-----------------------------------------
	# �e�X�g�T�[�o�[�o�^�t�H�[��
	} elsif ($action eq 'cts') {GO3:
		$return_html = &cts($html{3});
		$html_header =~ s/width="600"/width="100%"/g;
		
	#-----------------------------------------
	# ���C�Z���X���̕\��
	} elsif ($action eq 'show_license') {
		$title_bar = '���C�Z���X���̕\\��';
		$return_html = &show_license($html{4});
		
	#-----------------------------------------
	# �A�b�v�f�[�g�t�H�[��
	} elsif ($action eq 'update') {
		$title_bar = '�A�b�v�f�[�g';
		$return_html = $html{5};
		
	#-----------------------------------------
	# �A�b�v�f�[�g�m�F
	} elsif ($action eq 'update_check') {
		$title_bar = '�A�b�v�f�[�g';
		$return_html = &update_check($html{6});
		if ($error_msg) {
			$html{5} =~ s/<!-- error_msg -->/$error_msg<BR>/;
			$return_html = $html{5};
		}
		
	#-----------------------------------------
	# �A�b�v�f�[�g���s
	} elsif ($action eq 'update_exe') {
		$title_bar = '�A�b�v�f�[�g';
		$return_html = &update_exe($html_msgbox);
		
	#-----------------------------------------
	# �V�X�e���č\�z
	} elsif ($action eq 'remake') {
		$title_bar = '�V�X�e���č\�z';
		$return_html = &remake_check($html{7});
		
	#-----------------------------------------
	# �V�X�e���č\�z ���s
	} elsif ($action eq 'remake_exe') {
		$title_bar = '�V�X�e���č\�z';
		$return_html = &remake_exe($html_msgbox);
		
	#-----------------------------------------
	# �V�X�e���č\�z ���s
	} elsif ($action eq 'record') {
		$title_bar = '��Ɨ���';
		$return_html = &show_record($html{8});
		
	#-----------------------------------------
	# �t���[���̕\��
	} else {
		$return_html = &check_url($html{3});
		if (!$return_html) {
			&print_flame;
		}
	}
	
	$return_html =~ s/#target#/$conf{'target'}/g;
	return $return_html;
}



#-----------------------------------------------------------------------------2
#										���C�Z���X�t�H�[��
#------------------------------------------------------------------��2006.04.19
sub init_form {
	local($html) = @_;
	my $day30 = $time + 2592000;
	$html =~ s/#test_date#/&lib'get_time($day30,'3-0W')/ge;
		
	$html =~ s/#site_name#/$FORM{'site_name'}/;
	$html =~ s/#site_url#/$FORM{'site_url'}/;
	$html =~ s/#lc_code#/$FORM{'lc_code'}/;
	$html =~ s/#soft_code#/$fckey/g;
	$html =~ s/#soft_name#/$mjnm/g;
	$html =~ s/#apa#/$apa/g;
	$html =~ s/<!-- ER_test -->/$error_msg{"test"}/;
	if ($lh =~ /$ENV{'HTTP_HOST'}/) {
		$html =~ s/#http_host#//g;
	} else {
		$html =~ s/#http_host#/$ENV{'HTTP_HOST'}/g;
	}
	
	### �߂��URL�̍쐬
	my $ref = &make_ref_url;
	$html =~ s/#ref#/&lib'url_encode($ref)/eg;
	
	$html_header =~ s/width="600"/width="100%"/g;

	return $html;
}


#-----------------------------------------------------------------------------0
#										���p���Ԃ̊J�n
#------------------------------------------------------------------��
sub test_start {
	if (!$FORM{'test_time'}) {
		$error_msg{'test'} = '���p���J�n���邱�Ƃ��o���܂���ł����B<BR>';
		goto GO1;
	}
	my $test_time = "$FORM{'test_time'}\n";
	&lib'stokfile($meijin_log,$test_time);
}


#-----------------------------------------------------------------------------2
#										�t���[���̍쐬
#------------------------------------------------------------------��2007.02.23
sub print_flame {
	### �X�e�[�^�X�m�F
	if (-e "$LogDir/lcstatus.$log_ext") {
		&lib'openfile("$LogDir/lcstatus.$log_ext",*ER);
		&lib'system_error("er500-$ER[0]","���C�Z���X���ɃG���[������A�Ǘ���ʂւ̃A�N�Z�X�����ۂ���܂����B<BR>�ڂ����́A�V�X�e���Ǘ��҂ɂ��₢���킹���������B");
	}
	$print_html = "$html{'header'}$html{'footer'}";
	$print_html =~ s/#l_width#/$conf{'l_width'}/;
	$print_html =~ s/#menu#/admin.cgi?html=menu/;
	$print_html =~ s/#top#/$conf{'init_menu'}/;
	if ($conf{'left_scroll'} eq '1') {
		$print_html =~ s/scrolling="NO"//;
	}
	print "Content-type: text/html\n\n";
	print $print_html;
	exit;

}

#-----------------------------------------------------------------------------1
#										���C�Z���X�o�^
#------------------------------------------------------------------��2005.09.03
sub set_license {

	#--------------------------------
	# �F�؃G���[
	if ($FORM{'er'}) {
		$html{"$FORM{'page'}"} =~ s/<!-- ER -->/���C�Z���X��񂪐���������܂���B($FORM{'er'})/;
		$print_html = &init_form($html{"$FORM{'page'}"});
		goto "GO$FORM{'page'}";

	#--------------------------------
	# �e�X�g�T�[�o�o�^
	} elsif ($FORM{'http_host'}) {
		$test_url = $FORM{'http_host'};
	}

	#--------------------------------
	# ���C�Z���X�F�ؔԍ��̋L�^
	if ($FORM{'lcc'}) {
		&lib'writefile("$LogDir/lcc.$log_ext",$FORM{'lcc'});
	}
	
	my $mlc = "$FORM{'lc_code'}\0$FORM{'site_name'}\0$FORM{'site_url'}\0$test_url\0$time\0\0\n";
	&lib'openfile($meijin_log,*MJ);
	my @NEW_MJ = shift @MJ;
	push @NEW_MJ,$mlc;
	&lib'writefile($meijin_log,@NEW_MJ);
}


#-----------------------------------------------------------------------------2
#										���C�Z���X�t�H�[��
#------------------------------------------------------------------��2006.04.19
sub cts {
	local($html) = @_;

	$html =~ s/#lc_code#/$lc1/g;
	$html =~ s/#site_name#/$lc2/g;
	$html =~ s/#site_url#/$lc3/g;
	$html =~ s/#http_host#/$ENV{'HTTP_HOST'}/g;
	$html =~ s/#soft_code#/$fckey/g;
	$html =~ s/#apa#/$apa/g;
	
	### �߂��URL�̍쐬
	my $ref = &make_ref_url;
	$html =~ s/#ref#/&lib'url_encode($ref)/eg;

	return $html;
}

#-----------------------------------------------------------------------------0
#										�t�q�k�m�F
#------------------------------------------------------------------��
sub check_url {
	local($html) = @_;
	if (!$lc3) {
		return;
	} elsif ($lh =~ /$ENV{'HTTP_HOST'}/) {
		return;
	} elsif ($lc3 =~ /$ENV{'HTTP_HOST'}/ && $lc5) {
		return;
	} elsif ($lc4 =~ /$ENV{'HTTP_HOST'}/) {
		return;
	} elsif (!$lc4) {
		goto GO3;
	} else {
#		$html = $html_error;
#		$html =~ s/#title#/���C�Z���X�F�؃G���[�I/;
#		$html =~ s/#msg#/�ݒu���Ă���T�[�o�̓��C�Z���X���ƈ�v���܂���B/;
        return;
	}
	return $html;
}


#-----------------------------------------------------------------------------5
#										���C�Z���X���
#------------------------------------------------------------------��2009.06.14
sub show_license {
	local($html) = @_;
	my($frame_url);
	my $upflag = 'disabled';
	
	### ���C�Z���X�o�^�ς�
	if ($lc1 =~ /^L/) {
		($lc5) && ($lc5 = &lib'get_time($lc5,'3-0WF'));
		my @CUT = split(/<!-- CUT -->/,$html);
		$html = "$CUT[0]$CUT[2]";
		&lib'openfile("$LogDir/lcc.$log_ext",*LCC);
		my $ref = &make_ref_url;
		if ($mjnm =~ /�i���j/) {
			my $text = &lib'url_encode('�����ł̂��߃A�b�v�f�[�g�s��');
			$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
		} else {
			$frame_url = "https://www.cgi-park.com/license/regist.cgi?action=status&lc_code=$lc1&soft_code=$fckey&lcc=$LCC[0]&fud=$fud&ref=$ref";
			$upflag = '';
		}
	### ���p���Ԓ�
	} elsif ($lc1) {
		my $gap = substr $lc1,0,2;
		my $gtime = substr $lc1,2,10;
		my $apa2 = $apa;
		foreach (0..10) {$p += substr $gtime,$_,1;}
		foreach (0..$p) {$apa2++;}
		($apa2 eq $gap) || ($erflag = 1);
		$gtime = reverse $gtime;
		$test_date = &lib'get_time($gtime,'3-0W');
		$lc1 = '';
		
		my $text = &lib'url_encode('���p���Ԓ�');
		$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
	} else {
		$html =~ s/#test_date#�܂�//;
		my $text = &lib'url_encode('���쏀����');
		$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
	}
	### �č\�z�{�^��
	if ($mjnm =~ /�i���j/) {
		$html =~ s/#remake_btn#/disabled/;
	}

	### ���C�Z���X��Ԃ̕\��
	$html =~ s/#frame_url#/$frame_url/;

	$html =~ s/#update_btn#/$upflag/;
	$html =~ s/#lc_code#/$lc1/;
	$html =~ s/#site_name#/$lc2/;
	$html =~ s/#site_url#/$lc3/;
	$html =~ s/#test_server#/$lc4/;
	$html =~ s/#date#/$lc5/;
	$html =~ s/#meijin_name#/$mjnm/;
	$html =~ s/#test_date#/$test_date/;
	
	return $html;
}

# 4:2009.02.02 ���p���Ԃ̓��t���𐳂����擾�ł���悤�ɒ���
# 5:2009.06.14 �A�b�v�f�[�g�m�F��SSL�Ŋm�F����悤�ɕύX/���b�Z�[�W���G���R�[�h

#-----------------------------------------------------------------------------1
#										�X�e�[�^�X�m�F
#------------------------------------------------------------------��2005.09.05
sub status_check {
	my $print_status;
	# ���C�Z���X�m�F�R�[�h�̔F��
	if ($FORM{'status'} ne crypt('LCC','ys')) {
		&lib'openfile("$LogDir/lcc.$log_ext",*LCC);
		my $xlcc = crypt($LCC[0],$apa);
		$xlcc =~ s/[^a-zA-Z0-9]//g;
		if ($xlcc eq $FORM{'lcc'}) {
			# NG'ysxJegUpOVivE'
			if ($FORM{'status'} eq crypt('NG','ys')) {
				($FORM{'lock'}) && (&lib'writefile("$LogDir/lcstatus.$log_ext",$FORM{'er'}));
			# OK'ys6wBbpTkODgY'
			} elsif ($FORM{'status'} eq crypt('OK','ys')) {
				my $file = "$LogDir/lcstatus.$log_ext";
				(-e $file) && (unlink $file);
				if ($mjnm =~ /�i���j/) {
					$FORM{'text'} = '�A�b�v�f�[�g�t�@�C���͂���܂���B';
				}
			# SU'ysS.JePFjjFt.'
			} elsif ($FORM{'status'} eq crypt('SU','ys')) {
				my $pw = crypt($FORM{'pw'},$crypt_key);
				&lib'writefile("$LogDir/cpsu",$pw);
			}
		}
		
	# ���C�Z���X�m�F�R�[�h�̍쐬
	} else {
		my $lcc_log = "$LogDir/lcc.$log_ext";
		(-e $lcc_log) || (&lib'writefile($lcc_log,$FORM{'lcc'}));
	}

	my $print = qq|<TABLE border="0" width="100%" height="100%" style="font-size:14px;"><TR><TH>$FORM{'text'}</TH></TR></TABLE>|;
	print "Content-type: text/html\n\n";
	print $print;
	exit;
}



#-----------------------------------------------------------------------------1
#										�A�b�v�f�[�g�̊m�F
#------------------------------------------------------------------��2005.09.03
sub update_check {
	local($html) = @_;
	### �X�e�[�^�X�m�F
	if (-e "$LogDir/lcstatus.$log_ext") {
		&lib'openfile("$LogDir/lcstatus.$log_ext",*ER);
		&lib'system_error("er500-$ER[0]","���C�Z���X���ɃG���[������A�Ǘ���ʂւ̃A�N�Z�X�����ۂ���܂����B<BR>�ڂ����́A�V�X�e���Ǘ��҂ɂ��₢���킹���������B");
	}
	if (!$lc1) {
		$html_error =~ s/#title#/�G���[�I/;
		$html_error =~ s/#msg#/�A�b�v�f�[�g�����s���邱�Ƃ��o���܂���B<BR>�A�b�v�f�[�g���s�Ȃ��ɂ͐��������C�Z���X���o�^����Ă���K�v������܂��B/;
		return $html_error;
	}

	### �A�b�v�f�[�g�t�@�C���̊m�F
	if (!$FORM{'cpm_file'}) {
		$error_msg = '�A�b�v�f�[�g�t�@�C����I�����Ă��������B';
	}
	my $cpm_file_name = reverse $incfn{'cpm_file'};
	($cpm_file_name) = split(/\\/,$cpm_file_name);
	$cpm_file_name = reverse $cpm_file_name;
	my($name,$ext) = split(/\./,$cpm_file_name);
	($ext ne 'cpm') && ($error_msg = '�A�b�v�f�[�g�t�@�C�����s���ł��B�������t�@�C����I�����Ă��������B');
	my($name1,$name2) = split(/\-/,$name);
	($name1 ne $fckey) && ($error_msg = '�A�b�v�f�[�g�t�@�C�����s���ł��B�������t�@�C����I�����Ă��������B');
	
	### �t�@�C���̒��g���m�F
	$FORM{'cpm_file'} = &lib'unify_return_code($FORM{'cpm_file'});
	my @SYS = split(/\n/,$FORM{'cpm_file'});
	my $head = shift @SYS;
	my $foot = pop @SYS;
	my($fckey2,$apa2,$mjnm2,$fud2,$lud2,$cphp2,$cpem2) = split(/\0/,$head);
	if ($lud2 ne $fud) {
		$error_msg = '�A�b�v�f�[�g�t�@�C��������������܂���B<BR>���ݗ��p���Ă���o�[�W�������m�F���A���̃o�[�W�����ȍ~�ŏ��Ƀ����[�X���ꂽ�A�b�v�f�[�g�t�@�C����I�����Ă��������B';
	}

	### �G���[�̏ꍇ�����ŏI��
	($error_msg) && (return);

	### �A�b�v�f�[�g�t�@�C����ۑ�
	&lib'writefile("$LogDir/update-$name.$log_ext",$FORM{'cpm_file'});

	### �A�b�v�f�[�g���s�t�@�C���ꗗ�̍쐬
	my ($file_list,$file_name);
	foreach (@SYS) {
		my($file,$final_date,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $buf = "$DIR{\"$dir\"}/$name";
		if (!-e $buf) {
			$buf .= ' �i�V�K�ǉ��j';
		}
		$file_name .= "$buf<BR>";
	}
	$html =~ s/#file_name#/$file_name/g;
	$html =~ s/#pro_name#/$mjnm2/;
	$html =~ s/#final_date#/$fud2/;
	$html =~ s/#memo#/$foot/e;
	$html =~ s/#update_file#/$name/e;
	
	return $html;
}

#-----------------------------------------------------------------------------2
#										�A�b�v�f�[�g�̎��s
#------------------------------------------------------------------��2006.04.19
sub update_exe {
	local($html) = @_;
	($lc1) || (return);
	
	### �A�b�v�f�[�g�t�@�C���̓ǂݍ���
	my $update_file = "$LogDir/update-$FORM{'update_file'}.$log_ext";
	&lib'openfile($update_file,*UPDATE);
	my $new_head = shift @UPDATE;
	my $memo = pop @UPDATE;

	### ���C�Z���X�����ԍ��̓ǂݍ���
	local(@LCC);
	my $lcc_log = "$LogDir/lcc.$log_ext";
	&lib'openfile($lcc_log,*LCC);

	### CGI�p�[�~�b�V�����̊m�F
	my($par) = (stat("admin.cgi"))[2];

	### �A�b�v�f�[�g���s
	my $files;
	foreach (@UPDATE) {
		my($file,$ver,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $file_path = "$DIR{\"$dir\"}/$name";
		$data = reverse $data;
		$data =~ s/\[\\n\]/\n/g;
		if ($file_path =~ /.pl$/ || $file_path =~ /.cgi$/ ) {
			$data .= "\n#$file\n#$ver\n#$LCC[0]\n";
		}
		unlink $file_path;
		&lib'writefile($file_path,$data);
		if ($file_path =~ /.cgi$/) {
			chmod "$par" ,"$file_path";
		} else {
			chmod 0666, "$file_path";
		}
		### �X�V�v���O�����̎��s
		if ($name eq 'exe.pl') {
			require "$file_path";
			eval{&exe;};
			if ($@) {
				&lib'system_error('er600',"�A�b�v�f�[�g��ƂɎ��s���A�������p���ł��܂���ł����B<BR>$@",$@);
			} else {
				next;
			}
		}
		$new_line{"$file"} = $_;
		$files .= "$file,";
	}

	### �V�X�e���t�@�C���̍X�V
	&lib'openfile($system_log,*SYS);
	shift @SYS;
	foreach (@SYS) {
		my($file) = split(/\0/);
		if ($new_line{"$file"}) {
			s/.*\n/$new_line{"$file"}/;
			$new_line{"$file"} = '';
		}
	}
	foreach (@UPDATE) {
		my($file) = split(/\0/);
		if ($new_line{"$file"}) {
			push @SYS,$new_line{"$file"};
		}
	}
	unshift @SYS,$new_head;

	### �o�b�N�A�b�v
	my $fud3 = $fud;
	$fud3 =~ s/\.//g;
	rename "$system_log","$LogDir/backup-$fckey\-$fud3\.$log_ext";

	&lib'writefile($system_log,@SYS);
	unlink $update_file;
	
	### ���l�f�[�^�̍X�V
	my $meijin_log = "$LogDir/meijin.$log_ext";
	&lib'openfile($meijin_log,*MJ);
	$new_head =~ s/\0/\t/g;
	shift @MJ;
	unshift @MJ,$new_head;
	&lib'writefile($meijin_log,@MJ);

	### �X�V�����̍쐬
	my($new_mj) = (split(/\t/,$new_head))[2];
	&lib'openfile($up_record_db,*UR_DB);
	$UR{'ur_file'} = $FORM{'update_file'};
	$UR{'ur_name'} = $new_mj;
	$UR{'ur_time'} = $time;
	$UR{'ur_memo'} = $memo;
	$UR{'ur_list'} = $files;
	my $new_ur = &lib'make_log_line(\@UR_DB,\%UR);
	&lib'stokfile($up_record_log,$new_ur);

	$html =~ s/#title#/�A�b�v�f�[�g���������܂����B/;
	$html =~ s/#msg#/$new_mj�ւ̃A�b�v�f�[�g������Ɋ������܂����B/;
	$html =~ s/#html#/admin/;
	$html =~ s/#action#/show_license/;
	return $html;
}


#-----------------------------------------------------------------------------0
#										�V�X�e���̍č\�z �m�F
#------------------------------------------------------------------��
sub remake_check {
	local($html) = @_;

	### �č\�z���s�t�@�C���ꗗ�̍쐬
	my ($file_list,$file_name);
	&lib'openfile($system_log,*SYS);
	my $head = shift @SYS;
	foreach (@SYS) {
		my($file,$final_date,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $buf = "$DIR{\"$dir\"}/$name";
		if (!-e $buf) {
			$buf .= ' �i�ǉ��j';
		}
		$file_name .= "$buf<BR>";
	}
	my($mjnm2,$fud2) = (split(/\0/,$head))[2,3];
	$html =~ s/#file_name#/$file_name/g;
	$html =~ s/#pro_name#/$mjnm2/;
	$html =~ s/#final_date#/$fud2/;

	return $html;
}

#-----------------------------------------------------------------------------1
#										�V�X�e���̍č\�z
#------------------------------------------------------------------��2006.04.19
sub remake_exe {
	local($html) = @_;
	($lc1) || (return);
	### ���C�Z���X�����ԍ��̓ǂݍ���
	local(@LCC);
	my $lcc_log = "$LogDir/lcc.$log_ext";
	&lib'openfile($lcc_log,*LCC);

	### CGI�p�[�~�b�V�����̊m�F
	my($par) = (stat("admin.cgi"))[2];
	
	### �t�@�C���̓W�J
	&lib'openfile($system_log,*SYS);
	shift @SYS;
	my $files;
	foreach (@SYS) {
		my($file,$ver,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $file_name = "$DIR{\"$dir\"}/$name";
		$data = reverse $data;
		$data =~ s/\[\\n\]/\n/g;
		if ($file_name =~ /.pl$/ || $file_name =~ /.cgi$/ ) {
			$data .= "\n#$file\n#$ver\n#$LCC[0]\n";
		}
		unlink $file_name;
		&lib'writefile($file_name,$data);
		if ($file_name =~ /.cgi$/) {
			chmod "$par" ,"$file_name";
		} else {
			chmod 0666, "$file_name";
		}
		$files .= "$file,";
	}
	
	### �X�V�����̍쐬
	my($new_mj) = (split(/\t/,$new_head))[2];
	&lib'openfile($up_record_db,*UR_DB);
	$UR{'ur_name'} = $mjnm;
	$UR{'ur_time'} = $time;
	$UR{'ur_memo'} = "$mjnm�̍č\\�z";
	$UR{'ur_list'} = $files;
	my $new_ur = &lib'make_log_line(\@UR_DB,\%UR);
	&lib'stokfile($up_record_log,$new_ur);
	
	$html =~ s/#title#/�V�X�e���̍č\\�z���������܂����B/;
	$html =~ s/#msg#/$mjnm�̃V�X�e���̍č\\�z������Ɋ������܂����B/;
	$html =~ s/#html#/admin/;
	$html =~ s/#action#/show_license/;
	return $html;
}


#-----------------------------------------------------------------------------0
#										��Ɨ����̕\��
#------------------------------------------------------------------��
sub show_record {
	local($html) = @_;

	&lib'openfile($up_record_log,*UR_LOG);
	&lib'openfile($up_record_db,*UR_DB);
	@UR_LOG = reverse @UR_LOG;

	my @CUT = split(/<!-- CUT -->/,$html);
	my $list;
	foreach (@UR_LOG) {
		&get_log_field($_,*UR,@UR_DB);
		my $dum = $CUT[1];
		if ($UR{'ur_file'}) {
			$dum =~ s/#title#/$UR{'ur_name'}�փA�b�v�f�[�g/;
		} else {
			$dum =~ s/#title#/$UR{'ur_name'}�̍č\\�z/;
		}
		$UR{'ur_list'} =~ s/,/<BR>/g;
		$list .= &lib'change_key($dum,\@UR_DB,\%UR,'3-3WF');
	}
	if ($list) {
		$html = "$CUT[0]$list$CUT[2]";
	} else {
		$html = $html_error;
		$html =~ s/#title#/�����͂���܂���ł����B/;
		$html =~ s/#msg#/���݂܂ł̍�Ɨ����͂���܂���ł����B/;
	}

	return $html;
}



#-----------------------------------------------------------------------------0
#										�߂��URL�̍쐬
#------------------------------------------------------------------��2006.04.19
sub make_ref_url {
	my $ref;
	if ($admin_cgi_path) {
		$ref = $admin_cgi_path;
	} elsif ($ENV{'SCRIPT_URI'}) {
		$ref = $ENV{'SCRIPT_URI'};
	} elsif ($ENV{'HTTP_REFERER'}) {
		my(@hr) = split(/\//,$ENV{'HTTP_REFERER'});
		$ref = "$hr[0]//$hr[2]$ENV{'SCRIPT_NAME'}";
	}
	return $ref;
}


1;
