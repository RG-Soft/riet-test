
Функция ПреобразоватьДатуВСтроку(ДатаЧисло) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ДатаЧисло) Тогда 
		Возврат "";
	КонецЕсли;
	
	День = День(ДатаЧисло);
	
	Месяц = Месяц(ДатаЧисло);
	Если Месяц = 1 Тогда 
		МесяцСтрока = "JAN";
	ИначеЕсли Месяц = 2 Тогда
		МесяцСтрока = "FEB";
	ИначеЕсли Месяц = 3 Тогда
		МесяцСтрока = "MAR";
	ИначеЕсли Месяц = 4 Тогда
		МесяцСтрока = "APR";
	ИначеЕсли Месяц = 5 Тогда
		МесяцСтрока = "MAY";
	ИначеЕсли Месяц = 6 Тогда
		МесяцСтрока = "JUN";
	ИначеЕсли Месяц = 7 Тогда
		МесяцСтрока = "JUL";
	ИначеЕсли Месяц = 8 Тогда
		МесяцСтрока = "AUG";
	ИначеЕсли Месяц = 9 Тогда
		МесяцСтрока = "SEP";
	ИначеЕсли Месяц = 10 Тогда
		МесяцСтрока = "OCT";
	ИначеЕсли Месяц = 11 Тогда
		МесяцСтрока = "NOV";
	ИначеЕсли Месяц = 12 Тогда
		МесяцСтрока = "DEC";
	КонецЕсли;
	
	Год = СтрЗаменить(Год(ДатаЧисло),Символы.НПП,"");
	
	Значение = "" + День + "-" + МесяцСтрока + "-" + Год;
	Возврат Значение;

			
КонецФункции

Функция ПроверитьТрип(Trip, Док = Неопределено, LegalEntity = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	APInvoiceTrips.Ссылка
	               |ИЗ
	               |	Документ.APInvoice.Trips КАК APInvoiceTrips
	               |ГДЕ
	               |	APInvoiceTrips.Trip = &Trip
	               |	И APInvoiceTrips.Ссылка.Проведен";
	
	Если Док <> Неопределено Тогда
		Запрос.Текст = Запрос.Текст + " И APInvoiceTrips.Ссылка <> &Ссылка";
		Запрос.УстановитьПараметр("Ссылка", Док);
	КонецЕсли;
	
	Если LegalEntity <> Неопределено Тогда
		Запрос.Текст = Запрос.Текст + " И APInvoiceTrips.Ссылка.LegalEntity = &LegalEntity";
		Запрос.УстановитьПараметр("LegalEntity", LegalEntity); 
	КонецЕсли;

	Запрос.УстановитьПараметр("Trip",Trip);	
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Количество() > 0 Тогда
		Результат.Следующий();
		Сообщить("Трип с номером - " + Trip.Номер + ", уже есть в проведенном документе - " + Результат.Ссылка);
		Возврат Истина	
	Иначе		
		Возврат Ложь		
	КонецЕсли;
	
КонецФункции

Функция НастроитьДляВыбораИзAPInvoice(ServiceProvider, LegalEntity) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ServiceProvider", ServiceProvider);
	Запрос.УстановитьПараметр("LegalEntity", LegalEntity);
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.APInvoice.Trips КАК APInvoiceTrips
		|		ПО TripNonLawsonCompaniesParcels.Ссылка = APInvoiceTrips.Trip
		|			И (НЕ APInvoiceTrips.Ссылка.ПометкаУдаления)
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider = &ServiceProvider
		|	И TripNonLawsonCompaniesParcels.Ссылка.VerifiedByBillingSpecialist <> ДАТАВРЕМЯ(1, 1, 1)
		|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
		|	И APInvoiceTrips.Ссылка ЕСТЬ NULL 
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
		|	LocalDistributionCostsPerItemОбороты.Trip
		|ИЗ
		|	РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
		|			,
		|			,
		|			,
		|			Item.TransportRequest.LegalEntity = &LegalEntity
		|				И Trip В
		|					(ВЫБРАТЬ
		|						ВТ.Trip
		|					ИЗ
		|						ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
		|
		|СГРУППИРОВАТЬ ПО
		|	LocalDistributionCostsPerItemОбороты.Trip";
		
	Возврат Запрос.Выполнить().Выгрузить();
			
КонецФункции

// { RGS ASeryakov 10/11/2017 12:00:00 AM S-I-0003904
Функция ПодготовитьДанныеТаблиц(Таблица, ТаблицаДокумента, ДополнительныеПараметры, ЕстьGR) Экспорт
	
	Если ДополнительныеПараметры.Свойство("ПоляОтбора") Тогда
		
		ПоляОтбораПредставление = СтрСоединить(ДополнительныеПараметры.ПоляОтбора, ",");
		
		ТаблицаДанных = Таблица.Скопировать(, ПоляОтбораПредставление);
	Иначе
		ТаблицаДанных = Таблица.Скопировать();
	КонецЕсли;
	
	//} Подготовка данных таблицы для наших условий.
	ТаблицаФайла = Новый ТаблицаЗначений;
	КС = Новый КвалификаторыСтроки(10);
	ТаблицаФайла.Колонки.Добавить("PONumber", Новый ОписаниеТипов("Строка",,,КС));
	ТаблицаДанных.Свернуть("PONumber");
	МассивPONo = ТаблицаДанных.ВыгрузитьКолонку("PONumber");
	//} Подготовка данных таблицы для наших условий.
	
	Для каждого Элемент Из МассивPONo Цикл
		
		Строка = ТаблицаФайла.Добавить();
		Строка.PONumber = Элемент;
	КонецЦикла;
	
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.УстановитьПараметр("POs",ТаблицаДокумента);
	Запрос.УстановитьПараметр("TablePONo",ТаблицаФайла);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	POs.НомерСтроки,
	|	POs.PO,
	|	POs.PONo,
	|	POs.GR
	|ПОМЕСТИТЬ POs_VT
	|ИЗ
	|	&POs КАК POs
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TablePONo.PONumber
	|ПОМЕСТИТЬ TablePONo_VT
	|ИЗ
	|	&TablePONo КАК TablePONo
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TablePONo_VT.PONumber
	|ПОМЕСТИТЬ TablePONo_VT_Отбор
	|ИЗ
	|	TablePONo_VT КАК TablePONo_VT
	|ГДЕ
	|	TablePONo_VT.PONumber В
	|			(ВЫБРАТЬ
	|				POs_VT.PONo
	|			ИЗ
	|				POs_VT КАК POs_VT)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	POs_VT.НомерСтроки,
	|	POs_VT.PO,
	|	POs_VT.PONo,
	|	ВЫБОР
	|		КОГДА POs_VT.PONo = TablePONo_VT_Отбор.PONumber
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК GR
	|ПОМЕСТИТЬ SummaryTable
	|ИЗ
	|	POs_VT КАК POs_VT
	|		ЛЕВОЕ СОЕДИНЕНИЕ TablePONo_VT_Отбор КАК TablePONo_VT_Отбор
	|		ПО POs_VT.PONo = TablePONo_VT_Отбор.PONumber
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КОЛИЧЕСТВО(SummaryTable.GR) КАК NumberGR
	|ПОМЕСТИТЬ NumberGRs
	|ИЗ
	|	SummaryTable КАК SummaryTable
	|ГДЕ
	|	SummaryTable.GR
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	SummaryTable.НомерСтроки,
	|	SummaryTable.PO,
	|	SummaryTable.PONo,
	|	SummaryTable.GR
	|ИЗ
	|	SummaryTable КАК SummaryTable";
	
	
	Результат = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	
	NumberGR = Результат[4].Выгрузить()[0].NumberGR;
	ЕстьGR = ?(NumberGR > 0, Истина, Ложь);
	
	Возврат Результат[5];
	
КонецФункции
// } RGS ASeryakov 10/11/2017 12:00:00 AM S-I-0003904

// Функция разбирает трипы по AP Invoce
// - собираем Company и AU из связанных с трипом Transport requests
// - по регистру BORGSCombinations выбираем все возможные комбинации BORG-ParentCompany-AU
// - разносим трипы по данным комбинациям, пропорционально разбивая стоимость трипа 
// - на AP Invoices
// - Если трип уже входит в AP Invoce, то повторно он туда не заносится. 
// - Если нет AP Invoice для комбинации BORG-ParentCompany-AU, то создаем документ. Если есть - добавляем трип в существующий
// Возвращаемое значение:
// 	- Список созданных\измененных AP invoices
//
Функция РазнестиТрипы(СписокТрипов) Экспорт
	
	Сообщения = Новый Массив;
	
	// удалим из списка трипы, которые являются рентал и при этом для них нет рентал состс
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Трипы", СписокТрипов);
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	TripNonLawsonCompanies.Ссылка КАК Трип,
	|	RentalTrucksCostsSumsRentalTrucks.Ссылка КАК RentalCost
	|ИЗ
	|	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.RentalTrucksCostsSums.RentalTrucks КАК RentalTrucksCostsSumsRentalTrucks
	|		ПО RentalTrucksCostsSumsRentalTrucks.Trip = TripNonLawsonCompanies.Ссылка
	|ГДЕ
	|	TripNonLawsonCompanies.Ссылка В(&Трипы)
	|	И TripNonLawsonCompanies.TypeOfTransport = ЗНАЧЕНИЕ(Перечисление.TypesOfTransport.Rental)";
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		Если НЕ ЗначениеЗаполнено(Результат.RentalCost) Тогда
			Сообщения.Добавить("Невозможно создать AP register без Rental cost для документа " + Строка(Результат.Трип));
			СписокТрипов.Удалить(СписокТрипов.Найти(Результат.Трип));
		КонецЕсли;
	КонецЦикла;
	
	// Проверим, есть ли AP Invoce, в которые включен Trip	
	Запрос.Текст = 
	"ВЫБРАТЬ различные
	|	APInvoiceTrips.Trip,
	|	APInvoiceTrips.Ссылка как APInvoice
	|ИЗ
	|	Документ.APInvoice.Trips КАК APInvoiceTrips
	|ГДЕ
	|	APInvoiceTrips.Trip В(&Трипы)
	|	И НЕ APInvoiceTrips.Ссылка.ПометкаУдаления";
	
	ТаблицаТрипов = Запрос.Выполнить().Выгрузить();	
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Т.Company,
	|	Т.AU,
	|	Т.BORG,
	|	Т.Trip,
	|	Т.TransportRequest,
	|	Т.СуммаТрипаВсего,
	|	Т.СуммаТрипаРазнесенная,
	|	Т.СуммаТрипаВсего - Т.СуммаТрипаРазнесенная КАК ОстатокСуммы,
	|	Т.Stage
	|ПОМЕСТИТЬ ИсходныеДанные
	|ИЗ
	|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Company КАК Company,
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter КАК AU,
	|		BORGSCombinations.BORG КАК BORG,
	|		TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
	|		МАКСИМУМ(ЕСТЬNULL(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот, 0)) КАК СуммаТрипаВсего,
	|		СУММА(ЕСТЬNULL(APInvoiceTrips.Sum, 0)) КАК СуммаТрипаРазнесенная,
	|		StagesOfTripsNonLawsonCompanies.Stage КАК Stage
	|	ИЗ
	|		Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.BORGSCombinations КАК BORGSCombinations
	|			ПО TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Company = BORGSCombinations.ParentCompany
	|				И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter = BORGSCombinations.AU
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(, , , Trip В (&Трипы)) КАК LocalDistributionCostsPerItemОбороты
	|			ПО TripNonLawsonCompaniesParcels.Ссылка = LocalDistributionCostsPerItemОбороты.Trip
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.APInvoice.Trips КАК APInvoiceTrips
	|			ПО TripNonLawsonCompaniesParcels.Ссылка = APInvoiceTrips.Trip
	|				И (НЕ APInvoiceTrips.Ссылка.ПометкаУдаления)
	|				И (APInvoiceTrips.Ссылка.Проведен)
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.StagesOfTripsNonLawsonCompanies КАК StagesOfTripsNonLawsonCompanies
	|			ПО TripNonLawsonCompaniesParcels.Ссылка = StagesOfTripsNonLawsonCompanies.Trip
	|	ГДЕ
	|		TripNonLawsonCompaniesParcels.Ссылка В(&Трипы)
	|		И НЕ TripNonLawsonCompaniesParcels.Ссылка.ПометкаУдаления
	|	
	|	СГРУППИРОВАТЬ ПО
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest,
	|		TripNonLawsonCompaniesParcels.Ссылка,
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Company,
	|		TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter,
	|		BORGSCombinations.BORG,
	|		StagesOfTripsNonLawsonCompanies.Stage) КАК Т
	|ГДЕ
	|	Т.СуммаТрипаВсего - Т.СуммаТрипаРазнесенная > 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ИсходныеДанные.Company,
	|	ИсходныеДанные.AU,
	|	ИсходныеДанные.BORG,
	|	ИсходныеДанные.Trip КАК Трип,
	|	СУММА(1) КАК Счетчик
	|ПОМЕСТИТЬ ОсноваДляРасчета
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсходныеДанные.Company,
	|	ИсходныеДанные.Trip,
	|	ИсходныеДанные.AU,
	|	ИсходныеДанные.BORG
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СУММА(ОсноваДляРасчета.Счетчик) КАК Счетчик,
	|	ОсноваДляРасчета.Трип
	|ПОМЕСТИТЬ КоличествоКомбинацийНаТрип
	|ИЗ
	|	ОсноваДляРасчета КАК ОсноваДляРасчета
	|
	|СГРУППИРОВАТЬ ПО
	|	ОсноваДляРасчета.Трип
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсходныеДанные.Company КАК ParentCompany,
	|	ИсходныеДанные.AU,
	|	ИсходныеДанные.BORG,
	|	ИсходныеДанные.Trip,
	|	ИсходныеДанные.TransportRequest,
	|	ИсходныеДанные.СуммаТрипаВсего,
	|	ИсходныеДанные.СуммаТрипаРазнесенная,
	|	ИсходныеДанные.ОстатокСуммы,
	|	КоличествоКомбинацийНаТрип.Счетчик,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА КоличествоКомбинацийНаТрип.Счетчик = 0
	|				ТОГДА 0
	|			ИНАЧЕ ИсходныеДанные.ОстатокСуммы / КоличествоКомбинацийНаТрип.Счетчик
	|		КОНЕЦ КАК ЧИСЛО(15, 2)) КАК Sum,
	|	ИсходныеДанные.TransportRequest.LegalEntity КАК LegalEntity,
	|	ИсходныеДанные.Trip.ServiceProvider КАК ServiceProvider,
	|	ИсходныеДанные.Stage
	|ИЗ
	|	ИсходныеДанные КАК ИсходныеДанные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ КоличествоКомбинацийНаТрип КАК КоличествоКомбинацийНаТрип
	|		ПО ИсходныеДанные.Trip = КоличествоКомбинацийНаТрип.Трип";
	
	ТаблицаКэша = ПодготовитьТаблицуКэша();
	
	// 
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		
		// тут фильтруем данные и сообщаем пользователю результат работы
		Если НЕ Результат.Stage = Перечисления.TripNonLawsonCompaniesStages.Closed Тогда
			Сообщения.Добавить(Строка(Результат.Trip) + " is not in Closed stage. Current stage is " + Результат.Stage);
			Продолжить;
		КонецЕсли;		
		
		Если НЕ ЗначениеЗаполнено(Результат.BORG) Тогда
			Сообщения.Добавить("For " + Строка(Результат.Trip)+ " with AU = " + Строка(Результат.AU) + " and Company = " + Строка(Результат.ParentCompany) + " BORG has not been identified.");
			Продолжить;
		КонецЕсли;	
		
		СтрокиПоиска = ТаблицаТрипов.НайтиСтроки(Новый Структура("Trip", Результат.Trip));
		Если СтрокиПоиска.Количество() > 0 Тогда
			Сообщения.Добавить(Строка(Результат.Trip) + " has been already placed in " + Строка(СтрокиПоиска[0].APinvoice));
			Продолжить;
		КонецЕсли;
		
		ДокОбъект = Неопределено;
		
		// логика очень простая. 
		// смотрим по таблице кэша, есть ли у нас документ. 
		// если есть - берем его, если нет - создаем новые и помещаем в таблицу. 
		// далее, смотрим, есть ли в доке трип. Если есть - переходим к след. строке выборки. 
		// если нет - добавляем трип в документ
		
		СтруктураПоиска = Новый Структура("BORG, LegalEntity, ServiceProvider, AU, ParentCompany");
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, Результат);
		
		СтрокиКэша = ТаблицаКэша.НайтиСтроки(СтруктураПоиска);
		Если СтрокиКэша.Количество() = 0 Тогда
			// создаем документ
			ДокОбъект = Документы.APInvoice.СоздатьДокумент();
			ДокОбъект.Дата = ТекущаяДата();
			
			ЗаполнитьЗначенияСвойств(ДокОбъект, СтруктураПоиска);
			ДокОбъект.TransportationRegisterType = Перечисления.TransportationRegisterType.SWPS_PO;
			ДокОбъект.Company	= СтруктураПоиска.ParentCompany;
			ДокОбъект.FiscalInvoiceDate = ДокОбъект.Дата;
			ДокОбъект.FiscalInvoiceNoNeeded = Перечисления.YesNo.No;
			ДокОбъект.Received			= ДокОбъект.Дата;
			
			СтрокаКэша = ТаблицаКэша.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаКэша, СтруктураПоиска);
			
			СтрокаКэша.TR = ДокОбъект;
			
		Иначе
			
			ДокОбъект = СтрокиКэша[0].TR;
					
		КонецЕсли;
		
		// добавляем трип в док
		СтруктураПоискаТрипа = Новый Структура("Trip", Результат.Trip);
		
		СтрокиТрипов = ДокОбъект.Trips.НайтиСтроки(СтруктураПоискаТрипа);
		Если СтрокиТрипов.Количество() = 0 Тогда
			СтрокаТрипа = ДокОбъект.Trips.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТрипа, Результат);
		КонецЕсли;
		
	КонецЦикла;
	
	Ответ = Новый Структура;
	Доки  = Новый Массив;
	
	// после того, как все трипы разнесены по документам, вычисляем суммы в документе и записываем все, после чего отдаем на массив созданных документов. 
	Для каждого ТекСтрокаКэша Из ТаблицаКэша Цикл
		
		ДокОбъект = ТекСтрокаКэша.TR;
		ДокОбъект.SumVAT 		= ДокОбъект.Trips.Итог("Sum");
		ДокОбъект.SumWithVAT 	= ДокОбъект.SumVAT;
		
		// записываем документ. 
		ДокОбъект.Записать(РежимЗаписиДокумента.Запись);
		Доки.Добавить(ДокОбъект.Ссылка);
		
	КонецЦикла;
	
	Ответ.Вставить("Документы", Доки);
	Ответ.Вставить("Ошибки", Неопределено);
	Ответ.Вставить("Сообщения", Сообщения);
	
	Возврат Ответ;
	
КонецФункции

Функция ПодготовитьТаблицуКэша()
	
	ТаблицаКэша = Новый ТаблицаЗначений;
	ТаблицаКэша.Колонки.Добавить("BORG");
	ТаблицаКэша.Колонки.Добавить("LegalEntity");
	ТаблицаКэша.Колонки.Добавить("ServiceProvider");
	ТаблицаКэша.Колонки.Добавить("AU");
	ТаблицаКэша.Колонки.Добавить("ParentCompany");
	ТаблицаКэша.Колонки.Добавить("TR");
	
	Возврат ТаблицаКэша;
	
КонецФункции

// } RGS DKazanskiy 05.09.2018 14:15:58 - S-I-0005850