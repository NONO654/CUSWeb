 

<%-- Common Includes --%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.program.CostItem"%>
<%@page import="com.matrixone.apps.framework.ui.UITableCommon"%>
<%@page import="matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.util.PolicyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<!-- Added:12-Jan-2010:vf2:R209 RG:IR-013972 -->
<%@page import="com.matrixone.apps.common.Search"%>
<!-- End:12-Jan-2010:vf2:R209 RG:IR-013972 -->


<%@include file = "../common/emxUIConstantsInclude.inc"%>


<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.common.Company"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>


<%boolean bFlag = false;
            try {
                //gets the mode passed
                String languageStr = context.getSession().getLanguage();
                String strMode = emxGetParameter(request, "mode");
                String projectId = emxGetParameter(request, "objectId");
                String strReturnResult = "";
                StringBuffer sBuff = new StringBuffer();
                String strSubMode = emxGetParameter(request, "submode");
              
                // [ADDED::PRG:RG6:Jan 5, 2011:R211:IR-075617V6R2012:When invoked from RMB project id is coming as current obj id]
                String isFromRMB = emxGetParameter(request, "isFromRMB");
               if(null != isFromRMB && "true".equalsIgnoreCase(isFromRMB.trim())){
                   String strRootObjectId = emxGetParameter(request, "rootObjectId");
                   if( null != strRootObjectId && !"Null".equalsIgnoreCase(strRootObjectId.trim()) && !"".equalsIgnoreCase(strRootObjectId.trim())){
                	   projectId = strRootObjectId;
                   }   
               }
               // [ADDED::PRG:RG6:Jan 5, 2011:IR-075617V6R2012:R211::End]   
                
              //Added 27-Sep-2010:PRG:RG6:IR-070662V6R2011x
                com.matrixone.apps.domain.util.PersonUtil contextUser =  new  com.matrixone.apps.domain.util.PersonUtil();
                String strPreferredCurrency = contextUser.getCurrency(context);
                //Added 12-May-2011:PRG:MS9:IR-078882V6R2012x
                DomainObject domProjectObj = DomainObject.newInstance(context);
                if(ProgramCentralUtil.isNotNullString(projectId))
                {
                	domProjectObj.setId(projectId); 
                	
                if(null!=domProjectObj && !domProjectObj.isKindOf(context,DomainConstants.TYPE_PROJECT_TEMPLATE) && !strMode.equalsIgnoreCase("connectCostItem"))
                {  //End 12-May-2011:PRG:MS9:IR-078882V6R2012x 
	                if(null!=strPreferredCurrency && !strPreferredCurrency.equals("As Entered") && !strPreferredCurrency.equals(""))
	                {
	                    // do nothing
	                }
	                else
	                {
	                    String strTotalLabel = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
	              			  "emxProjectBudget.Error.NoDefaultCurrencyDefined", languageStr);
	                   %>
	                    <script language="JavaScript" type="text/javascript">
	                                                    alert("<%=strTotalLabel%>");
	                                                    window.closeWindow();
	                    </script>
	                    <%
	                }
                }
                }                          
              //End 27-Sep-2010:PRG:RG6:IR-070662V6R2011x 
                if (("edit").equals(strMode)){
//                  Getting the table row ids of the selected objects for clonig the request
                    String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
                    String strTokenId = "";
                    String strSelectedBudgetID = "";
                    if(strTableRowId == null || strTableRowId.length == 0){
                        String strLanguage = context.getSession().getLanguage();

                        String sErrMsg = EnoviaResourceBundle.getProperty(context,"ProgramCentral",
                        		"emxProgramCentral.Budget.SelectBudget",strLanguage);
                        %>
                <script language="JavaScript" type="text/javascript">
                                                alert("<%=sErrMsg%>");
                                            </script>
                <%return;
                }else {
                	Map mpTableID = null;
                	for (int i = 0; i < strTableRowId.length; i++) {
                		mpTableID = ProgramCentralUtil.parseTableRowId(context,strTableRowId[i]);
                    }
                    strSelectedBudgetID = (String)mpTableID.get("objectId");
                    DomainObject dmoSelectedID = new DomainObject(strSelectedBudgetID);
                   
                    if(!dmoSelectedID.isKindOf(context,ProgramCentralConstants.TYPE_BUDGET)){
                    	String strLanguage = context.getSession().getLanguage();
                        String sErrMsg = EnoviaResourceBundle.getProperty(context,"ProgramCentral",
                        		"emxProgramCentral.Budget.SelectBudget",strLanguage);
                        %>
                        <script language="JavaScript" type="text/javascript">
                                          alert("<%=sErrMsg%>");
                        </script>
                	<%return;
                    }
                    for (int i = 0; i < strTableRowId.length; i++) {
                        java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(
                                strTableRowId[i], "|");
                        int nTokenCount = strTokenizer.countTokens();
                        for (int j = 0; j < nTokenCount; j++) {
                            strTokenId = strTokenizer.nextToken();
                            if (j == 0) {
                            	strSelectedBudgetID =  strTokenId;
                            }
                        }
                    }
                 }

                    %>
                    <script language="javascript" type="text/javaScript">
                        url = "../common/emxForm.jsp?type=type_Budget&policy=policy_FinanciaItem&form=PMCProjectTemplateBudgetEditForm&mode=edit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Budget.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBudgetID)%>";
                        getTopWindow().showSlideInDialog(url,true);                
                    </script>
<%}
 else if(("editProjectBudget").equals(strMode)){

//       Getting the table row ids of the selected objects for clonig the request
         String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
         String strTokenId = "";
         String strSelectedBudgetID = "";
         if(strTableRowId == null || strTableRowId.length == 0){
             String strLanguage = context.getSession().getLanguage();

             String sErrMsg = i18nNow
                     .getI18nString(
                             "emxProgramCentral.ResourceRequest.SelectBudget",
                             "emxProgramCentralStringResource",
                             strLanguage);

             %>
     <script language="JavaScript" type="text/javascript">
                                     alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");

                                 </script>
     <%return;
     }else {
    	//Modified:di7:IR-123969V6R2012x:26-Aug-2011:start
    	 Map mpTableID = null;
         for (int i = 0; i < strTableRowId.length; i++) {
             mpTableID = ProgramCentralUtil.parseTableRowId(context,strTableRowId[i]);
                 }
         strSelectedBudgetID = (String)mpTableID.get("objectId");//added:di7
         DomainObject dmoSelectedID = new DomainObject(strSelectedBudgetID);
        //Modified:di7:IR-123969V6R2012x:26-Aug-2011:start
         if(!dmoSelectedID.isKindOf(context,ProgramCentralConstants.TYPE_BUDGET)){
        	 String strLanguage = context.getSession().getLanguage();

             String sErrMsg = i18nNow
                     .getI18nString(
                             "emxProgramCentral.Budget.SelectBudget",
                             "emxProgramCentralStringResource",
                             strLanguage);

             %>
     <script language="JavaScript" type="text/javascript">
                                     alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                                 </script>
     <%return;
        	 
         }
         }
         %>
         <script language="javascript" type="text/javaScript">
                url = "../common/emxForm.jsp?type=type_Budget&policy=policy_FinanciaItem&form=PMCProjectBudgetEditForm&mode=edit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Budget.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBudgetID)%>";
                getTopWindow().showSlideInDialog(url,true);                
              </script>
<%
     }else if (("editProjectBudgetProperties").equals(strMode)){
         String strSelectedBudgetID = "";        
         strSelectedBudgetID = emxGetParameter(request,"objectId");
         DomainObject dbBudget = DomainObject.newInstance(context,strSelectedBudgetID);
         String strQuery = "relationship["+ProgramCentralConstants.RELATIONSHIP_PROJECT_FINANCIAL_ITEM+"].from.type";
         String strParentType =  dbBudget.getInfo(context,strQuery);
         if(strParentType.equalsIgnoreCase(DomainObject.TYPE_PROJECT_SPACE)){
         %>
         <script language="javascript" type="text/javaScript">
             url = "../common/emxForm.jsp?type=type_Budget&policy=policy_FinanciaItem&form=PMCProjectBudgetEditForm&mode=edit&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralBudgetUtil.jsp?mode=refreshStructure&HelpMarker=emxhelpprojectbudgetedit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Budget.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBudgetID)%>";
             getTopWindow().showSlideInDialog(url,true);
              </script>
<%     
         }else{
         	%>
         	<script language="javascript" type="text/javaScript">
             url = "../common/emxForm.jsp?type=type_Budget&policy=policy_FinanciaItem&form=PMCProjectTemplateBudgetEditForm&mode=edit&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralBudgetUtil.jsp?mode=refreshStructure&HelpMarker=emxhelpprojectemplatebudgetedit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Budget.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBudgetID)%>";
             getTopWindow().showSlideInDialog(url,true);
            </script>
			<% 
         }
     }else if (("refreshStructure").equals(strMode)){
        
         %>
         <script language="javascript" type="text/javaScript">
         var topFrame = findFrame(getTopWindow(), "PMCProjectBudget");	
         if(topFrame== null){
        	 topFrame = findFrame(getTopWindow(), "detailsDisplay");
         }
         topFrame.location.href = topFrame.location.href; 
         </script>

			<% 
     }
     
 else if(("addCostItem").equals(strMode)){
	      String strComapnyId = PersonUtil.getUserCompanyId(context);
	 	  %>
	         <script language="javascript" type="text/javaScript">
	             getTopWindow().resizeTo(700,600);//because the full search windows is very wide
	             //
	             // Note: Also sending objectId parameter to form pages for form page to get closed
	             // correctly after edit process finished. This is Common Component defect's workaround,
	             // due to time constraints.
	             //
	             getTopWindow().location.href = "../common/emxIndentedTable.jsp?table=PMCProjectBudgetTable&selection=multiple&suiteKey=ProgramCentral&header=emxProgramCentral.Budget.AddCostCategoryItem&program=emxProjectBudget:getTableCostCategoryItemData&expandProgram=emxProjectBudget:getExpandTableCostCategoryItemData&objectId=<%=XSSUtil.encodeForURL(context,strComapnyId)%>&cancelLabel=emxProgramCentral.Button.Cancel&HelpMarker=emxhelpcostcategoryadd&submitLabel=emxFramework.Button.Submit&submitURL=../programcentral/emxProgramCentralBudgetUtil.jsp?mode=connectCostItem&ProjectId=<%=XSSUtil.encodeForURL(context,projectId)%>";
	              </script>
	<%
	     }
 else if(("connectCostItem").equals(strMode)){
	 %>
	 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
	 <%
	 String strProjectId = emxGetParameter(request, "ProjectId");
	 String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
     String strTokenId = "";
     String strSelectedCostItem = "";
     StringList slSelectedCostItem = new StringList();
     StringList slSelectedCostItemName = new StringList();
     String strSelectedCostCategoryId = "";
     String strSelectedCostCategory = "";
     StringList slSelectedCostCategory = new StringList();
     
     java.util.Set<String> objectInfoList = new HashSet<String>();
     java.util.Set<String> selectedObjectIds = new HashSet<String>();
     for (int i = 0; i < strTableRowId.length; i++) {
         java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(
                 strTableRowId[i], "|");
         int nTokenCount = strTokenizer.countTokens();
         for (int j = 0; j < nTokenCount; j++) {
             strTokenId = strTokenizer.nextToken();
             if (j == 0) {
            	 strSelectedCostItem =  strTokenId;
            	 selectedObjectIds.add(strSelectedCostItem);
             }
             
             if(j == 1 ){
            	 strSelectedCostCategoryId =  strTokenId;
             }
         }
         objectInfoList.add(strSelectedCostItem+"~"+strSelectedCostCategoryId);
     }
     java.util.List<String> finalObjectList = new ArrayList<String>(20);
     for(Iterator<String> itr = objectInfoList.iterator(); itr.hasNext();){
    	String sBenItemCat = itr.next();
    	StringList slObj = FrameworkUtil.splitString(sBenItemCat, "~");
    	String objId = (String)slObj.get(0);
    	String parentId = (String)slObj.get(1);
    	if(selectedObjectIds.contains(parentId)){
    		continue;
    	}
    	//strSelectedCostItem 	  = objId;
    	//strSelectedCostCategoryId = parentId;
    	finalObjectList.add(sBenItemCat);
     }
     
     for(Iterator<String> itr = finalObjectList.iterator();itr.hasNext();){
    	 String sBenItemCatPair = itr.next();
    	 StringList slObj = FrameworkUtil.splitString(sBenItemCatPair, "~");
     	String objId = (String)slObj.get(0);
     	String parentId = (String)slObj.get(1);
     	strSelectedCostItem 	  = objId;
     	strSelectedCostCategoryId = parentId;
     DomainObject dmoSelectedCostITem = new DomainObject(strSelectedCostItem);
     DomainObject dmoSelectedCostCAtegory = new DomainObject(strSelectedCostCategoryId);
     String strSelectedCostItemName = dmoSelectedCostITem.getInfo(context,DomainConstants.SELECT_NAME);
     strSelectedCostCategory = dmoSelectedCostCAtegory.getInfo(context,DomainConstants.SELECT_NAME);
     final String QUERY_WILDCARD = "*";
     StringList busSelects = new StringList();
    busSelects.add(DomainConstants.SELECT_ID);
    busSelects.add(DomainConstants.SELECT_NAME);
    String busWhere = "";
    MapList mapList = dmoSelectedCostITem.getRelatedObjects(
            context,        // context
            Financials.RELATIONSHIP_FINANCIAL_SUB_CATEGORIES,
            QUERY_WILDCARD, // type filter.
            busSelects,     // object selectables.
            null,           // relationship selectables
            false,          // expand to direction.
            true,           // expand from direction
            (short) 1,  // level
            busWhere,       // object where clause
            null);   
    
    if("null".equals(mapList)|| null == mapList || mapList.size() == 0){
            slSelectedCostItem.add(strSelectedCostItem);
    	    slSelectedCostItemName.add(strSelectedCostItemName);
    	    slSelectedCostCategory.add(strSelectedCostCategory);
    }else{
    	 Map mapCostCategory = null; 
          for (Iterator iterCostCat = mapList.iterator(); iterCostCat .hasNext();)
          {
        	  mapCostCategory = (Map) iterCostCat.next();
              String strSelectedCostItem1 = (String)mapCostCategory.get(DomainConstants.SELECT_ID);
              String strSelectedCostItemName1 = (String)mapCostCategory.get(DomainConstants.SELECT_NAME);
              slSelectedCostItem.add(strSelectedCostItem1);
              slSelectedCostItemName.add(strSelectedCostItemName1);
              slSelectedCostCategory.add(strSelectedCostItemName);
          }
    }
     }
    CostItem costItem = new CostItem();
    costItem.connectCostItem(context, strProjectId,slSelectedCostItem,slSelectedCostItemName,slSelectedCostCategory);
    %>
    <script language="JavaScript" type="text/javascript">
     getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().close();
    </script>
    <%
 }
 else if("listActualTransactions".equals(strMode)){
     DomainObject projectObj = DomainObject.newInstance(context,projectId);
     String strRelProjectFinancialItem = PropertyUtil.getSchemaProperty(context,"relationship_ProjectFinancialItem");
     String strActualTransactionCurrencyFilter = emxGetParameter(request,"PMCActualTransactionCurrencyFilter");
     if(ProgramCentralUtil.isNullString(strActualTransactionCurrencyFilter))
         strActualTransactionCurrencyFilter = strPreferredCurrency;
     String strTypePattern = ProgramCentralConstants.TYPE_BUDGET;
     StringList busSelect = new StringList();
     busSelect.add(DomainConstants.SELECT_NAME);
     busSelect.add(DomainConstants.SELECT_ID);
     StringList relSelect = new StringList();
     MapList mlBudget = projectObj.getRelatedObjects(
                                                        context,
                                                        strRelProjectFinancialItem,
                                                        strTypePattern,
                                                        busSelect,
                                                        relSelect,
                                                        false,
                                                        true,
                                                        (short)1,
                                                        null,
                                                        DomainConstants.EMPTY_STRING,
                                                        0);
     Map mapBudgetInfo = null;
     String strBudgetId = "";
     for (Iterator itrBudgetBenefit = mlBudget.iterator(); itrBudgetBenefit.hasNext();)
     {
    	 mapBudgetInfo = (Map) itrBudgetBenefit.next();
    	 strBudgetId  = (String)mapBudgetInfo.get(DomainConstants.SELECT_ID);
     }
     
     String hRef = "../common/emxIndentedTable.jsp?objectId="+ strBudgetId + "&projectId="+ projectId +"&program=emxProjectBudget:getBudgetActualTransactionSummaryList&table=PMCBudgetActualTransactionSummary&type=type_ActualTransaction&mode=view&selection=multiple&insertNewRow=true&connectionProgram=emxProjectBudget:addNewActualTransaction&header=emxProgramCentral.Budget.ActualTransaction.Heading&suiteKey=ProgramCentral&toolbar=PMCProjectBudgetActualTransactionToolbar,PMCActualTransactionFilter&postProcessJPO=emxTask:postProcessRefresh";
     hRef = hRef + "&PMCActualTransactionCurrencyFilter=" + strActualTransactionCurrencyFilter;
     hRef = hRef + "&preProcessJPO=emxProjectBudget:preProcessCheckForEdit";
     if(null!=strPreferredCurrency && !strPreferredCurrency.equals("As Entered") && !strPreferredCurrency.equals("") && strPreferredCurrency.equals(strActualTransactionCurrencyFilter)){
    	 hRef = hRef + "&editLink=true";
     }else{
    	 hRef = hRef + "&editLink=false";
     }    	 
     %>
	   	<script language="javascript">
		 var strUrl = "<%=hRef%>";   <%-- XSSOK --%>
	     var listActualTransactions = findFrame(getTopWindow(),"PMCBudgetActualTransactions");
	     listActualTransactions.location.href = strUrl;
		</script> 
	 <%
 }
 else if("deleteActualTransaction".equals(strMode)){
	 String[] actualTransactions = emxGetParameterValues(request,"emxTableRowId");
	 if(actualTransactions != null){
		 StringList strATList = new StringList();
		 for(int delCnt = 0; delCnt < actualTransactions.length; delCnt++){
			 java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(
					 actualTransactions[delCnt], "|");
			 String strATId = "";
	         if(strTokenizer.hasMoreElements()){
	        	  strATId = strTokenizer.nextToken();
	         }
	         
	         if(strATId != null && !"".equals(strATId)){
	        	 strATList.add(strATId);
	         }
		 }
		 if(strATList.size() > 0){
			 String[] strArr = new String[strATList.size()];
			 strATList.copyInto(strArr);
			 DomainObject.deleteObjects(context,strArr);
		 }
		 %>
		 <script language="JavaScript" type="text/javascript">
		    window.parent.location.href =  window.parent.location.href;
		 </script>
		 <%
	 }
 }
                
 else if("freezeBudget".equals(strMode)){
	 String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
     String strActualType=ProgramCentralConstants.EMPTY_STRING;
     String strActualID=ProgramCentralConstants.EMPTY_STRING;     
     String sErrMsg =ProgramCentralUtil.getPMCI18nString(context, "emxProjectBudget.Error.BudgetSelect", context.getSession().getLanguage());         
     String sErrMsgToFreeze =ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.ProjectBudget.ConfirmFreezeBudget", context.getSession().getLanguage()) ;
     strTableRowId = ProgramCentralUtil.parseTableRowId(context, strTableRowId);     
     if(strTableRowId == null || strTableRowId.length == 0 ){         
         %>
			<script language="JavaScript" type="text/javascript">
             alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
           </script>
        <% return;
 }
      StringList strSelectList = new StringList(); 
	 strSelectList.add(DomainObject.SELECT_TYPE);
	 strSelectList.add(DomainObject.SELECT_ID);
	 MapList mpList = DomainObject.getInfo(context,strTableRowId,strSelectList);   
  	 Iterator itr = mpList.iterator();
		while(itr.hasNext()) {
			Map strObjectId = (Map) itr.next();
			strActualType = (String)strObjectId.get(DomainConstants.SELECT_TYPE);
			strActualID = (String)strObjectId.get(DomainConstants.SELECT_ID);
     }
  if (!ProgramCentralConstants.TYPE_BUDGET.equalsIgnoreCase(strActualType)){
         %>
          <script language="JavaScript" type="text/javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
          </script>
          <%return;
     }
  else{
	  String postUrl = "../programcentral/emxProgramCentralBudgetUtil.jsp?budgetId="+XSSUtil.encodeForURL(context, strActualID)+"&mode=freezeBudgetPostAction";	
	  %>
		 <script language="JavaScript" type="text/javascript">         
	      var confirmMsg = false;
	       confirmMsg = confirm("<%=XSSUtil.encodeForJavaScript(context,sErrMsgToFreeze)%>");
	       if(confirmMsg){		    
		          var strUrl ="<%=postUrl%>";       <%-- XSSOK --%>     
			      var topFrame = findFrame(getTopWindow(), "PMCProjectBudget");			     		   		      
			       topFrame.window.parent.location.href= strUrl;
			   }		   
		    </script>
		   <%    
  }
 }
 else if(("freezeBudgetPostAction").equals(strMode)){     
	 String strSelectedBudget =  (String) emxGetParameter(request, "budgetId");
	 DomainObject BudgetObj = DomainObject.newInstance(context,strSelectedBudget);
	 BudgetObj.promote(context);
     %>
     <script language="JavaScript" type="text/javascript">
		    window.parent.location.href =  window.parent.location.href;
     </script>
     <%
 }else if("reportBudget".equals(strMode)){
     String parentOID = emxGetParameter(request, "parentOID");
	 parentOID = XSSUtil.encodeURLForServer(context, parentOID);
	 String filterCurrency = emxGetParameter(request, "PMCExpenseReportCurrencyFilter");
	 String strView =  emxGetParameter(request, "PMCProjectBudgetViewsReportFilter");
	 String strTimeLineView =  emxGetParameter(request, "PMCProjectBudgetReportFilterCommand");
	 String strReportBy =  emxGetParameter(request, "PMCProjectBudgetReportFiscalYearFilter");
	 String strDisplayView = emxGetParameter(request, "PMCProjectBudgetReportDisplayViewFilter");
	 String strNoOfIntervals = emxGetParameter(request, "PMCProjectBudgetReportIntervalFilter");
			 %>
	 <script language="javascript" type="text/javaScript">
        window.parent.location.href = "../common/emxIndentedTable.jsp?showRMB=true&selection=multiple&table=PMCProjectBudgetReportTable&suiteKey=ProgramCentral&toolbar=PMCProjectBudgetReportFilter&sortColumnName=none&header=emxProgramCentral.Budget.ReportFilter&program=emxProjectBudget:getTableProjectBudgetReportData&objectId=<%=XSSUtil.encodeForURL(context,projectId)%>&parentOID=<%=parentOID%>&PMCProjectBudgetViewsReportFilter=<%=XSSUtil.encodeForURL(context,strView)%>&PMCProjectBudgetReportFilterCommand=<%=XSSUtil.encodeForURL(context,strTimeLineView)%>&PMCProjectBudgetReportFiscalYearFilter=<%=XSSUtil.encodeForURL(context,strReportBy)%>&PMCExpenseReportCurrencyFilter=<%=XSSUtil.encodeForURL(context,filterCurrency)%>&PMCProjectBudgetReportDisplayViewFilter=<%=XSSUtil.encodeForURL(context,strDisplayView)%>&PMCProjectBudgetReportIntervalFilter=<%=XSSUtil.encodeForURL(context,strNoOfIntervals)%>";
 </script>
 <%
 }else if("editOption".equals(strMode)){
	 DomainObject BudgetObj = new DomainObject(projectId);
	 String SELECT_PROJECT_TYPE ="to["+Financials.RELATIONSHIP_PROJECT_FINANCIAL_ITEM+"].from.type";
	 String strProjectType = BudgetObj.getInfo(context,SELECT_PROJECT_TYPE);
	 if(DomainConstants.TYPE_PROJECT_SPACE.equals(strProjectType)){
             %>
     <script language="javascript" type="text/javaScript">
     getTopWindow().resizeTo(750,600);//because the full search windows is very wide
     getTopWindow().location.href = "../common/emxForm.jsp?form=PMCProjectBudgetPropertiesEditForm&toolbar=PMCProjectBudgetEditToolbar&suiteKey=ProgramCentral&objectId=<%=XSSUtil.encodeForURL(context,projectId)%>";
 </script>
 <%
	 }else{
		   %>
		     <script language="javascript" type="text/javaScript">
		     getTopWindow().resizeTo(750,600);//because the full search windows is very wide
		     getTopWindow().location.href = "../common/emxForm.jsp?form=PMCProjectTemplateBudgetPropertiesForm&toolbar=PMCProjectTemplateBudgetEditToolbar&suiteKey=ProgramCentral&objectId=<%=XSSUtil.encodeForURL(context,projectId)%>";
		 </script>
		 <%
	 }
 }else if("editProjectTemplateBudgetProperties".equals(strMode)){
	 String strSelectedBudgetID = "";
     
     strSelectedBudgetID = emxGetParameter(request,"objectId");

     %>
     <script language="javascript" type="text/javaScript">
         getTopWindow().resizeTo(750,600);//because the full search windows is very wide
         //
         // Note: Also sending objectId parameter to form pages for form page to get closed
         // correctly after edit process finished. This is Common Component defect's workaround,
         // due to time constraints.
         //added:di7
         getTopWindow().location.href = "../common/emxForm.jsp?type=type_Budget&policy=policy_FinanciaItem&form=PMCProjectTemplateBudgetEditForm&mode=edit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Budget.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBudgetID)%>&targetLocation=popup";
          </script>
	<%
 } 
// Added:1-Sep-2010:s2e:R210:PRG:IR-057886V6R2011x  
 else if (("displayCostItemProp").equals(strMode)){

     String strSelectedCostItemID = "";
    
     strSelectedCostItemID = emxGetParameter(request,"objectId");

     %>
     <script language="javascript" type="text/javaScript">
         getTopWindow().resizeTo(750,600);//because the full search windows is very wide
         //
         // Note: Also sending objectId parameter to form pages for form page to get closed
         // correctly after edit process finished. This is Common Component defect's workaround,
         // due to time constraints.
         //
         getTopWindow().location.href = "../common/emxForm.jsp?type=type_CostItem&policy=policy_FinanciaItem&form=PMCCostItemPropertiesForm&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Common.CostItemsDetails&objectId=<%=XSSUtil.encodeForURL(context,strSelectedCostItemID)%>";
          </script>
<%
 
 // End:1-Sep-2010:s2e:R210:PRG:IR-057886V6R2011x  
 } else if (("templateBudget").equals(strMode)){
	 String strLanguage = context.getSession().getLanguage();
     String headerValue = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Budget.ProjectTemplateBudget", strLanguage);
     headerValue=XSSUtil.encodeForURL(context,headerValue);
     
	 String projectTemplateBudgetURL = "../common/emxIndentedTable.jsp?table=PMCProjectTemplateBudgetTable"+
			                           "&toolbar=PMCProjectTemplateBudgetToolbar"+
			                           "&selection=multiple&header="+headerValue+
			                           "&massUpdate=false&program=emxProjectBudget:getTableTemplateBudgetData"+
			                           "&expandProgram=emxProjectBudget:getTableExpandChildTemplateBudgetData"+
			                           "&HelpMarker=emxhelpprojecttemplatebudgetlist&suiteKey=ProgramCentral&categoryTreeName=type_ProjectTemplate"+
			                           "&objectId="+projectId;
	 
	 DomainObject domainObject	=	DomainObject.newInstance(context,projectId);
	 
	 if (domainObject.getOwner(context).getName().equalsIgnoreCase(context.getUser())) {
	 	projectTemplateBudgetURL+="&editLink=true";
	 }
	 response.sendRedirect(projectTemplateBudgetURL);
	 
 } else if (("resourcePlanTemplate").equals(strMode)){
	 String strLanguage = context.getSession().getLanguage();
     String headerValue = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Common.ResourcePlanTemplate", strLanguage);
     headerValue=XSSUtil.encodeForURL(context,headerValue);
	 String resourcePlanTempalteURL = "../common/emxIndentedTable.jsp?table=PMCResourcePlanTemplateSummaryTable"+
			 						  "&freezePane=Name"+
			 						 "&suiteKey=ProgramCentral"+
			 						  "&HelpMarker=emxhelpresourceplantemplatelist&header="+headerValue+
			 						  "&program=emxResourcePlanTemplate:getTableResourcePlanTemplateData"+
			 						  "&selection=multiple&showRMB=false&toolbar=PMCResourcePlanTemplateToolBar&categoryTreeName=type_ProjectTemplate"+
			 						  "&postProcessJPO=emxResourceRequestBase:postProcessRefreshTable"+
     								  "&objectId="+projectId;

	Map paramMap = new HashMap(1);
    paramMap.put("objectId",projectId);
       
    boolean hasModifyAccess  = (boolean) JPO.invoke(context,"emxProjectTemplate", null, "isOwnerOrCoOwner", JPO.packArgs(paramMap), Boolean.class);
	if(hasModifyAccess){
		resourcePlanTempalteURL += "&editLink=true";
	}

	response.sendRedirect(resourcePlanTempalteURL);
 }else if ("redirectToMultipleOwnershipPage".equals(strMode)){
	 String objectId = emxGetParameter(request, "objectId");
	 DomainObject object = DomainObject.newInstance(context, objectId);
	 if(object.isKindOf(context, ProgramCentralConstants.TYPE_PROJECT_SPACE)){
			ProjectSpace project = new ProjectSpace(objectId);
			StringList selects = new StringList();
			selects.add(ProgramCentralConstants.SELECT_ID);
			MapList financialInfoList = null;
			
			try{
				ProgramCentralUtil.pushUserContext(context);	
				financialInfoList = FinancialItem.getFinancialBudgetOrBenefit(context, project, 
						selects, ProgramCentralConstants.TYPE_BUDGET);
			}finally{
				ProgramCentralUtil.popUserContext(context);
			}
			if(null!=financialInfoList){
				Map financialInfo = (Map) financialInfoList.get(0);
				objectId = (String)financialInfo.get(ProgramCentralConstants.SELECT_ID);
			}
 }
	Map multipleownershipAction = new HashMap();
	multipleownershipAction = UIMenu.getCommand(context,"DomainAccessTreeCategory");
	String strHref = (String) multipleownershipAction.get("href");
	strHref = strHref.replace("${COMMON_DIR}/", "../common/");
	strHref = strHref.replace("DomainAccessToolBar", "PMCBudgetMOASummaryToolBar");
	strHref += "&objectId=" + XSSUtil.encodeForURL(context, objectId);

	%>
	   	<script language="javascript">
		 var strUrl = "<%=strHref%>";   <%-- XSSOK --%>
	     var multipleOwnership = findFrame(getTopWindow(),"PMCMultipleOwnershipAccessCommandForBudget");
	     multipleOwnership.location.href = strUrl;
		</script> 
	 <%

 }else if ("addMemberToMultipleOwnershipPage".equals(strMode)){
	String objectId = emxGetParameter(request, "objectId");
	
	Map addMemberAction = new HashMap();
	addMemberAction = UIMenu.getCommand(context,"DomainAccessAddMember");
	String strHref = (String) addMemberAction.get("href");
	
	if(strHref != null && strHref.contains("&submitURL=")){
		strHref = FrameworkUtil.findAndReplace(strHref, "&submitURL=${COMMON_DIR}/emxDomainAccessProcess.jsp&cmdName=addPerson", "&submitURL=../programcentral/emxProjectManagementUtil.jsp?mode=addMemberToBudget");
	}
	strHref = strHref.replace("${COMMON_DIR}/", "../common/");
	strHref = strHref.replace("excludeOIDprogram=emxDomainAccess:getExcludePersonList", "excludeOIDprogram=emxProjectBudgetBase:getExcludePersonList");
	strHref += "&objectId=" + XSSUtil.encodeForURL(context, objectId);
		
	%>
	    <script language="javascript">
	  		 var url = "<%=strHref%>";
	  		 showModalDialog(url);
	    </script> 
    <%
	 
 }else{
            throw new IllegalArgumentException(strMode);
 }
}catch (Exception e){
                bFlag = true;
                e.printStackTrace();
                session.putValue("error.message", e.getMessage());
            }

        %>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
