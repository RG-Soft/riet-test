
Функция НайтиПоService(Service) Экспорт
	
	// Возвращает не помеченный на удаление SCA, в котором указан переданный Service
	
	Если НЕ ЗначениеЗаполнено(Service) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Service", Service);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ServicesCostsAllocationServices.Ссылка
		|ИЗ
		|	Документ.ServicesCostsAllocation.Services КАК ServicesCostsAllocationServices
		|ГДЕ
		|	ServicesCostsAllocationServices.Service = &Service
		|	И НЕ ServicesCostsAllocationServices.Ссылка.ПометкаУдаления";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

// { RGS ASeryakov, 25.07.2018 14:55:14 S-I-0005241
Функция ЭтоServicesCostsAllocation_AZ_TM(Ссылка) Экспорт

	DocumentBase = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Ссылка.Services[0].Service, "DocumentBase");
	ProcessLevel = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "ProcessLevel");
	
	Если ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") И ProcessLevel = Справочники.ProcessLevels.AZ
		ИЛИ (ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") И ProcessLevel = Справочники.ProcessLevels.TM) Тогда
	
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;

КонецФункции // } RGS ASeryakov 25.07.2018 14:55:24 S-I-0005241
