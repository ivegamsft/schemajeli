<%
Dim strTo, strSubject, strBody 'Strings for recipient, subject, boby
Dim objCDOMail 'The CDO object

strTo = "mailto:rephlpteam@USAEXCH01.navistar.com"
strSubject = "Sample E-mail sent from me to you."

strBody = "Here is the DDL generated from the Navistar Repository System.  When you get this message call me, and I will tell you the hell I went through to get this to work"
on error resume next
Set objCDOMail = Server.CreateObject("CDONTS.NewMail")
	objCDOMail.From = "mailto:rephlpteam@USAEXCH01.navistar.com"
	objCDOMail.To = strTo
    objCDOMail.Subject = strSubject
	objCDOMail.Body = strBody
	objCDOMail.AttachFile "c:\ddl\TATP010-YYYIXV1.txt","DDL for TATP010"
    objCDOMail.Send
    If err <> 0 then
       response.write err.number & "<BR>" & err.description
       response.end
    Else
    	Response.Write "Message sent to " & strTo & "!"
    End If
    Set objCDOMail = Nothing
%>
