<%--emxLibraryCentralRetentionScheduleDeleteProcess.jsp-

    Brief Description
    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

        Author     :Suman Kumar Jha
        Date       :28/01/07
        History    :

    static const char RCSID[] = $Id: emxLibraryCentralRetentionScheduleDeleteProcess.jsp.rca 1.2.1.4 Wed Oct 22 16:02:16 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>


<%

    Vector vecObjectIds = new Vector();
    StringList strinvalid =new StringList();
    StringList strvalid =new StringList();
    boolean bhasDelete=false;

    //Getting RowID
    String objIds[] = emxGetParameterValues(request,"emxTableRowId");
    objIds = getTableRowIDsArray(objIds);
  String strCurrent = "";
  String policyRetentionRecord = PropertyUtil.getSchemaProperty(context, "policy_RetentionRecord");
  String recordStateCreated  = FrameworkUtil.lookupStateName(context, policyRetentionRecord, "state_Created");

    //Getting ObjectID one by One.
    if(objIds!= null)
    {
        for(int i=0;i<objIds.length;i++)
        {

            StringTokenizer st   = new StringTokenizer(objIds[i],"|");

            String sObjId = "";
            while(st.hasMoreTokens())
            {
                sObjId = st.nextToken();
            }
            objIds[i] = sObjId;
            vecObjectIds.addElement(sObjId);
        }//End of for.
    }//End of if.

    //Checking Access "delete" for states.
    //Deleting Object after checking.
    try
    {
        if (objIds.length > 0)
        {
            DomainObject domObj ;

            for (int i = 0; i < objIds.length; ++i)
            {

                domObj = DomainObject.newInstance(context, objIds[i]);
                strCurrent = domObj.getInfo(context,"current");
                String deleteAccess=domObj.getInfo(context,"current.access[delete]");
                
                String retainedRel = PropertyUtil.getSchemaProperty(context, "relationship_RetainedRecord");
                String retainedDocuments = domObj.getInfo(context,"from["+retainedRel+"].id");
                
                boolean hasRetainedDocuments = true;
                if(retainedDocuments == null || retainedDocuments.equals("") || retainedDocuments.equals("null")){
                	hasRetainedDocuments = false;
                }
                
                String strName=domObj.getName(context);
                //if has delete acess then delete.
                if ("TRUE".equalsIgnoreCase(deleteAccess)  && recordStateCreated.equals(strCurrent) && !hasRetainedDocuments)
                {
                      DomainObject baseObject =(DomainObject)DomainObject.newInstance(context,objIds[i]);
                      baseObject.deleteObject(context);
                } else {
                      strinvalid.add(strName);  
                }
            }//End of for.

        }//End of if.

    }//End of try.

    catch(Exception e)
    {
        System.out.println("Exception...  "+e);
    }//End of catch
%>

<script language="javascript" type="text/javaScript">
    //if Object is not in Created State then give alert message.
    if(<xss:encodeForJavaScript><%=!strinvalid.isEmpty()%></xss:encodeForJavaScript>) {
        var errorMessage = "\n - <emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Message.CannotDeleteRetentionSchedule</emxUtil:i18nScript>" + "\n\n" + "<xss:encodeForJavaScript><%=strinvalid%></xss:encodeForJavaScript>";
        alert(errorMessage);
    }
    refreshTablePage();

</script>


