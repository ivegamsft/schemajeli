<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Search Element Key Words
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<script language="JavaScript"><!--

function Search_Check(theForm)
{
    if (theForm.KeyWord1.value == "")
     { 
	    alert("Please enter a keyword in `Keyword 1`  !");
		theForm.KeyWord1.focus()
		return (false);
		
	 } 
     else
     {
        theForm.submit();
        return (true);
     }
}   
//--></script>

<script language="VBScript"><!--
  Sub Window_OnLoad()
    Document.search_elems.KeyWord1.Focus
  end sub
//--></script>

<!--Header table -->
<table border="0" width="50%" align="center" bgcolor="<%=arypagecolors(7)%>">
<a name="top"></a>
  <tr>
    <td colspan="2" width="100%" height="40" align="center"><font color="<%=arypagecolors(0)%>"face="Verdana"><b>Search Elements-Keywords</b>
    <br>Enter up to five key words to search for</font>
    </td>
  </tr>    
</table>
<!--Body Table -->
<table border="0" width="50%" align="center" bgcolor="<%=arypagecolors(9)%>">
<FORM ACTION="query_result.asp?RelObject=ElementKywds" METHOD="POST" NAME="search_elems" onsubmit="return Search_Check(this)">
  <tr>
    <td align="center" colspan="4" style="border-bottom: thin solid rgb(255,255,255)">
    </td>
  </tr>
  

  <tr>
    <td><font face="Verdana" color="#000000" size="3">Keyword 1</font>
    </td>
    <td><input type="text" name="KeyWord1" TYPE="TEXT"  size="35">
        <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
    </td>
  </tr>

  <tr>
    <td><font face="Verdana" color="#000000" size="3">Keyword 2</font>
    </td>
    <td><input type="text" name="KeyWord2" size="35">
    </td>
  </tr>

  <tr>
    <td><font face="Verdana" color="#000000" size="3">Keyword 3</font>
    </td>
    <td><input type="text" name="KeyWord3" size="35">
    </td>
  </tr>

  <tr>
    <td><font face="Verdana" color="#000000" size="3">Keyword 4</font>
    </td>
    <td><input type="text" name="KeyWord4" size="35">
    </td>
  </tr>

  <tr>
    <td><font face="Verdana" color="#000000" size="3">Keyword 5</font>
    </td>
    <td><input type="text" name="KeyWord5" size="35">
    </td>
  </tr>

  <tr>
    <td>
    </td>

    <td> <input type="submit" name="cmdSubmit" value="Submit"> &nbsp;&nbsp   
         <input type="reset" value="Reset" name="cmdReset">

    </td>
  </tr>


  
</table>
</form>
</html>
