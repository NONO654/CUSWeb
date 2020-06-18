<%-- emxMultipleClassificationReclassify.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] ="$Id: emxMultipleClassificationReclassify.jsp.rca 1.6 Wed Oct 22 16:54:21 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../documentcentral/emxMultipleClassificationUtils.inc"%>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css" />
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />

<%
    final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";
	final String FRAMEWORK_STRING_RESOURCE = "emxFrameworkStringResource";
    final boolean isInheritedAlso = true;
    final boolean isNotInherited  = false;
    final String strLanguage = request.getHeader("Accept-Language");
%>
    <form name="formReclassify">
<%

    // Append the parameter to the content page

    for (Enumeration e = emxGetParameterNames(request); e.hasMoreElements();)
    {
        String strParamName  = (String)e.nextElement();
        String strParamValue = (String)emxGetParameter(request, strParamName);
%>
        <input type="hidden" name="<%=strParamName%>" value="<xss:encodeForHTMLAttribute><%=strParamValue%></xss:encodeForHTMLAttribute>" />
<%
    }
%>

<%
    String strSelectedObjectId  = emxGetParameter(request, "emxTableRowId");
    String strObjectId          = emxGetParameter(request, "objectId");
    String strNewParentObjectId = emxGetParameter(request, "parentObjectId");
    String stroldParentObjectId = emxGetParameter(request, "oldParentObjectId");
    String classificationMode   =(String)emxGetParameter(request, "classificationMode");
    String fromPage             = emxGetParameter(request, "fromPage");
    if(classificationMode == null && "null".equals(classificationMode)) {
        classificationMode = "";
    }
    StringList strlistAGToShow  = new StringList();
    int iClassifiedItems = 0;
    if(strObjectId != null && !strObjectId.trim().equals(""))
    {
        strSelectedObjectId = strObjectId;
    }
    DomainObject doOldParentObj = new DomainObject(stroldParentObjectId);
    String strOldParentName = doOldParentObj.getInfo(context,DomainConstants.SELECT_NAME);

    String sPartFamily = PropertyUtil.getSchemaProperty(context, "type_PartFamily");
    String sGeneralClass = PropertyUtil.getSchemaProperty(context, "type_GeneralClass");


    com.matrixone.apps.classification.Classification objOldClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, stroldParentObjectId, "Classification");
    StringList strlistOldParentAGInherited = objOldClassification.getAttributeGroups(context, isInheritedAlso);

    StringList strlistNewParentAGInherited  = new StringList();
    StringList slNewParentObjectIds         = FrameworkUtil.split(strNewParentObjectId, "|");
    for (int i = 0; i < slNewParentObjectIds.size() ; i++)
    {
        com.matrixone.apps.classification.Classification objNewClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, (String)slNewParentObjectIds.get(i), "Classification");
        strlistNewParentAGInherited.addAll(objNewClassification.getAttributeGroups(context, isInheritedAlso));
    }

    StringList strlistOldParentAGInheritedBkp = strlistOldParentAGInherited ;

    StringList strlistOLDParentAGToShow = new StringList();
    StringList strlistNewParentAGToShow = new StringList();
    StringList strNewParentAttributes = new StringList();
    StringList listAttributes = new StringList();
    String strAttributeGroupName = "";
    AttributeGroup attGrp  = new AttributeGroup();



    if (strlistOldParentAGInherited != null && strlistNewParentAGInherited != null)
    {
        strlistOldParentAGInherited.removeAll(strlistNewParentAGInherited);
        // Remember this to show !
        strlistOLDParentAGToShow = strlistOldParentAGInherited;


        strlistNewParentAGInherited.removeAll(strlistOldParentAGInheritedBkp);
        strlistNewParentAGToShow = strlistNewParentAGInherited;


        for(int iCnt = 0 ; iCnt < strlistNewParentAGToShow.size() ; iCnt ++){

            strAttributeGroupName =(String)strlistNewParentAGToShow.get(iCnt);
            attGrp = AttributeGroup.getInstance(context,strAttributeGroupName);
            listAttributes = attGrp.getAttributes();
            if(listAttributes != null){
                for(int iCount = 0 ; iCount< listAttributes.size() ; iCount++){
                    strNewParentAttributes.addElement((String)listAttributes.get(iCount));
                }
            }
        }
    }
%>

    <table border = "0" cellpadding = "5" cellspacing = "2" width = "100%">
        <tr>

        <td width="75%" class="inputField"><xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.ReclassifyMessage1")%></xss:encodeForHTML>

                <ul style="padding-top: 10px; padding-bottom: 10px; padding-left: 35px;">		
		
        <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.Common.ClassName")%></xss:encodeForHTML>:<xss:encodeForHTML><%=strOldParentName%></xss:encodeForHTML>		
		
<%               
                String strAttributeName = "";

                for (int i=0; i<strlistOLDParentAGToShow.size(); i++)
                {
                    strAttributeGroupName = (String)strlistOLDParentAGToShow.get(i);

                    if(strAttributeGroupName != null)
                    {
                        attGrp = AttributeGroup.getInstance(context,strAttributeGroupName);
                        listAttributes = attGrp.getAttributes();							
                        if(listAttributes != null){
                            int iAttrSize = listAttributes.size();							
                            for(int k=0;k<iAttrSize;k++)
                            {
                                strAttributeName = (String)listAttributes.get(k);
                               if(!strNewParentAttributes.contains(strAttributeName)){
								// Changes added by SKM10 (IR-566576-3DEXPERIENCER2018x)
								// if attribute is multiple words than to make it as one word by replacing " " by "_" to match with the name mentioned in properties file.                         	 
									String multiWordsAttributeName = strAttributeName.replace(" ", "_");
									strAttributeName = multiWordsAttributeName;                        	 
								// Changes added by SKM10 ends
							   // Changes added by PSA11 start(IR-503770-3DEXPERIENCER2018x).	
                               String attributeProperty = "emxFramework.Attribute." + strAttributeName;
                               String attributeNameFromPropertiesFile = EnoviaResourceBundle.getProperty(context,FRAMEWORK_STRING_RESOURCE,new Locale(strLanguage),attributeProperty);
                               if(attributeNameFromPropertiesFile.contains("emxFramework.Attribute.")){
                            		attributeNameFromPropertiesFile = strAttributeName;
                               }
                               // Changes added by PSA11 end.									

%>
                                <li style="list-style-type:disc;"><xss:encodeForHTML><%=strAttributeGroupName%></xss:encodeForHTML>:<xss:encodeForHTML><%=attributeNameFromPropertiesFile%></xss:encodeForHTML>
<%
								}
                            }
                        }
                    }
				}	
%>
                </ul>				
        <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.ReclassifyMessage2")%></xss:encodeForHTML><BR>       <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.ReclassifyMessage3")%></xss:encodeForHTML>
				
            </td>
        </tr>
    </table>
</form>
<%

    String strForwardPageUrl = "emxMultipleClassificationReclassifyProcess.jsp?attributesLost=true&fromPage="+fromPage;
%>

<script language="javascript">
<!--
    function submitForm()
    {
        if("reClassification" == "<xss:encodeForJavaScript><%=classificationMode%></xss:encodeForJavaScript>") {
            getTopWindow().closeWindow();
            getTopWindow().getWindowOpener().parent.callSaveChanges();
        }else {
            var openerDoc = window.getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().window.document;
            openerDoc.body.innerHTML = "<form name=\"formReclassify\"></form>";
            openerDoc.formReclassify.innerHTML = document.formReclassify.innerHTML;
            openerDoc.formReclassify.method = "post";
            openerDoc.formReclassify.action = "<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>";
            openerDoc.formReclassify.submit();

            getTopWindow().getWindowOpener().getTopWindow().closeWindow();
            getTopWindow().close(); //changes done for IR-484176
        }
    }
    function closeWindow()
    {
		//changes done for IR-484176
   	 if(getTopWindow().getWindowOpener && getTopWindow().getWindowOpener().getTopWindow().sb && getTopWindow().getWindowOpener().getTopWindow().sb.setSubmitURLRequestCompleted) {
    		getTopWindow().getWindowOpener().getTopWindow().sb.setSubmitURLRequestCompleted();
    		}
        getTopWindow().closeWindow();

    }
//-->
</script>
