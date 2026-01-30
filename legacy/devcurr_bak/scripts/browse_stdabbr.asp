<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Browse Tables</title>
</head>

<table border="0" width="100%" align="center">
<FORM NAME="BrowseStdAbbr" METHOD="POST" ACTION="browsestdabbr.asp">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing Standard Abbreviations</font></center></b>
     </td>
  </tr>
</table> 

<table bgcolor="#C0C0C0" width="50%" align="center">

 <tr>
    <td colspan="5" height="20">
     </td>
 </tr>

  <tr>
     <td>
     </td>
     <td align="center" colspan="3"><font face="Verdana" color="0000000"><b>Enter a word to abbreviate</font></b>
     </td>
     <td>
     </td>
  </tr>    

  <tr>
     <td>
     </td>
     <td align="center" colspan="3"><INPUT type="text" name="txtStdAbbr" size="20">
     </td>
   
     <td>
     </td>
  </tr>

  <tr>
     <td>
     </td>
     <td align="center" colspan="3"><input type="submit" NAME="cmdSelect" value="Select">
     </td>
     <td>
     </td>
  </tr>
  </FORM>
 </table>
</body>
</html>
