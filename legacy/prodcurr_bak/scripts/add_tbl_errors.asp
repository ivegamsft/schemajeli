<% response.buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<BODY>

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
   