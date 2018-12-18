
//////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	ЗаполнитьКеш();
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
		
	НастроитьЭлементы();
	
	Если Элементы.CustomsDepositSum.Видимость Тогда 
		CustomsDepositSum = ПолучитьCustomsDepositSumНаСервере(Объект.Дата, Объект.Ссылка, Объект.CustomsBond);
	КонецЕсли;
	
	ЗаполнитьДополнительныеКолонкиItems();
		
	ЗаполнитьBatchOfCustomsFilesиBoxOfCustomsFiles();	
	
	НастроитьUnpostИSaveDraft();
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.ТПООткрытие, Объект.Ссылка);
	
	// { RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	ПараметрПоиска = Новый Структура;
	ПараметрПоиска.Вставить("DescriptionForCustoms", ПредопределенноеЗначение("Перечисление.DescriptionForCustoms.Other"));
	НайденныеСтроки = Объект.Goods.НайтиСтроки(ПараметрПоиска);
	Если НайденныеСтроки.Количество() Тогда
		Элементы.AUsItemDescription.Видимость = Истина;
	КонецЕсли;
	
	ЕстьДанныеПоPOLine = Ложь;
	Для каждого СтрокаGoods Из Объект.Goods Цикл
		Если ЗначениеЗаполнено(СтрокаGoods.POLine) Тогда
			ЕстьДанныеПоPOLine = Истина;
			Прервать;
		КонецЕсли;	
	КонецЦикла;	
	
	Если ЕстьДанныеПоPOLine Тогда
		Элементы.AUsPOLine.Видимость = Истина;
	Иначе
		Элементы.AUsPOLine.Видимость = Ложь;
	КонецЕсли;
	// } RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	
КонецПроцедуры

&НаСервере
Процедура НастроитьUnpostИSaveDraft()
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда 
		Объект.Дата = Неопределено;	
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКеш()
	
	TypeOfTransactionCustomsFile = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight;
	TypeOfTransactionCustomsBond = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBond;
	TypeOfTransactionCustomsBondClosing = Перечисления.TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
КонецПроцедуры

// ДОДЕЛАТЬ
&НаСервере
Процедура ЗаполнитьBatchOfCustomsFilesиBoxOfCustomsFiles()
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Возврат;
	КонецЕсли;
	     		
	УстановитьПривилегированныйРежим(Истина);
	
	Если ЗначениеЗаполнено(Объект.TypeOfTransaction) Тогда
		
		Если Объект.TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО Тогда
			
			BatchOfCustomsFiles = Документы.BatchesOfCustomsFiles.ПолучитьПоCustomsReceiptOrder(Объект.Ссылка);
			
		ИначеЕсли Объект.TypeOfTransaction = TypeOfTransactionCustomsBond Тогда
			
			BatchOfCustomsFiles = Документы.BatchesOfCustomsFiles.ПолучитьПоCustomsBond(Объект.Ссылка);
	
		ИначеЕсли Объект.TypeOfTransaction = TypeOfTransactionCustomsBondClosing Тогда	
			
			BatchOfCustomsFiles = Документы.BatchesOfCustomsFiles.ПолучитьПоCustomsBondClosing(Объект.Ссылка);
			
		Иначе
			
			// другие виды операции пока не поддерживаются
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(BatchOfCustomsFiles) Тогда
			Элементы.BatchOfCustomsFiles.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
		КонецЕсли;
		
	КонецЕсли;
	
	// ЛУЧШЕ ПЕРЕНЕСТИ В МОДУЛЬ МЕНЕДЖЕРА BOX
	ЗапросBoxesOfCustomsFiles = Новый Запрос;
	ЗапросBoxesOfCustomsFiles.УстановитьПараметр("CustomsFileLight", Объект.Ссылка);
	ЗапросBoxesOfCustomsFiles.Текст =
		"ВЫБРАТЬ
		|	BoxesOfCustomsFilesCustomsFilesLight.Ссылка КАК BoxOfCustomsFiles
		|ИЗ
		|	Документ.BoxesOfCustomsFiles.CustomsFilesLight КАК BoxesOfCustomsFilesCustomsFilesLight
		|ГДЕ
		|	НЕ BoxesOfCustomsFilesCustomsFilesLight.Ссылка.ПометкаУдаления
		|	И BoxesOfCustomsFilesCustomsFilesLight.CustomsFileLight = &CustomsFileLight";
	       	
	ВыборкаBoxesOfCustomsFiles = ЗапросBoxesOfCustomsFiles.Выполнить().Выбрать();
    Если ВыборкаBoxesOfCustomsFiles.Следующий() Тогда
		BoxOfCustomsFiles = ВыборкаBoxesOfCustomsFiles.BoxOfCustomsFiles;
		Элементы.BoxOfCustomsFiles.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
	КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзмененДокументService" Тогда
		
		Если Параметр = Объект.Ссылка Тогда
			CustomsКлиентСервер.ОбновитьПодвалServices(Объект.Ссылка, ServicesBase, ServicesMarkup, ServicesSum, ServicesDiscount, ServicesGrandTotal);
		КонецЕсли;	
			
	ИначеЕсли ИмяСобытия = "ИзмененДокументCustomsPaymentAllocation" Тогда
		
		Если Параметр.CustomsDocument = Объект.Ссылка Тогда
			UnpaidSum = CustomsСервер.ПолучитьНеоплаченнуюСуммуТПО(Объект.Ссылка);
		КонецЕсли; 
		
	КонецЕсли;
		
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ТекущаяУниверсальнаяДатаВМиллисекундах());
	КонецЕсли;
	
	ТекущийОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	НастроитьUnpostИSaveDraft();
	
	Если Элементы.CustomsDepositSum.Видимость Тогда 
		CustomsDepositSum = ПолучитьCustomsDepositSumНаСервере(Объект.Дата, Объект.Ссылка, Объект.CustomsBond);
	КонецЕсли;
	
	Если Элементы.СтраницаItems.Видимость Тогда 
		ЗаполнитьДополнительныеКолонкиItems();
	КонецЕсли;

	НастроитьServices();
	
	НастроитьCustomsPaymentsAllocations();
	
	НастроитьCustomsBondClosing();
	
	НастроитьCustomsDepositRefundToBankAccount();
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.ТПОИнерактивноеПроведение, Объект.Ссылка);
	//КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Если ЗначениеЗаполнено(Объект.Shipment) Тогда
		Оповестить("ИзмененCustomsFileLight", Объект.Shipment);
	КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////
// ШАПКА

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	
	Элементы.Номер.ТолькоПросмотр = Не (Объект.ProcessLevel = ПредопределенноеЗначение("Справочник.ProcessLevels.AZ") И Объект.Дата >= Дата('20150101'));  // S-I-0000989
			
КонецПроцедуры

&НаКлиенте
Процедура CustomsPostНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			, "ProcessLevel", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура TypeOfTransactionПриИзменении(Элемент)
	
	НастроитьЭлементы();
			
КонецПроцедуры

&НаСервере
Процедура НастроитьЭлементы()
	
	TypesOfCustomsFileLightTransaction = Перечисления.TypesOfCustomsFileLightTransaction;
	
	// реквизиты шапки
	
	Элементы.Номер.ТолькоПросмотр = Не (Объект.ProcessLevel = ПредопределенноеЗначение("Справочник.ProcessLevels.AZ") И Объект.Дата >= Дата('20150101'));  // S-I-0000989
		
	// permanent / temporary
	Если Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight Тогда
		Элементы.PermanentTemporary.Видимость = Истина;
	Иначе
		Объект.PermanentTemporary = Перечисления.PermanentTemporary.Permanent;
		Элементы.PermanentTemporary.Видимость = Ложь;
	КонецЕсли;
	
	// regime
	Элементы.Regime.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight;
	
	// psa contract
	Элементы.PSAContract.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight;
	
	// shipment
	Элементы.Shipment.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBond;
	Элементы.Shipment.АвтоОтметкаНезаполненного = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBond;

	// invoice currency
	Элементы.InvoiceCurrency.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;	
		
	// invoice currency rate
	Элементы.InvoiceCurrencyRate.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;	
		
	// release date
	Элементы.ReleaseDate.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;
		
	// expiry date
	Элементы.ExpiryDate.Видимость = Объект.TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
									И Объект.PermanentTemporary = Перечисления.PermanentTemporary.Temporary;
									
	// customs value
	Элементы.CustomsValue.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;
		
	// shipment
	Если Объект.ImportExport = Перечисления.ИмпортЭкспорт.Import Тогда
		Элементы.Shipment.ОграничениеТипа = Новый ОписаниеТипов("ДокументСсылка.Поставка");
	ИначеЕсли Объект.ImportExport = Перечисления.ИмпортЭкспорт.Export Тогда
		Элементы.Shipment.ОграничениеТипа = Новый ОписаниеТипов("ДокументСсылка.ExportShipment");
	КонецЕсли;	
		
	// customs file
	Элементы.CustomsFile.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBond;
	
	// customs bond
	Элементы.CustomsBond.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
	// Refund to
	Элементы.CustomsDepositRefundTo.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
	// deposit sum
	Элементы.CustomsDepositSum.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBondClosing;

	// deposit amount to refund
	Элементы.CustomsDepositAmountToRefund.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
		
	// cтраницы
	
	// items
	Элементы.СтраницаItems.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBond
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsBondClosing;
	
	Элементы.ItemsCustomsFileHTC.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight;
	Элементы.ItemsCustomsFileNetWeight.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight;
	
	// AUs
	Элементы.СтраницаAUs.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;
	     			
	// Services 
	Элементы.СтраницаServices.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;
            		
	// команды
	
	Элементы.FillByShipment.Видимость = Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = TypesOfCustomsFileLightTransaction.ТПО;
		
	// динамические списки
	
	НастроитьServices();
	
	НастроитьCustomsPaymentsAllocations();
	
	НастроитьCustomsBondClosing();
	
	НастроитьCustomsDepositRefundToBankAccount();
	                        	
КонецПроцедуры

&НаКлиенте
Процедура ImportExportПриИзменении(Элемент)
	
	НастроитьЭлементы();
		
КонецПроцедуры

&НаКлиенте
Процедура ParentCompanyНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			, "Country", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура PermanentTemporaryПриИзменении(Элемент)
	
	НастроитьЭлементы();	
	
КонецПроцедуры

&НаКлиенте
Процедура RegimeНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.ImportExport) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Import / export' is empty!",
			, "ImportExport", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.PermanentTemporary) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Permanent / temporary' is empty!",
			, "PermanentTemporary", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура PSAContractНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			, "Country", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ShipmentНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
		
	Если НЕ ЗначениеЗаполнено(Объект.CCA) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'CCA' is empty!",
			, "CCA", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ImportExport) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Imp. / exp.' is empty!",
			, "ImportExport", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			, "ProcessLevel", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
			
КонецПроцедуры

&НаКлиенте
Процедура FillByShipment(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.Shipment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Shipment' is empty!",
			, "Shipment", "Объект");
		Возврат;
	КонецЕсли;
	
	Если Объект.Items.Количество() > 0
		ИЛИ Объект.Goods.Количество() > 0 Тогда 
		
		Ответ = Вопрос("We have to clear 'Items'.
			|Continue?", РежимДиалогаВопрос.ДаНет);
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли;
	
	КонецЕсли;
	
	FillByShipmentНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура FillByShipmentНаСервере()
	
	ПолноценныйОбъект = ДанныеФормыВЗначение(Объект, Тип("ДокументОбъект.CustomsFilesLight"));
	
	ПолноценныйОбъект.ЗаполнитьПоShipment(Объект.Shipment);
	
	ЗначениеВДанныеФормы(ПолноценныйОбъект, Объект);
	
	НастроитьЭлементы();
	
	ЗаполнитьДополнительныеКолонкиItems();
	
	Модифицированность = Истина;
	        	
КонецПроцедуры

&НаКлиенте
Процедура CustomsFileНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			, "SoldTo", "Объект");
		СтандартнаяОбработка = Ложь;	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Shipment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Shipment' is empty!",
			, "Shipment", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура CustomsBondНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.CustomsPost) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Customs post' is empty!",
			, "CustomsPost", "Объект");
		СтандартнаяОбработка = Ложь;	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ImportExport) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Imp. / exp.' is empty!",
			, "ImportExport", "Объект");
		СтандартнаяОбработка = Ложь;	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			, "SoldTo", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.CCA) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'CCA' is empty!",
			, "CCA", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsBondПриИзменении(Элемент)
	 
	CustomsDepositSum = ПолучитьCustomsDepositSumНаСервере(Объект.Дата, Объект.Ссылка, Объект.CustomsBond);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьCustomsDepositSumНаСервере(Дата, Регистратор, CustomsBond)
	
	// возвращает остаток депозита по Customs bond на момент времени документа (не включая его)
	// если документ - новый - получает на текущую дату
	
	Если ЗначениеЗаполнено(Дата) И ЗначениеЗаполнено(Регистратор) Тогда
		МоментВремени = Новый МоментВремени(Дата, Регистратор);
		Граница = Новый Граница(МоментВремени, ВидГраницы.Исключая);
	Иначе
		Граница = Неопределено;
	КонецЕсли;
	
	Возврат РегистрыНакопления.CustomsDeposits.ПолучитьОстатокПоCustomsBond(Граница, CustomsBond);
	
КонецФункции

&НаКлиенте
Процедура CustomsDepositRefundToПриИзменении(Элемент)
	
	НастроитьCustomsDepositRefundToBankAccount();
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////
// ITEMS

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ItemsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// Проверим, заполнены ли все реквизиты, необходимые для подбора items
	
	Если НЕ ЗначениеЗаполнено(Объект.TypeOfTransaction) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Type of transaction' is empty!",
			, "TypeOfTransaction", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ImportExport) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Imp. / exp' is empty!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Если Объект.TypeOfTransaction = TypeOfTransactionCustomsFile
		ИЛИ Объект.TypeOfTransaction = TypeOfTransactionCustomsBond Тогда
		
		Если НЕ ЗначениеЗаполнено(Объект.Shipment) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Shipment' is empty!",
				, "Shipment", "Объект", Отказ);
		КонецЕсли;
		
	ИначеЕсли Объект.TypeOfTransaction = TypeOfTransactionCustomsBondClosing Тогда
		
		Если НЕ ЗначениеЗаполнено(Объект.CustomsBond) Тогда
			 ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				 "'Customs bond' is empty!",
				 , "CustomsBond", "Объект", Отказ);
		КонецЕсли;
	
	Иначе
		ВызватьИсключение "Type of transaction '" + Объект.TypeOfTransaction + "' is not supported!";
	КонецЕсли;
		   		
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Сформируем структуру параметров и откроем форму подбора
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("TypeOfTransaction", Объект.TypeOfTransaction);
	СтруктураПараметров.Вставить("ImportExport", Объект.ImportExport);
	СтруктураПараметров.Вставить("ParentCompany", Объект.SoldTo);
	СтруктураПараметров.Вставить("PermanentTemporary", Объект.PermanentTemporary);
	СтруктураПараметров.Вставить("PSAContract", Объект.PSAContract);
	СтруктураПараметров.Вставить("Shipment", Объект.Shipment);
	СтруктураПараметров.Вставить("CustomsBond", Объект.CustomsBond);
	СтруктураПараметров.Вставить("CurrentCustomsFileLight", Объект.Ссылка);
	СтруктураПараметров.Вставить("CurrentItems", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекции(Объект.Items, "Item"));
	
	ОткрытьФорму("Документ.CustomsFilesLight.Форма.ФормаПодбораItems", СтруктураПараметров, Элемент, Объект.Ссылка);
	
	// так как форму мы открыли сами - откажемся от стандартной обработки
	Отказ = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ItemsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	// Если передали массив с Items - добавим их в табличную часть
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив")
		И ВыбранноеЗначение.Количество()
		И ТипЗнч(ВыбранноеЗначение[0]) = Тип("Структура")
		И ВыбранноеЗначение[0].Свойство("Item") Тогда
		
		Для Каждого Структура Из ВыбранноеЗначение Цикл
			
			НоваяСтрокаТЧ = Объект.Items.Добавить();
			НоваяСтрокаТЧ.Item = Структура.Item;
			ЗаполнитьДопКолонкиВСтрокеItems(НоваяСтрокаТЧ, Структура);
			// По-умолчанию заполним Customs file HTC и Customs file Net weight теми же полями, что были в инвойсе
			НоваяСтрокаТЧ.CustomsFileHTC = НоваяСтрокаТЧ.InvoiceHTC;
			НоваяСтрокаТЧ.CustomsFileNetWeight = НоваяСтрокаТЧ.ParcelsNetWeight;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ItemsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	// Для поля Customs file HTC и Customs file net weight достаточно стандартной обработки
	Если Поле = Элементы.ItemsCustomsFileHTC ИЛИ Поле = Элементы.ItemsCustomsFileNetWeight Тогда
		Возврат;
	КонецЕсли;
	
	// Для остальных полей переопределим выбор - откроем форму товара	
	СтандартнаяОбработка = Ложь;	
	Item = Объект.Items.НайтиПоИдентификатору(ВыбраннаяСтрока).Item;
	Если ЗначениеЗаполнено(Item) Тогда
		ПоказатьЗначение(,Item);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДополнительныеКолонкиItems()
	
	Если НЕ Элементы.СтраницаItems.Видимость Тогда
		Возврат;
	КонецЕсли;
	
	// когда получаются реквизиты items, важно знать импортные это товары или экспортные
	Если НЕ ЗначениеЗаполнено(Объект.ImportExport) Тогда
		Возврат;
	КонецЕсли;
	
	МассивItems = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекции(Объект.Items, "Item");	
	
	Если МассивItems.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);	
	ТаблицаItems = Документы.CustomsFilesLight.ПолучитьРеквизитыItems(МассивItems, Объект.ImportExport);
	
	Для Каждого СтрокаТЧ Из Объект.Items Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Item) Тогда
			Продолжить;
		КонецЕсли;
		
		РеквизитыItem = ТаблицаItems.Найти(СтрокаТЧ.Item, "Item");
		
		// это защитный код, по-хорошему строка должна быть найдена всегда, но там непростой запрос, мало ли что не сработает, так что пусть будет
		Если РеквизитыItem = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаполнитьДопКолонкиВСтрокеItems(СтрокаТЧ, РеквизитыItem);
		
	КонецЦикла;
		
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьДопКолонкиВСтрокеItems(СтрокаItems, РеквизитыItem)
	
	ЗаполнитьЗначенияСвойств(СтрокаItems, РеквизитыItem, "PartNo, SerialNo, Description, Qty, QtyUOMCode, WeightUOMCode, Price, CurrencyNameEng, TotalPrice, PONo, InvoiceHTC, ParcelsNetWeight");
		
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////
// AUs

&НаКлиенте
Процедура AUsPOLineПриИзменении(Элемент)
	
	ТекСтрокаAUs = Элементы.AUs.ТекущиеДанные;
	
	Если ТекСтрокаAUs = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	POLine = ТекСтрокаAUs.POLine;
	
	Если НЕ ЗначениеЗаполнено(POLine) Тогда
		Возврат;
	КонецЕсли;
		
	СтруктураРеквизитовPOLine = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(POLine, "КостЦентр, ОписаниеНоменклатуры");
			
	Если ЗначениеЗаполнено(СтруктураРеквизитовPOLine.КостЦентр) Тогда 
		ТекСтрокаAUs.AU = СтруктураРеквизитовPOLine.КостЦентр;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураРеквизитовPOLine.ОписаниеНоменклатуры) Тогда 
		ТекСтрокаAUs.Description = СтруктураРеквизитовPOLine.ОписаниеНоменклатуры;
	КонецЕсли;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////////////
// CUSTOMS PAYMENT ALLOCATIONS

// ДОДЕЛАТЬ
&НаСервере
Процедура НастроитьCustomsPaymentsAllocations()
	
	Элементы.СтраницаCustomsPaymentsAllocations.Видимость = Объект.TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.CustomsFileLight
		ИЛИ Объект.TypeOfTransaction = Перечисления.TypesOfCustomsFileLightTransaction.ТПО
		ИЛИ Объект.TypeOfTransaction = TypeOfTransactionCustomsBond;
	   
	// НЕ ХАРДКОДИТЬ, А СДЕЛАТЬ НАСТРОЙКУ. ПОДУМАТЬ НА КАКОМ УРОВНЕ: PROCESS LEVEL ИЛИ PARENT COMPANY
	Если Объект.ProcessLevel <> Справочники.ProcessLevels.RUWE
		И Объект.ProcessLevel <> Справочники.ProcessLevels.RUEA
		И Объект.ProcessLevel <> Справочники.ProcessLevels.RUSM Тогда
		Элементы.СтраницаCustomsPaymentsAllocations.Видимость = Ложь;
	КонецЕсли;
	  	    
	Если Не Элементы.СтраницаCustomsPaymentsAllocations.Видимость Тогда 
		Возврат;
	КонецЕсли;
	
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, ""); 
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		CustomsPaymentsAllocations.Отбор,
		"CustomsDocument",
		ЗначениеОтбора,
		ВидСравненияКомпоновкиДанных.Равно);
		
	UnpaidSum = CustomsСервер.ПолучитьНеоплаченнуюСуммуТПО(Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsPaymentsAllocationsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ЗаписатьПриНеобходимости(Отказ);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////
// SERVICES

// ДОДЕЛАТЬ
&НаСервере
Процедура НастроитьServices()
	
	// НЕ ХАРДКОДИТЬ, А СДЕЛАТЬ НАСТРОЙКУ. НА УРОВНЕ PROCESS LEVEL.
	
	Если Элементы.СтраницаServices.Видимость 
		И Объект.ProcessLevel <> Справочники.ProcessLevels.RUWE
		// { RGS AGorlenko 06.11.2014 15:16:11 - S-I-0000928
		И Объект.ProcessLevel <> Справочники.ProcessLevels.KZ
		// } RGS AGorlenko 06.11.2014 15:16:47 - S-I-0000928
		И Объект.ProcessLevel <> Справочники.ProcessLevels.RUEA
		
		// { RGS ASeryakov, 30.05.18 S-I-0005241
		//И Объект.ProcessLevel <> Справочники.ProcessLevels.RUSM Тогда
		И Объект.ProcessLevel <> Справочники.ProcessLevels.RUSM
		И Объект.ProcessLevel <> Справочники.ProcessLevels.AZ
		И Объект.ProcessLevel <> Справочники.ProcessLevels.TM Тогда
		// { RGS ASeryakov, 30.05.18 S-I-0005241
		
		Элементы.СтраницаServices.Видимость = Ложь;
		Возврат;
		
	КонецЕсли;
	
	Если Не Элементы.СтраницаServices.Видимость Тогда 
		Возврат;
	КонецЕсли;
	
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, "");
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		Services.Отбор,
		"DocumentBase",
		ЗначениеОтбора,
		ВидСравненияКомпоновкиДанных.Равно);
		
	CustomsКлиентСервер.ОбновитьПодвалServices(Объект.Ссылка, ServicesBase, ServicesMarkup, ServicesSum, ServicesDiscount, ServicesGrandTotal);	
	       		
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьServices(Команда)
	
	Элементы.Services.Обновить();
	CustomsКлиентСервер.ОбновитьПодвалServices(Объект.Ссылка, ServicesBase, ServicesMarkup, ServicesSum, ServicesDiscount, ServicesGrandTotal);
	
КонецПроцедуры

&НаКлиенте
Процедура ServicesПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ЗаписатьПриНеобходимости(Отказ);
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////
// CUSTOMS BOND CLOSINGS

&НаСервере
Процедура НастроитьCustomsBondClosing()
	
	Элементы.СтраницаCustomsBondClosing.Видимость = Объект.TypeOfTransaction = TypeOfTransactionCustomsBond;
	
	Если Не Элементы.СтраницаCustomsBondClosing.Видимость Тогда 
		Возврат;
	КонецЕсли;
	        		
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, ""); 
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		CustomsBondClosing.Отбор,
		"CustomsBond",
		ЗначениеОтбора,
		ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьCustomsDepositRefundToBankAccount()
	
	Элементы.НадписьCustomsAdvances.Видимость = Объект.CustomsDepositRefundTo = Перечисления.CustomsDepositsRefundTo.CustomsAdvances;
	
	Элементы.СтраницаCustomsDepositRefundToBankAccount.Видимость = Объект.TypeOfTransaction = TypeOfTransactionCustomsBondClosing
		И Объект.CustomsDepositRefundTo = Перечисления.CustomsDepositsRefundTo.BankAccount;
		
	Если Не Элементы.СтраницаCustomsDepositRefundToBankAccount.Видимость Тогда 
		Возврат;
	КонецЕсли;
	        		
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.CustomsBond), Объект.CustomsBond, ""); 
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		CustomsDepositRefundToBankAccount.Отбор,
		"CustomsBond",
		ЗначениеОтбора,
		ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////
// OTHER

&НаКлиенте
Процедура ProcessLevel1НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			, "Country", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////////////
// ПРОЧИЕ ПРОЦЕДУРЫ, ФУНКЦИИ

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ЗаписатьПриНеобходимости(Отказ)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Попытка
			Записать(Новый Структура);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to save ТПО!
				|" + ОписаниеОшибки(),
				,,, Отказ);
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

//-> RG-Soft VIvanov 2015/02/18
&НаКлиенте
Процедура AUsAUНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	текДанные = Элементы.AUs.ТекущиеДанные;
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Дата", Объект.Дата);
	СтруктураПараметров.Вставить("ТекущаяСтрока", текДанные.AU);
	ФормаВыбора = ПолучитьФорму("Справочник.КостЦентры.Форма.ФормаВыбораИзРегистра", СтруктураПараметров, Элемент);
	ФормаВыбора.РежимОткрытияОкна = РежимОткрытияОкнаФормы.БлокироватьОкноВладельца;
	ФормаВыбора.Открыть();
	
КонецПроцедуры

&НаКлиенте
Процедура AUsAUАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Текст) Тогда
		СтандартнаяОбработка = Ложь;
		ПараметрыПолученияДанных.Вставить("Дата", Объект.Дата);
		//ДанныеВыбора = ПолучитьДанныеВыбора(Тип("СправочникСсылка.КостЦентры"), Параметры);
		ДанныеВыбора = РГСофт.ПолучитьДанныеВыбораКостЦентров(ПараметрыПолученияДанных);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура AUsAUОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Текст) Тогда
		СтандартнаяОбработка = Ложь;
		ПараметрыПолученияДанных.Вставить("Дата", Объект.Дата);
		//ДанныеВыбора = ПолучитьДанныеВыбора(Тип("СправочникСсылка.КостЦентры"), Параметры);
		ДанныеВыбора = РГСофт.ПолучитьДанныеВыбораКостЦентров(ПараметрыПолученияДанных);
	КонецЕсли;
	
КонецПроцедуры
//<- RG-Soft VIvanov

// { RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
&НаКлиенте
Процедура AUsDescriptionForCustomsПриИзменении(Элемент)
	
	Если ТипЗнч(Объект.Shipment) = Тип("ДокументСсылка.Поставка") Тогда  
		Если Элементы.AUs.ТекущиеДанные.DescriptionForCustoms = ПредопределенноеЗначение("Перечисление.DescriptionForCustoms.CustomsValueCorrection") Тогда
			// проверяем причину в документе "Import Shipment"
			Если НЕ ЕстьCustomsValueCorrectionInShipment(Объект.Shipment) Тогда
				Элементы.AUs.ТекущиеДанные.DescriptionForCustoms = Неопределено;
				Сообщение = Новый СообщениеПользователю;
				Сообщение.Текст = НСтр("ru = 'Несоответствует причина в документе !'; 
				|en = 'The reason for discrepancy in the document!'") + Объект.Shipment;
				Сообщение.Сообщить();
			КонецЕсли;	
		КонецЕсли;
	КонецЕсли;	
	
	Если Элементы.AUs.ТекущиеДанные.DescriptionForCustoms = ПредопределенноеЗначение("Перечисление.DescriptionForCustoms.Other") Тогда
		Элементы.AUsItemDescription.Видимость = Истина;
	Иначе
		Элементы.AUsItemDescription.Видимость = Ложь;
	КонецЕсли;	
	
	Если Элементы.AUs.ТекущиеДанные.DescriptionForCustoms = ПредопределенноеЗначение("Перечисление.DescriptionForCustoms.CustomsValueCorrection") Тогда
		Элементы.AUsInvoiceCorrectionValue.Видимость = Истина;
	Иначе
		Элементы.AUsInvoiceCorrectionValue.Видимость = Ложь;
	КонецЕсли;	
	
КонецПроцедуры

Функция ЕстьCustomsValueCorrectionInShipment(Shipment)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПоставкаOutOfComplianceReasons.OutOfComplianceReason
		|ИЗ
		|	Документ.Поставка.OutOfComplianceReasons КАК ПоставкаOutOfComplianceReasons
		|ГДЕ
		|	ПоставкаOutOfComplianceReasons.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Shipment);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ТаблицаПричин = РезультатЗапроса.Выгрузить();
		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("OutOfComplianceReason", Справочники.OutOfComplianceReasons.CustomsValueCorrection);
		РезультатПоиска = ТаблицаПричин.НайтиСтроки(СтруктураПоиска);
		Если РезультатПоиска.Количество() > 0 Тогда
			Возврат Истина;
		КонецЕсли;	
	Иначе
		Возврат Ложь;
	КонецЕсли;	
	
КонецФункции	

&НаКлиенте
Процедура ParentCompanyПриИзменении(Элемент)

	Если НЕ ЗначениеЗаполнено(Объект.Shipment) Тогда	
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не заполнен реквизит ""Shipment"" в документе!';en = 'Not filled in the detail ""Shipment"" in the document!'");
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда	
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'Не заполнен реквизит ""Parent company"" в документе!';en = 'Not filled in the detail ""Parent company"" in the document!'");
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;	
		
	ПолучитьГТД();
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьГТД()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
				"ВЫБРАТЬ
				|	ГТД.Ссылка КАК CCD,
				|	ГТД.SoldTo КАК SoldTo,
				|	ГТД.Shipment КАК Shipment
				|ИЗ
				|	Документ.ГТД КАК ГТД
				|ГДЕ
				|	ГТД.SoldTo = &SoldTo
				|	И ГТД.Shipment = &Shipment";
			
	Запрос.УстановитьПараметр("Shipment", Объект.Shipment);
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	
	Результат = Запрос.Выполнить();
	
	Если НЕ Результат.Пустой() Тогда
		ТаблицаCCD = Результат.Выгрузить();
		Если ТаблицаCCD.Количество() = 1 Тогда
			Объект.CustomsFile = ТаблицаCCD[0].CCD;
		Иначе
			СписокCCD = ТаблицаCCD.Скопировать(, "CCD"); 
		КонецЕсли;	
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = НСтр("ru = 'В базе нет документов ""ГТД"" по указанными данным в полях ""Shipment"" и ""Parent company""!';
								|en = 'The database does not have documents ""CCD"" according to the data in the fields ""Shipment"" and ""Parent company""!'");
		Сообщение.Сообщить();
	КонецЕсли;	
	
Конецпроцедуры	

&НаКлиенте
Процедура CCDНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если СписокCCD.Количество() = 0 Тогда
		СтандартнаяОбработка = Истина;
		Возврат;
	Иначе
		СтандартнаяОбработка = Ложь;
	КонецЕсли;

	Список = Новый Массив;
	Для Каждого ЭлементСпискаCCD Из СписокCCD Цикл
		Список.Добавить(ЭлементСпискаCCD.CCD.Номер);
	КонецЦикла;
	ПараметрДляОткрытияФормыВыбора = Новый Структура("СписокДляОтбора", Список);
	ОткрытьФорму("Документ.ГТД.Форма.ФормаВыбора", ПараметрДляОткрытияФормыВыбора, Элемент);
	
КонецПроцедуры

// } RGS AFokin 13.09.2018 23:59:59 - S-I-0005710

