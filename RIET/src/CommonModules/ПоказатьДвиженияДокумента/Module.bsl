Функция ПровестиДокумент(ПараметрКоманды)
	
	ДокументОбъект = ПараметрКоманды.ПолучитьОбъект();
	Попытка
		Если НЕ ДокументОбъект.ПроверитьЗаполнение() Тогда 
			Возврат Ложь;
		КонецЕсли;
		
		НачатьТранзакцию();
		ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение);
		ЗафиксироватьТранзакцию();
		
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;

КонецФункции

Функция ПолучитьПараметрыДокумента(Ссылка)
	
	МетаданныеДокумента	= Ссылка.Метаданные();
	
	ЕстьРучнаяКорректировка	= ОбщегоНазначения.ЕстьРеквизитДокумента("РучнаяКорректировка", МетаданныеДокумента);
	
	ИменаРеквизитов	= "Проведен, ПометкаУдаления";
	Если ЕстьРучнаяКорректировка Тогда
		ИменаРеквизитов	= ИменаРеквизитов + ", РучнаяКорректировка";
	КонецЕсли;
	
	Результат	= ОбщегоНазначения.ПолучитьЗначенияРеквизитов(Ссылка, ИменаРеквизитов);
	Если НЕ ЕстьРучнаяКорректировка Тогда
		Результат.Вставить("РучнаяКорректировка", Ложь);
	КонецЕсли;
	
	Результат.Вставить("ОперацияБух",	ТипЗнч(Ссылка) = Тип("ДокументСсылка.ОперацияБух"));
	
	Возврат Результат;
	
КонецФункции

Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды) Экспорт
	
	ПараметрыДокумента = ПолучитьПараметрыДокумента(ПараметрКоманды);
	
	Если НЕ ПараметрыДокумента.ПометкаУдаления И НЕ ПараметрыДокумента.ОперацияБух И
		НЕ ПараметрыДокумента.РучнаяКорректировка И                                             
		НЕ ПараметрыДокумента.Проведен Тогда
		
		Кнопки = Новый СписокЗначений;
		Кнопки.Вставить(0, КодВозвратаДиалога.Да, "Провести");
		Кнопки.Вставить(1, КодВозвратаДиалога.Нет, "Отмена");
		Ответ = Вопрос(ВернутьСтр("ru = 'Перед просмотром проводок документ следует провести'"), Кнопки,, КодВозвратаДиалога.Да);
		Если Ответ <> КодВозвратаДиалога.Да Тогда
			Возврат;
		ИначеЕсли Не ПровестиДокумент(ПараметрКоманды) Тогда
			Сообщить(ВернутьСтр("ru = 'Не удалось провести документ'"), СтатусСообщения.Важное);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура("ДокументСсылка", ПараметрКоманды);
	ОткрытьФорму("Обработка.КорректировкаДвижений.Форма", 
		ПараметрыФормы, 
		ПараметрыВыполненияКоманды, 
		ПараметрКоманды);
	
КонецПроцедуры
