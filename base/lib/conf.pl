#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����conf.pl [Ver.2007.10.01] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F2007.02.08
#|���������ŏI�X�V���F2007.10.01
#|��
#|������������������������������������������������������������������������������


#-----------------------------------------------------------------------------0
#										���ݒ�
#------------------------------------------------------------------��
sub subroutine {
	$title_bar = '���ݒ�̕ύX';
	&lib'openfile($conf_log,*CF_LOG);
	&lib'openfile($conf_db,*CF_DB);

	#---------------------------------
	# �ꗗ�\��
	if (!$action) {GO1:
		$return_html = &init_form($html{1});
		
	#---------------------------------
	# �ݒ�ύX
	} elsif ($action eq 'change') {
		$return_html = &conf_change($html_msgbox);

	#---------------------------------
	# �V�X�e���Ǘ��҃��j���[
	} else {
		($ACC{'user_authorize'}) || (return);
		$title_bar .= '�i�V�X�e���Ǘ��Ґ�p���j���[�j';
		#---------------------------------
		# �ݒ胊�X�g
		if ($action eq 'list') {LIST:
			$return_html = &conf_list($html{2});

		#---------------------------------
		# ���̓t�H�[��
		} elsif ($action eq 'new') {NEW:
			$return_html = &form_initialize($html{3},@CF_DB);
			$return_html =~ s/#now_name#/$FORM{'now_name'}/;

		#---------------------------------
		# �o�^
		} elsif ($action eq 'regist') {
			&check_form_data(@CF_DB);
			if (%error_msg) {
				goto NEW;
			} else {
				$return_html = &conf_regist($html_msgbox);
			}
			
		#---------------------------------
		# �ݒ�t�H�[��
		} elsif ($action eq 'edit') {
			my $log = &lib'get_log_line($FORM{'conf_name'},@CF_LOG);
			&get_log_field($log,*FORM,@CF_DB);
			$FORM{'now_name'} = $FORM{'conf_name'};
			goto NEW;
			
		#---------------------------------
		# �����ύX
		} elsif ($action eq 'up' || $action eq 'down') {
			$return_html = &lib'change_line($conf_log,$FORM{'conf_name'},$action);
			&lib'openfile($conf_log,*CF_LOG);
			goto LIST;
			
		#---------------------------------
		# �폜
		} elsif ($action eq 'delete') {
			&lib'change_log_line($conf_log,$FORM{'conf_name'});
			&lib'openfile($conf_log,*CF_LOG);
			goto LIST;
		}
	}

	return $return_html;
}


#-----------------------------------------------------------------------------0
#										�ݒ胊�X�g
#------------------------------------------------------------------��
sub conf_list {
	local($html) = @_;

	my @CUT = split(/<!-- CUT -->/,$html);
	my ($list,$n);
	foreach (@CF_LOG) {
		&get_log_field($_,*CF,@CF_DB);
		$n++;
		if ($CF{'conf_type'} eq 'title') {
			$dum = @CUT[1];
		} else {
			$dum = @CUT[2];
		}
		($CF{'conf_admin'}) && ($CF{'conf_admin'} = '���ъǗ���');
		(@CF_LOG[$n]) || ($dum =~ s/��//);
		$list .= &lib'change_key($dum,\@CF_DB,\%CF);
	}
	$list =~ s/��//;
	$html = "@CUT[0]$list@CUT[3]";
	
	return $html;
}

#-----------------------------------------------------------------------------2
#										�t�H�[���̏�����
#------------------------------------------------------------------��2007.10.01
sub init_form {
	local($html) = @_;
	
	my @CUT = split(/<!-- CUT -->/,$html);
	my ($list,$hidden,$error_msg);
	foreach (@CF_LOG) {
		&get_log_field($_,*CF,@CF_DB);
		### �ݒ茠��
		if (!$ACC{'user_authorize'} && $CF{'conf_admin'}) {
			$hidden .= qq|<INPUT type="hidden" name="$CF{'conf_name'}" value="$CF{'conf_value'}">\n|;
			next;
		}
		
		### �^�C�g��
		if ($CF{'conf_type'} eq 'title') {
			$dum = @CUT[1];
		
		### ��s�e�L�X�g
		} elsif ($CF{'conf_type'} eq 'text') {
			$dum = @CUT[2];
			
			
		### �����s
		} elsif ($CF{'conf_type'} eq 'textarea') {
			$dum = @CUT[3];
			$CF{'conf_value'} = &lib'unset_BR($CF{'conf_value'});
			
		### �`�F�b�N�{�b�N�X�E���W�I�{�^��
		} elsif ($CF{'conf_type'} eq 'checkbox' || $CF{'conf_type'} eq 'radio') {
			$dum = @CUT[4];
			my $sct;
			my @DATA = split(/,/,$CF{'conf_list'});
			my @VALUE = split(/,/,$CF{'conf_value'});
			foreach $d (@DATA) {
				my($value,$name) = split(/:/,$d);
				($name) || ($name = $value);
				(grep(/^\Q$value\E$/,@VALUE)) ? ($select = 'checked') : ($select = '');
				$sct .= qq|<INPUT type="$CF{'conf_type'}" name="#conf_name#" value="$value" $select> $name |;
			}
			$dum =~ s/#checkbox#/$sct/;
			
		### �Z���N�g�{�b�N�X
		} elsif ($CF{'conf_type'} eq 'select') {
			$dum = @CUT[5];
			my $sct;
			my @DATA = split(/,/,$CF{'conf_list'});
			foreach $d (@DATA) {
				my($value,$name) = split(/:/,$d);
				($name) || ($name = $value);
				($value eq $CF{'conf_value'}) ? ($select = 'selected') : ($select = '');
				$sct .= qq|<OPTION value="$value" $select> $name |;
			}
			$dum =~ s/<!-- select -->/$sct/;
			
		}
		if ($error_msg{"$CF{'conf_name'}"}) {
			$error_msg{"$CF{'conf_name'}"} =~ s/#NAME#/$CF{'conf_title'}/;
			$error_msg .= qq|<LI><A href="#$CF{'conf_name'}" class="A_red">$error_msg{"$CF{'conf_name'}"}</A>|;
		}
		$dum =~ s/<!-- ERROR -->/<A name="$CF{'conf_name'}"><\/A>$error_msg{"$CF{'conf_name'}"}/;
		$list .= &lib'change_key($dum,\@CF_DB,\%CF);
	}
	$html = "@CUT[0]$list@CUT[6]";
	$html =~ s/<!-- hidden -->/$hidden/;
	if ($error_msg) {
		$html =~ s/<!-- error_msg -->/$error_msg/;
	}
	return $html;
}


#-----------------------------------------------------------------------------0
#										�o�^
#------------------------------------------------------------------��
sub conf_regist {
	local($html) = @_;

	my $new_log = &lib'make_log_line(\@CF_DB,\%FORM);
	if ($FORM{'now_name'}) {
		&lib'change_log_line($conf_log,$FORM{'now_name'},$new_log);
	} else {
		&lib'stokfile($conf_log,$new_log);
	}
	
	$html =~ s/#title#/�ݒ�ύX���������܂����B/;
	$html =~ s/#msg#/���ݒ�̐ݒ�ύX���������܂����B/;
	$html =~ s/#html#/conf/;
	$html =~ s/#action#/list/;

	return $html;
}

#-----------------------------------------------------------------------------0
#										�ݒ胍�O�̏�������
#------------------------------------------------------------------��
sub conf_change {
	local($html) = @_;
	
	foreach (@CF_LOG) {
		&get_log_field($_,*CF,@CF_DB);
		my $value = $FORM{"$CF{'conf_name'}"};
		($value && $value eq $CF{'conf_value'}) && (next);
		
		### ���͒l�ϊ�
		if ($CF{'conf_convert'}) {
			my $conf_convert = $CF{'conf_convert'};
			$conf_convert =~ s/\0/:/g;
			$value = &form::ValueConvert($value, $conf_convert);
		}
		### �G���[���o
		if ($CF{'conf_restrict'}) {
			my $value2 = $value;
			&jcode::convert(\$value2, "euc", "sjis");
			my $euckey = $CF{'conf_name'};
			&jcode::convert(\$euckey, "euc", "sjis");
			$EucValues{"$euckey"} = $value2;
			my $conf_restrict = $CF{'conf_restrict'};
			$conf_restrict =~ s/\0/:/g;
			$g_msg = &form::InputRestrict($EucValues{"$euckey"},$conf_restrict);
			($g_msg) && ($error_msg{"$CF{'conf_name'}"} = $g_msg);
		}
		$CF{'conf_value'} = $value;
		s/.*\n/&lib'make_log_line(\@CF_DB,\%CF)/e;
	}
	if (%error_msg) {
		goto GO1;
		return;
	}
	&lib'writefile($conf_log,@CF_LOG);

	$html =~ s/#title#/�ݒ�ύX���������܂����B/;
	$html =~ s/#msg#/���ݒ�̐ݒ�ύX���������܂����B/;
	$html =~ s/#html#/conf/;
	$html =~ s/#action#//;

	return $html;
}

1;
