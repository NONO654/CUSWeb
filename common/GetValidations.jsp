<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%@ page import = "com.matrixone.servlet.Framework" %>
<%@ page import = "matrix.db.*,java.io.*" %>

	<%
		
		String suiteKey = request.getParameter("suiteKey");
		String paths = null;
		String[] validationFilesNames;
		
		if(suiteKey==null || "".equals(suiteKey) || "Framework".equals(suiteKey)){
			return;
		} else {
			System.out.println("inside the new jsp in DataGrid "+suiteKey);
			Context context = Framework.getContext(session);
			
			String validationFile = EnoviaResourceBundle.getProperty(context, "eServiceSuite"+suiteKey+".UIFreezePane.ValidationFile");
			String suiteDirectory = UINavigatorUtil.getRegisteredDirectory(context, suiteKey);
			// if there is only single validation file specified in the emxSystem.proprties file
			if(validationFile.indexOf(',')==-1){
				paths = "../"+suiteDirectory+"/"+validationFile ;

			%>
			<jsp:include page="<%=paths%>" flush="true"></jsp:include>
			<%
			}
			// if there are multiple validation files then include each of them
			else if(validationFile.indexOf(',')!=-1){
				validationFilesNames = validationFile.split(",");	
				for(String validationFileName: validationFilesNames){	
					paths = "../"+suiteDirectory+"/"+validationFileName;
					%>
					<jsp:include page="<%=paths%>" flush="true"></jsp:include>
					<%
				} 
			}
		
		}

	%>


