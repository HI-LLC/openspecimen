package com.krishagni.catissueplus.core.biospecimen.services.impl;

import java.util.Arrays;
import java.util.List;

import com.krishagni.catissueplus.core.biospecimen.domain.Participant;
import com.krishagni.catissueplus.core.biospecimen.domain.ParticipantMedicalIdentifier;
import com.krishagni.catissueplus.core.common.service.impl.AbstractSearchEntityKeywordProvider;
import com.krishagni.catissueplus.core.common.util.Status;

public class MrnSearchKeywordProvider extends AbstractSearchEntityKeywordProvider {
	private static final List<String> PROPS = Arrays.asList("medicalRecordNumber");

	@Override
	public Long getEntityId(Object entity) {
		ParticipantMedicalIdentifier pmi = (ParticipantMedicalIdentifier) entity;
		return pmi.getParticipant().getId();
	}

	@Override
	public List<String> getKeywordProps() {
		return PROPS;
	}

	@Override
	public String getEntityName() {
		return Participant.getEntityName();
	}

	@Override
	public String getEntity() {
		return ParticipantMedicalIdentifier.class.getName();
	}

	@Override
	public boolean isEntityDeleted(Object entity) {
		ParticipantMedicalIdentifier pmi = (ParticipantMedicalIdentifier) entity;
		return Status.ACTIVITY_STATUS_DISABLED.equals(pmi.getParticipant().getActivityStatus());
	}
}
