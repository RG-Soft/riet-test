
Функция ПолучитьSettings(Дата, ParentCompany) Экспорт
	
	// возвращает структуру настроек для выгрузки в lawson
	// если настроек нет - возвращает Неопределено
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	SettingsOfCustomsFilesToLawsonСрезПоследних.Type,
		|	SettingsOfCustomsFilesToLawsonСрезПоследних.AU,
		|	SettingsOfCustomsFilesToLawsonСрезПоследних.Activity,
		|	SettingsOfCustomsFilesToLawsonСрезПоследних.Account,
		|	SettingsOfCustomsFilesToLawsonСрезПоследних.SubAccount
		|ИЗ
		|	РегистрСведений.SettingsOfCustomsFilesToLawson.СрезПоследних(&Дата, ParentCompany = &ParentCompany) КАК SettingsOfCustomsFilesToLawsonСрезПоследних";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если НЕ Выборка.Следующий() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СтрокаСвойств = "Type, AU, Activity, Account, SubAccount";
	СтруктураВозврата = Новый Структура(СтрокаСвойств);
	ЗаполнитьЗначенияСвойств(СтруктураВозврата, Выборка, СтрокаСвойств);
	
	Возврат СтруктураВозврата;
	
КонецФункции
