<SCRIPT RUNAT=Server LANGUAGE="VBScript">
PUBLIC FUNCTION CheckBusnsName(TERM)
	
	If IsNumeric(Left(TERM ,1)) Then
	   CheckBusName = False
	Else
	   CheckBusName = True
	 End If
END FUNCTION

PUBLIC FUNCTION GetStdAbbr(TERMS)
	Dim iNumTerms
	Dim iLoopCount
	Dim aryStdAbbr()
	Dim sqlQuery

    Set rs = Session("rs")
iNumTerms=UBound(TERMS)
ReDim aryStdAbbr(iNumTerms,1)            'resize the array to hold the abbr
For iLoopCount = 0 to iNumTerms
		If Not IsNumeric(TERMS(iLoopCount)) then
           sqlQuery = "SELECT std_abbr_nme" 
	       sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
 		   sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & UCASE(TERMS(iLoopCount)) & "'"
           If rs.State = 1 then
              rs.Close
           End If
           rs.open(sqlQuery)
           If rs.BOF = -1  Then
              aryStdAbbr(iLoopCount,0) = "??" & TERMS(iLoopCount) & "??"
              aryStdAbbr(iLoopCount,1) = "??" & TERMS(iLoopCount) & "??"
            Else
               aryStdAbbr(iLoopCount,0) = TERMS(iLoopCount)                   'The term
               aryStdAbbr(iLoopCount,1) = UCASE(TRIM(rs.Fields(0)))           'The abbreviation
            End If
         Else
               aryStdAbbr(iLoopCount,0) = TERMS(iLoopCount)                   'The term
               aryStdAbbr(iLoopCount,1) = TERMS(iLoopCount)                   'The abbreviation is numeric
         End If
Next
   rs.Close            'For debug
   GetStdAbbr=aryStdAbbr
END FUNCTION

PUBLIC FUNCTION GetStdAbbr4Term(TERM)
Dim sqlQuery

Set rs = Session("rs")
If Not IsNumeric(TERM) then
  sqlQuery = "SELECT std_abbr_nme" 
  sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
  sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & UCASE(TERM) & "'"
  If rs.State = 1 then
      rs.Close
  End If
  rs.open(sqlQuery)
  If rs.BOF = -1  Then
    GetStdAbbr4Term = "??" & TERM & "??"
  Else
    GetStdAbbr4Term = TRIM(rs.Fields(0))
  End If
Else
  GetStdAbbr4Term = TERM
End If
END FUNCTION

PUBLIC FUNCTION FindPhrases(TERMS)
Dim iTermCount
Dim iFound
Dim iTermCounter
Dim iLoopCount
Dim iPhraseIndex
Dim strCurTerm
Dim strPhraseFound
Dim aryPhrases()
Dim bLastTerm

Set rs = Session("rs")
iTermCount = UBOUND(TERMS)
ReDim aryPhrases(iTermCount,4)
bLastTerm = False

For iTermCounter = 0 to iTermCount
   aryPhrases(iTermCounter,0) = TERMS(iTermCounter)
   aryPhrases(iTermCounter,1) = GetStdAbbr4Term(TERMS(iTermCounter))
next   
For iTermCounter = 0 to iTermCount
   strCurTerm = TERMS(iTermCounter)
   strCurEvalTerm = strCurTerm
   For iNextTerm = iTermCounter + 1 to iTermCount
      strCurEvalTerm = strCurEvalTerm & " " & TERMS(iNextTerm)
'      response.write "Evaluating " & strCurEvalTerm
'      response.write "<BR>"
      sqlQuery = "Select std_abbr_srce_nme, std_abbr_nme"
      sqlQuery = sqlQuery & " FROM irma10_std_abbr"
      sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strCurEvalTerm & "'"
      If rs.State = 1 then
          rs.Close
      End If
      rs.open(sqlQuery)
      If Not rs.BOF = -1 then
         Do until rs.EOF = TRUE
            iFound = iFound + 1
            rs.MoveNext
         Loop
         rs.MoveFirst
         If iFound = 1 then
            iPhraseIndex = iTermCounter
            strPhraseFound = GetStdAbbr4Term(strCurEvalTerm)
            For iLoopCount = 0 to iNextTerm - iTermCounter
               aryPhrases(iPhraseIndex,2) = ""
               aryPhrases(iPhraseIndex,3) = 1
               aryPhrases(iPhraseIndex,4) = strCurEvalTerm
               iPhraseIndex = iPhraseIndex + 1
            Next
             aryPhrases(iNextTerm,2) = strPhraseFound
            If iNextTerm = iTermCount then
                bLastTerm = TRUE
                iFound = 0
                iTermCounter = iNextTerm -1
                iNextTerm = iTermCount
                Exit For
           Else
               iFound = 0
               iTermCounter = iNextTerm
               iNextTerm = iTermCount
               Exit For
            End If
      End If
    Else
     aryPhrases(iTermCounter,2) = GetStdAbbr4Term(TERMS(iTermCounter))
     aryPhrases(iTermCounter,3) = 0
   End If
   Next
Next
'           Get last term
If Not bLastTerm then
   iTermCounter = iTermCounter - 1
   aryPhrases(iTermCounter,2) = GetStdAbbr4Term(TERMS(iTermCounter))
   aryPhrases(iTermCounter,3) = 0
End If
'response.write blastterm
'response.write "<BR>"
'For i = 0 to UBOUND(aryPhrases)
'   response.write i & "-"
'   response.write aryPhrases(i,0) & " "
'   response.write aryPhrases(i,1) & " "
'   response.write aryPhrases(i,2) & " "
'   response.write aryPhrases(i,3) & " "
'   response.write aryPhrases(i,4) & " "   
'   response.write "<BR>"
'next
'Response.end
FindPhrases = aryPhrases
END FUNCTION

PUBLIC FUNCTION ValidElemChars(NAME)

DIM	aryForbiddenChars(30)
DIM iCount

	aryForbiddenChars(0)= "!"
	aryForbiddenChars(1)= "@"
	aryForbiddenChars(2)= "#"
	aryForbiddenChars(3)= "$"
	aryForbiddenChars(4)= "^"
	aryForbiddenChars(5)= "&"
	aryForbiddenChars(6)= "*"
	aryForbiddenChars(7)= "("
	aryForbiddenChars(8)= ")"
	aryForbiddenChars(9)= "["
	aryForbiddenChars(10)= "{"
	aryForbiddenChars(11)= "]"
	aryForbiddenChars(12)= "}"
	aryForbiddenChars(13)= chr(34)
	aryForbiddenChars(14)= "'"
	aryForbiddenChars(15)= ";"
	aryForbiddenChars(16)= ":"
	aryForbiddenChars(17)= "\"
	aryForbiddenChars(18)= "|"
	aryForbiddenChars(19)= ","
	aryForbiddenChars(20)= ","
	aryForbiddenChars(21)= "."
	aryForbiddenChars(22)= ">"
	aryForbiddenChars(23)= "/"
	aryForbiddenChars(24)= "?"
	aryForbiddenChars(25)= "`"
	aryForbiddenChars(26)= "~"
	aryForbiddenChars(27)= "-"
	aryForbiddenChars(28)= "="
	aryForbiddenChars(29)= "+"
	aryForbiddenChars(30) = Chr(34) & chr(34)

For iCOUNT = 0 to UBOUND(aryForbiddenChar)
    If InStr(,NAME,aryForbiddenChar(iCOUNT)) THEN
    	ValidElemChars=aryForbiddenChar(iCOUNT)
		Exit For
	else
	    ValidElemChars="True"
	End if
Next
END FUNCTION

PUBLIC FUNCTION CheckDuplicateAlias(CNAME)
Dim iFound

   sqlQuery = "SELECT a.elmt_busns_nme, a.elmt_dict_nme, a.elmt_col_nme"
   sqlQuery = sqlQuery & " FROM irma05_element a"
   sqlQuery = sqlQuery & " WHERE a.elmt_col_nme = '" & CNAME & "'"
   Set rs=Session("rs")
   If rs.State = 1 then
      rs.Close
   End If
   rs.open(sqlQuery)           'Open the record set

    iFound = rs.BOF

    If iFound = -1 then         'No record found
        CheckDuplicateAlias="False"
    Else
        CheckDuplicateAlias=rs.Fields(1)
     End If
     rs.Close
END FUNCTION

PUBLIC FUNCTION CheckExisting(BNAME)
Dim sqlQuery
Dim iFound
     
   sqlQuery = "SELECT a.elmt_busns_nme, a.elmt_dict_nme"
   sqlQuery = sqlQuery & " FROM irma05_element a"
   sqlQuery = sqlQuery & " WHERE a.elmt_busns_nme = '" & BNAME & "'"
   Set rs=Session("rs")
   If rs.State = 1 then
      rs.Close
   End If
   rs.open(sqlQuery)           'Open the record set

    iFound = rs.BOF

    If iFound = -1 then         'No record found
        CheckExisting="False"
    Else
        CheckExisting=rs.Fields(1)
     End If
     rs.Close
END FUNCTION

Function GetSuggested(BNAME)
Dim aryKeyWords
Dim aryDictNames
Dim sqlQuery
Dim sqlSubQuery
Dim iCount
Dim iUpToCount

  Set rs=Session("rs")
  aryKeyWords = SPLIT(UCASE(BNAME))
  For iCount = 0 To UBOUND(aryKeyWords)
      sqlSubQuery = sqlSubQuery & " SELECT elmt_dict_nme "
      sqlSubQuery = sqlSubQuery & " FROM irma07_elmt_kwd " 
      sqlSubQuery = sqlSubQuery & " WHERE key_word_nme = '" & aryKeyWords(iCount) & "')" 
      If Not iCount = UBOUND(aryKeyWords) Then
          sqlSubQuery = sqlSubQuery & " AND elmt_dict_nme in ("
      End IF
  Next
  sqlQuery = "SELECT DISTINCT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no "
  sqlQuery = sqlQuery & " FROM irma04_elmt_vrsn "
  sqlQuery = sqlQuery & " WHERE elmt_dict_nme in ( " & sqlSubQuery
  sqlQuery = sqlQuery & " ORDER BY elmt_dict_nme "
  If rs.State = 1 then
    rs.Close
  End If
  iCount = 0
'  response.write (sqlquery & "<br>")
  rs.open(sqlQuery)           'Open the record set
  If not rs.BOF = -1 Then
    Do Until rs.EOF = True
      iCount = iCount +1
      rs.MoveNext
    Loop
    rs.MoveFirst
'    response.write icount & " total records returned -------<br>"
    ReDim aryDictNames(iCount -1, 2)
    iCount = 0
    Do Until rs.EOF = True
      aryDictNames(iCount,0) = UCASE(TRIM(rs.Fields(0)))
      aryDictNames(iCount,1) = UCASE(TRIM(rs.Fields(1)))
      aryDictNames(iCount,2) = UCASE(TRIM(rs.Fields(2)))
      iCount = iCount + 1
      rs.MoveNext
    Loop
  Else 
    ReDim aryDictNames(1,2)
    aryDictNames(0) = "Not Found"
  End If
  rs.Close
'  For iCount = 0 to UBOUND(aryDictNames)
'    Response.write(aryDictNames(iCount,0) & "<br>")
'    Response.write(aryDictNames(iCount,1) & "<br>")
'    Response.write(aryDictNames(iCount,2) & "<br>")
'  next
'  Response.end
  GetSuggested = aryDictNames
End Function 
</SCRIPT>