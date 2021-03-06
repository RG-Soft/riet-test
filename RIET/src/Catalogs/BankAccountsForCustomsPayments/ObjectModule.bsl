
Процедура ПередЗаписью(Отказ)
	
	РГСофтКлиентСервер.УстановитьЗначение(Код, СокрЛП(Код));
	РГСофтКлиентСервер.УстановитьЗначение(Наименование, СокрЛП(Наименование));
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьЗаполнениеРеквизитов(Отказ);
		
КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли; 
	
	Если Не ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""No."" не заполнено!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
		
	Если Не ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Name"" не заполнено!",
			ЭтотОбъект, "Наименование", , Отказ);
	КонецЕсли;
		
	Если Не ЗначениеЗаполнено(TypeOfPayment) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Type of payment"" не заполнено!",
			ЭтотОбъект, "TypeOfPayment", , Отказ);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(SoldTo) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Sold-to"" не заполнено!",
			ЭтотОбъект, "SoldTo", , Отказ);
	КонецЕсли;
	
КонецПроцедуры 