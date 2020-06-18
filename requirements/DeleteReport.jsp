<%--
  DeleteReport.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = ;

 --%>
 
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
       are added under respective scriplet
      @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
      @quickreview T25 DJH 2014:03:03 HL Single Shot Deletion of Requirement Specification.
      @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%
	boolean isFromSearchDialog = "true".equalsIgnoreCase(emxGetParameter(request, "fromSearch"));
	boolean isFromStructureBrowser = "true".equalsIgnoreCase(emxGetParameter(request, "isFromStructureBrowser"));
	String timeStamp = emxGetParameter(request, "timeStamp");      
 %>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" language="JavaScript">
        //addStyleSheet("emxUIDefault");
        //addStyleSheet("emxUIList");
        //addStyleSheet("emxUISearch");

function popupObjectDialog(oid)
{
	showNonModalDialog("../common/emxTree.jsp?emxSuiteDirectory=common&suiteKey=Framework&relId=&parentOID=null&jsTreeID=null&objectId=" + oid, 900, 600,true )

}        
<%
try
{
  	String key = emxGetParameter(request, "key"); 
	if(key != null){ 
		Map deleteResult = (Map)session.getAttribute(key);
		if(deleteResult != null){
			int totalObjects = ((Integer)deleteResult.get("totalObjects")).intValue();
			Vector deleteObjects = (Vector)deleteResult.get("deletedObjects");
			boolean needRefresh = (deleteObjects.size() > 0 && !"true".equalsIgnoreCase((String)deleteResult.get("childrenDelete")));

%>
function getAllTableRowIds(win){
    var checkboxArray = new Array();

	var deleteObjects = '<xss:encodeForJavaScript><%=deleteObjects.toString().replace("[", "" ).replace("]", "").replace(" ", "")%></xss:encodeForJavaScript>'.split(',');
    for(var i = 0; i < deleteObjects.length; i ++){
	    var aRowsSelected = emxUICore.selectNodes(win.oXML,"/mxRoot/rows//r[@o='" + deleteObjects[i] + "']");
	    var chkLen = aRowsSelected.length;
	    for(var j = 0; j < chkLen; j++){
	       var id = aRowsSelected[j].getAttribute("id");
	       var oid = aRowsSelected[j].getAttribute("o");
	       var relid = aRowsSelected[j].getAttribute("r");
	       if (relid == null || relid == "null") {
	          relid = "";
	       }
	       var parentId = aRowsSelected[j].getAttribute("p");
	       if (parentId == null || parentId == "null") {
	          parentId = "";
	       }
	       var totalRowInfo = relid + "|" + oid + "|" + parentId + "|" + id;
	       checkboxArray[checkboxArray.length] = totalRowInfo;
	    }
    }
    return checkboxArray;
}

function refreshWindow(win)
{
	if(<xss:encodeForJavaScript><%=isFromStructureBrowser%></xss:encodeForJavaScript>){
	
		if(win.emxEditableTable && win.emxEditableTable.isRichTextEditor){//rich text editor
<%			for(Object oid : deleteObjects)
			{	%>
				win.deleteObject("<xss:encodeForJavaScript><%=oid%></xss:encodeForJavaScript>");
<%			}	%>
		} 
		else{ //structure browser popup
		    var cBoxArray = getAllTableRowIds(win);
		    win.emxEditableTable.removeRowsSelected(cBoxArray);
		}
	} else
	if(<xss:encodeForJavaScript><%=isFromSearchDialog%></xss:encodeForJavaScript>){
      var contentFrame = findFrame(win,"searchView");       
       if (contentFrame != null) {
           document.frm.action = "../common/emxTable.jsp";
           document.frm.target ="searchView";
           document.frm.submit();
        }
	} else
	if(win.refreshTreeDetailsPage && win.refreshTreeDetailsPage()){ //category list view
		//alert("refreshed tree details.");
	} else 
	if(win.refreshContentPage && win.refreshContentPage()){ //list view
		//alert("refreshed content frame");
	}
	
}

function refreshParentAndClose()
{
 //KIE1 ZUD TSK447636 
	var openerwin = getTopWindow().getWindowOpener();
	
	//should only refresh parent window if there is any objects get deleted.
	if(<xss:encodeForJavaScript><%=needRefresh%></xss:encodeForJavaScript>){
		refreshWindow(openerwin);
	}
	 //KIE1 ZUD TSK447636 
	getTopWindow().closeWindow();
}



</script>
<style type="text/css">
ul {
    /* list-style: none;  */
    margin-left: 0px; 
    padding-left: 0px;
}
li {
	margin-left: 40px;
	padding-left: 0px; 
}
</style>
</head>
<body onunload="refreshParentAndClose()">
<%
				if(isFromSearchDialog && timeStamp != null){
%>
    <jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/> 
    <form name="frm">
<%				    
			        Map requestMap = (Map)tableBean.getRequestMap(timeStamp);
			        if (requestMap != null)
			        {
			            java.util.Set keys = requestMap.keySet();
			            Iterator itr = keys.iterator();
			            String paramName = null;
			            String paramValue = null;
			            while(itr.hasNext()) 
			             {
			                paramName = (String)itr.next();
			                try 
			                 {
			                   paramValue = (String)requestMap.get(paramName);
			                 }catch(Exception ClassCastException) 
			                 {
			                    //Ignore the exception
			                 }
			        %>
			            <input type="hidden" name="<%=paramName%>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>" />
			        <% 
			             } 
			        }
%>
    </form>
			    
<%	
				}
				
				String suiteKey = emxGetParameter(request, "suiteKey");
	  			String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
				if("true".equalsIgnoreCase((String)deleteResult.get("childrenDelete"))){
%>
	<emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.DeleteChildrenFail</emxUtil:i18nScript>
<%
				}else{
				String[] arrFormatMessageArgs = new String[2];
                arrFormatMessageArgs[0] = (totalObjects - deleteObjects.size()) + "";
                arrFormatMessageArgs[1] = totalObjects + "";
                if(emxGetParameter(request, "mode")==null){
%>
	<xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.Delete.Error.DeleteSelectedFail",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
                            
<%}
				}
				List reservedObjects = (List)deleteResult.get("reserveCheck");
				List frozenObjects = (List)deleteResult.get("stateCheck");
				List readonlyObjects = (List)deleteResult.get("accessCheck");
				List parentCheckObjects = (List)deleteResult.get("parentCheck");
				List childCheckObjects = (List)deleteResult.get("childCheck");
				List r2rObjects = (List)deleteResult.get("r2rCheck");
				List exceptionObjects = (List)deleteResult.get("exceptionCheck");
				
				if(reservedObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.Reserved</emxUtil:i18nScript><br/>
<%				
					for(int i = 0; i < reservedObjects.size(); i++){
						Map values = (Map)reservedObjects.get(i);
						String[] arrFormatMessageArgs = new String[2];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = (String)values.get("reservedby");
						
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.Delete.Error.ReservedBy",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
</li>
<%
					}
%>
	</ul>
<%					
				}
				
				if(frozenObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.State</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < frozenObjects.size(); i++){
						Map values = (Map)frozenObjects.get(i);
						String[] arrFormatMessageArgs = new String[2];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = i18nNow.getStateI18NString("", (String)values.get("current"), request.getLocale().toString());
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.Delete.Error.CurrentState",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML></li>
<%
					}
%>
	</ul>
<%					
				}
				
				if(readonlyObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.Access</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < readonlyObjects.size(); i++){
						Map values = (Map)readonlyObjects.get(i);
%>
<li><a href="javascript:popupObjectDialog('<xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_ID)%></xss:encodeForHTMLAttribute>')">
	<xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_NAME)%></xss:encodeForHTMLAttribute> <xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_REVISION)%></xss:encodeForHTMLAttribute>
</a> </li>
<%
					}
%>
	</ul>
<%					
				}
				

				if(parentCheckObjects.size() > 0){
					int count = 0;
					for(int i = 0; i < parentCheckObjects.size(); i++)
          {
						boolean ifDetachedAndDeleted = false;
						Map values = (Map)parentCheckObjects.get(i);
						if(deleteObjects.size() > 0 && emxGetParameter(request, "mode")!=null && emxGetParameter(request, "mode").equals("deleteAll") ){
							
							for(int j = 0; j < deleteObjects.size(); j++){
								Map tempvalues = (Map)deleteObjects.get(j);
								 if(tempvalues.get(DomainConstants.SELECT_ID).equals(values.get(DomainConstants.SELECT_ID)))
								 {
									 ifDetachedAndDeleted = true; // when the object is in detached object list as well as in deleted objects list
									 break;
								 }
								
								}
						}
						if(!ifDetachedAndDeleted)
						{
							if(count==0) //add this message in report only once
							{
							    if(emxGetParameter(request, "mode")!=null && emxGetParameter(request, "mode").equals("deleteAll")){
								%>		
								   <p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.ParentCheck2</emxUtil:i18nScript><br/>	
								<%	}		
													else{
								%>
									<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.ParentCheck</emxUtil:i18nScript><br/>
									
								<%
								}
								count++;
							}
							%>
							<li><a href="javascript:popupObjectDialog('<xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_ID)%></xss:encodeForHTMLAttribute>')">
							<xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_NAME)%></xss:encodeForHTMLAttribute> <xss:encodeForHTMLAttribute><%=	values.get(DomainConstants.SELECT_REVISION)%></xss:encodeForHTMLAttribute>
							</a> </li>
							<%
                        }
					}
%>
	</ul>
<%					
				}
				
				if(deleteObjects.size() > 0 && emxGetParameter(request, "mode")!=null && emxGetParameter(request, "mode").equals("deleteAll")){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.DeleteSuccess</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < deleteObjects.size(); i++){
						Map values = (Map)deleteObjects.get(i);
%>
<li><xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_NAME)%></xss:encodeForHTMLAttribute> <xss:encodeForHTMLAttribute><%=values.get(DomainConstants.SELECT_REVISION)%></xss:encodeForHTMLAttribute>
 </li>
<%
					}
%>
	</ul>
<%					
				}

				if(childCheckObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.ChildCheck</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < childCheckObjects.size(); i++){
						Map values = (Map)childCheckObjects.get(i);
%>
<li><a href="javascript:popupObjectDialog('<xss:encodeForHTML><%=values.get(DomainConstants.SELECT_ID)%></xss:encodeForHTML>')">
	<xss:encodeForHTML><%=values.get(DomainConstants.SELECT_NAME)%></xss:encodeForHTML> <xss:encodeForHTML><%=values.get(DomainConstants.SELECT_REVISION)%></xss:encodeForHTML>
</a> </li>
<%
					}
%>
	</ul>
<%					
				}


				if(r2rObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.Rel2RelCheck</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < r2rObjects.size(); i++){
						Map values = (Map)r2rObjects.get(i);
%>
<li><a href="javascript:popupObjectDialog('<xss:encodeForHTML><%=values.get(DomainConstants.SELECT_ID)%></xss:encodeForHTML>')">
	<xss:encodeForHTML><%=values.get(DomainConstants.SELECT_NAME)%></xss:encodeForHTML> <xss:encodeForHTML><%=values.get(DomainConstants.SELECT_REVISION)%></xss:encodeForHTML>
</a> </li>
<%
					}
%>
	</ul>
<%					
				}


				if(exceptionObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.DeleteFail</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < exceptionObjects.size(); i++){
						Map values = (Map)exceptionObjects.get(i);
						String[] arrFormatMessageArgs = new String[2];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = (String)values.get("errorMsg");
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.Delete.Error.Exception",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
</li>
<%
					}
%>
	</ul>
<%					
				}

				
				session.removeAttribute(key);
			}
		}else{
		
		}
    }
    catch (Exception exp)
	{
		
		exp.printStackTrace(System.out);
		session.putValue("error.message", exp.getMessage());
		//throw exp;
	}
%>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
