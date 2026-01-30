
<%
'ERROR_MESSAGES.INC
PUBLIC FUNCTION GET_MESSAGES(MESSAGE_NO)
Dim aryMessage(1)

    Select case "MESSAGE_NO"
        CASE "001"
          aryMessage(0)= "Class word not found."
          aryMessage(1) = "Use of a datatype class word such as 'amount' or 'code' in each label is suggested."
          GET_MESSAGES=aryMessage
		CASE "002"
<TR>
<TD ALIGN=RIGHT>2</TD>
<TD>Class word use is suggested.</TD>
<TD>A datatype class word such as 'amount' or 'code' is required in each label.</TD>
</TR>
		CASE "003"
<TR>
<TD ALIGN=RIGHT>3</TD>
<TD>Class word must be abbreviated.</TD>
<TD>Datatype class word such as 'amount' or 'code' must be abbreviated (e.g. amt or cd).</TD>
</TR>
		CASE "004"
<TR>
<TD ALIGN=RIGHT>4</TD>
<TD>Approved Class word not found.</TD>
<TD>A datatype class word such as 'amount' or 'code' is required in each label.</TD>
</TR>
		CASE "005"
<TR>
<TD ALIGN=RIGHT>5</TD>
<TD>Prime term not found.</TD>
<TD>A topic identifier (such as 'employee' or 'account')  is required in each label.</TD>
</TR>
		CASE "006"
		<TR>
<TD ALIGN=RIGHT>6</TD>
<TD>Abbreviation substitution.</TD>
<TD></TD>
</TR>
		CASE "007"
		<TR>
<TD ALIGN=RIGHT>7</TD>
<TD>Tem substitution</TD>
<TD></TD>
</TR>
		CASE "008"
		<TR>
<TD ALIGN=RIGHT>8</TD>
<TD>Suffix use caution.</TD>
<TD></TD>
</TR>
		CASE "009"
		<TR>
<TD ALIGN=RIGHT>9</TD>
<TD>Preposition/Conjunction use caution.</TD>
<TD></TD>
</TR>
		CASE "010"
		<TR>
<TD ALIGN=RIGHT>10"</TD>
<TD>Plural form discouraged</TD>
<TD>The use of plurals is discouraged.</TD>
</TR>
		CASE "011"
		<TR>
<TD ALIGN=RIGHT>11</TD>
<TD>Verb use caution.</TD>
<TD></TD>
</TR>
		CASE 012
		<TR>
<TD ALIGN=RIGHT>12</TD>
<TD>Term restricted/use discouraged.</TD>
<TD>These terms are restricted or reserved:</TD>
</TR>
		CASE 013
		<TR>
<TD ALIGN=RIGHT>13</TD>
<TD>Term restricted</TD>
<TD>These terms are restricted or reserved:</TD>
</TR>
		CASE 014
		<TR>
<TD ALIGN=RIGHT>14</TD>
<TD>Term found in singular form.</TD>
<TD></TD>
</TR>
		CASE 015
		<TR>
<TD ALIGN=RIGHT>15</TD>
<TD>Term reserved for prime word.</TD>
<TD>These terms are reserved as prime words:</TD>
</TR>
		CASE 016
		<TR>
<TD ALIGN=RIGHT>16</TD>
<TD>Term this long should be abbreviated.</TD>
<TD>Terms are automatically abbreviated in short form if longer than:</TD>
</TR>
		CASE 017
		<TR>
<TD ALIGN=RIGHT>17</TD>
<TD>Term this long must be abbreviated.</TD>
<TD>Terms are automatically abbreviated in short form if longer than:</TD>
</TR>
		CASE 018
		<TR>
<TD ALIGN=RIGHT>18</TD>
<TD>Unabbreviated terms disallowed</TD>
<TD>Abbreviation term use is manditory if approved abbreviations exist.</TD>
</TR>
		CASE 019
		<TR>
<TD ALIGN=RIGHT>19</TD>
<TD>Abbreviated terms disallowed</TD>
<TD>The use of abbreviated terms is disallowed.</TD>
</TR>
		CASE 02"0
		<TR>
<TD ALIGN=RIGHT>20</TD>
<TD>OK; but approved abbreviation exists.</TD>
<TD>If abbreviations available they may be prefered to long forms.</TD>
</TR>
		CASE 02"1
		<TR>
<TD ALIGN=RIGHT>21</TD>
<TD>Term unapproved, abbreviated form?</TD>
<TD></TD>
</TR>
		CASE 02"2
		<TR>
<TD ALIGN=RIGHT>22</TD>
<TD>Term unapproved or unidentified.</TD>
<TD>The use of a system or database identifying term is suggested and should be the first word in each label.</TD>
</TR>
		CASE 02"3
		<TR>
<TD ALIGN=RIGHT>23</TD>
<TD>Term not approved.</TD>
<TD>The use of a system or database identifying term is suggested and should be the first word in each label.</TD>
</TR>
		CASE 02"4
		<TR>
<TD ALIGN=RIGHT>24</TD>
<TD>Term not approved/identified.</TD>
<TD>The use of a system or database identifying term is suggested and should be the first word in each label.</TD>
</TR>
		CASE 02"5
		<TR>
<TD ALIGN=RIGHT>25</TD>
<TD>'Data, element, system'  etc. often redundant.</TD>
<TD>'Data, element, system'  etc. often redundant.</TD>
</TR>
		CASE 02"6
		<TR>
<TD ALIGN=RIGHT>26</TD>
<TD>Terms are usually not plural.</TD>
<TD>Terms are usually not plural.</TD>
</TR>
		CASE 02"7
		<TR>
<TD ALIGN=RIGHT>27</TD>
<TD>Numeric field usually AMT or CNT.</TD>
<TD>Numeric field usually AMT or CNT.</TD>
</TR>
		CASE 02"8
		<TR>
<TD ALIGN=RIGHT>28</TD>
<TD>Alphanumeric 60+ field usually TXT or DSR.</TD>
<TD>Alphanumeric 60+ field usually TXT or DSR.</TD>
</TR>
		CASE 02"9
		<TR>
<TD ALIGN=RIGHT>29</TD>
<TD>Alphanumeric 1 field usually IND or FLG.</TD>
<TD>Alphanumeric 1 field usually IND or FLG.</TD>
</TR>
		CASE 03"0
		<TR>
<TD ALIGN=RIGHT>30</TD>
<TD>Modifier/adjective should not be first term.</TD>
<TD>Modifier/adjective should not be first term.</TD>
</TR>
		CASE 03"1
		<TR>
<TD ALIGN=RIGHT>31</TD>
<TD>Modifer/adjective must not be first term.</TD>
<TD>Modifer/adjective must not be first term.</TD>
</TR>
		CASE 03"2
		<TR>
<TD ALIGN=RIGHT>32</TD>
<TD>System/Record ID should not be in element.</TD>
<TD>System/Record ID should not be in element.</TD>
</TR>
		CASE 03"3
		<TR>
<TD ALIGN=RIGHT>33</TD>
<TD>System/Record ID must not be in element.</TD>
<TD>System/Record ID must not be in element.</TD>
</TR>
		CASE 03"4
		<TR>
<TD ALIGN=RIGHT>34</TD>
<TD>Entity should be first term.</TD>
<TD>An Entity identifier should be first term.</TD>
</TR>
		CASE 03"5
		<TR>
<TD ALIGN=RIGHT>35</TD>
<TD>Entity must be first term.</TD>
<TD>An Entity identifier must be first term.</TD>
</TR>
		CASE 03"6
		<TR>
<TD ALIGN=RIGHT>36</TD>
<TD>Record/file ID should be first term.</TD>
<TD>A Record or file ID should be first term.</TD>
</TR>
		CASE 03"7
		<TR>
<TD ALIGN=RIGHT>37</TD>
<TD>Record/file ID must be first term.</TD>
<TD>A record or file (database relation or table) identifying term is required and must be the first word in each label.</TD>
</TR>
		CASE 03"8
		<TR>
<TD ALIGN=RIGHT>38</TD>
<TD>System/database ID should be first term.</TD>
<TD>A system or database identifying term is required and must be the first word in each label.</TD>
</TR>
		CASE 03"9
		<TR>
<TD ALIGN=RIGHT>39</TD>
<TD>System/database ID must be first term.</TD>
<TD>The use of a system or database identifying term is suggested and should be the first word in each label.</TD>
</TR>
		CASE 04"0
		<TD ALIGN=RIGHT>40</TD>
<TD>Prime/topic should be first term.</TD>
<TD>The use of &quot;Prime&quot; terms is suggested and should be the first word in each label.</TD>
</TR>
		CASE 04"1
		<TR>
<TD ALIGN=RIGHT>41</TD>
<TD>Prime/topic must be first term.</TD>
<TD>A &quot;Prime&quot; term is required and must be the first word in each label.</TD>
</TR>
		CASE 04"2
		<TR>
<TD ALIGN=RIGHT>42</TD>
<TD>Datatype class should be last term.</TD>
<TD>A datatype &quot;Class&quot; term such as &quot;Code, Amount, Name&quot; etc is required and must be the last word in each label.</TD>
</TR>
		CASE 04"3
		<TR>
<TD ALIGN=RIGHT>43</TD>
<TD>Datatype class must be last term.</TD>
<TD>The use of datatype &quot;Class&quot; terms such as &quot;Code, Amount, Name&quot; etc is suggested as the last word in each label.</TD>
</TR>
		CASE 04"4
		<TR>
<TD ALIGN=RIGHT>44</TD>
<TD>Terms count exceed max. suggested.</TD>
<TD>Object metadata label term count suggested maximum (in number of words) is:</TD>
</TR>
		CASE 04"5
		<TR>
<TD ALIGN=RIGHT>45</TD>
<TD>Terms count exceed max. allowed.</TD>
<TD>Object metadata label term count maximum (in number of words) is:</TD>
</TR>
		CASE 04"6
		<TR>
<TD ALIGN=RIGHT>46</TD>
<TD>Terms count below min. suggested.</TD>
<TD>Object metadata label term count minimum suggested (in number of words) is:</TD>
</TR>
		CASE 04"7
		<TR>
<TD ALIGN=RIGHT>47</TD>
<TD>Term item count less than min. allowed</TD>
<TD>Object metadata label term count minimum (in number of words) is:</TD>
</TR>
		CASE 04"8
		<TR>
<TD ALIGN=RIGHT>48</TD>
<TD>Name longer than suggested.</TD>
<TD>Object metadata label suggested maximum length (in number of characters) is:</TD>
</TR>
		CASE 04"9
		<TR>
<TD ALIGN=RIGHT>49</TD>
<TD>Name too long.</TD>
<TD>Object metadata label maximum length (in number of characters) is:</TD>
</TR>
		CASE 05"0
		<TD ALIGN=RIGHT>50</TD>
<TD>Name shorter than suggested.</TD>
<TD>Object metadata label suggested minimum length (in number of characters) is:</TD>
</TR>
		CASE 05"1
<TR>	
	<TD ALIGN=RIGHT>51</TD>
<TD>Name too short.</TD>
<TD>Object metadata label minimum length (in number of characters) is:</TD>
</TR>
		CASE 05"2
<TR>
		<TD ALIGN=RIGHT>52</TD>
<TD>Lower case suggested.</TD>
<TD>Labels should be in lower case.  For example:&quot;employee_id&quot;.</TD>
</TR>

		CASE 05"3
		<TR>
<TD ALIGN=RIGHT>53</TD>
<TD>Case should be lower.</TD>
<TD>Labels should be in lower case.  For example: &quot;EMPLOYEE_ID&quot;.</TD>
</TR>
		CASE 05"4
		<TR>
<TD ALIGN=RIGHT>54</TD>
<TD>Term separators required.</TD>
<TD>Term Case separators (e.g. &quot;EmpLastName&quot;) are required.</TD>
</TR>
		CASE 05"5
		<TR>
		<TD ALIGN=RIGHT>55</TD>
<TD>Term Case separators allowed but discouraged.</TD>
<TD>Term Case separators (e.g. &quot;EmpLastName&quot;) are allowed but discouraged.</TD>
		CASE 05"6
		</TR>
<TR>
<TD ALIGN=RIGHT>56</TD>
<TD>Term Case separators disallowed.</TD>
<TD>Term Case separators (e.g. &quot;EmpLastName&quot;) are not allowed.</TD>
</TR>
		CASE 05"7
		<TR>
<TD ALIGN=RIGHT>57</TD>
<TD>Numerical characters discouraged</TD>
<TD>The use of numerical characters is discouraged.</TD>
</TR>
		CASE 05"8
		<TR>
<TD ALIGN=RIGHT>58</TD>
<TD></TD>
<TD>The following term separators (e.g. the &quot;_&quot; in &quot;Last_Name&quot; are allowed:</TD>
</TR>
		CASE 05"9
		<TR>
<TD ALIGN=RIGHT>59</TD>
<TD></TD>
<TD>The following term separator (e.g. the &quot;_&quot; in &quot;Last_Name&quot; is preferred:</TD>
</TR>
		CASE 06"0
		<TR>
<TD ALIGN=RIGHT>60</TD>
<TD>Upper case suggested.</TD>
<TD>Labels should be in upper case.  For example: &quot;Employee_ID&quot;.</TD>
</TR>

		CASE 06"1
		<TD ALIGN=RIGHT>61</TD>
<TD>Case should be UPPER.</TD>
<TD>Labels should be in upper case.  For example: &quot;Employee_ID&quot;.</TD>
</TR>
<TR>
		CASE 06"2
<TD ALIGN=RIGHT>62</TD>
<TD></TD>
<TD>The use of Case as term separators (e.g. employeeLastName) is discouraged, but allowed.</TD>
</TR>
<TR>
		CASE 06"3
		<TR>

<TD ALIGN=RIGHT>63</TD>
<TD></TD>
<TD>The use of Case as term separators (e.g. employeeLastName) is disallowed.</TD>
</TR>
		CASE 06"4
		<TR>
<TD ALIGN=RIGHT>64</TD>
<TD>Term separator allowed but not prefered.</TD>
<TD>The following term separators are allowed but not preferred:</TD>
</TR>
		CASE 06"5
		<TR>
<TD ALIGN=RIGHT>65</TD>
<TD>Term separator disallowed.</TD>
<TD>The following term separators are disallowed:</TD>
</TR>
		CASE 06"6
		<TR>
<TD ALIGN=RIGHT>66</TD>
<TD>Character discouraged.</TD>
<TD>Use of the following characters is discouraged:</TD>
</TR>

		CASE 06"7
		<TR>
<TD ALIGN=RIGHT>67</TD>
<TD>Character disallowed.</TD>
<TD>Use of the following characters is disallowed:</TD>
</TR>
		CASE 06"8
		<TR>
<TD ALIGN=RIGHT>68</TD>
<TD>Class word longer than suggested.</TD>
<TD>Datatype class words length must be less than:</TD>
</TR>
		CASE 06"9
		<TR>
<TD ALIGN=RIGHT>69</TD>
<TD>Class word too long.</TD>
<TD>Datatype class words length must be less than:</TD>
</TR>
		CASE 07"0
		<TR>
<TD ALIGN=RIGHT>70</TD>
<TD>Class word shorter than suggested.</TD>
<TD>Datatype class words must be at least equal to or longer than:</TD>
</TR>

		CASE 07"1
<TR>
		<TD ALIGN=RIGHT>71</TD>
<TD>Class word too short.</TD>
<TD>Datatype class words must be at least equal to or longer than:</TD>
</TR>
		CASE 07"2
		<TR>
<TD ALIGN=RIGHT>72</TD>
<TD>Prime term use is suggested.</TD>
<TD>A topic identifier (such as 'employee' or 'account')  is suggested in each label.</TD>
</TR>
		CASE 07"3
		CASE 07"3
		CASE 07"4
     End Select

End Function
%>