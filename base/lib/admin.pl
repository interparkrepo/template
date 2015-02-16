#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫admin.pl [Ver.2009.06.14] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：2009.02.02
#|┠──┨最終更新日：2009.06.14
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


#-----------------------------------------------------------------------------1
#										管理画面の作成
#------------------------------------------------------------------┤2005.09.03
sub subroutine {
	&setup_conf;
	$title_bar = 'ライセンス登録';

	#-----------------------------------------
	# ライセンス登録フォーム
	if ($lcs eq $html && !$action) {GO1:
		($au eq "$fckey\meijin") && (&print_flame);
		$return_html = &init_form($html{1});
		
	#-----------------------------------------
	# テスト試用開始（CGI-Parkからの解答）
	} elsif ($action eq 'test_start') {
		&test_start;
		print"Location: ./admin.cgi?c=no\n\n";
		exit;
		
	#-----------------------------------------
	# ライセンス登録フォーム（期限切れ）
	} elsif ($action eq 'lcs_form') {GO2:
		($au eq "$fckey\meijin") && (&print_flame);
		$return_html = &init_form($html{2});
		
	#-----------------------------------------
	# ライセンス登録（CGI-Parkからの解答）
	} elsif ($action eq 'license') {
		&set_license;
		print"Location: ./admin.cgi?c=no\n\n";
		exit;
		
	#-----------------------------------------
	# ステータス確認（CGI-Parkからの解答）
	} elsif ($action eq 'status_check') {
		&status_check;
		
	#-----------------------------------------
	# テストサーバー登録フォーム
	} elsif ($action eq 'cts') {GO3:
		$return_html = &cts($html{3});
		$html_header =~ s/width="600"/width="100%"/g;
		
	#-----------------------------------------
	# ライセンス情報の表示
	} elsif ($action eq 'show_license') {
		$title_bar = 'ライセンス情報の表\示';
		$return_html = &show_license($html{4});
		
	#-----------------------------------------
	# アップデートフォーム
	} elsif ($action eq 'update') {
		$title_bar = 'アップデート';
		$return_html = $html{5};
		
	#-----------------------------------------
	# アップデート確認
	} elsif ($action eq 'update_check') {
		$title_bar = 'アップデート';
		$return_html = &update_check($html{6});
		if ($error_msg) {
			$html{5} =~ s/<!-- error_msg -->/$error_msg<BR>/;
			$return_html = $html{5};
		}
		
	#-----------------------------------------
	# アップデート実行
	} elsif ($action eq 'update_exe') {
		$title_bar = 'アップデート';
		$return_html = &update_exe($html_msgbox);
		
	#-----------------------------------------
	# システム再構築
	} elsif ($action eq 'remake') {
		$title_bar = 'システム再構築';
		$return_html = &remake_check($html{7});
		
	#-----------------------------------------
	# システム再構築 実行
	} elsif ($action eq 'remake_exe') {
		$title_bar = 'システム再構築';
		$return_html = &remake_exe($html_msgbox);
		
	#-----------------------------------------
	# システム再構築 実行
	} elsif ($action eq 'record') {
		$title_bar = '作業履歴';
		$return_html = &show_record($html{8});
		
	#-----------------------------------------
	# フレームの表示
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
#										ライセンスフォーム
#------------------------------------------------------------------┤2006.04.19
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
	
	### 戻り先URLの作成
	my $ref = &make_ref_url;
	$html =~ s/#ref#/&lib'url_encode($ref)/eg;
	
	$html_header =~ s/width="600"/width="100%"/g;

	return $html;
}


#-----------------------------------------------------------------------------0
#										試用期間の開始
#------------------------------------------------------------------┤
sub test_start {
	if (!$FORM{'test_time'}) {
		$error_msg{'test'} = '試用を開始することが出来ませんでした。<BR>';
		goto GO1;
	}
	my $test_time = "$FORM{'test_time'}\n";
	&lib'stokfile($meijin_log,$test_time);
}


#-----------------------------------------------------------------------------2
#										フレームの作成
#------------------------------------------------------------------┤2007.02.23
sub print_flame {
	### ステータス確認
	if (-e "$LogDir/lcstatus.$log_ext") {
		&lib'openfile("$LogDir/lcstatus.$log_ext",*ER);
		&lib'system_error("er500-$ER[0]","ライセンス情報にエラーがあり、管理画面へのアクセスが拒否されました。<BR>詳しくは、システム管理者にお問い合わせください。");
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
#										ライセンス登録
#------------------------------------------------------------------┤2005.09.03
sub set_license {

	#--------------------------------
	# 認証エラー
	if ($FORM{'er'}) {
		$html{"$FORM{'page'}"} =~ s/<!-- ER -->/ライセンス情報が正しくありません。($FORM{'er'})/;
		$print_html = &init_form($html{"$FORM{'page'}"});
		goto "GO$FORM{'page'}";

	#--------------------------------
	# テストサーバ登録
	} elsif ($FORM{'http_host'}) {
		$test_url = $FORM{'http_host'};
	}

	#--------------------------------
	# ライセンス認証番号の記録
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
#										ライセンスフォーム
#------------------------------------------------------------------┤2006.04.19
sub cts {
	local($html) = @_;

	$html =~ s/#lc_code#/$lc1/g;
	$html =~ s/#site_name#/$lc2/g;
	$html =~ s/#site_url#/$lc3/g;
	$html =~ s/#http_host#/$ENV{'HTTP_HOST'}/g;
	$html =~ s/#soft_code#/$fckey/g;
	$html =~ s/#apa#/$apa/g;
	
	### 戻り先URLの作成
	my $ref = &make_ref_url;
	$html =~ s/#ref#/&lib'url_encode($ref)/eg;

	return $html;
}

#-----------------------------------------------------------------------------0
#										ＵＲＬ確認
#------------------------------------------------------------------┤
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
#		$html =~ s/#title#/ライセンス認証エラー！/;
#		$html =~ s/#msg#/設置しているサーバはライセンス情報と一致しません。/;
        return;
	}
	return $html;
}


#-----------------------------------------------------------------------------5
#										ライセンス情報
#------------------------------------------------------------------┤2009.06.14
sub show_license {
	local($html) = @_;
	my($frame_url);
	my $upflag = 'disabled';
	
	### ライセンス登録済み
	if ($lc1 =~ /^L/) {
		($lc5) && ($lc5 = &lib'get_time($lc5,'3-0WF'));
		my @CUT = split(/<!-- CUT -->/,$html);
		$html = "$CUT[0]$CUT[2]";
		&lib'openfile("$LogDir/lcc.$log_ext",*LCC);
		my $ref = &make_ref_url;
		if ($mjnm =~ /（改）/) {
			my $text = &lib'url_encode('改造版のためアップデート不可');
			$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
		} else {
			$frame_url = "https://www.cgi-park.com/license/regist.cgi?action=status&lc_code=$lc1&soft_code=$fckey&lcc=$LCC[0]&fud=$fud&ref=$ref";
			$upflag = '';
		}
	### 試用期間中
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
		
		my $text = &lib'url_encode('試用期間中');
		$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
	} else {
		$html =~ s/#test_date#まで//;
		my $text = &lib'url_encode('制作準備中');
		$frame_url = "admin.cgi?html=admin&action=status_check&c=no&text=$text";
	}
	### 再構築ボタン
	if ($mjnm =~ /（改）/) {
		$html =~ s/#remake_btn#/disabled/;
	}

	### ライセンス状態の表示
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

# 4:2009.02.02 試用期間の日付けを正しく取得できるように調整
# 5:2009.06.14 アップデート確認をSSLで確認するように変更/メッセージをエンコード

#-----------------------------------------------------------------------------1
#										ステータス確認
#------------------------------------------------------------------┤2005.09.05
sub status_check {
	my $print_status;
	# ライセンス確認コードの認証
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
				if ($mjnm =~ /（改）/) {
					$FORM{'text'} = 'アップデートファイルはありません。';
				}
			# SU'ysS.JePFjjFt.'
			} elsif ($FORM{'status'} eq crypt('SU','ys')) {
				my $pw = crypt($FORM{'pw'},$crypt_key);
				&lib'writefile("$LogDir/cpsu",$pw);
			}
		}
		
	# ライセンス確認コードの作成
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
#										アップデートの確認
#------------------------------------------------------------------┤2005.09.03
sub update_check {
	local($html) = @_;
	### ステータス確認
	if (-e "$LogDir/lcstatus.$log_ext") {
		&lib'openfile("$LogDir/lcstatus.$log_ext",*ER);
		&lib'system_error("er500-$ER[0]","ライセンス情報にエラーがあり、管理画面へのアクセスが拒否されました。<BR>詳しくは、システム管理者にお問い合わせください。");
	}
	if (!$lc1) {
		$html_error =~ s/#title#/エラー！/;
		$html_error =~ s/#msg#/アップデートを実行することが出来ません。<BR>アップデートを行なうには正しくライセンスが登録されている必要があります。/;
		return $html_error;
	}

	### アップデートファイルの確認
	if (!$FORM{'cpm_file'}) {
		$error_msg = 'アップデートファイルを選択してください。';
	}
	my $cpm_file_name = reverse $incfn{'cpm_file'};
	($cpm_file_name) = split(/\\/,$cpm_file_name);
	$cpm_file_name = reverse $cpm_file_name;
	my($name,$ext) = split(/\./,$cpm_file_name);
	($ext ne 'cpm') && ($error_msg = 'アップデートファイルが不正です。正しいファイルを選択してください。');
	my($name1,$name2) = split(/\-/,$name);
	($name1 ne $fckey) && ($error_msg = 'アップデートファイルが不正です。正しいファイルを選択してください。');
	
	### ファイルの中身を確認
	$FORM{'cpm_file'} = &lib'unify_return_code($FORM{'cpm_file'});
	my @SYS = split(/\n/,$FORM{'cpm_file'});
	my $head = shift @SYS;
	my $foot = pop @SYS;
	my($fckey2,$apa2,$mjnm2,$fud2,$lud2,$cphp2,$cpem2) = split(/\0/,$head);
	if ($lud2 ne $fud) {
		$error_msg = 'アップデートファイルが正しくありません。<BR>現在利用しているバージョンを確認し、そのバージョン以降最初にリリースされたアップデートファイルを選択してください。';
	}

	### エラーの場合ここで終了
	($error_msg) && (return);

	### アップデートファイルを保存
	&lib'writefile("$LogDir/update-$name.$log_ext",$FORM{'cpm_file'});

	### アップデート実行ファイル一覧の作成
	my ($file_list,$file_name);
	foreach (@SYS) {
		my($file,$final_date,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $buf = "$DIR{\"$dir\"}/$name";
		if (!-e $buf) {
			$buf .= ' （新規追加）';
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
#										アップデートの実行
#------------------------------------------------------------------┤2006.04.19
sub update_exe {
	local($html) = @_;
	($lc1) || (return);
	
	### アップデートファイルの読み込み
	my $update_file = "$LogDir/update-$FORM{'update_file'}.$log_ext";
	&lib'openfile($update_file,*UPDATE);
	my $new_head = shift @UPDATE;
	my $memo = pop @UPDATE;

	### ライセンス整理番号の読み込み
	local(@LCC);
	my $lcc_log = "$LogDir/lcc.$log_ext";
	&lib'openfile($lcc_log,*LCC);

	### CGIパーミッションの確認
	my($par) = (stat("admin.cgi"))[2];

	### アップデート実行
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
		### 更新プログラムの実行
		if ($name eq 'exe.pl') {
			require "$file_path";
			eval{&exe;};
			if ($@) {
				&lib'system_error('er600',"アップデート作業に失敗し、処理を継続できませんでした。<BR>$@",$@);
			} else {
				next;
			}
		}
		$new_line{"$file"} = $_;
		$files .= "$file,";
	}

	### システムファイルの更新
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

	### バックアップ
	my $fud3 = $fud;
	$fud3 =~ s/\.//g;
	rename "$system_log","$LogDir/backup-$fckey\-$fud3\.$log_ext";

	&lib'writefile($system_log,@SYS);
	unlink $update_file;
	
	### 名人データの更新
	my $meijin_log = "$LogDir/meijin.$log_ext";
	&lib'openfile($meijin_log,*MJ);
	$new_head =~ s/\0/\t/g;
	shift @MJ;
	unshift @MJ,$new_head;
	&lib'writefile($meijin_log,@MJ);

	### 更新履歴の作成
	my($new_mj) = (split(/\t/,$new_head))[2];
	&lib'openfile($up_record_db,*UR_DB);
	$UR{'ur_file'} = $FORM{'update_file'};
	$UR{'ur_name'} = $new_mj;
	$UR{'ur_time'} = $time;
	$UR{'ur_memo'} = $memo;
	$UR{'ur_list'} = $files;
	my $new_ur = &lib'make_log_line(\@UR_DB,\%UR);
	&lib'stokfile($up_record_log,$new_ur);

	$html =~ s/#title#/アップデートが完了しました。/;
	$html =~ s/#msg#/$new_mjへのアップデートが正常に完了しました。/;
	$html =~ s/#html#/admin/;
	$html =~ s/#action#/show_license/;
	return $html;
}


#-----------------------------------------------------------------------------0
#										システムの再構築 確認
#------------------------------------------------------------------┤
sub remake_check {
	local($html) = @_;

	### 再構築実行ファイル一覧の作成
	my ($file_list,$file_name);
	&lib'openfile($system_log,*SYS);
	my $head = shift @SYS;
	foreach (@SYS) {
		my($file,$final_date,$data) = split(/\0/);
		my($dir,$name) = split(/\//,$file);
		my $buf = "$DIR{\"$dir\"}/$name";
		if (!-e $buf) {
			$buf .= ' （追加）';
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
#										システムの再構築
#------------------------------------------------------------------┤2006.04.19
sub remake_exe {
	local($html) = @_;
	($lc1) || (return);
	### ライセンス整理番号の読み込み
	local(@LCC);
	my $lcc_log = "$LogDir/lcc.$log_ext";
	&lib'openfile($lcc_log,*LCC);

	### CGIパーミッションの確認
	my($par) = (stat("admin.cgi"))[2];
	
	### ファイルの展開
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
	
	### 更新履歴の作成
	my($new_mj) = (split(/\t/,$new_head))[2];
	&lib'openfile($up_record_db,*UR_DB);
	$UR{'ur_name'} = $mjnm;
	$UR{'ur_time'} = $time;
	$UR{'ur_memo'} = "$mjnmの再構\築";
	$UR{'ur_list'} = $files;
	my $new_ur = &lib'make_log_line(\@UR_DB,\%UR);
	&lib'stokfile($up_record_log,$new_ur);
	
	$html =~ s/#title#/システムの再構\築が完了しました。/;
	$html =~ s/#msg#/$mjnmのシステムの再構\築が正常に完了しました。/;
	$html =~ s/#html#/admin/;
	$html =~ s/#action#/show_license/;
	return $html;
}


#-----------------------------------------------------------------------------0
#										作業履歴の表示
#------------------------------------------------------------------┤
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
			$dum =~ s/#title#/$UR{'ur_name'}へアップデート/;
		} else {
			$dum =~ s/#title#/$UR{'ur_name'}の再構\築/;
		}
		$UR{'ur_list'} =~ s/,/<BR>/g;
		$list .= &lib'change_key($dum,\@UR_DB,\%UR,'3-3WF');
	}
	if ($list) {
		$html = "$CUT[0]$list$CUT[2]";
	} else {
		$html = $html_error;
		$html =~ s/#title#/履歴はありませんでした。/;
		$html =~ s/#msg#/現在までの作業履歴はありませんでした。/;
	}

	return $html;
}



#-----------------------------------------------------------------------------0
#										戻り先URLの作成
#------------------------------------------------------------------┤2006.04.19
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
