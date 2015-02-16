#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����setup.pl [Ver.2010.11.15] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F2006.04.19
#|���������ŏI�X�V���F2010.11.15
#|��
#|������������������������������������������������������������������������������

#-----------------------------------------------------------------------------0
#										�����ݒ�
#------------------------------------------------------------------��
### Perl�R�[�h�̈��k�������s�Ȃ�Ȃ��t�@�C��
@no_pl = ('jcode.pl','cgi-lib.pl','mimer.pl','mimew.pl');

#-----------------------------------------------------------------------------0
#										�V�X�e���t�@�C���̈��k����
#------------------------------------------------------------------��
sub subroutine {
	&setup_conf;
	$title_bar = "�V�X�e���t�@�C���̈��k����";

	#---------------------------
	# ���X�g�\��
	if (!$action || $FORM{'checked'}) {LIST:
		$return_html = &file_list($html{1});
		
	#---------------------------
	# ���k����
	} elsif ($action eq 'exe') {
		$return_html = &exe($html_msgbox);
		
	#---------------------------
	# �ʕϊ�
	} elsif ($action eq 'change') {
		$return_html = &change($html_msgbox);

	}

	return $return_html;
}

#-----------------------------------------------------------------------------2
#										�t�@�C�����X�g
#------------------------------------------------------------------��2010.11.15
sub file_list {
	local($html) = @_;
	
	&lib'opendir("..",*DIR1);
	my @CUT = split(/<!-- CUT -->/,$html);
	my $list;
	foreach $d1 (@DIR1) {
		### ���O����
		($d1 =~ /[a-z]/) || (next);
		($d1 eq 'Thumbs.db') && (unlink '../Thumbs.db');
		($d1 =~ /\./) && (next);
		($d1 eq 'log') && (next);
#		($d1 eq 'image') && (next);
		
		my $dum1 = @CUT[1];
		$dum1 =~ s/#dir#/$d1/g;
		$list .= $dum1;
		&lib'opendir("../$d1",*DIR2);
		foreach $d2 (@DIR2) {
			($d2 =~ /[a-z]/) || (next);
			($d2 eq 'Thumbs.db') && (unlink '../$d1/Thumbs.db');
			($d1 eq 'cgi' && ($d2 eq 'conf.pl' || $d2 eq 'folder.pl')) && (next);
			($d2 eq 'css_sample.htm' || $d2 eq 'setup.pl' || $d2 eq 'setup.htm' || $d2 eq 'setup.cgi') && (next);
			$dum2 = @CUT[2];
			$dum2 =~ s/#dir#/$d1/g;
			$dum2 =~ s/#file#/$d2/g;
			$dum2 =~ s/#size#/&get_file_size("..\/$d1\/$d2")/e;
			### �o�[�W�������̎擾
			if ($d2 =~ /.pl$/ || $d2 =~ /.cgi$/ || $d2 =~ /.htm$/) {
				local (@buf);
				&lib'openfile("..\/$d1\/$d2",*buf);
				my $buf = join("",@buf);
				if ($buf =~ /\[Ver\.(.*)\]/) {
					my $ver = $1;
					$dum2 =~ s/#ver#/$ver/g;
				}
			}
			if ($FORM{'checked'} && ($d1 eq 'image' || $d1 eq 'form' || $d1 eq 'item')) {
				$dum2 =~ s/#checked#//;
			}
			$list .= $dum2;
			$select .= qq|<OPTION value="$d1/$d2">$d1/$d2</OPTION>\n|;
		}
	}
	if ($FORM{'checked'}) {
		$list =~ s/#checked#/checked/g;
	} else {
		$list =~ s/#checked#//g;
	}
	$list =~ s/#ver#//g;
	$html = "@CUT[0]$list@CUT[3]";

	$html =~ s/<!-- file1 -->/$select/;
	$html =~ s/#pro_name#/$mjnm/g;
	$html =~ s/#final_date#/$fud/g;
	$html =~ s/#last_date#/$lud/g;
	$html =~ s/#fckey#/$fckey/g;
	$html =~ s/#apa#/$apa/g;
	return $html;
}

# 2:2010.11.15 �S�I����image�����O

#-----------------------------------------------------------------------------0
#										�t�@�C���T�C�Y�̎擾
#------------------------------------------------------------------��
sub get_file_size {
	local($file) = @_;
	my @KI = ('Byte','KB','MB','GB','TB');
	my $size = (stat("$file"))[7];
	my $n = 0;
	while ($size > 1024) {
		$n++;
		$size = sprintf("%.1f",($size / 1024));
	}

	$size ? return "$size@KI[$n]" : 0;
}


#-----------------------------------------------------------------------------3
#										���k���s
#------------------------------------------------------------------��2006.04.19
sub exe {
	local($html) = @_;
	my $data = "$FORM{'fckey'}\0$FORM{'apa'}\0$FORM{'pro_name'}\0$FORM{'final_date'}\0$FORM{'last_date'}\0$cphp\0$cpem\0\n";

	### ���s�t�@�C����擪�ɂ���
	my $exe_pl = 'lib/exe.pl';
	if ($FORM{'file_name'} =~ /\0$exe_pl/) {
		$FORM{'file_name'} =~ s/\0$exe_pl//;
		$FORM{'file_name'} = "$exe_pl\0$FORM{'file_name'}";
	}
	my @LIST = split(/\0/,$FORM{'file_name'});
	foreach (@LIST) {
		my $file;
		my($f,$n) = split(/\//);
		if ((/pl$/ || /cgi$/) && !(grep(/^$n$/,@no_pl))) {
			$file = &make_pl($_);
			if ($file =~ /&lib'check\(/) {
				$html_error =~ s/#title#/���k���s�I/;
				$html_error =~ s/#msg#/�u$_�v���ɕϐ��`�F�b�N���c���Ă��܂��B/;
				return $html_error;
			}
		} else {
			$file = &make_file($_);
		}
		$file = reverse $file;
		my $log = "$_\0$FORM{\"ver_$_\"}\0$file\0\n";
		$data .= $log;
	}
	

	#---------------------------
	# �V�X�e���t�@�C���̍쐬
	if ($FORM{'system'}) {
		### �Ǘ���ʃg�b�v�y�[�W���쐬
		my $file = &make_file("index.cgi");
		$file = reverse $file;
		$data .= "/index.cgi\0\0$file\0\n";
		
		### �Z�b�g�A�b�v�C���f�b�N�X�̍쐬
		&lib'writefile($system_log,$data);

	#---------------------------
	# �A�b�v�f�[�g�t�@�C���̍쐬
	} elsif ($FORM{'updata'}) {
		($FORM{'memo'}) || ($FORM{'memo'} = ' ');
		$data .= &lib'set_BR($FORM{'memo'});
		my $ld = $FORM{'final_date'};
		$ld =~ s/\.//g;
		my $upfile = "../../update/$FORM{'fckey'}\-$ld.cpm";
		&lib'writefile($upfile,$data);
	}

	$html =~ s/#title#/�������������܂����B/;
	$html =~ s/#msg#/���k�������������܂����B/;
	$html =~ s/#html#/setup/;
	$html =~ s/#action#//;
	return $html;
}


#-----------------------------------------------------------------------------0
#										�ʕϊ�
#------------------------------------------------------------------��
sub change {
	local($html) = @_;

	my $file;
	if ($FORM{'file1'} =~ /pl$/ || $FORM{'file1'} =~ /cgi$/) {
		$file = &make_pl($FORM{'file1'});
	} else {
		$file = &make_file($FORM{'file1'});
	}
	$file =~ s/\[\\n\]/\n/g;
	&lib'writefile($FORM{'file2'},$file);

	$html =~ s/#title#/�������������܂����B/;
	$html =~ s/#msg#/�ʕϊ��������������܂����B/;
	$html =~ s/#html#/setup/;
	$html =~ s/#action#//;
	return $html;
}


#-----------------------------------------------------------------------------0
#										���k����(PL)
#------------------------------------------------------------------��
sub make_pl {
	local($file) = @_;
	local(@FILE);
	&lib'openfile("../$file",*FILE);
	my $make;
	foreach $buf (@FILE) {;
		$buf =~ s/\t//g;
		$buf = &lib'unify_return_code($buf);
		if ($buf !~ /^#!\//) {
			$buf =~ s/^#.*\n//g;
		}
		if ($buf !~ /=<</) {
			$buf =~ s/;\n/;/g;
			$buf =~ s/{\n/{/g;
			$buf =~ s/}\n/}/g;
		}
		($buf eq "\n") && (next);
		($buf) || (next);
		$buf =~ s/\n/\[\\n\]/g;
		$make .= $buf;
	}
	return $make;
}


#-----------------------------------------------------------------------------0
#										���k����
#------------------------------------------------------------------��
sub make_file {
	local($file) = @_;
	local(@FILE);
	&lib'openfile("../$file",*FILE);
	my $make = join("",@FILE);
	$make = &lib'unify_return_code($make);
	$make =~ s/\n/\[\\n\]/g;
	return $make;
}




1;
