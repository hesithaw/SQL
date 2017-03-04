SET SERVEROUTPUT ON
DECLARE

i_instance_index		ATSD_INS_EQUITY.INSTANCE_INDEX%TYPE;
s_object_id			ATSD_INS_EQUITY.INSTRUMENT_ID%TYPE;
i_count				INTEGER;

CURSOR cursor_position_account IS
select INSTRUMENT_ID from ATSD_INS_EQUITY ;
CURSOR cursor_position_account2 IS
select INSTRUMENT_ID from ATSD_INS_BILL ;
CURSOR cursor_position_account3 IS
select INSTRUMENT_ID from ATSD_INS_BOND;

BEGIN
	i_count := 0;
	open cursor_position_account;
	loop
		fetch cursor_position_account into s_object_id;
		exit when cursor_position_account%notfound;
		
		update ATSD_INS_EQUITY set INSTANCE_INDEX=i_count where INSTRUMENT_ID=s_object_id;
		i_count := i_count + 1;
	end loop;
	close cursor_position_account;
	
	open cursor_position_account2;
	loop
		fetch cursor_position_account2 into s_object_id;
		exit when cursor_position_account2%notfound;
		
		update ATSD_INS_BILL set INSTANCE_INDEX=i_count where INSTRUMENT_ID=s_object_id;
		i_count := i_count + 1;
	end loop;
	close cursor_position_account2;
	
	open cursor_position_account3;
	loop
		fetch cursor_position_account3 into s_object_id;
		exit when cursor_position_account3%notfound;
		
		update ATSD_INS_BOND set INSTANCE_INDEX=i_count where INSTRUMENT_ID=s_object_id;
		i_count := i_count + 1;
	end loop;
	close cursor_position_account3;
END;