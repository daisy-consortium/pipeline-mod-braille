package org.daisy.pipeline.braille.dotify;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Optional;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DotifyTranslator extends AbstractTransform implements TextTransform {
	
	private BrailleTranslator translator;
	
	protected DotifyTranslator(BrailleTranslator translator) {
		this.translator = translator;
	}
	
	public String transform(String text) {
		return translator.translate(text).getTranslatedRemainder();
	}
	
	public String[] transform(String[] text) {
		throw new UnsupportedOperationException();
	}
	
	public BrailleTranslator asBrailleTranslator() {
		return translator;
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.DotifyTranslator.Provider",
		service = {
			DotifyTranslator.Provider.class,
			TextTransform.Provider.class
		}
	)
	public static class Provider implements TextTransform.Provider<DotifyTranslator> {
		
		public Transform.Provider<DotifyTranslator> withContext(Logger context) {
			return this;
		}
		
		/**
		 * Try to find a translator based on the given locale.
		 * An automatic fallback mechanism is used: if nothing is found for
		 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 */
		public Iterable<DotifyTranslator> get(Locale query) {
			return translators.get(query);
		}
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `dotify'.
		 * - locale: Required. Matches only Dotify translators for that locale. An
		 *     automatic fallback mechanism is used: if nothing is found for
		 *     language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 *
		 * No other features are allowed.
		 */
		public Iterable<DotifyTranslator> get(String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("translator")) != null)
				if (!o.get().equals("dotify"))
					return empty;
			if ((o = q.remove("locale")) != null)
				if (q.isEmpty())
					return get(parseLocale(o.get()));
			return empty;
		}
		
		private final static Iterable<DotifyTranslator> empty = Optional.<DotifyTranslator>absent().asSet();
		
		private final List<BrailleTranslatorFactoryService> factoryServices = new ArrayList<BrailleTranslatorFactoryService>();
		
		@Reference(
			name = "BrailleTranslatorFactoryService",
			unbind = "unbindBrailleTranslatorFactoryService",
			service = BrailleTranslatorFactoryService.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
			factoryServices.add(service);
			translators.invalidateCache();
		}
		
		protected void unbindBrailleTranslatorFactoryService(BrailleTranslatorFactoryService service) {
			factoryServices.remove(service);
			translators.invalidateCache();
		}
		
		private BrailleTranslator newTranslator(String locale, String grade) throws TranslatorConfigurationException {
			for (BrailleTranslatorFactoryService s : factoryServices)
				if (s.supportsSpecification(locale, grade))
					return s.newFactory().newTranslator(locale, grade);
			throw new RuntimeException("Cannot locate a factory for "
			                           + locale.toLowerCase() + "(" + grade.toUpperCase() + ")");
		}
		
		private final org.daisy.pipeline.braille.common.Provider.MemoizingProvider<Locale,DotifyTranslator> translators
		= memoize(
			new LocaleBasedProvider<Locale,DotifyTranslator>() {
				public Iterable<DotifyTranslator> _get(Locale locale) {
					try {
						BrailleTranslator translator = newTranslator(
							locale.toLanguageTag(), BrailleTranslatorFactory.MODE_UNCONTRACTED);
						translator.setHyphenating(false);
						return Optional.of(new DotifyTranslator(translator)).asSet(); }
					catch (Exception e) {
						logger.warn("Could not create translator for locale " + locale, e); }
					return Optional.<DotifyTranslator>absent().asSet(); }});
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
