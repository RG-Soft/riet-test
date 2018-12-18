
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();
	
	ПроверитьЗаполнениеРеквизитов(Отказ);		
		
КонецПроцедуры

Процедура ДозаполнитьРеквизиты()
	
	РГСофтКлиентСервер.УстановитьЗначение(Код, СокрЛП(Код));
	РГСофтКлиентСервер.УстановитьЗначение(ShortDescription, СокрЛП(ShortDescription));
	РГСофтКлиентСервер.УстановитьЗначение(FullDescription, ПолучитьFullDescription());
	Если НЕ ЭтоГруппа Тогда
		РГСофтКлиентСервер.УстановитьЗначение(UOM, СокрЛП(UOM));
		РГСофтКлиентСервер.УстановитьЗначение(Rate, СокрЛП(Rate));
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьFullDescription()
		
	Если ЗначениеЗаполнено(Родитель) Тогда
		GroupFullDescription = ОбщегоНазначения.ПолучитьЗначениеРеквизита(Родитель, "FullDescription");
		NewFullDescription = GroupFullDescription + " " + ShortDescription;
	Иначе
		NewFullDescription = ShortDescription;
	КонецЕсли;
	
	Возврат СокрЛП(NewFullDescription);
	
КонецФункции

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Code"" не заполнено!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ShortDescription) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Short description"" не заполнено!",
			ЭтотОбъект, "ShortDescription", , Отказ);
	КонецЕсли;
	
КонецПроцедуры
