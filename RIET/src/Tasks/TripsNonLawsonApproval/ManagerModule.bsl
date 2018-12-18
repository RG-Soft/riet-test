
Функция ПолучитьСсылкуНаApproval(Trip) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Trip", Trip);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripsNonLawsonApproval.Ссылка КАК Approval
	               |ИЗ
	               |	Задача.TripsNonLawsonApproval КАК TripsNonLawsonApproval
	               |ГДЕ
	               |	TripsNonLawsonApproval.Trip = &Trip";
	
	ВыборкаTripsApproval = Запрос.Выполнить().Выбрать();
	
	Если ВыборкаTripsApproval.Следующий() Тогда 
		Возврат  ВыборкаTripsApproval.Approval;
	Иначе 
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции