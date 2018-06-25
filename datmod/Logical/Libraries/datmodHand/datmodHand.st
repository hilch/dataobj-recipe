 (* data module handling *)
FUNCTION datmodHand
	datmodHand := 0;
	inst.status.busy := 0;	
	CASE inst.internal.step OF
		0: (* wait for command *)
		IF inst.cmd.load = 1 THEN  (* load module *)
			datmodHand := 65535;
			IF inst.para.pData <> 0 AND inst.para.dataLen <> 0  THEN
				inst.status.busy := 1;
				inst.internal.fubObjInfo( enable := 0 );
				inst.status.error.AlreadyExist := 0;
				inst.status.error.NotFound := 0;
				inst.status.error.WrongParameter := 0;
				inst.status.ok := 0;
				inst.internal.step := 10;
			ELSE
				inst.status.error.WrongParameter := 1;
			END_IF
		ELSIF inst.cmd.delete = 1 THEN (* delete module *)
			datmodHand := 65535;		
			inst.status.busy := 1;
			inst.internal.fubObjInfo( enable := 0 );				
			inst.internal.fubObjDelete( enable := 0 );
			inst.status.error.AlreadyExist := 0;
			inst.status.error.NotFound := 0;
			inst.status.error.WrongParameter := 0;
			inst.status.ok := 0;

			inst.internal.step := 20;
		ELSIF inst.cmd.save = 1 THEN (* save data to module *)
			datmodHand := 65535;
			IF inst.para.pData <> 0 AND inst.para.dataLen <> 0 THEN
				inst.status.busy := 1;
				inst.internal.fubObjCreate( enable := 0 );
				inst.internal.fubObjInfo( enable := 0 );				
				inst.internal.fubObjDelete( enable := 0 );				
				inst.status.error.AlreadyExist := 0;
				inst.status.error.NotFound := 0;
				inst.status.error.WrongParameter := 0;
				inst.status.ok := 0;
				inst.internal.step := 30;
			ELSE
				inst.status.error.WrongParameter := 1;
			END_IF
		END_IF
		
			
		
		10: (* load *)
		inst.internal.fubObjInfo( enable := 1, pName := ADR(inst.para.name) );
		IF inst.internal.fubObjInfo.status = 0 THEN
			inst.internal.fubObjRead( enable := 1, ident := inst.internal.fubObjInfo.ident, Offset := 0, pDestination := inst.para.pData, len := inst.para.dataLen );
			inst.cmd.load := 0;
			inst.status.ok := 1;
			inst.internal.step := 0;
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLPARAMETER THEN			
			inst.cmd.load := 0;
			inst.status.error.WrongParameter := 1;
			inst.internal.step := 0;						
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLOBJTYPE OR inst.internal.fubObjInfo.status = doERR_MODULNOTFOUND THEN
			inst.cmd.load := 0;
			inst.status.error.NotFound := 1;
			inst.internal.step := 0;
		
		END_IF
			
		
		
		20: (* delete *)
		inst.internal.fubObjInfo( enable := 1, pName := ADR(inst.para.name) );
		IF inst.internal.fubObjInfo.status = 0 THEN
			inst.internal.fubObjDelete( enable := 1, ident := inst.internal.fubObjInfo.ident );		
			inst.internal.step := 21;
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLPARAMETER THEN			
			inst.cmd.delete := 0;
			inst.status.error.WrongParameter := 1;
			inst.internal.step := 0;							
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLOBJTYPE OR inst.internal.fubObjInfo.status = doERR_MODULNOTFOUND THEN
			inst.cmd.delete := 0;
			inst.status.error.NotFound := 1;
			inst.internal.step := 0;			
		END_IF		
		
		
		21: 
		IF inst.internal.fubObjDelete.status = 0 THEN
			inst.cmd.delete := 0;
			inst.status.ok := 1;
			inst.internal.step := 0;
		ELSIF inst.internal.fubObjDelete.status <> 65535 THEN
			inst.cmd.delete := 0;
			inst.status.error.NotFound := 1;
			inst.internal.step := 0;
		ELSE
			inst.internal.fubObjDelete();
		END_IF
		
		
		
		30: (* save *)
		inst.internal.fubObjInfo( enable := 1, pName := ADR(inst.para.name) );
		IF inst.internal.fubObjInfo.status = 0 THEN
			IF inst.para.overwriteExisting = 0 THEN
				inst.cmd.save := 0;
				inst.status.error.AlreadyExist := 1;
				inst.internal.step := 0;
			ELSE	
				inst.internal.fubObjDelete( enable := 1, ident := inst.internal.fubObjInfo.ident );
				inst.internal.step := 31; (* module found ==> delete *)			
			END_IF
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLPARAMETER THEN			
			inst.cmd.save := 0;
			inst.status.error.WrongParameter := 1;
			inst.internal.step := 0;							
		ELSIF inst.internal.fubObjInfo.status = doERR_ILLOBJTYPE OR inst.internal.fubObjInfo.status = doERR_MODULNOTFOUND THEN
			inst.internal.step := 32;  (* module not found ==> create *)			
		END_IF		
		
		
		31:  (* module found ==> delete *)
		IF inst.internal.fubObjDelete.status = 0 THEN
			inst.internal.step := 32;
		ELSIF inst.internal.fubObjDelete.status <> 65535 THEN
			inst.cmd.save := 0;
			inst.status.error.NotFound := 1;
			inst.internal.step := 0;
		ELSE
			inst.internal.fubObjDelete();
		END_IF

		
		32:  (* create module *)
		inst.internal.fubObjCreate( enable := 1, pName := ADR(inst.para.name), grp := 0, len:= inst.para.dataLen, MemType := inst.para.memType, pCpyData := inst.para.pData ); 		
		IF inst.internal.fubObjCreate.status = 0 THEN
			inst.cmd.save := 0;
			inst.status.ok := 1;
			inst.internal.step := 0;
		ELSIF inst.internal.fubObjCreate.status = doERR_ILLPARAMETER THEN			
			inst.cmd.save := 0;
			inst.status.error.WrongParameter := 1;
			inst.internal.step := 0;							
		ELSIF inst.internal.fubObjCreate.status <> 65535 THEN
			inst.cmd.save := 0;		
			inst.status.error.NotFound := 1;
			inst.internal.step := 0;
		ELSE
			inst.internal.fubObjCreate();
		END_IF
	
	END_CASE
END_FUNCTION