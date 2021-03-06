
//////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	РГСофт.ОчиститьCreationModification(ЭтотОбъект);
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ);
		
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Код = СокрЛП(Код);
	CardHolder = СокрЛП(CardHolder);
	
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры 


///////////////////////////////////////////////////////////////////////////////////////

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'No.' is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(CardHolder) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Card holder' is empty!",
			ЭтотОбъект, "CardHolder", , Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(CCA) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'CCA' is empty!",
			ЭтотОбъект, "CCA", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ExpiryDate) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Expiry date' is empty!",
			ЭтотОбъект, "ExpiryDate", , Отказ);	
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParentCompany) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent company' is empty!",
			ЭтотОбъект, "ParentCompany", , Отказ);	
	КонецЕсли;

КонецПроцедуры

