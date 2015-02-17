#|������������������C����G����I����-����P����a����r����k������������������������
#|���@�@��
#|���@�@����cgi-sub.pl [Ver.2008.03.28] ��
#|��
#|��������Copyright(C) MilleniaNet 2002
#|��������http://www.cgi-park.com
#|��������support@cgi-park.com
#|������������J�n���F2005.01.15
#|���������O��X�V���F2006.07.19
#|���������ŏI�X�V���F2008.03.28
#|��
#|������������������������������������������������������������������������������

#-----------------------------------------------------------------------------0
#										�t�H�[���f�[�^�̎擾
#------------------------------------------------------------------��
sub get_form_data_field {
	local($line) = @_;
	chop $line;
	($f_name,$f_title,$f_type,$f_length,$f_restrict,$f_convert,$f_etc,$f_list) = split(/\t/,$line);
}


#-----------------------------------------------------------------------------0
#										���O�t�@�C���̎擾
#------------------------------------------------------------------��
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
#										�\�[�g����
#------------------------------------------------------------------��
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
#										�t�H�[���ɒl����
#------------------------------------------------------------------��2006.07.19
sub form_initialize {
  local($html,@F_DATA) = @_;
	my($hidden);

	foreach (@F_DATA) {
	  &get_form_data_field($_);
		### HIDDEN�̐ݒ�
		if ($f_type eq 'hidden' || $f_type =~ /^time$/i || $f_type eq  'SERIAL') {
			$hidden .= qq|<INPUT type="hidden" name="$f_name" value=\"$FORM{"$f_name"}\">\n|;
		}
		### �����s�e�L�X�g�{�b�N�X
		if ($f_type eq 'textarea') {
			$FORM{"$f_name"} = &lib'unset_BR($FORM{"$f_name"});
			
		### �Z���N�g�{�b�N�X
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
			
		### �^�C���X�^���v
		} elsif ($f_type =~ /time/i) {
		  ($FORM{$f_name}) ? ($html =~ s/#D-$f_name#/&lib'get_time($FORM{$f_name},$time_key)/ge) :($html =~ s/#D-$f_name#//g);

		### ���W�I�{�^���E�`�F�b�N�{�b�N�X
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
		### ���X�g�̒l��\��
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
#										���̓`�F�b�N
#------------------------------------------------------------------��
sub check_form_data {
	local(@FORM) = @_;
	
	foreach (@FORM) {
		&get_form_data_field($_);
		$value = $FORM{"$f_name"};
		($f_convert) && ($value = &form::ValueConvert($value, $f_convert));

		$value_len = length($value);
		if ($value_len > $f_length && $f_length && $lenFlag ne 'ng') {
			if ($f_type eq 'file') {
				$error_msg{"$f_name"} = "�t�@�C���T�C�Y���I�[�o�[���Ă��܂��B$f_length byte�ȉ��ɂ��Ă��������B<BR>";
			} else {
				$len2 = $f_length / 2;
				$error_msg{"$f_name"} = "�����T�C�Y���I�[�o�[���Ă��܂��B���p�̏ꍇ��$f_length����(�S�p��$len2����)�ȓ��ɂ��Ă��������B<BR>";
			}
		}
		($f_type eq 'file') && (next);		### �A�b�v���[�h�̏ꍇ�����ŏI��
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
#										�f�[�^�̐؂���
#------------------------------------------------------------------��
sub cut_data{
	# �\�������̎w��
	local($linkcgi,$show_scale,@logbuf) = @_;
#	local($logline);
	$p = $FORM{'p'};
	$logline = @logbuf;
	($show_scale) || ($show_scale = $logline);
	($show_scale) || (return);

	$p = int($p);
	$allpage = int(($logline-1) / $show_scale) + 1;
	($p > 0) && ($p <= $allpage) || ($p = 1);
	
	# �\���͈͂̓���
	$t = $p * $show_scale;
	$f = $t - $show_scale + 1;
	$logno = $f;
	($t < $logline) ? ($next = $p + 1) : ($t = $logline);
	($f > 1) && ($prev = $p - 1);
	
	# �O���؂���
	unshift(@logbuf, "dmy");
	@logbuf= splice(@logbuf, $f, $show_scale);

	# �O��ւ̃����N
	if ($allpage < 20) {
		$pagelink = "�S$logline���@�yNo.$f �` No.$t�z";
		$pagelink .= " �^ ";
		($prev) && ($pagelink .= "<A HREF=\"$linkcgi&p=$prev\">�O��$show_scale��</A> �^ ");
		for(1 .. $allpage){
			$pagelink .= ($_ == $p) ? "<B>$_</B> " : "<A HREF=\"$linkcgi&p=$_\">$_</A> ";
		}
		($next) && ($pagelink .= "�^ <A HREF=\"$linkcgi&p=$next\">����$show_scale��</A>");
	} else {
		$pagelink = "�S$logline���@�yNo.$f �` No.$t�z�@";
		($prev) && ($pagelink .= "<A HREF=\"$linkcgi&p=$prev\">�O��$show_scale��</A>�@|�@");
		($next) && ($pagelink .= "<A HREF=\"$linkcgi&p=$next\">����$show_scale��</A>");
		$pagelink .= "�@[<B>$p/$allpage</B>]";
	}
	
	return(@logbuf);
}

#-----------------------------------------------------------------------------1
#										���C�Z���X�m�F
#------------------------------------------------------------------��2005.10.10
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
		($erflag) && (&lib'system_error("er101-$erflag",'���C�Z���X��񂪕s���Ȃ��߁A�Ǘ���ʂւ̃A�N�Z�X�����ۂ���܂����B'));
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
			      <TD class="font14">��\�p����: <B>$tl_date<\/B> �܂ŁB���C�Z���X�o�^��<A href=".\/admin.cgi?html=admin&action=lcs_form" target="$conf{'target'}">������<\/A></TD>
			    </TR>
			</TABLE>
EOF
			$html_header =~ s/<!-- lcs_link -->/$lcs_link/;
		}
	}
	($erflag) && (&lib'system_error("er201-$erflag",'���C�Z���X��񂪕s���Ȃ��߁A�Ǘ���ʂւ̃A�N�Z�X�����ۂ���܂����B'));
	if ($html ne 'menu') {
		($html_footer =~ /<HR class="black" size="1">/) || (&lib'system_error("er301",'���������s�ł��܂���B'));
		$html_footer =~ s/<HR class="black" size="1">/<HR size="1">$site_link/;
	}
	return 1;
}


$cgi_park = qq|<DIV align="center" class="font14B"><A href="$cphp" target="_blank" class="A2_purple">- CGI\-Park -</A></DIV>|;
package lib;

#������������������������������������������������������������������������������
#������������������������������������������������������������������������������

#-----------------------------------------------------------
#  Digest::SHA-1 (hex) 
#-----------------------------------------------------------
sub endecrypt {
    # �Í�Key
	use constant CRYPT_KEY => 'ys';
    # �_�C�W�F�X�g���W���[��Key
    use constant DIGEST_SHA1 => 'Digest/SHA1.pm';

    # �_�C�W�F�X�g�t���O
	my $digest = 0;
    foreach my $key(keys(%INC)){
        # SHA1���W���[�����C���X�g�[������Ă���ꍇ
        if($key eq DIGEST_SHA1) {
	        # ���W���[���錾
	        use Digest::SHA1 qw(sha1_hex);
	        $digest = 1;
	        last;
        }
    }
    my ($pass, $crypt) = @_;
    # �Í����̏ꍇ
    if(!defined($crypt)) {
        # SHA-1�֐����g�p
        if($digest == 1) {
            return CRYPT_KEY . sha1_hex(CRYPT_KEY . $pass);
        # �W����crypt�֐����g�p
        } else {
            return crypt($pass,CRYPT_KEY);
        }
    # �������̏ꍇ
    } else {
        # salt�͐擪��2�����iCRYPT_KEY�j�𔲂��o��
        my $salt = substr($crypt, 0, length(CRYPT_KEY));

        # SHA-1�֐����g�p
        if($digest == 1) {
            # �ƍ�
            return $crypt eq ($salt . sha1_hex($salt . $pass)) ? 1 : 0;
        # �W����crypt�֐����g�p
        } else {
            return $crypt eq (crypt($pass,$salt)) ? 1 : 0;
        }
    }
}


#-----------------------------------------------------------------------------0
#										�p�X���[�h�̈Í����E�ƍ� Digest::SHA-1 (hex)
#------------------------------------------------------------------��
# my $shaPw = &lib'crypt($passwd);	# �Í���
# my $ret = &lib'crypt($passwd, $shaPw);	# �ƍ�
sub crypt {
	my($passwd,$shaPw) = @_;
	eval "use Digest::SHA1 qw(sha1_hex)";
	
	my $type = 'sha1';
	($@) && ($type = 'crypt');
	
	#---------------------------
	# �Í���
	if (!$shaPw) {
		my @str = ('a' .. 'f', 0 .. 9);
		my $salt; 
		for (1 .. 4) { 
			$salt .= $str[int(rand(@str))]; 
		}
    # SHA-1�֐����g�p
		if ($type eq 'sha1') {
			return $salt . sha1_hex($salt . $passwd);
			
    # �W����crypt�֐����g�p
		} else {
			return crypt($passwd, $salt);
		}
		
	#---------------------------
	# �ƍ�
	} else {
		my $salt = substr($shaPw, 0, 4);

    # SHA-1�֐����g�p
		if ($type eq 'sha1') {
			return $shaPw eq ($salt . sha1_hex($salt . $passwd)) ? 1 : 0;
			
    # �W����crypt�֐����g�p
		} else {
			return $shaPw eq (crypt($passwd, $salt)) ? 1 : 0;
		}
	}
}


#-----------------------------------------------------------------------------0
#										�t�@�C�����J���āA���g��z��ɑ������
#------------------------------------------------------------------��
sub openfile{
	local($filename, *buf) = @_;
	
	($filename) || &system_error("er102",'�t�@�C���ϐ���������܂���ł����B',"lib::openfile�����G���[�B�t�@�C�����s���B");
	(-e $filename) || return(0);
	
	open(FILE, "$filename") || &system_error("er202",'�p�[�~�b�V�����G���[',"�u$filename�v�̃p�[�~�b�V�������m�F���Ă��������B");
	flock(FILE, 1) or &system_error("er302",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	@buf = <FILE>;
	close(FILE);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���Ƀf�[�^������������
#------------------------------------------------------------------��
sub writefile {
	local($logfile,@buf) = @_;
	(-e $logfile) || &lib'makefile($logfile);
	chmod 0666,$logfile;
	
	open(FILE, "+<$logfile") or &system_error("er106",'�t�@�C���̏��������Ɏ��s���܂����B',"�u$logfile�v�̏��������Ɏ��s���܂����B�t�H���_�܂��̓p�[�~�b�V�������m�F���Ă��������B");
	flock(FILE, 2) or &system_error("er206",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	seek(FILE, 0, 0);
	print FILE @buf;
	truncate(FILE, tell(FILE));
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���Ƀf�[�^��ǉ�����(�X�g�b�N)
#------------------------------------------------------------------��
sub stokfile {
	local($logfile,$buf) = @_;
	chmod 0666,$logfile;

	if (!open (FILE, ">>$logfile")) {&system_error("er105",'�ǋL�G���[',"�u$logfile�v�̒ǋL�Ɏ��s���܂����B");}
	flock(FILE, 2) or &system_error("er205",'�A�N�Z�X�����G���Ă��܂��B���΂炭���Ă����蒼���Ă��������B');
	seek(FILE, 0, 2);
	print FILE $buf;
	close(FILE);
}

#-----------------------------------------------------------------------------0
#										�t�@�C���̍쐬
#------------------------------------------------------------------��
sub makefile{
	local($filename) = @_;
	($filename) || &system_error("er103",'�t�@�C���ϐ���������܂���ł����B','lib::makefile�����G���[�B�t�@�C�����s���B');

	open(FILE, ">$filename") || &system_error("er203",'�t�@�C���쐬�G���[',"�u$filename�v���쐬���邱�Ƃ��o���܂���ł����B�t�H���_�܂��̓p�[�~�b�V�������m�F���Ă��������B");
	close(FILE);
	chmod 0666,$filename;
}

#-----------------------------------------------------------------------------0
#										�t�H���_���J���āA���g��z��ɑ������
#------------------------------------------------------------------��
sub opendir{
	local($dir, *buf) = @_;
	
	(-e $dir) || &system_error("er104",'�t�H���_�ϐ���������܂���ł����B','lib::opendir�����G���[�B�t�H���_���s���B');
	opendir (DIR, "$dir") || &system_error("er204",'�t�H���_�I�[�v���G���[',"�u$dir�v�t�H���_���J�����Ƃ��o���܂���ł����B");
	@buf = readdir(DIR);
	closedir(DIR);
	
	(@buf) ? return(1) : return(0);
}

#-----------------------------------------------------------------------------0
#										�V�X�e���G���[��
#------------------------------------------------------------------��
# &lib'system_error($error_code,$print_msg,$send_msg);
# $error_code -> �G���[���ʃR�[�h
# $print_msg  -> ��ʏo�͗p���b�Z�[�W
# $send_msg   -> ���[�����M�p���b�Z�[�W�i����̏ꍇ���[�����M�j
sub system_error {
	local($error_code,$print_msg,$send_msg) = @_;
	### �񍐃G���[�쐬
	my $ertime = &lib'get_time($main'time,'3-3');
	my($env,$form,$env2,$form2);
	# ���ϐ�
	foreach (sort keys %ENV) {
		$env .= qq|$_		= $ENV{"$_"}\n|;
		$env2 .= qq|$_=$ENV{"$_"}&|;
	}
	# FORM�ϐ�
	foreach (sort keys %main'FORM) {
		$form .= qq|$_		= $main'FORM{"$_"}\n|;
		$form2 .= qq|$_=$main'FORM{"$_"}&|;
	}
	$env2 =~ s/\n//g;
	$form2 =~ s/\n//g;
	
	### �G���[��
	if ($send_msg && $main'conf{'suport_email'}) {
		my $mail_title = "�V�X�e���G���[����[$ENV{'HTTP_HOST'}]";
		my $mail_body = "
���G���[�R�[�h�@�@�@�@�F$error_code
���v���O�����R�[�h�@�@�F$main'fckey
��CGI���N�������y�[�W �F$ENV{'HTTP_REFERER'}
��CGI�X�N���v�g���@�@ �F$ENV{'SCRIPT_NAME'}
���G���[���������@�@�@�F$ertime
���G���[���e�@�@�@�@�@�F$send_msg

----- FORM�ϐ� ------
$form

----- ���ϐ� ------
$env
		";
		&lib'send_mail($main'conf{'suport_email'},$main'conf{'suport_email'},$mail_title,$mail_body);
	}
	$html_body = $main'html_error;
	$html_body =~ s/#msg#/�G���[�R�[�h�F$error_code<BR>$print_msg/;
	$print_html = "$main'html_header" . "$html_body" . "$main'html_footer";
	$print_html =~ s/#title#/�G���[���������܂����I/g;

	### �G���[���O�̋L�^
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
#										���[�����M
#------------------------------------------------------------------��2006.04.19
sub send_mail{
	local($mailto, $mailfrom, $mailtitle, $mailmain,$mailbcc) = @_;
	if (!$mailto) {
		($main'conf{'suport_email'}) || (return);
		$mailto = "$main'conf{'suport_email'}";
		$mailmain = "���Đ�s���̂��ߓ]�����܂����B\n\n$mailmain";
	}
	### �ԐM�p�A�h���X
	my $reply;
	if ($main'reply_to) {
		$reply = $main'reply_to;
	}

	### Sendmail�I�v�V����
	my $sendmail_opt = ' -t';
	if($main'conf{'f_option'}) {
		$sendmail_opt .= " -f'$main'conf{'f_option'}'";
	}
	
	#HTML�̃f�R�[�h
	$mailmain =~ s/<BR>/\n/gs;
	$mailmain =~ s/&LT;/</gs;
	$mailmain =~ s/&GT;/>/gs;
	$mailmain =~ s/&QUOT;/"/gs;
	$mailmain =~ s/<UP\/>$//s;
	&jcode'convert(*mailmain, 'jis');

	### MIME-Base64�G���R�[�h
	chomp $mailtitle;
	if (!$INC{"$main'LibDir/mimew.pl"}) {
		require "$main'LibDir/mimew.pl";
	}
	$mailtitle = main'mimeencode($mailtitle);
	$mailto = main'mimeencode($mailto);
	$mailfrom = main'mimeencode($mailfrom);

	open(MAIL,"| $main'conf{'sendmail'}$sendmail_opt") || &lib'system_error('er207','���[���̑��M�Ɏ��s���܂����B');
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
#										���݂̎����𓾂�
#------------------------------------------------------------------��2008.03.28
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
		$week = ('��','��','��','��','��','��','�y') [$wday];
		$week = "($week)";
		$format =~ s/W//;
	}
	
	my($format,$pa) = split(/:/,$format);
	if ($pa) {
		$pa1 = $pa;$pa2 = $pa;$pa3 = '';
	} else {
		$pa1 = '�N';$pa2 = '��';$pa3 = '��';
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
		$hash{'W'} = ('��','��','��','��','��','��','�y') [$wday];
		return %hash;
	}
	return "$year/$mon/$mday/$hour/$min/$sec/$wday"
}

#1:2007.08.28	$formmat=hash�Ńn�b�V���ϐ��֕Ԃ��悤�ɋ@�\�ǉ�
#2:2008.03.28 2-*F�ŗj�����o�Ȃ��o�O�𒲐�

#-----------------------------------------------------------------------------0
#										�g�s�l�k�t�@�C���̎�荞��
#------------------------------------------------------------------��
sub get_html {
	# $file_name��folder.pl�̃V�X�e��HTML�t�@�C���i�[�t�H���_
	# *buf�͌Ăяo�����ɒl��ԋp����z��B�錾���͋�B
	local($file_name,*buf) = @_;
	
	# ���L�A�S�̓X�J���[�ϐ��Ő錾�̂݁B
	local($get_main,$n,@SET_MAIN,@M_HTML);

	### �ڍ�HTML
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
#										�o�^�p���O�̍쐬
#------------------------------------------------------------------��2005.10.10
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
		### �^�u�̍폜
		$hv =~ s/\t/ /g;
		### ���s�R�[�h�̕ϊ�
		$hv = &lib'set_BR($hv);
		$line .= "$hv\t";
	}
	$line .= "\t\t\t0\n";
	return $line;
}


#-----------------------------------------------------------------------------0
#										���O���C���̎擾
#------------------------------------------------------------------��
sub get_log_line {
	local($key,@LOG) = @_;
	foreach (@LOG) {
		if (/^$key\t/) {return $_;}
	}
	return;
}


#-----------------------------------------------------------------------------0
#										���O�t�@�C���̏�������
#------------------------------------------------------------------��
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
		### �o�b�N�A�b�v
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
#										�L�[�̕ϊ�
#------------------------------------------------------------------��2007.05.15
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
		### ���X�g�̒l��\��
		if ($main'f_list && $html =~ /#N-$f_name#/) {
			my @LIST = split(/,/,$main'f_list);
			my ($flist);
			foreach $lst (@LIST) {
				my($value,$name) = split(/\:/,$lst);
				($name) || ($name = $value);
				if ($BUF{$f_name} =~ /\0/) {
					my @VAL = split(/\0/,$BUF{$f_name});
					if (grep(/^$value$/,@VAL)) {
						$flist .= "$name�A";
					}
				} else {
					if ($BUF{$f_name} eq $value) {
						$html =~ s/#N-$f_name#/$name/g;
						last;
					}
				}
			}
			$flist =~ s/�A$//;
			$html =~ s/#N-$f_name#/$flist/g;
		}
		### ������\��
		if ($html =~ /#Y-$f_name#/) {
			if ($BUF{$f_name} !~ /[^0-9]/) {
				$html =~ s/#Y-$f_name#/&lib'set_digit($BUF{$f_name})/eg;
			} else {
				$html =~ s/#Y-$f_name#/$BUF{$f_name}/g;
			}
		}
		### URL�G���R�[�h
		if ($html =~ /#E-$f_name#/) {
			$html =~ s/#E-$f_name#/&lib'url_encode($BUF{$f_name})/eg;
		}
		###�@HIDDEN�̍쐬
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
#										���я��̕ύX
#------------------------------------------------------------------��
# $file   => �����Ώۂ̃t�@�C��
# $key    => �L�[�ƂȂ镶����i�V���A���R�[�h�j
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
#										���[�U�[��IP�A�h���X�𓾂�
#------------------------------------------------------------------��2007.04.05
sub get_ip{
	# �z�X�g�����擾
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
#										�����̌��\��
#------------------------------------------------------------------��2005.08.23
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
#										URL�G���R�[�h
#------------------------------------------------------------------��
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
#										���s�R�[�h����
#------------------------------------------------------------------��
###-------- ���s�R�[�h�� <BR> �ɓ���
sub set_BR {
	local($value) = @_;
	
	$value =~ s/\r\n/<BR>/g;
	$value =~ s/\r/<BR>/g;
	$value =~ s/\n/<BR>/g;
	
	return ($value);
}

###-------- <BR>�� \n �ɓ���
sub unset_BR {
	local($value) = @_;
	$value =~ s/<BR>/\n/ig;
	return ($value);
}

###-------- ���s�R�[�h�� \n �ɓ���
sub unify_return_code {
	my($String) = @_;
	$String =~ s/\x0D\x0A/\n/g;
	$String =~ s/\x0D/\n/g;
	$String =~ s/\x0A/\n/g;
	return $String;
}


#-----------------------------------------------------------------------------0
#										�ϐ��`�F�b�N
#------------------------------------------------------------------��
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
#������������������������������������������������������������������������������
#������������������������������������������������������������������������������

#-----------------------------------------------------------------------------0
#										�N�b�L�[�̎擾
#------------------------------------------------------------------��
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
#										�N�b�L�[�̐ݒ�
#------------------------------------------------------------------��2006.07.19
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
#										���O�A�E�g
#------------------------------------------------------------------��
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
#������������������������������������������������������������������������������
#������������������������������������������������������������������������������

#-----------------------------------------------------------------------------0
#										���͒l�����`�F�b�N
#------------------------------------------------------------------��
sub InputRestrict {
	local($value,$restrict) = @_;
	local($value_len,$err_no,$rule,$error_msg);
	
	my %error_list = (
		'1' => '#NAME#�́A�ȗ��ł��܂���B<BR>',
		'2'  => '#NAME#�́A���p�����Ŏw�肵�Ă��������B<BR>',
		'3'  => '#NAME#�́A�S�p�����Ŏw�肵�Ă��������B<BR>',
		'4'  => '#NAME#�́A���p�A���t�@�x�b�g�Ŏw�肵�Ă��������B<BR>',
		'5'  => '#NAME#�́A�S�p�A���t�@�x�b�g�Ŏw�肵�Ă��������B<BR>',
		'6'  => '#NAME#�́A���p�p���Ŏw�肵�Ă��������B<BR>',
		'7'  => '#NAME#�́A�S�p�p���Ŏw�肵�Ă��������B<BR>',
		'8'  => '#NAME#�́A����������܂���B<BR>',
		'9'  => '#NAME#�́A���p�p��������[.],[-],[_],[?]�Ŏw�肵�Ă��������B<BR>',
		'10' => '#NAME#�́A����������܂���B<BR>',
		'20' => '#NAME#�́A�n�C�t���Ȃ���10����������11���̔��p�����Ŏw�肵�Ă��������B<BR>',
		'21' => '#NAME#�́A�n�C�t��������10����������11���̔��p�����Ŏw�肵�Ă��������B<BR>',
		'22' => '#NAME#�́A�n�C�t���Ȃ��Ŕ��p����7���Ŏw�肵�Ă��������B<BR>',
		'23' => '#NAME#�́A�n�C�t�������Ĕ��p����7���Ŏw�肵�Ă��������B<BR>',
		'31' => '#NAME#�́A�S�p�Ђ炪�ȂŎw�肵�Ă��������B<BR>',
		'32' => '#NAME#�́A�S�p�J�^�J�i�Ŏw�肵�Ă��������B<BR>'
	);
	
	$value_len = length($value);
	my @rules = split(/:/, $restrict);
	for $rule (@rules) {
		if($rule eq '1') {				#���͂Ȃ�
			if ($value eq '') {
				$err_no = $rule;
			}
		} elsif(!$value) {
			next;
		} elsif($rule eq '2') {			#���p�����̂�
			if($value =~ /[^0-9]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '3') {			#�S�p�����̂�
			$value =~ s/\xa3[\xb0-\xbf]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '4') {			#���p�A���t�@�x�b�g�̂�
			if($value =~ /[^a-zA-Z]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '5') {			#�S�p�A���t�@�x�b�g�̂�
			$value =~ s/\xa3[\xc0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '6') {			#���p�p���̂�
			if($value =~ /[^0-9a-zA-Z\.\-\_]/) {
				$err_no = $rule;
			}
		} elsif($rule eq '7') {			#�S�p�p���̂�
			$value =~ s/\xa3[\xb0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '8') {			#���[���A�h���X
			if($value =~ /[^a-zA-Z0-9\@\.\-\_\?]/) {
				$err_no = $rule;
			}
			unless($value =~ /^[^\@]+\@[^\@]+$/) {
				$err_no = $rule;
			}
			if($value =~ /\.$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '9') {			#�t�@�C����
			if($value =~ /[^a-zA-Z0-9\@\.\-\_\?]/) {
				$err_no = $rule;
			}
#		} elsif($rule eq '10') {		#URL

#			if ($value =~ /[\w|\!\#\&\=\-\%\@\~\;\+\:\.\?\/]+/) {
#				$err_no = $rule;
#			}
		} elsif($rule eq '20') {		#�n�C�t���Ȃ��̓d�b�ԍ��i���p�j
			if($value =~ /[^0-9]/) {
				$err_no = $rule;
			}
			if($value_len > 11 || $value_len < 10) {
				$err_no = $rule;
			}
		} elsif($rule eq '21') {		#�n�C�t������̓d�b�ԍ��i���p�j
			unless($value =~ /^0[0-9]+\-[0-9]+\-[0-9]+$/) {
				$err_no = $rule;
			}
			if($value_len > 13 || $value_len < 12) {
				$err_no = $rule;
			}
		} elsif($rule eq '22') {		#�n�C�t���Ȃ��̗X�֔ԍ��i���p�j�i��F1234567�j
			unless($value =~ /^[0-9]{7}$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '23') {		#�n�C�t������̗X�֔ԍ��i���p�j�i��F123-4567�j
			unless($value =~ /^[0-9]{3}\-[0-9]{4}$/) {
				$err_no = $rule;
			}
		} elsif($rule eq '31') {		#�S�p�Ђ炪�Ȃ̂�
			$value =~ s/\xa1\xa1//g;
			$value =~ s/ //g;
			$value =~ s/\xA1[\xA6\xBC\xB3\xB4]//g;		## [�E�[�R�S]������
			$value =~ s/\xa4[\xa0-\xff]//g;
			if($value) {
				$err_no = $rule;
			}
		} elsif($rule eq '32') {		#�S�p�J�^�J�i�̂�
			$value =~ s/\xa1\xa1//g;
			$value =~ s/ //g;
			$value =~ s/\xA1[\xA6\xBC\xB3\xB4]//g;		## [�E�[�R�S]������
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
#										���͒l�ϊ�
#------------------------------------------------------------------��
sub ValueConvert {
	my($value, $rule_str) = @_;
	my @rules = split(/:/, $rule_str);
	my $rule;
	for $rule (@rules) {
		if($rule eq '1') {		#�S�p�����ƑS�p�n�C�t���𔼊p�ɕϊ�
			&jcode::tr(\$value, '�O�P�Q�R�S�T�U�V�W�X�|', '0123456789-');
		} elsif($rule eq '2') {	#���p�����Ɣ��p�n�C�t����S�p�ɕϊ�
			&jcode::tr(\$value, '0123456789-', '�O�P�Q�R�S�T�U�V�W�X�|');
		} elsif($rule eq '3') {	#�S�p�E���p�n�C�t�����폜
			my $zen_hyphen = '�|';
			&jcode::convert(\$zen_hyphen, 'euc', 'sjis');
			&jcode::convert(\$value, 'euc', 'sjis');
			$value =~ s/$zen_hyphen//g;
			&jcode::convert(\$value, 'sjis', 'euc');
			$value =~ s/\-//g;
		} elsif($rule eq '4') {	#�S�p�A���t�@�x�b�g�𔼊p�ɕϊ�
			&jcode::tr(\$value, '�����������������������������������������������������`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
		} elsif($rule eq '5') {	#���p�A���t�@�x�b�g��S�p�ɕϊ�
			&jcode::tr(\$value, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '�����������������������������������������������������`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y');
		} elsif($rule eq '6') {	#���p�J�i��S�p�J�i�ɕϊ�
			&jcode::h2z_sjis(\$value);
		} elsif($rule eq '7') {	#���[���A�h���X�𔼊p�ɕϊ�
			&jcode::tr(\$value, '�����������������������������������������������������`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
			&jcode::tr(\$value, '�O�P�Q�R�S�T�U�V�W�X�|�Q', '0123456789-_');
			$value =~ s/��/\@/g;
			$value =~ s/�D/\./g;
		} elsif($rule eq '10') {	#["]��[�h]�ɕϊ�
			$value =~ s/"/�h/g;
		} elsif($rule eq '11') {	#�^�O�𖳌��ɂ���
			$value = &lib'cut_tab($value);
		}
	}
	return $value;
}



1;
