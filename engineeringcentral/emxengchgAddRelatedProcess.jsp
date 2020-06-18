<%--emxengchgAddRelatedProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
	String strChangeObjId     = emxGetParameter(request, "strChangeObjId");
	String sObjPartId         = emxGetParameter(request, "objectId");
	
	String sRelId = "";
	String sObjChildId = ""; 
	StringTokenizer st = null;
	
   	String checkBoxId1[] = emxGetParameterValues(request,"emxTableRowId");
   	
   	String strLanguage = context.getSession().getLanguage();    

   	String dojObjName="";
	if(checkBoxId1 != null) {
	    try {
	        for(int i=0; i < checkBoxId1.length; i++) {
                if(checkBoxId1[i].indexOf("|") != -1) {
                    st = new StringTokenizer(checkBoxId1[i], "|");
                    sRelId = st.nextToken();
                    sObjChildId = st.nextToken();	
                } else {
                    sObjChildId = checkBoxId1[i];
                }

				String affectedItemRel = PropertyUtil.getSchemaProperty(context, "relationship_AffectedItem");
				DomainRelationship domrel = new DomainRelationship();
				//Modified for IR-153632 start
				try {
                	domrel.connect(context,strChangeObjId,affectedItemRel,sObjChildId,true);
				} catch(Exception ex) {
					session.setAttribute("error.message", ex.getMessage());
				}
				//Modified for IR-153632 end
            }
        } catch (Exception e) {
            session.setAttribute("error.message", e.getMessage());
        }
    } else {
    	//Multitenant
    	//String strWarning=i18nNow.getI18nString("emxEngineeringCentral.Message.strAddRelatedMessage","emxEngineeringCentralStringResource",strLanguage);
    	String strWarning=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Message.strAddRelatedMessage"); 
%>
			<Script language="JavaScript">
			//XSSOK
			alert("<%=strWarning%>");
			</Script>
<%
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" type="text/javaScript">
    /*try {
		//To Take the page to Affected Item page after Refreshing the table
		var objWin = getTopWindow().getWindowOpener().parent;
		if(getTopWindow().getWindowOpener().parent.name == "treeContent") {
			objWin=getTopWindow().getWindowOpener();
			objWin.document.location.href = objWin.document.location.href;
			parent.window.close();
		} else if (parent.window.getWindowOpener().parent != null)  {
	        var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content")
	        var conTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
	        conTree.doNavigate = true;
	        getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
	        parent.window.close();
        }
    } catch(exec) {
        parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
        parent.window.close();
    }*/

    //Modified for IR-134422
    //top.getWindowOpener().getTopWindow().refreshTablePage();
    getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
    getTopWindow().closeWindow();
    
</script>
