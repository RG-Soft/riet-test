
&НаКлиенте
Процедура TripDateПриИзменении(Элемент)
	
	TripDay = НачалоДня(TripDate);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьПараметрNewTripTRs();
	
	ТекДата = КонецДня(ТекущаяДата());
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	
КонецПроцедуры

// Planning Trip

&НаКлиенте
Процедура GenerateDraftTrip(Команда)

	Если Не ЗначениеЗаполнено(TripDate) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Departure date!", , "TripDate");
		Возврат;
	КонецЕсли; 
	
	Если Не ЗначениеЗаполнено(NewTripTransport) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Transport!", , "NewTripTransport");
		Возврат;
	КонецЕсли;   
	
	Если Не ЗначениеЗаполнено(Equipment) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Equipment!", , "Equipment");
		Возврат;
	КонецЕсли;
	
	Если NewTrip.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Transport request!", , "NewTrip");
		Возврат;
	КонецЕсли;
	
	СтруктураЗаполнения = Новый Структура("TransportRequests,Transport,Equipment,TripDate", 
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(NewTrip, "TransportRequest"), NewTripTransport, Equipment, TripDate);
	
	Если ЗначениеЗаполнено(DraftTrip) Тогда 
		ПерезаполнитьDraftTripНаСервере(СтруктураЗаполнения);
		СтруктураПараметров = Новый Структура("Ключ", DraftTrip);
	иначе
		СтруктураПараметров = Новый Структура("ЗначенияЗаполнения", СтруктураЗаполнения); 	
	КонецЕсли;
	
	ОткрытьФорму("Документ.TripNonLawsonCompanies.ФормаОбъекта", СтруктураПараметров, ЭтаФорма,,,,, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
	DeletePlanНаКлиенте();

КонецПроцедуры

&НаСервере
Процедура ПерезаполнитьDraftTripНаСервере(СтруктураЗаполнения)
	
	DraftTripОбъект = DraftTrip.ПолучитьОбъект();
	DraftTripОбъект.Заполнить(СтруктураЗаполнения);
	DraftTripОбъект.Записать();	
	
КонецПроцедуры

&НаКлиенте
Процедура DeletePlan(Команда)
	
	DeletePlanНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура DeletePlanНаКлиенте()
	
	NewTrip.Очистить();
	TripDate = Неопределено;
	Equipment = Неопределено;
	DraftTrip = Неопределено;
	NewTripTransport = Неопределено;
	EffectiveWeight = Неопределено;
	Элементы.Transport.Обновить();
	УстановитьПараметрNewTripTRs();
	ПересчитатьNewTripTotal();
	
КонецПроцедуры

&НаКлиенте
Процедура NewTripВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные = Элементы.NewTrip.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда 
		ПоказатьЗначение(,ТекущиеДанные.TransportRequest);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура NewTripПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

// Transport requests

&НаКлиенте
Процедура AddToTrip(Команда)
	
	AddToTripНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура AddToTripНаКлиенте()
	
	МассивTR = Элементы.TransportRequests.ВыделенныеСтроки;
	Если МассивTR.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Transport request!", , "TransportRequests");
		Возврат;
	КонецЕсли;
	
	ДобавитьTransportRequestsВTrip(МассивTR);
	
	ПересчитатьNewTripTotal();
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьTransportRequestsВTrip(МассивTR) 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивTR", МассивTR);

	Запрос.Текст = "ВЫБРАТЬ
	               |	ДокументTransportRequest.Ссылка КАК TransportRequest,
	               |	СУММА(Parcels.GrossWeightKG) КАК GrossWeightKG,
	               |	СУММА(Parcels.NumOfParcels) КАК NumOfParcels,
	               |	СУММА(Parcels.CubicMeters) КАК CubicMeters
	               |ИЗ
	               |	Документ.TransportRequest КАК ДокументTransportRequest
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels КАК Parcels
	               |			ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |			ПО (НЕ TripNonLawsonCompaniesParcels.Ссылка.ПометкаУдаления)
	               |				И Parcels.Ссылка = TripNonLawsonCompaniesParcels.Parcel
	               |		ПО ДокументTransportRequest.Ссылка = Parcels.TransportRequest
	               |			И (НЕ Parcels.ПометкаУдаления)
	               |ГДЕ
	               |	ДокументTransportRequest.Проведен
	               |	И ДокументTransportRequest.Ссылка В (&МассивTR)
	               |	И TripNonLawsonCompaniesParcels.Ссылка ЕСТЬ NULL 
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ДокументTransportRequest.Ссылка";
	  		
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		НоваяСтрока = NewTrip.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
		
	КонецЦикла;
	
	УстановитьПараметрNewTripTRs();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрNewTripTRs() 
	
	TransportRequests.Параметры.УстановитьЗначениеПараметра("NewTripTRs", 
		РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(NewTrip, "TransportRequest"));
		
	TransportRequests.Параметры.УстановитьЗначениеПараметра("DraftTrip", DraftTrip);
	
КонецПроцедуры

&НаКлиенте
Процедура DeleteFromTrip(Команда)
	
	DeleteFromTripНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура NewTripОкончаниеПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	
	DeleteFromTripНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура DeleteFromTripНаКлиенте()
	
	МассивTR = Элементы.NewTrip.ВыделенныеСтроки;
	Если МассивTR.Количество() = 0 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Select Transport request!", , "NewTrip");
		Возврат;
	КонецЕсли;
	
	Для Каждого Стр из Элементы.NewTrip.ВыделенныеСтроки Цикл
		ВыделеннаяСтрока = NewTrip.НайтиПоИдентификатору(Стр);
		NewTrip.Удалить(ВыделеннаяСтрока);
	КонецЦикла; 
	
	УстановитьПараметрNewTripTRs();
	ПересчитатьNewTripTotal();
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьNewTripTotal()
	
	TotalGrossWeightKG = NewTrip.Итог("GrossWeightKG");
	TotalCubicMeters = NewTrip.Итог("CubicMeters");
	TotalNumOfParcels = NewTrip.Итог("NumOfParcels");
	
	Если EffectiveWeight = 0 Тогда 
		Difference = 0;
		LoadingPercent = 0;
	иначе  	
		Difference = EffectiveWeight - TotalGrossWeightKG;
		LoadingPercent = (TotalGrossWeightKG / EffectiveWeight) * 100;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура TransportRequestsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	AddToTripНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура TransportRequestsОкончаниеПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка)
	
	AddToTripНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура TransportRequestsПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры


// Transport

&НаКлиенте
Процедура TransportВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	NewTripTransport = Значение;
	
	ЗаполнитьEquipment();
	
КонецПроцедуры

// Draft trips

&НаКлиенте
Процедура DraftTripsВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	
	DraftTrip = Значение;
	
	Если NewTrip.Количество() > 0 Тогда 
		//
	КонецЕсли;
	
	ЗаполнитьТЗNewTripНаСервере(DraftTrip);
	
	УстановитьПараметрNewTripTRs();

	ЗаполнитьEquipment();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЗNewTripНаСервере(DraftTrip)
	
	NewTrip.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("DraftTrip", DraftTrip);
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
	               |	СУММА(TripNonLawsonCompaniesParcels.NumOfParcels) КАК NumOfParcels,
	               |	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG) КАК GrossWeightKG,
	               |	СУММА(TripNonLawsonCompaniesParcels.Parcel.CubicMeters) КАК CubicMeters,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Transport,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Дата,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Equipment
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Ссылка = &DraftTrip
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Transport,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Дата,
	               |	TripNonLawsonCompaniesParcels.Ссылка.Equipment";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
	
		НоваяСтрока = NewTrip.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);
			
	КонецЦикла;
	
	NewTripTransport = Выборка.Transport;
	TripDate = Выборка.Дата;
	Equipment = Выборка.Equipment;
			
КонецПроцедуры

&НаКлиенте
Процедура NewTripTransportПриИзменении(Элемент)
	
	ЗаполнитьEquipment();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьEquipment()
	 	
	Элементы.Equipment.ТолькоПросмотр = (NewTripTransport <> ПредопределенноеЗначение("Справочник.Transport.CallOut"));
	
	Equipment = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(NewTripTransport, "Equipment");
	                       	
	ПриИзмененииEquipment();
	
	ПересчитатьNewTripTotal();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииEquipment()
	
	EffectiveWeight = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Equipment, "EffectiveWeight");
	
КонецПроцедуры

&НаКлиенте
Процедура EquipmentПриИзменении(Элемент)
	
	ПриИзмененииEquipment();
	
КонецПроцедуры

