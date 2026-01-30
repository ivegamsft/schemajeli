<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<body bgcolor="<%=aryPageColors(1)%>" link=<%=aryPageColors(2)%> alink=<%=aryPageColors(2)%> vlink=<%=aryPageColors(2)%> text=<%=aryPageColors(0)%> align="center">
<table border="0" width="50%" align="center" bgcolor="<%=arypagecolors(7)%>">
  <tr>
     <td colspan="2" width="100%" height="40" align="center"><font color="<%=arypagecolors(0)%>"face="Verdana"><b>Search
        by Platform</font></center></b>
     </td>
  </tr>
 
  <tr>
     <td colspan = 4 height="20">
     </td>
  </tr>

  <tr>
    <td width="30%">
     </td>
     <td width="20%" bgcolor="#C0C0C0" align="right"><font face="Verdana" color="0000000"><b>Select a Platform</font></b>
     </td>
        <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
     <td width="20%" bgcolor="#C0C0C0"><select name="cboDatabase" size="1">
                                       <option selected value="Select a Platform">Select a Platform</option>
                                       <option value="DB2">DB2</option>
                                       <option value="RDB">RDB</option>
                                       <option value="SQL Server">SQL Server</option>
                                       <option value="Inoformix">Informix</option>
                                       <option value="Oracle">Oracle</option>
                                       </select>
     </td>
   
     <td width="30%">
     </td>
      <tr>

        <td width="30%">
        </td>
        <td width="20%" bgcolor="#C0C0C0"><font color="#000000">Display</font>
        </td>
        <td width="20%" bgcolor="#C0C0C0"><font color="#000000">
                                              <input type="checkbox" name="C1" value="ON">Databases<br>
                                              <input type="checkbox" name="C2" value="ON">Tables<br>
                                              <input type="checkbox" name="C3" value="ON">Elements<br>
      </td>
      </tr>
      <td width="30%">
      </td>

  <tr>
     <td width="30%">
     </td>
     <td align="center" bgcolor="#C0C0C0" colspan=2><input type="submit" NAME="cmdSelect" value="Select">
     </td>
     <td width="30%">
     </td>
      </tr>
    </table>
    </td>
  </tr>
</table>
</body>
</html>
