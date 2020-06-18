<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:include href="emxFreezePaneTree.xsl"/>
	<xsl:include href="emxFreezePaneTable.xsl"/>
	<xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
	<xsl:variable name="isUnix" select="/mxRoot/setting[@name='isUnix']"/>
	<xsl:variable name="urlParameters">uiType=structureBrowser&amp;timeStamp=<xsl:value-of select="//setting[@name='timeStamp']"/>&amp;rowBuffer=<xsl:value-of select="//setting[@name='rowBuffer']"/>&amp;<xsl:for-each select="//requestMap/setting[not(@name='timeStamp')]">
			<xsl:value-of select="@name"/>=<xsl:value-of select="text()"/>
			<xsl:if test="position()!=last()">&amp;</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="level" select="/mxRoot/level"/>
	<xsl:template match="/mxRoot">
		<html>
			<head>
				<title>tree and table</title>
				<script type="text/javascript">	
					function callParent(){
						parent.editableTable.copyHTML();
					}
				</script>
			</head>
			<body onload="callParent()">
				<div id="copyTree">
					<xsl:apply-templates select="//rows/r" mode="treeBodyTree"/>
				</div>
				<div id="copyTable">
					<table>
						<tbody>
							<xsl:apply-templates select="/mxRoot/rows/r">
								<xsl:with-param name="tblName" select="'bodyTable'"/>
							</xsl:apply-templates>
						</tbody>
					</table>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
