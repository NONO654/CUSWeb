<%--  emxTreeRefresh.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxTreeRefresh.jsp.rca 1.5 Wed Oct 22 15:47:53 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>


<!DOCTYPE html>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<script language="javascript" type="text/javascript" src="scripts/emxUICore.js"></script>
<script language="Javascript">
function refreshtree(obj, isStructure){
    setTimeout(function _refreshtree(){
        var curtree = getTopWindow().objDetailsTree; 
        if(isStructure) {
            curtree = getTopWindow().objStructureTree;
        }
        curtree.displayFrame=obj; 
        curtree.doNavigate = false; 
        curtree.refresh();
    },200);	
}
</script>

<% if (emxGetParameter(request,"tree").equals("details")) {%>
<body onload="refreshtree(this, 'false')">
<% } else { %>
<body onload="refreshtree(this, 'true')">
<% } %>

</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
