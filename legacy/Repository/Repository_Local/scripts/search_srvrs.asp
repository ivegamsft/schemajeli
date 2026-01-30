<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Search Servers
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<table border="0" width="50%" align="center" bgcolor="<%=arypagecolors(7)%>">
  <tr>
    <td colspan="2" width="100%" height="40" align="center"><font color="<%=arypagecolors(0)%>"face="Verdana"><b>Search Servers</font></b>
    </td>
  </tr>    
</Table>

<!--Body Table -->
<table border="0" width="50%" align="center" bgcolor="<%=arypagecolors(9)%>">   <tr>
     <td colspan="5" height="20">
     </td>
   </tr>
  
  <tr>
    <td align="center" colspan="5" style="border-bottom: thin solid rgb(255,255,255)"><font face="Verdana" color="#000000" size="5"><b>Specify search criteria</b></font>
    </td>
  </tr>
  
  <tr>
  </tr>
  
  <tr>
     <td width="50%"><font face="Verdana" color="#000000"><b>RDBMS</font></b>
     </td>
      <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
     <td width="50%"><select name="cboRDBMS" size="1">
                                       <option selected value="Select an RDBMS">Select an RDBMS</option>
                                       <option value="DB2">DB2</option>
                                       <option value="RDB">RDB</option>
                                       <option value="Informix">Informix</option>
                                       <option value="All">All</option>
                                       </select>
     </td>
    </tr>

   <tr>
      <td width="50%"><font face="Verdana" color="#000000"><b>Server&nbsp; name</font></b>
      </td>
      <td width="50%" bgcolor="#C0C0C0"><select name="cboServer" size="1">
                                       <option selected value="Select a Platform">Select a Server</option>
                                       <option value="BRKDBPX01">BRKDBPX01-Informix Production Node</option>
                                       <option value="BRKDBPX02">BRKDBPX02-Informix Production Node</option>
                                       <option value="BRKDBDX03">BRKDBDX03-Informix Development Node</option>
                                       <option value="BRKMFPROD">BRKMFPROD-IBM Mainframe Node</option>
                                       <option value="CCCPA2">CCCPA2-DEC/VMS/Rdb cluster-Parts</option>
                                       <option value="CCCPA4">CCCPA4-DEC/VMS/Rdb cluster-Manufacturing</option>
                                       <option value="CHEA09">CHEA09-DEC/VMS/Rdb cluster-Chatham Plant</option>
                                       <option value="SAPA09">SAPA09-DEC/VMS/Rdb cluster-Springfield Plant</option>                                       
                                       <option value="All">All-All Servers</option>                         
                                       </select>
      </td>      
    </tr>

     <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Status</font></b>
        </td>
        <td width="50%"><font face="Verdana" color="#000000"><input type="checkbox" name="InProd" value="ON">Production</font><br>
                        <font face="Verdana" color="#000000"><input type="checkbox" name="InDvlp" value="ON">In Development</font><br>
                        <font face="Verdana" color="#000000"><input type="checkbox" name="InAppr" value="ON">In Approval</font><br>
        </td>
      </tr>

       <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Keyword Search</font></b>
        </td>
        <td width="50%"><input type="text" name="txtKeyWord" size="25">
        </td>
      </tr>

      <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Description Search</font></b>
        </td>
        <td width="50%"><input type="text" name="txtDesc" size="25">
        </td>
      </tr>

      <tr>
        <td width="50%" align="right"><input type="button" value="Submit" name="cmdSubmit">
        </td>
        <td width="50%" align="left"><input type="button" value="Reset" name="cmdReset">
        </td>
      </tr>
    </table>
</body>
</html>
