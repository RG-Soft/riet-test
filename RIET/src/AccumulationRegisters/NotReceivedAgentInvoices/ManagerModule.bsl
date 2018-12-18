
Функция ПолучитьОстатки(МоментВремени=Неопределено, Services, ParentCompany=Неопределено) Экспорт
	
	// Возвращает таблицу остатков, отобранных по Services и опционально по Моменту времени и Parent company
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	Запрос.УстановитьПараметр("Services", Services);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);	
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	NotReceivedAgentInvoicesОстатки.Service,
		|	NotReceivedAgentInvoicesОстатки.SoldTo КАК ParentCompany,
		|	NotReceivedAgentInvoicesОстатки.SumОстаток
		|ИЗ
		|	РегистрНакопления.NotReceivedAgentInvoices.Остатки(
		|			&МоментВремени,
		|			Service В (&Services)
		|				И ВЫБОР
		|					КОГДА &ParentCompany = НЕОПРЕДЕЛЕНО
		|						ТОГДА ИСТИНА
		|					ИНАЧЕ SoldTo = &ParentCompany
		|				КОНЕЦ) КАК NotReceivedAgentInvoicesОстатки";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ОборотыПоРегистраторам(НачалоПериода=Неопределено, КонецПериода=Неопределено, Services, ParentCompany=Неопределено) Экспорт
	
	// Возвращает таблицу оборотов в разрезе регистраторов с обязательным отбором по Services и опциональными по периоду и Parent company
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода", КонецПериода);
	Запрос.УстановитьПараметр("Services", Services);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	
	Запрос.Текст =	
		"ВЫБРАТЬ
		|	NotReceivedAgentInvoicesОбороты.Регистратор,
		|	NotReceivedAgentInvoicesОбороты.Service,
		|	NotReceivedAgentInvoicesОбороты.SoldTo КАК ParentCompany,
		|	NotReceivedAgentInvoicesОбороты.SumОборот,
		|	NotReceivedAgentInvoicesОбороты.SumПриход,
		|	NotReceivedAgentInvoicesОбороты.SumРасход
		|ИЗ
		|	РегистрНакопления.NotReceivedAgentInvoices.Обороты(
		|			&НачалоПериода,
		|			&КонецПериода,
		|			Регистратор,
		|			Service В (&Services)
		|				И ВЫБОР
		|					КОГДА &ParentCompany = НЕОПРЕДЕЛЕНО
		|						ТОГДА ИСТИНА
		|					ИНАЧЕ SoldTo = &ParentCompany
		|				КОНЕЦ) КАК NotReceivedAgentInvoicesОбороты";
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции
