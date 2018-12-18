
Функция ПолучитьПоTMSId(Знач TMSId) Экспорт
	
	TMSId = ВРег(TMSId);
	
	Если TMSId = "EXPENSE" Тогда
		Возврат Перечисления.ТипыЗаказа.E;
		
	ИначеЕсли TMSID = "ASSET CONSTRUCTION (FTE)" Тогда
		Возврат Перечисления.ТипыЗаказа.V;
		
	ИначеЕсли TMSID = "ASSET CONSTRUCTION (NFTE)" Тогда
		Возврат Перечисления.ТипыЗаказа.U;
		
	ИначеЕсли TMSID = "ISSUED INVENTORY" Тогда
		Возврат Перечисления.ТипыЗаказа.I;
		
	ИначеЕсли TMSID = "NEW ASSET (FTE)" Тогда
		Возврат Перечисления.ТипыЗаказа.A;
		
	ИначеЕсли TMSID = "NEW ASSET (NFTE)" Тогда
		Возврат Перечисления.ТипыЗаказа.A;
		
	ИначеЕсли TMSID = "NEW INVENTORY" Тогда
		Возврат Перечисления.ТипыЗаказа.I;
		
	ИначеЕсли TMSID = "USED ASSET" Тогда
		Возврат Перечисления.ТипыЗаказа.FAT;
		
	Иначе
		Возврат Перечисления.ТипыЗаказа.E;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьTMSId(ERPTreatment, Leg7 = Ложь) Экспорт
	
	ERPTreatments = Перечисления.ТипыЗаказа;
	
	Если ERPTreatment = ERPTreatments.E Тогда
		Возврат "EXPENSE";
		
	ИначеЕсли ERPTreatment = ERPTreatments.V Тогда
		Возврат "ASSET CONSTRUCTION (FTE)";
		
	ИначеЕсли ERPTreatment =  ERPTreatments.U Тогда
		Возврат "ASSET CONSTRUCTION (NFTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.I Тогда
		Возврат ?(Leg7, "NEW INVENTORY", "ISSUED INVENTORY");
		
	ИначеЕсли ERPTreatment = ERPTreatments.A Тогда
		Возврат "NEW ASSET (FTE)";
						
	ИначеЕсли ERPTreatment = ERPTreatments.FAT Тогда
		Возврат "USED ASSET";
		
	Иначе
		Возврат "EXPENSE";
		
	КонецЕсли;	
	
КонецФункции
