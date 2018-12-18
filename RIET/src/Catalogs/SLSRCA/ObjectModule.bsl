
//////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	РГСофт.ОчиститьCreationModification(ЭтотОбъект);
	
КонецПроцедуры


//////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();
	
	ПроверитьРеквизиты(Отказ);
	
КонецПроцедуры

Процедура ДозаполнитьРеквизиты()
	
	Код = СокрЛП(Код);
	Наименование = СокрЛП(Наименование);
	Phone = СокрЛП(Phone);
	EMail = СокрЛП(EMail);
	
	Если ЗначениеЗаполнено(ProcessLevel) Тогда
		Country = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ProcessLevel, "Country");
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
	
	ProcessLevels.Свернуть("ProcessLevel");
	Segments.Свернуть("Segment");
	
КонецПроцедуры

Процедура ПроверитьРеквизиты(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Alias' is empty!",
			ЭтотОбъект, "Код",, Отказ);		
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(Наименование) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Name' is empty!",
			ЭтотОбъект, "Наименование",, Отказ);		
	КонецЕсли;	
	        		
	Если НЕ ЗначениеЗаполнено(Phone) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Phone' is empty!",
			ЭтотОбъект, "Phone",, Отказ);		
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(EMail) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'E-mail' is empty!",
			ЭтотОбъект, "EMail",, Отказ);		
	КонецЕсли;	
	
	//Если НЕ ЗначениеЗаполнено(ProcessLevel) Тогда
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
	//		"'Process level' is empty!",
	//		ЭтотОбъект, "ProcessLevel", , Отказ);
	//КонецЕсли;
	
	Если Не TransactionSpecialist Тогда 
		
		Если ProcessLevels.Количество() = 0 Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Add at least one process level!",
			ЭтотОбъект, "ProcessLevels",, Отказ);		
		КонецЕсли;
		
		Если Segments.Количество() = 0 Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Add at least one segment!",
			ЭтотОбъект, "Segments",, Отказ);		
		КонецЕсли;	
		
	КонецЕсли;

КонецПроцедуры

