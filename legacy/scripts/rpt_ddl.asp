<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<HTML>
<HEAD>
<TITLE>Generate DDL Report
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<SCRIPT LANGUAGE="JavaScript"><!--

function TableName_Check(theForm)
{

    if (theForm.Criteria.value == "")
     {
        alert("Please enter a table name!")
		theForm.Criteria.focus()
        return (false)
	 }	
	else
	 { 
		theForm.submit();
  		return (true);
     }  
}    
//--></SCRIPT>	 
<!--Header table -->
<FORM ACTION="rpt_ddl_dtls.asp" METHOD="POST" NAME="rpt_ddl" onsubmit="return TableName_Check(this)">
<TABLE BGCOLOR="<%=strBackColor%>" height="2" border="0"  align="center">
<TR>
 <TD BGCOLOR="<%=strHeaderColor%>" align="center" colspan="4" ><FONT FACE="Verdana" COLOR="#000000" SIZE="4"><B>Generate DDL</B></FONT>
</TD>
</TR>

  <!--  TABLE NAME -->
  <TR>
    <TD><FONT FACE="Verdana" COLOR="#000000" SIZE="3">Table Name</FONT>
    </TD>
    <TD><INPUT TYPE="text" NAME="Criteria" TYPE="TEXT"  SIZE="33" >&nbsp&nbsp&nbsp
	    <INPUT TYPE="text" NAME="Status" TYPE="TEXT"  SIZE="5" VALUE = "DVLP" >
	</TD>
  </TR>
 
  <TR>
        <TD COLSPAN="3" ALIGN="center"><INPUT TYPE="submit" NAME="cmdSubmit" VALUE="Submit"> &nbsp;&nbsp
         <INPUT TYPE="reset" VALUE="Reset" NAME="cmdReset">
        </TD>
  </TR>

<SCRIPT LANGUAGE="VBScript"><!--
  Sub Window_OnLoad()
    Document.rpt_ddl.Criteria.Focus
  end sub
  
 //--></SCRIPT>
  
 <% if session("tblexists") = "n" then %>
     <SCRIPT LANGUAGE="VBScript"><!--
     msgbox "Table doesn't exist, please reenter table name."
     //--></SCRIPT>
<%	 session("tblexists") = "y"
  end if
%>  

</FORM> 
</TABLE>  
</BODY>
</HTML>
