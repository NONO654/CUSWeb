<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import="java.text.*,java.io.*, java.util.*, javax.xml.parsers.DocumentBuilderFactory"%>
<%@page import="javax.xml.parsers.DocumentBuilder,javax.json.Json,javax.json.JsonArrayBuilder,javax.json.JsonObject,javax.json.JsonObjectBuilder, org.w3c.dom.*"%>
<%@page import="com.matrixone.apps.common.Lifecycle,com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>
<%
	try{
	
	String objectId			= request.getParameter("objectId");
	String rootObjectId		= request.getParameter("rootobjectId");
	String operationName	= request.getParameter("operationName");
	
	context 		= Framework.getFrameContext(session);
	
	String message = null;
	
	if(!isNullOrEmpty(operationName)) {
		 
		message = executeOperation(context, objectId, operationName);
	}

	if(!isNullOrEmpty(message)) {
		JsonObjectBuilder returnData = Json.createObjectBuilder();
        returnData.add("result", "begin_process_msg:" + message + ":end_process_msg");
		response.setContentType("application/json");
		response.setHeader("Content-Disposition", "inline");
		if(null!=message){
            String msg=returnData.build().toString();		 
			msg= unescape(msg);
			response.getWriter().write(msg);
		}
		out.flush();	
	}

	} catch (Exception exp) {
		exp.printStackTrace();
		throw exp;
	}
%>

<%!
private boolean isNullOrEmpty(String input)
{
	if(input == null || input.equals("") || input.equals("null")) return true;
	
	return false;
}

//TODO: This function needs to be in ProcessDashboard class
private String executeOperation(Context context, String objectId, String operationName)
{
	String errorMsg = DomainObject.EMPTY_STRING;
	try {
		DomainObject activeObj =  DomainObject.newInstance(context, objectId);
		if (operationName.equals("promote")) { //TODO: comment this and uncomment previous line after moving to ProcessDashboard
        com.matrixone.apps.framework.lifecycle.LifeCycleUtil.checksToPromoteObject(context, activeObj);
			activeObj.promote(context);
		}
			ClientTaskList listNotices = context.getClientTasks();
			ClientTaskItr itrNotices = new ClientTaskItr(listNotices);
			StringBuilder sbMessages = new StringBuilder();
			while (itrNotices.next()) {
				ClientTask clientTaskMessage = itrNotices.obj();
				sbMessages.append(" : ").append((String) clientTaskMessage.getTaskData());
			}
			if (!isNullOrEmpty(sbMessages.toString())) {
				errorMsg = errorMsg + " " + sbMessages.toString();
				context.clearClientTasks();
			}
	} catch (Exception e) {
		ClientTaskList listNotices 	= context.getClientTasks();	
	ClientTaskItr itrNotices 	= new ClientTaskItr(listNotices);
	StringBuilder sbMessages	= new StringBuilder();
	 errorMsg=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Error.OperationFailed");
	if(e.getMessage().contains("Cannot promote - all requirements not satisfied")){
		errorMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.LifeCycle.PromotionFailed.ErrorMessage");
	}else{
	while (itrNotices.next()) {
		ClientTask clientTaskMessage =  itrNotices.obj();
			sbMessages.append(" : ").append((String) clientTaskMessage.getTaskData());
		}
		if((sbMessages.toString()).isEmpty()){
		int errCode = 0;
        ErrorMessage mxErrMsg = new ErrorMessage(e.getMessage()); 
        if (mxErrMsg != null)
            errCode = mxErrMsg.getErrorCode();
        if (errCode == 5000001){
            String sErrorMsg = mxErrMsg.getMessage();
            int pos = sErrorMsg.indexOf("#5000001:");
            if (pos > -1){
                sErrorMsg = sErrorMsg.substring(pos+9).trim();
                sbMessages.append(sErrorMsg);
            }
        }
	}
	errorMsg = errorMsg + " "+sbMessages.toString();
	}
	context.clearClientTasks();
	errorMsg = errorMsg.replace("\"", "\\\"");
	}
	return errorMsg;
	}
	
   public static String unescape(String input) {
		    StringBuilder builder = new StringBuilder();

		    int i = 0;
		    while (i < input.length()) {
		      char delimiter = input.charAt(i); i++; // consume letter or backslash

		      if(delimiter == '\\' && i < input.length()) {

		        // consume first after backslash
		        char ch = input.charAt(i); i++;

		        if(ch == '\\' || ch == '/' || ch == '"' || ch == '\'') {
		          builder.append(ch);
}
		        else if(ch == 'n') builder.append('\n');
		        else if(ch == 'r') builder.append('\r');
		        else if(ch == 't') builder.append('\t');
		        else if(ch == 'b') builder.append('\b');
		        else if(ch == 'f') builder.append('\f');
		        else if(ch == 'u') {

		          StringBuilder hex = new StringBuilder();

		          // expect 4 digits
		          if (i+4 > input.length()) {
		            throw new RuntimeException("Not enough unicode digits! ");
		          }
		          for (char x : input.substring(i, i + 4).toCharArray()) {
		            if(!Character.isLetterOrDigit(x)) {
		              throw new RuntimeException("Bad character in unicode escape.");
		            }
		            hex.append(Character.toLowerCase(x));
		          }
		          i+=4; // consume those four digits.

		          int code = Integer.parseInt(hex.toString(), 16);
		          builder.append((char) code);
		        } else {
		          throw new RuntimeException("Illegal escape sequence: \\"+ch);
		        }
		      } else { // it's not a backslash, or it's the last character.
		        builder.append(delimiter);
		      }
		    }

		    return builder.toString();
		}%>
	
}

