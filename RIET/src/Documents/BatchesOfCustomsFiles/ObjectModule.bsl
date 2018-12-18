
//////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ТипЗнчДанныхЗаполнения = Тип("Структура") Тогда
		
		ДанныеЗаполнения.Свойство("Country", Country);
		ДанныеЗаполнения.Свойство("ProcessLevel", ProcessLevel);
		ДанныеЗаполнения.Свойство("SoldTo", SoldTo);
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Country) И ЗначениеЗаполнено(ProcessLevel) Тогда
		Country = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ProcessLevel, "Country");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(SoldTo) И ЗначениеЗаполнено(Country) Тогда
		SoldTo = ImportExportСерверПовтИспСеанс.ПолучитьLegalEntityOfCountry(Country);
	КонецЕсли;

КонецПроцедуры


//////////////////////////////////////////////////////////////////
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
	
	ПоместитьВДополнительныеСвойстваДополнительныеДанныеПередЗаписью(РежимЗаписи);
		
	ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи);
			
КонецПроцедуры

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
		
	Comment = СокрЛП(Comment);
	
	CCDs.Свернуть("CCD", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CCDs, "CCD");

	ТПО.Свернуть("ТПО", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(ТПО, "ТПО");
	
	CustomsFilesOfTemporaryImportExport.Свернуть("CustomsFile", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CustomsFilesOfTemporaryImportExport, "CustomsFile");
	
	CustomsBonds.Свернуть("CustomsBond", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CustomsBonds, "CustomsBond");
	
	CustomsBondClosings.Свернуть("CustomsBondClosing", "");
	ОбщегоНазначения.ОчиститьТаблицуОтСтрокСПустымиРеквизитами(CustomsBondClosings, "CustomsBondClosing");
	
КонецПроцедуры

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			ЭтотОбъект, "Country", , Отказ);	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ProcessLevel) Тогда
		
		ProcessLevelCountry = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ProcessLevel, "Country");
		Если ProcessLevelCountry <> Country Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Country '" + СокрЛП(ProcessLevelCountry) + "' of Process level differs from Country '" + СокрЛП(Country) + "' of the Batch!",
				ЭтотОбъект, "ProcessLevel", , Отказ);
		КонецЕсли;
		
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			ЭтотОбъект, "ProcessLevel", , Отказ);	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(SoldTo) Тогда
		
		ParentCompanyCountry = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(SoldTo, "Country");
		Если ParentCompanyCountry <> Country Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Country '" + СокрЛП(ParentCompanyCountry) + "' of Legal entity differs from Country '" + СокрЛП(Country) + "' of the Batch!",
				ЭтотОбъект, "SoldTo", , Отказ);
		КонецЕсли;
		
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			ЭтотОбъект, "SoldTo", , Отказ);	
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если Дата > ТекущаяДата() + 8 * 60 * 60 Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' can not be later than the current date!",
			ЭтотОбъект, "Дата", , Отказ);		
	КонецЕсли;
	
	Если CCDs.Количество() = 0 И ТПО.Количество() = 0 И CustomsFilesOfTemporaryImportExport.Количество() = 0 
		И CustomsBonds.Количество() = 0 И CustomsBondClosings.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Tables are empty!",
			ЭтотОбъект, , , Отказ);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПоместитьВДополнительныеСвойстваДополнительныеДанныеПередЗаписью(РежимЗаписи)
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		// реквизиты Customs files
		AllCustomsFiles = CCDs.ВыгрузитьКолонку("CCD");
		AllCustomsFiles = РГСофтКлиентСервер.СложитьМассивы(AllCustomsFiles, CustomsFilesOfTemporaryImportExport.ВыгрузитьКолонку("CustomsFile"));
		Если AllCustomsFiles.Количество() Тогда
			
			СтруктураПараметров.Вставить("AllCustomsFiles", AllCustomsFiles);	
			СтруктураТекстов.Вставить("РеквизитыCustomsFiles",
				"ВЫБРАТЬ
				|	CustomsFiles.Ссылка КАК CustomsFile,
				|	CustomsFiles.Проведен,
				|	CustomsFiles.Дата,
				|	CustomsFiles.ProcessLevel,
				|	CustomsFiles.SoldTo КАК ParentCompany,
				|	CustomsFiles.CustomsPost.Customs КАК Customs,
				|	CustomsFiles.CustomsPost.Customs.LawsonContractor КАК LawsonContractor,
				|	CustomsFiles.Shipment,
				|	InvoiceLinesMatchings.Ссылка КАК InvoiceLinesMatching
				|ИЗ
				|	Документ.ГТД КАК CustomsFiles
				|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗакрытиеПоставки КАК InvoiceLinesMatchings
				|		ПО CustomsFiles.Shipment = InvoiceLinesMatchings.Поставка
				|			И (CustomsFiles.Проведен)
				|ГДЕ
				|	CustomsFiles.Ссылка В(&AllCustomsFiles)");
	
		КонецЕсли;
		
		// реквизиты Customs files light
		AllCustomsFilesLight = ТПО.ВыгрузитьКолонку("ТПО");
		AllCustomsFilesLight = РГСофтКлиентСервер.СложитьМассивы(AllCustomsFilesLight, CustomsBonds.ВыгрузитьКолонку("CustomsBond"));
		AllCustomsFilesLight = РГСофтКлиентСервер.СложитьМассивы(AllCustomsFilesLight, CustomsBondClosings.ВыгрузитьКолонку("CustomsBondClosing"));
		Если AllCustomsFilesLight.Количество() Тогда
			
			СтруктураПараметров.Вставить("AllCustomsFilesLight", AllCustomsFilesLight);	
			СтруктураТекстов.Вставить("РеквизитыCustomsFilesLight",
				"ВЫБРАТЬ
				|	CustomsFilesLight.Ссылка КАК CustomsFileLight,
				|	CustomsFilesLight.Проведен,
				|	CustomsFilesLight.Дата,
				|	CustomsFilesLight.ProcessLevel,
				|	CustomsFilesLight.SoldTo КАК ParentCompany,
				|	CustomsFilesLight.CustomsPost.Customs КАК Customs,
				|	CustomsFilesLight.CustomsPost.Customs.LawsonContractor КАК LawsonContractor,
				|	CustomsFilesLight.TypeOfTransaction,
				|	""InvoiceLinesMatching"" КАК InvoiceLinesMatching
				|ИЗ
				|	Документ.CustomsFilesLight КАК CustomsFilesLight
				|ГДЕ
				|	CustomsFilesLight.Ссылка В(&AllCustomsFilesLight)");
		
		КонецЕсли;
		
		СтруктураПараметров.Вставить("Ссылка", Ссылка);
		
		// дубли по Customs files
		Если CCDs.Количество() > 0 Тогда
			
			СтруктураПараметров.Вставить("CustomsFiles", CCDs.ВыгрузитьКолонку("CCD"));
			СтруктураТекстов.Вставить("CustomsFilesInOtherBatches",
				"ВЫБРАТЬ
				|	BatchesOfCustomsFilesCustomsFiles.CCD,
				|	BatchesOfCustomsFilesCustomsFiles.Ссылка.Представление КАК BatchOfCustomsFilesПредставление
				|ИЗ
				|	Документ.BatchesOfCustomsFiles.CCDs КАК BatchesOfCustomsFilesCustomsFiles
				|ГДЕ
				|	BatchesOfCustomsFilesCustomsFiles.Ссылка <> &Ссылка
				|	И НЕ BatchesOfCustomsFilesCustomsFiles.Ссылка.ПометкаУдаления
				|	И BatchesOfCustomsFilesCustomsFiles.CCD В(&CustomsFiles)");
			
		КонецЕсли;
		
		// дубли по Customs files of temporary imp. / exp.
		Если CustomsFilesOfTemporaryImportExport.Количество() > 0 Тогда
				
			СтруктураПараметров.Вставить("CustomsFilesOfTemporaryImportExport", CustomsFilesOfTemporaryImportExport.ВыгрузитьКолонку("CustomsFile"));			
			СтруктураТекстов.Вставить("CustomsFilesOfTemporaryImportExportInOtherBatches",
				"ВЫБРАТЬ
				|	BatchesOfCustomsFilesCustomsFiles.CustomsFile,
				|	BatchesOfCustomsFilesCustomsFiles.Ссылка.Представление КАК BatchOfCustomsFilesПредставление
				|ИЗ
				|	Документ.BatchesOfCustomsFiles.CustomsFilesOfTemporaryImportExport КАК BatchesOfCustomsFilesCustomsFiles
				|ГДЕ
				|	BatchesOfCustomsFilesCustomsFiles.Ссылка <> &Ссылка
				|	И НЕ BatchesOfCustomsFilesCustomsFiles.Ссылка.ПометкаУдаления
				|	И BatchesOfCustomsFilesCustomsFiles.CustomsFile В(&CustomsFilesOfTemporaryImportExport)");
			
		КонецЕсли;

		// дубли по Customs receipt orders
		Если ТПО.Количество() > 0 Тогда
				
			СтруктураПараметров.Вставить("CustomsReceiptOrders", ТПО.ВыгрузитьКолонку("ТПО"));		
			СтруктураТекстов.Вставить("CustomsReceiptOrdersInOtherBatches",
				"ВЫБРАТЬ
				|	BatchesOfCustomsFilesCustomsReceiptOrders.ТПО,
				|	BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка.Представление КАК BatchOfCustomsFilesПредставление
				|ИЗ
				|	Документ.BatchesOfCustomsFiles.ТПО КАК BatchesOfCustomsFilesCustomsReceiptOrders
				|ГДЕ
				|	BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка <> &Ссылка
				|	И НЕ BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка.ПометкаУдаления
				|	И BatchesOfCustomsFilesCustomsReceiptOrders.ТПО В(&CustomsReceiptOrders)");
			
		КонецЕсли;
		
		// дубли по Customs bonds
		Если CustomsBonds.Количество() > 0 Тогда
				
			СтруктураПараметров.Вставить("CustomsBonds", CustomsBonds.ВыгрузитьКолонку("CustomsBond"));				
			СтруктураТекстов.Вставить("CustomsBondsInOtherBatches",
				"ВЫБРАТЬ
				|	BatchesOfCustomsFilesCustomsBonds.CustomsBond,
				|	BatchesOfCustomsFilesCustomsBonds.Ссылка.Представление КАК BatchOfCustomsFilesПредставление
				|ИЗ
				|	Документ.BatchesOfCustomsFiles.CustomsBonds КАК BatchesOfCustomsFilesCustomsBonds
				|ГДЕ
				|	BatchesOfCustomsFilesCustomsBonds.Ссылка <> &Ссылка
				|	И НЕ BatchesOfCustomsFilesCustomsBonds.Ссылка.ПометкаУдаления
				|	И BatchesOfCustomsFilesCustomsBonds.CustomsBond В(&CustomsBonds)");
			
		КонецЕсли;

		// дубли по Customs bond closings
		Если CustomsBondClosings.Количество() > 0 Тогда
				
			СтруктураПараметров.Вставить("CustomsBondClosings", CustomsBondClosings.ВыгрузитьКолонку("CustomsBondClosing"));				
			СтруктураТекстов.Вставить("CustomsBondClosingsInOtherBatches",
				"ВЫБРАТЬ
				|	BatchesOfCustomsFilesCustomsBondClosings.CustomsBondClosing,
				|	BatchesOfCustomsFilesCustomsBondClosings.Ссылка.Представление КАК BatchOfCustomsFilesПредставление
				|ИЗ
				|	Документ.BatchesOfCustomsFiles.CustomsBondClosings КАК BatchesOfCustomsFilesCustomsBondClosings
				|ГДЕ
				|	BatchesOfCustomsFilesCustomsBondClosings.Ссылка <> &Ссылка
				|	И НЕ BatchesOfCustomsFilesCustomsBondClosings.Ссылка.ПометкаУдаления
				|	И BatchesOfCustomsFilesCustomsBondClosings.CustomsBondClosing В(&CustomsBondClosings)");
			
		КонецЕсли;

	КонецЕсли; 	
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ТаблицаРеквизитовCustomsFiles", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFiles") Тогда
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles = СтруктураРезультатов.РеквизитыCustomsFiles.Выгрузить();
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles.Индексы.Добавить("CustomsFile");
	КонецЕсли;

	ДополнительныеСвойства.Вставить("ТаблицаРеквизитовCustomsFilesLight", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFilesLight") Тогда
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight = СтруктураРезультатов.РеквизитыCustomsFilesLight.Выгрузить();
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight.Индексы.Добавить("CustomsFileLight");
	КонецЕсли;

	ДополнительныеСвойства.Вставить("ТаблицаCustomsFilesInOtherBatches", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsFilesInOtherBatches") Тогда
		ДополнительныеСвойства.ТаблицаCustomsFilesInOtherBatches = СтруктураРезультатов.CustomsFilesInOtherBatches.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsFilesInOtherBatches.Индексы.Добавить("CCD");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsFilesOfTemporaryImportExportInOtherBatches", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsFilesOfTemporaryImportExportInOtherBatches") Тогда
		ДополнительныеСвойства.ТаблицаCustomsFilesOfTemporaryImportExportInOtherBatches = СтруктураРезультатов.CustomsFilesOfTemporaryImportExportInOtherBatches.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsFilesOfTemporaryImportExportInOtherBatches.Индексы.Добавить("CustomsFile");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsReceiptOrdersInOtherBatches", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsReceiptOrdersInOtherBatches") Тогда
		ДополнительныеСвойства.ТаблицаCustomsReceiptOrdersInOtherBatches = СтруктураРезультатов.CustomsReceiptOrdersInOtherBatches.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsReceiptOrdersInOtherBatches.Индексы.Добавить("ТПО");
	КонецЕсли;	
          	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsBondsInOtherBatches", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsBondsInOtherBatches") Тогда
		ДополнительныеСвойства.ТаблицаCustomsBondsInOtherBatches = СтруктураРезультатов.CustomsBondsInOtherBatches.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsBondsInOtherBatches.Индексы.Добавить("CustomsBond");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаCustomsBondClosingsInOtherBatches", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsBondClosingsInOtherBatches") Тогда
		ДополнительныеСвойства.ТаблицаCustomsBondClosingsInOtherBatches = СтруктураРезультатов.CustomsBondClosingsInOtherBatches.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsBondClosingsInOtherBatches.Индексы.Добавить("CustomsBondClosing");
	КонецЕсли;     

КонецПроцедуры

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли; 
	
	// Customs files
	ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, 
		"CCDs", "Customs files", "CCD", "Customs file",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles, "CustomsFile",
		ДополнительныеСвойства.ТаблицаCustomsFilesInOtherBatches);
		
	// дополнительные проверки Customs files
	Для Каждого СтрокаТЧ Из CCDs Цикл
		
		РеквизитыCustomsFile = ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles.Найти(СтрокаТЧ.CCD, "CustomsFile");
		
		// проверим, что реквизит Shipment - это импортная или экспортная поставка
		Если ТипЗнч(РеквизитыCustomsFile.Shipment) <> Тип("ДокументСсылка.Поставка")
			И ТипЗнч(РеквизитыCustomsFile.Shipment) <> Тип("ДокументСсылка.ExportShipment") Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + " of Customs files: Customs file is not for Import or Export shipment!",
				ЭтотОбъект, "CCDs[" + (СтрокаТЧ.НомерСтроки-1) + "].CCD", , Отказ);
			
		КонецЕсли;
		
	КонецЦикла;
			
	// Customs files of Temp. imp. / exp.
	ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, 
		"CustomsFilesOfTemporaryImportExport", "Customs files of temp. imp./exp.", "CustomsFile", "Customs file",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles, "CustomsFile",
		ДополнительныеСвойства.ТаблицаCustomsFilesOfTemporaryImportExportInOtherBatches);
		
	// дополнительные проверки Customs files of Temp. imp. / exp.
	Для Каждого СтрокаТЧ Из CustomsFilesOfTemporaryImportExport Цикл
		
		РеквизитыCustomsFile = ДополнительныеСвойства.ТаблицаРеквизитовCustomsFiles.Найти(СтрокаТЧ.CustomsFile, "CustomsFile");
		
		// проверим, что реквизит Shipment - Temp. imp. / exp. transaction
		Если ТипЗнч(РеквизитыCustomsFile.Shipment) <> Тип("ДокументСсылка.TemporaryImpExpTransactions") Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + " of Customs files: Customs file is not for Temp. imp. / exp. transaction!",
				ЭтотОбъект, "CustomsFilesOfTemporaryImportExport[" + (СтрокаТЧ.НомерСтроки-1) + "].CustomsFile", , Отказ);
			
		КонецЕсли;
		
	КонецЦикла;	
		
	// ТПО
	ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, 
		"ТПО", "Customs receipt orders", "ТПО", "Customs receipt order",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight, "CustomsFileLight",
		ДополнительныеСвойства.ТаблицаCustomsReceiptOrdersInOtherBatches);
		
	ПроверитьTypeOfTransactionВТЧ(Отказ, 
		"ТПО", "Customs receipt orders", "ТПО", "Customs receipt order",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight,
		Перечисления.TypesOfCustomsFileLightTransaction.ТПО);	
		
	// Customs bonds
	ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, 
		"CustomsBonds", "Customs bonds", "CustomsBond", "Customs bond",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight, "CustomsFileLight",
		ДополнительныеСвойства.ТаблицаCustomsBondsInOtherBatches);

	ПроверитьTypeOfTransactionВТЧ(Отказ, 
		"CustomsBonds", "Customs bonds", "CustomsBond", "Customs bond",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight,
		Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond);	
		
	// Customs bonds closing
	ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, 
		"CustomsBondClosings", "Customs bond closings", "CustomsBondClosing", "Customs bond closing",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight, "CustomsFileLight",
		ДополнительныеСвойства.ТаблицаCustomsBondClosingsInOtherBatches);
		
	ПроверитьTypeOfTransactionВТЧ(Отказ, 
		"CustomsBondClosings", "Customs bond closings", "CustomsBondClosing", "Customs bond closing",
		ДополнительныеСвойства.ТаблицаРеквизитовCustomsFilesLight,
		Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing);
		
КонецПроцедуры
	
Процедура ПроверитьРеквизитыТЧСДополнительнымиДанными(Отказ, ИмяТЧ, СинонимТЧ, ИмяРеквизитаТЧ, СинонимРеквизитаТЧ, 
																  ТаблицаРеквизитов, ИмяКолонкиТаблицыРеквизитов, ТаблицаInOtherBatches)
	   			
	Для Каждого СтрокаТЧ Из ЭтотОбъект[ИмяТЧ] Цикл        
			
		Реквизиты = ТаблицаРеквизитов.Найти(СтрокаТЧ[ИмяРеквизитаТЧ], ИмяКолонкиТаблицыРеквизитов);	
		ПрефиксОшибки = "In line " + СтрокаТЧ.НомерСтроки + " of " + СинонимТЧ + ": ";
		Поле = ИмяТЧ + "[" + (СтрокаТЧ.НомерСтроки-1) + "]." + ИмяРеквизитаТЧ;
		
		Если НЕ Реквизиты.Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + СинонимРеквизитаТЧ + " is not posted!",
				ЭтотОбъект, Поле, , Отказ);
		КонецЕсли; 
		
		Если Реквизиты.Дата > Дата Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + "Date " + Формат(Реквизиты.Дата, "ДЛФ=D") + " of " + СинонимРеквизитаТЧ + " is later than the date of the Batch!",
				ЭтотОбъект, Поле, , Отказ);	
		КонецЕсли;
		
		Если Реквизиты.ProcessLevel <> ProcessLevel Тогда   
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + "Process level '" + СокрЛП(Реквизиты.ProcessLevel) + "' of " + СинонимРеквизитаТЧ + " differs from Process level the Batch!",
				ЭтотОбъект, Поле, , Отказ);	
		КонецЕсли;
		
		Если Реквизиты.ParentCompany <> SoldTo Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + "Parent company " + СокрЛП(Реквизиты.ParentCompany) + " of " + СинонимРеквизитаТЧ + " differs from Parent company of the Batch!",
				ЭтотОбъект, Поле, , Отказ);	
		КонецЕсли; 
			
		Если НЕ ЗначениеЗаполнено(Реквизиты.InvoiceLinesMatching) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + "Invoice lines matching not found!",
				ЭтотОбъект, Поле, , Отказ);							
		КонецЕсли;

		Если НЕ ЗначениеЗаполнено(Реквизиты.LawsonContractor) Тогда	
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + "Lawson contractor is not defined for Customs '" + СокрЛП(Реквизиты.Customs) + "'!",
				ЭтотОбъект, Поле, , Отказ);	
		КонецЕсли;
		
		СтрокаТаблицыInOtherBatches = ТаблицаInOtherBatches.Найти(СтрокаТЧ[ИмяРеквизитаТЧ], ИмяРеквизитаТЧ);
		Если СтрокаТаблицыInOtherBatches <> Неопределено Тогда				
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ПрефиксОшибки + СинонимРеквизитаТЧ + " is already in the " + СтрокаТаблицыInOtherBatches.BatchOfCustomsFilesПредставление + "!",
				ЭтотОбъект, Поле, , Отказ);			
		КонецЕсли;

	КонецЦикла; 		
			
КонецПроцедуры

Процедура ПроверитьTypeOfTransactionВТЧ(Отказ, ИмяТЧ, СинонимТЧ, ИмяРеквизитаТЧ, СинонимРеквизитаТЧ, ТаблицаРеквизитов, TypeOfTransaction)
	
	Для Каждого СтрокаТЧ Из ЭтотОбъект[ИмяТЧ] Цикл
		
		Реквизиты = ТаблицаРеквизитов.Найти(СтрокаТЧ[ИмяРеквизитаТЧ], "CustomsFileLight");
		
		Если Реквизиты.TypeOfTransaction <> TypeOfTransaction Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + " of " + СинонимТЧ + ": the document is not " + TypeOfTransaction + "!",
				ЭтотОбъект, ИмяРеквизитаТЧ + "[" + (СтрокаТЧ.НомерСтроки-1) + "]." + ИмяРеквизитаТЧ, , Отказ);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры
