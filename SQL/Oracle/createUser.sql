insert into catissue_department values(CATISSUE_DEPARTMENT_SEQ.nextval,'department');
insert into catissue_institution  values(CATISSUE_INSTITUTION_SEQ.nextval,'institution');
insert into catissue_cancer_research_group  values(CATISSUE_CANCER_RES_GRP_SEQ.nextval,'crg');
insert into catissue_address (identifier,state,country,zipcode) values(CATISSUE_ADDRESS_SEQ.nextVal,null,null,null);

UPDATE CSM_USER SET LOGIN_NAME='admin@admin.com',
					DEPARTMENT=1,
					EMAIL_ID='admin@admin.com',
					PASSWORD='HvsnnH0FByw='
				WHERE USER_ID=1;	

UPDATE catissue_user SET EMAIL_ADDRESS='admin@admin.com',
							LOGIN_NAME='admin@admin.com',
							DEPARTMENT_ID=1,
							INSTITUTION_ID=1,
							CANCER_RESEARCH_GROUP_ID=1,
							ADDRESS_ID=1
						WHERE 
							IDENTIFIER = 1;

							
UPDATE catissue_password set PASSWORD='HvsnnH0FByw=',
							UPDATE_DATE=sysdate
						WHERE 
							IDENTIFIER = 1;