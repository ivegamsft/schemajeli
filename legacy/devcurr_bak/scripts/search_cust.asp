<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<html>

<head>
<title>Custom Search</title>
</head>


<!--Header table -->
<table border="0" width="100%" align="center">
  <tr>
    <td width="100%" bgcolor="#4889A2" height="40" align="center"><font face="Verdana" color="#FFFFFF"><b>Custom Search</font></b>
    </td>
  </tr>    
</Table>

<!--Body Table -->

<table border="0" bgcolor="#C0C0C0" width="50%" align="center">

   <tr>
     <td colspan="5" height="20">
     </td>
   </tr>
  
  <tr>
    <td align="center" colspan="5" style="border-bottom: thin solid rgb(255,255,255)"><font face="Verdana" color="#000000" size="5"><b>Specify search criteria</b></font>
    </td>
  </tr>
  
  <tr>
  </tr>
      <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
  <tr>
     <td width="50%"><font face="Verdana" color="#000000"><b>RDBMS</font></b>
     </td>
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
        <td width="50%"><font face="Verdana" color="#000000"><b>Database Name</font></b>
        </td>
        <td width="50%" bgcolor="#C0C0C0"><select name="cboDatabase" size="1">
                                           <option selected value="Select a Database">Select a Database</Option> 
                                           </select>
        </td>
      </tr>

      <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Table name</font></b>
        </td>
        <td width="50%" bgcolor="#C0C0C0"><select name="cboTable" size="1">
                                           <option selected value="Select a Table">Select a Table</Option> 
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
        <td width="50%"><font face="Verdana" color="#000000"><b>Version</font></b>
        </td>
        <td width="50%" bgcolor="#C0C0C0"><select name="cboVersion" size="1">
                                          <option selected value="Select a Version">Select a Version</Option>                                           
                                          <option value="Version1">1</Option>
                                          <option value="Version2">2</Option>
                                          <option value="Version3">3</Option>
                                          <option value="All">All</Option>
                                          </select>
       </td>
      </tr>

      <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Creator</font></b>
        </td>
        <td width="50%" bgcolor="#C0C0C0"><select name="cboCreator" size="1">
                                          <option selected value="Select an ID">Select an ID</Option>                                           
                                          <option value="ID1">YYYIXV1</Option>
                                          <option value="ID2">YYYMEG1</Option>
                                          <option value="ID3">YYYCLC1</Option>
                                          <option value="All">All</Option>
                                          </select>
        </td>
     </tr>

     <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Create Date</font></b>
        </td>
        <td width="50%"><input type="text" name="txtCDate" size="11">
        </td>       
      </tr>

      <tr>
        <td width="50%"><font face="Verdana" color="#000000"><b>Last Modified By</font></b>
        </td>
        <td width="50%"><select name="cboCreator" size="1">
                                          <option selected value="Select an ID">Select an ID</Option>                                           
                                          <option value="ID1">YYYIXV1</Option>
                                          <option value="ID2">YYYMEG1</Option>
                                          <option value="ID3">YYYCLC1</Option>
                                          <option value="All">All</Option>
                                          </select>
        </td>
      <tr> 
       <td width="50%"><font face="Verdana" color="#000000"><b>Last Modified Date</font></b>
       </td>
       <td width="50%"><input type="text" name="txtLMDate" size="11">
       </td>
       </tr>

       <tr>
        <td colspan="5" height="10">
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
