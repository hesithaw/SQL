SET SERVEROUTPUT ON
DECLARE
				
i_entity_id		ATS_ENTITY_NAMES.ENTITY_ID%TYPE;
s_prefix		ATS_ENTITY_NAMES.PREFIX%TYPE;
s_display_name 	ATS_CONSTANTS.DISPLAY_NAME%TYPE;
s_definition_id	ATS_INS_DEFS.DEFINITION_ID%TYPE;

s_sql_statement 	VARCHAR2(150);
s_sql_statement_2 	VARCHAR2(250);
s_def_table_name	VARCHAR2(150);
s_final_string		VARCHAR2(150);
i_table_count		INTEGER;
i_count_all			INTEGER;

CURSOR cursor_entity_names IS 
SELECT t1.ENTITY_ID, t1.PREFIX, t2.DISPLAY_NAME FROM ATS_ENTITY_NAMES t1 INNER JOIN(select DISPLAY_NAME, CONSTANT_VALUE from ATS_CONSTANTS 
where ENUMERATION_NAME = 'ENTITY_ID')t2 ON t1.ENTITY_ID=t2.CONSTANT_VALUE WHERE t1.IS_INSTANCE_CREATED = 1;

BEGIN
	open cursor_entity_names;
	loop
		fetch cursor_entity_names into i_entity_id, s_prefix, s_display_name;
		exit when cursor_entity_names%notfound;
		
		i_table_count := -1;
		i_count_all := -1;
		s_def_table_name := concat('ATS_', concat(s_prefix, '_DEFS'));
		--dbms_output.put_line(concat(s_display_name, concat('			',s_def_table_name)));
		select count(*) into i_table_count from all_objects where object_type in ('TABLE') and object_name = s_def_table_name;
		IF(i_table_count < 0)
		THEN
			dbms_output.put_line(concat(s_def_table_name, ' does not exist..'));
			CONTINUE;
		END IF;	
 
		s_sql_statement := concat('select count(*) from ', s_def_table_name);	 
		execute immediate s_sql_statement into i_count_all;
		--dbms_output.put_line(concat(s_sql_statement, i_count_all));
		 for i_count in 1..i_count_all 
		 loop
			s_sql_statement_2 := concat('SELECT temptablename.DEFINITION_ID FROM (SELECT DEFINITION_ID, ROW_NUMBER() OVER (ORDER BY DEFINITION_ID ASC) AS rownumber FROM ', concat(s_def_table_name, concat(') temptablename WHERE temptablename.rownumber=',i_count)));
			execute immediate s_sql_statement_2 into s_definition_id;
			
			s_final_string := concat('Add2DeleteSequence(',concat(s_display_name, concat(',"',concat(s_definition_id, '",NO);'))));
			dbms_output.put_line(s_final_string);
		 end loop;
		
		dbms_output.put_line('#-------------------------------------------');
		
	end loop;
	close cursor_entity_names;
END;
