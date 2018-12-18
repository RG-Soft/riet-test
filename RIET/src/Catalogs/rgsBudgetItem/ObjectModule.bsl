
Процедура ПриЗаписи(Отказ)
	
	Если BudgetPercentType <> Перечисления.rgsBudgetPercentTypes.RevenueProcent тогда
		
		Если Не ЗначениеЗаполнено(SubLevel) тогда
		Отказ = Истина;
		Message = New UserMessage();
		Message.Text = "Не заполнено поле SubLevel";
		Message.Message();			
		КонецЕсли;
		
	КонецЕсли;
	
	Запрос = новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	rgsBudgetItem.Ссылка
	               |ИЗ
	               |	Справочник.rgsBudgetItem КАК rgsBudgetItem
	               |ГДЕ
	               |	rgsBudgetItem.BudgetPercentType = &BudgetPercentType
	               |	И rgsBudgetItem.GroupLevel = &GroupLevel
	               |	И rgsBudgetItem.SubLevel = &SubLevel
	               |	И rgsBudgetItem.Ссылка <> &Ссылка";
	Запрос.УстановитьПараметр("BudgetPercentType",BudgetPercentType);
	Запрос.УстановитьПараметр("GroupLevel",GroupLevel);
	Запрос.УстановитьПараметр("SubLevel",SubLevel);
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() > 0 тогда
		Отказ = Истина;
		Message = New UserMessage();
		Message.Text = "Уже есть элемент с такими реквизитами";
		Message.Message();
	КонецЕсли;
	
	
	
КонецПроцедуры


