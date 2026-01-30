<TR>
<TD ALIGN="Center"><FONT FACE="Verdana" SIZE="2"><B>Select a report type</B>
</TD>
</TR>
<TR>
<TD ALIGN="center"><SELECT NAME="Type" ONCHANGE="SelectType()">
<%Select Case strRelObjReport
    Case "Database"
    If strRelObjReportType = "" Then%>
       <OPTION SELECTED>--------Report Type----------</OPTION>
<%     For i = 1 to UBOUND(aryReportType)%>
       <OPTION VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
<%     Next
    Else
      For i = 1 to UBOUND(aryReportType)
      If strRelObjReportType = aryReportType(i) Then%>
        <OPTION SELECTED VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
      <%Else%>
        <OPTION VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
      <%End If
      Next
    End If

    Case "Server"
    If strRelObjReportType = "" Then%>
       <OPTION SELECTED>--------Report Type----------</OPTION>
       <OPTION VALUE="<%=aryReportType(0)%>"><%=aryReportType(0)%></OPTION>
<%    Else%>
        <OPTION SELECTED VALUE="<%=aryReportType(0)%>"><%=aryReportType(0)%></OPTION>
<%    End If

    Case "Element"
    If strRelObjReportType = "" Then%>
       <OPTION SELECTED>--------Report Type----------</OPTION>
       <OPTION VALUE="<%=aryReportType(1)%>"><%=aryReportType(1)%></OPTION>
<%    Else%>
        <OPTION SELECTED VALUE="<%=aryReportType(1)%>"><%=aryReportType(1)%></OPTION>
<%    End If

    Case Else
    If strRelObjReportType = "" Then%>
         <OPTION SELECTED>--------Report Type----------</OPTION>
<%       For i = 0 to UBOUND(aryReportType) -1%>
         <OPTION VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
<%       Next
    Else
      For i = 0 to UBOUND(aryReportType) -1
      If strRelObjReportType = aryReportType(i) Then%>
        <OPTION SELECTED VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
      <%Else%>
        <OPTION VALUE="<%=aryReportType(i)%>"><%=aryReportType(i)%></OPTION>
      <%End If
      Next
    End If
End Select
%>
</SELECT>
</TD>
</TR>