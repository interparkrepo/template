#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����folder.pl [Ver.2007.12.05] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F2005.09.03
#|���������ŏI�X�V���F2007.12.05
#|��
#|������������������������������������������������������������������������������

#-----------------------------------------------------------------------------0
#										�t�H���_�Ǘ�
#------------------------------------------------------------------��
sub subroutine {
	&lib'openfile('folder.pl',*FOLDER);
	$title_bar = "�t�H���_�ݒ�";

	#---------------------------
	# ���X�g�\��
	if (!$action) {LIST:
		$return_html = &folder_list($html{1});
		
	#---------------------------
	# ���X�g�\��
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
#										�t�H���_�Ǘ�
#------------------------------------------------------------------��
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
#										�t�H���_�̕ύX
#------------------------------------------------------------------��2007.12.05
sub folder_change {
	local($html) = @_;

	### forder.pl�̃p�[�~�b�V�����m�F
	my $per_er;
	chmod 0666 ,"folder.pl";
	unless (-w "folder.pl") {
		$per_er = '�ucgi/folder.pl�v�̃p�[�~�b�V����������������܂���B<BR>�p�[�~�b�V�����́u666�v�ɕύX���Ă��������B<BR>';
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
				## �p�[�~�b�V�����G���[
				if ($per_er) {
					$error_msg{"$dir_code"} = $per_er;
					return $error_msg{"$dir_code"};
				}
				## �ړ��̎��s
				if (-d $FORM{"$dir_code"}) {
					my $rmdir = rmdir "$FORM{$dir_code}";
					if (!$rmdir) {
						$error_msg{"$dir_code"} = "�u$FORM{$dir_code}�v�t�H���_���ړ��ł��܂���ł����B<BR>�t�H���_�̒��Ƀt�@�C����t�H���_�������Ă��Ȃ������m�F���������B<BR>";
						return;
					}
					my $rename = rename("$dir_value","$FORM{$dir_code}");
					if ($rename) {
						my $new_line = "\$$dir_code = \"$FORM{\"$dir_code\"}\";\n";
						s/.*\n/$new_line/;
						last;
					} else {
						$error_msg{"$dir_code"} = "�u$FORM{$dir_code}�v�t�H���_���ړ��ł��܂���ł����B<BR>�t�H���_�̃p�[�~�b�V���������m�F���������B<BR>";
						return;
					}

				## �t�H���_���쐬���Ĉړ�
				} else {
					my $rename = rename("$dir_value","$FORM{$dir_code}");
					if ($rename) {
						chmod 0777 ,"$FORM{\"$dir_code\"}";
						my $new_line = "\$$dir_code = \"$FORM{\"$dir_code\"}\";\n";
						s/.*\n/$new_line/;
						last;
					} else {
						$error_msg{"$dir_code"} = "�u$FORM{\"$dir_code\"}�v�t�H���_���쐬�ł��܂���ł����B���炩���߈ړ���̃t�H���_���쐬���Ă����Ă��������B<BR>";
						return;
					}
				}
			}
		}
	}
	&lib'writefile('folder.pl',@FOLDER);

	$html =~ s/#title#/�t�H���_�̕ύX���������܂����B/;
	$html =~ s/#msg#/�u$dir_value�v���u$FORM{"$dir_code"}�v�ɕύX���܂����B/;
	$html =~ s/#html#/$FORM{'html'}/;
	$html =~ s/#action#//;
	return $html;
}



1;
