SET SERVEROUTPUT ON
DECLARE

s_session_id			ATS_SESSION_EVENT_DEFS.SESSION_ID%TYPE;
i_event_id				ATS_SESSION_EVENT_DEFS.EVENT_ID%TYPE;
s_display_name 			ATS_EVENT_DEFS.DISPLAY_NAME%TYPE;
s_new_procedure_name	ATS_PROCEDURE_FILES.PROCEDURE_NAME%TYPE;
s_cycle_id				ATS_SESSION_EVENT_DEFS.CYCLE_ID%TYPE;
s_data 					ATS_PROCEDURE_FILES.DATA%TYPE;
s_raw_new_event_data	ATS_SESSION_EVENT_DEFS.DATA%TYPE;
--i_ProcId				ATS_PROCEDURE_FILES.PROCEDURE_ID%TYPE;

i_ProcId INTEGER;
i_Next_ProcId INTEGER;
s_new_event_data VARCHAR2(150);

CURSOR session_event IS
SELECT SESSION_ID, EVENT_ID, DATA, CYCLE_ID from ATS_SESSION_EVENT_DEFS where EVENT_TYPE = 5;

BEGIN
	open session_event;
	loop
		fetch session_event into s_session_id, i_event_id, s_data, s_cycle_id;
		exit when session_event%notfound;
		--dbms_output.put_line(i_event_id);
		BEGIN
			select DISPLAY_NAME into s_display_name from ATS_EVENT_DEFS where EVENT_TYPE = 5 and EVENT_ID=i_event_id;
		END;
		s_new_procedure_name := concat(s_session_id, concat('__', s_display_name));
		i_ProcId := -1;
		
		BEGIN
			select files.PROCEDURE_ID into i_ProcId from ATS_PROCEDURE_FILES files, ATS_CYCLE_PROCEDURES cycles where cycles.PROC_ID = files.PROCEDURE_ID and
			files.PROCEDURE_ID > 0 and files.PROCEDURE_NAME = s_new_procedure_name ;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;	
		END;
		--dbms_output.put_line(concat('Exist Proc Id :', i_ProcId));
		IF(i_ProcId > 0)
		THEN
			dbms_output.put_line(concat(s_new_procedure_name, ' Procedure already exist..'));
			CONTINUE;
		END IF;
		
		BEGIN
			SELECT MAX(PROC_ID) into i_Next_ProcId from ATS_CYCLE_PROCEDURES;
		END;
		i_Next_ProcId := i_Next_ProcId + 1;
		INSERT INTO ATS_PROCEDURE_FILES VALUES(s_new_procedure_name, 5, s_data, '', '', 'Hesitha', '', -1, 1, 1, i_Next_ProcId);
		INSERT INTO ATS_CYCLE_PROCEDURES VALUES(s_cycle_id, i_Next_ProcId);
		
		s_new_event_data := concat('CALL', concat(' ', concat(s_new_procedure_name, ';')));
		--dbms_output.put_line(s_new_event_data);
		s_raw_new_event_data := utl_raw.cast_to_raw(s_new_event_data);
		
		UPDATE ATS_SESSION_EVENT_DEFS SET DATA = s_raw_new_event_data where SESSION_ID = s_session_id and EVENT_ID = i_event_id and EVENT_TYPE = 5;
		--dbms_output.put_line(s_new_procedure_name);
		--dbms_output.put_line(concat(s_cycle_id, i_Next_ProcId));
	end loop;
	close session_event;
	COMMIT;
END;