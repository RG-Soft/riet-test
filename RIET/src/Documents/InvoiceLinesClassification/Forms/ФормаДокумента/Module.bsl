
////////////////////////////////////////////////////////////////////////////
// ФОРМА

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ТочноеВремяНачала = ОценкаПроизводительностиРГСофт.ТочноеВремя();
	
	Если НЕ ЗначениеЗаполнено(Объект.ProcessLevel) Тогда
		Объект.ProcessLevel = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(ПараметрыСеанса.ТекущийПользователь, "ProcessLevel");
		Модифицированность = Истина;
	КонецЕсли;
		
	Если ЗначениеЗаполнено(Объект.InvoiceLinesMatching)
		И Объект.Classification.Количество() = 0 Тогда
		FillFromCatalogНаСервере();
	КонецЕсли;
	
	Если Параметры.Свойство("InvoiceLine") и ЗначениеЗаполнено(Параметры.InvoiceLine) Тогда
		МассивСтрок = Объект.Classification.НайтиСтроки(Новый Структура("InvoiceLine", Параметры.InvoiceLine));
		Если МассивСтрок.Количество() > 0 Тогда 
			Элементы.InvoiceLinesClassificationClassification.ТекущаяСтрока = МассивСтрок[0].ПолучитьИдентификатор(); 
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьРИЗП();
	
	//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ТочноеВремяНачала, Справочники.КлючевыеОперации.ILCОткрытие, Объект.Ссылка);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРИЗП()
	
	//Если НЕ ЗначениеЗаполнено(Объект.InvoiceLinesMatching) Тогда
	//	Возврат;
	//КонецЕсли;
	//
	//Запрос = Новый Запрос;
	//Запрос.УстановитьПараметр("InvoiceLinesMatching", Объект.InvoiceLinesMatching);
	//Запрос.Текст =
	//	"ВЫБРАТЬ
	//	|	РаспределениеИмпортаПоЗакрытиюПоставки.Ссылка КАК РИЗП
	//	|ИЗ
	//	|	Документ.РаспределениеИмпортаПоЗакрытиюПоставки КАК РаспределениеИмпортаПоЗакрытиюПоставки
	//	|ГДЕ
	//	|	РаспределениеИмпортаПоЗакрытиюПоставки.ShipmentСlosing = &InvoiceLinesMatching
	//	|	И (НЕ РаспределениеИмпортаПоЗакрытиюПоставки.ПометкаУдаления)";
	//		
	//ВыборкаРИЗП = Запрос.Выполнить().Выбрать();
	//Если ВыборкаРИЗП.Следующий() Тогда
	//	РИЗП = ВыборкаРИЗП.РИЗП;
	//	Элементы.РИЗП.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
	//КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Возврат;
	КонецЕсли;
	
	РИЗП = CustomsСервер.ПолучитьПроведенныйРИЗП(Объект.Ссылка);	
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	РГСофтКлиент.ПроверитьНеобходимостьЗаписиДокумента(ПараметрыЗаписи.РежимЗаписи, Объект.Проведен, Модифицированность, Отказ);
	  		
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
	//	ПараметрыЗаписи.Вставить("ТочноеВремяНачала", ОценкаПроизводительностиРГСофт.ТочноеВремя());
	//КонецЕсли;
	
	РГСофтКлиентСервер.УстановитьЗначение(ТекущийОбъект.ModifiedBy, ПараметрыСеанса.ТекущийПользователь);
	ТекущийОбъект.ModificationDate = ТекущаяДата();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	//Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		//ОценкаПроизводительностиРГСофт.ЗафиксироватьВремяОкончания(ПараметрыЗаписи.ТочноеВремяНачала, Справочники.КлючевыеОперации.ILCИнтерактивноеПроведение, Объект.Ссылка);
	//КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	СоответствиеТипов = Новый Соответствие;
	Для Каждого Стр из Объект.Classification Цикл
		СоответствиеТипов.Вставить(Стр.InvoiceLine, Стр.Type);
	КонецЦикла;
	
	Оповестить("ПриЗакрытииInvoicelinesClassification", СоответствиеТипов, Объект.Ссылка);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////
// ТАБЛИЧНАЯ ЧАСТЬ

&НаКлиенте
Процедура FillEmptyFieldsFromCatalog(Команда)
	
	Если НЕ ЗначениеЗаполнено(Объект.InvoiceLinesMatching) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Invoice lines matching"" не заполнено!",
			, "InvoiceLinesMatching", "Объект");
		Возврат;
	КонецЕсли;
	
	FillFromCatalogНаСервере();
		
КонецПроцедуры

&НаСервере
Процедура FillFromCatalogНаСервере(МассивItems=Неопределено)
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("InvoiceLinesMatching", Объект.InvoiceLinesMatching);
	Запрос.УстановитьПараметр("МассивItems", МассивItems);
	Запрос.Текст = CustomsСервер.ПолучитьТекстЗапросаЗаполненияInvoiceLinesClassification(МассивItems);
	Таблица = Запрос.Выполнить().Выгрузить();
	
	// { RGS AArsentev 04.07.2018 S-I-0005574 - т.к. NA не уникальное дублирует строки.
	Для Каждого Элемент Из Таблица Цикл
		РеквизитыАйтема = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Элемент.InvoiceLine, "КодПоИнвойсу, НаименованиеТовара");
		// { RGS ASeryakov, 21.08.2018 18:52:20 S-I-0005805
		//Если РеквизитыАйтема.КодПоИнвойсу = "NA" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "N\A" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "N/A" Тогда
		Если РеквизитыАйтема.КодПоИнвойсу = "NA" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "N\A" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "N/A"
		ИЛИ  РеквизитыАйтема.КодПоИнвойсу = "na" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "n\a" ИЛИ РеквизитыАйтема.КодПоИнвойсу = "n/a" Тогда
		// } RGS ASeryakov 21.08.2018 18:52:22 S-I-0005805
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			|	Catalog.DescriptionRus,
			|	Catalog.FiscalType
			|ИЗ
			|	Справочник.Catalog КАК Catalog
			|ГДЕ
			|	Catalog.Код = &Код
			|	И Catalog.DescriptionEng = &DescriptionEng";
			Запрос.УстановитьПараметр("Код", РеквизитыАйтема.КодПоИнвойсу);
			Запрос.УстановитьПараметр("DescriptionEng", РеквизитыАйтема.НаименованиеТовара);
			Результат = Запрос.Выполнить();
			Если НЕ Результат.Пустой() Тогда
				Выборка = Результат.Выбрать();
				Выборка.Следующий();
				Элемент.Type = Выборка.FiscalType;
				Элемент.Translation = Выборка.DescriptionRus;
			Иначе
				PartNo = TDСервер.НайтиСоздатьPartNo(РеквизитыАйтема.КодПоИнвойсу, Элемент.InvoiceLine);
				Элемент.Type = Неопределено;
				Элемент.Translation = PartNo.DescriptionRus;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Таблица.Свернуть("InvoiceLine,Type,Translation");
	// } RGS AArsentev 04.07.2018 S-I-0005574
	
	ТЧ = Объект.Classification;

	Если МассивItems <> Неопределено Тогда 
		
		// заполним только выделенные строки
		СтруктураПоиска = Новый Структура("InvoiceLine");
		Для Каждого СтрокаТаблицы из Таблица Цикл 
			
			СтруктураПоиска.InvoiceLine = СтрокаТаблицы.InvoiceLine;
			МассивСтрокТЧ = ТЧ.НайтиСтроки(СтруктураПоиска);
			СтрокаТЧ = МассивСтрокТЧ[0];
			
			Если ЗначениеЗаполнено(СтрокаТаблицы.Type) Тогда
				СтрокаТЧ.Type = СтрокаТаблицы.Type;
				Модифицированность = Истина;
			КонецЕсли; 
			
			Если ЗначениеЗаполнено(СтрокаТаблицы.Translation) Тогда
				СтрокаТЧ.Translation = СтрокаТаблицы.Translation;
				Модифицированность = Истина;
			КонецЕсли; 
			
		КонецЦикла;
		
		Возврат;
		
	КонецЕсли;	
	
	// Удалим лишние строки и дозаполним существующие
	ы = 0;
	Пока ы < ТЧ.Количество() Цикл
		
		СтрокаТЧ = ТЧ[ы];
		Если ЗначениеЗаполнено(СтрокаТЧ.InvoiceLine) Тогда
			
			СтрокаТаблицы = Таблица.Найти(СтрокаТЧ.InvoiceLine, "InvoiceLine");
			Если СтрокаТаблицы = Неопределено Тогда
				
				// Если в таблице такую строку найти не удалось - удаляем ее
				ТЧ.Удалить(ы);
				Модифицированность = Истина;
				Продолжить;
				
			Иначе
				
				Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Type)
					И ЗначениеЗаполнено(СтрокаТаблицы.Type) Тогда
					СтрокаТЧ.Type = СтрокаТаблицы.Type;
					Модифицированность = Истина;
				КонецЕсли; 
				
				Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Translation)
					И ЗначениеЗаполнено(СтрокаТаблицы.Translation) Тогда
					СтрокаТЧ.Translation = СтрокаТаблицы.Translation;
					Модифицированность = Истина;
				КонецЕсли; 
				
				// Удалим строку из таблицы, чтобы потом не добавить ее еще раз
				Таблица.Удалить(СтрокаТаблицы);
				
			КонецЕсли;	
				
		Иначе
			// Если реквизит Invoice line незаполнен - удаляем эту строку
			ТЧ.Удалить(ы);
			Модифицированность = Истина;
			Продолжить;
		КонецЕсли; 
		
		ы = ы + 1;
		
	КонецЦикла; 
	
	//Добавим новые строки, оставшиеся в таблице
	Для Каждого СтрокаТаблицы Из Таблица Цикл
		
		НоваяСтрокаТЧ = Объект.Classification.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаТЧ, СтрокаТаблицы, "InvoiceLine, Type, Translation");
		Модифицированность = Истина;
		
	КонецЦикла; 
	
КонецПроцедуры

&НаКлиенте
Процедура FillSelectedLinesFromCatalog(Команда)
	
	ТекущиеДанные = Элементы.InvoiceLinesClassificationClassification.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ВыделенныеСтроки = Элементы.InvoiceLinesClassificationClassification.ВыделенныеСтроки;
	
	Если ВыделенныеСтроки.Количество() = 1 Тогда
		
		Если ЗначениеЗаполнено(CatalogFiscalType) Тогда
			ТекущиеДанные.Type = CatalogFiscalType;
			Модифицированность = Истина;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(CatalogTranslation) Тогда
			ТекущиеДанные.Translation = CatalogTranslation;
			Модифицированность = Истина;
		КонецЕсли;
		
	иначе
		
		МассивItems = Новый Массив;
		Для Каждого ВыделеннаяСтрока из ВыделенныеСтроки цикл
			ДанныеСтроки = Элементы.InvoiceLinesClassificationClassification.ДанныеСтроки(ВыделеннаяСтрока);
			МассивItems.Добавить(ДанныеСтроки.InvoiceLine);
		КонецЦикла;
		
		FillFromCatalogНаСервере(МассивItems);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура FillEmptyFieldsFromHistory(Команда)
	
	// ЭТА КНОПКА - ВРЕМЕННЫЙ ЗАТЫК, ТАК КАК МЫ НЕ УСПЕВАЕМ ПРОВЕРЯТЬ КАТАЛОГ
	FillEmptyFieldsFromHistoryНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура FillEmptyFieldsFromHistoryНаСервере()
	
	// ЭТА КНОПКА - ВРЕМЕННЫЙ ЗАТЫК, ТАК КАК МЫ НЕ УСПЕВАЕМ ПРОВЕРЯТЬ КАТАЛОГ
	МассивInvoiceLines = Новый Массив;
	Для Каждого СтрокаТЧ Из Объект.Classification Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Type)
			ИЛИ НЕ ЗначениеЗаполнено(СтрокаТЧ.Translation) Тогда
			МассивInvoiceLines.Добавить(СтрокаТЧ.InvoiceLine);
		КонецЕсли; 
		
	КонецЦикла; 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("InvoiceLines", МассивInvoiceLines);
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	InvoiceLines.Ссылка КАК InvoiceLine,
		|	InvoiceLines.КодПоИнвойсу КАК PartNumber
		|ПОМЕСТИТЬ InvoiceLinesPartNumbers
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК InvoiceLines
		|ГДЕ
		|	InvoiceLines.Ссылка В(&InvoiceLines)
		|	И InvoiceLines.КодПоИнвойсу <> """"
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	PartNumber
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	InvoiceLinesClassificationClassification.InvoiceLine.КодПоИнвойсу КАК PartNumber,
		|	МАКСИМУМ(InvoiceLinesClassificationClassification.Ссылка.Дата) КАК Дата
		|ПОМЕСТИТЬ PartNumbersMaxDates
		|ИЗ
		|	InvoiceLinesPartNumbers КАК InvoiceLinesPartNumbers
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
		|		ПО InvoiceLinesPartNumbers.PartNumber = InvoiceLinesClassificationClassification.InvoiceLine.КодПоИнвойсу
		|			И (InvoiceLinesClassificationClassification.Ссылка.Проведен)
		|			И (InvoiceLinesClassificationClassification.Ссылка <> &Ссылка)
		|
		|СГРУППИРОВАТЬ ПО
		|	InvoiceLinesClassificationClassification.InvoiceLine.КодПоИнвойсу
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	PartNumber,
		|	Дата
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	PartNumbersMaxDates.PartNumber,
		|	InvoiceLinesClassificationClassification.Type КАК Type,
		|	InvoiceLinesClassificationClassification.Translation КАК Translation
		|ИЗ
		|	PartNumbersMaxDates КАК PartNumbersMaxDates
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
		|		ПО PartNumbersMaxDates.PartNumber = InvoiceLinesClassificationClassification.InvoiceLine.КодПоИнвойсу
		|			И PartNumbersMaxDates.Дата = InvoiceLinesClassificationClassification.Ссылка.Дата
		|			И (InvoiceLinesClassificationClassification.Ссылка.Проведен)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	InvoiceLinesPartNumbers.InvoiceLine,
		|	InvoiceLinesPartNumbers.PartNumber
		|ИЗ
		|	InvoiceLinesPartNumbers КАК InvoiceLinesPartNumbers";
		
	Результаты = Запрос.ВыполнитьПакет();
	
	ТаблицаИстории = Результаты[2].Выгрузить();
	ТаблицаИстории.Индексы.Добавить("PartNumber");
	
	ТаблицаInvoiceLinesPartNumbers = Результаты[3].Выгрузить();
	ТаблицаInvoiceLinesPartNumbers.Индексы.Добавить("InvoiceLine");
	
	Для Каждого СтрокаТЧ Из Объект.Classification Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Type)
			ИЛИ НЕ ЗначениеЗаполнено(СтрокаТЧ.Translation) Тогда
			
			СтрокаТаблицыInvoiceLinesPartNumbers = ТаблицаInvoiceLinesPartNumbers.Найти(СтрокаТЧ.InvoiceLine, "InvoiceLine");
			Если СтрокаТаблицыInvoiceLinesPartNumbers <> Неопределено Тогда
				
				СтрокаТаблицыИстории = ТаблицаИстории.Найти(СтрокаТаблицыInvoiceLinesPartNumbers.PartNumber);
				Если СтрокаТаблицыИстории <> Неопределено Тогда
					
					Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Type)
						И ЗначениеЗаполнено(СтрокаТаблицыИстории.Type) Тогда
						СтрокаТЧ.Type = СтрокаТаблицыИстории.Type;
						Модифицированность = Истина;
					КонецЕсли; 
					
					Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Translation)
						И ЗначениеЗаполнено(СтрокаТаблицыИстории.Translation) Тогда
						СтрокаТЧ.Translation = СтрокаТаблицыИстории.Translation;
						Модифицированность = Истина;
					КонецЕсли;
					
				КонецЕсли; 
				
			КонецЕсли; 
			
		КонецЕсли; 
		
	КонецЦикла; 
	
КонецПроцедуры 

&НаКлиенте
Процедура UpdateCatalog(Команда)
	
	Отказ = Ложь;
	ТекущиеДанные = Элементы.InvoiceLinesClassificationClassification.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Please, select a row!",
			, "Classification", "Объект", Отказ);
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.InvoiceLine) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"In line " + ТекущиеДанные.НомерСтроки + ": ""Invoice line"" is empty!",
			, "Classification[" + (ТекущиеДанные.НомерСтроки-1) + "].InvoiceLine" ,"Объект", Отказ);
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Type) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"In line " + ТекущиеДанные.НомерСтроки + ": ""Type"" is empty!",
			, "Classification[" + (ТекущиеДанные.НомерСтроки-1) + "].Type" ,"Объект", Отказ);
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Translation) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"In line " + ТекущиеДанные.НомерСтроки + ": ""Translation"" is empty!",
			, "Classification[" + (ТекущиеДанные.НомерСтроки-1) + "].Translation" ,"Объект", Отказ);
	КонецЕсли;	
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Ответ = Вопрос("Are you sure you want to update a catalog?",
		РежимДиалогаВопрос.ДаНет,
		30,
		КодВозвратаДиалога.Да,
		,
		КодВозвратаДиалога.Нет);
		
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	Результат = UpdateCatalogНаСервере(ТекущиеДанные.InvoiceLine, ТекущиеДанные.Type, ТекущиеДанные.Translation);
	Если Результат.Успех Тогда
		ПоказатьОповещениеПользователя(,, Результат.Описание);
		InvoiceLineCatalog = Результат.Catalog;
		CatalogFiscalType = ТекущиеДанные.Type;
		CatalogTranslation = ТекущиеДанные.Translation;
	Иначе
		Предупреждение(Результат.Описание, 30);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция UpdateCatalogНаСервере(InvoiceLine, FiscalType, Translation)
	
	СтруктураВозврата = Новый Структура("Успех, Catalog, Описание");
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("InvoiceLine", InvoiceLine);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Goods.КодПоИнвойсу КАК InvoiceLinePartNumber,
		|	Goods.НаименованиеТовара КАК InvoiceLineDescriptioin,
		|	Catalog.Ссылка КАК Catalog,
		|	Catalog.Представление КАК CatalogПредставление,
		|	Catalog.FiscalType КАК CatalogFiscalType,
		|	Catalog.DescriptionRus КАК CatalogTranslation
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Goods
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Catalog КАК Catalog
		|		ПО Goods.КодПоИнвойсу = Catalog.Код
		|ГДЕ
		|	Goods.Ссылка = &InvoiceLine";
		
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Если ЗначениеЗаполнено(Выборка.Catalog) Тогда
		
		Если Выборка.CatalogFiscalType = FiscalType
			И Выборка.CatalogTranslation = Translation Тогда
			
			ЗафиксироватьТранзакцию();
			СтруктураВозврата.Успех = Истина;
			СтруктураВозврата.Описание = """Catalog " + СокрЛП(Выборка.CatalogПредставление) + """ does not require an update";
			Возврат СтруктураВозврата;
			
		КонецЕсли;
		
		БлокировкаДанных = Новый БлокировкаДанных;
		ЭлементБлокировки = БлокировкаДанных.Добавить("Справочник.Catalog");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Catalog);
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		Попытка
			БлокировкаДанных.Заблокировать();
		Исключение
			ОтменитьТранзакцию();
			СтруктураВозврата.Успех = Ложь;
			СтруктураВозврата.Описание = "Failed to block ""Catalog " + СокрЛП(Выборка.CatalogПредставление) + """:
				|" + ОписаниеОшибки();
			Возврат СтруктураВозврата;
		КонецПопытки;
		
		CatalogОбъект = Выборка.Catalog.ПолучитьОбъект();
		СтруктураВозврата.Описание = """Catalog " + СокрЛП(CatalogОбъект) + """ was successfully updated";
		
	Иначе
		
		Если НЕ ЗначениеЗаполнено(Выборка.InvoiceLinePartNumber) Тогда
			ОтменитьТранзакцию();
			СтруктураВозврата.Успех = Ложь;
			СтруктураВозврата.Описание = "Failed to create catalog, because ""Part no."" in Item is empty!";
			Возврат СтруктураВозврата;
		КонецЕсли;
		
		CatalogОбъект = Справочники.Catalog.СоздатьЭлемент();
		CatalogОбъект.Код = Выборка.InvoiceLinePartNumber;
		CatalogОбъект.DescriptionEng = Выборка.InvoiceLineDescriptioin;
		СтруктураВозврата.Описание = """Catalog " + СокрЛП(CatalogОбъект) + """ was successfully created";
		
	КонецЕсли;
	
	РГСофтКлиентСервер.УстановитьЗначение(CatalogОбъект.FiscalType, FiscalType);
	РГСофтКлиентСервер.УстановитьЗначение(CatalogОбъект.DescriptionRus, Translation);
	
	Попытка
		CatalogОбъект.Записать();
	Исключение
		ОтменитьТранзакцию();
		СтруктураВозврата.Успех = Ложь;
		СтруктураВозврата.Описание = "Failed to save ""Catalog " + СокрЛП(CatalogОбъект) + """:
			|" + ОписаниеОшибки();
		Возврат СтруктураВозврата;
	КонецПопытки;
	
	ЗафиксироватьТранзакцию();
	
	СтруктураВозврата.Успех = Истина;
	СтруктураВозврата.Catalog = CatalogОбъект.Ссылка;

	Возврат СтруктураВозврата;
	
КонецФункции

&НаКлиенте
Процедура InvoiceLinesClassificationClassificationПриАктивизацииСтроки(Элемент)
	
	InvoiceLineDescription = "";
	InvoiceLineSoldTo = Неопределено;
	InvoiceLineERPTreatment = Неопределено;
	InvoiceLineSegment = Неопределено;
	InvoiceLineQty = 0;
	InvoiceLineUOM = Неопределено;
	InvoiceLinePrice = 0;
	InvoiceCurrency = Неопределено;
	InvoiceLineFiscalPriceWOServices = 0;
	InvoiceLineFiscalSumWOServices = 0;
	InvoiceLineCatalog = Неопределено;
	CatalogTranslation = "";
	CatalogFiscalType = Неопределено;
	CCDLineDescription = "";
	
	History.Очистить();
	
	ТекущаяСтрока = Элементы.InvoiceLinesClassificationClassification.ТекущаяСтрока;	
	Если ТекущаяСтрока <> Неопределено Тогда
		
		ТекущиеДанные = Объект.Classification.НайтиПоИдентификатору(ТекущаяСтрока);
		InvoiceLine = ТекущиеДанные.InvoiceLine;
		Если ЗначениеЗаполнено(InvoiceLine) Тогда
			
			СтруктураДанных = ПолучитьДанныеДляТекущейСтроки(Объект.Ссылка, Объект.InvoiceLinesMatching, InvoiceLine, History);
			
			InvoiceLineDescription = СтруктураДанных.InvoiceLineDescription;
			InvoiceLineSoldTo = СтруктураДанных.InvoiceLineSoldTo;
			InvoiceLineERPTreatment = СтруктураДанных.InvoiceLineERPTreatment;
			InvoiceLineSegment = СтруктураДанных.InvoiceLineSegment;
			InvoiceLineQty = СтруктураДанных.InvoiceLineQty;
			InvoiceLineUOM = СтруктураДанных.InvoiceLineUOM;
			InvoiceLinePrice = СтруктураДанных.InvoiceLinePrice;
			InvoiceCurrency = СтруктураДанных.InvoiceCurrency;
			InvoiceLineCatalog = СтруктураДанных.InvoiceLineCatalog;
			CatalogTranslation = СтруктураДанных.CatalogTranslation;
			CatalogFiscalType = СтруктураДанных.CatalogFiscalType;
			CCDLineDescription = СтруктураДанных.CCDLineDescription;
			InvoiceLineFiscalPriceWOServices = СтруктураДанных.FiscalPriceWOServices;
			InvoiceLineFiscalSumWOServices = СтруктураДанных.FiscalSumWOServices;
						
			Для Каждого СтрокаТаблицы Из СтруктураДанных.History Цикл
				НоваяСтрока = History.Добавить();
				НоваяСтрока.Date = СтрокаТаблицы.Date;
				НоваяСтрока.Type = СтрокаТаблицы.Type;
				НоваяСтрока.Translation = СтрокаТаблицы.Translation;
				НоваяСтрока.InvoiceLinesClassification = СтрокаТаблицы.InvoiceLinesClassification;
			КонецЦикла;
						
		КонецЕсли;
		
	КонецЕсли;	
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьДанныеДляТекущейСтроки(CurrentInvoiceLinesClassification, InvoiceLinesMatching, InvoiceLine, Знач History)
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("InvoiceLineDescription", "");
	СтруктураВозврата.Вставить("InvoiceLineSoldTo", "");
	СтруктураВозврата.Вставить("InvoiceLineERPTreatment", Неопределено);
	СтруктураВозврата.Вставить("InvoiceLineSegment", Неопределено);
	СтруктураВозврата.Вставить("InvoiceLineCatalog", Неопределено);
	СтруктураВозврата.Вставить("InvoiceLineQty", 0);
	СтруктураВозврата.Вставить("InvoiceLineUOM", Неопределено);
	СтруктураВозврата.Вставить("InvoiceLinePrice", 0);
	СтруктураВозврата.Вставить("InvoiceCurrency", Неопределено);
	СтруктураВозврата.Вставить("CatalogTranslation", "");
	СтруктураВозврата.Вставить("CatalogFiscalType", Неопределено);
	СтруктураВозврата.Вставить("CCDLineDescription", "");
	СтруктураВозврата.Вставить("FiscalPriceWOServices", 0);
	СтруктураВозврата.Вставить("FiscalSumWOServices", 0);
	СтруктураВозврата.Вставить("History", History);	
		
	СтруктураТекстов = Новый Структура;
	СтруктураПараметров = Новый Структура;
	
	СтруктураПараметров.Вставить("InvoiceLinesMatching", InvoiceLinesMatching);
	СтруктураПараметров.Вставить("InvoiceLine", InvoiceLine);
	
	СтруктураТекстов.Вставить("РеквизитыInvoiceLine",
		"ВЫБРАТЬ
		|	InvoiceLines.НаименованиеТовара КАК InvoiceLineDescription,
		|	InvoiceLines.Количество КАК InvoiceLineQty,
		|	InvoiceLines.Классификатор КАК InvoiceLineERPTreatment,
		|	InvoiceLines.КостЦентр.Segment КАК InvoiceLineSegment,
		|	InvoiceLines.SoldTo КАК InvoiceLineSoldTo,
		|	InvoiceLines.Цена КАК InvoiceLinePrice,
		|	InvoiceLines.Инвойс.Валюта КАК InvoiceCurrency,
		|	InvoiceLines.ЕдиницаИзмерения КАК InvoiceLineUOM,
		|	Catalog.Ссылка КАК Catalog,
		|	Catalog.FiscalType КАК CatalogFiscalType,
		|	Catalog.DescriptionRus КАК CatalogTranslation
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК InvoiceLines
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Catalog КАК Catalog
		|		ПО InvoiceLines.КодПоИнвойсу = Catalog.Код
		|ГДЕ
		|	InvoiceLines.Ссылка = &InvoiceLine");
	
	СтруктураТекстов.Вставить("ВременнаяТаблицаCCDLinesGoods",
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	InvoiceLinesMatching.ТоварСтрокиГТД КАК CCDLineGood
		|ПОМЕСТИТЬ CCDLinesGoods
		|ИЗ
		|	Документ.ЗакрытиеПоставки.Сопоставление КАК InvoiceLinesMatching
		|ГДЕ
		|	InvoiceLinesMatching.Ссылка = &InvoiceLinesMatching
		|	И InvoiceLinesMatching.СтрокаИнвойса = &InvoiceLine
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	CCDLineGood");
		
	СтруктураТекстов.Вставить("CCDLineDescription",
		"ВЫБРАТЬ
		|	ТоварыСтрокГТД.Владелец.НомерСтрокиГТД КАК НомерСтрокиГТД,
		|	0 КАК НомерСтроки,
		|	ТоварыСтрокГТД.Владелец.ОписаниеТовара КАК ОписаниеТовара,
		|	NULL КАК GoodsMarking
		|ИЗ
		|	CCDLinesGoods КАК CCDLinesGoods
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТоварыСтрокГТД КАК ТоварыСтрокГТД
		|		ПО CCDLinesGoods.CCDLineGood = ТоварыСтрокГТД.Ссылка
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	ТоварыСтрокГТД.Владелец.НомерСтрокиГТД,
		|	ТоварыСтрокГТД.Код,
		|	ТоварыСтрокГТД.Характеристика,
		|	ТоварыСтрокГТД.МаркировкаТовара
		|ИЗ
		|	CCDLinesGoods КАК CCDLinesGoods
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТоварыСтрокГТД КАК ТоварыСтрокГТД
		|		ПО CCDLinesGoods.CCDLineGood = ТоварыСтрокГТД.Ссылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерСтрокиГТД,
		|	НомерСтроки");
		
	СтруктураТекстов.Вставить("FiscalSumWOServices",
		"ВЫБРАТЬ
		|	InvoiceLinesCostsОбороты.СуммаФискальнаяОборот КАК FiscalSumWOServices
		|ИЗ
		|	РегистрНакопления.InvoiceLinesCosts.Обороты(
		|			,
		|			,
		|			,
		|			СтрокаИнвойса = &InvoiceLine
		|				И ЭлементФормированияСтоимости <> ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)
		|				И ЭлементФормированияСтоимости <> ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ПрочиеУслуги)) КАК InvoiceLinesCostsОбороты");
		
	СтруктураПараметров.Вставить("CurrentInvoiceLinesClassification", CurrentInvoiceLinesClassification);
	СтруктураТекстов.Вставить("History",
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	InvoiceLinesClassificationClassification.Ссылка.Дата КАК Date,
		|	InvoiceLinesClassificationClassification.Type КАК Type,
		|	InvoiceLinesClassificationClassification.Translation КАК Translation,
		|	InvoiceLinesClassificationClassification.Ссылка КАК InvoiceLinesClassification
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК InvoiceLines
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
		|		ПО InvoiceLines.КодПоИнвойсу = InvoiceLinesClassificationClassification.InvoiceLine.КодПоИнвойсу
		|ГДЕ
		|	InvoiceLines.Ссылка = &InvoiceLine
		|	И InvoiceLinesClassificationClassification.Ссылка <> &CurrentInvoiceLinesClassification
		|	И InvoiceLinesClassificationClassification.Ссылка.Проведен
		|
		|УПОРЯДОЧИТЬ ПО
		|	Date УБЫВ");
		
	СтруктураРезультатов = РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
	// Реквизиты Invoice line
	ВыборкаРеквизитовInvoiceLine = СтруктураРезультатов.РеквизитыInvoiceLine.Выбрать();
	Если ВыборкаРеквизитовInvoiceLine.Следующий() Тогда
		СтруктураВозврата.InvoiceLineDescription = ВыборкаРеквизитовInvoiceLine.InvoiceLineDescription;
		СтруктураВозврата.InvoiceLineSoldTo = ВыборкаРеквизитовInvoiceLine.InvoiceLineSoldTo;
		СтруктураВозврата.InvoiceLineERPTreatment = ВыборкаРеквизитовInvoiceLine.InvoiceLineERPTreatment;
		СтруктураВозврата.InvoiceLineSegment = ВыборкаРеквизитовInvoiceLine.InvoiceLineSegment;
		СтруктураВозврата.InvoiceLineQty = ВыборкаРеквизитовInvoiceLine.InvoiceLineQty;
		СтруктураВозврата.InvoiceLineUOM = ВыборкаРеквизитовInvoiceLine.InvoiceLineUOM;
		СтруктураВозврата.InvoiceLinePrice = ВыборкаРеквизитовInvoiceLine.InvoiceLinePrice;
		СтруктураВозврата.InvoiceCurrency = ВыборкаРеквизитовInvoiceLine.InvoiceCurrency;
		СтруктураВозврата.InvoiceLineCatalog = ВыборкаРеквизитовInvoiceLine.Catalog;
		СтруктураВозврата.CatalogTranslation = ВыборкаРеквизитовInvoiceLine.CatalogTranslation;
		СтруктураВозврата.CatalogFiscalType = ВыборкаРеквизитовInvoiceLine.CatalogFiscalType;
   	КонецЕсли;
	
	// CCD line description
	ВыборкаОписанийИзСтрокГТД = СтруктураРезультатов.CCDLineDescription.Выбрать();
	СтруктураВозврата.CCDLineDescription = "";
	Пока ВыборкаОписанийИзСтрокГТД.Следующий() Цикл
					
		СтруктураВозврата.CCDLineDescription = СтруктураВозврата.CCDLineDescription + Символы.ПС
			+ ?(ВыборкаОписанийИзСтрокГТД.НомерСтроки, "", Символы.ПС)
			+ ВыборкаОписанийИзСтрокГТД.НомерСтрокиГТД
			+ ?(ВыборкаОписанийИзСтрокГТД.НомерСтроки, "." + ВыборкаОписанийИзСтрокГТД.НомерСтроки, "")
			+ ") " + СокрЛП(ВыборкаОписанийИзСтрокГТД.ОписаниеТовара)
			+ ?(ВыборкаОписанийИзСтрокГТД.НомерСтроки, " (" + СокрЛП(ВыборкаОписанийИзСтрокГТД.GoodsMarking) + ")", "");
		
	КонецЦикла;
	
	СтруктураВозврата.CCDLineDescription = Прав(СтруктураВозврата.CCDLineDescription, СтрДлина(СтруктураВозврата.CCDLineDescription) - 2);
	
	ВыборкаFiscalSumWOServices = СтруктураРезультатов.FiscalSumWOServices.Выбрать();
	Если ВыборкаFiscalSumWOServices.Следующий() Тогда
		СтруктураВозврата.FiscalSumWOServices = ВыборкаFiscalSumWOServices.FiscalSumWOServices;
		Если СтруктураВозврата.InvoiceLineQty <> 0 Тогда
			СтруктураВозврата.FiscalPriceWOServices = СтруктураВозврата.FiscalSumWOServices / СтруктураВозврата.InvoiceLineQty;
		КонецЕсли;
	КонецЕсли;
	
	СтруктураВозврата.History.Загрузить(СтруктураРезультатов.History.Выгрузить());
	
	Возврат СтруктураВозврата;
	
КонецФункции


//////////////////////////////////////////////////////////////////////////////
// HISTORY

&НаКлиенте
Процедура HistoryВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если Поле = Элементы.HistoryInvoiceLinesClassification Тогда 
		ПоказатьЗначение(,Элемент.ТекущиеДанные.InvoiceLinesClassification);
	Иначе
		
		ТекущаяСтрокаТЧ = Элементы.InvoiceLinesClassificationClassification.ТекущиеДанные;
		Если ТекущаяСтрокаТЧ <> Неопределено Тогда
			
			Если Поле = Элементы.HistoryType Тогда
				
				ТекущаяСтрокаТЧ.Type = Элемент.ТекущиеДанные.Type;
				Модифицированность = Истина;
				
			ИначеЕсли Поле = Элементы.HistoryTranslation Тогда
				
				ТекущаяСтрокаТЧ.Translation = Элемент.ТекущиеДанные.Translation;
				Модифицированность = Истина;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры
