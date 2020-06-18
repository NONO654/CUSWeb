<%-- emxpartAVLEditLocationProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
  Part part = (Part)DomainObject.newInstance(context,
                  DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String languageStr    = request.getHeader("Accept-Language");
  boolean modifyaccess= true;
  
//Multitenant
//String strmodifyalertmsg = i18nNow.getI18nString("emxEngineeringCentral.Common.Modifyaccess","emxEngineeringCentralStringResource",context.getSession().getLanguage());
String strmodifyalertmsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Modifyaccess"); 
  try {
       String num = "";
       String relId = "";
       String status = "";
       String preference = "";
      // get the total number of rows displayed in the location edit page
       num = emxGetParameter(request,"totalrows");
       if (!("").equals(num))
       {
         DomainRelationship relObj = null;
         AttributeList listAttr = null;
         Attribute statusattribute = null;
         Attribute preferenceattribute = null;
         int totalrows = Integer.parseInt(num);
         for (int i=0;i<totalrows;i++) 
         {
             // retreive the rel id of each row
             relId = emxGetParameter(request,"relId"+i);
             // retreive the Location Status value 
             status = emxGetParameter(request,"statusCombo"+i);
             // retreive the Location Preference value 
             preference = emxGetParameter(request,"preferenceCombo"+i);
             listAttr = new AttributeList (2);
             // build the domain relationship based on the rel id
             if (relId!=null || !("").equals(relId)) {
                 relObj = new DomainRelationship(relId);
                 statusattribute = new Attribute (new AttributeType (part.ATTRIBUTE_LOCATION_STATUS),status);
                 preferenceattribute = new Attribute (new AttributeType (part.ATTRIBUTE_LOCATION_PREFERENCE),preference);
                 // add the attributes to the AttributeList
                 listAttr.add(statusattribute);
                 listAttr.add(preferenceattribute);
                 // Set the attributes on the relationship
                 relObj.setAttributeValues(context, listAttr);
             }
         }
     }
  }
  catch(Exception e)
  {
	  modifyaccess =false;
%>
    <%@include file = "emxEngrAbortTransaction.inc"%>
<%
       // throw e;
  }
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc" %>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
var modifyaccess = "<%=modifyaccess%>";
//XSSOK
var modifyalertmsg="<%=strmodifyalertmsg%>";
if(modifyaccess=='false') {
    alert(modifyalertmsg);
    parent.closeWindow();
}else{
	var objectRef = findFrame(parent.getWindowOpener().parent, "listDisplay");
	objectRef.location.reload();
    getTopWindow().closeWindow();
}
</script>
