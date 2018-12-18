
Процедура ПередЗаписью(Отказ)
	
	ClientPONo = СокрЛП(ClientPONo);
	ClientPartNo = СокрЛП(ClientPartNo); 	
	ClientDescription = СокрЛП(ClientDescription);
	
	Код = ClientPONo + "-" + СокрЛП(ClientLineNo);
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	      		
	Если НЕ ЗначениеЗаполнено(ClientPONo) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"'Client PO no.' is empty!",
		ЭтотОбъект, "ClientPONo", , Отказ);
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ClientLineNo) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"'Client PO line' is empty!",
		ЭтотОбъект, "ClientLineNo", , Отказ);
		
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда	
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Code' is empty!",
			ЭтотОбъект, "Код", , Отказ);
			
	иначе
			
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Код", СокрЛП(Код));
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	СтрокиИнвойса.Инвойс.Представление КАК Invoice
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
		|ГДЕ
		|	НЕ СтрокиИнвойса.ПометкаУдаления
		|	И СтрокиИнвойса.ClientPO <> &Ссылка
		|	И СтрокиИнвойса.ClientPO.Код = &Код
		|	И НЕ СтрокиИнвойса.ClientPO.ПометкаУдаления";
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Client PO line '" + СокрЛП(Код) + "' is already used in '" + СокрЛП(Выборка.Invoice) + "'!",
			ЭтотОбъект, "ClientLineNo", , Отказ);	
		КонецЕсли;

	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ClientPartNo) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"'Client Part No.' is empty!",
		ЭтотОбъект, "ClientPartNo", , Отказ);
		
	КонецЕсли;  
	
КонецПроцедуры
