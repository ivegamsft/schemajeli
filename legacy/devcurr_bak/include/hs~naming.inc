<%
'ELEMENT_NAMING.INC
PUBLIC FUNCTION ParseName(NAME)
'This function will parse the name and return an array of strings
	Dim iTermCount
	Dim iCurTerm
	Dim aryTerms(20)
    Dim strTerm
    strTerm = NAME									       'Set the input to a work variable

For i = 1 to Len(NAME)
   If mid(NAME, i, 1) = " " Then
      iTermCount= iTermCount + 1
   End If
Next
 iTermCount= iTermCount+1
 iCurTerm = 1
 For i = 1 to Len(Name)
    If Mid(NAME, i, 1) = " " Then
      iCurTerm = iCurTerm + 1
    Else
      aryTerms(iCurTerm) = aryTerms(iCurTerms) + Mid(NAME, i, 1)
    End If
Next
ParseName=aryTerms	   
END FUNCTION

PUBLIC FUNCTION CheckBusName(TERM)
'This function will check for a numeric in front
'It returns an error code (see "errors.inc")
	
	If  IsNumeric(Left(TERM(0), 1) Then
	   CheckBusName=073
	Else
	   CheckBusnName=000
	 End If
	END FUCTION

PUBLIC FUNCTION FindPhrases(TERMS)
	Dim iCurPos
	Dim iNumTerms
	Dim iNumTermsRet
	Dim iLoopCount
	Dim strCurPhrase
	Dim iCurRec
    Dim aryItem
	Dim iCurIndex
	Dim strCompPhrase
	Dim aryCurPhrases
	
	iNumTerms=UBOUND(TERMS)
	iCurPos=0
    Session.TimeOut = 1
    Server.ScriptTimeout = 1800
    Session("TimeOutChk") = "Y" 
    Set rsDC = Server.CreateObject("ADODB.Recordset")
    Set rsDC = Session("rs")
    STime = Time
    'rsDC.Close            'For debug
	rsDC.open(sqlQuery)
    ETime = Time
	
	Do until iCurPos = iNumTerms -1
		iCurPos=iCurPos+1
		Do Until iLoopCount=iNumTerms
		   sqlQuery = "SELECT std_abbr_srce_nme" 
		   sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
 		   sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme LIKE '" TERMS(iCurPos) & "%'"
          
		  If rsDC.Count > 0 Then                'More than one record returned
		     iCurIndex = 0
			 Do until rsDC.EOF                      'Search the record set until the end
		        If inStr(rsDC.Fields," ") then       'Check for phrases in the record set
				     aryCurPhrases(iCurIndex) = rsDC.Fields(0)        'Set working array of phrases
				     iCurIndex=iCurIndex+1                          'Increment counter
				End if
			 Next                                         'Next record
             



				       'Phrase found in record set
				   aryCurPhrase=ParseName(rsDC.Fields(0))   'Parse phrase to count words
				   iNumTermsRet=UBOUND(aryCurPhrase)         'Count the words
				   For iCurIndex = 0 to iNumTermsRet         'Build phrase from input string
				        strCompPhrase = strCompPhrase & TERMS(iCurIndex)
						
		
END FUNCTION

PUBLIC FUNCTION GetStdAbbr(TERMS)

END FUNCTION

PUBLIC FUNCTION GetKeyWords(TERMS)
END FUNCTION

PUBLIC FUNCTION GetDictName(TERMS)
END FUNCTION

PUBLIC FUNCTION GetColumnName(TERMS)
END FUNCTION

PUBLIC FUNCTION FindPhrases(TERMS)
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
	aryForbiddenChars(14)= """
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
DIM strClassWord as 	
END FUNCTION

PUBLIC FUNCTION CheckDuplicate(TERM)
END FUNCTION

PUBLIC FUNCTION AddToDb(ELEMENT)
END FUNCTION

PUBLIC FUNCTION DeleteFromDb(OBJECT, TYPE)
END FUNCTION

%>
