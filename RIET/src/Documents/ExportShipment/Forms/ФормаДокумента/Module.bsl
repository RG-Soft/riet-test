      
////////////////////////////////////////////////////////////////////////
// ФОРМА

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	УстановитьПривилегированныйРежим(Истина);
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
	
	// Заполним некоторые реквизиты при открытии
	Если НЕ ЗначениеЗаполнено(Объект.ExportSpecialist) Тогда
		Объект.ExportSpecialist = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
    Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		Объект.ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Объект.ExportSpecialist, "ProcessLevel");
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ImportExportКлиентСервер.ЗаполнитьРеквизитыExportShipmentОбщиеДляExportRequests(Объект);
	КонецЕсли;

	// Настроим видимость некоторых реквизитов
	
	// По-умолчанию скроем динамический список, чтобы не читать данные из СУБД
	Элементы.CustomsFilesFull.Видимость = Ложь;
	Элементы.Services.Видимость = Ложь;
	              		
	// Пока страницы Customs files full и Customs files различаются: на первой отображаются ГТДшки, на второй Customs files (light)
	// Азербайджан и Туркменистан делает Customs files (light), все остальные локации - загружают ГТДшки
	// Поэтом эти страницы может быть надо будет слить
	Если Объект.ProcessLevel = Справочники.ProcessLevels.AZ
		ИЛИ Объект.ProcessLevel = Справочники.ProcessLevels.UZ
		ИЛИ Объект.ProcessLevel = Справочники.ProcessLevels.TM
		// { RGS EParshina EParshina 25.12.2018 14:01:58 - S-I-0006542
		ИЛИ Объект.ProcessLevel = Справочники.ProcessLevels.GE
		// } RGS EParshina EParshina 25.12.2018 14:01:58 - S-I-0006542
		Тогда
		Элементы.СтраницаCustomsFilesFull.Видимость = Ложь;
		НужноПерезаполнитьCustomsFiles = Истина;
	Иначе
		Элементы.СтраницаCustomsFiles.Видимость = Ложь;
	КонецЕсли;
	
	// Closing document
	ClosingDocument = CustomsСервер.ПолучитьClosingDocument(Объект.Ссылка);
	НастроитьClosingDocument();
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.ExportShipmentОткрытие, Объект.Ссылка);
	// { RGS LHristyc 02.07.2018 10:33:20 - S-I-0004942
	УстановитьДоступностьЭлементовExportReports();
	// } RGS LHristyc 02.07.2018 10:33:22 - S-I-0004942 	     	 
	
	// { RGS DKazanskiy 10.10.2018 14:26:33 - S-I-0005759
	ОбновитьЗависимыеОтExportRequests()
	// } RGS DKazanskiy 10.10.2018 14:26:33 - S-I-0005759
КонецПроцедуры 	


&НаСервере
Процедура НастроитьClosingDocument()
	
	Элементы.ClosingDocument.Видимость = ЗначениеЗаполнено(ClosingDocument);
	Элементы.КоманднаяПанельClosingDocument.Видимость = НЕ ЗначениеЗаполнено(ClosingDocument) И ЗначениеЗаполнено(Объект.Ссылка);
	
КонецПроцедуры

// { RGS LHristyc 02.07.2018 10:20:46 - S-I-0004942
&НаСервере
Процедура УстановитьДоступностьЭлементовExportReports()
	
	Если CustomsСервер.ЭтоБрокер() ИЛИ РольДоступна("РедактированиеНедоступныхПолейExport") Тогда
		Возврат;
	КонецЕсли;
	
	ИспользуетсяExportReports = ПланыОбмена.Leg7.ПолучитьИспользованиеExportReportsДляCCA(Объект.CCA);
	Если ИспользуетсяExportReports Тогда
		ProcessLevelЕстьВУзле = ПланыОбмена.Leg7.ПроверитьProcessLevelПоCCA(Объект.CCA, Объект.ProcessLevel);
	КонецЕсли;
	
	DHLProviders = Новый Массив;
	DHLProviders.Добавить("DHL");
	//DHLProviders.Добавить("DHL Logist");
	
	// { RGS DKazanskiy 16.10.2018 10:01:07 - S-I-0005759
	// Данные поля редактируются только брокером или если это DHL поставка
	Если DHLProviders.Найти(СокрЛП(Объект.CCA.Код)) = Неопределено Тогда
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "SubmittedToCustoms", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "ReleasedFromCustoms", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "CCDNumber", "ТолькоПросмотр", Истина);
	КонецЕсли;	
	// } RGS DKazanskiy 16.10.2018 10:11:27 - S-I-0005759
	
	Если ИспользуетсяExportReports И ProcessLevelЕстьВУзле Тогда
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "InternationalWB1", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "InternationalETD", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "InternationalATD", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "PreAlertSent", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "InternationalETA", "ТолькоПросмотр", Истина);
		РГСофтКлиентСервер.НастроитьЭлементЕслиОнЕсть(Элементы, "InternationalATA", "ТолькоПросмотр", Истина);		
	КонецЕсли;
КонецПроцедуры // } RGS LHristyc 02.07.2018 10:20:51 - S-I-0004942
////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Модифицированность = Истина;
	КонецЕсли;
	
	НастроитьВидимостьПоCustomUnionTransaction();
	
	// { RGS AArsentev 28.06.2018
	Если CustomsСервер.ЭтоБрокер() Тогда
		Элементы.ГруппаПраваяКолонка.Видимость = Ложь;
	КонецЕсли;
	// } RGS AArsentev 28.06.2018
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьВидимостьПоCustomUnionTransaction()
	 	
	Элементы.СтраницаCustomsFiles.Видимость = Не Объект.CustomUnionTransaction;
	Элементы.СтраницаCustomsFilesFull.Видимость = Не Объект.CustomUnionTransaction;
	Элементы.СтраницаServices.Видимость = Не Объект.CustomUnionTransaction;
	Элементы.ГруппаCustoms.Видимость = Не Объект.CustomUnionTransaction;
	// { RGS AFokin 21.11.2018 23:59:59 - S-I-0006306
	//Элементы.ГруппаClosingDocument.Видимость = Не Объект.CustomUnionTransaction;
	// { RGS AFokin 21.11.2018 23:59:59 - S-I-0006306
	Элементы.POD.Видимость = Не Объект.CustomUnionTransaction;
	       
КонецПроцедуры

&НаКлиенте
Процедура CustomUnionTransactionПриИзменении(Элемент)
	
	НастроитьВидимостьПоCustomUnionTransaction();

КонецПроцедуры
////////////////////////////////////////////////////////////////////////

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзмененДокументService" Тогда
		
		Если Параметр = Объект.Ссылка Тогда
			CustomsКлиентСервер.ОбновитьПодвалServices(Объект.Ссылка, ServicesBase, ServicesMarkup, ServicesSum, ServicesDiscount, ServicesGrandTotal);
		КонецЕсли;
			
	ИначеЕсли ИмяСобытия = "ИзмененCustomsFileLight" Тогда
		
		Если Объект.Ссылка = Параметр Тогда
			
			НужноПерезаполнитьCustomsFiles = Истина;
			
			Если Элементы.Страницы.ТекущаяСтраница = Элементы.CustomsFiles Тогда
				// МОЖЕТ БЫТЬ ЭФФЕКТИВНЕЕ ПЕРЕЗАПОЛНЯТЬ ТОЛЬКО ОДНУ СТРОКУ?
				ImportExportКлиент.ПерезаполнитьCustomsFilesВShipmentПриНеобходимости(CustomsFiles, Объект.Ссылка, НужноПерезаполнитьCustomsFiles);
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	//ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ОценкаПроизводительностиРГСофт.ТочноеВремя());
	
	ТекущийОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
	
	НастроитьClosingDocument();
	
	Если Элементы.CustomsFilesFull.Видимость Тогда
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
			CustomsFilesFull.Отбор,
			"Shipment",
			Объект.Ссылка,
			ВидСравненияКомпоновкиДанных.Равно,
			,
			Истина);
		
	КонецЕсли;
	
	Если Элементы.CustomsFilesFull.Видимость Тогда
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
			Services.Отбор,
			"DocumentBase",
			Объект.Ссылка,
			ВидСравненияКомпоновкиДанных.Равно,
			,
			Истина);
		
	КонецЕсли;
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.ExportShipmentИнтерактивнаяЗапись, Объект.Ссылка);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////
// ПЕЧАТЬ NON PO

&НаКлиенте
Процедура NonPO(Команда)
	
	Если Объект.ProcessLevel <> ПредопределенноеЗначение("Справочник.ProcessLevels.AZ")
		И Объект.ProcessLevel <> ПредопределенноеЗначение("Справочник.ProcessLevels.KZ") 
		И Объект.ProcessLevel <> ПредопределенноеЗначение("Справочник.ProcessLevels.TM") Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""NON-PO"" is used only for process levels: AZ, KZ, TM!",
			, "ProcessLevel", "Объект");
		Возврат;
	КонецЕсли;
			
	Если Объект.ExportRequests.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Export requests"" table is empty!",
			, "ExportRequests", "Объект");
		Возврат;
	КонецЕсли;
	
	МассивТабДок = ПолучитьМассивТабДокNonPO();
	Для НПП = 1 по МассивТабДок.Количество() Цикл 
		ТабДок = МассивТабДок[(НПП - 1)];
		ТабДок.Показать("Non_PO_" + СокрЛП(Объект.Номер) + "-" + СокрЛП(НПП));
	КонецЦикла;
       		
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивТабДокNonPO()
	
	Если Модифицированность Тогда
		Записать(Новый Структура);
	КонецЕсли;
	
	МассивТабДок = Новый Массив;
	
	// Получим данные из СУБД
	Запрос = Новый Запрос;
	
	ExportRequests = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.ExportRequests, "ExportRequest");
	Запрос.УстановитьПараметр("ExportRequests", ExportRequests);
	Запрос.УстановитьПараметр("CreationDate", Объект.Дата);
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Items.КостЦентр.Код КАК AUCode,
		|	Items.Активити КАК AC,
		|	Items.КостЦентр.DefaultActivity КАК AUAC,
		|	ERPTreatmentAccountsСрезПоследних.CCDAccount КАК CustomsDutiesAccount,
		|	ERPTreatmentAccountsСрезПоследних.CCDSubAccount КАК CustomsDutiesSubAccount,
		|	ERPTreatmentAccountsСрезПоследних.AgentAccount КАК CCAServicesAccount,
		|	ERPTreatmentAccountsСрезПоследних.AgentSubAccount КАК CCAServicesSubAccount,
		|	СУММА(1) КАК ItemsCount,
		|	100 КАК Percent,
		|	Items.КостЦентр.Segment.Код КАК SegmentCode,
		|	Items.PSA.Код КАК PSACode,
		|	Items.КостЦентр.Segment КАК Segment,
		|	ВЫРАЗИТЬ("""" КАК СТРОКА(300)) КАК InvoiceList,
		|	Items.КостЦентр КАК AU,
		|	ВЫРАЗИТЬ("""" КАК СТРОКА(300)) КАК Regime
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Items
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ERPTreatmentAccounts.СрезПоследних(&CreationDate, ) КАК ERPTreatmentAccountsСрезПоследних
		|		ПО Items.Классификатор = ERPTreatmentAccountsСрезПоследних.ERPTreatment
		|ГДЕ
		|	Items.ExportRequest В(&ExportRequests)
		|	И НЕ Items.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	ERPTreatmentAccountsСрезПоследних.AgentSubAccount,
		|	ERPTreatmentAccountsСрезПоследних.AgentAccount,
		|	ERPTreatmentAccountsСрезПоследних.CCDSubAccount,
		|	ERPTreatmentAccountsСрезПоследних.CCDAccount,
		|	Items.Активити,
		|	Items.КостЦентр.Код,
		|	Items.КостЦентр.DefaultActivity,
		|	Items.КостЦентр.Segment.Код,
		|	Items.PSA.Код,
		|	Items.КостЦентр,
		|	Items.КостЦентр.Segment
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Items.КостЦентр.Segment КАК Segment,
		|	ВЫРАЗИТЬ(Items.ExportRequest.Номер КАК СТРОКА(25)) КАК InvoiceNo
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Items
		|ГДЕ
		|	Items.ExportRequest В(&ExportRequests)
		|	И НЕ Items.ПометкаУдаления
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Items.КостЦентр КАК AU,
		|	Items.PermanentTemporary КАК Regime
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Items
		|ГДЕ
		|	Items.ExportRequest В(&ExportRequests)
		|	И НЕ Items.ПометкаУдаления";
		
	УстановитьПривилегированныйРежим(Истина);
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	Результат = Запрос.ВыполнитьПакет();
	ЗафиксироватьТранзакцию();
	
	// Подготовим данные
	ТаблицаДанных = Результат[0].Выгрузить();
	
	ТаблицаInvoiceSegment = Результат[1].Выгрузить();
	ТаблицаInvoiceSegment.свернуть("Segment,InvoiceNo");
	
	ТаблицаRegime = Результат[2].Выгрузить();
	ТаблицаRegime.свернуть("AU,Regime");
	
	WBList = Объект.InternationalWBList;
	
	// Invoice List
	СтруктураПоискаSegment = Новый Структура("Segment");
	Для Каждого СтрокаТаблицыДанных Из ТаблицаДанных Цикл
		
		InvoiceList = "";
		СтруктураПоискаSegment.Segment = СтрокаТаблицыДанных.Segment;
		МассивСтрок = ТаблицаInvoiceSegment.НайтиСтроки(СтруктураПоискаSegment); 
		Для Каждого ЭлементМассива из МассивСтрок Цикл 
			InvoiceList = InvoiceList + ?(InvoiceList = "", "", ", ") + СокрЛП(ЭлементМассива.InvoiceNo);
		КонецЦикла;
		СтрокаТаблицыДанных.InvoiceList = СокрЛП(МассивСтрок.Количество()) + " (" + InvoiceList + ")";
		
	КонецЦикла;
	
	// Regime
	СтруктураПоискаAU = Новый Структура("AU");
	Для Каждого СтрокаТаблицыДанных Из ТаблицаДанных Цикл
		
		Regime = "";
		СтруктураПоискаAU.AU = СтрокаТаблицыДанных.AU;
		МассивСтрок = ТаблицаRegime.НайтиСтроки(СтруктураПоискаAU); 
		Для Каждого ЭлементМассива из МассивСтрок Цикл 
			Regime = Regime + ?(Regime = "", "", ", ") + СокрЛП(ЭлементМассива.Regime);
		КонецЦикла;
		СтрокаТаблицыДанных.Regime = Regime;
		
	КонецЦикла;
	
	//для AZ на каждый AU отдельный NON-PO
	Если Объект.ProcessLevel = Справочники.ProcessLevels.AZ Тогда 
		
		Для Каждого Стр из ТаблицаДанных Цикл 
			
			МассивСтрок = Новый Массив;
			МассивСтрок.Добавить(Стр);
			ТабДанных = ТаблицаДанных.Скопировать(МассивСтрок);
			   						
			МассивТабДок.Добавить(ImportExportСервер.ПолучитьТабДокNONPO(Объект, ТабДанных, WBList));
			
		КонецЦикла;
		
		Возврат МассивТабДок;
		
	КонецЕсли;
	
	TotalItemsCount = ТаблицаДанных.Итог("ItemsCount");
	TotalRows = ТаблицаДанных.Количество();
	
	// Заполним колонку с процентами
	Для Каждого СтрокаТаблицыДанных Из ТаблицаДанных Цикл
		СтрокаТаблицыДанных.Percent = 100 * СтрокаТаблицыДанных.ItemsCount / TotalItemsCount;
		СтрокаТаблицыДанных.Percent = Окр(СтрокаТаблицыДанных.Percent, 2);
	КонецЦикла;
	
	ТаблицаДанных.Сортировать("Percent УБЫВ");
	
	// Избавимся от ошибки округления
	CalculatedPercents = ТаблицаДанных.Итог("Percent");
	Если CalculatedPercents <> 100 Тогда
		ТаблицаДанных[0].Percent = ТаблицаДанных[0].Percent + 100 - CalculatedPercents;
	КонецЕсли;
	
	МассивТабДок.Добавить(ImportExportСервер.ПолучитьТабДокNONPO(Объект, ТаблицаДанных, WBList));
	
	Возврат МассивТабДок;
	
КонецФункции


////////////////////////////////////////////////////////////////////////
// СТРАНИЦЫ

&НаКлиенте
Процедура СтраницыПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	Если ТекущаяСтраница = Элементы.СтраницаCustomsFilesFull Тогда
		
		Если НЕ Элементы.CustomsFilesFull.Видимость Тогда
			НастроитьСтраницуCustomsFilesFull();
		КонецЕсли;
		
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаCustomsFiles Тогда
		
		ImportExportКлиент.ПерезаполнитьCustomsFilesВShipmentПриНеобходимости(CustomsFiles, Объект.Ссылка, НужноПерезаполнитьCustomsFiles);
		
	ИначеЕсли ТекущаяСтраница = Элементы.СтраницаServices Тогда
		
		Если НЕ Элементы.Services.Видимость Тогда
			НастроитьСтраницуServices();
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьСтраницуCustomsFilesFull()
	
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, "");
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		CustomsFilesFull.Отбор,
		"Shipment",
		ВидСравненияКомпоновкиДанных.Равно,
		ЗначениеОтбора,
		,
		Истина);
		
	Элементы.CustomsFilesFull.Видимость = Истина;
	Элементы.ФиктивнаяНадписьCustomsFilesFull.Видимость = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьСтраницуServices()
	
	ЗначениеОтбора = ?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, "");
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		Services.Отбор,
		"DocumentBase",
		ВидСравненияКомпоновкиДанных.Равно,
		ЗначениеОтбора,
		,
		Истина);
		
	CustomsКлиентСервер.ОбновитьПодвалServices(Объект.Ссылка, ServicesBase, ServicesMarkup, ServicesSum, ServicesDiscount, ServicesGrandTotal);		
		
	Элементы.Services.Видимость = Истина;
	Элементы.ФиктивнаяНадписьServices.Видимость = Ложь;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////
// ТАБЛИЧНАЯ ЧАСТЬ EXPORT REQUESTS

&НаКлиенте
Процедура ExportRequestsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	 
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзExportShipment");	
	СтруктураНастройки.Вставить("ExportShipment", Объект.Ссылка);
	СтруктураНастройки.Вставить("CCA", Объект.CCA);
	СтруктураНастройки.Вставить("InternationalFreightProvider", Объект.InternationalFreightProvider);
	СтруктураНастройки.Вставить("POD", Объект.POD);
	СтруктураНастройки.Вставить("POA", Объект.POA);
	СтруктураНастройки.Вставить("InternationalMOT", Объект.InternationalMOT);
	СтруктураНастройки.Вставить("CustomUnionTransaction", Объект.CustomUnionTransaction);

	МассивExportRequests = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.ExportRequests,"ExportRequest");
	СтруктураНастройки.Вставить("ExportRequests", МассивExportRequests);
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СтруктураНастройки", СтруктураНастройки);
	ПараметрыФормы.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Документ.ExportRequest.ФормаВыбора", ПараметрыФормы, Элемент);
    	 
КонецПроцедуры

&НаКлиенте
Процедура ExportRequestsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив")
		И ВыбранноеЗначение.Количество()
		И ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.ExportRequest") Тогда
		
		СтандартнаяОбработка = Ложь;	
		ДобавитьВыбранныеExportRequests(ВыбранноеЗначение);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ДобавитьВыбранныеExportRequests(МассивExportRequests)
	
	СтруктураПоискаПоExportRequest = Новый Структура("ExportRequest");
	
	Для Каждого ExportRequest Из МассивExportRequests Цикл
		
		СтруктураПоискаПоExportRequest.ExportRequest = ExportRequest;
		НайденныеСтроки = Объект.ExportRequests.НайтиСтроки(СтруктураПоискаПоExportRequest);
		Если НайденныеСтроки.Количество() = 0 Тогда
			НоваяСтрокаER = Объект.ExportRequests.Добавить();
			НоваяСтрокаER.ExportRequest = ExportRequest;
			Модифицированность = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	ImportExportКлиентСервер.ЗаполнитьРеквизитыExportShipmentОбщиеДляExportRequests(Объект);
	// { RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	ЗаполнитьProcessLevel();
	// } RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
КонецПроцедуры

&НаКлиенте
Процедура ExportRequestsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтрокаТЧ = Объект.ExportRequests.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если ЗначениеЗаполнено(СтрокаТЧ.ExportRequest) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,СтрокаТЧ.ExportRequest);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ExportRequestsПослеУдаления(Элемент)
	
	ImportExportКлиентСервер.ЗаполнитьРеквизитыExportShipmentОбщиеДляExportRequests(Объект);
	
КонецПроцедуры

// { RGS DKazanskiy 10.10.2018 14:26:33 - S-I-0005759
&НаКлиенте
Процедура ExportRequestsПриИзменении(Элемент)
	
	ОбновитьЗависимыеОтExportRequests()
	
КонецПроцедуры
// } RGS DKazanskiy 10.10.2018 14:26:33 - S-I-0005759

////////////////////////////////////////////////////////////////////////
// СТРАНИЦА CUSTOMS FILES FULL

&НаКлиенте
Процедура CustomsFilesFullПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ЗаписатьПриНеобходимости(Отказ);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////////
// СТРАНИЦА CUSTOMS FILES

&НаКлиенте
Процедура CustomsFilesПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// Переопределим добавление новое строки
	// Вместо этого создадим новый документ
	
	Отказ = Истина;
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Попытка
			Записать();
		Исключение
			Сообщить("Failed to save Shipment!
				|See errors above.
				|" + ОписаниеОшибки());
			Возврат;
		КонецПопытки;
	КонецЕсли;
	
	СтруктураПараметров = Новый Структура;
	Если Копирование Тогда
		
		ТекущиеДанные = Элемент.ТекущиеДанные;
		Если ТекущиеДанные = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		СтруктураПараметров.Вставить("ЗначениеКопирования", ТекущиеДанные.Ссылка);
		
	Иначе
		СтруктураПараметров.Вставить("Основание", Объект.Ссылка);
	КонецЕсли;
		
	ОткрытьФорму("Документ.CustomsFilesLight.ФормаОбъекта", СтруктураПараметров, ЭтаФорма, Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsFilesПередНачаломИзменения(Элемент, Отказ)
	
	// Переопределим изменение строки
	// Вместо этого откроем документ
	
	Отказ = Истина;
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПоказатьЗначение(,ТекущиеДанные.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsFilesПередУдалением(Элемент, Отказ)
	
	// Переопределим удаление строки
	// Вместо этого совсем откажемся от удаление, потому что с пометкой удаления будет геморрой (помечать на удаление, обновлять таблицу и т. д)
	
	Отказ = Истина;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////
// СТРАНИЦА SERVICES

&НаКлиенте
Процедура ServicesПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	ЗаписатьПриНеобходимости(Отказ);
	
	ПроверитьCCD(Отказ);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьПриНеобходимости(Отказ)
	
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		Попытка
			Записать();
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to save current Export shipment.
				|See errors above.
				|" + ОписаниеОшибки(),
				, "Объект",, Отказ);
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////
// OUT OF COMPLIANCE REASONS

&НаКлиенте
Процедура OutOfComplianceReasonsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Если Не Копирование Тогда
		Отказ = Истина;
		ОткрытьФорму("Справочник.OutOfComplianceReasons.ФормаВыбора", Новый Структура("Export"), Элемент);
	КонецЕсли;
	
КонецПроцедуры
      
&НаКлиенте
Процедура OutOfComplianceReasonsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ВыбранноеЗначение) и ТипЗнч(ВыбранноеЗначение) = Тип("СправочникСсылка.OutOfComplianceReasons") Тогда
		НоваяСтрока = Объект.OutOfComplianceReasons.Добавить();
		НоваяСтрока.OutOfComplianceReason = ВыбранноеЗначение;
		Модифицированность = Истина;
	КонецЕсли;	
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////
// ПОДВАЛ

// ДОДЕЛАТЬ
&НаКлиенте
Процедура ClosingDocumentНажатие(Элемент, СтандартнаяОбработка)
	
	Если ClosingDocument = "Create new" Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
			
			СтруктураПарамеров = Новый Структура;
			СтруктураПарамеров.Вставить("Основание", Объект.Ссылка);
			ОткрытьФорму("Документ.ЗакрытиеПоставки.ФормаОбъекта", СтруктураПарамеров);
			
		КонецЕсли;	
		
	КонецЕсли;
	
КонецПроцедуры

                            
////////////////////////////////////////////////////////////////////////
// SEND TO MOVE IT

&НаКлиенте
Процедура SendToMoveIt(Команда)
	
	ТабДокументы = СформироватьТабДокументыВыгрузки();	
	Для Каждого ТабДок из ТабДокументы Цикл 
		ТабДок.Показать();
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция СформироватьТабДокументыВыгрузки()
	
	Отказ = Ложь;
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	МассивТабДоков = Новый Массив;
	
	Если Модифицированность Тогда
		
		Попытка
			Записать(Новый Структура);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to save current Export shipment!
				|See errors above.
				|" + ОписаниеОшибки());
			Возврат МассивТабДоков;
		КонецПопытки;
		
	КонецЕсли; 
	
	// Получим таблицу данных
	
	ТаблицаДанных = ПолучитьТаблицуДанныхВыгрузки(Объект.Ссылка);
	ТаблицаДанных.Индексы.Добавить("SoldTo");
	ЗафиксироватьТранзакцию();
	
	// Найдем все различные Sold-to	
	ТаблицаSoldTo = ТаблицаДанных.Скопировать(,"SoldTo");
	ТаблицаSoldTo.Свернуть("SoldTo");
	
	СтруктураПоиска = Новый Структура("SoldTo");
	
	// Сформируем табличные документы для каждого Deliver-to
	Макет = ПолучитьОбщийМакет("UploadingToMoveIt");
	
	Для Каждого СтрокаТаблицыSoldTo из ТаблицаSoldTo Цикл 
		
		ТабДок = Новый ТабличныйДокумент;
		
		// Выведем шапку
		ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
		ТабДок.Вывести(ОбластьШапка);
		
		// Выведем строки
		ОбластьParcelLine = Макет.ПолучитьОбласть("ParcelLine");
		СтруктураПоиска.SoldTo = СтрокаТаблицыSoldTo.SoldTo;
		ТаблицаParcelLines = ТаблицаДанных.Скопировать(СтруктураПоиска);
		ТаблицаParcelLines.Сортировать("ParcelNo, ParcelItemLineNo");
		
		ТекущийParcelNo = "";
		ПорядковыйНомерПарселя = 0;
		Для Каждого ParcelLine из ТаблицаParcelLines Цикл 
			
			ПараметрыОбласти = ОбластьParcelLine.Параметры;
			
			ПараметрыОбласти.IsUrgent = ParcelLine.IsUrgent;
			
			ПараметрыОбласти.OriginCountry = ParcelLine.CountryName;
			
			ПараметрыОбласти.FromLocation = ParcelLine.ShipperCityLocation;
			
			ПараметрыОбласти.DestinationCountry = ParcelLine.POANameForMoveIt;
			
			ПараметрыОбласти.LocationTo = ParcelLine.DeliverToCityLocation;	
			
			ПараметрыОбласти.InvoiceToEntity = ParcelLine.SoldToNameForMoveIt;
			Если НЕ ЗначениеЗаполнено(ПараметрыОбласти.InvoiceToEntity) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"""Name for Move it"" in the SoldTo """ + СокрЛП(ParcelLine.SoldTo) + """ is empty!",
					ParcelLine.SoldTo,,, Отказ);
			КонецЕсли; 
			
			BORGCode = СокрЛП(ParcelLine.BORGCode);
			Если СтрДлина(BORGCode) = 2 Тогда
				BORGCodeCompanyNo = BORGCode + " - " + ParcelLine.CompanyNo;
			Иначе
				BORGCodeCompanyNo = BORGCode + "-" + ParcelLine.CompanyNo;
			КонецЕсли; 
			
			Если НЕ ЗначениеЗаполнено(ParcelLine.CompanyNo) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"""Company no."" in the SoldTo """ + СокрЛП(ParcelLine.SoldTo) + """ is empty!",
					ParcelLine.SoldTo,,, Отказ);
			КонецЕсли;
			
			AUCode = СокрЛП(ParcelLine.AUCode);
			Пока Лев(AUCode, 1) = "0" Цикл
				AUCode = Сред(AUCode, 2);
			КонецЦикла;
						
			ПараметрыОбласти.SegmentBORGAUAC = СокрЛП(ParcelLine.SegmentCode) + " / " + BORGCodeCompanyNo + " / " + AUCode + " / " + ParcelLine.Activity;
			
			// Package number
			Если ТекущийParcelNo <> ParcelLine.ParcelNo Тогда
				ТекущийParcelNo = ParcelLine.ParcelNo;
				ПорядковыйНомерПарселя = ПорядковыйНомерПарселя+1;
			КонецЕсли;
			ПараметрыОбласти.PackageNumber = ПорядковыйНомерПарселя;
			
			ПараметрыОбласти.PackageQuantity = 1;
			
			ПараметрыОбласти.GrossWeightKG = ParcelLine.GrossWeightKG;
			
			ПараметрыОбласти.LengthCM = ParcelLine.LengthCM;
			
			ПараметрыОбласти.WidthCM = ParcelLine.WidthCM;
			
			ПараметрыОбласти.HeightCM = ParcelLine.HeightCM;
			
			ПараметрыОбласти.EarliestPickUpDate = ParcelLine.ReadyToShipDate;
			
			ПараметрыОбласти.LatestDeliveryDate = ParcelLine.RequiredDeliveryDate;
			
			ПараметрыОбласти.PartNo = СокрЛП(ParcelLine.PartNo);
			
			ПараметрыОбласти.ItemDescription = ParcelLine.ItemDescription;
			
			ПараметрыОбласти.ItemType = ПолучитьItemType(ParcelLine.ERPTreatment);
			Если НЕ ЗначениеЗаполнено(ПараметрыОбласти.ItemType) Тогда
				Сообщить("Failed to determine Move IT item type by ERP treatment """ + ParcelLine.ERPTreatment + """!");
				Отказ = Истина;
			КонецЕсли;
			
			Если ЗначениеЗаполнено(ParcelLine.ParcelHazardClassNo) Тогда
				ПараметрыОбласти.Hazardous = "Yes";
				ПараметрыОбласти.ParcelHazardClass = ParcelLine.ParcelHazardClassNo;
			Иначе 
				ПараметрыОбласти.Hazardous = "No";
				ПараметрыОбласти.ParcelHazardClass = "";
			КонецЕсли;
			
			ПараметрыОбласти.SerialNo = ParcelLine.SerialNo;
			
			ПараметрыОбласти.HTC = ParcelLine.HTC;
			
			ПараметрыОбласти.Qty = ParcelLine.Qty;
			
			ПараметрыОбласти.UnitPrice = ParcelLine.UnitPrice;
			
			ПараметрыОбласти.CurrencyCode = СокрЛП(ParcelLine.CurrencyCode);
			
			ПараметрыОбласти.CargoComments = СокрЛП(ParcelLine.ExportShipmentNo) + " - " + ParcelLine.ExportRequestComments;
			
			ТабДок.Вывести(ОбластьParcelLine);
			
		КонецЦикла;
		
		ТабДок.ОтображатьСетку = Ложь;
		
		// Добавим сформированные табличный документ в массив
		МассивТабДоков.Добавить(ТабДок);
		
	КонецЦикла;
	
	Если Отказ Тогда
		Возврат Новый Массив;
	Иначе
		Возврат МассивТабДоков;
	КонецЕсли; 
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТаблицуДанныхВыгрузки(ExportShipment)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ExportShipment", ExportShipment);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ParcelsItems.Ссылка.Код КАК ParcelNo,
		|	ParcelsItems.Ссылка.HazardClass.Код КАК ParcelHazardClassNo,
		|	ParcelsItems.Ссылка.GrossWeightKG КАК GrossWeightKG,
		|	ParcelsItems.Ссылка.LengthCM КАК LengthCM,
		|	ParcelsItems.Ссылка.WidthCM КАК WidthCM,
		|	ParcelsItems.Ссылка.HeightCM КАК HeightCM,
		|	ВЫБОР
		|		КОГДА ParcelsItems.Ссылка.Urgency = ЗНАЧЕНИЕ(Перечисление.Urgencies.Emergency)
		|			ТОГДА ""YES""
		|		ИНАЧЕ ""NO""
		|	КОНЕЦ КАК IsUrgent,
		|	ParcelsItems.НомерСтроки КАК ParcelItemLineNo,
		|	ParcelsItems.СерийныйНомер КАК SerialNo,
		|	ParcelsItems.НомерЗаявкиНаЗакупку КАК PONo,
		|	ParcelsItems.Qty КАК Qty,
		|	ParcelsItems.СтрокаИнвойса.SoldTo КАК SoldTo,
		|	ParcelsItems.СтрокаИнвойса.SoldTo.NameForMoveIt КАК SoldToNameForMoveIt,
		|	ParcelsItems.СтрокаИнвойса.SoldTo.CompanyNo КАК CompanyNo,
		|	ParcelsItems.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
		|	ParcelsItems.СтрокаИнвойса.НаименованиеТовара КАК ItemDescription,
		|	ParcelsItems.СтрокаИнвойса.МеждународныйКодТНВЭД КАК HTC,
		|	ParcelsItems.СтрокаИнвойса.Цена КАК UnitPrice,
		|	ParcelsItems.СтрокаИнвойса.Классификатор КАК ERPTreatment,
		|	ParcelsItems.СтрокаИнвойса.Currency.НаименованиеEng КАК CurrencyCode,
		|	ExportShipmentExportRequests.Ссылка.Номер КАК ExportShipmentNo,
		|	ExportShipmentExportRequests.Ссылка.POA.NameForMoveIT КАК POANameForMoveIt,
		|	ExportShipmentExportRequests.ExportRequest.FromCountry.NameForMoveIT КАК CountryName,
		|	ExportShipmentExportRequests.ExportRequest.BORG.Код КАК BORGcode,
		|	ExportShipmentExportRequests.ExportRequest.AU.Код КАК AUcode,
		|	ExportShipmentExportRequests.ExportRequest.Activity КАК Activity,
		|	ExportShipmentExportRequests.ExportRequest.AU.Segment.Код КАК SegmentCode,
		|	ExportShipmentExportRequests.ExportRequest.Shipper.CityLocation КАК ShipperCityLocation,
		|	ExportShipmentExportRequests.ExportRequest.DeliverTo.CityLocation КАК DeliverToCityLocation,
		|	ExportShipmentExportRequests.ExportRequest.ReadyToShipDate КАК ReadyToShipDate,
		|	ExportShipmentExportRequests.ExportRequest.RequiredDeliveryDate КАК RequiredDeliveryDate,
		|	ExportShipmentExportRequests.ExportRequest.Comments КАК ExportRequestComments
		|ИЗ
		|	Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsItems
		|		ПО ExportShipmentExportRequests.ExportRequest = ParcelsItems.Ссылка.ExportRequest
		|			И ((НЕ ParcelsItems.Ссылка.Отменен))
		|ГДЕ
		|	ExportShipmentExportRequests.Ссылка = &ExportShipment";
		
	УстановитьПривилегированныйРежим(Истина);
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьItemType(ERPTreatment)
	
	ERPTreatments = Перечисления.ТипыЗаказа;
	Если ERPTreatment = ERPTreatments.E Тогда
		Возврат "M&S";
		
	ИначеЕсли ERPTreatment = ERPTreatments.I Тогда
		Возврат "New Inventory";
		
	ИначеЕсли ERPTreatment = ERPTreatments.A Тогда
		Возврат "New Asset (FTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.R Тогда
		Возврат "M&S";
		
	ИначеЕсли ERPTreatment = ERPTreatments.X Тогда
		Возврат "M&S";
		
	ИначеЕсли ERPTreatment = ERPTreatments.S Тогда
		Возврат "New Inventory";
		
	ИначеЕсли ERPTreatment = ERPTreatments.U Тогда
		Возврат "Asset Under Construction (NFTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.V Тогда
		Возврат "Asset Under Construction (FTE)";
		
	ИначеЕсли ERPTreatment = ERPTreatments.RAN Тогда
		Возврат "Used Asset";
		
	ИначеЕсли ERPTreatment = ERPTreatments.LOAN Тогда
		Возврат "Used Asset";
		
	ИначеЕсли ERPTreatment = ERPTreatments.FMT Тогда
		Возврат "Used Inventory";
		
	ИначеЕсли ERPTreatment = ERPTreatments.FAT Тогда
		Возврат "Used Asset";
		
	ИначеЕсли ERPTreatment = ERPTreatments.SS Тогда
		Возврат "M&S";
		
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

&НаСервере 
Функция ЗаполнитьProcessLevel(); // { RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816
	
	Объект.ProcessLevel = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ExportRequests[0].ExportRequest, "ProcessLevel");
		
КонецФункции  // } RGS AArsentev 23.08.2016 15:28:45 - S-I-0001816

&НаСервере
Процедура ПроверитьCCD(Отказ)
	
	ЕстьCCD = Документы.Service.ПроверимНаНаличиеCCD(Объект.Ссылка);
	Если Не ЕстьCCD Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Can't create 'Service' because there are no 'Customs Files'");
		Отказ = Не ЕстьCCD;
	КонецЕсли;
	
КонецПроцедуры

// { RGS DKazanskiy 10.10.2018 14:26:33 - S-I-0005759
// PERMITS

&НаКлиенте
Процедура PermitsRequired(Команда)
	
	МассивВыделенныхGoods = ПолучитьМассивВыделенныхItems();
	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item!",
		30);
		Возврат;
	КонецЕсли;
	
	МассивИзмененныхGoods = РГСофт.ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивВыделенныхGoods, "PermitsRequired", ПредопределенноеЗначение("Перечисление.YesNo.Yes"));
	
	Элементы.Items.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура PermitsNotRequired(Команда)
	
	МассивВыделенныхGoods = ПолучитьМассивВыделенныхItems();
	Если МассивВыделенныхGoods.Количество() = 0 Тогда
		Предупреждение(
		"Please, select at least one item!",
		30);
		Возврат;
	КонецЕсли;
	
	МассивИзмененныхGoods = РГСофт.ИзменитьРеквизитВСсылкахВПривилегированномРежиме(МассивВыделенныхGoods, "PermitsRequired", ПредопределенноеЗначение("Перечисление.YesNo.Yes"));
	
	Элементы.Items.Обновить();
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьМассивВыделенныхItems()
	
	Возврат Элементы.Items.ВыделенныеСтроки;
	
КонецФункции

&НаСервере
Процедура ОбновитьItems()
	
	ItemsСписок.Параметры.УстановитьЗначениеПараметра("ExportRequests", Объект.ExportRequests.Выгрузить().ВыгрузитьКолонку("ExportRequest"));
	
	Элементы.Items.Обновить();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьЗависимыеОтExportRequests()
	
	ОбновитьItems();
	
КонецПроцедуры

// } RGS DKazanskiy 10.10.2018 14:26:43 - S-I-0005759