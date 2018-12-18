
/////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ТипЗнчДанныхЗаполнения = Тип("Структура") Тогда
		
		ДанныеЗаполнения.Свойство("ProcessLevel", ProcessLevel);
		ДанныеЗаполнения.Свойство("TypeOfTransaction", TypeOfTransaction);	
		ДанныеЗаполнения.Свойство("CustomsFile", CustomsFile);
		ДанныеЗаполнения.Свойство("CustomsFileNo", CustomsFileNo);
		
		Если ДанныеЗаполнения.Свойство("Items") Тогда
			
			Для Каждого Item Из ДанныеЗаполнения.Items Цикл
				
				НоваяСтрокаТЧ = Items.Добавить();
				НоваяСтрокаТЧ.Item = Item;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////
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
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи);
	
	ПроверитьВозможностьИзменения(
		Отказ,
		ДополнительныеСвойства.ВыборкаFutureTemporaryImportTransactionsOfOldItems,
		ДополнительныеСвойства.ВыборкаПроведенныхILMs);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,                                                
		РежимЗаписи,
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile,
		ДополнительныеСвойства.ВыборкаFutureTemporaryImportTransactionsOfCurrentItems,
		ДополнительныеСвойства.ТаблицаItems,
		ДополнительныеСвойства.ТаблицаCustomsFileNoOfItems,
		ДополнительныеСвойства.ТаблицаAdditionalDataOfItemsInTempImpExp);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Дата = НачалоДня(Дата);
	
	Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда
		
		CustomsFile = Неопределено;
		ShipperName = СокрЛП(ShipperName);
		CCAJobReference = СокрЛП(CCAJobReference);
		NewCustomsFileNo = "";
		
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.Prolongation Тогда
		
		NewResponsible = Неопределено;
		ShipperName = "";
		CCAJobReference = "";
		CustomsRegime = Неопределено;
		NewCustomsFileNo = "";
		
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.ResponsibleChange Тогда
		
		CustomsFile = Неопределено;
		CustomsFileNo = Неопределено;
		ExpiryDate = Неопределено;
		ShipperName = "";
		CCAJobReference = "";
		CustomsRegime = Неопределено;
		NewCustomsFileNo = "";
		
	ИначеЕсли Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
		
		ExpiryDate = Неопределено;
		NewResponsible = Неопределено;
		ShipperName = "";
		CCAJobReference = "";
		CustomsRegime = Неопределено;
		NewCustomsFileNo = СокрЛП(NewCustomsFileNo);
		
	КонецЕсли;
	
	Comments = СокрЛП(Comments);
	CustomsFileNo = СокрЛП(CustomsFileNo);
	
	Если ЭтоНовый() Тогда		
		CreatedBy = ПараметрыСеанса.ТекущийПользователь;
		CreationDate = ТекущаяДата();	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ModifiedBy) Тогда
		ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ModificationDate) Тогда
		ModificationDate = ТекущаяДата();
	КонецЕсли;
	
	// Очистим пустые строки в ТЧ
	ИндексСтроки = 0;
	Пока ИндексСтроки < Items.Количество() Цикл
	
		Если ЗначениеЗаполнено(Items[ИндексСтроки].Item) Тогда
			ИндексСтроки = ИндексСтроки + 1;
		Иначе
			Items.Удалить(ИндексСтроки);
		КонецЕсли;
		
	КонецЦикла;
	
	// Очистим Qty при необходимости
	Если ЗначениеЗаполнено(TypeOfTransaction) И НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
		
		Для Каждого СтрокаТЧ Из Items Цикл
			СтрокаТЧ.Qty = 0;
		КонецЦикла;
		
	КонецЕсли;
	
	// Очистим Customs file line no. при необходимости
	Если ЗначениеЗаполнено(TypeOfTransaction) И НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда
		
		Для Каждого СтрокаТЧ Из Items Цикл
			СтрокаТЧ.CustomsFileLineNo = 0;
		КонецЦикла;
		
	КонецЕсли;
	
	// Свернем ТЧ
	Items.Свернуть("Item, Qty, CustomsFileLineNo", "");
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	// Номер
	Если НЕ ЭтоНовый() И НЕ ЗначениеЗаполнено(СокрЛП(Номер)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'No.' is empty!",
			ЭтотОбъект, "Номер", , Отказ);
	КонецЕсли;
	
	// Process level
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			ЭтотОбъект, "ProcessLevel", , Отказ);
	КонецЕсли;
	
	// Дата
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date of transaction' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
			
	ИначеЕсли Дата < '19910101' Тогда
			
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' seems to be too early!",
			ЭтотОбъект, "Дата", , Отказ);	
			
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// Type of transaction
	Если НЕ ЗначениеЗаполнено(TypeOfTransaction) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Type of transaction' is empty!",
			ЭтотОбъект, "TypeOfTransaction", , Отказ);
	КонецЕсли;
	
	TypesOfTemporaryImpExpTransaction = Перечисления.TypesOfTemporaryImpExpTransaction;
	
	// Проверим Customs file no.
	Если TypeOfTransaction <> TypesOfTemporaryImpExpTransaction.ResponsibleChange
		И НЕ ЗначениеЗаполнено(CustomsFileNo) Тогда	
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs file no.' is empty!",
			ЭтотОбъект, "CustomsFileNo", , Отказ);	
			
	КонецЕсли;
		
	// Проверим Expiry date
	Если TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction)
		ИЛИ TypeOfTransaction = TypesOfTemporaryImpExpTransaction.Prolongation Тогда
		
		Если ЗначениеЗаполнено(ExpiryDate) Тогда
			
			Если ExpiryDate < Дата Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Expiry date' can not be earlier than 'Transaction date'!",
					ЭтотОбъект, "ExpiryDate", , Отказ);
			КонецЕсли;
			
		Иначе
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Expiry date' is empty!",
				ЭтотОбъект, "ExpiryDate", , Отказ);
				
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим New responsible
	Если TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction)
		ИЛИ TypeOfTransaction = TypesOfTemporaryImpExpTransaction.ResponsibleChange Тогда
			
		Если НЕ ЗначениеЗаполнено(NewResponsible) Тогда
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'New responsible' is empty!",
				ЭтотОбъект, "NewResponsible", , Отказ);
				
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим Shipper name, CCA job ref. и Regime
	Если TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда

		Если НЕ ЗначениеЗаполнено(ShipperName) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Shipper name' is empty!",
				ЭтотОбъект, "ShipperName", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(CCAJobReference) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'CCA job ref.' is empty!",
				ЭтотОбъект, "CCAJobReference", , Отказ);
		КонецЕсли;
		
		// Проверим Customs regime
		Если НЕ ЗначениеЗаполнено(CustomsRegime) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Customs regime' is empty!",
				ЭтотОбъект, "CustomsRegime", , Отказ);
				
		Иначе
			
			// Проверим, что указан temporary regime
			CustomsRegimePermanentTemporary = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(CustomsRegime, "PermanentTemporary");
			Если CustomsRegimePermanentTemporary <> Перечисления.PermanentTemporary.Temporary Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Customs regime '" + СокрЛП(CustomsRegime) + "' is not temporary!",
					ЭтотОбъект, "CustomsRegime", , Отказ);
			КонецЕсли;
			
			// Проверим, что выбран режим с правильным реквизитов ImportExport
			CustomsRegimeImportExport = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(CustomsRegime, "ImportExport");
			TypeOfTransactionImportExport = TypesOfTemporaryImpExpTransaction.ПолучитьImportExport(TypeOfTransaction);
			Если CustomsRegimeImportExport <> TypeOfTransactionImportExport Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Customs regime '" + СокрЛП(CustomsRegime) + "' is not for " + TypeOfTransactionImportExport + "!",
					ЭтотОбъект, "CustomsRegime", , Отказ);	
			КонецЕсли;
						
		КонецЕсли;
		
	КонецЕсли;
	
	Если TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
		
		Если НЕ ЗначениеЗаполнено(NewCustomsFileNo) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'New Customs file no.' is empty!",
				ЭтотОбъект, "NewCustomsFileNo", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим ТЧ
	
	Если Items.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Items table is empty!",
			ЭтотОбъект, "Items", , Отказ);
		Возврат;
	КонецЕсли;
	
	Если TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
	
		Для Каждого СтрокаТЧ Из Items Цикл
			
			// Проверим заполнение количества в ТЧ
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Qty) Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": Qty is empty!",
					ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Qty", , Отказ);
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи)
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
		
	Если Проведен Тогда
		
		// Проверим, что документ не выдергивают из хронологической последовательности	
		СтруктураТекстов.Вставить("FutureTemporaryImportTransactionsOfOldItems",
			"ВЫБРАТЬ
			|	TemporaryImpExpTransactionsItems1.Item.Представление КАК ItemПредставление,
			|	TemporaryImpExpTransactionsItems1.Ссылка.Представление КАК TemporaryImportTransactionПредставление
			|ИЗ
			|	Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems1
			|		ПО TemporaryImpExpTransactionsItems.Item = TemporaryImpExpTransactionsItems1.Item
			|			И TemporaryImpExpTransactionsItems.Ссылка.Дата < TemporaryImpExpTransactionsItems1.Ссылка.Дата
			|			И (TemporaryImpExpTransactionsItems1.Ссылка.Проведен)
			|ГДЕ
			|	TemporaryImpExpTransactionsItems.Ссылка = &Ссылка");
			
		// Проверим, не заведен ли уже ILM
		Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.PermanentImport
			ИЛИ TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.PermanentExport Тогда
			
			СтруктураТекстов.Вставить("ПроведенныеILMs",
				"ВЫБРАТЬ
				|	InvoiceLinesMatching.Представление
				|ИЗ
				|	Документ.ЗакрытиеПоставки КАК InvoiceLinesMatching
				|ГДЕ
				|	InvoiceLinesMatching.Поставка = &Ссылка
				|	И InvoiceLinesMatching.Проведен");
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		СтруктураПараметров.Вставить("Items", Items.ВыгрузитьКолонку("Item"));
		
		Если ЗначениеЗаполнено(CustomsFile) Тогда
			
			СтруктураПараметров.Вставить("CustomsFile", CustomsFile);
			Если ТипЗнч(CustomsFile) = Тип("ДокументСсылка.ГТД") Тогда
				
				СтруктураТекстов.Вставить("РеквизитыCustomsFile", 
					"ВЫБРАТЬ
					|	CustomsFiles.Проведен,
					|	CustomsFiles.Номер,
					|	CustomsFiles.ImportExport,
					|	CustomsFiles.PermanentTemporary,		
					|	CustomsFiles.ДатаВыпуска КАК ReleaseDate
					|ИЗ
					|	Документ.ГТД КАК CustomsFiles
					|ГДЕ
					|	CustomsFiles.Ссылка = &CustomsFile");
					
			ИначеЕсли ТипЗнч(CustomsFile) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
				
				СтруктураТекстов.Вставить("РеквизитыCustomsFile", 
					"ВЫБРАТЬ
					|	CustomsFilesLight.Проведен,
					|	CustomsFilesLight.Номер,
					|	CustomsFilesLight.ImportExport,
					|	CustomsFilesLight.PermanentTemporary,
					|	CustomsFilesLight.TypeOfTransaction,
					|	CustomsFilesLight.ReleaseDate КАК ReleaseDate
					|ИЗ
					|	Документ.CustomsFilesLight КАК CustomsFilesLight
					|ГДЕ
					|	CustomsFilesLight.Ссылка = &CustomsFile");
				
			КонецЕсли;
			
		КонецЕсли;
		
		СтруктураТекстов.Вставить("РеквизитыItems",
			"ВЫБРАТЬ
			|	Items.Ссылка КАК Item,
			|	Items.ПометкаУдаления,
			|	Items.Инвойс КАК ImportInvoice,
			|	Items.ExportRequest,
			|	Items.Количество КАК Qty,
			|	Items.PermanentTemporary,
			|	Items.Final
			|ИЗ
			|	Справочник.СтрокиИнвойса КАК Items
			|ГДЕ
			|	Items.Ссылка В(&Items)");
				
		СтруктураПараметров.Вставить("Дата", Дата);
		
		// Проверим, что нет дублей и документ не вставляют внутрь хронологической последовательности
		СтруктураТекстов.Вставить("FutureTemporaryImportTransactionsOfCurrentItems",
			"ВЫБРАТЬ
			|	TemporaryImpExpTransactionsItems.Item,
			|	TemporaryImpExpTransactionsItems.Ссылка КАК TemporaryImportTransaction
			|ИЗ
			|	Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
			|ГДЕ
			|	TemporaryImpExpTransactionsItems.Item В(&Items)
			|	И TemporaryImpExpTransactionsItems.Ссылка <> &Ссылка
			|	И TemporaryImpExpTransactionsItems.Ссылка.Дата >= &Дата
			|	И TemporaryImpExpTransactionsItems.Ссылка.Проведен");
			
		Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.Prolongation
			ИЛИ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
			
			// Проверим, что товары относятся именно к указанной Customs file
			СтруктураТекстов.Вставить("CustomsFileNoOfItems",
				"ВЫБРАТЬ
				|	CustomsFilesOfGoods.Item,
				|	CustomsFilesOfGoods.DTNo КАК CustomsFileNo
				|ИЗ
				|	РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
				|ГДЕ
				|	CustomsFilesOfGoods.Item В(&Items)");
				
		КонецЕсли;	
		
		Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
			
			СтруктураТекстов.Вставить("AdditionalDataOfItemsInTempImpExp",
				"ВЫБРАТЬ
				|	AdditionalDataOfItemsInTemporaryImpExp.Item,
				|	AdditionalDataOfItemsInTemporaryImpExp.CustomsRegime.ImportExport КАК ImportExport,
				|	AdditionalDataOfItemsInTemporaryImpExp.CustomsRegime
				|ИЗ
				|	РегистрСведений.AdditionalDataOfItemsInTemporaryImpExp КАК AdditionalDataOfItemsInTemporaryImpExp
				|ГДЕ
				|	AdditionalDataOfItemsInTemporaryImpExp.Item В(&Items)");
			
		КонецЕсли;
	
	КонецЕсли;
	     	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаFutureTemporaryImportTransactionsOfOldItems", Неопределено);
	Если СтруктураРезультатов.Свойство("FutureTemporaryImportTransactionsOfOldItems") Тогда
		ДополнительныеСвойства.ВыборкаFutureTemporaryImportTransactionsOfOldItems = СтруктураРезультатов.FutureTemporaryImportTransactionsOfOldItems.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаПроведенныхILMs", Неопределено);
	Если СтруктураРезультатов.Свойство("ПроведенныеILMs") Тогда
		ДополнительныеСвойства.ВыборкаПроведенныхILMs = СтруктураРезультатов.ПроведенныеILMs.Выбрать();	
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаFutureTemporaryImportTransactionsOfCurrentItems", Неопределено);
	Если СтруктураРезультатов.Свойство("FutureTemporaryImportTransactionsOfCurrentItems") Тогда
		ДополнительныеСвойства.ВыборкаFutureTemporaryImportTransactionsOfCurrentItems = СтруктураРезультатов.FutureTemporaryImportTransactionsOfCurrentItems.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCustomsFile", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFile") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile = СтруктураРезультатов.РеквизитыCustomsFile.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаItems", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыItems") Тогда
		ДополнительныеСвойства.ТаблицаItems = СтруктураРезультатов.РеквизитыItems.Выгрузить();
		ДополнительныеСвойства.ТаблицаItems.Индексы.Добавить("Item");
	КонецЕсли;
		
	ДополнительныеСвойства.Вставить("ТаблицаCustomsFileNoOfItems", Неопределено);
	Если СтруктураРезультатов.Свойство("CustomsFileNoOfItems") Тогда
		ДополнительныеСвойства.ТаблицаCustomsFileNoOfItems = СтруктураРезультатов.CustomsFileNoOfItems.Выгрузить();
		ДополнительныеСвойства.ТаблицаCustomsFileNoOfItems.Индексы.Добавить("Item");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаAdditionalDataOfItemsInTempImpExp", Неопределено);
	Если СтруктураРезультатов.Свойство("AdditionalDataOfItemsInTempImpExp") Тогда
		ДополнительныеСвойства.ТаблицаAdditionalDataOfItemsInTempImpExp = СтруктураРезультатов.AdditionalDataOfItemsInTempImpExp.Выгрузить();
		ДополнительныеСвойства.ТаблицаAdditionalDataOfItemsInTempImpExp.Индексы.Добавить("Item");
	КонецЕсли;

КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(Отказ, ВыборкаFutureTemporaryImportTransactionsOfOldItems, ВыборкаПроведенныхILMs)
	
	Если НЕ Проведен Тогда
		Возврат;
	КонецЕсли;
	
	Пока ВыборкаFutureTemporaryImportTransactionsOfOldItems.Следующий() Цикл
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"You can not change current document, because there is later '" + ВыборкаFutureTemporaryImportTransactionsOfOldItems.TemporaryImportTransactionПредставление + "' for Item '" + СокрЛП(ВыборкаFutureTemporaryImportTransactionsOfOldItems.ItemПредставление) + "'!",
			ЭтотОбъект, , , Отказ);
		
	КонецЦикла;
	
	Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.PermanentImport
		ИЛИ TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.PermanentExport Тогда
		
		Если ВыборкаПроведенныхILMs.Следующий() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"You can not change current document, because there is already '" + ВыборкаПроведенныхILMs.Представление + "'!",
				ЭтотОбъект, , , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаРеквизитовCustomsFile, 
													ВыборкаFutureTemporaryImportTransactionsOfCurrentItems, 
													ТаблицаItems, ТаблицаCustomsFileNoOfItems,
													ТаблицаAdditionalDataOfItemsInTempImpExp)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// Проверм Customs file
	Если ЗначениеЗаполнено(CustomsFile) Тогда
		
		Если НЕ ВыборкаРеквизитовCustomsFile.Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'" + CustomsFile + "' is not posted!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsFile.ReleaseDate > Дата Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Release date " + Формат(ВыборкаРеквизитовCustomsFile.ReleaseDate, "ДЛФ=D") + " of '" + CustomsFile + "' is later than Transaction date!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		// Проверим Customs file no.
		Если ЗначениеЗаполнено(CustomsFileNo) И СокрЛП(ВыборкаРеквизитовCustomsFile.Номер) <> CustomsFileNo Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"No. of '" + CustomsFile + "' differs from Customs file no. '" + CustomsFileNo + "'!",
				ЭтотОбъект, "CustomsFileNo", , Отказ);
		КонецЕсли;
		
		// Проверим, что ImportExport в CustomsFile соответствует ImportExport типа транзакции
		TypeOfTransactionImportExport = Перечисления.TypesOfTemporaryImpExpTransaction.ПолучитьImportExport(TypeOfTransaction);
		Если ЗначениеЗаполнено(TypeOfTransactionImportExport) И ВыборкаРеквизитовCustomsFile.ImportExport <> TypeOfTransactionImportExport Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"You can use only '" + TypeOfTransactionImportExport + "' customs files for '" + TypeOfTransaction + "'!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		// Проверим, что Customs file именно на временный ввоз
		Если ВыборкаРеквизитовCustomsFile.PermanentTemporary <> Перечисления.PermanentTemporary.Temporary Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"You can use only temporary customs files!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	Пока ВыборкаFutureTemporaryImportTransactionsOfCurrentItems.Следующий() Цикл	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"There is '" + ВыборкаFutureTemporaryImportTransactionsOfCurrentItems.TemporaryImportTransaction + "' for Item '" + СокрЛП(ВыборкаFutureTemporaryImportTransactionsOfCurrentItems.Item) + "'!",
			ВыборкаFutureTemporaryImportTransactionsOfCurrentItems.TemporaryImportTransaction,,, Отказ);	
	КонецЦикла;
	
	// получим тип Импорт или Экспорт для проверки сооветствия режима товара данному типу
	ImportExportTransactionForItem = Перечисления.TypesOfTemporaryImpExpTransaction.ПолучитьImportExportForItem(TypeOfTransaction);
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		РеквизитыItem = ТаблицаItems.Найти(СтрокаТЧ.Item, "Item");
		
		// Проверим реквизиты товара
		
		Если РеквизитыItem.ПометкаУдаления Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": Item is marked for deletion!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
		КонецЕсли;
		
		Если НЕ РеквизитыItem.Final Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": Item is not marked as Final!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
		КонецЕсли;
		
		Если РеквизитыItem.PermanentTemporary <> Перечисления.PermanentTemporary.Temporary Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": Item is not marked as temporary!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
		КонецЕсли;
				
		Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.TemporaryImport
			И ЗначениеЗаполнено(РеквизитыItem.ImportInvoice) Тогда	
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": you can not use Item attached to Import invoice!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);	
		КонецЕсли;
		
		Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.TemporaryExport
			И ЗначениеЗаполнено(РеквизитыItem.ExportRequest) Тогда	
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": you can not use Item attached to Export request!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);	
		КонецЕсли;
		
		// Проверим заполнение количества в товаре
		Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction)
			И НЕ ЗначениеЗаполнено(РеквизитыItem.Qty) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": Qty in Item is empty!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли;
		
		// Проверим, что товар привязан именно к той Customs file, что указана в шапке
		Если TypeOfTransaction = Перечисления.TypesOfTemporaryImpExpTransaction.Prolongation
			ИЛИ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
			
			СтрокаТаблицыCustomsFileNoOfItems = ТаблицаCustomsFileNoOfItems.Найти(СтрокаТЧ.Item, "Item");
			Если СтрокаТаблицыCustomsFileNoOfItems = Неопределено Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": Item is not attached to any Customs file!",
					ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			ИначеЕсли СтрокаТаблицыCustomsFileNoOfItems.CustomsFileNo <> CustomsFileNo Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": Item is attached to another Customs file '" + СтрокаТаблицыCustomsFileNoOfItems.CustomsFileNo + "'!",
					ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			КонецЕсли;
			
		КонецЕсли;	
		
		// Проверим заполнение количества в ТЧ
		Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
			
			Если СтрокаТЧ.Qty > РеквизитыItem.Qty Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": Qty in line exceeds Qty in Item!",
					ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Qty", , Отказ);
				
			КонецЕсли;
			
		КонецЕсли;
		   				
		//проверим возможность использовать тип транзакции для режима товара
		Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
			
			AdditionalDataOfItemInTempImpExp = ТаблицаAdditionalDataOfItemsInTempImpExp.Найти(СтрокаТЧ.Item, "Item");
			Если AdditionalDataOfItemInTempImpExp.ImportExport <> ImportExportTransactionForItem Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": Item on regime '" + СокрЛП(AdditionalDataOfItemInTempImpExp.CustomsRegime) 
						+ "' can not be used with current type of transaction!",
					ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			КонецЕсли;
				
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияПоQtyOfItemsInTemporaryImpExp(Отказ, ДополнительныеСвойства.ТаблицаItems);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияПоCustomsFilesOfItems();
	
	ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp();
	
	ДвиженияПоResponsiblesOfItemsInTemporaryImpExp();
	
	ДвижениеПоAdditionalDataOfItemsInTemporaryImpExp();
	
КонецПроцедуры

Процедура ДвиженияПоQtyOfItemsInTemporaryImpExp(Отказ, ТаблицаItems)
	
	ДвиженияПоQtyOfItemsInTemporaryImpExp = Движения.QtyOfItemsInTemporaryImpExp;
	ДвиженияПоQtyOfItemsInTemporaryImpExp.Очистить();
	
	Если Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда
		
		ОтразитьРучноеПринятиеКоличестваТоваров(Отказ, ДвиженияПоQtyOfItemsInTemporaryImpExp, ТаблицаItems);
				
	ИначеЕсли Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоВывод(TypeOfTransaction) Тогда
		
		ОтразитьВыводКоличестваТоваров(Отказ, ДвиженияПоQtyOfItemsInTemporaryImpExp);
		
	Иначе
		
		ДвиженияПоQtyOfItemsInTemporaryImpExp.Записывать = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтразитьРучноеПринятиеКоличестваТоваров(Отказ, ДвиженияПоQtyOfItemsInTemporaryImpExp, ТаблицаItems)
	
	// Сформируем движения
	Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
	
		Движение = ДвиженияПоQtyOfItemsInTemporaryImpExp.ДобавитьПриход();
		Движение.Период = Дата;
		Движение.Item = СтрокаТаблицыItems.Item;
		Движение.Qty = СтрокаТаблицыItems.Qty;
		
	КонецЦикла;

	// Запишем в регистр
	ДвиженияПоQtyOfItemsInTemporaryImpExp.Записать();
	
	// Проверим остатки
	ТаблицаОстатков = ПолучитьТаблицуОстатковQtyOfItemsInTemporaryImpExp();
	ТаблицаОстатков.Индексы.Добавить("Item");
	Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
		
		СтрокаТаблицыОстатков = ТаблицаОстатков.Найти(СтрокаТаблицыItems.Item, "Item");
		Если СтрокаТаблицыОстатков.Qty > СтрокаТаблицыItems.Qty Тогда
			
			СтрокаТЧ = Items.Найти(СтрокаТаблицыItems.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": Item '" + СокрЛП(СтрокаТЧ.Item) + "' is already in temporary import / export!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);	
			
		КонецЕсли;
		
	КонецЦикла;
		
КонецПроцедуры

Процедура ОтразитьВыводКоличестваТоваров(Отказ, ДвиженияПоQtyOfItemsInTemporaryImpExp)
	
	// Сформируем движения
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движение = ДвиженияПоQtyOfItemsInTemporaryImpExp.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Item = СтрокаТЧ.Item;
		Движение.Qty = СтрокаТЧ.Qty;
		
	КонецЦикла;
	
	// Запишем в регистр
	ДвиженияПоQtyOfItemsInTemporaryImpExp.Записать();
	
	// Проверим остатки
	ТаблицаОстатков = ПолучитьТаблицуОстатковQtyOfItemsInTemporaryImpExp();	
	Для Каждого СтрокаТаблицыОстатков Из ТаблицаОстатков Цикл
		
		СтрокаТЧ = Items.Найти(СтрокаТаблицыОстатков.Item, "Item");
		Если СтрокаТаблицыОстатков.Qty < 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + ": there are " + (-СтрокаТаблицыОстатков.Qty) + " items less in temporary import/export than you specified!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Qty", , Отказ);	
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьТаблицуОстатковQtyOfItemsInTemporaryImpExp()
		
	Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
	Отбор = Новый Структура("Item", Items.ВыгрузитьКолонку("Item")); 
	Возврат РегистрыНакопления.QtyOfItemsInTemporaryImpExp.Остатки(Граница, Отбор, "Item", "Qty");
		  			
КонецФункции

Процедура ДвиженияПоCustomsFilesOfItems()
	
	CustomsFilesOfItems = Движения.CustomsFilesOfGoods;
	CustomsFilesOfItems.Очистить();
	CustomsFilesOfItems.Записывать = Истина;
	
	Если НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движение = CustomsFilesOfItems.Добавить();
		Движение.Период = Дата;
		Движение.Item = СтрокаТЧ.Item;
		Движение.DTNo = CustomsFileNo;
		Движение.DTLineNo = СтрокаТЧ.CustomsFileLineNo;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp()
	
	ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp = Движения.ExpiryDatesOfItemsInTemporaryImpExp;
	ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp.Очистить();
	ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Если НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction)
		И TypeOfTransaction <> Перечисления.TypesOfTemporaryImpExpTransaction.Prolongation Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движение = ДвиженияПоExpiryDatesOfItemsInTemporaryImpExp.Добавить();
		Движение.Период = Дата;
		Движение.Item = СтрокаТЧ.Item;
		Движение.ExpiryDate = ExpiryDate;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДвиженияПоResponsiblesOfItemsInTemporaryImpExp()
	
	ДвиженияПоResponsiblesOfItemsInTemporaryImpExp = Движения.ResponsiblesForItemsInTemporaryImpExp;
	ДвиженияПоResponsiblesOfItemsInTemporaryImpExp.Очистить();
	ДвиженияПоResponsiblesOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Если НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction)
		И TypeOfTransaction <> Перечисления.TypesOfTemporaryImpExpTransaction.ResponsibleChange Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движение = ДвиженияПоResponsiblesOfItemsInTemporaryImpExp.Добавить();
		Движение.Период = Дата;
		Движение.Item = СтрокаТЧ.Item;
		Движение.Responsible = NewResponsible;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДвижениеПоAdditionalDataOfItemsInTemporaryImpExp()
	
	ДвиженияПоAdditionalDataOfItemsInTemporaryImpExp = Движения.AdditionalDataOfItemsInTemporaryImpExp;
	ДвиженияПоAdditionalDataOfItemsInTemporaryImpExp.Очистить();
	ДвиженияПоAdditionalDataOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Если НЕ Перечисления.TypesOfTemporaryImpExpTransaction.ЭтоРучноеПринятие(TypeOfTransaction) Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движение = ДвиженияПоAdditionalDataOfItemsInTemporaryImpExp.Добавить();
		Движение.Период = Дата;
		Движение.Item = СтрокаТЧ.Item;
		Движение.ProcessLevel = ProcessLevel;
		Движение.ShipperName = ShipperName;
		Движение.CCAJobReference = CCAJobReference;
		Движение.CustomsRegime = CustomsRegime;
		
	КонецЦикла;
	
КонецПроцедуры
