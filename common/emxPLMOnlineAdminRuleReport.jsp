
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
    public String     _I18_ACCESS = "Access";
    public String     _I18_FILTER = "Filter";
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
                    else {
                        accessResult = PLMUtil.replaceAll(accessResult, ",", ", ");
                    }
					out.print("><b>"+_I18_ACCESS+":</b>&nbsp;" + accessResult + "<br><b>"+_I18_FILTER+":</b>&nbsp;&nbsp;" + resultArr[1]);
				}
				else
				{
					if(resultStr.equals("none"))
					{
						resultStr = "<strike><font color='red'>none</font></strike>";
					}
                    else {
                        resultStr = PLMUtil.replaceAll(resultStr, ",", ", ");
                    }
					out.print("><b>"+_I18_ACCESS+":</b>&nbsp;" + resultStr);
				}
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
        initTrace("AdminRuleReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_accesses   = getNLS("Accesses");
        String i18_properties = getNLS("Properties");
        _I18_ACCESS           = getNLS("Accesses.Access");
        _I18_FILTER           = getNLS("Accesses.Filter");
		//get input parameters
		String sCharSet = Framework.getCharacterEncoding(request);
		String ruleName = emxGetParameter(request, "ruleName");
		ruleName = FrameworkUtil.decodeURL(ruleName, sCharSet);
		//out.println("ruleName: " + ruleName);
		//new parameter added to avoid same names in DIV ids in case of being called from Relationship Report
		String levelID = request.getParameter("levelID");
		String baseDivId = ruleName;
		if(levelID != null)
			baseDivId += levelID;

		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print rule $1",ruleName);
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
			else if(resultLine.startsWith("Relationship Type:"))
			{
				//get Relationship result
				String relResult = resultLine.substring(resultLine.indexOf(": ") + 2, resultLine.length());
				propsMap.put("RelationshipType", "PROP_VALUE:" + relResult);
			}
			else if(resultLine.startsWith("public"))
			{
				//get public result
				String publicResult = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				accessesMap.put("public", publicResult);
			}
			else if(resultLine.startsWith("owner"))
			{
				//get owner result
				String ownerResult = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
				accessesMap.put("owner", ownerResult);
			}
			else if(resultLine.startsWith("user"))
			{
				//get user name
				String userName = resultLine.substring(resultLine.indexOf(" ") + 1,resultLine.lastIndexOf(" ") );
				//get access result
				String accessResult = resultLine.substring(resultLine.lastIndexOf(" ") + 1, resultLine.length());
				//get filter result
				String filterResult  = " ";
				String newResultLine = "";
				if((i+1) < resultsArr.length && resultsArr[i+1] != null && !resultsArr[i+1].equals(""))
				{
					//get next result line
					newResultLine = resultsArr[i+1].trim();
					//check filter access
					if(newResultLine.startsWith("filter "))
					{
						//update index as filter line has found
						i++;
						filterResult  = newResultLine.substring(newResultLine.indexOf(" ") + 1, newResultLine.length());
						//out.println(filterResult);
						//check for further filter result (as filter result may contain new lines)
						while((++i) < resultsArr.length && resultsArr[i] != null)
						{
							//read result line
							newResultLine = resultsArr[i].trim();
							//if it's a new user or empty line then update index and break
							if(newResultLine.startsWith("user") || newResultLine.startsWith("nothidden") || newResultLine.startsWith("created") ||  newResultLine.equals(""))
							{
								i--;
								break;
							}
							//append result with space
							filterResult += " " + newResultLine.trim();
						}
					}
				}
				//update map
				accessesMap.put(userName, accessResult + "\n" + filterResult);
			}
		}
		//generate report
		//string to specify table row color
		String color = "CCFFFFF";
		HashMap resultMap = null;
		//variable to specify current table row level in report
		int currentLevel = 0;
		%>
		<div class="barDivInReport" >
		<%
			addBar(out, "barTDInReport", ruleName, baseDivId + "mainDiv", currentLevel);
		%>
		</div>
		<div  id='<%=baseDivId + "mainDiv"%>'  style="display:none">
		<%
		//update current level
		currentLevel++;
		%>
			<div id='<%=baseDivId + "propertiesDiv"%>' >
			<%
			addBar(out, "ctxBarTDInReport", i18_properties, baseDivId + "propertiesResultDiv", currentLevel);
			%>
			</div>
			<div id='<%=baseDivId + "propertiesResultDiv"%>' style="display:none">
			<%
				resultMap = propsMap;
				//write all table rows with access results
				writeAllResults(out, resultMap, currentLevel, color, "Properties", getNLSCatalog());
			%>
			</div>
			
			<div id='<%=baseDivId + "AccessesDiv"%>' >
			<%
			addBar(out, "ctxBarTDInReport", i18_accesses, baseDivId + "accessesResultDiv", currentLevel);
			%>
			</div>
			<div id='<%=baseDivId + "accessesResultDiv"%>' style="display:none">
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
