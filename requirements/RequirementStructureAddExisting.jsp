<%--  SpecificationStructureAddExisting.jsp  --%>
<!--
 /*
* @quickreview LX6 JX5 13 Sep 12(IR-123110V6R2014  "FIR : Requirement Groups having parent are displayed in search result while attach Existing Groups.")
*/ 
-->
<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>  
<%
try
{
    String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

    String timeStamp = (String)requestMap.get("timeStamp");
    String objectId = (String)requestMap.get("objectId");
    String relName = (String)requestMap.get("relName");
    String addType = (String)requestMap.get("addType");
    String table = (String)requestMap.get("table");
    String isFromRMB = (String)requestMap.get("isFromRMB");

	String isFrom=(String) requestMap.get("from");
	boolean bIsFrom = false; 
	if(isFrom != null && "true".equalsIgnoreCase(isFrom))
	{
		bIsFrom = true;
	}
    String tableRowId = "|" + objectId + "||0";
    String searchTable = "RMTGlobalSearchBasicsTable";
    String searchTypes = null;
    String excludeProg = null;
    String submitHRef = null;
    String modeTypes = null;

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
        else if (tableRowIds.length > 1)
        {
            String mess = EnoviaResourceBundle.getProperty(context, resc, context.getLocale(), "emxFramework.Common.PleaseSelectOneItemOnly");
            throw (new Exception(mess));
        }

        tableRowId = tableRowIds[0];
    }

    if (addType.equals("Specification"))
    {	
		excludeProg = "emxRequirementGroup:getSearchReqSpecExcludeList";
        searchTypes = "type_SoftwareRequirementSpecification";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from="+(bIsFrom?"true":"false")+"%26isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Product"))
    {
        searchTypes = "type_Products";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=true%26isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Requirement"))
    {
        searchTypes = "type_Requirement";
        excludeProg = "emxSpecificationStructure:excludeChildObjects";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=true%26isFromRMB=" + isFromRMB;
        modeTypes = "CONTAINED_IN_PRODUCTS,CONTAINED_IN_SPECIFICATIONS";
    }
    else if (addType.equals("UseCase"))
    {
        searchTypes = "type_UseCase";
        searchTable = "RMTGlobalSearchUseCasesTable";
        //Start:oep:IR-013439V6R2011
        // excludeProg = "emxSpecificationStructure:excludeChildObjects";
        excludeProg = "emxUseCase:excludeSubUseCases";
       //End:oep:IR-013439V6R2011
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=true%26isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("TestCase"))
    {
        searchTypes = "type_TestCase";
        excludeProg = "emxSpecificationStructure:excludeChildObjects";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=true%26isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Person"))
    {
        searchTypes = "type_Person";
        excludeProg = "emxSpecificationStructure:excludeChildObjects";
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=false%26isFromRMB=" + isFromRMB;
    }
    else if (addType.equals("Group"))
    {
        searchTypes = "type_RequirementGroup";
      //Start:IR:123110V6R2014:LX6
        excludeProg = "emxRequirementGroup:getExcludeListForAttachExistingGroup";
      //End:IR:123110V6R2014:LX6
        submitHRef = "../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=" + relName + "%26from=true%26isFromRMB=" + isFromRMB;
    }		
    else
    {
        throw(new Exception("Invalid addType: " + addType));
    }

    String dialogUrl = "../common/emxFullSearch.jsp" +
                       "?field=TYPES%3D" + searchTypes +
                       "&table=" + (table == null || table.length() == 0? searchTable: table) +
                       (excludeProg == null || excludeProg.length() == 0? "": "&excludeOIDprogram=" + excludeProg) +
                       "&selection=multiple" +
                       "&suiteKey=Requirements" +
                       "&cancelButton=true" +
                       "&cancelLabel=emxRequirements.Button.Cancel" +
                       "&showSavedQuery=True" +
                       "&showInitialResults=false" + 
                       "&searchCollectionEnabled=True" +
                       "&HelpMarker=emxhelpfullsearch" +
                       "&emxTableRowId=" + tableRowId +
                       "&objectId=" + objectId +
                       "&rel=" + relName +
                       "&type=" + searchTypes +
                       "&submitURL=" + submitHRef + 
                       "&formInclusionList=" + modeTypes;
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript">
    showModalDialog("<xss:encodeForJavaScript><%=dialogUrl%></xss:encodeForJavaScript>", 900, 600, true);
</script>
<%
} // End of try
catch (Exception ex)
{
  session.putValue("error.message", ex.getMessage());
} // End of catch
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
