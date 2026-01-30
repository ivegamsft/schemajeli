<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Browse Custom</title>
</head>

<table border="0" width="100%" align="center">
<FORM NAME="BrowseCust" METHOD="POST" ACTION="browsecust.asp">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing Custom</font></center></b>
     </td>
  </tr>
</table> 

<table border="0" bgcolor="#C0C0C0" width="50%" align="center">

 <tr>
    <td colspan="5" height="20">
     </td>
 </tr>

  <tr>
     <td>
     </td>
     <td align="center" colspan="3"><font face="Verdana" color="0000000"><b>Select a Database</font></b>
     </td>
  </tr>    
  <tr>
     <td>
     </td>
     <td align="center" colspan="3"><select name="cboDatabase" size="1">
                                       <option value="Select a Database">Select a Database</Option> 
                                       </select>
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
