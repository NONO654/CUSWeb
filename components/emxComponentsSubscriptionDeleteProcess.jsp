<%--  emxComponentsSubscriptionDeleteProcess.jsp 

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSubscriptionDeleteProcess.jsp.rca 1.1.7.5 Wed Oct 22 16:18:55 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
        String emxTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
        String id = "";
        String[] relIdArray = new String[emxTableRowIds.length];
        try
        {
            for(int i=0;i<emxTableRowIds.length;i++)
            {

                id = emxTableRowIds[i];

                StringTokenizer st = new StringTokenizer(id, "|");

                while (st.hasMoreTokens())
                {
                    relIdArray[i] = st.nextToken() ;
                    st.nextToken();
                    if(st.hasMoreTokens()){
                    	st.nextToken();
                    }
                }

            }
            ContextUtil.startTransaction(context, true);
            DomainRelationship.disconnect(context,relIdArray);
            ContextUtil.commitTransaction(context);

        }
        catch(Exception ex)
        {
                ContextUtil.abortTransaction(context);
                if(ex.toString() != null && (ex.toString().trim()).length()>0){
                        emxNavErrorObject.addMessage("emxSearch:" + ex.toString().trim());
                }
        }

%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language ="javascript">
    getTopWindow().refreshTablePage();
</script>
