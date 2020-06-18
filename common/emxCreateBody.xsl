<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:aef="http://www.matrixone.com/aef">
        <xsl:output method="html" version="1.0" encoding="UTF-8" indent="no" />
        <xsl:variable name="timeStamp" select="aef:setting[@name = 'timeStamp']" />
        <xsl:variable name="uiAutomation" select ="//aef:requestMap/aef:setting[@name='uiAutomation']" />
        <xsl:template name="pageBody">
                <form name="emxCreateForm" autocomplete="off" method="post" onsubmit="return false;">
                		<xsl:if test="$uiAutomation = 'true' ">
							<script>
								jQuery('[name="emxCreateForm"]').attr("data-aid","<xsl:value-of select="//aef:requestMap/aef:setting[@name='form']" />");
         			    	</script>
						</xsl:if>  		
                        <input type="hidden" id="timeStamp" name="timeStamp" value="{aef:setting[@name = 'timeStamp']}" />
                        <input type="hidden" id="uiType" name="uiType" value="form" />
                        <input type="hidden" id="mode" name="mode" value="create" />
                        <script>
 							var requestMapJavaScript = {};
                        <xsl:for-each select="//aef:requestMap/aef:setting[not(@name='timeStamp')]">
                        	requestMapJavaScript["<xsl:value-of select="@name" />"] = "<xsl:value-of select="text()" />"; 	
         			   </xsl:for-each>
                      			for(var propt in requestMapJavaScript){
    								jQuery('[name="emxCreateForm"]').append('<input type="hidden"  name="' + propt + '"  value="' + requestMapJavaScript[propt] + '"></input>'); 
								}				
         			    </script>
                        <table class="form">
                                 <tr>
                  <xsl:choose>
                  <xsl:when test="$slideinui = 'true'">
                  </xsl:when>
                  <xsl:otherwise>
                    <td></td>
                  </xsl:otherwise>
                  </xsl:choose>
                                       <td class="createRequiredNotice"> 
                                               <xsl:value-of select="aef:setting[@name = 'fieldsinred']"/>
                                       </td>
                                 </tr>
                                 <xsl:apply-templates select="aef:UnsupportedFieldTypeSetting" />
                                 <xsl:choose>
                                    <xsl:when test="$slideinui = 'true'">
                                        <xsl:apply-templates select="aef:fields/aef:field" mode="global-slidein"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="aef:fields/aef:field" mode="global"/>
                                    </xsl:otherwise>
                                   </xsl:choose>
                        </table>
                </form>
        </xsl:template>

        <xsl:template match="aef:UnsupportedFieldTypeSetting">
        <script>
                 alert("<xsl:value-of select = "aef:setting[@name = 'Message'] " />");
         </script>
        </xsl:template>
<!-- HORIZONTAL GROUPING  -->
<xsl:template match="//aef:fields/aef:field" mode="horizontal">
         <xsl:param name="grpName"/>
         <xsl:param name="grpCount"/>
         <xsl:param name="grpPositon"/>
        <xsl:variable name="varGrpName" select ="aef:settings/aef:setting[@name = 'Group Name']" />
        <xsl:variable name="varVerticalCount" select="aef:settings/aef:setting[@name = 'Vertical Group Count']" />
        <xsl:variable name="varVerticalGroup" select="aef:settings/aef:setting[@name = 'Vertical Group Name']" />
        <xsl:variable name="localPosition" select="position()"/>
         <xsl:variable name="Colspan" select="aef:settings/aef:setting[@name = 'Colspan']" />

        <xsl:variable name="hideLabel">
              <xsl:choose>
                     <xsl:when test="aef:settings/aef:setting[@name = 'Hide Label']">
                            <xsl:value-of select="aef:settings/aef:setting[@name = 'Hide Label']" />
                     </xsl:when>
                     <xsl:otherwise>false</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
        <xsl:if test="normalize-space($grpName) = normalize-space($varGrpName) and ($localPosition &lt;= number($grpCount + $grpPositon) and ($localPosition &gt;= $grpPositon))">
                <xsl:choose>
                   <xsl:when test="(number($varVerticalCount) &gt; 1 )">        
                                <xsl:call-template name="vertical">
                                        <xsl:with-param name="varVerticalGroupName" select="$varVerticalGroup" />
                                        <xsl:with-param name="varGroupName" select="$varGrpName" />
                                        <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                        <xsl:with-param name="Colspan" select="$Colspan" />

                                </xsl:call-template>
                   </xsl:when>
                   <xsl:when test="(normalize-space($varGrpName) = normalize-space($grpName) and string-length($varVerticalCount) = 1)" >
                           <xsl:if test="normalize-space($hideLabel) = 'false'">
                                   <xsl:choose>
                                    <xsl:when test="$slideinui = 'true'">
                                        <xsl:call-template name="label-slidein">
                                                <xsl:with-param name="groupName" select="$varGrpName" />
                                                <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="label">
                                                <xsl:with-param name="groupName" select="$varGrpName" />
                                                <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                   </xsl:choose>
                                </xsl:if>
                                <xsl:call-template name="field">
                                </xsl:call-template>
                      </xsl:when>
                   <xsl:when test="(normalize-space($varGrpName) = normalize-space($grpName)) and (string-length($varVerticalGroup) = 0)" >
                           <xsl:if test="normalize-space($hideLabel) = 'false'">
                                        <xsl:choose>
                                      <xsl:when test="$slideinui = 'true'">
                                          <xsl:call-template name="label-slidein">
                                                  <xsl:with-param name="groupName" select="$varGrpName" />
                                                  <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                          </xsl:call-template>
                                      </xsl:when>
                                      <xsl:otherwise>
                                          <xsl:call-template name="label">
                                                  <xsl:with-param name="groupName" select="$varGrpName" />
                                                  <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                          </xsl:call-template>
                                      </xsl:otherwise>
                                     </xsl:choose>
                                </xsl:if>
                                <xsl:call-template name="field">
                                </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                      </xsl:otherwise>
                </xsl:choose>
      </xsl:if>
</xsl:template>

<xsl:template match="aef:fields/aef:field" mode="global" >
        <xsl:variable name="varFieldType" select="aef:settings/aef:setting[@name = 'Field Type']" />
        <xsl:variable name="varGroupName" select="aef:settings/aef:setting[@name = 'Group Name']" />
        <xsl:variable name="varVerticalGroupName" select="aef:settings/aef:setting[@name = 'Vertical Group Name']" />
        <xsl:variable name="varGroupCount" select="aef:settings/aef:setting[@name = 'Group Count']" />
        <xsl:variable name="varDynamicField" select="aef:settings/aef:setting[@name = 'Dynamic Attribute']" />
        <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="varTableField" select="./@TableField" />
        <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)" />
                <xsl:choose>
                        <xsl:when test="$Field_Type = 'image' and string-length($varGroupName) = 0 and string-length($varVerticalGroupName) = 0 and string-length($varTableField) = 0" >
                                <tr id="calc_{@name}">
                                 <td class="createLabel">
                                        <xsl:value-of select="@name" />
                                 </td>
                                 <td class="createInputField">
                                        <xsl:element name="img">
                                                <xsl:attribute name="src">images/<xsl:value-of select="aef:settings/aef:setting[@name = 'Image'] "/></xsl:attribute>
                                                <xsl:attribute name="border">0</xsl:attribute>
                                                <xsl:attribute name="height">16</xsl:attribute>
                                                <xsl:attribute name="width">16</xsl:attribute>
                                        </xsl:element>
                                 </td>
                                </tr>
                        </xsl:when>
                        <xsl:when test="$Field_Type = 'section header'">
                                <tr>
                                <xsl:variable name="ColSpan" select="aef:settings/aef:setting[@name = 'Colspan']" />
                                        <td>
                                               <xsl:attribute name="colspan">
                <xsl:choose>
                        <xsl:when test="string-length($ColSpan) &gt; 0" >
                                <xsl:value-of select="$ColSpan" />
                        </xsl:when>
                        
                </xsl:choose>
        </xsl:attribute>
                                                <xsl:attribute name="class">
                                                        <xsl:choose>
                                                                <xsl:when test="@sectionLevel = '1'">heading1</xsl:when>
                                                                <xsl:otherwise>heading2</xsl:otherwise>
                                                        </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:value-of select="@label" />
                                        </td>
                                </tr>
                        </xsl:when>

                        <xsl:when test="$Field_Type = 'section separator'">
                        <tr>
                            <td align="center">&amp;#160;</td>
                        </tr>
                        </xsl:when>
                        <xsl:when test="$Field_Type = 'table holder'">
                        <tr>
                                <xsl:call-template name="TableHolder">
                                        <xsl:with-param name="varTableName" select="./@TableHolder"/>
                                </xsl:call-template>
                        </tr>
                      </xsl:when>
                      <xsl:when test="$Field_Type = 'dynamic attributes'">
                              <tr id="calc_{@name}">
                                        <xsl:call-template name="DynamicAttributes">
                                        <xsl:with-param name="fieldName" select="./@DynamicAttribute" />
                                        </xsl:call-template>
                              </tr>
                      </xsl:when>
                      <xsl:when test="$Field_Type = 'dynamic'">
                              <tr id="calc_{@name}">
                                        <xsl:call-template name="dynamic">
                                        <xsl:with-param name="fieldName" select="./@Dynamic" />
                                        </xsl:call-template>
                              </tr>
                      </xsl:when>
                        <xsl:otherwise>
                                        <xsl:variable name="hideLabel">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Hide Label']">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Hide Label']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>false</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="isRequired">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Required'] and aef:settings/aef:setting[@name = 'Editable'] = 'true'">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Required']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>false</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="sortDirection">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Sort Direction']">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Sort Direction']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>none</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                   <xsl:variable name="isTable" select="aef:settings/aef:setting[@name = 'TableName']" />
                                        <xsl:attribute name="id">
                                                <xsl:value-of select="@name" />
                                        </xsl:attribute>
                                   <xsl:choose>
                                   <!-- HORIZONTAL GROUPING -->
                                   <xsl:when test="(string-length($varGroupName) &gt; 0) and (string-length($varGroupCount) &gt; 0) " >
                                   <tr id="calc_{@name}">
                                                   <xsl:apply-templates select="//aef:fields/aef:field" mode="horizontal">
                                                 <xsl:with-param name="grpName" select="aef:settings/aef:setting[@name ='Group Name']" />
                                                 <xsl:with-param name="grpCount" select="aef:settings/aef:setting[@name ='Group Count']" />
                                                 <xsl:with-param name="grpPositon" select="position()" />
                                         </xsl:apply-templates>
                                    </tr>
                                   </xsl:when>
                                   <xsl:when test="(string-length($varGroupName) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:when test="(string-length($isTable) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:when test="(string-length($varDynamicField) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:otherwise>
                                   <!-- ///// FIELD WITHOUT ANY SETTINGS ///////-->
                                   <tr id="calc_{@name}">
                                                  <xsl:if test="normalize-space($hideLabel) = 'false' or normalize-space($hideLabel) = 'False'">
                                          <xsl:call-template name="label">

                                          </xsl:call-template>
                                          </xsl:if>

                                          <xsl:call-template name="field">
                                          </xsl:call-template>
                                   </tr>
                                   </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:copy-of select="aef:TypeAhead/node()" />
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
<xsl:template match="aef:fields/aef:field" mode="global-slidein" >
        <xsl:variable name="varFieldType" select="aef:settings/aef:setting[@name = 'Field Type']" />
        <xsl:variable name="varGroupName" select="aef:settings/aef:setting[@name = 'Group Name']" />
        <xsl:variable name="varVerticalGroupName" select="aef:settings/aef:setting[@name = 'Vertical Group Name']" />
        <xsl:variable name="varGroupCount" select="aef:settings/aef:setting[@name = 'Group Count']" />
        <xsl:variable name="varDynamicField" select="aef:settings/aef:setting[@name = 'Dynamic Attribute']" />
        <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="varTableField" select="./@TableField" />
        <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)" />
                <xsl:choose>
                        <xsl:when test="$Field_Type = 'image' and string-length($varGroupName) = 0 and string-length($varVerticalGroupName) = 0 and string-length($varTableField) = 0" >
                                <tr id="calc_{@name}">
                                 <td class="createLabel">
                                        <xsl:value-of select="@name" />
                                 </td>
                                 </tr><tr>
                                 <td class="createInputField">
                                        <xsl:element name="img">
                                                <xsl:attribute name="src">images/<xsl:value-of select="aef:settings/aef:setting[@name = 'Image'] "/></xsl:attribute>
                                                <xsl:attribute name="border">0</xsl:attribute>
                                                <xsl:attribute name="height">16</xsl:attribute>
                                                <xsl:attribute name="width">16</xsl:attribute>
                                        </xsl:element>
                                 </td>
                                </tr>
                        </xsl:when>
                        <xsl:when test="$Field_Type = 'section header'">
                                <tr>
                                        <td>
                                                <xsl:attribute name="class">
                                                        <xsl:choose>
                                                                <xsl:when test="@sectionLevel = '1'">heading1</xsl:when>
                                                                <xsl:otherwise>heading2</xsl:otherwise>
                                                        </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:value-of select="@label" />
                                        </td>
                                </tr>
                        </xsl:when>

                        <xsl:when test="$Field_Type = 'section separator'">
                        <tr>
                            <td align="center">&amp;#160;</td>
                        </tr>
                        </xsl:when>
                        <xsl:when test="$Field_Type = 'table holder'">
                        <tr>
                                <xsl:call-template name="TableHolder">
                                        <xsl:with-param name="varTableName" select="./@TableHolder"/>
                                </xsl:call-template>
                        </tr>
                      </xsl:when>
                      <xsl:when test="$Field_Type = 'dynamic attributes'">
                              <tr id="calc_{@name}">
                                        <xsl:call-template name="DynamicAttributes">
                                        <xsl:with-param name="fieldName" select="./@DynamicAttribute" />
                                        </xsl:call-template>
                              </tr>
                      </xsl:when>
                       <xsl:when test="$Field_Type = 'dynamic'">
                              <tr id="calc_{@name}">
                                        <xsl:call-template name="dynamic">
                                        <xsl:with-param name="fieldName" select="./@Dynamic" />
                                        </xsl:call-template>
                              </tr>
                      </xsl:when>
                        <xsl:otherwise>
                                        <xsl:variable name="hideLabel">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Hide Label']">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Hide Label']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>false</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="isRequired">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Required'] and aef:settings/aef:setting[@name = 'Editable'] = 'true'">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Required']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>false</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                        <xsl:variable name="sortDirection">
                                                <xsl:choose>
                                                        <xsl:when test="aef:settings/aef:setting[@name = 'Sort Direction']">
                                                                <xsl:value-of select="aef:settings/aef:setting[@name = 'Sort Direction']" />
                                                        </xsl:when>
                                                        <xsl:otherwise>none</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:variable>
                                   <xsl:variable name="isTable" select="aef:settings/aef:setting[@name = 'TableName']" />
                                        <xsl:attribute name="id">
                                                <xsl:value-of select="@name" />
                                        </xsl:attribute>
                                   <xsl:choose>
                                   <!-- HORIZONTAL GROUPING -->
                                   <xsl:when test="(string-length($varGroupName) &gt; 0) and (string-length($varGroupCount) &gt; 0) " >
                                   <tr id="calc_{@name}">
                                                   <xsl:apply-templates select="//aef:fields/aef:field" mode="horizontal">
                                                 <xsl:with-param name="grpName" select="aef:settings/aef:setting[@name ='Group Name']" />
                                                 <xsl:with-param name="grpCount" select="aef:settings/aef:setting[@name ='Group Count']" />
                                                 <xsl:with-param name="grpPositon" select="position()" />
                                         </xsl:apply-templates>
                                    </tr>
                                   </xsl:when>
                                   <xsl:when test="(string-length($varGroupName) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:when test="(string-length($isTable) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:when test="(string-length($varDynamicField) &gt; 0)" >
                                   </xsl:when>
                                   <xsl:otherwise>
                                   <!-- ///// FIELD WITHOUT ANY SETTINGS ///////-->
                                   <tr id="calc_{@name}">
                                                  <xsl:if test="normalize-space($hideLabel) = 'false' or normalize-space($hideLabel) = 'False'">
                                          <xsl:call-template name="label-slidein">

                                          </xsl:call-template>
                                          </xsl:if>

                                          <xsl:call-template name="field">
                                          </xsl:call-template>
                                   </tr>
                                   </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:copy-of select="aef:TypeAhead/node()" />
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>


<xsl:template name="DynamicAttributes">
<xsl:param name="fieldName"/>
       <xsl:for-each select="//aef:fields/aef:field/aef:settings/aef:setting[(@name ='Dynamic Attribute')]">

                <xsl:variable name="varFieldName" select="parent::node()/aef:setting[@name = 'Dynamic Attribute']"/> 
                <xsl:variable name="groupNextRow" select="parent::node()/aef:setting[@name = 'groupNextRow']"/> 
                <xsl:variable name="rowName" select="parent::node()/aef:setting[@name = 'dynamicRowName']"/> 
                <xsl:if test="string-length($groupNextRow) &gt; 0 and normalize-space($fieldName)=normalize-space($varFieldName)" >
                     <tr>
                                <xsl:apply-templates select="//aef:fields/aef:field" mode="printAttributes" >
                                   <xsl:with-param name="varFieldName" select="$fieldName" />
                                   <xsl:with-param name="varRowName" select="$rowName" />
                                </xsl:apply-templates>
                     </tr>
                </xsl:if>
        </xsl:for-each>
</xsl:template>

<xsl:template name="dynamic">
	<xsl:param name="fieldName"/>
	<xsl:for-each select="//aef:fields/aef:field/aef:settings/aef:setting[(@name ='Dynamic')]">

		<xsl:variable name="varFieldName" select="parent::node()/aef:setting[@name = 'Dynamic']"/> 
		<xsl:variable name="groupNextRow" select="parent::node()/aef:setting[@name = 'groupNextRow']"/> 
		<xsl:variable name="rowName" select="parent::node()/aef:setting[@name = 'dynamicRowName']"/> 
		<xsl:if test="string-length($groupNextRow) &gt; 0 and normalize-space($fieldName)=normalize-space($varFieldName)" >
			<tr>
				<xsl:apply-templates select="//aef:fields/aef:field" mode="printFields" >
					<xsl:with-param name="varFieldName" select="$fieldName" />
					<xsl:with-param name="varRowName" select="$rowName" />
				</xsl:apply-templates>
			</tr>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="aef:field" mode="printAttributes">
<xsl:param name="varFieldName" />
<xsl:param name="varRowName" />

        <xsl:variable name="fieldName" select="aef:settings/aef:setting[@name = 'Dynamic Attribute']" />
        <xsl:variable name="rowName" select="aef:settings/aef:setting[@name = 'dynamicRowName']" />
        <xsl:variable name="colSpan" select="aef:settings/aef:setting[@name = 'colSpan']" />
        <xsl:if test="normalize-space($varFieldName) = normalize-space($fieldName) and normalize-space($varRowName) = normalize-space($rowName)" >
                 <xsl:call-template name="label">
                 </xsl:call-template>
                 <xsl:call-template name="field">
                 <xsl:with-param name="colSpan" select="$colSpan" />
                 </xsl:call-template>
        </xsl:if>
</xsl:template>

<xsl:template match="aef:field" mode="printFields">
	<xsl:param name="varFieldName" />
	<xsl:param name="varRowName" />

	<xsl:variable name="fieldName" select="aef:settings/aef:setting[@name = 'Dynamic']" />
	<xsl:variable name="rowName" select="aef:settings/aef:setting[@name = 'dynamicRowName']" />
	<xsl:variable name="colSpan" select="aef:settings/aef:setting[@name = 'colSpan']" />
	<xsl:if test="normalize-space($varFieldName) = normalize-space($fieldName) and normalize-space($varRowName) = normalize-space($rowName)" >
		<xsl:call-template name="label">
		</xsl:call-template>
		<xsl:call-template name="field">
			<xsl:with-param name="colSpan" select="$colSpan" />
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="TableHolder">
<xsl:param name="varTableName"/>
<xsl:param name="totalFields" />

       <xsl:variable name="varColumnHeaders" select="aef:settings/aef:setting[@name = 'Field Column Headers']" />
        <td class="createLabel" width="150">&#160;</td>
        <xsl:call-template name="tokenize">
              <xsl:with-param name="varColumnHeaders" select="$varColumnHeaders" />
       </xsl:call-template>


       <xsl:for-each select="//aef:fields/aef:field/aef:settings/aef:setting[(@name ='TableName')]">
                <xsl:variable name="nextRow" select="parent::node()/aef:setting[@name = 'nextRow']"/> 
                <xsl:variable name="table" select="parent::node()/aef:setting[@name = 'TableName']"/> 
                <xsl:variable name="varRowName" select="parent::node()/aef:setting[@name = 'RowName']"/> 
                <xsl:if test="string-length($nextRow) &gt; 0 and normalize-space($table)=normalize-space($varTableName)" >
                     <tr>
                               <td class="createLabel"><xsl:value-of select="parent::node()/aef:setting[@name = 'RowHeader']" /></td>
                                <xsl:apply-templates select="//aef:fields/aef:field" mode="printColumns" >
                                   <xsl:with-param name="varTableName" select="$varTableName" />
                                   <xsl:with-param name="varRowName" select="$varRowName" />
                                </xsl:apply-templates>
                     </tr>
                </xsl:if>
        </xsl:for-each>
       </xsl:template>

<xsl:template match="aef:field" mode="printColumns">
<xsl:param name="varTableName" />
<xsl:param name="varRowName" />

        <xsl:variable name="tableName" select="aef:settings/aef:setting[@name = 'TableName']" />
        <xsl:variable name="rowName" select="aef:settings/aef:setting[@name = 'RowName']" />

        <xsl:if test="normalize-space($varTableName) = normalize-space($tableName) and normalize-space($varRowName) = normalize-space($rowName)" >
                 <xsl:call-template name="field">
                 </xsl:call-template>
        </xsl:if>
</xsl:template>


       <xsl:template name="vertical">
            <xsl:param name="varVerticalGroupName" />
       <xsl:param name="varGroupName" />
            <xsl:param name="varVerticalCount" />
            <xsl:param name="Colspan" />
            <td valign="middle" height="100%">
            <xsl:attribute name="colspan">
                                <xsl:value-of select="$Colspan" />
            </xsl:attribute>
            <table height="100%" width="100%">
            <xsl:for-each select="//aef:fields/aef:field/aef:settings/aef:setting[(@name ='Vertical Group Name')]">
            <xsl:variable name="tarVerticalGroupName" select="parent::node()/aef:setting[@name = 'Vertical Group Name']" />
            <xsl:variable name="tarGroupName" select="parent::node()/aef:setting[@name = 'Group Name']" />

       <xsl:variable name="hideLabel">
              <xsl:choose>
                                     <xsl:when test="parent::node()/aef:setting[@name = 'Hide Label']">
                                            <xsl:value-of select="parent::node()/aef:setting[@name = 'Hide Label']" />
                     </xsl:when>
                     <xsl:otherwise>false</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
              <xsl:if test="normalize-space($varVerticalGroupName) = normalize-space($tarVerticalGroupName) and normalize-space($varGroupName) = normalize-space($tarGroupName)">
                <tr id="calc_{@name}">
                         <xsl:if test="normalize-space($hideLabel) = 'false' or normalize-space($hideLabel) = 'False'">
                                          <xsl:call-template name="label">
                                          <xsl:with-param name="groupName" select="$tarGroupName" />
                                          <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
                                          </xsl:call-template>
                                   </xsl:if>
                                   <xsl:call-template name="verticalField">
                                   </xsl:call-template>
                </tr>
              </xsl:if>

       </xsl:for-each>
          </table>
          </td>
       </xsl:template>

       <xsl:template name="tokenize">
              <xsl:param name="varColumnHeaders" />

              <xsl:variable name="varColumn" select="substring-before($varColumnHeaders,',')" />
              <xsl:if test="string-length($varColumn) &gt; 0 or string-length($varColumnHeaders) &gt; 0" >
                     <td class="createLabel">
                     <xsl:choose>
                            <xsl:when test="string-length($varColumn) !=0">
                                   <xsl:value-of select="normalize-space($varColumn)" />
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:value-of select="$varColumnHeaders" />
                            </xsl:otherwise>
                     </xsl:choose>
                     </td>
                     <xsl:call-template name="tokenize" >
                            <xsl:with-param name="varColumnHeaders" select="substring-after($varColumnHeaders,',')" />
                     </xsl:call-template>
              </xsl:if>
       </xsl:template>

       <xsl:template name="label" >
       <xsl:param name="groupName" />
       <xsl:param name="varVerticalCount" />
       <xsl:variable name="isRequired" select="aef:settings/aef:setting[@name = 'Required']" />
              <td width="150" valign="middle">
                     <!-- define the class for the cell -->
                     <xsl:attribute name="class">
                            <xsl:choose>
                                   <xsl:when test="normalize-space($isRequired) = 'true' and number($varVerticalCount) &gt; 1">labelRequired</xsl:when>
                                   <xsl:when test="normalize-space($isRequired) = 'true'">createLabelRequired</xsl:when>
                                   <xsl:otherwise>
                                   <xsl:variable name="isRequired1" select="../../aef:settings/aef:setting[@name = 'Required']" />
                                   <xsl:choose>
                                        <xsl:when test="string-length($groupName) != 0 and number($varVerticalCount) &gt; 1" >
                                                <xsl:choose>
                                                                <xsl:when test="normalize-space($isRequired1) = 'true' and number($varVerticalCount) &gt; 1">labelRequired</xsl:when>
                                                        <xsl:when test="normalize-space($isRequired1) = 'true'">createLabelRequired</xsl:when>
                                                                <xsl:when test="number($varVerticalCount) &gt; 1">label</xsl:when>
                                                        <xsl:otherwise>createLabel</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:when>
                                                <xsl:when test="number($varVerticalCount) &gt; 1">label</xsl:when>
                                        <xsl:otherwise>createLabel</xsl:otherwise>
                                   </xsl:choose>
                                   </xsl:otherwise>
                            </xsl:choose>
                     </xsl:attribute>
                     <label>
                            <xsl:attribute name="for">
                               <xsl:choose>
                                <xsl:when test="string-length($groupName) != 0 and number($varVerticalCount) &gt; 1" >
                                    <xsl:value-of select="parent::node()/parent::node()/@name" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@name" />
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:attribute>
                        <xsl:choose>
                          <xsl:when test="string-length($groupName) != 0 and number($varVerticalCount) &gt; 1" >
                                <xsl:value-of select="parent::node()/parent::node()/@label" />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="@label" />
                          </xsl:otherwise>
                      </xsl:choose>
                  </label>
       </td>
       </xsl:template>
       
       <xsl:template name="label-slidein" >
       <xsl:param name="varGrpName" />
       <xsl:param name="varVerticalCount" />
       <xsl:variable name="isRequired" select="aef:settings/aef:setting[@name = 'Required']" />
            <tr>
              <xsl:call-template name="label">
                <xsl:with-param name="groupName" select="$varGrpName" />
                <xsl:with-param name="varVerticalCount" select="$varVerticalCount" />
              </xsl:call-template>
            </tr>
       </xsl:template>
        <xsl:template name="options">
                <xsl:param name="sortDir" />
                <xsl:choose>
                        <xsl:when test="$sortDir = 'ascending'">
                                <xsl:for-each select="aef:rangeValues/aef:range">
                                        <xsl:sort select="aef:label" order="ascending" />
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$sortDir = 'descending'">
                                <xsl:for-each select="aef:rangeValues/aef:range">
                                        <xsl:sort select="aef:label" order="descending" />
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each select="aef:rangeValues/aef:range">
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>


        <xsl:template name="optionsVerticalField">
                <xsl:param name="sortDir" />
                <xsl:choose>
                        <xsl:when test="$sortDir = 'ascending'">
                                <xsl:for-each select="parent::node()/parent::node()/aef:rangeValues/aef:range">
                                        <xsl:sort select="aef:label" order="ascending" />
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$sortDir = 'descending'">
                                <xsl:for-each select="parent::node()/parent::node()/aef:rangeValues/aef:range">
                                        <xsl:sort select="aef:label" order="descending" />
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each select="parent::node()/parent::node()/aef:rangeValues/aef:range">
                                        <option>
                                                <xsl:attribute name="value">
                                                        <xsl:value-of select="aef:value" />
                                                </xsl:attribute>
                                                <xsl:if test="@selected = 'true'">
                                                        <xsl:attribute name="selected">
                                                                selected
                                                        </xsl:attribute>
                                                </xsl:if>
                                                <xsl:value-of select="aef:label" />
                                        </option>
                                </xsl:for-each>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>

        <xsl:template match="aef:rangeValues/aef:range" mode="radiobutton">
                <tr>
                        <td width="16">
                                <input type="radio">
                                        <xsl:attribute name="name">
                                                <xsl:value-of select="../../@name" />
                                        </xsl:attribute>
                                        <xsl:attribute name="id">
                                                <xsl:value-of select="../../@name" />
                                        </xsl:attribute>
                                        <xsl:attribute name="value">
                                                <xsl:value-of select="aef:value" />
                                        </xsl:attribute>
                                        <xsl:if test="@selected = 'true'">
                                                <xsl:attribute name="checked">
                                                        checked
                                                </xsl:attribute>
                                        </xsl:if>
                                </input>
                        </td>
                        <td>
                                <xsl:value-of select="aef:label" />
                        </td>
                </tr>
        </xsl:template>
        <xsl:template match="aef:rangeValues/aef:range" mode="checkbox">
                <tr>
                        <td width="16">
                                <input type="checkbox">
                                        <xsl:attribute name="name">
                                                <xsl:value-of select="../../@name" />
                                        </xsl:attribute>
                                        <xsl:attribute name="id">
                                                <xsl:value-of select="aef:value" />
                                        </xsl:attribute>
                                        <xsl:attribute name="value">
                                                <xsl:value-of select="aef:value" />
                                        </xsl:attribute>
                                        <xsl:if test="@selected = 'true'">
                                                <xsl:attribute name="checked">
                                                        checked
                                                </xsl:attribute>
                                        </xsl:if>
                                </input>
                        </td>
                        <td>
                                <xsl:value-of select="aef:label" />
                        </td>
                </tr>
        </xsl:template>

          <xsl:template name="booleanCheckbox">
      
      <tr>
        <td>                       
               <input type="checkbox" onClick="changeVal(this)">
                                <xsl:attribute name="name">
                                        <xsl:value-of select="@name" />
                                 </xsl:attribute>
                                 <xsl:attribute name="id">
                                        <xsl:value-of select="@name" />
                                 </xsl:attribute>
                                 <xsl:attribute name="value">
                                         <xsl:value-of select="aef:rangeValues/aef:range/aef:value" />
                                 </xsl:attribute>
                                 <xsl:if test="aef:settings/aef:setting[@name = 'Default'] = 'true'">
                                        <xsl:attribute name="checked">
                                           checked
                                    </xsl:attribute>
                                 </xsl:if>
                         </input>  
                        
                </td>
                
    </tr>
  </xsl:template>

        <xsl:template name="clearButton">
                <xsl:param name="fldName" />
                <xsl:param name="clearButton" />
                <xsl:choose>
                        <xsl:when test="$clearButton = 'true'">
                                <a>
                                        <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="$fldName" />')
                                        </xsl:attribute>
                                        <xsl:value-of select="$fldName" />
                                </a>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>

        <xsl:template name="textbox">
                <xsl:param name="verticalField"/>
                <xsl:param name="name" />
                <xsl:param name="label" />
                <xsl:param name="id" />
                <xsl:param name="value" />
                <xsl:param name="keyEntry" />
                <xsl:param name="maxLength" />
                <xsl:param name="disabled" />
                <xsl:param name="autoName" />
                <xsl:param name="typeaheadList" />
				<xsl:if test="$keyEntry = 'false'">
                        <xsl:attribute name="class">createInputField disabled</xsl:attribute>
				</xsl:if>
                <xsl:variable name="autoNameChecked">
                         <xsl:choose>
                             <xsl:when test="string-length($verticalField) = 0" >
                                    <xsl:value-of select="aef:settings/aef:setting[@name = 'AutoName Checked']" />
                             </xsl:when>
                             <xsl:otherwise><xsl:value-of select="parent::node()/aef:setting[@name = 'AutoName Checked']" /></xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>
                <xsl:variable name="size">
                         <xsl:choose>
                             <xsl:when test="string-length($verticalField) = 0" >
                                    <xsl:value-of select="aef:settings/aef:setting[@name = 'Field Size']" />
                             </xsl:when>
                             <xsl:otherwise><xsl:value-of select="parent::node()/aef:setting[@name = 'Field Size']" /></xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>
                <xsl:variable name="typeAhead">
                         <xsl:choose>
                             <xsl:when test="string-length($verticalField) = 0" >
                                    <xsl:value-of select="aef:TypeAhead" />
                             </xsl:when>
                             <xsl:otherwise><xsl:value-of select="parent::node()/parent::node()/aef:TypeAhead" /></xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>
                <xsl:variable name="rangeURL">
                         <xsl:choose>
                             <xsl:when test="string-length($verticalField) = 0" >
                                    <xsl:value-of select="aef:rangeURL" />
                             </xsl:when>
                             <xsl:otherwise><xsl:value-of select="parent::node()/parent::node()/aef:rangeURL" /></xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>

                <input type="text" name="{$name}" id="{$id}" value="{$value}">
                        <xsl:attribute name="fieldLabel">
                                <xsl:value-of select="$label" />
                        </xsl:attribute>
                         <xsl:attribute name="title">
                                <xsl:value-of select="$label" />
                        </xsl:attribute>
                        <xsl:attribute name="size">
                                <xsl:choose>
                                        <xsl:when test="string-length($size) != 0">
                                             <xsl:value-of select="$size" />
                                        </xsl:when>
                                        <xsl:otherwise>20</xsl:otherwise>
                                </xsl:choose>
                        </xsl:attribute>
                        
                        <xsl:variable name="fullSearchURL">emxFullSearch.jsp</xsl:variable>
         				
                        <xsl:choose>
                                <xsl:when test="contains($rangeURL, $fullSearchURL) and normalize-space($typeAhead) = ''">
                                        <xsl:attribute name="onKeyPress">
                                            checkEnterKeyPressed(event,"<xsl:value-of select="$rangeURL"/>",'<xsl:value-of select="$name"/>')
                                        </xsl:attribute>
                                </xsl:when>
                        </xsl:choose>
                        
                        <xsl:choose>
                                <xsl:when test="$maxLength != ''">
                                        <xsl:attribute name="maxLength">
                                                <xsl:value-of select="$maxLength" />
                                        </xsl:attribute>
                                </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                                <xsl:when test="$disabled != ''">
                                        <xsl:attribute name="disabled">
                                                <xsl:value-of select="$disabled" />
                                        </xsl:attribute>
                                        <xsl:attribute name="style">
                                                background-color: #dedede
                                        </xsl:attribute>
                                </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                                <xsl:when test="$keyEntry = 'false'">
                                        <xsl:attribute name="readonly">true</xsl:attribute>
                                </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                                <xsl:when test="normalize-space($name) = 'TypeActualDisplay' and normalize-space($typeAhead) = ''">
                                        <xsl:attribute name="onChange">updateHiddenValue(this);reload()</xsl:attribute>
                                        <xsl:attribute name="onfocus">storePreviousValue(this)</xsl:attribute>
                                </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                                <xsl:when test="normalize-space($typeaheadList) = '' and normalize-space($name) != 'TypeActualDisplay' and normalize-space($rangeURL) != '' ">
                                        <xsl:attribute name="onChange">updateHiddenValue(this)</xsl:attribute>
                                        <xsl:attribute name="onfocus">storePreviousValue(this)</xsl:attribute>
                                </xsl:when>
                        </xsl:choose>

                </input>
                
                <xsl:choose>
                        <xsl:when test="$autoName != ''">
                               &amp;#160;<input type="checkbox" value="true" name="autoNameCheck" onclick="onAutoNameClick(this)">
                                                <xsl:if test="$autoNameChecked ='true'">
                                                        <xsl:attribute name="checked"> true </xsl:attribute>
                                                        <script language="JavaScript">
                                                                document.forms[0]['Name'].disabled = true; 
                                                                document.forms[0]['Name'].value = "";
                                                        </script>
                                                </xsl:if>
                                        </input>&amp;#160;<xsl:value-of select="$autoName"/>
                        </xsl:when>
                </xsl:choose>
        </xsl:template>


       <xsl:template name="field" >
       <xsl:param name="colSpan"/>
       <xsl:variable name="varFieldType" select="aef:settings/aef:setting[@name = 'Field Type']" />
        <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)" />
        <xsl:variable name="varName" select="@name" />
       <xsl:variable name="isRequired">
              <xsl:choose>
                     <xsl:when test="aef:settings/aef:setting[@name = 'Required'] and aef:settings/aef:setting[@name = 'Editable'] = 'true'">
                            <xsl:value-of select="aef:settings/aef:setting[@name = 'Required']" />
                     </xsl:when>
                     <xsl:otherwise>false</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
       <xsl:variable name="autoName" select="aef:settings/aef:setting[@name = 'autoName']" />
       <xsl:variable name="autoNameChecked" select="aef:settings/aef:setting[@name = 'AutoName Checked']" />

        <xsl:variable name="sortDirection">
              <xsl:choose>
                     <xsl:when test="aef:settings/aef:setting[@name = 'Sort Direction']">
                            <xsl:value-of select="aef:settings/aef:setting[@name = 'Sort Direction']" />
                     </xsl:when>
                     <xsl:otherwise>none</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
        <xsl:variable name="inputType" select="aef:settings/aef:setting[@name = 'Input Type']" />
        <xsl:variable name="ColSpan" select="aef:settings/aef:setting[@name = 'Colspan']" />
        <xsl:variable name="richTextEditor" select="@isRTEField" />
        <xsl:variable name="isMultiVal" select="@isMultiVal" />
       <td class="createInputField" valign="middle">
       <xsl:if test="$uiAutomation = 'true' ">
				<xsl:attribute name="data-aid">
                	<xsl:value-of select="@name" />
        		</xsl:attribute>
		</xsl:if>       
        <xsl:attribute name="colspan">
                <xsl:choose>
                        <xsl:when test="string-length($ColSpan) &gt; 0" >
                                <xsl:value-of select="$ColSpan" />
                        </xsl:when>
                        
                </xsl:choose>
        </xsl:attribute>
                <xsl:choose>
              <xsl:when test="$Field_Type = 'programhtmloutput'">
                   <div name="{$varName}_html" id="{$varName}_html">
                      <xsl:copy-of select="aef:actualValue/node()"/>
                     </div>
                     <xsl:if test="$isRequired = 'true'">
                            <script language="JavaScript">
                                   myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="@name" />']);
                            </script>
                     </xsl:if>
                 </xsl:when>                                                        
                <xsl:otherwise>
                <xsl:choose>
                     <xsl:when test="aef:settings/aef:setting[@name = 'Editable'] = 'false'">
                            <xsl:choose>
                                   <xsl:when test="aef:displayValue = ''">&#160;</xsl:when>
                                   <xsl:otherwise>
                                          <xsl:choose>
                                                 <xsl:when test="string-length(@objectIcon) &gt; 0">
                                                        <table border="0" width="95%"><tr><td valign="top"><img border="0" src="{@objectIcon}" /></td><td><xsl:value-of select="aef:displayValue" /></td></tr></table>
                                                        <input type="hidden" name="{@name}" value="{aef:actualValue}"/>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                 <xsl:value-of select="aef:displayValue" />
                                                 <input type="hidden" name="{@name}" value="{aef:actualValue}"/>
                                          </xsl:otherwise>
                                   </xsl:choose>
                            </xsl:otherwise>
                     </xsl:choose>
              </xsl:when>
                <xsl:when test="normalize-space($Field_Type) = 'image'">
                        <xsl:element name="img">
                                <xsl:attribute name="src">images/<xsl:value-of select="aef:settings/aef:setting[@name = 'Image'] "/></xsl:attribute>
                                <xsl:attribute name="border">0</xsl:attribute>
                                <xsl:attribute name="height">16</xsl:attribute>
                                <xsl:attribute name="width">16</xsl:attribute>
                        </xsl:element>
                  </xsl:when>
              <xsl:otherwise>
              <xsl:if test="normalize-space($inputType)= 'combobox'">
                   <xsl:variable name="size" select="aef:settings/aef:setting[@name = 'Field Size']" />
                   <xsl:variable name="classValue">
              					<xsl:if test="$isMultiVal = 'true'">
                        	    	<xsl:value-of select="'multi-attr'" />
                        	    </xsl:if>
                   </xsl:variable>
                   <table class="{$classValue}">
                    <tr><td>
                   <xsl:choose>
                     <xsl:when test="aef:manualEntryRange">
                            <select id="{@name}Id" onChange="allowCustomInput(this,'{@name}','{@name}Idtxt',{$isRequired},false);">
                                   <xsl:attribute name="fieldLabel">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:attribute name="style">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($size) != 0">
                                                        width:<xsl:value-of select="$size" />px
                                                 </xsl:when>
                                          </xsl:choose>
                                   </xsl:attribute>
                                   <xsl:choose>
                                          <xsl:when test="@isSelected = 'false'">
                                                 <xsl:attribute name="name">
                                                        <xsl:value-of select="concat(@name,'_tmp')" />
                                                 </xsl:attribute>
                                          </xsl:when>
                                          <xsl:otherwise>
                                                 <xsl:attribute name="name">
                                                        <xsl:value-of select="@name" />
                                                 </xsl:attribute>
                                          </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:call-template name="options">
                                          <xsl:with-param name="sortDir" select="$sortDirection" />
                                   </xsl:call-template>
                                   <option>
                                          <xsl:attribute name="value">
                                                 <xsl:value-of select="aef:manualEntryRange/aef:value" />
                                          </xsl:attribute>
                                          <xsl:if test="@isSelected = 'true'">
                                                 <xsl:attribute name="selected">selected</xsl:attribute>
                                          </xsl:if>
                                          <xsl:value-of select="aef:manualEntryRange/aef:label" />
                                   </option>
                            </select>
                            <xsl:choose>
                            <xsl:when test="@isSelected = 'false'">
                            <xsl:call-template name="textbox">
                                   <xsl:with-param name="name" select="@name" />
                                   <xsl:with-param name="id" select="concat(@name, 'Idtxt')" />
                                   <xsl:with-param name="value" select="aef:displayValue" />
                                   <xsl:with-param name="label" select="@label" />
                                   <xsl:with-param name="keyEntry" select="@canKeyDate" />
                            </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:call-template name="textbox">
                                          <xsl:with-param name="id" select="concat(@name, 'Idtxt')" />
                                          <xsl:with-param name="label" select="@label" />
                                          <xsl:with-param name="disabled">disabled</xsl:with-param>
                                          <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                   </xsl:call-template>
                            </xsl:otherwise>
                            </xsl:choose>
                            </xsl:when>                   
                            <xsl:otherwise>
                                   <select id="{@name}Id" name="{@name}">
                                   <xsl:attribute name="onChange">
                                     <xsl:if test="@name='TypeActual'">
                                            reload()
                                     </xsl:if>     
                                   </xsl:attribute>
                                   <xsl:attribute name="title">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:attribute name="style">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($size) != 0">
                                                        width:<xsl:value-of select="$size" />px
                                                 </xsl:when>
                                          </xsl:choose>
                                   </xsl:attribute>
                                          <xsl:call-template name="options">
                                                 <xsl:with-param name="sortDir" select="$sortDirection" />
                                          </xsl:call-template>
                                   </select>
                            </xsl:otherwise>
                     </xsl:choose>
                     </td>
 	           	   <xsl:if test="$isMultiVal = 'true'">
 	           	   	<input type="hidden" name="{@name}_order" id="{@name}_order" value=""/> 	           	   
 	           			 <td>
 	           			   <xsl:choose> 	           			 
			           	   <xsl:when test="$slideinui = 'true'">
			           	   			 <a id="formAddValue" name="addValueInCreateForm" onclick="addValueInCreateForm('{@name}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:when>
	              		   <xsl:otherwise>
			           	   			 <a id="formAddValue" name="addValueInEditForm" onclick="addValueInEditForm('{@name}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:otherwise>
			           	   </xsl:choose>
			           	 </td>
	               </xsl:if>  
	               </tr></table> 
              </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'listbox'">
                     <xsl:variable name="size" select="aef:settings/aef:setting[@name = 'Field Size']" />
                     <select>
                            <xsl:attribute name="name">
                                   <xsl:value-of select="@name" />
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                   <xsl:choose>
                                          <xsl:when test="string-length($size) != 0">
                                                 width:<xsl:value-of select="$size" />px
                                          </xsl:when>
                                          <xsl:otherwise>20</xsl:otherwise>
                                   </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="multiple">true</xsl:attribute>

                            <xsl:attribute name="fieldLabel">
                                   <xsl:value-of select="@label" />
                            </xsl:attribute>
                            <xsl:call-template name="options">
                                   <xsl:with-param name="sortDir" select="$sortDirection" />
                            </xsl:call-template>
                     </select>
                     </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'radiobutton'">
                            <table border="0">
                                   <xsl:apply-templates select="aef:rangeValues/aef:range" mode="radiobutton"></xsl:apply-templates>
                            </table>
                     </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'checkbox'">
                  <xsl:variable name="AttributeType" select="@AttributeType" />
                  <xsl:if test ="$AttributeType != 'boolean'" >
                            <table border="0">
                                   <xsl:apply-templates select="aef:rangeValues/aef:range" mode="checkbox"></xsl:apply-templates>
                            </table>
                      </xsl:if>
      <xsl:if test ="$AttributeType = 'boolean'" >
        <table border="0">
             <xsl:call-template name="booleanCheckbox">

             </xsl:call-template>
         </table>
                      </xsl:if>
                </xsl:if>  
                
                 <xsl:variable name="expression" select="@expression" />
                  <xsl:if test ="$expression = 'name'" >
                            <script language="JavaScript">
                                myValidationRoutines1.push(['assignValidateMethod', '<xsl:value-of select="@name" />', 'isBadNameChars']);
                            </script>
                      </xsl:if>                   
             <xsl:if test="normalize-space($inputType) = 'textarea'">
                            <xsl:variable name="size" select="aef:settings/aef:setting[@name = 'Field Size']" />
                            <xsl:variable name="colssetting" select="aef:settings/aef:setting[@name = 'Cols']" />
                            <xsl:variable name="showClearBtn"  select="aef:settings/aef:setting[@name = 'Show Clear Button']"/>
                            <xsl:variable name="showClearText" select="//aef:mxRoot/aef:setting[@name = 'clear']"/>
                            <xsl:variable name="classValue">
              					<xsl:if test="$isMultiVal = 'true'">
                        	    	<xsl:value-of select="'multi-attr '" />
                        	    </xsl:if>
                        	</xsl:variable>
                            <table class="{$classValue}textarea">
                            <tr><td>
                             <textarea>
                                   <xsl:attribute name="cols">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($colssetting) != 0">
                                                      <xsl:value-of select="$colssetting" />
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                 <xsl:choose>
                                                        <xsl:when test="string-length($size) != 0">
                                                               <xsl:value-of select="$size" />
                                                        </xsl:when>
                                                        <xsl:otherwise>25</xsl:otherwise>
                                                 </xsl:choose>
                                                 </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:attribute>
                                   <xsl:attribute name="rows">5</xsl:attribute>
                                   <xsl:if test="normalize-space($richTextEditor) = 'true'">
                                   <xsl:attribute name="class">rte</xsl:attribute>
                                   </xsl:if>                                  
                                   
                                   <xsl:attribute name="name">
                                          <xsl:value-of select="@name" />
                                   </xsl:attribute>
                                   <xsl:attribute name="id">
                                          <xsl:value-of select="concat(@name, 'Id')" />
                                   </xsl:attribute>
                                   <xsl:attribute name="fieldLabel">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:attribute name="title">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:value-of select="aef:displayValue" />                                   
                            </textarea>
                            </td>
	                       <xsl:if test="$isMultiVal = 'true' and aef:settings/aef:setting[@name = 'Input Type'] = 'textarea'">
	                          	<input type="hidden" name="{@name}_order" id="{@name}_order" value=""/>                       	
	                       			<td>           	   			
	                       			<xsl:choose>          	   			
					           	   <xsl:when test="$slideinui = 'true'">
					           	   			 <a id="formAddValue" name="addValueInCreateForm"  onclick="addValueInCreateForm('{@name}','{$showClearBtn}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
					           	   </xsl:when>
			              		   <xsl:otherwise>
					           	   			 <a id="formAddValue" name="addValueInEditForm"  onclick="addValueInEditForm('{@name}','{$showClearBtn}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
					           	   </xsl:otherwise>
					           	   </xsl:choose>
					           	   </td>
			               </xsl:if>  
                            <xsl:if test="aef:settings/aef:setting[@name = 'Show Clear Button'] = 'true'">
                            	<td>	
                                   <a>
                                          <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="@name" />')
                                          </xsl:attribute>
                                          <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                   </a>
                                </td>
                            </xsl:if>
                         </tr></table> 
                     </xsl:if>

           <xsl:if test="normalize-space($inputType) = 'textbox'">
                            <xsl:choose>
                                   <xsl:when test="aef:settings/aef:setting[@name = 'format'] = 'date'">
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="name" select="@name" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="value" select="aef:displayValue" />
                                                 <xsl:with-param name="id" select="@name" />
                                                 <xsl:with-param name="maxLength" select="aef:settings/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                          </xsl:call-template>
                        <!-- Added:For Enhanced Calendar Control:AEF:nr2:20-11-09 -->
                                        <xsl:variable name="CalendarProgram" select="normalize-space(aef:settings/aef:setting[@name = 'Calendar Program'])" />
                                        <xsl:variable name="CalendarFunction" select="normalize-space(aef:settings/aef:setting[@name = 'Calendar Function'])" />                                                                                 
                                        <xsl:variable name="InputType" select="normalize-space(aef:settings/aef:setting[@name = 'Input Type'])" />
                                        <xsl:variable name="format" select="normalize-space(aef:settings/aef:setting[@name = 'format'])" />
                                       <!--  <xsl:variable name="calBeanTimeStamp" select="normalize-space(../../aef:requestMap/aef:setting[@name = 'timeStamp'])" />  -->
                                        <xsl:variable name="calBeanTimeStamp" select="normalize-space(../../../aef:mxRoot/aef:setting[@name = 'timeStamp'])" />

                                        <xsl:variable name="calReqMap">
                                            <xsl:text>{"CalendarProgram":"</xsl:text><xsl:value-of select="$CalendarProgram" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"CalendarFunction":"</xsl:text><xsl:value-of select="$CalendarFunction" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"InputType":"</xsl:text><xsl:value-of select="$InputType" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"format":"</xsl:text><xsl:value-of select="$format" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"calBeanTimeStamp":"</xsl:text><xsl:value-of select="$calBeanTimeStamp" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"componentType":"form"</xsl:text>
                                            <!-- Added:25-01-10:nr2:IR-035216V6R2011 -->
                                            <xsl:text>,"columnName":"</xsl:text><xsl:value-of select="@name" /><xsl:text>"</xsl:text>
                                            <!-- End:25-01-10:nr2:IR-035216V6R2011 -->
                                            <xsl:text>,"mode":"create"}</xsl:text>
                                        </xsl:variable>
                        <!-- End:For Enhanced Calendar Control:AEF:nr2:20-11-09 -->
                                          <a id="formDateChooser" name="{@name}_date" href="javascript:showCalendar('emxCreateForm', '{@name}', '{aef:displayValue}', '','','','','{$calReqMap}');">
                                                 <img src="../common/images/iconSmallCalendar.gif" alt="Date Picker" border="0" />
                                          </a>
                                          <xsl:if test="aef:settings/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                 <a>
                                                        <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="@name" />')
                                                        </xsl:attribute>
                                                        <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                                 </a>
                                          </xsl:if>
                                               <xsl:choose>
                                                 <xsl:when test="@canKeyDate = 'true'">
                                                        <br />
                                                        <span class="hint">(<xsl:value-of select="aef:locDatefrmt" />)</span>
                                                 </xsl:when>
                                          </xsl:choose>
                                          <input type="hidden" name="{@name}_msvalue" value="{aef:msValue}" />
                                   </xsl:when>
                                   <xsl:when test="aef:rangeURL">
                                          <xsl:choose>
                                                 <xsl:when test="aef:TypeAhead or  aef:settings/aef:setting[@name = 'Allow Manual Edit'] = 'true'">
                                                        <xsl:call-template name="textbox">
                                                               <xsl:with-param name="name" select="concat(@name, 'Display')" />
                                                               <xsl:with-param name="label" select="@label" />
                                                               <xsl:with-param name="value" select="aef:displayValue" />
                                                               <xsl:with-param name="maxLength" select="aef:settings/aef:setting[@name = 'Maximum Length']" />
                                                               <xsl:with-param name="typeaheadList" select="aef:TypeAhead" />
                                                               <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                                        </xsl:call-template>
                                                        <input type="hidden" name="{@name}" value="{aef:actualValue}" />
                                                        <input type="hidden" name="{@name}OID" value="{aef:fieldValueOID}" />
														<xsl:choose>
															<xsl:when test="aef:oslcEnabled = 'true'">
																   <input type="button" name="btn{@name}" value="{aef:rangeURLLabel}" onclick="{aef:rangeURL}" />
																   <input type="button" name="btn{@name}" value="{aef:altRangeURLLabel}" onclick="{aef:altRangeURL}" />
															</xsl:when>
															<xsl:otherwise>
                                                        <input type="button" name="btn{@name}" value="..." onclick="{aef:rangeURL}" />
															</xsl:otherwise>	
														</xsl:choose>
                                                        <xsl:if test="aef:settings/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                               <a><xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="@name" />')</xsl:attribute>
                                                                      <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                                               </a>
                                                        </xsl:if>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                 <xsl:call-template name="textbox">
                                                        <xsl:with-param name="name" select="concat(@name, 'Display')" />
                                                        <xsl:with-param name="label" select="@label" />
                                                        <xsl:with-param name="value" select="aef:displayValue" />
                                                        <xsl:with-param name="maxLength" select="aef:settings/aef:setting[@name = 'Maximum Length']" />
                                                        <xsl:with-param name="keyEntry">false</xsl:with-param>
                                                 </xsl:call-template>
                                                 <input type="hidden" name="{@name}" value="{aef:actualValue}" />
                                                 <input type="hidden" name="{@name}OID" value="{aef:fieldValueOID}" />
                               
                                                 		<xsl:choose>
															<xsl:when test="aef:oslcEnabled = 'true'">
																   <input type="button" name="btn{@name}" attr-type="chooser" value="{aef:rangeURLLabel}" onclick="{aef:rangeURL}" />
																   <input type="button" name="btn{@name}" attr-type="chooser" value="{aef:altRangeURLLabel}" onclick="{aef:altRangeURL}" />
															</xsl:when>
															<xsl:otherwise>
                                                 <input type="button" name="btn{@name}" attr-type="chooser" value="..." onclick="{aef:rangeURL}" />
															</xsl:otherwise>	
														</xsl:choose>
                                                 <xsl:if test="aef:settings/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                        <a>
                                                               <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="concat(@name, 'Display')" />')</xsl:attribute>
                                                               <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                                        </a>
                                                 </xsl:if>
                                                 </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:when>
                                   <xsl:when test="aef:settings/aef:setting[@name = 'format'] = 'user' and aef:settings/aef:setting[@name = 'Editable'] = 'false'">
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="name" select="concat(@name,'Display')" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="value" select="aef:displayValue" />
                                                 <xsl:with-param name="maxLength" select="aef:settings/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                          </xsl:call-template>
                                          <input type="hidden" name="{@name}" value="{aef:actualValue}" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                    	<xsl:variable name="showClearBtn"  select="aef:settings/aef:setting[@name = 'Show Clear Button']"/>
                      				    <xsl:variable name="showClearText" select="//aef:mxRoot/aef:setting[@name = 'clear']"/>
										<xsl:variable name="classValue">
			              					<xsl:if test="$isMultiVal = 'true'">
			                        	    	<xsl:value-of select="'multi-attr'" />
			                        	    </xsl:if>
                        				</xsl:variable>
										<table class="{$classValue}">
                       					     <tr><td>
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="name" select="@name" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="id" select="@name" />
                                                 <xsl:with-param name="value" select="aef:displayValue" />
                                                 <xsl:with-param name="maxLength" select="aef:settings/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="autoName" select="aef:settings/aef:setting[@name = 'autoName']" />                                                                                                                        
                                          </xsl:call-template>
                                          <xsl:if test="@isUOMAttribute = 'true'">
                                          <select name="{@UOMDisplayName}" id="{@UOMDisplayName}Id">                                                                                                              
                                                 <xsl:for-each select="aef:rangeValues/aef:range">
                                                        <xsl:sort select="aef:label" order="ascending" />
                                                 
                                                        <option>
                                                        <xsl:attribute name="value">
                                                               <xsl:value-of select="aef:value" />
                                                        </xsl:attribute>
                                                        <xsl:if test="@selected = 'true'">
                                                               <xsl:attribute name="selected">
                                                                      selected
                                                               </xsl:attribute>
                                                        </xsl:if>
                                                        <xsl:value-of select="aef:label" />
                                                        </option>
                                                 </xsl:for-each>
                                          </select>
                                          </xsl:if>
                                          </td>
				                        <xsl:if test="$isMultiVal = 'true' and aef:settings/aef:setting[@name = 'Input Type'] = 'textbox'">
				                        	<input type="hidden" name="{@name}_order" id="{@name}_order" value=""/>
				                        	<td>
				                        	<xsl:choose> 	  
							           	   <xsl:when test="$slideinui = 'true'">
									           	   		 <a id="formAddValue" name="addValueInCreateForm" onclick="addValueInCreateForm('{@name}','{$showClearBtn}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
							           	   </xsl:when>
					              		   <xsl:otherwise>
									           	   		  <a id="formAddValue" name="addValueInCreateForm"  onclick="addValueInEditForm('{@name}','{$showClearBtn}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
							            </xsl:otherwise>
							            </xsl:choose>
							            </td>
	               				</xsl:if>   
                                          <xsl:if test="aef:settings/aef:setting[@name = 'Show Clear Button'] = 'true'">
				                          	<td>
                                                 <a>
                                                        <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="@name" />')
                                                        </xsl:attribute>
                                                        <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                                 </a>
                                            </td>
                                          </xsl:if>
                                         </tr></table>
                                          
                                   </xsl:otherwise>
                                   </xsl:choose>
                            </xsl:if>
                            </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                   <xsl:when test="aef:settings/aef:setting[@name = 'Validate']">
                                          <script language="JavaScript">
                                                 myValidationRoutines1.push(['assignValidateMethod', '<xsl:value-of select="@name" />', '<xsl:value-of select="aef:settings/aef:setting[@name = 'Validate']" />']);
                                          </script>
                                   </xsl:when>
                                </xsl:choose>
                            <xsl:if test="aef:settings/aef:setting[@name = 'format'] = 'numeric'">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateNumericField', '<xsl:value-of select="@name" />']);
                                   </script>
                            </xsl:if>
                            <xsl:if test="aef:settings/aef:setting[@name = 'format'] = 'integer'">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateIntegerField', '<xsl:value-of select="@name" />']);
                                   </script>
                            </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$isRequired = 'true' and not($autoName) ">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="@name" />']);
                                   </script>
                                    </xsl:when>
                                    <xsl:when test="$isRequired = 'true' and normalize-space($autoName) != '' and normalize-space($autoNameChecked) = '' ">
                                           <script language="JavaScript">
                                                  myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="@name" />']);
                                           </script>
                                    </xsl:when>
                                    <xsl:when test="$isRequired = 'true' and normalize-space($autoName) != '' and normalize-space($autoNameChecked) != 'true' ">
                                           <script language="JavaScript">
                                                  myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="@name" />']);
                                           </script>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    </xsl:otherwise>
                                </xsl:choose>
                            <xsl:if test="aef:settings/aef:setting[@name = 'Input Type'] = 'textbox' or aef:settings/aef:setting[@name = 'Input Type'] = 'textarea'">
                                   <xsl:if test="aef:settings/aef:setting[@name = 'Validate Type'] = 'Basic'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForBadCharacters', '<xsl:value-of select="@name" />']);
                                          </script>
                                   </xsl:if>
                                   <xsl:if test="aef:settings/aef:setting[@name = 'Validate Type'] = 'Name'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForBadNameCharacters', '<xsl:value-of select="@name" />']);
                                          </script>
                                   </xsl:if>
                                   <xsl:if test="aef:settings/aef:setting[@name = 'Validate Type'] = 'Restricted'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForRestrictedBadCharacters', '<xsl:value-of select="@name" />']);
                                          </script>
                                   </xsl:if>
                            </xsl:if>
                            </xsl:otherwise>
                     </xsl:choose>
    </td>
       </xsl:template>



<!-- VERTICAL FIELD  -->
       <xsl:template name="verticalField" >
        <xsl:variable name="varFieldType" select="parent::node()/aef:setting[@name = 'Field Type']" />
        <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)" />
        <xsl:variable name="varName" select="parent::node()/parent::node()/@name" />
		<xsl:variable name="isMultiVal" select="parent::node()/parent::node()/@isMultiVal" />
       <xsl:variable name="isRequired">
                     <xsl:choose>
                     <xsl:when test="parent::node()/aef:setting[@name = 'Required'] and parent::node()/aef:setting[@name = 'Editable'] = 'true'">
                            <xsl:value-of select="parent::node()/aef:setting[@name = 'Required']" />
                     </xsl:when>
                     <xsl:otherwise>false</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
       <xsl:variable name="autoName" select="parent::node()/aef:setting[@name = 'autoName']" />
       <xsl:variable name="autoNameChecked" select="parent::node()/aef:setting[@name = 'AutoName Checked']" />
        <xsl:variable name="sortDirection">
              <xsl:choose>
                     <xsl:when test="parent::node()/aef:setting[@name = 'Sort Direction']">
                            <xsl:value-of select="parent::node()/aef:setting[@name = 'Sort Direction']" />
                     </xsl:when>
                     <xsl:otherwise>none</xsl:otherwise>
              </xsl:choose>
       </xsl:variable>
        <xsl:variable name="varGroupName" select="parent::node()/aef:setting[@name = 'Group Name']" />
        <xsl:variable name="inputType" select="parent::node()/aef:setting[@name = 'Input Type']" />
        <xsl:variable name="richTextEditor" select="parent::node()/parent::node()/@isRTEField" />
        <td class="inputField" valign="middle">
        	  <xsl:if test="$uiAutomation = 'true' ">
				   <xsl:attribute name="data-aid">
                	  <xsl:value-of select="$varName" />
        		   </xsl:attribute>
			  </xsl:if>
             <xsl:choose>
              <xsl:when test="$Field_Type = 'programhtmloutput'">
                  <div name="{$varName}_html" id="{$varName}_html">
                      <xsl:copy-of select="parent::node()/parent::node()/aef:actualValue/node()"/>
                     </div>                     
                     <xsl:if test="$isRequired = 'true'">
                            <script language="JavaScript">
                                   myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="$varName" />']);
                            </script>
                     </xsl:if>
                 </xsl:when>
                <xsl:otherwise>
                <xsl:choose>
                     <xsl:when test="parent::node()/aef:setting[@name = 'Editable'] = 'false'">
                            <xsl:choose>
                                   <xsl:when test="parent::node()/parent::node()/aef:displayValue = ''">&#160;</xsl:when>
                                   <xsl:otherwise>
                                          <xsl:choose>
                                                 <xsl:when test="string-length(@objectIcon) &gt; 0">
                                                        <table border="0" width="95%"><tr><td valign="top"><img border="0" src="{@objectIcon}" /></td><td><xsl:value-of select="parent::node()/parent::node()/aef:displayValue" /></td></tr></table>
                                                        <input type="hidden" name="{$varName}" value="{parent::node()/parent::node()/aef:actualValue}"/>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                         <xsl:value-of select="parent::node()/parent::node()/aef:displayValue" />
                                                         <input type="hidden" name="{$varName}" value="{parent::node()/parent::node()/aef:actualValue}"/>
                                                  </xsl:otherwise>
                                           </xsl:choose>
                                    </xsl:otherwise>
                             </xsl:choose>
                      </xsl:when>
                  <xsl:when test="normalize-space($Field_Type) = 'image'">
                        <xsl:element name="img">
                                <xsl:attribute name="src">images/<xsl:value-of select="parent::node()/aef:setting[@name = 'Image'] "/></xsl:attribute>
                                <xsl:attribute name="border">0</xsl:attribute>
                                <xsl:attribute name="height">16</xsl:attribute>
                                <xsl:attribute name="width">16</xsl:attribute>
                        </xsl:element>
                  </xsl:when>
              <xsl:otherwise>
              <xsl:if test="normalize-space($inputType)= 'combobox'">
              <xsl:variable name="classValue">
      					<xsl:if test="$isMultiVal = 'true'">
                	    	<xsl:value-of select="'multi-attr'" />
                	    </xsl:if>
              </xsl:variable>
              <table class="{$classValue}">
                    <tr><td>
                   <xsl:variable name="size" select="parent::node()/aef:setting[@name = 'Field Size']" />
                   <xsl:choose>
                     <xsl:when test="parent::node()/parent::node()/aef:manualEntryRange">
                            <select id="{$varName}Id" onChange="allowCustomInput(this,'{$varName}','{$varName}Idtxt',{$isRequired},false);">
                                   <xsl:attribute name="fieldLabel">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:attribute name="style">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($size) != 0">
                                                        width:<xsl:value-of select="$size" />px
                                                 </xsl:when>
                                          </xsl:choose>
                                   </xsl:attribute>
                                   <xsl:choose>
                                          <xsl:when test="@isSelected = 'false'">
                                                 <xsl:attribute name="name">
                                                        <xsl:value-of select="concat($varName,'_tmp')" />
                                                 </xsl:attribute>
                                          </xsl:when>
                                          <xsl:otherwise>
                                                 <xsl:attribute name="name">
                                                        <xsl:value-of select="$varName" />
                                                 </xsl:attribute>
                                          </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:call-template name="optionsVerticalField">
                                          <xsl:with-param name="sortDir" select="$sortDirection" />
                                   </xsl:call-template>
                                   <option>
                                          <xsl:attribute name="value">
                                                 <xsl:value-of select="parent::node()/parent::node()/aef:manualEntryRange/aef:value" />
                                          </xsl:attribute>
                                          <xsl:if test="@isSelected = 'true'">
                                                 <xsl:attribute name="selected">selected</xsl:attribute>
                                          </xsl:if>
                                          <xsl:value-of select="parent::node()/parent::node()/aef:manualEntryRange/aef:label" />
                                   </option>
                            </select>
                            <xsl:choose>
                            <xsl:when test="@isSelected = 'false'">
                            <xsl:call-template name="textbox">
                                   <xsl:with-param name="verticalField" select="1" />
                                   <xsl:with-param name="name" select="$varName" />
                                   <xsl:with-param name="id" select="concat($varName, 'Idtxt')" />
                                   <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                   <xsl:with-param name="label" select="@label" />
                                   <xsl:with-param name="keyEntry" select="false" />
                            </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:call-template name="textbox">
                                         <xsl:with-param name="verticalField" select="1" />
                                          <xsl:with-param name="id" select="concat($varName, 'Idtxt')" />
                                          <xsl:with-param name="label" select="@label" />
                                          <xsl:with-param name="disabled">disabled</xsl:with-param>
                                          <xsl:with-param name="keyEntry" select="false" />
                                   </xsl:call-template>
                            </xsl:otherwise>
                            </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                   <select id="{$varName}Id" name="{$varName}">
                                   <xsl:attribute name="onChange">
                                     <xsl:if test="$varName='TypeActual'">
                                            reload()
                                     </xsl:if>     
                                   </xsl:attribute>
                                   <xsl:attribute name="style">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($size) != 0">
                                                        width:<xsl:value-of select="$size" />px
                                                 </xsl:when>
                                          </xsl:choose>
                                   </xsl:attribute>
                                          <xsl:call-template name="optionsVerticalField">
                                                 <xsl:with-param name="sortDir" select="$sortDirection" />
                                          </xsl:call-template>
                                   </select>
                            </xsl:otherwise>
                     </xsl:choose>
                     </td>
                      	   <xsl:if test="$isMultiVal = 'true'">
                      	   <input type="hidden" name="{$varName}_order" id="{$varName}_order" value=""/>
 	           			 <td>
 	           			   <xsl:choose> 	           			 
			           	   <xsl:when test="$slideinui = 'true'">
			           	   			 <a id="formAddValue" name="addValueInCreateForm" onclick="addValueInCreateForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:when>
	              		   <xsl:otherwise>
			           	   			 <a id="formAddValue" name="addValueInEditForm" onclick="addValueInEditForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:otherwise>
			           	   </xsl:choose>
			           	 </td>
	               </xsl:if> 
                     </tr></table>
              </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'listbox'">
                     <xsl:variable name="size" select="parent::node()/aef:setting[@name = 'Field Size']" />
                     <select>
                            <xsl:attribute name="name">
                                   <xsl:value-of select="$varName" />
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                   <xsl:choose>
                                          <xsl:when test="string-length($size) != 0">
                                                 width:<xsl:value-of select="$size" />px
                                          </xsl:when>
                                   </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="multiple">true</xsl:attribute>
                            <xsl:attribute name="fieldLabel">
                                   <xsl:value-of select="@label" />
                            </xsl:attribute>
                            <xsl:call-template name="optionsVerticalField">
                                   <xsl:with-param name="sortDir" select="$sortDirection" />
                            </xsl:call-template>
                     </select>
              </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'radiobutton'">
                            <table border="0">
                                   <xsl:apply-templates select="parent::node()/parent::node()/aef:rangeValues/aef:range" mode="radiobutton"></xsl:apply-templates>
                            </table>
              </xsl:if>
              <xsl:if test="normalize-space($inputType) = 'checkbox'">
                    <table border="0">
                           <xsl:apply-templates select="parent::node()/parent::node()/aef:rangeValues/aef:range" mode="checkbox"></xsl:apply-templates>
                    </table>
             </xsl:if>
             <xsl:if test="normalize-space($inputType) = 'textarea'">
              <xsl:variable name="classValue">
      					<xsl:if test="$isMultiVal = 'true'">
                	    	<xsl:value-of select="'multi-attr'" />
                	    </xsl:if>
              </xsl:variable>
              <table class="{$classValue}">
                    <tr><td>
                            <xsl:variable name="size" select="parent::node()/aef:setting[@name = 'Field Size']" />
                            <xsl:variable name="colssetting" select="parent::node()/aef:setting[@name = 'Cols']" />
                            <textarea>
                                   <xsl:attribute name="cols">
                                          <xsl:choose>
                                                 <xsl:when test="string-length($colssetting) != 0">
                                                      <xsl:value-of select="$colssetting" />
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                 <xsl:choose>
                                                        <xsl:when test="string-length($size) != 0">
                                                               <xsl:value-of select="$size" />
                                                        </xsl:when>
                                                        <xsl:otherwise>25</xsl:otherwise>
                                                 </xsl:choose>
                                                 </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:attribute>
                                   <xsl:attribute name="rows">5</xsl:attribute>
                                   <xsl:if test="normalize-space($richTextEditor) = 'true'">
                                   <xsl:attribute name="class">rte</xsl:attribute>
                                   </xsl:if>
                                   
                                   <xsl:attribute name="name">
                                          <xsl:value-of select="$varName" />
                                   </xsl:attribute>
                                    <xsl:attribute name="id">
                                          <xsl:value-of select="concat($varName, 'Id')" />
                                   </xsl:attribute>
                                   <xsl:attribute name="fieldLabel">
                                          <xsl:value-of select="@label" />
                                   </xsl:attribute>
                                   <xsl:value-of select="parent::node()/parent::node()/aef:displayValue" />
                            </textarea>
                            </td>
                             <xsl:if test="$isMultiVal = 'true'">
                             <input type="hidden" name="{@name}_order" id="{@name}_order" value=""/>
 	           			 <td>
 	           			   <xsl:choose> 	           			 
			           	   <xsl:when test="$slideinui = 'true'">
			           	   			 <a id="formAddValue" name="addValueInCreateForm" onclick="addValueInCreateForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:when>
	              		   <xsl:otherwise>
			           	   			 <a id="formAddValue" name="addValueInEditForm" onclick="addValueInEditForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
			           	   </xsl:otherwise>
			           	   </xsl:choose>
			           	 </td>
			           	 </xsl:if>
                            <xsl:if test="parent::node()/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                   <a>
                                          <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="$varName" />')
                                          </xsl:attribute>
                                          <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                   </a>
                            </xsl:if>
                            </tr></table>
           </xsl:if>
           <xsl:if test="normalize-space($inputType) = 'textbox'">
                            <xsl:choose>
                                   <xsl:when test="parent::node()/aef:setting[@name = 'format'] = 'date'">
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="verticalField" select="1" />
                                                 <xsl:with-param name="name" select="$varName" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                                 <xsl:with-param name="id" select="$varName" />
                                                 <xsl:with-param name="maxLength" select="parent::node()/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="keyEntry">false</xsl:with-param>
                                          </xsl:call-template>
                        <!-- Added:For Enhanced Calendar Control:AEF:nr2:20-11-09 -->
                                        <xsl:variable name="CalendarProgram" select="normalize-space(aef:settings/aef:setting[@name = 'Calendar Program'])" />
                                        <xsl:variable name="CalendarFunction" select="normalize-space(aef:settings/aef:setting[@name = 'Calendar Function'])" />                                                                                 
                                        <xsl:variable name="InputType" select="normalize-space(aef:settings/aef:setting[@name = 'Input Type'])" />
                                        <xsl:variable name="format" select="normalize-space(aef:settings/aef:setting[@name = 'format'])" />
                                       <!--  <xsl:variable name="calBeanTimeStamp" select="normalize-space(../../aef:requestMap/aef:setting[@name = 'timeStamp'])" />  -->
                                        <xsl:variable name="calBeanTimeStamp" select="normalize-space(../../../aef:mxRoot/aef:setting[@name = 'timeStamp'])" />

                                        <xsl:variable name="calReqMap">
                                            <xsl:text>{"CalendarProgram":"</xsl:text><xsl:value-of select="$CalendarProgram" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"CalendarFunction":"</xsl:text><xsl:value-of select="$CalendarFunction" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"InputType":"</xsl:text><xsl:value-of select="$InputType" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"format":"</xsl:text><xsl:value-of select="$format" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"calBeanTimeStamp":"</xsl:text><xsl:value-of select="$calBeanTimeStamp" /><xsl:text>"</xsl:text>
                                            <xsl:text>,"componentType":"form"</xsl:text>
                                            <!-- Added:25-01-10:nr2:IR-035216V6R2011 -->
                                            <xsl:text>,"columnName":"</xsl:text><xsl:value-of select="@name" /><xsl:text>"</xsl:text>
                                            <!-- End:25-01-10:nr2:IR-035216V6R2011 -->
                                            <xsl:text>,"mode":"create"}</xsl:text>
                                        </xsl:variable>
                        <!-- End:For Enhanced Calendar Control:AEF:nr2:20-11-09 -->
                                          <a id="formDateChooser" name="{$varName}_date" href="javascript:showCalendar('emxCreateForm', '{$varName}', '{parent::node()/parent::node()/aef:displayValue}','','','','','{$calReqMap}');">
                                                 <img src="../common/images/iconSmallCalendar.gif" alt="Date Picker" border="0" />
                                          </a>
                                          <xsl:if test="parent::node()/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                 <a>
                                                        <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="$varName" />')
                                                        </xsl:attribute>
                                                        <xsl:value-of select="parent::node()/aef:setting[@name = 'clear']" />
                                                 </a>
                                          </xsl:if>
                                               <xsl:choose>
                                                 <xsl:when test="@canKeyDate = 'true'">
                                                        <br />
                                                        <span class="hint">(<xsl:value-of select="parent::node()/parent::node()/aef:locDatefrmt" />)</span>
                                                 </xsl:when>
                                          </xsl:choose>
                                          <input type="hidden" name="{$varName}_msvalue" value="{parent::node()/parent::node()/aef:msValue}" />
                                   </xsl:when>
                                   <xsl:when test="parent::node()/parent::node()/aef:rangeURL">
                                          <xsl:choose>
                                                 <xsl:when test="parent::node()/parent::node()/aef:TypeAhead or parent::node()/aef:setting[@name = 'Allow Manual Edit'] = 'true'">

                                                        <xsl:call-template name="textbox">
                                                               <xsl:with-param name="verticalField" select="1" />
                                                               <xsl:with-param name="name" select="concat($varName, 'Display')" />
                                                               <xsl:with-param name="label" select="@label" />
                                                               <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                                               <xsl:with-param name="maxLength" select="parent::node()/aef:setting[@name = 'Maximum Length']" />
                                                               <xsl:with-param name="typeaheadList" select="parent::node()/parent::node()/aef:TypeAhead" />
                                                               <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                                        </xsl:call-template>
                                                        <input type="hidden" name="{$varName}" value="{parent::node()/parent::node()/aef:actualValue}" />
                                                        <input type="hidden" name="{$varName}OID" value="{parent::node()/parent::node()/aef:fieldValueOID}" />
                                                        <input type="button" name="btn{$varName}" value="..." onclick="{parent::node()/parent::node()/aef:rangeURL}" />
                                                        <xsl:if test="parent::node()/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                               <a><xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="$varName" />')</xsl:attribute>
                                                                      <xsl:value-of select="//aef:mxRoot/aef:setting[@name = 'clear']" />
                                                               </a>
                                                        </xsl:if>
                                                 </xsl:when>
                                                 <xsl:otherwise>
                                                 <xsl:call-template name="textbox">
                                                        <xsl:with-param name="verticalField" select="1" />
                                                        <xsl:with-param name="name" select="concat($varName, 'Display')" />
                                                        <xsl:with-param name="label" select="@label" />
                                                        <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                                        <xsl:with-param name="maxLength" select="parent::node()/aef:setting[@name = 'Maximum Length']" />
                                                        <xsl:with-param name="keyEntry">false</xsl:with-param>
                                                 </xsl:call-template>
                                                 <input type="hidden" name="{varName}" value="{parent::node()/parent::node()/aef:actualValue}" />
                                                 <input type="hidden" name="{varName}OID" value="{parent::node()/parent::node()/aef:fieldValueOID}" />
                                                 <input type="button" name="btn{varName}" value="..." onclick="{parent::node()/parent::node()/aef:rangeURL}" />
                                                 <xsl:if test="parent::node()/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                        <a>
                                                               <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="concat($varName, 'Display')" />')</xsl:attribute>
                                                               <xsl:value-of select="parent::node()/aef:setting[@name = 'clear']" />
                                                        </a>
                                                 </xsl:if>
                                                 </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:when>
                                   <xsl:when test="parent::node()/aef:setting[@name = 'format'] = 'user' and parent::node()/aef:setting[@name = 'Editable'] = 'false'">
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="verticalField" select="1" />
                                                 <xsl:with-param name="name" select="concat($varName,'Display')" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                                 <xsl:with-param name="maxLength" select="parent::node()/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="keyEntry" select="@canKeyDate" />
                                          </xsl:call-template>
                                          <input type="hidden" name="{$varName}" value="{parent::node()/parent::node()/aef:actualValue}" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                    <xsl:variable name="classValue">
					      					<xsl:if test="$isMultiVal = 'true'">
					                	    	<xsl:value-of select="'multi-attr'" />
					                	    </xsl:if>
					                </xsl:variable>
									<table class="{$classValue}">
											<tr><td>
                                          <xsl:call-template name="textbox">
                                                 <xsl:with-param name="verticalField" select="1" />
                                                 <xsl:with-param name="name" select="$varName" />
                                                 <xsl:with-param name="label" select="@label" />
                                                 <xsl:with-param name="id" select="$varName" />
                                                 <xsl:with-param name="value" select="parent::node()/parent::node()/aef:displayValue" />
                                                 <xsl:with-param name="maxLength" select="parent::node()/aef:setting[@name = 'Maximum Length']" />
                                                 <xsl:with-param name="autoName" select="parent::node()/aef:setting[@name = 'autoName']" />                                                                                                                        
                                                 <xsl:with-param name="keyEntry" select="@canKeyDate" />                                                                                                                       
                                          </xsl:call-template>
                                          <xsl:if test="parent::node()/parent::node()/@isUOMAttribute = 'true'">
                                          <select name="{parent::node()/parent::node()/@UOMDisplayName}" id="{parent::node()/parent::node()/@UOMDisplayName}Id">                                                                                                              
                                                 <xsl:for-each select="parent::node()/parent::node()/aef:rangeValues/aef:range">
                                                        <xsl:sort select="aef:label" order="ascending" />
                                                 
                                                        <option>
                                                        <xsl:attribute name="value">
                                                               <xsl:value-of select="aef:value" />
                                                        </xsl:attribute>
                                                        <xsl:if test="@selected = 'true'">
                                                               <xsl:attribute name="selected">
                                                                      selected
                                                               </xsl:attribute>
                                                        </xsl:if>
                                                        <xsl:value-of select="aef:label" />
                                                        </option>
                                                 </xsl:for-each>
                                          </select>
                                          </xsl:if>
                                          </td>
                                          <xsl:if test="$isMultiVal = 'true'">
                                          <input type="hidden" name="{$varName}_order" id="{$varName}_order" value=""/>
					 	           			 <td>
					 	           			   <xsl:choose> 	           			 
								           	   <xsl:when test="$slideinui = 'true'">
								           	   			 <a id="formAddValue" name="addValueInCreateForm" onclick="addValueInCreateForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
								           	   </xsl:when>
						              		   <xsl:otherwise>
								           	   			 <a id="formAddValue" name="addValueInEditForm" onclick="addValueInEditForm('{$varName}')" href="javascript:void(0);"><img src="../common/images/iconActionListAdd.gif" alt="Add Value Create Form" border="0" /></a>
								           	   </xsl:otherwise>
								           	   </xsl:choose>
								           	 </td>
			      				     	 </xsl:if>
                                          <xsl:if test="parent::node()/aef:setting[@name = 'Show Clear Button'] = 'true'">
                                                 <a>
                                                        <xsl:attribute name="href">javascript:basicClear('<xsl:value-of select="$varName" />')
                                                        </xsl:attribute>
                                                        <xsl:value-of select="parent::node()/aef:setting[@name = 'clear']" />
                                                 </a>
                                          </xsl:if>
                                          </tr></table>
                                   </xsl:otherwise>
                                   </xsl:choose>
                            </xsl:if>
                            </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                   <xsl:when test="parent::node()/aef:setting[@name = 'Validate']">
                                          <script language="JavaScript">
                                                 myValidationRoutines1.push(['assignValidateMethod', '<xsl:value-of select="$varName" />', '<xsl:value-of select="parent::node()/aef:setting[@name = 'Validate']" />']);
                                          </script>
                                   </xsl:when>
                                </xsl:choose>
                            <xsl:if test="parent::node()/aef:setting[@name = 'format'] = 'numeric'">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateNumericField', '<xsl:value-of select="$varName" />']);
                                   </script>
                            </xsl:if>
                            <xsl:if test="parent::node()/aef:setting[@name = 'format'] = 'integer'">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateIntegerField', '<xsl:value-of select="$varName" />']);
                                   </script>
                            </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$isRequired = 'true' and not($autoName) ">
                                   <script language="JavaScript">
                                          myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="$varName" />']);
                                   </script>
                                    </xsl:when>
                                    <xsl:when test="$isRequired = 'true' and normalize-space($autoName) != '' and normalize-space($autoNameChecked) = '' ">
                                           <script language="JavaScript">
                                                  myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="$varName" />']);
                                           </script>
                                    </xsl:when>
                                    <xsl:when test="$isRequired = 'true' and normalize-space($autoName) != '' and normalize-space($autoNameChecked) != 'true' ">
                                           <script language="JavaScript">
                                                  myValidationRoutines.push(['validateRequiredField', '<xsl:value-of select="$varName" />']);
                                           </script>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    </xsl:otherwise>
                                </xsl:choose>
                            <xsl:if test="parent::node()/aef:setting[@name = 'Input Type'] = 'textbox' or parent::node()/aef:setting[@name = 'Input Type'] = 'textarea'">
                                   <xsl:if test="parent::node()/aef:setting[@name = 'Validate Type'] = 'Basic'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForBadCharacters', '<xsl:value-of select="$varName" />']);
                                          </script>
                                   </xsl:if>
                                   <xsl:if test="parent::node()/aef:setting[@name = 'Validate Type'] = 'Name'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForBadNameCharacters', '<xsl:value-of select="$varName" />']);
                                          </script>
                                   </xsl:if>
                                   <xsl:if test="parent::node()/aef:setting[@name = 'Validate Type'] = 'Restricted'">
                                          <script language="JavaScript">
                                                 myValidationRoutines.push(['validateForRestrictedBadCharacters', '<xsl:value-of select="$varName" />']);
                                          </script>
                                   </xsl:if>
                            </xsl:if>
                            </xsl:otherwise>
                     </xsl:choose>
              </td>
       </xsl:template>
</xsl:stylesheet>
