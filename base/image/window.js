
// 
// HTML JSのLINK<script src="window.js" type="text/javascript"></script>
//
//<td height="20" bgcolor="#dedede" onClick="openNewWin('../common/map.html','372','440','150','150')"><U><font color="#0000FF" size="2" class="mouse">test</font></u></td>
//<A href="javascript:openNewWin('sample.html','600','500','150','150');">

//NEW WINDOW OPEN
function openNewWin(t_url,W,H,X,Y)
{
url = t_url
winW = "width="+ W +",";
winH = "height="+ H +",";
posX = "left="+ X +",";
posY = "top="+ Y +",";

window.open(url,"newWindow","toolbar=no,location=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,"+winW+winH+posX+posY);
}



// 任意のフォーム名称を付ける
// <FORM name="form" onsubmit="submitOnce(this);"
//

function submitOnce(form) {
    for(i = 0; i < form.elements.length; i++) {
        if(form.elements[i].type == "submit")
            form.elements[i].disabled = true;
    }
}