<TR>
<TD ALIGN="center"><FONT FACE="Verdana" SIZE="2"><B>Select a report</B>
</TD>
</TR>
<TR>
<TD ALIGN="center">
<SELECT NAME="Report" OnChange="SelectReport()">
<%If strRelObjReport = "" Then%>
   <OPTION SELECTED>----Relational object----</OPTION>
   <%For i = 0 to UBOUND(aryReport)%>
   <OPTION VALUE="<%=aryReport(i)%>"><%=aryReport(i)%></OPTION>  
   <%Next%>
   </SELECT>
   </TD>
   </TR>
<%Else
   For i = 0 to UBOUND(aryReport)
   If strRelObjReport = aryReport(i) then%>
     <OPTION SELECTED VALUE="<%=aryReport(i)%>"><%=aryReport(i)%></OPTION>
   <%Else%>
     <OPTION VALUE="<%=aryReport(i)%>"><%=aryReport(i)%></OPTION>
   <%End IF
   Next
End If%>
   </SELECT>
</TD>
</TR>