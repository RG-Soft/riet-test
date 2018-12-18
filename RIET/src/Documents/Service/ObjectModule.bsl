
////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ТипЗнчДанныхЗаполнения = Тип("Структура") Тогда 
		
		МетаданныеОбъекта = Метаданные();
		Для Каждого КлючИЗначение Из ДанныеЗаполнения Цикл
			
			Если МетаданныеОбъекта.Реквизиты.Найти(КлючИЗначение.Ключ) <> Неопределено Тогда
				ЭтотОбъект[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
			КонецЕсли; 
			
		КонецЦикла; 
		
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(DocumentBase) Тогда
		
		Если НЕ ЗначениеЗаполнено(Agent)
			И ТипЗнч(DocumentBase) <> Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
			Agent = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "CCA");
		КонецЕсли; 
		
		Если НЕ ЗначениеЗаполнено(AgentNo)
			И ТипЗнч(DocumentBase) = Тип("ДокументСсылка.Поставка") Тогда
			AgentNo = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "CCAJobReference");
		КонецЕсли; 

	КонецЕсли; 
	
КонецПроцедуры 


////////////////////////////////////////////////////////////////////////////
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
	
	ПроверитьВозможностьИзменения(
		Отказ,
		ДополнительныеСвойства.ВыборкаServicesCostsAllocations);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли; 

	ДозаполнитьРеквизитыСДополнительнымиДанными();
	
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,
		РежимЗаписи,
		ДополнительныеСвойства.ВыборкаРеквизитовDocumentBase,
		ДополнительныеСвойства.МассивServicePorts);
		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	AgentNo = СокрЛП(AgentNo);
	Description = СокрЛП(Description);	
		
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
			
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 

	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(DocumentBase) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Document-base' is empty!",
			ЭтотОбъект, "DocumentBase", , Отказ);	
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли; 

	Если НЕ ЗначениеЗаполнено(Agent) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Agent' is empty!",
			ЭтотОбъект, "Agent", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Service) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Service' is empty!",
			ЭтотОбъект, "Service", , Отказ);	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Sum) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Sum' is empty!",
			ЭтотОбъект, "Sum", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(GrandTotal) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Grand total' is empty!",
			ЭтотОбъект, "GrandTotal", , Отказ);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойстваПередЗаписью(РежимЗаписи)
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если Проведен Тогда
		
		СтруктураПараметров.Вставить("Ссылка", Ссылка);
		СтруктураТекстов.Вставить("ServicesCostsAllocations",
			"ВЫБРАТЬ
			|	ServicesCostsAllocationServices.Ссылка.Представление
			|ИЗ
			|	Документ.ServicesCostsAllocation.Services КАК ServicesCostsAllocationServices
			|ГДЕ
			|	ServicesCostsAllocationServices.Service = &Ссылка
			|	И ServicesCostsAllocationServices.Ссылка.Проведен");
		
	КонецЕсли; 
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
			
		СтруктураПараметров.Вставить("DocumentBase", DocumentBase);
		СтруктураТекстов.Вставить("РеквизитыDocumentBase");
		ТипЗнчDocumentBase = ТипЗнч(DocumentBase);
		Если ТипЗнчDocumentBase = Тип("ДокументСсылка.Поставка") Тогда
			
			СтруктураТекстов.РеквизитыDocumentBase =
				"ВЫБРАТЬ
				|	Поставка.Проведен,
				|	Поставка.ActualPOA КАК Port,
				|	Поставка.InCustoms,
				|	Поставка.TMSShipmentID,
				|	Поставка.ProcessLevel
				|ИЗ
				|	Документ.Поставка КАК Поставка
				|ГДЕ
				|	Поставка.Ссылка = &DocumentBase";	
				
		ИначеЕсли ТипЗнчDocumentBase = Тип("ДокументСсылка.ExportShipment") Тогда
				
			СтруктураТекстов.РеквизитыDocumentBase =
				"ВЫБРАТЬ
				|	ExportShipment.Проведен,
				|	ExportShipment.POD КАК Port,
				|	ExportShipment.SubmittedToCustoms КАК InCustoms,
				|	ExportShipment.TMSShipmentID,
				|	ExportShipment.ProcessLevel
				|ИЗ
				|	Документ.ExportShipment КАК ExportShipment
				|ГДЕ
				|	ExportShipment.Ссылка = &DocumentBase";	
				
		ИначеЕсли ТипЗнчDocumentBase = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			
			СтруктураТекстов.РеквизитыDocumentBase = 
				"ВЫБРАТЬ
				|	CustomsFilesLight.Shipment,
				|	CustomsFilesLight.Проведен,
				|	CustomsFilesLight.Дата,
				|	CustomsFilesLight.ReleaseDate,
				|	CustomsFilesLight.CCA,
				|	CustomsFilesLight.PaidByCCA,
				|	CustomsFilesLight.ProcessLevel,
				|	CustomsFilesLight.Shipment.TMSShipmentID КАК TMSShipmentID
				|ИЗ
				|	Документ.CustomsFilesLight КАК CustomsFilesLight
				|ГДЕ
				|	CustomsFilesLight.Ссылка = &DocumentBase";
			
		ИначеЕсли ТипЗнчDocumentBase = Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
			
			СтруктураТекстов.РеквизитыDocumentBase = 
				"ВЫБРАТЬ
				|	TemporaryImpExpTransactions.Проведен,
				|	TemporaryImpExpTransactions.Дата,
				|	TemporaryImpExpTransactions.ProcessLevel,
				|	TemporaryImpExpTransactions.CustomsFile.Shipment КАК Shipment,
				|	TemporaryImpExpTransactions.CustomsFile.Shipment.TMSShipmentID КАК TMSShipmentID
				|ИЗ
				|	Документ.TemporaryImpExpTransactions КАК TemporaryImpExpTransactions
				|ГДЕ
				|	TemporaryImpExpTransactions.Ссылка = &DocumentBase";
			
		КонецЕсли;
				
		СтруктураПараметров.Вставить("Service", Service);				
		СтруктураТекстов.Вставить("ServicePorts",
			"ВЫБРАТЬ
			|	ServicePorts.Port
			|ИЗ
			|	Справочник.Services.Ports КАК ServicePorts
			|ГДЕ
			|	ServicePorts.Ссылка = &Service");
		
		// { RGS ASeryakov, 08.11.2018 11:26:59 S-I-0005241
		//Если ТипЗнч(DocumentBase) <> Тип("ДокументСсылка.CustomsFilesLight")
		//	И ЗначениеЗаполнено(CCD) Тогда
		//	
		//	СтруктураПараметров.Вставить("CCD", CCD);
		//	СтруктураТекстов.Вставить("РеквизитыCCD",
		//		"ВЫБРАТЬ
		//		|	CustomsFile.Дата,
		//		|	CustomsFile.Проведен,
		//		|	CustomsFile.CCA,
		//		|	CustomsFile.Shipment,
		//		|	CustomsFile.PaidByCCA
		//		|ИЗ
		//		|	Документ.ГТД КАК CustomsFile
		//		|ГДЕ
		//		|	CustomsFile.Ссылка = &CCD");
		
		Если ТипЗнч(DocumentBase) <> Тип("ДокументСсылка.CustomsFilesLight")
			И ЗначениеЗаполнено(CCD) И ТипЗнч(CCD) = Тип("ДокументСсылка.ГТД") Тогда
			
			СтруктураПараметров.Вставить("CCD", CCD);
			СтруктураТекстов.Вставить("РеквизитыCCD",
				"ВЫБРАТЬ
				|	CustomsFile.Дата,
				|	CustomsFile.Проведен,
				|	CustomsFile.CCA,
				|	CustomsFile.Shipment,
				|	CustomsFile.PaidByCCA
				|ИЗ
				|	Документ.ГТД КАК CustomsFile
				|ГДЕ
				|	CustomsFile.Ссылка = &CCD");
		ИначеЕсли ТипЗнч(DocumentBase) <> Тип("ДокументСсылка.CustomsFilesLight")
			И ЗначениеЗаполнено(CCD) И ТипЗнч(CCD) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			
			СтруктураПараметров.Вставить("CCD", CCD);
			СтруктураТекстов.Вставить("РеквизитыCCD",
				"ВЫБРАТЬ
				|	CustomsFilesLight.Дата,
				|	CustomsFilesLight.Проведен,
				|	CustomsFilesLight.CCA,
				|	CustomsFilesLight.Shipment,
				|	CustomsFilesLight.PaidByCCA
				|ИЗ
				|	Документ.CustomsFilesLight КАК CustomsFilesLight
				|ГДЕ
				|	CustomsFilesLight.Ссылка = &CCD");
		// } RGS ASeryakov 08.11.2018 11:27:01 S-I-0005241
		КонецЕсли;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаServicesCostsAllocations", Неопределено);
	Если СтруктураРезультатов.Свойство("ServicesCostsAllocations") Тогда
		ДополнительныеСвойства.ВыборкаServicesCostsAllocations = СтруктураРезультатов.ServicesCostsAllocations.Выбрать();
	КонецЕсли; 
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовDocumentBase", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыDocumentBase") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовDocumentBase = СтруктураРезультатов.РеквизитыDocumentBase.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовDocumentBase.Следующий();
	КонецЕсли;
		
	ДополнительныеСвойства.Вставить("МассивServicePorts", Неопределено);
	Если СтруктураРезультатов.Свойство("ServicePorts") Тогда
		ДополнительныеСвойства.МассивServicePorts = СтруктураРезультатов.ServicePorts.Выгрузить().ВыгрузитьКолонку("Port");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCCD", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCCD") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCCD = СтруктураРезультатов.РеквизитыCCD.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCCD.Следующий();
	КонецЕсли; 
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(Отказ, ВыборкаServicesCostsAllocations)
	
	Если Проведен Тогда
		
		Если ВыборкаServicesCostsAllocations.Следующий() Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"You can not change the current service, because there is already posted '" + ВыборкаServicesCostsAllocations.Представление + "'!",
				ЭтотОбъект, , , Отказ);
			
		КонецЕсли;
		
	КонецЕсли; 
		
КонецПроцедуры 


////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными()
	
	Если ЗначениеЗаполнено(Service) Тогда
		// { RGS ASeryakov, 22.07.18:09:50:49 S-I-0005241
		//AllocationArea = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "AllocationArea");
		AllocationArea = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Service, "AllocationArea");
		// { RGS ASeryakov, 22.07.18:09:50:49 S-I-0005241
		
		Если AllocationArea <> Перечисления.AllocationAreas.CCD
			ИЛИ ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			
			CCD = Неопределено;
			
		КонецЕсли;
		//// { RGS ASeryakov, 22.07.18:09:50:49 S-I-0005241
		//Если AllocationArea <> Перечисления.AllocationAreas.InvoiceLines
		//	ИЛИ ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		//	
		//	InvoiceLines.Очистить();
		//	
		//КонецЕсли;
		
		//SumCalculationMethod = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "SumCalculationMethod");
		
		ProcessLevel = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "ProcessLevel");
		
		Если AllocationArea <> Перечисления.AllocationAreas.InvoiceLines И (ProcessLevel <> Справочники.ProcessLevels.AZ И ProcessLevel <> Справочники.ProcessLevels.TM)
			ИЛИ ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") И (ProcessLevel <> Справочники.ProcessLevels.AZ И ProcessLevel <> Справочники.ProcessLevels.TM) Тогда
			
			InvoiceLines.Очистить();
			
		КонецЕсли;
		
		SumCalculationMethod = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Service, "SumCalculationMethod");
		// } RGS ASeryakov 22.07.18:09:50 S-I-0005241
		
		Если SumCalculationMethod <> Перечисления.SumCalculationMethods.StandardTariff Тогда
			
			Qty = 0;
			Price = 0;
			
		КонецЕсли;
		
		Если SumCalculationMethod <> Перечисления.SumCalculationMethods.CostPlus Тогда 
				
			Base = 0;
			Percent = 0;
			Markup = 0;
			
		КонецЕсли;
		
	КонецЕсли;
	
	InvoiceLines.Свернуть("InvoiceLine", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(InvoiceLines, "InvoiceLine");
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаРеквизитовDocumentBase, МассивServicePorts)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли; 
		
	ДатаПолученияЦены = Неопределено;
		
	Если Не ВыборкаРеквизитовDocumentBase.Проведен Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'" + DocumentBase + "' is not posted!",
			ЭтотОбъект, "DocumentBase", , Отказ);
	КонецЕсли;
	
	Если ТипЗнч(DocumentBase) = Тип("ДокументСсылка.Поставка") Тогда
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.Port) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In the """ + DocumentBase + """ ""Actual POA"" is empty!",
				ЭтотОбъект, "DocumentBase", , Отказ);		
		КонецЕсли;
		
		ДатаПолученияЦены = ВыборкаРеквизитовDocumentBase.InCustoms;
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.InCustoms) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' 'In customs' is empty!",
				ЭтотОбъект, "DocumentBase", , Отказ);
				
		ИначеЕсли ВыборкаРеквизитовDocumentBase.InCustoms > Дата Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' In customs '" + Формат(ВыборкаРеквизитовDocumentBase.InCustoms, "ДЛФ=D") + "' is greater than Date '" + Формат(Дата, "ДЛФ=D") + "' of the current service!",
				ЭтотОбъект, "DocumentBase", , Отказ);
			
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(DocumentBase) = Тип("ДокументСсылка.ExportShipment") Тогда
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.Port) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' 'POD' is empty!",
				ЭтотОбъект, "DocumentBase", , Отказ);		
		КонецЕсли;
		
		ДатаПолученияЦены = ВыборкаРеквизитовDocumentBase.InCustoms;
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.InCustoms) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' 'Submitted to customs' is empty!",
				ЭтотОбъект, "DocumentBase", , Отказ);
				
		ИначеЕсли ВыборкаРеквизитовDocumentBase.InCustoms > Дата Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' Submitted to customs '" + Формат(ВыборкаРеквизитовDocumentBase.InCustoms, "ДЛФ=D") + "' is greater than Date '" + Формат(Дата, "ДЛФ=D") + "' of the current service!",
				ЭтотОбъект, "DocumentBase", , Отказ);
			
		КонецЕсли;	
		
	ИначеЕсли ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") 
		  ИЛИ ТипЗнч(DocumentBase) = Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
		
		ДатаПолученияЦены = ВыборкаРеквизитовDocumentBase.Дата;
		
		Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.Дата) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' 'Date' or 'Submitted to customs / In customs' (in shipment) is empty!",
				DocumentBase, "Date", , Отказ);
				
		ИначеЕсли ВыборкаРеквизитовDocumentBase.Дата > Дата Тогда 
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In '" + DocumentBase + "' Date '" + Формат(ВыборкаРеквизитовDocumentBase.Дата, "ДЛФ=D") + "' is greater than Date '" + Формат(Дата, "ДЛФ=D") + "' of the current service!",
				ЭтотОбъект, "DocumentBase", , Отказ);
			
		КонецЕсли;
		
		Если ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight")
			И РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "DutiesRecharge") Тогда
			
			Если ЗначениеЗаполнено(Agent) И ВыборкаРеквизитовDocumentBase.CCA <> Agent Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In '" + DocumentBase + "' the CCA '" + СокрЛП(ВыборкаРеквизитовDocumentBase.CCA) + "' differs from Agent '" + СокрЛП(Agent) + "' of the current service!",
					ЭтотОбъект, "DocumentBase", , Отказ);
			КонецЕсли;		
					
			Если НЕ ВыборкаРеквизитовDocumentBase.PaidByCCA Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"For 'Duties recharge' Service only 'Paid by CCA' Customs file is allowed!",
					ЭтотОбъект, "DocumentBase", , Отказ);
			КонецЕсли;	
				
		КонецЕсли; 
		
	КонецЕсли;
	// } RGS ASeryakov 01.12.2017 16:00:00 PM S-I-0004100
	//Если (ВыборкаРеквизитовDocumentBase.ProcessLevel = Справочники.ProcessLevels.KZ
	//	ИЛИ ВыборкаРеквизитовDocumentBase.ProcessLevel = Справочники.ProcessLevels.UZ) 
	//	И НЕ ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.TMSShipmentID) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//	"In the """ + DocumentBase + """ ""TMS Shipment ID"" is empty!",
	//	ЭтотОбъект, "DocumentBase", , Отказ);		
	//КонецЕсли;
		
	AllocationArea = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "AllocationArea");
					
	Если РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "AllocationMethod") = Перечисления.AllocationMethods.ByChargeableWeight
		И ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Для ТПО нельзя использовать сервисы с распределением пропорционально весу!",
			ЭтотОбъект, "Service", , Отказ);
		
	КонецЕсли;
	
	// Проверим, что указанный сервис можно использовать на Port, указанном в поставке
	Если (ТипЗнч(DocumentBase) = Тип("ДокументСсылка.Поставка") ИЛИ ТипЗнч(DocumentBase) = Тип("ДокументСсылка.ExportShipment"))
		И ЗначениеЗаполнено(ВыборкаРеквизитовDocumentBase.Port)
		И МассивServicePorts.Количество() > 0 Тогда
		
		МассивShipmentPorts = CustomsСерверПовтИсп.ПолучитьPortСРодителями(ВыборкаРеквизитовDocumentBase.Port);
		НайденыСовпадающиеPorts = Ложь;
		Для Каждого ShipmentPort Из МассивShipmentPorts Цикл
			Если МассивServicePorts.Найти(ShipmentPort) <> Неопределено Тогда
				НайденыСовпадающиеPorts = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если НЕ НайденыСовпадающиеPorts Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"You can not use Service '" + СокрЛП(Service) + "' in Port '" + СокрЛП(ВыборкаРеквизитовDocumentBase.Port) + "'!",
				ЭтотОбъект, "Service", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	SumCalculationMethod = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "SumCalculationMethod");
	
	// Проверим, что услуга находится в действующем прайс-листе
	ПроверитьЧтоУслугаЕстьВДействующемПрайсЛисте(Отказ, Service, SumCalculationMethod, Agent, ДатаПолученияЦены);
			
	Если AllocationArea = Перечисления.AllocationAreas.CCD
		И ТипЗнч(DocumentBase) <> Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		Если НЕ ЗначениеЗаполнено(CCD) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Customs file' is empty!",
				ЭтотОбъект, "CCD", , Отказ);
				
		Иначе
		
			ВыборкаРеквизитовCCD = ДополнительныеСвойства.ВыборкаРеквизитовCCD;
			
			Если НЕ ВыборкаРеквизитовCCD.Проведен Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'" + CCD + "' is not posted!",
					ЭтотОбъект, "CCD", , Отказ);
			КонецЕсли;
			
			Если ВыборкаРеквизитовCCD.Дата > Дата Тогда 	
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In '" + CCD + "' Date '" + Формат(ВыборкаРеквизитовCCD.Дата, "ДЛФ=D") + "' is greater than Date '" + Формат(Дата, "ДЛФ=D") + "' of the current service!",
					ЭтотОбъект, "CCD", , Отказ);	
			КонецЕсли;
			
			Если ВыборкаРеквизитовCCD.Shipment <> DocumentBase Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In '" + CCD + "' '" + ВыборкаРеквизитовCCD.Shipment + "' differs from the '" + DocumentBase + "' of the current service!",
					ЭтотОбъект, "CCD", , Отказ);
			КонецЕсли; 
			
			Если РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "DutiesRecharge") Тогда
				
				Если ВыборкаРеквизитовCCD.CCA <> Agent Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"In '" + CCD + "' the CCA '" + СокрЛП(ВыборкаРеквизитовCCD.CCA) + "' differs from Agent '" + СокрЛП(Agent) + "' of the current service!",
						ЭтотОбъект, "CCD", , Отказ);
				КонецЕсли;		
				
				Если НЕ ВыборкаРеквизитовCCD.PaidByCCA Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"For 'Duties recharge' Service only 'Paid by CCA' Customs file is allowed!",
						ЭтотОбъект, "CCD", , Отказ);
				КонецЕсли; 
				
			КонецЕсли; 
									
		КонецЕсли; 
		
	КонецЕсли;
		
	Если AllocationArea = Перечисления.AllocationAreas.InvoiceLines Тогда
		
		Если ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
			// { RGS ASeryakov, 22.07.18 08:29:20 S-I-0005241
			//ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			//"Для ТПО нельзя использвать сервис с распределением по строкам инвойса!",
			//ЭтотОбъект, "Service", , Отказ);
			
			ProcessLevel = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(DocumentBase, "ProcessLevel");
			
			Если ProcessLevel <> Справочники.ProcessLevels.AZ И ProcessLevel <> Справочники.ProcessLevels.TM Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				НСтр("ru = 'Для ТПО нельзя использвать сервис с распределением по строкам инвойса! За исключением стран: AZ, TM.';
					|en = 'For TPO, you can not use the service with the distribution of the invoice lines! With the exception of countries: AZ, TM.'"),
				ЭтотОбъект, "Service", , Отказ);
			КонецЕсли;
			// } RGS ASeryakov 22.07.18 08:29:20 S-I-0005241
		Иначе
			
			Если НЕ InvoiceLines.Количество() Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Table 'Invoice lines' is empty!",
					ЭтотОбъект, "InvoiceLines", , Отказ);
				
			Иначе
				
				Shipment = Неопределено;
				
				ТипЗнчDocumentBase = ТипЗнч(DocumentBase);
				Если ТипЗнчDocumentBase = Тип("ДокументСсылка.Поставка") 
					ИЛИ ТипЗнчDocumentBase = Тип("ДокументСсылка.ExportShipment") 
					ИЛИ ТипЗнчDocumentBase = Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
					Shipment = DocumentBase;
				ИначеЕсли ТипЗнчDocumentBase = Тип("ДокументСсылка.CustomsFilesLight") Тогда
					Shipment = ВыборкаРеквизитовDocumentBase.Shipment;
				КонецЕсли;
				
				Если ЗначениеЗаполнено(Shipment) Тогда
					
					ТипЗнчShipment = ТипЗнч(Shipment);
					Если ТипЗнчShipment = Тип("ДокументСсылка.Поставка") Тогда
						МассивShipmentItems = Документы.Поставка.ПолучитьМассивСтрокИнвойсовПоставки(Shipment);
					ИначеЕсли ТипЗнчShipment = Тип("ДокументСсылка.ExportShipment") Тогда
						МассивShipmentItems = Документы.ExportShipment.ПолучитьItemsOfExportShipment(Shipment);
					ИначеЕсли ТипЗнчShipment = Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
						МассивShipmentItems = Документы.TemporaryImpExpTransactions.ПолучитьItemsOfTemporaryImpExpTransactions(Shipment);
					КонецЕсли;
					
					Для каждого СтрокаТЧ ИЗ InvoiceLines Цикл
						
						Если МассивShipmentItems.Найти(СтрокаТЧ.InvoiceLine) = Неопределено Тогда
							ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
								"""Item " + СокрЛП(СтрокаТЧ.InvoiceLine) + """ does not belong to the current Shipment!",
								ЭтотОбъект, "InvoiceLines[" + (СтрокаТЧ.НомерСтроки - 1) + "].InvoiceLine", , Отказ);
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
				
	КонецЕсли;
		
	Если SumCalculationMethod = Перечисления.SumCalculationMethods.StandardTariff Тогда
		
		Если НЕ ЗначениеЗаполнено(Qty) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Qty"" is empty!",
				ЭтотОбъект, "Qty", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Price) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Price"" is empty!",
				ЭтотОбъект, "Price", , Отказ);
		КонецЕсли;	
				
	КонецЕсли;
		
	Если SumCalculationMethod = Перечисления.SumCalculationMethods.CostPlus Тогда 
		
		Если НЕ ЗначениеЗаполнено(Base) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Base"" is empty!",
				ЭтотОбъект, "Base", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Markup) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""Markup"" is empty!",
				ЭтотОбъект, "Markup", , Отказ);
		КонецЕсли; 
			
	КонецЕсли; 
						
КонецПроцедуры

Процедура ПроверитьЧтоУслугаЕстьВДействующемПрайсЛисте(Отказ, Service, SumCalculationMethod, Agent, ДатаПолученияЦены)
	
	Если НЕ ЗначениеЗаполнено(Service)
		ИЛИ НЕ ЗначениеЗаполнено(SumCalculationMethod)
		ИЛИ НЕ ЗначениеЗаполнено(Agent)
		ИЛИ НЕ ЗначениеЗаполнено(ДатаПолученияЦены) Тогда
		
		Возврат;
		
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Service", Service);
	Запрос.УстановитьПараметр("Agent", Agent);
	Запрос.УстановитьПараметр("ДатаПолученияЦены", ДатаПолученияЦены);
	
	Если SumCalculationMethod = Перечисления.SumCalculationMethods.StandardTariff Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Таблица.Service
			|ИЗ
			|	Документ.PriceListOfServices.StandardTariffs КАК Таблица
			|ГДЕ
			|	Таблица.Service = &Service
			|	И Таблица.StartDate <= &ДатаПолученияЦены
			|	И (Таблица.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.ExpireDate >= &ДатаПолученияЦены)
			|	И Таблица.Ссылка.Проведен
			|	И Таблица.Ссылка.Agent = &Agent
			|	И Таблица.Ссылка.Дата <= &ДатаПолученияЦены
			|	И (Таблица.Ссылка.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.Ссылка.ExpireDate >= &ДатаПолученияЦены)";
			
	ИначеЕсли SumCalculationMethod = Перечисления.SumCalculationMethods.CostPlus Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Таблица.Service
			|ИЗ
			|	Документ.PriceListOfServices.CostPlus КАК Таблица
			|ГДЕ
			|	Таблица.Service = &Service
			|	И Таблица.StartDate <= &ДатаПолученияЦены
			|	И (Таблица.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.ExpireDate >= &ДатаПолученияЦены)
			|	И Таблица.Ссылка.Проведен
			|	И Таблица.Ссылка.Agent = &Agent
			|	И Таблица.Ссылка.Дата <= &ДатаПолученияЦены
			|	И (Таблица.Ссылка.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.Ссылка.ExpireDate >= &ДатаПолученияЦены)";
			
	ИначеЕсли SumCalculationMethod = Перечисления.SumCalculationMethods.Quoted Тогда 
		
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	Таблица.Service
			|ИЗ
			|	Документ.PriceListOfServices.Quoted КАК Таблица
			|ГДЕ
			|	Таблица.Service = &Service
			|	И Таблица.StartDate <= &ДатаПолученияЦены
			|	И (Таблица.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.ExpireDate >= &ДатаПолученияЦены)
			|	И Таблица.Ссылка.Проведен
			|	И Таблица.Ссылка.Agent = &Agent
			|	И Таблица.Ссылка.Дата <= &ДатаПолученияЦены
			|	И (Таблица.Ссылка.ExpireDate = ДАТАВРЕМЯ(1, 1, 1)
			|			ИЛИ Таблица.Ссылка.ExpireDate >= &ДатаПолученияЦены)";
		
	КонецЕсли;
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Could not find price list for the: ""Service " + СокрЛП(Service) + """, ""Agent " + СокрЛП(Agent) + """, active on " + Формат(ДатаПолученияЦены, "ДЛФ=D") + "!",
			ЭтотОбъект, "Service");
			
		Если ДатаПолученияЦены >= '20111201' Тогда
			Отказ = Истина;
		КонецЕсли; 
		
	КонецЕсли; 
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоUnpaidCCDИлиНеоплаченнымТПО(Отказ);
		
КонецПроцедуры

Процедура ДвиженияПоUnpaidCCDИлиНеоплаченнымТПО(Отказ)
	
	ДвиженияПоUnpaidCCDs = Движения.UnpaidCCDs;
	ДвиженияПоUnpaidCCDs.Очистить();
		
	ДвиженияПоНеоплаченнымТПО = Движения.НеоплаченныеТПО;
	ДвиженияПоНеоплаченнымТПО.Очистить();
	
	Если НЕ РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "DutiesRecharge") Тогда
		
		ДвиженияПоUnpaidCCDs.Записывать = Истина;
		ДвиженияПоНеоплаченнымТПО.Записывать = Истина;
		Возврат;
		
	КонецЕсли; 
	
	SumCalculationMethod = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Service, "SumCalculationMethod");
	Если ТипЗнч(DocumentBase) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		ДобавитьИПроверитьДвиженияПоНеоплаченнымТПО(Отказ, SumCalculationMethod);
			
	Иначе
		
		ДобавитьИПроверитьДвиженияПоUnpaidCCDs(Отказ, SumCalculationMethod);
			
	КонецЕсли; 
	
КонецПроцедуры 

Процедура ДобавитьИПроверитьДвиженияПоНеоплаченнымТПО(Отказ, SumCalculationMethod)
	
	ДвиженияПоНеоплаченнымТПО = Движения.НеоплаченныеТПО;
	Движение = ДвиженияПоНеоплаченнымТПО.ДобавитьРасход();
	Движение.Период = Дата;
	Движение.ТПО = DocumentBase;
	Движение.Sum = GrandTotal;
	
	ДвиженияПоНеоплаченнымТПО.Записать();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТПО", DocumentBase);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НеоплаченныеТПООстатки.SumОстаток
		|ИЗ
		|	РегистрНакопления.НеоплаченныеТПО.Остатки(, ТПО = &ТПО) КАК НеоплаченныеТПООстатки
		|ГДЕ
		|	НеоплаченныеТПООстатки.SumОстаток < 0";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"" + Движение.Sum + " exceeds ТПО unpaid sum by " + (-Выборка.SumОстаток) + "!",
			ЭтотОбъект, "DocumentBase", , Отказ);
		
	КонецЕсли; 
	
КонецПроцедуры

Процедура ДобавитьИПроверитьДвиженияПоUnpaidCCDs(Отказ, SumCalculationMethod)
	
	ДвиженияПоUnpaidCCDs = Движения.UnpaidCCDs;
	Движение = ДвиженияПоUnpaidCCDs.ДобавитьРасход();
	Движение.Период = Дата;
	Движение.CCD = CCD;
	Движение.Sum = GrandTotal;
	
	ДвиженияПоUnpaidCCDs.Записать();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("CCD", CCD);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	UnpaidCCDsОстатки.SumОстаток
		|ИЗ
		|	РегистрНакопления.UnpaidCCDs.Остатки(, CCD = &CCD) КАК UnpaidCCDsОстатки
		|ГДЕ
		|	UnpaidCCDsОстатки.SumОстаток < 0";
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"" + Движение.Sum + " exceeds CCD unpaid sum by " + (-Выборка.SumОстаток) + "!",
			ЭтотОбъект, "CCD", , Отказ);
		
	КонецЕсли;
	
КонецПроцедуры
