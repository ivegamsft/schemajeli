<% Response.buffer = True %>
<!--INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Welcome page
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--#INCLUDE FILE="../include/navmenu.inc"-->
<TABLE BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strHeaderColor%>">
  <TR>
  <TD WIDTH="100%"><CENTER><FONT FACE="Tahoma">
    <H2>Welcome <%=TRIM(Session("UserName"))%>, to the Navistar Repository System</H2>
    <B>Use the navigation menu above to move around the repository.</B>
    </FONT>
  </TD>
  </TR>
</TABLE>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center">
  <TR>
  <TD WIDTH="100%" HEIGHT="40" COLSPAN="2"><CENTER><FONT FACE="Verdana">
    If you are new to the Navistar Repository System, or want to learn more about meta-data,<BR>
    visit <A HREF="http://wwwnio.navistar.com/edw/Teams/om/default.htm" TARGET="_blank">The Enterprise Data Warehouse-Object Management home page.</A>
  </TD>
  </TR>
  <TR>
  <TD HEIGHT="20" COLSPAN="2"></TD>
  </TR>
  <TR>
  <TD WIDTH="50%"><FONT FACE="Verdana" SIZE="3">
   <B>Intranet links to other resources:<FONT COLOR="<%=strErrTextColor%>">*</B></FONT>
  </TD>
  <TD WIDTH="50%"><FONT FACE="Verdana" SIZE="3">
   <B>Internet links to other resources:<FONT COLOR="<%=strErrTextColor%>">**</B></FONT>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/dbagroup/rdbms.htm" TARGET="_blank">Navistar DBA Standards Page</A>
   </TD>
  <TD><A HREF="http://www-datadmn.itsi.disa.mil" TARGET="_blank">DOD Data Dictionary Standards page</A>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/dapweb.pdf" TARGET="_blank">Data Acquisition & Preparation Overview</A>
  </TD>
  <TD><A HREF="http://www.marketplace.unisys.com/urep/" TARGET="_blank">Unisys&reg;-UREP</A>
  </TD>
  </TR>    
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0011b.pdf" TARGET="_blank">IB0011 -- Data Element Name and Definition Class</A>
  </TD>
  <TD><A HREF="http://www.cutter.com/" TARGET="_blank">Cutter Information Corp</A>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0003.pdf" TARGET="_blank">IB0003 -- Data Modeling:  The Three Level Approach</A>
  </TD>
  <TD><A HREF="http://www.omg.org/" TARGET="_blank">The Object Management Group (OMG&reg;)</A>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0004.pdf" TARGET="_blank">IB0004 -- Conceptual Data Model Checklist and Reference</A>
  </TD>
  <TD><A HREF="http://www.rational.com/index.jtmpl" TARGET="_blank">Rational&reg; Software</A>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0005.pdf" TARGET="_blank">IB0005 -- Logical Data Model Checklist and Reference</A>
  </TD>
  <TD><A HREF="http://www.mdcinfo.com" TARGET="_blank">Meta Data Coalition</A>
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0008.pdf" TARGET="_blank">IB0008 -- What Is This Thing Called Modeling?</A>
  </TD>
  <TD>&nbsp;
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0009.pdf" TARGET="_blank">IB0009 -- Table Definition Template</A>
  </TD>
  <TD>&nbsp;
  </TD>
  </TR>
  <TR>
  <TD><A HREF="http://wwwnio.navistar.com/edw/edwspdfs/ib0011.pdf" TARGET="_blank">IB0011 -- Data Element Name and Definition Class</A>
  </TD>
  <TD>&nbsp;
  </TD>
  </TR>
  <TR>
  <TD WIDTH="50%" HEIGHT="40"><FONT FACE="Verdana" SIZE="1" COLOR="<%=strErrTextColor%>">
   <B>* Some of these links open Adobe&reg; *.PDF files, which require <A HREF="http://wwwnio.navistar.com/edw/reference/download.htm" TARGET="_blank"> Adobe Acrobat.</A></B>
  <TD WIDTH="50%" HEIGHT="40"><FONT FACE="Verdana" SIZE="1" COLOR="<%=strErrTextColor%>">
   <B>** These links require that you have external, internet access on your machine.</B>
  </TD>
  </TR>
</TABLE>
</BODY>
</HTML>
