package com.krishagni.catissueplus.core.init;

import org.springframework.beans.factory.InitializingBean;

import com.krishagni.catissueplus.core.administrative.domain.StorageContainer;
import com.krishagni.catissueplus.core.biospecimen.domain.CollectionProtocolRegistration;
import com.krishagni.catissueplus.core.biospecimen.domain.Participant;
import com.krishagni.catissueplus.core.biospecimen.domain.Specimen;
import com.krishagni.catissueplus.core.biospecimen.domain.Visit;
import com.krishagni.catissueplus.core.biospecimen.services.impl.MrnSearchKeywordProvider;
import com.krishagni.catissueplus.core.common.service.SearchService;
import com.krishagni.catissueplus.core.common.service.impl.DefaultSearchEntityKeywordProvider;

public class PostInitializer implements InitializingBean {
	private SearchService searchSvc;

	public void setSearchSvc(SearchService searchSvc) {
		this.searchSvc = searchSvc;
	}

	@Override
	public void afterPropertiesSet() throws Exception {
		searchSvc.registerKeywordProvider(
			new DefaultSearchEntityKeywordProvider()
				.entityClass(CollectionProtocolRegistration.class)
				.entityName(CollectionProtocolRegistration.getEntityName())
				.keywordProps("ppid")
		);

		addKeywordProvider(CollectionProtocolRegistration.class, CollectionProtocolRegistration.getEntityName(), "ppid");
		addKeywordProvider(Participant.class, Participant.getEntityName(), "empi,uid");
		searchSvc.registerKeywordProvider(new MrnSearchKeywordProvider());
		addKeywordProvider(Visit.class, Visit.getEntityName(), "name,surgicalPathologyNumber");
		addKeywordProvider(Specimen.class, Specimen.getEntityName(), "label,barcode");
		addKeywordProvider(StorageContainer.class, StorageContainer.getEntityName(), "name,barcode");
	}

	private void addKeywordProvider(Class<?> entityClass, String entityName, String keywordProps) {
		searchSvc.registerKeywordProvider(new DefaultSearchEntityKeywordProvider(entityClass, entityName, keywordProps));
	}
}
