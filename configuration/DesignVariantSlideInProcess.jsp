<%--
  DesignVariantSlideInProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
try
{   
	String strLevel = emxGetParameter(request, "strLevel");
	String objectId = emxGetParameter(request, "objectId");//LF id for which DV being manipulated
	
%>
	<script language="javascript" type="text/javaScript">

       //var varLevel='<%=XSSUtil.encodeForJavaScript(context,strLevel)%>';
       var contentFrameObj = findFrame(getTopWindow(),"FTRSystemArchitectureLogicalFeatures");//Product->LF
       if(typeof contentFrameObj == 'undefined' || contentFrameObj == null ){
    	   contentFrameObj = findFrame(getTopWindow(),"FTRContextLFLogicalFeatures");//LF->LF
       }
       if(typeof contentFrameObj == 'undefined' || contentFrameObj == null ){
    	   contentFrameObj = findFrame(getTopWindow(),"content");//pageContentDiv MyDesk->LF
       }
       var varObjectId='<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
	   var rowsToRefresh = emxUICore.selectNodes(contentFrameObj.oXML, "/mxRoot/rows//r[@o = '" + varObjectId + "']");
   	   if(rowsToRefresh!=null && rowsToRefresh.length>0){//LF Exist in OXML
		for(var i=0;i<rowsToRefresh.length;i++){//Iterate on all LF Exist in OXML
		 var curRowToRefresh=rowsToRefresh[i];
	 	 var varlevel2=curRowToRefresh.getAttribute("id");
		 arrIds2=[];
		 arrIds2.push(varlevel2);//put current row level id in array to refresh row
         var currentTagTokens2 = varlevel2.split("," );
         var tempLength2 = currentTagTokens2.length;//get depth of current row
		 if(tempLength2>2){//if it is 2 level- will not need to iterate to parent
		   if(curRowToRefresh.parentNode!=null 
				&& curRowToRefresh.parentNode.getAttribute("id")!=null 
				   && curRowToRefresh.parentNode.getAttribute("id").split(",").length>2){//check parent row level id
					   arrIds2.push(curRowToRefresh.parentNode.getAttribute("id"));
					   var parentNode=curRowToRefresh.parentNode;
					   while(parentNode.getAttribute("id").split(",").length>2){
				    	   var rowsToRefreshParent= parentNode.parentNode;
				    	   varlevel2=rowsToRefreshParent.getAttribute("id");
				    	   arrIds2.push(varlevel2);
				    	   parentNode=rowsToRefreshParent;
					   }
		  }else if(curRowToRefresh.parentNode!=null 
					&& curRowToRefresh.parentNode.getAttribute("id")!=null 
					   && curRowToRefresh.parentNode.getAttribute("id").split(",").length==2){//if parent level is 2- add to array to refresh row
					   arrIds2.push(curRowToRefresh.parentNode.getAttribute("id"));
		  }
		}
        for(var j=0;j<arrIds2.length;j++){//iterate all rows- and call refresh by row id
          console.log("refresh-"+arrIds2[j]);
 		  contentFrameObj.emxEditableTable.refreshRowByRowId(arrIds2[j]);
        }
	   }
	  }else{//oxml doesn't content lf- refresh complete SB
		contentFrameObj.editableTable.loadData();
		contentFrameObj.emxEditableTable.refreshStructureWithOutSort();
	  }
      getTopWindow().closeSlideInDialog();//Close slidein
    </script>	
<%
}catch(Exception e){ 
            session.putValue("error.message", e.getMessage());
}
%>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
