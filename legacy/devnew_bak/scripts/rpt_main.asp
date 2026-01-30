<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Dim strRelObjReport
Dim strRelObjReportType
Dim strRelObjStatus
Dim strRelObjServer
Dim strRelObjName
Dim strStep
Dim aryReport(3)
Dim aryReportType(2)
Dim aryStatus(3,1)
Dim aryServer()
Set rs = Session("rs")
strRelObjReport = Request.Form("RelObjReport")
strRelObjReportType = Request.Form("RelObjReportType")
strRelObjStatus = Request.Form("RelObjStatus")
strRelObjServer = Request.Form("RelObjServer")
strRelObjName = Request.Form("RelObjName")
strStep = Request.Form("Step")

aryReport(0) = "Server"
aryReport(1) = "Database"
aryReport(2) = "Table"
aryReport(3) = "Element"

aryReportType(0) = "Summary"
aryReportType(1) = "Detail"
aryReportType(2) = "Full"

aryStatus(0,0) = "PRDT"
aryStatus(0,1) = "Production"
aryStatus(1,0) = "DVLP"
aryStatus(1,1) = "Development"
aryStatus(2,0) = "ITST"
aryStatus(2,1) = "IT status"
aryStatus(3,0) = "APRV"
aryStatus(3,1) = "Approval"
%>
<!--#INCLUDE FILE="../include/Rpt_ShwHead.inc"-->
<!--#INCLUDE FILE="../include/Rpt_ShwRep.inc"-->    
<%Select Case strRelObjReport
   Case "Server"
   Select Case strStep
        Case "2", ""
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
<%      Case "5"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
        <!--#INCLUDE FILE="../include/Rpt_ShwEnd.inc"-->
<%      End Select

   Case "Database"
   Select Case strStep
        Case "2", ""
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
<%      Case "3"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
<%      Case "4"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
<%      Case "5"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwSrvr.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
        <!--#INCLUDE FILE="../include/Rpt_ShwName.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwEnd.inc"-->
<%   End Select

   Case "Table"
   Select Case strStep
        Case "3",""
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
<%      Case "4"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->
<%      Case "5"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
        <!--#INCLUDE FILE="../include/Rpt_ShwName.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwEnd.inc"-->
<%   End Select

   Case "Element"
   Select Case strStep
        Case "3", ""
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
<%      Case "4"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"--> 
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
<%      Case "5"
%>      <!--#INCLUDE FILE="../include/Rpt_ShwStat.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwType.inc"-->   
        <!--#INCLUDE FILE="../include/Rpt_ShwName.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_ShwEnd.inc"-->
<%   End Select
End Select
%>
<!--#INCLUDE FILE="../include/Rpt_ShwFoot.inc"-->
