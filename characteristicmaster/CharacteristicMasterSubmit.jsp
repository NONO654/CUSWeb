<%--  CharacteristicMasterSubmit.jsp  --  
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
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
                <script type="text/javascript" src="../common/scripts/emxUIFormHandler.js"></script>
                <script type="text/javascript" src="scripts/CharacteristicMasterFormValidation.js"></script>
                <script type="text/javascript">
                    try {
                        var $fields = top.opener.$("form[name='emxCreateForm'] #DimensionId");
                        $.each($fields, function(i, field){
                            var type = "<%=XSSUtil.encodeForJavaScript(context, paramType)%>";
							var typeNLS = "<%=XSSUtil.encodeForJavaScript(context, paramTypeNLS)%>";
                            var found = -1;
                            $.each(field, function(j, option_j){
                                if (option_j.value == type)
                                    found = j;
                            });
                            
                            if (found == -1)
                            {       
                            	//getTopWindow()
                                var opt = top.opener.document.createElement('option');
                                opt.selected = true; 
                                field.options.add(opt);
                                opt.innerHTML = typeNLS;  
                                opt.value = type;
                               
                                field.selectedIndex = field.length-1;
                            }
                            else
                                field.selectedIndex = found;
                                                   
                        });
                        
                        var dimension = top.opener.$("form[name='emxCreateForm'] #DimensionId");
                        top.opener.onDimensionChange();
                        
                        
                    } catch (e) {
                        alert(e.message);
                    }
                </script>
                <%
            }
        }
        %>
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
