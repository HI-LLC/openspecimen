package com.krishagni.catissueplus.core.common.service.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.engine.spi.SessionImplementor;
import org.hibernate.event.service.spi.EventListenerRegistry;
import org.hibernate.event.spi.AbstractEvent;
import org.hibernate.event.spi.EventType;
import org.hibernate.event.spi.PostDeleteEvent;
import org.hibernate.event.spi.PostDeleteEventListener;
import org.hibernate.event.spi.PostInsertEvent;
import org.hibernate.event.spi.PostInsertEventListener;
import org.hibernate.event.spi.PostUpdateEvent;
import org.hibernate.event.spi.PostUpdateEventListener;
import org.hibernate.internal.SessionFactoryImpl;
import org.hibernate.persister.entity.EntityPersister;
import org.springframework.beans.factory.InitializingBean;

import com.krishagni.catissueplus.core.biospecimen.repository.DaoFactory;
import com.krishagni.catissueplus.core.common.PlusTransactional;
import com.krishagni.catissueplus.core.common.domain.SearchEntityKeyword;
import com.krishagni.catissueplus.core.common.errors.OpenSpecimenException;
import com.krishagni.catissueplus.core.common.events.ResponseEvent;
import com.krishagni.catissueplus.core.common.events.SearchResult;
import com.krishagni.catissueplus.core.common.repository.SearchEntityKeywordDao;
import com.krishagni.catissueplus.core.common.service.SearchEntityKeywordProvider;
import com.krishagni.catissueplus.core.common.service.SearchResultProcessor;
import com.krishagni.catissueplus.core.common.service.SearchService;

public class SearchServiceImpl implements SearchService, InitializingBean {
	private SessionFactory sessionFactory;

	private DaoFactory daoFactory;

	private Map<String, SearchEntityKeywordProvider> entityKeywordProviders = new HashMap<>();

	private Map<String, SearchResultProcessor> resultProcessors = new HashMap<>();

	private Map<Transaction, KeywordProcessor> processors = new HashMap<>();

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	public void setDaoFactory(DaoFactory daoFactory) {
		this.daoFactory = daoFactory;
	}

	public void setEntityKeywordProviders(List<SearchEntityKeywordProvider> providers) {
		providers.forEach(provider -> entityKeywordProviders.put(provider.getEntity(), provider));
	}

	public void setResultProcessors(List<SearchResultProcessor> processors) {
		processors.forEach(processor -> resultProcessors.put(processor.getEntity(), processor));
	}

	@Override
	@PlusTransactional
	public List<SearchResult> search(String searchTerm, int maxResults) {
		if (StringUtils.isBlank(searchTerm)) {
			return Collections.emptyList();
		}

		//
		// Search for the input keyword
		//
		List<SearchEntityKeyword> matches = daoFactory.getSearchEntityKeywordDao().getMatches(searchTerm, maxResults);
		List<SearchResult> result = SearchResult.from(matches);
		if (result.isEmpty()) {
			return Collections.emptyList();
		}

		//
		// Prepare matches by entity so that all entity matches can be processed in one go
		//
		Map<String, List<SearchResult>> entityMatchesMap = new HashMap<>();
		for (SearchResult match : result) {
			List<SearchResult> entityMatches = entityMatchesMap.computeIfAbsent(match.getEntity(), (k) -> new ArrayList<>());
			entityMatches.add(match);
		}

		//
		// Process all entity matches
		//
		entityMatchesMap.replaceAll((entity, entityMatches) -> {
			SearchResultProcessor processor = resultProcessors.get(entity);
			return processor != null ? processor.process(entityMatches) : entityMatches;
		});

		//
		// Remove the entity matches that are not present in the processed matches
		//
		Iterator<SearchResult> iter = result.iterator();
		while (iter.hasNext()) {
			SearchResult match = iter.next();
			if (!entityMatchesMap.get(match.getEntity()).contains(match)) {
				iter.remove();
			}
		}

		return result;
	}

	@Override
	public void registerKeywordProvider(SearchEntityKeywordProvider provider) {
		entityKeywordProviders.put(provider.getEntity(), provider);
	}

	@Override
	public void registerSearchResultProcessor(SearchResultProcessor processor) {
		resultProcessors.put(processor.getEntity(), processor);
	}

	@Override
	public void afterPropertiesSet() throws Exception {
		EventListenerRegistry reg = ((SessionFactoryImpl) sessionFactory).getServiceRegistry().getService(EventListenerRegistry.class);

		EntityEventListener listener = new EntityEventListener();
		reg.getEventListenerGroup(EventType.POST_INSERT).appendListener(listener);
		reg.getEventListenerGroup(EventType.POST_UPDATE).appendListener(listener);
		reg.getEventListenerGroup(EventType.POST_DELETE).appendListener(listener);
	}

	private void addKeywords(AbstractEvent event, List<SearchEntityKeyword> keywords) {
		if (keywords == null || keywords.isEmpty()) {
			return;
		}

		Transaction txn = event.getSession().getTransaction();
		KeywordProcessor processor = processors.get(txn);
		if (processor == null) {
			processor = new KeywordProcessor();
			processors.put(txn, processor);

			event.getSession().getActionQueue().registerProcess(
				(session) -> {
					final KeywordProcessor process = processors.get(txn);
					if (process != null) {
						process.process(session);
						session.flush();
					}
				}
			);

			event.getSession().getActionQueue().registerProcess(
				(session) -> {
					processors.remove(txn);
				}
			);
		}

		processor.addKeywords(keywords);
	}

	private class EntityEventListener implements PostInsertEventListener, PostUpdateEventListener, PostDeleteEventListener {
		@Override
		public void onPostInsert(PostInsertEvent event) {
			SearchEntityKeywordProvider provider = entityKeywordProviders.get(event.getEntity().getClass().getName());
			if (provider == null) {
				return;
			}

			addKeywords(event, provider.getKeywords(event));
		}

		@Override
		public void onPostUpdate(PostUpdateEvent event) {
			SearchEntityKeywordProvider provider = entityKeywordProviders.get(event.getEntity().getClass().getName());
			if (provider == null) {
				return;
			}

			addKeywords(event, provider.getKeywords(event));
		}

		@Override
		public void onPostDelete(PostDeleteEvent event) {
			SearchEntityKeywordProvider provider = entityKeywordProviders.get(event.getEntity().getClass().getName());
			if (provider == null) {
				return;
			}

			addKeywords(event, provider.getKeywords(event));
		}

		@Override
		public boolean requiresPostCommitHanding(EntityPersister persister) {
			return false;
		}
	}

	private class KeywordProcessor {
		private List<SearchEntityKeyword> keywords = new ArrayList<>();

		public void addKeywords(List<SearchEntityKeyword> keywords) {
			this.keywords.addAll(keywords);
		}

		public void process(SessionImplementor session) {
			SearchEntityKeywordDao keywordDao = daoFactory.getSearchEntityKeywordDao();

			for (SearchEntityKeyword keyword : keywords) {
				if (StringUtils.isNotBlank(keyword.getValue())) {
					keyword.setValue(keyword.getValue().toLowerCase());
				}

				SearchEntityKeyword existing = null;
				switch (keyword.getOp()) {
					case 0:
						saveKeyword(keyword);
						break;

					case 1:
						existing = getFromDb(keyword);
						if (existing == null) {
							saveKeyword(keyword);
						} else {
							existing.update(keyword);
							if (StringUtils.isBlank(keyword.getValue())) {
								keywordDao.delete(existing);
							}
						}
						break;

					case 2:
						existing = getFromDb(keyword);
						if (existing != null) {
							keywordDao.delete(existing);
						}
						break;
				}
			}
		}

		private SearchEntityKeyword getFromDb(SearchEntityKeyword keyword) {
			List<SearchEntityKeyword> keywords = daoFactory.getSearchEntityKeywordDao()
				.getKeywords(keyword.getEntity(), keyword.getEntityId(), keyword.getKey());

			return keywords.stream().filter(ex -> ex.getValue().equalsIgnoreCase(keyword.getOldValue())).findFirst().orElse(null);
		}

		private void saveKeyword(SearchEntityKeyword keyword) {
			if (StringUtils.isBlank(keyword.getValue())) {
				return;
			}

			daoFactory.getSearchEntityKeywordDao().saveOrUpdate(keyword);
		}
	}
}
