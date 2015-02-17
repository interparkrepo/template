#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫cgi-sub.pl [Ver.2008.03.28] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：2006.07.19
#|┠──┨最終更新日：2008.03.28
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------0
#										フォームデータの取得
#------------------------------------------------------------------┤
sub get_form_data_field {
	local($line) = @_;
	chop $line;
	($f_name,$f_title,$f_type,$f_length,$f_restrict,$f_convert,$f_etc,$f_list) = split(/\t/,$line);
}


#-----------------------------------------------------------------------------0
#										ログファイルの取得
#------------------------------------------------------------------┤
sub get_log_field {
	local($line,*buf,@FORM) = @_;
	@LINE = split(/\t/,$line);
	foreach (@FORM) {
		&get_form_data_field($_);
		$buf{"$f_name"} = shift @LINE;
	}
	(%buf) ? return(1) : return(0);
}


#-----------------------------------------------------------------------------0
#										ソート処理
#------------------------------------------------------------------┤
sub by_num {
	local(@a) = split (/\t/, $a);
	local(@b) = split (/\t/, $b);
	($b["$sort_flag"] <=> $a["$sort_flag"]) || ($b[0] <=> $a[0]);
}
sub by_cmp {
	local(@a) = split (/\t/, $a);
	local(@b) = split (/\t/, $b);
	($a["$sort_flag"] cmp $b["$sort_flag"]) || ($a[0] cmp $b[0]);
}


#-----------------------------------------------------------------------------3
#										フォームに値を代入
#------------------------------------------------------------------┤2006.07.19
sub form_initialize {
  local($html,@F_DATA) = @_;
	my($hidden);

	foreach (@F_DATA) {
	  &get_form_data_field($_);
		### HIDDENの設定
		if ($f_type eq 'hidden' || $f_type =~ /^time$/i || $f_type eq  'SERIAL') {
			$hidden .= qq|<INPUT type="hidden" name="$f_name" value=\"$FORM{"$f_name"}\">\n|;
		}
		### 複数行テキストボックス
		if ($f_type eq 'textarea') {
			$FORM{"$f_name"} = &lib'unset_BR($FORM{"$f_name"});
			
		### セレクトボックス
		} elsif ($f_type eq 'select') {
			if ($html =~ /<!-- $f_name -->/) {
				if ($sct{"$f_name"}) {
					$html =~ s/<!-- $f_name -->/$sct{"$f_name"}/g;
				} else {
					my ($select,%sct);
					my @DATA = split(/,/,$f_list);
					foreach $d (@DATA) {
						my($value,$name) = split(/:/,$d);
						($name) || ($name = $value);
						my $select;
						($value eq $FORM{"$f_name"}) ? ($select = 'selected') : ($select = '');
						$sct{"$f_name"} .= qq|<OPTION value="$value" $select> $name |;
					}
					$html =~ s/<!-- $f_name -->/$sct{"$f_name"}/g;
				}
			} else {
				my $value = $FORM{"$f_name"};
				&jcode::convert(\$html, 'euc', 'sjis');
				&jcode::convert(\$value, 'euc', 'sjis');
				$html =~ s/#$f_name$value#/selected/;
				&jcode::convert(\$html, 'sjis', 'euc');
			}
			
		### タイムスタンプ
		} elsif ($f_type =~ /time/i) {
		  ($FORM{$f_name}) ? ($html =~ s/#D-$f_name#/&lib'get_time($FORM{$f_name},$time_key)/ge) :($html =~ s/#D-$f_name#//g);

		### ラジオボタン・チェックボックス
		} elsif ($f_type eq 'radio' || $f_type eq 'checkbox') {
			if ($html =~ /<!-- $f_name -->/) {
				my ($select,%sct);
				my @DATA = split(/,/,$f_list);
				$FORM{$f_name} =~ s/&nul;/\0/g;
				my @VALUE = split(/\0/,$FORM{$f_name});
				foreach $d (@DATA) {
					my($value,$name) = split(/:/,$d);
					($name) || ($name = $value);
					my $select;
					if ($f_type eq 'radio') {
						($value eq $FORM{"$f_name"}) ? ($select = 'checked') : ($select = '');
					} else {
						(grep(/^$value$/,@VALUE)) ? ($select = 'checked') : ($select = '');
					}
					$sct{"$f_name"} .= qq|<INPUT type="$f_type" name="$f_name" value="$value" id="$f_name$value" $select> <LABEL for="$f_name$value">$name</LABEL> |;
				}
				$html =~ s/<!-- $f_name -->/$sct{"$f_name"}/g;
			} else {
				my $value = $FORM{"$f_name"};
				&jcode::convert(\$html, 'euc', 'sjis');
				&jcode::convert(\$value, 'euc', 'sjis');
				if ($f_type eq 'checkbox') {
					$value =~ s/&nul;/\0/g;
					my @VALUE = split(/\0/,$value);
					foreach $vl (@VALUE) {
						$html =~ s/#$f_name$vl#/checked/;
					}
				} else {
					$html =~ s/#$f_name$value#/checked/;
				}
				&jcode::convert(\$html, 'sjis', 'euc');
			}
		}
		### リストの値を表示
		if ($f_list && $html =~ /#N-$f_name#/) {
			my @LIST = split(/,/,$f_list);
			foreach $lst (@LIST) {
				my($value,$name) = split(/\:/,$lst);
				if ($FORM{$f_name} eq $value) {
					$html =~ s/#N-$f_name#/$name/g;
					last;
				}
			}
			$html =~ s/#N-$f_name#//g;
		}
		($error_msg{"$f_name"}) && ($error_msg{"$f_name"} =~ s/#NAME#/$f_title/);
		$html =~ s/<!-- ER_$f_name -->/<A name="$f_name"><\/A>$error_msg{"$f_name"}/;
		$FORM{"$f_name"} =~ s/&/&amp;/g;
		$FORM{"$f_name"} =~ s/"/&quot;/g;
		$html =~ s/#$f_name#/$FORM{"$f_name"}/g;
	}
	$html =~ s/<!-- hidden -->/$hidden/;
	$html =~ s/<!-- HIDDEN -->/$hidden/g;
	
	return $html;
}



#-----------------------------------------------------------------------------0
#										入力チェック
#------------------------------------------------------------------┤
sub check_form_data {
	local(@FORM) = @_;
	
	foreach (@FORM) {
		&get_form_data_field($_);
		$value = $FORM{"$f_name"};
		($f_convert) && ($value = &form::ValueConvert($value, $f_convert));

		$value_len = length($value);
		if ($value_len > $f_length && $f_length && $lenFlag ne 'ng') {
			if ($f_type eq 'file') {
				$error_msg{"$f_name"} = "ファイルサイズがオーバーしています。$f_length byte以下にしてください。<BR>";
			} else {
				$len2 = $f_length / 2;
				$error_msg{"$f_name"} = "文字サイズがオーバーしています。半角の場合は$f_length文字(全角で$len2文字)以内にしてください。<BR>";
			}
		}
		($f_type eq 'file') && (next);		### アップロードの場合ここで終了
		$value =~ s/ $//;
		&jcode::convert(\$value, "euc", "sjis");
		my $euckey = $f_name;
		&jcode::convert(\$euckey, "euc", "sjis");
		$EucValues{"$euckey"} = $value;
		
		$g_msg = &form::InputRestrict($EucValues{"$euckey"},$f_restrict);
		($g_msg) && ($error_msg{"$f_name"} = $g_msg);
		&jcode::convert(\$EucValues{"$euckey"}, "sjis", "euc");
		$FORM{"$f_name"} = $EucValues{$euckey};
	}
}


#-----------------------------------------------------------------------------0
#										データの切り取り
#------------------------------------------------------------------┤
sub cut_data{
	# 表示順序の指定
	local($linkcgi,$show_scale,@logbuf) = @_;
#	local($logline);
	$p = $FORM{'p'};
	$logline = @logbuf;
	($show_scale) || ($show_scale = $logline);
	($show_scale) || (return);

	$p = int($p);
	$allpage = int(($logline-1) / $show_scale) + 1;
	($p > 0) && ($p <= $allpage) || ($p = 1);
	
	# 表示範囲の特定
	$t = $p * $show_scale;
	$f = $t - $show_scale + 1;
	$logno = $f;
	($t < $logline) ? ($next = $p + 1) : ($t = $logline);
	($f > 1) && ($prev = $p - 1);
	
	# 前後を切り取る
	unshift(@logbuf, "dmy");
	@logbuf= splice(@logbuf, $f, $show_scale);

	# 前後へのリンク
	if ($allpage < 20) {
		$pagelink = "全$logline件　【No.$f ～ No.$t】";
		$pagelink .= " ／ ";
		($prev) && ($pagelink .= "<A HREF=\"$linkcgi&p=$prev\">前の$show_scale件</A> ／ ");
		for(1 .. $allpage){
			$pagelink .= ($_ == $p) ? "<B>$_</B> " : "<A HREF=\"$linkcgi&p=$_\">$_</A> ";
		}
		($next) && ($pagelink .= "／ <A HREF=\"$linkcgi&p=$next\">次の$show_scale件</A>");
	} else {
		$pagelink = "全$logline件　【No.$f ～ No.$t】　";
		($prev) && ($pagelink .= "<A HREF=\"$linkcgi&p=$prev\">前の$show_scale件</A>　|　");
		($next) && ($pagelink .= "<A HREF=\"$linkcgi&p=$next\">次の$show_scale件</A>");
		$pagelink .= "　[<B>$p/$allpage</B>]";
	}
	
	return(@logbuf);
}

#-----------------------------------------------------------------------------1
#										ライセンス確認
#------------------------------------------------------------------┤2005.10.10
sub lcs {
	local($erflag,$p,$gap);
	$site_link = $cgi_park;
	if ($lcs =~ /^L/) {
		my $length1 = length "$lc2";
		my $length2 = length "$lc3";
		my $length3 = $length1 * $length2 * 7;
		$length3 = substr($length3,0,3);
		my $length = sprintf("%03d",$length3);
		my $make_lc = "L$fckey$length";
		my($a,$b,$c) = split(/-/,$lc1);
		$c .= $b;
		$b = length $c;
		($a eq $make_lc) || ($erflag = 1);
		($b eq 8) || ($erflag = 2);
		($c =~ /[0-9]/) || ($erflag = 3);
		($erflag) && (&lib'system_error("er101-$erflag",'ライセンス情報が不正なため、管理画面へのアクセスが拒否されました。'));
		$site_link = qq|<DIV align="center" class="font14B"><A href="$lc3" target="_blank" class="A2_purple">- $lc2 -</A></DIV>|;
	} elsif ($lcs eq 'admin') {
	} elsif ($au eq "$fckey\meijin") {
	} else {
		chomp $lcs;
		$gap = substr $lcs,0,2;
		$gtime = substr $lcs,2;
		my $apa2 = $apa;
		foreach (0..10) {$p += substr $gtime,$_,1;}
		foreach (0..$p) {
			if ($apa2 eq 'zz') {$apa2 = 'aa';next;}
			$apa2++;
		}
		($apa2 eq $gap) || ($erflag = 4);
		$gtime = reverse $gtime;
		($gtime - $time > 2678400) && ($erflag = 5);
		if ($gtime < $time && $action ne 'lcs_form' && $action ne 'license') {
			print"Location: ./admin.cgi?html=admin&action=lcs_form&c=no\n\n";
			exit;
		}
		if ($action ne 'lcs_form' && $action ne 'license') {
			$tl_date = &lib'get_time($gtime,'3-0W');
			my $lcs_link =<<EOF;
			<TABLE border="0" width="600" height="20" bgcolor="#cc0000" class="white">
			    <TR>
			      <TD class="font14">試\用期間: <B>$tl_date<\/B> まで。ライセンス登録は<A href=".\/admin.cgi?html=admin&action=lcs_form" target="$conf{'target'}">こちら<\/A></TD>
			    </TR>
			</TABLE>
EOF
			$html_header =~ s/<!-- lcs_link -->/$lcs_link/;
		}
	}
	($erflag) && (&lib'system_error("er201-$erflag",'ライセンス情報が不正なため、管理画面へのアクセスが拒否されました。'));
	if ($html ne 'menu') {
		($html_footer =~ /<HR class="black" size="1">/) || (&lib'system_error("er301",'処理を実行できません。'));
		$html_footer =~ s/<HR class="black" size="1">/<HR size="1">$site_link/;
	}
	return 1;
}


$cgi_park = qq|<DIV align="center" class="font14B"><A href="$cphp" target="_blank" class="A2_purple">- CGI\-Park -</A></DIV>|;
package lib;

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------
#  Digest::SHA-1 (hex) 
#-----------------------------------------------------------
sub endecrypt {
    # 暗号Key
	use constant CRYPT_KEY => 'ys';
    # ダイジェストモジュールKey
    use constant DIGEST_SHA1 => 'Digest/SHA1.pm';

    # ダイジェストフラグ
	my $digest = 0;
    foreach my $key(keys(%INC)){
        # SHA1モジュールがインストールされている場合
        if($key eq DIGEST_SHA1) {
	        # モジュール宣言
	        use Digest::SHA1 qw(sha1_hex);
	        $digest = 1;
	        last;
        }
    }
    my ($pass, $crypt) = @_;
    # 暗号化の場合
    if(!defined($crypt)) {
        # SHA-1関数を使用
        if($digest == 1) {
            return CRYPT_KEY . sha1_hex(CRYPT_KEY . $pass);
        # 標準のcrypt関数を使用
        } else {
            return crypt($pass,CRYPT_KEY);
        }
    # 複合化の場合
    } else {
        # saltは先頭の2文字（CRYPT_KEY）を抜き出す
        my $salt = substr($crypt, 0, length(CRYPT_KEY));

        # SHA-1関数を使用
        if($digest == 1) {
            # 照合
            return $crypt eq ($salt . sha1_hex($salt . $pass)) ? 1 : 0;
        # 標準のcrypt関数を使用
        } else {
            return $crypt eq (crypt($pass,$salt)) ? 1 : 0;
        }
    }
}


#-----------------------------------------------------------------------------0
#										パスワードの暗号化・照合 Digest::SHA-1 (hex)
#------------------------------------------------------------------┤
# my $shaPw = &lib'crypt($passwd);	# 暗号化
# my $ret = &lib'crypt($passwd, $shaPw);	# 照合
sub crypt {
	my($passwd,$shaPw) = @_;
	eval "use Digest::SHA1 qw(sha1_hex)";
	
	my $type = 'sha1';
	($@) && ($type = 'crypt');
	
	#---------------------------
	# 暗号化
	if (!$shaPw) {
		my @str = ('a' .. 'f', 0 .. 9);
		my $salt; 
		for (1 .. 4) { 
			$salt .= $str[int(rand(@str))]; 
		}
    # SHA-1関数を使用
		if ($type eq 'sha1') {
			return $salt . sha1_hex($salt . $passwd);
			
    # 標準のcrypt関数を使用
		} else {
			return crypt($passwd, $salt);
		}
		
	#---------------------------
	# 照合
	} else {
		my $salt = substr($shaPw, 0, 4);

    # SHA-1関数を使用
		if ($type eq 'sha1') {
			return $shaPw eq ($salt . sha1_hex($salt . $passwd)) ? 1 : 0;
			
    # 標準のcrypt関数を使用
		} else {
			return $shaPw eq (crypt($passwd, $salt)) ? 1 : 0;
		}
	}
}


#-----------------------------------------------------------------------------0
#										ファイルを開いて、中身を配列に代入する
#------------------------------------------------------------------┤
sub openfile{
	local($filename, *buf) = @_;
	
	($filename) || &system_error("er102",'ファイル変数が見つかりませんでした。',"lib::openfile処理エラー。ファイル名不明。");
	(-e $filename) || return(0);
	
	open(FILE, "$filename") || &system_error("er202",'パーミッションエラー',"「$filename」のパーミッションを確認してください。");
	flock(FILE, 1) or &system_error("er302",'アクセスが混雑しています。しばらくしてからやり直してください。');
	@buf = <FILE>;
	close(FILE);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										ファイルにデータを書き換える
#------------------------------------------------------------------┤
sub writefile {
	local($logfile,@buf) = @_;
	(-e $logfile) || &lib'makefile($logfile);
	chmod 0666,$logfile;
	
	open(FILE, "+<$logfile") or &system_error("er106",'ファイルの書き換えに失敗しました。',"「$logfile」の書き換えに失敗しました。フォルダまたはパーミッションを確認してください。");
	flock(FILE, 2) or &system_error("er206",'アクセスが混雑しています。しばらくしてからやり直してください。');
	seek(FILE, 0, 0);
	print FILE @buf;
	truncate(FILE, tell(FILE));
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										ファイルにデータを追加する(ストック)
#------------------------------------------------------------------┤
sub stokfile {
	local($logfile,$buf) = @_;
	chmod 0666,$logfile;

	if (!open (FILE, ">>$logfile")) {&system_error("er105",'追記エラー',"「$logfile」の追記に失敗しました。");}
	flock(FILE, 2) or &system_error("er205",'アクセスが混雑しています。しばらくしてからやり直してください。');
	seek(FILE, 0, 2);
	print FILE $buf;
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										ファイルの作成
#------------------------------------------------------------------┤
sub makefile{
	local($filename) = @_;
	($filename) || &system_error("er103",'ファイル変数が見つかりませんでした。','lib::makefile処理エラー。ファイル名不明。');

	open(FILE, ">$filename") || &system_error("er203",'ファイル作成エラー',"「$filename」を作成することが出来ませんでした。フォルダまたはパーミッションを確認してください。");
	close(FILE);
	chmod 0666,$filename;
}

#-----------------------------------------------------------------------------0
#										フォルダを開いて、中身を配列に代入する
#------------------------------------------------------------------┤
sub opendir{
	local($dir, *buf) = @_;
	
	(-e $dir) || &system_error("er104",'フォルダ変数が見つかりませんでした。','lib::opendir処理エラー。フォルダ名不明。');
	opendir (DIR, "$dir") || &system_error("er204",'フォルダオープンエラー',"「$dir」フォルダを開くことが出来ませんでした。");
	@buf = readdir(DIR);
	closedir(DIR);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										システムエラー報告
#------------------------------------------------------------------┤
# &lib'system_error($error_code,$print_msg,$send_msg);
# $error_code -> エラー識別コード
# $print_msg  -> 画面出力用メッセージ
# $send_msg   -> メール送信用メッセージ（ありの場合メール送信）
sub system_error {
	local($error_code,$print_msg,$send_msg) = @_;
	### 報告エラー作成
	my $ertime = &lib'get_time($main'time,'3-3');
	my($env,$form,$env2,$form2);
	# 環境変数
	foreach (sort keys %ENV) {
		$env .= qq|$_		= $ENV{"$_"}\n|;
		$env2 .= qq|$_=$ENV{"$_"}&|;
	}
	# FORM変数
	foreach (sort keys %main'FORM) {
		$form .= qq|$_		= $main'FORM{"$_"}\n|;
		$form2 .= qq|$_=$main'FORM{"$_"}&|;
	}
	$env2 =~ s/\n//g;
	$form2 =~ s/\n//g;
	
	### エラー報告
	if ($send_msg && $main'conf{'suport_email'}) {
		my $mail_title = "システムエラー発生[$ENV{'HTTP_HOST'}]";
		my $mail_body = "
■エラーコード　　　　：$error_code
■プログラムコード　　：$main'fckey
■CGIを起動したページ ：$ENV{'HTTP_REFERER'}
■CGIスクリプト名　　 ：$ENV{'SCRIPT_NAME'}
■エラー発生日時　　　：$ertime
■エラー内容　　　　　：$send_msg

----- FORM変数 ------
$form

----- 環境変数 ------
$env
		";
		&lib'send_mail($main'conf{'suport_email'},$main'conf{'suport_email'},$mail_title,$mail_body);
	}
	$html_body = $main'html_error;
	$html_body =~ s/#msg#/エラーコード：$error_code<BR>$print_msg/;
	$print_html = "$main'html_header" . "$html_body" . "$main'html_footer";
	$print_html =~ s/#title#/エラーが発生しました！/g;

	### エラーログの記録
	my $er_log = "$ertime\t$error_code\t$main'time\t$print_msg\t$env2\t$form2\t\t0\n";
	open (FILE, ">>$main'LogDir/error.$main'log_ext");
	flock(FILE, 2);
	seek(FILE, 0, 2);
	print FILE $er_log;
	close(FILE);

	print "Content-type: text/html\n\n";
	print $print_html;
	exit;
}


#-----------------------------------------------------------------------------3
#										メール送信
#------------------------------------------------------------------┤2006.04.19
sub send_mail{
	local($mailto, $mailfrom, $mailtitle, $mailmain,$mailbcc) = @_;
	if (!$mailto) {
		($main'conf{'suport_email'}) || (return);
		$mailto = "$main'conf{'suport_email'}";
		$mailmain = "あて先不明のため転送しました。\n\n$mailmain";
	}
	### 返信用アドレス
	my $reply;
	if ($main'reply_to) {
		$reply = $main'reply_to;
	}

	### Sendmailオプション
	my $sendmail_opt = ' -t';
	if($main'conf{'f_option'}) {
		$sendmail_opt .= " -f'$main'conf{'f_option'}'";
	}
	
	#HTMLのデコード
	$mailmain =~ s/<BR>/\n/gs;
	$mailmain =~ s/&LT;/</gs;
	$mailmain =~ s/&GT;/>/gs;
	$mailmain =~ s/&QUOT;/"/gs;
	$mailmain =~ s/<UP\/>$//s;
	&jcode'convert(*mailmain, 'jis');

	### MIME-Base64エンコード
	chomp $mailtitle;
	if (!$INC{"$main'LibDir/mimew.pl"}) {
		require "$main'LibDir/mimew.pl";
	}
	$mailtitle = main'mimeencode($mailtitle);
	$mailto = main'mimeencode($mailto);
	$mailfrom = main'mimeencode($mailfrom);

	open(MAIL,"| $main'conf{'sendmail'}$sendmail_opt") || &lib'system_error('er207','メールの送信に失敗しました。');
	print MAIL "Reply-To: $reply\n" if($reply);
	print MAIL "To: $mailto\n";
	print MAIL "CC: $mailcc\n" if($mailcc);
	print MAIL "BCC: $mailbcc\n" if($mailbcc);
	print MAIL "From: $mailfrom\n";
	print MAIL "Subject: $mailtitle\n";
	print MAIL "X-Mailer: $main'fckey $main'lud\n";
	print MAIL "MIME-Version: 1.0\n";
	print MAIL "X-User-Agent: $ENV{HTTP_USER_AGENT}\n";
	print MAIL "X-Host: $ENV{REMOTE_ADDR}\n";
	print MAIL "Content-Transfer-Encoding: 7bit\n";
	print MAIL "Content-type: text/plain; charset=ISO-2022-JP\n\n";

	print MAIL "$mailmain\n";
	close(MAIL);

}


#-----------------------------------------------------------------------------1
#										現在の時刻を得る
#------------------------------------------------------------------┤2008.03.28
sub get_time {
	local($tsec, $format) = @_;
	($tsec) || ($tsec = time());
	($tsec =~ /[^0-9]/) && (return $tsec);
	($format) || ($format = '3-0W');
	local($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($tsec);
	$mon++;
	$year += 1900;
	my $week;
	if ($format =~ /W/) {	
		$week = ('日','月','火','水','木','金','土') [$wday];
		$week = "($week)";
		$format =~ s/W//;
	}
	
	my($format,$pa) = split(/:/,$format);
	if ($pa) {
		$pa1 = $pa;$pa2 = $pa;$pa3 = '';
	} else {
		$pa1 = '年';$pa2 = '月';$pa3 = '日';
	}
	
	($format eq '3-3F') && return sprintf("%04d$pa1%02d$pa2%02d$pa3$week %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
	($format eq '3-2F') && return sprintf("%04d$pa1%02d$pa2%02d$pa3$week %02d:%02d", $year, $mon, $mday, $hour, $min);
	($format eq '3-0F') && return sprintf("%04d$pa1%02d$pa2%02d$pa3$week", $year, $mon, $mday);

	($format eq '2-3F') && return sprintf("%02d$pa2%02d$pa3$week %02d:%02d:%02d",  $mon, $mday, $hour, $min, $sec);
	($format eq '2-2F') && return sprintf("%02d$pa2%02d$pa3$week %02d:%02d", $mon, $mday, $hour, $min);
	($format eq '2-0F') && return sprintf("%02d$pa2%02d$pa3$week", $mon, $mday);

	($format eq '3-3') && return sprintf("$year$pa1$mon$pa2$mday$pa3$week %02d:%02d:%02d", $hour, $min, $sec);
	($format eq '3-2') && return sprintf("$year$pa1$mon$pa2$mday$pa3$week %02d:%02d", $hour, $min);
	($format eq '3-0') && return "$year$pa1$mon$pa2$mday$pa3$week";

	($format eq '2-3') && return sprintf("$mon$pa2$mday$pa3$week %02d:%02d:%02d",  $hour, $min, $sec);
	($format eq '2-2') && return sprintf("$mon$pa2$mday$pa3$week %02d:%02d", $hour, $min);
	($format eq '2-0') && return "$mon$pa2$mday$pa3$week";
	
	($format eq 'F') && return sprintf("%04d/%02d/%02d/%02d/%02d/%02d/%01d", $year, $mon, $mday, $hour, $min, $sec, $wday);
	if ($format eq 'hash') {
		my %hash;
		$hash{'yyyy'} = $year;
		$hash{'mm'} = sprintf("%02d",$mon);
		$hash{'dd'} = sprintf("%02d",$mday);
		$hash{'yy'} = substr($year,2,2);
		$hash{'m'} = $mon;
		$hash{'d'} = $mday;
		$hash{'HH'} = sprintf("%02d",$hour);
		$hash{'MM'} = sprintf("%02d",$min);
		$hash{'SS'} = sprintf("%02d",$sec);
		$hash{'H'} = $hour;
		$hash{'M'} = $min;
		$hash{'S'} = $sec;
		$hash{'w'} = $wday;
		$hash{'W'} = ('日','月','火','水','木','金','土') [$wday];
		return %hash;
	}
	return "$year/$mon/$mday/$hour/$min/$sec/$wday"
}

#1:2007.08.28	$formmat=hashでハッシュ変数へ返すように機能追加
#2:2008.03.28 2-*Fで曜日が出ないバグを調整

#-----------------------------------------------------------------------------0
#										ＨＴＭＬファイルの取り込み
#------------------------------------------------------------------┤
sub get_html {
	# $file_nameはfolder.plのシステムHTMLファイル格納フォルダ
	# *bufは呼び出す元に値を返却する配列。宣言時は空。
	local($file_name,*buf) = @_;
	
	# 下記、４つはスカラー変数で宣言のみ。
	local($get_main,$n,@SET_MAIN,@M_HTML);

	### 詳細HTML
	(-f $file_name) || (return);
	&lib'openfile($file_name,*M_HTML);
	$get_main = join("",@M_HTML);
	@SET_MAIN = split(/<HR width="99%">/,$get_main);
	$buf{'header'} = shift @SET_MAIN;
	$buf{'footer'} = pop @SET_MAIN;
	
	foreach (@SET_MAIN) {
		$n++;
		$buf{"$n"} = $_;
	}
	(%buf) ? return(1) : return(0);
}



#-----------------------------------------------------------------------------1
#										登録用ログの作成
#------------------------------------------------------------------┤2005.10.10
sub make_log_line {
  local($F_DATA,$BUF) = @_;
	my @F_DATA = @{$F_DATA};
	my %BUF = %{$BUF};
	my($line);
	foreach (@F_DATA) {
	  &main'get_form_data_field($_);
		my $hv = $BUF{"$main'f_name"};
		$hv =~ s/&amp;/&/g;
		$hv =~ s/&quot;/"/g;
		$hv =~ s/&nul;/\0/g;
		### タブの削除
		$hv =~ s/\t/ /g;
		### 改行コードの変換
		$hv = &lib'set_BR($hv);
		$line .= "$hv\t";
	}
	$line .= "\t\t\t0\n";
	return $line;
}


#-----------------------------------------------------------------------------0
#										ログラインの取得
#------------------------------------------------------------------┤
sub get_log_line {
	local($key,@LOG) = @_;
	foreach (@LOG) {
		if (/^$key\t/) {return $_;}
	}
	return;
}


#-----------------------------------------------------------------------------0
#										ログファイルの書き換え
#------------------------------------------------------------------┤
sub change_log_line {
	local($file,$key,$line,$backup) = @_;
	(-f $file) || (return 0);
	($key) || (return 0);
	
	local(@LOG,$dellog);
	&lib'openfile($file,*LOG);
	foreach (@LOG) {
		if (/^$key\t/) {
			$dellog = $_;
			s/.*\n/$line/;
			last;
		}
	}
	
	if ($dellog) {
		&lib'writefile($file,@LOG);
		### バックアップ
		if ($backup) {
			my $date = &lib'get_time();
			$dellog = "$file\t$date\t$dellog";
			&lib'stokfile($backup,$dellog);
		}
		return 1;
	} else {
		return 0;
	}
}


#-----------------------------------------------------------------------------3
#										キーの変換
#------------------------------------------------------------------┤2007.05.15
# $html = &lib'change_key($html,\@DB,\%FORM);
sub change_key {
  local($html,$F_DATA,$BUF,$time_key) = @_;
	my @F_DATA = @{$F_DATA};
	my %BUF = %{$BUF};
	local($hidden);
	foreach (@F_DATA) {
	  &main'get_form_data_field($_);
		my $f_name = $main'f_name;
		my $f_type = $main'f_type;
		($f_type eq 'textarea') && ($BUF{"$f_name"} = &lib'set_BR($BUF{"$f_name"}));
		$html =~ s/#$f_name#/$BUF{"$f_name"}/g;
		if ($f_type =~ /time/i) {
		  ($BUF{$f_name}) ? ($html =~ s/#D-$f_name#/&lib'get_time($BUF{$f_name},$time_key)/ge) :($html =~ s/#D-$f_name#//g);
		}
		### リストの値を表示
		if ($main'f_list && $html =~ /#N-$f_name#/) {
			my @LIST = split(/,/,$main'f_list);
			my ($flist);
			foreach $lst (@LIST) {
				my($value,$name) = split(/\:/,$lst);
				($name) || ($name = $value);
				if ($BUF{$f_name} =~ /\0/) {
					my @VAL = split(/\0/,$BUF{$f_name});
					if (grep(/^$value$/,@VAL)) {
						$flist .= "$name、";
					}
				} else {
					if ($BUF{$f_name} eq $value) {
						$html =~ s/#N-$f_name#/$name/g;
						last;
					}
				}
			}
			$flist =~ s/、$//;
			$html =~ s/#N-$f_name#/$flist/g;
		}
		### 数字を表示
		if ($html =~ /#Y-$f_name#/) {
			if ($BUF{$f_name} !~ /[^0-9]/) {
				$html =~ s/#Y-$f_name#/&lib'set_digit($BUF{$f_name})/eg;
			} else {
				$html =~ s/#Y-$f_name#/$BUF{$f_name}/g;
			}
		}
		### URLエンコード
		if ($html =~ /#E-$f_name#/) {
			$html =~ s/#E-$f_name#/&lib'url_encode($BUF{$f_name})/eg;
		}
		###　HIDDENの作成
		my $hv = $BUF{"$f_name"};
		$hv =~ s/&/&amp;/g;
		$hv =~ s/"/&quot;/g;
		$hv =~ s/\0/&nul;/g;
		$hidden .= qq|<INPUT type="hidden" name="$f_name" value="$hv">\n|;
	}
	$html =~ s/<!-- hidden -->/$hidden/;
	$html =~ s/<!-- HIDDEN -->/$hidden/g;
	return $html;
}


#-----------------------------------------------------------------------------0
#										並び準の変更
#------------------------------------------------------------------┤
# $file   => 処理対象のファイル
# $key    => キーとなる文字列（シリアルコード）
# $action => 'up' or 'down'
sub change_line {
	local($file,$key,$action) = @_;
	($file && $key) || (return);
	local(@LOG,$n);
	
	&lib'openfile($file,*LOG);
	foreach (@LOG) {
		if (/^$key\t/) {
			$g_line = $_;
			if ($action eq 'up') {
				$t_line = @LOG[$n-1];
				($t_line) || (return);
				@LOG[$n-1] = "";
				s/.*\n/$_$t_line/;
			} elsif ($action eq 'down') {
				$t_line = @LOG[$n+1];
				($t_line) || (return);
				@LOG[$n+1] = "";
				s/.*\n/$t_line$_/;
			}
			&lib'writefile($file,@LOG);
			last;
		}
		$n++;
	}
}


#-----------------------------------------------------------------------------1
#										ユーザーのIPアドレスを得る
#------------------------------------------------------------------┤2007.04.05
sub get_ip{
	# ホスト名を取得
	my $host  = $ENV{'REMOTE_HOST'};
	my $addr  = $ENV{'REMOTE_ADDR'};
	if ($host eq "" || $host eq "$addr") {
		if ($addr =~ /192.168/ || $addr eq '127.0.0.1') {
			$host = 'localhost';
			return($host,$addr);
		}
		my ($p1,$p2,$p3,$p4) = split(/\./,$addr);
		my $temp = pack("C4",$p1,$p2,$p3,$p4);
		$host = gethostbyaddr("$temp", 2);
		if ($host eq "") { $host = $addr; }
	}
	return($host,$addr);
}


#-----------------------------------------------------------------------------1
#										数字の桁表示
#------------------------------------------------------------------┤2005.08.23
sub set_digit {
	local($atai) = @_;
	local($num,$hiku);
	if ($atai =~ /^-/) {
		$atai =~ s/^-//;
		$hiku = 1;
	}
	for ($keta=length($atai); $keta>=1; $keta--) {
		$moji=int($atai/(10**($keta-1)));
		$atai=$atai-$moji*(10**($keta-1));
		if ($keta eq 4 || $keta eq 7) {
			$num .= $moji . ","; 
		} else {
			$num .= $moji;
		}
  }
	($hiku) && ($num = "-$num");
	return($num);
}


#-----------------------------------------------------------------------------0
#										URLエンコード
#------------------------------------------------------------------┤
# $value = &lib'url_encode($value,$task);
sub url_encode {
	local($value,$task) = @_;
	if ($task eq 'decode') {
		$value =~ tr/+/ /;
		$value =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("C", hex($1))/eg;
	} else {
		$value =~ s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
	}
	return $value;
}



#-----------------------------------------------------------------------------0
#										改行コード処理
#------------------------------------------------------------------┤
###-------- 改行コードを <BR> に統一
sub set_BR {
	local($value) = @_;
	
	$value =~ s/\r\n/<BR>/g;
	$value =~ s/\r/<BR>/g;
	$value =~ s/\n/<BR>/g;
	
	return ($value);
}

###-------- <BR>を \n に統一
sub unset_BR {
	local($value) = @_;
	$value =~ s/<BR>/\n/ig;
	return ($value);
}

###-------- 改行コードを \n に統一
sub unify_return_code {
	my($String) = @_;
	$String =~ s/\x0D\x0A/\n/g;
	$String =~ s/\x0D/\n/g;
	$String =~ s/\x0A/\n/g;
	return $String;
}


#-----------------------------------------------------------------------------0
#										変数チェック
#------------------------------------------------------------------┤
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
	$get =~ s/\0/<FONT color="blue">\\0<\/FONT>/g;
	$get =~ s/\t/<FONT color="blue">\\t<\/FONT>/g;

	$gettime = &lib'get_time(time,'3-3F');
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

package cookie;
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------0
#										クッキーの取得
#------------------------------------------------------------------┤
sub get_cookie {
	local($c_name) = @_;

	$cookies = $ENV{'HTTP_COOKIE'};
	@pairs = split(/;/,$cookies);
	foreach $pair (@pairs) {
		($name, $value) = split(/=/, $pair);
		$name =~ s/ //g;
		$DUMMY{$name} = $value;
	}
	@pairs = split(/,/,$DUMMY{"$c_name"});
	foreach $pair (@pairs) {
		($name, $value) = split(/:/, $pair);
		$COOKIE{$name} = $value;
	}
}

#-----------------------------------------------------------------------------1
#										クッキーの設定
#------------------------------------------------------------------┤2006.07.19
sub set_cookie {
	local($c_name, $c_value, $c_date, $c_path) = @_;
	
	($c_date eq '') && ($c_date = 30);
	($c_path) ? ($c_path = '') : ($c_path = '/');
	if ($c_date eq '0') {
		print "Set-Cookie: $c_name=$c_value; path=$c_path\n";
	} else {
		my($secg,$ming,$hourg,$mdayg,$mong,$yearg,$wdayg,$ydayg,$isdstg)=gmtime(time + $c_date*24*60*60);
		$yearg  += 1900 ;
		$mong =  ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')[$mong];
		my $youbi =  ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')[$wdayg];
		my $date_gmt = sprintf("%s\, %02d\-%s\-%04d %02d:%02d:%02d GMT",$youbi, $mdayg, $mong, $yearg, $hourg, $ming, $secg);

		print "Set-Cookie: $c_name=$c_value; expires=$date_gmt; path=$c_path\n";
	}
	
}



#-----------------------------------------------------------------------------0
#										ログアウト
#------------------------------------------------------------------┤
sub logout {
	local($cookie_name) = @_;
	($secg,$ming,$hourg,$mdayg,$mong,$yearg,$wdayg,$ydayg,$isdstg)=gmtime(time-1);
	$yearg  += 1900 ;
	$mong =  ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')[$mong];
	$youbi =  ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')[$wdayg];
	$date_gmt = sprintf("%s\, %02d\-%s\-%04d %02d:%02d:%02d GMT",$youbi, $mdayg, $mong, $yearg, $hourg, $ming, $secg);

	print "Set-Cookie: $cookie_name=; expires=$date_gmt; path=/\n";
}


package form;
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------0
#										入力値制限チェック
#------------------------------------------------------------------┤
sub InputRestrict {
	local($value,$restrict) = @_;
	local($value_len,$err_no,$rule,$error_msg);
	
	my %error_list = (
		'1' => '#NAME#は、省略できません。<BR>',
		'2'  => '#NAME#は、半角数字で指定してください。<BR>',
		'3'  => '#NAME#は、全角数字で指定してください。<BR>',
		'4'  => '#NAME#は、半角アルファベットで指定してください。<BR>',
		'5'  => '#NAME#は、全角アルファベットで指定してください。<BR>',
		'6'  => '#NAME#は、半角英数で指定してください。<BR>',
		'7'  => '#NAME#は、全角英数で指定してください。<BR>',
		'8'  => '#NAME#は、正しくありません。<BR>',
		'9'  => '#NAME#は、半角英数字又は[.],[-],[_],[?]で指定してください。<BR>',
		'10' => '#NAME#は、正しくありません。<BR>',
		'20' => '#NAME#は、ハイフンなしで10桁もしくは11桁の半角数字で指定してください。<BR>',
		'21' => '#NAME#は、ハイフンを入れて10桁もしくは11桁の半角数字で指定してください。<BR>',
		'22' => '#NAME#は、ハイフンなしで半角数字7桁で指定してください。<BR>',
		'23' => '#NAME#は、ハイフンを入れて半角数字7桁で指定してください。<BR>',
		'31' => '#NAME#は、全角ひらがなで指定してください。<BR>',
		'32' => '#NAME#は、全角カタカナで指定してください。<BR>'
	);
	
	$value_len = length($value);
	my @rules = split(/:/, $restrict);
	for $rule (@rules) {
		if($rule eq '1') {				#入力なし
			if ($value eq '') {
				$err_no = $rule;
			}
		} elsif(!$value) {
			next;
		} elsif($rule eq '2') {			#半角数字のみ
			if($value =~ /[^0-9]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '3') {			#全角数字のみ
			$value =~ s/\xa3[\xb0-\xbf]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '4') {			#半角アルファベットのみ
			if($value =~ /[^a-zA-Z]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '5') {			#全角アルファベットのみ
			$value =~ s/\xa3[\xc0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '6') {			#半角英数のみ
			if($value =~ /[^0-9a-zA-Z\.\-\_]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '7') {			#全角英数のみ
			$value =~ s/\xa3[\xb0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '8') {			#メールアドレス
			if($value =~ /[^a-zA-Z0-9\@\.\-\_\?]/) {
				$err_no = $rule;
			}
			unless($value =~ /^[^\@]+\@[^\@]+$/) {
				$err_no = $rule;
			}
			if($value =~ /\.$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '9') {			#ファイル名
			if($value =~ /[^a-zA-Z0-9\@\.\-\_\?]/) {
				$err_no = $rule;
			}
#		} elsif($rule eq '10') {		#URL

#			if ($value =~ /[\w|\!\#\&\=\-\%\@\~\;\+\:\.\?\/]+/) {
#				$err_no = $rule;
#			}
		} elsif($rule eq '20') {		#ハイフンなしの電話番号（半角）
			if($value =~ /[^0-9]/) {
				$err_no = $rule;
			}
			if($value_len > 11 || $value_len < 10) {
				$err_no = $rule;
			}
		} elsif($rule eq '21') {		#ハイフンありの電話番号（半角）
			unless($value =~ /^0[0-9]+\-[0-9]+\-[0-9]+$/) {
				$err_no = $rule;
			}
			if($value_len > 13 || $value_len < 12) {
				$err_no = $rule;
			}
		} elsif($rule eq '22') {		#ハイフンなしの郵便番号（半角）（例：1234567）
			unless($value =~ /^[0-9]{7}$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '23') {		#ハイフンありの郵便番号（半角）（例：123-4567）
			unless($value =~ /^[0-9]{3}\-[0-9]{4}$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '31') {		#全角ひらがなのみ
			$value =~ s/\xa1\xa1//g;
			$value =~ s/ //g;
			$value =~ s/\xA1[\xA6\xBC\xB3\xB4]//g;		## [・ーヽヾ]を除く
			$value =~ s/\xa4[\xa0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '32') {		#全角カタカナのみ
			$value =~ s/\xa1\xa1//g;
			$value =~ s/ //g;
			$value =~ s/\xA1[\xA6\xBC\xB3\xB4]//g;		## [・ーヽヾ]を除く
			$value =~ s/\xa5[\xa0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		}
		if($err_no) {
			$error_msg .= $error_list{$rule};
		}
	}
	return $error_msg;
}
#-----------------------------------------------------------------------------0
#										入力値変換
#------------------------------------------------------------------┤
sub ValueConvert {
	my($value, $rule_str) = @_;
	my @rules = split(/:/, $rule_str);
	my $rule;
	for $rule (@rules) {
		if($rule eq '1') {		#全角数字と全角ハイフンを半角に変換
			&jcode::tr(\$value, '０１２３４５６７８９－', '0123456789-');
		} elsif($rule eq '2') {	#半角数字と半角ハイフンを全角に変換
			&jcode::tr(\$value, '0123456789-', '０１２３４５６７８９－');
		} elsif($rule eq '3') {	#全角・半角ハイフンを削除
			my $zen_hyphen = '－';
			&jcode::convert(\$zen_hyphen, 'euc', 'sjis');
			&jcode::convert(\$value, 'euc', 'sjis');
			$value =~ s/$zen_hyphen//g;
			&jcode::convert(\$value, 'sjis', 'euc');
			$value =~ s/\-//g;
		} elsif($rule eq '4') {	#全角アルファベットを半角に変換
			&jcode::tr(\$value, 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
		} elsif($rule eq '5') {	#半角アルファベットを全角に変換
			&jcode::tr(\$value, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ');
		} elsif($rule eq '6') {	#半角カナを全角カナに変換
			&jcode::h2z_sjis(\$value);
		} elsif($rule eq '7') {	#メールアドレスを半角に変換
			&jcode::tr(\$value, 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
			&jcode::tr(\$value, '０１２３４５６７８９－＿', '0123456789-_');
			$value =~ s/＠/\@/g;
			$value =~ s/．/\./g;
		} elsif($rule eq '10') {	#["]を[”]に変換
			$value =~ s/"/”/g;
		} elsif($rule eq '11') {	#タグを無効にする
			$value = &lib'cut_tab($value);
		}
	}
	return $value;
}



1;
