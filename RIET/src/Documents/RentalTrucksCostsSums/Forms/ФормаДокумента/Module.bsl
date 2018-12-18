
/////////////////////////////////////////////////////////////////////////////////////////////////
// СТАНДАРТНЫЕ ОБРАБОТЧИКИ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Период.ДатаНачала 		= Объект.ДатаНачала;
	Период.ДатаОкончания 	= Объект.ДатаОкончания;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	УстановитьЗаголовкиШапки();
	ОпределитьОбщуюСумму();
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ ЭЛЕМЕНТОВ ШАПКИ

&НаКлиенте
Процедура ПериодПриИзменении(Элемент)
	
	Если ДобавитьМесяц(Период.ДатаНачала, 1) - 1 <> Период.ДатаОкончания Тогда
		Объект.ДатаНачала = Дата(1,1,1);
		Объект.ДатаОкончания = Дата(1,1,1);
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не корректно выбран период, необходимо указать целый месяц";
		Сообщение.Сообщить();
	Иначе
		Объект.ДатаНачала = Период.ДатаНачала;
		Объект.ДатаОкончания = Период.ДатаОкончания;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ServiceProviderПриИзменении(Элемент)
	
	УстановитьЗаголовкиШапки();
	
КонецПроцедуры

&НаКлиенте
Процедура ГруппаRentalCostsPagesПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	Если ТекущаяСтраница = Элементы.ГруппаByTrips Тогда
		RentalTrucksПриАктивизацииСтроки(Элементы.RentalTrucks);
	Иначе
		RentalTrucksManualПриАктивизацииСтроки(Элементы.RentalTrucksManual);
	КонецЕсли;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ ТАБЛИЧНЫХ ЧАСТЕЙ


#Область AccessorialCosts 

&НаКлиенте
Процедура AccessorialCostsПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НоваяСтрока Тогда
		ТД.Идентификатор = ИдентификаторТекущейСтроки;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура AccessorialCostsПриИзменении(Элемент)
	
	
	Если ПустаяСтрока(ИдентификаторТекущейСтроки)Тогда
		Возврат;
	КонецЕсли;
	
	// нужно посчитать величину допов и записать в соответствующую строку тч владельца
	Сумма = 0;
	
	СтрокиДопРасходов = Объект.AccessorialCosts.НайтиСтроки(Новый Структура("Идентификатор", ИдентификаторТекущейСтроки));
	
	Для каждого ТекСтрокаДопРасходов из СтрокиДопРасходов Цикл
		
		Сумма = Сумма + ТекСтрокаДопРасходов.Sum;
		
	КонецЦикла;
	
	// посчитали сумму - ставим ее в нужную строку
	Элементы[ИмяТЧ].ТекущиеДанные.AccessorialCosts = Сумма;
	
	
КонецПроцедуры

#КонецОбласти

#Область RentalTrucks 

&НаКлиенте
Процедура ЗаполнитьПоTrip(Команда)
	ЗаполнитьПоTripНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПоTripНаСервере()
		
	Объект.RentalTrucks.Очистить();
	Если НЕ ЗначениеЗаполнено(Объект.ДатаНачала) ИЛИ НЕ ЗначениеЗаполнено(Объект.ДатаОкончания) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Неверно задан период!";
		Сообщение.Сообщить();
	Иначе
		Если Не ЗначениеЗаполнено(Объект.ServiceProvider) Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Не указан 'Service provider'";
			Сообщение.Сообщить();
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.LegalEntity) Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Не указан 'Legal entity'!";
			Сообщение.Сообщить();
		КонецЕсли;
		
		// { RGS AArsentev 18.06.2018 - rental automatic
		Если Объект.RentalAutomatic Тогда
			ЗапросRentalAutomatic = Новый Запрос;
			ЗапросRentalAutomatic.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			                              |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Transport КАК Transport,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider КАК ServiceProvider,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Equipment КАК Equipment,
			                              |	TripNonLawsonCompaniesStops.ActualDepartureLocalTime КАК ActualDepartureLocalTime,
			                              |	TripNonLawsonCompaniesStops.ActualArrivalLocalTime КАК ActualArrivalLocalTime,
			                              |	StagesOfTripsNonLawsonCompanies.Stage КАК Stage,
			                              |	СУММА(ВЫБОР
			                              |			КОГДА TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels = 0
			                              |				ТОГДА 0
			                              |			ИНАЧЕ TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels
			                              |		КОНЕЦ) КАК Weight,
			                              |	TripNonLawsonCompaniesStops.Ссылка.Дата КАК DateTrip,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Segment КАК Segment,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter КАК AU,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.EquipmentNo КАК Vehicle,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.BaseCostsSum КАК BaseCost,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum КАК Cost,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Currency КАК Currency,
			                              |	СУММА(TripNonLawsonCompaniesCosts.Sum) КАК AccessorialCosts,
			                              |	СУММА(TripNonLawsonCompaniesStops.Mileage) КАК Milage
			                              |ИЗ
			                              |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			                              |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
			                              |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops.Ссылка
			                              |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
			                              |		ПО TripNonLawsonCompaniesParcels.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
			                              |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Costs КАК TripNonLawsonCompaniesCosts
			                              |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesCosts.Ссылка
			                              |ГДЕ
			                              |	TripNonLawsonCompaniesStops.ActualArrivalLocalTime МЕЖДУ &Дата1 И &Дата2
			                              |	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
			                              |	И TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport = &TypeOfTransport
			                              |	И TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider = &ServiceProvider
			                              |	И TripNonLawsonCompaniesStops.Type = &Type
			                              |	И StagesOfTripsNonLawsonCompanies.Stage = &Stage
			                              |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
			                              |
			                              |СГРУППИРОВАТЬ ПО
			                              |	TripNonLawsonCompaniesParcels.Ссылка,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest,
			                              |	TripNonLawsonCompaniesStops.ActualDepartureLocalTime,
			                              |	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
			                              |	StagesOfTripsNonLawsonCompanies.Stage,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Transport,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Equipment,
			                              |	TripNonLawsonCompaniesStops.Ссылка.Дата,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Segment,
			                              |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.EquipmentNo,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.BaseCostsSum,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum,
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Currency
			                              |
			                              |УПОРЯДОЧИТЬ ПО
			                              |	TripNonLawsonCompaniesParcels.Ссылка.Дата";
			ЗапросRentalAutomatic.УстановитьПараметр("Дата1", Объект.ДатаНачала);
			ЗапросRentalAutomatic.УстановитьПараметр("Дата2", Объект.ДатаОкончания);
			ЗапросRentalAutomatic.УстановитьПараметр("TypeOfTransport", Перечисления.TypesOfTransport.RentalAutomatic);
			ЗапросRentalAutomatic.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
			ЗапросRentalAutomatic.УстановитьПараметр("LegalEntity", Объект.LegalEntity);
			ЗапросRentalAutomatic.УстановитьПараметр("Type", Перечисления.StopsTypes.Destination);
			ЗапросRentalAutomatic.УстановитьПараметр("Stage", Перечисления.TripNonLawsonCompaniesStages.Closed);
			
			РезультатЗапросRentalAutomatic = ЗапросRentalAutomatic.Выполнить().Выгрузить();
			
			Объект.RentalTrucks.Загрузить(РезультатЗапросRentalAutomatic);
			
		Иначе
		
		
		//Получим список Трипов / Заявок по поставщику с пробегом и временем
		ЗапросПробегИВремя = Новый Запрос;
		ЗапросПробегИВремя.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport КАК Transport,
		|	TripNonLawsonCompaniesStops.Mileage КАК Milage,
		|	TripNonLawsonCompaniesParcels.Ссылка.TotalActualDuration / 3600 КАК TotalActualDuration,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider КАК ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка.Equipment КАК Equipment,
		|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime КАК ActualDepartureLocalTime,
		|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
		|	StagesOfTripsNonLawsonCompanies.Stage,
		|	СУММА(ВЫБОР
		|			КОГДА TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels = 0
		|				ТОГДА 0
		|			ИНАЧЕ TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels
		|		КОНЕЦ) КАК GrossWeightKG
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
		|		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
		|		ПО TripNonLawsonCompaniesParcels.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
		|ГДЕ
		|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime МЕЖДУ &Дата1 И &Дата2
		|	И TripNonLawsonCompaniesParcels.Ссылка.Проведен
		|	И TripNonLawsonCompaniesParcels.Ссылка.TypeOfTransport = &TypeOfTransport
		|	И TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider = &ServiceProvider
		|	И TripNonLawsonCompaniesStops.Type = &Type
		|	И StagesOfTripsNonLawsonCompanies.Stage = &Stage
		|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
		|
		|СГРУППИРОВАТЬ ПО
		|	TripNonLawsonCompaniesParcels.Ссылка,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest,
		|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime,
		|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
		|	StagesOfTripsNonLawsonCompanies.Stage,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport,
		|	TripNonLawsonCompaniesStops.Mileage,
		|	TripNonLawsonCompaniesParcels.Ссылка.TotalActualDuration / 3600,
		|	TripNonLawsonCompaniesParcels.Ссылка.Transport.ServiceProvider,
		|	TripNonLawsonCompaniesParcels.Ссылка.Equipment
		|
		|УПОРЯДОЧИТЬ ПО
		|	TripNonLawsonCompaniesParcels.Ссылка.Дата";
		
		ЗапросПробегИВремя.УстановитьПараметр("Дата1", Объект.ДатаНачала);
		ЗапросПробегИВремя.УстановитьПараметр("Дата2", Объект.ДатаОкончания);
		ЗапросПробегИВремя.УстановитьПараметр("TypeOfTransport", Перечисления.TypesOfTransport.Rental);
		ЗапросПробегИВремя.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросПробегИВремя.УстановитьПараметр("LegalEntity", Объект.LegalEntity);
		ЗапросПробегИВремя.УстановитьПараметр("Type", Перечисления.StopsTypes.Destination);
		ЗапросПробегИВремя.УстановитьПараметр("Stage", Перечисления.TripNonLawsonCompaniesStages.Closed);
		РезультатПробегИВремя = ЗапросПробегИВремя.Выполнить().Выгрузить();
		
		//Свернем по поставщику
		РезультатПробегИВремяПоПоставщикам_Машинам = РезультатПробегИВремя.Скопировать();
		РезультатПробегИВремяПоПоставщикам_Машинам.Свернуть("ServiceProvider, Transport", "TotalActualDuration, Milage");	
		
		//Свернем по транспорту
		РезультатОбщийВесПоТС = РезультатПробегИВремя.Скопировать();
		РезультатОбщийВесПоТС.Свернуть("Transport", "GrossWeightKG");	
		
		Трипы = РезультатПробегИВремя.Скопировать();
		//{ RGS AArsentev 21.03.2017 S-I-0002462
		//Трипы.Свернуть("Trip");	
		Трипы.Свернуть("Trip, Transport");	
		//} RGS AArsentev 21.03.2017 S-I-0002462
		
		//Получим BaseCost для Транспортных средств
		РезультатBaseCost = ПолучитьBaseCosts(Объект.Дата);	
		
		//заполним Табличную часть документа
		i = 0;
		Объект.RentalTrucks.Очистить();
		МассивОшибок = Новый Массив;
		Для Каждого Элемент из Трипы Цикл
			
			Отбор  = новый Структура;
			Отбор.Вставить("Trip", Элемент.Trip);
			РезультатПробегИВремяПоТрипам = РезультатПробегИВремя.Скопировать(Отбор);
			//{ RGS AArsentev 21.03.2017 S-I-0002462
			МаксимальныйИндекс = 0;
			ЭтоМаксимум = Ложь;
			ид = 0;
			Для Каждого ПоискМаксимальногоИндекса ИЗ Трипы Цикл
				Если МаксимальныйИндекс < ид И Элемент.Transport = ПоискМаксимальногоИндекса.Transport Тогда
					МаксимальныйИндекс = ид;
				КонецЕсли;
				ид = ид + 1;
			КонецЦикла;
			Если i = МаксимальныйИндекс Тогда
				ЭтоМаксимум = Истина;
			КонецЕсли;
			//} RGS AArsentev 21.03.2017 S-I-0002462
			н = 0;
			Для каждого Строка из  РезультатПробегИВремяПоТрипам Цикл
				//{ RGS AArsentev 21.03.2017 S-I-0002462
				н = н + 1;
				ПроверитьКопейки = Ложь;
				КолВо = РезультатПробегИВремяПоТрипам.Количество();
				Если н = КолВо и ЭтоМаксимум Тогда
					ПроверитьКопейки = Истина;
				КонецЕсли;
				//} RGS AArsentev 21.03.2017 S-I-0002462
				СтрокаТЧ = Объект.RentalTrucks.Добавить();
				СтрокаТЧ.DateTrip 			= Строка.Trip.Дата;
				СтрокаТЧ.TransportRequest 	= Строка.TransportRequest;
				СтрокаТЧ.Trip 				= Строка.Trip;
				СтрокаТЧ.LegalEntity 		= Строка.TransportRequest.LegalEntity;
				СтрокаТЧ.Segment 			= Строка.TransportRequest.CostCenter.Segment;
				СтрокаТЧ.AU 				= Строка.TransportRequest.CostCenter;
				СтрокаТЧ.Vehicle 			= Строка.Trip.EquipmentNo;  				
				СтрокаТЧ.Weight 			= ПосчитатьВесПоЗаявке(Строка); // Посчитаем общий вес по заявке
				//{ RGS AArsentev 21.03.2017 S-I-0002462
				СтрокаТЧ.Transport 			= Строка.Trip.Transport;
				//} RGS AArsentev 21.03.2017 S-I-0002462
				TotalWeight = РезультатОбщийВесПоТС.Найти(Строка.Trip.Transport, "Transport").GrossWeightKG;
				
				Сумма = ПосчитатьСумму(Строка, СтрокаТЧ, TotalWeight, РезультатПробегИВремяПоПоставщикам_Машинам, Трипы, РезультатПробегИВремяПоТрипам, МассивОшибок); //определим сумму затрат
				
				Если Сумма <> "" Тогда
					СтрокаТЧ.Currency 	= Сумма[0];
					СтрокаТЧ.Cost 		= Сумма[1];
					//{ RGS AArsentev 21.03.2017 S-I-0002462
					Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType") = Перечисления.RentalTrucksCostsTypes.Milage Тогда
						СуммаМесячныхЗатрат = Сумма[2];
					Иначе
						СуммаМесячныхЗатрат = 0;
					КонецЕсли;
				Иначе
					СуммаМесячныхЗатрат = 0;
				//} RGS AArsentev 21.03.2017 S-I-0002462
				КонецЕсли;
				
				СтрокаТЧ.Milage = Строка.Milage;
				BaseCost = ПосчитатьBaseCost(РезультатBaseCost, Строка.Trip.Transport); //получим BaseCost по Transport указанный в Trip
				Если BaseCost <> 0 Тогда
					СтрокаТЧ.BaseCost = BaseCost.MonthlyRate;
					СтрокаТЧ.BaseCostCurrency = BaseCost.Currency;
				КонецЕсли;
				//{ RGS AArsentev 21.03.2017 S-I-0002462
				Если ПроверитьКопейки И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType") = Перечисления.RentalTrucksCostsTypes.Milage И СуммаМесячныхЗатрат <> 0 Тогда
					Отбор = Новый Структура;
					Отбор.Вставить("Transport", СтрокаТЧ.Transport);
					ЗаполненныеСтроки = Объект.RentalTrucks.НайтиСтроки(Отбор);
					РаспределеннаяСумма = 0;
					КоличествоДнейПоТС = 0;
					Для Каждого Элемент ИЗ ЗаполненныеСтроки Цикл
						РаспределеннаяСумма = РаспределеннаяСумма + Элемент.Cost;
					КонецЦикла;
					
					Если (СуммаМесячныхЗатрат - РаспределеннаяСумма) <> 0 Тогда
						СтрокаТЧ.Cost = СтрокаТЧ.Cost - (РаспределеннаяСумма - СуммаМесячныхЗатрат);
					КонецЕсли;
					//} RGS AArsentev 21.03.2017 S-I-0002462
				КонецЕсли;
			КонецЦикла;
			//{ RGS AArsentev 21.03.2017 S-I-0002462
			i = i + 1;
			//} RGS AArsentev 21.03.2017 S-I-0002462
		КонецЦикла;
		// { RGS AArsentev 11.04.2017 S-I-0002850
		КолВоКалендарныхДней = День(КонецМесяца(Период.ДатаОкончания));
		КоличествоДнейПоТрипам = Объект.RentalTrucks.Выгрузить();
		КоличествоДнейПоТрипам.Свернуть("Transport", "ОтработаноДней");
		RentalTrucksCostsType = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType");
		Для Каждого Авто из КоличествоДнейПоТрипам Цикл
			Отбор = Новый Структура;
			Отбор.Вставить("Transport", Авто.Transport);
			ЗаполненныеСтрокиТЧ = Объект.RentalTrucks.НайтиСтроки(Отбор);
			Если Авто.ОтработаноДней > КолВоКалендарныхДней Тогда
				МассивОшибок.Добавить("По ТС - " + Авто.Transport + " количество отработанных дней " + Авто.ОтработаноДней + " превышает количество календарных дней в месяце " + КолВоКалендарныхДней);
			КонецЕсли;
			Для Каждого СтрокаТранспорт ИЗ ЗаполненныеСтрокиТЧ Цикл
				СтрокаТранспорт.ОбщееЧислоДнейИспользования = Авто.ОтработаноДней;
				Если RentalTrucksCostsType = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost ИЛИ RentalTrucksCostsType = Перечисления.RentalTrucksCostsTypes.Milage Тогда
					СтрокаТранспорт.Cost = СтрокаТранспорт.Cost * (Авто.ОтработаноДней / КолВоКалендарныхДней);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
		// } RGS AArsentev 11.04.2017 S-I-0002850
		Если МассивОшибок.Количество() > 0 Тогда
			Ошибки = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивОшибок, Символы.ПС);
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = Ошибки;
			Сообщение.Сообщить();
		КонецЕсли;
		ОпределитьОбщуюСумму();
	КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksПриАктивизацииСтроки(Элемент)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		ИдентификаторТекущейСтроки = "";
		Элементы.AccessorialCosts.Доступность 	= Ложь;
		УстановитьОтборДляДопРасходов();
		Возврат;
	КонецЕсли;
	
	ИмяТЧ 										= Элемент.Имя;
	
	// для старых доков
	Если ПустаяСтрока(ТД.Идентификатор) Тогда
		ТД.Идентификатор = Строка(Новый УникальныйИдентификатор);
	КонецЕсли;
	
	ИдентификаторТекущейСтроки 					= ТД.Идентификатор;
	Элементы.AccessorialCosts.Доступность 		= Истина;	
	УстановитьОтборДляДопРасходов();
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НоваяСтрока Тогда
		ТД.Идентификатор 			= Строка(Новый УникальныйИдентификатор);
		ИдентификаторТекущейСтроки 	= ТД.Идентификатор;
		УстановитьОтборДляДопРасходов();
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksПередУдалением(Элемент, Отказ)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторТекущейСтрокиУдаление = ТД.Идентификатор;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksПослеУдаления(Элемент)
	
	Если ПустаяСтрока(ИдентификаторТекущейСтрокиУдаление) Тогда
		Возврат;
	КонецЕсли;
	
	СтрокиДляУдаления = Объект.AccessorialCosts.НайтиСтроки(Новый Структура("Идентификатор", ИдентификаторТекущейСтрокиУдаление));
	Для каждого ТекСтрокаНаУдаление из СтрокиДляУдаления Цикл
		
		Объект.AccessorialCosts.Удалить(ТекСтрокаНаУдаление);
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область RentalTrucksManual 

&НаКлиенте
Процедура RentalTrucksManualПриАктивизацииСтроки(Элемент)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		ИдентификаторТекущейСтроки = "";
		Элементы.AccessorialCosts.Доступность = Ложь;
		УстановитьОтборДляДопРасходов();
		Возврат;
	КонецЕсли;
	
	ИмяТЧ 									= Элемент.Имя;
	
	// для старых доков
	Если ПустаяСтрока(ТД.Идентификатор) Тогда
		ТД.Идентификатор = Строка(Новый УникальныйИдентификатор);
	КонецЕсли;

	ИдентификаторТекущейСтроки 				= ТД.Идентификатор;
	Элементы.AccessorialCosts.Доступность 	= Истина;	
	УстановитьОтборДляДопРасходов();
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НоваяСтрока Тогда
		ТД.Идентификатор 			= Строка(Новый УникальныйИдентификатор);
		ИдентификаторТекущейСтроки 	= ТД.Идентификатор;
		УстановитьОтборДляДопРасходов();
		
		Если Не Копирование Тогда 
			Элемент.ТекущиеДанные.NumOfTrips = 1;
			Элемент.ТекущиеДанные.BaseCostPercent = 100;
		КонецЕсли;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualПередУдалением(Элемент, Отказ)
	
	ТД = Элемент.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторТекущейСтрокиУдаление = ТД.Идентификатор;

	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualПослеУдаления(Элемент)
	
	Если ПустаяСтрока(ИдентификаторТекущейСтрокиУдаление) Тогда
		Возврат;
	КонецЕсли;
	
	СтрокиДляУдаления = Объект.AccessorialCosts.НайтиСтроки(Новый Структура("Идентификатор", ИдентификаторТекущейСтрокиУдаление));
	Для каждого ТекСтрокаНаУдаление из СтрокиДляУдаления Цикл
		
		Объект.AccessorialCosts.Удалить(ТекСтрокаНаУдаление);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualTransportПриИзменении(Элемент)
	
	ТД = Элементы.RentalTrucksManual.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТС = ТД.Transport;
	
	Если ЗначениеЗаполнено(ТС) Тогда
		
		Результат = ОбщегоНазначения.ПолучитьЗначенияРеквизитов(ТД.Transport, "Код, Equipment, Site, Geomarket");
		
		ТД.Vehicle	 = Результат.Код;
		ТД.Equipment = Результат.Equipment;
		ТД.Geomarket = Результат.Geomarket;
		Если НЕ ЗначениеЗаполнено(ТД.LocationFrom) Тогда
			ТД.LocationFrom = Результат.Site;
		КонецЕсли;
		
		// получим базовую стоимость и валюту
		ЗаполнитьЗначенияСвойств(ТД, ПолучитьBaseCosts(Объект.Дата, ТД.Transport), "BaseCost, BaseCostCurrency");
		
	Иначе
		
		ТД.Vehicle	 			= "";
		ТД.Equipment 			= "";
		ТД.Geomarket 			= "";
		ТД.BaseCost	 			= "";
		ТД.BaseCostCurrency	 	= "";
		
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура Рассчитать(Команда)
	РассчитатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура РассчитатьНаСервере()
	
	// по умолчанию считаем, что в дне 16 часов рабочих для машины
	КоличествоЧасовВДнеПоУмолчанию = 16;
		
	ВидТарифа 	= Объект.ServiceProvider.RentalTrucksCostsType;
	СЗагрузкой 	= Объект.ServiceProvider.WithLoading; 
	Для каждого ТекСтрокаРучногоРасчета из Объект.RentalTrucksManual Цикл
		//{ RGS AArsentev 21.03.2017 S-I-0002462
		ТекСтрокаРучногоРасчета.Cost = 0;
		//} RGS AArsentev 21.03.2017 S-I-0002462
		Cost 			= 0;
		Weight 			= ТекСтрокаРучногоРасчета.Weight;
		EffectiveWeight = ТекСтрокаРучногоРасчета.Equipment.EffectiveWeight * ?(ТекСтрокаРучногоРасчета.NumOfTrips=0,1,ТекСтрокаРучногоРасчета.NumOfTrips);  //Эффективная загрузка, кг.
		
		Если Weight > EffectiveWeight Тогда 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("In line " + СокрЛП(ТекСтрокаРучногоРасчета.НомерСтроки) 
			+ " total weight exceeds effective weight of equipment * num of trips = " + СокрЛП(EffectiveWeight) + "!",
			,"RentalTrucksManual[" + (ТекСтрокаРучногоРасчета.НомерСтроки-1) + "].Weight", "Объект");
		КонецЕсли;
		
		СтруктураПараметров = Новый Структура;
		
		// выберем все строки из таблицы по данному ТС
		Отбор = Новый Структура("Transport, Vehicle, Equipment");
		ЗаполнитьЗначенияСвойств(Отбор, ТекСтрокаРучногоРасчета);
					
		СтрокиПоиска = Объект.RentalTrucksManual.НайтиСтроки(Отбор);		
		TotalMilage = 0;
		//{ RGS AArsentev 21.03.2017 S-I-0002462
		TotalWeight = 0;
		МаксимальнаяСтрока = 0;
		//} RGS AArsentev 21.03.2017 S-I-0002462
		Для каждого ТекСтрокаПоиска из СтрокиПоиска Цикл
			TotalMilage = TotalMilage + ТекСтрокаПоиска.Milage;
			//{ RGS AArsentev 21.03.2017 S-I-0002462
			TotalWeight = TotalWeight + ТекСтрокаПоиска.Weight;
			Если МаксимальнаяСтрока < ТекСтрокаПоиска.НомерСтроки Тогда
				МаксимальнаяСтрока = ТекСтрокаПоиска.НомерСтроки;
			КонецЕсли;
			//} RGS AArsentev 21.03.2017 S-I-0002462
		КонецЦикла;	
			
		СтруктураПараметров.Вставить("Milage", 			TotalMilage);	
		СтруктураПараметров.Вставить("Hours_a_day", 	ТекСтрокаРучногоРасчета.Hours_a_day);
		СтруктураПараметров.Вставить("Дата", 			Объект.Дата);
		СтруктураПараметров.Вставить("Equipment", 		ТекСтрокаРучногоРасчета.Equipment);
		СтруктураПараметров.Вставить("Transport", 		ТекСтрокаРучногоРасчета.Transport);
		
		Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours
			или ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда
			
			Тариф = ОпределитьТарифВремяПробег(, , СтруктураПараметров);
			
			Если Тариф = "" Тогда
				Тариф = ОпределитьТарифПробег(, , СтруктураПараметров);		
			КонецЕсли;
			
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.Milage Тогда
			
			Тариф = ОпределитьТарифПробег(, , СтруктураПараметров);	
			     					
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerDay 
			или ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerHour Тогда
			
			Тариф = ОпределитьТарифВремяДни(, , СтруктураПараметров)
			
		// { RGS AArsentev 11.04.2017 S-I-0002850
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost Тогда
			Тариф = ПолучитьТарифBaseCosts(Объект.Дата, ТекСтрокаРучногоРасчета.Transport);
		// } RGS AArsentev 11.04.2017 S-I-0002850
		КонецЕсли;
		
		Если Тариф = "" Тогда
			Продолжить;
		КонецЕсли;
		
		ТекСтрокаРучногоРасчета.Currency = Тариф.Currency;

		Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours
			или ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда
			                              						
			Duration = ТекСтрокаРучногоРасчета.Duration;
			
			Если Duration - Цел(Duration) > 0 Тогда 
				Duration = Цел(Duration) + 1;
			КонецЕсли;
			
			СontractMonthlyCost = Тариф.Cost; //месячная сумма затрат
			
			//Отбор = Новый Структура("Transport, Vehicle, Equipment");
			//ЗаполнитьЗначенияСвойств(Отбор, ТекСтрокаРучногоРасчета);			
			//СтрокиПоиска = Объект.RentalTrucksManual.НайтиСтроки(Отбор);		
						
			Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда
				Cost = (?(СЗагрузкой, (Weight / EffectiveWeight), 1) * Duration) * СontractMonthlyCost/30;
			Иначе				
				Cost = (?(СЗагрузкой, (Weight / EffectiveWeight), 1) * Duration) * СontractMonthlyCost/720;
			КонецЕсли;
			
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.Milage
			// { RGS AArsentev 11.04.2017 S-I-0002850
			ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost Тогда
			// } RGS AArsentev 11.04.2017 S-I-0002850Тогда
			
			СontractMonthlyCost = Тариф.Cost; //месячная сумма затрат
			
			Milage = ТекСтрокаРучногоРасчета.Milage;
			
			//{ RGS AArsentev 21.03.2017 S-I-0002462
			//Cost = СontractMonthlyCost * Milage / TotalMilage;
			Если СЗагрузкой Тогда
				Cost = Окр(?(TotalWeight = 0, 0, СontractMonthlyCost * Weight / TotalWeight),2);
			Иначе
				Cost = Окр(?(TotalMilage = 0, 0, СontractMonthlyCost * Milage / TotalMilage),2);
			КонецЕсли;
			
			Если МаксимальнаяСтрока = ТекСтрокаРучногоРасчета.НомерСтроки Тогда
				Отбор = Новый Структура("Transport, Vehicle, Equipment");
				ЗаполнитьЗначенияСвойств(Отбор, ТекСтрокаРучногоРасчета);
				ЗаполненныеСтроки = Объект.RentalTrucksManual.НайтиСтроки(Отбор);
				РаспределеннаяСумма = 0;
				Для Каждого Элемент ИЗ ЗаполненныеСтроки Цикл
					РаспределеннаяСумма = РаспределеннаяСумма + Элемент.Cost;
				КонецЦикла;
				РаспределеннаяСумма = РаспределеннаяСумма + Cost;
				Если (СontractMonthlyCost - РаспределеннаяСумма) <> 0 Тогда
					Cost = Cost - (РаспределеннаяСумма - СontractMonthlyCost);
				КонецЕсли;
			КонецЕсли;
			//} RGS AArsentev 21.03.2017 S-I-0002462
			
			//Если СЗагрузкой Тогда
			//	Cost = Cost * (Weight / EffectiveWeight);	
			//КонецЕсли;      
			
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerDay Тогда
			
			Days = ТекСтрокаРучногоРасчета.Duration;
			Cost = Тариф.CostPerDay * Days;
						
			// выберем все строки из таблицы по данному ТС
			Отбор = Новый Структура("Transport, Vehicle, Equipment");
			ЗаполнитьЗначенияСвойств(Отбор, ТекСтрокаРучногоРасчета);
						
			СтрокиПоиска = Объект.RentalTrucksManual.НайтиСтроки(Отбор);		
			TotalDurations = 0;
			Для каждого ТекСтрокаПоиска из СтрокиПоиска Цикл
				TotalDurations = TotalDurations + ТекСтрокаПоиска.Duration;
			КонецЦикла;			
			
			Cost = Cost * Days / TotalDurations;
			
			Если СЗагрузкой Тогда
				Cost = Cost * (Weight / EffectiveWeight);	
			КонецЕсли;
			
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerHour Тогда
			
			Hours = ТекСтрокаРучногоРасчета.Duration;			
			Если Hours - Цел(Hours) > 0 Тогда 
				Hours = Цел(Hours) + 1;
			КонецЕсли;
			Cost = Тариф.CostPerHour * Hours;
			Если СЗагрузкой Тогда
				Cost = Cost * (Weight / EffectiveWeight);	
			КонецЕсли;
			
		КонецЕсли;
		
		ТекСтрокаРучногоРасчета.CostBeforePercentApplying = Cost;
		ТекСтрокаРучногоРасчета.Cost					  = Cost * ?(ТекСтрокаРучногоРасчета.BaseCostPercent = 0, 100, ТекСтрокаРучногоРасчета.BaseCostPercent) / 100;
		
	КонецЦикла;
	
	// { RGS AArsentev 11.04.2017 S-I-0002850
	КолВоКалендарныхДней = День(КонецМесяца(Период.ДатаОкончания));
	КоличествоДнейПоТрипам = Объект.RentalTrucksManual.Выгрузить();
	КоличествоДнейПоТрипам.Свернуть("Transport", "ОтработаноДней");
	RentalTrucksCostsType = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType");
	Для Каждого Авто из КоличествоДнейПоТрипам Цикл
		Отбор = Новый Структура;
		Отбор.Вставить("Transport", Авто.Transport);
		ЗаполненныеСтрокиТЧ = Объект.RentalTrucksManual.НайтиСтроки(Отбор);
		Если Авто.ОтработаноДней > КолВоКалендарныхДней Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "По ТС - " + Авто.Transport + " количество отработанных дней " + Авто.ОтработаноДней + " превышает количество календарных дней в месяце " + КолВоКалендарныхДней;
			Сообщение.Сообщить();
		КонецЕсли;
		Для Каждого СтрокаТранспорт ИЗ ЗаполненныеСтрокиТЧ Цикл
			СтрокаТранспорт.ОбщееЧислоДнейИспользования = Авто.ОтработаноДней;
			Если RentalTrucksCostsType = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost ИЛИ RentalTrucksCostsType = Перечисления.RentalTrucksCostsTypes.Milage Тогда
				СтрокаТранспорт.Cost = СтрокаТранспорт.Cost * (Авто.ОтработаноДней / КолВоКалендарныхДней);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	// } RGS AArsentev 11.04.2017 S-I-0002850
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualBaseCostPercentПриИзменении(Элемент)
	
	ТД = Элементы.RentalTrucksManual.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТД.Cost = ТД.CostBeforePercentApplying * ТД.BaseCostPercent / 100;
	
КонецПроцедуры
	
&НаКлиенте
Процедура RentalTrucksManualCostПриИзменении(Элемент)
	
	ТД = Элементы.RentalTrucksManual.ТекущиеДанные;
	Если ТД = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТД.CostBeforePercentApplying = ТД.Cost;
	
	ПересчитатьПроценты(ТД.Vehicle, ТД.Equipment);
	
КонецПроцедуры	

&НаКлиенте
Процедура ПересчитатьПроценты(Vehicle, Equipment)
	
	СтруктураПоиска = Новый Структура("Vehicle, Equipment", Vehicle, Equipment);
	
	СтрокиПоиска = Объект.RentalTrucksManual.НайтиСтроки(СтруктураПоиска);
	
	ОбщаяСумма = 0;
	Для каждого ТекСтрокаПоиска из СтрокиПоиска Цикл
		
		ОбщаяСумма = ОбщаяСумма + ТекСтрокаПоиска.CostBeforePercentApplying;
		
	КонецЦикла;
	
	Для каждого ТекСтрокаПоиска из СтрокиПоиска Цикл
		
		ТекСтрокаПоиска.BaseCostPercent = ?(ОбщаяСумма = 0, 0, ТекСтрокаПоиска.CostBeforePercentApplying / ОбщаяСумма * 100);
		
	КонецЦикла;
	
КонецПроцедуры
	
#КонецОбласти

/////////////////////////////////////////////////////////
/// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаКлиенте
Процедура УстановитьОтборДляДопРасходов()
	
	Элементы.AccessorialCosts.ОтборСтрок = Новый ФиксированнаяСтруктура(Новый Структура("Идентификатор", ИдентификаторТекущейСтроки));	
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЗаголовкиШапки()
	
	Если Не ЗначениеЗаполнено(Объект.ServiceProvider) Тогда
		Возврат;
	КонецЕсли;
	
	SPWithLoading = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "WithLoading");
	Элементы.WithLoading.Видимость = SPWithLoading;
	Элементы.WithoutLoading.Видимость = Не SPWithLoading;
		
	ТипРасчета = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType");
	
	Если ТипРасчета = ПредопределенноеЗначение("Перечисление.RentalTrucksCostsTypes.MilageDays") или 
		ТипРасчета = ПредопределенноеЗначение("Перечисление.RentalTrucksCostsTypes.PerDay") Тогда
		
		Элементы.RentalTrucksManualDuration.Заголовок = НСтр("ru = 'Длительность, дней'; en = 'Duration, days'");
		
	Иначе
		
		Элементы.RentalTrucksManualDuration.Заголовок = НСтр("ru = 'Длительность, часов'; en = 'Duration, hours'");
		
	КонецЕсли;
	
	Элементы.RentalTrucksManualHours_a_day.Видимость = (ТипРасчета = ПредопределенноеЗначение("Перечисление.RentalTrucksCostsTypes.MilageHours"));
	              	
КонецПроцедуры

/////////////////////////////////////////////////////////
/// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ РАСЧЕТОВ

&НаСервереБезКонтекста
Функция ПолучитьBaseCosts(ДатаЗапроса, Транспорт = Неопределено) 
	
	ЗапросBaseCost = Новый Запрос;
	ЗапросBaseCost.Текст = 
	"ВЫБРАТЬ
	|	TransportMonthlyRateСрезПоследних.Transport,
	|	TransportMonthlyRateСрезПоследних.MonthlyRate,
	|	TransportMonthlyRateСрезПоследних.Currency
	|ИЗ
	|	РегистрСведений.TransportMonthlyRate.СрезПоследних(
	|			&Дата,
	|			ВЫБОР
	|				КОГДА &Transport = НЕОПРЕДЕЛЕНО
	|					ТОГДА ИСТИНА
	|				ИНАЧЕ Transport = &Transport
	|			КОНЕЦ) КАК TransportMonthlyRateСрезПоследних
	|
	|УПОРЯДОЧИТЬ ПО
	|	TransportMonthlyRateСрезПоследних.Период УБЫВ";
	ЗапросBaseCost.УстановитьПараметр("Дата",		ДатаЗапроса);
	ЗапросBaseCost.УстановитьПараметр("Transport", 	Транспорт);
	
	Результат = ЗапросBaseCost.Выполнить().Выгрузить();
	
	Если ЗначениеЗаполнено(Транспорт) Тогда
		
		Ответ = Новый Структура("BaseCost, BaseCostCurrency", "", "");
		
		Если Результат.Количество() > 0 Тогда
			Ответ.BaseCost 			= Результат[0].MonthlyRate;
			Ответ.BaseCostCurrency 	= Результат[0].Currency;
		КонецЕсли;
		
		Возврат Ответ;
	Иначе
		Возврат Результат;	
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ПосчитатьСумму(Строка, СтрокаТЧ_Rental, TotalWeight, ПробегИВремя, Трипы, РезультатПробегИВремяПоТрипам, МассивОшибок)
	
	Тариф = "";
	ВидТарифа 	= Объект.ServiceProvider.RentalTrucksCostsType;
	СЗагрузкой 	= Объект.ServiceProvider.WithLoading; 
	
	// по умолчанию считаем, что в дне 16 часов рабочих для машины
	КоличествоЧасовВДнеПоУмолчанию = 16;
	
	Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours
		ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда
		Тариф = ОпределитьТарифВремяПробег(ПробегИВремя, Строка.Trip);
		Если Тариф = "" Тогда
			Тариф = ОпределитьТарифПробег(ПробегИВремя, Строка.Trip);		
		КонецЕсли;
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.Milage Тогда
		Тариф = ОпределитьТарифПробег(ПробегИВремя, Строка.Trip);			
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerDay 
		ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerHour Тогда
		Тариф = ОпределитьТарифВремяДни(ПробегИВремя, Строка.Trip);
	// { RGS AArsentev 11.04.2017 S-I-0002850
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost Тогда
		Тариф = ПолучитьТарифBaseCosts(Объект.Дата, Строка.Transport);
	// } RGS AArsentev 11.04.2017 S-I-0002850
	КонецЕсли;
	
	Если Тариф = "" Тогда
		//{ RGS AArsentev 23.03.2017 - расширил собщения об ошибках
		//Message = New UserMessage();
		//Message.Text = "Для транспортного средства " + СокрЛП(Строка.Transport) + " нет тарифов на аренду";
		//Message.Message();
		//Возврат "";
		
		Если НЕ ПробегИВремя.Количество() = 0 Тогда
			Milage = ПробегИВремя[0].Milage;
			Hours_a_day = ПробегИВремя[0].TotalActualDuration /  720;
			ServiceProvider =  Объект.ServiceProvider;
			Equipment = СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.Trip, "Equipment"));
			Transport = СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Строка.Trip, "Transport"));
		КонецЕсли;
		
		Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда
			Text = "Для Service provider - " + ServiceProvider + ", по текущим данным: 
			|Milage - " + Milage + "
			|Hours a day - " + Hours_a_day + "
			|ServiceProvider - " + Equipment + "
			|Transport - " + Transport + "
			|тарифа не найдено";
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.Milage Тогда
			Text = "Для Service provider - " + ServiceProvider + ", по текущим данным: 
			|Milage - " + Milage + "
			|ServiceProvider - " + Equipment + "
			|Transport - " + Transport + "
			|тарифа не найдено";
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerDay ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerHour Тогда
			Text = "Для Service provider - " + ServiceProvider + ", по текущим данным: 
			|ServiceProvider - " + Equipment + "
			|Transport - " + Transport + "
			|тарифа не найдено";
		// { RGS AArsentev 11.04.2017 S-I-0002850
		ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost Тогда
			Text = "Для Service provider - " + ServiceProvider + ", по текущим данным: 
			|ServiceProvider - " + Equipment + "
			|Transport - " + Transport + "
			|тарифа не найдено";
		// } RGS AArsentev 11.04.2017 S-I-0002850
		КонецЕсли;
		МассивОшибок.Добавить(Text);
		//} RGS AArsentev 23.03.2017
		Возврат "";
		
	КонецЕсли;
	
	МассивСумм = Новый Массив;
	МассивСумм.Добавить(Тариф.Currency);
	
	EffectiveWeight = Строка.Trip.Equipment.EffectiveWeight;  //Эффективная загрузка, кг.
	
	// { RGS AArsentev 11.04.2017 S-I-0002850
	СтрокаТЧ_Rental.ОтработаноДней = ОпределитьКоличествоДней(Строка.Trip);
	// } RGS AArsentev 11.04.2017 S-I-0002850
	
	Если ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours 
		ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays Тогда 
		
		DurationTrip = Строка.Trip.TotalActualDuration / ?(ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageHours, 3600, ?(Тариф.Hours_a_day = 0, КоличествоЧасовВДнеПоУмолчанию,  Тариф.Hours_a_day) * 3600); //Затраченное время
		
		Если DurationTrip - Цел(DurationTrip) > 0 Тогда 
			DurationTrip = Цел(DurationTrip) + 1;
		КонецЕсли;
		
		СontractMonthlyCost = Тариф.Cost; //месячная сумма затрат
		
		Отбор = Новый Структура;
		Отбор.Вставить("Transport", Строка.Transport);
		ТаблицаПоМашине = ПробегИВремя.Скопировать(Отбор);		
		
		TotalHoursFromTrips = ТаблицаПоМашине[0].TotalActualDuration; //Затраченное время, часы
		
		TotalDaysFromTrips = ТаблицаПоМашине[0].TotalActualDuration / ?(Тариф.Hours_a_day = 0, КоличествоЧасовВДнеПоУмолчанию,  Тариф.Hours_a_day); //Затраченное время, дни
		
		Если TotalHoursFromTrips - Цел(TotalHoursFromTrips) > 0 Тогда 
			TotalHoursFromTrips = Цел(TotalHoursFromTrips) + 1;
		КонецЕсли;
		
		Если TotalDaysFromTrips - Цел(TotalDaysFromTrips) > 0 Тогда 
			TotalDaysFromTrips = Цел(TotalDaysFromTrips) + 1;
		КонецЕсли;
		
		Divider = ?(ВидТарифа = Перечисления.RentalTrucksCostsTypes.MilageDays, TotalDaysFromTrips, TotalHoursFromTrips); 
		
		Cost = (?(СЗагрузкой, (СтрокаТЧ_Rental.Weight / EffectiveWeight), 1) * DurationTrip) / Divider * СontractMonthlyCost;
		
		МассивСумм.Добавить(Cost);
		Возврат МассивСумм; 
		
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.Milage
		// { RGS AArsentev 11.04.2017 S-I-0002850
		ИЛИ ВидТарифа = Перечисления.RentalTrucksCostsTypes.BaseMonthlyCost Тогда
		// } RGS AArsentev 11.04.2017 S-I-0002850
		СontractMonthlyCost = Тариф.Cost; //месячная сумма затрат
		
		Отбор = Новый Структура;
		Отбор.Вставить("Transport", Строка.Transport);
		ТаблицаПоМашине = ПробегИВремя.Скопировать(Отбор);		
		
		TotalMilageFromTrips = ТаблицаПоМашине[0].Milage; //общий пробег ТС
		
		Cost = ?(TotalMilageFromTrips = 0, 0, СontractMonthlyCost * (Строка.Milage / TotalMilageFromTrips));
		
		//{ RGS AArsentev 21.03.2017 S-I-0002462
		//Если СЗагрузкой Тогда
		//	Cost = Cost * (Weight / TotalWeight);	
		//КонецЕсли;
		Если СЗагрузкой Тогда // расчет в зависимости от коеффициента загрузки ТС
			Cost = ?(TotalWeight = 0, 0, СontractMonthlyCost * (СтрокаТЧ_Rental.Weight / TotalWeight));
		Иначе
			Cost = ?(TotalMilageFromTrips = 0, 0, СontractMonthlyCost * (Строка.Milage / TotalMilageFromTrips));
		КонецЕсли;
		//} RGS AArsentev 21.03.2017 S-I-0002462
		
		МассивСумм.Добавить(Cost);
		МассивСумм.Добавить(СontractMonthlyCost);
		Возврат МассивСумм;
		
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerDay Тогда
		
		Days = ОпределитьКоличествоДней(Строка.Trip);
		Cost = Тариф.CostPerDay * Days;
		Если СЗагрузкой Тогда
			Cost = Cost * (СтрокаТЧ_Rental.Weight / EffectiveWeight); 	
		КонецЕсли;
		//Распределение = ОпределитьКоеффициентРаспределения(Строка, Трипы, РезультатПробегИВремяПоТрипам); //Если у текущего транпортного средства было несколько выездов за день. определим коеффициент распределения на текущую строку
		Распределение = 1;
		Cost = Cost * Распределение;
		МассивСумм.Добавить(Cost);
		Возврат МассивСумм;				
		
	ИначеЕсли ВидТарифа = Перечисления.RentalTrucksCostsTypes.PerHour Тогда
		
		Hours = Строка.Trip.TotalActualDuration / 3600;			
		Если Hours - Цел(Hours) > 0 Тогда 
			Hours = Цел(Hours) + 1;
		КонецЕсли;
		Cost = Тариф.CostPerHour * Hours;
		Если СЗагрузкой Тогда
			Cost = Cost * (СтрокаТЧ_Rental.Weight / EffectiveWeight);	
		КонецЕсли;
		МассивСумм.Добавить(Cost);
		Возврат МассивСумм;
		
	Иначе			
		Message = New UserMessage();
		Message.Text = "Нет формулы для расчета суммы аренды указанной для поставщика " + СокрЛП(Объект.ServiceProvider);
		Message.Message();	
	КонецЕсли;		
	
КонецФункции

&НаСервере
Функция ПосчитатьBaseCost(BaseCost, Transport)
	
	Отбор = новый Структура;
	Отбор.Вставить("Transport", Transport);
	Результат = BaseCost.Скопировать(Отбор);
	Если Результат.Количество() > 0 Тогда
		Возврат Результат[0];
	Иначе
		Возврат 0;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ОпределитьКоличествоДней(Trip)
	
	Стопы = Trip.Stops.Выгрузить();
	ОтборНачальный = Новый Структура;
	ОтборНачальный.Вставить("Type", Перечисления.StopsTypes.Source);
	
	ОтборКонечный = Новый Структура;
	ОтборКонечный.Вставить("Type", Перечисления.StopsTypes.Destination);
	
	НачальныйСтоп = Стопы.Скопировать(ОтборНачальный);
	КонечныйСтоп = Стопы.Скопировать(ОтборКонечный);
	
	ДатаНачала = НачальныйСтоп[0].ActualDepartureLocalTime;
	ДатаОкончания = КонечныйСтоп[0].ActualArrivalLocalTime;
	
	КоличествоДней = Окр((КонецДня(ДатаОкончания) - НачалоДня(ДатаНачала)) / 86400 , 2);
	
	Если КоличествоДней - Цел(КоличествоДней) > 0 Тогда 
		КоличествоДней = Цел(КоличествоДней) + 1;
	КонецЕсли;
	
	Возврат КоличествоДней
	
КонецФункции

&НаСервере
Функция ОпределитьТарифВремяПробег(ТаблицаПоПоставщикамМашинам = Неопределено, Trip = Неопределено, СтруктураПараметров = Неопределено)
		
	ЗапросTrucksCosts = Новый Запрос;
	ЗапросTrucksCosts.Текст = "ВЫБРАТЬ
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
	|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day) КАК Hours_a_day
	|ПОМЕСТИТЬ ВременнаяТаблица
	|ИЗ
	|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	|			&Дата,
	|			Milage >= &Milage
	|				И Hours_a_day >= &Hours_a_day
	|				И ServiceProvider = &ServiceProvider
	|				И Equipment = &Equipment
	|				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	|
	|СГРУППИРОВАТЬ ПО
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage) КАК Milage,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day
	|ПОМЕСТИТЬ ВТMilageHours
	|ИЗ
	|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	|			&Дата,
	|			ServiceProvider = &ServiceProvider
	|				И Hours_a_day В
	|					(ВЫБРАТЬ
	|						ВременнаяТаблица.Hours_a_day
	|					ИЗ
	|						ВременнаяТаблица КАК ВременнаяТаблица)
	|				И Milage >= &Milage
	|				И Equipment = &Equipment
	|				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	|
	|СГРУППИРОВАТЬ ПО
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
	|ИЗ
	|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	|			&Дата,
	|			Milage >= &Milage
	|				И Hours_a_day >= &Hours_a_day
	|				И ServiceProvider = &ServiceProvider
	|				И Equipment = &Equipment
	|				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	|ГДЕ
	|	(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage, ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day) В
	|			(ВЫБРАТЬ
	|				ВТMilageHours.Milage,
	|				ВТMilageHours.Hours_a_day
	|			ИЗ
	|				ВТMilageHours КАК ВТMilageHours)";
	
	Если НЕ ТаблицаПоПоставщикамМашинам = Неопределено Тогда
		
		Отбор = Новый Структура;
		Отбор.Вставить("Transport", Trip.Transport);
		ТаблицаПоМашине = ТаблицаПоПоставщикамМашинам.Скопировать(Отбор);
		
		ЗапросTrucksCosts.УстановитьПараметр("Milage", 			ТаблицаПоМашине[0].Milage);	
		ЗапросTrucksCosts.УстановитьПараметр("Hours_a_day", 	ТаблицаПоМашине[0].TotalActualDuration /  720);
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			Trip.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		Trip.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		Trip.Transport);
		
	Иначе
		
		ЗапросTrucksCosts.УстановитьПараметр("Milage", 			СтруктураПараметров.Milage);	
		ЗапросTrucksCosts.УстановитьПараметр("Hours_a_day", 	СтруктураПараметров.Hours_a_day);
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			СтруктураПараметров.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		СтруктураПараметров.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		СтруктураПараметров.Transport);
		
	КонецЕсли;
	
	РезультатTrucksCosts = ЗапросTrucksCosts.Выполнить();
	СТранспортом = РезультатTrucksCosts.Выгрузить();
	//БезТранспорта = РезультатTrucksCosts[3].Выгрузить();
	Если СТранспортом.Количество() > 0 Тогда
		Возврат СТранспортом[0];
	Иначе
		ЗапросTrucksCosts.Текст = "ВЫБРАТЬ
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
		|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day) КАК Hours_a_day
		|ПОМЕСТИТЬ ВременнаяТаблица
		|ИЗ
		|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
		|			&Дата,
		|			Milage >= &Milage
		|				И Hours_a_day >= &Hours_a_day
		|				И ServiceProvider = &ServiceProvider
		|				И Equipment = &Equipment
		|				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
		|
		|СГРУППИРОВАТЬ ПО
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage) КАК Milage,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day
		|ПОМЕСТИТЬ ВТMilageHours
		|ИЗ
		|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
		|			&Дата,
		|			ServiceProvider = &ServiceProvider
		|				И Hours_a_day В
		|					(ВЫБРАТЬ
		|						ВременнаяТаблица.Hours_a_day
		|					ИЗ
		|						ВременнаяТаблица КАК ВременнаяТаблица)
		|				И Milage >= &Milage
		|				И Equipment = &Equipment
		|				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
		|
		|СГРУППИРОВАТЬ ПО
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
		|ИЗ
		|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
		|			&Дата,
		|			Milage >= &Milage
		|				И Hours_a_day >= &Hours_a_day
		|				И ServiceProvider = &ServiceProvider
		|				И Equipment = &Equipment
		|				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
		|ГДЕ
		|	(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage, ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day) В
		|			(ВЫБРАТЬ
		|				ВТMilageHours.Milage,
		|				ВТMilageHours.Hours_a_day
		|			ИЗ
		|				ВТMilageHours КАК ВТMilageHours)";
		РезультатTrucksCostsБезТранспорта = ЗапросTrucksCosts.Выполнить();
		БезТранспорта = РезультатTrucksCostsБезТранспорта.Выгрузить();
		Если БезТранспорта.Количество() > 0 Тогда
			Возврат БезТранспорта[0];
		Иначе
			Возврат "";
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ОпределитьТарифПробег(ТаблицаПоПоставщикамМашинам = Неопределено, Trip = Неопределено, СтруктураПараметров = Неопределено)
		
	ЗапросTrucksCosts = Новый Запрос;
	ЗапросTrucksCosts.Текст = "ВЫБРАТЬ
	|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage) КАК Milage
	|ПОМЕСТИТЬ ВТMilage
	|ИЗ
	|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	|			&Дата,
	|			ServiceProvider = &ServiceProvider
	|				И Milage >= &Milage
	|				И Equipment = &Equipment
	|				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
	|ИЗ
	|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	|			&Дата,
	|			Milage >= &Milage
	|				И ServiceProvider = &ServiceProvider
	|				И Equipment = &Equipment
	|				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	|ГДЕ
	|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage В
	|			(ВЫБРАТЬ
	|				ВТMilage.Milage
	|			ИЗ
	|				ВТMilage КАК ВТMilage)";
	
	Если НЕ ТаблицаПоПоставщикамМашинам = Неопределено Тогда
		
		Отбор = Новый Структура;
		Отбор.Вставить("Transport", Trip.Transport);
		ТаблицаПоМашине = ТаблицаПоПоставщикамМашинам.Скопировать(Отбор);
		
		ЗапросTrucksCosts.УстановитьПараметр("Milage", 			ТаблицаПоМашине[0].Milage);	
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			Trip.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		Trip.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		Trip.Transport);
		
	Иначе
		
		ЗапросTrucksCosts.УстановитьПараметр("Milage", 			СтруктураПараметров.Milage);	
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			СтруктураПараметров.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		СтруктураПараметров.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		СтруктураПараметров.Transport);
		
	КонецЕсли;
	
	РезультатTrucksCosts = ЗапросTrucksCosts.Выполнить();
	СТранспортом = РезультатTrucksCosts.Выгрузить();
	Если СТранспортом.Количество() > 0 Тогда
		Возврат СТранспортом[0]
	Иначе
		ЗапросTrucksCosts.Текст = "ВЫБРАТЬ
		|	МИНИМУМ(ServiceProvidersRentalTrucksCostsСрезПоследних.Milage) КАК Milage
		|ПОМЕСТИТЬ ВТMilage
		|ИЗ
		|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
		|			&Дата,
		|			ServiceProvider = &ServiceProvider
		|				И Milage >= &Milage
		|				И Equipment = &Equipment
		|				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
		|ИЗ
		|	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
		|			&Дата,
		|			Milage >= &Milage
		|				И ServiceProvider = &ServiceProvider
		|				И Equipment = &Equipment
		|				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
		|ГДЕ
		|	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage В
		|			(ВЫБРАТЬ
		|				ВТMilage.Milage
		|			ИЗ
		|				ВТMilage КАК ВТMilage)";
		БезТранспорта = ЗапросTrucksCosts.Выполнить().Выгрузить();
		Если БезТранспорта.Количество() > 0 Тогда
			Возврат БезТранспорта[0];
		Иначе
			Возврат "";
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ОпределитьКоеффициентРаспределения(СтрокаТрип, Трипы, РезультатПробегИВремяПоТрипам)
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	TripNonLawsonCompaniesStops.Ссылка,
	|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime КАК ActualDepartureLocalTime,
	|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
	|	TripNonLawsonCompaniesStops.Type,
	|	TripNonLawsonCompaniesStops.Ссылка.TotalActualDuration
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
	|ГДЕ
	|	TripNonLawsonCompaniesStops.Ссылка.Transport = &Transport
	|	И TripNonLawsonCompaniesStops.Ссылка В(&Трипы)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ActualDepartureLocalTime";
	Запрос.УстановитьПараметр("Transport", СтрокаТрип.Trip.Transport);
	Запрос.УстановитьПараметр("Трипы", Трипы);
	
	Результат = Запрос.Выполнить().Выгрузить();
	КоличествоТрипов = Результат.Скопировать();
	КоличествоТрипов.Свернуть("Ссылка");
	
	Если КоличествоТрипов.Количество() = 0 или КоличествоТрипов.Количество() = 1 Тогда
		Возврат 1
	Иначе
		
		ТаблицаТрипов = Новый ТаблицаЗначений;
		ТаблицаТрипов.Колонки.Добавить("Начало");
		ТаблицаТрипов.Колонки.Добавить("Конец");
		ТаблицаТрипов.Колонки.Добавить("Трип");
		ТаблицаТрипов.Колонки.Добавить("Часы");	
		
		Для Каждого Элемент из КоличествоТрипов Цикл
			
			ОтборНачальный = Новый Структура;
			ОтборНачальный.Вставить("Type", Перечисления.StopsTypes.Source);
			ОтборНачальный.Вставить("Ссылка", Элемент.Ссылка);	
			
			ОтборКонечный = Новый Структура;
			ОтборКонечный.Вставить("Type", Перечисления.StopsTypes.Destination);
			ОтборКонечный.Вставить("Ссылка", Элемент.Ссылка);
			
			НачальныйСтоп = Результат.Скопировать(ОтборНачальный);
			КонечныйСтоп = Результат.Скопировать(ОтборКонечный);
			СтрокаТТ = ТаблицаТрипов.Добавить();
			СтрокаТТ.Начало = НачальныйСтоп[0].ActualDepartureLocalTime;
			СтрокаТТ.Конец = КонечныйСтоп[0].ActualArrivalLocalTime;
			СтрокаТТ.Трип = Элемент.Ссылка;
			СтрокаТТ.Часы = Элемент.Ссылка.TotalActualDuration / 3600;
			
		КонецЦикла;
		
		День = ТаблицаТрипов.Найти(СтрокаТрип.Trip.Ссылка, "Трип").Начало;
		КолВоЧасовЗаДень = 0;
		Для Каждого Строка из ТаблицаТрипов Цикл
			Если Строка.Начало >= НачалоДня(День) И Строка.Конец <= КонецДня(День) Тогда 	
				
				КолВоЧасовЗаДень = КолВоЧасовЗаДень + Строка.Часы;
				
			КонецЕсли;	
		КонецЦикла;
		
		КоеффициентВеса = 1;
		
		Если РезультатПробегИВремяПоТрипам.Количество() > 1 Тогда
			
			ОбщийВес = 0;
			
			Для каждого СтрокаТрипа из РезультатПробегИВремяПоТрипам Цикл
				ОбщийВес = ОбщийВес + ПосчитатьВесПоЗаявке(СтрокаТрипа);
			КонецЦикла;
			
			ВесТекущего = ПосчитатьВесПоЗаявке(СтрокаТрип);
			
			КоеффициентВеса = ВесТекущего / ОбщийВес; 
			
		КонецЕсли;		
		Если КолВоЧасовЗаДень = 0 ИЛИ (СтрокаТрип.Trip.TotalActualDuration / 3600) > 24 Тогда 
			Возврат 1
		Иначе
			Возврат (СтрокаТрип.Trip.TotalActualDuration / 3600) / КолВоЧасовЗаДень * КоеффициентВеса;
		КонецЕсли;
	КонецЕсли;
	
	
КонецФункции	

&НаСервере
Функция ПосчитатьВесПоЗаявке(Строка)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Parcels", Строка.Trip.Parcels.Выгрузить());
	Запрос.УстановитьПараметр("TransportRequest", Строка.TransportRequest);
	
	Запрос.Текст =  "ВЫБРАТЬ
	|	Parcels.Parcel КАК Parcel,
	|	Parcels.NumOfParcels КАК NumOfParcels
	|ПОМЕСТИТЬ Parcels
	|ИЗ
	|	&Parcels КАК Parcels
	|;
	|ВЫБРАТЬ
	|	Сумма(TripParcels.Parcel.GrossWeightKG / TripParcels.Parcel.NumOfParcels * TripParcels.NumOfParcels) КАК GrossWeightKG
	|ИЗ
	|	Parcels КАК TripParcels
	|ГДЕ
	|	TripParcels.Parcel.TransportRequest = &TransportRequest";
				
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество()>0 тогда
		Возврат Результат[0].GrossWeightKG 
	Иначе
		Возврат 0
	КонецЕсли;	
	
КонецФункции

&НаСервере
Функция ОпределитьТарифВремяДни(ТаблицаПоПоставщикам  = Неопределено, Trip  = Неопределено, СтруктураПараметров = Неопределено)
	
	ЗапросTrucksCosts = Новый Запрос;
	ЗапросTrucksCosts.Текст = "ВЫБРАТЬ
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport КАК Transport,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
	                          |ИЗ
	                          |	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	                          |			&Дата,
	                          |			ServiceProvider = &ServiceProvider
	                          |				И Equipment = &Equipment
	                          |				И Transport = &Transport) КАК ServiceProvidersRentalTrucksCostsСрезПоследних
	                          |;
	                          |
	                          |////////////////////////////////////////////////////////////////////////////////
	                          |ВЫБРАТЬ
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Период КАК Период,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.ServiceProvider КАК ServiceProvider,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Milage КАК Milage,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Hours_a_day КАК Hours_a_day,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Transport КАК Transport,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Equipment КАК Equipment,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Cost КАК Cost,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerHour КАК CostPerHour,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.CostPerDay КАК CostPerDay,
	                          |	ServiceProvidersRentalTrucksCostsСрезПоследних.Currency КАК Currency
	                          |ИЗ
	                          |	РегистрСведений.ServiceProvidersRentalTrucksCosts.СрезПоследних(
	                          |			&Дата,
	                          |			ServiceProvider = &ServiceProvider
	                          |				И Equipment = &Equipment
	                          |				И Transport = ЗНАЧЕНИЕ(Справочник.Transport.ПустаяСсылка)) КАК ServiceProvidersRentalTrucksCostsСрезПоследних";
							  
	Если НЕ ТаблицаПоПоставщикам = Неопределено Тогда
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			Trip.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		Trip.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		Trip.Transport);
	Иначе
		ЗапросTrucksCosts.УстановитьПараметр("Дата", 			СтруктураПараметров.Дата);
		ЗапросTrucksCosts.УстановитьПараметр("ServiceProvider", Объект.ServiceProvider);
		ЗапросTrucksCosts.УстановитьПараметр("Equipment", 		СтруктураПараметров.Equipment);
		ЗапросTrucksCosts.УстановитьПараметр("Transport", 		СтруктураПараметров.Transport);	
	КонецЕсли;
		
	РезультатTrucksCosts = ЗапросTrucksCosts.ВыполнитьПакет();
	
	СТранспортом = РезультатTrucksCosts[0].Выгрузить();
	БезТранспорта = РезультатTrucksCosts[1].Выгрузить();
	Если СТранспортом.Количество() > 0 Тогда
		Возврат СТранспортом[0]
	ИначеЕсли БезТранспорта.Количество() > 0 Тогда
		Возврат БезТранспорта[0]
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ПолучитьТарифBaseCosts(ДатаЗапроса, Транспорт = Неопределено) 
	
	ЗапросBaseCost = Новый Запрос;
	ЗапросBaseCost.Текст = 
	"ВЫБРАТЬ
	|	TransportMonthlyRateСрезПоследних.Transport,
	|	TransportMonthlyRateСрезПоследних.MonthlyRate КАК Cost,
	|	TransportMonthlyRateСрезПоследних.Currency
	|ИЗ
	|	РегистрСведений.TransportMonthlyRate.СрезПоследних(
	|			&Дата,
	|			ВЫБОР
	|				КОГДА &Transport = НЕОПРЕДЕЛЕНО
	|					ТОГДА ИСТИНА
	|				ИНАЧЕ Transport = &Transport
	|			КОНЕЦ) КАК TransportMonthlyRateСрезПоследних
	|
	|УПОРЯДОЧИТЬ ПО
	|	TransportMonthlyRateСрезПоследних.Период УБЫВ";
	ЗапросBaseCost.УстановитьПараметр("Дата",		ДатаЗапроса);
	ЗапросBaseCost.УстановитьПараметр("Transport", 	Транспорт);
	
	Результат = ЗапросBaseCost.Выполнить().Выгрузить();
	
	Если Результат.Количество() > 0 Тогда
		Возврат Результат[0];
	Иначе
		Возврат "";
	КонецЕсли;

		
КонецФункции

&НаКлиенте
Процедура RentalTrucksОтработаноДнейПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.RentalTrucks.ТекущиеДанные;
	Если ТекущиеДанные.ОтработаноДней = 0 Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Количество отработанных дней не может быть раным нулю";
		Сообщение.Сообщить();
	Иначе
		ПересчитаемОбщееКоличествоДней(ТекущиеДанные);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksManualОтработаноДнейПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.RentalTrucksManual.ТекущиеДанные;
	Если ТекущиеДанные.ОтработаноДней = 0 Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Количество отработанных дней не может быть раным нулю";
		Сообщение.Сообщить();
	Иначе
		ПересчитаемОбщееКоличествоДней(ТекущиеДанные);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитаемОбщееКоличествоДней(ТекущиеДанные)
	
	ТекущееТС = ТекущиеДанные.Transport;
	ОбщееКолВоДнейДо = ТекущиеДанные.ОбщееЧислоДнейИспользования;
	ОбщаяСумма = 0;
	КолвоДнейПосле = 0;
	Отбор = Новый Структура;
	Отбор.Вставить("Transport", ТекущееТС);
	ЗаполненныеСтрокиТЧ = Объект.RentalTrucks.НайтиСтроки(Отбор);
	НомерТекСтроки = ТекущиеДанные.НомерСтроки;

	Для Каждого СтрокаТранспорт ИЗ ЗаполненныеСтрокиТЧ Цикл
		КолвоДнейПосле = КолвоДнейПосле + СтрокаТранспорт.ОтработаноДней;
	КонецЦикла;
		
	КолВоКалендарныхДней = День(КонецМесяца(Период.ДатаОкончания));
	
	КоеффициентИсходный = ОбщееКолВоДнейДо / КолВоКалендарныхДней;
	КоеффициентНовый = КолвоДнейПосле / КолВоКалендарныхДней;

	RentalTrucksCostsType = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ServiceProvider, "RentalTrucksCostsType");
	
	Если КолвоДнейПосле > КолВоКалендарныхДней Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "По ТС - " + ТекущееТС + " количество отработанных дней превышает количество календарных дней";
		Сообщение.Сообщить();
	КонецЕсли;
	
	Если КолвоДнейПосле <> 0 Тогда
		//СуммаЗаДеньПосле = ОбщаяСумма / КолвоДнейПосле;
		
		Для Каждого СтрокаТранспорт_пересчет ИЗ ЗаполненныеСтрокиТЧ Цикл
			СтрокаТранспорт_пересчет.ОбщееЧислоДнейИспользования = КолвоДнейПосле;
			Если RentalTrucksCostsType = ПредопределенноеЗначение("Перечисление.RentalTrucksCostsTypes.BaseMonthlyCost")
				ИЛИ RentalTrucksCostsType = ПредопределенноеЗначение("Перечисление.RentalTrucksCostsTypes.Milage") Тогда
				Если КоеффициентИсходный <> 0 Тогда 
					СтрокаТранспорт_пересчет.Cost = СтрокаТранспорт_пересчет.Cost / КоеффициентИсходный * КоеффициентНовый;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "По ТС - " + ТекущееТС + " количество отработанных дней равно нулю";
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Если НЕ ЗначениеЗаполнено(Объект.ServiceProvider) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"""Service provider"" is empty!",
		, "ServiceProvider", "Объект", Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Объект.ДатаНачала) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"""Start date"" is empty!",
		, "ДатаНачала", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.ДатаОкончания) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"""End date"" is empty!",
		, "ДатаОкончания", "Объект", Отказ);
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;	
	
	Отказ = Истина;
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзRentalTracking");
	СтруктураНастройки.Вставить("ServiceProvider", Объект.ServiceProvider);
	СтруктураНастройки.Вставить("ДатаНачала", Объект.ДатаНачала);
	СтруктураНастройки.Вставить("ДатаОкончания", Объект.ДатаОкончания);
	
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	СтруктураПараметров.Вставить("РежимВыбора", Истина);
	СтруктураПараметров.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Документ.TripNonLawsonCompanies.ФормаВыбора", СтруктураПараметров, Элемент, Элемент, 
		ВариантОткрытияОкна.ОтдельноеОкно, , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
КонецПроцедуры

&НаСервере
Процедура ДобавитьВыбранные(Массив, Параметр)
	
	Если Параметр = "APInvoice" Тогда
		МассивTrips = Новый Массив;
		Для Каждого Invoice Из Массив Цикл
			МассивИзInvoice = Invoice.Trips.Выгрузить();
			МассивTrips = РГСофтКлиентСервер.СложитьМассивы(МассивTrips, МассивИзInvoice.ВыгрузитьКолонку("Trip"));
		КонецЦикла;
	ИначеЕсли Параметр = "Trips" Тогда
		МассивTrips = Массив
	КонецЕсли;
	
	Для Каждого Trip Из МассивTrips Цикл
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.SegmentLawson КАК Segment,
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter КАК AU
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Trip";
		Запрос.УстановитьПараметр("Trip", Trip);
		Результат = Запрос.Выполнить();
		Если Результат.Пустой() Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "У выбранного Trip"+ Trip +" нет TR";
			Сообщение.Сообщить();
			НоваяСтрока = Объект.RentalTrucks.Добавить();
			НоваяСтрока.DateTrip = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Дата");
			НоваяСтрока.Trip = Trip;
			НоваяСтрока.Vehicle = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "EquipmentNo");
		Иначе
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				НоваяСтрока = Объект.RentalTrucks.Добавить();
				НоваяСтрока.TransportRequest = Выборка.TransportRequest;
				НоваяСтрока.Segment = Выборка.Segment;
				НоваяСтрока.AU = Выборка.AU;
				НоваяСтрока.LegalEntity = Выборка.LegalEntity;
				НоваяСтрока.DateTrip = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "Дата");
				НоваяСтрока.Trip = Trip;
				НоваяСтрока.Vehicle = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "EquipmentNo")
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура RentalTrucksОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив") И ВыбранноеЗначение.Количество() Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Если ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.TripNonLawsonCompanies") Тогда
			
			ДобавитьВыбранные(ВыбранноеЗначение, "Trips");
			
		ИначеЕсли ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.APInvoice") Тогда
			
			ДобавитьВыбранные(ВыбранноеЗначение, "APInvoice");
			
		КонецЕсли
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура LoadFromExcel(Команда)
	
	ПоказатьВопрос(
	Новый ОписаниеОповещения("ОбработкаКомандыLoadItemsAndParcelsFromExcelЗавершение", 
	ЭтотОбъект, Объект.ссылка),
	"Выполнить заполнение данных из Excel?", 
	РежимДиалогаВопрос.ДаНет,
	60,
	КодВозвратаДиалога.Нет,
	,
	КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаКомандыLoadItemsAndParcelsFromExcelЗавершение(Результат, Параметр) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
	НастройкиДиалога.Вставить("Rental", ЭтотОбъект);
	
	Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресФайла = РезультатПомещенияФайлов.Хранение;
	РасширениеФайла = "xlsx";
	ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, AP)
	
	ПолноеИмяXLSФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(ПолноеИмяXLSФайла);
	
	ЗагрузитьДанныеИзФайла(ПолноеИмяXLSФайла, AP);
	
	УдалитьФайлы(ПолноеИмяXLSФайла);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеИзФайла(ПолноеИмяФайла, AP)  
	
	ТекстОшибок = "";
	
	ТаблицаExcel = ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла);
	
	Если ПустаяСтрока(ТекстОшибок) Тогда
		ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP);
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ТекстОшибок;
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуExcel(ТекстОшибок, ПолноеИмяФайла)
	
	Connection = Новый COMОбъект("ADODB.Connection");
	СтрокаПодключения = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 12.0;HDR=No;IMEX=1""";	
	
	Попытка 
		Connection.Open(СтрокаПодключения);	
	Исключение
		Попытка
			СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + ПолноеИмяФайла + ";Extended Properties=""Excel 8.0;HDR=No;IMEX=1""";
			Connection.Open(СтрокаПодключения);
		Исключение
			ТекстОшибок = ТекстОшибок + ОписаниеОшибки();
		КонецПопытки;
	КонецПопытки;
	
	rs = Новый COMObject("ADODB.RecordSet");
	rs.ActiveConnection = Connection;
	rs = Connection.OpenSchema(20);
	
	МассивЛистов = Новый Массив;
	Лист = Неопределено;
	
	Пока rs.EOF() = 0 Цикл
		
		Если ЗначениеЗаполнено(Лист) И СтрНайти(rs.Fields("TABLE_NAME").Value, Лист) > 0 Тогда
			rs.MoveNext();
			Продолжить;
		КонецЕсли;
		
		Лист = rs.Fields("TABLE_NAME").Value;
		МассивЛистов.Добавить(Лист);
		
		rs.MoveNext();
		
	КонецЦикла;  
	
	ТаблицаExcel = Новый ТаблицаЗначений();
	ТаблицаExcel.Колонки.Добавить("НомерСтрокиФайла", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(5, 0)),"НомерСтрокиФайла");
	
	Для Каждого ЛистЭксель из МассивЛистов Цикл 
		
		sqlString = "select * from [" + ЛистЭксель + "]";
		rs.Close();
		rs.Open(sqlString);
		
		rs.MoveFirst();
		
		СвойстваСтруктуры = "DateTrip,TransportRequest,Trip,LegalEntity,Segment,AU,Vehicle,Cost,Currency,AccessorialCosts,Weight,Milage,ОтработаноДней";
		
		НомерСтроки = 0;
		Пока rs.EOF = 0 Цикл
			
			НомерСтроки = НомерСтроки + 1;
			
			Если НомерСтроки = 1 Тогда 
				
				СтруктураИменИНомеровКолонок = ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок);
				
				Если Не ПустаяСтрока(ТекстОшибок) Тогда 
					Прервать;
				КонецЕсли;
				
				rs.MoveNext();
				Продолжить;
				
			КонецЕсли;
			
			СтруктураЗначенийСтроки = Новый Структура(СвойстваСтруктуры);
			
			//добавляем значение каждой ячейки файла в структуру значений
			Для Каждого ЭлементСтруктуры из СтруктураИменИНомеровКолонок Цикл 
				
				ЗначениеЯчейки = rs.Fields(ЭлементСтруктуры.Значение-1).Value;
				СтруктураЗначенийСтроки[ЭлементСтруктуры.Ключ] = СокрЛП(ЗначениеЯчейки);
				
			КонецЦикла;     			        						
			
			//добавляем новую структуру и пытаемся заполнить	
			Попытка
				
				НоваяСтрокаТаблицы = ТаблицаExcel.Добавить();
				
				ЗаполнитьЗначенияСвойств(НоваяСтрокаТаблицы, СтруктураЗначенийСтроки, СвойстваСтруктуры);
				
				НоваяСтрокаТаблицы.НомерСтрокиФайла = НомерСтроки;
				
			Исключение
				ТекстОшибок = ТекстОшибок + "
				|не удалось прочитать данные в строке №" + НомерСтроки + "'!";
			КонецПопытки;
			
			rs.MoveNext();
			
		КонецЦикла;
		
		Прервать;
		
	КонецЦикла;
	
	rs.Close();
	Connection.Close();
	
	Возврат ТаблицаExcel;
	
КонецФункции

&НаСервере
Функция ПолучитьСтруктуруИменИНомеровКолонок(rs, СвойстваСтруктуры, ТаблицаExcel, ТекстОшибок)
	
	СтруктураКолонокИИндексов = Новый Структура(СвойстваСтруктуры);
	
	НомерКолонки = 1;
	Для Каждого Field из rs.Fields Цикл 
		
		ТекстЯчейки = СокрЛП(Field.Value);
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Прервать;
		КонецЕсли; 
		
		Если ТекстЯчейки = "Date trip" Тогда
			СтруктураКолонокИИндексов.DateTrip = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "TR no." Тогда
			СтруктураКолонокИИндексов.TransportRequest = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Trip no." Тогда
			СтруктураКолонокИИндексов.Trip = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Legal entity" Тогда
			СтруктураКолонокИИндексов.LegalEntity = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Segment" Тогда
			СтруктураКолонокИИндексов.Segment = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "AU" Тогда
			СтруктураКолонокИИндексов.AU = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Vehicle" Тогда
			СтруктураКолонокИИндексов.Vehicle = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Cost" Тогда
			СтруктураКолонокИИндексов.Cost = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Currency" Тогда
			СтруктураКолонокИИндексов.Currency = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Accessorial costs" Тогда
			СтруктураКолонокИИндексов.AccessorialCosts = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Mileage" Тогда
			СтруктураКолонокИИндексов.Milage = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Duration, days" Тогда
			СтруктураКолонокИИндексов.ОтработаноДней = НомерКолонки;
		ИначеЕсли ТекстЯчейки = "Gross weight, kg" Тогда
			СтруктураКолонокИИндексов.Weight = НомерКолонки;
		КонецЕсли;
		
		НомерКолонки = НомерКолонки + 1;
		
	КонецЦикла; 
	
	Для Каждого КлючИЗначение Из СтруктураКолонокИИндексов Цикл
		
		Если КлючИЗначение.Значение = Неопределено Тогда
			ТекстОшибок = ТекстОшибок + "
			|необходимо проверить наличие колонки с данными '" + СтрЗаменить(КлючИЗначение.Ключ, "_", " ") + "'!";
		иначе
			ТаблицаExcel.Колонки.Добавить(КлючИЗначение.Ключ,,КлючИЗначение.Ключ);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтруктураКолонокИИндексов;
	
КонецФункции

&НаСервере	
Процедура ЗагрузитьОбъекты(ТекстОшибок, ТаблицаExcel, AP) 
	
	ТаблицаДляЗагрузки = ОбработатьТаблицу(ТаблицаExcel);
	
	СписокTripTR = ТаблицаДляЗагрузки.Скопировать();
	СписокTripTR.Свернуть("Trip, TransportRequest");
	
	Для Каждого Трип Из СписокTripTR Цикл
		Если НЕ ЗначениеЗаполнено(Трип.Trip) ИЛИ НЕ ЗначениеЗаполнено(Трип.TransportRequest) Тогда
			Продолжить
		КонецЕсли;
		
		Отбор = Новый Структура();
		Отбор.Вставить("Trip", Трип.Trip);
		Отбор.Вставить("TransportRequest", Трип.TransportRequest);
		
		НайденноеЗначение = Объект.RentalTrucks.НайтиСтроки(Отбор);
		
		Если НайденноеЗначение.Количество() > 0 Тогда
			
			Для Каждого НайденнаяСтрока из НайденноеЗначение Цикл
				
				НайденныеСтроки = ТаблицаExcel.НайтиСтроки(Отбор);
				Если НайденныеСтроки.Количество() <> 0 Тогда
					НайденнаяСтрока.Cost = НайденныеСтроки[0].Cost;
					НайденнаяСтрока.Currency = НайденныеСтроки[0].Currency;
					НайденнаяСтрока.AccessorialCosts = НайденныеСтроки[0].AccessorialCosts;
					НайденнаяСтрока.Weight = НайденныеСтроки[0].Weight;
					НайденнаяСтрока.Milage = НайденныеСтроки[0].Milage;
					НайденнаяСтрока.ОтработаноДней = НайденныеСтроки[0].ОтработаноДней;
				Иначе
					НоваяСтрока = Объект.RentalTrucks.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, НайденнаяСтрока);
				КонецЕсли;
				
			КонецЦикла;
			
		Иначе
			
			НайденныеСтроки = ТаблицаExcel.НайтиСтроки(Отбор);
			Для Каждого Строка Из НайденныеСтроки Цикл
				
				НоваяСтрока = Объект.RentalTrucks.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
				
			КонецЦикла;
			
		КонецЕсли;
		
		//ЗначениеWaybillNo = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Трип.Trip, "WaybillNo");
		//Если Не ЗначениеЗаполнено(ЗначениеWaybillNo) Тогда
		//	ПолученныйТрип = Трип.Trip.ПолучитьОбъект();
		//	ПолученныйТрип.WaybillNo = 
		//КонецЕсли;
		
	КонецЦикла;
	
	
КонецПроцедуры

&НаСервере
Функция ОбработатьТаблицу(ТаблицаExcel)
	
	Для Каждого Строка Из ТаблицаExcel Цикл
		Если Строка.DateTrip = "" Тогда
			Продолжить;
		КонецЕсли;
		Строка.Trip = Документы.TripNonLawsonCompanies.НайтиПоНомеру(Строка.Trip);
		Строка.DateTrip = Дата(Строка.DateTrip + " 00:00:00");
		Строка.TransportRequest = Документы.TransportRequest.НайтиПоНомеру(Строка.TransportRequest);
		Строка.LegalEntity = Справочники.LegalEntities.НайтиПоНаименованию(Строка.LegalEntity);
		Строка.Segment = Справочники.Сегменты.НайтиПоКоду(Строка.Segment);
		Строка.AU = Справочники.КостЦентры.НайтиПоКоду(Строка.AU);
		Строка.Currency = Справочники.Валюты.НайтиПоНаименованию(Строка.Currency);
		Строка.Milage = ?(Строка.Milage = "", 0, Число(Строка.Milage));
		Строка.Cost = ?(Строка.Cost = "", 0, Число(Строка.Cost));
		Строка.AccessorialCosts = ?(Строка.AccessorialCosts = "", 0, Число(Строка.AccessorialCosts));
		Строка.ОтработаноДней = ?(Строка.ОтработаноДней = "", 0, Число(Строка.ОтработаноДней));
		Строка.Weight = ?(Строка.Weight = "", 0, Число(Строка.Weight));
		
	КонецЦикла;
	
	Возврат ТаблицаExcel;
	
КонецФункции

&НаСервере
Процедура ОпределитьОбщуюСумму()
	
	СуммаRental = Объект.RentalTrucks.Итог("Cost") + Объект.RentalTrucks.Итог("AccessorialCosts");
	СуммаРучных = Объект.RentalTrucksManual.Итог("Cost") + Объект.RentalTrucksManual.Итог("AccessorialCosts");
	CostsSum = СуммаRental + СуммаРучных;
	
КонецПроцедуры


&НаКлиенте
Процедура RentalTrucksПриИзменении(Элемент)
	ОпределитьОбщуюСумму();
КонецПроцедуры


&НаКлиенте
Процедура RentalTrucksManualПриИзменении(Элемент)
	ОпределитьОбщуюСумму();
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ЗаписанApproval" 
		И Источник = Объект.Ссылка Тогда
		ЭтаФорма.Прочитать();
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если Не ЗначениеЗаполнено(Approval) Тогда 
		Approval = Задачи.RentalCostsApproval.ПолучитьСсылкуНаApproval(Объект.Ссылка);
	КонецЕсли;

КонецПроцедуры

