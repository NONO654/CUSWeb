<%-- emxMultipleClassificationRemoveClass.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMultipleClassificationRemoveClass.jsp.rca 1.8 Tue Oct 28 23:01:56 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIForm.css" />
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />

<%
    final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";
    final boolean isInheritedAlso = true;
    final boolean isNotInherited  = false;
    final String strLanguage = request.getHeader("Accept-Language");
    boolean isModeRemove = "remove".equalsIgnoreCase(emxGetParameter(request, "Mode"));
%>
    <form name="formRemoveOrMoveClass">
<%

    // Append the parameter to the content page
    StringBuffer queryString = new StringBuffer();
    for (Enumeration e = emxGetParameterNames(request); e.hasMoreElements();)
    {
        String strParamName  = (String)e.nextElement();
        String strParamValue = (String)emxGetParameter(request, strParamName);
        queryString.append(strParamName);
        queryString.append("=");
        queryString.append(XSSUtil.encodeForURL(context,strParamValue));
        queryString.append("&");
    }
%>

<%
    String strObjectId          = emxGetParameter(request, "objectId");
    String strNewParentObjectId = emxGetParameter(request, "parentObjectId");
    String stroldParentObjectId = emxGetParameter(request, "oldParentObjectId");
    StringList strlistAGToShow  = new StringList();
    String strSelectedObjectId  = null;
    int iClassifiedItems = 0;
    if(!isModeRemove)
    {
        strSelectedObjectId = strObjectId;
    }
    else {
            String emxTableRowIds[] = (String[]) emxGetParameterValues(request,"emxTableRowId");
            emxTableRowIds          = getTableRowIDsArray(emxTableRowIds);
            if(emxTableRowIds != null && emxTableRowIds.length > 0) {
                strSelectedObjectId = emxTableRowIds[0];
            }
    }
    com.matrixone.apps.classification.Classification objClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, strSelectedObjectId, "Classification");

    iClassifiedItems = objClassification.getRecursiveEndItemCount(context);

    if (isModeRemove)
    {
        //
        // We need to list only the inherited attribute groups, hence we will find the AG all(+inherited) except
        // AG only at that level.
        //
        StringList strlistAttributeGroupsInheritedAlso = objClassification.getAttributeGroups(context, isInheritedAlso);
        StringList strlistAttributeGroupsNotInherited  = objClassification.getAttributeGroups(context, isNotInherited);

        if (strlistAttributeGroupsInheritedAlso != null && strlistAttributeGroupsNotInherited != null)
        {
            strlistAttributeGroupsInheritedAlso.removeAll(strlistAttributeGroupsNotInherited);

            // Remove the LCAttributeGroups from the list
            if(strlistAttributeGroupsInheritedAlso.contains(ClassificationConstants.INTERFACE_CLASSIFICATION_ATTRIBUTE_GROUPS))
            {
                int intIndexOfElementToRemove = strlistAttributeGroupsInheritedAlso.indexOf(ClassificationConstants.INTERFACE_CLASSIFICATION_ATTRIBUTE_GROUPS);
                strlistAttributeGroupsInheritedAlso.removeElementAt(intIndexOfElementToRemove);
            }

            // Remember this to show !
            strlistAGToShow = strlistAttributeGroupsInheritedAlso;
        }
        else
        {
            throw new Exception("No inherited attribute group(s) found.");
        }
    }
    else //if (!isModeRemove)
    {
    	StringList strlistNewParentAGNotInherited = null;
    	StringList strlistOldParentAGNotInherited = null;

    	//Code added for R216 Release
    	//Introducing a check to see whether new parent is a Library
    	//Code within ELSE Block is the already existing code
    	if(new DomainObject(strNewParentObjectId).isKindOf(context, LibraryCentralConstants.TYPE_LIBRARIES))
    	{
    		com.matrixone.apps.classification.Classification objOldClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, stroldParentObjectId, "Classification");
    		//strlistOldParentAGNotInherited = objOldClassification.getAttributeGroups(context,isNotInherited);
			strlistOldParentAGNotInherited = objOldClassification.getAttributeGroups(context,isInheritedAlso);
    		strlistAGToShow = strlistOldParentAGNotInherited;
    	}
    	else
    	{
            com.matrixone.apps.classification.Classification objNewClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, strNewParentObjectId, "Classification");

            com.matrixone.apps.classification.Classification objOldClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, stroldParentObjectId, "Classification");

            strlistNewParentAGNotInherited = objNewClassification.getAttributeGroups(context, isNotInherited);
			// Changes added by PSA11 start(IR-500026-3DEXPERIENCER2018x).
			StringList strlistOldParentAGInherited = null;
			strlistOldParentAGInherited = objOldClassification.getAttributeGroups(context, isInheritedAlso);
            if (strlistNewParentAGNotInherited != null && strlistOldParentAGInherited != null)
            {
                strlistOldParentAGInherited.removeAll(strlistNewParentAGNotInherited);
                // Remember this to show !
                strlistAGToShow = strlistOldParentAGInherited;
            }
			// Changes added by PSA11 end.
    	}
    }//else !

%>

    <table border = "0" cellpadding = "5" cellspacing = "2" width = "100%">
        <tr>
            <td width="25%" class="label">
                <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.Options")%></xss:encodeForHTML>
            </td>
            <td width="75%" class="inputField">

                <input type="radio" name="optionForAG" value="carry" checked>
                <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.CarryForwardInheritedAG")%></xss:encodeForHTML>
                <br>
                <input type="radio" name="optionForAG" value="lose">
                <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.LoseInheritedAG")%></xss:encodeForHTML>

                 <ul style="padding-top: 10px; padding-left: 35px;">
                    <li style="list-style-type:disc;"><xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.FollowingAGWillBeLost")%></xss:encodeForHTML>
                     <ul style="padding-left: 35px;">
<%                      for (int i=0; i<strlistAGToShow.size(); i++)
                        {
                            String strAttributeGroupName = (String)strlistAGToShow.get(i);
%>
                        <li style="list-style-type:circle;"><xss:encodeForHTML><%=strAttributeGroupName%></xss:encodeForHTML>
<%
                        }
%>
                    </ul>
                </ul>
                <ul style="padding-top: 10px; padding-left: 35px;">
                <li style="list-style-type:disc;"><xss:encodeForHTML><%=iClassifiedItems%></xss:encodeForHTML> <xss:encodeForHTML><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.AttributeGroup.ClassifiedItems")%></xss:encodeForHTML>
                </ul>
            </td>
        </tr>
    </table>
</form>
<%

    String strForwardPageUrl = "";
    if (isModeRemove)
    {
        //Modified url path  for bug 352482
        strForwardPageUrl = "../documentcentral/emxMultipleClassificationRemoveClassProcess.jsp";
    }
    else
    {
        strForwardPageUrl = "emxMultipleClassificationMoveClassificationProcess.jsp";
    }
%>
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript">
<!--
    function submitForm()
    {
        var isToBeContinued = true;
        var isModeRemove    = "<xss:encodeForJavaScript><%=isModeRemove%></xss:encodeForJavaScript>";
        if (isModeRemove == "true")
        {
            var strConfirmationMessage1 = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.RemoveClassification.ConfirmMessage")%></xss:encodeForJavaScript>";
            var strConfirmationMessage2 = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.Remove.ConfirmMsg")%></xss:encodeForJavaScript>";
                isToBeContinued = document.forms[0].elements['optionForAG'][1].checked ?
                    window.confirm(strConfirmationMessage1) : window.confirm(strConfirmationMessage2);
        }
        if (isToBeContinued)
        {
            var optionForAGValue	= document.forms[0].elements['optionForAG'][0].checked?"carry":"lose";
            var strForwardPageUrl	= "<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>" +"?"+ "<xss:encodeForJavaScript><%=queryString.toString()%></xss:encodeForJavaScript>" + "optionForAG=" + optionForAGValue;
            findFrame(getTopWindow(),"listHidden").location.href = strForwardPageUrl;
            closeWindow();
        }
    }



    function closeWindow()
    {
    	var isModeRemove    = "<xss:encodeForJavaScript><%=isModeRemove%></xss:encodeForJavaScript>";
    	var closeDiv = $('div[name=newLoad]',getTopWindow().document);
    	if(isModeRemove != "true"){
		   // Changes added by PSA11 start(IR-517183-3DEXPERIENCER2018x).
           // Changes added by PSA11 start(IR-487482-3DEXPERIENCER2018x).		   
		   var isFTS = getTopWindow().location.href.indexOf("common/emxFullSearch.jsp") != -1;
           if(isFTS){
    	      var sbFrame = findFrame(getTopWindow(),"structure_browser");	
		      if(sbFrame != null){
			     sbFrame.setSubmitURLRequestCompleted();
		      }			  
		   }
		   // Changes added by PSA11 end.
        }		   
    	closeDiv.remove();
    }
//-->
</script>
