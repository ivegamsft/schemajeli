<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Browse Elements</title>
</head>

<table border="0" width="100%" align="center">
<FORM NAME="BrowseElem" METHOD="POST" ACTION="browse.asp?RelObject=Elements">
  <tr>
     <td bgcolor="#4889A2" colspan="4" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing Elements</font></center></b>
     </td>
  </tr>
</table>

<table border="0" bgcolor="#C0C0C0" width="50%"  align="center">

 <tr>
    <td colspan="5" height="20">
     </td>
 </tr>

  <tr>
    <td>
     </td>
     <td align="center" colspan="3"><font face="Verdana" color="0000000"><b>Select a status</font></b>
     </td>
  </tr>

   <tr>    
    <td>
     </td>
     <td align="center" colspan="3"><select name="cboElements" size="1">
                                        <option value="Select a Status">Select a Status</Option> 
                                        <option value="Production">Production</Option>
                                        <option value="Development">Development</Option> 
                                        <option value="Approval">Approval</Option>
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
