

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>



<%@page import="com.dassault_systemes.smaslm.matrix.server.XmlTableUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.W3CUtil"%>
<%@page import="org.w3c.dom.Document"%>
<%@page import="org.w3c.dom.Element"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil" %>

<%@page import="org.w3c.dom.NamedNodeMap" %>
<%@page import="org.w3c.dom.Node" %>
<%@page import="org.w3c.dom.NodeList" %>


<%
    String timeStamp = emxGetParameter(request, "timeStamp");
     //Get object & relationship ids

    PropertyUtil.setGlobalRPEValue(context, DomainAccess.RPE_MEMBER_ADDED_REMOVED, "true");
    String objectId = emxGetParameter(request, "objectId");
    String access = emxGetParameter(request, "access");
    String cmdEventToHandle = emxGetParameter(request, "cmdName");
    String[] ids = emxGetParameterValues(request, "emxTableRowId");

    //System.out.println("DEFAULT PROJECT = " +DomainAccess.getDefaultProject(context));

    String owner = "";
    String ownerAccess = "";
    String defaultAccess = "";
    String OID = "";
    for (int i = 0; i < ids.length; i++)
    {

        StringList idList = com.matrixone.apps.domain.util.StringUtil
            .split(ids[i], "|");


        if (idList.size() > 2)
        {
            String busId = (String) idList.get(1);

            if (!busId.equals(OID))
            {
                OID = busId;
                owner = new DomainObject(busId).getInfo(context,
                    DomainObject.SELECT_OWNER);
                StringList accessNames = DomainAccess
                    .getLogicalNames(context, busId);
                //System.out.println("ACCESSNAME ===== "+ accessNames);
                defaultAccess = (String) accessNames.get(0);
                ownerAccess = (String) accessNames.get(accessNames
                    .size() - 1);
            }

            String attrName = SimulationConstants.SYMBOLIC_attribute_Definition;

            if (attrName.startsWith("attribute_"))
                attrName = SimulationUtil
                    .getSchemaProperty(attrName);

            DomainObject domainObj = new DomainObject(objectId);
            String xmlAttr = domainObj.getAttributeValue(context,
                attrName);

            Document templateDefinationDoc = W3CUtil
                .loadXml(xmlAttr);

            Element accessList = W3CUtil.findElement(
                templateDefinationDoc, "/template/accessList");



            if (cmdEventToHandle.equals("deleteAccess"))
            {

                Node childNodeToRemove = null ;

                for( Node childNode = accessList.getFirstChild() ; childNode != null ;){

                    Node nextChild = childNode.getNextSibling();
                    Map<String,String> listAccessAttr = W3CUtil.getAttributes(((Element)childNode));

                    String name = listAccessAttr.get("name");
                    String organization = listAccessAttr.get("organization");
                    String project = listAccessAttr.get("project");


                    String[] arrIds = ids[i].split(":");
                    String rowName = arrIds[2];
                    String rowOrg = arrIds[1];
                    String prjUn = arrIds[4];
                    String[] arrRowPrj = prjUn.split("\\|");
                    String rowPrj = arrRowPrj[0];




                    if(name.equals(rowName) && organization.equals(rowOrg) && project.equals(rowPrj) ){
                        childNodeToRemove = childNode ;
                        break;
                    }

                    childNode = nextChild;

                }

                accessList.removeChild(childNodeToRemove);

            }
            else{

                Element accessEl = W3CUtil.newElement(accessList,
                    "access");

                if (cmdEventToHandle.equals("addPerson"))
                {
                    String personId = (String) idList.get(0);
                    String personName = new DomainObject(personId)
                        .getInfo(context, DomainObject.SELECT_NAME);

                    String personalProject = personName + "_PRJ";
                    String project = PersonUtil.getFullName(context,
                        personName);

                    /*---In template defination xml personal project is stored as  name
                    Example : name="RKP-C_PRJ"
                    abd full name is stroed as project
                    Example : project="KULKARNI, Rahul-C"
                     */
                    accessEl.setAttribute("name", personalProject);
                    accessEl.setAttribute("organization", "");
                    accessEl.setAttribute("project", project);
                    accessEl.setAttribute("accessLevel", ownerAccess);
                    accessEl.setAttribute("comment",
                        DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);

                }
                else if (cmdEventToHandle.equals("addProject"))
                {
                    String projectId = (String) idList.get(0);
                    String projectName = new DomainObject(projectId)
                        .getInfo(context, DomainObject.SELECT_NAME);

                    accessEl.setAttribute("name", projectName);
                    accessEl.setAttribute("organization", "");
                    accessEl.setAttribute("project", projectName);
                    accessEl.setAttribute("accessLevel", ownerAccess);
                    accessEl.setAttribute("comment",
                        DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);

                }
                else if (cmdEventToHandle.equals("addOrg"))
                {
                    String orgId = (String) idList.get(0);
                    String orgName = new DomainObject(orgId).getInfo(
                        context, DomainObject.SELECT_NAME);

                    accessEl.setAttribute("name", orgName);
                    accessEl.setAttribute("organization", orgName);
                    accessEl.setAttribute("project", "");
                    accessEl.setAttribute("accessLevel", ownerAccess);
                    accessEl.setAttribute("comment",
                        DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);

                }
                else if (cmdEventToHandle.equals("addSecurityContext"))
                {
                    String secContextId = (String) idList.get(0);
                    String orgName = new DomainObject(secContextId)
                        .getInfo(
                            context,
                            DomainConstants.SELECT_RELATIONSHIP_SECURITY_CONTEXT_ORGANIZATION_TO_NAME);
                    String projectName = new DomainObject(secContextId)
                        .getInfo(
                            context,
                            DomainConstants.SELECT_RELATIONSHIP_SECURITY_CONTEXT_PROJECT_TO_NAME);

                    accessEl.setAttribute("name", orgName + "."
                        + projectName);
                    accessEl.setAttribute("organization", orgName);
                    accessEl.setAttribute("project", projectName);
                    accessEl.setAttribute("accessLevel", ownerAccess);
                    accessEl.setAttribute("comment",
                        DomainAccess.COMMENT_MULTIPLE_OWNERSHIP);

                }
            }

            String definition = W3CUtil.toString(templateDefinationDoc);
            domainObj.setAttributeValue(context, attrName,
                definition);

        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script>
    var pageToRefresh = getTopWindow().window.getWindowOpener();
    var cmdEvent = "<%=cmdEventToHandle%>";
    if (pageToRefresh) {
        if ("deleteAccess" == cmdEvent){
            var detailsDisplayFrame = findFrame(getTopWindow(),"detailsDisplay");
            if(detailsDisplayFrame == null) {
                detailsDisplayFrame = findFrame(getTopWindow(),"content");
            }
            if(detailsDisplayFrame != null) {
                detailsDisplayFrame.location.href = detailsDisplayFrame.location.href;
            }

        } else {
        getTopWindow().window.getWindowOpener().location.reload();
        getTopWindow().closeWindow();
        getTopWindow().closeWindow();
        }
    }
    else
    {
        getTopWindow().refreshTablePage();
    }
</script>
