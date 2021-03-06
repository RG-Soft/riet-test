
////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ДозаполнитьРеквизиты();
		
	СтруктураРезультатов = ПолучитьСтруктуруРезультатовЗапросовПередЗаписью();
	
	ПроверитьВозможностьИзменения(СтруктураРезультатов, Отказ);		
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьЗаполнениеРеквизитов(СтруктураРезультатов, Отказ);
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизиты()
	
	РГСофтКлиентСервер.УстановитьЗначение(ОписаниеТовара, СокрЛП(ОписаниеТовара));
	РГСофтКлиентСервер.УстановитьЗначение(Наименование, "" + НомерСтрокиГТД + "-" + ОписаниеТовара);
	
	Для Каждого СтрокаТЧ Из ИсчислениеПлатежей Цикл
		РГСофтКлиентСервер.УстановитьЗначение(СтрокаТЧ.СП, ВРег(СокрЛП(СтрокаТЧ.СП)));
	КонецЦикла;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьСтруктуруРезультатовЗапросовПередЗаписью()
	
	СтруктураПараметров = Новый Структура;
	СтруктураТекстов = Новый Структура;
	
	СтруктураПараметров.Вставить("Ссылка", Ссылка);
	
	Если ЗначениеЗаполнено(Ссылка) Тогда
		
		СтруктураТекстов.Вставить("СтарыеРеквизиты",
			"ВЫБРАТЬ
			|	CCDLines.ГТД КАК CCD,
			|	CCDLines.ПометкаУдаления
			|ИЗ
			|	Справочник.СтрокиГТД КАК CCDLines
			|ГДЕ
			|	CCDLines.Ссылка = &Ссылка");
		
	КонецЕсли;
	
	Если НЕ ПометкаУдаления Тогда
		
		Если ЗначениеЗаполнено(ГТД) Тогда
		
			СтруктураПараметров.Вставить("CCD", ГТД);
			СтруктураТекстов.Вставить("РеквизитыCCD",
				"ВЫБРАТЬ
				|	ГТД.Проведен
				|ИЗ
				|	Документ.ГТД КАК ГТД
				|ГДЕ
				|	ГТД.Ссылка = &CCD");
			
			Если ЗначениеЗаполнено(НомерСтрокиГТД) Тогда
				
				СтруктураПараметров.Вставить("НомерСтрокиГТД", НомерСтрокиГТД);
				СтруктураТекстов.Вставить("Дубли",
					"ВЫБРАТЬ
					|	CCDLines.Представление
					|ИЗ
					|	Справочник.СтрокиГТД КАК CCDLines
					|ГДЕ
					|	CCDLines.Ссылка <> &Ссылка
					|	И (НЕ CCDLines.ПометкаУдаления)
					|	И CCDLines.ГТД = &CCD
					|	И CCDLines.НомерСтрокиГТД = &НомерСтрокиГТД");
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
		
	Возврат РГСофт.ПолучитьСтруктуруРезультатовТекстовЗапросов(СтруктураТекстов, СтруктураПараметров);
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьВозможностьИзменения(СтруктураРезультатов, Отказ)
	
	Если НЕ ПометкаУдаления И ЗначениеЗаполнено(ГТД) Тогда
		
		ВыборкаРеквизитовCCD = СтруктураРезультатов.РеквизитыCCD.Выбрать();
		ВыборкаРеквизитовCCD.Следующий();
		Если ВыборкаРеквизитовCCD.Проведен = Истина Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Нельзя изменять CCD line """ + ЭтотОбъект + """, так как проведена """ + ГТД + """!",
				ЭтотОбъект,,, Отказ);
			Возврат;
		КонецЕсли;
	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Ссылка) Тогда
		
		ВыборкаСтарыхРеквизитов = СтруктураРезультатов.СтарыеРеквизиты.Выбрать();
		ВыборкаСтарыхРеквизитов.Следующий();
		Если НЕ ВыборкаСтарыхРеквизитов.ПометкаУдаления
			И ВыборкаСтарыхРеквизитов.CCD <> ГТД
			И ЗначениеЗаполнено(ВыборкаСтарыхРеквизитов.CCD)
			И ОбщегоНазначения.ПолучитьЗначениеРеквизита(ВыборкаСтарыхРеквизитов.CCD, "Проведен") Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Нельзя изменять CCD line """ + ЭтотОбъект + """, так как проведена """ + ВыборкаСтарыхРеквизитов.CCD + """!",
				ЭтотОбъект,,, Отказ);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеРеквизитов(СтруктураРезультатов, Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ГТД) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""CCD"" is epmty!",
			ЭтотОбъект, "ГТД", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(НомерСтрокиГТД) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""CCD line no."" is empty!",
			ЭтотОбъект, "НомерСтрокиГТД", , Отказ);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ГТД)
		И ЗначениеЗаполнено(НомерСтрокиГТД) Тогда
		
		Выборка = СтруктураРезультатов.Дубли.Выбрать();
		Пока Выборка.Следующий() Цикл
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"There is already line #" + НомерСтрокиГТД + " for """ + ГТД + """ (""" + Выборка.Представление + """)!",
				ЭтотОбъект, "НомерСтрокиГТД", , Отказ);
			
		КонецЦикла;

	КонецЕсли;
		
КонецПроцедуры
