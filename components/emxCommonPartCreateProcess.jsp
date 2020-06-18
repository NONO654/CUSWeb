<%--  emxCommonPartCreateProcess.jsp  -  The process page for part creation.

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonPartCreateProcess.jsp.rca 1.12 Tue Oct 28 19:01:09 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
  String parentObjId = emxGetParameter(request,"parentObjId");
  String strDescription = emxGetParameter(request, "description");
  String strName = emxGetParameter(request, "partName");
  String strPartType = emxGetParameter(request, "type"); //Changed for Bug 346004  // Modified for Bug 360655 
  String strPartPolicy = emxGetParameter(request, "policy");//Changed for Bug 346004
  String partId = emxGetParameter(request, "partId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");

  Policy partPolicy = new Policy(strPartPolicy);
  partPolicy.open(context);
  String strPartRevision = "";
  if (partPolicy.hasSequence()) {
    strPartRevision = partPolicy.getFirstInSequence();
  }
  partPolicy.close(context);
  BusinessObject busPart = new BusinessObject(strPartType, strName, strPartRevision, context.getVault().getName() );
  String strPartId = "";

  boolean partexists = false;

  if(partId == null || "".equalsIgnoreCase(partId)) {
    partexists = busPart.exists(context);
  }

  if (partexists) {
	  com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
	
	String msgtext = loc.GetString("emxComponentsStringResource", request.getHeader("Accept-Language"), "emxComponents.Common.AlreadyExists");
	msgtext = "'"+strName+"' " + msgtext;
	session.putValue("error.message"," " + msgtext);

	
        context.shutdown();
	%>
    <jsp:forward page ="emxCommonPartCreateDialog.jsp" />
<%
    return;
  } else {
    try {

    	com.matrixone.apps.common.Part doPart = (com.matrixone.apps.common.Part)DomainObject.newInstance(context,strPartType);
      if (strDescription != null) {
        strDescription = strDescription.trim();
      }
	  AttributeList attrListGeneric = new AttributeList();
	  BusinessType busType = new BusinessType(strPartType,context.getVault());
	  AttributeTypeList attList = busType.getAttributeTypes(context);
      String strEstimatedCostAttribute = PropertyUtil.getSchemaProperty(context,"attribute_EstimatedCost");
      String strOriginatorAttribute = PropertyUtil.getSchemaProperty(context,"attribute_Originator");
      String sAttrValue   = "";
      String sTrimVal     = "";
      String sAttrTxtVal  = "";
      String sAttrCombVal = "";
      String sAttName     = "";
	  String sUOMAttributeValue = "";
      AttributeTypeItr itr = new AttributeTypeItr(attList);
	  while (itr.next()) {
		AttributeType attrTypeGeneric = itr.obj();
		String sDataType = attrTypeGeneric.getDataType(context);
        sAttrTxtVal  = "" ;
        sAttrCombVal = "";
		sUOMAttributeValue = "";

        //To get the name of the attribute
        sAttName = attrTypeGeneric.getName();
        if ( sAttName.equals(strOriginatorAttribute) ) {
          continue;
        }
        StringList choiceList = attrTypeGeneric.getChoices();

        if (choiceList != null && choiceList.size() > 0) {
          String sAttChoiceName = "txt_"+sAttName;
          sAttrTxtVal = emxGetParameter(request, sAttChoiceName);
        }
        sAttrCombVal = emxGetParameter(request, sAttName);
        if (sDataType.equals("timestamp"))
        {
          double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();
          if (sAttrCombVal != null && !sAttrCombVal.equals("") && !sAttrCombVal.equals("null") ) {
            sAttrCombVal = eMatrixDateFormat.getFormattedInputDate(context,sAttrCombVal,tz,request.getLocale());
          }
		}
		
		if((sDataType.equals("real") || sDataType.equals("integer")))
		{
			String strUOMAttribute  = emxGetParameter(request, sAttName);
			String strUOMAttributeUnit  = emxGetParameter(request, "units_"+sAttName);

			if(strUOMAttribute==null || "null".equalsIgnoreCase(strUOMAttribute) || "".equals(strUOMAttribute))
			{
				strUOMAttribute = "0";
			}

			if(strUOMAttributeUnit!=null && !"null".equalsIgnoreCase(strUOMAttributeUnit) && !"".equals(strUOMAttributeUnit))
			{
				sUOMAttributeValue = strUOMAttribute + " " + strUOMAttributeUnit;
			}
			else{
				sUOMAttributeValue = strUOMAttribute;
			}

		}

        if( (sAttrTxtVal !=null)&&(!sAttrTxtVal.equals("")) ) {
          sAttrValue = sAttrTxtVal;
		} else if((sUOMAttributeValue !=null)&&(!sUOMAttributeValue.equals(""))){
			sAttrValue = sUOMAttributeValue;
        } else {
          sAttrValue = sAttrCombVal;
        }

        if( (sAttrValue != null) && (!sAttrValue.equals(""))) {
          sTrimVal = sAttrValue.trim();
          Attribute attrGeneric = new Attribute(attrTypeGeneric,sTrimVal);
          attrListGeneric.addElement(attrGeneric);

        }
      }

    String strObjectId = doPart.create(context,strPartType,strName,strPartRevision,strPartPolicy,context.getVault().getName(),strDescription,attrListGeneric,parentObjId);

	
%>
   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript">
       try {
       		updateCountAndRefreshTree("<%=appDirectory%>", getTopWindow().getWindowOpener().getTopWindow());     
       }catch(ex) {	  
    	   //do nothing
       }
       
       window.closeWindow();
   </script>

<%

    } catch (Exception ex ){
      session.putValue("error.message", ex.getMessage());
    }
  }
%>
