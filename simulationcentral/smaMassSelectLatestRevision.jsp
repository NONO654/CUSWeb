<%-- © Dassault Systemes, 2007, 2008 --%>
<%--
  This programs assigns latest revision of the selected documents to category/Sim Folder/Referenced Folder
--%>
<%--  --%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.Parameters" %>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
<jsp:useBean id="indentedTableBean"
    class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
 
    
<% 

String timeStamp = emxGetParameter(request, "timeStamp");
String tableRowIdList[] = Request.getParameterValues(request, "emxTableRowId");
HashMap tableData= indentedTableBean.getTableData(timeStamp);
int notSupportedcount = 0;
StringBuilder notSupportedList=new StringBuilder();
int latestRevisioncount = 0;
StringBuilder latestRevisionList=new StringBuilder();
int noConnectAccessCount = 0;
StringBuilder noConnectAccessList=new StringBuilder();
StringList toggleList= new StringList();
final String locale = context.getSession().getLanguage();
StringBuilder message = new StringBuilder();
boolean displayMessage = false;
StringBuffer data = new StringBuffer(256);
%>
 <script type="text/javascript">
                 var topFrame = getTopWindow();
                 if (getTopWindow().getWindowOpener())
                 {
                     topFrame = getTopWindow().getWindowOpener().getTopWindow();        
                 }
                var rowsToRemove = [];
                var parentRowIds = [];
                var count = 0;
                var frame = sbFindFrame(topFrame, "detailsDisplay");
                if (frame != null)
                {
                    frame.turnOnProgress();
<%
                    // If the old content is visible in the TOC, it has to be
                    // removed.
                    // Get the Structure Browser entry for the template row
                    // and check if it has a child (which is the old content).
    
                    //-- In the indentedTableBean, the table data is stored in
                    //-- the IndexedObjectList TreeMap.
                    //-- And the map keys are the "d,d,..." row ids.
                    String sXML = "";
                    for(int i=0;i<tableRowIdList.length;i++){
                       
                     String[] templateTableRowIdParts = tableRowIdList[i].split("\\|");
                     String templateRowId = templateTableRowIdParts[3];
                     String parentId = templateTableRowIdParts[2];
                     String objectId = templateTableRowIdParts[1];
                     String relationshipId = templateTableRowIdParts[0];
                     String toggleID     = "";
                     SortedMap<String,Map> indexedObjectList = null;
                     if(tableData!=null)
                         indexedObjectList = (SortedMap)tableData.get("IndexedObjectList");
     
                     // Get the entry for the template row.
                     Map templateRowMap = (Map)indexedObjectList.get(templateRowId);
                     // File Row may contain filename along with ID
                     //We can safely ignore file rows as we are dealing with documents only 
                     if(!objectId.matches("^[0-9\\.]+$")){
                         String fileName = objectId;
                         if(objectId.contains("~")){
                             String fileNameArray[]=objectId.split("~");
                             if(fileNameArray[1]!=null){
                                 fileName = fileNameArray[1];
                             }
                         }
                         notSupportedList.append(fileName+" , ");
                         notSupportedcount++;
%>
                         sbUncheckRow("<%=tableRowIdList[i]%>", false, "detailsDisplay");
<%
                         continue;                                                  
                     }
                    DomainObject oldRevision=DomainObject.newInstance(context, objectId);
                    String relationship = (String)templateRowMap.get("relationship");
                    boolean isDocument = oldRevision.isKindOf(context, "DOCUMENTS");
                    String objecTitle = oldRevision.getInfo(context, "attribute[Title]");
                    if(objecTitle.isEmpty()){
                        objecTitle = oldRevision.getName();
                    }
                    if(!isDocument) {
                        notSupportedList.append(objecTitle+" , ");
                        notSupportedcount++;
%>
                     sbUncheckRow("<%=tableRowIdList[i]%>", false, "detailsDisplay");
<%
                        continue;
                    }
                    if(oldRevision.isLastRevision(context)){
                        latestRevisioncount++;
                        latestRevisionList.append(objecTitle+" , ");
%>
                        sbUncheckRow("<%=tableRowIdList[i]%>", false, "detailsDisplay");
<%
                        continue;
                    }
                    DomainObject parent=DomainObject.newInstance(context, parentId);
                    RelationshipList relList= parent.getToRelationship(context);
                    BusinessObject parentOid=new BusinessObject();
                    if(relList!=null){
                        Relationship parentRel = (Relationship) relList.get(0);
                        if(parentRel != null){
                            parentOid=parentRel.getFrom();
                        }
                    }
                    BusinessObject latestRevision = oldRevision.getLastRevision(context);
                    Map requestMap= new HashMap();
                    requestMap.put("emxTableRowId", latestRevision.getObjectId());
                    Map tabledata = new HashMap();
                    Map RequestMap= new HashMap();
                    RequestMap.put("ContentRowIds",tableRowIdList[i]);
                    RequestMap.put("ParentOID",parentOid.getObjectId());
                    tabledata.put("RequestMap",RequestMap);
                    Map programMap=new HashMap();
                    programMap.put("requestMap", requestMap);
                    programMap.put("tableData",tabledata);
                    try{
                        SimulationContentUtil.selectRevision(context, programMap);
                    }
                    catch(Exception ex){
                        noConnectAccessCount ++;
                        noConnectAccessList.append(objecTitle +" , ");
%>
                        sbUncheckRow("<%=tableRowIdList[i]%>", false, "detailsDisplay");
<%
                        continue;
                    }
                                    
                    // Check if the template row has a child.
                    MapList templateRowChildren = (MapList)templateRowMap.get("children");
                    if (templateRowChildren != null && templateRowChildren.size() != 0)
                    {
                        toggleList.add(templateRowId);
                    }
                    // Convert parent ID and added content to an appropriate javascript
                    // code that either adds the entities or displays an error message.
                    data.append(StructureBrowserUtil.setXMLdataRow(context, parentId, relationshipId, latestRevision.getObjectId(), "nada"));
                    sXML = StructureBrowserUtil.setXMLStructureBrowserResponse(context, "add", "", data.toString());
%>   
                    
                    rowsToRemove[count] = "<%=tableRowIdList[i]%>";
                    
                    var childRow = emxUICore.selectSingleNode(frame.oXML.documentElement,
                    "/mxRoot/rows//r[@id = '<%=templateRowId%>']");
                    var parentRowId = null;
                    if(childRow){
                        parentRowId = childRow.parentNode.getAttribute("r")
                        + "|" + childRow.parentNode.getAttribute("o")
                        + "|" + childRow.parentNode.parentNode.getAttribute("o")
                        + "|" + childRow.parentNode.getAttribute("id");  
                        
                    }
                   
                    parentRowIds[count++]=parentRowId;
                   
<%
                }
%>
            
            frame.removeRows(rowsToRemove);
            if(parentRowIds != null && parentRowIds.length!=0) {
                sbAddToSelectedMultipleRows(parentRowIds, "<%=sXML%>",false, "detailsDisplay");
            }
            
            frame.turnOffProgress();
                }
<%
            if(notSupportedcount !=0){
                displayMessage = true;
                if(notSupportedcount == 1){
                    message.append(SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.NoSupportMassSelect",
                        "P1",notSupportedList.substring(0, notSupportedList.length()-2)));
                }else {
                    message.append(SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.NoSupportMassSelectMultiple", 
                        "P1",""+notSupportedcount,"P2",notSupportedList.substring(0, notSupportedList.length()-2)));
                }
            }

            if(latestRevisioncount !=0){
                displayMessage = true;
                if(latestRevisioncount == 1){
                    message.append("\\n" +SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.AlreadyLatestRevision", 
                        "P1",latestRevisionList.substring(0, latestRevisionList.length()-2)));
                }else {
                    message.append("\\n" +SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.AlreadyLatestRevisionMultiple", 
                        "P1",""+latestRevisioncount,"P2",latestRevisionList.substring(0, latestRevisionList.length()-2)));
                }
                }
            if(noConnectAccessCount !=0){
                displayMessage = true;
                if(noConnectAccessCount == 1){
                    message.append("\\n" +SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.NoToconnectAccess", 
                        "P1",noConnectAccessList.substring(0, noConnectAccessList.length()-2)));
                }else {
                    message.append("\\n" +SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.NoToconnectAccessMultiple", 
                        "P1",""+noConnectAccessCount,"P2",noConnectAccessList.substring(0, noConnectAccessList.length()-2)));
                }
            }
            if(displayMessage) {
%>
                alert("<%=message%>");
<%
            }
%>            
            </script>
      
