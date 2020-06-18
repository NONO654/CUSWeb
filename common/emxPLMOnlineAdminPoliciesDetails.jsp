

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="com.dassault_systemes.vplmsecurity.util.PLMUtil" %>
<%@include file = "../common/emxPLMOnlineAdminIncludeNLS.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<!--include required for showModalDialog() function-->
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIModal.js"></script>

<html>

<head>

	<link href="../common/styles/emxUIDefault.css" rel="stylesheet" type="text/css" />

	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<link href="styles/emxPLMOnlineAdminStyle.css" rel="stylesheet" type="text/css" />

	<script language="javascript">
    //<![CDATA[
			
			// previous statePattern input for Report
			var prevStatePattern = "NoPrevious";

			// previous accessPattern input for Report
			var prevAccessPattern = "NoPrevious";

			// previous typePattern input for Report
			var prevTypePattern = "NoPrevious";

			// global array of policies+states
			var globalStateArray = new Array();

			// get tree object (the tree explorer on left side)
			var objDetailsTree = top.objDetailsTree;

			// get tree root name (MyProfile, or the selected user)
			var treeRoot = objDetailsTree.getCurrentRoot().getName();

            // ------------------------------------------------------------------------------
			//update global array of states
            // ------------------------------------------------------------------------------
			function updateGlobalStateArray(stateArray){
				//reset global array of states
				globalStateArray = new Array();

				for(var i = 0; i<stateArray.length; i++)
				{
					if(stateArray[i] != "")
					{
						//insert states in global states array
						globalStateArray.push(stateArray[i]);
					}
				}
			}

            // ------------------------------------------------------------------------------
			//update state combobox based on policy selection
            // ------------------------------------------------------------------------------
			function updateStateCombobox(){
				//if policies have been selected
				if(document.getElementById("policyComboBox").style.display == 'none')
				{
                    var bPolicyAll = document.filterIncludeForm.policyAll.checked;
					//if "All" policies are selected then add all states
					//if(document.filterIncludeForm.policyAll.checked == true)
					//{
					//	//fill combo box
					//	fillCombobox(globalStateArray, "state");
					//}
					////else update states based on selected policies
					//else
					//{
						var policyCheckboxes = document.filterIncludeForm.policyCheckbox;
						var newStateArray = new Array();
						//if there are more than one checkboxes
						if(policyCheckboxes.length)
						{
							for(var i=0; i < policyCheckboxes.length; i++)
							{
								//if policy is selected
								if(bPolicyAll || policyCheckboxes[i].checked == true)
								{
									for(var k = 0; k < globalStateArray.length; k++)
									{
										//if policy names match
										if(globalStateArray[k].substring(0, globalStateArray[k].indexOf(":")) == policyCheckboxes[i].value)
										{
											//update new array
											newStateArray.push(globalStateArray[k]);
										}
									}
								}
							}
						}
						//if there is only one checkbox
						else
						{
							//if policy is selected
							if(policyCheckboxes.checked == true)
							{
								for(var k = 0; k < globalStateArray.length; k++)
								{
									//if policy names match
									if(globalStateArray[k].substring(0, globalStateArray[k].indexOf(":")) == policyCheckboxes.value)
									{
										//update new array
										newStateArray.push(globalStateArray[k]);
									}
								}
							}
						}
						//fill combo box with new array
						fillCombobox(newStateArray, "state");
					//}
				}

			}
			
            // ------------------------------------------------------------------------------
			//initialization on page loading
            // ------------------------------------------------------------------------------
			function init()
			{
				// set comboboxes divs positions
				setComboboxPosition("policyComboBox", "policyTextboxId");
				setComboboxPosition("stateComboBox", "stateTextboxId");

				//refresh report
				//refreshReport();
			}

            // ------------------------------------------------------------------------------
			//refresh report
            // ------------------------------------------------------------------------------
			function refreshReport(){
				var typePattern   = document.filterIncludeForm.typePattern.value;
				var policyPattern = document.filterIncludeForm.policyPattern.value;
				var accessPattern = document.filterIncludeForm.accessPattern.value;
				var statePattern  = document.filterIncludeForm.statePattern.value;
				if(policyPattern != "")
				{
					policyPattern = removeExtraCommas(policyPattern);
                    document.filterIncludeForm.policyPattern.value = policyPattern;
				}
				if(accessPattern != "")
				{
					accessPattern = removeExtraCommas(accessPattern);
                    document.filterIncludeForm.accessPattern.value = accessPattern;
				}

                var policyComboBox = document.getElementById("policyComboBox");
                if (policyComboBox && policyComboBox.style.display == '') {
                    // Policies combo is open ... close it and update state combo
                    policyComboBox.style.display = 'none';
                    updateStateCombobox();
                }

				//get all values in textbox if "All" is checked
				var stateList    = getReallyAllCheckboxValues("filterIncludeForm", "stateCheckbox", "stateTextboxId");
				var policyList    = getReallyAllCheckboxValues("filterIncludeForm", "policyCheckbox", "policyTextboxId");

				//remove extra commas if necessary
				if(stateList != "")
				{
					stateList = removeExtraCommas(stateList);
				}
				if(policyList != "")
				{
					policyList = removeExtraCommas(policyList);
				}

				//refresh report with new values
				//added temporarily to work in MySpace
				if(treeRoot != "<%=context.getUser()%>")
					treeRoot = "<%=context.getUser()%>";
				//end
				//update Report only if inputs are different
				if(prevStatePattern != statePattern || prevAccessPattern != accessPattern || prevTypePattern != typePattern) {
                    var filterApplyForm = document.filterApplyForm;
                    filterApplyForm.treeRoot.value = treeRoot;
                    filterApplyForm.statePattern.value  = statePattern;
                    filterApplyForm.stateList.value     = stateList;
                    filterApplyForm.accessPattern.value = accessPattern;
                    filterApplyForm.typePattern.value   = typePattern;
                    filterApplyForm.policyPattern.value = policyPattern;
                    filterApplyForm.policyList.value    = policyList;
                    filterApplyForm.submit();
                }
                else alert('no change');
                // update previous field values
				prevStatePattern  = statePattern;
				prevAccessPattern = accessPattern;
                prevTypePattern   = typePattern;
			}

	//]]>
	</script>

</head>
	
<%!
    public static final int     ACCESS_OK      = 1;
    public static final int     ACCESS_DENIED  = 0;
    public static final int     ACCESS_UNKNOWN = -1;
    //
    public static final boolean EXPAND_OK      = true;
    public static final boolean EXPAND_NONE    = false;
    //
    public static final String  COLOR_RESULTS  = "CCFFFFF";
    //
    public static final String  ICON_PATH      = "../common/images/";
    //
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
			String parentRoleQuery = "list role '"+roleName+"' select parent dump";
			try{
				parentRoleResult = MqlUtil.mqlCommand(context,parentRoleQuery);
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
            if (dbgActive(3)) dbg("|   | "+PSkey+" = "+resultStr);
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
	//method to add a section bar : expandible (+/-) / access info
    //----------------------------------------------------------------------
    public void beginSection(JspWriter out, int indentWidth) throws IOException
    {
		//start table
		out.print("<table border='0' cellpadding='3' cellspacing='0' width='100%'>");
		//start row
		out.print("<tr>");
		
		if(indentWidth != 0) {
			out.print("<td width='" + indentWidth + "%'></td>");
        }
    }
    //----------------------------------------------------------------------
	public void addSectionBar(JspWriter out, String tdClass, String roleName, String divIdUniquePart, String i18_level, boolean bExpandible, int bHasAccess) throws IOException
	{
        if (dbgActive(2)) dbg("addBar("+roleName+") expand="+bExpandible+", access="+bHasAccess);
        String sExpandIcon = ICON_PATH + (String)(bExpandible ? "buttonPlus.gif"     : "buttonMinus.gif");
        String sExpandAction = (String)(bExpandible ? "onclick=\"switchMenu('" + roleName + divIdUniquePart + "Div', this);\"" : "");
        //
        String sAccessIcon = (String) (bHasAccess==ACCESS_UNKNOWN ? "" : "<img src='" + ICON_PATH + (String)(bHasAccess==ACCESS_OK  ? "buttonMiniDone.gif" : "buttonMiniCancel.gif") + "'/>");
        //
		out.print("<td class='" + tdClass + "'><img src='"+sExpandIcon+"' "+sExpandAction+"/>&nbsp;"+sAccessIcon+"&nbsp;<b>" + i18_level + "</td>");
	}
    //----------------------------------------------------------------------
    public void endSection(JspWriter out) throws IOException
    {
		//end row and table
		out.print("</tr></table>");
    }
    //----------------------------------------------------------------------
	//method to add bar cell based on accesses
    //----------------------------------------------------------------------
	public void addBarTD(JspWriter out, String tdClass, String roleName, boolean isMainLevel, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap) throws IOException
	{
        if (dbgActive(2)) traceIn("addBarTD("+roleName+")");
		//specify width for leftmost cell based on current level for indentation
		beginSection(out, level * 3);

        String i18_level = isMainLevel ? getNLS("Level."+roleName) : roleName;
		//check accesses
		HashMap resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
		//if it is context node and has either access or its any root roles have accesses
		if(roleName.contains("ctx::") && ((resultMap!=null && resultMap.size() > 0) || hasAnyRootRolesAccess(roleName, uniqueRoleResultsMap, uniqueParentsMap)))
		{
			//write cell with access image
            addSectionBar(out, tdClass, roleName, divIdUniquePart, i18_level, EXPAND_OK, ACCESS_OK);
		}
		//if it is not context node but has access
		else if(!roleName.contains("ctx::") && resultMap!=null && resultMap.size() > 0)
		{
			//write cell with access image
            addSectionBar(out, tdClass, roleName, divIdUniquePart, i18_level, EXPAND_OK, ACCESS_OK);
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
                if (dbgActive(2)) dbg("checking parents:");
                expandible = isRoleRequired(roleName, uniqueRoleResultsMap, uniqueParentsMap);
			}
            if (dbgActive(2)) dbg("==> "+expandible);
            addSectionBar(out, tdClass, roleName, divIdUniquePart, i18_level, expandible, expandible?ACCESS_OK:ACCESS_DENIED);
		}
        endSection(out);
        if (dbgActive(2)) traceOut();
	}
    //----------------------------------------------------------------------
	//method to add context bar cell based on accesses
    //----------------------------------------------------------------------
	public void addContextBarTD(JspWriter out, String tdClass, String roleName, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap, String[] contextArray) throws IOException
	{
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
				if(isRoleRequired(ctxRoleName, uniqueRoleResultsMap, uniqueParentsMap))
				{
					access = true;
					break;
				}
			}
            String i18_level = getNLS("Level."+roleName);
		    beginSection(out, level * 3);
            addSectionBar(out, tdClass, roleName, divIdUniquePart, i18_level, EXPAND_OK, access ? ACCESS_OK : ACCESS_DENIED);
            endSection(out);
		}
	}
    //----------------------------------------------------------------------
	//method to check if the role is required to be shown
    //----------------------------------------------------------------------
	public boolean isRoleRequired(String roleName, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap)
	{
        if (dbgActive(2)) traceIn("isRoleRequired("+roleName+")");
        boolean ok = true;
		HashMap resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);

		if(resultMap.size() <= 0) {
            //get parent roles
    		String parentRoles = (String)uniqueParentsMap.get(roleName);
	    	//if it has no access and no parent roles
		    if(parentRoles == null || parentRoles.equals("")) {
                ok = false;
            }
            else {

        		//if it has no access but has parent roles : check parents!
	        	String[] parentRoleArray = PLMUtil.split(parentRoles,",");
		        //step through each parent role
                ok = false;
    		    for(int i = 0; i < parentRoleArray.length && !parentRoleArray[i].equals(""); i++)
    	    	{
	    	    	if(isRoleRequired(parentRoleArray[i], uniqueRoleResultsMap, uniqueParentsMap)) {
                        ok = true;
                        break;
                    }
                }
    		}
        }
        if (dbgActive(2)) dbg(""+ok);
        if (dbgActive(2)) traceOut();
		return ok;
	}
    //----------------------------------------------------------------------
	//method to add bar cell if required
    //----------------------------------------------------------------------
	public void addBarIfRequired(JspWriter out, String tdClass, String roleName, int level, String divIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap) throws IOException
	{
		//specify width for leftmost cell based on current level for indentation
		//if it is to be shown only if it is required without access image
		if(isRoleRequired(roleName, uniqueRoleResultsMap, uniqueParentsMap))
		{
		    beginSection(out, level * 3);
			//write cell without access image
            addSectionBar(out, tdClass, roleName, divIdUniquePart, roleName, EXPAND_OK, ACCESS_OK);
            endSection(out);
		}
	}
    //----------------------------------------------------------------------
	// method to add bar cell if required
    //----------------------------------------------------------------------
	public void addCheckBoxInCombo(JspWriter out, String sComboId, String sName, String sValue, String sNLSValue, boolean bChecked) throws IOException
	{
        String sChecked = (String)(bChecked ? "checked" : "");
        out.println("<tr><td><input type=\"checkbox\" name=\""+sName+"\" value=\""+sValue+"\" onclick=\"updateTextBox(this, \'"+sComboId+"\')\" "+sChecked+">"+sNLSValue+"</td></tr>");
	}
		
    //----------------------------------------------------------------------
	// method to retrieve the ancestors of a role (recursive)
    //----------------------------------------------------------------------
	public void retrieveRolesAncestors(Context context, String[] arrRoles, HashMap uniqueParentsMap, HashMap uniqueRoleResultsMap) throws IOException
	{
		for(int i=0; i < arrRoles.length; i++)
		{
			String roleName = arrRoles[i];
			//if not created already then create entry in map
			if(!uniqueRoleResultsMap.containsKey(roleName))
			{
				uniqueRoleResultsMap.put(roleName, new LinkedHashMap());
			}
			//else don't go for inner loop and continue
			else continue;
			
			//get parent roles
			String parentsResult = getParentRoles(context, roleName, uniqueParentsMap);
            if (parentsResult != null && parentsResult.length()>0) {
                traceIn(roleName);
    			String[] arrParentRoles = PLMUtil.split(parentsResult,",");
                // retrieve its ancestors
                retrieveRolesAncestors(context, arrParentRoles, uniqueParentsMap, uniqueRoleResultsMap);
                traceOut();
            }
            else dbg(roleName);
        }
	}
		
    //----------------------------------------------------------------------
	// prints a "role" report (and recursively on role parents)
    //----------------------------------------------------------------------
	public void printRoles(JspWriter out, Context context, int currentLevel, boolean odd, String[] arrRoles, String currentDivIdUniquePart, HashMap uniqueRoleResultsMap, HashMap uniqueParentsMap) throws Exception
	{
		for(int i = 0; i < arrRoles.length && !arrRoles[i].equals(""); i++)
		{
            // get i-th role in array
			String roleName = arrRoles[i];
            traceIn(roleName);
            try {
                // compute the UID part of the DIV ID
                String divIdUniquePart = currentDivIdUniquePart + "_" + i;
                // add the clickable bar
                String sDivClass = (String) (odd ? "ctxBarTDInReport" : "stateAccessBarTDInReport");
                if (currentLevel>2)
                    addBarIfRequired(out, sDivClass, roleName, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
                else
                    addBarTD(out, sDivClass, roleName, false, currentLevel, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
                // start DIV
                out.print("<div id=\""+roleName+divIdUniquePart+"Div\" style=\"display:none\">");
                // DIV body:
                try {
                    // - check access
                    HashMap resultMap = (HashMap)uniqueRoleResultsMap.get(roleName);
	    	    	if(resultMap.size() > 0)
		    	    {
			    	    //write all table rows with access results
    			    	writeAllResults(out, resultMap, currentLevel, COLOR_RESULTS);
    	    		}
	    	    	String parentRolesResult = getParentRoles(context, roleName, uniqueParentsMap);
		    	    String[] parentRolesArray = PLMUtil.split(parentRolesResult,",");
                    // prints parents roles report
                    printRoles(out, context, currentLevel+1, !odd, parentRolesArray, divIdUniquePart, uniqueRoleResultsMap, uniqueParentsMap);
                }
                catch(Exception ex) {
                    ex.printStackTrace();
                    throw ex;
                }
                finally {
                    // - 
                    // end DIV
                    out.print("</div>");
                }
            }
            catch(Exception ex) {
                ex.printStackTrace();
                throw ex;
            }
            finally {
                traceOut();
            }
        }
	}
		
%>

<body  onload="init()">
<%
    initTrace("AdminPolicyReportUI");
    initNLSCatalog("emxPLMOnlineAdminSecurityReport",request);
    String i18_type    = getNLS("Filter.Type");
    String i18_policy  = getNLS("Filter.Policy");
    String i18_state   = getNLS("Filter.State");
    String i18_access  = getNLS("Filter.Access");
    String i18_report  = getSafeNLS("Filter.Report");
    _I18_ACCESS           = getNLS("Accesses.Access");
    _I18_FILTER           = getNLS("Accesses.Filter");
    try {
        traceIn("emxPLMOnlineAdminPoliciesDetails.jsp");

		// get input parameters:
        // - concerned person (default: null = use current context user)
		String personName           = request.getParameter("treeRoot");
        // - form parameters
		String typePattern          = request.getParameter("typePattern");
		String policyPattern        = request.getParameter("policyPattern");
		String policyListParam      = request.getParameter("policyList");
		String statePattern         = request.getParameter("statePattern");
		String stateListParam       = request.getParameter("stateList");
		String accessPattern        = request.getParameter("accessPattern");
        // - hidden parameters
        String paramListAllPolicies     = request.getParameter("listAllPolicies");
        String paramListAllPolicyStates = request.getParameter("listAllPolicyStates");
        dbg("-----------------------------------------------------------------");
        if (personName == null) {
            personName = context.getUser();
            dbg("> User  : "+personName+" (from context)");
        }
        else {
            dbg("> User  : "+personName);
        }
        if (typePattern == null) { typePattern = "All"; }
        dbg("> Type  : "+typePattern);
        if (policyPattern == null) { policyPattern = "All"; }
        dbg("> Policy: "+policyPattern);
        dbg("> - list: "+policyListParam);
        if (statePattern == null) { statePattern = "All"; }
        dbg("> States: "+statePattern);
        dbg("> - list: "+stateListParam);
        if (accessPattern == null) { accessPattern = "All"; }
        dbg("> Access: "+accessPattern);
        dbg("-----------------------------------------------------------------");
        dbg("> All policies     : "+paramListAllPolicies);
        dbg("> All policy states: "+paramListAllPolicyStates);
        dbg("-----------------------------------------------------------------");

		//
		// -------------------------------------------------------------------
        // Load all Policies 
		// -------------------------------------------------------------------
        // 
        boolean   bSelectedPolicyAll = (policyPattern.equals("All"));
		ArrayList policyList = new ArrayList(); 
		
        if (paramListAllPolicies == null) {
    		try{
                dbg("=== Get Policies");
	    		policyList.addAll(new TreeSet((ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getPolicyNames", null, ArrayList.class)));
                paramListAllPolicies = "";
				for(int i=0;i<policyList.size();i++) {
                    if (i != 0) paramListAllPolicies += ",";
                    paramListAllPolicies += policyList.get(i);
                }
                dbg("All policies ==> "+paramListAllPolicies);
    		}
	    	catch(Exception e)
		    {
			    out.print("Exception has come: "+ e);
    		}
        }
        else {
            if (policyListParam == null) {
                dbg("INFO: reusing allPolicies parameter");
                String list[] = paramListAllPolicies.split(",");
                for (int i=0; i<list.length; i++) {
                    policyList.add(list[i]);
                }
            }
            else {
                dbg("INFO: reusing selected Policies parameter");
                String list[] = policyListParam.split(",");
                for (int i=0; i<list.length; i++) {
                    policyList.add(list[i]);
                }
            }
        }
		
		// 
		// -------------------------------------------------------------------
        // Load all Policies States 
		// -------------------------------------------------------------------
        // 
        boolean   bSelectedPolicyStatesAll = (statePattern.equals("All"));
		ArrayList stateList         = new ArrayList(); 
		ArrayList explicitStateList = new ArrayList(); 

        if (paramListAllPolicyStates == null) {
    		HashMap polMap = new HashMap();
	    	polMap.put("policyList",policyList);
		    String []args = JPO.packArgs(polMap);
		
    		try{
                dbg("=== Get Policies states");
		    	stateList.addAll(new TreeSet((ArrayList)JPO.invoke(context,"emxPLMOnlineAdminPersonViewProgram", null,"getStates", args, ArrayList.class)));
                paramListAllPolicyStates = "";
				for(int i=0;i<stateList.size();i++) {
                    if (i != 0) paramListAllPolicyStates += ",";
                    paramListAllPolicyStates += stateList.get(i);
                }
                dbg("All policy states ==> "+paramListAllPolicyStates);
    		}
	    	catch(Exception e)
		    {
			    out.print("Exception has come: "+ e);
            }
		}
        else {
            // list of states (in combo)
            String list[] = null;
            if (stateListParam == null) {
                dbg("INFO: reusing allPolicyStates parameter");
                list = PLMUtil.split(paramListAllPolicyStates,",");
            }
            else {
                dbg("INFO: reusing selected PolicyStates parameter");
                list = PLMUtil.split(stateListParam,",");
            }
            if (list != null) {
                for (int i=0; i<list.length; i++) {
                    stateList.add(list[i]);
                }
            }
        }
            // explicit list of selected states
            if (bSelectedPolicyStatesAll) {
                dbg("INFO: selected states = all");
                explicitStateList.addAll(stateList);
            }
            else {
                dbg("INFO: selected states = filtered");
                String selected[] = PLMUtil.split(statePattern,",");
                for (int i=0; i<selected.length; i++) {
                    explicitStateList.add(selected[i]);
                }
            }
		
		// 
		// -------------------------------------------------------------------
        // Define Policy selection (for combo box)
		// -------------------------------------------------------------------

        ArrayList listOfSelectedPolicies = new ArrayList();
        //
        if (!bSelectedPolicyAll) {
            // there is a selection
            dbg("Selected policies:");
            String list[] = PLMUtil.split(policyPattern,",");
            for (int i=0; i<list.length; i++) {
                dbg("| selected policy["+i+"] = "+(String)list[i]);
                listOfSelectedPolicies.add(list[i]);
            }
        }
		
		// 
		// -------------------------------------------------------------------
        // Define Policy states selection (for combo box)
		// -------------------------------------------------------------------

        ArrayList listOfSelectedPolicyStates = new ArrayList();
        //
        if (!bSelectedPolicyStatesAll) {
            // there is a selection
            dbg("Selected policy states:");
            String list[] = PLMUtil.split(statePattern,",");
            for (int i=0; i<list.length; i++) {
                dbg("| selected policy state["+i+"] = "+(String)list[i]);
                listOfSelectedPolicyStates.add(list[i]);
            }
        }
        
		// -------------------------------------------------------------------
		//update global state array for javascript
		// -------------------------------------------------------------------
	%>
		<script language="javascript">
    <%
        //dbg("globalStateArray content:");
        String allStates[] = PLMUtil.split(paramListAllPolicyStates,",");
		for(int i=0;i<allStates.length;i++)
		{
			String stateName = (String)allStates[i];
            //dbg("| state["+i+"] = "+stateName);
			%>
				globalStateArray.push(<%="'"+stateName+"'"%>);
			<%
		}
	%>
		</script>
	<%

%>
          <table >
             <tr>
                <td>
	                <form name="filterIncludeForm">
                     <table>
                        <tr>
                          <td class="labelInFilter"><label><%=i18_type%></label></td>

                          <td class="inputField" >
                            <input type="text" name="typePattern" size="10" id="typeNames" value="<%=typePattern%>" readonly>
                          </td>
						  <td>
                            <input type="button"  class="buttonInFilter"  value="..." onclick="showModalDialog('../common/emxTable.jsp?table=emxPLMOnlineAdminModelViewReferenceTable&selection=multiple&program=emxPLMOnlineAdminModelViewProgram:getReferenceNames&objectBased=false&Style=Dialog&FilterFramePage=emxPLMOnlineAdminCustomFilter.jsp&mode=open&CancelButton=true&CancelLabel=Cancel&SubmitLabel=Done&SubmitURL=emxPLMOnlineAdminPoliciesSelectTypesProcess.jsp')">
                          </td>

                          <td > &nbsp; </td>
                          <td class="labelInFilter" ><label><%=i18_policy%></label></td>
						  <td>
                            <input type="text" name="policyPattern" id="policyTextboxId" readonly class="textboxForCombo" style="width:220px" onclick="showHideList(this, 'policyComboBox'); updateStateCombobox();"  id="policyNames" value="<%=policyPattern%>">
							<div id="policyComboBox" class="comboboxInFilter" style="display:none">
								<table bgcolor="white" width="100%" id="policyTableId">
									<%
                                    dbg("policy combo box content:");
                                    addCheckBoxInCombo(out, "policyTextboxId", "policyAll", "All", "All", bSelectedPolicyAll);
									for(int i=0;i<policyList.size();i++)
									{
                                        String policyName = (String)policyList.get(i);
                                        dbg("| policy["+i+"] = "+policyName);
                                        addCheckBoxInCombo(out, "policyTextboxId", "policyCheckbox", policyName, policyName, !bSelectedPolicyAll && listOfSelectedPolicies.contains(policyName));
									}					
									%>
								</table>
							</div>
						</td>

						<td > &nbsp; </td>
						<td class="labelInFilter"><label><%=i18_state%></label></td>
						<td>
                            <input type="text" name="statePattern" id="stateTextboxId" readonly class="textboxForCombo" onclick="showHideList(this, 'stateComboBox')" style="width:257px" id="stateNames" value="<%=statePattern%>">
							<div id="stateComboBox" class="comboboxInFilter" style="display:none;">
								<table bgcolor="white" width="100%" id="stateTableId">
									<%
                                    dbg("policy/states combo box content:");
                                    addCheckBoxInCombo(out, "stateTextboxId", "stateAll", "All", "All", bSelectedPolicyStatesAll);
									for(int i=0;i<stateList.size();i++)
									{
                                        String stateName = (String)stateList.get(i);
                                        dbg("| state["+i+"] = "+stateName);
                                        addCheckBoxInCombo(out, "stateTextboxId", "stateCheckbox", stateName, stateName, !bSelectedPolicyStatesAll && listOfSelectedPolicyStates.contains(stateName));
									}					
									%>
								</table>
							</div>
						</td>

						<td > &nbsp; </td>
						<td class="labelInFilter"><label><%=i18_access%></label></td>
						<td class="inputField" >
							<input type="text" name="accessPattern" size="10" value="<%=accessPattern%>" readonly>
						</td>
						<td>
                            <input type="button"  class="buttonInFilter" value="..." onclick="showModalDialog('emxPLMOnlineAdminAccessDisplayFS.jsp')">
                        </td>
						<td width="20"> &nbsp; </td>
						<!-- td width="150"><input type="button" class="buttonInFilter" name="btnFilter" value="<%=i18_report%>" onclick="refreshReport()"></td -->
			            </tr>
		             </table>
			        </form>
                </td>
                <td>
                     <table>
                        <tr>
						  <td>
	                       <form name="filterApplyForm" method="post" action="emxPLMOnlineAdminPoliciesDetails.jsp">
                            <input type="hidden" name="treeRoot"        value="<%=personName%>" />
                            <input type="hidden" name="listAllPolicies"     value="<%=paramListAllPolicies%>" />
                            <input type="hidden" name="listAllPolicyStates" value="<%=paramListAllPolicyStates%>" />
                            <input type="hidden" name="typePattern"     value="typePattern" />
                            <input type="hidden" name="policyPattern"   value="policyPattern" />
                            <input type="hidden" name="policyList"      value="policyList" />
                            <input type="hidden" name="statePattern"    value="statePattern" />
                            <input type="hidden" name="stateList"       value="stateList" />
                            <input type="hidden" name="accessPattern"   value="accessPattern" />
						    <input type="button" class="buttonInFilter" name="btnFilter" value="<%=i18_report%>" onclick="refreshReport()">
			               </form>
                          </td>
			            </tr>
		             </table>
			    </td>
			 </tr>
		  </table>
	
        <!-- ============================================================== -->
        <!-- === Content frame                                          === -->
        <!-- ============================================================== -->

		<!-- iframe name="contentFrame" id="contentFrame" src="emxPLMOnlineAdminPoliciesLoading.jsp" frameborder="0" class="iframe" width="100%" height="90%"/ -->
		<div id="contentFrame" class="iframe" width="100%" height="90%">
<%
        try {

		// -------------------------------------------------------------------
        // convert param strings to lists
		// -------------------------------------------------------------------

		// get array of selected policy states
        //   result: policyStateArray[]
        String policyStateArray[] = new String[explicitStateList.size()];
        for (int ip=0; ip<policyStateArray.length; ip++) {
            policyStateArray[ip] = (String)explicitStateList.get(ip);
        }
		// get array of selected accesses
        //   result: accessArray[]
        if (accessPattern == null) {
            accessPattern = "All";
        }
		String accessArray[] = accessPattern.split(",");
		

		//get Contexts
		String personCTXResult = "";
		try{
			personCTXResult = MqlUtil.mqlCommand(context,"print person $1 select $2 dump",personName,"assignment");
		}
		catch (Exception ex) {
			System.out.println("Exception: "+ex);
		}
		String contextArray[] = personCTXResult.split(",");
		
		// -------------------------------------------------------------------
        // build map for parent roles
        //   result: uniqueParentsMap{}
        //   result: uniqueRoleResultsMap{}
		// -------------------------------------------------------------------
		//hash map of parent roles with distinct role name as key
		HashMap uniqueParentsMap = new HashMap();
		//hash map to contain distinct role names as keys and result hashmaps (which in turn contains policy+state as keys and access results as values) as values
		HashMap uniqueRoleResultsMap = new HashMap();

		//step through each context
        traceIn("ancestors()");
        retrieveRolesAncestors(context, contextArray, uniqueParentsMap, uniqueRoleResultsMap);
        traceOut();

		// -------------------------------------------------------------------
        // query selected policies & states, to get related accesses and filters
		// -------------------------------------------------------------------

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
            dbg("| policy/state: "+policyName+" / "+stateName);
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
                        if (_trace.isTracing(4)) {
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

		// -------------------------------------------------------------------
		//parse policy query results and update role results 
		// -------------------------------------------------------------------

		String resultLine = "";
		String result = "";
		String roleName = "";
		HashMap resultMap = null;
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

		// -------------------------------------------------------------------
        // update filtered access with associated filter
		// -------------------------------------------------------------------

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

		// -------------------------------------------------------------------
        // display result
		// -------------------------------------------------------------------
		
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
        dbg("printing roles:");
        printRoles(out, context, 1, true, contextArray, "", uniqueRoleResultsMap, uniqueParentsMap);
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
        </div>
<%
    }
    catch (Exception ex) {
        ex.printStackTrace();
    }
    finally {
        traceOut();
    }
%>
	
</body>

</html>
