<%--  emxComponentsRegionUtil.jsp  --  Creating Region object

    Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxComponentsRegionUtil.jsp.rca 1.19 Wed Oct 22 16:18:45 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  Region region = (Region)DomainObject.newInstance(context,DomainConstants.TYPE_REGION);
  String typeRegion     = PropertyUtil.getSchemaProperty(context, "type_Region");
  String policyRegion   = PropertyUtil.getSchemaProperty(context, "policy_Region");

  com.matrixone.apps.common.Person contextPerson = com.matrixone.apps.common.Person.getPerson(context);

  boolean bBackPage= false;
  String name = emxGetParameter(request, "RegionName");
  String description = emxGetParameter(request, "description");
  String mode    = emxGetParameter(request,"mode");
  String companyId = emxGetParameter(request,"companyId");
  String objectId = emxGetParameter(request,"objectId");
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(UINavigatorUtil.isMobile(context)){
	  checkBoxId = ComponentsUIUtil.getSplitTableRowIds(checkBoxId);
  }
  String fromActionsTab = "false";
  String newId[] = null;
  String objectIdList[] = null;
  StringTokenizer st = null;
  String delId = "";
  String sObjId = null;
  String relId = null;
  DomainObject parentObject = null;
  String CREATE = "Create";
  String DELETE = "Delete";
  String ADDEXISTING = "AddExisting";
  String URL =null;
  String relationshipId = "";
  HashMap data = new HashMap();
  
  String strLanguage = request.getHeader("Accept-Language");

  // handle creation of Region
  if(CREATE.equals(mode)) 
  {
    try
    {
      String strObjType = "";
      String strRelName = "";
      if(companyId == null || "".equals(companyId) || "null".equals(companyId))
      {
        Company contextCompany = contextPerson.getCompany(context);
        companyId = contextCompany.getId();
        strObjType = contextCompany.getInfo(context,DomainObject.SELECT_TYPE);
        fromActionsTab = "true";
      }
      else
      {
        DomainObject compObj = new DomainObject(companyId);
        strObjType = compObj.getInfo(context,DomainObject.SELECT_TYPE);
      }
      if(typeRegion.equals(strObjType))
      {
        strRelName = Region.RELATIONSHIP_SUB_REGION;
      }
      else
      {
        strRelName = Region.RELATIONSHIP_ORGANIZATION_REGION;
      }

      matrix.db.Query query = new matrix.db.Query();
      query.open(context);
      query.setBusinessObjectType(typeRegion);
      query.setBusinessObjectName(name);
      query.setBusinessObjectRevision("*");
      query.setVaultPattern("*");
      query.setOwnerPattern("*");
      query.setWhereExpression("to["+strRelName+"].from.id == "+companyId);
      BusinessObjectList boList = query.evaluate(context);
      query.close(context);
      int countEqual = boList.size();
      String regionId = "";
      if(countEqual == 0)
      {
        // create Regions
        regionId = FrameworkUtil.autoRevision(context, typeRegion, name, policyRegion, contextPerson.getVaultName(context));
        
        region.setId(regionId);
        region.setDescription(context, description);
        DomainRelationship domRel = region.addFromObject(context,new RelationshipType(strRelName),companyId);
        relationshipId = region.getInfo(context,"to["+strRelName+"].id");
        
        URL = UINavigatorUtil.getCommonDirectory(context)+ "/emxTree.jsp?AppendParameters=true"+"&objectId=" + XSSUtil.encodeForURL(context, regionId)  +"&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory) + "&mode=insert&relId="+XSSUtil.encodeForURL(context, relationshipId);
      }
      else
      {
        // to set error message in session if name is already exists
        session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.AddRegion.RegionAlreadyExists", strLanguage));
        bBackPage = true;
        
      }
    }
    catch(Exception  e )
    {
      session.putValue("error.message", e.toString());
      bBackPage = true;
    }
    // If any error while Creating the Region go Back to Dialog page
    if(bBackPage) 
    {
        URL = "../components/emxCommonFS.jsp?functionality=RegionCreateFSInstance&objectId="+XSSUtil.encodeForURL(context, companyId)+"&suiteKey=Components";
%>
        <script language="javascript">
        //XSSOK
          parent.location.href= '<%=URL%>';
        </script>
<%
    // Go to Sumary Page
    }
    else 
    {

%>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="javascript" src="../common/scripts/emxUICore.js"></script>
        <script language="javascript">
         var tree = parent.window.getWindowOpener().getTopWindow().objStructureTree;
         if(parent.getWindowOpener().parent.frames[0].getTopWindow().modalDialog)
         {
               var contentFrame = openerFindFrame (getTopWindow(), "detailsDisplay");
               contentFrame.location.href = contentFrame.location.href;
         }
          <%if(!"true".equals(fromActionsTab) ) {%>
          //XSSOK
                parent.window.getWindowOpener().parent.parent.location.href="<%= URL %>&jsTreeID=" + tree.getSelectedNode().nodeID;
          <%}else {%>
          //XSSOK
               parent.window.getWindowOpener().parent.frames[1].frames[1].location.href="<%= URL %>";
          <%}%>
          getTopWindow().closeWindow();
        </script>
<%
    }
  } else if(DELETE.equals(mode)){ // handle deletion of Region
    if(checkBoxId != null )
    {
      objectIdList = new String[checkBoxId.length];
      try 
      {
        for(int i=0;i<checkBoxId.length;i++)
        {
          st = new StringTokenizer(checkBoxId[i], "|");
          while (st.hasMoreTokens()) {
             sObjId = st.nextToken();
          }
          objectIdList[i]=sObjId;
          delId=delId+objectIdList[i]+";";
        }
        Region.deleteObjects(context,objectIdList);
      }
      catch(Exception Ex)
      {
        session.putValue("error.message", Ex.toString());
      }
    }
%>
        <script language="javascript">
          var tree = getTopWindow().objStructureTree;
          if (tree != null && tree.root != null) {
<%
            st= new StringTokenizer(delId,";",false);
            while (st.hasMoreTokens()) {
              relId = st.nextToken();
%>
              tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, relId)%>");
<%
            }
%>
          }
          getTopWindow().refreshTablePage();
       </script>
<%
  }else if(ADDEXISTING.equals(mode)){ // handle "AddExisting" Region mode
    newId = emxGetParameterValues(request,"newId");
    try {
      Region.addExistingObjects(context,objectId , newId,true,DomainConstants.RELATIONSHIP_ORGANIZATION_REGION);
    }catch(Exception Ex){
      session.putValue("error.message", Ex.toString());
    }
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  
<script language="javascript">

var contentFrame = openerFindFrame (getTopWindow(), "detailsDisplay");
  if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
  {
    getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
  }

  contentFrame.location.href = contentFrame.location.href;

  getTopWindow().closeWindow();
</script>
<%
  }
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
