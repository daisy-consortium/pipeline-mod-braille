<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@css:before or @css:after or @css:duplicate]">
        <xsl:variable name="id" select="if (@css:id) then string(@css:id) else generate-id(.)"/>
        <xsl:copy>
            <xsl:sequence select="@* except (@css:before|@css:after|@css:duplicate)"/>
            <xsl:if test="@css:duplicate">
                <xsl:attribute name="css:id" select="$id"/>
            </xsl:if>
            <xsl:if test="@css:before">
                <css:before style="{@css:before}"/>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="@css:after">
                <css:after style="{@css:after}"/>
            </xsl:if>
        </xsl:copy>
        <xsl:if test="@css:duplicate">
            <css:duplicate css:anchor="{$id}" style="{@css:duplicate}">
                <xsl:sequence select="@* except (@style|@css:id|@css:anchor|@css:before|@css:after|@css:duplicate)"/>
                <xsl:apply-templates/>
            </css:duplicate>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
