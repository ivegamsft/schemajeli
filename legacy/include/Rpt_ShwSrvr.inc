<TR>
<TD ALIGN="Center"><FONT FACE="Verdana" SIZE="2">
<B>Select a server name</B>
</TD>
</TR>
<%sqlQuery = "Select DISTINCT srvr_nme from irma12_srvr"
If rs.State = 1 then
  rs.Close
End If
rs.open(sqlQuery)
iLoopCount = 0
Do until rs.EOF = True
  ReDim PRESERVE aryServer(iLoopCount)
  aryServer(iLoopCount) = UCASE(TRIM(rs.Fields(0)))
  iLoopCount = iLoopCount + 1
  rs.MoveNext
Loop
rs.Close%>
<TR>
<TD ALIGN="center"><SELECT NAME="Server" SIZE="1" ONCHANGE="SelectServer()">
<%If strRelObjServer = "" Then%>
  <OPTION SELECTED>-----Server Name-----</OPTION>
  <%For i=0 to UBOUND(aryServer)%>
  <OPTION VALUE="<%=aryServer(i)%>"><%=aryServer(i)%></OPTION>
  <%Next
Else
   For i=0 to UBOUND(aryServer)
  If strRelObjServer = aryServer(i) then%>
     <OPTION SELECTED VALUE="<%=aryServer(i)%>"><%=aryServer(i)%></OPTION>
  <%Else%>
     <OPTION VALUE="<%=aryServer(i)%>"><%=aryServer(i)%></OPTION>
  <%End IF
  Next
End If%>
</SELECT>
</TD>
</TR>