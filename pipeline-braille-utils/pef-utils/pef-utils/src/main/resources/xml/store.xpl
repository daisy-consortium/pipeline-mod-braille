<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                exclude-inline-prefixes="#all"
                type="pef:store" name="store" version="1.0">
    
    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>
    
    <p:option name="href" required="true"/>
    <p:option name="preview-href" required="false" select="''"/>
    <p:option name="brf-href" required="false" select="''"/>
    
    <p:option name="brf-table" required="false" select="'(id:&quot;org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US&quot;)'"/>
    
    <p:import href="pef-to-html.convert.xpl"/>
    <p:import href="pef2text.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    
    <!-- ============ -->
    <!-- STORE AS PEF -->
    <!-- ============ -->
    
    <px:message>
        <p:with-option name="message" select="concat('[progress pef:store 1 p:store] Storing PEF as ''', $href,'''')"/>
    </px:message>
    <p:store indent="true" encoding="utf-8" omit-xml-declaration="false" name="store.pef">
        <p:input port="source">
            <p:pipe step="store" port="source"/>
        </p:input>
        <p:with-option name="href" select="$href"/>
    </p:store>
    
    <!-- ============ -->
    <!-- STORE AS BRF -->
    <!-- ============ -->
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="store" port="source"/>
        </p:input>
    </p:identity>
    <p:choose name="choose.pef2text">
        <p:when test="not($brf-href='')">
            <px:message>
                <p:with-option name="message" select="concat('[progress pef:store 17 pef:pef2text] Storing BRF as ''', $brf-href, '''')"/>
            </px:message>
            <pef:pef2text breaks="DEFAULT" pad="BOTH">
                <p:with-option name="href" select="$brf-href"/>
                <p:with-option name="table" select="$brf-table"/>
            </pef:pef2text>
        </p:when>
        <p:otherwise>
            <px:message message="[progress pef:store 17] Not storing as BRF"/>
            <p:sink/>
        </p:otherwise>
    </p:choose>
    
    <!-- ==================== -->
    <!-- STORE AS PEF PREVIEW -->
    <!-- ==================== -->
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="store" port="source"/>
        </p:input>
    </p:identity>
    <p:choose>
        <p:when test="not($preview-href='')">
            <px:message>
                <p:with-option name="message" select="concat('[progress pef:store 80 px:pef-to-html.convert] Converting PEF to HTML preview using the BRF table ''',$brf-table,'''')"/>
            </px:message>
            <px:pef-to-html.convert>
                <p:with-option name="table" select="$brf-table"/>
            </px:pef-to-html.convert>
            <px:message>
                <p:with-option name="message" select="concat('[progress pef:store 1 p:store] Storing HTML preview as ''', $preview-href, '''')"/>
            </px:message>
            <p:store indent="false" encoding="utf-8" method="xhtml" omit-xml-declaration="false"
                     doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                <p:with-option name="href" select="$preview-href"/>
            </p:store>
            <!--
                because copy-resource does not create parent directory
            -->
            <px:mkdir name="mkdir">
                <p:with-option name="href" select="resolve-uri('./',$preview-href)"/>
            </px:mkdir>
            <p:identity>
                <p:input port="source">
                    <p:inline>
                        <irrelevant/>
                    </p:inline>
                </p:input>
            </p:identity>
            <px:message message="[progress pef:store 1 px:copy-resource] Copying braille font file (odt2braille8.ttf) to HTML preview directory"/>
            <px:copy-resource fail-on-error="true" cx:depends-on="mkdir">
                <p:with-option name="href" select="resolve-uri('../odt2braille8.ttf')"/>
                <p:with-option name="target" select="resolve-uri('odt2braille8.ttf', $preview-href)"/>
            </px:copy-resource>
            <p:sink/>
        </p:when>
        <p:otherwise>
            <px:message message="[progress pef:store 82] Not including HTML preview"/>
            <p:sink/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
