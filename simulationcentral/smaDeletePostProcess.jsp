<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%-- Wrapper JSP to invoke SubmitJPO with selected rows. --%>

<%-- Common Includes --%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.common.WorkspaceVault"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>


<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../simulationcentral/smaUITree.js"></script>

<%
matrix.db.Context context2 = 
    (matrix.db.Context)request.getAttribute("context");
if (context2 != null)
    context = context2;

String[] sRowIds = null;
sRowIds = emxGetParameterValues(request, "emxTableRowId");
//Added by A2I for IR-183403V6R2015 Start
if (sRowIds == null || sRowIds.length==0)
     {
    sRowIds = (String[])session.getAttribute("deleteIds");
     }
session.removeAttribute("deleteIds");
//Added by A2I for IR-183403V6R2015 End
String removeOpt = emxGetParameter(request,"RemoveOption");
String parentId = emxGetParameter(request, "parentId");
Boolean isWorkspace = Boolean.parseBoolean(emxGetParameter(request, "isWorkspace"));
Boolean isDocument = Boolean.parseBoolean(emxGetParameter(request, "isDocument"));
String errorMsg = "";
final String strLang = request.getHeader("Accept-Language");
Boolean isUnlinkForWS=false;
Boolean dontRemoveRow=false;
if("leaveIn".equals(removeOpt)&& isWorkspace)
    {isUnlinkForWS=true;dontRemoveRow=true;}
final String workspaceUnlinkMsg = SimulationUtil.getI18NString(context,"smaSimulationCentral.DeleteContent.CannotUnlinkWorkspace");
final String accessErr = SimulationUtil.getI18NString(context,"ErrMsg.Content.noaccess");
String delErr="";
try
{
    /**
     *Changes for IR-186925V6R2014 - x86
     *Adding a validation to check if there is any warning sent during delete process
     */
    final String REL_VAULTED = SimulationUtil.getSchemaProperty
             (SimulationConstants.SYMBOLIC_relationship_VaultedObjects);
	
    final String SELECT_CONN_ID ="id";
	
    StringList oSelect = new StringList();
	oSelect.addElement(SELECT_CONN_ID);
	
	DomainObject DO = new DomainObject();
	DO.setId(parentId);
	
	Map rel = DO.getRelatedObject
	     (context, REL_VAULTED, false, oSelect, null);
	
	parentId = (String)rel.get(SELECT_CONN_ID);
    
	String warningMsg = null;
    warningMsg = deleteItems(context,sRowIds,"takeOut".equals(removeOpt));
    if ((warningMsg != null) && warningMsg != "" && warningMsg.length() != 0)
    {
        warningMsg =XSSUtil.encodeForJavaScript(context,warningMsg);
        %>
         <script language="javascript">
           alert('<%=warningMsg%>');
        </script>
       <%
        //throw new Exception(warningMsg);
    }
    
    // Changes for IR-186925V6R2014 ends here
}
catch(Exception ex)
{
   //TODO : VE4
   // VE4 designed error action for Structure browser home page.
   // now need to think through for Structure Navigator
   // SUCCESS case refresh is handled below
    String msg =XSSUtil.encodeForJavaScript(context,ex.getMessage());
    %>
     <script language="javascript">
       alert('<%=msg%>');
    </script>
   <%
}
// Get the object ids from sRowIds.
StringBuilder deletedIds = new StringBuilder();
for (int iii=0; iii<sRowIds.length; iii++)
{
    
    String[] idParts = sRowIds[iii].split("\\|");
    if (deletedIds.length() > 0)
        deletedIds.append("|");
    if(idParts.length>1)
        deletedIds.append(idParts[1]);
    else
        deletedIds.append(idParts[0]);
}
//HF-111927 : To publish this event for Folder subscriptions as 
//Team Central does not handle this.
try{
    if(isDocument){
        SimulationUtil.publishWorkspaceVaultEvent(context, null, parentId,
            WorkspaceVault.EVENT_CONTENT_REMOVED);
    }else{
        //check for publish_subscribe relationship for WS Folder for other SCE objects
        if (parentId != null) {

            boolean isDoc = isDocument;

            final String TYPE_EVENT = SimulationUtil
                    .getSchemaProperty(DomainConstants.TYPE_EVENT);//type pattern

            final String TYPE_PUBLISH_SUBSCRIBE = SimulationUtil
                    .getSchemaProperty(DomainConstants.TYPE_PUBLISH_SUBSCRIBE);//type pattern

            final String RELATIONSHIP_PUBLISH = SimulationUtil
                    .getSchemaProperty(DomainConstants.RELATIONSHIP_PUBLISH);//rel pattern

            final String RELATIONSHIP_PUBLISH_SUBSCRIBE = SimulationUtil
                    .getSchemaProperty(DomainConstants.RELATIONSHIP_PUBLISH_SUBSCRIBE);//rel pattern                

            String relSelect = RELATIONSHIP_PUBLISH + ","
                    + RELATIONSHIP_PUBLISH_SUBSCRIBE;
            String typeSelect = TYPE_PUBLISH_SUBSCRIBE + ", "
                    + TYPE_EVENT;

            StringList objSelects = new StringList();
            String attrEventType = SimulationUtil
                    .getAttributeSelect(DomainSymbolicConstants.SYMBOLIC_attribute_EventType);
            objSelects.add(attrEventType);

            StringList relSel = new StringList();
            Map relWSFmap = null;
            try {
                DomainObject wsFolderObj = new DomainObject(
                        parentId);

                MapList eventMapList = wsFolderObj
                        .getRelatedObjects(context, 
                                relSelect, //relationship pattern
                                "*", //type pattern
                                objSelects, // object selects
                                relSel, // relationshipSelects
                                false, // get to
                                true, // get from
                                (short) 0, // level
                                null, // object where
                                null, // relationship where
                                0); // limit

                if (eventMapList != null) {
                    int numObjects = eventMapList.size();
                    String[] events = new String[numObjects];

                    for (int i = 0; i < numObjects; ++i) {
                        Map map = (Map) eventMapList.get(i);

                        events[i] = (String) map.get(attrEventType);

                        //if the event "Content Removed" is present, proceed with subscriptions
                        if (events[i].contains("Content Removed")) {
                            SimulationUtil
                                    .publishWorkspaceVaultEvent(
                                            context, 
                                            null,
                                            parentId,
                                            WorkspaceVault.EVENT_CONTENT_REMOVED);

                            break;
                        }//if
                    }//for 
                    System.out.println(events);
                }//outer if
            }// try for creating maplist of event types
            catch (Exception ex) {
                //
                // - Swallow the exception. Null map will be returned.
                //
            }
        }
    }
}
catch(Exception ex)
{
   //Ignore the expetion
}

%>
<script type="text/javascript">
              var nullString = "null";
    		  refreshNode("<%=parentId%>","<%=parentId%>");
</script>

<%!
private String deleteItems(Context context, String[] sRowIds, boolean deleteObj)
throws FrameworkException, MatrixException, Exception
{
    // Sort based on level, we want to delete all leaves first and
    // then their parents.
    // Level is the last column of the row ids, so create a temp
    // set of row ids for sorting, with level first.
    HashMap errorMap = new HashMap();
    String warnMsg = null;
    StringList selectRowIds = new StringList(sRowIds.length);
    for (int jj=0; jj<sRowIds.length; jj++ )
    {
        String[] fields = sRowIds[jj].split("\\|");
        selectRowIds.add(fields[fields.length-1] + "&" + sRowIds[jj]);
    }
    
    selectRowIds.sort();

    // Need to remove the added front part now.
    // Reverse the order so leaves come first
    int i = 0;
    for (int jj=sRowIds.length-1; jj>=0; jj-- )
    {
        String sId = (String) selectRowIds.get(jj);
        String[] tmpParts = sId.split("\\&");
        sRowIds[i++] = tmpParts[1];
    }
    
    /**
     *Changes for IR-186925V6R2014 - x86
     *Adding a validation to check if there is any warning sent during delete process
     *If there is a message extract it from the map
     */
    errorMap = SlmUIUtil.removeTOCReferences(context, sRowIds, deleteObj);
    if(errorMap != null && (String)errorMap.get("warningmsgkey")!= null){
        String msgKey = (String)errorMap.get("warningmsgkey");
        DomainObject doObj = (DomainObject)errorMap.get("domainObj");
        warnMsg =
            SimulationUtil.formatTNRMessage(context,
                doObj, msgKey);
     
    }
    
    return warnMsg;
    
    // Chnages for IR-186925V6R2014 ends here
}
%>
