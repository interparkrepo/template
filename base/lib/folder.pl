#|┏━━┳━━━━━C━━G━━I━━-━━P━━a━━r━━k━━━━━━━━━━━━
#|┃　　┃
#|┃　　┗┫folder.pl [Ver.2007.12.05] ┃
#|┃
#|┠──┨Copyright(C) MilleniaNet 2002
#|┠──┨http://www.cgi-park.com
#|┠──┨support@cgi-park.com
#|┠──┨製作開始日：2005.01.15
#|┠──┨前回更新日：2005.09.03
#|┠──┨最終更新日：2007.12.05
#|┃
#|┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#-----------------------------------------------------------------------------0
#										フォルダ管理
#------------------------------------------------------------------┤
sub subroutine {
	&lib'openfile('folder.pl',*FOLDER);
	$title_bar = "フォルダ設定";

	#---------------------------
	# リスト表示
	if (!$action) {LIST:
		$return_html = &folder_list($html{1});
		
	#---------------------------
	# リスト表示
	} elsif ($action eq 'change') {
		$return_html = &folder_change($html_msgbox);
		if (%error_msg) {
			&lib'openfile('folder.pl',*FOLDER);
			goto LIST;
		}

	}

	return $return_html;
}

#-----------------------------------------------------------------------------0
#										フォルダ管理
#------------------------------------------------------------------┤
sub folder_list {
	local($html) = @_;
	my @CUT = split(/<!-- CUT -->/,$html);
	
	my $list;
	foreach (@FOLDER) {
		chop;
		if (/^\$/) {
			$dir_name =~ s/#//g;
			$dir_name =~ s/ //g;
			s/ //g;
			s/"//g;
			s/\;//g;
			s/\$//;
			($dir_code,$dir_value) = split(/=/);
			$dummy = $CUT[1];
			$dummy =~ s/#dir_name#/$dir_name/g;
			$dummy =~ s/#dir_code#/$dir_code/g;
			$dummy =~ s/#dir_value#/$dir_value/g;
			$dummy =~ s/<!-- ER_$dir_code -->/$error_msg{"$dir_code"}/g;
			$list .= $dummy;
		}
		if (/^#/) {
			$dir_name = $_;
		}
	}
	$html = "$CUT[0]$list$CUT[2]";
	return $html;
}


#-----------------------------------------------------------------------------2
#										フォルダの変更
#------------------------------------------------------------------┤2007.12.05
sub folder_change {
	local($html) = @_;

	### forder.plのパーミッション確認
	my $per_er;
	chmod 0666 ,"folder.pl";
	unless (-w "folder.pl") {
		$per_er = '「cgi/folder.pl」のパーミッションが正しくありません。<BR>パーミッションは「666」に変更してください。<BR>';
	}
	
	foreach (@FOLDER) {
		if (/^\$/) {
			my $buf = $_;
			chop $buf;
			$buf =~ s/ //g;
			$buf =~ s/"//g;
			$buf =~ s/\;//g;
			$buf =~ s/\$//;
			($dir_code,$dir_value) = split(/=/,$buf);
			if ($FORM{"btn_$dir_code"}) {
				if ($FORM{"$dir_code"} eq $dir_value) {$error_msg{1} = '1';return;}
				## パーミッションエラー
				if ($per_er) {
					$error_msg{"$dir_code"} = $per_er;
					return $error_msg{"$dir_code"};
				}
				## 移動の実行
				if (-d $FORM{"$dir_code"}) {
					my $rmdir = rmdir "$FORM{$dir_code}";
					if (!$rmdir) {
						$error_msg{"$dir_code"} = "「$FORM{$dir_code}」フォルダを移動できませんでした。<BR>フォルダの中にファイルやフォルダが入っていないかご確認ください。<BR>";
						return;
					}
					my $rename = rename("$dir_value","$FORM{$dir_code}");
					if ($rename) {
						my $new_line = "\$$dir_code = \"$FORM{\"$dir_code\"}\";\n";
						s/.*\n/$new_line/;
						last;
					} else {
						$error_msg{"$dir_code"} = "「$FORM{$dir_code}」フォルダを移動できませんでした。<BR>フォルダのパーミッションをご確認ください。<BR>";
						return;
					}

				## フォルダを作成して移動
				} else {
					my $rename = rename("$dir_value","$FORM{$dir_code}");
					if ($rename) {
						chmod 0777 ,"$FORM{\"$dir_code\"}";
						my $new_line = "\$$dir_code = \"$FORM{\"$dir_code\"}\";\n";
						s/.*\n/$new_line/;
						last;
					} else {
						$error_msg{"$dir_code"} = "「$FORM{\"$dir_code\"}」フォルダを作成できませんでした。あらかじめ移動先のフォルダを作成しておいてください。<BR>";
						return;
					}
				}
			}
		}
	}
	&lib'writefile('folder.pl',@FOLDER);

	$html =~ s/#title#/フォルダの変更が完了しました。/;
	$html =~ s/#msg#/「$dir_value」を「$FORM{"$dir_code"}」に変更しました。/;
	$html =~ s/#html#/$FORM{'html'}/;
	$html =~ s/#action#//;
	return $html;
}



1;
