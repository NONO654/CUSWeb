<%@include file = "../common/emxNavigatorInclude.inc"%>

<html>

	<head>
		<title></title>
		<%@include file = "../common/emxUIConstantsInclude.inc"%>
		<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
		<%@include file = "../common/emxVPMCreateVPMAction.inc"%>

		<%@page import = "com.matrixone.vplmintegration.util.*"%>

    </head>

    <body>
    	<%
    	String targetLocation = emxGetParameter(request, "targetLocation");
    	String msgString = null;
    	String url = null;
    	String browser = request.getHeader("USER-AGENT");
        boolean isIE = browser.indexOf("MSIE") > 0;
        StringBuffer parametersBuffer = new StringBuffer();
    	try{
    		//Get the language
    		String languageStr = request.getHeader("Accept-Language");

    		//Create the arguments
    		Hashtable argTable = new Hashtable();

        	//Pass all the arguments in the URL
    		Map parameters = request.getParameterMap();
    		java.util.Set keys = parameters.keySet();
    		Iterator keysItr = keys.iterator();

    		while(keysItr.hasNext()){
    			String key = (String) keysItr.next();
    			String value[] = (String[])parameters.get(key);

    			if(parametersBuffer!=null && !parametersBuffer.toString().isEmpty()){
					parametersBuffer.append("&");
				}
				parametersBuffer.append(key + "=" + value[0]);

    			if(value!=null && value[0].toString().length()>0){
    				if(key.equals("type")){
    					String vpmType = convertMatrixTypeToVPLMType(value[0].toString());
    					String custo = getDomainFromPLMType(vpmType);
    					argTable.put(key,custo);

    				}else{
    					AttributeType type = null;
    					type = new AttributeType(key);
    					if(null!= type){
    						String dataType = "";
    						try{
    							type.open(context);
    							dataType = type.getDataType();
    							type.close(context);
    						}catch(Exception e){
    							session.putValue("error.message", e.getMessage());
    						}

    						// Don't use the "real" dates but only their hidden value (*_msvalue)
    						if( !dataType.equals("timestamp")){
    							// Add it in list of attributes only if it's the hidden (*_msvalue) value
    							if(key.contains("_msvalue")){
    								long date = Long.parseLong(value[0].toString()) / 1000;
    								String strDate = ""+date;
    								String strKey = key.substring(0, key.lastIndexOf("_msvalue"));
                                	argTable.put(strKey,strDate);
    							}
    							// Is not a "real" date
    							else{
    								argTable.put(key,value[0].toString());
    							}
    						}
    					}
    				}
    			}
    		}
    		String [] args  = JPO.packArgs(argTable);

    		// Invoke the JPO - Succeed: display the created ECA in an emxTree - Failed: go back to emxVPMCreateVPMActionFS.jsp
    		Hashtable matrixObjIDvplmObjIDMap = new Hashtable();
    		try{
    			matrixObjIDvplmObjIDMap = (Hashtable)JPO.invoke(context, "emxVPMTaskBase", null, "createVPMAction", args, Hashtable.class);
    		}catch (Exception e){
    			String errorMessage = "";
    			session.putValue("error.message", e.getMessage());
    			if(e.getMessage().contains("not unique")){
    				errorMessage = UINavigatorUtil.getI18nString("emxVPMCentral.Change.CreateECA.Exception.NameNotUnique", "emxVPMCentralStringResource", languageStr);
    			}else{
    				errorMessage = UINavigatorUtil.getI18nString("emxVPMCentral.Change.CreateECA.Exception.CommitFailed", "emxVPMCentralStringResource", languageStr);
    			}
    			url = "../common/emxVPMCreateVPMAction.jsp?errorMessage="+errorMessage+"&"+parametersBuffer.toString();
    			response.sendRedirect(url);
    			throw new MatrixException(errorMessage);
    		}

    		if(matrixObjIDvplmObjIDMap!=null && matrixObjIDvplmObjIDMap.size()>0){
    			String m1id = (String) matrixObjIDvplmObjIDMap.get("OBJECTID");
    			url = "../common/emxTree.jsp?objectId="+m1id;
    		}

    		%>
    		<script language="javascript">
    			var topWindow = top.opener? top.opener : top;
    			<%if("slidein".equalsIgnoreCase(targetLocation)){%>
    				topWindow = findFrame(top,"detailsDisplay");
    				if(!topWindow){
    					topWindow = findFrame(top,"content");
    				}
    			<%}%>

    			var contentFrame = findFrame(topWindow.top, "content");
	            if(contentFrame){
                    contentFrame.document.location.href = "<%=url%>";
                }
	            <%if("slidein".equalsIgnoreCase(targetLocation)){%>
	            	top.closeSlideInDialog();
	            <%}else{%>
	            	if (top.opener && isIE){
	            		closePopupWindow(top);
	            	}else if (top.opener){
	            		top.close();
	            	}
	            <%}%>
    		</script>

    	<%}catch(Exception exception){
    		exception.printStackTrace();
    		msgString = exception.getMessage();
    		emxNavErrorObject.addMessage(msgString);
    	}%>

    	<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

    </body>
</html>

