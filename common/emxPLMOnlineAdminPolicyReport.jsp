
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
	//method to add policy bar in type report
    //----------------------------------------------------------------------
	public void addBarInTypeReport(JspWriter out, String tdClass, String barName, String divId, int level, String alignment) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		int initialWidth = level * 3;
		
		//start table
		out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%' style='color:blue'>");
		//start row
		out.print("<tr>");
		
		if(initialWidth != 0)
			out.print("<td width='" + initialWidth + "%'></td>");

		//write cell without access image
		out.print("<td class='" + tdClass + "'><img src='../common/images/buttonPlus.gif'  onclick=\"switchMenu('" + divId + "', this);\"/></td><td class='" + tdClass + "' style='text-align:" + alignment + "'>&nbsp;&nbsp;<b>" + barName + "</td>");
				
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
	        dbg("=== ["+key +"] = "+resultStr);
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
			//--out.print("<td width='"+new Integer(84-initialWidth)+"%' bgcolor='" + color + "' class='cellInReport'");
			out.print("<td bgcolor='" + color + "' class='cellInReport'");
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
			//check if it is the result info of Branch
			else if(resultStr.startsWith("BRANCH_RESULT:"))
			{
				//get "To State" name
				String strTillState = resultStr.substring(resultStr.indexOf("To State:") + 9, resultStr.length());
				String onlyStateName = strTillState.substring(0, strTillState.indexOf("\n"));
				//remove "To State" name from results string
				resultStr = resultStr.replace("To State:" + onlyStateName, "");
                /*
				String result = resultStr.substring(resultStr.indexOf(":") + 1, resultStr.length()).replace("\n", "<br>");
				out.print("><b>" + onlyStateName + "</b><br>" + result);
                */
				out.print("><b>" + onlyStateName + "</b>");
                String[] lines = PLMUtil.split(resultStr.substring(resultStr.indexOf(":") + 1, resultStr.length()), "\n");
                for (int i=0; i<lines.length; i++) {
                    if (lines[i].length()<=0) continue;
                    // - process keyword ("xxx:")
                    int endKey = lines[i].indexOf(":");
                    if (endKey>=0) {
                        String subkey = lines[i].substring(0, endKey);
                        String value  = lines[i].substring(endKey+1,lines[i].length());
                        // - process value
                        out.print("<br>"+getNLS(tag_category+"."+subkey)+": "+value);
                    }
                    else {
                        out.print("<br>"+lines[i]);
                    }
                }
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
	//update Map With Governed Type
    //----------------------------------------------------------------------
	public void updateMapWithGovernedType(Context context, String policyName, HashMap propsMap)
	{
		//build query
		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print policy $1 select $2 dump",policyName,"type");
            queryResult = PLMUtil.replaceAll(queryResult, "VPLMtyp/", "");
            queryResult = PLMUtil.replaceAll(queryResult, ",", ", ");
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		//update map
		if(queryResult != null)
			propsMap.put("GovernedTypes", "PROP_VALUE:" + queryResult);
		else
			propsMap.put("GovernedTypes", "PROP_VALUE:" + "");
	}

    //----------------------------------------------------------------------
    // Main body
    //----------------------------------------------------------------------
	%>
	<body>
	<%
		String[] accesses = new String[]{
            "read", 
            "modify", 
            "delete", 
            "checkout", 
            "checkin", 
            "lock", 
            "unlock", 
            "grant", 
            "revoke", 
            "changeowner", 
            "create", 
            "promote",
            "demote", 
            "enable", 
            "disable", 
            "override", 
            "schedule", 
            "revise", 
            "changevault", 
            "changename", 
            "changepolicy", 
            "changetype", 
            "fromconnect", 
            "toconnect", 
            "fromdisconnect", 
            "todisconnect", 
            "freeze", 
            "thaw", 
            "execute", 
            "modifyform", 
            "viewform", 
            "show", 
            "majorrevise", 
            "all", 
            "none"
		};
		java.util.List accessList = java.util.Arrays.asList(accesses);
		
        initTrace("AdminPolicyReportUI");
        initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
        String i18_accesses   = getNLS("Accesses");
        String i18_branches   = getNLS("Branches");
        String i18_properties = getNLS("Properties");
        String i18_alsoknowas = getNLS("AlsoKnownAs");
        _I18_ACCESS           = getNLS("Accesses.Access");
        _I18_FILTER           = getNLS("Accesses.Filter");
		//get input parameters
		String sCharSet = Framework.getCharacterEncoding(request);
		String policyName = emxGetParameter(request, "policyName");
		policyName = FrameworkUtil.decodeURL(policyName, sCharSet);
		//new parameter added to avoid same names in DIV ids in case of being called from Type Report
		String levelID = request.getParameter("levelID");
		String baseDivId = policyName;
		if(levelID != null)
			baseDivId += levelID;
		//new parameter added to align text in policy bar in case of being called from Type Report
		String alignment = request.getParameter("alignment");
		//out.println("policyName: " + policyName);

		//get results
		String queryResult = "";
		try{
			queryResult = MqlUtil.mqlCommand(context,"print policy $1",policyName);
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
	    dbg("=== POLICY: " + policyName + "\n" + queryResult);

		//parse query result
		HashMap propsMap = new LinkedHashMap();
		HashMap statesMap = new LinkedHashMap();
		String stateName = "";
		String branchName = "";

		StringBuffer branchResult = new StringBuffer("");
		
		HashMap stateMap = null;
		HashMap accessMap = null;
		HashMap branchMap = null;

		//parse query results
		String resultLine = "";
		String[] resultsArr = queryResult.split("\n");
		//out.println("queryResult: " + queryResult + "<br>");
		//step through each access result
		boolean statePortion = false;
		boolean signaturePortion = false;
		for(int i = 0; i < resultsArr.length; i++)
		{
			//read result line
			resultLine = resultsArr[i];
			if(resultLine == null || resultLine.equals(""))
				continue;
			//out.println("resultLine: " + resultLine + "<br>");
			resultLine = resultLine.trim();
	        dbg("### line: " + resultLine);
			
			//state results have started coming
			if(resultLine.startsWith("state "))
				statePortion = true;
			//get states' results
			if(statePortion)
			{		
                /*
				//if new state or the end of results found
				if(resultLine.startsWith("state ") || (i + 1) == resultsArr.length)
				{
					//update branch map with previous info (if new branch info found)
					if(!branchName.equals(""))
					{
						//out.println("<br>Added state name: " + stateName + "::branch name: " + branchName);
						branchMap.put(branchName, branchResult.toString());
					}
				}
                */
				//check state
				if(resultLine.startsWith("state "))
				{
					//create new state map
					stateMap = new HashMap();
					//create new access map
					accessMap = new LinkedHashMap();
					//create new branch map
					branchMap = new LinkedHashMap();
					//add access and branch maps to state map
					stateMap.put("access", accessMap);
					stateMap.put("branch", branchMap);
					//reset signaturePortion
					signaturePortion = false;
					//get state name
					stateName = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
                    if (dbgActive()) {
    		            dbg("=============================================");
                		dbg("=== | STATE: " + stateName);
                		dbg("=============================================");
                    }
					//update states map
					statesMap.put(stateName, stateMap);
					//out.println("<br>state name: " + stateName);
					
				}
				else
				{
                    /*
					//get state map
					stateMap = (HashMap)statesMap.get(stateName);
					//get access map
					accessMap = (HashMap)stateMap.get("access");
					//get branch map
					branchMap = (HashMap)stateMap.get("branch");
                    */
					//check public access
					if(resultLine.startsWith("public "))
					{
						String publicResult = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
						//update state map
						accessMap.put("public", publicResult);
					}
					//check owner access
                    else if(resultLine.startsWith("owner "))
					{
						String ownerResult = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
						//update state map
						accessMap.put("owner", ownerResult);
					}
					//check user access
					else if(resultLine.startsWith("user ") || resultLine.startsWith("login "))
					{
						
						//out.println("for user: " + resultLine + "<br>");
						StringTokenizer tokenizer = new StringTokenizer(resultLine," ");
						//get user name
						String userName = "";
						//get access result
						String accessResult  = "";						
						//get filter result
						String filterResult  = " ";
						int state = 0;
						while(tokenizer.hasMoreTokens()) {
							String token = tokenizer.nextToken();
							switch(state) {
							case 0:
							if(!token.equals("user") && !token.equals("login")) {
								state = 1;
								userName = userName + token + " ";
							}
							break;
							case 1:
							if(token.contains(",") || accessList.contains(token)) {
								state = 2;
								accessResult = token;
							} else userName = userName + token + " ";
							break;
							case 2:
							filterResult = filterResult + token + " ";
							break;
							}
						}
						//update access map
						accessMap.put(userName, accessResult + "\n" + filterResult);
					}
					//check branch access
					else if(resultLine.startsWith("signature ") )
					{
						//out.println("<br>sign: " + resultLine);
						//update branch map with previous info (if new branch info found)
						// set signaturePortion to true
						signaturePortion = true;
						//get branch name
						branchName = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
						//reset branch result
						branchResult = new StringBuffer("BRANCH_RESULT:");
                        if (dbgActive()) {
                    		dbg("--------------------------------------------");
                    		dbg("=== | / BRANCH: "+branchName);
                    		dbg("--------------------------------------------");
                        }
						if(!branchName.equals(""))
						{
							//out.println("<br>Added state name: " + stateName + "::branch name: " + branchName);
							branchMap.put(branchName, branchResult.toString());
						}
						
					}
					//other 
                    else if (signaturePortion)
					{
						//check signature/approve access
						if(resultLine.startsWith("approve "))
						{
							branchResult.append("Approve: " + resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length()) + "\n");
		                dbg("=== | / BRANCH: "+branchName + " (+approve) = "+branchResult);
							branchMap.put(branchName, branchResult.toString());
						}
						//check signature/reject access
						else if(resultLine.startsWith("reject "))
						{
							branchResult.append("Reject: " + resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length()) + "\n");
							branchMap.put(branchName, branchResult.toString());
						}
						//check signature/ignore access
						else if(resultLine.startsWith("ignore "))
						{
							branchResult.append("Ignore: " + resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length()) + "\n");
							branchMap.put(branchName, branchResult.toString());
						}
						//check signature/branch 
						else if(resultLine.startsWith("branch "))
						{
							branchResult.append("To State: " + resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length()) + "\n");
		                dbg("=== | / BRANCH: "+branchName + " (+tostate) = "+branchResult);
							branchMap.put(branchName, branchResult.toString());
						}
						//check signature/filter access
						else if(resultLine.startsWith("filter "))
						{
							branchResult.append("Filter: " + resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length()) + "\n");
							branchMap.put(branchName, branchResult.toString());
						}
				    	else
    				    {
    	    				signaturePortion = false;
	    	    		}
					}
                    if (!signaturePortion) {
						if(resultLine.startsWith("property state_"))
						{
                            int idx1 = resultLine.indexOf(" value ");
                            if (idx1>0) {
                                String sAlias = resultLine.substring(15, idx1);
                                String sState = resultLine.substring(idx1+7, resultLine.length());
		                        dbg("=== | (+property) = "+sAlias+" = "+sState);
                                HashMap map = (HashMap)statesMap.get(sState);
                                if (map!=null) map.put("alias",sAlias);
                            }
                        }
                    }
				}
			}
			//get properties results
			else if(!resultLine.startsWith("policy ") )
			{
				//get property name
				String propName = "";
				if(resultLine.contains(" ")) {
                    if (resultLine.startsWith("revision sequence")) {
                        propName = "RevisionSequence";
                        resultLine = resultLine.substring(18, resultLine.length());
		                dbg("=== | (+revision) = "+resultLine);
                    }
				    else if(resultLine.startsWith("minor sequence")) {
    					propName = "RevisionSequence";
                        resultLine = resultLine.substring(15, resultLine.length());
                    }
				    else if(resultLine.startsWith("major sequence")) {
    					propName = "RevisionSequence";
                        resultLine = resultLine.substring(15, resultLine.length());
                    }
				    else if(resultLine.startsWith("type ")) {
    					propName = "AllReferencedTypes";
                        resultLine = PLMUtil.replaceAll(resultLine, "VPLMtyp/", "");
                        resultLine = PLMUtil.replaceAll(resultLine, ",", ", ");
                    }
                    else {
					    propName = resultLine.substring(0, resultLine.indexOf(" "));
                    }
                }
				else {
					propName = resultLine;
                }
				//make it in proper case
				propName = propName.substring(0, 1).toUpperCase() + propName.substring(1, propName.length());
				//get property value
				String propValue = "";
				if(resultLine.contains(" "))
					propValue = resultLine.substring(resultLine.indexOf(" ") + 1, resultLine.length());
                else
					propValue = resultLine;
				//update map
				propsMap.put(propName, "PROP_VALUE:" + propValue);
				//if it is "Description then also add Governed Type info to map
				updateMapWithGovernedType(context, policyName, propsMap);
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
		if(alignment == null)
			addBar(out, "barTDInReport", policyName, baseDivId + "mainDiv", currentLevel);
		else
			addBarInTypeReport(out, "barTDInReport", policyName, baseDivId + "mainDiv", currentLevel, alignment);
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
			
			<%
			//get key iterator
			Iterator keyItr = statesMap.keySet().iterator();
			//step through each result
			//update current level
			currentLevel++;
			while(keyItr.hasNext())
			{
				//get state name
				stateName = (String)keyItr.next();
				//get map for current state
				stateMap = (HashMap)statesMap.get(stateName);
				%>
				<div id='<%=baseDivId + stateName + "Div"%>' >
				<%
                String sState = stateName;
                String sAlias = (String )stateMap.get("alias");
                if (sAlias!=null) sState = sState + " ("+i18_alsoknowas+ " "+sAlias+")";
				addBar(out, "ctxBarTDInReport", sState, baseDivId + stateName + "ResultDiv", currentLevel - 1);
				%>
				</div>
				<div id='<%=baseDivId + stateName + "ResultDiv"%>' style="display:none">
					<div id='<%=baseDivId + stateName + "stateAccessesDiv"%>' style="display:">
					<%
					addBar(out, "stateAccessBarTDInReport", i18_accesses, baseDivId + stateName + "AccessesDiv", currentLevel);
					%>
						<div id='<%=baseDivId + stateName + "AccessesDiv"%>' style="display:none">
						<%
                        if (dbgActive()) {
                    		dbg("--------------------------------------------");
                    		dbg("=== | STATE: "+stateName+" / accesses");
                    		dbg("--------------------------------------------");
                        }
						//get map for current state's access
						resultMap =  (HashMap)stateMap.get("access");
						//write all table rows with results
                        if (!resultMap.isEmpty()) {
						    writeAllResults(out, resultMap, currentLevel, color, "Accesses", null);
                        }
						%>
						</div>
					</div>
					<%
					//get map for current state's access
                    if (dbgActive()) {
                		dbg("--------------------------------------------");
                		dbg("=== | STATE: "+stateName+" / branches");
                		dbg("--------------------------------------------");
                    }
					resultMap =  (HashMap)stateMap.get("branch");
                    if (!resultMap.isEmpty()) {
					%>
    					<div id='<%=baseDivId + stateName + "stateBranchesDiv"%>' style="display:">
	    				<%
		    			addBar(out, "stateAccessBarTDInReport", i18_branches, baseDivId + stateName + "BranchesDiv", currentLevel);
			    		%>
    						<div id='<%=baseDivId + stateName + "BranchesDiv"%>' style="display:none">
	    					<%
		    				//write all table rows with results
						    writeAllResults(out, resultMap, currentLevel, color, "Branches", null);
						%>
						</div>
					</div>
					<%
                    }
                    else {
		                dbg("=== | STATE: "+stateName+" / empty branches");
                    }
					%>
				</div>
		<%
			}
		%>
	</div>
	</body>

</html>

