package org.daisy.pipeline.braille;

import com.google.common.base.Function;
import com.google.common.collect.Iterators;

import java.io.File;
import java.net.URL;
import java.util.Map;

import org.daisy.pipeline.braille.Utilities.Files;
import org.osgi.service.component.ComponentContext;

public abstract class UnpackedTablePath extends BundledTablePath {

	private File directory = null;

	public void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		super.activate(context, properties);
		directory = context.getBundleContext().getDataFile("tables");
		if (!directory.exists()) {
			directory.mkdir();
			Files.unpack(
				Iterators.<String,URL>transform(
					tableNames.iterator(),
					new Function<String,URL>() {
						public URL apply(String tableName) { return Files.composeURL(path, tableName); }}),
				directory); }
		path = directory.toURI().toURL();
	}
}