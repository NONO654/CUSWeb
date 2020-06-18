<%--  emxLibraryCentralPostProcess.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralPostProcess.jsp.rca 1.7 Wed Oct 22 16:02:39 2008 przemek Experimental przemek $
   
--%>

<html>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../documentcentral/emxLibraryCentralUtils.inc"%>

<%
try{
    String objectId          = emxGetParameter(request, "objectId");
    String parentOId         = emxGetParameter(request, "parentOID");
    String mode              = emxGetParameter(request, "mode");
    String suiteKey          = emxGetParameter(request, "suiteKey");
    String createInOId       = emxGetParameter(request, "Create InOID");
    String sUrl              = "";

    // isClassified item should be true for classified items.
    // We should not add classified items to the structure tree
    String classifiedItem    = emxGetParameter(request, "isClassifiedItem");
    boolean isClassifiedItem = classifiedItem != null && "true".equals(classifiedItem);
    boolean addStructure     = false;
    
    if(!UIUtil.isNullOrEmpty(mode) && "create".equals(mode) || "copy".equals(mode)|| "revise".equals(mode)) {
        objectId            = emxGetParameter(request, "newObjectId"); 
       
        // the created object should be added to structure only if it is not classified item and
        //1) if  the mode is copy or revise  or create
        addStructure   = (!isClassifiedItem && 
                          ("copy".equals(mode)|| "revise".equals(mode) ||"create".equals(mode)));               
    }
    //Code to set all the Classification Attributes during create. -- now use update functions --
	//-- code removed as part of IR-652485-3DEXPERIENCER2019x -- BAE3 --
    
%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="../documentcentral/emxLibraryCentralUtilities.js"></script>
<script language=javascript>
    var vParentOID      = "<xss:encodeForJavaScript><%=parentOId%></xss:encodeForJavaScript>";
    var vMode           = "<xss:encodeForJavaScript><%=mode%></xss:encodeForJavaScript>";
    var vObjectId       = "<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
    var vAppDirectory   = "<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>";
    var vSuiteKey       = "<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>";
    var vCreateInOID    = "<xss:encodeForJavaScript><%=createInOId%></xss:encodeForJavaScript>";
    if (<xss:encodeForJavaScript><%=addStructure%></xss:encodeForJavaScript> && getTopWindow().objStructureTree) {
        // For copy and revise ParentOID will be selected node ID. 
        // But we have to add the node under the parent of the select Id
        if ("copy" == vMode || "revise" == vMode) {
            vParentOID = getTopWindow().objStructureTree.getSelectedNode().getParent().objectID;
        } else if ("create" == vMode) {
            vParentOID = vCreateInOID;
        }
        getTopWindow().addStructureTreeNode(vObjectId,vParentOID,vAppDirectory,getTopWindow());  
    } else if (<xss:encodeForJavaScript><%=isClassifiedItem%></xss:encodeForJavaScript>) {
        updateCountAndRefreshTreeLBC(vAppDirectory, getTopWindow());
        if ("create" == vMode) {
            // need to launch files page after creation of Generic doc/Document Sheet
            var vDocUrl = "../common/emxTree.jsp?AppendParameters=true&objectId="+vObjectId+"&suiteKey="+vSuiteKey+"&mode=insert";
            var displayFrame      = getTopWindow().findFrame(getTopWindow(),"content");
            if(getTopWindow().objDetailsTree && getTopWindow().emxUIConstants.STR_UITREE_OLDUI == "true") {
                   var jsTreeID   = getTopWindow().objDetailsTree.getSelectedNode().nodeID;
                   vDocUrl       += "&jsTreeID="+jsTreeID;                   
            }
            displayFrame.document.location.href = vDocUrl;
                                   
        }
    } else{    	
    	 if("edit"== vMode){
       	 updateCountAndRefreshTreeLBC(vAppDirectory, getTopWindow().getWindowOpener().getTopWindow(),vParentOID);
		}
	}
    
<%
}catch(Exception err){
	err.printStackTrace();
}
%>

</script>
</html>

