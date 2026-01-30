<SCRIPT RUNAT=Server LANGUAGE="VBScript">
PUBLIC FUNCTION ParseName(NAME)
'This function will parse the name and return an array of strings
	Dim iTermCount
	Dim iCurTerm
	Dim aryTerms()
    Dim strTerm

For i = 1 to Len(NAME)               'Count the number of terms entered by the user
   If mid(NAME, i, 1) = " " Then
      iTermCount = iTermCount + 1
   End If
Next
 iTermCount= iTermCount+1           'Count the last Term

ReDim aryTerms(iTermCount -1)          'Size the array to hold the separated terms(-1 to keep zero based)
 iCurTerm = 1                        'Set the term counter
 For i = 0 to Len(Name) - 1              'Count the total characters
    If Mid(NAME, i, 1) = " " Then           'Count the spaces to get the words
      iCurTerm = iCurTerm + 1               
    Else
      aryTerms(iCurTerm - 1) = aryTerms(iCurTerm - 1) + Mid(NAME, i, 1)     'Add the separated words to the array of Terms
    End If
Next
ParseName=aryTerms	                  'Return the array
END FUNCTION

PUBLIC FUNCTION CheckBusnsName(TERM)
'This function will check for a numeric in front
'It returns an error code (see "errors.inc")
	
	If IsNumeric(Left(TERM ,1)) Then
	   CheckBusName = "073"
	Else
	   CheckBusName = "000"
	 End If
END FUNCTION

PUBLIC FUNCTION FindPhrases(TERMS)
	
END FUNCTION

PUBLIC FUNCTION GetStdAbbr(TERMS)
	Dim iNumTerms
	Dim iLoopCount
	Dim aryStdAbbr()
	Dim sqlQuery

    Set rs = Session("rs")
    'rs.Close            'For debug
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

PUBLIC FUNCTION GetKeyWords(TERMS)
END FUNCTION

PUBLIC FUNCTION GetDictName(TERMS)
END FUNCTION

PUBLIC FUNCTION GetColumnName(TERMS)
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
'               aryPhrases(iPhraseIndex,0) = TERMS(iPhraseIndex)
               aryPhrases(iPhraseIndex,2) = ""
               aryPhrases(iPhraseIndex,3) = 1
               aryPhrases(iPhraseIndex,4) = strCurEvalTerm
               iPhraseIndex = iPhraseIndex + 1
            Next
             aryPhrases(iNextTerm,2) = strPhraseFound
'            response.write "I found phrase " & aryPhrases(iTermCounter,1) & " for the term " & strCurEvalTerm & " " & inextterm & " of " & iTermCount & " remaining."
'            response.write "<BR>"
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
'    aryPhrases(iTermCounter,0) = TERMS(iTermCounter)
     aryPhrases(iTermCounter,2) = GetStdAbbr4Term(TERMS(iTermCounter))
     aryPhrases(iTermCounter,3) = 0
'    response.write terms(iTermCounter) & " "
   End If
   Next
Next
'           Get last term
If Not bLastTerm then
   iTermCounter = iTermCounter - 1
'   aryPhrases(iTermCounter,0) = TERMS(iTermCounter)
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
'   response.write "<BR>"
'next
'Response.end
FindPhrases = aryPhrases
END FUNCTION

PUBLIC FUNCTION ValidChar(NAME)

DIM	aryForbiddenChars(33)
DIM iCount

	aryForbiddenChars(0)= "!"
	aryForbiddenChars(1)= "@"
	aryForbiddenChars(2)= "#"
	aryForbiddenChars(3)= "$"
	aryForbiddenChars(4)= "%"
	aryForbiddenChars(5)= "^"
	aryForbiddenChars(6)= "&"
	aryForbiddenChars(7)= "*"
	aryForbiddenChars(8)= "("
	aryForbiddenChars(9)= ")"
	aryForbiddenChars(10)= "["
	aryForbiddenChars(11)= "{"
	aryForbiddenChars(12)= "]"
	aryForbiddenChars(13)= "}"
	aryForbiddenChars(14)= chr(34)
	aryForbiddenChars(15)= "'"
	aryForbiddenChars(16)= ";"
	aryForbiddenChars(17)= ":"
	aryForbiddenChars(18)= "\"
	aryForbiddenChars(19)= "|"
	aryForbiddenChars(20)= ","
	aryForbiddenChars(21)= ","
	aryForbiddenChars(22)= "."
	aryForbiddenChars(23)= ">"
	aryForbiddenChars(24)= "/"
	aryForbiddenChars(25)= "?"
	aryForbiddenChars(26)= "`"
	aryForbiddenChars(27)= "~"
	aryForbiddenChars(28)= "-"
	aryForbiddenChars(29)= "_"
	aryForbiddenChars(30)= "="
	aryForbiddenChars(32)= "+"
	aryForbiddenChars(33) = " "

For iCOUNT = 0 to UBOUND(aryForbiddenChar)
    If InStr(,NAME,aryForbiddenChar(iCOUNT)) THEN
    	ValidChar=False
		Exit For
	else
	    ValidChar=True
	End if
Next
END FUNCTION

PUBLIC FUNCTION ValidClassWord(NAME)
DIM strClassWord 	
END FUNCTION

PUBLIC FUNCTION CheckDuplicate(TERM)
END FUNCTION

PUBLIC FUNCTION AddToDb(ELEMENT)
END FUNCTION

PUBLIC FUNCTION DeleteFromDb(OBJECT)
END FUNCTION

PUBLIC FUNCTION CheckExisting(BNAME)
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
</SCRIPT>