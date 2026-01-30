<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--Help menu-->
<%
Dim strTopic
Dim strFileName

strTopic = Request.QueryString("Topic")
Select Case strTopic
    Case "Reports"%>
    <!--#INCLUDE FILE="../help/hlp_reports.htm"-->
<%  Case "Search"%>
    <!--#INCLUDE FILE="../help/hlp_search.htm"-->
<%  Case "Maintain"%>
    <!--#INCLUDE FILE="../help/hlp_maintain.htm"-->
<%  Case "Admin"%>
    <!--#INCLUDE FILE="../help/hlp_admin.htm"-->
<%  Case "Support"%>
    <!--#INCLUDE FILE="../help/hlp_support.htm"-->
<%End Select
%> 
</BODY>     