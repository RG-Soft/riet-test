
////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ЗАПОЛНЕНИЯ

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	ТипЗнчДанныхЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Если ТипЗнчДанныхЗаполнения = Тип("ДокументСсылка.Поставка")
		ИЛИ ТипЗнчДанныхЗаполнения = Тип("ДокументСсылка.ExportShipment") Тогда
		
		ЗаполнитьПоShipment(ДанныеЗаполнения);
		
	ИначеЕсли ТипЗнчДанныхЗаполнения = Тип("ДокументСсылка.ГТД") Тогда
		
		ЗаполнитьПоCustomsFile(ДанныеЗаполнения);	 
		
	ИначеЕсли ТипЗнчДанныхЗаполнения = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		Если ДанныеЗаполнения.TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
			ЗаполнитьПоCustomsBond(ДанныеЗаполнения);
		КонецЕсли;
				
	ИначеЕсли ТипЗнчДанныхЗаполнения = Тип("Структура") Тогда
		
		ЗаполнитьПоСтруктуре(ДанныеЗаполнения);
		
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Country) И ЗначениеЗаполнено(ProcessLevel) Тогда
		Country = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ProcessLevel, "Country");
	КонецЕсли;
	
КонецПроцедуры 

Процедура ЗаполнитьПоShipment(ShipmentОснование) Экспорт
	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond
		ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
		ВызватьИсключение "Type of transaction '" + TypeOfTransaction + "' is not supported!";
	КонецЕсли;

	УстановитьПривилегированныйРежим(Истина);
	
	// shipment
	Shipment = ShipmentОснование;
	
	// cca, process level
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ShipmentОснование, "CCA, ProcessLevel");
	 
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
		ProcessLevel = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
	КонецЕсли;
	
	// type of transaction
	// для России и Казахстана по-умолчанию использует вид операции ТПО, для остальных - Customs file light
	Если НЕ ЗначениеЗаполнено(TypeOfTransaction) Тогда
		
		Если ProcessLevel = Справочники.ProcessLevels.RUWE
			ИЛИ ProcessLevel = Справочники.ProcessLevels.RUEA
			ИЛИ ProcessLevel = Справочники.ProcessLevels.RUSM
			ИЛИ ProcessLevel = Справочники.ProcessLevels.KZ Тогда
			TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО;
		Иначе
			TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight;
		КонецЕсли;
		
	КонецЕсли;
		
	ТипЗнчShipment = ТипЗнч(ShipmentОснование);
	
	// import / export
	Если ТипЗнч(ShipmentОснование) = Тип("ДокументСсылка.Поставка") Тогда
		ImportExport = Перечисления.ИмпортЭкспорт.Import;
	ИначеЕсли ТипЗнч(ShipmentОснование) = Тип("ДокументСсылка.ExportShipment") Тогда
		ImportExport = Перечисления.ИмпортЭкспорт.Export;
	Иначе
		ВызватьИсключение "Unknown Shipment type '" + ТипЗнч(ShipmentОснование) + "'!";
	КонецЕсли;
	
	// найдем items, которые еще не подобраны в customs files
	ДоступныеItems = Документы.CustomsFilesLight.ПолучитьДоступныеItemsДляCustomsFileИCustomsBond(TypeOfTransaction, ShipmentОснование, SoldTo, PermanentTemporary, PSAContract, Ссылка);
	
	Если ДоступныеItems.Количество() = 0 Тогда
		
		ТекстОшибки = "Failed to find items for:
			|" + ShipmentОснование;
			
		Если ЗначениеЗаполнено(SoldTo) Тогда
			ТекстОшибки = ТекстОшибки + "
				|Parent company '" + СокрЛП(SoldTo) + "'";
		КонецЕсли;
		
		Если ЗначениеЗаполнено(PermanentTemporary) Тогда
			ТекстОшибки = ТекстОшибки + "
				|'" + PermanentTemporary + "'";
		КонецЕсли;
		
		Если ЗначениеЗаполнено(PSAContract) Тогда
			ТекстОшибки = ТекстОшибки + "
				|PSA contract '" + СокрЛП(PSAContract) + "'";
		КонецЕсли;
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ТекстОшибки,
			ЭтотОбъект);
		Возврат;
		
	КонецЕсли;

	// получим реквизиты найденных items
	ТаблицаItems = Документы.CustomsFilesLight.ПолучитьРеквизитыItems(ДоступныеItems, ImportExport);
		
	// Sold-to
	ТаблицаParentCompanies = ТаблицаItems.Скопировать(, "ParentCompany");
	ТаблицаParentCompanies.Свернуть("ParentCompany", "");
	Если ТаблицаParentCompanies.Количество() = 1 Тогда
			
		SoldTo = ТаблицаParentCompanies[0].ParentCompany;
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"There are several Parent companies in '" + ShipmentОснование + "'!
			|Fill in Parent company manually.",
			ЭтотОбъект, "SoldTo");
		Возврат;
		
	КонецЕсли;
	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		
		// Permanent / temporary
		ТаблицаPermanentTemporary = ТаблицаItems.Скопировать(, "PermanentTemporary");
		ТаблицаPermanentTemporary.Свернуть("PermanentTemporary", "");
		Если ТаблицаPermanentTemporary.Количество() = 1 Тогда
			
			PermanentTemporary = ТаблицаPermanentTemporary[0].PermanentTemporary;
						
		Иначе
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There are items with different Permanent / temporary property in '" + ShipmentОснование + "'!
				|Fill in Permanent / temporary manually.",
				ЭтотОбъект, "PermanentTemporary");
			Возврат;
			
		КонецЕсли;	
		
		// PSA contract
		ТаблицаPSAContracts = ТаблицаItems.Скопировать(, "PSAContract");
		ТаблицаPSAContracts.Свернуть("PSAContract", "");
		Если ТаблицаPSAContracts.Количество() = 1 Тогда
			
			PSAContract = ТаблицаPSAContracts[0].PSAContract;
			
		Иначе
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There are items with different PSA contracts in '" + ShipmentОснование + "'!
				|Fill in PSA contract manually.",
				ЭтотОбъект, "PSAContract");
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
	// Invoice currency	
	ТаблицаInvoiceCurrency = ТаблицаItems.Скопировать(, "Currency");
	ТаблицаInvoiceCurrency.Свернуть("Currency", "");
	Если ТаблицаInvoiceCurrency.Количество() = 1 Тогда
		
		InvoiceCurrency = ТаблицаInvoiceCurrency[0].Currency;
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"There are different currencies in '" + ShipmentОснование + "'!
			|Fill in Invoice currency manually.",
			ЭтотОбъект, "InvoiceCurrency");
		Возврат;
		
	КонецЕсли;
		
	Items.Очистить();
	Goods.Очистить();
	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		
		Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
			
			НоваяСтрокаТЧ = Items.Добавить();
			НоваяСтрокаТЧ.Item = СтрокаТаблицыItems.Item;
			НоваяСтрокаТЧ.CustomsFileHTC = СтрокаТаблицыItems.InvoiceHTC;
			НоваяСтрокаТЧ.CustomsFileNetWeight = СтрокаТаблицыItems.ParcelsNetWeight;
		
		КонецЦикла;
		
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		//ТаблицаItems.Свернуть("AU, Description, POLine", "TotalPrice");
		ТаблицаItems.Свернуть("AU, Description, Item, POLine", "TotalPrice");
		// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		
		Для Каждого СтрокаТаблицыItems Из ТаблицаItems Цикл
			
			НоваяСтрокаТЧ = Goods.Добавить();
			НоваяСтрокаТЧ.AU = СтрокаТаблицыItems.AU;
			НоваяСтрокаТЧ.Description = СтрокаТаблицыItems.Description;
			НоваяСтрокаТЧ.InvoiceTotalValue = СтрокаТаблицыItems.TotalPrice;
			НоваяСтрокаТЧ.POLine = СтрокаТаблицыItems.POLine;
			// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
			НоваяСтрокаТЧ.InvoiceLine = СтрокаТаблицыItems.Item;
			// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПоCustomsFile(CustomsFileОснование)
	
	TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond;
	
	CustomsFile = CustomsFileОснование;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, CustomsFileОснование, "CustomsPost, SoldTo, CCA, ImportExport, Shipment, ProcessLevel"); 
	
КонецПроцедуры

Процедура ЗаполнитьПоCustomsBond(CustomsBondОснование)

	TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
	CustomsBond = CustomsBondОснование;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, CustomsBondОснование, "CustomsPost, SoldTo, CCA, ImportExport, ProcessLevel"); 
			
КонецПроцедуры

Процедура ЗаполнитьПоСтруктуре(Структура)
	
	Структура.Свойство("Country", Country);
	Структура.Свойство("ProcessLevel", ProcessLevel);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

// ДОДЕЛАТЬ
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	// заполняем "Description" на основании "DescriptionForCustoms"
	Для Каждого СтрокаGoods Из Goods Цикл
		Если СтрокаGoods.DescriptionForCustoms <> Перечисления.DescriptionForCustoms.Other Тогда
			Если НЕ ЗначениеЗаполнено(СтрокаGoods.Description) Тогда
				СтрокаGoods.Description = Строка(СтрокаGoods.DescriptionForCustoms);
			КонецЕсли;			
		КонецЕсли;
	КонецЦикла;	
	// } RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи);
	
	ДозаполнитьРеквизитыСДополнительнымиДанными();
		
	// СДЕЛАТЬ ПРОВЕРКУ ИЗМЕНЕНИЯ
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьРеквизитыСДополнительнымиДанными(
		Отказ,
		РежимЗаписи,
		ДополнительныеСвойства.ВыборкаРеквизитовShipment,
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile,
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsBond,
		ДополнительныеСвойства.ВыборкаItemsInOtherCustomsFilesLight,
		ДополнительныеСвойства.ТаблицаItems,
		ДополнительныеСвойства.ТаблицаPOLines);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Дата = НачалоДня(Дата);
	SeqNo = СокрЛП(SeqNo);
	
	// customs file
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		
		Если PermanentTemporary = Перечисления.PermanentTemporary.Permanent Тогда
			ExpiryDate = Неопределено;
		КонецЕсли;
		CustomsFile = Неопределено;
		CustomsBond = Неопределено;
		CustomsDepositAmountToRefund = 0;
		CustomsDepositRefundTo = Неопределено;
		
		Goods.Очистить();
		
	// customs receipt
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		
		PermanentTemporary = Перечисления.PermanentTemporary.Permanent;
		Regime = Неопределено;
		PSAContract = Неопределено;
		ExpiryDate = Неопределено;
		CustomsFile = Неопределено;
		CustomsBond = Неопределено;
		CustomsDepositAmountToRefund = 0;
		CustomsDepositRefundTo = Неопределено;
		
		Items.Очистить();
				
	// customs bond
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
		
		PermanentTemporary  = Неопределено;
		Regime 		 	    = Неопределено;
		PSAContract 	    = Неопределено;
		InvoiceCurrency     = Неопределено;
		InvoiceCurrencyRate = Неопределено;
		ReleaseDate   		= Неопределено;
		ExpiryDate 		    = Неопределено;
		CustomsValue        = Неопределено;
		CustomsBond 		= Неопределено;
		CustomsDepositAmountToRefund = 0;
		CustomsDepositRefundTo = Неопределено;
		
		Goods.Очистить();
		
	// customs bond closing
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда			
				
		PermanentTemporary  = Неопределено;
		Regime 		 	    = Неопределено;
		PSAContract 	    = Неопределено;
		InvoiceCurrency     = Неопределено;
		InvoiceCurrencyRate = Неопределено;
		ReleaseDate   		= Неопределено;
		ExpiryDate 		    = Неопределено;
		CustomsValue        = Неопределено;
		Shipment 			= Неопределено;
		CustomsFile			= Неопределено;
		
		Goods.Очистить();
		
	КонецЕсли;
	
	// items: свернем и очистим от пустых строк
	Items.Свернуть("Item, CustomsFileHTC", "CustomsFileNetWeight");
	
	ИндексСтроки = 0;
	Пока ИндексСтроки < Items.Количество() Цикл
		Если ЗначениеЗаполнено(Items[ИндексСтроки].Item) Тогда
			ИндексСтроки = ИндексСтроки + 1;
		Иначе
			Items.Удалить(ИндексСтроки);
		КонецЕсли;
	КонецЦикла;
	
	// goods
	Для Каждого СтрокаТЧ Из Goods Цикл
		СтрокаТЧ.Description = СокрЛП(СтрокаТЧ.Description);
	КонецЦикла;
	
	// payments: заполним сделаем СокрЛП и заполним PaidByCCA в шапке
	PaidByCCA = Ложь;
	Для Каждого СтрокаТЧ Из Payments Цикл
		
		СтрокаТЧ.PaymentKind = СокрЛП(СтрокаТЧ.PaymentKind);
		
		Если СтрокаТЧ.PaidByCCA Тогда
			PaidByCCA = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	ИтогоПоГрафеВ = Payments.Итог("Sum");
	
	Comment = СокрЛП(Comment);
		
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	ПроверитьШапкуБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	ПроверитьItemsБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	ПроверитьAUsБезДополнительныхДанных(Отказ, РежимЗаписи);
	
	ПроверитьPaymentsБезДополнительныхДанных(Отказ, РежимЗаписи);
		
КонецПроцедуры

Процедура ПроверитьШапкуБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	// Выполним некоторые проверки не при проведении, а при записи, чтобы потом не потерять документ
	
	// Customs post
	Если НЕ ЗначениеЗаполнено(CustomsPost) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs post' is empty!",
			ЭтотОбъект, "CustomsPost", , Отказ);
	КонецЕсли;
	
	// Дата документа
	Если НЕ ЗначениеЗаполнено(Дата) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' is empty!",
			ЭтотОбъект, "Дата", , Отказ);
		
	Иначе
		
		Если Дата < Дата(1998,1,1) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date' can not be earlier than 01.01.1998!",
				ЭтотОбъект, "Дата", , Отказ);	
		КонецЕсли;
		
		Если Дата > ТекущаяДата() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Date' can not be later than the current date!",
				ЭтотОбъект, "Дата", , Отказ);	
		КонецЕсли;
		
	КонецЕсли;
	
	// type of transaction
	Если НЕ ЗначениеЗаполнено(TypeOfTransaction) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Type of transaction' is empty!",
			ЭтотОбъект, "TypeOfTransaction", , Отказ);
	КонецЕсли;
	
	// import / Export
	Если НЕ ЗначениеЗаполнено(ImportExport) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'I/E' is empty!",
			ЭтотОбъект, "ImportExport", , Отказ);
	КонецЕсли;
	
	// parent company
	Если НЕ ЗначениеЗаполнено(SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'parent company' is empty!",
			ЭтотОбъект, "SoldTo", , Отказ);
	КонецЕсли;
	
	// CCA
	Если НЕ ЗначениеЗаполнено(CCA) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'CCA' is empty!",
			ЭтотОбъект, "CCA", , Отказ);
	КонецЕсли;
	
	Если НЕ РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// seq no.
	Если НЕ ЗначениеЗаполнено(SeqNo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Seq. no.' is empty!",
			ЭтотОбъект, "SeqNo", , Отказ);
	КонецЕсли;
	
	//No.
	Если НЕ ЗначениеЗаполнено(Номер) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'No' is empty!",
			ЭтотОбъект, "Номер", , Отказ);
	КонецЕсли;
	
	// permanent / temporary
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
		И НЕ ЗначениеЗаполнено(PermanentTemporary) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Permanent / temporary' is empty!",
			ЭтотОбъект, "PermanentTemporary", , Отказ);
	КонецЕсли;
	
	// regime	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
		И НЕ ЗначениеЗаполнено(Regime) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Regime' is empty!",
			ЭтотОбъект, "Regime", , Отказ);
	КонецЕсли;
				
	// invoice currency
	Если (TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight 
		ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО)
		И НЕ ЗначениеЗаполнено(InvoiceCurrency) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Invoice currency' is empty!",
			ЭтотОбъект, "InvoiceCurrency", , Отказ);
			
	КонецЕсли;
		
	// invoice currency rate
	Если (TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight 
		ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО)
		И НЕ ЗначениеЗаполнено(InvoiceCurrencyRate) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Invoice currency rate' is empty!",
			ЭтотОбъект, "InvoiceCurrencyRate", , Отказ);
			
	КонецЕсли;
		
	// customs value
	Если (TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight 
		ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО)
		И НЕ ЗначениеЗаполнено(CustomsValue) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs value' is empty!",
			ЭтотОбъект, "CustomsValue", , Отказ);
			
	КонецЕсли;
              	
	// release date
	Если НЕ ЗначениеЗаполнено(ReleaseDate) Тогда
		
		Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
			ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Release date' is empty!",
				, "ReleaseDate", "Объект", Отказ);
		КонецЕсли;
	
	Иначе
		
		Если ReleaseDate < Дата Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Release date can not be earlier than ""Date""!",
				ЭтотОбъект, "ReleaseDate", , Отказ);	
		ИначеЕсли ReleaseDate > ТекущаяДата() Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Release date can not be later than the current date!",
				ЭтотОбъект, "ReleaseDate", , Отказ);
        КонецЕсли;
					
	КонецЕсли;
	
	// expiry date
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
		И PermanentTemporary = Перечисления.PermanentTemporary.Temporary
		И НЕ ЗначениеЗаполнено(ExpiryDate) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Expiry date' is empty!",
			ЭтотОбъект, "ExpiryDate", , Отказ);
	КонецЕсли;	
	
	// shipment
	Если НЕ ЗначениеЗаполнено(Shipment) Тогда
		
		Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
			ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Shipment' is empty!",
				ЭтотОбъект, "Shipment", , Отказ);
		КонецЕсли;

	Иначе
		
		Если ImportExport = Перечисления.ИмпортЭкспорт.Import Тогда
			
			Если ТипЗнч(Shipment) <> Тип("ДокументСсылка.Поставка") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"You can not use '" + Shipment + "' for import Customs file light!",
					ЭтотОбъект, "Shipment", , Отказ);
			КонецЕсли;
			
		ИначеЕсли ImportExport = Перечисления.ИмпортЭкспорт.Export Тогда
			
			Если ТипЗнч(Shipment) <> Тип("ДокументСсылка.ExportShipment") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"You can not use '" + Shipment + "' for export Customs file light!",
					ЭтотОбъект, "Shipment", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
						
	КонецЕсли;
	
	// customs file
	Если НЕ ЗначениеЗаполнено(CustomsFile)
		И TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs file' is empty!",
			ЭтотОбъект, "CustomsFile", , Отказ);
			
	КонецЕсли;
	
	// customs bond
	Если НЕ ЗначениеЗаполнено(CustomsBond)
		И TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
			
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs bond' is empty!",
			ЭтотОбъект, "CustomsBond", , Отказ);
		
	КонецЕсли;
	
	// Refund to
	Если CustomsDepositAmountToRefund <> 0 
		И НЕ ЗначениеЗаполнено(CustomsDepositRefundTo) Тогда
			
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Refund to' is empty!",
			ЭтотОбъект, "CustomsDepositRefundTo", , Отказ);
		
	КонецЕсли;
	
	// Country
	Если НЕ ЗначениеЗаполнено(Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			ЭтотОбъект, "Country", , Отказ);
	КонецЕсли;
	
	// Process level
	Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			ЭтотОбъект, "ProcessLevel", , Отказ);		
	КонецЕсли;
	    				
КонецПроцедуры

Процедура ПроверитьItemsБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если Items.Количество() = 0 Тогда
		
		Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
			ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond
			ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Items' table is empty!",
				ЭтотОбъект, "Items", , Отказ);
				
		КонецЕсли;
			
	Иначе
		
		Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
			
			Для Каждого СтрокаТЧ Из Items Цикл
				
				Если НЕ ЗначениеЗаполнено(СтрокаТЧ.CustomsFileHTC) Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"In line " + СтрокаТЧ.НомерСтроки + " of Items: 'Customs file HTC' is empty!",
						ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].CustomsFileHTC", , Отказ);
				КонецЕсли;
				
				Если НЕ ЗначениеЗаполнено(СтрокаТЧ.CustomsFileNetWeight) Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
						"In line " + СтрокаТЧ.НомерСтроки + " of Items: 'Customs file net weight' is empty!",
						ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].CustomsFileNetWeight", , Отказ);
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьAUsБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		Возврат;
	КонецЕсли;
		
	Если Goods.Количество() = 0 Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'AUs' is empty!",
			ЭтотОбъект, "Goods", , Отказ);
	
	Иначе
		
		СтоимостьТоваров = 0;
		
		Для Каждого СтрокаТЧ Из Goods Цикл
			
			// AU
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.AU) Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": ""AU"" is empty!",
					ЭтотОбъект, "Goods[" + (СтрокаТЧ.НомерСтроки-1) + "].AU", , Отказ);
			КонецЕсли;
			
			// Description
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Description) Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": ""Description"" is empty!",
					ЭтотОбъект, "Goods[" + (СтрокаТЧ.НомерСтроки-1) + "].Description", , Отказ);
			КонецЕсли;
			
			// Invoice total value
			Если ЗначениеЗаполнено(СтрокаТЧ.InvoiceTotalValue) Тогда		
				СтоимостьТоваров = СтоимостьТоваров + Цел(СтрокаТЧ.InvoiceTotalValue * InvoiceCurrencyRate);	
			Иначе
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": ""Invoice total value"" is empty!",
					ЭтотОбъект, "Goods[" + (СтрокаТЧ.НомерСтроки-1) + "].InvoiceTotalValue", , Отказ);
			КонецЕсли;
				
		КонецЦикла;
		
		Если ЗначениеЗаполнено(CustomsValue) И РГСофтКлиентСервер.МодульЧисла(СтоимостьТоваров) > РГСофтКлиентСервер.МодульЧисла(CustomsValue) Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Invoice total value * Invoice currency rate (" + СтоимостьТоваров + ") can not be greater than Customs value (" + CustomsValue + ")!",
				ЭтотОбъект, "CustomsValue", , Отказ);
		КонецЕсли;
	
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьPaymentsБезДополнительныхДанных(Отказ, РежимЗаписи)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если Payments.Количество() = 0 Тогда 
							
		Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
			
			Если Не ЗначениеЗаполнено(PSAContract) 
				ИЛИ Не РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(PSAContract, "ZeroCustomsCharges") Тогда
							
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Payments' table is empty!",
					ЭтотОбъект, "Payments", , Отказ);
				
			КонецЕсли;
			
		ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Payments' table is empty!",
				ЭтотОбъект, "Payments", , Отказ);
								
		ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
			
			Если CustomsDepositAmountToRefund = 0 Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"'Payments' table or 'amount to refund' is empty!",
					ЭтотОбъект, "CustomsDepositAmountToRefund", , Отказ);
				
			КонецЕсли;
				
		КонецЕсли;
		
	Иначе
		
		Для Каждого СтрокаТЧ Из Payments Цикл
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.PaymentKind) Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + " of Payments: ""Payment kind"" is empty!",
					ЭтотОбъект, "Payments[" + (СтрокаТЧ.НомерСтроки-1) + "].PaymentKind", , Отказ);

			Иначе
				
				Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда 
					
					ЭлементФормированияСтоимости = Справочники.ЭлементыФормированияСтоимости.ПолучитьПоPaymentKind(СтрокаТЧ.PaymentKind);
					Если НЕ ЗначениеЗаполнено(ЭлементФормированияСтоимости)
						И Лев(СтрокаТЧ.PaymentKind, 1) <> "9" Тогда
					
						ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
							"In line " + СтрокаТЧ.НомерСтроки + " of Payments: unknown Payment kind '" + СтрокаТЧ.PaymentKind + "'!",
							ЭтотОбъект, "Payments[" + (СтрокаТЧ.НомерСтроки-1) + "].PaymentKind", , Отказ);
							
					КонецЕсли;
						
				КонецЕсли;
			
			КонецЕсли;
			
			Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Sum) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + " of Payments: 'Sum' is empty!",
					ЭтотОбъект, "Payments[" + (СтрокаТЧ.НомерСтроки-1) + "].Sum", , Отказ);
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

// ДОДЕЛАТЬ
Процедура ПоместитьДополнительныеДанныеВДополнительныеСвойства(РежимЗаписи)
	
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	СтруктураПараметров.Вставить("Items", Items.ВыгрузитьКолонку("Item"));
	
	Если НЕ ПометкаУдаления Тогда
		
		// Дубли по Items
		// ОХ НАДО ПОДУМАТЬ, МОЖЕТ БЫТЬ ДУБЛИ ЭФФЕКТИНО ПРОВЕРЯЮТСЯ РЕГИСТРАМИ, ТОГДА ЭТОТ ЗАПРОС НЕ НУЖЕН
		Если Items.Количество() Тогда
				
			СтруктураПараметров.Вставить("TypeOfTransaction", TypeOfTransaction);
			СтруктураТекстов.Вставить("ItemsInOtherCustomsFilesLight", 
				"ВЫБРАТЬ
				|	CustomsFilesLightItems.Item,
				|	CustomsFilesLightItems.Item.Представление КАК ItemПредставление,
				|	CustomsFilesLightItems.Ссылка.Представление КАК CustomsFileLightПредставление
				|ИЗ
				|	Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
				|ГДЕ
				|	CustomsFilesLightItems.Ссылка <> &Ссылка
				|	И НЕ CustomsFilesLightItems.Ссылка.ПометкаУдаления
				|	И CustomsFilesLightItems.Item В(&Items)
				|	И CustomsFilesLightItems.Ссылка.TypeOfTransaction = &TypeOfTransaction");
				
		КонецЕсли;
		          		
	КонецЕсли;
	
	// ЗАЩИТА ОТ ИЗМЕНЕНИЯ
	//СтруктураТекстов.Вставить("TemporaryImportTransactionsOfOldItems",
	//	"ВЫБРАТЬ
	//	|	TemporaryImpExpTransactionsItems.Item.Представление КАК ItemПредставление,
	//	|	TemporaryImpExpTransactionsItems.Ссылка.Представление КАК TemporaryImportTransactionПредставление
	//	|ИЗ
	//	|	Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
	//	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TemporaryImpExpTransactions.Items КАК TemporaryImpExpTransactionsItems
	//	|		ПО CustomsFilesLightItems.Item = TemporaryImpExpTransactionsItems.Item
	//	|			И (TemporaryImpExpTransactionsItems.Ссылка.Проведен)
	//	|ГДЕ
	//	|	TemporaryImpExpTransactionsItems.Ссылка = &Ссылка");
			
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		// реквизиты Shipment
		Если ЗначениеЗаполнено(Shipment) Тогда
			
			СтруктураПараметров.Вставить("Shipment", Shipment);
            СтруктураТекстов.Вставить("РеквизитыShipment");
			ТипЗнчShipment = ТипЗнч(Shipment);	
			Если ТипЗнчShipment = Тип("ДокументСсылка.Поставка") Тогда
					
				СтруктураТекстов.РеквизитыShipment =  
					"ВЫБРАТЬ
					|	ImportShipment.CCA,
					|	ImportShipment.Cleared,
					|	ImportShipment.Проведен,
					|	ImportShipment.Coordinator КАК Specialist,
					|	ImportShipment.ProcessLevel КАК ProcessLevel,
					|	ImportShipment.ProcessLevel.Country КАК Country,
					|	ImportShipment.CCAJobReference		
					|ИЗ
					|	Документ.Поставка КАК ImportShipment
					|ГДЕ
					|	ImportShipment.Ссылка = &Shipment";
								
			ИначеЕсли ТипЗнчShipment = Тип("ДокументСсылка.ExportShipment") Тогда
				
				СтруктураТекстов.РеквизитыShipment = 
					"ВЫБРАТЬ
					|	ExportShipment.CCA,
					|	ExportShipment.ReleasedFromCustoms КАК Cleared,
					|	НЕ ExportShipment.ПометкаУдаления КАК Проведен,
					|	ExportShipment.ExportSpecialist КАК Specialist,
					|	ExportShipment.ProcessLevel КАК ProcessLevel,
					|	ExportShipment.ProcessLevel.Country КАК Country,
					|	"""" КАК CCAJobReference
					|ИЗ
					|	Документ.ExportShipment КАК ExportShipment
					|ГДЕ
					|	ExportShipment.Ссылка = &Shipment";
								
			КонецЕсли;
			      		     					
		КонецЕсли;
		
		// реквизиты Customs file
		Если ЗначениеЗаполнено(CustomsFile) Тогда
			
			СтруктураПараметров.Вставить("CustomsFile", CustomsFile);
			СтруктураТекстов.Вставить("РеквизитыCustomsFile",
				"ВЫБРАТЬ
				|	CustomsFile.CustomsPost,
				|	CustomsFile.Проведен,
				|	CustomsFile.CCA,
				|	CustomsFile.SoldTo,
				|	CustomsFile.ProcessLevel,
				|	CustomsFile.ImportExport,
				|	CustomsFile.Shipment
				|ИЗ
				|	Документ.ГТД КАК CustomsFile
				|ГДЕ
				|	CustomsFile.Ссылка = &CustomsFile");
				
		КонецЕсли;
		
		// реквизиты customs bond
		Если ЗначениеЗаполнено(CustomsBond) Тогда
			
			СтруктураПараметров.Вставить("CustomsBond", CustomsBond);
			СтруктураТекстов.Вставить("РеквизитыCustomsBond", 
				"ВЫБРАТЬ
				|	CustomsFilesLight.CustomsPost,
				|	CustomsFilesLight.Проведен,
				|	CustomsFilesLight.CCA,
				|	CustomsFilesLight.SoldTo,
				|	CustomsFilesLight.ProcessLevel,
				|	CustomsFilesLight.ImportExport
				|ИЗ
				|	Документ.CustomsFilesLight КАК CustomsFilesLight
				|ГДЕ
				|	CustomsFilesLight.Ссылка = &CustomsBond");
		
		КонецЕсли;
		
		// реквизиты Items
		Если Items.Количество() Тогда
			
			СтруктураТекстов.Вставить("Items",
				"ВЫБРАТЬ
				|	Items.Ссылка КАК Item,
				|	Items.SoldTo КАК LegalEntity,
				|	Items.Currency,
				|	Items.PSA КАК PSAContract,
				|	Items.PermanentTemporary,
				|	Items.Количество КАК Qty,
				|	Items.Сумма КАК ItemTotalPrice,
				|	Items.КостЦентр КАК AU,
				|   Items.Классификатор КАК ERPTreatment,
				|	Items.Активити КАК Activity,
				|	Items.Инвойс КАК ImportInvoice,
				|	Items.Инвойс.Проверен КАК ImportInvoiceFinal,
				|	Items.ExportRequest
				|ИЗ
				|	Справочник.СтрокиИнвойса КАК Items
				|ГДЕ
				|	Items.Ссылка В (&Items)");
		
		КонецЕсли;
				
		// реквизиты PO lines		
		МассивPOLines = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Goods, "POLine");			
		Если МассивPOLines.Количество() Тогда
			СтруктураПараметров.Вставить("POLines", МассивPOLines);
			СтруктураТекстов.Вставить("РеквизитыPOLines",
				"ВЫБРАТЬ
				|	POLines.Ссылка КАК POLine,
				|	POLines.КостЦентр КАК AU,
				|	POLines.ПометкаУдаления
				|ИЗ
				|	Справочник.СтрокиЗаявкиНаЗакупку КАК POLines
				|ГДЕ
				|	POLines.Ссылка В(&POLines)");
		КонецЕсли;					
		
		// Attachments
		СтруктураТекстов.Вставить("ПрисоединенныеФайлы", 		
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	CustomsFilesLightПрисоединенныеФайлы.Ссылка
			|ИЗ
			|	Справочник.CustomsFilesLightПрисоединенныеФайлы КАК CustomsFilesLightПрисоединенныеФайлы
			|ГДЕ
			|	CustomsFilesLightПрисоединенныеФайлы.ВладелецФайла = &Ссылка
			|	И НЕ CustomsFilesLightПрисоединенныеФайлы.ПометкаУдаления");
			
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	ДополнительныеСвойства.Вставить("ВыборкаItemsInOtherCustomsFilesLight", Неопределено);
	Если СтруктураРезультатов.Свойство("ItemsInOtherCustomsFilesLight") Тогда
		ДополнительныеСвойства.ВыборкаItemsInOtherCustomsFilesLight = СтруктураРезультатов.ItemsInOtherCustomsFilesLight.Выбрать();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовShipment", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыShipment") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовShipment = СтруктураРезультатов.РеквизитыShipment.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовShipment.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCustomsFile", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsFile") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile = СтруктураРезультатов.РеквизитыCustomsFile.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsFile.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаРеквизитовCustomsBond", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыCustomsBond") Тогда
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsBond = СтруктураРезультатов.РеквизитыCustomsBond.Выбрать();
		ДополнительныеСвойства.ВыборкаРеквизитовCustomsBond.Следующий();
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ТаблицаItems", Неопределено);
	Если СтруктураРезультатов.Свойство("Items") Тогда
		ДополнительныеСвойства.ТаблицаItems = СтруктураРезультатов.Items.Выгрузить();
		ДополнительныеСвойства.ТаблицаItems.Индексы.Добавить("Item");
	КонецЕсли;	
	
	ДополнительныеСвойства.Вставить("ТаблицаPOLines", Неопределено);
	Если СтруктураРезультатов.Свойство("РеквизитыPOLines") Тогда
		ДополнительныеСвойства.ТаблицаPOLines = СтруктураРезультатов.РеквизитыPOLines.Выгрузить();
		ДополнительныеСвойства.ТаблицаPOLines.Индексы.Добавить("POLine");
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ВыборкаПрисоединенныхФайлов", Неопределено);
	Если СтруктураРезультатов.Свойство("ПрисоединенныеФайлы") Тогда
		ДополнительныеСвойства.ВыборкаПрисоединенныхФайлов = СтруктураРезультатов.ПрисоединенныеФайлы.Выбрать();
	КонецЕсли;
		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными()
	
	Если ЗначениеЗаполнено(CustomsPost) Тогда
		CustomsPostNo = СокрЛП(РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(CustomsPost, "Код"));
	Иначе
		CustomsPostNo = "";
	КонецЕсли;
	
	// В Азербайджане и Туркменистане отличается алгоритм нумерации от стандартного
	
	Если ProcessLevel = Справочники.ProcessLevels.AZ Тогда
		
		Если Дата < Дата('20150101') Тогда  // S-I-0000989
			Номер = СокрЛП(CustomsPostNo) + Формат(Дата, "ДФ=yy") + SeqNo;
		КонецЕсли;
		
	ИначеЕсли ProcessLevel = Справочники.ProcessLevels.TM Тогда
		
		Номер = СокрЛП(CustomsPostNo) + Формат(Дата, "ДФ=yy") + SeqNo;
		
	Иначе
		
		// Для всех остальных процесс левелов можно использовать стандартную процедуру
		Номер = CustomsСервер.ПолучитьНомерТаможенногоДокумента(CustomsPostNo, Дата, SeqNo);
		
	КонецЕсли;
	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда 
		Номер = SeqNo;
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаРеквизитовShipment, ВыборкаРеквизитовCustomsFile, ВыборкаРеквизитовCustomsBond, ВыборкаItemsInOtherCustomsFilesLight, ТаблицаItems, ТаблицаPOLines)
																		
	ПроверитьШапкуСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаРеквизитовShipment, ВыборкаРеквизитовCustomsFile, ВыборкаРеквизитовCustomsBond);																	
	
	ПроверитьItemsСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаItemsInOtherCustomsFilesLight, ТаблицаItems);
	
	ПроверитьAUsСДополнительнымиДанными(Отказ, РежимЗаписи, ТаблицаPOLines);	
	
	ПроверитьНаличиеПрисоединенныхФайлов(Отказ, РежимЗаписи, ДополнительныеСвойства.ВыборкаПрисоединенныхФайлов);
		
КонецПроцедуры

Процедура ПроверитьШапкуСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаРеквизитовShipment, ВыборкаРеквизитовCustomsFile, ВыборкаРеквизитовCustomsBond)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
		
	Если НЕ РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// CustomsPost.ProcessLevel vs ProcessLevel
	CustomsPostProcessLevel = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(CustomsPost, "ProcessLevel");
	Если CustomsPostProcessLevel <> ProcessLevel Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Process level '" + СокрЛП(CustomsPostProcessLevel) + "' of Customs post differs from Process level '" + СокрЛП(ProcessLevel) + "' of the document!",
			ЭтотОбъект, "CustomsPost", , Отказ);
	КонецЕсли;
		
	// LegalEntity.Country vs Country
	LegalEntityCountry = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(SoldTo, "Country");
	Если LegalEntityCountry <> Country Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Country '" + СокрЛП(LegalEntityCountry) + "' of Legal entity differs from Country '" + СокрЛП(Country) + "' of the document!",
			ЭтотОбъект, "SoldTo", , Отказ);
	КонецЕсли;
	
	// Сверим реквизиты Regime с реквизитами шапки
	Если ЗначениеЗаполнено(Regime) Тогда
		
		RegimeImportExport = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Regime, "ImportExport");
		Если RegimeImportExport <> ImportExport Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Regime is '" + RegimeImportExport + "', but current document is '" + ImportExport + "'!",
				ЭтотОбъект, "Regime", , Отказ);
		КонецЕсли;
		
		RegimePermTemp = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Regime, "PermanentTemporary");
		Если RegimePermTemp <> PermanentTemporary Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Regime is '" + RegimePermTemp + "', but current document is '" + PermanentTemporary + "'!",
				ЭтотОбъект, "Regime", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(PSAContract) Тогда
		
		PSAContractCountry = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(PSAContract, "Country");
		Если PSAContractCountry <> Country Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Country '" + СокрЛП(PSAContractCountry) + "' of PSA contract differs from Country '" + СокрЛП(Country) + "' of current document!",
				ЭтотОбъект, "PSAContract", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	// Проверим реквизиты Shipment
	Если ЗначениеЗаполнено(Shipment) Тогда
		
		Если НЕ ВыборкаРеквизитовShipment.Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'" + Shipment + "' is not posted!",
				ЭтотОбъект, "Shipment", , Отказ);			
		КонецЕсли;

		Если CCA <> ВыборкаРеквизитовShipment.CCA Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"CCA '" + СокрЛП(ВыборкаРеквизитовShipment.CCA) + "' of Shipment differs from CCA '" + СокрЛП(CCA) + "' of current document!",
				ЭтотОбъект, "Shipment", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовShipment.Country <> Country Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Country '" + СокрЛП(ВыборкаРеквизитовShipment.Country) + "' of Shipment differs from Country '" + СокрЛП(Country) + "' of current document!",
				ЭтотОбъект, "Shipment", , Отказ);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ReleaseDate)
	 		И ЗначениеЗаполнено(ВыборкаРеквизитовShipment.Cleared)
			И ReleaseDate > ВыборкаРеквизитовShipment.Cleared Тогда 
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Cleared date '" + Формат(ВыборкаРеквизитовShipment.Cleared, "ДЛФ=D") + "' of Shipment can not be earlier than Release date '" + Формат(ReleaseDate, "ДЛФ=D") + "' of current document!",
				ЭтотОбъект, "ReleaseDate", , Отказ);
									
		КонецЕсли;
		
	КонецЕсли;
	
	// customs file 			
	Если ЗначениеЗаполнено(CustomsFile) Тогда
		
		Если Не ВыборкаРеквизитовCustomsFile.Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs file is not posted!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
			
		Если ВыборкаРеквизитовCustomsFile.CustomsPost <> CustomsPost Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs post '" + СокрЛП(ВыборкаРеквизитовCustomsFile.CustomsPost) + "' in Customs file differs Customs post of current document!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsFile.CCA <> CCA Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"CCA '" + СокрЛП(ВыборкаРеквизитовCustomsFile.CCA) + "' in Customs file differs from CCA of current document!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsFile.SoldTo <> SoldTo Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Parent company '" + СокрЛП(ВыборкаРеквизитовCustomsFile.SoldTo) + "' in Customs file differs from Parent company of current document!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsFile.ProcessLevel <> ProcessLevel Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Process level '" + СокрЛП(ВыборкаРеквизитовCustomsFile.ProcessLevel) + "' in Customs file differs from Process level of current document!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;

		Если ВыборкаРеквизитовCustomsFile.ImportExport <> ImportExport Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs file is '" + ВыборкаРеквизитовCustomsFile.ImportExport + "', but current document is '" + ImportExport + "'!",
				ЭтотОбъект, "CustomsFile", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsFile.Shipment <> Shipment Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Shipment '" + СокрЛП(ВыборкаРеквизитовCustomsFile.Shipment) + "' of Customs file differs from Shipment of current document!",
				ЭтотОбъект, "CustomsFile", , Отказ);	
		КонецЕсли;
		
	КонецЕсли;
	
	// customs bond 			
	Если ЗначениеЗаполнено(CustomsBond) Тогда
		
		Если Не ВыборкаРеквизитовCustomsBond.Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs bond is not posted!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;
			
		Если ВыборкаРеквизитовCustomsBond.CustomsPost <> CustomsPost Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs post '" + СокрЛП(ВыборкаРеквизитовCustomsBond.CustomsPost) + "' in Customs bond differs Customs post of current document!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsBond.CCA <> CCA Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"CCA '" + СокрЛП(ВыборкаРеквизитовCustomsBond.CCA) + "' in Customs bond differs from CCA of current document!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsBond.SoldTo <> SoldTo Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Parent company '" + СокрЛП(ВыборкаРеквизитовCustomsBond.SoldTo) + "' in Customs bond differs from Parent company of current document!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;
		
		Если ВыборкаРеквизитовCustomsBond.ProcessLevel <> ProcessLevel Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Process level '" + СокрЛП(ВыборкаРеквизитовCustomsBond.ProcessLevel) + "' in Customs bond differs from Process level of current document!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;

		Если ВыборкаРеквизитовCustomsBond.ImportExport <> ImportExport Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Customs bond is '" + ВыборкаРеквизитовCustomsBond.ImportExport + "', but current document is '" + ImportExport + "'!",
				ЭтотОбъект, "CustomsBond", , Отказ);
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьItemsСДополнительнымиДанными(Отказ, РежимЗаписи, ВыборкаItemsInOtherCustomsFilesLight, ТаблицаItems)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	// Проверим что указанные товары не входят в другие Customs files (light)
	Если Items.Количество() Тогда
		
		Пока ВыборкаItemsInOtherCustomsFilesLight.Следующий() Цикл
			
			СтрокаТЧ = Items.Найти(ВыборкаItemsInOtherCustomsFilesLight.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Item '" + СокрЛП(ВыборкаItemsInOtherCustomsFilesLight.ItemПредставление) + "' is already in '" + ВыборкаItemsInOtherCustomsFilesLight.CustomsFileLightПредставление + "'!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
					
		КонецЦикла;
		
	КонецЕсли;
	
	Если НЕ РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	// Проверим табличные части		
	Для Каждого СтрокаТЧ Из Items Цикл
		
		РеквизитыItem = ТаблицаItems.Найти(СтрокаТЧ.Item, "Item");
					
		Если РеквизитыItem.LegalEntity <> SoldTo Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Parent company '" + СокрЛП(РеквизитыItem.LegalEntity) + "' of Item '" + СокрЛП(СтрокаТЧ.Item) + "' differs from Parent company '" + СокрЛП(SoldTo) + "' of current document!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли;
		
		Если ImportExport = Перечисления.ИмпортЭкспорт.Import Тогда
			
			Если НЕ РеквизитыItem.ImportInvoiceFinal Тогда
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Invoice '" + РеквизитыItem.ImportInvoice + "' is not marked as Final!",
					РеквизитыItem.ImportInvoice, "Проверен", , Отказ);
				
			КонецЕсли;
				
		КонецЕсли;
			
		Если ЗначениеЗаполнено(PermanentTemporary) И РеквизитыItem.PermanentTemporary <> PermanentTemporary Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Item '" + СокрЛП(СтрокаТЧ.Item) + "' is marked for '" + РеквизитыItem.PermanentTemporary + "' " + ImportExport + ", but the Customs file (light) is for '" + PermanentTemporary + "' " + ImportExport + "!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(PSAContract) И РеквизитыItem.PSAContract <> PSAContract Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"PSA contract '" + СокрЛП(РеквизитыItem.PSAContract) + "' of Item '" + СокрЛП(СтрокаТЧ.Item) + "' differs from PSA contract '" + СокрЛП(PSAContract) + "' of current document!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(InvoiceCurrency) И РеквизитыItem.Currency <> InvoiceCurrency Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Currency '" + СокрЛП(РеквизитыItem.Currency) + "' of Item '" + СокрЛП(СтрокаТЧ.Item) + "' differs from Invoice currency '" + СокрЛП(InvoiceCurrency) + "' of current document!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли; 			
					
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьAUsСДополнительнымиДанными(Отказ, РежимЗаписи, ТаблицаPOLines)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
		
	Если НЕ РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;						 				
		
	Для Каждого СтрокаТЧ Из Goods Цикл
		
		// AU	
		Если Не Справочники.BORGs.AUs7BORGcodes(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТЧ.POLine, "Владелец.БОРГ.Код"), СтрокаТЧ.AU) Тогда  
			
			AUDefaultActivity = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(СтрокаТЧ.AU, "DefaultActivity");
			Если НЕ ЗначениеЗаполнено(AUDefaultActivity) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": in AU 'Default activity' is empty!",
					ЭтотОбъект, "Goods[" + (СтрокаТЧ.НомерСтроки-1) + "].AU",, Отказ);
			КонецЕсли;
		
		КонецЕсли;

		// PO line
		Если ЗначениеЗаполнено(СтрокаТЧ.POLine) Тогда
			
			РеквизитыPOLine = ТаблицаPOLines.Найти(СтрокаТЧ.POLine, "POLine");	
			Если ЗначениеЗаполнено(СтрокаТЧ.AU)
				И ЗначениеЗаполнено(РеквизитыPOLine.AU)
				И СтрокаТЧ.AU <> РеквизитыPOLine.AU Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"In line " + СтрокаТЧ.НомерСтроки + ": AU '" + СокрЛП(СтрокаТЧ.AU) + "' in line differs from AU '" + СокрЛП(РеквизитыPOLine.AU) + "' in PO line!",
					ЭтотОбъект, "Goods[" + (СтрокаТЧ.НомерСтроки-1) + "].AU", , Отказ);
			КонецЕсли;
							
		КонецЕсли;
			
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьНаличиеПрисоединенныхФайлов(Отказ, РежимЗаписи, ВыборкаПрисоединенныхФайлов)
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыборкаПрисоединенныхФайлов.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Attach scan of the customs file!",
			ЭтотОбъект, , , Отказ);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ОБРАБОТКА ПРОВЕДЕНИЯ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	ДвиженияПоСтоимостиТоваровПоТПО(Отказ);
	
	ДвиженияПоНеоплаченнымТПО(Отказ);
	
	ДвиженияПоCustomsFilesOfItems(Отказ);
	
	ДвиженияПоTemporaryItems(Отказ,
		ДополнительныеСвойства.ВыборкаРеквизитовShipment,
		ДополнительныеСвойства.ТаблицаItems);
	
	ДвиженияПоImportItemsWithoutCustomsFiles(Отказ);
	
	ДвиженияПоExportItemsWithoutCustomsFiles(Отказ, ДополнительныеСвойства.ТаблицаItems);
	
	ДвиженияПоItemsWithoutCVCDecision(Отказ);
	
	ДвиженияПоInvoiceLinesCosts(Отказ, ДополнительныеСвойства.ТаблицаItems);  
	
	ДвиженияПоCustomsDeposits(Отказ);
	
	ДвиженияПоCustomsDepositsToRefund(Отказ);
	
	СформироватьДвиженияInternationalFactCosts(Отказ);
	
КонецПроцедуры
       
Процедура ДвиженияПоНеоплаченнымТПО(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияПоНеоплаченнымТПО = Движения.НеоплаченныеТПО;
	ДвиженияПоНеоплаченнымТПО.Очистить();
	ДвиженияПоНеоплаченнымТПО.Записывать = Истина;
	    	
	Если Payments.Количество() = 0 
		ИЛИ TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
		Возврат;
	КонецЕсли;
	
	// Для некоторых процесс левелов аллокацию платежей не делают, поэтому и отражать их бессмысленно
	Если ProcessLevel = Справочники.ProcessLevels.KZ
		ИЛИ ProcessLevel = Справочники.ProcessLevels.UZ
		ИЛИ ProcessLevel = Справочники.ProcessLevels.AZ
		ИЛИ ProcessLevel = Справочники.ProcessLevels.TM Тогда
		Возврат;
	КонецЕсли;
	
	//{S-I-0000662 - включение пени в зачет депозита по там. расписке - исключаем из неоплаченных ТПО
	МассивСтрокPayments = Новый Массив;
	Для Каждого СтрокаPayments из Payments Цикл 
		Если Не СтрокаPayments.InTheSetoffCustomsDeposit Тогда 
			МассивСтрокPayments.Добавить(СтрокаPayments);	
		КонецЕсли;
	КонецЦикла; 
	
	ТаблицаPayments = Payments.Выгрузить(МассивСтрокPayments, "PaymentKind, PaidByCCA, Sum");
	
	// Очистим Payment kind для Paid by CCA, так как в этом случае Payment kind не отслеживается
	Для Каждого СтрокаТаблицы Из ТаблицаPayments Цикл
		
		Если СтрокаТаблицы.PaidByCCA Тогда
			СтрокаТаблицы.PaymentKind = "";
		КонецЕсли;
		
	КонецЦикла;
	
	ТаблицаPayments.Свернуть("PaymentKind", "Sum");
	
	Для Каждого СтрокаТаблицы Из ТаблицаPayments Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТаблицы.Sum) Тогда
			Продолжить;
		КонецЕсли;
		     				
		ДвиженияПоНеоплаченнымТПО.ДобавитьЗапись(
			ВидДвиженияНакопления.Приход,
			Дата,
			Ссылка,
			СтрокаТаблицы.PaymentKind,
			СтрокаТаблицы.Sum);
									
	КонецЦикла;
			
КонецПроцедуры

Процедура ДвиженияПоСтоимостиТоваровПоТПО(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияПоСтоимостиТоваровПоТПО = Движения.СтоимостьТоваровПоТПО;
	ДвиженияПоСтоимостиТоваровПоТПО.Очистить();
	ДвиженияПоСтоимостиТоваровПоТПО.Записывать = Истина;
	
	Если Payments.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		Возврат;
	КонецЕсли;
	
	// сформируем таблицу сумм, которые будет распределять
	РаспределяемаяТаблица = ПолучитьРаспределяемуюТаблицу();
	  	
	// сформируем таблицу на которую будем распределять суммы
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);   
	Запрос.Текст = "ВЫБРАТЬ
	               |	CustomsFilesLightGoods.POLine.Владелец.БОРГ.Код КАК BORGCode,
	               |	CustomsFilesLightGoods.AU КАК AU,
	               |	CustomsFilesLightGoods.AU.DefaultActivity КАК DefaultActivity,
	               |	СУММА(CustomsFilesLightGoods.InvoiceTotalValue) КАК InvoiceTotalValue
	               |ИЗ
	               |	Документ.CustomsFilesLight.Goods КАК CustomsFilesLightGoods
	               |ГДЕ
	               |	CustomsFilesLightGoods.Ссылка = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	CustomsFilesLightGoods.POLine.Владелец.БОРГ.Код,
	               |	CustomsFilesLightGoods.AU,
	               |	CustomsFilesLightGoods.AU.DefaultActivity";
	
	ТаблицаAU = Запрос.Выполнить().Выгрузить();
	Для Каждого СтрокаТаблицы из ТаблицаAU Цикл   	
		Справочники.BORGs.ПодменитьAU_ACДля7BORGcodes(СтрокаТаблицы, "AU", "DefaultActivity", СтрокаТаблицы.BORGcode);   	
	КонецЦикла;  	
	
	ТаблицаAU.Свернуть("AU,DefaultActivity", "InvoiceTotalValue");
	РаспределеннаяТаблица = ПолучитьРаспределеннуюТаблицу(ТаблицаAU, РаспределяемаяТаблица, "AU, DefaultActivity, InvoiceTotalValue");
	
	// выполним распределение
	CustomsСервер.РаспределитьСуммы(РаспределяемаяТаблица, "ЭлементФормированияСтоимости", "Sum", "Элементы формирования стоимости", "InvoiceTotalValue", "Invoice total value", РаспределеннаяТаблица, Отказ);
	                       
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// добавим движения
	Для Каждого СтрокаРаспределеннойТаблицы Из РаспределеннаяТаблица Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаРаспределеннойТаблицы.Sum) Тогда
			Продолжить;
		КонецЕсли;
		
		ДвиженияПоСтоимостиТоваровПоТПО.ДобавитьЗапись(
			Дата,
			Ссылка,
			СтрокаРаспределеннойТаблицы.ЭлементФормированияСтоимости,
			СтрокаРаспределеннойТаблицы.AU,
			СтрокаРаспределеннойТаблицы.DefaultActivity,
			СтрокаРаспределеннойТаблицы.Sum); 
				
	КонецЦикла;
	     		
КонецПроцедуры

Процедура СформироватьДвиженияInternationalFactCosts(Отказ)
	
	// регистр International Fact Costs   	

	УстановитьПривилегированныйРежим(Истина);
	
	ДвиженияInternationalFactCosts = Движения.InternationalAndDomesticFactCosts;
	
	ДвиженияInternationalFactCosts.Записывать = Истина;
	ДвиженияInternationalFactCosts.Очистить();
	
	Currency = Справочники.CountriesOfProcessLevels.ПолучитьМестнуюВалюту(
		РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(ProcessLevel, "Country"));
	Если Не ЗначениеЗаполнено(Currency) Тогда 
		Currency = InvoiceCurrency;	
	КонецЕсли;
	
	СurrencyUSD = Справочники.Валюты.НайтиПоКоду("840");
	ИсключаемыеИзЗатратERPTreatments = ImportExportСерверПовтИспСеанс.ПолучитьИсключаемыеИзЗатратERPTreatments();
	
	Если Currency <> СurrencyUSD Тогда
		СтруктураСurrency = ОбщегоНазначения.ПолучитьКурсВалюты(Currency, ReleaseDate);
		СтруктураСurrencyUSD = ОбщегоНазначения.ПолучитьКурсВалюты(СurrencyUSD, ReleaseDate);
	КонецЕсли;
	
	PaymentsSum = 0;
	      	
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		
		Для Каждого СтрPayments из Payments Цикл 
			Если Лев(СтрPayments.PaymentKind, 1) <> "5" 
				И Не СтрPayments.PaidByCCA
				И Не СтрPayments.InTheSetoffCustomsDeposit Тогда
				PaymentsSum = PaymentsSum + СтрPayments.Sum;
			КонецЕсли;
		КонецЦикла;
		
		Если PaymentsSum = 0 Тогда 
			Возврат;
		КонецЕсли;
		
		Если Currency <> СurrencyUSD Тогда
			PaymentsSum = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(PaymentsSum, 
				Currency, СurrencyUSD, 
				СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Goods", Goods.Выгрузить(,"AU,InvoiceTotalValue"));
		
		Запрос.Текст = "ВЫБРАТЬ
		|	Goods.AU КАК AU,
		|	Goods.InvoiceTotalValue КАК InvoiceTotalValue
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&Goods КАК Goods
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ.AU.Segment КАК Segment,
		|	ВТ.AU.SubSegment КАК SubSegment,
		|	ВТ.AU.Geomarket КАК Geomarket,
		|	ВТ.AU.SubGeomarket КАК SubGeomarket,
		|	ВТ.InvoiceTotalValue КАК InvoiceTotalValue,
		|	0 КАК Sum
		|ИЗ
		|	ВТ КАК ВТ";
		
		ТЗLines = Запрос.Выполнить().Выгрузить();
		
		ТЗLines.Свернуть("Segment,SubSegment,Geomarket,SubGeomarket", "InvoiceTotalValue,Sum");
		
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗLines.ВыгрузитьКолонку("InvoiceTotalValue"), PaymentsSum, ТЗLines, "Sum");
				
		Для Каждого СтрокаТЗ Из ТЗLines Цикл
			
			Движение = ДвиженияInternationalFactCosts.Добавить();
			
			Движение.Период = НачалоМесяца(?(День(ReleaseDate) > 25, ДобавитьМесяц(ReleaseDate, 1), ReleaseDate));
			Движение.CostsType = Перечисления.FactCostsTypes.CustomsDuties_Fees;
			Движение.DomesticInternational = Перечисления.DomesticInternational.International;
			
			Движение.ParentCompany = SoldTo;
			Движение.Geomarket = СтрокаТЗ.Geomarket;
			Движение.SubGeomarket = СтрокаТЗ.SubGeomarket;
			Движение.Segment = СтрокаТЗ.Segment;
			Движение.SubSegment = СтрокаТЗ.SubSegment;
			
			Движение.Sum = СтрокаТЗ.Sum;
			
		КонецЦикла;
		
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		     		
		Для Каждого СтрPayments из Payments Цикл 
			Если Лев(СтрPayments.PaymentKind, 1) <> "3"  Тогда  //считаем что VAT для AZ начинается с "3"
				PaymentsSum = PaymentsSum + СтрPayments.Sum;
			КонецЕсли;
		КонецЦикла;
		
		Если PaymentsSum = 0 Тогда 
			Возврат;
		КонецЕсли;
		
		Если Currency <> СurrencyUSD Тогда
			PaymentsSum = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(PaymentsSum, 
				Currency, СurrencyUSD, 
				СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
		КонецЕсли;
			
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Items", Items.Выгрузить(,"Item"));
		
		Запрос.Текст = "ВЫБРАТЬ
		|	Items.Item КАК Item
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&Items КАК Items
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ.Item.КостЦентр.Segment КАК Segment,
		|	ВТ.Item.КостЦентр.SubSegment КАК SubSegment,
		|	ВТ.Item.КостЦентр.Geomarket КАК Geomarket,
		|	ВТ.Item.КостЦентр.SubGeomarket КАК SubGeomarket,
		|	ВТ.Item.Классификатор КАК ERPTreatment,
		|	СУММА(ВТ.Item.Сумма) КАК ItemСумма,
		|	СУММА(0) КАК Sum
		|ИЗ
		|	ВТ КАК ВТ
		|
		|СГРУППИРОВАТЬ ПО
		|	ВТ.Item.КостЦентр.Segment,
		|	ВТ.Item.КостЦентр.SubSegment,
		|	ВТ.Item.КостЦентр.SubGeomarket,
		|	ВТ.Item.КостЦентр.Geomarket,
		|	ВТ.Item.Классификатор";
		
		ТЗLines = Запрос.Выполнить().Выгрузить();
		
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗLines.ВыгрузитьКолонку("ItemСумма"), PaymentsSum, ТЗLines, "Sum");
		
		ТЗLinesБезИсключаемыхERP = ТЗLines.СкопироватьКолонки();
		Для Каждого Стр из ТЗLines Цикл
			
			Если ИсключаемыеИзЗатратERPTreatments.Найти(Стр.ERPTreatment) <> Неопределено Тогда 
				Продолжить;
			КонецЕсли;	
			
			СтрокаТЗ = ТЗLinesБезИсключаемыхERP.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТЗ, Стр);
			
		КонецЦикла;
		
		ТЗLinesБезИсключаемыхERP.Колонки.Удалить("ERPTreatment");  
		ТЗLinesБезИсключаемыхERP.Свернуть("Geomarket,SubGeomarket,Segment,SubSegment", "ItemСумма,Sum");
		        		      
		Для Каждого СтрокаТЗ Из ТЗLinesБезИсключаемыхERP Цикл
			
			Движение = ДвиженияInternationalFactCosts.Добавить();
			
			Движение.Период = НачалоМесяца(?(День(ReleaseDate) > 25, ДобавитьМесяц(ReleaseDate, 1), ReleaseDate));
			Движение.CostsType = Перечисления.FactCostsTypes.CustomsDuties_Fees;
			Движение.DomesticInternational = Перечисления.DomesticInternational.International;
			
			Движение.ParentCompany = SoldTo;
			Движение.Geomarket = СтрокаТЗ.Geomarket;
			Движение.SubGeomarket = СтрокаТЗ.SubGeomarket;
			Движение.Segment = СтрокаТЗ.Segment;
			Движение.SubSegment = СтрокаТЗ.SubSegment;
			
			Движение.Sum = СтрокаТЗ.Sum;
			
		КонецЦикла;
		
	КонецЕсли;
	
			  		
КонецПроцедуры

Процедура ДвиженияПоCustomsFilesOfItems(Отказ)
	
	Движения.CustomsFilesOfGoods.Очистить();
	Движения.CustomsFilesOfGoods.Записывать = Истина;
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл
		
		Движения.CustomsFilesOfGoods.ДобавитьЗапись(
			СтрокаТЧ.Item,
			Ссылка,
			Номер);
			
	КонецЦикла;
		
КонецПроцедуры

Процедура ДвиженияПоTemporaryItems(Отказ, ВыборкаРеквизитовShipment, ТаблицаItems)
		
	Движения.ExpiryDatesOfItemsInTemporaryImpExp.Очистить();
	Движения.ExpiryDatesOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Движения.QtyOfItemsInTemporaryImpExp.Очистить();
	Движения.QtyOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Движения.ResponsiblesForItemsInTemporaryImpExp.Очистить();
	Движения.ResponsiblesForItemsInTemporaryImpExp.Записывать = Истина;
	
	Движения.AdditionalDataOfItemsInTemporaryImpExp.Очистить();
	Движения.AdditionalDataOfItemsInTemporaryImpExp.Записывать = Истина;
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		Возврат;
	КонецЕсли;
	
	Если PermanentTemporary <> Перечисления.PermanentTemporary.Temporary Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из Items Цикл

		// Отразим в expiry date
		Движения.ExpiryDatesOfItemsInTemporaryImpExp.ДобавитьЗапись(
			Дата,
			СтрокаТЧ.Item,
			ExpiryDate);
		
		РеквизитыItem = ТаблицаItems.Найти(СтрокаТЧ.Item, "Item");
		
		// Отразим количество
		Движения.QtyOfItemsInTemporaryImpExp.ДобавитьЗапись(
			ВидДвиженияНакопления.Приход,
			Дата,
			СтрокаТЧ.Item,
			РеквизитыItem.Qty);
		
		// Отразим ответственного
		Движения.ResponsiblesForItemsInTemporaryImpExp.ДобавитьЗапись(
			Дата,
			СтрокаТЧ.Item,
			ВыборкаРеквизитовShipment.Specialist);
		
		// Отразим дополнительные данные
		Движения.AdditionalDataOfItemsInTemporaryImpExp.ДобавитьЗапись(
			Дата,
			СтрокаТЧ.Item,
			ВыборкаРеквизитовShipment.ProcessLevel,
			Regime,
			ВыборкаРеквизитовShipment.CCAJobReference);
			
	КонецЦикла;
			
КонецПроцедуры

// ДОДЕЛАТЬ
Процедура ДвиженияПоImportItemsWithoutCustomsFiles(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияImportItemsWithoutCustomsFiles = Движения.ImportItemsWithoutCustomsFiles;
	ДвиженияImportItemsWithoutCustomsFiles.Очистить();
	ДвиженияImportItemsWithoutCustomsFiles.Записывать = Истина;
	
	Если ТипЗнч(Shipment) <> Тип("ДокументСсылка.Поставка") Тогда
		Возврат;
	КонецЕсли;
	
	// ДУМАТЬ, ЧТО ДЕЛАТЬ С ТПО
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда 
		Возврат;	
	КонецЕсли;
	
	// Добавим движения
	Для Каждого Стр из Items Цикл
		ДвиженияImportItemsWithoutCustomsFiles.ДобавитьЗапись(
			ВидДвиженияНакопления.Расход,
			ReleaseDate,
			Стр.Item,
			Shipment);
	КонецЦикла;
	
	// Проверим остатки
	ДвиженияImportItemsWithoutCustomsFiles.Записать();
		
	ТаблицаОстатков = РегистрыНакопления.ImportItemsWithoutCustomsFiles.ПолучитьОстаткиПоItems(
						Новый Граница(ReleaseDate, ВидГраницы.Включая),
						Items.ВыгрузитьКолонку("Item"));
	СообщитьОбОстаткахItemsWithoutCustomsFiles(Отказ, ТаблицаОстатков, "ImportShipment");
	
КонецПроцедуры

// ДОДЕЛАТЬ
Процедура ДвиженияПоExportItemsWithoutCustomsFiles(Отказ, ТаблицаItems)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДвиженияExportItemsWithoutCustomsFiles = Движения.ExportItemsWithoutCustomsFiles;
	ДвиженияExportItemsWithoutCustomsFiles.Очистить();
	ДвиженияExportItemsWithoutCustomsFiles.Записывать = Истина;
	
	Если ТипЗнч(Shipment) <> Тип("ДокументСсылка.ExportShipment") Тогда
		Возврат;
	КонецЕсли;

	// ДУМАТЬ, ЧТО ДЕЛАТЬ С ТПО
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда 
		Возврат;	
	КонецЕсли;
	
	// Добавим движения
	Для Каждого Стр из Items Цикл
		
		РеквизитыItem = ТаблицаItems.Найти(Стр.Item, "Item");
		
		ДвиженияExportItemsWithoutCustomsFiles.ДобавитьЗапись(
			ВидДвиженияНакопления.Расход,
			ReleaseDate,
			Стр.Item,
			РеквизитыItem.ExportRequest,
			Shipment);
				
	КонецЦикла;
	
	// Проверим остатки
	ДвиженияExportItemsWithoutCustomsFiles.Записать();
	
	ТаблицаОстатков = РегистрыНакопления.ExportItemsWithoutCustomsFiles.ПолучитьОстаткиПоItems(
						Новый Граница(ReleaseDate, ВидГраницы.Включая),
						Items.ВыгрузитьКолонку("Item"));
	СообщитьОбОстаткахItemsWithoutCustomsFiles(Отказ, ТаблицаОстатков, "ExportShipment");
		
КонецПроцедуры

Процедура СообщитьОбОстаткахItemsWithoutCustomsFiles(Отказ, ТаблицаОстатков, ИмяИзмеренияShipment)
	
	Для Каждого СтрокаОстатков Из ТаблицаОстатков Цикл
		
		Если СтрокаОстатков.РесурсОстаток < 0 Тогда
			
			СтрокаТЧ = Items.Найти(СтрокаОстатков.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + " of 'Items': Item '" + СокрЛП(СтрокаОстатков.Item) + "' does not belong to '" + Shipment + "' or Shipment is not posted (submitted to customs) yet or Release date is earlier than Released from customs in shipment!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
				
		ИначеЕсли СтрокаОстатков.РесурсОстаток > 0 Тогда
			
			СтрокаТЧ = Items.Найти(СтрокаОстатков.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"In line " + СтрокаТЧ.НомерСтроки + " of 'Items': Item '" + СокрЛП(СтрокаОстатков.Item) + "' is in '" + СтрокаОстатков[ИмяИзмеренияShipment] + "', not in '" + Shipment + "'!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
				
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДвиженияПоItemsWithoutCVCDecision(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Движения.ItemsWithoutCVCDecision.Очистить();
	Движения.ItemsWithoutCVCDecision.Записывать = Истина;
	
	// Определим параметры движений
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond Тогда 		
		ВидДвижения = ВидДвиженияНакопления.Приход;
		Документ    = Ссылка;
	
	ИначеЕсли TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда		
		ВидДвижения = ВидДвиженияНакопления.Расход;
		Документ    = CustomsBond;
	
	Иначе	
		Возврат;
		
	КонецЕсли;
	
	// Добавим движения
	Для Каждого СтрокаТЧ Из Items Цикл
		Движения.ItemsWithoutCVCDecision.ДобавитьЗапись(
			ВидДвижения,
			Дата,
			СтрокаТЧ.Item,
			Документ);
	КонецЦикла;
		
	// Проверим остатки
	Движения.ItemsWithoutCVCDecision.Записать();	
	ТаблицаОстатков = РегистрыНакопления.ItemsWithoutCVCDecision.ПолучитьОстаткиПоItems(
		 Новый Граница(МоментВремени(), ВидГраницы.Включая),
		 Items.ВыгрузитьКолонку("Item"));		
	Для Каждого СтрокаОстатков Из ТаблицаОстатков Цикл
		
		Если СтрокаОстатков.РесурсОстаток > 1 Тогда
			
			СтрокаТЧ = Items.Найти(СтрокаОстатков.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Item '" + СокрЛП(СтрокаОстатков.Item) + "' is already waiting for decision on '" + СтрокаОстатков.CustomsBond + "'!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
		
		ИначеЕсли СтрокаОстатков.РесурсОстаток < 0 Тогда
			
			СтрокаТЧ = Items.Найти(СтрокаОстатков.Item, "Item");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Item '" + СокрЛП(СтрокаОстатков.Item) + "' already has decision on '" + СтрокаОстатков.CustomsBond + "'!",
				ЭтотОбъект, "Items[" + (СтрокаТЧ.НомерСтроки-1) + "].Item", , Отказ);
			
		КонецЕсли;
		
	КонецЦикла;
	 	
КонецПроцедуры
  
Процедура ДвиженияПоInvoiceLinesCosts(Отказ, ТаблицаItems)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Движения.InvoiceLinesCosts.Очистить();
	Движения.InvoiceLinesCosts.Записывать = Истина;
	
	Если Payments.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
	//включить когда заработает справочник payment kinds
	//Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
	//Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
 	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing
		И TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		Возврат;
	КонецЕсли;
	
	// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
	Если TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
		// сформируем таблицу с суммами, в случае оредера данные берем из табличной части "Goods/AUs"
		Для Каждого СтрокаGoods Из Goods Цикл
			Если НЕ ЗначениеЗаполнено(СтрокаGoods.InvoiceLine) Тогда
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = НСтр("ru = 'Не заполнен реквизит ""Invoice line"" в документе!';en = 'Not filled in the detail ""Invoice line"" in the document!'");
				Сообщение.Сообщить();
				Отказ = Истина;
			КонецЕсли;	
		КонецЦикла;	
		РаспределеннаяТаблица = Goods.Выгрузить();
		СкорректироватьРаспределеяемуюТаблицу(РаспределеннаяТаблица);
	Иначе
	// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		// сформируем таблицу с суммами, которые будем распределять
		РаспределяемаяТаблица = ПолучитьРаспределяемуюТаблицу();	
		
		// сформируем таблицу на которую будем распределять суммы
		РаспределеннаяТаблица = ПолучитьРаспределеннуюТаблицу(ТаблицаItems, РаспределяемаяТаблица, "Item, ItemTotalPrice");
			
		// выполним распределение
		CustomsСервер.РаспределитьСуммы(РаспределяемаяТаблица, "ЭлементФормированияСтоимости", "Sum", 
							"Элементы формирования стоимости", "ItemTotalPrice", "Item total price", РаспределеннаяТаблица, Отказ);
	// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
	КонецЕсли;
	// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710

	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Движения по регистру
	
	CurrencyRUB = Справочники.Валюты.НайтиПоКоду("643");
	Для Каждого СтрокаРаспределеннойТаблицы Из РаспределеннаяТаблица Цикл
		
		// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
		//Если СтрокаРаспределеннойТаблицы.Sum = 0 Тогда 
		Если СтрокаРаспределеннойТаблицы.Sum = 0 ИЛИ СтрокаРаспределеннойТаблицы.InvoiceTotalValue = 0 Тогда 
		// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
			Продолжить;
		КонецЕсли;
		
		Движения.InvoiceLinesCosts.ДобавитьЗапись(
			Дата,
			СтрокаРаспределеннойТаблицы.Item,
			СтрокаРаспределеннойТаблицы.ЭлементФормированияСтоимости,
			Ссылка,
			CurrencyRUB,
			СтрокаРаспределеннойТаблицы.Sum,
			// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
			//СтрокаРаспределеннойТаблицы.Sum);
			СтрокаРаспределеннойТаблицы.Sum,
			СтрокаРаспределеннойТаблицы.InvoiceCorrectionValue);
			// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
	КонецЦикла;
	           	
КонецПроцедуры

Функция ПолучитьРаспределяемуюТаблицу()
	
	// Создает из таблицы платежей таблицу с суммами, которые нужно распределить на товары
	
	РаспределяемаяТаблица = Payments.ВыгрузитьКолонки("Sum");
	
	ТипЭлементФормированияСтоимости = Новый ОписаниеТипов("СправочникСсылка.ЭлементыФормированияСтоимости");	
	РаспределяемаяТаблица.Колонки.Добавить("ЭлементФормированияСтоимости", ТипЭлементФормированияСтоимости);
	
	ЭлементыФормированияСтоимости = Справочники.ЭлементыФормированияСтоимости;
	
	Для Каждого СтрокаPayments Из Payments Цикл
		
		ЭлементФормированияСтоимости = Справочники.ЭлементыФормированияСтоимости.ПолучитьПоPaymentKind(СокрЛП(СтрокаPayments.PaymentKind));
		
		// Если элемент стоимости определить не удалось - этот Payment kind не участвует в формировании стоимости
		// То что это не какая-то ошибка проверяется выше в ПроверитьPaymentsБезДополнительныхДанных
		Если НЕ ЗначениеЗаполнено(ЭлементФормированияСтоимости) Тогда
			Продолжить;
		КонецЕсли;
		
		НоваяСтрокаРаспределяемойТаблицы = РаспределяемаяТаблица.Добавить();
		НоваяСтрокаРаспределяемойТаблицы.ЭлементФормированияСтоимости = ЭлементФормированияСтоимости;
		НоваяСтрокаРаспределяемойТаблицы.Sum = СтрокаPayments.Sum;
		
	КонецЦикла;
	
	РаспределяемаяТаблица.Свернуть("ЭлементФормированияСтоимости", "Sum");
	
	Возврат РаспределяемаяТаблица;
	
КонецФункции

Функция ПолучитьРаспределеннуюТаблицу(ТаблицаТоваров, РаспределяемаяТаблица, СтрокаКопируемыхКолонок)
	
	// подготавливает таблицу для распределения платежей на товары
	
	РаспределеннаяТаблица = ТаблицаТоваров.СкопироватьКолонки(СтрокаКопируемыхКолонок);
	
	ТипЭлементФормированияСтоимости = Новый ОписаниеТипов("СправочникСсылка.ЭлементыФормированияСтоимости");
 	РаспределеннаяТаблица.Колонки.Добавить("ЭлементФормированияСтоимости", ТипЭлементФормированияСтоимости);
		
	ТипЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2));
	РаспределеннаяТаблица.Колонки.Добавить("Sum", ТипЧисло);
		
	Для Каждого СтрокаРаспределяемойТаблицы Из РаспределяемаяТаблица Цикл
		ДобавитьВРаспределеннуюТаблицуПорциюСтрок(РаспределеннаяТаблица, ТаблицаТоваров, СтрокаРаспределяемойТаблицы.ЭлементФормированияСтоимости, СтрокаКопируемыхКолонок);
	КонецЦикла;
		
	Возврат РаспределеннаяТаблица;
	
КонецФункции

Процедура ДобавитьВРаспределеннуюТаблицуПорциюСтрок(РаспределеннаяТаблица, ТаблицаТоваров, ЭлементФормированияСтоимости, СтрокаКопируемыхКолонок)
	               	
	ЭлементыФормированияСтоимости = Справочники.ЭлементыФормированияСтоимости;
	
	// УДАЛИТЬ ACCOUNT
	//Если ЭлементФормированияСтоимости = ЭлементыФормированияСтоимости.ТаможняПошлины
	//	ИЛИ ЭлементФормированияСтоимости = ЭлементыФормированияСтоимости.ТаможняСборы Тогда
	//	Account = "531006";
	//ИначеЕсли ЭлементФормированияСтоимости = ЭлементыФормированияСтоимости.ТаможняНДС Тогда
	//	Account = "";
	//КонецЕсли;
	
	Для Каждого СтрокаТаблицыТоваров Из ТаблицаТоваров Цикл
		
		НоваяСтрокаРаспределеннойТаблицы = РаспределеннаяТаблица.Добавить();
		
		ЗаполнитьЗначенияСвойств(НоваяСтрокаРаспределеннойТаблицы, СтрокаТаблицыТоваров, СтрокаКопируемыхКолонок);
		
		НоваяСтрокаРаспределеннойТаблицы.ЭлементФормированияСтоимости = ЭлементФормированияСтоимости;
		  		
	КонецЦикла;
	
КонецПроцедуры

Процедура ДвиженияПоCustomsDeposits(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Движения.CustomsDeposits.Очистить();
	Движения.CustomsDeposits.Записывать = Истина;
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда
		Возврат;
	КонецЕсли;
	
	// добавим расход
	PaymentsWithDepositToRefund = CustomsDepositAmountToRefund + Payments.Итог("Sum");	
	Движения.CustomsDeposits.ДобавитьЗапись(
		ВидДвиженияНакопления.Расход,
		Дата,
		CustomsBond,
		PaymentsWithDepositToRefund);
		
	// запишем движение и проверим остатки
	Движения.CustomsDeposits.Записать();
	Граница = Новый Граница(МоментВремени(), ВидГраницы.Включая);
	ОстатокПоCustomsBond = РегистрыНакопления.CustomsDeposits.ПолучитьОстатокПоCustomsBond(Граница, CustomsBond);
	Если ОстатокПоCustomsBond < 0 Тогда
		Сообщить("Payments (" + Payments.Итог("Sum") + ") + deposit to refund (" + CustomsDepositAmountToRefund + ") exceed previous customs bond sum by " + (-ОстатокПоCustomsBond) + "!");
		Отказ = Истина;	
	КонецЕсли;
 	
КонецПроцедуры

Процедура ДвиженияПоCustomsDepositsToRefund(Отказ)
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Движения.CustomsDepositsToRefund.Записывать = Истина;
	Движения.CustomsDepositsToRefund.Очистить();
	
	Если TypeOfTransaction <> Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing Тогда  
		Возврат;
	КонецЕсли;	
	
	Если CustomsDepositRefundTo <> Перечисления.CustomsDepositsRefundTo.BankAccount Тогда  
		Возврат;
	КонецЕсли;
	
	Если CustomsDepositAmountToRefund = 0 Тогда
		Возврат;
	КонецЕсли;

	Движения.CustomsDepositsToRefund.ДобавитьЗапись(
		ВидДвиженияНакопления.Приход,
		Дата,
		CustomsBond,
		CustomsDepositAmountToRefund);
	 	
КонецПроцедуры

// { RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
Процедура СкорректироватьРаспределеяемуюТаблицу(ТаблицаДляКорректировки)
	
	ТипЧисло = Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,2));
	ТаблицаДляКорректировки.Колонки.Добавить("Sum", ТипЧисло);
	
	ТипЭлементФормированияСтоимости = Новый ОписаниеТипов("СправочникСсылка.ЭлементыФормированияСтоимости");
 	ТаблицаДляКорректировки.Колонки.Добавить("ЭлементФормированияСтоимости", ТипЭлементФормированияСтоимости);
	
	МассивЭлементовФормированияСтоимости = Новый Массив;
	МассивЭлементовФормированияСтоимости.Добавить(Справочники.ЭлементыФормированияСтоимости.ИнвойсСуммаСтрокиИнвойса);
	ТаблицаДляКорректировки.ЗагрузитьКолонку(МассивЭлементовФормированияСтоимости, "ЭлементФормированияСтоимости");
	ТаблицаДляКорректировки.ЗаполнитьЗначения(Справочники.ЭлементыФормированияСтоимости.ИнвойсСуммаСтрокиИнвойса,"ЭлементФормированияСтоимости"); 

	МассивСумм = ТаблицаДляКорректировки.ВыгрузитьКолонку("InvoiceTotalValue");
	ТаблицаДляКорректировки.ЗагрузитьКолонку(МассивСумм,"Sum");
	
	ТипСтрокиИнвойсов = Новый ОписаниеТипов("СправочникСсылка.СтрокиИнвойса");
	ТаблицаДляКорректировки.Колонки.Добавить("Item", ТипСтрокиИнвойсов);
	
	МассивItem = ТаблицаДляКорректировки.ВыгрузитьКолонку("InvoiceLine");
	ТаблицаДляКорректировки.ЗагрузитьКолонку(МассивItem,"Item");
	 
	//// определяем строки инвойса(item)
	//Если ТипЗнч(Shipment) = Тип("ДокументСсылка.Поставка") Тогда
	//	МассивDOCs = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Shipment.УпаковочныеЛисты, "УпаковочныйЛист");
	//	Если МассивDOCs.Количество() = 0 Тогда
	//		Возврат;
	//	КонецЕсли;
	//	ДанныеПоShipment = ПолучитьДанныеItems(МассивDOCs);
	//	ТаблицаItems = ДанныеПоShipment.Скопировать();
	//
	//ИначеЕсли ТипЗнч(Shipment) = Тип("ДокументСсылка.ExportShipment") Тогда
	//	ДанныеПоВсемЗаявкам = ПолучитьДанныеItemsExportRequest(Shipment.ExportRequests[0].ExportRequest);
	//	ДанныеПоВсемЗаявкам.Очистить();									
	//	Для Каждого СтрокаExportRequests Из Shipment.ExportRequests Цикл
	//		ДанныеПоЗаявке = ПолучитьДанныеItemsExportRequest(СтрокаExportRequests.ExportRequest);
	//		Если ДанныеПоЗаявке <> Неопределено Тогда
	//			ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ДанныеПоВсемЗаявкам,ДанныеПоЗаявке); 
	//		КонецЕсли;	
	//	КонецЦикла;
	//	ТаблицаItems = ДанныеПоВсемЗаявкам.Скопировать();
	//КонецЕсли;		
	//
	//// дозаполнение таблицы строками инвойса
	//Для Каждого СтрокаТаблицаДляКорректировки Из ТаблицаДляКорректировки Цикл
	//	СтруктураПоиска = Новый Структура;
	//	СтруктураПоиска.Вставить("POLine", СтрокаТаблицаДляКорректировки.POLine); 
	//	РезультатПоиска = ТаблицаItems.НайтиСтроки(СтруктураПоиска);
	//	Если РезультатПоиска.Количество() Тогда
	//		СтрокаТаблицаДляКорректировки.Item = РезультатПоиска[0];
	//	КонецЕсли;
	//КонецЦикла;	
	
КонецПроцедуры 

Функция ПолучитьДанныеItems(МассивDOCs)
	
	МассивСтруктур = Новый Массив;
	Если МассивDOCs.Количество() = 0 Тогда
		Возврат МассивСтруктур;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивDOCs", МассивDOCs);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Items.Ссылка КАК Item,
		|	Items.СтрокаЗаявкиНаЗакупку КАК POline
		|ИЗ
		|	Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК DOCsInvoices
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
		|		ПО DOCsInvoices.Инвойс = Items.Инвойс
		|			И (НЕ Items.ПометкаУдаления)
		|ГДЕ
		|	DOCsInvoices.Ссылка В(&МассивDOCs)";
		
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ТаблицаItems = РезультатЗапроса.Выгрузить();
	Иначе
		ТаблицаItems = Неопределено;
	КонецЕсли;
	
	Возврат ТаблицаItems;
	
КонецФункции

Функция ПолучитьСтрокуРеквизитовItem()
	
	Возврат "Item, DOC, DOCNo, Invoice, InvoiceNo, LineNo, PONo, SegmentCode, PartNo, SerialNo, ItemDescription, Qty, QtyUOMCode, Price, CurrencyCode, Sum, SoldToCode, CountryOfOrigin, Manufacturer, HTC, NetWeight, WeightUOMCode, PSAContract, PSAContractCode, PermanentTemporary, PermitsRequired, COORequired, AUCode, Activity, Shortage, OLDShortage, GuaranteeLetter, MOC, ConfirmationOfCargoLatestDate, CustomsBSReceiptDate";
	
КонецФункции

Функция ПолучитьДанныеItemsExportRequest(ExportRequest)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СправочникСтрокиИнвойса.Ссылка КАК Item,
		|	СправочникСтрокиИнвойса.СтрокаЗаявкиНаЗакупку КАК POline
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СправочникСтрокиИнвойса
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.TDStatuses.СрезПоследних КАК TDStatusesСрезПоследних
		|		ПО СправочникСтрокиИнвойса.Ссылка = TDStatusesСрезПоследних.Item
		|			И (TDStatusesСрезПоследних.DOC = &ExportRequest)
		|			И (TDStatusesСрезПоследних.PartNo.Код = СправочникСтрокиИнвойса.КодПоИнвойсу)
		|ГДЕ
		|	СправочникСтрокиИнвойса.ExportRequest = &ExportRequest";
	
	Запрос.УстановитьПараметр("ExportRequest", ExportRequest);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ТаблицаItems = РезультатЗапроса.Выгрузить();
	Иначе
		ТаблицаItems = Неопределено;
	КонецЕсли;
	
	Возврат ТаблицаItems;
	
КонецФункции	
// } RGS AFokin 19.09.2018 23:59:59 - S-I-0005710
	