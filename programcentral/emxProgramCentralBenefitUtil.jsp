

<%-- Common Includes --%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.common.Company"%>
<%@page import="com.matrixone.apps.program.BenefitItem"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.framework.taglib.XSSEncodeForURLTag"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.program.Financials"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="matrix.util.StringList"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>


<%boolean bFlag = false;
            try {
                //gets the mode passed
                String languageStr = context.getSession().getLanguage();
                String strMode = emxGetParameter(request, "mode");
                strMode = XSSUtil.encodeURLForServer(context, strMode);
                String projectId = emxGetParameter(request, "objectId");
                projectId = XSSUtil.encodeURLForServer(context, projectId);
                String strReturnResult = "";
                StringBuffer sBuff = new StringBuffer();
                String strSubMode = emxGetParameter(request, "submode");
                
              //[ADDED::PRG:RG6:Jan 5, 2011:R211:IR-075617V6R2012:When invoked from RMB project id is coming as current obj id]
                String isFromRMB = emxGetParameter(request, "isFromRMB");
               if(null != isFromRMB && "true".equalsIgnoreCase(isFromRMB.trim())){
                   String strRootObjectId = emxGetParameter(request, "rootObjectId");
                   if( null != strRootObjectId && !"Null".equalsIgnoreCase(strRootObjectId.trim()) && !"".equalsIgnoreCase(strRootObjectId.trim())){
                       projectId = strRootObjectId;
                   }   
               }
               // [ADDED::PRG:RG6:Jan 5, 2011:IR-075617V6R2012:R211::End]   

 
 if(("addBenefitItem").equals(strMode)){
          String strComapnyId = PersonUtil.getUserCompanyId(context);
          %>
             <script language="javascript" type="text/javaScript">
                 getTopWindow().resizeTo(700,600);//because the full search windows is very wide
                 //
                 // Note: Also sending objectId parameter to form pages for form page to get closed
                 // correctly after edit process finished. This is Common Component defect's workaround,
                 // due to time constraints.
                 //
	             getTopWindow().location.href = "../common/emxIndentedTable.jsp?table=PMCProjectBenefitAddBenefitTable&selection=multiple&suiteKey=ProgramCentral&HelpMarker=emxhelpcostcategoryadd&header=emxProgramCentral.ProjectBenefit.Command.AddBenefitItem&program=emxBenefitItem:getTableBenefitCategoryItemData&expandProgram=emxBenefitItem:getExpandTableBenefitCategoryItemData&objectId=<%=XSSUtil.encodeForURL(context,strComapnyId)%>&cancelLabel=emxProgramCentral.Button.Cancel&submitLabel=emxFramework.Button.Submit&submitURL=../programcentral/emxProgramCentralBenefitUtil.jsp?mode=connectBenefitItem&ProjectId=<%=XSSUtil.encodeForURL(context,projectId)%>";
                  </script>
    <%
         }
 else if(("connectBenefitItem").equals(strMode)){
     String strProjectId = emxGetParameter(request, "ProjectId");
     String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
     String strTokenId = "";
     String strSelectedCostItem = "";
     StringList slSelectedCostItem = new StringList();
     StringList slSelectedCostItemName = new StringList();
     String strSelectedCostCategoryId = "";
     String strSelectedCostCategory = "";
     BenefitItem benefitItem = new BenefitItem();
     DomainObject dmoProject = DomainObject.newInstance(context, strProjectId);
     String strBenefit = benefitItem.getBudgetorBenefitCreated(context, ProgramCentralConstants.TYPE_BENEFIT, dmoProject);
     benefitItem.setId(strBenefit);
     String selectItemNames      = "from["+ProgramCentralConstants.RELATIONSHIP_FINANCIAL_ITEMS+"].to.name";
     String selectItemRevisions  = "from["+ProgramCentralConstants.RELATIONSHIP_FINANCIAL_ITEMS+"].to.revision";
     
     StringList selectables = new StringList();
     DomainObject.MULTI_VALUE_LIST.add(selectItemNames);
     DomainObject.MULTI_VALUE_LIST.add(selectItemRevisions);
     selectables.add(selectItemNames);
     selectables.add(selectItemRevisions);
     
     Map slBeneItemInfo = benefitItem.getInfo(context, selectables);
     StringList slItemNames = (StringList)slBeneItemInfo.get(selectItemNames);
     StringList slItemRevisions = (StringList)slBeneItemInfo.get(selectItemRevisions);
     int size = slItemNames != null ? slItemNames.size() : 0;
     StringList slBenefitItemNamRevInfo = new StringList(); 
     for(int i=0; i<size; i++){
    	 String itemName = (String)slItemNames.get(i);
    	 String itemRevision = (String)slItemRevisions.get(i);
    	 StringList slRevObjects = FrameworkUtil.splitString(itemRevision, "-");
    	 String sCategoryName = (String)slRevObjects.get(1);
    	 slBenefitItemNamRevInfo.add(itemName+"~"+sCategoryName);
     }
     
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
    	if(!slBenefitItemNamRevInfo.contains(strSelectedCostItemName+"~"+strSelectedCostCategory)){
        slSelectedCostItem.add(strSelectedCostItem);
        slSelectedCostItemName.add(strSelectedCostItemName);
        slSelectedCostCategory.add(strSelectedCostCategory);
    	}
}else{
     Map mapCostCategory = null; 
      for (Iterator iterCostCat = mapList.iterator(); iterCostCat .hasNext();)
      {
          mapCostCategory = (Map) iterCostCat.next();
          String strSelectedCostItem1 = (String)mapCostCategory.get(DomainConstants.SELECT_ID);
          String strSelectedCostItemName1 = (String)mapCostCategory.get(DomainConstants.SELECT_NAME);
          if(!slBenefitItemNamRevInfo.contains(strSelectedCostItemName1+"~"+strSelectedCostItemName)){
          slSelectedCostItem.add(strSelectedCostItem1);
          slSelectedCostItemName.add(strSelectedCostItemName1);
          slSelectedCostCategory.add(strSelectedCostItemName);
      }
}
 }
 }
    
    //
    benefitItem.connectBenefitItem(context, strProjectId,slSelectedCostItem,slSelectedCostItemName,slSelectedCostCategory);
    %>
    <script language="JavaScript" type="text/javascript">
    getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().window.close();
    </script>
    <%
 }
 else if("freezeBenefit".equals(strMode)){
     String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
     String strActualType=ProgramCentralConstants.EMPTY_STRING;
     String strActualID=ProgramCentralConstants.EMPTY_STRING;
     String sErrMsg =ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.ProjectBenefit.SelectBenefit", context.getSession().getLanguage());
     String sErrMsgToFreeze =ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.ProjectBenefit.ConfirmFreezeBenefit", context.getSession().getLanguage());
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
	if (!ProgramCentralConstants.TYPE_BENEFIT.equalsIgnoreCase(strActualType)){
	 %>
	 <script language="JavaScript" type="text/javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
	    </script>
	   <%return;
	  } 
  else{
	  String postUrl = "../programcentral/emxProgramCentralBenefitUtil.jsp?benefitId="+XSSUtil.encodeForURL(context, strActualID)+"&mode=freezeBenefitPostAction";	
	  %>
		 <script language="JavaScript" type="text/javascript">          
	      var confirmMsg = false;
	       confirmMsg = confirm("<%=XSSUtil.encodeForJavaScript(context,sErrMsgToFreeze)%>");
	       if(confirmMsg){		    
		          var strUrl ="<%=postUrl%>";      <%--XSSOK --%>      
		          document.location.href = strUrl;
             }
		    </script>
		   <%    
         }        
 }
 else if(("freezeBenefitPostAction").equals(strMode)){     
	 String benefitId =  (String) emxGetParameter(request, "benefitId");
	 DomainObject dmoBenefitObj = new DomainObject(benefitId);
     dmoBenefitObj.promote(context);
     %>
     <script language="JavaScript" type="text/javascript">
         //window.parent.location.href =  window.parent.location.href;
         var topFrame = findFrame(getTopWindow(), "PMCProjectBenefit");	
		 topFrame.location.href = topFrame.location.href;
     </script>
     <%
 }
 else if(("editProjectBenefitProperties").equals(strMode)){

//   Getting the table row ids of the selected objects for clonig the request
     String[] strTableRowId = emxGetParameterValues(request,"emxTableRowId");
     String strSelectedBenefitID =ProgramCentralConstants.EMPTY_STRING; 
     String strActualType=ProgramCentralConstants.EMPTY_STRING;
     String strActualID=ProgramCentralConstants.EMPTY_STRING;   
     String sErrMsg =ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.ProjectBenefit.SelectBenefit", context.getSession().getLanguage());
     strTableRowId = ProgramCentralUtil.parseTableRowId(context, strTableRowId);
     if(strTableRowId == null || strTableRowId.length == 0 ){         
         %>
 <script language="JavaScript" type="text/javascript">
                                 alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                             </script>
 <%return;
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
  if (!ProgramCentralConstants.TYPE_BENEFIT.equalsIgnoreCase(strActualType)){
                      %>
                      <script language="JavaScript" type="text/javascript">
                                 alert("<%=XSSUtil.encodeForJavaScript(context,sErrMsg)%>");
                             </script>
	   <%return;
                  }
                 strSelectedBenefitID = strActualID ;                 
  
     %>
     <script language="javascript" type="text/javascript">
         url = "../common/emxForm.jsp?type=type_Benefit&policy=policy_FinanciaItem&form=PMCProjectBenefitPropertyPage&mode=edit&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralBenefitUtil.jsp?mode=refreshStructure&suiteKey=ProgramCentral&HelpMarker=emxhelpbenefitedit&formHeader=emxProgramCentral.ProjectBenefit.Command.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBenefitID)%>";
         getTopWindow().showSlideInDialog(url,true);
          </script>
<%
 }
 else if(("editBenefitProperties").equals(strMode)){
     String strSelectedBenefitID = "";
     
     strSelectedBenefitID = emxGetParameter(request,"objectId");

     %>
     <script language="javascript" type="text/javaScript">
         url = "../common/emxForm.jsp?type=type_Benefit&policy=policy_FinanciaItem&form=PMCProjectBenefitPropertyPage&mode=edit&submitAction=doNothing&postProcessURL=../programcentral/emxProgramCentralBenefitUtil.jsp?mode=refreshStructure&suiteKey=ProgramCentral&HelpMarker=emxhelpbenefitedit&formHeader=emxProgramCentral.ProjectBenefit.Command.EditLink&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBenefitID)%>";
         getTopWindow().showSlideInDialog(url,true);
          </script>
<%
 }else if (("refreshStructure").equals(strMode)){
     
     %>
     <script language="javascript" type="text/javaScript">
     var topFrame = findFrame(getTopWindow(), "PMCProjectBenefit");	
     topFrame.location.href = topFrame.location.href; 
     </script>

	<% 
 }
 
 else if("editOption".equals(strMode)){
           %>
             <script language="javascript" type="text/javaScript">
             getTopWindow().resizeTo(750,600);//because the full search windows is very wide
             getTopWindow().location.href = "../common/emxForm.jsp?form=PMCProjectBenefitPropertyPage&toolbar=PMCProjectBenefitEditToolbar&suiteKey=ProgramCentral&objectId=<%=XSSUtil.encodeForURL(context,projectId)%>";
         </script>
         <%
 }
 else if (("displayBenefitItem").equals(strMode)){

     String strSelectedBenefitItemID = "";
    
     strSelectedBenefitItemID = emxGetParameter(request,"objectId");

     %>
     <script language="javascript" type="text/javaScript">
         getTopWindow().resizeTo(750,600);//because the full search windows is very wide
         //
         // Note: Also sending objectId parameter to form pages for form page to get closed
         // correctly after edit process finished. This is Common Component defect's workaround,
         // due to time constraints.
         //
         getTopWindow().location.href = "../common/emxForm.jsp?type=type_BenefitItem&policy=policy_FinanciaItem&form=PMCBenefitItemPropertiesForm&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Common.BenefitItemsDetails&objectId=<%=XSSUtil.encodeForURL(context,strSelectedBenefitItemID)%>";
          </script>
<%
 
 }
 else if("Filter".equalsIgnoreCase(strMode)){                
     String objId = emxGetParameter(request,"objectId");
     String jsTreeID = emxGetParameter(request,"jsTreeID");
     String strProjectBudgetCurrencyFilter = emxGetParameter(request,"PMCProjectBudgetCurrencyFilter");
     String strProjectBudgetIntervalFilter = emxGetParameter(request,"PMCProjectBudgetIntervalFilter"); 
     String strProjectBudgetViewsFilter = emxGetParameter(request,"PMCProjectBudgetViewsFilter"); 
     String strProjectBudgetFiscalYearFilter = emxGetParameter(request,"PMCProjectBudgetFiscalYearFilter"); 
     String strProjectBudgetDisplayViewFilter = emxGetParameter(request,"PMCProjectBudgetDisplayViewFilter");     
     String portal = emxGetParameter(request,"portal");
     boolean isEditable = true; 
     String strURL = "../common/emxIndentedTable.jsp?expandProgram=emxProjectBudget:getTableExpandChildBudgetData"
             +"&otherTollbarParams=projectID,isStructure"
             +"&table=PMCProjectBudgetPlanTable&isStructure=true&treeLabel=TestBudget"
             +"&showPageHeader=false&header=emxProgramCentral.Budget.ProjectBudget"
             +"&portalMode=true&emxSuiteDirectory=programcentral"
             +"&suiteKey=ProgramCentral&SuiteDirectory=programcentral&HelpMarker=emxhelpprojectbudgetlist"
             +"&StringResourceFileId=emxProgramCentralStringResource&hideHeader=true&objectId=";
     strURL = strURL + objId;
     strURL = strURL + "&projectID=" +objId;
     strURL = strURL + "&parentOID=" +objId;
     strURL = strURL + "&jsTreeID=" +jsTreeID;
     strURL = strURL + "&PMCProjectBudgetCurrencyFilter=" +strProjectBudgetCurrencyFilter;
     strURL = strURL + "&PMCProjectBudgetIntervalFilter=" +strProjectBudgetIntervalFilter;       
     strURL = strURL + "&PMCProjectBudgetViewsFilter=" +strProjectBudgetViewsFilter; 
     strURL = strURL + "&PMCProjectBudgetFiscalYearFilter=" +strProjectBudgetFiscalYearFilter; 
     strURL = strURL + "&PMCProjectBudgetDisplayViewFilter=" +strProjectBudgetDisplayViewFilter; 
     strURL = strURL + "&emxExpandFilter=3";
     strURL = strURL + "&customize=false";
     strURL = strURL + "&selection=multiple";
     strURL = strURL + "&portal=" +  portal;
     String strPreferredCurrency = PersonUtil.getCurrency(context);
     if(ProgramCentralUtil.isNotNullString(strProjectBudgetCurrencyFilter) &&
             !strProjectBudgetCurrencyFilter.equals(strPreferredCurrency)){
         isEditable = false;
     }
     else if(ProgramCentralUtil.isNotNullString(objId)){
         DomainObject project = DomainObject.newInstance(context,objId);
         StringList slSelects = new StringList(1);
         slSelects.add(ProgramCentralConstants.SELECT_CURRENT);
         MapList mlBudget = project.getRelatedObjects(context,
                 ProgramCentralConstants.RELATIONSHIP_PROJECT_FINANCIAL_ITEM, 
                 ProgramCentralConstants.TYPE_BUDGET,
                 slSelects,      // bus selects
                 null,       // relationshipSelects
                 false,      // getTo
                 true,       // getFrom
                 (short) 1,  // recurseToLevel
                 "",        // objectWhere
                 null,      // relationshipWhere
                 0);         
        if(mlBudget != null){
            Map budgetInfo = (Map)mlBudget.get(0);
            String current = (String)budgetInfo.get(ProgramCentralConstants.SELECT_CURRENT);
            if(current.equals("Plan Frozen") && 
                    ProgramCentralUtil.isNotNullString(strProjectBudgetViewsFilter) && 
                            !strProjectBudgetViewsFilter.equals("Estimate View")){
                isEditable = false;     
            }
        } 
     }
     
     //if(ProgramCentralUtil.isNullString(portal) || "PMCProjectBudgetPortal".equals(portal)){
	 if(ProgramCentralUtil.isNullString(portal) || "PMCFinancials".equals(portal)){
         strURL = strURL + "&portalCmdName=PMCProjectBudget";
         strURL = strURL + "&toolbar=PMCProjectBudgetToolbar,PMCProjectBudgetFilter";    
     }else{
         strURL = strURL + "&portalCmdName=PMCProjectBudgetInDashboard";
         strURL = strURL + "&toolbar=PMCProjectBudgetFilter";    
         isEditable = false;
     }
     strURL = strURL + "&editLink=" + isEditable;
     strURL = XSSUtil.encodeURLForServer(context, strURL);
     %>
     <script language="javascript">
		var strUrl = "<%=strURL%>";
        window.parent.location.href = strUrl;
     </script>
 <%              
 }
 else if("benifitFilter".equalsIgnoreCase(strMode)){                
     String objId = emxGetParameter(request,"objectId");
     String projectID = emxGetParameter(request,"projectID");
     String parentOID = emxGetParameter(request,"parentOID");
     String jsTreeID = emxGetParameter(request,"jsTreeID");
     
     String strProjectBenifitCurrencyFilter = emxGetParameter(request,"PMCProjectBenefitCurrencyFilter");
     String strProjectBenefitIntervalFilter = emxGetParameter(request,"PMCProjectBenefitIntervalFilter"); 
     String strProjectBenefitViewsFilter = emxGetParameter(request,"PMCProjectBenefitViewsFilter"); 
     String portal = emxGetParameter(request,"portal");
     String strURL = "../common/emxIndentedTable.jsp?table=PMCProjectBenefitSummaryTable&freezePane=Name&selection=multiple&hideHeader=true&header=emxProgramCentral.ProjectBenefit.Benefit&expandProgram=emxBenefitItem:getTableExpandChildProjectBenefitData&postProcessJPO=emxBenefitItem:postProcessRefresh&HelpMarker=emxhelpfinancialitemsummary&emxExpandFilter=3&suiteKey=ProgramCentral&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource";
     strURL = strURL + "&objectId=" +objId;
     strURL = strURL + "&projectID=" +projectID;
     //strURL = strURL + "&parentOID=" +parentOID;
     strURL = strURL + "&jsTreeID=" +jsTreeID;
     strURL = strURL + "&PMCProjectBenefitCurrencyFilter=" +strProjectBenifitCurrencyFilter;
     strURL = strURL + "&PMCProjectBenefitIntervalFilter=" +strProjectBenefitIntervalFilter;       
     strURL = strURL + "&PMCProjectBenefitViewsFilter=" +strProjectBenefitViewsFilter; 
     strURL = strURL + "&emxExpandFilter=3";
     strURL = strURL + "&customize=false";
     strURL = strURL + "&selection=multiple";
     strURL = strURL + "&portal=" +  portal;
     boolean isEditable = true; 
 
     String strPreferredCurrency = PersonUtil.getCurrency(context);
     if(ProgramCentralUtil.isNotNullString(strProjectBenifitCurrencyFilter) &&
             !strProjectBenifitCurrencyFilter.equals(strPreferredCurrency)){
         isEditable = false;
     }
     else if(ProgramCentralUtil.isNotNullString(objId)){
         DomainObject project = DomainObject.newInstance(context,objId);
         StringList slSelects = new StringList(1);
         slSelects.add(ProgramCentralConstants.SELECT_CURRENT);
         MapList mlBenefit = project.getRelatedObjects(context,
                 ProgramCentralConstants.RELATIONSHIP_PROJECT_FINANCIAL_ITEM, 
                 ProgramCentralConstants.TYPE_BENEFIT,
                 slSelects,      // bus selects
                 null,       // relationshipSelects
                 false,      // getTo
                 true,       // getFrom
                 (short) 1,  // recurseToLevel
                 "",        // objectWhere
                 null,      // relationshipWhere
                 0);         
        if(mlBenefit != null){
            Map budgetInfo = (Map)mlBenefit.get(0);
            String current = (String)budgetInfo.get(ProgramCentralConstants.SELECT_CURRENT);
            if(current.equals("Plan Frozen") && 
                    ProgramCentralUtil.isNotNullString(strProjectBenefitViewsFilter) && 
                    strProjectBenefitViewsFilter.equals("Plan View")){
                isEditable = false;     
            }
        } 
     }
     
     if(ProgramCentralUtil.isNullString(portal) || "PMCFinancials".equals(portal)){
         strURL = strURL + "&portalCmdName=PMCProjectBenefit";
         strURL = strURL + "&toolbar=PMCProjectBenefitOperationsToolBar,PMCProjectBenefitFilter";    
     }else{
         strURL = strURL + "&portalCmdName=PMCProjectBenefitInDashboard";
         strURL = strURL + "&toolbar=PMCProjectBenefitFilter";   
         isEditable = false;
     }
    if(isEditable)
        strURL = strURL + "&editLink=true";
    else
        strURL = strURL + "&editLink=false";
     
    objId = XSSUtil.encodeForURL(context,objId);
     strURL = strURL + "&objectId=" +XSSUtil.encodeForURL(context,objId);
    
    portal  = XSSUtil.encodeForURL(context,portal);
    strURL = strURL + "&portal=" +  XSSUtil.encodeForURL(context,portal);
    
    projectID = XSSUtil.encodeForURL(context,projectID);
     strURL = strURL + "&projectID=" +XSSUtil.encodeForURL(context,projectID);
    
    parentOID = XSSUtil.encodeForURL(context,parentOID);
     strURL = strURL + "&parentOID=" +XSSUtil.encodeForURL(context, parentOID);
    
    jsTreeID = XSSUtil.encodeForURL(context,jsTreeID);
     strURL = strURL + "&jsTreeID=" +XSSUtil.encodeForURL(context, jsTreeID);
    
    strProjectBenifitCurrencyFilter = XSSUtil.encodeForURL(context,strProjectBenifitCurrencyFilter);
     strURL = strURL + "&PMCProjectBenefitCurrencyFilter=" +strProjectBenifitCurrencyFilter;
    
    strProjectBenefitIntervalFilter = XSSUtil.encodeForURL(context,strProjectBenefitIntervalFilter);
     strURL = strURL + "&PMCProjectBenefitIntervalFilter=" +strProjectBenefitIntervalFilter;       
    
    strProjectBenefitViewsFilter = XSSUtil.encodeForURL(context,strProjectBenefitViewsFilter);
     strURL = strURL + "&PMCProjectBenefitViewsFilter=" +strProjectBenefitViewsFilter; 
 
   %>
     <script language="javascript">
     var strUrl = "<%=strURL%>";   <%--XSSOK --%>
     window.parent.location.href = strUrl;
     </script>
 <%              
 }
  
 else if("ActualTransactions".equalsIgnoreCase(strMode)){     
     String strBudgetId = emxGetParameter(request, "objectId");
     String strProjectId = emxGetParameter(request, "projectId");
     String strPreferredCurrency = PersonUtil.getCurrency(context); 
     String strActualTransactionCurrencyFilter = emxGetParameter(request,"PMCActualTransactionCurrencyFilter");
     if(ProgramCentralUtil.isNullString(strActualTransactionCurrencyFilter))
         strActualTransactionCurrencyFilter = strPreferredCurrency;
     String strURL = "../common/emxIndentedTable.jsp?table=PMCBudgetActualTransactionSummary";
     strURL = strURL + "&projectId=" + XSSUtil.encodeForURL(context,strProjectId);
     strURL = strURL + "&objectId=" + XSSUtil.encodeForURL(context,strBudgetId);
     strURL = strURL + "&program=emxProjectBudget:getBudgetActualTransactionSummaryList";
     strURL = strURL + "&type=type_ActualTransaction";
     strURL = strURL + "&mode=view";
     strURL = strURL + "&selection=multiple";
     strURL = strURL + "&connectionProgram=emxProjectBudget:addNewActualTransaction";
     strURL = strURL + "&header=emxProgramCentral.Budget.ActualTransaction.Heading";
     strURL = strURL + "&suiteKey=ProgramCentral";
     strURL = strURL + "&toolbar=PMCProjectBudgetActualTransactionToolbar,PMCActualTransactionFilter";
     strURL = strURL + "&postProcessJPO=emxTask:postProcessRefresh";
     strURL = strURL + "&PMCActualTransactionCurrencyFilter=" + strActualTransactionCurrencyFilter;
 
     boolean isEditable = true; 
     if(strPreferredCurrency.equals(strActualTransactionCurrencyFilter)){
         strURL = strURL + "&editLink=true";
         strURL = strURL + "&insertNewRow=true";
     }else{
         strURL = strURL + "&editLink=false";
     }
     %>
     <script language="javascript">
     var strUrl = "<%=strURL%>";   <%--XSSOK --%>
     window.parent.location.href = strUrl;
     </script>
 <%              

 }else if ("redirectToMultipleOwnershipPageForBenefit".equals(strMode)){
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
						selects, ProgramCentralConstants.TYPE_BENEFIT);
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
	strHref += "&objectId=" + XSSUtil.encodeForURL(context, objectId);
  
	%>
	   	<script language="javascript">
		 var strUrl = "<%=strHref%>";  <%--XSSOK --%>
	     var multipleOwnership = findFrame(getTopWindow(),"PMCProjectBenefitMultipleOwnershipAccessCommand");
	     multipleOwnership.location.href = strUrl;
		</script> 
	 <%

 }else
    {
            throw new IllegalArgumentException(strMode);
    }
            }
            catch (Exception e)
            {
                bFlag = true;
                e.printStackTrace();
                session.putValue("error.message", e.getMessage());
            }

        %>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
