<%--  emxEngrCreateApplication.jsp   - Dialog page to edit EBOM relationship.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<html>
<head>
<title></title>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>    
</head>

<%@ include file = "emxDesignTopInclude.inc" %>
<%@ include file = "../eServiceUtil.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="com.matrixone.apps.engineering.Part" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<body>
<%

Part part = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

boolean bAutoName = false;

      Properties createPartprop = (Properties) session.getAttribute("createPartprop_KEY");


         String type                = DomainConstants.TYPE_APPLICATION_PART;

      String partNum             = createPartprop.getProperty("partNum_KEY");
      String policy              = createPartprop.getProperty("policy_KEY");
         String revision            = createPartprop.getProperty("revision_KEY");
      String rev                 = createPartprop.getProperty("rev_KEY");
      String Vault               = createPartprop.getProperty("Vault_KEY");
      String Owner               = createPartprop.getProperty("Owner_KEY");
      String description         = createPartprop.getProperty("description_KEY");
         String checkAutoName       = createPartprop.getProperty("checkAutoName_KEY");
      String locName             = createPartprop.getProperty("locName_KEY");
      String locId               = createPartprop.getProperty("locId_KEY");
         String RDO                 = createPartprop.getProperty("RDO_KEY");
         String RDOId               = createPartprop.getProperty("RDOId_KEY");
      String objectId            = createPartprop.getProperty("objectId_KEY");
      String assemblyPartId      = createPartprop.getProperty("assemblyPartId_KEY");
      String jsTreeID            = createPartprop.getProperty("jsTreeID_KEY");
      String suiteKey            = createPartprop.getProperty("suiteKey_KEY");
      String SuiteDirectory      = createPartprop.getProperty("suiteDirectory_KEY");

      if("None".equals(revision))
      {
         bAutoName = false;
         revision = rev;
      }
      else
      {
         bAutoName = true;
         partNum = null;
      }


      // to get the selected parts in previous page
      String totalElements = emxGetParameter(request, "totalElements");
      int NumofElements = Integer.parseInt(totalElements);
      java.util.Vector selectedMEPs = new Vector();

      if (NumofElements > 0) {
         for (int k=0;k<=NumofElements;k++)
         {
                   String chkboxnames = "checkBox"+k;
                   String tempparam = emxGetParameter(request,chkboxnames);

             if(tempparam != null || null != tempparam)
             {
                      selectedMEPs.addElement(tempparam.toString());
                }
         }
      }
      // end of to get the selected parts in previous page

      //get and set the attribute values
      double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();

      Map attrMap = (Map) session.getAttribute("attributeMap");
      HashMap attributesMap = (HashMap) session.getAttribute("attributesMap");

      java.util.Set keys = attrMap.keySet();
      Iterator itr = keys.iterator();

      while (itr.hasNext()){
          Map valueMap = (Map)attrMap.get((String)itr.next());
          String attrName = (String)valueMap.get("name");
          String attrValue = (String)attributesMap.get(attrName);

          if ("attrOriginator".equals(attrName)){
                attributesMap.put(attrName,context.getUser());
             }

             if ((attrValue!= null) && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals("")))
             {
             String sDataType = "";
             try {
                 AttributeType attrTypeGeneric = new AttributeType(attrName);
                 attrTypeGeneric.open(context);
                 sDataType = attrTypeGeneric.getDataType();
                 attrTypeGeneric.close(context);
             } catch (Exception ex ) {
                 sDataType = "";
             }

             if (sDataType.equals("timestamp"))
             {
                 if (attrValue != null && !attrValue.equals("") && !attrValue.equals("null") ) {
                     attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(attrValue,tz,request.getLocale());
                 }
             }

             attributesMap.put(attrName, attrValue);
          }
      }

      session.removeAttribute("attributeMap");
      session.removeAttribute("createPartprop_KEY");
      session.removeAttribute("attributesMap");

      if("on".equalsIgnoreCase(checkAutoName)) {
         bAutoName = true;
         partNum = null;
      }
      try {
          part.setId(objectId);
          part.createApplicationPart(context,assemblyPartId,type,
                 partNum, revision,policy, description,Owner, context.getVault().getName(),
                 RDOId,locId, selectedMEPs,attributesMap,bAutoName,rev);
      }catch(Exception e) {
          throw e;
      }
%>

<script>
//getTopWindow().getWindowOpener().getTopWindow().location.href=getTopWindow().getWindowOpener().getTopWindow().location.href;
var frame = openerFindFrame(getTopWindow(), "content");
frame.location.href=frame.location.href;
getTopWindow().closeWindow();
</script>

</body>
</html>
