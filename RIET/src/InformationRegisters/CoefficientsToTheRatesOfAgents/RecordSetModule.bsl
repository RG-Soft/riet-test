
Процедура ПередЗаписью(Отказ, Замещение)
	
	Для Каждого Запись Из ЭтотОбъект Цикл
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Agent", Запись.Agent);
		Запрос.УстановитьПараметр("Service", Запись.Service);
		Запрос.УстановитьПараметр("StartDate", Запись.StartDate);
		Запрос.УстановитьПараметр("ExpiryDate", Запись.ExpiryDate);
		
		Запрос.Текст = "ВЫБРАТЬ
		               |	CoefficientsToTheRatesOfAgents.StartDate,
		               |	CoefficientsToTheRatesOfAgents.ExpiryDate
		               |ИЗ
		               |	РегистрСведений.CoefficientsToTheRatesOfAgents КАК CoefficientsToTheRatesOfAgents
		               |ГДЕ
		               |	CoefficientsToTheRatesOfAgents.Agent = &Agent
		               |	И CoefficientsToTheRatesOfAgents.Service = &Service
		               |	И (CoefficientsToTheRatesOfAgents.StartDate >= &StartDate
		               |				И CoefficientsToTheRatesOfAgents.StartDate < &ExpiryDate
		               |			ИЛИ CoefficientsToTheRatesOfAgents.ExpiryDate >= &StartDate
		               |				И CoefficientsToTheRatesOfAgents.ExpiryDate < &ExpiryDate)";
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда 
		
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"For Service " + СокрЛП(Запись.Service) + " and Agent " + СокрЛП(Запись.Agent) + " already exists setting 
				|with overlapping period: " + СокрЛП(Выборка.StartDate) + " - " + СокрЛП(Выборка.ExpiryDate),
				,,, Отказ);
		
		КонецЕсли;
		   		
	КонецЦикла;
	
КонецПроцедуры
