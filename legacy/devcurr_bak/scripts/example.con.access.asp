<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<%
Dim DConn
Dim cmdDC
Dim rsDC

' Create and establish data connection
Set DConn = Server.CreateObject("ADODB.Connection")
DConn.ConnectionTimeout = 15
DConn.CommandTimeout = 30

'Access connection code
DConn.Open "DBQ=" & Server.MapPath("../navservers.mdb") & ";Driver={Microsoft Access Driver (*.mdb)};DriverId=25;MaxBufferSize=8192;Threads=20;"
Set cmdDC = Server.CreateObject("ADODB.Command")
cmdDC.ActiveConnection = DConn
cmdDC.CommandText = "SELECT db_nme FROM tblDbs_Desc;" 
cmdDC.CommandType = 1

' Create recordset and retrieve values using command object
Set rsDC = Server.CreateObject("ADODB.Recordset")
' Opening record set with a forward-only cursor (the 0) and in read-only mode (the 1)
rsDC.Open cmdDC, , 0, 1
%>
<table border="0" width="100%" align="center">
<FORM NAME="BrowseTbls" METHOD="POST" ACTION="browse.asp?RelObject=Tables">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40" align="center"><font face="Verdana" color="ffffff"><b>Browsing Tables</font></b>
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
     <td colspan="3" align="center"><select name="ObjName" size="1">
                                       <option value="Select a Database">Select a Database</Option> 
                                       <% If rsDC.EOF Then rsDC.MoveFirst %>
                                       <% Do While Not rsDC.EOF%>
                                       <OPTION value="<%= rsDC.Fields("db_nme")%>">
									                  <%= rsDC.Fields("db_nme")%></OPTION>
									   <%rsDC.MoveNext%>
	                                   <%Loop%>
	                                   </SELECT>
<%
' Close Data Access Objects and free DB variables
	rsDC.Close
	Set rsDC =  Nothing
	' can't do a "cmdDC.Close" !
	Set cmdDC = Nothing
	DConn.Close
	Set DConn = Nothing
%>
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
