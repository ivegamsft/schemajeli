
	// Customize default NavBar menu color - bgColor, fontColor, mouseoverColor
	setDefaultNavBarMenuColor("#6699CC", "white", "red");
	
	//***** Add NavBar menus *****
	addNavBarMenu("Search", "Search Menu", "","");
	addNavBarSubMenu("Search","Databases","search_dbs.asp");
	addNavBarSubMenu("Search","Tables","search_tbls.asp");
	addNavBarSubMenu("Search","Elements","search_elem.asp");
	addNavBarSubMenu("Search","Element Key Words","search_elem_kywds.asp");
	addNavBarSubMenu("Search","Standard Abbreviations","search_std_abbrs.asp");
            	
	addNavBarMenu("Reports", "Reports Menu", "","");
	addNavBarSubMenu("Reports","View Class Words","query_result.asp?RelObject=ClassWord");
	addNavBarSubMenu("Reports","Server Reoprt","query_result.asp?RelObject=Server");
	addNavBarSubMenu("Reports","Generate DDL","rpt_ddl.asp");
                 
	addNavBarMenu("Maintain", "Maintain Objects", "","");
	addNavBarSubMenu("Maintain","Add/Mmaitain Databases","add_db_nme.asp");
	addNavBarSubMenu("Maintain","Add/Maintain Tables","add_tbl_nme.asp");
	addNavBarSubMenu("Maintain","Add Element","add_elem_nme.asp");
	addNavBarSubMenu("Maintain","Maintain Element","add_elem_nme.asp?Option=Maintain");

    	
	addNavBarMenu("Admin", "Administer Objects", "","");
	addNavBarSubMenu("Admin","Servers","add_server.asp");
	addNavBarSubMenu("Admin","Standard Abbreviations","add_stdabbr.asp");
	addNavBarSubMenu("Admin","Users","add_user.asp");
	addNavBarSubMenu("Admin","Copy Table","copy_tbl.asp");    
	addNavBarSubMenu("Admin","Status Move","status_move.asp");

	addNavBarMenu("Help", "Help", "","");
	addNavBarSubMenu("Help", "Using the Repository", "/Timesheet/Accounting.asp");
	addNavBarSubMenu("Help", "Generating Reports", "/Timesheet/Emails.asp");
	addNavBarSubMenu("Help", "Maintaining Objects", "/Timesheet/Emails.asp");
	addNavBarSubMenu("Help", "Administering Objects", "/Timesheet/Emails.asp");
	addNavBarSubMenu("Help", "Support", "/Timesheet/Emails.asp");
	addNavBarSubMenu("Help", "Return to Main Page", "/Timesheet/Emails.asp");

	addNavBarMenu("Exit", "Exit", "","");
	addNavBarSubMenu("Exit", "Exit and Log-Off", "exit.asp");
    