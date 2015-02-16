#!/usr/bin/perl -w

#|================#
#| プログラム情報 #
#|================#------------------------------------------#
#|                                                           #
#|    CGI-Park 名人シリーズ                                  #
#|    ○○名人 Ver 1.0.0                                     #
#|    Produced by [MilleniaNet] Yuma Suda                    #
#|    admin.cgi [Ver.2007.12.05]　                           #
#|                                                           #
#|    制作開始日：2005.01.15 　                              #
#|    前回更新日：2006.04.19  　                             #
#|    最終更新日：2007.12.05  　                             #
#|                                                           #
#|    URL:http://www.cgi-park.com/                           #
#|    E-Mail:support@cgi-park.com                            #
#|                                                           #
#|-----------------------------------------------------------#

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					ライブラリの取得
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 変数ライブラリのパス
require "folder.pl";

# 変数ライブラリのパス
require "conf.pl";

# サブルーティンライブラリのパス
require "$LibDir/cgi-sub.pl";

# 文字コード変換ライブラリのパス
require "$LibDir/jcode.pl";

# CGIライブラリのパス
require "$LibDir/cgi-lib.pl";

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					初期設定
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$fckey{'zz'} = 's000';

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					メイン処理
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
eval{
&ReadParse(*FORM);

&initialize;
&authentication;
&lcs;
$html_body = &subroutine;
};
&print_html;

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------1
#										初期化処理
#------------------------------------------------------------------┤2005.09.03
sub initialize {
	$html = $FORM{'html'};
	$action = $FORM{'action'};
	($html) || ($html = "admin");

	if (-e "$LibDir/$html.pl") {
		require "$LibDir/$html.pl";
	} elsif ($CoLibDir && -e "$CoLibDir/$html.pl") {
		require "$CoLibDir/$html.pl";
	}

	### HTMLファイルの読み込み
	&lib'get_html($main_html, *m_html);
	$html_header = $m_html{'header'};
	$html_footer = $m_html{'footer'};
	$html_title = $m_html{'1'};
	$html_error = $m_html{'2'};
	$html_msgbox = $m_html{'3'};
	if (-e "$HtmlDir/$html.htm") {
		&lib'get_html("$HtmlDir/$html.htm", *html);
	} elsif ($CoHtmlDir && -e "$CoHtmlDir/$html.htm") {
		&lib'get_html("$CoHtmlDir/$html.htm", *html);
	}

	### アカウントの読み込み
	&lib'openfile($account_log,*AC_LOG);
	&lib'openfile($account_db,*AC_DB);
	if (!@AC_LOG && $html ne 'account' && $html ne 'help' && $html ne 'admin' && $html ne 'menu') {
		print "Location: ./admin.cgi?html=account&route=new\n\n";
		exit;
	}

	### 設定ファイルの読み込み
	(-e "$conf_log") || (&init_log_ext);
	&lib'openfile($conf_log,*CF_LOG);
	foreach (@CF_LOG) {
		my($name,$value) = split(/\t/);
		$conf{$name} = $value;
	}

}


#-----------------------------------------------------------------------------1
#										アクセス認証
#------------------------------------------------------------------┤2005.09.05
sub authentication {
	### プログラム情報の照会
	if ($fckey{"$apa"} ne $fckey) {
		&lib'system_error('er401','設定が不正なため管理画面へのアクセスが拒否されました。');
	}
	### ライセンス情報
	if ($lc1) {
		$lcs = $lc1;
	} elsif ($au eq "$fckey\meijin") {
	} else {
		$lcs = 'admin';
	}
	(@AC_LOG) || (return);
	if ($html eq 'admin' && $FORM{'c'} eq 'no') {return}
	### 外部アクセス認証
	if ($conf{'ex_access'} eq 'no' && !$FORM{'ex_access'}) {
		unless ($ENV{'HTTP_REFERER'} =~ /$ENV{'HTTP_HOST'}/) {
			print"Location: $conf{'hp_url'}\n\n";
			exit;
		}
	}
	unless ($html eq 'login' || $lcs eq 'admin') {
		&cookie'get_cookie($cookie_name);
		my $c_name = $cookie'COOKIE{'n'};
		my $c_pass = $cookie'COOKIE{'p'};
		my $c_time = $cookie'COOKIE{'t'};
		if ($c_name) {
			if ($cookie'COOKIE{'su'}) {
				$ACC{'user_authorize'} = '1';
				return;
			}
			foreach (@AC_LOG) {
				&get_log_field($_,*ACC,@AC_DB);
				if ($c_name eq $ACC{'user_name'} && $c_pass eq $ACC{'user_pass'}) {
					my $check_time = $time - 60*60*6;
					if ($c_time < $check_time) {
						my $c_value = "n:$ACC{'user_name'},p:$ACC{'user_pass'},t:$time";
						&cookie'set_cookie($cookie_name,$c_value,$conf{'cookie_time'});
						&login_record('access','アクセス',$ACC{'user_name'});
					}
					return;
				}
			}
		}
		print"Location: ./admin.cgi?html=login\n\n";
		exit;
	}
}


#-----------------------------------------------------------------------------2
#										出力
#------------------------------------------------------------------┤2007.12.05
sub print_html {
	### エラー確認
	if ($@) {
		&lib'system_error('eval',"$@");
	}
	
	### ヘッダー
	$html_header = &make_title_bar("$html_header$html_title",$title_bar);
	$print_html = "$html_header$html_body$html_footer";

	### イメージフォルダの移動
	if ($ImageDir ne '../image') {
		$print_html =~ s/"..\/image/"$ImageDir/g;
	}
	
	### システム名称
	($conf{'cgi_title'}) || ($conf{'cgi_title'} = $mjnm);
	$print_html =~ s/#meijin_name#/$conf{'cgi_title'}/g;
	($site_link) || (die);
	print "Content-type: text/html\n\n";
	print $print_html;
}


#-----------------------------------------------------------------------------1
#										タイトルの作成
#------------------------------------------------------------------┤2007.12.05
sub make_title_bar {
	local($html,$title_bar) = @_;
	### ヘッダー
	if ($conf{'r_width'}) {
		$html =~ s/width="600"/width="$conf{'r_width'}"/g;
	}
	$html =~ s/<title>([^<]*)<\/title>/<TITLE>$title_bar<\/TITLE>/i;
	
	$html =~ s/#title#/$title_bar/g;

	### ホームページLink
	if ($lc2) {
		$html =~ s/#hp_name#/$lc2/g;
		$html =~ s/#homepage#/$lc3/g;
	} else {
		$html =~ s/#hp_name#/CGI-Park/g;
		$html =~ s/#homepage#/$cphp/g;
	}

	$html =~ s/#target#/$conf{'target'}/g;
	return $html;
}


#-----------------------------------------------------------------------------1
#										アクセス記録
#------------------------------------------------------------------┤2005.09.05
sub login_record {
	local($action,$status,$name,$email) = @_;
	local(%LOG,%LG_DB);
	($cookie'COOKIE{'su'}) && (return);
	&lib'openfile($login_db,*LG_DB);
	
	($LOG{'log_host'}) = &lib'get_ip;
	$LOG{'log_time'} = $time;
	$LOG{'log_action'} = $action;
	$LOG{'log_status'} = $status;
	$LOG{'log_name'} = $name;
	$LOG{'log_email'} = $email;
	my $log = &lib'make_log_line(\@LG_DB,\%LOG);
	&lib'stokfile($login_log,$log);

}


#-----------------------------------------------------------------------------0
#										ログ拡張子の初期設定
#------------------------------------------------------------------┤
sub init_log_ext {
	if ($log_ext eq 'htm' || $log_ext eq 'db' || $log_ext eq 'mail') {
		&lib'system_error('er107','ログファイルの拡張子の設定が不正です。「$log_ext」は利用出来ません。');
	}
	
	&lib'opendir($LogDir,*DIR);
	my $now_ext;
	foreach (@DIR) {
		my($name,$ext) = split(/\./);
		if ($name eq 'conf') {
			$now_ext = $ext;
			last;
		}
	}
	foreach (@DIR) {
		my($name,$ext) = split(/\./);
		if ($ext eq $now_ext) {
			my $new_name = "$name\.$log_ext";
			rename "$LogDir/$_","$LogDir/$new_name";
		}
	}

}


