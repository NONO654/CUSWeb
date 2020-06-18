<%--  emxParameterResetCreateForm.jsp  --  Reset the create form
  Copyright (c) 1992-2012 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
 --%>

<script src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">
    try {
        $(document).ready(function()
        {
            var $fields = parent.$("form[name='emxCreateForm'] #Name, form[name='emxCreateForm'] #Title, form[name='emxCreateForm'] :input[name='Description'],"
                + " form[name='emxCreateForm'] #Value, form[name='emxCreateForm'] #Min, form[name='emxCreateForm'] #Max");
            $.each($fields, function(i, field){
                var toBeUpdated = true;
                if (field.id == "Value")
                {
                    if ("[object HTMLSelectElement]" == field.valueOf())
                    {
                        field.options[0].selected = true;
                        //field.value = "TRUE";
                        toBeUpdated = false;
                    }
                }
                if (toBeUpdated)
                {
                    field.value = "";
                    if (field.id == "Name")
                    {
                        field.disabled = true;
                        field.requiredValidate = "";
                    }
                }
            });
            
            var $fieldsToCheck = parent.$("form[name='emxCreateForm'] :checkbox[name='autoNameCheck'], form[name='emxCreateForm'] #minIncludedId,  form[name='emxCreateForm'] #maxIncludedId");
            $.each($fieldsToCheck, function(i, fieldToCheck){
               fieldToCheck.checked = true; 
            });
        });
    } catch (e) {
    }
</script>
