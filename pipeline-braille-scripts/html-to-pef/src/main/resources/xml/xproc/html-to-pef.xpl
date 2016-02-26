<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:html-to-pef" version="1.0"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pef="http://www.daisy.org/ns/2008/pef"
                exclude-inline-prefixes="#all"
                name="main">
    
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <h1 px:role="name">HTML to PEF</h1>
        <p px:role="desc">Transforms a HTML document into a PEF.</p>
        <dl px:role="author">
            <dt>Name:</dt>
            <dd px:role="name">Jostein Austvik Jacobsen</dd>
            <dt>Organization:</dt>
            <dd px:role="organization" href="http://www.nlb.no/">NLB</dd>
            <dt>E-mail:</dt>
            <dd><a px:role="contact" href="mailto:josteinaj@gmail.com">josteinaj@gmail.com</a></dd>
        </dl>
    </p:documentation>
    
    <p:option name="html" required="true" px:type="anyFileURI" px:sequence="false" px:media-type="application/xhtml+xml text/html">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <h2 px:role="name">Input HTML</h2>
            <p px:role="desc">The HTML you want to convert to braille.</p>
        </p:documentation>
    </p:option>
    
    <p:option name="stylesheet"/>
    <p:option name="transform"/>
    <p:option name="ascii-table"/>
    <p:option name="include-preview"/>
    <p:option name="include-brf"/>
    <p:option name="page-width"/>
    <p:option name="page-height"/>
    <p:option name="predefined-page-formats"/>
    <p:option name="left-margin"/>
    <p:option name="duplex"/>
    <p:option name="levels-in-footer"/>
    <p:option name="main-document-language"/>
    <p:option name="hyphenation"/>
    <p:option name="line-spacing"/>
    <p:option name="tab-width"/>
    <p:option name="capital-letters"/>
    <p:option name="accented-letters"/>
    <p:option name="polite-forms"/>
    <p:option name="downshift-ordinal-numbers"/>
    <p:option name="include-captions"/>
    <p:option name="include-images"/>
    <p:option name="include-image-groups"/>
    <p:option name="include-line-groups"/>
    <p:option name="text-level-formatting"/>
    <p:option name="include-note-references"/>
    <p:option name="include-production-notes"/>
    <p:option name="show-braille-page-numbers"/>
    <p:option name="show-print-page-numbers"/>
    <p:option name="force-braille-page-break"/>
    <p:option name="toc-depth"/>
    <p:option name="ignore-document-title"/>
    <p:option name="include-symbols-list"/>
    <p:option name="choice-of-colophon"/>
    <p:option name="footnotes-placement"/>
    <p:option name="colophon-metadata-placement"/>
    <p:option name="rear-cover-placement"/>
    <p:option name="number-of-pages"/>
    <p:option name="maximum-number-of-pages"/>
    <p:option name="minimum-number-of-pages"/>
    <p:option name="sbsform-macros"/>
    <p:option name="output-dir"/>
    <p:option name="brf-output-dir" required="false"/>
    <p:option name="html-output-dir" required="false"/>
    <p:option name="temp-dir" required="false"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/html-to-pef/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/html-utils/library.xpl"/>
    
    <!-- ================================================= -->
    <!-- Create a <c:param-set/> of the options            -->
    <!-- ================================================= -->
    <!-- ...for easy piping so we won't have to explicitly -->
    <!-- pass all the variables all the time.              -->
    <!-- ================================================= -->
    <p:in-scope-names name="in-scope-names"/>
    <p:identity>
        <p:input port="source">
            <p:pipe port="result" step="in-scope-names"/>
        </p:input>
    </p:identity>
    <p:insert match="/*" position="last-child">
        <p:input port="insertion">
            <p:inline>
                <c:param name="default-stylesheet" value="http://www.daisy.org/pipeline/modules/braille/html-to-pef/css/default.css"/>
            </p:inline>
        </p:input>
    </p:insert>
    <p:add-attribute match="/*/*[@name='transform']" attribute-name="value">
        <p:with-option name="attribute-value"  select="if ($transform!='') then $transform
                                                                           else '(translator:liblouis)(formatter:dotify)'"/>
    </p:add-attribute>
    <p:identity name="input-options"/>
    <p:sink/>
    
    <!-- =============== -->
    <!-- CREATE TEMP DIR -->
    <!-- =============== -->
    <px:tempdir name="temp-dir">
        <p:with-option name="href" select="if ($temp-dir!='') then $temp-dir else $output-dir"/>
    </px:tempdir>
    
    <!-- ========= -->
    <!-- LOAD HTML -->
    <!-- ========= -->
    <px:message message="Loading HTML"/>
    <px:html-load name="html">
        <p:with-option name="href" select="$html"/>
    </px:html-load>
    
    <!-- ============ -->
    <!-- HTML TO PEF -->
    <!-- ============ -->
    <px:message message="Done loading HTML, starting conversion to PEF"/>
    <px:html-to-pef.convert name="convert">
        <p:with-option name="temp-dir" select="concat(string(/c:result),'convert/')">
            <p:pipe step="temp-dir" port="result"/>
        </p:with-option>
        <p:input port="parameters">
            <p:pipe port="result" step="input-options"/>
        </p:input>
    </px:html-to-pef.convert>
    
    <!-- ========= -->
    <!-- STORE PEF -->
    <!-- ========= -->
    <px:message message="Storing PEF"/>
    <pef:store>
        <p:with-option name="output-dir" select="$output-dir"/>
        <p:with-option name="name" select="replace(p:base-uri(/),'^.*/([^/]*)\.[^/\.]*$','$1')">
            <p:pipe step="html" port="result"/>
        </p:with-option>
        <p:with-option name="brf-table" select="if ($ascii-table!='') then $ascii-table
                                                else concat('(locale:',(/*/@xml:lang,'und')[1],')')">
            <p:pipe step="html" port="result"/>
        </p:with-option>
        <p:with-option name="include-preview" select="$include-preview"/>
        <p:with-option name="include-brf" select="$include-brf"/>
    </pef:store>
    
</p:declare-step>
