<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Browse RDBMS</title>
</head>

<table border="0" width="100%" align="center">
<FORM NAME="BrowseRdbms" METHOD="POST" ACTION="browserdbms.asp">
  <tr>
     <td bgcolor="#4889A2" colspan="4" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing RDBMS</font></center></b>
     </td>
  </tr>
 
 <tr>
    <td colspan = 4 height="20">
     </td>
 </tr>

  <tr>
    <td width="30%">
     </td>
     <td width="20%" bgcolor="#C0C0C0" align="center"><font face="Verdana" color="0000000"><b>Select a starting point</font></b>
     </td>
    
     <td bgcolor="#C0C0C0" colspan="2" align="center"><select name="ObjName" size="1">
                                       <option selected value="Select an RDBMS">Select an RDBMS</option>
                                       <option value="DB2">DB2</option>
                                       <option value="RDB">RDB</option>
                                       <option value="Informix">Informix</option>
                                       </select>
     </td>
   
     <td width="30%">
     </td>
  </tr>

  <tr>
     <td width="30%">
     </td>
     <td align="center" bgcolor="#C0C0C0" colspan=2><input type="submit" NAME="cmdSelect" value="Select">
     </td>
     <td width="30%">
     </td>
  </tr>
  </FORM>
 </table>
</body>
</html>
