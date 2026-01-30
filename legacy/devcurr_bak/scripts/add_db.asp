<%@ LANGUAGE="VBSCRIPT" %>
<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<html>

<head>
<title>Design Database</title>
</head>


<!--Header table -->
<table border="0" width="100%" align="center">
  <tr>
    <td width="100%" bgcolor="#4889A2" height="40" align="center"><font face="Verdana" color="#FFFFFF"><b>Design Database</font></b>
    </td>
  </tr>    
</Table>

<!--Body Table -->

<table border="0" bgcolor="#C0C0C0" width="50%" align="center">
<FORM METHOD=POST NAME="NewElem" ACTION="scripts/verif_Db.asp">
   <tr>
     <td colspan="5" height="20">
     </td>
   </tr>
  
  <tr>
    <td align="center" colspan="5" style="border-bottom: thin solid rgb(255,255,255)">
                            <font face="Verdana" color="#000000" size="5"><b>Specify Data</b></font>
    </td>
  </tr>
  
  <tr>
  </tr>

  <tr>
     <td width="50%"><font face="Verdana" color="#000000">Status</td></font>
     <td width="50%"><font face="Verdana" color="#000000">
                     <input type="radio" name="Status" value="DVLP" checked >In Development (Default)<br>
                     <input type="radio" name="Status" value="PRDT">In Producution<br>
                     <input type="radio" name="Status" value="APPR">In Approval
            </font>
     </td>
  </tr>

  <tr>
     <td width="50%"><font face="Verdana" color="#000000">Select an RDMBS</td></font>
     <td width="50%"><select name="cboRDBMS" size="1">
                     <option selected value="Select an RDMBS">Select an RDBMS</option>
                     <option value="DB2">DB2</option>
                     <option value="RDB">RDB</option>
                     <option value="Informix">Informix</option>
                     </select>
     </td>   
  </tr>

  <tr>
     <td width="50%"><font face="Verdana" color="#000000">Select an Environment</td></font>
     <td width="50%"><select name="cboRDBMS" size="1">
                     <option selected value="Select an Environment">Select an Environment</option>
                     <option value="DB2">Operational</option>
                     <option value="RDB">Warehouse</option>
                     <option value="Informix">Development</option>
                     </select>
     </td>   
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Name</td></font>
    <td width="50%"><input type="text" name="txtDbName" value="" Size="30">
                    </select>
    </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Creator</td></font>
    <td width="50%"><input type="text" name="txtCreator" value="" Size="30">
    </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Create Date</td></font>
    <td width="50%"><input type="text" name="txtCreateDate" value="" Size="11">
  </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Version</td></font>
    <td width="50%"><input type="text" name="txtVersion" value="" Size="2">
    </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Key Words</td></font>
    <td width="50%"><input type="text" name="txtKeyWords" value="" Size="30">
    </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">See Clause</td></font>
    <td width="50%"><input type="text" name="txtSeeClause" value="" Size="30">
    </td>
  </tr>

  <tr>
    <td width="50%"><font face="Verdana" color="#000000">Description</td></font>
    <td width="50%"><textarea name="txtDesc" rows="5" cols="50"></textarea>	
    </td>
  </tr>

  <tr>
    <td width="50%" align="center"><input type="submit" value="Submit" name="cmdSubmit">
    <td width="50%" align="center"><input type="reset" value="Reset" name="cmdReset">
      </form>
  </tr>  
</table>

</body>
</html>