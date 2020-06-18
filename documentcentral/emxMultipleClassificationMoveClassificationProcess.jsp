<%-- emxMultipleClassificationMoveClassificationProcess.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] = "$Id: emxMultipleClassificationMoveClassificationProcess.jsp.rca 1.7 Wed Oct 22 16:54:23 2008 przemek Experimental przemek $"
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file="emxMultipleClassificationUtils.inc"%>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  String sRelSubclass            = LibraryCentralConstants.RELATIONSHIP_SUBCLASS;
  String strObjectId             = emxGetParameter(request, "objectId");
  String strNewParentObjectId    = emxGetParameter(request, "parentObjectId");
  String stroldParentObjectId    = emxGetParameter(request, "oldParentObjectId");
  String optionForAG             = emxGetParameter(request, "optionForAG");
  String strMode                 = emxGetParameter(request, "Mode");
  boolean isClassification       = true;
  boolean isFromAttributeLostORCarryPage = !(null == optionForAG || "null".equalsIgnoreCase(optionForAG));
  boolean carryOverInheritedAttributeGroups = isFromAttributeLostORCarryPage && optionForAG.equalsIgnoreCase("Carry");
  HashMap map = new HashMap();
  
  StringBuffer sbMoveErrorMsg = new StringBuffer();
  boolean errorInMove = false;
  String languageStr = request.getHeader("Accept-Language");
  
//
// Find if object has inherited attributes
//
  if (isClassification)
  {
    com.matrixone.apps.classification.Classification objClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, strObjectId, "Classification");
    try
    {
      // Code altered for R216 Release.
      // Instead of the Classification Object of new parent, new parent's ID is passed.
      map = (HashMap)objClassification.reparent(context,strObjectId,stroldParentObjectId,strNewParentObjectId,carryOverInheritedAttributeGroups);
    }
    catch(Exception exp)
    {
      errorInMove = true;
      sbMoveErrorMsg.append(EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(languageStr),"emxDocumentCentral.Message.ObjectsNotMoved"));
    }
  }//if isClassification


%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>
<script language="javascript" src="../documentcentral/emxLibraryCentralUtilities.js"></script>
<script language=javascript>
    try {
        // delete the selected class from current parent

        var vTop         = "";
        var vCloseWindow = "";
		if(getTopWindow().getWindowOpener()=='undefined'|| getTopWindow().getWindowOpener()==null)//non popup
			vTop = getTopWindow();
		else
        vTop = getTopWindow().getWindowOpener().getTopWindow();
        vCloseWindow = getTopWindow();
        
		// Changes done by PSA11 start(IR-498425-3DEXPERIENCER2018x).
		if(<%=errorInMove%>){
        	var vErrorMsg   = "<xss:encodeForJavaScript><%=sbMoveErrorMsg.toString().trim()%></xss:encodeForJavaScript>";
        	alert(vErrorMsg);
			//changes done by ssi17 start(IR-552246-3DEXPERIENCER2019x)
			// for 3dSearch	its not required as it work on single frame
        		//vCloseWindow.close();
				
			//End ssi17	
        				
		} else {
            vTop.deleteObjectFromTrees('<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>',false);

		    // Update the count of New Parent before that of Old Parent. Done by PSA11 start(IR-514724-3DEXPERIENCER2018x).
            // update the count of new parent
            updateCountAndRefreshTreeLBC('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',vTop,'<xss:encodeForJavaScript><%=strNewParentObjectId%></xss:encodeForJavaScript>');

            // add the object under the new parent id
            vTop.addStructureTreeNode("<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=strNewParentObjectId%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>",vTop);		
		
            // update the count of old parent
            updateCountAndRefreshTreeLBC('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',vTop);		

		    // Changes done by PSA11 end.			
		}
       // Changes done by PSA11 end. 
       // vTop.refreshTablePage();
    } catch(exec){
    }
</script>
