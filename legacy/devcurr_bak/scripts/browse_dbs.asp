<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Browse Databases</title>
</head>

<table border="0" width="100%" align="center">
<FORM NAME="BrowseDbs" METHOD="POST" ACTION="browse.asp?RelObject=Databases">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing Databases</font></center></b>
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
     <td align="center" colspan="2"><font face="Verdana" color="0000000"><b>Select an RDBMS</font></b>
     </td>
     <td>
     </td>
   </tr>

   <tr>
    <td>
    </td>
    <td colspan="3" align="center"><select name="ObjName" size="1">
                                       <option selected value="Select an RDBMS">Select an RDBMS</option>
                                       <option value="DB2">DB2</option>
                                       <option value="Informix">Informix</option>
                                       <option value="RDB">RDB</option>
<!--UDB not yet                        <option value="UDB">UDB</option> -->
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
 