#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫account.pl [Ver.2005.09.12] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：
#|┠──┨最終更新日：2005.09.12
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


#-----------------------------------------------------------------------------0
#										アカウントの設定
#------------------------------------------------------------------┤
sub subroutine {
	$title_bar = 'アカウントの設定';

	#----------------------------------------
	# 初期設定
	if ($FORM{'route'} eq 'new') {SET:
		$return_html = &form_initialize($html{4},@AC_DB);

	#----------------------------------------
	# トップ
	} elsif (!$action) {TOP:
		# 初期設定
		if (!@AC_LOG) {
			goto SET;
		# システム管理者
		} elsif ($ACC{'user_authorize'}) {
			$return_html = &account_list($html{2});
		# HP管理者
		} else {
			%FORM = %ACC;
			$return_html = &account_form($html{1});
		}

	#----------------------------------------
	# 新規
	} elsif ($action eq 'new') {NEW:
		$return_html = &account_form($html{3});

	#----------------------------------------
	# 登録実行
	} elsif ($action eq 'new_regist' || $action eq 'set') {
		$return_html = &new_account($html_msgbox);

	#----------------------------------------
	# 修正
	} elsif ($action eq 'edit') {
		my $log = &lib'get_log_line($FORM{'user_name'},@AC_LOG);
		&get_log_field($log,*FORM,@AC_DB);EDIT:
		$return_html = &account_form($html{1});

	#----------------------------------------
	# 修正実行
	} elsif ($action eq 'change') {
		$return_html = &account_edit($html_msgbox);
		
	#----------------------------------------
	# 削除
	} elsif ($action eq 'delete') {
		&lib'change_log_line($account_log,$FORM{'user_name'});
		&lib'openfile($account_log,*AC_LOG);
		goto TOP;
	}

	return $return_html;
}


#-----------------------------------------------------------------------------0
#										初期設定
#------------------------------------------------------------------┤
sub new_account {
	local($html) = @_;
	### 重複確認
	foreach (@AC_LOG) {
		&get_log_field($_,*AC,@AC_DB);
		if ($AC{'user_name'} eq $FORM{'user_name'}) {
			$error_msg{'user_name'} = 'このユーザー名はすでに利用されています。<BR>';
		}
		if ($AC{'user_email'} eq $FORM{'user_email'}) {
			$error_msg{'user_email'} = 'このE-Mailはすでに利用されています。<BR>';
		}
	}

	### パスワード
	if (!$FORM{'user_pass'}) {
		$error_msg{'user_pass'} = 'パスワードは省略できません。<BR>';
	} elsif ($FORM{'user_pass'} ne $FORM{'user_pass2'}) {
		$error_msg{'user_pass'} = 'パスワードが一致しません。<BR>';
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
		$html =~ s/#title#/登録が完了しました。/;
		$html =~ s/#msg#/新規アカウントの登録が完了しました。/;
		$html =~ s/#html#/account/;
		$html =~ s/#action#//;
	} elsif ($action eq 'set') {
		### クッキーのセット
		my $c_value = "n:$FORM{'user_name'},p:$FORM{'user_pass'},t:$time";
		&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
		&login_record('login','アカウント作成',$FORM{'user_name'});
		
		$html =~ s/#title#/設定が完了しました。/;
		$html =~ s/#msg#/システム管理者のアカウント登録が完了しました。続いてシステムの環境設定を行ないます。/;
		$html =~ s/#html#/conf/;
		$html =~ s/#action#//;
		$html =~ s/戻る/環境設定へ/;
	}

	return $html;
}


#-----------------------------------------------------------------------------0
#										修正
#------------------------------------------------------------------┤
sub account_edit {
	local($html) = @_;

	### パスワード
	if ($FORM{'user_pass'} && $FORM{'user_pass'} ne $FORM{'user_pass2'}) {
		$error_msg{'user_pass'} = 'パスワードが一致しません。<BR>';
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
	
	### クッキーのセット
	if ($ACC{'user_name'} eq $FORM{'user_name'}) {
		my $c_value = "n:$FORM{'user_name'},p:$FORM{'user_pass'},t:$time";
		&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
	}

	$html =~ s/#title#/修正が完了しました。/;
	$html =~ s/#msg#/ユーザー名「$FORM{'user_name'}」のアカウントの修正が完了しました。/;
	$html =~ s/#html#/account/;
	$html =~ s/#action#//;

	return $html;
}


#-----------------------------------------------------------------------------1
#										システム管理者
#------------------------------------------------------------------┤2005.09.12
sub account_list {
	local($html) = @_;

	my @CUT = split(/<!-- CUT -->/,$html);
	my $list;
	foreach (@AC_LOG) {
		&get_log_field($_,*AC,@AC_DB);
		my $dum = @CUT[1];
		if ($AC{'user_authorize'}) {
			$AC{'user_authorize'} = 'ｼｽﾃﾑ管理者';
			$dum =~ s/cell1"/cell2"/g;
		} else {
			$AC{'user_authorize'} = 'HP管理者';
		}
		($ACC{'user_name'} eq $AC{'user_name'}) && ($dum =~ s/削除//g);
		$list .= &lib'change_key($dum,\@AC_DB,\%AC);
	}
	$html = "@CUT[0]$list@CUT[2]";
	
	return $html;
}


#-----------------------------------------------------------------------------0
#										HP管理者
#------------------------------------------------------------------┤
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
