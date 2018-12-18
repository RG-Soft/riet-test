 
////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ПередЗаписью(Отказ)
	
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
		
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Name"" не заполнено!",
			ЭтотОбъект, "Name", , Отказ);
	КонецЕсли;
				
КонецПроцедуры

