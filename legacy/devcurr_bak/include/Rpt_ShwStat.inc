<tr>
<TD align="center">
<FONT FACE="Verdana" SIZE="2"><B>Select an object status</B>
</TD>
</tr>
<tr>
<TD ALIGN="center"><SELECT NAME="Status" ONCHANGE="SelectStatus()">
<%If strRelObjStatus="" Then%>
  <OPTION SELECTED>------------Status------------</OPTION>
  <%For i = 0 to UBOUND(aryStatus)%>
  <OPTION VALUE="<%=aryStatus(i,0)%>"><%=aryStatus(i,1)%></OPTION>
  <%Next%>
<%Else
  For i = 0 to UBOUND(aryStatus)
  If strRelObjStatus = aryStatus(i,0) Then%>
    <OPTION SELECTED VALUE="<%=aryStatus(i,0)%>"><%=aryStatus(i,1)%></OPTION>
  <%Else%>
    <OPTION VALUE="<%=aryStatus(i,0)%>"><%=aryStatus(i,1)%></OPTION>
  <%End If%>
<%Next
End If%>
</SELECT>
</TD>
</tr>
