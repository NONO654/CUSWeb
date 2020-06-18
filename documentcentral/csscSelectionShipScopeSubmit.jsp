<%@include file = "../emxUICommonAppInclude.inc"%>

<%@include file = "emxLibraryCentralUtils.inc" %>


<%

String[]  strSelectedCollections = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
String parentId         = emxGetParameter(request, "objectId");
String objectIds = "";
String errorIds = "";
String otherTypeIds = "";
String popUrl = "";
String selectType = "VPMReference";
	ContextUtil.pushContext(context);
	for(int i = 0;i<strSelectedCollections.length;i++){
		String oid = strSelectedCollections[i];
		System.out.println("oid--------"+oid);
		if(oid!=null && oid.length()>0){
		String sType = MqlUtil.mqlCommand(context,"print bus "+oid+" select type dump");
		if(selectType.equals(sType)){
			String shipScopeValue = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
			if(shipScopeValue!=null && shipScopeValue.length()>0&&shipScopeValue.contains(";")){
				String [] shipScopes = shipScopeValue.split(";");
				if(shipScopes.length!=2){
					errorIds+=oid+",";
				}else{
					objectIds+=oid+",";
				}
				
			}else{
				errorIds+=oid+",";
			}
		}
		
		if(!selectType.equals(sType)){
			otherTypeIds+=oid+",";
		}
		}
	}
		ContextUtil.popContext(context);
		objectIds = objectIds+otherTypeIds;
	
	System.out.println("objectIds------"+objectIds);
	System.out.println("errorIds-----"+errorIds);
	
	 String sNoConnectMessage = "";
	 StringBuffer errorMessage = new StringBuffer();
	if(objectIds!=null && objectIds.length()>0){ 
			String sClassification  = LibraryCentralConstants.TYPE_CLASSIFICATION;
			String[]childIds = objectIds.split(",");
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
	}

	
%>
<script language="JavaScript" src="../components/emxComponentsTreeUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="emxLibraryCentralUtilities.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">

<script language="JavaScript" type="text/javascript">
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

</script>

 <script language="JavaScript" type="text/javascript">  
		var objectIds ="<%=objectIds%>";
		if(objectIds!=null && objectIds!=""){
			vTop = getTopWindow();
			updateCountAndRefreshTreeLBC("<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>", vTop);
			getTopWindow().closeWindow();
		}
		
		var errorIds = "<%=errorIds%>";
		var parentId = "<%=parentId%>";
		if(errorIds!=null && errorIds!=""){
			//var popurl = "csscSelectionShipScope.jsp?objectId="+errorIds+"&parentId="+parentId;
			var openUrl = "csscSelectionShipScope.jsp?objectId="+errorIds+"&parentId="+parentId;
			var iWidth=900; //弹出窗口的宽度;  
			var iHeight=700; //弹出窗口的高度;  
			var iTop = (window.screen.availHeight-30-iHeight)/2; //获得窗口的垂直位置;  
			var iLeft = (window.screen.availWidth-10-iWidth)/2; //获得窗口的水平位置;  
			window.open(openUrl,"","height="+iHeight+", width="+iWidth+", top="+iTop+", left="+iLeft);   
		}

</script>

