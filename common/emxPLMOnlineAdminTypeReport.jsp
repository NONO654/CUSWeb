
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmposadminservices.NLSCatalog" %>
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
    //----------------------------------------------------------------------
	//method to add bar in report
    //----------------------------------------------------------------------
	public void addBar(JspWriter out, String tdClass, String barName, String divId, int level) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		
		//start table
		out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
		//start row
		out.print("<tr>");
		
		if(initialWidth != 0)
			out.print("<td width='" + initialWidth + "%'></td>");

		//write cell without access image
		if(!divId.equals(""))
			out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + divId + "', this);\"/>&nbsp;&nbsp;<b>" + barName + "</td>");
		else
			out.print("<td class='" + tdClass + "'>&nbsp;&nbsp;<b>" + barName + "</td>");
				
		//end row and table
		out.print("</tr></table>");
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
	//method to write table rows at current level with report node data
    //----------------------------------------------------------------------
	public void writeAllResults(JspWriter out, HashMap resultMap, int level, String color, String tag_category, NLSCatalog catalog) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3 + 3;

		//start table
		out.print("<table border='0' cellpadding='5' cellspacing='0' width='100%'>");
		//write results in table rows
		//get key iterator
		Iterator keyItr = resultMap.keySet().iterator();
		//step through each result
		while(keyItr.hasNext())
		{
			//get key
			String key = (String)keyItr.next();
            String i18n_key = getNLSOrDefault(tag_category+"."+key,key);
			//get result
			String resultStr = (String)resultMap.get(key);
			//flag to check if it is last result
			boolean isLast = !(keyItr.hasNext());
			//change color
			color = changeRowColor(color);
			
			//start row
			out.print("<tr>");
			//add cell for empty space i.e. for indentation
			out.print("<td width='" + initialWidth + "%'></td>");
			//write name cell
			out.print("<td width='16%' bgcolor='" + color + "' class='policyCellInReport'");
			//manage borders
			out.print(" style=\"border-top:solid #6196ff 1px;\"");
			if(!keyItr.hasNext())
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
			out.print(">" + i18n_key + "</td>");
			
			//write result cell
			out.print("<td bgcolor='" + color + "' class='cellInReport'");
			//manage border
			if(isLast)
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");

			//make result to be able to fit in current table row
			String result = PLMUtil.replaceAll(resultStr, ",", ", ");
			out.print(">&nbsp;" + result);
			
			//end result cell
			out.print("</td>");			
			//close row
			out.print("</tr>");
		}
		//end table
		out.print("</table>");
	}
    //----------------------------------------------------------------------
	//method to update PolicyTypesMap
    //----------------------------------------------------------------------
	public void updatePolicyTypesMap(Context context, ArrayList policyList, HashMap typePoliciesMap)
	{
		for(int i = 0; i < policyList.size(); i++)
		{
			String policyName = (String)policyList.get(i);
			if(policyName.equals(""))
				continue;

			//get results
			String queryResult = "";
			try{
				queryResult = MqlUtil.mqlCommand(context,"print policy $1 select type dump",policyName);
			}
			catch (Exception ex) {
				System.out.println("Exception: "+ex);
			}
			if(queryResult != null && !queryResult.equals(""))
			{
				String[] resultArr = queryResult.split(",");
				//check for all types
				for(int j = 0; j < resultArr.length; j++)
				{
					String typeName = resultArr[j];
					//update map
					if(!typeName.equals(""))
					{
						//if key is not already then update map
						if(!typePoliciesMap.containsKey(typeName))
						{
							typePoliciesMap.put(typeName, policyName);
						}
						//else update values with same key
						else
						{
							String policyNames = (String)typePoliciesMap.get(typeName);
							//update string of policy names
							if(!policyNames.equals(policyName))
							{
								policyNames += "," + policyName;
								//update map
								typePoliciesMap.put(typeName, policyNames);
							}
						}
					}
				}
			}
		}
	}
    //----------------------------------------------------------------------
	//method to parent type name from a type
    //----------------------------------------------------------------------
	public String getParentType(Context context, String typeName)
	{
		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print type $1 select derived dump",typeName);
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		return queryResult;
	}
    //----------------------------------------------------------------------
	//method to update accesses map
    //----------------------------------------------------------------------
	public void updateAccessesMap(HashMap accessesMap, String currentTypeName, Context context)
	{
		//get all Policies 
		ArrayList policyList = new ArrayList(); 
		try{
			policyList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getPolicyNames", null, ArrayList.class);
		}
		catch(Exception e)
		{
			System.out.println("Exception has come: "+ e);
		}
		//map to contain governed type as key and  policies as values
		HashMap typePoliciesMap = new HashMap();
		//update policyTypesMap
		updatePolicyTypesMap(context, policyList, typePoliciesMap);

		Stack accessesStack = new Stack();
		
		String typeName = "", policyNames = "";
		//get current type and policy name
		typeName = currentTypeName;
		policyNames = (String)typePoliciesMap.get(typeName);
		//push in stack
		if(policyNames != null)
			accessesStack.push(typeName + ":" + policyNames);
		//else push empty policy name
		else
			accessesStack.push(typeName + ":" + "");
		//get parent types and their policies
		while(true)
		{
			//get parent type
			typeName =  getParentType(context, typeName);
			//if type name is null or empty then break
			if(typeName == null || typeName.equals(""))
				break;
			//get policy names
			policyNames = (String)typePoliciesMap.get(typeName);
			//push in stack if it is not null
			if(policyNames != null)
				accessesStack.push(typeName + ":" + policyNames);
			//else push empty policy name
			else
				accessesStack.push(typeName + ":" + "");
		}
		//update map with the help of stack
		while(!accessesStack.empty())
		{
			String strAccess = (String)accessesStack.pop();
			String[] arrAccess = strAccess.split(":");
			//put in map
			if(arrAccess.length == 2)
				accessesMap.put(arrAccess[0], arrAccess[1]);
			else
				accessesMap.put(arrAccess[0], "");
		}
	}

    //----------------------------------------------------------------------
    // Main body
    //----------------------------------------------------------------------
	%>
	<body>
	<%
        initTrace("AdminTypeReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_accesses   = getNLS("Accesses");
        String i18_properties = getNLS("Properties");
		//get input parameters
		String sCharSet = Framework.getCharacterEncoding(request);
		String typeName = emxGetParameter(request, "typeName");
		typeName = FrameworkUtil.decodeURL(typeName, sCharSet);
		//out.println("typeName: " + typeName);

		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print type $1" ,typeName);
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		//out.println("queryResult: " + queryResult);

		//parse query result
		HashMap propsMap = new LinkedHashMap();
		HashMap accessesMap = new LinkedHashMap();

		//parse query results
		String resultLine = "";
		String[] resultsArr = queryResult.split("\n");
		//out.println("queryResult: " + queryResult + "<br>");
		//step through each access result
		for(int i = 0; i < resultsArr.length; i++)
		{
			//read result line
			resultLine = resultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//out.println("resultLine: " + resultLine + "<br>");
			resultLine = resultLine.trim();
			
			if(resultLine.startsWith("description"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				propsMap.put("Description", result);
			}
			else if(resultLine.startsWith("derived"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
                result = PLMUtil.replaceAll(result, "VPLMtyp/", "");
				propsMap.put("DerivedFrom", result);
			}
			if(resultLine.startsWith("abstract"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				propsMap.put("AbstractType", result);
			}
			if(resultLine.startsWith("attribute"))
			{
				//get result
				String result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
                result = PLMUtil.replaceAll(result, "VPLMatt/", "");
				propsMap.put("Attribute", result);
			}
			if(resultLine.startsWith("inherited attribute"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.lastIndexOf(" ") + 1, resultLine.length());
                result = PLMUtil.replaceAll(result, "VPLMatt/", "");
				propsMap.put("InheritedAttribute", result);
			}
			if(resultLine.startsWith("policy"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.lastIndexOf(" ") + 1, resultLine.length());
				propsMap.put("Policy", result);
			}
			if(resultLine.startsWith("application"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.lastIndexOf(" ") + 1, resultLine.length());
				propsMap.put("Application", result);
			}
			if(resultLine.startsWith("access"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.lastIndexOf(" ") + 1, resultLine.length());
				propsMap.put("Access", result);
			}
		}
		//update accesses map
		updateAccessesMap(accessesMap, typeName, context);

		//generate report
		//string to specify table row color
		String color = "CCFFFFF";
		HashMap resultMap = null;
		//variable to specify current table row level in report
		int currentLevel = 0;
		%>
		<div class="barDivInReport" >
		<%
            String sType = PLMUtil.replaceAll(typeName, "VPLMtyp/", "");
			addBar(out, "barTDInReport", sType, "mainDiv", currentLevel);
		%>
		</div>
		<div  id="mainDiv"  style="display:none">
		<%
		//update current level
		currentLevel++;
		%>
			<div id="propertiesDiv" >
			<%
			addBar(out, "ctxBarTDInReport", i18_properties, "propertiesResultDiv", currentLevel);
			%>
			</div>
			<div id="propertiesResultDiv" style="display:none">
			<%
				resultMap = propsMap;
				//write all table rows with access results
				writeAllResults(out, resultMap, currentLevel, color, "Properties", getNLSCatalog());
			%>
			</div>

			<div id="accessesDiv" >
			<%
			addBar(out, "ctxBarTDInReport", i18_accesses, "accessesResultDiv", currentLevel);
			%>
			</div>
			<div id="accessesResultDiv" style="display:none">
			<%
			//out.print(accessesMap+ "<br>");
			//update current level
			currentLevel++;
			//get key iterator
			Iterator keyItr = accessesMap.keySet().iterator();
			//step through each result
			while(keyItr.hasNext())
			{
				//get type name
				typeName = (String)keyItr.next();
			%>
				<div id="typeDiv" >
				<%
                String sTreeType = PLMUtil.replaceAll(typeName, "VPLMtyp/", "");
				addBar(out, "stateAccessBarTDInReport", sTreeType, "", currentLevel);
				%>
				</div>
			<%
				//get policy names
				String policyNames = (String)accessesMap.get(typeName);
				//get array of policy names
				String[] policyNamesArr = policyNames.split(",");
				//get each policy name
				for(int i = 0; i < policyNamesArr.length; i++)
				{
					String policyName = policyNamesArr[i];
					if(!policyName.equals(""))
					{
				%>
					<div id="policyDiv" style=" position: relative ; <%= "margin-right: " + currentLevel + "px; width:" + (100 - (currentLevel + 1) * 3) + "% ; left:" + ((currentLevel + 1) * 3 - 0.3) + "%; " %> ">
					<jsp:include page="emxPLMOnlineAdminPolicyReport.jsp">	
						<jsp:param name="policyName" value="<%= policyName%>" />	
						<jsp:param name="levelID" value="<%= currentLevel%>" />	
						<jsp:param name="alignment" value="right" />	
					</jsp:include>
					</div>
				<%
					}
				}
				//update current level
				currentLevel++;
			}
			%>
			</div>
							
	</div>
	</body>

</html>
