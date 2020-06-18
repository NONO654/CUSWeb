<%--  emxMEPDisconnectProcess.jsp   
   Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPDisconnectProcess.jsp 1.1.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
--%>



<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxMEPCommonInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%

String objectId = emxGetParameter(request,"objectId");

 
com.matrixone.apps.manufacturerequivalentpart.Part part = new com.matrixone.apps.manufacturerequivalentpart.Part(objectId);
 
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  
  String initSource = emxGetParameter(request,"initSource");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String url = "";
  String delId  ="";

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      try{
          String relIdList[] = new String[checkBoxId.length];
          for(int i=0;i<checkBoxId.length;i++){
             
             StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
             String sRelId = st.nextToken();
             BusinessObject FromObject = null;
             relIdList[i] = sRelId;
             BusinessObject ToObject =null;
             String FromId ="";
             String ToId="";
             matrix.db.Relationship relobject = new matrix.db.Relationship(sRelId);

             relobject.open(context);
             FromObject = relobject.getFrom();
             ToObject = relobject.getTo();
             if(FromObject != null ){
               FromId = FromObject.getObjectId();

             }
             if(ToObject != null ){
               ToId = ToObject.getObjectId();

             }
             relobject.close(context);

             if(objectId.equals(FromId)){
               delId=delId+ToId+";";
             }else{
               delId=delId+FromId+";";
             }
          }
//modified for 313612
          boolean isMBOMInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMManufacturing",false,null,null);
          String sAltSubExtEnabled =  EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.AlternateSubstitute.EquivalentPartExtensionEnabled");
          if(isMBOMInstalled && sAltSubExtEnabled.equalsIgnoreCase("true")){
   				String[] sColumnId = emxGetParameterValues(request,"emxTableRowId");
   				String relId = emxGetParameter(request,"relId");	
   				HashMap paramMap = new HashMap();
   				paramMap.put("parentId", sColumnId);
   		 		paramMap.put("parentOID", objectId);
   		 		paramMap.put("EBOMRel",relId);
				if(UIUtil.isNotNullAndNotEmpty(relId)){
   					JPO.invoke(context, "emxMBOMPart", null, "modifyUsageForMEPRemove", JPO.packArgs(paramMap));
				}
		  } 
          part.disconnectMEPs(context,relIdList);

          url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;

      }catch(Exception Ex){
          session.putValue("error.message", Ex.toString());
      }
  }
%>


<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

if (tree)
{
if (tree.root != null)
    {
      var parentId = tree.root.id;
      var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens())
      {
        String RelId = sIdsToken.nextToken();
%>
//XSSOK
    var objId = '<%=RelId%>';
  //  tree.getSelectedNode().removeChild(objId);

     if(parentId == objId )
         {
            isRootId = true;
          }
<%
  }
%>
    }
}
    if(isRootId)
    {
    //XSSOK
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=appDirectory%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame)
          {
            contentFrame.location.replace(url);
           }
      else
          {
                    if(getTopWindow().refreshTablePage)
                    {
                        getTopWindow().refreshTablePage();
                     }
                    else
                    {
                        getTopWindow().location.href = getTopWindow().location.href;
                     }
            }
     }
      else
          {
            parent.location.href = parent.location.href;
          }

</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

