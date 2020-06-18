<%--  emxParameterSubmitNewParamType.jsp  --  Delete the selected parameters
  Copyright (c) 1992-2012 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxParameterStartTransaction.inc"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%
    try {
        String types[] = emxGetParameterValues(request, "emxTableRowId");
        int size = null != types ? types.length : -1;
        for (int i=0; i<size; i++)
        {
            String type_i = types[i];
			String paramType = "" , paramTypeNLS = "" ;
			
            if ((null != type_i) && !type_i.isEmpty())
            {
                if (type_i.startsWith("|"))
                    type_i = type_i.substring(1);
                int pipesIdx = type_i.indexOf("||");
                if (pipesIdx > 0)
                    type_i = type_i.substring(0, pipesIdx);
				
				StringTokenizer str = new StringTokenizer(type_i,"|");
				
				if(str.hasMoreTokens()){
					paramType = str.nextToken();					
				}
				
				if(str.hasMoreTokens()){
					paramTypeNLS = str.nextToken();					
				}
				
                %>
                <script src="../common/scripts/jquery-latest.js"></script>
                <script src="emxParameterUIFormCreateValidation.jsp"></script>
                <script type="text/javascript">
                    try {
                        var $fields = top.opener.$("form[name='emxCreateForm'] #Dimension");
                        $.each($fields, function(i, field){
                            var type = "<%=paramType%>";
							var typeNLS = "<%=paramTypeNLS%>";
							
                            var found = -1;
                            $.each(field, function(j, option_j){
                                if (option_j.value == type)
                                    found = j;
                            });
                            
                            if (found == -1)
                            {                                          
                                var opt = top.opener.document.createElement('option');  
                                field.options.add(opt);
                                opt.innerHTML = typeNLS;  
                                opt.value = type;
                               
                                field.selectedIndex = field.length-1;
                            }
                            else
                                field.selectedIndex = found;
                            
                            onParameterComboChange(field, false);
                        });
                    } catch (e) {
                        alert(e.message);
                    }
                </script>
                <%
            }
        }
        %>
        <%@ include file = "emxParameterCommitTransaction.inc" %>
        <%
    } catch (Exception ex) {
        %>
        <script type="text/javascript">
            alert("Exception");
        </script>
        <%
        System.out.println("SubmitNewParamType : type retrieval failed: " + ex.getMessage());
        emxNavErrorObject.addMessage("New parameter type selection failed : " + ex.getMessage());
        %>
        <%@ include file = "emxParameterAbortTransaction.inc" %>
        <%
    } finally {
        %>
        <script type="text/javascript">
            top.close();
        </script>
        <%
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
