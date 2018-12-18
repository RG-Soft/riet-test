
// ДОДЕЛАТЬ
Функция ПолучитьReadyCustomsFiles(Дата, ProcessLevel, ParentCompany, CurrentCustomsFiles, CurrentBatch) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel); 
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("CurrentCustomsFiles", CurrentCustomsFiles);
	Запрос.УстановитьПараметр("CurrentBatch", CurrentBatch);
	
	// ПАХНЕТ ТАК, КАК БУДТО ЗДЕСЬ НУЖЕН РЕГИСТР НАКОПЛЕНИЯ
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	CustomsFiles.Ссылка КАК CustomsFile
		|ИЗ
		|	Документ.ГТД КАК CustomsFiles
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗакрытиеПоставки КАК InvoiceLinesMatchings
		|		ПО CustomsFiles.Shipment = InvoiceLinesMatchings.Поставка
		|			И (InvoiceLinesMatchings.Проведен)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BatchesOfCustomsFiles.CCDs КАК BatchesOfCustomsFilesCustomsFiles
		|		ПО CustomsFiles.Ссылка = BatchesOfCustomsFilesCustomsFiles.CCD
		|			И (НЕ BatchesOfCustomsFilesCustomsFiles.Ссылка.ПометкаУдаления)
		|			И (НЕ BatchesOfCustomsFilesCustomsFiles.Ссылка = &CurrentBatch)
		|ГДЕ
		|	CustomsFiles.ДатаВыпуска <= &Дата
		|	И CustomsFiles.ProcessLevel = &ProcessLevel
		|	И CustomsFiles.SoldTo = &ParentCompany
		|	И (CustomsFiles.Shipment ССЫЛКА Документ.Поставка
		|			ИЛИ CustomsFiles.Shipment ССЫЛКА Документ.ExportShipment)
		|	И CustomsFiles.Проведен
		|	И НЕ CustomsFiles.Ссылка В (&CurrentCustomsFiles)
		|	И BatchesOfCustomsFilesCustomsFiles.CCD ЕСТЬ NULL";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsFile");
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьReadyCustomsFilesOfTempImpExp(Дата, ProcessLevel, ParentCompany, CurrentCustomsFilesOfTempImpExp, CurrentBatch) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel); 
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("CurrentCustomsFilesOfTempImpExp", CurrentCustomsFilesOfTempImpExp);
	Запрос.УстановитьПараметр("CurrentBatch", CurrentBatch);
	
	// ПАХНЕТ ТАК, КАК БУДТО ЗДЕСЬ НУЖЕН РЕГИСТР НАКОПЛЕНИЯ
	Запрос.Текст =
		"ВЫБРАТЬ
		|	CustomsFiles.Ссылка КАК CustomsFile
		|ИЗ
		|	Документ.ГТД КАК CustomsFiles
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗакрытиеПоставки КАК InvoiceLinesMatchings
		|		ПО CustomsFiles.Shipment = InvoiceLinesMatchings.Поставка
		|			И (InvoiceLinesMatchings.Проведен)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BatchesOfCustomsFiles.CustomsFilesOfTemporaryImportExport КАК BatchesOfCustomsFilesCustomsFilesOfTempImpExp
		|		ПО CustomsFiles.Ссылка = BatchesOfCustomsFilesCustomsFilesOfTempImpExp.CustomsFile
		|			И (НЕ BatchesOfCustomsFilesCustomsFilesOfTempImpExp.Ссылка.ПометкаУдаления)
		|			И (НЕ BatchesOfCustomsFilesCustomsFilesOfTempImpExp.Ссылка = &CurrentBatch)
		|ГДЕ
		|	CustomsFiles.ДатаВыпуска <= &Дата
		|	И CustomsFiles.ProcessLevel = &ProcessLevel
		|	И CustomsFiles.SoldTo = &ParentCompany
		|	И CustomsFiles.Shipment ССЫЛКА Документ.TemporaryImpExpTransactions
		|	И CustomsFiles.Проведен
		|	И НЕ CustomsFiles.Ссылка В (&CurrentCustomsFilesOfTempImpExp)
		|	И BatchesOfCustomsFilesCustomsFilesOfTempImpExp.CustomsFile ЕСТЬ NULL ";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsFile");
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьReadyCustomsReceiptOrders(Дата, ProcessLevel, ParentCompany, CurrentCustomsReceiptOrders, CurrentBatch) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel); 
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("CurrentCustomsReceiptOrders", CurrentCustomsReceiptOrders);
	Запрос.УстановитьПараметр("CurrentBatch", CurrentBatch);
	
	// ПАХНЕТ ТАК, КАК БУДТО ЗДЕСЬ НУЖЕН РЕГИСТР НАКОПЛЕНИЯ
	Запрос.Текст =
		"ВЫБРАТЬ
		|	CustomsReceiptOrders.Ссылка КАК CustomsReceiptOrder
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsReceiptOrders
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BatchesOfCustomsFiles.ТПО КАК BatchesOfCustomsFilesCustomsReceiptOrders
		|		ПО CustomsReceiptOrders.Ссылка = BatchesOfCustomsFilesCustomsReceiptOrders.ТПО
		|			И (НЕ BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка.ПометкаУдаления)
		|			И (НЕ BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка = &CurrentBatch)
		|ГДЕ
		|	CustomsReceiptOrders.ReleaseDate <= &Дата
		|	И CustomsReceiptOrders.ProcessLevel = &ProcessLevel
		|	И CustomsReceiptOrders.SoldTo = &ParentCompany
		|	И CustomsReceiptOrders.TypeOfTransaction = ЗНАЧЕНИЕ(Перечисление.TypesOfCustomsFileLightTransaction.ТПО)
		|	И CustomsReceiptOrders.Проведен
		|	И НЕ CustomsReceiptOrders.Ссылка В (&CurrentCustomsReceiptOrders)
		|	И BatchesOfCustomsFilesCustomsReceiptOrders.ТПО ЕСТЬ NULL ";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsReceiptOrder");
	
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьReadyCustomsBonds(Дата, ProcessLevel, ParentCompany, CurrentCustomsBonds, CurrentBatch) Экспорт
		
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel); 
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("CurrentCustomsBonds", CurrentCustomsBonds);
	Запрос.УстановитьПараметр("CurrentBatch", CurrentBatch);

	// ПАХНЕТ ТАК, КАК БУДТО ЗДЕСЬ НУЖЕН РЕГИСТР НАКОПЛЕНИЯ
	Запрос.Текст =
		"ВЫБРАТЬ
		|	CustomsBonds.Ссылка КАК CustomsBond
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsBonds
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BatchesOfCustomsFiles.CustomsBonds КАК BatchesOfCustomsFilesCustomsBonds
		|		ПО CustomsBonds.Ссылка = BatchesOfCustomsFilesCustomsBonds.CustomsBond
		|			И (НЕ BatchesOfCustomsFilesCustomsBonds.Ссылка.ПометкаУдаления)
		|			И (НЕ BatchesOfCustomsFilesCustomsBonds.Ссылка = &CurrentBatch)
		|ГДЕ
		|	CustomsBonds.Дата <= &Дата
		|	И CustomsBonds.ProcessLevel = &ProcessLevel
		|	И CustomsBonds.SoldTo = &ParentCompany
		|	И CustomsBonds.TypeOfTransaction = ЗНАЧЕНИЕ(Перечисление.TypesOfCustomsFileLightTransaction.CustomsBond)
		|	И CustomsBonds.Проведен
		|	И НЕ CustomsBonds.Ссылка В (&CurrentCustomsBonds)
		|	И BatchesOfCustomsFilesCustomsBonds.CustomsBond ЕСТЬ NULL";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsBond");
		
КонецФункции

// ДОДЕЛАТЬ
Функция ПолучитьReadyCustomsBondClosings(Дата, ProcessLevel, ParentCompany, CurrentCustomsBondClosings, CurrentBatch) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		ВызватьИсключение "Date is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ВызватьИсключение "Process level is empty!";	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ВызватьИсключение "Parent company is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel); 
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("CurrentCustomsBondClosings", CurrentCustomsBondClosings);
	Запрос.УстановитьПараметр("CurrentBatch", CurrentBatch);

	// ПАХНЕТ ТАК, КАК БУДТО ЗДЕСЬ НУЖЕН РЕГИСТР НАКОПЛЕНИЯ
	Запрос.Текст =
		"ВЫБРАТЬ
		|	CustomsBondClosings.Ссылка КАК CustomsBondClosing
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsBondClosings
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.BatchesOfCustomsFiles.CustomsBondClosings КАК BatchesOfCustomsFilesCustomsBondClosings
		|		ПО CustomsBondClosings.Ссылка = BatchesOfCustomsFilesCustomsBondClosings.CustomsBondClosing
		|			И (НЕ BatchesOfCustomsFilesCustomsBondClosings.Ссылка.ПометкаУдаления)
		|			И (НЕ BatchesOfCustomsFilesCustomsBondClosings.Ссылка = &CurrentBatch)
		|ГДЕ
		|	CustomsBondClosings.Дата <= &Дата
		|	И CustomsBondClosings.ProcessLevel = &ProcessLevel
		|	И CustomsBondClosings.SoldTo = &ParentCompany
		|	И CustomsBondClosings.TypeOfTransaction = ЗНАЧЕНИЕ(Перечисление.TypesOfCustomsFileLightTransaction.CustomsBondClosing)
		|	И CustomsBondClosings.Проведен
		|	И НЕ CustomsBondClosings.Ссылка В (&CurrentCustomsBondClosings)
		|	И BatchesOfCustomsFilesCustomsBondClosings.CustomsBondClosing ЕСТЬ NULL";
		
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("CustomsBondClosing");
		
КонецФункции

Функция ПолучитьПоCustomsReceiptOrder(CustomsReceiptOrder) Экспорт
	
	Если НЕ ЗначениеЗаполнено(CustomsReceiptOrder) Тогда
		ВызватьИсключение "Customs receipt order is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("CustomsReceiptOrder", CustomsReceiptOrder);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка
		|ИЗ
		|	Документ.BatchesOfCustomsFiles.ТПО КАК BatchesOfCustomsFilesCustomsReceiptOrders
		|ГДЕ
		|	НЕ BatchesOfCustomsFilesCustomsReceiptOrders.Ссылка.ПометкаУдаления
		|	И BatchesOfCustomsFilesCustomsReceiptOrders.ТПО = &CustomsReceiptOrder";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат ПустаяСсылка();
	КонецЕсли;
	
КонецФункции

Функция ПолучитьПоCustomsBond(CustomsBond) Экспорт
	
	Если НЕ ЗначениеЗаполнено(CustomsBond) Тогда
		ВызватьИсключение "Customs bond is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("CustomsBond", CustomsBond);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	BatchesOfCustomsFilesCustomsBonds.Ссылка
		|ИЗ
		|	Документ.BatchesOfCustomsFiles.CustomsBonds КАК BatchesOfCustomsFilesCustomsBonds
		|ГДЕ
		|	НЕ BatchesOfCustomsFilesCustomsBonds.Ссылка.ПометкаУдаления
		|	И BatchesOfCustomsFilesCustomsBonds.CustomsBond = &CustomsBond";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат ПустаяСсылка();
	КонецЕсли;
	
КонецФункции

Функция ПолучитьПоCustomsBondClosing(CustomsBondClosing) Экспорт
	
	Если НЕ ЗначениеЗаполнено(CustomsBondClosing) Тогда
		ВызватьИсключение "Customs bond closing is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("CustomsBondClosing", CustomsBondClosing);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	BatchesOfCustomsFilesCustomsBondClosings.Ссылка
		|ИЗ
		|	Документ.BatchesOfCustomsFiles.CustomsBondClosings КАК BatchesOfCustomsFilesCustomsBondClosings
		|ГДЕ
		|	НЕ BatchesOfCustomsFilesCustomsBondClosings.Ссылка.ПометкаУдаления
		|	И BatchesOfCustomsFilesCustomsBondClosings.CustomsBondClosing = &CustomsBondClosing";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	Иначе
		Возврат ПустаяСсылка();
	КонецЕсли;
	
КонецФункции
