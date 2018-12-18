
Процедура ПередЗаписьюРегистраСведенийОбменДокументамиLogelcoERMПередЗаписью(Источник, Отказ, Замещение) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	УзелERM = rgsОбменДокументамиLogelcoERMПовтИспСеанс.ПолучитьУзелERM();
	
	Если УзелERM = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого СтрокаНабора Из Источник Цикл
		
		Если ТипЗнч(СтрокаНабора.Документ) = Тип("ДокументСсылка.РеализацияТоваровУслуг")
			ИЛИ ТипЗнч(СтрокаНабора.Документ) = Тип("ДокументСсылка.ПередачаОС") Тогда
			
			ПланыОбмена.ЗарегистрироватьИзменения(УзелERM, СтрокаНабора.Документ);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПриЗаписиДокументаОбменДокументамиLogelcoERMПриЗаписи(Источник, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если Источник.ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	УзелERM = rgsОбменДокументамиLogelcoERMПовтИспСеанс.ПолучитьУзелERM();
	
	Если УзелERM = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИННОрганизации = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Источник.Организация, "ИНН");
	ИННКонтрагента = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Источник.Контрагент, "ИНН");
	
	ЭтоИнтеркампэни = КонтрольПроведенияСервер.КонтрольПроведенияДляОрганизацииИспользуется(ИННОрганизации) И 
		КонтрольПроведенияСервер.КонтрольПроведенияДляОрганизацииИспользуется(ИННКонтрагента)
		И ИННОрганизации <> ИННКонтрагента;
		
	Если НЕ ЭтоИнтеркампэни Тогда
		ПланыОбмена.ЗарегистрироватьИзменения(УзелERM, Источник.Ссылка);
	КонецЕсли;
	
КонецПроцедуры
