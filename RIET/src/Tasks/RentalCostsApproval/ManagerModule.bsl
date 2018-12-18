
Функция ПолучитьСсылкуНаApproval(RentalCost) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("RentalCost", RentalCost);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	RentalCostsApproval.Ссылка КАК Approval
	|ИЗ
	|	Задача.RentalCostsApproval КАК RentalCostsApproval
	|ГДЕ
	|	RentalCostsApproval.RentalCost = &RentalCost";
	
	ВыборкаRentalCostApproval = Запрос.Выполнить().Выбрать();
	
	Если ВыборкаRentalCostApproval.Следующий() Тогда 
		Возврат  ВыборкаRentalCostApproval.Approval;
	Иначе 
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции