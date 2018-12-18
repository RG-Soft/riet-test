
Функция ВычислитьРасстояние(Location1, Location2, СчитатьПоПрямой = Ложь, СообщатьОбОшибке = Истина) Экспорт
	
	Расстояние = 0;
	
	Если ЗначениеЗаполнено(Location1) И ЗначениеЗаполнено(Location2) Тогда
		
		Расстояние = ПолучитьРасстояниеПоRouteOfLocation(Location1, Location2);
		
		Если Расстояние = 0 Тогда
			Попытка
				Расстояние = ВычислитьРасстояниеПоМаршруту(Location1.Latitude, Location1.Longitude, Location2.Latitude, Location2.Longitude, СообщатьОбОшибке);
			Исключение
				Если СообщатьОбОшибке Тогда 
					ТекстСообщения = "Failed to find ""Milage"" automatically. Please input data manually.";
					Сообщить(ТекстСообщения);
				КонецЕсли;
			КонецПопытки;
		КонецЕсли;
		
		Если Расстояние = 0 И СчитатьПоПрямой Тогда
			Расстояние = ВычислитьРасстояниеПоПрямой(Location1.Latitude, Location1.Longitude, Location2.Latitude, Location2.Longitude);
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Расстояние;
	
КонецФункции

Функция ПолучитьРасстояниеПоRouteOfLocation(Location1, Location2) Экспорт
	
	Расстояние = 0;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	RouteOfLocationСрезПоследних.LocationStart,
	|	RouteOfLocationСрезПоследних.LocationEnd,
	|	RouteOfLocationСрезПоследних.Mileage
	|ИЗ
	|	РегистрСведений.RouteOfLocation.СрезПоследних(
	|			,
	|			LocationStart = &Location1
	|					И LocationEnd = &Location2
	|				ИЛИ LocationStart = &Location2
	|					И LocationEnd = &Location1) КАК RouteOfLocationСрезПоследних";
	
	Запрос.УстановитьПараметр("Location1",	Location1);
	Запрос.УстановитьПараметр("Location2",	Location2);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Расстояние = Выборка.Mileage;
	КонецЕсли;
	
	Возврат Расстояние;
	
КонецФункции

Функция ВычислитьРасстояниеПоМаршруту(Широта1, Долгота1, Широта2, Долгота2, СообщатьОбОшибке = Истина) Экспорт
	
	Если Широта1 = 0 Или Долгота1 = 0 Или Широта2 = 0 Или Долгота2 = 0 Тогда
		Возврат 0;
	КонецЕсли;
	
	ВременныйФайл = ПолучитьИмяВременногоФайла("xml");
	 
	мШирота1	= Формат(Широта1,	"ЧДЦ=7; ЧРД=.; ЧГ=0");
	мДолгота1	= Формат(Долгота1,	"ЧДЦ=7; ЧРД=.; ЧГ=0");
	мШирота2	= Формат(Широта2,	"ЧДЦ=7; ЧРД=.; ЧГ=0");
	мДолгота2	= Формат(Долгота2,	"ЧДЦ=7; ЧРД=.; ЧГ=0");
	 
	 
	НачальныеКоординаты	= "&flat="+мШирота1+"&flon="+мДолгота1+"";
	КонечныеКоординаты	= "&tlat="+мШирота2+"&tlon="+мДолгота2+"";
	 
	//Выполним подключение к сервису и получим данные
	 
	КодСтраницыСайта = Новый HTTPСоединение("yournavigation.org", , , , Неопределено);  
	КодСтраницыСайта.Получить("/api/1.0/gosmore.php?format=kml" + НачальныеКоординаты + "" + КонечныеКоординаты + "", ВременныйФайл);
	 
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ВременныйФайл);
	 
	Имя = ЧтениеXML.Имя;
	Массив = Новый Структура(Имя);
	 
	Попытка
		
		Пока ЧтениеXML.Прочитать() Цикл
			
	        Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
                зИмя =  ЧтениеXML.Имя;
	        КонецЕсли;
	       
			Если зИмя = "distance" И ЗначениеЗаполнено(ЧтениеXML.Значение) Тогда
				
				Если ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
					
                    Попытка
                        Расстояние = Число(ЧтениеXML.Значение);
                    Исключение
                        Расстояние = 0;
                    КонецПопытки;
                   
                    Прервать;
					
				КонецЕсли;    
				
			КонецЕсли;            
			
		КонецЦикла;
		       
		ЧтениеXML.Закрыть();
	 
	Исключение
		Если СообщатьОбОшибке Тогда
			ТекстСообщения = "Failed to find ""Milage"" automatically. Please input data manually.";
			Сообщить(ТекстСообщения);
		КонецЕсли;
	КонецПопытки;
	 
	Возврат Расстояние; // Км
	
КонецФункции

Функция ВычислитьРасстояниеПоПрямой(Широта1, Долгота1, Широта2, Долгота2) Экспорт
	
	Если Широта1 = 0 Или Долгота1 = 0 Или Широта2 = 0 Или Долгота2 = 0 Тогда
		Возврат 0;
	КонецЕсли;
	
	РадиусЗемли	= 6371302;
	ЧислоПи		= 3.1415926535;
	
	Широта1_Рад		= Широта1 * ЧислоПи / 180;
	Широта2_Рад		= Широта2 * ЧислоПи / 180;
	Долгота1_Рад	= Долгота1 * ЧислоПи / 180;
	Долгота2_Рад	= Долгота2 * ЧислоПи / 180;
	
	cl1		= cos(Широта1_Рад);
	cl2		= cos(Широта2_Рад);
	sl1		= sin(Широта1_Рад);
	sl2		= sin(Широта2_Рад);
	delta	= Долгота2_Рад - Долгота1_Рад;
	cdelta	= cos(delta);
	sdelta	= sin(delta);
	
	y = sqrt((cl2 * sdelta)*(cl2 * sdelta)+ (cl1 * sl2 - sl1 * cl2 * cdelta)*(cl1 * sl2 - sl1 * cl2 * cdelta));
	x = sl1 * sl2 + cl1 * cl2 * cdelta;
	
	ad = atan(y/x);
	Расстояние = ad * РадиусЗемли;
	
	Возврат Расстояние / 1000; // Км
	
КонецФункции

Функция ПолучитьВсеКомбинацииРасстояний(ТаблицаРасстояний) Экспорт
	
	ТаблицаРезультат = ТаблицаРасстояний.Скопировать();
	
	ВсегоСтрок = ТаблицаРасстояний.Количество();
	
	Для ы = 1 По ВсегоСтрок Цикл
		
		ТекРасстояние = ТаблицаРасстояний[ы-1].Mileage;
		Для ыы = ы + 1 По ВсегоСтрок Цикл
			
			НоваяСтрока = ТаблицаРезультат.Добавить();
			
			НоваяСтрока.LocationStart	= ТаблицаРасстояний[ы-1].LocationStart;
			НоваяСтрока.LocationEnd		= ТаблицаРасстояний[ыы-1].LocationEnd;
			НоваяСтрока.Mileage			= ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			
			ТекРасстояние = ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаРезультат;
	
КонецФункции

Процедура FillEmptyActualTimeTrip() Экспорт
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	TripNonLawsonCompaniesStops.Ссылка КАК Trip,
	|	TripNonLawsonCompaniesStops.Ссылка.Проведен,
	|	TripNonLawsonCompaniesStops.НомерСтроки,
	|	TripNonLawsonCompaniesStops.Location,
	|	TripNonLawsonCompaniesStops.Type,
	|	TripNonLawsonCompaniesStops.ActualArrivalLocalTime,
	|	TripNonLawsonCompaniesStops.ActualArrivalUniversalTime,
	|	TripNonLawsonCompaniesStops.ActualDepartureLocalTime,
	|	TripNonLawsonCompaniesStops.ActualDepartureUniversalTime
	|ПОМЕСТИТЬ ТаблицаПоставок
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
	|		ПО TripNonLawsonCompaniesStops.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
	|ГДЕ
	|	НЕ TripNonLawsonCompaniesStops.Ссылка.ПометкаУдаления
	|	И НЕ ЕСТЬNULL(StagesOfTripsNonLawsonCompanies.Stage, ЗНАЧЕНИЕ(Перечисление.TripNonLawsonCompaniesStages.ПустаяСсылка)) В (ЗНАЧЕНИЕ(Перечисление.TripNonLawsonCompaniesStages.Closed), ЗНАЧЕНИЕ(Перечисление.TripNonLawsonCompaniesStages.Rejected))
	|	И (TripNonLawsonCompaniesStops.ActualArrivalLocalTime = ДАТАВРЕМЯ(1, 1, 1)
	|			ИЛИ TripNonLawsonCompaniesStops.ActualArrivalUniversalTime = ДАТАВРЕМЯ(1, 1, 1)
	|			ИЛИ TripNonLawsonCompaniesStops.ActualDepartureLocalTime = ДАТАВРЕМЯ(1, 1, 1)
	|			ИЛИ TripNonLawsonCompaniesStops.ActualDepartureUniversalTime = ДАТАВРЕМЯ(1, 1, 1))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаПоставок.Trip,
	|	ТаблицаПоставок.Проведен,
	|	ТаблицаПоставок.НомерСтроки,
	|	ТаблицаПоставок.Location,
	|	ТаблицаПоставок.Type,
	|	ТаблицаПоставок.ActualArrivalLocalTime,
	|	ТаблицаПоставок.ActualArrivalUniversalTime,
	|	ТаблицаПоставок.ActualDepartureLocalTime,
	|	ТаблицаПоставок.ActualDepartureUniversalTime,
	|	ЕСТЬNULL(StatusOfTriplArrival.Период, ДАТАВРЕМЯ(1, 1, 1)) КАК ArrivalUniversalTime,
	|	ЕСТЬNULL(StatusOfTriplArrival.LocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК ArrivalLocalTime,
	|	ЕСТЬNULL(StatusOfTripDeparture.Период, ДАТАВРЕМЯ(1, 1, 1)) КАК DepartureUniversalTime,
	|	ЕСТЬNULL(StatusOfTripDeparture.LocalTime, ДАТАВРЕМЯ(1, 1, 1)) КАК DepartureLocalTime
	|ПОМЕСТИТЬ ТаблицаTime
	|ИЗ
	|	ТаблицаПоставок КАК ТаблицаПоставок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StatusOfTrip КАК StatusOfTriplArrival
	|		ПО ТаблицаПоставок.Trip = StatusOfTriplArrival.Trip
	|			И ТаблицаПоставок.Location = StatusOfTriplArrival.Location
	|			И ТаблицаПоставок.Type = StatusOfTriplArrival.Type
	|			И (StatusOfTriplArrival.Status = Значение(Перечисление.JobStatus.InWarehouse))
	|			И (StatusOfTriplArrival.LocalTime <> ДАТАВРЕМЯ(1, 1, 1))
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StatusOfTrip КАК StatusOfTripDeparture
	|		ПО ТаблицаПоставок.Trip = StatusOfTripDeparture.Trip
	|			И ТаблицаПоставок.Location = StatusOfTripDeparture.Location
	|			И ТаблицаПоставок.Type = StatusOfTripDeparture.Type
	|			И (StatusOfTripDeparture.Status В (Значение(Перечисление.JobStatus.LoadingDone), Значение(Перечисление.JobStatus.UnloadingDone)))
	|			И (StatusOfTripDeparture.LocalTime <> ДАТАВРЕМЯ(1, 1, 1))
	|ГДЕ
	|	(НЕ StatusOfTriplArrival.Trip ЕСТЬ NULL
	|			ИЛИ НЕ StatusOfTripDeparture.Trip ЕСТЬ NULL)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаTime.Trip,
	|	ТаблицаTime.Проведен,
	|	ТаблицаTime.НомерСтроки,
	|	ТаблицаTime.Location,
	|	ТаблицаTime.Type,
	|	ТаблицаTime.ActualArrivalLocalTime,
	|	ТаблицаTime.ActualArrivalUniversalTime,
	|	ТаблицаTime.ActualDepartureLocalTime,
	|	ТаблицаTime.ActualDepartureUniversalTime,
	|	МИНИМУМ(ТаблицаTime.ArrivalUniversalTime) КАК ArrivalUniversalTime,
	|	МИНИМУМ(ТаблицаTime.ArrivalLocalTime) КАК ArrivalLocalTime,
	|	МАКСИМУМ(ТаблицаTime.DepartureUniversalTime) КАК DepartureUniversalTime,
	|	МАКСИМУМ(ТаблицаTime.DepartureLocalTime) КАК DepartureLocalTime
	|ИЗ
	|	ТаблицаTime КАК ТаблицаTime
	|
	|СГРУППИРОВАТЬ ПО
	|	ТаблицаTime.Trip,
	|	ТаблицаTime.Проведен,
	|	ТаблицаTime.НомерСтроки,
	|	ТаблицаTime.Location,
	|	ТаблицаTime.Type,
	|	ТаблицаTime.ActualArrivalLocalTime,
	|	ТаблицаTime.ActualArrivalUniversalTime,
	|	ТаблицаTime.ActualDepartureLocalTime,
	|	ТаблицаTime.ActualDepartureUniversalTime";
	
	// Не однозначное определение времени убытия
	
КонецПроцедуры
