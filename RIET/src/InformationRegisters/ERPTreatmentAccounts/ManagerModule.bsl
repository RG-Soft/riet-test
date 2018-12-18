
Функция ПолучитьAccounts(Дата, ERPTreatment) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ERPTreatment) Тогда
		ВызватьИсключение "ERP treatment is empty!";
	КонецЕсли;
		
	СтруктураОтбора = Новый Структура("ERPTreatment", ERPTreatment);
	Возврат ПолучитьПоследнее(Дата, СтруктураОтбора);
	
КонецФункции

Функция ПолучитьAccountsПовтИсп(Дата, ERPTreatment) Экспорт
	
	Возврат CustomsСерверПовтИсп.ПолучитьAccountsПоERPTreatment(НачалоМесяца(Дата), ERPTreatment);	
	
КонецФункции