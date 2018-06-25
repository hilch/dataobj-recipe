
PROGRAM _INIT

recipe1.milk := 0.4;
recipe1.name := 'espresso';
recipe1.sugar := 1;


//
END_PROGRAM


PROGRAM _CYCLIC

	CASE step OF
		0: (* store data *)
		recipeHandling.para.pData := ADR(recipe1);
		recipeHandling.para.dataLen := SIZEOF(recipe1);
		recipeHandling.para.memType := doUSRROM;
		recipeHandling.para.name := 'recipe00';
		recipeHandling.para.overwriteExisting := 1;	   
		recipeHandling.cmd.save := 1;
		step := 1;
	   
		1: (* load data *)
		IF recipeHandling.status.ok THEN
			recipeHandling.para.pData := ADR(recipe2);
			recipeHandling.para.dataLen := SIZEOF(recipe1);
			recipeHandling.para.memType := doUSRROM;
			recipeHandling.para.name := 'recipe00';
			recipeHandling.cmd.load := 1;
			step := 2;
		END_IF
		
		2:
	   
	END_CASE
	
	(* call function *)
	datmodHand( recipeHandling );

END_PROGRAM
