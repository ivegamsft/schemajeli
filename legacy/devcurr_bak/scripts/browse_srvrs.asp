<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!--#INCLUDE file="../include/adovbs.inc"-->
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
cmdDC.CommandText = "SELECT * FROM tblAll_Srvrs;" 
cmdDC.CommandType = 1

' Create recordset and retrieve values using command object
Set rsDC = Server.CreateObject("ADODB.Recordset")
' Opening record set with a forward-only cursor (the 0) and in read-only mode (the 1)
rsDC.Open cmdDC, , 0, 1
%>
<TABLE>
<table border="0" width="100%" align="center">
<FORM NAME="BrowseSrvrs" METHOD="POST" ACTION="browse.asp?RelObject=Servers">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff"><b>Browsing Servers</font></center></b>
     </td>
  </tr>
</table>

<table border="0"  bgcolor="#C0C0C0" width="50%" align="center">
 <tr>
    <td colspan="5" height="20">
     </td>
 </tr>

  <tr>
    <td>
     </td>
     <td align="center" colspan="3"><font face="Verdana" color="0000000"><b>Select a Server</font></b>
     </td>
     <td>
     </td>
  </tr>
    
   <tr>
      <td>
      </td>
      <td align="center" colspan="3"><select name="ObjName" size="1">
                                       <option selected value="Select an RDBMS">Select a Server</option>
                                       <% If Not rsDC.EOF Then rsDC.MoveFirst %>
                                       <% Do While Not rsDC.EOF%>
                                       <OPTION VALUE="<%= rsDC.Fields("srvr_nme")%>">
									                  <%= rsDC.Fields("srvr_nme") & " - " & rsDC.Fields("srvr_desc")%></OPTION>
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
     <td  align="center" colspan="3"><input type="submit" NAME="cmdSelect" value="Select">
     </td>
     <td>
     </td>
  </tr>
  </FORM>
 </table>
</body>
</html>
