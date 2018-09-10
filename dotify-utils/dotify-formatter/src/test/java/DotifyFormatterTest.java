import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

import static org.daisy.pipeline.pax.exam.Options.thisPlatform;

import org.ops4j.pax.exam.ProbeBuilder;
import org.ops4j.pax.exam.TestProbeBuilder;

public class DotifyFormatterTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			brailleModule("css-core"),
			brailleModule("css-utils"),
			brailleModule("pef-utils"),
			brailleModule("obfl-utils"),
			brailleModule("common-utils"),
			brailleModule("dotify-utils"),
			brailleModule("liblouis-core"),
			"org.daisy.pipeline.modules.braille:liblouis-native:jar:" + thisPlatform() + ":?",
			// because of bug in lou_indexTables we need to include liblouis-tables even though we're not using it
			brailleModule("liblouis-tables"),
			"com.google.guava:guava:?",
			"org.daisy.dotify:dotify.api:?",
			"org.daisy.dotify:dotify.common:?",
			"org.daisy.dotify:dotify.translator.impl:?",
			"org.daisy.pipeline:calabash-adapter:?",
			// logging
			"org.slf4j:jul-to-slf4j:?",
			"org.daisy.pipeline:logging-activator:?",
			// FIXME: Dotify needs older version of jing
			"org.daisy.libs:jing:20120724.0.0",
		};
	}
	
	@ProbeBuilder
	public TestProbeBuilder probeConfiguration(TestProbeBuilder probe) {
		probe.setHeader("Service-Component", "OSGI-INF/number-braille-translator-provider.xml");
		return probe;
	}
}
