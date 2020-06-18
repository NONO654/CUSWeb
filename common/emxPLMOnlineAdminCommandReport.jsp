
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
			out.print("<td width='65%' bgcolor='" + color + "' class='cellInReport'");
			//manage border
			if(isLast)
				out.print(" style=\"border-bottom:solid #6196ff 1px;\"");
			//check if it is the value of Property
			if(resultStr.startsWith("PROP_VALUE:"))
			{
				//make result to be able to fit in current table row
				String result = resultStr.substring(resultStr.indexOf(":") + 1, resultStr.length());
				out.print(">&nbsp;" + result);
			}
			//else
			else
			{
				//manage border
				out.print(" style=\"border-left:;\">&nbsp;");
			}
			//end result cell
			out.print("</td>");			
			//close row
			out.print("</tr>");
		}
		//end table
		out.print("</table>");
	}

    //----------------------------------------------------------------------
    // Main body
    //----------------------------------------------------------------------
	%>
	<body>
	<%
        initTrace("AdminCommandReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_accesses   = getNLS("Accesses");
        String i18_properties = getNLS("Properties");
		//get input parameters
		String sCharSet = Framework.getCharacterEncoding(request);
		String commandName = emxGetParameter(request, "commandName");
		commandName = FrameworkUtil.decodeURL(commandName, sCharSet);
		//out.println("commandName: " + commandName);
		//build query

		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print command $1", "vplm::" + commandName);
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
				//get description result
				String descResult = "";
				if(resultLine.contains(" "))
					descResult = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				propsMap.put("Description", "PROP_VALUE:" + descResult);
			}
			else if(resultLine.startsWith("user"))
			{
				//get user name
				String userName = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length() );
				
				//update map
				accessesMap.put(userName, "");
			}
		}
		//if accesses map is empty it means it has "All" access
		if(accessesMap.size() == 0)
			accessesMap.put("all", "");

		//generate report
		//string to specify table row color
		String color = "CCFFFFF";
		HashMap resultMap = null;
		//variable to specify current table row level in report
		int currentLevel = 0;
		%>
		<div class="barDivInReport" >
		<%
			addBar(out, "barTDInReport", commandName, "mainDiv", currentLevel);
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
			//get map for current state's access
			resultMap = accessesMap;
			//write all table rows with results
			writeAllResults(out, resultMap, currentLevel, color, "Accesses", null);
			%>
			</div>
					
	</div>
	</body>

</html>
