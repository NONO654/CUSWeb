<%--  emxLibraryCentralObjectAddEndItems.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Add contents to given Buisness object
   Parameters : childIds
                objectId

   Author     :
   Date       :
   History    :

    static const char RCSID[] = $Id: emxLibraryCentralObjectAddEndItems.jsp.rca 1.9 Wed Oct 22 16:02:16 2008 przemek Experimental przemek $;

   --%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file = "emxLibraryCentralUtils.inc" %>

<%@page	import="java.io.PrintWriter"%>
<%
    String sClassification  = LibraryCentralConstants.TYPE_CLASSIFICATION;
    String parentId         = emxGetParameter(request, "objectId");
	//edit by yuf 
	String shipScope = emxGetParameter(request, "shipScope");
	System.out.println("shipScope-------------"+shipScope);
	
	//edit end
	
	String childIds[]       = null;
	  
	//edit by yuf   
	String selectionIds         = emxGetParameter(request, "selectionIds");
	if(selectionIds!=null && selectionIds.length()>0){	
		childIds = selectionIds.split(",");
		for(int s = 0;s<childIds.length;s++){
			String oid = childIds[s];
			ContextUtil.pushContext(context);
			MqlUtil.mqlCommand(context,"modify bus "+oid+"  PLMEntity.V_description  '"+shipScope+"' ");
			ContextUtil.popContext(context);
		}
		
	}else{
		
		childIds = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));
	}
	//edit by yuf 
	
	/*String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
	DomainObject dom = DomainObject.newInstance(context);
	
	for(int i = 0;i<ids.length;i++){
		String oid = ids[i];
		dom.setId(oid);
		String sName = dom.getInfo(context,"name");
		String shipScopValue = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
		if(UIUtil.isNullOrEmpty(shipScopValue)){
		PrintWriter ps = response.getWriter();
			ps.write("<script>alert('"+sName+"\u6ca1\u6709\u9002\u7528\u8239\u578b\u53ca\u9002\u7528\u8303\u56f4\uff01')</script>");
			ps.write("<script>window.close()</script>");
			ps.flush();
		}	
	}*/
	
	
    String folderContentAdd = emxGetParameter(request, "folderContentAdd");
	 String sNoConnectMessage = "";
	 StringBuffer errorMessage = new StringBuffer();
    try{
		StringList childInfoSelectable = new StringList();
		childInfoSelectable.add("current.access[toconnect]");
		MapList mlChildInfo = DomainObject.getInfo(context, childIds, childInfoSelectable);
		Iterator itr = mlChildInfo.iterator();
		String access = "";
		while(itr.hasNext()){
			 Map childInfo = (Map)itr.next();
			access = (String)childInfo.get("current.access[toconnect]");
			System.out.println("current.access[toconnect]:"+access);
		}
		String strResult = "";
		if(access.equalsIgnoreCase("TRUE"))
			  strResult  = (String)Classification.addEndItems(context,parentId,childIds);
		else
		{
			sNoConnectMessage = "".equals(sNoConnectMessage)?sNoConnectMessage = 
			 EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(context.getSession().getLanguage()),"emxLibraryCentral.Message.CannotConnectObjectAddItem")
			 : sNoConnectMessage;
		}
    } catch(Exception e) {
		e.printStackTrace();
        session.setAttribute("error.message",getSystemErrorMessage (e.getMessage()));
		// Changes added by PSA11 start(IR-532768-3DEXPERIENCER2018x).
		errorMessage.append(EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(context.getSession().getLanguage()),"emxLibraryCentral.Message.TypeNotClassifiable"));
		// Changes added by PSA11 end.
    }
%>

<script language="JavaScript" src="../components/emxComponentsTreeUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="emxLibraryCentralUtilities.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">
<% 
if(!"".equals(sNoConnectMessage)){
%>
    alert("<%=sNoConnectMessage%>");
<%
} else if(!"".equals(errorMessage.toString())){
%>	
	alert("<%=errorMessage.toString()%>");
<%	
} %>     

    try {
	 <% if("".equals(sNoConnectMessage)){%>
		var vTop         = "";
		if(getTopWindow().getWindowOpener()=='undefined' || getTopWindow().getWindowOpener()==null)//non popup
			vTop = getTopWindow();
		else
			vTop = getTopWindow().getWindowOpener().getTopWindow();
		updateCountAndRefreshTreeLBC("<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>", vTop);
        getTopWindow().closeWindow();
    
    <%}%>
    }catch (ex){
    	getTopWindow().closeWindow();
    }
</script>

