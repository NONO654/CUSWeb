
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmsecurity.util.PLMUtil" %>
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
    public String     _I18_ACCESS = "Access";
    public String     _I18_FILTER = "Filter";
    //----------------------------------------------------------------------
	//declare utility method to filter accesses from result
    //----------------------------------------------------------------------
	public String filterAccesses(String currentAccessResult, String[] accessArray)
	{
		//filter accesses based on the selected accesses
		//if selected access is "None"
		if(accessArray[0].equals("None"))
		{
			//if result is also "none", return "none"
			if(currentAccessResult.equals("none"))
				return currentAccessResult;
			//else return empty
			else
				return "NOT_REQUIRED";
		}
		//if result is "all", then return the same
		if(currentAccessResult.equals("all"))
			return currentAccessResult;
		//if selected access is not "All", then only filter accesses
		if(!accessArray[0].equals("All"))
		{
			String filteredAccessResult = "";
			for(int accessIdx = 0; accessIdx < accessArray.length; accessIdx++)
			{
				String selectedAccess = accessArray[accessIdx].toLowerCase();
				//if access result contains selected access then append that to a new string
				if(currentAccessResult.contains(selectedAccess))
				{
					//out.print(selectedAccess+"<br>");
					filteredAccessResult += selectedAccess + ",";
				}
			}
			if(filteredAccessResult.length() > 0) {
				currentAccessResult = filteredAccessResult.substring(0, filteredAccessResult.length() - 1);
            }
			else
				currentAccessResult = filteredAccessResult;
		}
        currentAccessResult = PLMUtil.replaceAll(currentAccessResult, ",", ", ");
		//return
		return currentAccessResult;
	}
	
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
			HashMap rootRoleResultMap = (HashMap)uniqueRoleResultsMap.get(ctxRootRoleName);
			//if it has access
			if(rootRoleResultMap.size() > 0)
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
	public void writeAllResults(JspWriter out, HashMap resultMap, int level, String color) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3 + 3;

		//start table
		out.print("<table border='0' cellpadding='5' cellspacing='0' width='100%'>");
		//write results in table rows
		//get key iterator
		Iterator keyItr = resultMap.keySet().iterator();
		//get previous policy name to manage rows color and borders
		String prevPolicyName = "";
		//step through each result
		while(keyItr.hasNext())
		{
			//get key which is policy:state
			String PSkey = (String)keyItr.next();
			//get result
			String resultStr = (String)resultMap.get(PSkey);
			//flag to check if it is last result
			boolean isLast = !(keyItr.hasNext());
			//get current policy and state name
			String[] PSArray = PSkey.split(":");
			String policyName = PSArray[0];
			String stateName = PSArray[1];
			//if policy is new, then change color
			if(!policyName.equals(prevPolicyName))
			{
				color = changeRowColor(color);
			}
			//start row
			out.print("<tr>");
			//add cell for empty space i.e. for indentation
			out.print("<td width='" + initialWidth + "%'></td>");
			//write policy cell
			//if policy is new
			if(!policyName.equals(prevPolicyName))
			{
				out.print("<td width='16%' bgcolor='" + color + "' class='policyCellInReport'");
				//manage borders
				out.print(" style=\"border-top:solid #6196ff 1px;\"");
				if(!keyItr.hasNext())
					out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
				out.print(">" + policyName + "</td>");
			}
			//else write empty policy cell
			else
			{
				out.print("<td width='16%' bgcolor='" + color + "' class='policyCellInReport'");
				if(isLast)
					out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
				out.print(">&nbsp;</td>");
			}
			//write state cell
			out.print("<td width='8%' bgcolor='" + color + "' class='stateCellInReport'");
			//manage border
			if(isLast)
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
			out.print(">" + stateName + "</td>");

			//write access result cell
			out.print("<td bgcolor='" + color + "' class='cellInReport'");
			//manage border
			if(isLast)
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
			//check if contains two results i.e. access and filter result
			if(resultStr.contains("\n"))
			{
				String[] resultArr = resultStr.split("\n");
				//make access result to be able to fit in current table row
				String accessResult = resultArr[0];
				if(accessResult.equals("none"))
				{
					accessResult = "<strike><font color='red'>none</font></strike>";
				}
				out.print("><b>"+_I18_ACCESS+":</b>&nbsp;" + accessResult + "<br><b>"+_I18_FILTER+":</b>&nbsp;&nbsp;" + resultArr[1]);
			}
			else
			{
				if(resultStr.equals("none"))
				{
					resultStr = "<strike><font color='red'>none</font></strike>";
				}
				out.print("><b>"+_I18_ACCESS+":</b>&nbsp;" + resultStr);
			}
			//end result cell
			out.print("</td>");			
			//close row
			out.print("</tr>");
			//update previous policy name
			prevPolicyName = policyName;
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
		HashMap resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
		//if it is context node and has either access or its any root roles have accesses
		if(roleName.contains("ctx::") && ((resultMap!=null && resultMap.size() > 0) || hasAnyRootRolesAccess(roleName, uniqueRoleResultsMap, uniqueParentsMap)))
		{
			//write cell with access image
			out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;<img src='../common/images/buttonMiniDone.gif' />&nbsp;<b>" + i18_level + "</td>");
		}
		//if it is not context node but has access
		else if(!roleName.contains("ctx::") && resultMap!=null && resultMap.size() > 0)
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
					resultMap = (HashMap)uniqueRoleResultsMap.get(parentRoleName);
					//if it has access, return true
					if(resultMap!=null && resultMap.size() > 0)
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
				HashMap ctxResultMap = (HashMap)uniqueRoleResultsMap.get(ctxRoleName);
				//if it has access or its any root roles have accesses
				if(ctxResultMap.size() > 0 || hasAnyRootRolesAccess(ctxRoleName, uniqueRoleResultsMap, uniqueParentsMap))
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
	//method to check if the role is required to be shown
    //----------------------------------------------------------------------
	public boolean isRoleRequired(String roleName, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap)
	{
		HashMap resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
		//if it has access
		if(resultMap.size() > 0)
			return true;
		else
		{
			//get parent roles
			String parentRoles = (String)uniqueParentsMap.get(roleName);
			//if it has no access and no parent roles
			if(parentRoles == null || parentRoles.equals(""))
				return false;
			//if it has no access but has parent roles
			else
			{
				String[] parentRoleArray = parentRoles.split(",");
				//step through each parent role
				for(int i = 0; i < parentRoleArray.length && !parentRoleArray[i].equals(""); i++)
				{
					if(isRoleRequired(parentRoleArray[i], uniqueRoleResultsMap, uniqueParentsMap))
						return true;
				}
				return false;
			}
		}
	}
    //----------------------------------------------------------------------
	//method to add bar cell if required
    //----------------------------------------------------------------------
	public void addBarIfRequired(JspWriter out, String tdClass, String roleName, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		//if it is to be shown only if it is required without access image
		if(isRoleRequired(roleName, uniqueRoleResultsMap, uniqueParentsMap))
		{
			//start table
			out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
			//start row
			out.print("<tr>");

			if(initialWidth != 0)
				out.print("<td width='" + initialWidth + "%'></td>");

			//write cell without access image
			out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"/>&nbsp;&nbsp;<b>" + roleName + "</td>");
			//end row and table
			out.print("</tr></table>");
		}
	}
		
	%>
	<body>
	<%
        initTrace("AdminPolicyReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        _I18_ACCESS           = getNLS("Accesses.Access");
        _I18_FILTER           = getNLS("Accesses.Filter");
        try {
		//get input parameters
		String personName = request.getParameter("treeRoot");
		String selectedPolicyStates = request.getParameter("statePattern");
		String accessPattern = request.getParameter("accessPattern");

		//get array of selected policy states
        dbg("Selected Policy States = ["+selectedPolicyStates+"]");
		String policyStateArray[] = selectedPolicyStates.split(",");
        if (dbgActive()) {
            for (int ip=0; ip<policyStateArray.length; ip++) {
                dbg("=== "+ip+" = "+policyStateArray[ip]);
            }
        }
		//get array of selected accesses
		String accessArray[] = accessPattern.split(",");
		
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
		//hash map to contain distinct role names as keys and result hashmaps (which in turn contains policy+state as keys and access results as values) as values
		HashMap uniqueRoleResultsMap = new HashMap();

		String roleName = "";
		HashMap resultMap = null;
		//step through each context
		for(int j = 0; j < contextArray.length; j++)
		{
			roleName = contextArray[j];
			//if not created already then create entry in map
			if(!uniqueRoleResultsMap.containsKey(roleName))
			{
				uniqueRoleResultsMap.put(roleName, new LinkedHashMap());
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
					uniqueRoleResultsMap.put(roleName, new LinkedHashMap());
				}
				//else don't go for inner loop and continue
				else
					continue;
					
				//get parent roles
				String parentRoleResult = getParentRoles(context, roleName, uniqueParentsMap);
				String[] parentRoleArray = parentRoleResult.split(",");
				
				//step through each parent role of an individual role
				for(int m = 0; m < parentRoleArray.length && !parentRoleArray[m].equals(""); m++)
				{
					roleName = parentRoleArray[m];
					//if not created already then create entry in map
					if(!uniqueRoleResultsMap.containsKey(roleName))
					{
						uniqueRoleResultsMap.put(roleName, new LinkedHashMap());
					}
					//else don't go for inner loop and continue
					else
						continue;
					
					//get parent roles
					String m1RoleResult = getParentRoles(context, roleName, uniqueParentsMap);
					String[] m1RoleArray = m1RoleResult.split(",");
						
					//step through each parent's parent role ie M1 std role
					for(int n = 0; n < m1RoleArray.length && !m1RoleArray[n].equals(""); n++)
					{
						roleName = m1RoleArray[n];
						//if not created already then create entry in map
						if(!uniqueRoleResultsMap.containsKey(roleName))
						{
							uniqueRoleResultsMap.put(roleName, new LinkedHashMap());
						}
					}
				}
			}
		}

		//create entry for Person access
		uniqueRoleResultsMap.put("Person", new LinkedHashMap());
		//create entry for Public access
		uniqueRoleResultsMap.put("Public", new LinkedHashMap());
		
		//getting results
		String policyAccessResults = "";
		String policyFilterResults = "";
		String policyName = "";
		String stateName = "";
		String prevPolicyName = "";
		//string to contain access query
		String accessQuery = "";
		//string to contain filter query
		String filterQuery = "";
		//string to contain access query result
		String accessResult = "";
		//string to contain filter query result
		String filterResult = "";
		//step through each policy state
        dbg("Querying Policy / States:");
	final String [] t = new String[0];
	java.util.List<String> args1 = new java.util.ArrayList<String>(), args2 = new java.util.ArrayList<String>();
		for(int i = 0; i < policyStateArray.length; i++)
		{
			//if policyState is empty then skip further processing and continue
			if(policyStateArray[i].equals(""))
				continue;
			//get current policy and state name
			String[] PSArray = policyStateArray[i].split(":");
			policyName = PSArray[0];
			stateName = PSArray[1];
            dbg("=== policy/state: "+policyName+" / "+stateName);
			//if policy is new
			if(!policyName.equals(prevPolicyName))
			{
				//execute old policy query
				if(!accessQuery.equals("") && !filterQuery.equals(""))
				{
					//get results
					try{
					    accessResult = MqlUtil.mqlCommand(context,accessQuery,args1.toArray(t));
					    filterResult = MqlUtil.mqlCommand(context,filterQuery,args2.toArray(t));
                        if (_trace.isTracing(2)) {
                            dbg("===  | Accesses:\n["+accessResult+"]");
                            dbg("===  | Filters:\n["+filterResult+"]");
                        }
						policyAccessResults += accessResult + "\n";
						policyFilterResults += filterResult + "\n";
					}
					catch (Exception ex) {
						System.out.println("Exception: "+ex);
					}
				}
				//start new access query
				accessQuery = "print policy $1 select $2 $3 ";
				//start new filter query
				filterQuery = "print policy $1 select $2 ";

				args1 = new ArrayList<String>();
				args1.add(policyName);
				args1.add("state[" + stateName + "].publicaccess");
				args1.add("state[" + stateName + "].access ");

				args2 = new ArrayList<String>();
				args2.add(policyName);
				args2.add("state[" + stateName + "].filter");
			}
			//if policy name is same as previous
			else
			{
			    accessQuery += " $4 $5";
			    args1.add("state[" + stateName + "].publicaccess");
			    args1.add("state[" + stateName + "].access");

			    filterQuery += " $4";
			    args2.add("state[" + stateName + "].filter");
			}
			//if it is last
			if(i == policyStateArray.length - 1)
			{
				//execute last policy query
				if(!accessQuery.equals("") && !filterQuery.equals(""))
				{
					//get results
					try{
						accessResult = MqlUtil.mqlCommand(context,accessQuery,args1.toArray(t));
						policyAccessResults += accessResult;
						filterResult = MqlUtil.mqlCommand(context,filterQuery,args2.toArray(t));
						policyFilterResults += filterResult;
                        if (_trace.isTracing(2)) {
                            dbg("===  | Accesses:\n["+accessResult+"]");
                            dbg("===  | Filters:\n["+filterResult+"]");
                        }
					}
					catch (Exception ex) {
						System.out.println("Exception: "+ex);
					}
				}
			}

			//update previous policy name
			prevPolicyName = policyName;
		}

		//parse policy query results and update role results 
		String resultLine = "";
		String result = "";
		String[] policyAccessResultsArr = policyAccessResults.split("\n");
		//step through each access result
		for(int i = 0; i < policyAccessResultsArr.length; i++)
		{
			//read result line
			resultLine = policyAccessResultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//get policy name and continue for its results
			if(resultLine.contains("policy "))
			{
				policyName = (resultLine.substring(resultLine.indexOf("policy ") + 7, resultLine.length())).trim();
				continue;
			}
			//get state name
            else if(resultLine.contains("state["))
			{
				stateName = resultLine.substring(resultLine.indexOf("state[") + 6, resultLine.indexOf("]."));
				//get public access result
				if(resultLine.contains("publicaccess"))
				{
					roleName = "Public";
					result = (resultLine.substring(resultLine.indexOf(" = ") + 3, resultLine.length())).trim();
					//filter accesses
					result = filterAccesses(result, accessArray);
					//update role results
					resultMap = (LinkedHashMap)uniqueRoleResultsMap.get(roleName);
					//if result is not in map, then put it in map
					if(resultMap != null && !resultMap.containsKey(policyName + ":" + stateName))
					{
						//update result map with results
						if(result != null && !result.equals("") && !result.contains("NOT_REQUIRED"))
							resultMap.put(policyName + ":" + stateName, result);
					}
				}
				//else get role name and access result
				else if(resultLine.contains("access["))
				{
					roleName = resultLine.substring(resultLine.indexOf("access[") + 7, resultLine.indexOf("] ="));
					if(roleName.equals(personName))
						roleName = "Person";
					result = (resultLine.substring(resultLine.indexOf(" = ") + 3, resultLine.length())).trim();
					//filter accesses
					result = filterAccesses(result, accessArray);
					//update role results
					resultMap = (LinkedHashMap)uniqueRoleResultsMap.get(roleName);
					//if result is not in map, then put it in map
					if(resultMap != null && !resultMap.containsKey(policyName + ":" + stateName))
					{
						//update result map with results
						if(result != null && !result.equals(""))
							resultMap.put(policyName + ":" + stateName, result + "\n ");
					}
				}
			}
		}
		String[] policyFilterResultsArr = policyFilterResults.split("\n");
		//step through each filter result
		for(int i = 0; i < policyFilterResultsArr.length; i++)
		{
			//read result line
			resultLine = policyFilterResultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//get policy name and continue for its results
			if(resultLine.contains("policy "))
			{
				policyName = (resultLine.substring(resultLine.indexOf("policy ") + 7, resultLine.length())).trim();
				continue;
			}
			//get state name
            else if(resultLine.contains("state["))
			{
				stateName = resultLine.substring(resultLine.indexOf("state[") + 6, resultLine.indexOf("]."));
				// get role name and access result
				if(resultLine.contains("filter["))
				{
					roleName = resultLine.substring(resultLine.indexOf("filter[") + 7, resultLine.indexOf("] ="));
					if(roleName.equals(personName))
						roleName = "Person";
					result = (resultLine.substring(resultLine.indexOf(" = ") + 3, resultLine.length())).trim();
					//check for further filter result for same role name and rule name (as result may contain new lines)
					while(++i < policyFilterResultsArr.length && policyFilterResultsArr[i] != null)
					{
						//read result line
						resultLine = policyFilterResultsArr[i];
						//if it's a new rule or filter then update index and break
						if(resultLine.contains("policy") || resultLine.contains("state") || resultLine.contains("filter["))
						{
							i--;
							break;
						}
						//append result with space
						result += " " + resultLine.trim();
					}
					//update role results
					resultMap = (LinkedHashMap)uniqueRoleResultsMap.get(roleName);
					//if result is not in map, then put it in map
					if(resultMap != null && !resultMap.containsKey(policyName + ":" + stateName))
					{
						//update result map with results
						if(result != null && !result.equals(""))
							resultMap.put(policyName + ":" + stateName, " \n" + result);
					}
					else if(resultMap != null)
					{
						accessResult = (String)resultMap.get(policyName + ":" + stateName);
						//update result map with results
						if(result != null)
						{
							//if it is required then update else remove whole entry
							if(!accessResult.contains("NOT_REQUIRED"))
								resultMap.put(policyName + ":" + stateName, accessResult + result);
							else
								resultMap.remove(policyName + ":" + stateName);
						}
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
		resultMap = (HashMap)uniqueRoleResultsMap.get("Person");
		if(resultMap.size() > 0)
		{
			//write all table rows with access results
			writeAllResults(out, resultMap, currentLevel, color);
		}
		%>
		</div>
		&nbsp;
		<div id="contextBarDiv" class="barDivInReport" >
		<%
			//reset current level
			currentLevel = 0;
			//add bar cell based on access
            dbg("addContextBarTD");
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
            dbg("| role["+j+"] = "+roleName);
			//add bar cell based on access
			divIdUniquePart = "" + j;
			addBarTD(out, "ctxBarTDInReport", roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
			%>
			<div id="<%=roleName + divIdUniquePart%>Div" style="display:none">
			<%
			//check access
			resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
			if(resultMap.size() > 0)
			{
				//write all table rows with access results
				writeAllResults(out, resultMap, currentLevel, color);
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
				resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
				if(resultMap.size() > 0)
				{
					//write all table rows with access results
					writeAllResults(out, resultMap, currentLevel, color);
				}
				//update current level
				currentLevel++;
				//get parent roles
				String parentRoleResult = getParentRoles(context, roleName, uniqueParentsMap);
				String[] parentRoleArray = parentRoleResult.split(",");
				//step through each root role's parent role
				for(int m = 0; m < parentRoleArray.length && !parentRoleArray[m].equals(""); m++)
				{
					roleName = parentRoleArray[m];
					//add bar cell based on access
					divIdUniquePart = ""+j+k+m;
					addBarIfRequired(out, "ctxBarTDInReport", roleName, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
					%>
					<div id="<%=roleName + divIdUniquePart%>Div" style="display:none">
					<%
					//check access
					resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
					if(resultMap.size() > 0)
					{
						//write all table rows with access results
						writeAllResults(out, resultMap, currentLevel, color);
					}
					//update current level
					currentLevel++;
					//get parent's parents ie M1 std roles
					String m1RoleResult = getParentRoles(context, roleName, uniqueParentsMap);
					String[] m1RoleArray = m1RoleResult.split(",");
					//step through each parent's parent role i.e. M1 standard role
					for(int n = 0; n < m1RoleArray.length && !m1RoleArray[n].equals(""); n++)
					{
						roleName = m1RoleArray[n];
						//add bar cell based on access
						divIdUniquePart = ""+j+k+m+n;
						addBarIfRequired(out, "stateAccessBarTDInReport", roleName, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
						%>
						<div id="<%=roleName + divIdUniquePart%>Div" style="display:none">
						<%
						//check access
						resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
						if(resultMap.size() > 0)
						{
							//write all table rows with access results
							writeAllResults(out, resultMap, currentLevel, color);
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
				//update current level
				currentLevel--;
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
		resultMap = (HashMap)uniqueRoleResultsMap.get("Public");
		if(resultMap.size() > 0)
		{
			//write all table rows with access results
			writeAllResults(out, resultMap, currentLevel, color);
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
