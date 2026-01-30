<% Response.buffer = True %>
<HTML>
<HEAD>
<STYLE>
BODY       { 
              font-family:Verdana;
              font-size: small;
              color:#2F2F9F;
              font-weight: bold;}

.warning    {
              font-family:Arial;
              font-size: x-small;
              color:red;}
              
A:link      {
             font-family:Verdana;
             font-size: small;
             color:blue;
             text-decoration:none;
             font-weight: bold; }

A:visited   {color:blue;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }


A:active    {color:blue;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }


A:hover     {color:red;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }

</STYLE>
<TITLE>MainPage
</TITLE>
<%
'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!--#INCLUDE FILE="../include/colors.inc"-->
</HEAD>
<BODY BGCOLOR="<%=aryPageColors(1)%>" marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
<TABLE BORDER="0" WIDTH="100%" ALIGN="center">
  <TR>
  <TD WIDTH="100%" HEIGHT="40" COLSPAN="2" BGCOLOR="<%= strHeaderColor %>" align="CENTER">
  If you are new to the Navistar Repository System, or want to learn more about meta-data,<BR>
  visit <A HREF="http://wwwnio.navistar.com/edw/Teams/om/default.htm" TARGET="_blank">The Enterprise Data Warehouse-Object Management home page.</A>
  </TD>
  </TR>
  <TR>
  <TD WIDTH="100%" HEIGHT="40" COLSPAN="2"></TD>
  </TR>
  <TR>
  <TD ALIGN="center">
<SCRIPT LANGUAGE="JavaScript1.2">

/*
Pausing updown message scroller- 
Last updated: 99/07/05 (Bugs fixed, ability to specify background image for scroller)
© Dynamic Drive (www.dynamicdrive.com)
For full source code, installation instructions,
100's more DHTML scripts, and Terms Of
Use, visit dynamicdrive.com
*/

//configure the below five variables to change the style of the scroller
var scrollerwidth=500
var scrollerheight=100
var scrollerbgcolor='white'
//set below to '' if you don't wish to use a background image
var scrollerbackground='../images/watermrk.jpg'

//configure the below variable to change the contents of the scroller
var messages=new Array()
messages[0]="Looking for help on the Navistar Naming Standards?<BR>Visit the <A HREF='http://wwwnio.navistar.com/dbagroup/rdbms.htm' TARGET='_blank'>Navistar DBA Standards Page</A></font>"
messages[1]="Visit the <A HREF='http://wwwnio.navistar.com/edw/edwspdfs/dapweb.pdf' TARGET='_blank'>Data Acquisition & Preparation Overview</A><br>for information on the Enterprise Data Warehouse*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[2]="For help on element names go to <BR><A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0011b.pdf' TARGET='_blank'>IB0011 -- Data Element Name and Definition Class</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[3]="<A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0003.pdf' TARGET='_blank'>IB0003 -- Data Modeling:  The Three Level Approach</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[4]="<A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0004.pdf' TARGET='_blank'>IB0004 -- Conceptual Data Model Checklist and Reference</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[5]="<A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0005.pdf' TARGET='_blank'>IB0005 -- Logical Data Model Checklist and Reference</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[6]="<A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0008.pdf' TARGET='_blank'>IB0008 -- What Is This Thing Called Modeling?</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[7]="<A HREF='http://wwwnio.navistar.com/edw/edwspdfs/ib0009.pdf' TARGET='_blank'>IB0009 -- Table Definition Template</A>*<BR><BR>*<B CLASS='warning'>This link requires <A HREF='http://wwwnio.navistar.com/edw/reference/download.htm' TARGET='_blank'>Adobe&reg; Acrobat.</A></B>"
messages[8]="Go to the <A HREF='http://wwwnio.navistar.com' TARGET='_blank'>Navistar Home Page</A>"
messages[9]="<A HREF='http://www-datadmn.itsi.disa.mil' TARGET='_blank'>DOD Data Dictionary Standards page</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"
messages[10]="<A HREF='http://www.marketplace.unisys.com/urep/' TARGET='_blank'>Unisys&reg;-UREP</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"
messages[11]="<A HREF='http://www.cutter.com/' TARGET='_blank'>Cutter Information Corp</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"
messages[12]="<A HREF='http://www.omg.org/' TARGET='_blank'>The Object Management Group (OMG&reg;)</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"
messages[13]="<A HREF='http://www.rational.com/index.jtmpl' TARGET='_blank'>Rational&reg; Software</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"
messages[14]="<A HREF='http://www.mdcinfo.com' TARGET='_blank'>Meta Data Coalition</A>**<BR><BR>**<B CLASS='warning'>This link requires that you have external, internet access on your machine.</B>"

///////Do not edit pass this line///////////////////////

if (messages.length>1)
i=2
else
i=0

function move1(whichlayer){
tlayer=eval(whichlayer)
if (tlayer.top>0&&tlayer.top<=5){
tlayer.top=0
setTimeout("move1(tlayer)",3000)
setTimeout("move2(document.main.document.second)",3000)
return
}
if (tlayer.top>=tlayer.document.height*-1){
tlayer.top-=5
setTimeout("move1(tlayer)",100)
}
else{
tlayer.top=scrollerheight
tlayer.document.write(messages[i])
tlayer.document.close()
if (i==messages.length-1)
i=0
else
i++
}
}

function move2(whichlayer){
tlayer2=eval(whichlayer)
if (tlayer2.top>0&&tlayer2.top<=5){
tlayer2.top=0
setTimeout("move2(tlayer2)",3000)
setTimeout("move1(document.main.document.first)",3000)
return
}
if (tlayer2.top>=tlayer2.document.height*-1){
tlayer2.top-=5
setTimeout("move2(tlayer2)",100)
}
else{
tlayer2.top=scrollerheight
tlayer2.document.write(messages[i])
tlayer2.document.close()
if (i==messages.length-1)
i=0
else
i++
}
}

function move3(whichdiv){
tdiv=eval(whichdiv)
if (tdiv.style.pixelTop>0&&tdiv.style.pixelTop<=5){
tdiv.style.pixelTop=0
setTimeout("move3(tdiv)",3000)
setTimeout("move4(second2)",3000)
return
}
if (tdiv.style.pixelTop>=tdiv.offsetHeight*-1){
tdiv.style.pixelTop-=5
setTimeout("move3(tdiv)",100)
}
else{
tdiv.style.pixelTop=scrollerheight
tdiv.innerHTML=messages[i]
if (i==messages.length-1)
i=0
else
i++
}
}

function move4(whichdiv){
tdiv2=eval(whichdiv)
if (tdiv2.style.pixelTop>0&&tdiv2.style.pixelTop<=5){
tdiv2.style.pixelTop=0
setTimeout("move4(tdiv2)",3000)
setTimeout("move3(first2)",3000)
return
}
if (tdiv2.style.pixelTop>=tdiv2.offsetHeight*-1){
tdiv2.style.pixelTop-=5
setTimeout("move4(second2)",100)
}
else{
tdiv2.style.pixelTop=scrollerheight
tdiv2.innerHTML=messages[i]
if (i==messages.length-1)
i=0
else
i++
}
}

function startscroll(){
if (document.all){
move3(first2)
second2.style.top=scrollerheight
second2.style.visibility='visible'
}
else if (document.layers){
document.main.visibility='show'
move1(document.main.document.first)
document.main.document.second.top=scrollerheight+5
document.main.document.second.visibility='show'
}
}

window.onload=startscroll

</SCRIPT>




<ILAYER ID="main" WIDTH=&{SCROLLERWIDTH}; HEIGHT=&{SCROLLERHEIGHT}; BGCOLOR=&{SCROLLERBGCOLOR}; BACKGROUND=&{SCROLLERBACKGROUND}; VISIBILITY=HIDE>
<LAYER ID="first" LEFT=0 TOP=1 WIDTH=&{SCROLLERWIDTH};>
<SCRIPT LANGUAGE="JavaScript1.2">
if (document.layers)
document.write(messages[0])
</SCRIPT>
</LAYER>
<LAYER ID="second" LEFT=0 TOP=0 WIDTH=&{SCROLLERWIDTH}; VISIBILITY=HIDE>
<SCRIPT LANGUAGE="JavaScript1.2">
if (document.layers)
document.write(messages[1])
</SCRIPT>
</LAYER>
</ILAYER>

<SCRIPT LANGUAGE="JavaScript1.2">
if (document.all){
document.writeln('<span id="main2" style="position:relative;width:'+scrollerwidth+';height:'+scrollerheight+';overflow:hiden;background-color:'+scrollerbgcolor+' ;background-image:url('+scrollerbackground+')">')
document.writeln('<div style="position:absolute;width:'+scrollerwidth+';height:'+scrollerheight+';clip:rect(0 '+scrollerwidth+' '+scrollerheight+' 0);left:0;top:0">')
document.writeln('<div id="first2" style="position:absolute;width:'+scrollerwidth+';left:0;top:1;">')
document.write(messages[0])
document.writeln('</div>')
document.writeln('<div id="second2" style="position:absolute;width:'+scrollerwidth+';left:0;top:0;visibility:hidden">')
document.write(messages[1])
document.writeln('</div>')
document.writeln('</div>')
document.writeln('</span>')
}
</SCRIPT>
  </TD>
  </TR>
</TABLE>
</BODY>
</HTML>