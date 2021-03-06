<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="px:fileset-add-tempfile"
                name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:d="http://www.daisy.org/ns/pipeline/data"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="directory" primary="true"/>
    <p:input port="source"/>
    
    <p:output port="result">
        <p:pipe step="result" port="result"/>
    </p:output>
    
    <p:option name="media-type" required="true"/>
    <p:option name="suffix" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/library.xpl"/>
    
    <px:tempfile delete-on-exit="false" name="file">
        <p:with-option name="href" select="/d:fileset/@xml:base">
            <p:pipe step="main" port="directory"/>
        </p:with-option>
        <p:with-option name="suffix" select="$suffix"/>
    </px:tempfile>
    
    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
        <p:with-option name="attribute-value" select="/c:result">
            <p:pipe step="file" port="result"/>
        </p:with-option>
    </p:add-attribute>
    <p:delete match="@xml:base" name="in-memory"/>
    
    <px:fileset-add-entry name="result">
        <p:input port="source">
            <p:pipe step="main" port="directory"/>
        </p:input>
        <p:with-option name="href" select="/c:result">
            <p:pipe step="file" port="result"/>
        </p:with-option>
        <p:with-option name="media-type" select="$media-type"/>
    </px:fileset-add-entry>
    
    <px:fileset-filter>
        <p:with-option name="href" select="/c:result">
            <p:pipe step="file" port="result"/>
        </p:with-option>
    </px:fileset-filter>
    
    <px:fileset-store name="generated-css">
        <p:input port="in-memory.in">
            <p:pipe step="in-memory" port="result"/>
        </p:input>
    </px:fileset-store>
    
</p:declare-step>
