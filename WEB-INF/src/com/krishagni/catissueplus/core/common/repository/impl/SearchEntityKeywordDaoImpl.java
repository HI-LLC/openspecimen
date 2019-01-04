package com.krishagni.catissueplus.core.common.repository.impl;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.criterion.MatchMode;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

import com.krishagni.catissueplus.core.common.OrderBySubstringMatch;
import com.krishagni.catissueplus.core.common.domain.SearchEntityKeyword;
import com.krishagni.catissueplus.core.common.repository.AbstractDao;
import com.krishagni.catissueplus.core.common.repository.SearchEntityKeywordDao;

public class SearchEntityKeywordDaoImpl extends AbstractDao<SearchEntityKeyword> implements SearchEntityKeywordDao {

	@Override
	public Class<SearchEntityKeyword> getType() {
		return SearchEntityKeyword.class;
	}

	@Override
	public List<SearchEntityKeyword> getKeywords(String entity, Long entityId, String key) {
		return getCurrentSession().getNamedQuery(GET_KEYWORDS)
			.setParameter("entity", entity)
			.setParameter("entityId", entityId)
			.setParameter("key", key)
			.list();
	}

	@Override
	public List<SearchEntityKeyword> getKeywords(String searchTerm, int maxResults) {
		return getCurrentSession().createCriteria(SearchEntityKeyword.class, "keyword")
			.add(Restrictions.like("value", searchTerm, MatchMode.START))
			.setMaxResults(maxResults <= 0 ? 100 : maxResults)
			.addOrder(OrderBySubstringMatch.asc("value", searchTerm))
			.list();
	}

	private static final String FQN = SearchEntityKeyword.class.getName();

	private static final String GET_KEYWORDS = FQN + ".getKeywords";
}
