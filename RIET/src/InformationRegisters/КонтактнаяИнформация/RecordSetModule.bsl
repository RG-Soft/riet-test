
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для каждого Запись Из ЭтотОбъект Цикл
		Если ОбщегоНазначения.ЗначениеНеЗаполнено(Запись.Объект) Тогда
			Отказ = Истина;
			СтрокаОтказа = "Не заполнен объект.";
			Продолжить;
		КонецЕсли; 
		Если Запись.Объект.ЭтоГруппа И Не ТипЗнч(Запись.Объект) = Тип("СправочникСсылка.ПодразделенияОрганизаций") Тогда
			Отказ = Истина;
			СтрокаОтказа = "Нельзя использовать группу в качестве объекта контактной информации.";
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Отказ Тогда
		Сообщить(СтрокаОтказа);
	КонецЕсли; 
	
КонецПроцедуры
