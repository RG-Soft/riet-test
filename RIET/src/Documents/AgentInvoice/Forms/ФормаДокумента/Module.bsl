
&НаКлиенте
Процедура CoefficientDateПриИзменении(Элемент)
	
	FillCoefficientAndSumНаСервере();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ОценкаПроизводительностиРГСофт.ТочноеВремя());
	//КонецЕсли;
	
	РГСофтКлиентСервер.УстановитьЗначение(ТекущийОбъект.ModifiedBy, ПараметрыСеанса.ТекущийПользователь);
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УстановитьДоступностьПолейСуммСКоэффциентами();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.AgentInvoiceИнтерактивноеПроведение, Объект.Ссылка);
	//КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////
// КОМАНДНАЯ ПАНЕЛЬ

&НаКлиенте
Процедура Unload(Команда)
		
	ТабДок = ПолучитьТабДокAgentBatch();
	Если ТабДок <> Неопределено Тогда
		ЗаголовокДокумента = СокрЛП(Объект.Номер);
		ТабДок.Показать(ЗаголовокДокумента);
	КонецЕсли; 
		
КонецПроцедуры

// ДОДЕЛАТЬ
&НаСервере
Функция ПолучитьТабДокAgentBatch()
	
	// Проведем документ при необходимости
	Если Модифицированность
		ИЛИ НЕ Объект.Проведен Тогда
		
		СтруктураПараметров = Новый Структура("РежимЗаписи", РежимЗаписиДокумента.Проведение);
		Попытка
			Записать(СтруктураПараметров);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to post the document!
				|See errors above.
				|" + ОписаниеОшибки(),
				, , "Объект");
			Возврат Неопределено;
		КонецПопытки;
		
	КонецЕсли; 
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	Запрос.УстановитьПараметр("Agent", Объект.Agent);
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	Запрос.УстановитьПараметр("Received", Объект.Received);
	Запрос.УстановитьПараметр("Services", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.Services, "Service"));
	
	// УБРАТЬ КОСТЫЛЬ ИЗ ТЕКСТА ЗАПРОСА
	// Костыль заключается в том, что для сервисов, заведенных на Temporary imp. / exp. transaction,
	// необходимо использовать Account и SubAccount как для Expense
	// независимо от ERP treatment товаров
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	SoldTo.Представление КАК SoldToПредставление,
		|	SoldTo.CompanyNo
		|ИЗ
		|	Справочник.SoldTo КАК SoldTo
		|ГДЕ
		|	SoldTo.Ссылка = &SoldTo
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Agents.Представление КАК AgentПредставление,
		|	Agents.LawsonContractor.Код КАК VendorID,
		|	Agents.TaxCode
		|ИЗ
		|	Справочник.Agents КАК Agents
		|ГДЕ
		|	Agents.Ссылка = &Agent
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	InvoiceLinesCostsОбороты.ДокументОснование КАК DocumentBase,
		|	InvoiceLinesCostsОбороты.AU,
		|	InvoiceLinesCostsОбороты.Activity КАК Activity,
		|	ERPTreatmentAccountsСрезПоследних.AgentAccount КАК Account,
		|	ERPTreatmentAccountsСрезПоследних.AgentSubAccount КАК SubAccount,
		|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК Amount,
		|	ПОДСТРОКА(InvoiceLinesCostsОбороты.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2) КАК BORGcode
		|ПОМЕСТИТЬ CostsOfServices
		|ИЗ
		|	РегистрНакопления.InvoiceLinesCosts.Обороты(
		|			,
		|			,
		|			,
		|			SoldTo = &SoldTo
		|				И ДокументОснование В (&Services)
		|				И НЕ ДокументОснование.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
		|				И НЕ AU.NonLawson) КАК InvoiceLinesCostsОбороты
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ERPTreatmentAccounts.СрезПоследних(&Received, ) КАК ERPTreatmentAccountsСрезПоследних
		|		ПО InvoiceLinesCostsОбороты.ERPTreatment = ERPTreatmentAccountsСрезПоследних.ERPTreatment
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	InvoiceLinesCostsОбороты.ДокументОснование,
		|	InvoiceLinesCostsОбороты.AU,
		|	InvoiceLinesCostsОбороты.Activity,
		|	ERPTreatmentAccountsСрезПоследних.AgentAccount,
		|	ERPTreatmentAccountsСрезПоследних.AgentSubAccount,
		|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
		|	ПОДСТРОКА(InvoiceLinesCostsОбороты.СтрокаИнвойса.НомерЗаявкиНаЗакупку, 1, 2)
		|ИЗ
		|	РегистрНакопления.InvoiceLinesCosts.Обороты(
		|			,
		|			,
		|			,
		|			SoldTo = &SoldTo
		|				И ДокументОснование В (&Services)
		|				И ДокументОснование.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
		|				И НЕ AU.NonLawson) КАК InvoiceLinesCostsОбороты,
		|	РегистрСведений.ERPTreatmentAccounts.СрезПоследних(&Received, ERPTreatment = ЗНАЧЕНИЕ(Перечисление.ТипыЗаказа.E)) КАК ERPTreatmentAccountsСрезПоследних
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	DutiesRechargedОбороты.ДокументОснование,
		|	DutiesRechargeParametersСрезПоследних.AU,
		|	DutiesRechargedОбороты.Activity,
		|	DutiesRechargeParametersСрезПоследних.Account,
		|	DutiesRechargeParametersСрезПоследних.SubAccount,
		|	DutiesRechargedОбороты.СуммаФискальнаяОборот,
		|	""""
		|ИЗ
		|	РегистрНакопления.DutiesRecharged.Обороты(
		|			,
		|			,
		|			,
		|			SoldTo = &SoldTo
		|				И ДокументОснование В (&Services)) КАК DutiesRechargedОбороты,
		|	РегистрСведений.DutiesRechargeParameters.СрезПоследних(&Received, ) КАК DutiesRechargeParametersСрезПоследних
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	СтоимостьТоваровПоТПООбороты.DocumentBase,
		|	СтоимостьТоваровПоТПООбороты.AU,
		|	СтоимостьТоваровПоТПООбороты.Activity,
		|	""531012"",
		|	""1"",
		|	СтоимостьТоваровПоТПООбороты.FiscalSumОборот,
		|	""""
		|ИЗ
		|	РегистрНакопления.СтоимостьТоваровПоТПО.Обороты(
		|			,
		|			,
		|			,
		|			DocumentBase В (&Services)
		|				И НЕ AU.NonLawson) КАК СтоимостьТоваровПоТПООбороты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	&Ссылка КАК Document,
		|	ЛОЖЬ КАК НДС,
		|	ВложенныйЗапрос.AUNo КАК AUNo,
		|	ВложенныйЗапрос.DocumentBaseNo КАК DocumentBaseNo,
		|	ВложенныйЗапрос.Activity,
		|	ВЫБОР
		|		КОГДА ВложенныйЗапрос.DocumentBaseService = ЗНАЧЕНИЕ(Справочник.Services.CustomFeesAndPenaltiesPaidByCCA)
		|			ТОГДА ""556301""
		|		ИНАЧЕ ВложенныйЗапрос.Account
		|	КОНЕЦ КАК AccountNo,
		|	ВЫБОР
		|		КОГДА ВложенныйЗапрос.DocumentBaseService = ЗНАЧЕНИЕ(Справочник.Services.CustomFeesAndPenaltiesPaidByCCA)
		|			ТОГДА ""1""
		|		ИНАЧЕ ВложенныйЗапрос.SubAccount
		|	КОНЕЦ КАК SubAccountNo,
		|	СУММА(ВложенныйЗапрос.Amount) КАК Amount,
		|	ВложенныйЗапрос.BORGcode КАК BORGcode
		|ИЗ
		|	(ВЫБРАТЬ
		|		CostsOfServices.AU.Код КАК AUNo,
		|		ВЫРАЗИТЬ(CostsOfServices.DocumentBase КАК Документ.Service).DocumentBase.Номер КАК DocumentBaseNo,
		|		CostsOfServices.Activity КАК Activity,
		|		CostsOfServices.Account КАК Account,
		|		CostsOfServices.SubAccount КАК SubAccount,
		|		CostsOfServices.Amount КАК Amount,
		|		CostsOfServices.DocumentBase.Service КАК DocumentBaseService,
		|		CostsOfServices.BORGcode КАК BORGcode
		|	ИЗ
		|		CostsOfServices КАК CostsOfServices) КАК ВложенныйЗапрос
		|
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.DocumentBaseNo,
		|	ВложенныйЗапрос.Activity,
		|	ВложенныйЗапрос.AUNo,
		|	ВЫБОР
		|		КОГДА ВложенныйЗапрос.DocumentBaseService = ЗНАЧЕНИЕ(Справочник.Services.CustomFeesAndPenaltiesPaidByCCA)
		|			ТОГДА ""556301""
		|		ИНАЧЕ ВложенныйЗапрос.Account
		|	КОНЕЦ,
		|	ВЫБОР
		|		КОГДА ВложенныйЗапрос.DocumentBaseService = ЗНАЧЕНИЕ(Справочник.Services.CustomFeesAndPenaltiesPaidByCCA)
		|			ТОГДА ""1""
		|		ИНАЧЕ ВложенныйЗапрос.SubAccount
		|	КОНЕЦ,
		|	ВложенныйЗапрос.BORGcode";
				
	Результаты = Запрос.ВыполнитьПакет();
	ЗафиксироватьТранзакцию();
	
	Отказ = Ложь;
	
	ВыборкаРеквизитовSoldTo = Результаты[0].Выбрать();
	ВыборкаРеквизитовSoldTo.Следующий();
	Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовSoldTo.CompanyNo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Company no."" in ""Sold-to " + СокрЛП(ВыборкаРеквизитовSoldTo.SoldToПредставление) + """ is empty!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли;
	
	ВыборкаРеквизитовAgent = Результаты[1].Выбрать();
	ВыборкаРеквизитовAgent.Следующий(); 
	Если НЕ ЗначениеЗаполнено(ВыборкаРеквизитовAgent.VendorID) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Lawson contractor"" in ""Agent " + СокрЛП(ВыборкаРеквизитовAgent.AgentПредставление) + """ is empty!",
			, "Agent", "Объект", Отказ);
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат Неопределено;
	КонецЕсли; 
	
	// Сформируем структуру шапки
	СтруктураРеквизитовШапки = Новый Структура;
	СтруктураРеквизитовШапки.Вставить("Номер", СокрЛП(Объект.FiscalNo));
	СтруктураРеквизитовШапки.Вставить("Дата", Объект.Дата);
	СтруктураРеквизитовШапки.Вставить("LastModified", Объект.ModificationDate);
	СтруктураРеквизитовШапки.Вставить("SoldTo", Объект.SoldTo);
	СтруктураРеквизитовШапки.Вставить("CompanyNo", ВыборкаРеквизитовSoldTo.CompanyNo);
	//СтруктураРеквизитовШапки.Вставить("TaxCode", ВыборкаРеквизитовSoldTo.TaxCode);
	//СтруктураРеквизитовШапки.Вставить("Responsible", Объект.ModifiedBy);
	СтруктураРеквизитовШапки.Вставить("Responsible", ПолучитьResponsibleПоДокументамОснованиям(Объект.Ссылка));
	СтруктураРеквизитовШапки.Вставить("Comment", Объект.Comment);
	
	// Сформируем таблицу документов
	ТаблицаДокументов = Новый ТаблицаЗначений;
	ТаблицаДокументов.Колонки.Добавить("Document");
	ТаблицаДокументов.Колонки.Добавить("DocumentNo");
	ТаблицаДокументов.Колонки.Добавить("DocumentDate");
	ТаблицаДокументов.Колонки.Добавить("VendorID");
	ТаблицаДокументов.Колонки.Добавить("TaxCode");
	ТаблицаДокументов.Колонки.Добавить("InvRecptDate");
	ТаблицаДокументов.Колонки.Добавить("DueDate");
	ТаблицаДокументов.Колонки.Добавить("Commodity");
	НоваяСтрокаТаблицыДокументов = ТаблицаДокументов.Добавить();
	НоваяСтрокаТаблицыДокументов.Document = Объект.Ссылка;
	НоваяСтрокаТаблицыДокументов.DocumentNo = СокрЛП(Объект.FiscalNo);
	НоваяСтрокаТаблицыДокументов.DocumentDate = Объект.Дата;
	НоваяСтрокаТаблицыДокументов.VendorID = ВыборкаРеквизитовAgent.VendorID;
	НоваяСтрокаТаблицыДокументов.TaxCode = ВыборкаРеквизитовAgent.TaxCode;
	НоваяСтрокаТаблицыДокументов.InvRecptDate = Объект.Received;
	НоваяСтрокаТаблицыДокументов.DueDate = Объект.Received;
	НоваяСтрокаТаблицыДокументов.Commodity = "200-50";
	
	// Сформируем таблицу деталей
	ТаблицаДеталей = Результаты[3].Выгрузить();
	
	Для Каждого СтрокаТаблицы из ТаблицаДеталей Цикл 
		
		Если ЗначениеЗаполнено(СтрокаТаблицы.BORGcode) 
			И Лев(СтрокаТаблицы.BORGcode, 1) = "7" Тогда
			
			//S-I-0002231
			Справочники.BORGs.ПодменитьAU_ACДля7BORGcodes(СтрокаТаблицы, "AUNo",  "Activity", СтрокаТаблицы.BORGcode);
			
		КонецЕсли;	
			
	КонецЦикла;

	ТаблицаДеталей.Свернуть("Document, DocumentBaseNo, НДС, AUNo, AccountNo, Activity, SubAccountNo", "Amount");
	
	Если ЗначениеЗаполнено(Объект.VAT) И ТаблицаДеталей.Количество() > 0 Тогда
		
		НоваяСтрокаТаблицыДеталей = ТаблицаДеталей.Добавить();
		НоваяСтрокаТаблицыДеталей.Document = Объект.Ссылка;
		НоваяСтрокаТаблицыДеталей.НДС = Истина;
		НоваяСтрокаТаблицыДеталей.Amount = ?(Объект.Coefficient = Перечисления.AgentInvoicesCoefficients.WithoutCoefficient, 
			Объект.VAT, Объект.VATWithCoefficient);
							
	КонецЕсли; 
	
	Возврат CustomsСервер.ПолучитьТабличныйДокументВыгрузкиВLawson(СтруктураРеквизитовШапки, ТаблицаДокументов, ТаблицаДеталей);
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьResponsibleПоДокументамОснованиям(AgentInvoice)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	AgentInvoiceServices.Service.DocumentBase.ProcessLevel КАК ProcessLevel
	|ИЗ
	|	Документ.AgentInvoice.Services КАК AgentInvoiceServices
	|ГДЕ
	|	AgentInvoiceServices.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	AgentInvoiceServices.Service.DocumentBase.CreatedBy.Код КАК CreatedByНаименование
	|ИЗ
	|	Документ.AgentInvoice.Services КАК AgentInvoiceServices
	|ГДЕ
	|	AgentInvoiceServices.Ссылка = &Ссылка
	|	И (AgentInvoiceServices.Service.DocumentBase ССЫЛКА Документ.CustomsFilesLight
	|			ИЛИ AgentInvoiceServices.Service.DocumentBase ССЫЛКА Документ.ExportShipment
	|			ИЛИ AgentInvoiceServices.Service.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions)
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ВЫРАЗИТЬ(AgentInvoiceServices.Service.DocumentBase КАК Документ.Поставка).Coordinator.Код
	|ИЗ
	|	Документ.AgentInvoice.Services КАК AgentInvoiceServices
	|ГДЕ
	|	AgentInvoiceServices.Ссылка = &Ссылка
	|	И AgentInvoiceServices.Service.DocumentBase ССЫЛКА Документ.Поставка";
	
	Запрос.УстановитьПараметр("Ссылка", AgentInvoice);
	МассивРезультатов = Запрос.ВыполнитьПакет();
	
	ВыборкаProcessLevel = МассивРезультатов[0].Выбрать();
	Если ВыборкаProcessLevel.Количество() > 1 Тогда
		Возврат AgentInvoice.ModifiedBy;
	КонецЕсли;
	ВыборкаProcessLevel.Следующий();
	Если ВыборкаProcessLevel.ProcessLevel <> Справочники.ProcessLevels.KZ Тогда
		Возврат AgentInvoice.ModifiedBy;
	КонецЕсли;
	
	ВыборкаCreatedBy = МассивРезультатов[1].Выбрать();
	СтрокаРезультата = "";
	Пока ВыборкаCreatedBy.Следующий() Цикл
		СтрокаРезультата = СтрокаРезультата + ВыборкаCreatedBy.CreatedByНаименование + ",";
	КонецЦикла;
	
	Возврат Лев(СтрокаРезультата, СтрДлина(СтрокаРезультата) - 1);
	
КонецФункции

#Область SWPSLawsonUnload

&НаКлиенте
Процедура SWPSLawsonUnload(Команда)
	
	Если ЗначениеЗаполнено(Объект.SoldTo) Тогда
		// { RGS AArsentev 30.03.2018 S-I-0004889
		Country = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.SoldTo, "Country");		
        ВыгружатьВLawson = ПроверитьCountryДляВыгрузки(Country);
		// } RGS AArsentev 30.03.2018 S-I-0004889
		Если Не ВыгружатьВLawson Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Команда доступна только для KZ, AZ и TM");
		Возврат;
		КонецЕсли;
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Необходимо указать 'SoldTo'");
		Возврат
	КонецЕсли;
	
	Если Объект.Проведен И Не Модифицированность Тогда
		
		МассивТабДок = ПолучитьТабДокSWPSLawson();
		
		Сч = 1;
		Для Каждого ТабДок из МассивТабДок Цикл 
			ЗаголовокДокумента = СокрЛП(Объект.Номер + "-" + Сч);
			ТабДок.Показать(ЗаголовокДокумента);
			Сч = Сч + 1;
		КонецЦикла;
		
	Иначе
		
		Сообщить("Перед формированием выгрузки необходимо провести документ.");
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТабДокSWPSLawson()
	
	МассивТабДок = Новый Массив;

	ТабДок = Новый ТабличныйДокумент;	
	Макет = ПолучитьОбщийМакет("SWPS_Lawson_Unload");
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапка);
	
	НомерПП = 1;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Services", Объект.Services.Выгрузить().ВыгрузитьКолонку("Service"));
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	
	Запрос.Текст =  "ВЫБРАТЬ
	                |	InvoiceLinesCostsОбороты.СтрокаИнвойса КАК СтрокаИнвойса,
	                |	InvoiceLinesCostsОбороты.AU,
	                |	InvoiceLinesCostsОбороты.AU.DefaultActivity КАК Activity,
	                |	InvoiceLinesCostsОбороты.Валюта,
	                |	ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase КАК Документ.TemporaryImpExpTransactions).Номер КАК НомерТранзакции,
	                |	ЕСТЬNULL(ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase КАК Документ.TemporaryImpExpTransactions).NewCustomsFileNo, """") КАК NewCustomsFileNo,
	                |	СУММА(InvoiceLinesCostsОбороты.СуммаОборот) КАК СуммаОборот
	                |ПОМЕСТИТЬ ВТ_Обороты
	                |ИЗ
	                |	РегистрНакопления.InvoiceLinesCosts.Обороты(
	                |			,
	                |			,
	                |			,
	                |			ДокументОснование В (&Services)
	                |				И SoldTo = &SoldTo) КАК InvoiceLinesCostsОбороты
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	InvoiceLinesCostsОбороты.СтрокаИнвойса,
	                |	InvoiceLinesCostsОбороты.AU,
	                |	InvoiceLinesCostsОбороты.AU.DefaultActivity,
	                |	InvoiceLinesCostsОбороты.Валюта,
	                |	ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase КАК Документ.TemporaryImpExpTransactions).Номер,
	                |	ЕСТЬNULL(ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase КАК Документ.TemporaryImpExpTransactions).NewCustomsFileNo, """")
	                |
	                |ИНДЕКСИРОВАТЬ ПО
	                |	СтрокаИнвойса
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	ВТ_Обороты.AU.Наименование КАК CostCenterName,
	                |	ВТ_Обороты.AU.Код КАК CostCenterКод,
	                |	ВТ_Обороты.Activity КАК ActivityCode,
	                |	ВТ_Обороты.Валюта.НаименованиеEng КАК CurrencyEng,
	                |	ВЫБОР
	                |		КОГДА ВТ_Обороты.NewCustomsFileNo <> """"
	                |			ТОГДА ВТ_Обороты.NewCustomsFileNo
	                |		ИНАЧЕ ЕСТЬNULL(CustomsFilesOfGoods.DTNo, """")
	                |	КОНЕЦ КАК CCD,
					// { RGS AArsentev 30.03.2018 S-I-0004889
	                // |	МАКСИМУМ(ВТ_Обороты.СуммаОборот) КАК Sum,
					|	Сумма(ВТ_Обороты.СуммаОборот) КАК Sum,
					// } RGS AArsentev 30.03.2018 S-I-0004889
	                |	МАКСИМУМ(ЕСТЬNULL(ПоставкаУпаковочныеЛисты.Ссылка.Номер, """")) КАК ImportSH,
	                |	МАКСИМУМ(ЕСТЬNULL(ExportShipmentExportRequests.Ссылка.Номер, """")) КАК ExportSH,
	                |	МАКСИМУМ(ЕСТЬNULL(ParcelsДетали.Ссылка.ExportRequest.Recharge, ЛОЖЬ)) КАК Recharge,
	                |	МАКСИМУМ(ЕСТЬNULL(ParcelsДетали.Ссылка.ExportRequest.RechargeToLegalEntity, """")) КАК RechargeToLegalEntity,
	                |	МАКСИМУМ(ЕСТЬNULL(ParcelsДетали.Ссылка.ExportRequest.RechargeToAU, """")) КАК RechargeToAU,
	                |	МАКСИМУМ(ЕСТЬNULL(ParcelsДетали.Ссылка.ExportRequest.RechargeToActivity, """")) КАК RechargeToActivity,
	                |	МАКСИМУМ(ВТ_Обороты.НомерТранзакции) КАК НомерТранзакции
	                |ИЗ
	                |	ВТ_Обороты КАК ВТ_Обороты
	                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	                |		ПО ВТ_Обороты.СтрокаИнвойса = CustomsFilesOfGoods.Item
	                |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	                |			ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК КонсолидированныйПакетЗаявокНаПеревозкуParcels
	                |				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
	                |				ПО КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка = ПоставкаУпаковочныеЛисты.УпаковочныйЛист
	                |					И (НЕ ПоставкаУпаковочныеЛисты.Ссылка.ПометкаУдаления)
	                |			ПО ParcelsДетали.Ссылка = КонсолидированныйПакетЗаявокНаПеревозкуParcels.Parcel
	                |				И (НЕ КонсолидированныйПакетЗаявокНаПеревозкуParcels.Ссылка.ПометкаУдаления)
	                |			ЛЕВОЕ СОЕДИНЕНИЕ Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
	                |			ПО ParcelsДетали.Ссылка.ExportRequest = ExportShipmentExportRequests.ExportRequest
	                |		ПО ВТ_Обороты.СтрокаИнвойса = ParcelsДетали.СтрокаИнвойса
	                |			И (НЕ ParcelsДетали.Ссылка.ПометкаУдаления)
	                |			И (НЕ ParcelsДетали.Ссылка.Отменен)
	                |			И (НЕ ParcelsДетали.Ссылка.LocalOnly)
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	ВТ_Обороты.AU.Наименование,
	                |	ВТ_Обороты.Валюта.НаименованиеEng,
	                |	ВТ_Обороты.AU.Код,
	                |	ВТ_Обороты.Activity,
	                |	ВЫБОР
	                |		КОГДА ВТ_Обороты.NewCustomsFileNo <> """"
	                |			ТОГДА ВТ_Обороты.NewCustomsFileNo
	                |		ИНАЧЕ ЕСТЬNULL(CustomsFilesOfGoods.DTNo, """")
	                |	КОНЕЦ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	SWPSSupplierCode = СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Agent, "SWPSSupplierCode"));
	FiscalInvoiceNo = СокрЛП(Объект.FiscalNo);
	
	Пока Выборка.Следующий() Цикл 
		
		Если НомерПП > 124 Тогда 
			
			МассивТабДок.Добавить(ТабДок);
			
			ТабДок = Новый ТабличныйДокумент;	
			Макет = ПолучитьОбщийМакет("SWPS_Lawson_Unload");
			ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
			ТабДок.Вывести(ОбластьШапка);
			
			НомерПП = 1;
			
		КонецЕсли;
		
		//ЭтоИмпорт = Не ПустаяСтрока(Выборка.ImportSH);
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		ПараметрыОбласти = ОбластьСтрока.Параметры;
		ПараметрыОбласти.SWPSSupplierCode = SWPSSupplierCode;
		ПараметрыОбласти.Qty = "1";
		ПараметрыОбласти.UOM = "EA-each";
		
		//Если ЭтоИмпорт Тогда
		//	ПараметрыОбласти.LineDescription = СокрЛП(Выборка.CCD) + "-" + Выборка.ImportSH; // + "-" + Выборка.ImportMOT + "-" + Выборка.ImportPOD + "/" + Выборка.ImportPOA;
		//Иначе
		//	ПараметрыОбласти.LineDescription = СокрЛП(Выборка.CCD) + "-" + Выборка.ExportSH; // + "-" + Выборка.ExportMOT + "-" + Выборка.ExportPOD + "/" + Выборка.ExportPOA;
		//КонецЕсли;
		ПараметрыОбласти.LineDescription = СокрЛП(Выборка.CCD) + "-" + ?(ЗначениеЗаполнено(Выборка.ImportSH), Выборка.ImportSH, Выборка.ExportSH) + "-" + Выборка.НомерТранзакции; // + "-" + Выборка.ImportMOT + "-" + Выборка.ImportPOD + "/" + Выборка.ImportPOA;
		
		ПараметрыОбласти.PartNumber = FiscalInvoiceNo;
			
		ПараметрыОбласти.UnitPrice = Выборка.Sum;
		//ПараметрыОбласти.Currency = ВРег(СокрЛП(Выборка.CurrencyEng));
		// { RGS AArsentev 30.03.2018 S-I-0004889
		//ПараметрыОбласти.Currency = "KZT";
		Country = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.SoldTo, "Country");		
		Если Country = Справочники.CountriesOfProcessLevels.KZ Тогда
			ПараметрыОбласти.Currency = "KZT";
		ИначеЕсли Country = Справочники.CountriesOfProcessLevels.AZ Тогда
			ПараметрыОбласти.Currency = "AZN";
		ИначеЕсли Country = Справочники.CountriesOfProcessLevels.TM Тогда
			ПараметрыОбласти.Currency = "TMT";
		КонецЕсли;
		// } RGS AArsentev 30.03.2018 S-I-0004889	
		
		//Delivery Date should be the following - Current date + 13 days
		ПараметрыОбласти.DeliveryDate = Формат(ТекущаяДата() + 86400*13, "ДФ=""ddMMyyyy""");
		
		ПараметрыОбласти.AccountingUnitDescription = СокрЛП(Выборка.CostCenterКод) + ": " + СокрЛП(Выборка.CostCenterName) + " (Customs)";
		ПараметрыОбласти.ActivityCode = СокрЛП(Выборка.ActivityCode);
		
		ПараметрыОбласти.Req_Type = "Expense";
		
		ПараметрыОбласти.Taxonomy = "CLCCCC01-Customs Clearance";
		ПараметрыОбласти.Shipping_Method = "98-Standard";
		ПараметрыОбласти.Payment_Method = "Compliant";
		
		RechargeInfo = "";
		Если Выборка.Recharge Тогда 
			
			RechargeInfo = "Internal: " + СокрЛП(Выборка.RechargeToLegalEntity) + ", AU:" + СокрЛП(Выборка.RechargeToAU) 
			+ ", AC:" + СокрЛП(Выборка.RechargeToActivity);
			
		КонецЕсли;
		ПараметрыОбласти.Shipping_Instructions = RechargeInfo;
		
		ТабДок.Вывести(ОбластьСтрока);
		
		НомерПП = НомерПП + 1;
		
	КонецЦикла;
	
	МассивТабДок.Добавить(ТабДок);

	Возврат МассивТабДок;
	
КонецФункции

#КонецОбласти

///////////////////////////////////////////////////////////////////////
// ШАПКА

&НаКлиенте
Процедура CoefficientПриИзменении(Элемент)
	
	УстановитьДоступностьПолейСуммСКоэффциентами();
	
	Если Объект.Coefficient = ПредопределенноеЗначение(
		"Перечисление.AgentInvoicesCoefficients.WithoutCoefficient") Тогда 
		
		Объект.SumWithoutVATWithCoefficient = Неопределено;
		Объект.VATWithCoefficient = Неопределено;
		Объект.SumWithVATWithCoefficient = Неопределено;
		
		Для Каждого СтрокаТЧServices из Объект.Services Цикл 
			СтрокаТЧServices.Coefficient = Неопределено;
			СтрокаТЧServices.SumWithCoefficient = Неопределено;
		КонецЦикла;
		
	иначе
		
		FillCoefficientAndSumНаСервере();
				
	КонецЕсли;
	   	  	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьПолейСуммСКоэффциентами()
	
	WithOutCoef = (Объект.Coefficient = ПредопределенноеЗначение(
		"Перечисление.AgentInvoicesCoefficients.WithoutCoefficient"));
		
	Элементы.SumWithoutVATWithCoefficient.Доступность = Не WithOutCoef;
	Элементы.VATWithCoefficient.Доступность = Не WithOutCoef;
	Элементы.SumWithVATWithCoefficient.Доступность = Не WithOutCoef;
	
	Элементы.ServicesFillCoefficientAndSum.Видимость = Не WithOutCoef;
	Элементы.ServicesCoefficient.Видимость = Не WithOutCoef;
	Элементы.ServicesSumWithCoefficient.Видимость = Не WithOutCoef;
	 		
КонецПроцедуры

///////////////////////////////////////////////////////////////////////
// ТАБЛИЧНАЯ ЧАСТЬ

&НаКлиенте
Функция МожноЗаполнитьТабличнуюЧасть()
	
	Отказ = Ложь;
	
	Если НЕ ЗначениеЗаполнено(Объект.Agent) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Agent"" не заполнено!",
			, "Agent", "Объект", Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Sold-to"" не заполнено!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли; 
	
	Если Отказ Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ РГСофтКлиент.ЗадатьВопросОбОчисткеТЧПередЗаполнением(Объект.Services) Тогда
		Возврат Ложь;
	КонецЕсли; 
	
	Если Объект.Проведен Тогда
		Ответ = Вопрос("Перед заполнением документ будет распроведен.
			|Продолжить?", РежимДиалогаВопрос.ДаНет, 30, КодВозвратаДиалога.Да, "Внимание!", КодВозвратаДиалога.Нет);
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат Ложь;
		КонецЕсли; 
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьServicesПоОстаткам(Команда)
	
	Если МожноЗаполнитьТабличнуюЧасть() Тогда
					
		ЗаполнитьServicesПоОстаткамНаСервере();
		
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьServicesПоОстаткамНаСервере()
	
	Если Объект.Проведен Тогда
		
		СтруктураПараметров = Новый Структура("РежимЗаписи", РежимЗаписиДокумента.ОтменаПроведения);
		Попытка
			Записать(СтруктураПараметров);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось распровести документ!");
			Возврат;
		КонецПопытки;
		
	КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Agent", Объект.Agent);
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	NotReceivedAgentInvoicesОстатки.Service,
		|	NotReceivedAgentInvoicesОстатки.SumОстаток КАК Sum
		|ИЗ
		|	РегистрНакопления.NotReceivedAgentInvoices.Остатки(
		|			,
		|			SoldTo = &SoldTo
		|				И Service.Agent = &Agent) КАК NotReceivedAgentInvoicesОстатки";
		
	Объект.Services.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры 

&НаКлиенте
Процедура ЗаполнитьServicesПоServicesCostsAllocations(Команда)
	
	Если МожноЗаполнитьТабличнуюЧасть() Тогда
		
		Если Объект.Проведен Тогда
			СтруктураПараметров = Новый Структура("РежимЗаписи", РежимЗаписиДокумента.ОтменаПроведения);
			Попытка
				Записать(СтруктураПараметров);
			Исключение
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"Не удалось распровести документ!");
				Возврат;
			КонецПопытки;
		КонецЕсли; 
		
		СтруктураНастройки = Новый Структура;
		СтруктураНастройки.Вставить("Имя", "ВыборИзAgentInvoice");
		СтруктураНастройки.Вставить("Agent", Объект.Agent);
		СтруктураНастройки.Вставить("SoldTo", Объект.SoldTo);
		
		СтруктураПараметров = Новый Структура("СтруктураНастройки", СтруктураНастройки);
		МассивServicesCostsAllocations = ОткрытьФормуМодально("Документ.ServicesCostsAllocation.ФормаВыбора", СтруктураПараметров, ЭтаФорма);
		Если МассивServicesCostsAllocations <> Неопределено И МассивServicesCostsAllocations.Количество() Тогда
			ЗаполнитьServicesПоServicesCostsAllocationsНаСервере(МассивServicesCostsAllocations);
		КонецЕсли; 	
		
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьServicesПоServicesCostsAllocationsНаСервере(МассивServicesCostsAllocations)
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Agent", Объект.Agent);
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	Запрос.УстановитьПараметр("ServicesCostsAllocations", МассивServicesCostsAllocations);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	NotReceivedAgentInvoicesОбороты.Service,
		|	NotReceivedAgentInvoicesОбороты.SumПриход КАК Sum
		|ИЗ
		|	РегистрНакопления.NotReceivedAgentInvoices.Обороты(
		|			,
		|			,
		|			Регистратор,
		|			SoldTo = &SoldTo
		|				И Service.Agent = &Agent) КАК NotReceivedAgentInvoicesОбороты
		|ГДЕ
		|	NotReceivedAgentInvoicesОбороты.Регистратор В(&ServicesCostsAllocations)";
		
	Объект.Services.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры 

&НаКлиенте
Процедура ServicesПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
		
	Если НЕ ЗначениеЗаполнено(Объект.Agent) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Agent"" is empty!",
			, "Agent", "Объект", Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Объект.SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sold-to"" is empty!",
			, "SoldTo", "Объект", Отказ);
	КонецЕсли; 
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	
	Если Объект.Проведен Тогда
		
		Ответ = Вопрос("The document needs to be unposted.
			|Continue?", РежимДиалогаВопрос.ДаНет, 30, КодВозвратаДиалога.Да, "Attention!", КодВозвратаДиалога.Нет);
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли; 
		
		СтруктураПараметров = Новый Структура("РежимЗаписи", РежимЗаписиДокумента.ОтменаПроведения);
		Попытка
			Записать(СтруктураПараметров);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Failed to unpost the document!
				|See errors above.
				|" + ОписаниеОшибки());
			Возврат;
		КонецПопытки;
		
	КонецЕсли;
		
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзAgentInvoice");
	СтруктураНастройки.Вставить("МассивТекущихServices", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.Services, "Service"));
	СтруктураНастройки.Вставить("Date", Объект.Date);
	СтруктураНастройки.Вставить("Agent", Объект.Agent);
	СтруктураНастройки.Вставить("SoldTo", Объект.SoldTo);
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	СтруктураПараметров.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Документ.Service.ФормаВыбора", СтруктураПараметров, Элемент);
		
КонецПроцедуры 

&НаКлиенте
Процедура ServicesОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив")
		И ВыбранноеЗначение.Количество() > 0
		И ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.Service") Тогда
		
		Для Каждого Service Из ВыбранноеЗначение Цикл
			НоваяСтрока = Объект.Services.Добавить();
			НоваяСтрока.Service = Service;
		КонецЦикла;	
		
		Модифицированность = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ServicesВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле.Имя = "ServicesService" Тогда
		
		СтандартнаяОбработка = Ложь;
		ТекущийService = Элемент.ТекущиеДанные.Service;
		Если ЗначениеЗаполнено(ТекущийService) Тогда
			ПоказатьЗначение(,ТекущийService);
		КонецЕсли;
		
	КонецЕсли; 
	 
КонецПроцедуры

// КОМАНДА Refresh Coef&Sum

&НаКлиенте
Процедура FillCoefficientAndSum(Команда)
	
	FillCoefficientAndSumНаСервере();	                           
		
КонецПроцедуры

&НаСервере
Процедура FillCoefficientAndSumНаСервере()
	
	ТаблицаServicesCoefficients = ПолучитьТаблицуServicesCoefficients();
		
	Для Каждого СтрокаТЧServices из Объект.Services Цикл 
		
		СтрокаServicesCoefficients = ТаблицаServicesCoefficients.Найти(СтрокаТЧServices.Service, "DocumentService");
			
		СтрокаТЧServices.Coefficient = СтрокаServicesCoefficients.Coefficient;
		
		// если заполнена фиксированная сумма, то коэффициент умножается на фиксированную сумму
		Если ЗначениеЗаполнено(СтрокаServicesCoefficients.FixedSumForCoefficient) Тогда 
			
			FixedSumForCoefficientВПропорцииПоКомпании = СтрокаServicesCoefficients.FixedSumForCoefficient * 
			(СтрокаServicesCoefficients.Sum / СтрокаServicesCoefficients.GrandTotal);

			СтрокаТЧServices.SumWithCoefficient = СтрокаТЧServices.Sum 
			- FixedSumForCoefficientВПропорцииПоКомпании 
			+ (FixedSumForCoefficientВПропорцииПоКомпании * СтрокаServicesCoefficients.Coefficient);
			
		//для cost plus коэффициент применяется к сумме Markup
		ИначеЕсли СтрокаServicesCoefficients.CostPlus тогда
			
			MarkupВПропорцииПоКомпании = СтрокаServicesCoefficients.Markup * 
			(СтрокаServicesCoefficients.Sum / СтрокаServicesCoefficients.GrandTotal);
			
			СтрокаТЧServices.SumWithCoefficient = СтрокаServicesCoefficients.Sum 
			- MarkupВПропорцииПоКомпании 
			+ (MarkupВПропорцииПоКомпании * СтрокаТЧServices.Coefficient);
			
		иначе
			
			СтрокаТЧServices.SumWithCoefficient = СтрокаТЧServices.Sum * СтрокаТЧServices.Coefficient;
			
		КонецЕсли;
	
	КонецЦикла;
	  	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуServicesCoefficients()  
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("CoefficientDate", Объект.CoefficientDate);
	Запрос.УстановитьПараметр("Coefficient", Объект.Coefficient);
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	Запрос.УстановитьПараметр("МассивServices", РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Объект.Services, "Service"));
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	NotReceivedAgentInvoicesОбороты.Service КАК DocumentService,
	               |	NotReceivedAgentInvoicesОбороты.Service.Service КАК Service,
	               |	NotReceivedAgentInvoicesОбороты.SumПриход КАК Sum,
	               |	ВЫБОР
	               |		КОГДА NotReceivedAgentInvoicesОбороты.Service.Service.SumCalculationMethod = ЗНАЧЕНИЕ(Перечисление.SumCalculationMethods.CostPlus)
	               |			ТОГДА ИСТИНА
	               |		ИНАЧЕ ЛОЖЬ
	               |	КОНЕЦ КАК CostPlus,
	               |	NotReceivedAgentInvoicesОбороты.Service.Markup КАК Markup,
	               |	NotReceivedAgentInvoicesОбороты.Service.Agent КАК Agent,
	               |	NotReceivedAgentInvoicesОбороты.Service.GrandTotal КАК GrandTotal
	               |ПОМЕСТИТЬ ВТ_DocumentsServices
	               |ИЗ
	               |	РегистрНакопления.NotReceivedAgentInvoices.Обороты(
	               |			,
	               |			,
	               |			Регистратор,
	               |			Service В (&МассивServices)
	               |				И SoldTo = &SoldTo) КАК NotReceivedAgentInvoicesОбороты
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_DocumentsServices.DocumentService,
	               |	ВТ_DocumentsServices.Service,
	               |	ВТ_DocumentsServices.CostPlus,
	               |	ЕСТЬNULL(ВЫБОР
	               |			КОГДА &Coefficient = ЗНАЧЕНИЕ(Перечисление.AgentInvoicesCoefficients.Coefficient1)
	               |				ТОГДА CoefficientsToTheRatesOfAgents.Coefficient1
	               |			ИНАЧЕ CoefficientsToTheRatesOfAgents.Coefficient2
	               |		КОНЕЦ, 1) КАК Coefficient,
	               |	ВТ_DocumentsServices.GrandTotal,
	               |	ВТ_DocumentsServices.Markup,
	               |	ВТ_DocumentsServices.Sum,
	               |	ЕСТЬNULL(CoefficientsToTheRatesOfAgents.FixedSumForCoefficient, 0) КАК FixedSumForCoefficient
	               |ИЗ
	               |	ВТ_DocumentsServices КАК ВТ_DocumentsServices
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CoefficientsToTheRatesOfAgents КАК CoefficientsToTheRatesOfAgents
	               |		ПО ВТ_DocumentsServices.Service = CoefficientsToTheRatesOfAgents.Service
	               |			И (ВЫБОР
	               |				КОГДА CoefficientsToTheRatesOfAgents.ExpiryDate = ДАТАВРЕМЯ(1, 1, 1)
	               |					ТОГДА ИСТИНА
	               |				ИНАЧЕ CoefficientsToTheRatesOfAgents.ExpiryDate > &CoefficientDate
	               |			КОНЕЦ)
	               |			И (CoefficientsToTheRatesOfAgents.StartDate <= &CoefficientDate)
	               |			И ВТ_DocumentsServices.Agent = CoefficientsToTheRatesOfAgents.Agent";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

&НаКлиенте
Процедура TMSUnload(Команда)
	
	Если Объект.Проведен И Не Модифицированность Тогда
		
		ТабДок = ПолучитьТабДокTMSShipmentCostUpload();
		
		Если ТабДок <> Неопределено Тогда
						
			Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
			Диалог.Фильтр = "*.xls|*.xls";
			
			Если НЕ Диалог.Выбрать() Тогда
				Возврат;
			КонецЕсли;
			        			
			ТабДок.Записать(Диалог.ПолноеИмяФайла, ТипФайлаТабличногоДокумента.xls);
			         			
		КонецЕсли;
		
	Иначе
		Сообщить("Перед формированием выгрузки необходимо провести документ.");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТабДокTMSShipmentCostUpload()
	
	ТабДок = Новый ТабличныйДокумент;	
	Макет = ПолучитьОбщийМакет("TMSShipmentCostUpload");
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапка);
	
	НомерПП = 1;                  	
	
	Currency = Справочники.CountriesOfProcessLevels.ПолучитьМестнуюВалюту(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.SoldTo, "Country"));
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Services", Объект.Services.Выгрузить().ВыгрузитьКолонку("Service"));
	Запрос.УстановитьПараметр("SoldTo", Объект.SoldTo);
	
	//  исключаем сервисы с  Allocation Area = Перечисление.AllocationAreas.InvoiceLines
	
	Запрос.Текст =  "ВЫБРАТЬ
	                |	InvoiceLinesCostsОбороты.СуммаОборот,
	                |	InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase КАК ServiceDocumentBase
	                |ПОМЕСТИТЬ ВТ_Items
	                |ИЗ
	                |	РегистрНакопления.InvoiceLinesCosts.Обороты(
	                |			,
	                |			,
	                |			,
	                |			SoldTo = &SoldTo
	                |				И ДокументОснование В (&Services)
	                |				И НЕ ДокументОснование.Service.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.InvoiceLines)
	                |				И НЕ ДокументОснование.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
	                |				И НЕ AU.NonLawson) КАК InvoiceLinesCostsОбороты
	                |
	                |ОБЪЕДИНИТЬ ВСЕ
	                |
	                |ВЫБРАТЬ
	                |	InvoiceLinesCostsОбороты.СуммаОборот,
	                |	InvoiceLinesCostsОбороты.ДокументОснование.DocumentBase
	                |ИЗ
	                |	РегистрНакопления.InvoiceLinesCosts.Обороты(
	                |			,
	                |			,
	                |			,
	                |			SoldTo = &SoldTo
	                |				И ДокументОснование В (&Services)
	                |				И НЕ ДокументОснование.Service.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.InvoiceLines)
	                |				И ДокументОснование.DocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
	                |				И НЕ AU.NonLawson) КАК InvoiceLinesCostsОбороты
	                |
	                |ОБЪЕДИНИТЬ ВСЕ
	                |
	                |ВЫБРАТЬ
	                |	DutiesRechargedОбороты.СуммаФискальнаяОборот,
	                |	DutiesRechargedОбороты.ДокументОснование.DocumentBase
	                |ИЗ
	                |	РегистрНакопления.DutiesRecharged.Обороты(
	                |			,
	                |			,
	                |			,
	                |			SoldTo = &SoldTo
	                |				И ДокументОснование В (&Services)
	                |				И НЕ ДокументОснование.Service.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.InvoiceLines)) КАК DutiesRechargedОбороты
	                |
	                |ОБЪЕДИНИТЬ ВСЕ
	                |
	                |ВЫБРАТЬ
	                |	СтоимостьТоваровПоТПООбороты.FiscalSumОборот,
	                |	СтоимостьТоваровПоТПООбороты.DocumentBase.DocumentBase
	                |ИЗ
	                |	РегистрНакопления.СтоимостьТоваровПоТПО.Обороты(
	                |			,
	                |			,
	                |			,
	                |			DocumentBase В (&Services)
	                |				И НЕ DocumentBase.Service.AllocationArea = ЗНАЧЕНИЕ(Перечисление.AllocationAreas.InvoiceLines)
	                |				И НЕ AU.NonLawson) КАК СтоимостьТоваровПоТПООбороты
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	СУММА(ВТ_Items.СуммаОборот) КАК CostAmount,
	                |	ВЫБОР
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.Поставка
	                |				ИЛИ ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.ExportShipment
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.TMSShipmentID
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.CustomsFilesLight
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.Shipment.TMSShipmentID
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.CustomsFile.Shipment.TMSShipmentID
	                |		ИНАЧЕ """"
	                |	КОНЕЦ КАК TMSShipmentID
	                |ИЗ
	                |	ВТ_Items КАК ВТ_Items
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	ВЫБОР
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.Поставка
	                |				ИЛИ ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.ExportShipment
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.TMSShipmentID
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.CustomsFilesLight
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.Shipment.TMSShipmentID
	                |		КОГДА ВТ_Items.ServiceDocumentBase ССЫЛКА Документ.TemporaryImpExpTransactions
	                |			ТОГДА ВТ_Items.ServiceDocumentBase.CustomsFile.Shipment.TMSShipmentID
	                |		ИНАЧЕ """"
	                |	КОНЕЦ";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		ПараметрыОбласти = ОбластьСтрока.Параметры;
		
		ПараметрыОбласти.ShipmentXID = СокрЛП(Выборка.TMSShipmentID);
		ПараметрыОбласти.AccessorialCode = "AGENT / BROKERAGE SERVICES";
		ПараметрыОбласти.CostAmount = Выборка.CostAmount;
		ПараметрыОбласти.CostCurrency = СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Currency, "НаименованиеEng"));
		
		ТабДок.Вывести(ОбластьСтрока);
		
	КонецЦикла;
	         	
	Возврат ТабДок;   	
	
КонецФункции

// { RGS AArsentev 30.03.2018 S-I-0004889
&НаСервере
Функция ПроверитьCountryДляВыгрузки(Country)
	
	Если Country <> Справочники.CountriesOfProcessLevels.AZ
		И Country <> Справочники.CountriesOfProcessLevels.KZ 
		И Country <> Справочники.CountriesOfProcessLevels.TM
		Тогда
		Возврат Ложь
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции // } RGS AArsentev 30.03.2018 S-I-0004889

