#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫memu.pl [Ver.2005.09.27] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：
#|┠──┨最終更新日：2005.09.27
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------1
#										メニューの作成
#------------------------------------------------------------------┤2005.09.27
sub subroutine {
	$title_bar = 'メニュー管理';
	&lib'openfile($menu_dat,*MN_DAT);
	
	#---------------------------------
	# メニューの表示
	if (!$action) {
		$html_header = $html{'header'};
		$html_footer = $html{'footer'};
		$html_title = '';
		$return_html = &show_menu($html{1});
	}

	#---------------------------------
	# システム管理者メニュー
	else {
		($ACC{'user_authorize'}) || (return);
		$title_bar .= '（システム管理者専用メニュー）';
		#---------------------------------
		# アクセス権限の変更
		if ($action eq 'setup') {
			$return_html = &menu_setup($html{2},$html_msgbox);
			
		#---------------------------------
		# メニューのカスタマイズ
		} elsif ($action eq 'custom') {LIST:
			$return_html = &menu_custom($html{3});
			
		#---------------------------------
		# 設定フォーム
		} elsif ($action eq 'form') {
			$return_html = &menu_form($html{4});
			
		#---------------------------------
		# 設定
		} elsif ($action eq 'regist') {
			$return_html = &menu_regist($html_msgbox);
			
		#---------------------------------
		# 削除
		} elsif ($action eq 'delete') {
			&lib'change_log_line($menu_dat,$FORM{'code'});
			&lib'openfile($menu_dat,*MN_DAT);
			goto LIST;
			
		#---------------------------------
		# 順序変更
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
#										メニューの表示
#------------------------------------------------------------------┤
sub show_menu {
	local($html) = @_;
	### 初期設定環境
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
#										アクセス権限の変更
#------------------------------------------------------------------┤2005.09.27
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
		$html2 =~ s/#title#/変更が完了しました/;
		$html2 =~ s/#msg#/管理メニューのアクセス権限の変更が完了しました。/;
		$html2 =~ s/#html#/menu/;
		$html2 =~ s/#action#/setup/;
		return $html2;
	}
	return $html;
}

#-----------------------------------------------------------------------------1
#										メニューのカスタマイズ
#------------------------------------------------------------------┤2005.09.27
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
		($flag) ? ($dum =~ s/#flag#/ｼｽﾃﾑ管理者/) : ($dum =~ s/#flag#//);
		(@MN_DAT[$n]) || ($dum =~ s/↓//);
		$list .= $dum;
	}
	$list =~ s/↑//;
	$html = "@CUT[0]$list@CUT[3]";
	
	return $html;
}

#-----------------------------------------------------------------------------0
#										メニューフォーム
#------------------------------------------------------------------┤
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
#										設定
#------------------------------------------------------------------┤
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
	
	$html =~ s/#title#/設定が完了しました。/g;
	$html =~ s/#msg#/メニューの設定が完了しました。/g;
	$html =~ s/#html#/menu/g;
	$html =~ s/#action#/setup/;
	
	return $html;
}


1;
