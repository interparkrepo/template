#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����account.pl [Ver.2005.09.12] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F
#|���������ŏI�X�V���F2005.09.12
#|��
#|������������������������������������������������������������������������������


#-----------------------------------------------------------------------------0
#										�A�J�E���g�̐ݒ�
#------------------------------------------------------------------��
sub subroutine {
	$title_bar = '�A�J�E���g�̐ݒ�';

	#----------------------------------------
	# �����ݒ�
	if ($FORM{'route'} eq 'new') {SET:
		$return_html = &form_initialize($html{4},@AC_DB);

	#----------------------------------------
	# �g�b�v
	} elsif (!$action) {TOP:
		# �����ݒ�
		if (!@AC_LOG) {
			goto SET;
		# �V�X�e���Ǘ���
		} elsif ($ACC{'user_authorize'}) {
			$return_html = &account_list($html{2});
		# HP�Ǘ���
		} else {
			%FORM = %ACC;
			$return_html = &account_form($html{1});
		}

	#----------------------------------------
	# �V�K
	} elsif ($action eq 'new') {NEW:
		$return_html = &account_form($html{3});

	#----------------------------------------
	# �o�^���s
	} elsif ($action eq 'new_regist' || $action eq 'set') {
		$return_html = &new_account($html_msgbox);

	#----------------------------------------
	# �C��
	} elsif ($action eq 'edit') {
		my $log = &lib'get_log_line($FORM{'user_name'},@AC_LOG);
		&get_log_field($log,*FORM,@AC_DB);EDIT:
		$return_html = &account_form($html{1});

	#----------------------------------------
	# �C�����s
	} elsif ($action eq 'change') {
		$return_html = &account_edit($html_msgbox);
		
	#----------------------------------------
	# �폜
	} elsif ($action eq 'delete') {
		&lib'change_log_line($account_log,$FORM{'user_name'});
		&lib'openfile($account_log,*AC_LOG);
		goto TOP;
	}

	return $return_html;
}


#-----------------------------------------------------------------------------0
#										�����ݒ�
#------------------------------------------------------------------��
sub new_account {
	local($html) = @_;
	### �d���m�F
	foreach (@AC_LOG) {
		&get_log_field($_,*AC,@AC_DB);
		if ($AC{'user_name'} eq $FORM{'user_name'}) {
			$error_msg{'user_name'} = '���̃��[�U�[���͂��łɗ��p����Ă��܂��B<BR>';
		}
		if ($AC{'user_email'} eq $FORM{'user_email'}) {
			$error_msg{'user_email'} = '����E-Mail�͂��łɗ��p����Ă��܂��B<BR>';
		}
	}

	### �p�X���[�h
	if (!$FORM{'user_pass'}) {
		$error_msg{'user_pass'} = '�p�X���[�h�͏ȗ��ł��܂���B<BR>';
	} elsif ($FORM{'user_pass'} ne $FORM{'user_pass2'}) {
		$error_msg{'user_pass'} = '�p�X���[�h����v���܂���B<BR>';
	}

	&check_form_data(@AC_DB);
	if (%error_msg && $action eq 'set') {
		goto SET;
	} elsif (%error_msg && $action eq 'new_regist') {
		goto NEW;
	}

	$FORM{'user_pass'} = crypt($FORM{'user_pass'},"$crypt_key");
	my $new_log = &lib'make_log_line(\@AC_DB,\%FORM);
	&lib'stokfile($account_log,$new_log);

	if ($action eq 'new_regist') {
		$html =~ s/#title#/�o�^���������܂����B/;
		$html =~ s/#msg#/�V�K�A�J�E���g�̓o�^���������܂����B/;
		$html =~ s/#html#/account/;
		$html =~ s/#action#//;
	} elsif ($action eq 'set') {
		### �N�b�L�[�̃Z�b�g
		my $c_value = "n:$FORM{'user_name'},p:$FORM{'user_pass'},t:$time";
		&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
		&login_record('login','�A�J�E���g�쐬',$FORM{'user_name'});
		
		$html =~ s/#title#/�ݒ肪�������܂����B/;
		$html =~ s/#msg#/�V�X�e���Ǘ��҂̃A�J�E���g�o�^���������܂����B�����ăV�X�e���̊��ݒ���s�Ȃ��܂��B/;
		$html =~ s/#html#/conf/;
		$html =~ s/#action#//;
		$html =~ s/�߂�/���ݒ��/;
	}

	return $html;
}


#-----------------------------------------------------------------------------0
#										�C��
#------------------------------------------------------------------��
sub account_edit {
	local($html) = @_;

	### �p�X���[�h
	if ($FORM{'user_pass'} && $FORM{'user_pass'} ne $FORM{'user_pass2'}) {
		$error_msg{'user_pass'} = '�p�X���[�h����v���܂���B<BR>';
	}

	&check_form_data(@AC_DB);
	(%error_msg) && (goto EDIT);

	if ($FORM{'user_pass'}) {
		$FORM{'user_pass'} = crypt($FORM{'user_pass'},"$crypt_key");
	} else {
		$FORM{'user_pass'} = $FORM{'now_pass'};
	}
	
	my $new_log = &lib'make_log_line(\@AC_DB,\%FORM);
	&lib'change_log_line($account_log,$FORM{'user_name'},$new_log);
	
	### �N�b�L�[�̃Z�b�g
	if ($ACC{'user_name'} eq $FORM{'user_name'}) {
		my $c_value = "n:$FORM{'user_name'},p:$FORM{'user_pass'},t:$time";
		&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
	}

	$html =~ s/#title#/�C�����������܂����B/;
	$html =~ s/#msg#/���[�U�[���u$FORM{'user_name'}�v�̃A�J�E���g�̏C�����������܂����B/;
	$html =~ s/#html#/account/;
	$html =~ s/#action#//;

	return $html;
}


#-----------------------------------------------------------------------------1
#										�V�X�e���Ǘ���
#------------------------------------------------------------------��2005.09.12
sub account_list {
	local($html) = @_;

	my @CUT = split(/<!-- CUT -->/,$html);
	my $list;
	foreach (@AC_LOG) {
		&get_log_field($_,*AC,@AC_DB);
		my $dum = @CUT[1];
		if ($AC{'user_authorize'}) {
			$AC{'user_authorize'} = '���ъǗ���';
			$dum =~ s/cell1"/cell2"/g;
		} else {
			$AC{'user_authorize'} = 'HP�Ǘ���';
		}
		($ACC{'user_name'} eq $AC{'user_name'}) && ($dum =~ s/�폜//g);
		$list .= &lib'change_key($dum,\@AC_DB,\%AC);
	}
	$html = "@CUT[0]$list@CUT[2]";
	
	return $html;
}


#-----------------------------------------------------------------------------0
#										HP�Ǘ���
#------------------------------------------------------------------��
sub account_form {
	local($html) = @_;

	($FORM{'now_pass'}) && ($FORM{'user_pass'} = $FORM{'now_pass'});
	$html = &form_initialize($html,@AC_DB);
	if (!$ACC{'user_authorize'}) {
		my @CUT = split(/<!-- authorize -->/,$html);
		$html = "@CUT[0]@CUT[2]";
	} elsif ($ACC{'user_name'} eq $FORM{'user_name'}) {
		$html =~ s/type="radio"/type="hidden"/;
		my @CUT = split(/<!-- authorize2 -->/,$html);
		$html = "@CUT[0]@CUT[2]";
	}
	
	return $html;
}



1;
