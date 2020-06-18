<%--  SpecificationStructureAddExisting.jsp  --%>
<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%-- @quickreview ZUD DJH 19 June 2013  IR-234827V6R2014x An error message is not translated into Japanese --%>
<%-- @quickreview T25 DJH 13:10:18 : HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. --%>
<%-- @quickreview ZUD DJH 13:11:07 : NHIV6R-041268: Added model is not getting searched when user tries to remove it from requirement specification structure. Removal of %26 with & --%>
<%-- @quickreview LX6     IR-348544-3DEXPERIENCER2016x Structure Display page controls & commands are in active state when Quick Chart is invoked and behavior of it is inconsistent with various commands. --%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
try
{
    String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String timeStamp = (String)requestMap.get("timeStamp");
    String objectId = (String)requestMap.get("objectId");
    String addType = (String)requestMap.get("addType");
    String isFromRMB = (String)requestMap.get("isFromRMB");
    String mode = (String)requestMap.get("mode");

    i18nNow i18nNowInstance = new i18nNow();
    String strLocale = context.getSession().getLanguage();
    String tableRowId = "|" + objectId + "||0";
    String searchTypes = null;
    String searchTable = null;
    String excludeProg = null;
    String includeProg = null;
    String submitHRef = null;
    String strToolbar = null;
    String strRelationship = null;
    String strExpandProgram = null;
    String strDirection = null;
    String modeTypes = null;
    String strSelection = "multiple";
    String strShowSavedQuery = "True";
    String strSearchCollectionEnabled = "True";
    String strCancelLabel = "emxRequirements.Button.Cancel";
    boolean showCancelButton = true;
    boolean showInitialResults = false;
 
    String strShowClipboard = "True";
    String strPrinterFriendly = "True";
    String strObjectCompare = "True";
    //String strCustomize = "True";
    String strExport = "True";
    String strMultiColumnSort = "True";
    String strTriggerValidation = "True";
    String strExpandLevelFilter = "True";
    String strAutoFilter = "True";
    StringList strList = new StringList();
	String objId = "";    
	String objectIdList =  "";

    // If a single row is selected, use it as the target ID...
    if (tableRowIds != null)
    {
        String lang = request.getHeader("Accept-Language");
        String resc = "emxFrameworkStringResource";

        if (tableRowIds.length == 0 )
        {
            String mess = EnoviaResourceBundle.getProperty(context, resc, context.getLocale(), "emxFramework.Common.PleaseSelectitem");
            throw (new Exception(mess));
        }
        if(addType.equals("Model") || addType.equals("RemoveModel"))
        {
        	
        	if(tableRowIds != null && tableRowIds.length > 0) 
            {   
               for(int i = 0; i < tableRowIds.length ; i++) 
               {                     
                  if(tableRowIds[i].indexOf("|") != -1)
                  {
                     strList = FrameworkUtil.split(tableRowIds[i], "|");
                     if (strList.size() == 3)
                     {
                    	 objId = (String)strList.get(0);
                         
                     }else
                     {
                    	 objId = (String)strList.get(1);
                     }         
                  }else
                  {
                	  objId = tableRowIds[i];
                  }
                 //  objectIdList.add(objId);      
                  objectIdList = objectIdList + objId;
                  objectIdList = objectIdList + "|";
                }      
             }
        }
        else if (tableRowIds.length > 1)
        {
            String mess = EnoviaResourceBundle.getProperty(context, resc, context.getLocale(), "emxFramework.Common.PleaseSelectOneItemOnly");
            throw (new Exception(mess));
        }

        tableRowId = tableRowIds[0];
    }
    
    // ++ HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy. ++
    String emxTableRowID = emxGetParameter(request, "emxTableRowId");
    String[] itemsInRow = emxTableRowID.split("[|]", -1);
    String selectedObjId = itemsInRow[1];
	BusinessObject busObj = new BusinessObject(selectedObjId);
	busObj.open(context);
	String objType = busObj.getTypeName();
	busObj.close(context);
	
    if(objType.equalsIgnoreCase("Requirement Proxy") && (addType.equalsIgnoreCase("Model") || addType.equalsIgnoreCase("RemoveModel")))
    {
    	//the object is leaf object.
    	throw new Exception("InvalidSpecTreeSelectionReqProxy");
    }
    // -- HAT1 ZUD: OSLC Disble action cmds for Requirement Proxy.-- 
    
	if("ensureSpecStructureSelection".equalsIgnoreCase(mode))
	{
		String emxTableRowId = emxGetParameter(request, "emxTableRowId");
    	String[] items = emxTableRowId.split("[|]", -1);
    	String oid = items[1];
    	String pid = items[2];
    	if(RequirementsUtil.isRequirement(context, oid) && 
    			(pid.trim().length() == 0 || RequirementsUtil.isRequirement(context, pid)))
    	{
    		throw new Exception("InvalidSpecTreeSelection");
    	}
	}
    if (addType.equals("Chapter"))
    {
        searchTypes = "type_Chapter";
        searchTable = "RMTGlobalSearchBasicsTable";
        // ZUD Changes to exclude Ancestor chapter to be listed in Search Window 
        excludeProg = "emxSpecificationStructure:excludeBranchChapters";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddToStructure&relName=relationship_SpecificationStructure&specStructId=" + tableRowId + "&isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Comment"))
    {
        searchTypes = "type_Comment";
        searchTable = "RMTGlobalSearchBasicsTable";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddToStructure&relName=relationship_SpecificationStructure&specStructId=" + tableRowId + "&isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Requirement"))
    {
        // When adding an existing Requirement to a Specification Structure from the search results, the selected rowId
        // is the existing object to be added, not the location of the new object as it is in Create Requirement command.
        // So we need to pass the originally selected rowId from the structure as the parent objectId to the submitted url:

        searchTypes = "type_Requirement";
        searchTable = "RMTGlobalSearchRequirementsTable";
        //excludeProg = "emxSpecificationStructure:excludeBranchRequirements";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddToStructure&relName=relationship_SpecificationStructure&specStructId=" + tableRowId + "&isFromRMB=" + isFromRMB;
        modeTypes = "CONTAINED_IN_PRODUCTS,CONTAINED_IN_SPECIFICATIONS";
    }
    else if (addType.equals("SubRequirement"))
    {
        searchTypes = "type_Requirement";
        searchTable = "RMTGlobalSearchRequirementsTable";
        excludeProg = "emxRequirementSearch:excludeParentRequirements";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddToStructure&relName=relationship_RequirementBreakdown&from=true&specStructId=" + tableRowId +  "&isFromRMB=" + isFromRMB;
        modeTypes = "CONTAINED_IN_PRODUCTS,CONTAINED_IN_SPECIFICATIONS";
    }
    else if (addType.equals("DerivedRequirement"))
    {
        searchTypes = "type_Requirement";
        searchTable = "RMTGlobalSearchRequirementsTable";
        excludeProg = "emxRequirementSearch:excludeParentRequirements";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddToStructure&relName=relationship_DerivedRequirement&from=true&specStructId=" + tableRowId +  "&isFromRMB=" + isFromRMB;
        modeTypes = "CONTAINED_IN_PRODUCTS,CONTAINED_IN_SPECIFICATIONS";
    }
    //Start V6R2010xHF1
    else if (addType.equals("SubDerivedRequirement"))
    {
        searchTypes = "type_Requirement";
        searchTable = "RMTCreateAndLinkExistingSpecAndRequirementSearchTable";
        strSelection = "single";
        strCancelLabel = "emxRequirements.Button.Close";
        strToolbar = "RMTAddExistingSubDerivedRequirementsToolbar";
        strShowSavedQuery = null;
        strSearchCollectionEnabled = null;
        excludeProg = "emxRequirementSearch:excludeParentRequirements";
      //  excludeProg = "emxSpecificationStructure:excludeAllocatedRequirements";
        strExpandProgram = "emxSpecificationStructure:expandTreeWithAllRequirements";
        strShowClipboard = "False";
        strPrinterFriendly = "False";
        strObjectCompare = "False";
        // strCustomize = "False";
        strExport = "False";
        strMultiColumnSort = "False";
        strTriggerValidation = "False";
        strExpandLevelFilter = "False";
        strAutoFilter = "False";
    }
    else if(addType.equals("Model"))
    {
    	 searchTypes = "type_Model";
    	 searchTable = "PLCSearchModelsTable";
    	 strCancelLabel = "emxRequirements.Button.Close";
    	 excludeProg = "emxSpecificationStructure:excludeConnectedModels";
    	 strSelection = "multiple";
    	 strShowClipboard = "False";
         strPrinterFriendly = "False";
         strObjectCompare = "False";
         strExport = "False";
         strMultiColumnSort = "False";
         strTriggerValidation = "False";
         strExpandLevelFilter = "False";
         strAutoFilter = "False";
         submitHRef="../requirements/FullSearchUtil.jsp?mode=AddModels&relName=relationship_ConfigurationContext&from=false&specStructId=" + objectIdList;
    }
    else if(addType.equals("RemoveModel"))
    {
    	 searchTypes = "type_Model";
    	 searchTable = "PLCSearchModelsTable";
    	 strCancelLabel = "emxRequirements.Button.Close";
    	 includeProg = "emxSpecificationStructure:includeNonConnectedModels";
    	 strSelection = "multiple";
    	 strShowClipboard = "False";
         strPrinterFriendly = "False";
         strObjectCompare = "False";
         strExport = "False";
         strMultiColumnSort = "False";
         strTriggerValidation = "False";
         strExpandLevelFilter = "False";
         strAutoFilter = "False";
         submitHRef="../requirements/FullSearchUtil.jsp?mode=RemoveModels&relName=relationship_ConfigurationContext&from=false&specStructId=" + objectIdList;
    }

    //End V6R2010xHF1    
    else
    {
        throw(new Exception("Invalid addType: " + addType));
    }

    String dialogUrl = "../common/emxFullSearch.jsp" +
                       "?field=TYPES%3D" + searchTypes +
                	   "&sortColumnName=none" + 
                       "&table=" + searchTable +
                       (excludeProg == null || excludeProg.length() == 0? "": "&excludeOIDprogram=" + excludeProg) +
                       "&selection=" + strSelection +
                       "&suiteKey=Requirements" +
                       "&cancelButton=" + showCancelButton + 
                       "&header=emxRequirements.Heading.SearchResult" + 
                       "&cancelLabel=" + strCancelLabel +
                       "&showInitialResults=" + showInitialResults + 
                       "&HelpMarker=emxhelpfullsearch" +
                       "&emxTableRowId=" + tableRowId +
                       "&formInclusionList=" + modeTypes + 
                       "&includeOIDprogram=" + includeProg + 
                       
                       (strShowClipboard == null           || strShowClipboard.length()           == 0? "": "&showClipboard=" + strShowClipboard) +
			   		   (strPrinterFriendly == null         || strPrinterFriendly.length()         == 0? "": "&PrinterFriendly=" + strPrinterFriendly) +
			           (strObjectCompare == null           || strObjectCompare.length()           == 0? "": "&objectCompare=" + strObjectCompare) +
			           // (strCustomize == null               || strCustomize.length()               == 0? "": "&customize=" + strCustomize) +
			           (strExport == null                  || strExport.length()                  == 0? "": "&Export=" + strExport) + 
			           (strMultiColumnSort == null         || strMultiColumnSort.length()         == 0? "": "&multiColumnSort=" + strMultiColumnSort) + 
			           (strTriggerValidation == null       || strTriggerValidation.length()       == 0? "": "&triggerValidation=" + strTriggerValidation) + 
			           (strExpandLevelFilter == null       || strExpandLevelFilter.length()       == 0? "": "&expandLevelFilter=" + strExpandLevelFilter) +
			           (strAutoFilter == null       	   || strAutoFilter.length()	          == 0? "": "&autoFilter=" + strAutoFilter) +
			
                       (strSearchCollectionEnabled == null || strSearchCollectionEnabled.length() == 0? "": "&searchCollectionEnabled=" + strSearchCollectionEnabled) +
                       (strShowSavedQuery == null          || strShowSavedQuery.length()          == 0? "": "&showSavedQuery=" + strShowSavedQuery) +
                       (submitHRef == null                 || submitHRef.length()                 == 0? "": "&submitURL=" + submitHRef) +
                       (strExpandProgram == null           || strExpandProgram.length()           == 0? "": "&expandProgram=" + strExpandProgram) +
                       (strToolbar == null                 || strToolbar.length()                 == 0? "": "&toolbar=" + strToolbar);
%>

<%@page import="matrix.util.StringList"%>
<%@page import="java.util.ArrayList"%><script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<script type="text/javascript" src="../plugins/libs/jquery/2.0.3/jquery.js"></script> 
<script language="javascript">
$.getScript("../webapps/AmdLoader/AmdLoader.js", function (){
	window.dsDefaultWebappsBaseUrl = "../webapps/";
	$.getScript("../webapps/WebappsUtils/WebappsUtils.js", function (){
		require(['DS/ENORMTCustoSB/panelRightContext'], function(){
			//START : LX6 IR-348544-3DEXPERIENCER2016x
			closePanel();
			//ENDT : LX6 IR-348544-3DEXPERIENCER2016x
		});
	});
});

    showModalDialog("<xss:encodeForJavaScript><%=dialogUrl%></xss:encodeForJavaScript>", 750, 500, true);
</script>
<%
} // End of try
catch (Exception e)
{
  //session.putValue("error.message", "" + ex);
  String strAlertString = "emxRequirements.Alert." + e.getMessage();
  String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), strAlertString); 
  if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
  {
      session.putValue("error.message", e.getMessage());
  }
  else
  {
      session.putValue("error.message", i18nErrorMessage);
  }
} // End of catch
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

