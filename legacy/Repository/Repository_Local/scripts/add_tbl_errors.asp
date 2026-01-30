<% response.buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Add/Maintain Table
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<FORM ACTION="add_tbl.asp" METHOD="POST" NAME="add_tbl_errors" >
<INPUT TYPE=HIDDEN NAME-FILLER VALUE=NOTHING>

<% dupFound = session("dupExist")
if dupFound = "y" then
  session("EntryPoint") = "add_tbl_insrt"
%>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg
   sub msg
    Dim theForm
    Set theForm = Document.Forms.item(0)
     message = "You've selected a duplicate element!" + (Chr(13)& Chr(10)) + "Please select another element"
     msgbox message, 0, "Element Selection"
	 theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
    -->
</SCRIPT>
 <% end if%> 
 
 <%
 
 if isNull(Session("prkeys")) then
    session("prkeys") = " "
 end if	
  
'--------------------------------------------------------------------------
		
 DBNmError = session("dbNmError")
 if DBNmError = "y" then
    session("EntryPoint") = "add_tbl_insrt"
%>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg1
   sub msg1
    Dim theForm
    Set theForm = Document.Forms.item(0)
     message = "Database name not found!" + (Chr(13)& Chr(10)) + "Please enter a valid database name"
     msgbox message, 0, "Invalid Name"
	 theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
    -->
</SCRIPT>
<%end if%> 

</FORM>
</BODY>
</HTML>
   