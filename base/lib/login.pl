#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫login.pl [Ver.2005.09.05] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：
#|┠──┨最終更新日：2005.09.05
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------0
#										ログイン
#------------------------------------------------------------------┤2005.09.05
sub subroutine {
	$title_bar = 'ログイン';

	#-----------------------------------------
	# ログインフォーム
	if (!$action) {LOGIN:
		$return_html = $html{1};
		my $width = $conf{'l_width'} + $conf{'r_width'};
		($width < 300) && ($width = '100%');
		$html_header =~ s/width="600"/width="$width"/g;
	
	#-----------------------------------------
	# ログイン実行
	} elsif ($action eq 'login') {
		&login_exe;
		$html{1} =~ s/<!-- ERROR -->/　ログインできませんでした。<BR>　ユーザー名、またはパスワードをご確認ください。/;
		goto LOGIN;
		
	#-----------------------------------------
	# ログアウト
	} elsif ($action eq 'logout') {
		&logout_exe;
		
	#-----------------------------------------
	# ログイン履歴
	} elsif ($action eq 'check') {
		$title_bar = 'ログイン履歴';
		$return_html = &access_check($html{2});
	}

	$return_html =~ s/#user_name#/$FORM{'user_name'}/g;
	$return_html =~ s/#target#/$conf{'target'}/g;
	return $return_html;

}

#-----------------------------------------------------------------------------0
#										ログイン
#------------------------------------------------------------------┤
sub login_exe {
	(!$FORM{'user_name'} && !$FORM{'user_pass'}) && (goto LOGIN);

	my $x_pass = crypt($FORM{'user_pass'},"$crypt_key");
	if (-e "$LogDir/cpsu") {
		local(@su);
		&lib'openfile("$LogDir/cpsu",*su);
		if ($x_pass eq @su[0]) {
			&cookie'set_cookie($cookie_name,"n:$x_pass,su:1");
			print"Location: ./admin.cgi\n\n";
			exit;
		}
	}
	foreach (@AC_LOG) {
		&get_log_field($_,*AC,@AC_DB);
		if ($AC{'user_name'} eq $FORM{'user_name'} && $AC{'user_pass'} eq $x_pass) {
			my $c_value = "n:$AC{'user_name'},p:$AC{'user_pass'},t:$time";
			&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
			&login_record($action,'ログイン成功',$AC{'user_name'});
			print"Location: ./admin.cgi\n\n";
			exit;
		}
	}
	&login_record($action,'ログイン失敗',$FORM{'user_name'});

}


#-----------------------------------------------------------------------------0
#										ログアウト
#------------------------------------------------------------------┤2005.09.05
sub logout_exe {
	&cookie'get_cookie($cookie_name);
	if ($cookie'COOKIE{'su'}) {
		unlink "$LogDir/cpsu";
	} else {
		&login_record($action,'ログアウト',$cookie'COOKIE{'n'});
	}
	&cookie'logout($cookie_name);
	print"Location: ./admin.cgi?html=login\n\n";
	exit;
}


#-----------------------------------------------------------------------------0
#										アクセス記録照会
#------------------------------------------------------------------┤
sub access_check {
	local($html) = @_;
	local @HIT;
	($FORM{'log'}) || ($FORM{'log'} = 'access');
	&lib'openfile($login_log,*LI_LOG);
	&lib'openfile($login_db,*LI_DB);
	
	@LI_LOG = reverse @LI_LOG;
	foreach (@LI_LOG) {
		(/^$FORM{'log'}\t/) && (push @HIT,$_);
	}
	my $link_cgi = "admin.cgi?html=login&action=check&log=$FORM{'log'}";
	@HIT = &cut_data($link_cgi,$alog_scale,@HIT);

	my @CUT = split(/<!-- CUT -->/,$html);
	### ヘッダー作成
	if ($FORM{'log'} eq 'access') {
		@CUT[0] =~ s/color1/color3/;
		@CUT[0] =~ s/color1/color5/;
		@CUT[0] =~ s/color1/color5/;
	} elsif ($FORM{'log'} eq 'login') {
		@CUT[0] =~ s/color1/color5/;
		@CUT[0] =~ s/color1/color3/;
		@CUT[0] =~ s/color1/color5/;
	} elsif ($FORM{'log'} eq 'logout') {
		@CUT[0] =~ s/color1/color5/;
		@CUT[0] =~ s/color1/color5/;
		@CUT[0] =~ s/color1/color3/;
	}
	@CUT[0] =~ s/#page_link#/$pagelink/g;

	my $list;
	foreach (@HIT) {
		&get_log_field($_,*LI,@LI_DB);
		$list .= &lib'change_key(@CUT[1],\@LI_DB,\%LI,'3-3F:-');
	}
	$html = "@CUT[0]$list@CUT[2]";

	return $html;
}



1;



