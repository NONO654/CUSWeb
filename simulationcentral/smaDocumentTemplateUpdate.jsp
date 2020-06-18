<html>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.common.CommonDocument"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import  ="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "matrix.db.BusinessObject"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<body>

<%

String fileObjectId  = emxGetParameter(request, "objectId");

String commandForFileBusName = "print bus $1 select $2 dump",
       fileBusName = MqlUtil.mqlCommand(context,commandForFileBusName,true,fileObjectId,"name"),
       outputOfTempQuery = MqlUtil.mqlCommand(context,"temp query bus $1 $2 $3 where $4 select $5 dump", true, "*", 
    		   fileBusName,"*","latest == TRUE","id");
String[] infoFromTempQuery =  outputOfTempQuery.split(",");
String fileObjectIdOfLatestFile = infoFromTempQuery[infoFromTempQuery.length-1];

if(!fileObjectId.equals(fileObjectIdOfLatestFile)){
  
  String[] objIDsOfFiles = {fileObjectIdOfLatestFile};
  String commandToGetDocumenetFromFile = "print bus $1 select $2 dump";
  String docId = MqlUtil.mqlCommand(context,commandToGetDocumenetFromFile,true,fileObjectIdOfLatestFile,"to[Latest Version].from.id");
  CommonDocument commonDocument = (CommonDocument)DomainObject.newInstance(context,docId);
  commonDocument.deleteVersion(context, objIDsOfFiles, false);
}

try
{       
    BusinessObject verDoc = new BusinessObject(fileObjectId);
    if(!verDoc.isLocked(context))
    {
        boolean  oldTransaction  =  context.isTransactionActive();
        // pause the context
        if (oldTransaction)  
            context.commitWithCheck();        
        if (!verDoc.isLocked(context))
            verDoc.lock(context);        
    }
}
catch(Exception e)
{
    e.printStackTrace();
    System.out.println
    ("ERROR: Internal Server Error while trying to " +
            "lock document for update.");
}

StringBuffer href = new StringBuffer(256);
                            href.append("../components/emxCommonDocumentPreCheckin.jsp?")
                            .append("objectId=").append(fileObjectId)
                            .append("&objectAction=").append("update")
                            .append("&largeFileUpdate=true")
                            .append("&forceApplet=true")
                            .append("&showFormat=readonly")
                            .append("&appProcessPage=smaClose.jsp")
                            .append("&appDir=simulationcentral")  
                            .append("&showComments=required");
                              
%>
    <script>
        getTopWindow().document.location.href = "<%=href.toString() %>";
                             
    </script>

</body>
</html>
