
&НаСервере
Процедура ЗаполнитьАрендованымТранспортомНаСервере()
	
	Объект.PlanningCosts.Очистить();
	Запрос = Новый Запрос;
	Запрос.Текст =  "ВЫБРАТЬ
	                |	ТранспортноеСредство.Транспорт КАК Транспорт,
	                |	ТранспортноеСредство.ServiceProvider КАК ServiceProvider,
	                |	ТранспортноеСредство.Equipment КАК Equipment,
	                |	TransportAvailabilityStatusСрезПоследних.Status КАК Status,
	                |	TransportMonthlyRateСрезПоследних.MonthlyRate КАК MonthlyRate,
	                |	TransportMonthlyRateСрезПоследних.Currency КАК Currency
	                |ИЗ
	                |	(ВЫБРАТЬ
	                |		Transport.Ссылка КАК Транспорт,
	                |		Transport.ServiceProvider КАК ServiceProvider,
	                |		Transport.Equipment КАК Equipment
	                |	ИЗ
	                |		Справочник.Transport КАК Transport
	                |	ГДЕ
	                |		Transport.TypeOfTransport = ЗНАЧЕНИЕ(Перечисление.TypesOfTransport.Rental)) КАК ТранспортноеСредство
	                |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.TransportAvailabilityStatus.СрезПоследних(&Дата, Status <> ЗНАЧЕНИЕ(Перечисление.TransportAvailabilityStatuses.EndOfRental)) КАК TransportAvailabilityStatusСрезПоследних
	                |		ПО ТранспортноеСредство.Транспорт = TransportAvailabilityStatusСрезПоследних.Transport
	                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.TransportMonthlyRate.СрезПоследних(&Дата, ) КАК TransportMonthlyRateСрезПоследних
	                |		ПО ТранспортноеСредство.Транспорт = TransportMonthlyRateСрезПоследних.Transport";
	Запрос.УстановитьПараметр("Дата", КонецМесяца(Объект.Дата));
		
	Результат = Запрос.Выполнить().Выбрать();
	Пока Результат.Следующий() Цикл
		
		СтрокаТЧ = Объект.PlanningCosts.Добавить();
		СтрокаТЧ.Transport = Результат.Транспорт;
		СтрокаТЧ.ServiceProvider = Результат.ServiceProvider;
		СтрокаТЧ.Equipment = Результат.Equipment;
		СтрокаТЧ.PlanCosts = Результат.MonthlyRate;
		СтрокаТЧ.Currency = Результат.Currency;
		CostsSumUSD = 0;
		Если Результат.MonthlyRate <> 0 И ЗначениеЗаполнено(Результат.Currency) Тогда
			CostsSumUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Результат.MonthlyRate, Результат.Currency, Объект.Дата);
		КонецЕсли;
		СтрокаТЧ.PlanCostsUSD = CostsSumUSD;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьАрендованымТранспортом(Команда)
	ЗаполнитьАрендованымТранспортомНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура PlaningCostsPlanCostПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.PlaningCosts.ТекущиеДанные;
	Если ТекущиеДанные.PlanCosts <> 0 И ЗначениеЗаполнено(ТекущиеДанные.Currency) Тогда
		CostsSumUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекущиеДанные.PlanCosts, ТекущиеДанные.Currency, Объект.Дата);
		ТекущиеДанные.PlanCostsUSD = CostsSumUSD;	
	КонецЕсли;	
	
КонецПроцедуры
