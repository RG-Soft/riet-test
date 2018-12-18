  
////////////////////////////////////////////////////////////
// ФОРМА

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастроитьВидимостьUnpostИSave();	
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ОценкаПроизводительностиРГСофт.ТочноеВремя());
	//КонецЕсли;
	
	ТекущийОбъект.ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	НастроитьВидимостьUnpostИSave();
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.BatchOfCustomsFilesИнтерактивноеПроведение, Объект.Ссылка);	
	//КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////
// КОМАНДНАЯ ПАНЕЛЬ

&НаСервере
Процедура НастроитьВидимостьUnpostИSave()
	
	ImportExportСервер.НастроитьВидимостьUnpostИSave(Элементы.Найти("ФормаОтменаПроведения"), Элементы.Найти("ФормаЗаписать"), Объект.Проведен);
	
КонецПроцедуры

&НаКлиенте
Процедура Unload(Команда)
	
	Если НЕ Объект.Проведен Тогда
		Сообщить("Batch is not posted!");
		Возврат;
	КонецЕсли;
	
	Если Модифицированность Тогда
		Сообщить("Please, post the batch first!");
		Возврат;
	КонецЕсли;
	
	ТабДок = ПолучитьТабДокBatchOfCustomsFiles();
	Если ТабДок <> Неопределено Тогда
		ТабДок.Показать();
	КонецЕсли; 		
	
КонецПроцедуры

// ДОДЕЛАТЬ
&НаСервере
Функция ПолучитьТабДокBatchOfCustomsFiles()
	
	ParentCompanyNo = РГСофтСерверПовтИспСеанс.ЗначениеРеквизитаОбъекта(Объект.SoldTo, "CompanyNo");
	Если НЕ ЗначениеЗаполнено(ParentCompanyNo) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Company no.' in Parent company '" + СокрЛП(Объект.SoldTo) + "' is empty!",
			Объект.SoldTo, "CompanyNo");
		Возврат Неопределено;
		
	КонецЕсли; 
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	SettingsOfCustomsFilesToLawson = РегистрыСведений.SettingsOfCustomsFilesToLawson.ПолучитьSettings(Объект.Дата, Объект.SoldTo);	
	Если SettingsOfCustomsFilesToLawson = Неопределено Тогда 
		
		ОтменитьТранзакцию();
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"There are no settings of customs files to lawson for Parent company '" + СокрЛП(Объект.SoldTo) + "'!",
			 Объект.SoldTo);	
		Возврат Неопределено;
		
	КонецЕсли;
	
	// структура реквизитов шапки выгрузки		
	СтруктураРеквизитовШапки = Новый Структура;
	СтруктураРеквизитовШапки.Вставить("Номер", Объект.Номер);
	СтруктураРеквизитовШапки.Вставить("Дата", Объект.Дата);
	СтруктураРеквизитовШапки.Вставить("LastModified", Объект.ModificationDate);
	СтруктураРеквизитовШапки.Вставить("SoldTo", Объект.SoldTo);
	СтруктураРеквизитовШапки.Вставить("CompanyNo", ParentCompanyNo);
	СтруктураРеквизитовШапки.Вставить("Responsible", Объект.ModifiedBy);
	СтруктураРеквизитовШапки.Вставить("Comment", Объект.Comment);
	
	// таблица шапок документов	
	ЗапросШапокДокументов = Новый Запрос;

	//по просьбе Saida Mussagaliyeva 23.01.2014
	Если Объект.ProcessLevel = Справочники.ProcessLevels.KZ Тогда 
		ЗапросШапокДокументов.УстановитьПараметр("Commodity", "");
	иначе
		ЗапросШапокДокументов.УстановитьПараметр("Commodity", "700-10");
	КонецЕсли;

	МассивCustomsFiles = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CCDs, "CCD");
	ЗапросШапокДокументов.УстановитьПараметр("МассивCustomsFiles", МассивCustomsFiles);
	
	МассивCustomsFilesOfTempImpExp = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsFilesOfTemporaryImportExport, "CustomsFile");
	ЗапросШапокДокументов.УстановитьПараметр("МассивCustomsFilesOfTempImpExp", МассивCustomsFilesOfTempImpExp);
	
	МассивCustomsReceiptOrders = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.ТПО, "ТПО");
	ЗапросШапокДокументов.УстановитьПараметр("МассивCustomsReceiptOrders", МассивCustomsReceiptOrders);
	
	МассивCustomsBonds = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBonds, "CustomsBond");
	ЗапросШапокДокументов.УстановитьПараметр("МассивCustomsBonds", МассивCustomsBonds); 
	
	МассивCustomsBondClosings = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBondClosings, "CustomsBondClosing");	
	ЗапросШапокДокументов.УстановитьПараметр("МассивCustomsBondClosings", МассивCustomsBondClosings);
		
	ЗапросШапокДокументов.Текст = 
		"ВЫБРАТЬ
		|	CustomsFiles.Ссылка КАК Document,
		|	CustomsFiles.Номер КАК DocumentNo,
		|	CustomsFiles.Дата КАК DocumentDate,
		|	CustomsFiles.ДатаВыпуска КАК InvRecptDate,
		|	CustomsFiles.ДатаВыпуска КАК DueDate,
		|	CustomsFiles.CustomsPost.Customs.LawsonContractor.Код КАК VendorID,
		|	CustomsFiles.CustomsPost.Customs.TaxCode КАК TaxCode,
		|	&Commodity КАК Commodity
		|ИЗ
		|	Документ.ГТД КАК CustomsFiles
		|ГДЕ
		|	(CustomsFiles.Ссылка В (&МассивCustomsFiles)
		|			ИЛИ CustomsFiles.Ссылка В (&МассивCustomsFilesOfTempImpExp))
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	CustomsReceiptOrders.Ссылка,
		|	CustomsReceiptOrders.Номер,
		|	CustomsReceiptOrders.Дата,
		|	CustomsReceiptOrders.ReleaseDate,
		|	CustomsReceiptOrders.ReleaseDate,
		|	CustomsReceiptOrders.CustomsPost.Customs.LawsonContractor.Код,
		|	CustomsReceiptOrders.CustomsPost.Customs.TaxCode,
		|	&Commodity
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsReceiptOrders
		|ГДЕ
		|	CustomsReceiptOrders.Ссылка В(&МассивCustomsReceiptOrders)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	CustomsBondsAndClosings.Ссылка,
		|	CustomsBondsAndClosings.Номер,
		|	CustomsBondsAndClosings.Дата,
		|	CustomsBondsAndClosings.Дата,
		|	CustomsBondsAndClosings.Дата,
		|	CustomsBondsAndClosings.CustomsPost.Customs.LawsonContractor.Код,
		|	CustomsBondsAndClosings.CustomsPost.Customs.TaxCode,
		|	&Commodity
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsBondsAndClosings
		|ГДЕ
		|	(CustomsBondsAndClosings.Ссылка В (&МассивCustomsBonds)
		|			ИЛИ CustomsBondsAndClosings.Ссылка В (&МассивCustomsBondClosings))";
				
	ТаблицаШапокДокументов = ЗапросШапокДокументов.Выполнить().Выгрузить();	
	     
	// таблица деталей документов
	ЗапросДеталейДокументов = Новый Запрос;
	ЗапросДеталейДокументов.УстановитьПараметр("Дата", Объект.Дата);
	
	// НЕ НАДО ХАРДКОДИТЬ, НАДО СДЕЛАТЬ ПЕРИОДИЧЕСКИЙ РЕГИСТР СВЕДЕНИЙ
	// ПРАВДА ТОГДА НУЖНО СОХРАНЯТЬ CUSTOMS BOND ACCOUNT ЧТОБЫ ПОТОМ ИМЕННО ЕГО СПИСАТЬ В CUSTOMS BOND CLOSING
	ЗапросДеталейДокументов.УстановитьПараметр("AccountForDeposits", "141102");
	ЗапросДеталейДокументов.УстановитьПараметр("SubAccountForDeposits", "141102-1");
	ЗапросДеталейДокументов.УстановитьПараметр("AUForDeposits", "2812019");
	
	ParametersType = SettingsOfCustomsFilesToLawson.Type;
	Если ParametersType = Перечисления.TypesOfCustomsFilesUnloading.ParametersFromItems Тогда
		
		// Accounts для Expense                              
		СтруктураERPTreatmentAccountsExpense = РегистрыСведений.ERPTreatmentAccounts.ПолучитьAccountsПовтИсп(Объект.Дата, Перечисления.ТипыЗаказа.E);  
	    ЗапросДеталейДокументов.УстановитьПараметр("AccountExpense", СтруктураERPTreatmentAccountsExpense.CCDAccount);
		ЗапросДеталейДокументов.УстановитьПараметр("SubAccountExpense", СтруктураERPTreatmentAccountsExpense.CCDSubAccount);
		
	Иначе
		
		AUNo = СокрЛП(РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(SettingsOfCustomsFilesToLawson.AU, "Код"));
		ЗапросДеталейДокументов.УстановитьПараметр("AUNo", AUNo);
		ЗапросДеталейДокументов.УстановитьПараметр("Activity", SettingsOfCustomsFilesToLawson.Activity);
		ЗапросДеталейДокументов.УстановитьПараметр("Account", SettingsOfCustomsFilesToLawson.Account);
		ЗапросДеталейДокументов.УстановитьПараметр("SubAccount", SettingsOfCustomsFilesToLawson.SubAccount);
		
	КонецЕсли;
	
	ЗапросДеталейДокументов.Текст = "";
	
	ДополнитьЗапросДеталямиCustomsFiles(ЗапросДеталейДокументов, МассивCustomsFiles, ParametersType);
		
	ДополнитьЗапросДеталямиCustomsFilesOfTempImpExp(ЗапросДеталейДокументов, МассивCustomsFilesOfTempImpExp, ParametersType);   	
	
    ДополнитьЗапросДеталямиCustomsReceiptOrders(ЗапросДеталейДокументов, МассивCustomsReceiptOrders, ParametersType);
	
    ДополнитьЗапросДеталямиCustomsBonds(ЗапросДеталейДокументов, МассивCustomsBonds, ParametersType);
	
    ДополнитьЗапросДеталямиCustomsBondClosings(ЗапросДеталейДокументов, МассивCustomsBondClosings, ParametersType);
	     			        	
	ТаблицаДеталейДокументов = ЗапросДеталейДокументов.Выполнить().Выгрузить();
	
	//очистим для НДС: AUNo, AccountNo, Activity, SubAccountNo, чтобы сумма НДС свернулась одной строкой 
	Для Каждого СтрокаТаблицы из ТаблицаДеталейДокументов Цикл 
		
		Если ЗначениеЗаполнено(СтрокаТаблицы.BORGcode) 
			И Лев(СтрокаТаблицы.BORGcode, 1) = "7" Тогда
			
			//S-I-0002231
			Справочники.BORGs.ПодменитьAU_ACДля7BORGcodes(СтрокаТаблицы, "AUNo",  "Activity", СтрокаТаблицы.BORGcode);
			
		КонецЕсли;	
			
		Если СтрокаТаблицы.НДС Тогда 
			СтрокаТаблицы.AUNo         = Неопределено;
			СтрокаТаблицы.AccountNo    = Неопределено;
			СтрокаТаблицы.Activity     = Неопределено;
			СтрокаТаблицы.SubAccountNo = Неопределено;
		КонецЕсли;
		
	КонецЦикла;
	
	ТаблицаДеталейДокументов.Свернуть("Document, DocumentBaseNo, НДС, AUNo, AccountNo, Activity, SubAccountNo", "Amount");
	
	ЗафиксироватьТранзакцию();
	
	Возврат CustomsСервер.ПолучитьТабличныйДокументВыгрузкиВLawson(СтруктураРеквизитовШапки, ТаблицаШапокДокументов, ТаблицаДеталейДокументов);
		
КонецФункции

&НаСервере
Процедура ДополнитьЗапросДеталямиCustomsFiles(Запрос, МассивCustomsFiles, ParametersType)
	
	Если МассивCustomsFiles.Количество() = 0 Тогда 
		Возврат;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("МассивCustomsFiles", МассивCustomsFiles);

	Если Не ПустаяСтрока(Запрос.Текст) Тогда 
		Запрос.Текст = Запрос.Текст + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
	КонецЕсли;
	
	Если ParametersType = Перечисления.TypesOfCustomsFilesUnloading.ParametersFromItems Тогда
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	InvoiceLinesCostsОбороты.AU.Код КАК AUNo,
			|	ERPTreatmentAccountsСрезПоследних.CCDAccount КАК AccountNo,
			|	ERPTreatmentAccountsСрезПоследних.CCDSubAccount КАК SubAccountNo,
			|	InvoiceLinesCostsОбороты.Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	ПОДСТРОКА(InvoiceLinesCostsОбороты.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(
			|			,
			|			,
			|			,
			|			НЕ AU.NonLawson
			|				И ДокументОснование В (&МассивCustomsFiles)) КАК InvoiceLinesCostsОбороты
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ERPTreatmentAccounts.СрезПоследних(&Дата, ) КАК ERPTreatmentAccountsСрезПоследних
			|		ПО InvoiceLinesCostsОбороты.ERPTreatment = ERPTreatmentAccountsСрезПоследних.ERPTreatment";
		
	Иначе
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	&AUNo КАК AUNo,
			|	&Account КАК AccountNo,
			|	&SubAccount КАК SubAccountNo,
			|	&Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	"""" КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(, , , ДокументОснование В (&МассивCustomsFiles)) КАК InvoiceLinesCostsОбороты";
		
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура ДополнитьЗапросДеталямиCustomsFilesOfTempImpExp(Запрос, МассивCustomsFilesOfTempImpExp, ParametersType)
	
	Если МассивCustomsFilesOfTempImpExp.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("МассивCustomsFilesOfTempImpExp", МассивCustomsFilesOfTempImpExp);
	
	Если Не ПустаяСтрока(Запрос.Текст) Тогда 
		Запрос.Текст = Запрос.Текст + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
	КонецЕсли;
	
	Если ParametersType = Перечисления.TypesOfCustomsFilesUnloading.ParametersFromItems Тогда
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	InvoiceLinesCostsОбороты.AU.Код КАК AUNo,
			|	&AccountExpense КАК AccountNo,
			|	&SubAccountExpense КАК SubAccountNo,
			|	InvoiceLinesCostsОбороты.Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	ПОДСТРОКА(InvoiceLinesCostsОбороты.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(
			|			,
			|			,
			|			,
			|			НЕ AU.NonLawson
			|				И ДокументОснование В (&МассивCustomsFilesOfTempImpExp)) КАК InvoiceLinesCostsОбороты";
		
	Иначе
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	&AUNo КАК AUNo,
			|	&Account КАК AccountNo,
			|	&SubAccount КАК SubAccountNo,
			|	&Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	"""" КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(, , , ДокументОснование В (&МассивCustomsFilesOfTempImpExp)) КАК InvoiceLinesCostsОбороты";
		
	КонецЕсли;
		
КонецПроцедуры

// ДОДЕЛАТЬ
&НаСервере
Процедура ДополнитьЗапросДеталямиCustomsReceiptOrders(Запрос, МассивCustomsReceiptOrders, ParametersType)
	
	Если МассивCustomsReceiptOrders.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("МассивCustomsReceiptOrders", МассивCustomsReceiptOrders);
		
	Если Не ПустаяСтрока(Запрос.Текст) Тогда 
		Запрос.Текст = Запрос.Текст + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
	КонецЕсли;
	
	Если ParametersType = Перечисления.TypesOfCustomsFilesUnloading.ParametersFromItems Тогда
		
		// ХОРОШО БЫ НЕ ХАРДКОДИТЬ СЧЕТА ПРЯМО В ЗАПРОСЕ, А РАЗОБРАТЬСЯ ОТКУДА ОНИ БЕРУТСЯ И СДЕЛАТЬ НАСТРОЙКУ
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	СтоимостьТоваровПоТПООбороты.DocumentBase КАК Document,
			|	СтоимостьТоваровПоТПООбороты.DocumentBase.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА СтоимостьТоваровПоТПООбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	СтоимостьТоваровПоТПООбороты.AU.Код КАК AUNo,
			|	""531006"" КАК AccountNo,
			|	"""" КАК SubAccountNo,
			|	СтоимостьТоваровПоТПООбороты.Activity КАК Activity,
			|	СтоимостьТоваровПоТПООбороты.FiscalSumОборот КАК Amount,
			|	"""" КАК BORGcode
			|ИЗ
			|	РегистрНакопления.СтоимостьТоваровПоТПО.Обороты(
			|			,
			|			,
			|			,
			|			НЕ AU.NonLawson
			|				И DocumentBase В (&МассивCustomsReceiptOrders)) КАК СтоимостьТоваровПоТПООбороты";
		
	Иначе
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	СтоимостьТоваровПоТПООбороты.DocumentBase КАК Document,
			|	СтоимостьТоваровПоТПООбороты.DocumentBase.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА СтоимостьТоваровПоТПООбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	&AUNo КАК AUNo,
			|	&Account КАК AccountNo,
			|	&SubAccount КАК SubAccountNo,
			|	СтоимостьТоваровПоТПООбороты.Activity КАК Activity,
			|	СтоимостьТоваровПоТПООбороты.FiscalSumОборот КАК Amount,
			|	"""" КАК BORGcode
			|ИЗ
			|	РегистрНакопления.СтоимостьТоваровПоТПО.Обороты(, , , DocumentBase В (&МассивCustomsReceiptOrders)) КАК СтоимостьТоваровПоТПООбороты";
		
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура ДополнитьЗапросДеталямиCustomsBonds(Запрос, МассивCustomsBonds, ParametersType)
	
	Если МассивCustomsBonds.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("МассивCustomsBonds", МассивCustomsBonds);
	
	Если Не ПустаяСтрока(Запрос.Текст) Тогда 
		Запрос.Текст = Запрос.Текст + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
	КонецЕсли;
		
	Запрос.Текст = Запрос.Текст +
		"ВЫБРАТЬ
		|	CustomsFilesLight.Ссылка КАК Document,
		|	CustomsFilesLight.Номер КАК DocumentBaseNo,
		|	ЛОЖЬ КАК НДС,
		|	&AUForDeposits КАК AUNo,
		|	&AccountForDeposits КАК AccountNo,
		|	&SubAccountForDeposits КАК SubAccountNo,
		|	"""" КАК Activity,
		|	CustomsFilesLight.ИтогоПоГрафеВ КАК Amount,
		|	"""" КАК BORGcode
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsFilesLight
		|ГДЕ
		|	CustomsFilesLight.Ссылка В(&МассивCustomsBonds)";
		
КонецПроцедуры

&НаСервере
Процедура ДополнитьЗапросДеталямиCustomsBondClosings(Запрос, МассивCustomsBondClosings, ParametersType)
	
	Если МассивCustomsBondClosings.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("МассивCustomsBondClosings", МассивCustomsBondClosings);
	
	Если Не ПустаяСтрока(Запрос.Текст) Тогда 
		Запрос.Текст = Запрос.Текст + "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|";
	КонецЕсли;
	
	Если ParametersType = Перечисления.TypesOfCustomsFilesUnloading.ParametersFromItems Тогда
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	InvoiceLinesCostsОбороты.AU.Код КАК AUNo,
			|	&AccountExpense КАК AccountNo,
			|	&SubAccountExpense КАК SubAccountNo,
			|	InvoiceLinesCostsОбороты.Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	ПОДСТРОКА(InvoiceLinesCostsОбороты.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(
			|			,
			|			,
			|			,
			|			НЕ AU.NonLawson
			|				И ДокументОснование В (&МассивCustomsBondClosings)) КАК InvoiceLinesCostsОбороты";
		
	Иначе
		
		Запрос.Текст = Запрос.Текст +
			"ВЫБРАТЬ
			|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
			|	InvoiceLinesCostsОбороты.ДокументОснование.Номер КАК DocumentBaseNo,
			|	ВЫБОР
			|		КОГДА InvoiceLinesCostsОбороты.ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
			|			ТОГДА ИСТИНА
			|		ИНАЧЕ ЛОЖЬ
			|	КОНЕЦ КАК НДС,
			|	&AUNo КАК AUNo,
			|	&Account КАК AccountNo,
			|	&SubAccount КАК SubAccountNo,
			|	&Activity КАК Activity,
			|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
			|	"""" КАК BORGcode
			|ИЗ
			|	РегистрНакопления.InvoiceLinesCosts.Обороты(, , , ДокументОснование В (&МассивCustomsBondClosings)) КАК InvoiceLinesCostsОбороты";
		
	КонецЕсли;
			
	Запрос.Текст = Запрос.Текст + "
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	CustomsFilesLight.Ссылка КАК Document,
		|	ВЫБОР
		|		КОГДА CustomsFilesLight.CustomsBond.ИтогоПоГрафеВ = CustomsFilesLight.CustomsDepositAmountToRefund
		|			ТОГДА CustomsFilesLight.Номер
		|		ИНАЧЕ ""Reverse "" + CustomsFilesLight.CustomsBond.Номер
		|	КОНЕЦ КАК DocumentBaseNo,
		|	ЛОЖЬ КАК НДС,
		|	&AUForDeposits КАК AUNo,
		|	&AccountForDeposits КАК AccountNo,
		|	&SubAccountForDeposits КАК SubAccountNo,
		|	"""" КАК Activity,
		|	-CustomsFilesLight.CustomsDepositAmountToRefund КАК Amount,
		|	"""" КАК BORGcode
		|ИЗ
		|	Документ.CustomsFilesLight КАК CustomsFilesLight
		|ГДЕ
		|	CustomsFilesLight.Ссылка В(&МассивCustomsBondClosings)
		|	И CustomsFilesLight.CustomsDepositAmountToRefund <> 0";	
		
	Запрос.Текст = Запрос.Текст + "
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	InvoiceLinesCostsОбороты.ДокументОснование КАК Document,
		|	""Reverse "" + InvoiceLinesCostsОбороты.ДокументОснование.CustomsBond.Номер КАК DocumentBaseNo,
		|	ЛОЖЬ КАК НДС,
		|	&AUForDeposits КАК AUNo,
		|	&AccountForDeposits КАК AccountNo,
		|	&SubAccountForDeposits КАК SubAccountNo,
		|	"""" КАК Activity,
		|	-InvoiceLinesCostsОбороты.СуммаФискальнаяОборот  КАК Amount,
		|	"""" КАК BORGcode
		|ИЗ
		|	РегистрНакопления.InvoiceLinesCosts.Обороты(, , , ДокументОснование В (&МассивCustomsBondClosings)) КАК InvoiceLinesCostsОбороты";
	                  		
КонецПроцедуры


////////////////////////////////////////////////////////////
// HEADER

&НаКлиенте
Процедура ProcessLevelНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			, "Country", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура LegalEntityНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если НЕ ЗначениеЗаполнено(Объект.Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			, "Country", "Объект");
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////
// ЗАПОЛНЕНИЕ ТАБЛИЧНЫХ ЧАСТЕЙ

&НаКлиенте
Процедура Fill(Команда)
	
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
		
	Очистить = Ложь;
	Если Объект.CCDs.Количество() ИЛИ Объект.ТПО.Количество() ИЛИ Объект.CustomsFilesOfTemporaryImportExport.Количество()
		ИЛИ Объект.CustomsBonds.Количество() ИЛИ Объект.CustomsBondClosings.Количество() Тогда
		
		Ответ = Вопрос("Очистить таблицы перед заполнением?", РежимДиалогаВопрос.ДаНет, 30, КодВозвратаДиалога.Да, "Заполнение таблиц", КодВозвратаДиалога.Нет);
		Если Ответ = КодВозвратаДиалога.Да Тогда
			Очистить = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	ЗаполнитьТаблицыНаСервере(Очистить);
			
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицыНаСервере(Очистить)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	Модифицированность = Истина;
	
	// очистим ТЧ при необходимости
	Если Очистить Тогда
		Объект.CCDs.Очистить();
		Объект.ТПО.Очистить();
		Объект.CustomsFilesOfTemporaryImportExport.Очистить();
		Объект.CustomsBonds.Очистить();
		Объект.CustomsBondClosings.Очистить();
	КонецЕсли; 
	
	// customs files
	CurrentCustomsFiles = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CCDs, "CCD");
	ReadyCustomsFiles = Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsFiles(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsFiles, Объект.Ссылка);
	Для Каждого ReadyCustomsFile Из ReadyCustomsFiles Цикл
		НоваяСтрока = Объект.CCDs.Добавить();
		НоваяСтрока.CCD = ReadyCustomsFile;	
	КонецЦикла;
	
	// customs files of temp. imp./exp.
	CurrentCustomsFilesOfTempImpExp = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsFilesOfTemporaryImportExport, "CustomsFile");
	ReadyCustomsFilesOfTempImpExp = Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsFilesOfTempImpExp(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsFilesOfTempImpExp, Объект.Ссылка);
    Для Каждого ReadyCustomsFileOfTempImpExp Из ReadyCustomsFilesOfTempImpExp Цикл
		НоваяСтрока = Объект.CustomsFilesOfTemporaryImportExport.Добавить();
		НоваяСтрока.CustomsFile = ReadyCustomsFileOfTempImpExp;	
	КонецЦикла;
	
	// customs receipt orders
	CurrentCustomsReceiptOrders = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.ТПО, "ТПО");
	ReadyCustomsReceiptOrders = Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsReceiptOrders(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsReceiptOrders, Объект.Ссылка);
	Для Каждого ReadyCustomsReceiptOrder Из ReadyCustomsReceiptOrders Цикл
		НоваяСтрока = Объект.ТПО.Добавить();
		НоваяСтрока.ТПО = ReadyCustomsReceiptOrder;		 
	КонецЦикла; 
	
	// customs bonds
	CurrentCustomsBonds = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBonds, "CustomsBond");
	ReadyCustomsBonds = Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsBonds(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsBonds, Объект.Ссылка);
	Для Каждого ReadyCustomsBond Из ReadyCustomsBonds Цикл
		НоваяСтрока = Объект.CustomsBonds.Добавить();
		НоваяСтрока.CustomsBond = ReadyCustomsBond;		 
	КонецЦикла;
	
	// customs bond closings
	CurrentCustomsBondClosings = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBondClosings, "CustomsBondClosing");
	ReadyCustomsBondClosings = Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsBondClosings(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsBondClosings, Объект.Ссылка);
	Для Каждого ReadyCustomsBondClosing Из ReadyCustomsBondClosings Цикл
		НоваяСтрока = Объект.CustomsBondClosings.Добавить();
		НоваяСтрока.CustomsBondClosing = ReadyCustomsBondClosing;		 
	КонецЦикла;
		
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.BatchOfCustomsFilesИнтерактивноеЗаполнение, Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Функция МожноПолучитьCustomsDocuments()
	
	Отказ = Ложь;
	
	Если НЕ ЗначениеЗаполнено(Объект.Дата) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Date' is empty!",
			, "Дата", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Process level' is empty!",
			, "ProcessLevel", "Объект", Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли; 
	
	Возврат НЕ Отказ;
	
КонецФункции 


////////////////////////////////////////////////////////////
// CUSTOMS FILES

&НаКлиенте
Процедура CustomsFilesПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// переопределим стандартный механизм платформы
	Отказ = Истина;
	
	// проверим реквизиты, необходимые для выбора
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
	
	// получим массив доступных Customs files
	CurrentCustomsFiles = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CCDs, "CCD"); 
	ReadyCustomsFiles = ПолучитьReadyCustomsFiles(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsFiles, Объект.Ссылка);
	
	// если доступных Customs files нет - сообщим и откажемся от выбора
	Если ReadyCustomsFiles.Количество() = 0 Тогда
		Сообщить("No ready customs file found!");
		Возврат;
	КонецЕсли;
	
	// настроем и откроем форму выбора
	СтруктураОтбора = Новый Структура;	
	СтруктураОтбора.Вставить("ProcessLevel", Объект.ProcessLevel);
	СтруктураОтбора.Вставить("SoldTo", Объект.SoldTo);
	СтруктураОтбора.Вставить("Проведен", Истина);
	СтруктураОтбора.Вставить("Ссылка", ReadyCustomsFiles);	
	
	СтруктураПараметров = Новый Структура("Отбор", СтруктураОтбора);
	ОткрытьФорму("Документ.ГТД.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьReadyCustomsFiles(Дата, ProcessLevel, ParentCompany, CurrentCustomsFiles, CurrentBatch)
	
	Возврат Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsFiles(Дата, ProcessLevel, ParentCompany, CurrentCustomsFiles, CurrentBatch); 
	
КонецФункции

&НаКлиенте
Процедура CustomsFilesОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ВыбранноеЗначение)
		И ТипЗнч(ВыбранноеЗначение) = Тип("ДокументСсылка.ГТД") Тогда
		
		НоваяСтрока = Объект.CCDs.Добавить();
		НоваяСтрока.CCD = ВыбранноеЗначение;
		
		Модифицированность = Истина;
				
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsFilesВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	CustomsFile = Объект.CCDs.НайтиПоИдентификатору(ВыбраннаяСтрока).CCD;
	Если ЗначениеЗаполнено(CustomsFile) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,CustomsFile);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////
// CUSTOMS FILES OF TEMP IMP EXP

&НаКлиенте
Процедура CustomsFilesOfTempImpExpПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// переопределим стандартный механизм платформы
	Отказ = Истина;
	
	// проверим реквизиты, необходимые для выбора
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
	
	// получим ready customs files of temp. imp./exp.
	CurrentCustomsFilesOfTempImpExp = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsFilesOfTemporaryImportExport, "CustomsFile");
	ReadyCustomsFilesOfTempImpExp = ПолучитьReadyCustomsFilesOfTempImpExp(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsFilesOfTempImpExp, Объект.Ссылка);
	
	// если доступных документов нет - сообщим и откажемся от выбора
	Если ReadyCustomsFilesOfTempImpExp.Количество() = 0 Тогда
		Сообщить("No ready customs files of temp. imp./exp. found!");
		Возврат;
	КонецЕсли;
	
	// настроем и откроем форму выбора
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ProcessLevel", Объект.ProcessLevel);
	СтруктураОтбора.Вставить("SoldTo", Объект.SoldTo);
	СтруктураОтбора.Вставить("Проведен", Истина);
	СтруктураОтбора.Вставить("Ссылка", ReadyCustomsFilesOfTempImpExp);
	
	СтруктураПараметров = Новый Структура("Отбор", СтруктураОтбора);
	ОткрытьФорму("Документ.ГТД.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьReadyCustomsFilesOfTempImpExp(Дата, ProcessLevel, ParentCompany, CurrentCustomsFilesOfTempImpExp, CurrentBatch)
	
	Возврат Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsFilesOfTempImpExp(Дата, ProcessLevel, ParentCompany, CurrentCustomsFilesOfTempImpExp, CurrentBatch);
	
КонецФункции

&НаКлиенте
Процедура CustomsFilesOfTempImpExpОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	  	
	Если ЗначениеЗаполнено(ВыбранноеЗначение)
		И ТипЗнч(ВыбранноеЗначение) = Тип("ДокументСсылка.ГТД") Тогда
		
		НоваяСтрока = Объект.CustomsFilesOfTemporaryImportExport.Добавить();
		НоваяСтрока.CustomsFile = ВыбранноеЗначение;
		
		Модифицированность = Истина;
				
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsFilesOfTempImpExpВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	CustomsFile = Объект.CustomsFilesOfTemporaryImportExport.НайтиПоИдентификатору(ВыбраннаяСтрока).CustomsFile;
	Если ЗначениеЗаполнено(CustomsFile) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,CustomsFile);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////
// CUSTOMS RECEIPT ORDERS

&НаКлиенте
Процедура CustomsReceiptOrdersПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// переопределим стандартный механизм платформы
	Отказ = Истина;
	
	// проверим реквизиты, необходимые для выбора
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
	
	// получим массив доступных документов
	CurrentCustomsReceiptOrders = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.ТПО, "ТПО");
	ReadyCustomsReceiptOrders = ПолучитьReadyCustomsReceiptOrders(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsReceiptOrders, Объект.Ссылка);
	
	// если доступных документов нет - сообщим и откажемся от выбора
	Если ReadyCustomsReceiptOrders.Количество() = 0 Тогда
		Сообщить("No ready customs receipt order found!");
		Возврат;
	КонецЕсли;
	
	// настроем и откроем форму выбора
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ProcessLevel", Объект.ProcessLevel);
	СтруктураОтбора.Вставить("SoldTo", Объект.SoldTo);
	СтруктураОтбора.Вставить("TypeOfTransaction", ПредопределенноеЗначение("Перечисление.TypesOfCustomsFileLightTransaction.ТПО"));
	СтруктураОтбора.Вставить("Проведен", Истина);
	СтруктураОтбора.Вставить("Ссылка", ReadyCustomsReceiptOrders);
	
	СтруктураПараметров = Новый Структура("Отбор", СтруктураОтбора);
	ОткрытьФорму("Документ.CustomsFilesLight.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьReadyCustomsReceiptOrders(Дата, ProcessLevel, ParentCompany, CurrentCustomsReceiptOrders, CurrentBatch)
	
	Возврат Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsReceiptOrders(Дата, ProcessLevel, ParentCompany, CurrentCustomsReceiptOrders, CurrentBatch);
	
КонецФункции

&НаКлиенте
Процедура CustomsReceiptOrdersОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ВыбранноеЗначение)
		И ТипЗнч(ВыбранноеЗначение) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		НоваяСтрока = Объект.ТПО.Добавить();
		НоваяСтрока.ТПО = ВыбранноеЗначение;
		
		Модифицированность = Истина;
				
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsReceiptOrdersВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТПО = Объект.ТПО.НайтиПоИдентификатору(ВыбраннаяСтрока).ТПО;
	Если ЗначениеЗаполнено(ТПО) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,ТПО);
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////
// CUSTOMS BONDS

&НаКлиенте
Процедура CustomsBondsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// переопределим стандартный механизм платформы
	Отказ = Истина;
	
	// проверим реквизиты, необходимые для выбора
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
	
	// получим массив доступных документов
	CurrentCustomsBonds = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBonds, "CustomsBond");
	ReadyCustomsBonds = ПолучитьReadyCustomsBonds(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsBonds, Объект.Ссылка);
	
	// если доступных документов нет - сообщим и откажемся от выбора
	Если ReadyCustomsBonds.Количество() = 0 Тогда
		Сообщить("No ready customs bond found!");
		Возврат;
	КонецЕсли;
	
	// настроем и откроем форму выбора
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ProcessLevel", Объект.ProcessLevel);
	СтруктураОтбора.Вставить("SoldTo", Объект.SoldTo);
	СтруктураОтбора.Вставить("TypeOfTransaction", ПредопределенноеЗначение("Перечисление.TypesOfCustomsFileLightTransaction.CustomsBond"));
	СтруктураОтбора.Вставить("Проведен", Истина);
	СтруктураОтбора.Вставить("Ссылка", ReadyCustomsBonds);
	
	СтруктураПараметров = Новый Структура("Отбор", СтруктураОтбора);
	ОткрытьФорму("Документ.CustomsFilesLight.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьReadyCustomsBonds(Дата, ProcessLevel, ParentCompany, CurrentCustomsBonds, CurrentBatch)
	
	Возврат Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsBonds(Дата, ProcessLevel, ParentCompany, CurrentCustomsBonds, CurrentBatch);
	
КонецФункции

&НаКлиенте
Процедура CustomsBondsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ВыбранноеЗначение)
		И ТипЗнч(ВыбранноеЗначение) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		НоваяСтрока = Объект.CustomsBonds.Добавить();
		НоваяСтрока.CustomsBond = ВыбранноеЗначение;
		
		Модифицированность = Истина;
				
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура CustomsBondsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	CustomsBond = Объект.CustomsBonds.НайтиПоИдентификатору(ВыбраннаяСтрока).CustomsBond;
	Если ЗначениеЗаполнено(CustomsBond) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,CustomsBond);
	КонецЕсли;	
	
КонецПроцедуры
                      

////////////////////////////////////////////////////////////
// CUSTOMS BOND CLOSINGS

&НаКлиенте
Процедура CustomsBondClosingsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	// переопределим стандартный механизм платформы
	Отказ = Истина;
	
	// проверим реквизиты, необходимые для выбора
	Если НЕ МожноПолучитьCustomsDocuments() Тогда
		Возврат;
	КонецЕсли;
	
	// получим массив доступных документов
	CurrentCustomsBondClosings = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.CustomsBondClosings, "CustomsBondClosing");
	ReadyCustomsBondClosings = ПолучитьReadyCustomsBondClosings(Объект.Дата, Объект.ProcessLevel, Объект.SoldTo, CurrentCustomsBondClosings, Объект.Ссылка);
	
	// если доступных документов нет - сообщим и откажемся от выбора
	Если ReadyCustomsBondClosings.Количество() = 0 Тогда
		Сообщить("No ready customs bond closing found!");
		Возврат;
	КонецЕсли;
	
	// настроем и откроем форму выбора
	СтруктураОтбора = Новый Структура;
	СтруктураОтбора.Вставить("ProcessLevel", Объект.ProcessLevel);
	СтруктураОтбора.Вставить("SoldTo", Объект.SoldTo);
	СтруктураОтбора.Вставить("TypeOfTransaction", ПредопределенноеЗначение("Перечисление.TypesOfCustomsFileLightTransaction.CustomsBondClosing"));
	СтруктураОтбора.Вставить("Проведен", Истина);
	СтруктураОтбора.Вставить("Ссылка", ReadyCustomsBondClosings);
	
	СтруктураПараметров = Новый Структура("Отбор", СтруктураОтбора);
	ОткрытьФорму("Документ.CustomsFilesLight.ФормаВыбора", СтруктураПараметров, Элемент);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьReadyCustomsBondClosings(Дата, ProcessLevel, ParentCompany, CurrentCustomsBondClosings, CurrentBatch)
	
	Возврат Документы.BatchesOfCustomsFiles.ПолучитьReadyCustomsBondClosings(Дата, ProcessLevel, ParentCompany, CurrentCustomsBondClosings, CurrentBatch);
	
КонецФункции

&НаКлиенте
Процедура CustomsBondClosingsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(ВыбранноеЗначение)
		И ТипЗнч(ВыбранноеЗначение) = Тип("ДокументСсылка.CustomsFilesLight") Тогда
		
		НоваяСтрока = Объект.CustomsBondClosings.Добавить();
		НоваяСтрока.CustomsBondClosing = ВыбранноеЗначение;
		
		Модифицированность = Истина;
				
	КонецЕсли;
	
КонецПроцедуры
            
&НаКлиенте
Процедура CustomsBondClosingsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	CustomsBondClosing = Объект.CustomsBondClosings.НайтиПоИдентификатору(ВыбраннаяСтрока).CustomsBondClosing;
	Если ЗначениеЗаполнено(CustomsBondClosing) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,CustomsBondClosing);
	КонецЕсли;	
	
КонецПроцедуры
