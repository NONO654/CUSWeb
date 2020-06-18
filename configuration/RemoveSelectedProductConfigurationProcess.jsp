<%-- $RCSfile: /ENOVariantConfigurationBase/CNext/webroot/configuration/RemoveSelectedProductConfigurationProcess.jsp$

Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,Inc.
Copyright notice is precautionary only and does not evidence any actual or intended
publication of such program

static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/RemoveSelectedProductConfigurationProcess.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>


<%@  include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%
  String[] ObjectIds = null;
  String parentOID = null;

  try {  
    ObjectIds = emxGetParameterValues(request,"emxTableRowId");
    parentOID = emxGetParameter(request,"parentOID");

    for(int i=0;i<ObjectIds.length;i++) {
      String tempObjectId =   ObjectIds[i];
      StringTokenizer stItr=new StringTokenizer(tempObjectId,"|");
      String ObjectId ="";
      while (stItr.hasMoreTokens()) {
        ObjectId=(String)stItr.nextToken();
      }
      if(parentOID!=null && !"".equals(parentOID)) {
        {
          DomainObject domObj=new DomainObject(ObjectId);
          DomainObject domObj1=new DomainObject(parentOID);
          if(ObjectId!=null && !"".equals(ObjectId))
          {
            boolean isRelCustomItem=domObj.hasRelatedObjects(context,ProductLineConstants.RELATIONSHIP_CUSTOM_ITEM,false);
            if(isRelCustomItem==true)
            {
              domObj1.disconnect(context,new RelationshipType(ProductLineConstants.RELATIONSHIP_CUSTOM_ITEM),true, domObj);
            }
            else
            {
              domObj1.disconnect(context,new RelationshipType(ProductLineConstants.RELATIONSHIP_STANDARD_ITEM),
              true, domObj);
            }
          }
        }
      }
    }
  }
  catch (Exception ex )
  {
    session.putValue("error.message",ex.getMessage());
  }
%>
<script language="javascript">
{
  getTopWindow().refreshTablePage();
}
</script>


