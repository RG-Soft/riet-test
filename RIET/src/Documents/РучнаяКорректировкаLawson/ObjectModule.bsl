
Функция ПолучитьТаблицуСоответствияКолонок(ПорядокКолонок) Экспорт 
	
	табВозврата = Новый ТаблицаЗначений;
	табВозврата.Колонки.Добавить("НомерКолонки");
	табВозврата.Колонки.Добавить("Имя");
	
	СтрокаОбработки = ПорядокКолонок;
	НомерКолонки = 1;
	Пока СтрДлина(СтрокаОбработки) Цикл
		Позиция = СтрНайти(СтрокаОбработки, ",");
		Если Позиция Тогда
			ИмяКолонки = СокрЛП(Лев(СтрокаОбработки, Позиция - 1));
			СтрокаОбработки = СокрЛП(Прав(СтрокаОбработки, СтрДлина(СтрокаОбработки) - Позиция));
		Иначе
			ИмяКолонки = СокрЛП(СтрокаОбработки);
			СтрокаОбработки = "";
		КонецЕсли;
		НоваяСтрока = табВозврата.Добавить();
		НоваяСтрока.НомерКолонки = НомерКолонки;
		НоваяСтрока.Имя = ИмяКолонки;
		НомерКолонки = НомерКолонки + 1;
	КонецЦикла;
	
	Возврат табВозврата;
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Для Каждого Запись Из Движения.ПроводкиDSSОбщие Цикл
		Запись.Период = Запись.PeriodLawson;
		Если НЕ ЗначениеЗаполнено(Запись.GUID) Тогда
			Запись.GUID = Новый УникальныйИдентификатор();
		КонецЕсли;
		Запись.GltObjId = 1000000001;
	КонецЦикла;
	
КонецПроцедуры

