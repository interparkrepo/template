#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����memu.pl [Ver.2005.09.27] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F
#|���������ŏI�X�V���F2005.09.27
#|��
#|������������������������������������������������������������������������������

#-----------------------------------------------------------------------------1
#										���j���[�̍쐬
#------------------------------------------------------------------��2005.09.27
sub subroutine {
	$title_bar = '���j���[�Ǘ�';
	&lib'openfile($menu_dat,*MN_DAT);
	
	#---------------------------------
	# ���j���[�̕\��
	if (!$action) {
		$html_header = $html{'header'};
		$html_footer = $html{'footer'};
		$html_title = '';
		$return_html = &show_menu($html{1});
	}

	#---------------------------------
	# �V�X�e���Ǘ��҃��j���[
	else {
		($ACC{'user_authorize'}) || (return);
		$title_bar .= '�i�V�X�e���Ǘ��Ґ�p���j���[�j';
		#---------------------------------
		# �A�N�Z�X�����̕ύX
		if ($action eq 'setup') {
			$return_html = &menu_setup($html{2},$html_msgbox);
			
		#---------------------------------
		# ���j���[�̃J�X�^�}�C�Y
		} elsif ($action eq 'custom') {LIST:
			$return_html = &menu_custom($html{3});
			
		#---------------------------------
		# �ݒ�t�H�[��
		} elsif ($action eq 'form') {
			$return_html = &menu_form($html{4});
			
		#---------------------------------
		# �ݒ�
		} elsif ($action eq 'regist') {
			$return_html = &menu_regist($html_msgbox);
			
		#---------------------------------
		# �폜
		} elsif ($action eq 'delete') {
			&lib'change_log_line($menu_dat,$FORM{'code'});
			&lib'openfile($menu_dat,*MN_DAT);
			goto LIST;
			
		#---------------------------------
		# �����ύX
		} elsif ($action eq 'up' || $action eq 'down') {
			&lib'change_line($menu_dat,$FORM{'code'},$action);
			&lib'openfile($menu_dat,*MN_DAT);
			goto LIST;
			
		}
	}
	
	$return_html =~ s/#target#/$conf{'target'}/;
	return $return_html;
}

#-----------------------------------------------------------------------------0
#										���j���[�̕\��
#------------------------------------------------------------------��
sub show_menu {
	local($html) = @_;
	### �����ݒ��
	if (!@AC_LOG) {
		$ACC{'user_authorize'} = 1;
	}

	my @CUT = split(/<!-- CUT -->/,$html);
	my $list;
	foreach (@MN_DAT) {
		my($code,$name,$link,$flag) = split(/\t/);
		(!$ACC{'user_authorize'} && $flag) && (next);
		if ($link) {
			$dum = @CUT[2];
			$dum =~ s/#name#/$name/g;
			$dum =~ s/#link#/$link/g;
		} else {
			$dum = @CUT[1];
			$dum =~ s/#name#/$name/g;
		}
		$list .= $dum;
	}
	$html = "@CUT[0]$list@CUT[3]";
		
	return $html;
}

#-----------------------------------------------------------------------------0
#										�A�N�Z�X�����̕ύX
#------------------------------------------------------------------��2005.09.27
sub menu_setup {
	local($html,$html2) = @_;

	my @CUT = split(/<!-- CUT -->/,$html);
	my ($list);
	foreach (@MN_DAT) {
		my($code,$name,$link,$flag) = split(/\t/);
		if ($FORM{'btn'}) {
			if ($flag ne $FORM{"$code"}) {
				$flag = $FORM{"$code"};
				my $log = "$code\t$name\t$link\t$flag\t\t0\n";
				s/.*\n/$log/;
			}
		}
		if ($link) {
			$dum = @CUT[2];
			$dum =~ s/#link#/$link/g;
		} else {
			$dum = @CUT[1];
		}
		$dum =~ s/#name#/$name/g;
		$dum =~ s/#code#/$code/g;
		($flag) ? ($dum =~ s/#check#/checked/) : ($dum =~ s/#check#//);
		$list .= $dum;
	}
	$html = "@CUT[0]$list@CUT[3]";

	if ($FORM{'btn'}) {
		&lib'writefile($menu_dat,@MN_DAT);
		$html2 =~ s/#title#/�ύX���������܂���/;
		$html2 =~ s/#msg#/�Ǘ����j���[�̃A�N�Z�X�����̕ύX���������܂����B/;
		$html2 =~ s/#html#/menu/;
		$html2 =~ s/#action#/setup/;
		return $html2;
	}
	return $html;
}

#-----------------------------------------------------------------------------1
#										���j���[�̃J�X�^�}�C�Y
#------------------------------------------------------------------��2005.09.27
sub menu_custom {
	local($html) = @_;

	my @CUT = split(/<!-- CUT -->/,$html);
	my ($list,$n);
	foreach (@MN_DAT) {
		$n++;
		my($code,$name,$link,$flag) = split(/\t/);
		if ($link) {
			$dum = @CUT[2];
			$dum =~ s/#name#/$name/g;
			$dum =~ s/#link#/$link/g;
		} else {
			$dum = @CUT[1];
			$dum =~ s/#name#/$name/g;
		}
		$dum =~ s/#code#/$code/g;
		($flag) ? ($dum =~ s/#flag#/���ъǗ���/) : ($dum =~ s/#flag#//);
		(@MN_DAT[$n]) || ($dum =~ s/��//);
		$list .= $dum;
	}
	$list =~ s/��//;
	$html = "@CUT[0]$list@CUT[3]";
	
	return $html;
}

#-----------------------------------------------------------------------------0
#										���j���[�t�H�[��
#------------------------------------------------------------------��
sub menu_form {
	local($html) = @_;

	if ($FORM{'code'}) {
		my $log = &lib'get_log_line($FORM{'code'},@MN_DAT);
		($code,$name,$link,$flag) = split(/\t/,$log);
	}
	$html =~ s/#code#/$code/g;
	$html =~ s/#name#/$name/g;
	$html =~ s/#link#/$link/g;
	$html =~ s/#flag$flag#/checked/;
	
	return $html;
}

#-----------------------------------------------------------------------------0
#										�ݒ�
#------------------------------------------------------------------��
sub menu_regist {
	local($html) = @_;

	if ($FORM{'code'}) {
		my $log = "$FORM{'code'}\t$FORM{'name'}\t$FORM{'link'}\t$FORM{'flag'}\t\t0\n";
		&lib'change_log_line($menu_dat,$FORM{'code'},$log);
	} else {
		my @LOG = sort by_num @MN_DAT;
		($FORM{'code'}) = split(/\t/,@LOG[0]);
		$FORM{'code'}++;
		my $log = "$FORM{'code'}\t$FORM{'name'}\t$FORM{'link'}\t$FORM{'flag'}\t\t0\n";
		&lib'stokfile($menu_dat,$log);
	}
	
	$html =~ s/#title#/�ݒ肪�������܂����B/g;
	$html =~ s/#msg#/���j���[�̐ݒ肪�������܂����B/g;
	$html =~ s/#html#/menu/g;
	$html =~ s/#action#/setup/;
	
	return $html;
}


1;
