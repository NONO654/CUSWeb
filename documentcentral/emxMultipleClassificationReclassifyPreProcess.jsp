<%-- emxMultipleClassificationReclassifyPreProcess.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] ="$Id: emxMultipleClassificationReclassifyPreProcess.jsp.rca 1.4 Wed Oct 22 16:54:22 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../documentcentral/emxLibraryCentralUtils.inc"%>
<jsp:useBean id="libraries" class="com.matrixone.apps.library.Libraries" scope="session"/>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
    boolean isClassification     = false;
    boolean isInheritedAGPresent = false;
    boolean showPopup            = false;
    boolean isInherited = true;
//
// Check if the parent object is Classification
//

    String strObjectId          = emxGetParameter(request, "objectId");
    String strNewParentObjectId = emxGetParameter(request, "parentObjectId");
    String stroldParentObjectId = emxGetParameter(request, "oldParentObjectId");
    String strSelectedObjectId  = strObjectId;
    String classificationMode   =(String)emxGetParameter(request, "classificationMode");
    String fromPage             =(String)emxGetParameter(request, "fromPage");
    classificationMode          = UIUtil.isNullOrEmpty(classificationMode)? "" :classificationMode;
    if("classifiedItemsList".equals(fromPage)) {
        strNewParentObjectId = getTableRowIDsString((String[]) emxGetParameterValues(request, "emxTableRowId"));
        strObjectId = getTableRowIDsString(libraries.getObjectRowID());
        stroldParentObjectId = emxGetParameter(request, "objectId");
    } else if(!UIUtil.isNullOrEmpty(classificationMode) && "reClassification".equals(classificationMode)) {
        //from classified item page
        strNewParentObjectId    = emxGetParameter(request, "ClassOID");
        stroldParentObjectId    = emxGetParameter(request, "selectedClassIds");
    }
    
//
// Find if object has inherited attributes
//

    StringList strParentlistAttributeGroupsInherited    = new StringList();
    StringList strOldParentlistAttributeGroupsInherited = new StringList();

    StringList strNewParentlistAttributesInherited    = new StringList();
    StringList strOldParentlistAttributesInherited = new StringList();

        //
        // In case the classification under the Library node is tried to move the old parent of the
        // classification will not be another classification, in that case we will not be able to find the
        // attribute groups of such old parent, so the following check is necessary. The new parent will always
        // be the classification object anyways.
        //
        DomainObject dObjOldParent = new DomainObject(stroldParentObjectId);
        if (dObjOldParent.isKindOf(context, LibraryCentralConstants.TYPE_CLASSIFICATION))
        {
            com.matrixone.apps.classification.Classification objOldParentClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context,stroldParentObjectId,"Classification");

            strOldParentlistAttributeGroupsInherited = objOldParentClassification.getAttributeGroups(context, isInherited);
        }

        dObjOldParent = null; // Done with this object !

        StringList slNewParentObjectIds = FrameworkUtil.split(strNewParentObjectId, "|");
        
        for (int i = 0 ; i < slNewParentObjectIds.size() ; i++)
        {
            com.matrixone.apps.classification.Classification objParentClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context,(String)slNewParentObjectIds.get(i),"Classification");

            strParentlistAttributeGroupsInherited.addAll(objParentClassification.getAttributeGroups(context, isInherited));
        }


        com.matrixone.apps.classification.AttributeGroup attGrp = null;
        String strAttributeGroupName = "";
        StringList listAttributes = null;
		
        for(int iCnt = 0 ; iCnt < strOldParentlistAttributeGroupsInherited.size() ; iCnt ++){

            strAttributeGroupName =(String)strOldParentlistAttributeGroupsInherited.get(iCnt);
            attGrp = AttributeGroup.getInstance(context,strAttributeGroupName);
            listAttributes = attGrp.getAttributes();
			// Changes added by PSA11 start(IR-505016-3DEXPERIENCER2018x).
			if(listAttributes!=null){
			   for(int i=0;i<listAttributes.size();i++ ){
            	 strOldParentlistAttributesInherited.addElement((String)listAttributes.elementAt(i));
               }	
			}
			// Changes added by PSA11 end.
        }
        for(int iCnt = 0 ; iCnt < strParentlistAttributeGroupsInherited.size() ; iCnt ++){

            strAttributeGroupName =(String)strParentlistAttributeGroupsInherited.get(iCnt);
            attGrp = AttributeGroup.getInstance(context,strAttributeGroupName);
            listAttributes = attGrp.getAttributes();
			// Changes added by PSA11 start(IR-505016-3DEXPERIENCER2018x).
			if(listAttributes!=null){
			  for(int i=0;i<listAttributes.size();i++ ){
            	strNewParentlistAttributesInherited.addElement((String)listAttributes.elementAt(i));
              }	
			}
			// Changes added by PSA11 end.
        }

        if(!strNewParentlistAttributesInherited.containsAll(strOldParentlistAttributesInherited))
        {
                showPopup = true;
        }
%>

<%
    //Accumulate all the parameters
    StringBuffer sbufAppendParameters = new StringBuffer(256);

    for(Enumeration e = emxGetParameterNames(request); e.hasMoreElements(); )
    {
        String strParamName = (String)e.nextElement();
        String strParamValue = (String)emxGetParameter(request, strParamName);


        if (sbufAppendParameters.length() > 0)
        {
            sbufAppendParameters.append("&");
        }
        sbufAppendParameters.append(strParamName+"="+strParamValue);
    }
%>


<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%
    //
    // Form a page url to which this page should be submitted
    // If both the conditions are satisfied then  show the popup window else
    // go to the process page directly.
    String strForwardPageUrl = "";
    if (showPopup)
    {

        strForwardPageUrl = "emxMultipleClassificationReclassifyFS.jsp";
        if(classificationMode != null && !"null".equals(classificationMode) && "reClassification".equals(classificationMode)) {
            strForwardPageUrl = strForwardPageUrl + "?objectId="+strObjectId+"&parentObjectId="+strNewParentObjectId+"&oldParentObjectId="+stroldParentObjectId+"&classificationMode="+classificationMode+"&fromPage="+fromPage;
        }else if (sbufAppendParameters.length() > 0) {
            strForwardPageUrl = strForwardPageUrl + "?objectId="+strObjectId+"&parentObjectId="+strNewParentObjectId+"&oldParentObjectId="+stroldParentObjectId+"&classificationMode="+classificationMode+"&fromPage="+fromPage;
        }
%>
        <script language="javascript">
		//Start for IR 484176
		 function registerEvent()
        {
        	var contentWindow = getTopWindow().modalDialog.contentWindow;
        
        	 if(contentWindow)
        		 {
        		 if(contentWindow.addEventListener)
        			contentWindow.addEventListener("unload" , setSubmitUrlRequestFalse,false);
        		 else if(contentWindow.attachEvent)
        			 contentWindow.attachEvent("onunload" , setSubmitUrlRequestFalse); 
        		 }
        }
        function setSubmitUrlRequestFalse()
        {
        	
        	if(getTopWindow().sb && getTopWindow().sb.setSubmitURLRequestCompleted) {
        		getTopWindow().sb.setSubmitURLRequestCompleted();
        	}
        }
		//end IR484176
            showModalDialog("<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>", "600", "500", false);
			setTimeout("registerEvent()",150); //for IR 484176
        </script>
<%
    }//if !
    else
    {
        if(classificationMode != null && !"null".equals(classificationMode) && "reClassification".equals(classificationMode)) {
%>
            <script language="javascript">
                parent.callSaveChanges();
            </script>
<%
         }else {
            strForwardPageUrl = "emxMultipleClassificationReclassifyProcess.jsp?parentObjectId="+strNewParentObjectId+"&oldParentObjectId="+stroldParentObjectId+"&objectId="+strObjectId+"&fromPage="+fromPage+"";
%>
       	<form name="formSubmit" method="post" target = "listHidden" action="emxMultipleClassificationReclassifyProcess.jsp">
       	<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
       	<input type="hidden" name="parentObjectId" value="<xss:encodeForJavaScript><%=strNewParentObjectId%></xss:encodeForJavaScript>"/>
       	<input type="hidden" name="oldParentObjectId" value="<xss:encodeForJavaScript><%=stroldParentObjectId%></xss:encodeForJavaScript>"/>
       	<input type="hidden" name="objectId" value="<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>"/>
       	<input type="hidden" name="fromPage" value="<xss:encodeForJavaScript><%=fromPage%></xss:encodeForJavaScript>"/>
        <script language="Javascript">
        <%--     document.location.href = "<xss:encodeForJavaScript><%=strForwardPageUrl%></xss:encodeForJavaScript>"; --%>
        document.formSubmit.submit();
        </script>
        </form>
<%
         }
    }
%>
