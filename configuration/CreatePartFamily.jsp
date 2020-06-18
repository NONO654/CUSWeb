<%--  emxProductCentralCreatePartFamily.jsp   -The Processing page for creating a new Part Family

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/CreatePartFamily.jsp 1.5.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "com.matrixone.apps.productline.*"%>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="/ematrix/common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
</head>

<%

  String sTypeName   = emxGetParameter(request,"partFamilyType");
  String sObjName    = emxGetParameter(request,"partFamilyName");
  String sDescr      = emxGetParameter(request,"Description");
  String sVaultName  = emxGetParameter(request,"Vault");
  String sBaseNumber = emxGetParameter(request,"Part Family Base Number");
  String sSeparator  = emxGetParameter(request,"Part Family Pattern Separator");
  String sSuffix     = emxGetParameter(request,"Part Family Suffix Pattern");
  String sPrefix     = emxGetParameter(request,"Part Family Prefix Pattern");
  String sGenerator  = emxGetParameter(request,DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON);
  
  String sdefaultPartTypeActual         = emxGetParameter(request,"defaultPartTypeActual");

  // Modified by Infosys for Bug # 331389 Date Oct 27, 2005
  String strSymbolicTypeName           = FrameworkUtil.getAliasForAdmin(context, DomainConstants.SELECT_TYPE, sdefaultPartTypeActual, true);

  if(strSymbolicTypeName != null && !"".equals(strSymbolicTypeName))
  {
      sdefaultPartTypeActual = strSymbolicTypeName;
  }

  String sdefaultPartPolicyActual       = emxGetParameter(request,"defaultPartPolicyActual");

  // Modified by Infosys for Bug # 331389 Date Oct 27, 2005
  String strSymbolicPolicyName          = FrameworkUtil.getAliasForAdmin(context, DomainConstants.SELECT_POLICY, sdefaultPartPolicyActual, true);

  if(strSymbolicPolicyName != null && !"".equals(strSymbolicPolicyName))
  {
      sdefaultPartPolicyActual = strSymbolicPolicyName;
  }

  String attributeNames                 = emxGetParameter(request, "attributeNames");
  StringTokenizer strTok                = new StringTokenizer(attributeNames, ";");
  Properties createPartFamilyProp = new Properties();

  if(sTypeName!=null && !"null".equals(sTypeName)){
    createPartFamilyProp.setProperty("typeName_KEY",sTypeName);
  }
  if(sObjName!=null && !"null".equals(sObjName)){
    createPartFamilyProp.setProperty("objName_KEY",sObjName);
  }
  if(sDescr!=null && !"null".equals(sDescr)){
    createPartFamilyProp.setProperty("descr_KEY",sDescr);
  }
  if(sVaultName!=null && !"null".equals(sVaultName)){
    createPartFamilyProp.setProperty("vaultName_KEY",sVaultName);
  }
  if(sSeparator!=null && !"null".equals(sSeparator)){
    createPartFamilyProp.setProperty("separator_KEY",sSeparator);
  }
  if(sGenerator!=null && !"null".equals(sGenerator)){
    createPartFamilyProp.setProperty("generator_KEY",sGenerator);
  }
  if(sdefaultPartTypeActual!=null && !"null".equals(sdefaultPartTypeActual)){
    createPartFamilyProp.setProperty("defaultPartTypeActual_KEY",sdefaultPartTypeActual);
  }
  if(sdefaultPartPolicyActual!=null && !"null".equals(sdefaultPartPolicyActual)){
    createPartFamilyProp.setProperty("defaultPartPolicyActual_KEY",sdefaultPartPolicyActual);
  }
  if(attributeNames!=null && !"null".equals(attributeNames)){
    createPartFamilyProp.setProperty("attributeNames_KEY",attributeNames);
  }

  HashMap attributesMap = new HashMap();

  while (strTok.hasMoreTokens())
  {
    String attrName = strTok.nextToken();

    if(!"".equals(attrName) && !"null".equals(attrName))
    {
      String attrValue = emxGetParameter(request,attrName);

      if (attrName.equals(ProductLineConstants.ATTRIBUTE_DEFAULT_PART_TYPE))
      {
        attrValue = sdefaultPartTypeActual;
      }

      if (attrName.equals(ProductLineConstants.ATTRIBUTE_DEFAULT_PART_POLICY))
      {
        attrValue = sdefaultPartPolicyActual;
      }
      if (attrValue != null && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals("")))
      {
        createPartFamilyProp.setProperty(attrName,attrValue);
      }
      if (attrName.equals(DomainObject.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON))
      {
        if (attrValue != null && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals("")))
        {
          createPartFamilyProp.setProperty(attrName,attrValue);
        }
        else
        {
          createPartFamilyProp.setProperty(attrName,"FALSE");
        }
      }
      if ((attrValue!= null) && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals("")))
      {
        if ((attrName!= null) && !(attrName.equalsIgnoreCase("null")) && !(attrName.equals("")))
        attributesMap.put(attrName, attrValue);
      }
    }
  }

  if (sGenerator != null && "TRUE".equalsIgnoreCase(sGenerator))
  {
    sGenerator = "TRUE";
  } else {
    sGenerator = "FALSE";
  }

  String sOriginator    = emxGetParameter(request,"Originator");
  String sSequence      = emxGetParameter(request,"Part Family Sequence Pattern");
  String parentObjectId = emxGetParameter(request,"objectId");
  String sRevision      = null;
  String sPolicy        = emxGetParameter(request,"Policy");
  String pageName       = emxGetParameter(request,"page");

  if (pageName == null) {
    pageName = "PartFamilyCreate";
  }

  if(sVaultName!=null && !sVaultName.equalsIgnoreCase("null")) {
    sVaultName=sVaultName.trim();
  }

  try {
            Map objAttributeMap = new HashMap(1);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_BASE_NUMBER, sBaseNumber);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON, sGenerator);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_PATTERN_SEPARATOR, sSeparator);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_SUFFIX_PATTERN, sSuffix);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_PREFIX_PATTERN, sPrefix);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_PART_FAMILY_SEQUENCE_PATTERN, sSequence);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_ORIGINATOR, sOriginator);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_DEFAULT_PART_TYPE, sdefaultPartTypeActual);
            objAttributeMap.put(DomainConstants.ATTRIBUTE_DEFAULT_PART_POLICY, sdefaultPartPolicyActual);
            LogicalFeature logicalFTR= new LogicalFeature(parentObjectId);
            logicalFTR.createAndConnectPartFamily(context,  sTypeName, sObjName.trim(), sRevision, sPolicy,  sVaultName, sDescr,  objAttributeMap);

            //calling the method for Part Family inclusion rule update -- MOVED TO PartFamily.createAndConnect()
            // TODO- in PartFamily.createAndConnect()  Master backgrund Job
            
  } catch(com.matrixone.apps.domain.util.FrameworkException e) {
            session.putValue("createPartFamilyProp_KEY",createPartFamilyProp );
            String msg = ((matrix.util.ErrorMessage)e.getMessages().get(e.getMessages().size()-1)).getMessage();
            String errorMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.PartFamily.AlreadyExists",request.getHeader("Accept-Language"));
            //Message:Name 'Part Family MK-1 -' not unique Severity:2 ErrorCode:1500179
            //START - modifies if condition for bug No. IR-040036V6R2011
            if(!msg.contains("not unique")) {
                errorMsg = e.getMessage();
            }
    %>
    <script language="JavaScript">
           alert("<%=XSSUtil.encodeForJavaScript(context,errorMsg)%>");
           parent.window.location.href = parent.window.location.href;
    </script>
    <%
  }
%>

<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
    getTopWindow().window.closeWindow();
    //For NextGen UI Adoption : Using findFrame will not work in GBOM PArt TAble Context because it is portal pAge
    parent.getWindowOpener().document.location.href = parent.window.getWindowOpener().document.location.href;
  
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
