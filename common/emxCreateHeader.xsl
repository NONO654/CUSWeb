<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:aef="http://www.matrixone.com/aef">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:template name="pageHead">
        <div id="pageHeadDiv">
	        <table>
	            <tr>
                    <td class="page-title">
	            <h2>
					<xsl:attribute name="title">
						<xsl:value-of select="aef:setting[@name='header']"/>
					</xsl:attribute>
					<xsl:value-of select="aef:setting[@name='header']"/>
				</h2>
			<xsl:if test="aef:setting[@name='subHeader']">
	                <h3>
						<xsl:attribute name="title">
							<xsl:value-of select="aef:setting[@name='subHeader']"/>
						</xsl:attribute>
						<xsl:value-of select="aef:setting[@name='subHeader']"/>
					</h3>
			</xsl:if>
		             </td>
                    <td class="functions">
            <table>
              <tr>
                <td class="progress-indicator">
                     <div id="imgProgressDiv" style="visibility: hidden;"></div>
                </td>
              </tr>
             </table>
                    </td>
                  </tr>
             </table>
                     		
		<!-- TOOLBAR DIV -->
		<div class="toolbar-container" id="divToolbarContainer">
			<div id="divToolbar" class="toolbar-frame"/>
			</div>
		</div>

	</xsl:template>
</xsl:stylesheet>
