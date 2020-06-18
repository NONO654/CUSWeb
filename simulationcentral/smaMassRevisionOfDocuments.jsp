<%-- © Dassault Systemes, 2007, 2008 --%>
<%--
  This programs creates and assigns latest revision of the selected documents to category/Sim Folder/Referenced Folder
--%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.RevisionNameGenerator" %>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
<jsp:useBean id="indentedTableBean"
    class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<%
String timeStamp = emxGetParameter(request, "callerTimeStamp");
//String tableRowIdList[] = Request.getParameterValues(request, "emxTableRowId");
String tableRowIdList[] = (String[])session.getAttribute("massEmxTableRowId");
session.removeAttribute("massEmxTableRowId");


String templateRowIds[] = new String[tableRowIdList.length];
String parentIds[] = new String[tableRowIdList.length];
String objectIds [] = new String[tableRowIdList.length];
String relationshipIds [] = new String[tableRowIdList.length];
String[] rowIDs = new String[tableRowIdList.length];
int counter =0;

HashMap tableData= indentedTableBean.getTableData(timeStamp);
SortedMap<String,Map> indexedObjectList = null;
if(tableData!=null)
    indexedObjectList = (SortedMap)tableData.get("IndexedObjectList");
final String locale = context.getSession().getLanguage();
final String NoAccessToRevise =SimulationUtil.getI18NString(context,
    "smaSimulationCentral.Content.ErrMsg.NoAccessToRevise");

final String NoAccessToConnect =SimulationUtil.getI18NString(context,
    "smaSimulationCentral.Content.ErrMsg.NoAccessToConnect");

StringList toggleList= new StringList();
String message = null;
StringBuffer data = new StringBuffer();

HashMap<String,String> objectList=new HashMap();
%>
 <script>
                 var topFrame = getTopWindow();
                 if (getTopWindow().getWindowOpener())
                 {
                     topFrame = getTopWindow().getWindowOpener().getTopWindow();
                 }
                var frame = sbFindFrame(topFrame, "detailsDisplay");
                var rowsToRemove = [];
                var parentIds = [];
                var count = 0;
                if (frame != null)
                {
<%
                    // If the old content is visible in the TOC, it has to be
                    // removed.
                    // Get the Structure Browser entry for the template row
                    // and check if it has a child (which is the old content).

                    //-- In the indentedTableBean, the table data is stored in
                    //-- the IndexedObjectList TreeMap.
                    //-- And the map keys are the "d,d,..." row ids.
                    String strCopyFiles = emxGetParameter(request, "RevisionWithFiles");
                    Boolean copyFiles = false;
                    if ("on".equalsIgnoreCase(strCopyFiles)) {
                        copyFiles = true;
                    }

                    String reviseContent = emxGetParameter(request,"ReviseContent");
                    String reviseContentBool = "No";
                    if("on".equalsIgnoreCase(reviseContent))
                        reviseContentBool = "Yes";

                    for(int i=0;i<tableRowIdList.length;i++){
                         String[] templateTableRowIdParts = tableRowIdList[i].split("\\|");
                         String templateRowId = templateTableRowIdParts[3];
                         String parentId = templateTableRowIdParts[2];
                         String objectId = templateTableRowIdParts[1];
                         String relationshipId = templateTableRowIdParts[0];

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
                             message =SimulationUtil.getI18NString(context,
                                 "smaSimulationCentral.Content.ErrMsg.NoToObjectTypeRevise","P1","File");
                             objectList.put(objectId,message);
%>
                             sbUncheckRow("<%=tableRowIdList[i]%>", false, "detailsDisplay");
<%
                             continue;
                         }
                         rowIDs[counter] =tableRowIdList[i];
                         templateRowIds[counter] = templateTableRowIdParts[3];
                         parentIds[counter] = templateTableRowIdParts[2];
                         objectIds[counter] = templateTableRowIdParts[1];
                         relationshipIds[counter++] = templateTableRowIdParts[0];
                    }

                    objectIds = Arrays.copyOf(objectIds, counter, String[].class);
                    final StringBuilder BUF = new StringBuilder();
                    final String DOCUMENTS =SimulationUtil.getSchemaProperty(CommonDocument.TYPE_DOCUMENTS);
                    final String SELECT_DOCUMENTS = StringUtil.concat(BUF,"type.kindof[", DOCUMENTS, "]");
                    final String attributeTitle= "attribute[Title]";
                    final String name= "name";
                    final String type= "type";
                    final String policy= "Policy";
                    String vault=context.getVault().getName();

                    StringList selectList = new StringList();
                    selectList.addElement(SELECT_DOCUMENTS);
                    selectList.addElement(attributeTitle);
                    selectList.addElement(name);
                    selectList.addElement(type);
                    selectList.addElement(policy);
                    BusinessObjectWithSelectList bowsl =
                        BusinessObject.getSelectBusinessObjectData(context, objectIds,
                            selectList);
                    int noObjPassed = 0;
                    for(int i=0;i<counter;i++){
                        String templateRowId = templateRowIds[i];
                        String parentId = parentIds[i];
                        String objectId = objectIds[i];
                        String relationshipId = relationshipIds[i];

                        BusinessObjectWithSelect bows = bowsl.getElement(i);


                        boolean isDocument = "TRUE".equalsIgnoreCase(bows.getSelectData(SELECT_DOCUMENTS));
                        String objecTitle = bows.getSelectData(attributeTitle);
                        if(objecTitle.isEmpty()){
                            objecTitle = bows.getSelectData(name);
                        }
                        if(!isDocument) {
                            message =SimulationUtil.getI18NString(context,
                                "smaSimulationCentral.Content.ErrMsg.NoToObjectTypeRevise","P1",objecTitle = bows.getSelectData(type));
                            objectList.put(objectId,message);
%>
                         sbUncheckRow("<%=rowIDs[i]%>", false, "detailsDisplay");
<%
                            continue;
                        }

                        if (AccessUtil.canRevise(context, objectId) == false)
                        {
                            objectList.put(objectId,NoAccessToRevise);
%>
                            sbUncheckRow("<%=rowIDs[i]%>", false, "detailsDisplay");
<%
                               continue;
                        }
                        DomainObject oldRevision=DomainObject.newInstance(context, objectId);
                        BusinessObject lastRev = oldRevision.getLastRevision(context);
                        String description=lastRev.getDescription(context);
                        String nextRevId = lastRev.getNextSequence(context);
                        if (nextRevId == null || nextRevId.length()==0)
                        {
                            // The policy does not specify a revision sequence.
                            nextRevId = RevisionNameGenerator.
                                getRevision(context, objectId);

                            if (nextRevId == null)
                                nextRevId = "";
                        }
                        Map paramMap=new HashMap();
                        paramMap.put("objectId", lastRev.getObjectId());
                        paramMap.put("Revision", nextRevId);
                        paramMap.put("Description", description);
                        paramMap.put("Title", objecTitle);
                        paramMap.put("Policy", bows.getSelectData(policy));
                        paramMap.put("Vault", vault);
                        paramMap.put("copyFiles", copyFiles);
                        paramMap.put("reviseContent", reviseContentBool);

                        HashMap programMap = new HashMap();
                        programMap.put("paramMap",paramMap);
                        Map returnMap =SimulationUIUtil.postRevise(context, programMap);
                        String action = (String)returnMap.get("Action");
                        if("STOP".equalsIgnoreCase(action)){
                            objectList.put(objectId,NoAccessToRevise);
%>
                            sbUncheckRow("<%=rowIDs[i]%>", false, "detailsDisplay");
<%
                            continue;
                        }
                        String latestRevisionId = (String)returnMap.get("objectId");
                        DomainObject parent=DomainObject.newInstance(context, parentId);
                        RelationshipList relList= parent.getToRelationship(context);
                        BusinessObject parentOid=new BusinessObject();
                        if(relList!=null){
                            Relationship parentRel = (Relationship) relList.get(0);
                            if(parentRel != null){
                                parentOid=parentRel.getFrom();
                            }
                        }
                        Map requestMap= new HashMap();
                        requestMap.put("emxTableRowId", latestRevisionId);
                        Map tabledata = new HashMap();
                        Map RequestMap= new HashMap();
                        RequestMap.put("ContentRowIds",rowIDs[i]);
                        RequestMap.put("ParentOID",parentOid.getObjectId());
                        tabledata.put("RequestMap",RequestMap);
                        programMap=new HashMap();
                        programMap.put("requestMap", requestMap);
                        programMap.put("tableData",tabledata);
                        try{
                            SimulationContentUtil.selectRevision(context, programMap);
                        }
                        catch(Exception ex){
                            objectList.put(objectId,NoAccessToConnect);
%>
                            sbUncheckRow("<%=rowIDs[i]%>", false, "detailsDisplay");
<%
                            continue;
                        }
                        noObjPassed++;
                        // Get the entry for the template row.
                        // Check if the template row has a child.
                        Map templateRowMap = (Map)indexedObjectList.get(templateRowId);
                        MapList templateRowChildren = (MapList)templateRowMap.get("children");
                        if (templateRowChildren != null && templateRowChildren.size() != 0)
                        {
                            toggleList.add(templateRowId);
                        }
                        // Convert parent ID and added content to an appropriate javascript
                        // code that either adds the entities or displays an error message.
                        data.append(StructureBrowserUtil.setXMLdataRow(context, parentId, relationshipId, latestRevisionId, "nada"));

%>
                        rowsToRemove[count] = "<%=rowIDs[i]%>";
                        var childRow = emxUICore.selectSingleNode(frame.oXML.documentElement,
                        "/mxRoot/rows//r[@id = '<%=templateRowId%>']");
                        var parentRowId = null;
                        if(childRow){
                            parentRowId = childRow.parentNode.getAttribute("r")
                            + "|" + childRow.parentNode.getAttribute("o")
                            + "|" + childRow.parentNode.parentNode.getAttribute("o")
                            + "|" + childRow.parentNode.getAttribute("id");
                        }
                        parentIds[count++] =parentRowId;

<%
                    }
            String sXML = StructureBrowserUtil.setXMLStructureBrowserResponse(context, "add", "", data.toString() );
            session.setAttribute("objectList", objectList);
            //String  href = "../common/emxTable.jsp?table=SMARevise_Report&program=jpo.simulation.SimulationUI:getReviseError&header=smaSimulationCentral.Label.MassRevisionReport&selection=none&CancelButton=true&CancelLabel=smaSimulationCentral.Button.Close&tableType=emxIndentedTable&suiteKey=SimulationCentral&autoFilter=false&showClipboard=false&showRMB=false&subHeader=smaSimulationCentral.Label.ErrorReportDialog&multiColumnSort=false&customize=false&jpoAppServerParamList=session:objectList";
            String href="../simulationcentral/smaReviseReport.jsp?totalCount="+tableRowIdList.length+"&noObjPassed="+noObjPassed;


%>

frame.removeRows(rowsToRemove);

<%
if(data.length() !=0) {
%>

sbAddToSelectedMultipleRows(parentIds, "<%=sXML%>",false, "detailsDisplay");

<%
                }
%>

var urltoOpen = "<%=href%>";
showModalDialog(urltoOpen,700,600);


}
   </script>

