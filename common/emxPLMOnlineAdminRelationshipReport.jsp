
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
		out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + divId + "', this);\"/>&nbsp;&nbsp;<b>" + barName + "</td>");
				
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
	//method to get rules list
    //----------------------------------------------------------------------
	public ArrayList getRulesList(String relationshipName, Context context)
	{
		ArrayList relationList = new ArrayList();
		relationList.add(relationshipName);
		//get all rules from relations
		ArrayList ruleList = new ArrayList(); 
		HashMap polMap = new HashMap();
		polMap.put("relationList",relationList);
		try{
			String []args = JPO.packArgs(polMap);
			ruleList = (ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getRulesFromRelations", args, ArrayList.class);
		}
		catch(Exception e)
		{
			System.out.println("Exception has come: "+ e);
		}
		return ruleList;
	}

    //----------------------------------------------------------------------
    // Main body
    //----------------------------------------------------------------------
	%>
	<body>
	<%
        initTrace("AdminRelationReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_properties = getNLS("Properties");
        String i18_from       = getNLS("Properties.From");
        String i18_to         = getNLS("Properties.To");
        String i18_rules      = getNLS("Rules");
		//get input parameters
		String sCharSet = Framework.getCharacterEncoding(request);
		String relationshipName = emxGetParameter(request, "relationshipName");
		relationshipName = FrameworkUtil.decodeURL(relationshipName, sCharSet);
		//out.println("relationshipName: " + relationshipName);

		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print relationship $1",relationshipName);
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		//out.println("queryResult: " + queryResult);

		//parse query result
		HashMap propsMap = new LinkedHashMap();
		HashMap fromMap = new LinkedHashMap();
		HashMap toMap = new LinkedHashMap();
		ArrayList rulesList = new ArrayList();
		
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
			else if(resultLine.startsWith("application"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				propsMap.put("Application", result);
			}
			else if(resultLine.startsWith("access"))
			{
				//get result
				String result = "";
				if(resultLine.contains(" "))
					result = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				propsMap.put("Access", result);
			}
			else if(resultLine.startsWith("from"))
			{
				//get "from" result
				String newResultLine = "";
				//check for further result
				while((++i) < resultsArr.length && resultsArr[i] != null)
				{
					//read result line
					newResultLine = resultsArr[i].trim();
					//if it's a new user or empty line then update index and break
					if(newResultLine.startsWith("to") || newResultLine.startsWith("application") || newResultLine.startsWith("created") ||  newResultLine.equals(""))
					{
						i--;
						break;
					}
					String name = "";
					if(newResultLine.contains(" "))
						name = newResultLine.substring(0, newResultLine.lastIndexOf(" ") );
					else if(newResultLine.contains("meaning"))
						name = "meaning";
					//make it in proper case
					name = name.substring(0, 1).toUpperCase() + name.substring(1, name.length());
			        name = PLMUtil.replaceAll(name, " ", "_");

					String result = "";
					if(newResultLine.contains(" "))
						result = newResultLine.substring(newResultLine.lastIndexOf(" ") + 1, newResultLine.length());
                    // convert types, relationships ...
                    if (name.startsWith("Type")) {
                        result = PLMUtil.replaceAll(result, "VPLMtyp/", "");
                    }
                    else if (name.startsWith("Relationship")) {
                        result = PLMUtil.replaceAll(result, "VPLMrel/", "");
                    }
					//update map
					fromMap.put(name, result);
				}
			
			}
			else if(resultLine.startsWith("to"))
			{
				//get "to" result
				String newResultLine = "";
				//check for further result
				while((++i) < resultsArr.length && resultsArr[i] != null)
				{
					//read result line
					newResultLine = resultsArr[i].trim();
					//if it's a new user or empty line then update index and break
					if(newResultLine.startsWith("application") || newResultLine.startsWith("created") ||  newResultLine.equals(""))
					{
						i--;
						break;
					}
					String name = "";
					if(newResultLine.contains(" "))
						name = newResultLine.substring(0, newResultLine.lastIndexOf(" ") );
					else if(newResultLine.contains("meaning"))
						name = "meaning";
					//make it in proper case
					name = name.substring(0, 1).toUpperCase() + name.substring(1, name.length());
			        name = PLMUtil.replaceAll(name, " ", "_");

					String result = "";
					if(newResultLine.contains(" "))
						result = newResultLine.substring(newResultLine.lastIndexOf(" ") + 1, newResultLine.length());
                    // convert types, relationships ...
                    if (name.startsWith("Type")) {
                        result = PLMUtil.replaceAll(result, "VPLMtyp/", "");
                    }
                    else if (name.startsWith("Relationship")) {
                        result = PLMUtil.replaceAll(result, "VPLMrel/", "");
                    }
					//update map
					toMap.put(name, result);
				}
			
			}

		}
		//get rulesList
		rulesList = getRulesList(relationshipName, context);

		//generate report
		//string to specify table row color
		String color = "CCFFFFF";
		HashMap resultMap = null;
		//variable to specify current table row level in report
		int currentLevel = 0;
		%>
		<div class="barDivInReport" >
		<%
            String sType = PLMUtil.replaceAll(relationshipName, "VPLMrel/", "");
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
				//update current level
				currentLevel++;
			%>
			
			<div id="fromDiv" >
			<%
			addBar(out, "stateAccessBarTDInReport", i18_from, "fromResultDiv", currentLevel);
			%>
			</div>
			<div id="fromResultDiv" style="display:none">
			<%
			//get map for current state's access
			resultMap = fromMap;
			//write all table rows with results
			writeAllResults(out, resultMap, currentLevel, color, "Properties.Type", getNLSCatalog());
			%>
			</div>
			<div id="toDiv" >
			<%
			addBar(out, "stateAccessBarTDInReport", i18_to, "toResultDiv", currentLevel);
			%>
			</div>
			<div id="toResultDiv" style="display:none">
			<%
			//get map for current state's access
			resultMap = toMap;
			//write all table rows with results
			writeAllResults(out, resultMap, currentLevel, color, "Properties.Type", getNLSCatalog());
			//update current level
			currentLevel--;
			%>
			</div>

			</div>

			<div id="rulesDiv" >
			<%
			addBar(out, "ctxBarTDInReport", i18_rules, "rulesResultDiv", currentLevel);
			%>
			</div>
			<div id="rulesResultDiv" style="display:none">
			<%
			//update current level
			currentLevel++;
			//step through each rule
			for(int i = 0; i < rulesList.size(); i++)
			{
				//get rule name
				String ruleName = (String)rulesList.get(i);
			%>
					<div id="ruleDiv" style=" position: relative ; <%= "margin-right: " + currentLevel + "px; width:" + (100 - currentLevel * 3) + "% ; left:" + (currentLevel * 3 - 0.3) + "%; " %> ">
					<jsp:include page="emxPLMOnlineAdminRuleReport.jsp">	
						<jsp:param name="ruleName" value="<%= ruleName%>" />	
						<jsp:param name="levelID" value="<%= currentLevel%>" />	
					</jsp:include>
					</div>
			<%
			}
			%>
			</div>
			
	</div>
	</body>

</html>
