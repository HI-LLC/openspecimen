package com.krishagni.catissueplus.core.common.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import com.krishagni.catissueplus.core.common.domain.SearchEntityKeyword;
import com.krishagni.catissueplus.core.common.repository.SearchEntityKeywordDao;
import com.krishagni.catissueplus.core.common.service.SearchEntityKeywordProvider;
import com.krishagni.catissueplus.core.common.service.SearchService;

public class SearchServiceImpl implements SearchService, InitializingBean {
	private Map<String, SearchEntityKeywordProvider> entityKeywordProviders = new HashMap<>();

	private SessionFactory sessionFactory;

	private DaoFactory daoFactory;

	private Map<Transaction, KeywordProcessor> processors = new HashMap<>();

	public void setEntityKeywordProviders(List<SearchEntityKeywordProvider> providers) {
		providers.forEach(provider -> entityKeywordProviders.put(provider.getEntity(), provider));
	}

	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	public void setDaoFactory(DaoFactory daoFactory) {
		this.daoFactory = daoFactory;
	}

	@Override
	public void registerKeywordProvider(SearchEntityKeywordProvider provider) {
		entityKeywordProviders.put(provider.getEntity(), provider);
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
