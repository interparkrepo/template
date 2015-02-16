#!/usr/bin/perl

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					本CGIファイルの説明
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 本CGIファイルはサーバに本製品をセットアップするためのCGIです。
# セットアップ後は不要になりますので、破棄しても結構です。
# 
# このファイルの一行目に書かれている「#!/usr/bin/perl」は、Perlのパスとなります。
# セットアップするサーバの環境に合わせて書き換えてください。
# 一般的なサーバでは上記以外の場合、「#!/usr/local/bin/perl」となる場合もありま
# す。
# 
# また、ファイルのパーミッションもCGIが実行できるパーミッションに変更してくださ
# い。
# 通常「755」とすればよいのですが、サーバの環境によっては「705」又は「704」とし
# ないと実行しない場合もあります。
# 不明な場合は、サーバ管理者にご確認ください。
#


#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					ライブラリの取得
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
eval{
require "folder.pl";
require "conf.pl";

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					初期設定
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
&setup_conf;

my $action = $ENV{'QUERY_STRING'};

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#					メイン処理
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------1
#										システムのセットアップフォーム
#------------------------------------------------------------------┤2009.06.14
sub setup_form {
	if (-f "$LibDir") {
		&lib'system_error('',"すでにセットアップは完了しています。");
	}
	$html = qq|
	<HTML>
	<HEAD>
	<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
	<META http-equiv="Content-Style-Type" content="text/css">
	<script src="$ImageDir/window.js" type="text/javascript"></script>
	<LINK rel="stylesheet" href="$ImageDir/font.css" type="text/css">
	<TITLE>セットアップの開始</TITLE>
	</HEAD>
	<BODY>
	<CENTER><BR>
	<BR>
	<TABLE border="0" width="600" cellpadding="4" cellspacing="1" bgcolor="#333333" class="font15">
	  <TR>
	    <TD colspan="2" bgcolor="#000080" class="white">　■　セットアップの開始</TD>
	  </TR>
    <TR>
      <TD bgcolor="#ffcc00" rowspan="2"></TD>
      <TD bgcolor="#ffffff">このたびは、CGI-Park製品をダウンロードいただき、ありがとうございます。<BR>
      当CGIを利用するには最初にシステムのセットアップ作業を行なう必要があります。セットアップ作業を行なうと、設置するサーバにプログラムファイルや各種設定ファイルが作成されます。<BR>
      <BR>
      システムのセットアップを行なう前に必ず下記の使用許諾契約書に目を通し、内容に同意した上でセットアップを開始してください。使用許諾契約書に同意できない場合はセットアップを行なわないでください。<BR>
      <IFRAME width="575" height="300" frameborder="1" src="https://www.cgi-park.com/document/contract.txt" marginwidth="3" marginheight="5"></IFRAME><BR>
      </TD>
    </TR>
	  <TR>
	    <TD bgcolor="#ffffff" align="center">
	    <FORM class="FORM" action="setup.cgi" onsubmit="submitOnce(this);">
			<INPUT type="submit" value="上記使用許諾契約書に同意しセットアップを実行する" onclick="return confirm('使用許諾契約書に同意し、セットアップを実行します。よろしいですか？');">
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

# 1:2009.06.14 規約をSSLで表示するように修正

#-----------------------------------------------------------------------------0
#										システムのセットアップ
#------------------------------------------------------------------┤2005.09.27
sub setup {
	if (-f "$LibDir") {
		&lib'system_error('',"すでにセットアップは完了しています。");
	}

	### ログファイルの拡張子
	if ($log_ext ne 'log') {
		if ($log_ext eq 'htm' || $log_ext eq 'db' || $log_ext eq 'mail') {
			&lib'system_error('',"ログファイルの拡張子の設定が不正です。拡張子に「$log_ext」は利用出来ません。");
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
	
	### 実行権限の確認
	my $owner;
	my $this_file_name = 'setup.cgi';

	my $execuid = $<;	#実UID

	my @path_array = split(/\//, $ENV{'SCRIPT_FILENAME'});
	my $auto_find_file_name = pop @path_array;
	if($auto_find_file_name) {
		$this_file_name = $auto_find_file_name;
	}
	my ($par,$uid,$gid) = (stat($this_file_name))[2,4,5];

	#Windowsサーバ
	if ($^O =~ /MSWin32/i) {
		$owner = 'win';
	#owner 権限で実行
	} elsif($execuid eq $uid) {
		$owner = 'owner';
	#other 権限で実行
	} else {
		$owner = 'other';
	}

	### システムデータの読み込み
	&lib'openfile($system_log,*SYS);

	### プログラム情報の確認
	my $head = shift @SYS;
	$head =~ s/\0/,/g;
	my $check = "$fckey,$apa,$mjnm,$fud,$lud,$cphp,$cpem,";
	unless ($head =~ /^$check/) {
		&lib'system_error('er100',"システム情報が一致しません。<BR>$head<BR>$check<BR>");
	}

	### ファイルの確認
	foreach (@SYS) {
		my($file) = split(/\0/);
		my($dir,$name) =split(/\//,$file);
		if (-e "$DIR{\"$dir\"}/$name") {
			&lib'system_error('er200',"ファイルの展開に失敗しました。ファイルがすでに存在します。<BR>$file");
		}
	}

	### Perlのパス確認
	&lib'openfile($this_file_name,*SU);
	my $perl_path = shift @SU;

	### ファイルの展開
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
				&lib'system_error('er300',"$file_pathシステム設置フォルダに対してアクセス権限がありません。フォルダのパーミッションを確認してください。");
			}
		}
		$data = reverse $data;
		$data =~ s/\[\\n\]/\n/g;

		### 実行ファイル
		if ($name =~ /\.cgi$/) {
			if ($data =~ /^#!\// && $data !~ /^$perl_path/) {
				$data =~ s/^#!\/usr\/bin\/perl\n/$perl_path/;
			}
		}
		### 識別コードの埋め込み
		if ($file_path =~ /.pl$/ || $file_path =~ /.cgi$/ ) {
			$data .= "\n#$file\n#$ver\n\n";
		}
		
		### ファイルの保存
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

	### セットアップの完成
	unlink "setup.cgi";

	$html = qq|
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
		<META http-equiv="Content-Style-Type" content="text/css">
		<TITLE>セットアップの完了</TITLE>
		<LINK rel="stylesheet" href="$ImageDir/font.css" type="text/css">
		</HEAD>
		<BODY bgcolor="#ffffff">
		<CENTER><BR>
		<TABLE border="0" width="600" cellpadding="4" cellspacing="1" bgcolor="#333333" class="font15">
			<TR>
			  <TD colspan="2" bgcolor="#000080" class="white">　■　セットアップの完了</TD>
			</TR>
			<TR>
			  <TD bgcolor="#ffcc00" rowspan="2"></TD>
			  <TD bgcolor="#ffffff" align="center" height="200"><BR>
			  ありがとうございました。セットアップが正常に完了しました。<BR>
			  下記のボタンより管理画面にログインしてください。<BR>
			  </TD>
			</TR>
			<TR>
			  <TD bgcolor="#ffffff" align="center">
			  <FORM action="../index.cgi" method="POST"><INPUT type="submit" value="管理画面へ" class="FORM"></FORM>
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
sub system_error {
	local($error_code,$print_msg) = @_;
	### 報告エラー作成
	my $ertime = &lib'get_time;
	my($env2,$form2);
	# 環境変数
	foreach (sort keys %ENV) {
		$env2 .= qq|$_=$ENV{"$_"}&|;
	}
	# FORM変数
	foreach (sort keys %main'FORM) {
		$form2 .= qq|$_=$main'FORM{"$_"}&|;
	}
	$env2 =~ s/\n//g;
	$form2 =~ s/\n//g;

	### エラーログの記録
	my $er_log = "$ertime\t$error_code\t$main'time\t$print_msg\t$env2\t$form2\t\t0\n";
	open (FILE, ">>$main'LogDir/error.$main'log_ext");
	flock(FILE, 2);
	seek(FILE, 0, 2);
	print FILE $er_log;
	close(FILE);
	
	### エラー報告
	my $print_html = qq|
		<HTML>
		<HEAD>
		<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
		<META http-equiv="Content-Style-Type" content="text/css">
		<TITLE>エラーが発生しました！</TITLE>
		</HEAD>
		<BODY bgcolor="#ffffff">
		<CENTER>
		<TABLE border="0" width="400" cellpadding="2" cellspacing="1" bgcolor="#cccccc">
		    <TR>
		      <TD align="left" bgcolor="#cc0000">　<B><FONT color="#ffffff" size="2">エラーが発生しました！[ エラーコード：$error_code ]</FONT></B></TD>
		    </TR>
		    <TR>
		      <TD height="100" bgcolor="#ffffff"><FONT size="2">以下の内容でエラーが発生しました。<BR>
		      $print_msg</FONT><BR>
		      </TD>
		    </TR>
		    <TR>
		      <TD align="center" bgcolor="#ffffff"><INPUT type="button" value="　戻る　" onclick="history.back();"></TD>
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
#										現在の時刻を得る
#------------------------------------------------------------------┤
sub get_time {
	my $tsec = time();
	my($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime($tsec);
	$mon++;
	$year += 1900;
	return sprintf("$year年$mon月$mday日 %02d:%02d:%02d", $hour, $min, $sec);
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



#前回更新日：2005.09.27
#最終更新日：2006.04.19


