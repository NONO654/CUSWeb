
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
			//if it is context's root roles then change order
			if(roleName.startsWith("ctx::"))
			{
				//System.out.println("parentRoleResult: "+parentRoleResult);
				String rootRolesArr[] = parentRoleResult.split(",");
				parentRoleResult = rootRolesArr[0] + "," + rootRolesArr[2] + "," + rootRolesArr[1];
				//System.out.println("parentRoleResult: "+parentRoleResult);
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
		//get key iterator (list iterator in this report get know previous element)
		ListIterator resultItr = resultList.listIterator();
		//step through each result
		while(resultItr.hasNext())
		{
			//change color
			color = changeRowColor(color);
			//if there are more than one results in the list then highlight them with new color
			if(resultItr.hasPrevious())
				color = "#ffccff";
			//get result
			String resultStr = (String)resultItr.next();
			//flag to check if it is last result
			boolean isLast = !(resultItr.hasNext());
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
	public void addBarTD(JspWriter out, String tdClass, String roleName, boolean isMainLevel, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap, HashMap grantedMaskMap) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		
		//start table
		out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
		//start row
		out.print("<tr>");
		
		if(initialWidth != 0)
			out.print("<td width='" + initialWidth + "%'></td>");

		String grantedMaskMsg = "";
		//if Person has mask access then show that one to Contexts as well
		if(roleName.contains("ctx::") &&  grantedMaskMap.containsKey("Person"))
		{
			grantedMaskMsg = (String)grantedMaskMap.get("Person");
		}
		//else
		else if(grantedMaskMap.containsKey(roleName))
		{
			grantedMaskMsg = (String)grantedMaskMap.get(roleName);
			
		}

        String i18_level = isMainLevel ? getNLS("Level."+roleName) : roleName;
		//check accesses
		ArrayList resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
		//if it is context node and has either access or its any root roles have accesses( or granted mask has Person access)
		if(roleName.contains("ctx::") && (resultList.size() > 0 || hasAnyRootRolesAccess(roleName, uniqueRoleResultsMap, uniqueParentsMap) || grantedMaskMap.containsKey("Person") || grantedMaskMsg.contains("DEFAULT")))
		{
			//write cell with access image
			//manage right border for granted mask msg
			if(!grantedMaskMsg.equals(""))
				out.print("<td class='" + tdClass + "' style=' border-right:0px'>");
			else
				out.print("<td class='" + tdClass + "' >");
			//if it doesn't have result and its no root roles has result but either it has person mask access	 or DEFAULT mask
			if((grantedMaskMap.containsKey("Person") || grantedMaskMsg.contains("DEFAULT")) && !(resultList.size() > 0 || hasAnyRootRolesAccess(roleName, uniqueRoleResultsMap, uniqueParentsMap)))
				out.print("<img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniCancel.gif' />&nbsp;<b>" + i18_level + "");
			//else
			else
				out.print("<img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "");
			//show granted access
			if(!grantedMaskMsg.equals(""))
			{
				if(grantedMaskMsg.contains("DEFAULT"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='green'><b>Granted: " + grantedMaskMsg + "</b></font></td>");
				}
				else if(grantedMaskMsg.contains("Granted:"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='blue'><b>Granted: " + grantedMaskMsg + "</b></font></td>");
				}
				else if(grantedMaskMsg.contains("Error:"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='red'><b>Error: " + grantedMaskMsg + "</b></font></td>");
				}
				
			}
		}
		//if it is not context node but has access
		else if(!roleName.contains("ctx::") && resultList.size() > 0)
		{//System.out.println("Hi:"+grantedMaskMsg);
			//write cell with access image 
			//manage right border for granted mask msg
			if(!grantedMaskMsg.equals(""))
				out.print("<td class='" + tdClass + "' style=' border-right:0px'>");
			else
				out.print("<td class='" + tdClass + "' >");
			//if it is public and 	has only DEFAULT access
			if(roleName.equals("Public") && resultList.size() == 1)
				out.print("<img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniCancel.gif' />&nbsp;<b>" + i18_level + "");
			//else
			else
				out.print("<img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "");
			//show granted access
			if(!grantedMaskMsg.equals(""))
			{
				if(grantedMaskMsg.contains("Granted:"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='blue'><b>Granted: " + grantedMaskMsg + "</b></font></td>");
				}
				else if(grantedMaskMsg.contains("Error:"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='red'><b>Error: " + grantedMaskMsg + "</b></font></td>");
				}
				else	if(grantedMaskMsg.contains("Unexpected:"))
				{
					grantedMaskMsg = grantedMaskMsg.substring(grantedMaskMsg.indexOf(":") + 1, grantedMaskMsg.length());
					out.print("</td><td class='" + tdClass + "' style='text-align:right; border-left:0px'><font color='red'><b>Unexpected: " + grantedMaskMsg + "</b></font></td>");
				}
			}
			
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
    //----------------------------------------------------------------------
	//method to add mask result to the list
    //----------------------------------------------------------------------
	public boolean addMaskResult(String roleName, ArrayList maskResultList, HashMap uniqueRoleResultsMap)
	{
		//get result list
		ArrayList resultList = (ArrayList)uniqueRoleResultsMap.get(roleName);
		//if it has access result
		if(resultList.size() > 0)
		{
			//if it has only one access, add granted access
			if(resultList.size() == 1 && ! resultList.get(0).equals("DEFAULT"))
			{
				maskResultList.add( resultList.get(0));
				return true;
			}
			//else add result masks
			else
			{
				for(int i = 0; i < resultList.size(); i++)
				{
					if(!resultList.get(i).equals("DEFAULT"))
						maskResultList.add( resultList.get(i)); 
				}
				
				return true;
			}
		}
		else
			return false;
	}
    //----------------------------------------------------------------------
	//method to add mask result to the grantedMaskMap
    //----------------------------------------------------------------------
	public void addMaskInMap(String roleName, HashMap grantedMaskMap, ArrayList maskResultList)
	{
		//string to contain error msg
		String errorMsg = "Error:";
		if(maskResultList.size() == 1)
		{
			//special error for Public	mask
			if(roleName.equals("Public"))
				grantedMaskMap.put(roleName, "Unexpected:" + maskResultList.get(0));
			else
				grantedMaskMap.put(roleName, "Granted:" + maskResultList.get(0));
		}
		else
		{
			for(int i = 0; i < maskResultList.size(); i++)
				errorMsg += maskResultList.get(i) + ",";
			//special error for Public	mask
			if(roleName.equals("Public") && maskResultList.size() > 0)
			{
				//add message
				grantedMaskMap.put(roleName, "Unexpected:" + errorMsg.substring(errorMsg.indexOf(":") + 1, errorMsg.length() - 1));
			}
			else
			{
				errorMsg = errorMsg.substring(0, errorMsg.length() - 1) + "?";
				//add message
				grantedMaskMap.put(roleName, errorMsg);
			}
		}
	}

    //----------------------------------------------------------------------
	//method to update granted mask map
    //----------------------------------------------------------------------
	public void updateGrantedMaskMap(HashMap grantedMaskMap, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap, String[] contextArray)
	{
			ArrayList maskResultList = new ArrayList();

			//check for Public access
			String roleName = "Public";
			//reset mask result list
			maskResultList.clear();
		    addMaskResult(roleName, maskResultList, uniqueRoleResultsMap);
		    addMaskInMap(roleName, grantedMaskMap, maskResultList);
			//System.out.println(grantedMaskMap);

			//check accesses as per precence rule
			boolean isGranted = false;
			//check Person access
			roleName = "Person";
			//reset mask result list
			maskResultList.clear();
			isGranted = addMaskResult(roleName, maskResultList, uniqueRoleResultsMap);
			//if granted then update maskMap and return (precedence level 1)
			if(isGranted)
			{
				 addMaskInMap(roleName, grantedMaskMap, maskResultList);
				return;
			}
			//if not granted
			else
			{
				boolean isGrantedForCtx = false;
				//step through each context
				for(int j = 0; j < contextArray.length; j++)
				{
					//reset mask result list
					maskResultList.clear();
					//reset flag
					isGranted = false;
				
					//check all ctx accesses
					String ctxName = contextArray[j];
					isGrantedForCtx = addMaskResult(ctxName, maskResultList, uniqueRoleResultsMap);
					//if granted (precedence level 2)
					if(isGrantedForCtx)
					{
						isGranted = true;
					}
					//else
					else
					{
						//get parent roles
						String roleResult = (String)uniqueParentsMap.get(ctxName);
						String[] roleArray = roleResult.split(",");
						//step through each individual role of context
						for(int k = 0; k < roleArray.length && !roleArray[k].equals(""); k++)
						{
							//check all role accesses
							roleName = roleArray[k];
							boolean isGrantedForRootRole = addMaskResult(roleName, maskResultList, uniqueRoleResultsMap);
							//if granted for any ctx's root role, then access is granted finally	 (precedence level 3)
							if(isGrantedForRootRole)
							{
								isGranted = true;
								break;
							}
						}

					}
					//if granted then update maskMap 
					if(isGranted)
					{
						 addMaskInMap(ctxName, grantedMaskMap, maskResultList);
					}
					else
					{
						ArrayList listWithDefaultMask = new ArrayList();
						listWithDefaultMask.add("DEFAULT");
						addMaskInMap(ctxName, grantedMaskMap, listWithDefaultMask);
						//System.out.println(grantedMaskMap);
					}
				}
			}
			
		}
	%>
	<body>
	<%
        initTrace("AdminMaskReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);

        try {
		//get input parameters
		String personName = request.getParameter("treeRoot");
		String selectedMasks = request.getParameter("maskPattern");

		//get array of masks
		String maskArray[] = selectedMasks.split(",");
		
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
		//hash map to contain distinct role names as keys and results(list of mask names) as values
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

		//create entry for person access
		uniqueRoleResultsMap.put("Person", new ArrayList());
		//create entry for Public access
		//add "DEFAULT" as result
		ArrayList defaultForPublic = new ArrayList();
		defaultForPublic.add("DEFAULT");
		uniqueRoleResultsMap.put("Public", defaultForPublic);
		
		//getting results
		String maskName = "";
		String maskResults = "";
		//string to contain query
		String query = "";
		//string to contain query result
		String result = "";
		//step through each mask
		for(int i = 0; i < maskArray.length; i++)
		{
			//if it is empty then skip further processing and continue
			if(maskArray[i].equals(""))
				continue;
			//get mapped mask name in M1 <TODO - confirm if this is always OK. What if customers have different prefix>
			maskName = "mask::" + maskArray[i];
			//start new query

			//execute mask query
			if(!query.equals(""))
			{
				//get results
				try{
					result = MqlUtil.mqlCommand(context,"print command $1 select user global",maskName);
					maskResults += result + "\n";
				}
				catch (Exception ex) {
					System.out.println("Exception: "+ex);
				}
			}
		}
        dbg("Masks Result:\n["+maskResults+"]");

		//parse mask query results and update role results 
		ArrayList resultList = null;
		String resultLine = "";
		String[] maskResultsArr = maskResults.split("\n");
		//step through each result
		for(int i = 0; i < maskResultsArr.length; i++)
		{
			//read result line
			resultLine = maskResultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//get mask name and continue for its results
			if(resultLine.contains("command"))
			{
				maskName = (resultLine.substring(resultLine.indexOf("command ") + 8, resultLine.length())).trim();
				//get mask name from mapped M1 mask name<TODO - confirm if this is always OK. What if customers have different prefix>
				maskName = maskName.substring(maskName.indexOf("mask::") + 6, maskName.length());
                dbg("=== Mask ["+maskName+"]");
			}
            else if(resultLine.contains("global = "))
			{
                // check for public access
                if (resultLine.contains("TRUE")) {
					roleName = "Public";
					result = maskName;
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
            else if(resultLine.contains("user"))
			{
			    //get access result
				roleName = (resultLine.substring(resultLine.indexOf(" = ") + 3, resultLine.length())).trim();
				if(roleName.equals(personName))
					roleName = "Person";
				result = maskName;
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
		//build map of roles as keys and granted masks as values
		HashMap grantedMaskMap = new HashMap();
		//update masks map
		updateGrantedMaskMap(grantedMaskMap, uniqueRoleResultsMap, uniqueParentsMap, contextArray);
		
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
			addBarTD(out, "barTDInReport", "Person", true, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap, grantedMaskMap);
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
		<div id="ContextBarDiv" class="barDivInReport" >
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
			addBarTD(out, "ctxBarTDInReport", roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap, grantedMaskMap);
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
				addBarTD(out, "stateAccessBarTDInReport", roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap, grantedMaskMap);
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
			addBarTD(out, "barTDInReport", "Public", true, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap, grantedMaskMap);
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
