<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<%session("EntryPoint") = "add_tbl_nme"%>
<%session("DBname") = ""%>


<SCRIPT LANGUAGE="JavaScript"><!--

<!--#INCLUDE FILE="../include/ASCCodes.inc"-->

function TableName_Check(theForm)
{
    if (theForm.Criteria.value == "")
     {
        alert("Please enter a table name!");
		theForm.Criteria.focus();
        return (false);
     } 
     else
	 {
	    var error = false;
		var strName = theForm.Criteria.value.toUpperCase();
	 
	 	if (strName.length > 18)
		{ 
   		  errortxt="Table name greater then 18 characters";
		  theForm.Criteria.focus();
  		  error = true;
		}   
		
		if (!(ValidASC(strName.substr(0,2))))
		{
   		  errortxt="First 2 characters have to be an Application System Code";
   		  theForm.Criteria.focus(); 
		  error = true;
		}
		
		if (strName.substr(2,1) != "T")
		{
   		  errortxt="Third character has to be T";
   		  theForm.Criteria.focus();
		  error = true;
		}
 		
		if (strName.substr(3,1) != "P" && strName.substr(3,1) != "2" && strName.substr(3,1) != "4")
		{
   		  errortxt="Fourth character has to be P, 2 or 4";
   		  theForm.Criteria.focus();
		  error = true;
		}
		
		if (!(strName.substr(5,1) >= 0 && strName.substr(5,1) <= 9))
		{
   		  errortxt="6th character has to be numeric";
   		  theForm.Criteria.focus();
		  error = true;
		}
		
		if (!(strName.substr(6,1) >= 0 && strName.substr(6,1) <= 9))
		{
   		  errortxt="7th character has to be numeric";
   		  theForm.Criteria.focus();
		  error = true;
		}
		
		if (!(strName.substr(7,1) == "_")) 
		{
   		  errortxt="8th character has to be an underscore";
   		  theForm.Criteria.focus();
		  error = true;
		}
		
		if ((strName.substr(8,1) == "")) 
		{
   		  errortxt="Enter table identifier";
   		  theForm.Criteria.focus();
		  error = true;
		}
				
		if (error) 
		{ 
  		  alert(errortxt)  
  		  return (false)
		}  
		else
		{ 
		  theForm.submit();
  		  return (true);
		}  
	} 
}
//--></SCRIPT>

<!--Header table -->


<TABLE BORDER="0" BGCOLOR="<%=strHeaderColor%>" WIDTH="60%" ALIGN="center">
  <TR>
    <TD HEIGHT="40" ALIGN="center"><FONT FACE="Verdana" SIZE="3" COLOR="<%=strtextColor%>">
    <B>Specify Data</B> - Table<BR>Enter a table name</FONT>
    </TD>
  </TR>    
<!--Body Table -->
<FORM ACTION="add_tbl.asp?Entry=add_tbl_nme"" METHOD="POST" NAME="ADD_TBL" onsubmit="return TableName_Check(this)">
<%
if IsObject(Session("cart")) then
    set dictElmPicks = CreateObject("Scripting.Dictionary")
    set Session("cart") = dictElmPicks 
end if
%>
<INPUT TYPE="hidden" NAME="EntryPoint" VALUE="add_tbl_nme"> 
</TABLE>
<TABLE WIDTH="60%" BORDER="0" ALIGN="center" BGCOLOR="<%=strBackColor%>">
  <!--  TABLE NAME -->
  <TR>
    <TD ALIGN="RIGHT"><FONT FACE="Verdana" COLOR="#000000" SIZE="3">Table Name</FONT>
    </TD>
    <TD><INPUT TYPE="text" NAME="Criteria" TYPE="TEXT"  SIZE="50" >
    </TD>
  </TR>

  <TR>
        <TD ALIGN="center" COLSPAN="2">
        <INPUT TYPE="submit" NAME="cmdSubmit" VALUE="Submit">&nbsp;&nbsp
        <INPUT TYPE="reset" VALUE="Reset" NAME="cmdReset">
        </TD>
  </TR>
<SCRIPT LANGUAGE="VBScript"><!--
  Sub Window_OnLoad()
    Document.add_tbl.Criteria.Focus
  end sub
//--></SCRIPT>
 
</TABLE>
</FORM>
</HTML>
