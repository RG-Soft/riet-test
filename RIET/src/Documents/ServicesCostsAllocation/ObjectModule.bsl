
///////////////////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();	
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью(РежимЗаписи);
	
	ПроверитьВозможностьИзменения(Отказ, РежимЗаписи, ДополнительныеСвойства.УдаленныеServices);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 
	
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,
		РежимЗаписи,
		ДополнительныеСвойства.ВыборкаServices,
		ДополнительныеСвойства.ВыборкаServicesInOtherAllocations,
		ДополнительныеСвойства.ВыборкаUnclosedShipments);
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
			
	Services.Свернуть("Service", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(Services, "Service");
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли; 

	Если НЕ ЗначениеЗаполнено(Agent) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Agent' is empty!",
			ЭтотОбъект, "Agent", , Отказ);
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если Services.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"List of 'Services' is empty!",
			ЭтотОбъект, "Services", , Отказ);
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью(РежимЗаписи)
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	СтруктураПараметров.Вставить("МассивServices", Services.ВыгрузитьКолонку("Service"));
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	
	Если Проведен Тогда
		
		СтруктураТекстов.Вставить("УдаленныеServices",
			"ВЫБРАТЬ
			|	ServicesCostsAllocationServices.Service
			|ИЗ
			|	Документ.ServicesCostsAllocation.Services КАК ServicesCostsAllocationServices
			|ГДЕ
			|	ServicesCostsAllocationServices.Ссылка = &Ссылка
			|	И НЕ ServicesCostsAllocationServices.Service В (&МассивServices)");
					
	КонецЕсли;  
		
	Если НЕ ПометкаУдаления Тогда
		
		СтруктураТекстов.Вставить("ServicesInOtherAllocations",
			"ВЫБРАТЬ
			|	ServicesCostsAllocationServices.Ссылка.Представление КАК AllocationПредставление,
			|	ServicesCostsAllocationServices.Service,
			|	ServicesCostsAllocationServices.Service.Представление КАК ServiceПредставление
			|ИЗ
			|	Документ.ServicesCostsAllocation.Services КАК ServicesCostsAllocationServices
			|ГДЕ
			|	ServicesCostsAllocationServices.Ссылка <> &Ссылка
			|	И (НЕ ServicesCostsAllocationServices.Ссылка.ПометкаУдаления)
			|	И ServicesCostsAllocationServices.Service В(&МассивServices)");

		
	КонецЕсли;
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
				
		СтруктураТекстов.Вставить("РеквизитыServices",
			"ВЫБРАТЬ
			|	ДокументService.Ссылка КАК Service,
			|	ДокументService.Agent КАК Agent,
			|	ДокументService.Проведен,
			|	ДокументService.DocumentBase.ProcessLevel.Country КАК Country
			|ИЗ
			|	Документ.Service КАК ДокументService
			|ГДЕ
			|	ДокументService.Ссылка В(&МассивServices)");
								
		СтруктураТекстов.Вставить("UnclosedShipments",
			"ВЫБРАТЬ
			|	ДокументService.Ссылка КАК Service,
			|	ДокументService.Представление КАК ServiceПредставление,
			|	ДокументService.DocumentBase.Представление КАК DocumentBaseПредставление
			|ИЗ
			|	Документ.Service КАК ДокументService
			|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗакрытиеПоставки КАК ЗакрытиеПоставки
			|		ПО ДокументService.DocumentBase = ЗакрытиеПоставки.Поставка
			|			И (ЗакрытиеПоставки.Проведен)
			|ГДЕ
			|	ДокументService.Ссылка В(&МассивServices)
			|	И ЗакрытиеПоставки.Проведен ЕСТЬ NULL 
			|	И (ДокументService.DocumentBase ССЫЛКА Документ.Поставка
			|			ИЛИ ДокументService.DocumentBase ССЫЛКА Документ.ExportShipment
			|			ИЛИ ДокументService.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions)
			// { RGS AArsentev 28.03.2018 S-I-0004889
			|	И ДокументService.DocumentBase.ProcessLevel <> ЗНАЧЕНИЕ(Справочник.ProcessLevels.AZ)
			|	И ДокументService.DocumentBase.ProcessLevel <> ЗНАЧЕНИЕ(Справочник.ProcessLevels.TM)
			// } RGS AArsentev 28.03.2018 S-I-0004889
			|");
			
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("УдаленныеServices", Новый Массив);
	Если СтруктураРезультатов.Свойство("УдаленныеServices") Тогда
		ДополнительныеСвойства.УдаленныеServices = СтруктураРезультатов.УдаленныеServices.Выгрузить().ВыгрузитьКолонку("Service");	
	КонецЕсли;
		
	ДополнительныеСвойства.Вставить("ВыборкаServicesInOtherAllocations", Неопределено);
	Если СтруктураРезультатов.Свойство("ServicesInOtherAllocations") Тогда
		ДополнительныеСвойства.ВыборкаServicesInOtherAllocations = СтруктураРезультатов.ServicesInOtherAllocations.Выбрать();
	КонецЕсли; 
	
	ДополнительныеСвойства.Вставить("ВыборкаServices", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыServices") Тогда
		ДополнительныеСвойства.ВыборкаServices = СтруктураРезультатов.РеквизитыServices.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаUnclosedShipments", Неопределено);
	Если СтруктураРезультатов.Свойство("UnclosedShipments") Тогда
		ДополнительныеСвойства.ВыборкаUnclosedShipments = СтруктураРезультатов.UnclosedShipments.Выбрать();
	КонецЕсли;
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(Отказ, РежимЗаписи, УдаленныеServices)
	
	Если НЕ Проведен Тогда 
		Возврат;
	КонецЕсли;
	
	// Определим, есть ли расход по удаляемым из ТЧ сервисам или по текущим сервисам, если документ распроводится	
	ServicesДляПолученияОборотов = РГСофтКлиентСервер.СложитьМассивы(УдаленныеServices, Новый Массив);
	Если РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения Тогда
		ServicesДляПолученияОборотов = РГСофтКлиентСервер.СложитьМассивы(ServicesДляПолученияОборотов, Services.ВыгрузитьКолонку("Service"));	
	КонецЕсли;
	
	Если ServicesДляПолученияОборотов.Количество() Тогда
		
		ТаблицаОборотов = РегистрыНакопления.NotReceivedAgentInvoices.ОборотыПоРегистраторам(,, ServicesДляПолученияОборотов);
		ТаблицаОборотов.Свернуть("Регистратор, Service", "SumРасход");
		Для Каждого СтрокаТаблицы Из ТаблицаОборотов Цикл
			
			Если СтрокаТаблицы.SumРасход > 0 Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"You can not change '" + ЭтотОбъект + "', because Service '" + СтрокаТаблицы.Service + "' is already in '" + СтрокаТаблицы.Регистратор + "'!",
					СтрокаТаблицы.Регистратор, , , Отказ);	
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаServices, ВыборкаServicesInOtherAllocations, ВыборкаUnclosedShipments)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
	
	// Убедимся, что указанные сервисы еще не проходили распределения
	Пока ВыборкаServicesInOtherAllocations.Следующий() Цикл
		
		СтрокаТЧ = Services.Найти(ВыборкаServicesInOtherAllocations.Service, "Service");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'" + ВыборкаServicesInOtherAllocations.ServiceПредставление + "' is already in '" + ВыборкаServicesInOtherAllocations.AllocationПредставление + "'!",
			ЭтотОбъект, "Services[" + (СтрокаТЧ.НомерСтроки - 1) + "].Service", , Отказ);
			
	КонецЦикла; 
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли; 
		
	Пока ВыборкаServices.Следующий() Цикл
				
		Если Не ВыборкаServices.Проведен Тогда
			
			СтрокаТЧ = Services.Найти(ВыборкаServices.Service, "Service");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'" + ВыборкаServices.Service + "' is not posted!",
				ЭтотОбъект, "Services[" + (СтрокаТЧ.НомерСтроки - 1) + "].Service", , Отказ);
			
		КонецЕсли; 
		
		Если ВыборкаServices.Agent <> Agent Тогда
			
			СтрокаТЧ = Services.Найти(ВыборкаServices.Service, "Service");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Agent '" + СокрЛП(ВыборкаServices.Agent) + "' of '" + ВыборкаServices.Service + "' differs from the Agent '" + СокрЛП(Agent) + "' of the current document!",
				ЭтотОбъект, "Services[" + (СтрокаТЧ.НомерСтроки - 1) + "].Service", , Отказ);
			
		КонецЕсли; 
		
	КонецЦикла; 
				
	// Убедимся, что для всех Shipment есть Invoice lines matchings
	Пока ВыборкаUnclosedShipments.Следующий() Цикл
		
		СтрокаТЧ = Services.Найти(ВыборкаUnclosedShipments.Service, "Service");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"There is no Invoice lines mathching for '" + ВыборкаUnclosedShipments.DocumentBaseПредставление + "'!",
			ЭтотОбъект, "Services[" + (СтрокаТЧ.НомерСтроки - 1) + "].Service", , Отказ);
		
	КонецЦикла;
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоInvoiceLinesCosts(Отказ);
	
	ДвиженияПоNotReceivedAgentInvoices(Отказ);
	
КонецПроцедуры 

Процедура ДвиженияПоInvoiceLinesCosts(Отказ)
	
	СтруктураПараметров = Новый Структура("МассивServices", Services.ВыгрузитьКолонку("Service"));
	СтруктураТекстов = Новый Структура;
	
	СтруктураТекстов.Вставить("Services",
		"ВЫБРАТЬ
		|	ДокументService.Ссылка КАК Service,
		|	ДокументService.Service.AllocationArea КАК AllocationArea,
		|	ДокументService.Service.AllocationMethod КАК AllocationMethod,
		|	ДокументService.Service.DutiesRecharge КАК DutiesRecharge,
		|	ДокументService.GrandTotal КАК Sum,
		|	ДокументService.DocumentBase КАК DocumentBase
		|ПОМЕСТИТЬ Services
		|ИЗ
		|	Документ.Service КАК ДокументService
		|ГДЕ
		|	ДокументService.Ссылка В(&МассивServices)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Service,
		|	AllocationArea,
		|	AllocationMethod,
		|	DocumentBase");
		
	СтруктураТекстов.Вставить("ShipmentServicesEqually",
		"ВЫБРАТЬ
		|	Services.Service,
		|	Services.Sum
		|ИЗ
		|	Services КАК Services
		|ГДЕ
		|	Services.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.Equally)
		|	И (Services.DocumentBase ССЫЛКА Документ.Поставка
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.ExportShipment
		// { RGS ASeryakov, 22.07.18:105644 S-I-0005241
		|			//СтрокаУсловие
		// } RGS ASeryakov 22.07.18:105646 S-I-0005241
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions)");
		
	// { RGS ASeryakov, 22.07.18:105644 S-I-0005241
	СтрокаУсловие = "ИЛИ Services.DocumentBase ССЫЛКА Документ.CustomsFilesLight";
	
	Если Документы.ServicesCostsAllocation.ЭтоServicesCostsAllocation_AZ_TM(ЭтотОбъект.Ссылка) Тогда
	
		ТекстЗапроса_ShipmentServicesEqually = СтруктураТекстов.ShipmentServicesEqually;
		ТекстЗапроса_ShipmentServicesEqually_AZ_TM = СтрЗаменить(ТекстЗапроса_ShipmentServicesEqually, "//СтрокаУсловие", СтрокаУсловие);
		СтруктураТекстов.ShipmentServicesEqually = ТекстЗапроса_ShipmentServicesEqually_AZ_TM;
		
	КонецЕсли;
	// } RGS ASeryakov 22.07.18:105646 S-I-0005241
	
	СтруктураТекстов.Вставить("ShipmentServicesBySum",
		"ВЫБРАТЬ
		|	Services.Service,
		|	Services.Sum
		|ИЗ
		|	Services КАК Services
		|ГДЕ
		|	Services.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.BySum)
		|	И (Services.DocumentBase ССЫЛКА Документ.Поставка
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.ExportShipment
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions)");
		
	СтруктураТекстов.Вставить("ShipmentServicesByChargeableWeight",
		"ВЫБРАТЬ
		|	Services.Service,
		|	Services.Sum
		|ИЗ
		|	Services КАК Services
		|ГДЕ
		|	Services.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.ByChargeableWeight)
		|	И (Services.DocumentBase ССЫЛКА Документ.Поставка
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.ExportShipment
		|			ИЛИ Services.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions)");
		
	СтруктураТекстов.Вставить("ТПОServicesEqually",
		"ВЫБРАТЬ
		|	Services.Service,
		|	Services.Sum
		|ИЗ
		|	Services КАК Services
		|ГДЕ
		|	Services.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.Equally)
		|	И Services.DocumentBase ССЫЛКА Документ.CustomsFilesLight");
		
	СтруктураТекстов.Вставить("ТПОServicesBySum",
		"ВЫБРАТЬ
		|	Services.Service,
		|	Services.Sum
		|ИЗ
		|	Services КАК Services
		|ГДЕ
		|	Services.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.BySum)
		|	И Services.DocumentBase ССЫЛКА Документ.CustomsFilesLight");	
		
	СтруктураТекстов.Вставить("ServicesWithInvoiceLines",
		"ВЫБРАТЬ
		|	ServicesWithInvoiceLines.Service,
		|	ServicesWithInvoiceLines.DutiesRecharge,
		|	ServicesWithInvoiceLines.AllocationMethod КАК AllocationMethod,
		|	ServicesWithInvoiceLines.InvoiceLine
		|ПОМЕСТИТЬ ServicesWithInvoiceLines
		|ИЗ
		|	(ВЫБРАТЬ
		|		Services.Service КАК Service,
		|		Services.AllocationMethod КАК AllocationMethod,
		|		Services.DutiesRecharge КАК DutiesRecharge,
		|		СтрокиИнвойса.Ссылка КАК InvoiceLine
		|	ИЗ
		|		Services КАК Services
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
		|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|					ПО КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс = СтрокиИнвойса.Инвойс
		|						И (НЕ СтрокиИнвойса.ПометкаУдаления)
		|				ПО ПоставкаУпаковочныеЛисты.УпаковочныйЛист = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
		|			ПО Services.DocumentBase = ПоставкаУпаковочныеЛисты.Ссылка
		|	ГДЕ
		|		Services.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.Shipment)
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		Services.Service,
		|		Services.AllocationMethod,
		|		Services.DutiesRecharge,
		|		Goods.Ссылка
		|	ИЗ
		|		Services КАК Services
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ExportShipment.ExportRequests КАК ExportShipmentsExportRequests
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Goods
		|				ПО ExportShipmentsExportRequests.ExportRequest = Goods.ExportRequest
		|					И (НЕ Goods.ПометкаУдаления)
		|			ПО Services.DocumentBase = ExportShipmentsExportRequests.Ссылка
		|	ГДЕ
		|		Services.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.Shipment)
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		Services.Service,
		|		Services.AllocationMethod,
		|		Services.DutiesRecharge,
		|		TemporaryImpExpTransactionsItems.Item
		|	ИЗ
		|		Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Services КАК Services
		|			ПО (Services.DocumentBase = TemporaryImpExpTransactionsItems.Ссылка)
		|	ГДЕ
		|		Services.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.Shipment)
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ РАЗЛИЧНЫЕ
		|		Services.Service,
		|		Services.AllocationMethod,
		|		Services.DutiesRecharge,
		|		ЗакрытиеПоставкиСопоставление.СтрокаИнвойса
		|	ИЗ
		|		Services КАК Services
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗакрытиеПоставки.Сопоставление КАК ЗакрытиеПоставкиСопоставление
		|			ПО Services.Service.CCD = ЗакрытиеПоставкиСопоставление.ТоварСтрокиГТД.Владелец.ГТД
		|	ГДЕ
		|		Services.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.CCD)
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		Services.Service,
		|		Services.AllocationMethod,
		|		Services.DutiesRecharge,
		|		ServiceInvoiceLines.InvoiceLine
		|	ИЗ
		|		Services КАК Services
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Service.InvoiceLines КАК ServiceInvoiceLines
		|			ПО Services.Service = ServiceInvoiceLines.Ссылка
		|	ГДЕ
		|		Services.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.InvoiceLines)) КАК ServicesWithInvoiceLines
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	AllocationMethod");
		
	СтруктураТекстов.Вставить("InvoiceLines",
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ServicesWithInvoiceLines.InvoiceLine КАК InvoiceLine
		|ПОМЕСТИТЬ InvoiceLines
		|ИЗ
		|	ServicesWithInvoiceLines КАК ServicesWithInvoiceLines
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	InvoiceLine");
		
	СтруктураПараметров.Вставить("МоментВремени", МоментВремени());
	СтруктураТекстов.Вставить("РеквизитыInvoiceLines",
	    "ВЫБРАТЬ
	    |	InvoiceLines.InvoiceLine КАК InvoiceLine,
		|	СтрокиИнвойса.SoldTo,
	    |	СтрокиИнвойса.КостЦентр КАК AU,
		|	СтрокиИнвойса.КостЦентр.Segment КАК Segment,
		|	СтрокиИнвойса.КостЦентр.SubSegment КАК SubSegment,
		|	СтрокиИнвойса.КостЦентр.Geomarket КАК Geomarket,
		|	СтрокиИнвойса.КостЦентр.SubGeomarket КАК SubGeomarket,
	    |	СтрокиИнвойса.Классификатор КАК ERPTreatment,
	    |	СтрокиИнвойса.Активити КАК InvoiceLineActivity,
	    |	СтрокиИнвойса.КостЦентр.DefaultActivity КАК AUActivity,
	    |	ERPTreatmentAccountsСрезПоследних.AgentAccount КАК Account
	    |ИЗ
	    |	InvoiceLines КАК InvoiceLines
	    |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	    |			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ERPTreatmentAccounts.СрезПоследних(&МоментВремени, ) КАК ERPTreatmentAccountsСрезПоследних
	    |			ПО СтрокиИнвойса.Классификатор = ERPTreatmentAccountsСрезПоследних.ERPTreatment
	    |		ПО InvoiceLines.InvoiceLine = СтрокиИнвойса.Ссылка");
		
	СтруктураТекстов.Вставить("InvoiceLinesEqually",
		"ВЫБРАТЬ
		|	ServicesWithInvoiceLines.Service,
		|	ServicesWithInvoiceLines.DutiesRecharge,
		|	ServicesWithInvoiceLines.InvoiceLine
		|ИЗ
		|	ServicesWithInvoiceLines КАК ServicesWithInvoiceLines
		|ГДЕ
		|	ServicesWithInvoiceLines.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.Equally)");
		
	СтруктураТекстов.Вставить("InvoiceLinesBySum",
		"ВЫБРАТЬ
		|	ServicesWithInvoiceLines.Service,
		|	ServicesWithInvoiceLines.DutiesRecharge,
		|	ServicesWithInvoiceLines.InvoiceLine,
		|	ServicesWithInvoiceLines.InvoiceLine.Сумма КАК InvoiceLineSum
		|ИЗ
		|	ServicesWithInvoiceLines КАК ServicesWithInvoiceLines
		|ГДЕ
		|	ServicesWithInvoiceLines.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.BySum)");
		
	СтруктураТекстов.Вставить("InvoiceLinesByChargeableWeight",
		"ВЫБРАТЬ
		|	ServicesWithInvoiceLines.Service,
		|	ServicesWithInvoiceLines.DutiesRecharge,
		|	ServicesWithInvoiceLines.InvoiceLine,
		|	ServicesWithInvoiceLines.InvoiceLine.Сумма КАК InvoiceLineSum,
		|	СУММА(ParcelGoods.ChargeableWeight) КАК ChargeableWeight
		|ИЗ
		|	ServicesWithInvoiceLines КАК ServicesWithInvoiceLines
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelGoods
		|		ПО ServicesWithInvoiceLines.InvoiceLine = ParcelGoods.СтрокаИнвойса
		|			И (ParcelGoods.Ссылка.Проверен)
		|ГДЕ
		|	ServicesWithInvoiceLines.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.ByChargeableWeight)
		|
		|СГРУППИРОВАТЬ ПО
		|	ServicesWithInvoiceLines.Service,
		|	ServicesWithInvoiceLines.DutiesRecharge,
		|	ServicesWithInvoiceLines.InvoiceLine,
		|	ServicesWithInvoiceLines.InvoiceLine.Сумма");
		
	СтруктураТекстов.Вставить("ServicesWithAUs",
		"ВЫБРАТЬ
		|	Services.Service КАК Service,
		|	Services.AllocationMethod КАК AllocationMethod,
		|	Services.DutiesRecharge,
		|	CustomsFilesLightAUs.Ссылка.SoldTo КАК SoldTo,
		|	CustomsFilesLightAUs.AU КАК AU,
		|	CustomsFilesLightAUs.AU.Segment КАК Segment,
		|	CustomsFilesLightAUs.AU.DefaultActivity КАК Activity,
		|	СУММА(CustomsFilesLightAUs.InvoiceTotalValue) КАК InvoiceTotalValue
		|ПОМЕСТИТЬ ServicesWithAUs
		|ИЗ
		|	Services КАК Services
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.CustomsFilesLight.Goods КАК CustomsFilesLightAUs
		|		ПО Services.DocumentBase = CustomsFilesLightAUs.Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	Services.Service,
		|	Services.AllocationMethod,
		|	Services.DutiesRecharge,
		|	CustomsFilesLightAUs.AU,
		|	CustomsFilesLightAUs.AU.DefaultActivity,
		|	CustomsFilesLightAUs.AU.Segment,
		|	CustomsFilesLightAUs.Ссылка.SoldTo
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	AllocationMethod");	
		
	СтруктураТекстов.Вставить("РеквизитыAUs",
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ServicesWithAUs.AU,
		|	ServicesWithAUs.Activity
		|ИЗ
		|	ServicesWithAUs КАК ServicesWithAUs");
		
	СтруктураТекстов.Вставить("AUsEqually",
		"ВЫБРАТЬ
		|	ServicesWithAUs.Service,
		|	ServicesWithAUs.DutiesRecharge,
		|	ServicesWithAUs.SoldTo,
		|	ServicesWithAUs.Segment,
		|	ServicesWithAUs.AU, 		
		|	ServicesWithAUs.AU.SubSegment КАК SubSegment,
		|	ServicesWithAUs.AU.Geomarket КАК Geomarket,
		|	ServicesWithAUs.AU.SubGeomarket КАК SubGeomarket,
		|	ServicesWithAUs.Activity
		|ИЗ
		|	ServicesWithAUs КАК ServicesWithAUs
		|ГДЕ
		|	ServicesWithAUs.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.Equally)");
		
	СтруктураТекстов.Вставить("AUsBySum",
		"ВЫБРАТЬ
		|	ServicesWithAUs.Service,
		|	ServicesWithAUs.DutiesRecharge,
		|	ServicesWithAUs.SoldTo,
		|	ServicesWithAUs.Segment,
		|	ServicesWithAUs.AU,
		|	ServicesWithAUs.AU.SubSegment КАК SubSegment,
		|	ServicesWithAUs.AU.Geomarket КАК Geomarket,
		|	ServicesWithAUs.AU.SubGeomarket КАК SubGeomarket,
		|	ServicesWithAUs.Activity,
		|	ServicesWithAUs.InvoiceTotalValue
		|ИЗ
		|	ServicesWithAUs КАК ServicesWithAUs
		|ГДЕ
		|	ServicesWithAUs.AllocationMethod = ЗНАЧЕНИЕ(Перечисление.AllocationMethods.BySum)");
		
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);	
	
	// Проверим заполнение реквизитов в строках инвойса
	ТаблицаРеквизитовInvoiceLines = СтруктураРезультатов.РеквизитыInvoiceLines.Выгрузить();
	Для Каждого СтрокаТаблицы Из ТаблицаРеквизитовInvoiceLines Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.AU) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In ""Item """ + СокрЛП(СтрокаТаблицы.InvoiceLine) + """ ""AU"" is empty!",
				ЭтотОбъект, , , Отказ);
		КонецЕсли; 
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.ERPTreatment) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In ""Item " + СокрЛП(СтрокаТаблицы.InvoiceLine) + """ ""ERP treatment"" is empty!",
				ЭтотОбъект, , , Отказ);
		Иначе
				
			Если ЗначениеЗаполнено(СтрокаТаблицы.Account) Тогда
				
				Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.InvoiceLineActivity)
					И НЕ ЗначениеЗаполнено(СтрокаТаблицы.AUActivity)
					И Лев(СтрокаТаблицы.Account, 1) = "5" Тогда
					
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"Failed to determine Activity for ""Item " + СокрЛП(СтрокаТаблицы.InvoiceLine) + """!",
						ЭтотОбъект, , , Отказ);
									
				КонецЕсли; 	
				
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"There is no Account for ""ERP treatment " + СокрЛП(СтрокаТаблицы.ERPTreatment) + """!",
					ЭтотОбъект, , , Отказ);		
			КонецЕсли;
						
		КонецЕсли;
		
	КонецЦикла;
	
	// Проверим заполнение реквизитов в AU
	ВыборкаРеквизитовAUs = СтруктураРезультатов.РеквизитыAUs.Выбрать();
	Пока ВыборкаРеквизитовAUs.Следующий() Цикл
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовAUs.Activity) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In ""AU " + СокрЛП(ВыборкаРеквизитовAUs.AU) + """ ""Default activity"" is empty!",
				ЭтотОбъект, , , Отказ);
		КонецЕсли;
		
	КонецЦикла;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Сформируем таблицы
	ТаблицаShipmentServicesEqually = СтруктураРезультатов.ShipmentServicesEqually.Выгрузить();
	ТаблицаInvoiceLinesEqually = СтруктураРезультатов.InvoiceLinesEqually.Выгрузить();
			
	ТаблицаShipmentServicesBySum = СтруктураРезультатов.ShipmentServicesBySum.Выгрузить();
	ТаблицаInvoiceLinesBySum = СтруктураРезультатов.InvoiceLinesBySum.Выгрузить();	
	
	ТаблицаShipmentServicesByChargeableWeight = СтруктураРезультатов.ShipmentServicesByChargeableWeight.Выгрузить();
	ТаблицаInvoiceLinesByChargeableWeight = СтруктураРезультатов.InvoiceLinesByChargeableWeight.Выгрузить();
	
	// Найдем Invoice lines, у которых не определен chargeable weight, и перекинем их в таблицы распределения по сумме
	ТаблицаInvoiceLinesByChargeableWeight.Индексы.Добавить("Service");
	СтруктураПоиска = Новый Структура("Service");
	Индекс = 0;
	Пока Индекс < ТаблицаShipmentServicesByChargeableWeight.Количество() Цикл
		
		СтрокаТаблицыShipmentServicesByChargeableWeight = ТаблицаShipmentServicesByChargeableWeight[Индекс];
		СтруктураПоиска.Service = СтрокаТаблицыShipmentServicesByChargeableWeight.Service;
		СтрокиТаблицыInvoiceLinesByChargeableWeight = ТаблицаInvoiceLinesByChargeableWeight.НайтиСтроки(СтруктураПоиска);
		
		НужноРаспределятьПоСумме = Ложь;
		Для Каждого СтрокаТаблицыInvoiceLinesByChargeableWeight Из СтрокиТаблицыInvoiceLinesByChargeableWeight Цикл
			Если НЕ ЗначениеЗаполнено(СтрокаТаблицыInvoiceLinesByChargeableWeight.ChargeableWeight) Тогда
				НужноРаспределятьПоСумме = Истина;
				Прервать;
			КонецЕсли; 			 
		КонецЦикла; 
		
		Если НужноРаспределятьПоСумме Тогда
			
			НоваяСтрока = ТаблицаShipmentServicesBySum.Добавить();
			НоваяСтрока.Service = СтрокаТаблицыShipmentServicesByChargeableWeight.Service;
			НоваяСтрока.Sum = СтрокаТаблицыShipmentServicesByChargeableWeight.Sum;	
			ТаблицаShipmentServicesByChargeableWeight.Удалить(Индекс);
			
			Для Каждого СтрокаТаблицыInvoiceLinesByChargeableWeight Из СтрокиТаблицыInvoiceLinesByChargeableWeight Цикл
				
				НоваяСтрока = ТаблицаInvoiceLinesBySum.Добавить();
				НоваяСтрока.Service = СтрокаТаблицыInvoiceLinesByChargeableWeight.Service;
				НоваяСтрока.DutiesRecharge = СтрокаТаблицыInvoiceLinesByChargeableWeight.DutiesRecharge;
				НоваяСтрока.InvoiceLine = СтрокаТаблицыInvoiceLinesByChargeableWeight.InvoiceLine;
				НоваяСтрока.InvoiceLineSum = СтрокаТаблицыInvoiceLinesByChargeableWeight.InvoiceLineSum;
				ТаблицаInvoiceLinesByChargeableWeight.Удалить(СтрокаТаблицыInvoiceLinesByChargeableWeight);
				
			КонецЦикла; 
			
		Иначе
			
			Индекс = Индекс + 1;
			
		КонецЕсли; 
		
	КонецЦикла; 
	
	ТаблицаТПОServicesEqually = СтруктураРезультатов.ТПОServicesEqually.Выгрузить();
	ТаблицаAUsEqually = СтруктураРезультатов.AUsEqually.Выгрузить();
			
	ТаблицаТПОServicesBySum = СтруктураРезультатов.ТПОServicesBySum.Выгрузить();
	ТаблицаAUsBySum = СтруктураРезультатов.AUsBySum.Выгрузить();
	
	// Выполним распределение
	ТипЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2));
	
	ТаблицаInvoiceLinesEqually.Колонки.Добавить("Sum", ТипЧисло);
	CustomsСервер.РаспределитьСуммы(ТаблицаShipmentServicesEqually, "Service", "Sum", "Invoice lines", , , ТаблицаInvoiceLinesEqually, Отказ);
		
	ТаблицаInvoiceLinesBySum.Колонки.Добавить("Sum", ТипЧисло);
	CustomsСервер.РаспределитьСуммы(ТаблицаShipmentServicesBySum, "Service", "Sum", "Invoice lines", "InvoiceLineSum", "Invoice line sum", ТаблицаInvoiceLinesBySum, Отказ);
	
	ТаблицаInvoiceLinesByChargeableWeight.Колонки.Удалить("InvoiceLineSum");
	ТаблицаInvoiceLinesByChargeableWeight.Колонки.Добавить("Sum", ТипЧисло);
	CustomsСервер.РаспределитьСуммы(ТаблицаShipmentServicesByChargeableWeight, "Service", "Sum", "Invoice lines", "ChargeableWeight", "Chargeable weight", ТаблицаInvoiceLinesByChargeableWeight, Отказ);
	
	ТаблицаAUsEqually.Колонки.Добавить("Sum", ТипЧисло);
	CustomsСервер.РаспределитьСуммы(ТаблицаТПОServicesEqually, "Service", "Sum", "AUs", , , ТаблицаAUsEqually, Отказ);
		
	ТаблицаAUsBySum.Колонки.Добавить("Sum", ТипЧисло);
	CustomsСервер.РаспределитьСуммы(ТаблицаТПОServicesBySum, "Service", "Sum", "AUs", "InvoiceTotalValue", "Invoice total value", ТаблицаAUsBySum, Отказ);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	ВалютаРуб = Справочники.Валюты.НайтиПоКоду("643");
	
	ДвиженияПоInvoiceLinesCosts = Движения.InvoiceLinesCosts;
	ДвиженияПоInvoiceLinesCosts.Очистить();
	ДвиженияПоDutiesRecharged = Движения.DutiesRecharged;
	ДвиженияПоDutiesRecharged.Очистить();
	
	ТаблицаРеквизитовInvoiceLines.Индексы.Добавить("InvoiceLine");
	ДобавитьДвиженияShipments(ТаблицаInvoiceLinesEqually, ТаблицаРеквизитовInvoiceLines, ВалютаРуб);
	ДобавитьДвиженияShipments(ТаблицаInvoiceLinesBySum, ТаблицаРеквизитовInvoiceLines, ВалютаРуб);
	ДобавитьДвиженияShipments(ТаблицаInvoiceLinesByChargeableWeight, ТаблицаРеквизитовInvoiceLines, ВалютаРуб);

	ДвиженияПоInvoiceLinesCosts.Записать();
	
	ДвиженияПоСтоимостиТоваровПоТПО = Движения.СтоимостьТоваровПоТПО;
	ДвиженияПоСтоимостиТоваровПоТПО.Очистить();
	
	// { RGS ASeryakov, 25.07.2018 13:36:30 S-I-0005241
	//ДобавитьДвиженияПоСтоимостиТоваровПоТПО(ТаблицаAUsEqually);
	
	// Для исключения дублирования записей выводимых в отчет AgentInvoicesDetails
	// для случаев когда в Service реквизит DocBase это CustomsFilesLight и ProcessLevel AZ,TM
	//выполняем проверку:
	DocumentBase = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ЭтотОбъект.Services[0].Service, "DocumentBase");
	ProcessLevel = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "ProcessLevel");
	
	Если НЕ Документы.ServicesCostsAllocation.ЭтоServicesCostsAllocation_AZ_TM(ЭтотОбъект.Ссылка) Тогда
		
			ДобавитьДвиженияПоСтоимостиТоваровПоТПО(ТаблицаAUsEqually);
		
	КонецЕсли;
	// } RGS ASeryakov 25.07.2018 13:36:39 S-I-0005241
	
	ДобавитьДвиженияПоСтоимостиТоваровПоТПО(ТаблицаAUsBySum);
	ДвиженияПоСтоимостиТоваровПоТПО.Записать();
	
	ДвиженияПоDutiesRecharged.Записать();
	
	СформироватьДвиженияInternationalFactCosts(ТаблицаInvoiceLinesEqually, ТаблицаInvoiceLinesBySum, ТаблицаInvoiceLinesByChargeableWeight,
		ТаблицаРеквизитовInvoiceLines, ТаблицаAUsEqually, ТаблицаAUsBySum);
	
КонецПроцедуры 

// ДОДЕЛАТЬ
Процедура ДобавитьДвиженияShipments(Таблица, ТаблицаРеквизитовInvoiceLines, ВалютаРуб)
	
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		
		Если ЗначениеЗаполнено(СтрокаТаблицы.Sum) Тогда
			
			РеквизитыInvoiceLine = ТаблицаРеквизитовInvoiceLines.Найти(СтрокаТаблицы.InvoiceLine, "InvoiceLine");
			
			// ЭТУ ЛОГИКУ НУЖНО ВЫНЕСТИ. ОНА УЖЕ ЕСТЬ В РЕГИСТРЕ INVOICE LINES COSTS.
			Activity = "";
			Если Лев(РеквизитыInvoiceLine.Account, 1) = "5" Тогда
				Activity = ?(ЗначениеЗаполнено(РеквизитыInvoiceLine.InvoiceLineActivity), РеквизитыInvoiceLine.InvoiceLineActivity, РеквизитыInvoiceLine.AUActivity);	
			КонецЕсли;
			
			Если СтрокаТаблицы.DutiesRecharge Тогда
				
				Движение = Движения.DutiesRecharged.Добавить();
				Движение.Период = Дата;
				Движение.SoldTo = РеквизитыInvoiceLine.SoldTo;
				Движение.Segment = РеквизитыInvoiceLine.Segment;
				Движение.СтрокаИнвойса = СтрокаТаблицы.InvoiceLine;
				Движение.ДокументОснование = СтрокаТаблицы.Service;
				Движение.Activity = Activity;
				Движение.СуммаФискальная = СтрокаТаблицы.Sum;
				
			Иначе
				
				Движения.InvoiceLinesCosts.ДобавитьЗапись(
					Дата,
					СтрокаТаблицы.InvoiceLine,
					Справочники.ЭлементыФормированияСтоимости.ПрочиеУслуги,
					СтрокаТаблицы.Service,
					ВалютаРуб,
					СтрокаТаблицы.Sum,
					СтрокаТаблицы.Sum);
								
			КонецЕсли;
			
		КонецЕсли; 
				
	КонецЦикла;
	
КонецПроцедуры 

Процедура ДобавитьДвиженияПоСтоимостиТоваровПоТПО(Таблица)
	
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		
		Если ЗначениеЗаполнено(СтрокаТаблицы.Sum) Тогда
			
			Если СтрокаТаблицы.DutiesRecharge Тогда
				
				Движение = Движения.DutiesRecharged.Добавить();
				Движение.Период = Дата;
				Движение.SoldTo = СтрокаТаблицы.SoldTo;
				Движение.Segment = СтрокаТаблицы.Segment;
				Движение.ДокументОснование = СтрокаТаблицы.Service;
				Движение.Activity = СтрокаТаблицы.Activity;
				Движение.СуммаФискальная = СтрокаТаблицы.Sum;
				
			Иначе
				
				Движение = Движения.СтоимостьТоваровПоТПО.Добавить();
				Движение.Период = Дата;
				Движение.DocumentBase = СтрокаТаблицы.Service;
				Движение.ЭлементФормированияСтоимости = Справочники.ЭлементыФормированияСтоимости.ПрочиеУслуги;
				Движение.AU = СтрокаТаблицы.AU;		
				Движение.Activity = СтрокаТаблицы.Activity;
				Движение.FiscalSum = СтрокаТаблицы.Sum;
				
			КонецЕсли;
			
		КонецЕсли; 
				
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияInternationalFactCosts(ТаблицаInvoiceLinesEqually, ТаблицаInvoiceLinesBySum, ТаблицаInvoiceLinesByChargeableWeight,
													 ТаблицаРеквизитовInvoiceLines, ТаблицаAUsEqually, ТаблицаAUsBySum)
	
	 // регистр International Fact Costs   	
	 УстановитьПривилегированныйРежим(Истина);
	 
	 ДвиженияInternationalFactCosts = Движения.InternationalAndDomesticFactCosts;
	 
	 ДвиженияInternationalFactCosts.Записывать = Истина;
	 ДвиженияInternationalFactCosts.Очистить();
	 
	 Currency = Справочники.CountriesOfProcessLevels.ПолучитьМестнуюВалюту(ДополнительныеСвойства.ВыборкаServices.Country);
	 СurrencyUSD = Справочники.Валюты.НайтиПоКоду("840");
	 ИсключаемыеИзЗатратERPTreatments = ImportExportСерверПовтИспСеанс.ПолучитьИсключаемыеИзЗатратERPTreatments();
	 	 
	 Если ЗначениеЗаполнено(Currency) И Currency <> СurrencyUSD Тогда
		 СтруктураСurrency = ОбщегоНазначения.ПолучитьКурсВалюты(Currency, Дата);
		 СтруктураСurrencyUSD = ОбщегоНазначения.ПолучитьКурсВалюты(СurrencyUSD, Дата);
	 КонецЕсли;
	 
	 // Invoice lines
	 ТЗLinesБезИсключаемыхERP = ТаблицаРеквизитовInvoiceLines.СкопироватьКолонки("SoldTo,Geomarket,SubGeomarket,Segment,SubSegment");
	 ТЗLinesБезИсключаемыхERP.Колонки.Добавить("Sum", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
	 
	 ТаблицаInvoiceLines = СформироватьТаблицуInvoiceLines(ТаблицаInvoiceLinesEqually, ТаблицаInvoiceLinesBySum, ТаблицаInvoiceLinesByChargeableWeight);
	 
	 Для Каждого СтрокаТаблицы Из ТаблицаInvoiceLines Цикл
		 
		 Если Не ЗначениеЗаполнено(СтрокаТаблицы.Sum) Тогда
			 Продолжить;
		 КонецЕсли;
		 
		 РеквизитыInvoiceLine = ТаблицаРеквизитовInvoiceLines.Найти(СтрокаТаблицы.InvoiceLine, "InvoiceLine");
		 
		 Если ИсключаемыеИзЗатратERPTreatments.Найти(РеквизитыInvoiceLine.ERPTreatment) <> Неопределено Тогда 
			 Продолжить;
		 КонецЕсли;	 					
		 
		 СтрокаТЗ = ТЗLinesБезИсключаемыхERP.Добавить();
		 ЗаполнитьЗначенияСвойств(СтрокаТЗ, РеквизитыInvoiceLine);
		 
		 Если ЗначениеЗаполнено(Currency) И Currency <> СurrencyUSD Тогда
			 Sum = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.Sum, 
				 Currency, СurrencyUSD, 
				 СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
		 КонецЕсли;
		 
		 СтрокаТЗ.Sum = Sum;
		 
	 КонецЦикла;
	           	 
	 ТЗLinesБезИсключаемыхERP.Свернуть("SoldTo,Geomarket,SubGeomarket,Segment,SubSegment", "Sum");
	 
	 ДвиженияПоInternationalFactCosts(ДвиженияInternationalFactCosts, ТЗLinesБезИсключаемыхERP);	
	 
	 
	 //AUs
	 
	 ТЗLines = ТаблицаAUsEqually.СкопироватьКолонки("SoldTo,Geomarket,SubGeomarket,Segment,SubSegment");
	 ТЗLines.Колонки.Добавить("Sum", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2)));
	 
	 Для Каждого Стр из ТаблицаAUsEqually Цикл
		 СтрокаТЗ = ТЗLines.Добавить();
		 ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр, "SoldTo,Geomarket,SubGeomarket,Segment,SubSegment,Sum");
	 КонецЦикла;
	 
	 Для Каждого Стр из ТаблицаAUsBySum Цикл
		 СтрокаТЗ = ТЗLines.Добавить();
		 ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр, "SoldTo,Geomarket,SubGeomarket,Segment,SubSegment,Sum");
	 КонецЦикла;
	 
	 ТЗLines.Свернуть("SoldTo,Geomarket,SubGeomarket,Segment,SubSegment", "Sum");
	    
	 Если ЗначениеЗаполнено(Currency) И Currency <> СurrencyUSD Тогда
		 
		 Для Каждого СтрокаТаблицы Из ТЗLines Цикл
			 СтрокаТаблицы.Sum = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(СтрокаТаблицы.Sum, 
				 Currency, СurrencyUSD, 
				 СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
		 КонецЦикла;
		 
	 КонецЕсли;

	 ДвиженияПоInternationalFactCosts(ДвиженияInternationalFactCosts, ТЗLines);	
	 
	 
КонецПроцедуры

Функция СформироватьТаблицуInvoiceLines(ТаблицаInvoiceLinesEqually, ТаблицаInvoiceLinesBySum, ТаблицаInvoiceLinesByChargeableWeight)
	
	ТаблицаInvoiceLines = ТаблицаInvoiceLinesEqually.СкопироватьКолонки("InvoiceLine,Sum");
	
	Для Каждого Стр из ТаблицаInvoiceLinesEqually Цикл
		СтрокаТЗ = ТаблицаInvoiceLines.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр, "InvoiceLine,Sum");
	КонецЦикла;
	
	Для Каждого Стр из ТаблицаInvoiceLinesBySum Цикл
		СтрокаТЗ = ТаблицаInvoiceLines.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр, "InvoiceLine,Sum");
	КонецЦикла;
	
	Для Каждого Стр из ТаблицаInvoiceLinesByChargeableWeight Цикл
		СтрокаТЗ = ТаблицаInvoiceLines.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр, "InvoiceLine,Sum");
	КонецЦикла;
	
	Возврат ТаблицаInvoiceLines;
	
КонецФункции

Процедура ДвиженияПоInternationalFactCosts(ДвиженияInternationalFactCosts, ТЗLines)
	
	Для Каждого СтрокаТЗ Из ТЗLines Цикл
		
		Движение = ДвиженияInternationalFactCosts.Добавить();
		
		Движение.Период = НачалоМесяца(?(День(Дата) > 25, ДобавитьМесяц(Дата, 1), Дата));
		Движение.CostsType = Перечисления.FactCostsTypes.BrokerageServices;
		Движение.DomesticInternational = Перечисления.DomesticInternational.International;
		
		Движение.ParentCompany = СтрокаТЗ.SoldTo;
		Движение.Geomarket = СтрокаТЗ.Geomarket;
		Движение.SubGeomarket = СтрокаТЗ.SubGeomarket;
		Движение.Segment = СтрокаТЗ.Segment;
		Движение.SubSegment = СтрокаТЗ.SubSegment;
		
		Движение.Sum = СтрокаТЗ.Sum;
		
	КонецЦикла;
	
КонецПроцедуры

// ДОДЕЛАТЬ
Процедура ДвиженияПоNotReceivedAgentInvoices(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 
	
	ДвиженияПоNotReceivedInvoices = Движения.NotReceivedAgentInvoices;
	ДвиженияПоNotReceivedInvoices.Очистить();
	ДвиженияПоNotReceivedInvoices.Записывать = Истина;
	
	
	// МОЖНО НЕ ДЕЛАТЬ ЗАПРОС, А БРАТЬ ВСЮ ИНФУ ПРЯМО ИЗ ДВИЖЕНИЙ
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	NotReceivedAgentInvoices.SoldTo,
	|	NotReceivedAgentInvoices.Service,
	|	СУММА(NotReceivedAgentInvoices.Sum) КАК Sum
	|ИЗ
	|	(ВЫБРАТЬ
	|		InvoiceLinesCosts.SoldTo КАК SoldTo,
	|		InvoiceLinesCosts.ДокументОснование КАК Service,
	|		InvoiceLinesCosts.СуммаФискальная КАК Sum
	|	ИЗ
	|		РегистрНакопления.InvoiceLinesCosts КАК InvoiceLinesCosts
	|	ГДЕ
	|		InvoiceLinesCosts.Регистратор = &Регистратор
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		DutiesRecharged.SoldTo,
	|		DutiesRecharged.ДокументОснование,
	|		DutiesRecharged.СуммаФискальная
	|	ИЗ
	|		РегистрНакопления.DutiesRecharged КАК DutiesRecharged
	|	ГДЕ
	|		DutiesRecharged.Регистратор = &Регистратор
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		ВЫРАЗИТЬ(СтоимостьТоваровПоТПО.DocumentBase КАК Документ.Service).DocumentBase.SoldTo,
	|		СтоимостьТоваровПоТПО.DocumentBase,
	|		СтоимостьТоваровПоТПО.FiscalSum
	|	ИЗ
	|		РегистрНакопления.СтоимостьТоваровПоТПО КАК СтоимостьТоваровПоТПО
	|	ГДЕ
	|		СтоимостьТоваровПоТПО.Регистратор = &Регистратор) КАК NotReceivedAgentInvoices
	|
	|СГРУППИРОВАТЬ ПО
	|	NotReceivedAgentInvoices.SoldTo,
	|	NotReceivedAgentInvoices.Service";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ДвиженияПоNotReceivedInvoices.ДобавитьЗапись(
		ВидДвиженияНакопления.Приход,
		Дата,
		Выборка.Service,
		Выборка.SoldTo,
		Выборка.Sum);
		
	КонецЦикла; 
	
КонецПроцедуры 
