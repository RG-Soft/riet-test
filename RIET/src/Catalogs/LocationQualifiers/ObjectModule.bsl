
///////////////////////////////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	РГСофт.ОчиститьCreationModification(ЭтотОбъект);
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();	
	
	ПроверитьЗаполнениеРеквизитов(Отказ);
		
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизиты()
	
	Код = СокрЛП(ВРег(Код));
		
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Code' is empty!",
			ЭтотОбъект, "Код", , Отказ);	
	КонецЕсли;
		
КонецПроцедуры
