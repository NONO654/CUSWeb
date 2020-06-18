<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:aef="http://www.matrixone.com/aef">
        <xsl:output method="html" version="1.0" encoding="UTF-8" indent="no"/>
        <xsl:template name="pageFooter">
                <div id="divDialogButtons">
                        <table>
                                <tr>
                                <td class="functions"></td>
                                <td class="buttons">
                                        <table>
                                                <tr>
                                                <td><a class="footericon" href="javascript:void(0)" onClick="saveCreateChanges(false,'{$targetLocation}')"><img src="images/buttonDialogDone.gif" border="0" alt="Done"/></a></td>
                                    <td><a href="javascript:void(0)" onClick="saveCreateChanges(false,'{$targetLocation}')" class="button"><button class="btn-primary" type="button"><xsl:value-of select="aef:setting[@name = 'done']"/></button></a></td>
                                    <td>&amp;#160;</td>
                                    	<xsl:choose>
                                    		<xsl:when test="$showApply = 'true'">                                    		
                                                       <td><a class="footericon" href="javascript:void(0)" onClick="saveCreateChanges(true,'{$targetLocation}')"><img src="images/buttonDialogApply.gif" border="0" alt="Apply"/></a></td>
                                   <td><a href="javascript:void(0)" onClick="saveCreateChanges(true,'{$targetLocation}')" class="button"><button class="btn-default" type="button"><xsl:value-of select="aef:setting[@name = 'apply']"/></button></a></td>
                                   				<td>&amp;#160;</td>
                                   			<xsl:choose>
                                   				<xsl:when test="$targetLocation = 'slidein' or $slideinType = 'wider'">
                                   					<td><div id="cancelImage"><a class="footericon" href="javascript:void(0)" onClick="closeSlideinWindow(getTopWindow())"><img src="images/buttonDialogCancel.gif" border="0" alt="Cancel"/></a></div></td>
                                                    <td><div id="cancelText"><a href="javascript:void(0)" onClick="closeSlideinWindow(getTopWindow())" class="button"><button class="btn-default" type="button"><xsl:value-of select="aef:setting[@name = 'close']"/></button></a></div></td>
                                                </xsl:when>
                                   				<xsl:otherwise>
                                   					<td><div id="cancelImage"><a class="footericon" href="javascript:void(0)" onClick="closePopupWindow(getTopWindow())"><img src="images/buttonDialogCancel.gif" border="0" alt="Close"/></a></div></td>
                                    				<td><div id="cancelText"><a href="javascript:void(0)" onClick="closePopupWindow(getTopWindow())" class="button"><button class="btn-default" type="button"><xsl:value-of select="aef:setting[@name = 'close']"/></button></a></div></td>
                                      			</xsl:otherwise>
                                      		</xsl:choose>
                                    		</xsl:when>
                                    	<xsl:otherwise>                                    		
                                                  <xsl:choose>
                                                      <xsl:when test="$targetLocation = 'slidein' or $slideinType = 'wider'">
                                                        <td><div id="cancelImage"><a class="footericon" href="javascript:void(0)" onClick="closeSlideinWindow(getTopWindow())"><img src="images/buttonDialogCancel.gif" border="0" alt="Cancel"/></a></div></td>
                                                         <td><div id="cancelText"><a href="javascript:void(0)" onClick="closeSlideinWindow(getTopWindow())" class="button"><button class="btn-default" type="button"><xsl:value-of select="aef:setting[@name = 'cancel']"/></button></a></div></td>
                                                      </xsl:when>
                                                      <xsl:otherwise>
                                   					<td><div id="cancelImage"><a class="footericon" href="javascript:void(0)" onClick="closePopupWindow(getTopWindow())"><img src="images/buttonDialogCancel.gif" border="0" alt="Close"/></a></div></td>
                                    <td><div id="cancelText"><a href="javascript:void(0)" onClick="closePopupWindow(getTopWindow())" class="button"><button class="btn-default" type="button"><xsl:value-of select="aef:setting[@name = 'cancel']"/></button></a></div></td>
                                      </xsl:otherwise>
                                                  </xsl:choose>
                                    	</xsl:otherwise>
                                    	</xsl:choose>
                                                        </tr>
                                        </table>
                                </td>
                                </tr>
                        </table>
        </div>
        
                <script type="text/javascript">
                		var field = null;
                        <xsl:variable name="quote">"</xsl:variable>
                        <xsl:variable name="escape">\"</xsl:variable>
                        <xsl:variable name="escapeChar">\</xsl:variable>
                        <xsl:variable name="doubleEscapeChar">\\</xsl:variable>
                        <xsl:for-each select="//aef:fields/aef:field">
                                field = FieldFactory.CreateField("<xsl:value-of select="@name" />","<xsl:value-of select="normalize-space(./aef:settings/aef:setting[@name = 'Field Type'])" />","<xsl:value-of select="normalize-space(./aef:settings/aef:setting[@name = 'Input Type'])" />","<xsl:value-of select="normalize-space(./aef:settings/aef:setting[@name = 'format'])" />","<xsl:value-of select="@isUOMAttribute" />");
                                
                                <xsl:for-each select="./aef:settings/aef:setting">                              
                                        <xsl:variable name="varActualValue" select="normalize-space(text())"/>
                                <xsl:variable name="jsActualValue"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="$varActualValue"/><xsl:with-param name="from" select="$quote"/><xsl:with-param name="to" select="$escape"/></xsl:call-template></xsl:variable>
                                        field.AddSetting( new Setting("<xsl:value-of select="normalize-space(@name)"/>","<xsl:value-of select="normalize-space($jsActualValue)"/>"));
                                </xsl:for-each>
                                
                                <xsl:for-each select="./aef:rangeValues/aef:range">
                                        <xsl:variable name="varLabelValue" select="./aef:label/text()"/>
                                <xsl:variable name="jsLableValueEsc"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="$varLabelValue"/><xsl:with-param name="from" select="$escapeChar"/><xsl:with-param name="to" select="$doubleEscapeChar"/></xsl:call-template></xsl:variable>
                                <xsl:variable name="jsLableValue"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="$jsLableValueEsc"/><xsl:with-param name="from" select="$quote"/><xsl:with-param name="to" select="$escape"/></xsl:call-template></xsl:variable>
                                <xsl:variable name="varRangeValue" select="./aef:value/text()"/>     
                                <xsl:variable name="jsRangeValueEsc"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="$varRangeValue"/><xsl:with-param name="from" select="$escapeChar"/><xsl:with-param name="to" select="$doubleEscapeChar"/></xsl:call-template></xsl:variable>
                                <xsl:variable name="jsRangeValue"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="$jsRangeValueEsc"/><xsl:with-param name="from" select="$quote"/><xsl:with-param name="to" select="$escape"/></xsl:call-template></xsl:variable>
                                    field.AddRange(new Range("<xsl:value-of select="normalize-space($jsLableValue)"/>","<xsl:value-of select="normalize-space($jsRangeValue)"/>"));			
                                </xsl:for-each>
                                
                                FormHandler.AddField(field);
                </xsl:for-each>
                                
                    FormHandler.SetPreProcess("<xsl:value-of select="//aef:requestMap/aef:setting[@name='preProcessJavaScript']" />");
                    FormHandler.SetFormType("CreateForm");
                    modifyRedundantFields();
                                          <xsl:choose>
                                                      <xsl:when test="$targetLocation = 'slidein' or $slideinType = 'wider'">                                                   
                                                      </xsl:when>
                                                      <xsl:otherwise>
                    registerChildWindows(getTopWindow(), getTopWindow().getWindowOpener());
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                    
        </script>
        </xsl:template>
                
        <!-- 
     ! utility template
     !-->
    <xsl:template name="replace-string">
            <xsl:param name="text"/>
            <xsl:param name="from"/>
            <xsl:param name="to"/>
            <xsl:choose>
              <xsl:when test="contains($text, $from)">  
                <xsl:variable name="before" select="substring-before($text, $from)"/>
                <xsl:variable name="after" select="substring-after($text, $from)"/>
                <xsl:variable name="prefix" select="concat($before, $to)"/>     
                <xsl:value-of select="$before"/>
                <xsl:value-of select="$to"/>
                <xsl:call-template name="replace-string">
                  <xsl:with-param name="text" select="$after"/>
                  <xsl:with-param name="from" select="$from"/>
                  <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
              </xsl:when> 
              <xsl:otherwise>
                <xsl:value-of select="$text"/>  
              </xsl:otherwise>
            </xsl:choose>
        </xsl:template>
        
</xsl:stylesheet>
