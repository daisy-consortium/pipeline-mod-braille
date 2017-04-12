import org.daisy.pipeline.junit.AbstractXSpecAndXProcSpecTest;

public class PefCalabashTest extends AbstractXSpecAndXProcSpecTest {
	
	@Override
	protected String[] testDependencies() {
		return new String[] {
			brailleModule("common-utils"),
			brailleModule("css-core"),
			brailleModule("pef-core"),
			"org.daisy.braille:braille-utils.impl:?",
			"org.daisy.braille:braille-utils.pef-tools:?"
		};
	}
}
