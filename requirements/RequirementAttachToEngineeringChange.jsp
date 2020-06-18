<%--  RequirementAttachToEngineeringChange.jsp  --%>
<!-- /*
* @quickreview QYG     12:09:05(IR-174856V6R2013x  "Attach to EC" commands could not handle large number of objects.)
* @quickreview LX6 QYG 12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
* @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet.
* @quickreview T25 DJH 14:01:20 : Correction IR-269245V6R2013x  (Unable to create EC from large requirement specs )
* @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
*/ -->
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%
//Start:IR:1230516R2013x:LX6
boolean isError = false;
try
{
//End:IR:1230516R2013x:LX6
    String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String timeStamp = (String)requestMap.get("timeStamp");
    String objectId = (String)requestMap.get("objectId");
    String addType = (String)requestMap.get("addType");
    String searchTypes = null;
    String searchTable = null;
    String excludeProg = null;
    String submitHRef = null;
    String strExpandProgram = null;
    String strSelection = "multiple";
    String strShowSavedQuery = "True";
    String strSearchCollectionEnabled = "True";
    String strCancelLabel = "emxRequirements.Button.Cancel";
    boolean showCancelButton = true;
    String strIsTo = "";
    String strDestRelName = "";
    String key="";
    
    // Start:IR:123051V6R2013x:LX6
    boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,tableRowIds);
    if(isRequirementGroupInList == true)
    {
    	isError = true;
      throw new Exception("invalidForReqGroup");
    }
    // End:IR:123051V6R2013x:LX6
    // If a single row is selected, use it as the target ID...
    StringList strList = new StringList();
    ArrayList objectIdList = new ArrayList();
    StringList parentIDList = new StringList();
    String oid = "";    
    if(tableRowIds != null && tableRowIds.length > 0) 
    {   
       for(int i = 0; i < tableRowIds.length ; i++) 
       {                     
          if(tableRowIds[i].indexOf("|") != -1)
          {
             strList = FrameworkUtil.split(tableRowIds[i], "|");
             if (strList.size() == 3)
             {
                 oid = (String)strList.get(0);
                 
             }else
             {
                 oid = (String)strList.get(1);
             }         
          }else
          {
             oid = tableRowIds[i];
          }
          objectIdList.add(oid);                  
        }      
     }
    
    java.util.Set set = new java.util.HashSet(objectIdList);   
    String idsSelected  = "";
    java.util.Iterator itr = set.iterator();
    while(itr.hasNext())
    {
        String id = (String)itr.next();
        idsSelected += id;
        
        if(itr.hasNext())
            idsSelected += ",";
    }
    
    if (addType.equals("AttachEC"))
    {
    	long number = new Random(System.currentTimeMillis()).nextLong();
    	key = "AttachToEC" + System.currentTimeMillis() + "_" + number;
    	session.setAttribute(key, idsSelected.toString());
    	searchTypes = "type_EngineeringChange:CURRENT!=policy_EngineeringChangeStandard.state_Close,policy_EngineeringChangeStandard.state_Complete,policy_EngineeringChangeStandard.state_Reject";
    	searchTable = "AEFGeneralSearchResults";
    	excludeProg = objectIdList.size() == 1 ?  "emxCommonEngineeringChange:excludeConnectedEC" : null;
    	submitHRef = "../components/emxEngineeringChangeUtil.jsp?mode=AddExistingECAffectedItems&key="+key;
    	strShowSavedQuery = "True";
        strSelection = "multiple";
    	strSearchCollectionEnabled ="True";
    	strIsTo = "false";
    	strDestRelName = "relationship_ECAffectedItem";
    }

        
    else
    {
        throw(new Exception("AttachECError"));
    }

    String dialogUrl = "../common/emxFullSearch.jsp" +
                       "?field=TYPES%3D" + searchTypes +
                       "&table=" + searchTable +
                       (excludeProg == null || excludeProg.length() == 0? "": "&excludeOIDprogram=" + excludeProg) +
                       "&selection=" + strSelection +
                       "&suiteKey=Requirements" +
                       "&cancelButton=" + showCancelButton + 
                       "&cancelLabel=" + strCancelLabel +
                       "&HelpMarker=emxhelpfullsearch" +
                       "&showSavedQuery=" + strShowSavedQuery +
                       "&searchCollectionEnabled=" + strSearchCollectionEnabled +
                       "&srcDestRelName=" + strDestRelName +
                       "&isTo=" + strIsTo +
                       (submitHRef == null                 || submitHRef.length()                 == 0? "": "&submitURL=" + submitHRef);
    dialogUrl += "&emxTableRowId=" + idsSelected.split(",")[0];
%>

<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.ArrayList"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script language="Javascript">    
   showModalDialog("<xss:encodeForJavaScript><%=dialogUrl%></xss:encodeForJavaScript>");
</script>     
<%
//Start:IR:1230516R2013x:LX6
} // End of try
catch (Exception ex)
{
	  // Start:IR:123051V6R2013x:LX6
	  String strAlertString = "emxRequirements.Alert." + ex.getMessage();
    String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), strAlertString);
    if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
    {
        session.putValue("error.message", ex.getMessage());
    }
    else
    {
        session.putValue("error.message", i18nErrorMessage);
    }
} // End of catch
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<script type="text/javascript">
<%
if(isError == true)
{
%>
  //KIE1 ZUD TSK447636 
getTopWindow().closeWindow();
<%
}
%>
</script type="text/javascript">
<!-- // End:IR:123051V6R2013x:LX6 -->

