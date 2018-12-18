&НаСервереБезКонтекста
Функция ПолучитьТаблицуДанных(Периодичность, ДатаОтчета) 
	
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал,
	|	ДОБАВИТЬКДАТЕ(Интервалы.Интервал, МЕСЯЦ, -1) КАК ПредИнтервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Source.Month,
	|	Source.Trip,
	|	Source.Specialist,
	|	Source.sortIndex,
	|	Source.Title
	|ПОМЕСТИТЬ ИсходнаяВыборка
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		ТаблицаИнтервалов.Интервал КАК Month,
	|		Trip.Ссылка КАК Trip,
	|		""Trips authorized by specialist"" КАК Title,
	|		Trip.Ссылка.Specialist КАК Specialist,
	|		0 КАК sortIndex
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК Trip
	|			ПО (ТаблицаИнтервалов.Интервал = НАЧАЛОПЕРИОДА(Trip.ETA, МЕСЯЦ))
	|				И (НЕ Trip.Ссылка.ПометкаУдаления)
	|				И (НЕ Trip.Ссылка.CreatedBy.Код = ""НеАвторизован"")
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		ТаблицаИнтервалов.Интервал,
	|		Trip.Ссылка,
	|		""Trips NOT authorized by specialist"",
	|		Trip.Ссылка.Specialist,
	|		1
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК Trip
	|			ПО (ТаблицаИнтервалов.Интервал = НАЧАЛОПЕРИОДА(Trip.ETA, МЕСЯЦ))
	|				И (НЕ Trip.Ссылка.ПометкаУдаления)
	|				И (Trip.Ссылка.CreatedBy.Код = ""НеАвторизован"")
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		ТаблицаИнтервалов.Интервал,
	|		Trip.Ссылка,
	|		""Trips pending from previous period"",
	|		Trip.Ссылка.Specialist,
	|		2
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК Trip
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(Trip.ETA, МЕСЯЦ))
	|				И (НЕ Trip.Ссылка.ПометкаУдаления)
	|				И (Trip.Ссылка.CreatedBy.Код = ""НеАвторизован"")
	|				И (Trip.Ссылка.Specialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка))) КАК Source
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсходнаяВыборка.Month,
	|	ИсходнаяВыборка.Trip,
	|	ИсходнаяВыборка.sortIndex КАК sortIndex,
	|	ИсходнаяВыборка.Specialist,
	|	ИсходнаяВыборка.Title
	|ИЗ
	|	ИсходнаяВыборка КАК ИсходнаяВыборка
	|
	|УПОРЯДОЧИТЬ ПО
	|	sortIndex";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
		
	Возврат ТаблицаДанных;	
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТаблицуДанныхОсновная(Периодичность, ДатаОтчета)
	
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсходнаяВыборка.TR,
	|	ИсходнаяВыборка.Specialist,
	|	ИсходнаяВыборка.Title,
	|	ИсходнаяВыборка.Month,
	|	ИсходнаяВыборка.NoTrip,
	|	ИсходнаяВыборка.Stage,
	|	ИсходнаяВыборка.sortIndex
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TransportRequestDoc.Ссылка КАК TR,
	|		TransportRequestDoc.Ссылка.Specialist КАК Specialist,
	|		""Total TR current month"" КАК Title,
	|		НАЧАЛОПЕРИОДА(TransportRequestDoc.CreationDate, МЕСЯЦ) КАК Month,
	|		НАЧАЛОПЕРИОДА(TransportRequestDoc.CreationDate, МЕСЯЦ) КАК ПредИнтервал,
	|		NULL КАК NoTrip,
	|		NULL КАК Stage,
	|		0 КАК sortIndex
	|	ИЗ
	|		Документ.TransportRequest КАК TransportRequestDoc
	|	ГДЕ
	|		TransportRequestDoc.CreationDate МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|		И НЕ TransportRequestDoc.ПометкаУдаления
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		StagesOfTransportRequests.TransportRequest,
	|		StagesOfTransportRequests.TransportRequest.Specialist,
	|		""TR proccessed (current)"",
	|		ТаблицаИнтервалов.Интервал,
	|		NULL,
	|		NULL,
	|		StagesOfTransportRequests.Stage,
	|		1
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
	|			ПО (ТаблицаИнтервалов.Интервал = НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime, МЕСЯЦ))
	|	ГДЕ
	|		StagesOfTransportRequests.Stage В (ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.CompletelyDelivered), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.CompletelyShipped), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.PartiallyDelivered))
	|		И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		StagesOfTransportRequests.TransportRequest,
	|		StagesOfTransportRequests.TransportRequest.Specialist,
	|		""TR proccessed (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		NULL,
	|		NULL,
	|		StagesOfTransportRequests.Stage,
	|		2
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
	|			ПО (ТаблицаИнтервалов.Интервал = НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.CreationDate, МЕСЯЦ))
	|	ГДЕ
	|		StagesOfTransportRequests.Stage В (ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.Requested), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.PartiallyShipped), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.AcceptedBySpecialist))
	|		И НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime, МЕСЯЦ) < НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.CreationDate, МЕСЯЦ)
	|		И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		StagesOfTransportRequests.TransportRequest,
	|		StagesOfTransportRequests.TransportRequest.Specialist,
	|		""TR pending (current)"",
	|		ТаблицаИнтервалов.Интервал,
	|		NULL,
	|		ВЫБОР
	|			КОГДА StagesOfTransportRequests.Stage = ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.AcceptedBySpecialist)
	|					И TripNonLawsonCompaniesParcels.Ссылка ЕСТЬ NULL
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ,
	|		StagesOfTransportRequests.Stage,
	|		4
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|				ПО StagesOfTransportRequests.TransportRequest = TripNonLawsonCompaniesParcels.Parcel.TransportRequest
	|			ПО (ТаблицаИнтервалов.Интервал = НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime, МЕСЯЦ))
	|	ГДЕ
	|		StagesOfTransportRequests.Stage В (ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.Requested), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.PartiallyShipped), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.AcceptedBySpecialist))
	|		И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|		И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		StagesOfTransportRequests.TransportRequest,
	|		StagesOfTransportRequests.TransportRequest.Specialist,
	|		""TR pending (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		NULL,
	|		ВЫБОР
	|			КОГДА StagesOfTransportRequests.Stage = ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.AcceptedBySpecialist)
	|					И TripNonLawsonCompaniesParcels.Ссылка ЕСТЬ NULL
	|				ТОГДА ИСТИНА
	|			ИНАЧЕ ЛОЖЬ
	|		КОНЕЦ,
	|		StagesOfTransportRequests.Stage,
	|		5
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTransportRequests КАК StagesOfTransportRequests
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|				ПО StagesOfTransportRequests.TransportRequest = TripNonLawsonCompaniesParcels.Parcel.TransportRequest
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.CreationDate, МЕСЯЦ))
	|	ГДЕ
	|		StagesOfTransportRequests.Stage В (ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.Requested), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.PartiallyShipped), ЗНАЧЕНИЕ(Перечисление.TransportRequestStages.AcceptedBySpecialist))
	|		И НЕ StagesOfTransportRequests.TransportRequest.ПометкаУдаления
	|		И НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.RequiredDeliveryLocalTime, МЕСЯЦ) < НАЧАЛОПЕРИОДА(StagesOfTransportRequests.TransportRequest.CreationDate, МЕСЯЦ)) КАК ИсходнаяВыборка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ИсходныеДанные.TR КАК TR,
	|	ИсходныеДанные.Specialist,
	|	ИсходныеДанные.Title КАК Title,
	|	ИсходныеДанные.Month,
	|	ИсходныеДанные.sortIndex КАК sortIndex
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|ГДЕ
	|	ИсходныеДанные.Month МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "МЕСЯЦ");
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "КВАРТАЛ");
	КонецЕсли;
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
		
	Возврат ТаблицаДанных;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТаблицуДанныхBillingDashboardBenchmark1(Периодичность, ДатаОтчета)
	
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Trip,
	|	Данные.Sum,
	|	Данные.Specialist,
	|	Данные.BillingSpecialist,
	|	Данные.Title,
	|	Данные.Month,
	|	Данные.SortIndex
	|ПОМЕСТИТЬ ИсходнаяВыборка
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка КАК Trip,
	|		0 КАК Sum,
	|		TripNonLawsonCompanies.Specialist КАК Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist КАК BillingSpecialist,
	|		""Total trips verified by specialist"" КАК Title,
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) КАК Month,
	|		0 КАК SortIndex
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		TripNonLawsonCompanies.TotalCostsSumUSD / 1000,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Total trips verified by specialist"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		0
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		2
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|		И НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) = НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		TripNonLawsonCompanies.TotalCostsSumUSD / 1000,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		2
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|		И НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ) = НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (previous period)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		4
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist > TripNonLawsonCompanies.Closed
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		TripNonLawsonCompanies.TotalCostsSumUSD / 1000,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Verified by specialist (previous period)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.VerifiedByBillingSpecialist, МЕСЯЦ),
	|		4
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist > TripNonLawsonCompanies.Closed
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ),
	|		8
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist = ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		TripNonLawsonCompanies.TotalCostsSumUSD / 1000,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (current)"",
	|		НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ),
	|		8
	|	ИЗ
	|		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|	ГДЕ
	|		НЕ TripNonLawsonCompanies.ПометкаУдаления
	|		И TripNonLawsonCompanies.Проведен
	|		И TripNonLawsonCompanies.VerifiedByBillingSpecialist = ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1)
	|		И TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		0,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		10
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ))
	|				И (TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД))
	|				И (НЕ TripNonLawsonCompanies.ПометкаУдаления)
	|				И (TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1))
	|				И (TripNonLawsonCompanies.Проведен)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompanies.Ссылка,
	|		TripNonLawsonCompanies.TotalCostsSumUSD / 1000,
	|		TripNonLawsonCompanies.Specialist,
	|		TripNonLawsonCompanies.BillingSpecialist,
	|		""Not verified (previous period)"",
	|		ТаблицаИнтервалов.Интервал,
	|		10
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|			ПО (ТаблицаИнтервалов.Интервал > НАЧАЛОПЕРИОДА(TripNonLawsonCompanies.Closed, МЕСЯЦ))
	|				И (TripNonLawsonCompanies.Closed МЕЖДУ НАЧАЛОПЕРИОДА(&ТекущаяДата, ГОД) И КОНЕЦПЕРИОДА(&ТекущаяДата, ГОД))
	|				И (НЕ TripNonLawsonCompanies.ПометкаУдаления)
	|				И (TripNonLawsonCompanies.Closed <> ДАТАВРЕМЯ(1, 1, 1))
	|				И (TripNonLawsonCompanies.Проведен)) КАК Данные
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Т.Trip,
	|	СУММА(Т.Sum) КАК Sum,
	|	ВЫБОР
	|		КОГДА НЕ Т.BillingSpecialist ЕСТЬ NULL
	|				И НЕ Т.BillingSpecialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|				И НЕ Т.BillingSpecialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|			ТОГДА Т.BillingSpecialist
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА Т.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	Т.Title,
	|	Т.Month
	|ИЗ
	|	(ВЫБРАТЬ
	|		ИсходнаяВыборка.Trip КАК Trip,
	|		ИсходнаяВыборка.Sum КАК Sum,
	|		ИсходнаяВыборка.Specialist КАК Specialist,
	|		ИсходнаяВыборка.BillingSpecialist КАК BillingSpecialist,
	|		ИсходнаяВыборка.Title КАК Title,
	|		ИсходнаяВыборка.Month КАК Month
	|	ИЗ
	|		ИсходнаяВыборка КАК ИсходнаяВыборка) КАК Т
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО Т.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner
	|
	|СГРУППИРОВАТЬ ПО
	|	ВЫБОР
	|		КОГДА НЕ Т.BillingSpecialist ЕСТЬ NULL
	|				И НЕ Т.BillingSpecialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|				И НЕ Т.BillingSpecialist = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
	|			ТОГДА Т.BillingSpecialist
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА Т.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ,
	|	Т.Title,
	|	Т.Trip,
	|	Т.Month";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "МЕСЯЦ");
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "КВАРТАЛ");
	КонецЕсли;
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
	
	Показатели = Новый Массив;
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total trips verified by specialist", 0));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Verified by specialist (current)", 2));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Verified by specialist (previous period)", 4));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total TRIP closed", 6));  	
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not verified (current)", 8));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not verified (previous period)", 10)); 
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total TRIP pending", 12));
	
	Для каждого ТекПоказатель из Показатели Цикл
		
		Если ТаблицаДанных.Найти(ТекПоказатель.Показатель, "Title") = Неопределено Тогда
			
			Стр = ТаблицаДанных.Добавить();
			Стр.Title 	  = ТекПоказатель.Показатель;
			Стр.Month 	  = НачалоМесяца(ТекущаяДата());	
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТаблицаДанных;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТаблицуДанныхBillingDashboardLeg7(Периодичность, ДатаОтчета)
		
	ТаблицаПериодов = ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Интервалы.Интервал
	|ПОМЕСТИТЬ ТаблицаИнтервалов
	|ИЗ
	|	&Интервалы КАК Интервалы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Source.Trip,
	|	Source.Title,
	|	Source.Specialist,
	|	Source.Month,
	|	Source.SortIndex
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripFinalDestinations.Ссылка КАК Trip,
	|		""Sent to TMS (SH exist) period = ATA"" КАК Title,
	|		TripFinalDestinations.Ссылка.Specialist КАК Specialist,
	|		ТаблицаИнтервалов.Интервал КАК Month,
	|		0 КАК SortIndex
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|						И (TripDomesticOB.Ссылка.Проведен)
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripFinalDestinations.Ссылка,
	|		""Sent to TMS from previous period"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		1
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|					И (TripDomesticOB.Ссылка.Проведен)
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) < ТаблицаИнтервалов.Интервал)
	|				И (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) >= НАЧАЛОПЕРИОДА(ТаблицаИнтервалов.Интервал, ГОД))
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripFinalDestinations.Ссылка,
	|		""Not processed to TMS"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		3
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (НЕ TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (НЕ OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripFinalDestinations.Ссылка,
	|		""No SH in TMS"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		4
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) = ТаблицаИнтервалов.Интервал)
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripFinalDestinations.Ссылка,
	|		""Pending from previous period"",
	|		TripFinalDestinations.Ссылка.Specialist,
	|		ТаблицаИнтервалов.Интервал,
	|		5
	|	ИЗ
	|		ТаблицаИнтервалов КАК ТаблицаИнтервалов
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Trip.FinalDestinations КАК TripFinalDestinations
	|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.Trip.DomesticOB КАК TripDomesticOB
	|					ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.OBNoAndWONo КАК OBNoAndWONo
	|					ПО TripDomesticOB.OBNo = OBNoAndWONo.OBNo
	|				ПО TripFinalDestinations.Ссылка = TripDomesticOB.Ссылка
	|					И (TripDomesticOB.Ссылка.Проведен)
	|			ПО (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) < ТаблицаИнтервалов.Интервал)
	|				И (НАЧАЛОПЕРИОДА(TripFinalDestinations.ATA, МЕСЯЦ) >= НАЧАЛОПЕРИОДА(ТаблицаИнтервалов.Интервал, ГОД))
	|				И (TripFinalDestinations.Ссылка.DomesticOBSentToTMS)
	|				И (OBNoAndWONo.WO ЕСТЬ NULL)
	|				И (НЕ TripFinalDestinations.Ссылка.ПометкаУдаления)
	|				И (TripFinalDestinations.Ссылка.Проведен)) КАК Source
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсходныеДанные.Trip,
	|	ИсходныеДанные.Title,
	|	ВЫБОР
	|		КОГДА PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist ЕСТЬ NULL
	|			ТОГДА ИсходныеДанные.Specialist
	|		ИНАЧЕ PlannersBillingSpecialistsMatchingСрезПоследних.BillingSpecialist
	|	КОНЕЦ КАК Specialist,
	|	ИсходныеДанные.Month,
	|	ИсходныеДанные.SortIndex
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.PlannersBillingSpecialistsMatching.СрезПоследних(&ТекущаяДата, ) КАК PlannersBillingSpecialistsMatchingСрезПоследних
	|		ПО ИсходныеДанные.Specialist = PlannersBillingSpecialistsMatchingСрезПоследних.Planner";
	
	Запрос.УстановитьПараметр("Интервалы", ТаблицаПериодов);
	Запрос.УстановитьПараметр("ТекущаяДата", ДатаОтчета);
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "МЕСЯЦ");
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ГОД", "КВАРТАЛ");
	КонецЕсли;
	
	ТаблицаДанных = Запрос.Выполнить().Выгрузить();
	
	Показатели = Новый Массив;
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Sent to TMS (SH exist) period = ATA", 0));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Sent to TMS from previous period", 1));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total proccessed", 2)); 
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Not processed to TMS", 3));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "No SH in TMS", 4));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Pending from previous period", 5));
	Показатели.Добавить(Новый Структура("Показатель, Индекс", "Total pending", 6)); 
	
	Для каждого ТекПоказатель из Показатели Цикл
		
		Если ТаблицаДанных.Найти(ТекПоказатель.Показатель, "Title") = Неопределено Тогда
			
			Стр = ТаблицаДанных.Добавить();
			Стр.Title 	  = ТекПоказатель.Показатель;
			Стр.Month 	  = НачалоМесяца(ТекущаяДата());	
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТаблицаДанных;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьТаблицуПериодов(Периодичность, ДатаОтчета)
	
	ТаблицаПериодов = Новый ТаблицаЗначений;
	ТаблицаПериодов.Колонки.Добавить("Интервал", ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.Дата));
	
	НачалоПериода = НачалоМесяца(ДатаОтчета);
	КонецПериода  = НачалоПериода;
	
	Если Периодичность = Перечисления.Периодичность.Месяц Тогда
		Стр = ТаблицаПериодов.Добавить();
		Стр.Интервал = НачалоПериода;
	ИначеЕсли Периодичность = Перечисления.Периодичность.Квартал Тогда
		НачалоПериода = НачалоКвартала(НачалоПериода);
		Для Счет = 1 по 3 Цикл
			
			Стр = ТаблицаПериодов.Добавить();
			Стр.Интервал = НачалоПериода;
			
			НачалоПериода = ДобавитьМесяц(НачалоПериода, 1);
			
		КонецЦикла;
	ИначеЕсли Периодичность = Перечисления.Периодичность.Год Тогда
		НачалоПериода = НачалоГода(НачалоПериода);
		Для Счет = 1 по 12 Цикл
			
			Стр = ТаблицаПериодов.Добавить();
			Стр.Интервал = НачалоПериода;
			
			НачалоПериода = ДобавитьМесяц(НачалоПериода, 1);
			
		КонецЦикла;
	КонецЕсли;
	
	Возврат ТаблицаПериодов;
	
КонецФункции

&НаСервере
Процедура СформироватьОтчетНаСервере()
	
	ВнешниеДанные = Новый Структура;
	Если ИмяСхемы = "PlannersDashboardGeneral" Тогда
		ВнешниеДанные.Вставить("Данные", ПолучитьТаблицуДанныхОсновная(Отчет.Периодичность, Отчет.ДатаОтчета));
	ИначеЕсли ИмяСхемы = "PlannersDashboardLeg7" Тогда 
		ВнешниеДанные.Вставить("Данные", ПолучитьТаблицуДанных(Отчет.Периодичность, Отчет.ДатаОтчета));
	ИначеЕсли ИмяСхемы = "BillingDashboardBenchmark1" Тогда 
		ВнешниеДанные.Вставить("Данные", ПолучитьТаблицуДанныхBillingDashboardBenchmark1(Отчет.Периодичность, Отчет.ДатаОтчета));
	ИначеЕсли ИмяСхемы = "BillingDashboardLeg7" Тогда 
		ВнешниеДанные.Вставить("Данные", ПолучитьТаблицуДанныхBillingDashboardLeg7(Отчет.Периодичность, Отчет.ДатаОтчета));
	КонецЕсли;
	
	ОбъектОтчет = РеквизитФормыВЗначение("Отчет"); 
	ОСКД = ОбъектОтчет.ПолучитьМакет(ИмяСхемы); 
	ТекстЗапроса = Неопределено;
	Попытка 
		ТексЗапроса = ОСКД.НаборыДанных[0].Запрос;
	Исключение
	КонецПопытки;
	//
	НастройкиОСКД = ОСКД.НастройкиПоУмолчанию; 
	//
	НастрйокаКолонки = Неопределено;
	Попытка
		НастройкаКолонки = НастройкиОСКД.Структура[0].Колонки[0].ПоляГруппировки.Элементы[0];
	Исключение
	КонецПопытки;
	
	Если Отчет.Периодичность = Перечисления.Периодичность.Месяц Тогда
		Если ТекстЗапроса <> Неопределено Тогда
			ТексЗапроса = СтрЗаменить(ТексЗапроса, "ГОД", "МЕСЯЦ");
		КонецЕсли;
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоМесяца(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецМесяца(ТекущаяДата());
		КонецЕсли;
	ИначеЕсли Отчет.Периодичность = Перечисления.Периодичность.Квартал Тогда
		Если ТекстЗапроса <> Неопределено Тогда
			ТексЗапроса = СтрЗаменить(ТексЗапроса, "ГОД", "КВАРТАЛ");
		КонецЕсли;
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоКвартала(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецКвартала(ТекущаяДата());
		КонецЕсли;
	Иначе
		Если НЕ НастройкаКолонки = Неопределено Тогда
			НастройкаКолонки.НачалоПериода = НачалоГода(ТекущаяДата());
			НастройкаКолонки.КонецПериода  = КонецГода(ТекущаяДата());
		КонецЕсли;
	КонецЕсли;
	
	Если ТекстЗапроса <> Неопределено Тогда
		ОСКД.НаборыДанных[0].Запрос = ТексЗапроса;	
	КонецЕсли;
	
	ТекущаяДата = НастройкиОСКД.ПараметрыДанных.Элементы.Найти("ТекущаяДата");
	Если ТекущаяДата <> Неопределено Тогда
		ТекущаяДата.Использование 	= Истина;
		ТекущаяДата.Значение 		= Отчет.ДатаОтчета;
	КонецЕсли;
	
	ПараметрыДанныхОСКД = НастройкиОСКД.ПараметрыДанных.Элементы; 
	
	Игнорируемые = Новый Массив;
	Игнорируемые.Добавить("датаотчета");
	Игнорируемые.Добавить("периодичность");
	Игнорируемые.Добавить("имясхемы");
	Игнорируемые.Добавить("sortindex");
	
	// ставим отборы, которые прилетели в параметрах
	НастройкиОСКД.Отбор.Элементы.Очистить();
	
	Для каждого ВхПараметр из ВходящиеПараметры Цикл
		Если СтрНайти(ВхПараметр.Ключ, "I_") = 0 И 
			НЕ ЗначениеЗаполнено(ВхПараметр.Значение)
			И ВхПараметр.Ключ <> "Specialist" Тогда
			Продолжить;
		КонецЕсли;
		
		Если НЕ Игнорируемые.Найти(НРег(ВхПараметр.Ключ)) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		НовыйЭлементОтбора = НастройкиОСКД.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		
		ПолеОтбора = Новый ПолеКомпоновкиДанных(ВхПараметр.Ключ);
		
		НовыйЭлементОтбора.ЛевоеЗначение  = ПолеОтбора;
		НовыйЭлементОтбора.Использование  = Истина;
		Если НЕ СтрНайти(ВхПараметр.Ключ, "I_") = 0 Тогда
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.Больше;
			НовыйЭлементОтбора.ПравоеЗначение = 0;
		ИначеЕсли ВхПараметр.Значение = "Total TR proccessed" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("TR proccessed (current)");
			СписокЗначений.Добавить("TR proccessed (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;			
		ИначеЕсли ВхПараметр.Значение = "Total TR pending" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("TR pending (current)");
			СписокЗначений.Добавить("TR pending (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;		
		ИначеЕсли ВхПараметр.Значение = "Total TRIP closed" И НЕ ВходящиеПараметры.ИмяСхемы = "FleetDashboardGeneral" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("Verified by specialist (current)");
			СписокЗначений.Добавить("Verified by specialist (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total TRIP pending" И НЕ ВходящиеПараметры.ИмяСхемы = "FleetDashboardGeneral" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("Not verified (current)");
			СписокЗначений.Добавить("Not verified (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total pending" И НЕ ВходящиеПараметры.ИмяСхемы = "PlannersDashboardLeg7" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("Not processed to TMS");
			СписокЗначений.Добавить("No SH in TMS");
			СписокЗначений.Добавить("Pending from previous period");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total proccessed" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("Sent to TMS (SH exist) period = ATA");
			СписокЗначений.Добавить("Sent to TMS from previous period");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total TRIP pending" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("TRIP Pending (current)");
			СписокЗначений.Добавить("TRIP Pending (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total TRIP closed" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("TRIP closed (current)");
			СписокЗначений.Добавить("TRIP closed (previous period)");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		ИначеЕсли ВхПараметр.Значение = "Total pending" Тогда 
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.ВСписке;
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.Добавить("Trips NOT authorized by specialist");
			СписокЗначений.Добавить("Trips pending from previous period");
			НовыйЭлементОтбора.ПравоеЗначение = СписокЗначений;
		Иначе			
			НовыйЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.Равно;
			НовыйЭлементОтбора.ПравоеЗначение = ВхПараметр.Значение;
		КонецЕсли;
	КонецЦикла;
	 
	ДанныеРасшифровкиКомпоновкиДанных = Новый ДанныеРасшифровкиКомпоновкиДанных;
	КомпоновщикМакетаОСКД = Новый КомпоновщикМакетаКомпоновкиДанных; 
	//Макет = КомпоновщикМакетаОСКД.Выполнить(ОСКД, КомпоновщикНастроекДанных.ПолучитьНастройкиОСКД()); 
	Макет = КомпоновщикМакетаОСКД.Выполнить(ОСКД, НастройкиОСКД,ДанныеРасшифровкиКомпоновкиДанных); 
	ПроцессорКомпоновкиОСКД = Новый ПроцессорКомпоновкиДанных; 
	ПроцессорКомпоновкиОСКД.Инициализировать(Макет, ВнешниеДанные,ДанныеРасшифровкиКомпоновкиДанных); 
	Результат.Очистить(); 
	ПроцессорВыводаОСКД = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент; 
	ПроцессорВыводаОСКД.УстановитьДокумент(Результат); 
	ПроцессорВыводаОСКД.Вывести(ПроцессорКомпоновкиОСКД);
	 	
	ДанныеРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, УникальныйИдентификатор);
	
	// Чтобы не писалось "Отчет не сформирован…" 
	Элементы.Результат.ОтображениеСостояния.Видимость = Ложь; 
	Элементы.Результат.ОтображениеСостояния.ДополнительныйРежимОтображения = ДополнительныйРежимОтображения.НеИспользовать;
	
КонецПроцедуры

&НаКлиенте
Процедура СформироватьОтчет(Команда)
	
	Если Не ЗначениеЗаполнено(Отчет.ДатаОтчета) Тогда
		Отчет.ДатаОтчета = ТекущаяДата();
	КонецЕсли;
	
	СформироватьОтчетНаСервере(); 

КонецПроцедуры

&НаКлиенте
Процедура РезультатОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДеталиРасшифровки = Новый Структура;
	
	ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки);
	
	Если ДеталиРасшифровки.Количество() > 0 Тогда
		
		Если ДеталиРасшифровки.Свойство("TR") И ЗначениеЗаполнено(ДеталиРасшифровки.TR) Тогда
			ПоказатьЗначение(, ДеталиРасшифровки.TR);
		КонецЕсли;
		
		Если ДеталиРасшифровки.Свойство("Trip") И ЗначениеЗаполнено(ДеталиРасшифровки.Trip) Тогда
			ПоказатьЗначение(, ДеталиРасшифровки.Trip);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//Отчет.Периодичность = Перечисления.Периодичность.Месяц;
	//Отчет.ДатаОтчета 	= ТекущаяДата();
	ЗаполнитьЗначенияСвойств(ЭтаФорма, Параметры.Отбор);
	ЗаполнитьЗначенияСвойств(Отчет, Параметры.Отбор);
	
	ВходящиеПараметры = Параметры.Отбор;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	СформироватьОтчетНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ДатаОтчетаПриИзменении(Элемент)
	
	СформироватьОтчет(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодичностьПриИзменении(Элемент)
	
	СформироватьОтчет(Неопределено);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРасшифровкуНаСервере(Расшифровка, ДеталиРасшифровки, ЭтоГруппа = Ложь) 
	Данные = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);    
	
	ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Расшифровка);
	
КонецФункции 

&НаСервереБезКонтекста
Процедура ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Расшифровка)
	
	ЭлементРасшифровкиДанных = Данные.Элементы.Получить(Расшифровка);
	
	// выбираем поля. Если это группа, то обходим ее рекурсивно
	Если ТипЗнч(ЭлементРасшифровкиДанных) = Тип("ЭлементРасшифровкиКомпоновкиДанныхПоля") Тогда
		Поля = Данные.Элементы.Получить(Расшифровка).ПолучитьПоля(); 
		//Для Каждого ЭлементРасшифровки Из ДеталиРасшифровки Цикл 
		//	ПолеНоменкл = Поля.Найти(ЭлементРасшифровки.Ключ); 
		//	Если Не ПолеНоменкл = Неопределено Тогда 
		//		ДеталиРасшифровки[ЭлементРасшифровки.Ключ] = ПолеНоменкл.Значение;
		//	КонецЕсли; 
		//КонецЦикла;	
		Для каждого ТекПоле из Поля Цикл
			ДеталиРасшифровки.Вставить(ТекПоле.Поле, ТекПоле.Значение);
		КонецЦикла;
	КонецЕсли;
	
	// далее просматриваем родителей
	Родители = ЭлементРасшифровкиДанных.ПолучитьРодителей(); 
	
	Для каждого Родитель из Родители Цикл
		
		ПолучитьЗначенияРасшифровки(Данные, ДеталиРасшифровки, Родитель.Идентификатор);
		//Поля = Данные.Элементы.Получить(Родитель.Идентификатор).ПолучитьПоля(); 
		//Для Каждого ЭлементРасшифровки Из ДеталиРасшифровки Цикл 
		//	ПолеНоменкл = Поля.Найти(ЭлементРасшифровки.Ключ); 
		//	Если Не ПолеНоменкл = Неопределено Тогда 
		//		ДеталиРасшифровки[ЭлементРасшифровки.Ключ] = ПолеНоменкл.Значение;
		//	КонецЕсли; 
		//КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриПовторномОткрытии()
	//СформироватьОтчетНаСервере();
КонецПроцедуры

