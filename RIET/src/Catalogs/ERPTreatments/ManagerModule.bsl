
Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
		Поля.Добавить("Наименование");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
	  	Представление = Данные.Наименование;
	КонецЕсли;
	 	       
КонецПроцедуры

Функция ПолучитьTMSId(ERPTreatment) Экспорт
	
	ERPTreatments = Справочники.ERPTreatments;
	
	Если ERPTreatment = ERPTreatments.Expense Тогда
		Возврат "EXPENSE";
		
	ИначеЕсли ERPTreatment = ERPTreatments.Asset_FTE_Construction Тогда
		Возврат "ASSET CONSTRUCTION (FTE)";
		
	ИначеЕсли ERPTreatment =  ERPTreatments.Asset_NFTE_Construction Тогда
		Возврат "ASSET CONSTRUCTION (NFTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.New_Inventory Тогда
		Возврат "NEW INVENTORY";
		
	ИначеЕсли ERPTreatment = ERPTreatments.Issued_Inventory Тогда
		Возврат "ISSUED INVENTORY";
		
	ИначеЕсли ERPTreatment = ERPTreatments.New_Asset_FTE Тогда
		Возврат "NEW ASSET (FTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.New_Asset_NFTE Тогда
		Возврат "NEW ASSET (NFTE)";
						
	ИначеЕсли ERPTreatment = ERPTreatments.Used_Asset Тогда
		Возврат "USED ASSET";
		
	Иначе
		Возврат "EXPENSE";
		
	КонецЕсли;	
	
КонецФункции
