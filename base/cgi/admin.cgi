#!/usr/bin/perl -w

#|================#
#| �v���O������� #
#|================#------------------------------------------#
#|                                                           #
#|    CGI-Park ���l�V���[�Y                                  #
#|    �������l Ver 1.0.0                                     #
#|    Produced by [MilleniaNet] Yuma Suda                    #
#|    admin.cgi [Ver.2007.12.05]�@                           #
#|                                                           #
#|    ����J�n���F2005.01.15 �@                              #
#|    �O��X�V���F2006.04.19  �@                             #
#|    �ŏI�X�V���F2007.12.05  �@                             #
#|                                                           #
#|    URL:http://www.cgi-park.com/                           #
#|    E-Mail:support@cgi-park.com                            #
#|                                                           #
#|-----------------------------------------------------------#

#������������������������������������������������������������
#					���C�u�����̎擾
#������������������������������������������������������������
# �ϐ����C�u�����̃p�X
require "folder.pl";

# �ϐ����C�u�����̃p�X
require "conf.pl";

# �T�u���[�e�B�����C�u�����̃p�X
require "$LibDir/cgi-sub.pl";

# �����R�[�h�ϊ����C�u�����̃p�X
require "$LibDir/jcode.pl";

# CGI���C�u�����̃p�X
require "$LibDir/cgi-lib.pl";

#������������������������������������������������������������
#					�����ݒ�
#������������������������������������������������������������
$fckey{'zz'} = 's000';

#������������������������������������������������������������
#					���C������
#������������������������������������������������������������
eval{
&ReadParse(*FORM);

&initialize;
&authentication;
&lcs;
$html_body = &subroutine;
};
&print_html;

#������������������������������������������������������������
#������������������������������������������������������������

#-----------------------------------------------------------------------------1
#										����������
#------------------------------------------------------------------��2005.09.03
sub initialize {
	$html = $FORM{'html'};
	$action = $FORM{'action'};
	($html) || ($html = "admin");

	if (-e "$LibDir/$html.pl") {
		require "$LibDir/$html.pl";
	} elsif ($CoLibDir && -e "$CoLibDir/$html.pl") {
		require "$CoLibDir/$html.pl";
	}

	### HTML�t�@�C���̓ǂݍ���
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

	### �A�J�E���g�̓ǂݍ���
	&lib'openfile($account_log,*AC_LOG);
	&lib'openfile($account_db,*AC_DB);
	if (!@AC_LOG && $html ne 'account' && $html ne 'help' && $html ne 'admin' && $html ne 'menu') {
		print "Location: ./admin.cgi?html=account&route=new\n\n";
		exit;
	}

	### �ݒ�t�@�C���̓ǂݍ���
	(-e "$conf_log") || (&init_log_ext);
	&lib'openfile($conf_log,*CF_LOG);
	foreach (@CF_LOG) {
		my($name,$value) = split(/\t/);
		$conf{$name} = $value;
	}

}


#-----------------------------------------------------------------------------1
#										�A�N�Z�X�F��
#------------------------------------------------------------------��2005.09.05
sub authentication {
	### �v���O�������̏Ɖ�
	if ($fckey{"$apa"} ne $fckey) {
		&lib'system_error('er401','�ݒ肪�s���Ȃ��ߊǗ���ʂւ̃A�N�Z�X�����ۂ���܂����B');
	}
	### ���C�Z���X���
	if ($lc1) {
		$lcs = $lc1;
	} elsif ($au eq "$fckey\meijin") {
	} else {
		$lcs = 'admin';
	}
	(@AC_LOG) || (return);
	if ($html eq 'admin' && $FORM{'c'} eq 'no') {return}
	### �O���A�N�Z�X�F��
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
						&login_record('access','�A�N�Z�X',$ACC{'user_name'});
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
#										�o��
#------------------------------------------------------------------��2007.12.05
sub print_html {
	### �G���[�m�F
	if ($@) {
		&lib'system_error('eval',"$@");
	}
	
	### �w�b�_�[
	$html_header = &make_title_bar("$html_header$html_title",$title_bar);
	$print_html = "$html_header$html_body$html_footer";

	### �C���[�W�t�H���_�̈ړ�
	if ($ImageDir ne '../image') {
		$print_html =~ s/"..\/image/"$ImageDir/g;
	}
	
	### �V�X�e������
	($conf{'cgi_title'}) || ($conf{'cgi_title'} = $mjnm);
	$print_html =~ s/#meijin_name#/$conf{'cgi_title'}/g;
	($site_link) || (die);
	print "Content-type: text/html\n\n";
	print $print_html;
}


#-----------------------------------------------------------------------------1
#										�^�C�g���̍쐬
#------------------------------------------------------------------��2007.12.05
sub make_title_bar {
	local($html,$title_bar) = @_;
	### �w�b�_�[
	if ($conf{'r_width'}) {
		$html =~ s/width="600"/width="$conf{'r_width'}"/g;
	}
	$html =~ s/<title>([^<]*)<\/title>/<TITLE>$title_bar<\/TITLE>/i;
	
	$html =~ s/#title#/$title_bar/g;

	### �z�[���y�[�WLink
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
#										�A�N�Z�X�L�^
#------------------------------------------------------------------��2005.09.05
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
#										���O�g���q�̏����ݒ�
#------------------------------------------------------------------��
sub init_log_ext {
	if ($log_ext eq 'htm' || $log_ext eq 'db' || $log_ext eq 'mail') {
		&lib'system_error('er107','���O�t�@�C���̊g���q�̐ݒ肪�s���ł��B�u$log_ext�v�͗��p�o���܂���B');
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


