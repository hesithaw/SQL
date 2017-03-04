SET SERVEROUTPUT ON
DECLARE
		
s_def_id				ATS_TAB_DEFS.DEFINITION_ID%TYPE;
s_tab_entry_def_id		ATS_TAB_DEFS.TABULAR_ENTRY_DEFINITION_ID%TYPE;

CURSOR cursor_tabstructure_fetch IS
SELECT DEFINITION_ID, TABULAR_ENTRY_DEFINITION_ID OVER from ATS_TAB_DEFS ORDER BY DEFINITION_ID ASC;

BEGIN
	open cursor_tabstructure_fetch;
	loop
		fetch cursor_tabstructure_fetch into s_def_id, s_tab_entry_def_id;
		exit when cursor_tabstructure_fetch%notfound;
		
		dbms_output.put_line(concat('CASE	"',concat(s_def_id,concat('"	{ RETURN	"',concat(s_tab_entry_def_id,'"	;}')))));
	end loop;
	close cursor_tabstructure_fetch;
END;
