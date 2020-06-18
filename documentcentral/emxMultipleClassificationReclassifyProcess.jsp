<%-- emxMultipleClassificationReclassifyProcess.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] ="$Id: emxMultipleClassificationReclassifyProcess.jsp.rca 1.6 Wed Oct 22 16:54:23 2008 przemek Experimental przemek $"
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file="../documentcentral/emxMultipleClassificationUtils.inc"%>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  String sRelSubclass             = LibraryCentralConstants.RELATIONSHIP_SUBCLASS;
  String sRelClassifiedItem       =           LibraryCentralConstants.RELATIONSHIP_CLASSIFIED_ITEM;
  String strObjectId              = emxGetParameter(request, "objectId");
  String fromPage                 = emxGetParameter(request, "fromPage");
  String attributesLost           = emxGetParameter(request, "attributesLost");

  attributesLost                  = UIUtil.isNullOrEmpty(attributesLost)?"":attributesLost;

  StringTokenizer strTokens = new StringTokenizer(strObjectId,",");
  Vector vecSelectedObjects = new Vector();
  boolean error = false;
  while(strTokens.hasMoreTokens())
  {
    vecSelectedObjects.addElement(strTokens.nextToken());
  }
  Object[] objChildIds = (Object[])vecSelectedObjects.toArray();
  int iSize = objChildIds.length;
  String[] childIds = new String[iSize];
  for(int k=0;k<iSize;k++)
  {
    childIds[k] = (String)objChildIds[k];
  }
  String strNewParentObjectId    = emxGetParameter(request, "parentObjectId");
  String stroldParentObjectId    = emxGetParameter(request, "oldParentObjectId");
  HashMap map = new HashMap();
  String errorStr = "";
   try
    {
      map = (HashMap)com.matrixone.apps.classification.Classification.reclassify(context, childIds, stroldParentObjectId, strNewParentObjectId);
    }
    catch(Exception e)
    {
    	errorStr = getErrorMessage(e.getMessage());
		// Changes added by PSA11 start(IR-532112-3DEXPERIENCER2018x).
        errorStr = errorStr.replaceAll("java.lang.Exception:", "");
        // Changes added by PSA11 end.		
        error = true;
    }
    if(error){
%>
 <script language="javascript">
          alert("<xss:encodeForJavaScript><%=errorStr%></xss:encodeForJavaScript>");
</script>
<%
   }else{
%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="emxLibraryCentralUtilities.js"></script>
<script language="javascript" type="text/javaScript">
    try {
        var vTop         = "";
        var vWinOpener   = "";
        var vCloseWindow = "";
        if("classifiedItemsList" == "<xss:encodeForJavaScript><%=fromPage%></xss:encodeForJavaScript>") {
            if ("true" == "<xss:encodeForJavaScript><%=attributesLost%></xss:encodeForJavaScript>") {
            	vTop = getTopWindow();
            } else {
                // changes for IR-552090-3DEXPERIENCER2018x
                vWinOpener = getTopWindow().getWindowOpener();
                if(vWinOpener != null && vWinOpener != "undefined"){
                    vTop = vWinOpener.getTopWindow();
                }else{
                    vTop = getTopWindow();
                }
            	vCloseWindow = getTopWindow();
            }
        } else {
        	vCloseWindow= parent;
        }
		// Changes added by PSA11 start(IR-533734-3DEXPERIENCER2018x). Update of count to of the new Parent to be done before old parent.
        // update the count of new parent
        updateCount('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',vTop,'<xss:encodeForJavaScript><%=strNewParentObjectId%></xss:encodeForJavaScript>');		
        // update the count of old parent 
        updateCount('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',vTop);
        //setTimeout("vTop.refreshTablePage()",1000); // time out is added for fixing bug "FF 10: 'Search' page fails to disappear after reclassifying end items. "
        vTop.refreshTablePage();
        if ("true" != "<xss:encodeForJavaScript><%=attributesLost%></xss:encodeForJavaScript>") {
        	vCloseWindow.closeWindow();
        }
		// refresh the Tree for LBC
		refreshTreeLBC();
    }catch (ex) {
    }
</script>
<%}%>
