INSERT INTO dyextn_abstract_metadata values(1849,NULL,NULL,NULL,'edu.wustl.catissuecore.domain.Race',null);
INSERT INTO dyextn_abstract_entity values(1849);
INSERT INTO dyextn_entity values(1849,3,0,NULL,3,NULL,NULL,1);
INSERT INTO dyextn_database_properties values(1844,'CATISSUE_RACE');
INSERT INTO dyextn_table_properties (IDENTIFIER,ABSTRACT_ENTITY_ID) values(1844,1849);
INSERT INTO dyextn_abstract_metadata values(1850,NULL,NULL,NULL,'id',null);
INSERT INTO DYEXTN_BASE_ABSTRACT_ATTRIBUTE values(1850);
INSERT INTO dyextn_attribute values (1850,1849);
insert into dyextn_primitive_attribute (IDENTIFIER,IS_COLLECTION,IS_IDENTIFIED,IS_PRIMARY_KEY,IS_NULLABLE) values (1850,0,NULL,1,1);
insert into dyextn_attribute_type_info (IDENTIFIER,PRIMITIVE_ATTRIBUTE_ID) values (1136,1850);
insert into dyextn_numeric_type_info (IDENTIFIER,MEASUREMENT_UNITS,DECIMAL_PLACES,NO_DIGITS) values (1136,NULL,0,NULL);
insert into dyextn_long_type_info (IDENTIFIER) values (1136);
insert into dyextn_database_properties (IDENTIFIER,NAME) values (1845,'IDENTIFIER');
insert into dyextn_column_properties (IDENTIFIER,PRIMITIVE_ATTRIBUTE_ID) values (1845,1850);
INSERT INTO dyextn_abstract_metadata values(1851,NULL,NULL,NULL,'raceName',null);
INSERT INTO DYEXTN_BASE_ABSTRACT_ATTRIBUTE values(1851);
INSERT INTO dyextn_attribute values (1851,1849);
insert into dyextn_primitive_attribute (IDENTIFIER,IS_COLLECTION,IS_IDENTIFIED,IS_PRIMARY_KEY,IS_NULLABLE) values (1851,0,NULL,0,1);
insert into dyextn_attribute_type_info (IDENTIFIER,PRIMITIVE_ATTRIBUTE_ID) values (1137,1851);
insert into dyextn_string_type_info (IDENTIFIER) values (1137);
insert into dyextn_database_properties (IDENTIFIER,NAME) values (1846,'RACE_NAME');
insert into dyextn_column_properties (IDENTIFIER,PRIMITIVE_ATTRIBUTE_ID) values (1846,1851);
insert into dyextn_abstract_metadata values (1852,null,null,null,'participant_race',null);
INSERT INTO DYEXTN_BASE_ABSTRACT_ATTRIBUTE values(1852);
insert into dyextn_attribute values (1852,844);
insert into dyextn_role values (1341,'CONTAINTMENT',2,0,'raceCollection');
insert into dyextn_role values (1342,'ASSOCIATION',1,0,'participant');
insert into dyextn_association values (1852,'BI_DIRECTIONAL',1849,1342,1341,1);
insert into dyextn_database_properties values (1847,'participant_race');
insert into dyextn_constraint_properties (IDENTIFIER,SOURCE_ENTITY_KEY,TARGET_ENTITY_KEY,ASSOCIATION_ID) values(1847,null,'PARTICIPANT_ID',1852);
insert into association values(811,2);
insert into intra_model_association values(811,1852);
insert into path values (985585,844,811,1849);
insert into dyextn_abstract_metadata values (1853,null,null,null,'race_participant',null);
INSERT INTO DYEXTN_BASE_ABSTRACT_ATTRIBUTE values(1853);
insert into dyextn_attribute values (1853,1849);
insert into dyextn_association values (1853,'BI_DIRECTIONAL',844,1341,1342,1);
insert into dyextn_database_properties values (1848,'race_participant');
insert into dyextn_constraint_properties (IDENTIFIER,SOURCE_ENTITY_KEY,TARGET_ENTITY_KEY,ASSOCIATION_ID) values(1848,'PARTICIPANT_ID',null,1853);
insert into association values(812,2);
insert into intra_model_association values(812,1853);
insert into path values (985586,1849,812,844);