
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<html>

<head>

	<title></title>
	
	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />
	
</head>
	
	<%!
    //----------------------------------------------------------------------
	//method to retrieve parent roles if not retrieved already
    //----------------------------------------------------------------------
	public String getParentRoles(Context context, String roleName, HashMap uniqueParentsMap)
	{
		//string to contain parent roles
		String parentRoleResult = "";
		//if already retrieved then get it from map
		if(uniqueParentsMap.containsKey(roleName))
		{
			parentRoleResult = (String)uniqueParentsMap.get(roleName);
		}
		//else retrieve and update map
		else
		{
			//get parent roles
			
			try{
				parentRoleResult = MqlUtil.mqlCommand(context,"list role $1 select $2 dump",roleName,"parent");
			}
			catch (Exception ex) {
				System.out.println("Exception: "+ex);
			}
			uniqueParentsMap.put(roleName, parentRoleResult);
		}
		//return result
		return parentRoleResult;
	}
    //----------------------------------------------------------------------
	//method to get changed color for new Table row
    //----------------------------------------------------------------------
	public String changeRowColor(String color)
	{
		String newColor = color;
		if(color.equals("99FFFFF"))
			newColor = "CCFFFFF";
		else
			newColor = "99FFFFF";

		return newColor;
	}
    //----------------------------------------------------------------------
	//method to check if a context's any root roles have accesses
    //----------------------------------------------------------------------
	public boolean hasAnyRootRolesAccess(String ctxRoleName, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap)
	{
		boolean access = false;
		//get root role for particular context
		String ctxRootRoleResult = (String)uniqueParentsMap.get(ctxRoleName);
		String[] ctxRootRoleArray = ctxRootRoleResult.split(",");
		//step through each root role
		for(int j = 0; j < ctxRootRoleArray.length && !ctxRootRoleArray[j].equals(""); j++)
		{
			//get root role
			String ctxRootRoleName = ctxRootRoleArray[j];
			ArrayList rootRoleResultList = (ArrayList)uniqueRoleResultsMap.get(ctxRootRoleName);
			//if it has access
			if(rootRoleResultList.size() > 0)
			{
				access = true;
				break;
			}
		}
		//return result
		return access;
	}
    //----------------------------------------------------------------------
	//method to write table rows at current level with report node data
    //----------------------------------------------------------------------
	public void writeAllResults(JspWriter out, ArrayList resultList, int level, String color) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3 + 3;

		//start table
		out.print("<table border='0' cellpadding='5' cellspacing='0' width='100%'>");
		//write results in table rows
		//get key iterator
		Iterator resultItr = resultList.iterator();
		//step through each result
		while(resultItr.hasNext())
		{
			//get result
			String resultStr = (String)resultItr.next();
			//flag to check if it is last result
			boolean isLast = !(resultItr.hasNext());
			//change color
			color = changeRowColor(color);
			//start row
			out.print("<tr>");
			//add cell for empty space i.e. for indentation
			out.print("<td width='" + initialWidth + "%'></td>");
			//write access result cell
			out.print("<td align='right' bgcolor='" + color + "' class='cellInReport'");
			//manage border
			if(isLast)
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
			out.print(">&nbsp;" + resultStr);
			//end result cell
			out.print("</td>");			
			//close row
			out.print("</tr>");
		}
		//end table
		out.print("</table>");
	}
    //----------------------------------------------------------------------
	//method to add bar cell based on accesses
    //----------------------------------------------------------------------
	public void addBarTD(JspWriter out, String tdClass, String roleName, boolean isMainLevel, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		
		//start table
		out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
		//start row
		out.print("<tr>");
		
		if(initialWidth != 0)
			out.print("<td width='" + initialWidth + "%'></td>");

        String i18_level = isMainLevel ? getNLS("Level."+roleName) : roleName;
		//check accesses
		ArrayList resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
		//if it is context node and has either access or its any root roles have accesses
		if(roleName.contains("ctx::") && ((resultList!=null && resultList.size() > 0) || hasAnyRootRolesAccess(roleName, uniqueRoleResultsMap, uniqueParentsMap)))
		{
			//write cell with access image
			out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "</td>");
		}
		//if it is not context node but has access
		else if(!roleName.contains("ctx::") && resultList!=null && resultList.size() > 0)
		{
			//write cell with access image
			out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "</td>");
		}
		//else
		else
		{
			//check it should be displayed as expandible or not
			boolean expandible = false;
			//get parent roles
			String parentRoles = (String)uniqueParentsMap.get(roleName);
			if(parentRoles != null)
			{
				String[] parentRolesArr = parentRoles.split(",");
				//step through each parent role
				for(int k = 0; k < parentRolesArr.length && !parentRolesArr[k].equals(""); k++)
				{
					String parentRoleName = parentRolesArr[k];
					//check accesses
					resultList = (ArrayList)uniqueRoleResultsMap.get(parentRoleName);
					//if it has access, return true
					if(resultList.size() > 0)
					{
						expandible = true;
						break;
					}
				}
			}
			if(expandible)
			{
				//write cell with no access image but with + sign to make it expandible
				out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniCancel.gif' />&nbsp;<b>" + i18_level + "</td>");
			}
			else
			{
				//write cell with no access image with - sign
				out.print("<td class='" + tdClass + "'><img src='../common/images/buttonMinus.gif'  />&nbsp;<img src='../common/images/buttonMiniCancel.gif' />&nbsp;<b>" + i18_level + "</td>");
			}
		}
		//end row and table
		out.print("</tr></table>");
	}
    //----------------------------------------------------------------------
	//method to add context bar cell based on accesses
    //----------------------------------------------------------------------
	public void addContextBarTD(JspWriter out, String tdClass, String roleName, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap, String[] contextArray) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		
		//check accesses

		//check if it is Contexts' main node
		if(roleName.equals("Contexts"))
		{
			boolean access = false;
			//step through each context
			for(int j = 0; j < contextArray.length; j++)
			{
				//get role for particular context
				String ctxRoleName = contextArray[j];
				ArrayList ctxResultList = (ArrayList)uniqueRoleResultsMap.get(ctxRoleName);
				//if it has access or its any root roles have accesses
				if(ctxResultList.size() > 0 || hasAnyRootRolesAccess(ctxRoleName, uniqueRoleResultsMap, uniqueParentsMap))
				{
					access = true;
					break;
				}
				
			}
			//start table
			out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
			//start row
			out.print("<tr>");

			if(initialWidth != 0)
				out.print("<td width='" + initialWidth + "%'></td>");

			//if it has access
            String i18_level = getNLS("Level."+roleName);
			if(access)
			{
				//write cell with access image
				out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "</td>");
			}
			//else
			else
			{
				//write cell with no access image
				out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniCancel.gif' />&nbsp;<b>" + i18_level + "</td>");
			}
			//end row and table
			out.print("</tr></table>");
		}
	}
	
	%>
	<body>
	<%
        initTrace("AdminCommandReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        try {
		//get input parameters
		String personName = request.getParameter("treeRoot");
		String selectedCommands = request.getParameter("commandPattern");

		//get array of commands
		String commandArray[] = selectedCommands.split(",");
		
		//query to get Contexts of current user
		//get Contexts
		String personCTXResult = "";
		try{
			personCTXResult = MqlUtil.mqlCommand(context,"print person $1 select $2 dump",personName,"assignment");
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		String contextArray[] = personCTXResult.split(",");
		
		//build map for parent roles
		//hash map of parent roles with distinct role name as key
		HashMap uniqueParentsMap = new HashMap();
		//hash map to contain distinct role names as keys and results(list of command names) as values
		HashMap uniqueRoleResultsMap = new HashMap();

		String roleName = "";
		//step through each context
		for(int j = 0; j < contextArray.length; j++)
		{
			roleName = contextArray[j];
			//if not created already then create entry in map
			if(!uniqueRoleResultsMap.containsKey(roleName))
			{
				uniqueRoleResultsMap.put(roleName, new ArrayList());
			}
			//else don't go for inner loop and continue
			else
				continue;
			
			//get parent roles
			String roleResult = getParentRoles(context, roleName, uniqueParentsMap);
			String[] roleArray = roleResult.split(",");

			//step through each individual role of context
			for(int k = 0; k < roleArray.length && !roleArray[k].equals(""); k++)
			{
				roleName = roleArray[k];
				//if not created already then create entry in map
				if(!uniqueRoleResultsMap.containsKey(roleName))
				{
					uniqueRoleResultsMap.put(roleName, new ArrayList());
				}
			}
		}

		//create entry for Person access
		uniqueRoleResultsMap.put("Person", new ArrayList());
		//create entry for Public access
		uniqueRoleResultsMap.put("Public", new ArrayList());
		
		//getting results
		String commandName = "";
		String commandResults = "";
		//string to contain query
		String query = "";
		//string to contain query result
		String result = "";
		//step through each command
		for(int i = 0; i < commandArray.length; i++)
		{
			//if it is empty then skip further processing and continue
			if(commandArray[i].equals(""))
				continue;
			//get mapped command name in M1 <TODO - confirm if this is always OK. What if customers have different prefix??>
			commandName = "vplm::" + commandArray[i];
			//start new query
			//execute command query

				//get results
				try{
					result = MqlUtil.mqlCommand(context,"print command $1 select user global",commandName);
					commandResults += result + "\n";
				}
				catch (Exception ex) {
					System.out.println("Exception: "+ex);
				}
		}
        dbg("Commands Result:\n["+commandResults+"]");

		//parse command query results and update role results 
		ArrayList resultList = null;
		String resultLine = "";
		String[] commandResultsArr = commandResults.split("\n");
		//step through each result
		for(int i = 0; i < commandResultsArr.length; i++)
		{
			//read result line
			resultLine = commandResultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//get command name and continue for its results
			if(resultLine.contains("command"))
			{
				commandName = (resultLine.substring(resultLine.indexOf("command ") + 8, resultLine.length())).trim();
				//get command name from mapped M1 command name<TODO - confirm if this is always OK. What if customers have different prefix??>
				commandName = commandName.substring(commandName.indexOf("vplm::") + 6, commandName.length());
                dbg("=== Command ["+commandName+"]");
			}
            else if(resultLine.contains("global = "))
			{
                // check for public access
                if (resultLine.contains("TRUE")) {
					roleName = "Public";
					result = commandName;
					//update role results
					resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
					//if result is not in map, then put it in map
					if(resultList != null && !resultList.contains(result))
					{
						//update result list with results
						if(result != null && !result.equals("")) {
							resultList.add(result);
                            dbg("===     --> "+roleName);
                        }
					}
                }
			}
            else if(resultLine.contains("user = "))
			{
			    //get access result
				roleName = (resultLine.substring(resultLine.indexOf(" = ") + 3, resultLine.length())).trim();
				if(roleName.equals(personName))
					roleName = "Person";
				result = commandName;
				//update role results
				resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
				//if result is not in map, then put it in map
				if(resultList != null && !resultList.contains(result))
				{
					//update result list with results
					if(result != null && !result.equals("")) {
						resultList.add(result);
                        dbg("===     --> "+roleName);
                    }
				}
			}
		}
		
		//string to specify table row color
		String color = "CCFFFFF";
		//variable to specify current table row level in report
		int currentLevel = 0;
		//string to contain unique name for each div
		String divIdUniquePart = "";
	%>
		<!--generate report-->

		<div id="PersonBarDiv" class="barDivInReport" >
		<%
			//reset current level
			currentLevel = 0;
			//add bar cell based on access
			addBarTD(out, "barTDInReport", "Person", true, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
		%>
		</div>
		<div id="<%="Person" + divIdUniquePart%>Div" style="display:none">
		<%
		//check access
		resultList = (ArrayList)uniqueRoleResultsMap.get("Person");
		if(resultList.size() > 0)
		{
			//write all table rows with access results
			writeAllResults(out, resultList, currentLevel, color);
		}
		%>
		</div>
		&nbsp;
		<div id="contextBarDiv" class="barDivInReport" >
		<%
			//reset current level
			currentLevel = 0;
			//add bar cell based on access
			addContextBarTD(out, "barTDInReport", "Contexts", currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap, contextArray);
		%>
		</div>

		<div id="<%="Contexts" + divIdUniquePart%>Div" style="display:none">
		<%
		//update current level
		currentLevel++;
		//step through each context
		for(int j = 0; j < contextArray.length; j++)
		{
			roleName = contextArray[j];
			//add bar cell based on access
			divIdUniquePart = "" + j;
			addBarTD(out, "ctxBarTDInReport", roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
			%>
			<div id="<%=roleName + divIdUniquePart%>Div" style="display:none">
			<%
			//check access
			resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
			if(resultList.size() > 0)
			{
				//write all table rows with access results
				writeAllResults(out, resultList, currentLevel, color);
			}
			//update current level
			currentLevel++;
			//get individual roles
			String roleResult = getParentRoles(context, roleName, uniqueParentsMap);
			String[] roleArray = roleResult.split(",");
			//step through each context's root role
			for(int k = 0; k < roleArray.length && !roleArray[k].equals(""); k++)
			{
				roleName = roleArray[k];
				//add bar cell based on access
				divIdUniquePart = ""+j+k;
				addBarTD(out, "stateAccessBarTDInReport", roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
				%>
				<div id="<%=roleName + divIdUniquePart%>Div" style="display:none">
				<%
				//check access
				resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
				if(resultList.size() > 0)
				{
					//write all table rows with access results
					writeAllResults(out, resultList, currentLevel, color);
				}
				%>
				</div>
			<%
			}
			//update current level
			currentLevel--;
			%>
			</div>
		<%
		}
		%>
		</div>

		&nbsp;
		<div id="PublicBarDiv" class="barDivInReport" >
		<%
			//reset current level
			currentLevel = 0;
			//add bar cell based on access
			addBarTD(out, "barTDInReport", "Public", true, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
		%>
		</div>
		<div id="<%="Public" + divIdUniquePart%>Div" style="display:none">
		<%
		//check access
		resultList = (ArrayList)uniqueRoleResultsMap.get("Public");
		if(resultList.size() > 0)
		{
			//write all table rows with access results
			writeAllResults(out, resultList, currentLevel, color);
		}
		%>
		</div>
		
	<%
    }
    catch (Exception ex) {
        ex.printStackTrace();
    }
	%>
	
	</body>

</html>
