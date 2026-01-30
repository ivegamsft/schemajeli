<%
'---This check for the proper uid and password
Session.Timeout = 60
Function PCase(strInput)
	Dim iPosition  
	Dim iSpace     
	Dim strOutput 

	iPosition = 1
	
	Do While InStr(iPosition, strInput, " ", 1) <> 0
		iSpace = InStr(iPosition, strInput, " ", 1)
		strOutput = strOutput & UCase(Mid(strInput, iPosition, 1))
		strOutput = strOutput & LCase(Mid(strInput, iPosition + 1, iSpace - iPosition))
		iPosition = iSpace + 1
	Loop
	strOutput = strOutput & UCase(Mid(strInput, iPosition, 1))
	strOutput = strOutput & LCase(Mid(strInput, iPosition + 1))
	PCase = strOutput
End Function

Dim sqlQuery
Dim strUserId

  strUserId = UCASE(Request.Form("UserId"))
  Set rs = Session("rs")
  sqlQuery = "SELECT uid, user_auth_cd, empl_1st_nme, empl_lst_nme "
  sqlQuery = sqlQuery & " FROM irma15_user"
  sqlQuery = sqlQuery & " WHERE uid = '" & strUserId & "'"
  If rs.State = 1 Then
     rs.Close
  End If
  rs.open(sqlQuery)
'  response.write sqlquery
  If rs.BOF <> -1 then
     If TRIM(rs.Fields(1)) = "ADMN" Then
     Response.Redirect "login.asp?UserId=" & strUserId & "&ShowPassword=True"
   Else
     Session("UserID") = TRIM(rs.Fields(0))
     Session("UAuth") = TRIM(rs.Fields(1))
     Session("UserName") = pCase(TRIM(rs.Fields(2)))
     If InStr(1,TRIM(rs.Fields(3)),"!") Then
         Dim strLName
         strLName = Replace(TRIM(rs.Fields(3)),"!","'")
     Else
         strLName = TRIM(rs.Fields(3))
     End If
     Session("EmailAddr") = TRIM(rs.Fields(2)) & "." & strLName & "@navistar.com"
   End If
  Else
	 Session("UserID")="Guest"		  
  	 Session("UserName")="Guest"
     Session("UAuth")=""
     strAuth = "Guest"
  End If
  
'------------------------------------------------------------------------
'---- SAVE LOGIN INFORMATION ON THE WEB SERVER --------------------------
'------------------------------------------------------------------------
Dim strPath
Dim strFileName
Dim strDDL

strPath = session("savepath")&"\logs\"
strFileName = replace(date, "/", "-")&".txt" 
strPageLogName = replace(date, "/", "-") & "pgs.txt"

Set fs = Server.CreateObject("Scripting.FileSystemObject")
Set filPageLog = Server.CreateObject("Scripting.FileSystemObject")
'response.write strPath & "\" & strFilename
if not fs.fileExists(strPath & "\" & strFilename) then
    set myfile=fs.CreateTextfile(strPath & "\" & strFileName)
    set filPageLog = fs.CreateTextfile(strPath & "\" & strPageLogName)
	newfile="y"
	myfile.close
    filPageLog.Close
end if	    

set myfile=fs.openTextfile(strPath & "\" & strFilename,8,TRUE)
set filPageLog=fs.openTextfile(strPath & "\" & strPageLogName,8,TRUE)
if newfile = "y" then
   myfile.writeLine("User_Id "+"Authorization "+"Login_Time "+"Session_Id ")
   myfile.writeBlankLines(1)
   filPageLog.writeLine("Session_Id        Time        Script_Name        Query_String")
   filPageLog.writeBlankLines(1)
end if   
'Email if anyone accesses application
Set objCDOMail = Server.CreateObject("CDONTS.NewMail")
	objCDOMail.From = "rephlpteam@USAEXCH01.navistar.com"
	objCDOMail.To = "rephlpteam@USAEXCH01.navistar.com"
    objCDOMail.Subject = Session("UserName") & " Login"
	objCDOMail.Body = strUserId & " is logging in at " & TIME & " as " & Session("UserID") & " with " & Session("UAuth") & " authority." 
    objCDOMail.Send
    If err <> 0 then
       response.write err.number & "<BR>" & err.description
       response.end
    End If
Set objCDOMail = Nothing

if Session("UAuth")= "" then
   Session("UAuth")="NONE"
end if  
  
myfile.writeLine(strUserId+","+Session("UAuth")+","&TIME&","&Session.SessionId)
myfile.close
filPageLog.Close
Set fs = nothing
Set myfile = nothing
Set filPageLog = nothing
set strPath = nothing
'-------------------------------------------------------------------------  
'Response.Redirect "mainpage.asp"
Response.Redirect "welcome.asp"
%>

