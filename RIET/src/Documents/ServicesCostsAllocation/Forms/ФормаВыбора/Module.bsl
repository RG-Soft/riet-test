
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзAgentInvoice" Тогда
			НастроитьДляВыбораИзAgentInvoice(СтруктураНастройки);
		КонецЕсли;
		
	КонецЕсли;
	
	Параметры.Отбор.Вставить("ПометкаУдаления", Ложь);
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзAgentInvoice(СтруктураНастройки)
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("Agent", СтруктураНастройки.Agent);
	
	// Покажем только те Services costs allocations, по которым есть остатки
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Agent", СтруктураНастройки.Agent);
	Запрос.УстановитьПараметр("SoldTo", СтруктураНастройки.SoldTo);
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ServicesCostsAllocationServices.Ссылка
		|ИЗ
		|	РегистрНакопления.NotReceivedAgentInvoices.Остатки(
		|			,
		|			SoldTo = &SoldTo
		|				И Service.Agent = &Agent) КАК NotReceivedAgentInvoicesОстатки
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ServicesCostsAllocation.Services КАК ServicesCostsAllocationServices
		|		ПО NotReceivedAgentInvoicesОстатки.Service = ServicesCostsAllocationServices.Service
		|			И (ServicesCostsAllocationServices.Ссылка.Проведен)";
	МассивServicesCostsAllocations = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	Отбор.Вставить("Ссылка", МассивServicesCostsAllocations);
	
	Элементы.Список.МножественныйВыбор = Истина;
	
КонецПроцедуры