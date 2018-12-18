
Функция ПолучитьTripStage(Trip) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	TripStages = Перечисления.TripNonLawsonCompaniesStages;
	
	TripОбъект = Trip.ПолучитьОбъект();
	
	// получим лимит затрат, превышение которого требует утверждения
	СтруктураBaseCostsSumLimit = РегистрыСведений.BaseCostsSumLimitForApproval.ПолучитьПоследнее(TripОбъект.Дата);
	LimitForApproval = ?(TripОбъект.CostsPlanning = Перечисления.TypesOfCostsPlanning.Automatic, 
		СтруктураBaseCostsSumLimit.LimitForApprovalLevel1AutomaticPlanning, СтруктураBaseCostsSumLimit.LimitForApprovalLevel1ManualPlanning);
	  	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Trip", Trip);

	Запрос.Текст = "ВЫБРАТЬ
	               |	TripsNonLawsonApproval.Status,
	               |	TripsNonLawsonApproval.Выполнена,
	               |	TripsNonLawsonApproval.Ссылка
	               |ИЗ
	               |	Задача.TripsNonLawsonApproval КАК TripsNonLawsonApproval
	               |ГДЕ
	               |	НЕ TripsNonLawsonApproval.ПометкаУдаления
	               |	И TripsNonLawsonApproval.Trip = &Trip";
	
	ВыборкаTripsApproval = Запрос.Выполнить().Выбрать();
	
	Если ЗначениеЗаполнено(TripОбъект.Closed) Тогда 
		
		Возврат Перечисления.TripNonLawsonCompaniesStages.Closed;
		
	ИначеЕсли TripОбъект.Проведен И ВыборкаTripsApproval.Следующий() Тогда
		
		Если TripОбъект.TypeOfTransport <> Перечисления.TypesOfTransport.CallOut Тогда
			
			//нужно пометить на удаление Утверждение
			ApprovalОбъект = ВыборкаTripsApproval.Ссылка.ПолучитьОбъект();
			Если Не ApprovalОбъект.ПометкаУдаления Тогда 
				ApprovalОбъект.УстановитьПометкуУдаления(Истина);
			КонецЕсли;
		
		иначе
			
			Если ВыборкаTripsApproval.Выполнена Тогда  
				
				Возврат ?(ВыборкаTripsApproval.Status = Перечисления.StatusesOfApproval.Approved, 
				Перечисления.TripNonLawsonCompaniesStages.Approved,
				Перечисления.TripNonLawsonCompaniesStages.Rejected)
				
			иначе
				
				Возврат Перечисления.TripNonLawsonCompaniesStages.AwaitingApproval;
				
			КонецЕсли;
			
		КонецЕсли;
	
	ИначеЕсли TripОбъект.Проведен И TripОбъект.TypeOfTransport = Перечисления.TypesOfTransport.CallOut
		И ЗначениеЗаполнено(TripОбъект.ServiceProvider)
		И (ЗначениеЗаполнено(TripОбъект.BaseCostsSum) ИЛИ TripОбъект.ZeroBaseCostsSum) 
		И ЗначениеЗаполнено(TripОбъект.Currency) Тогда
		
		Если TripОбъект.ZeroBaseCostsSum
			ИЛИ TripОбъект.BaseCostsSumSLBUSD > LimitForApproval 
			ИЛИ TripОбъект.TotalAccessorialCostsSum > (TripОбъект.BaseCostsSum / 2) Тогда 
			
			Возврат TripStages.Saved_ApprovalIsRequired;
			
		Иначе 
			
			Возврат TripStages.Saved_ApprovalIsNotRequired;
			
		КонецЕсли;
		
	ИначеЕсли TripОбъект.Проведен Тогда 
		
		Если TripОбъект.TypeOfTransport <> Перечисления.TypesOfTransport.CallOut Тогда
			Возврат TripStages.Saved_ApprovalIsNotRequired;
		КонецЕсли;
		
		Возврат TripStages.Saved_AwaitingServiceProvidersCosts;
		
	Иначе	
		
		Возврат TripStages.Draft;
		
	КонецЕсли;
	
КонецФункции

Функция ОпределитьStage(Trip) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не ЗначениеЗаполнено(Trip) Тогда
		Возврат Перечисления.TripNonLawsonCompaniesStages.Draft;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Trip);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	StagesOfTripsNonLawsonCompanies.Stage
		|ИЗ
		|	РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
		|ГДЕ
		|	StagesOfTripsNonLawsonCompanies.Trip = &Ссылка";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Stage;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции
