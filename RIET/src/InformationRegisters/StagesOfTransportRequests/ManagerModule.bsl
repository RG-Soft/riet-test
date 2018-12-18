
Функция ПолучитьTransportRequestStage(TransportRequest) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	TransportRequestStages = Перечисления.TransportRequestStages;
	
	РеквизитыTransportRequest = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(TransportRequest, "RequestedLocalTime, Проведен, TotalNumOfParcels");
	                      	
	Если РеквизитыTransportRequest.Проведен Тогда 
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("TransportRequest", TransportRequest);
		Запрос.Текст = "ВЫБРАТЬ
		               |	СУММА(ParcelsOfTransportRequestsWithoutShipmentОстатки.NumOfParcelsОстаток) КАК NumOfParcelsОстаток
		               |ИЗ
		               |	РегистрНакопления.ParcelsOfTransportRequestsWithoutShipment.Остатки(, TransportRequest = &TransportRequest) КАК ParcelsOfTransportRequestsWithoutShipmentОстатки
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	МИНИМУМ(TripNonLawsonCompaniesStops.ActualDepartureLocalTime) КАК MinPickUpActualDepartureLocalTime,
		               |	МАКСИМУМ(TripNonLawsonCompaniesStops.ActualDepartureLocalTime) КАК MaxPickUpActualDepartureLocalTime
		               |ИЗ
		               |	Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		               |		ПО TripNonLawsonCompaniesStops.Ссылка = TripNonLawsonCompaniesParcels.Ссылка
		               |			И TripNonLawsonCompaniesStops.Location = TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse
		               |ГДЕ
		               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TransportRequest
		               |	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	МИНИМУМ(TripNonLawsonCompaniesStops.ActualArrivalLocalTime) КАК MinDeliverToActualLocalTime,
		               |	МАКСИМУМ(TripNonLawsonCompaniesStops.ActualDepartureLocalTime) КАК MaxDeliverToActualLocalTime
		               |ИЗ
		               |	Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
		               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		               |		ПО TripNonLawsonCompaniesStops.Ссылка = TripNonLawsonCompaniesParcels.Ссылка
		               |			И TripNonLawsonCompaniesStops.Location = TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo
		               |ГДЕ
		               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TransportRequest
		               |	И TripNonLawsonCompaniesParcels.Ссылка.Проведен";
		
		Результат = Запрос.ВыполнитьПакет();
		
		ВыборкаОстатки = Результат[0].Выбрать();
		ВыборкаОстатки.Следующий();
		
		ВыборкаPickUp = Результат[1].Выбрать();
		ВыборкаPickUp.Следующий();

		ВыборкаDeliverTo = Результат[2].Выбрать();
		ВыборкаDeliverTo.Следующий();
		
		Если ВыборкаОстатки.NumOfParcelsОстаток = 0 Тогда 
			
			// все парсели в проведенных поставках
			
			Если ЗначениеЗаполнено(ВыборкаDeliverTo.MinDeliverToActualLocalTime) Тогда 
				
				Возврат TransportRequestStages.CompletelyDelivered;
				
			иначеЕсли ЗначениеЗаполнено(ВыборкаDeliverTo.MaxDeliverToActualLocalTime) Тогда 
				
				Возврат TransportRequestStages.PartiallyDelivered;
				
			иначеЕсли ЗначениеЗаполнено(ВыборкаPickUp.MinPickUpActualDepartureLocalTime) Тогда 
				
				Возврат TransportRequestStages.CompletelyShipped;

			иначеЕсли ЗначениеЗаполнено(ВыборкаPickUp.MaxPickUpActualDepartureLocalTime) Тогда 
				
				Возврат TransportRequestStages.PartiallyShipped;
				
			Иначе 
				
				Возврат TransportRequestStages.AcceptedBySpecialist;
				
			КонецЕсли;
			
		иначе 
			
			// не все парсели в проведенных поставках
			
			Если ВыборкаОстатки.NumOfParcelsОстаток = РеквизитыTransportRequest.TotalNumOfParcels Тогда 
				
				Возврат TransportRequestStages.AcceptedBySpecialist;
				
			ИначеЕсли ЗначениеЗаполнено(ВыборкаDeliverTo.MaxDeliverToActualLocalTime) Тогда 
				
				Возврат TransportRequestStages.PartiallyDelivered;

			иначеЕсли ЗначениеЗаполнено(ВыборкаPickUp.MaxPickUpActualDepartureLocalTime) Тогда 
				
				Возврат TransportRequestStages.PartiallyShipped;
				
			иначе 
				
				Возврат TransportRequestStages.AcceptedBySpecialist;
								
			КонецЕсли;
			
		КонецЕсли;		
		
	ИначеЕсли ЗначениеЗаполнено(РеквизитыTransportRequest.RequestedLocalTime) Тогда
		
		Возврат TransportRequestStages.Requested;
		
	Иначе	
		
		Возврат TransportRequestStages.Draft;
		
	КонецЕсли;
	
КонецФункции

Функция ОпределитьStage(TransportRequest) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Не ЗначениеЗаполнено(TransportRequest) Тогда
		Возврат Перечисления.TransportRequestStages.Draft;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", TransportRequest);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	StagesOfTransportRequests.Stage
		|ИЗ
		|	РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
		|ГДЕ
		|	StagesOfTransportRequests.TransportRequest = &Ссылка";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Stage;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции