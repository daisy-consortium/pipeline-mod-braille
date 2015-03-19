package org.daisy.pipeline.braille.liblouis;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URI;
import java.util.Properties;

import javax.inject.Inject;

import static org.daisy.pipeline.braille.Utilities.Files.asFile;
import static org.daisy.pipeline.braille.Utilities.Locales.parseLocale;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.options.MavenArtifactProvisionOption;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.bundle;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LiblouisCoreTest {
	
	@Inject
	Liblouis liblouis;
	
	@Inject
	LiblouisTableResolver resolver;
	
	@Inject
	LiblouisTableLookup lookup;
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/src/test/resources/logback.xml"),
			mavenBundle().groupId("org.slf4j").artifactId("slf4j-api").version("1.7.2"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-core").version("1.0.11"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-classic").version("1.0.11"),
			mavenBundle().groupId("org.apache.felix").artifactId("org.apache.felix.scr").version("1.6.2"),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("common-java").versionAsInProject(),
			forThisPlatform(mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-native").versionAsInProject()),
			thisBundle("org.daisy.pipeline.modules.braille", "liblouis-core"),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
	
	@Test
	public void testResolveTable() {
		assertEquals("foobar.cti", asFile(resolver.resolve(asURI("foobar.cti"))).getName());
	}
	
	@Test
	public void testResolveTableList() {
		assertEquals("foobar.cti", (resolver.resolveTableList(new URI[]{asURI("foobar.cti")}, null)[0]).getName());
	}
	
	@Test
	public void testLookupTable() {
		assertEquals(new URI[]{asURI("http://test/table_path_1/foobar.cti")}, lookup.lookup(parseLocale("foo")));
	}
	
	@Test
	public void testTranslate() {
		assertEquals("foobar", liblouis.translate("foobar.cti", "foobar", false, null));
	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", liblouis.hyphenate("foobar.cti,foobar.dic", "foobar"));
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar", liblouis.hyphenate("foobar.cti,foobar.dic", "foo-bar"));
	}
	
	public static Option thisBundle(String groupId, String artifactId) {
		Properties dependencies = new Properties();
		try {
			dependencies.load(new FileInputStream(new File(PathUtils.getBaseDir() + "/target/classes/META-INF/maven/dependencies.properties"))); }
		catch (IOException e) {
			throw new RuntimeException(e); }
		String projectGroupId = dependencies.getProperty("groupId");
		String projectArtifactId = dependencies.getProperty("artifactId");
		if (groupId.equals(projectGroupId) && artifactId.equals(projectArtifactId))
			return bundle("reference:file:" + PathUtils.getBaseDir() + "/target/classes/");
		else
			return mavenBundle().groupId(groupId).artifactId(artifactId).versionAsInProject();
	}
	
	public static MavenArtifactProvisionOption forThisPlatform(MavenArtifactProvisionOption bundle) {
		String name = System.getProperty("os.name").toLowerCase();
		if (name.startsWith("windows"))
			return bundle.classifier("windows");
		else if (name.startsWith("mac os x"))
			return bundle.classifier("mac");
		else if (name.startsWith("linux"))
			return bundle.classifier("linux");
		else
			throw new RuntimeException("Unsupported OS: " + name);
	}
}
