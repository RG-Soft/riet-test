
Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	ТипУведомления = ЭтотОбъект[0].Type;
	
	Если ТипУведомления = Перечисления.NotificationType.TR Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("MOT"));
	КонецЕсли;
	
КонецПроцедуры
