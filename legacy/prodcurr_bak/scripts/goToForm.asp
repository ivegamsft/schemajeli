<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<%
'redirect to proper form
Dim strDestOption
Dim strDestForm
strDestOption = Request.Querystring("Option")

Select Case strDestOption
Case "Search"
 strDestForm = Request.Form("cboSearch")
 If strDestForm = "" then
    strDestForm = "welcome.asp"
 End If
 Response.Redirect(strDestForm)
Case "Maintain"
 strDestForm = Request.Form("cboMaintain")
 If strDestForm = "" then
    strDestForm = "welcome.asp"
 End If
 Response.Redirect strDestForm
Case "Administration"
 strDestForm = Request.Form("cboAdministration")
 If strDestForm = "" then
    strDestForm = "welcome.asp"
 End If
 Response.Redirect strDestForm
Case "Reports"
 strDestForm = Request.Form("cboReports")
 If strDestForm = "" then
    strDestForm = "welcome.asp"
 End If
 Response.Redirect strDestForm
Case "Help"
 strDestForm = Request.Form("cboHelp")
 If strDestForm = "" then
    strDestForm = "welcome.asp"
 End If
 Select Case strDestForm
   Case "HowTo"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowHelp "../help/hlp_howto.htm",top=500, width=500
   End Sub
   </SCRIPT>
   <%
   Case "Reports"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowModalDialog "../help/hlp_reports.htm", "dialogHeight=800", "dialogLeft=1000", "center=no"
   End Sub
   </SCRIPT>
   <%
   Case "Search"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowHelp "../help/hlp_search.htm"
   End Sub
   </SCRIPT>
   <%
   Case "Maintain"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowHelp "../help/hlp_maintain.htm"
   End Sub
   </SCRIPT>
   <%
   Case "Admin"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowHelp "../help/hlp_admin.htm"
   End Sub
   </SCRIPT>
   <%
   Case "Support"
   %>
   <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
       ShowHelp "../help/hlp_support.htm"
   End Sub
   </SCRIPT>
   <%
   Case Else
      Response.Redirect strDestForm
   End Select
Case "Menu"
 strDestForm = "nav_menu.asp"
 If strDestForm = "" then
    strDestForm = "home.asp"
 End If
 Response.Redirect strDestForm
Case Else
 strDestForm = "home.asp"
 End Select
%>