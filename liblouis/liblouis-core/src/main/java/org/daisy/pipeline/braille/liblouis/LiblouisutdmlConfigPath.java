package org.daisy.pipeline.braille.liblouis;

import java.util.Map;

import org.daisy.pipeline.braille.BundledResourcePath;
import org.osgi.service.component.ComponentContext;

public class LiblouisutdmlConfigPath extends BundledResourcePath {
	
	@Override
	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		unpack(context);
	}
}