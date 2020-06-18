<%--
  smaSearchUtil.jsp

  Copyright (c) 1992-2003 MatrixOne, Inc.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: smaSearchUtil.jsp.rca 1.30.1.1 Fri Dec  2 11:26:34 2005 sroy Experimental young young young young chen $";

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "matrix.util.StringList"%>

<html>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>


<%

try
{
    Enumeration enumParam = request.getParameterNames();
//    while (enumParam.hasMoreElements())
//    {
//        String name = (String) enumParam.nextElement();
//        String value = emxGetParameter(request, name);
//        System.out.println(name + ": " + value);
//    }

    StringBuffer sbCmd = new StringBuffer(1);
    String sComment = "";

    String history = emxGetParameter(request, "history");
    
    StringList hist  = FrameworkUtil.split(history,"|");
    String objectId  = (String)hist.get(0);
    String objAction = (String)hist.get(1);
    
    sbCmd.append("modify bus $1");//.append(objectId);
    sbCmd.append(" add history $2");//.append("\"" + objAction + "\"");

    // Checkin history - grab file names
    if ( objAction.equalsIgnoreCase("Checkin") )
    {
        String docName  = "";
        String docTitle = "";
        String docFiles = "";

        // Name of document into which the files are checked in
        if ( hist.size() > 1 ) docName = (String)hist.get(2);
        if ( hist.size() > 2 ) docTitle = (String)hist.get(3);
        if ( !docName.equals(docTitle) )
        {
            if ( docTitle.length() > 0 )
            {
                if ( docName.length() > 0 )
                    docName = docTitle + " (" + docName + ")";
                else
                    docName = docTitle;
            }
        }
        
        while (enumParam.hasMoreElements())
        {
            String name = (String) enumParam.nextElement();
            if ( name.startsWith("fileName") )
            {
                String file = emxGetParameter(request, name);
                if ( file.trim().length() > 0 )
                    docFiles += ", " + file;
            }
        }
        
        // Remove leading comma and set history
        if ( docFiles.length() > 2 )
        {
            docFiles = docFiles.substring(2);
            if ( docFiles.indexOf(",") > 0 )
                sComment = "Checked files: " + docFiles;
            else
                sComment = "Checked file: " + docFiles;

            sComment += " into: " + docName;

            sbCmd.append(" comment $3");//.append("\"" + sComment + "\"");
            MqlUtil.mqlCommand(context, sbCmd.toString(),objectId,objAction,sComment );
        }
    }

}
catch (Exception e)
{}
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script text="text/javascript">
	getTopWindow().closeWindow();
</script>

</html>

