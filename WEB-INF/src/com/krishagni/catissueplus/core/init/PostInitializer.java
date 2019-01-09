package com.krishagni.catissueplus.core.init;

import org.springframework.beans.factory.InitializingBean;

import com.krishagni.catissueplus.core.administrative.domain.DistributionOrder;
import com.krishagni.catissueplus.core.administrative.domain.DistributionProtocol;
import com.krishagni.catissueplus.core.administrative.domain.Shipment;
import com.krishagni.catissueplus.core.administrative.domain.Site;
import com.krishagni.catissueplus.core.administrative.domain.StorageContainer;
import com.krishagni.catissueplus.core.administrative.domain.User;
import com.krishagni.catissueplus.core.biospecimen.domain.CollectionProtocol;
import com.krishagni.catissueplus.core.biospecimen.domain.CollectionProtocolRegistration;
import com.krishagni.catissueplus.core.biospecimen.domain.Participant;
import com.krishagni.catissueplus.core.biospecimen.domain.Specimen;
import com.krishagni.catissueplus.core.biospecimen.domain.Visit;
import com.krishagni.catissueplus.core.biospecimen.services.impl.EmpiUidSearchKeywordProvider;
import com.krishagni.catissueplus.core.biospecimen.services.impl.MrnSearchKeywordProvider;
import com.krishagni.catissueplus.core.common.service.SearchEntityKeywordProvider;
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

		addKeywordProvider(CollectionProtocol.class, CollectionProtocol.getEntityName(), "title,shortTitle,code");
		addKeywordProvider(CollectionProtocolRegistration.class, CollectionProtocolRegistration.getEntityName(), "ppid");
		addKeywordProvider(new EmpiUidSearchKeywordProvider());
		addKeywordProvider(new MrnSearchKeywordProvider());
		addKeywordProvider(Visit.class, Visit.getEntityName(), "name,surgicalPathologyNumber");
		addKeywordProvider(Specimen.class, Specimen.getEntityName(), "label,barcode");
		addKeywordProvider(StorageContainer.class, StorageContainer.getEntityName(), "name,barcode");
		addKeywordProvider(Site.class, Site.getEntityName(), "name,code");
		addKeywordProvider(User.class, User.getEntityName(), "firstName,lastName,loginName,emailAddress");
		addKeywordProvider(DistributionProtocol.class, DistributionProtocol.getEntityName(), "title,shortTitle,irbId");
		addKeywordProvider(DistributionOrder.class, DistributionOrder.getEntityName(), "name");
		addKeywordProvider(Shipment.class, Shipment.getEntityName(), "name");
	}

	private void addKeywordProvider(Class<?> entityClass, String entityName, String keywordProps) {
		searchSvc.registerKeywordProvider(new DefaultSearchEntityKeywordProvider(entityClass, entityName, keywordProps));
	}

	private void addKeywordProvider(SearchEntityKeywordProvider provider) {
		searchSvc.registerKeywordProvider(provider);
	}
}
