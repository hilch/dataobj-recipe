
TYPE
	datmodHandPara_typ : 	STRUCT 
		name : STRING[10]; (*name of data module*)
		overwriteExisting : BOOL; (*overwrite existing module*)
		pData : UDINT; (*pointer to data buffer*)
		dataLen : UDINT; (*length of data*)
		memType : USINT; (*target memory in which the data object is to be saved,  e.g. doTEMP, doUSRRAM, doUSRROM, ...*)
	END_STRUCT;
	datmodHandCmd_typ : 	STRUCT  (*1 = execute, 2 = busy*)
		load : BOOL; (*load module*)
		save : BOOL; (*save data to module*)
		delete : BOOL; (*delete module*)
	END_STRUCT;
	datmodHandStatusError_typ : 	STRUCT 
		AlreadyExist : BOOL; (*module already exist*)
		NotFound : BOOL; (*module not found*)
		WrongParameter : BOOL; (*parameter error (e.g. para.dataLen = 0, para.pData = 0, para.name = '' )*)
	END_STRUCT;
	datmodHandStatus_typ : 	STRUCT 
		ok : BOOL; (*command executed with no error*)
		error : datmodHandStatusError_typ; (*command executed with errors*)
		busy : BOOL; (*busy*)
	END_STRUCT;
	datmodHandInternal_typ : 	STRUCT 
		step : UINT;
		fubObjCreate : DatObjCreate;
		fubObjDelete : DatObjDelete;
		fubObjInfo : DatObjInfo;
		fubObjRead : DatObjRead;
	END_STRUCT;
	datmodHand_typ : 	STRUCT 
		cmd : datmodHandCmd_typ; (*commands*)
		para : datmodHandPara_typ; (*parameters*)
		status : datmodHandStatus_typ; (*states*)
		internal : datmodHandInternal_typ; (*(internal use)*)
	END_STRUCT;
END_TYPE
