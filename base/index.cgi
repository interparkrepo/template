#!/usr/bin/perl -w
$html = qq|
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html; charset=Shift_JIS">
<META http-equiv="Content-Style-Type" content="text/css">
<TITLE>�Ǘ����</TITLE>
</HEAD>
<FRAMESET>
  <FRAME src="cgi/admin.cgi" name="admin">
</FRAMESET>
</HTML>
|;
print "Content-type: text/html\n\n";
print $html;
exit;

