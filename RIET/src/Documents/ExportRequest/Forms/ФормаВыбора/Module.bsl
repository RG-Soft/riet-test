
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
   Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзExportShipment" Тогда
			НастроитьДляВыбораИзExportShipment(СтруктураНастройки);
		КонецЕсли;
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзTDStatuses" Тогда
			НастроитьДляВыбораИзTDStatuses(СтруктураНастройки);
		КонецЕсли;

	КонецЕсли;
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("Canceled", Ложь);
	
	ImportExportСервер.ДобавитьОтборПоProcessLevelПриНеобходимости(Отбор, "ProcessLevel");

КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзExportShipment(СтруктураНастройки) 
	
	Отбор = Параметры.Отбор;
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		Список.Отбор,
		"AcceptedBySpecialist",,
		ВидСравненияКомпоновкиДанных.Заполнено,	, 
		Истина);
		
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		Список.Отбор,
		"CustomUnionTransaction",
		СтруктураНастройки.CustomUnionTransaction,
		ВидСравненияКомпоновкиДанных.Равно,	, 
		Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("CurrentExportShipment", СтруктураНастройки.ExportShipment);
	Запрос.УстановитьПараметр("CurrentExportRequests", СтруктураНастройки.ExportRequests);
	Запрос.УстановитьПараметр("CustomUnionTransaction", СтруктураНастройки.CustomUnionTransaction);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ExportRequests.Ссылка
		|ИЗ
		|	Документ.ExportRequest КАК ExportRequests
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
		|		ПО ExportRequests.Ссылка = ExportShipmentExportRequests.ExportRequest
		|			И (НЕ ExportShipmentExportRequests.Ссылка.ПометкаУдаления)
		|			И (ExportShipmentExportRequests.Ссылка <> &CurrentExportShipment)
		|ГДЕ
		|	НЕ ExportRequests.Canceled
		|	И НЕ ExportRequests.Ссылка В (&CurrentExportRequests)
		|	И ExportShipmentExportRequests.Ссылка ЕСТЬ NULL 
		|	И ExportRequests.CustomUnionTransaction = &CustomUnionTransaction";	
	
	Если Не СтруктураНастройки.CustomUnionTransaction И ЗначениеЗаполнено(СтруктураНастройки.CCA) Тогда 
		
		МассивCCA = Новый Массив;
		МассивCCA.Добавить(СтруктураНастройки.CCA);
		МассивCCA.Добавить(Справочники.Agents.ПустаяСсылка());
		Отбор.Вставить("CCA", МассивCCA);
		
		Запрос.УстановитьПараметр("CCAs", МассивCCA);
		Запрос.Текст = Запрос.Текст + "
			|	И ExportRequests.CCA В (&CCAs)";
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураНастройки.InternationalFreightProvider) Тогда 
		
		МассивFreightProviders = Новый Массив;
		МассивFreightProviders.Добавить(СтруктураНастройки.InternationalFreightProvider);
		МассивFreightProviders.Добавить(Справочники.FreightForwarders.ПустаяСсылка());
		Отбор.Вставить("InternationalFreightProvider", МассивFreightProviders);
		
		Запрос.УстановитьПараметр("FreightAgents", МассивFreightProviders);
		Запрос.Текст = Запрос.Текст + "
			|	И ExportRequests.InternationalFreightProvider В (&FreightAgents)";
		
	КонецЕсли;

	Если Не СтруктураНастройки.CustomUnionTransaction И ЗначениеЗаполнено(СтруктураНастройки.POD) Тогда 
		
		МассивPOD = Новый Массив;
		МассивPOD.Добавить(СтруктураНастройки.POD);
		МассивPOD.Добавить(Справочники.SeaAndAirPorts.ПустаяСсылка());
		Отбор.Вставить("POD", МассивPOD);
		
		Запрос.УстановитьПараметр("PODs", МассивPOD);
		Запрос.Текст = Запрос.Текст + "
			|	И ExportRequests.POD В (&PODs)";
		
	КонецЕсли;

	Если ЗначениеЗаполнено(СтруктураНастройки.POA) Тогда 
		
		МассивPOA = Новый Массив;
		МассивPOA.Добавить(СтруктураНастройки.POA);
		МассивPOA.Добавить(Справочники.CountriesHUBs.ПустаяСсылка());
		Отбор.Вставить("POA", МассивPOA);
		
		Запрос.УстановитьПараметр("POAs", МассивPOA);
		Запрос.Текст = Запрос.Текст + "
			|	И ExportRequests.POA В (&POAs)";
		
	КонецЕсли;
		
	Если ЗначениеЗаполнено(СтруктураНастройки.InternationalMOT) Тогда 
		
		МассивMOT = Новый Массив;
		МассивMOT.Добавить(СтруктураНастройки.InternationalMOT);
		МассивMOT.Добавить(Справочники.MOTs.ПустаяСсылка());
		Отбор.Вставить("InternationalMOT", МассивMOT);
		
		Запрос.УстановитьПараметр("MOTs", МассивMOT);
		Запрос.Текст = Запрос.Текст + "
			|	И ExportRequests.InternationalMOT В (&MOTs)";
		
	КонецЕсли;
	
	ВозможныеExportRequests = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	Отбор.Вставить("Ссылка", ВозможныеExportRequests);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	Если СтруктураНастройки <> Неопределено
		И СтруктураНастройки.Имя = "ВыборИзExportShipment" Тогда
		
		Отказ = Ложь;
		ПроверитьВыбранныеExportRequestsДляExportShipment(Отказ, Значение);
		СтандартнаяОбработка = Не Отказ; 
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВыбранныеExportRequestsДляExportShipment(Отказ, МассивЗначений)
	
	// Проверим, что в выбранных Export requests заполненные реквизиты соответствуют переданным в форму выбора
	// А если какие-то переданные реквизиты - пустые - проверим, что они совпадают у выбранных Export requests
	СтрокаСвойств = "CCA, InternationalFreightProvider, POD, POA, InternationalMOT, CustomUnionTransaction";
	
	СтруктураТребуемыхЗначений = Новый Структура(СтрокаСвойств);
	ЗаполнитьЗначенияСвойств(СтруктураТребуемыхЗначений, СтруктураНастройки, СтрокаСвойств);
	
	Для Каждого ExportRequest Из МассивЗначений Цикл 
		
		ДанныеExportRequest = Элементы.Список.ДанныеСтроки(ExportRequest);
		
		Для Каждого ЭлементСтруктуры Из СтруктураТребуемыхЗначений Цикл 
			
			Если ЗначениеЗаполнено(ДанныеExportRequest[ЭлементСтруктуры.Ключ]) Тогда 
				
				Если ЗначениеЗаполнено(ЭлементСтруктуры.Значение) Тогда
					
					Если ЭлементСтруктуры.Значение <> ДанныеExportRequest[ЭлементСтруктуры.Ключ] Тогда 
					
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
							"""" + ЭлементСтруктуры.Ключ + " " + СокрЛП(ДанныеExportRequest[ЭлементСтруктуры.Ключ]) + """ of """ + ExportRequest + """ differs from required """ + ЭлементСтруктуры.Ключ + " " + СокрЛП(ЭлементСтруктуры.Значение) + """!",
							, , , Отказ);
							
					КонецЕсли;
					
				Иначе
					
					СтруктураТребуемыхЗначений[ЭлементСтруктуры.Ключ] = ДанныеExportRequest[ЭлементСтруктуры.Ключ];
					
				КонецЕсли;
																
			Иначе	
				
				Если ДанныеExportRequest.CustomUnionTransaction 
					И (ЭлементСтруктуры.Ключ = "CCA" ИЛИ ЭлементСтруктуры.Ключ = "POD") Тогда 
					Продолжить;
				КонецЕсли;	
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"""" + ЭлементСтруктуры.Ключ + """ is empty in """ + ExportRequest + """!",
					ExportRequest, ЭлементСтруктуры.Ключ, , Отказ);
				
	                 					
			КонецЕсли;
		
		КонецЦикла;
		
	КонецЦикла;	
			
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзTDStatuses(СтруктураНастройки) 
	
	Отбор = Параметры.Отбор;
	
	Запрос = Новый Запрос;
	// { RGS AArsentev 17.05.2018
	//Запрос.УстановитьПараметр("PartNumber", СтруктураНастройки.PartNumber);
	Запрос.УстановитьПараметр("PartNumbers", СтруктураНастройки.PartNumbers);
	// } RGS AArsentev 17.05.2018
	
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	СтрокиИнвойса.ExportRequest КАК ExportRequest
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
		|		ПО СтрокиИнвойса.ExportRequest = ExportShipmentExportRequests.ExportRequest
		|			И (НЕ ExportShipmentExportRequests.Ссылка.ПометкаУдаления)
		|ГДЕ
		|	СтрокиИнвойса.ExportRequest <> ЗНАЧЕНИЕ(Документ.ExportRequest.ПустаяСсылка)
		// { RGS AArsentev 17.05.2018
		//|	И СтрокиИнвойса.КодПоИнвойсу = &PartNumber
		// } RGS AArsentev 17.05.2018
		|	И СтрокиИнвойса.КодПоИнвойсу В (&PartNumbers)
		|	И ExportShipmentExportRequests.Ссылка ЕСТЬ NULL
		|	И НЕ СтрокиИнвойса.ПометкаУдаления";	
		
	ВозможныеExportRequests = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ExportRequest");
	
	Отбор.Вставить("Ссылка", ВозможныеExportRequests);
	
КонецПроцедуры
