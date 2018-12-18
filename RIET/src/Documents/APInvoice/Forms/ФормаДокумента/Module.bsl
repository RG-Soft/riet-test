
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПриИзмененииTransportationRegisterType();
	// { RGS riet_test_ru0149app35 25.10.2018 10:07:12 - S-I-0005850
	УправлениеВидимостью(ЭтаФорма, Объект);
	// } RGS riet_test_ru0149app35 25.10.2018 10:07:12 - S-I-0005850

КонецПроцедуры

&НаКлиенте
Процедура TripsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Если НЕ ЗначениеЗаполнено(Объект.ServiceProvider) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"""Service provider"" is empty!",
		, "ServiceProvider", "Объект", Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(Объект.LegalEntity) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"""Legal etity"" is empty!",
		, "LegalEntity", "Объект", Отказ);
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;	
	
	Отказ = Истина;
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзAPInvoice");
	СтруктураНастройки.Вставить("ServiceProvider", Объект.ServiceProvider);
	СтруктураНастройки.Вставить("LegalEntity", Объект.LegalEntity);
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	СтруктураПараметров.Вставить("РежимВыбора", Истина);
	СтруктураПараметров.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Документ.TripNonLawsonCompanies.ФормаВыбора", СтруктураПараметров, Элемент, Элемент, 
		ВариантОткрытияОкна.ОтдельноеОкно, , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	      	
КонецПроцедуры

&НаКлиенте
Процедура TripsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив") И ВыбранноеЗначение.Количество() Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Если ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.TripNonLawsonCompanies") Тогда
			
			ДобавитьВыбранные(ВыбранноеЗначение, "Trip");
			
		ИначеЕсли  ТипЗнч(ВыбранноеЗначение[0]) = Тип("ДокументСсылка.RentalTrucksCostsSums") Тогда
			
			ДобавитьВыбранные(ВыбранноеЗначение, "RentalTrucks");
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьВыбранные(Массив, Параметр)
	
	Если Параметр = "RentalTrucks" Тогда
		
		Для Каждого RentalTrucks Из Массив Цикл
			МассивИзRental = RentalTrucks.RentalTrucks.Выгрузить();
			МассивИзRental.Свернуть("Trip", "Cost, AccessorialCosts");
			
			Для Каждого Трипы Из МассивИзRental Цикл
				
				Дубль = Документы.APInvoice.ПроверитьТрип(Трипы.Trip, Объект.Ссылка, Объект.LegalEntity);
				Если Дубль Тогда
					Продолжить
				КонецЕсли;
				
				НоваяСтрока = Объект.Trips.Добавить();
				
				НоваяСтрока.Trip = Трипы.Trip;
				НоваяСтрока.Sum = Трипы.Cost + Трипы.AccessorialCosts;
				
			КонецЦикла;
			
		КонецЦикла;
		
	ИначеЕсли Параметр = "Trip" Тогда
		МассивTrips = Массив;
		
		Для Каждого Trip Из МассивTrips Цикл
			
			Дубль = Документы.APInvoice.ПроверитьТрип(Trip, Объект.Ссылка, Объект.LegalEntity);
			Если Дубль Тогда
				Продолжить
			КонецЕсли;
			
			НоваяСтрока = Объект.Trips.Добавить();
			
			НоваяСтрока.Trip = Trip;
			Сумма = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Trip, "TotalCostsSum");
			НоваяСтрока.Sum = Сумма.TotalCostsSum;
			
		КонецЦикла;
		
	КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура FillНаСервере()
	
	ТаблицаTrips = Документы.APInvoice.НастроитьДляВыбораИзAPInvoice(Объект.ServiceProvider, Объект.LegalEntity);
		
	Объект.Trips.Загрузить(ТаблицаTrips);
	
КонецПроцедуры

&НаКлиенте
Процедура FillTrips(Команда)
	  		
	FillНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура TransportationRegisterTypeПриИзменении(Элемент)
	
	ПриИзмененииTransportationRegisterType();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииTransportationRegisterType()
	
	ЭтоAP_Invoice = (Объект.TransportationRegisterType = 
		ПредопределенноеЗначение("Перечисление.TransportationRegisterType.AP_Invoice"));
		
	ЭтоSWPS_PO = (Объект.TransportationRegisterType = 
		ПредопределенноеЗначение("Перечисление.TransportationRegisterType.SWPS_PO"));

	Элементы.BookedToERP_date.Видимость = ЭтоAP_Invoice;
	Элементы.Invoices.Видимость = ЭтоAP_Invoice;
	
	Элементы.SWPS.Видимость = ЭтоSWPS_PO;
	
	Элементы.ФормаOracleUnload.Видимость = ЭтоAP_Invoice;
	Элементы.ФормаSWPSOracleUnload.Видимость = ЭтоSWPS_PO;
	Элементы.ФормаSWPSLawsonUnload.Видимость = ЭтоSWPS_PO;
	
КонецПроцедуры

// MI Oracle Unload

&НаКлиенте
Процедура OraclUnload(Команда)
	
	Если Объект.Проведен И Не Модифицированность Тогда
		ТабДок = ПолучитьТабДокMIOracle();
		Если ТабДок <> Неопределено Тогда
			ЗаголовокДокумента = СокрЛП(Объект.Номер);
			ТабДок.Показать(ЗаголовокДокумента);
			// { RGS AArsentev 07.06.2018 S-I-0005386
			ОбновитьДатуВыгрузки();
			// } RGS AArsentev 07.06.2018 S-I-0005386
		КонецЕсли;
	Иначе
		Сообщить("Перед формированием выгрузки необходимо провести документ.");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТабДокMIOracle()
	
	ТабДок = Новый ТабличныйДокумент;	
	Макет = ПолучитьОбщийМакет("MI_Oracle_Unload");
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапка);
	
	НомерПП = 1;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Trips", Объект.Trips.Выгрузить().ВыгрузитьКолонку("Trip"));
	Запрос.УстановитьПараметр("LegalEntity", Объект.LegalEntity);
	
	Запрос.Текст =  "ВЫБРАТЬ РАЗЛИЧНЫЕ
	                |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
	                |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest
	                |ПОМЕСТИТЬ ВТ
	                |ИЗ
	                |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	                |ГДЕ
	                |	TripNonLawsonCompaniesParcels.Ссылка В(&Trips)
	                |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
	                |;
	                |
	                |////////////////////////////////////////////////////////////////////////////////
	                |ВЫБРАТЬ
	                |	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
	                |	ВТ.Trip.Номер КАК TripNo,
	                |	ВТ.TransportRequest.Номер КАК TransportRequestNo,
	                |	ВТ.TransportRequest.ProductLine.Код КАК ProductLineКод,
	                |	ВТ.TransportRequest.CostCenter.Код КАК CostCenterКод,
	                |	ВТ.TransportRequest.Company КАК Company,
	                |	ВТ.TransportRequest.AcquisitionCost КАК AcquisitionCost,
	                |	ВТ.TransportRequest.Recharge КАК Recharge,
	                |	ВТ.TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouse,
	                |	ВТ.TransportRequest.DeliverTo.Наименование КАК DeliverTo,
	                |	ВТ.Trip.TypeOfTransport КАК TypeOfTransport,
	                |	ВТ.TransportRequest.ProjectClient.Наименование КАК Client,
	                |	ВТ.Trip,
	                |	ВТ.Trip.Currency.НаименованиеEng КАК TripCurrencyEng,
	                |	ВТ.TransportRequest.ProjectClient.Наименование КАК ClientDescription
	                |ИЗ
	                |	ВТ КАК ВТ
	                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
	                |				,
	                |				,
	                |				,
	                |				Item.TransportRequest.LegalEntity = &LegalEntity
	                |					И Trip В
	                |						(ВЫБРАТЬ
	                |							ВТ.Trip
	                |						ИЗ
	                |							ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
	                |		ПО ВТ.Trip = LocalDistributionCostsPerItemОбороты.Trip
	                |			И ВТ.TransportRequest = LocalDistributionCostsPerItemОбороты.Item.TransportRequest
	                |
	                |СГРУППИРОВАТЬ ПО
	                |	ВТ.Trip.Номер,
	                |	ВТ.TransportRequest.Номер,
	                |	ВТ.TransportRequest.ProductLine.Код,
	                |	ВТ.TransportRequest.CostCenter.Код,
	                |	ВТ.TransportRequest.Company,
	                |	ВТ.TransportRequest.AcquisitionCost,
	                |	ВТ.TransportRequest.Recharge,
	                |	ВТ.TransportRequest.PickUpWarehouse.Наименование,
	                |	ВТ.TransportRequest.DeliverTo.Наименование,
	                |	ВТ.Trip.TypeOfTransport,
	                |	ВТ.TransportRequest.ProjectClient.Наименование,
	                |	ВТ.Trip,
	                |	ВТ.Trip.Currency.НаименованиеEng,
	                |	ВТ.TransportRequest.ProjectClient.Наименование";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		ПараметрыОбласти = ОбластьСтрока.Параметры;
		ПараметрыОбласти.INVOICE_NUMBER = СокрЛП(Объект.FiscalInvoiceNo);
		ПараметрыОбласти.INVOICE_TYPE = "STANDARD";
		ПараметрыОбласти.INVOICE_DATE = Документы.APInvoice.ПреобразоватьДатуВСтроку(Объект.FiscalInvoiceDate);
		ПараметрыОбласти.VENDOR_NAME = СокрЛП(Объект.ServiceProvider.OracleVendorName);
		ПараметрыОбласти.VENDOR_SITE_CODE = СокрЛП(Объект.ServiceProvider.OracleVendorSiteCode);
		//ПараметрыОбласти.INVOICE_AMOUNT = Объект.SumVAT;
		ПараметрыОбласти.INVOICE_AMOUNT = Формат(Объект.SumVAT, "ЧДЦ=2; ЧРД=.;ЧГ=");
		ПараметрыОбласти.CURRENCY_CODE = ВРег(СокрЛП(Выборка.TripCurrencyEng));
		ПараметрыОбласти.EXCHANGE_RATE = "1";
		ПараметрыОбласти.EXCHANGE_RATE_TYPE2 = "USER";
		ПараметрыОбласти.EXCHANGE_DATE = Документы.APInvoice.ПреобразоватьДатуВСтроку(КонецМесяца(Объект.FiscalInvoiceDate));
		ПараметрыОбласти.INVOICE_TERMS = "NET";
		ПараметрыОбласти.LINE_DESCRIPTION = СокрЛП(Выборка.TripNo) + "###" + СокрЛП(Выборка.ClientDescription);  //S-I-0002805
		ПараметрыОбласти.DESCRIPTION = СокрЛП(Выборка.TransportRequestNo) + " " + СокрЛП(Выборка.TypeOfTransport) + " from " + СокрЛП(Выборка.PickUpWarehouse) 
			+ " to " + СокрЛП(Выборка.DeliverTo) + ?(ЗначениеЗаполнено(Выборка.Client), " for " + СокрЛП(Выборка.Client), "");
		ПараметрыОбласти.ATTRIBUTE_CATEGORY = "68499";	
		ПараметрыОбласти.LIABILITY_ACCOUNT = "9660.546." + СокрЛП(Выборка.CostCenterКод) + ".2101.000.0000.602100";
		ПараметрыОбласти.LINE_NUM = НомерПП;
		ПараметрыОбласти.LINE_TYPE = "ITEM";
		//ПараметрыОбласти.LINE_AMOUNT = Выборка.Sum;     ЧДЦ=2; ЧРД=.; ЧГ=
		ПараметрыОбласти.LINE_AMOUNT = Формат(Выборка.Sum, "ЧДЦ=2; ЧРД=.;ЧГ=");
		ПараметрыОбласти.GL_DATE = Документы.APInvoice.ПреобразоватьДатуВСтроку(ТекущаяДата());
		ПараметрыОбласти.INVOICE_RECEIVED_DATE = Документы.APInvoice.ПреобразоватьДатуВСтроку(Объект.FiscalInvoiceDate);												
		ПараметрыОбласти.Clearing_Account = LocalDistributionForNonLawsonСервер.OracleCoding(
			Выборка.Company, Выборка.AcquisitionCost, Выборка.Recharge, Выборка.ProductLineКод, Выборка.CostCenterКод, Выборка.Trip);
		// { RGS AGorlenko 20.02.2017 16:06:57 - S-I-0002585
		//ПараметрыОбласти.LINE_ATTRIBUTE9 = СокрЛП(Выборка.ClientDescription);  //S-I-0002805
		// } RGS AGorlenko 20.02.2017 16:07:10 - S-I-0002585

		ТабДок.Вывести(ОбластьСтрока);
		
		НомерПП = НомерПП + 1;
		
	КонецЦикла;
	         	
	Возврат ТабДок;   	
	
КонецФункции

// SWPS Oracle Unload

&НаКлиенте
Процедура SWPSOracleUnload(Команда)
	
	Если Объект.Проведен И Не Модифицированность Тогда
		
		МассивТабДок = ПолучитьТабДокSWPSOracle();
		Сч = 1; 		
		Для Каждого ТабДок из МассивТабДок Цикл 
			ЗаголовокДокумента = СокрЛП(Объект.Номер + "-" + Сч);
			ТабДок.Показать(ЗаголовокДокумента);
			Сч = Сч + 1;
		КонецЦикла;
		
		// { RGS AArsentev 07.06.2018 S-I-0005386
		ОбновитьДатуВыгрузки();
		// } RGS AArsentev 07.06.2018 S-I-0005386
		
	Иначе
		Сообщить("Перед формированием выгрузки необходимо провести документ.");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТабДокSWPSOracle()
	
	МассивТабДок = Новый Массив;
	
	ТабДок = Новый ТабличныйДокумент;
	ДокументОбъект = РеквизитФормыВЗначение("Объект");

	Макет = ДокументОбъект.ПолучитьМакет("SWPS_Oracle_Unload");
		
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапка);
	
	НомерПП = 1;
	
	Запрос = Новый Запрос;
	
	//{ RGS AArsentev 13.12.2017 S-I-0004211
	//Запрос.УстановитьПараметр("Trips", Объект.Trips.Выгрузить().ВыгрузитьКолонку("Trip"));
	Запрос.УстановитьПараметр("LegalEntity", Объект.LegalEntity);
	Для Каждого Trip Из Объект.Trips Цикл
		Если Не ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip.Trip, "Secondary") Тогда
		Запрос.УстановитьПараметр("Trips", Trip.Trip);
		Запрос.Текст =  "ВЫБРАТЬ РАЗЛИЧНЫЕ
		                |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
		                |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
		                |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Requestor КАК Requestor,
		                |	TripNonLawsonCompaniesStops_Source.ActualArrivalLocalTime КАК ArrivalLocalTimeSource,
		                |	TripNonLawsonCompaniesStops_Source.ActualDepartureLocalTime КАК DepartureLocalTimeSource,
		                |	TripNonLawsonCompaniesStops_Destination.ActualArrivalLocalTime КАК ArrivalLocalTimeDestination,
		                |	TripNonLawsonCompaniesStops_Destination.ActualDepartureLocalTime КАК DepartureLocalTimeDestination
		                |ПОМЕСТИТЬ ВТ
		                |ИЗ
		                |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		                |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
		                |			И (НЕ ParcelsДетали.Ссылка.ПометкаУдаления)
		                |			И (НЕ ParcelsДетали.СтрокаИнвойса.ПометкаУдаления)
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Source
		                |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Source.Ссылка
		                |			И (TripNonLawsonCompaniesStops_Source.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Destination
		                |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Destination.Ссылка
		                |			И (TripNonLawsonCompaniesStops_Destination.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
		                |ГДЕ
		                |	TripNonLawsonCompaniesParcels.Ссылка В(&Trips)
		                |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
		                |	ВТ.Trip.Номер КАК TripNo,
		                |	ВТ.TransportRequest.Номер КАК TransportRequestNo,
		                |	ВТ.TransportRequest.ProductLine.Код КАК ProductLineКод,
		                |	ВТ.TransportRequest.CostCenter.Код КАК CostCenterКод,
		                |	ВТ.TransportRequest.Company КАК Company,
		                |	ВТ.TransportRequest.AcquisitionCost КАК AcquisitionCost,
		                |	ВТ.TransportRequest.Recharge КАК Recharge,
		                |	ВТ.TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouse,
		                |	ВТ.TransportRequest.DeliverTo.Наименование КАК DeliverTo,
		                |	ВТ.Trip.TypeOfTransport КАК TypeOfTransport,
		                |	ВТ.TransportRequest.ProjectClient.Наименование КАК Client,
		                |	ВТ.Trip,
		                |	ВТ.Trip.Currency.НаименованиеEng КАК TripCurrencyEng,
		                |	ВТ.ArrivalLocalTimeSource,
		                |	ВТ.DepartureLocalTimeSource,
		                |	ВТ.ArrivalLocalTimeDestination,
		                |	ВТ.DepartureLocalTimeDestination,
		                |	ВТ.Requestor,
		                |	ВТ.TransportRequest
		                |ИЗ
		                |	ВТ КАК ВТ
		                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
		                |				,
		                |				,
		                |				Регистратор,
		                |				Item.TransportRequest.LegalEntity = &LegalEntity
		                |					И Trip В
		                |						(ВЫБРАТЬ
		                |							ВТ.Trip
		                |						ИЗ
		                |							ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
		                |		ПО ВТ.Trip = LocalDistributionCostsPerItemОбороты.Trip
		                |			И ВТ.TransportRequest = LocalDistributionCostsPerItemОбороты.Item.TransportRequest
		                |
		                |СГРУППИРОВАТЬ ПО
		                |	ВТ.Trip.Номер,
		                |	ВТ.TransportRequest.Номер,
		                |	ВТ.TransportRequest.ProductLine.Код,
		                |	ВТ.TransportRequest.CostCenter.Код,
		                |	ВТ.TransportRequest.Company,
		                |	ВТ.TransportRequest.AcquisitionCost,
		                |	ВТ.TransportRequest.Recharge,
		                |	ВТ.TransportRequest.PickUpWarehouse.Наименование,
		                |	ВТ.TransportRequest.DeliverTo.Наименование,
		                |	ВТ.Trip.TypeOfTransport,
		                |	ВТ.TransportRequest.ProjectClient.Наименование,
		                |	ВТ.Trip,
		                |	ВТ.Trip.Currency.НаименованиеEng,
		                |	ВТ.ArrivalLocalTimeSource,
		                |	ВТ.DepartureLocalTimeSource,
		                |	ВТ.ArrivalLocalTimeDestination,
		                |	ВТ.DepartureLocalTimeDestination,
		                |	ВТ.Requestor,
		                |	ВТ.TransportRequest";
	Иначе
		Запрос.УстановитьПараметр("Trip", Trip.Trip);
		Запрос.УстановитьПараметр("Primary", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip.Trip, "Primary"));
		Запрос.Текст = "ВЫБРАТЬ
		               |	ВложенныйЗапрос.SecondaryCompany КАК SecondaryCompany,
		               |	ВложенныйЗапрос.SecondaryLegalEntity КАК SecondaryLegalEntity,
		               |	ВложенныйЗапрос.SecondarySegment КАК SecondarySegment,
		               |	ВложенныйЗапрос.SecondarySegmentLawson КАК SecondarySegmentLawson,
		               |	ВложенныйЗапрос.SecondaryCostCenter КАК SecondaryCostCenter,
		               |	ВложенныйЗапрос.SecondaryProductLine КАК SecondaryProductLine,
		               |	ВложенныйЗапрос.Trip КАК Trip,
		               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
		               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Requestor КАК Requestor,
		               |	TripNonLawsonCompaniesStops_Source.ActualArrivalLocalTime КАК ArrivalLocalTimeSource,
		               |	TripNonLawsonCompaniesStops_Source.ActualDepartureLocalTime КАК DepartureLocalTimeSource,
		               |	TripNonLawsonCompaniesStops_Destination.ActualArrivalLocalTime КАК ArrivalLocalTimeDestination,
		               |	TripNonLawsonCompaniesStops_Destination.ActualDepartureLocalTime КАК DepartureLocalTimeDestination
		               |ПОМЕСТИТЬ ВТ
		               |ИЗ
		               |	(ВЫБРАТЬ
		               |		TripNonLawsonCompanies.SecondaryCompany КАК SecondaryCompany,
		               |		TripNonLawsonCompanies.SecondaryLegalEntity КАК SecondaryLegalEntity,
		               |		TripNonLawsonCompanies.SecondarySegment КАК SecondarySegment,
		               |		TripNonLawsonCompanies.SecondarySegmentLawson КАК SecondarySegmentLawson,
		               |		TripNonLawsonCompanies.SecondaryCostCenter КАК SecondaryCostCenter,
		               |		TripNonLawsonCompanies.SecondaryProductLine КАК SecondaryProductLine,
		               |		TripNonLawsonCompanies.Ссылка КАК Trip
		               |	ИЗ
		               |		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
		               |	ГДЕ
		               |		TripNonLawsonCompanies.Ссылка = &Trip
		               |		И TripNonLawsonCompanies.SecondaryLegalEntity = &LegalEntity) КАК ВложенныйЗапрос,
		               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Source
		               |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Source.Ссылка
		               |			И (TripNonLawsonCompaniesStops_Source.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Destination
		               |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Destination.Ссылка
		               |			И (TripNonLawsonCompaniesStops_Destination.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
		               |ГДЕ
		               |	TripNonLawsonCompaniesParcels.Ссылка = &Primary
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
		               |	ВТ.Trip.Номер КАК TripNo,
		               |	ВТ.TransportRequest.Номер КАК TransportRequestNo,
		               |	ВТ.SecondaryProductLine.Код КАК ProductLineКод,
		               |	ВТ.SecondaryCostCenter.Код КАК CostCenterКод,
		               |	ВТ.SecondaryCompany КАК Company,
		               |	ВТ.TransportRequest.AcquisitionCost КАК AcquisitionCost,
		               |	ВТ.TransportRequest.Recharge КАК Recharge,
		               |	ВТ.TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouse,
		               |	ВТ.TransportRequest.DeliverTo.Наименование КАК DeliverTo,
		               |	ВТ.Trip.TypeOfTransport КАК TypeOfTransport,
		               |	ВТ.TransportRequest.ProjectClient.Наименование КАК Client,
		               |	ВТ.Trip КАК Trip,
		               |	ВТ.Trip.Currency.НаименованиеEng КАК TripCurrencyEng,
		               |	ВТ.TransportRequest.ProjectClient.Наименование КАК ClientDescription,
		               |	ВТ.Requestor,
		               |	ВТ.ArrivalLocalTimeSource,
		               |	ВТ.DepartureLocalTimeSource,
		               |	ВТ.ArrivalLocalTimeDestination,
		               |	ВТ.DepartureLocalTimeDestination,
		               |	ВТ.TransportRequest
		               |ИЗ
		               |	ВТ КАК ВТ
		               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
		               |				,
		               |				,
		               |				,
		               |				Trip В
		               |					(ВЫБРАТЬ
		               |						ВТ.Trip
		               |					ИЗ
		               |						ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
		               |		ПО ВТ.Trip = LocalDistributionCostsPerItemОбороты.Trip
		               |			И ВТ.TransportRequest = LocalDistributionCostsPerItemОбороты.Item.TransportRequest
		               |
		               |СГРУППИРОВАТЬ ПО
		               |	ВТ.Trip.Номер,
		               |	ВТ.TransportRequest.Номер,
		               |	ВТ.TransportRequest.AcquisitionCost,
		               |	ВТ.TransportRequest.Recharge,
		               |	ВТ.TransportRequest.PickUpWarehouse.Наименование,
		               |	ВТ.TransportRequest.DeliverTo.Наименование,
		               |	ВТ.Trip.TypeOfTransport,
		               |	ВТ.TransportRequest.ProjectClient.Наименование,
		               |	ВТ.Trip,
		               |	ВТ.Trip.Currency.НаименованиеEng,
		               |	ВТ.SecondaryProductLine.Код,
		               |	ВТ.SecondaryCostCenter.Код,
		               |	ВТ.SecondaryCompany,
		               |	ВТ.Requestor,
		               |	ВТ.ArrivalLocalTimeSource,
		               |	ВТ.DepartureLocalTimeSource,
		               |	ВТ.ArrivalLocalTimeDestination,
		               |	ВТ.DepartureLocalTimeDestination,
		               |	ВТ.TransportRequest.ProjectClient.Наименование,
		               |	ВТ.TransportRequest";
	КонецЕсли;
	//} RGS AArsentev 13.12.2017 S-I-0004211
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		Если НомерПП > 124 Тогда 
			
			МассивТабДок.Добавить(ТабДок);
			
			ТабДок = Новый ТабличныйДокумент;	
			
			Макет = ДокументОбъект.ПолучитьМакет("SWPS_Oracle_Unload");
			
			ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
			ТабДок.Вывести(ОбластьШапка);
			
			НомерПП = 1;
			 			
		КонецЕсли;

		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		ПараметрыОбласти = ОбластьСтрока.Параметры;
		ПараметрыОбласти.SWPSSupplierCode = СокрЛП(Объект.ServiceProvider.SWPSSupplierCode);
		ПараметрыОбласти.Qty = "1";
		ПараметрыОбласти.UOM = "EA-each";
		ПараметрыОбласти.LineDescription = Лев(СокрЛП(Выборка.TransportRequestNo) + "/" + СокрЛП(Выборка.TripNo) 
			+ ?(ЗначениеЗаполнено(Выборка.Client), "/" + СокрЛП(Выборка.Client), "")
			+ "/" + СокрЛП(Выборка.TypeOfTransport) + " from " + СокрЛП(Выборка.PickUpWarehouse) 
			+ " to " + СокрЛП(Выборка.DeliverTo), 255);
			
		ПараметрыОбласти.PartNumber = СокрЛП(Объект.FiscalInvoiceNo);	 //S-I-0002485

		ПараметрыОбласти.UnitPrice = Выборка.Sum;
		ПараметрыОбласти.Currency = ВРег(СокрЛП(Выборка.TripCurrencyEng));
		
		//Delivery Date should be the following - Current date + 13 days
		ПараметрыОбласти.DeliveryDate = Формат(ТекущаяДата() + 86400*13, "ДФ=""ddMMyyyy""");
		
		ПараметрыОбласти.AccountingUnitDescription = LocalDistributionForNonLawsonСервер.OracleCoding(
				Выборка.Company, Выборка.AcquisitionCost, Выборка.Recharge, Выборка.ProductLineКод, Выборка.CostCenterКод, Выборка.Trip);
				
		//ПараметрыОбласти.Req_Type = ПолучитьReq_TypeПоERPTreatment(Выборка.ERPTreatmentNonLawson);  //S-I-0002485
		ПараметрыОбласти.Req_Type = "Expense";
		
		Taxonomy = ОпределитьTaxonomy(Выборка.Trip);
		
		ПараметрыОбласти.Taxonomy = Taxonomy;
		
		
		ПараметрыОбласти.Shipping_Method = "98-Standard";			    				
		ПараметрыОбласти.Payment_Method = "Compliant";    
		        		
		ПараметрыОбласти.BusinessLine = СокрЛП(Выборка.ProductLineКод);
		
		ПараметрыОбласти.Major = LocalDistributionForNonLawsonСервер.OracleCoding(
			Выборка.Company, Выборка.AcquisitionCost, Выборка.Recharge, Выборка.ProductLineКод, Выборка.CostCenterКод, Выборка.Trip, 4);
		ПараметрыОбласти.Minor = LocalDistributionForNonLawsonСервер.OracleCoding(
			Выборка.Company, Выборка.AcquisitionCost, Выборка.Recharge, Выборка.ProductLineКод, Выборка.CostCenterКод, Выборка.Trip, 5);
		
		ПараметрыОбласти.OracleVendorSiteCode = СокрЛП(Объект.ServiceProvider.OracleVendorSiteCode);
		
		ПараметрыОбласти.Intercompany = "0000";
		
		// { RGS AArsentev 06.10.2017
		//Если СокрЛП(Выборка.Company) = "SLI-SMI RU" Тогда
		//	ПараметрыОбласти.Local = "000000";
		//иначе
		//	ПараметрыОбласти.Local = "441061";
		//КонецЕсли;
		ПараметрыОбласти.Local = LocalDistributionForNonLawsonСервер.OracleCoding(
			Выборка.Company, Выборка.AcquisitionCost, Выборка.Recharge, Выборка.ProductLineКод, Выборка.CostCenterКод, Выборка.Trip, 7);
		// } RGS AArsentev 06.10.2017
		
		// { RGS AArsentev 22.12.2017
		ПараметрыОбласти.ArrivalLocalTimeSource = Выборка.ArrivalLocalTimeSource;
		ПараметрыОбласти.DepartureLocalTimeSource = Выборка.DepartureLocalTimeSource;
		ПараметрыОбласти.ArrivalLocalTimeDestination = Выборка.ArrivalLocalTimeDestination;
		ПараметрыОбласти.DepartureLocalTimeDestination = Выборка.DepartureLocalTimeDestination;
		ПараметрыОбласти.Requestor = СокрЛП(Выборка.Requestor);
		ПараметрыОбласти.Items = ПолучитьНаименованияТоваров(Выборка.TransportRequest,Выборка.Trip);
		// } RGS AArsentev 22.12.2017
		
		// { RGS AArsentev 05.02.2018
		ApproveInformation = ПолучитьApprove(Выборка.Trip);
		
		ПараметрыОбласти.Approve = ApproveInformation.Approved;
		
		Если ApproveInformation.Свойство("InformationForApproval") Тогда
			ПараметрыОбласти.InformationForApproval = ApproveInformation.InformationForApproval;
		КонецЕсли;
		// } RGS AArsentev 05.02.2018
			
		ТабДок.Вывести(ОбластьСтрока);
		
		НомерПП = НомерПП + 1;
		
	КонецЦикла;
	//{ RGS AArsentev 13.12.2017 S-I-0004211
	КонецЦикла;
	//} RGS AArsentev 13.12.2017 S-I-0004211
	МассивТабДок.Добавить(ТабДок);

	Возврат МассивТабДок;   	
	
КонецФункции

Функция ПолучитьReq_TypeПоERPTreatment(ERPTreatmentNonLawson)
	
	ERPTreatments = Справочники.ERPTreatments;
	
	Если ERPTreatmentNonLawson = ERPTreatments.Asset_FTE_Construction
		ИЛИ ERPTreatmentNonLawson = ERPTreatments.Asset_NFTE_Construction
		ИЛИ ERPTreatmentNonLawson = ERPTreatments.Used_Asset 
		ИЛИ ERPTreatmentNonLawson = ERPTreatments.New_Asset_FTE 
		ИЛИ ERPTreatmentNonLawson = ERPTreatments.New_Asset_NFTE Тогда
		
		Возврат "A-Asset";
		
	ИначеЕсли ERPTreatmentNonLawson = ERPTreatments.Expense Тогда
		
		Возврат "Expense";
		
	ИначеЕсли ERPTreatmentNonLawson =  ERPTreatments.Issued_Inventory 
		ИЛИ ERPTreatmentNonLawson = ERPTreatments.New_Inventory Тогда
		
		Возврат "I-Inventory";
		
	КонецЕсли;	
	
	Возврат "";
	
КонецФункции

&НаКлиенте
Процедура SWPSLawsonUnload(Команда)
	
	Если Объект.Проведен И Не Модифицированность Тогда
		                           				
		МассивТабДок = ПолучитьТабДокSWPSLawson();
		Сч = 1; 		
		Для Каждого ТабДок из МассивТабДок Цикл 
			ЗаголовокДокумента = СокрЛП(Объект.Номер + "-" + Сч);
			ТабДок.Показать(ЗаголовокДокумента);
			Сч = Сч + 1;
		КонецЦикла;
		
		// { RGS AArsentev 07.06.2018 S-I-0005386
		ОбновитьДатуВыгрузки();
		// } RGS AArsentev 07.06.2018 S-I-0005386
		
	Иначе
		Сообщить("Перед формированием выгрузки необходимо провести документ.");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТабДокSWPSLawson()
	
	МассивТабДок = Новый Массив;

	ТабДок = Новый ТабличныйДокумент;
	ДокументОбъект = РеквизитФормыВЗначение("Объект");

	Макет = ДокументОбъект.ПолучитьМакет("SWPS_Lawson_Unload");
	
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ТабДок.Вывести(ОбластьШапка);
	
	НомерПП = 1;
	
	Запрос = Новый Запрос;
	//{ RGS AArsentev 13.12.2017 S-I-0004211
	//Запрос.УстановитьПараметр("Trips", Объект.Trips.Выгрузить().ВыгрузитьКолонку("Trip"));
	Запрос.УстановитьПараметр("LegalEntity", Объект.LegalEntity);
	Для Каждого Trip Из Объект.Trips Цикл
		Если Не ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip.Trip, "Secondary") Тогда
		Запрос.УстановитьПараметр("Trips", Trip.Trip);
		Запрос.Текст =  "ВЫБРАТЬ РАЗЛИЧНЫЕ
		                |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
		                |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
		                |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Requestor КАК Requestor,
		                |	TripNonLawsonCompaniesStops_Source.ActualArrivalLocalTime КАК ArrivalLocalTimeSource,
		                |	TripNonLawsonCompaniesStops_Source.ActualDepartureLocalTime КАК DepartureLocalTimeSource,
		                |	TripNonLawsonCompaniesStops_Destination.ActualArrivalLocalTime КАК ArrivalLocalTimeDestination,
		                |	TripNonLawsonCompaniesStops_Destination.ActualDepartureLocalTime КАК DepartureLocalTimeDestination
		                |ПОМЕСТИТЬ ВТ
		                |ИЗ
		                |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
		                |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
		                |			И (НЕ ParcelsДетали.Ссылка.ПометкаУдаления)
		                |			И (НЕ ParcelsДетали.СтрокаИнвойса.ПометкаУдаления)
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Source
		                |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Source.Ссылка
		                |			И (TripNonLawsonCompaniesStops_Source.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
		                |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Destination
		                |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Destination.Ссылка
		                |			И (TripNonLawsonCompaniesStops_Destination.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination))
		                |ГДЕ
		                |	TripNonLawsonCompaniesParcels.Ссылка В(&Trips)
		                |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
		                |;
		                |
		                |////////////////////////////////////////////////////////////////////////////////
		                |ВЫБРАТЬ
		                |	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
		                |	ВТ.Trip.Номер КАК TripNo,
		                |	ВТ.TransportRequest.Номер КАК TransportRequestNo,
		                |	ВТ.TransportRequest.ProductLine.Код КАК ProductLineКод,
		                |	ВТ.TransportRequest.CostCenter.Код КАК CostCenterКод,
		                |	ВТ.TransportRequest.Company КАК Company,
		                |	ВТ.TransportRequest.Recharge КАК Recharge,
		                |	ВТ.TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouse,
		                |	ВТ.TransportRequest.DeliverTo.Наименование КАК DeliverTo,
		                |	ВТ.Trip.TypeOfTransport КАК TypeOfTransport,
		                |	ВТ.TransportRequest.ProjectClient.Наименование КАК Client,
		                |	ВТ.Trip,
		                |	ВТ.Trip.Currency.НаименованиеEng КАК TripCurrencyEng,
		                |	ВТ.TransportRequest.RechargeType КАК RechargeType,
		                |	ВТ.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
		                |	ВТ.TransportRequest.CostCenter.Наименование КАК CostCenterName,
		                |	ВТ.TransportRequest.RechargeToAU КАК RechargeToAU,
		                |	ВТ.TransportRequest.RechargeToActivity КАК RechargeToActivity,
		                |	ВТ.TransportRequest.ActivityLawson КАК ActivityCode,
		                |	ВТ.TransportRequest.ClientForRecharge КАК ClientForRecharge,
		                |	ВТ.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
		                |	ВТ.ArrivalLocalTimeSource,
		                |	ВТ.DepartureLocalTimeSource,
		                |	ВТ.ArrivalLocalTimeDestination,
		                |	ВТ.DepartureLocalTimeDestination,
		                |	ВТ.Requestor,
		                |	ВТ.TransportRequest
		                |ИЗ
		                |	ВТ КАК ВТ
		                |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
		                |				,
		                |				,
		                |				Регистратор,
		                |				Item.TransportRequest.LegalEntity = &LegalEntity
		                |					И Trip В
		                |						(ВЫБРАТЬ
		                |							ВТ.Trip
		                |						ИЗ
		                |							ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
		                |		ПО ВТ.Trip = LocalDistributionCostsPerItemОбороты.Trip
		                |			И ВТ.TransportRequest = LocalDistributionCostsPerItemОбороты.Item.TransportRequest
		                |
		                |СГРУППИРОВАТЬ ПО
		                |	ВТ.Trip.Номер,
		                |	ВТ.TransportRequest.Номер,
		                |	ВТ.TransportRequest.ProductLine.Код,
		                |	ВТ.TransportRequest.CostCenter.Код,
		                |	ВТ.TransportRequest.Company,
		                |	ВТ.TransportRequest.Recharge,
		                |	ВТ.TransportRequest.PickUpWarehouse.Наименование,
		                |	ВТ.TransportRequest.DeliverTo.Наименование,
		                |	ВТ.Trip.TypeOfTransport,
		                |	ВТ.TransportRequest.ProjectClient.Наименование,
		                |	ВТ.Trip,
		                |	ВТ.Trip.Currency.НаименованиеEng,
		                |	ВТ.TransportRequest.RechargeType,
		                |	ВТ.TransportRequest.RechargeToLegalEntity,
		                |	ВТ.TransportRequest.CostCenter.Наименование,
		                |	ВТ.TransportRequest.RechargeToAU,
		                |	ВТ.TransportRequest.RechargeToActivity,
		                |	ВТ.TransportRequest.ActivityLawson,
		                |	ВТ.TransportRequest.ClientForRecharge,
		                |	ВТ.TransportRequest.AgreementForRecharge,
		                |	ВТ.ArrivalLocalTimeSource,
		                |	ВТ.DepartureLocalTimeSource,
		                |	ВТ.ArrivalLocalTimeDestination,
		                |	ВТ.DepartureLocalTimeDestination,
		                |	ВТ.Requestor,
		                |	ВТ.TransportRequest";
		
	Иначе
	Запрос.УстановитьПараметр("Trip", Trip.Trip);
	Запрос.УстановитьПараметр("Primary", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip.Trip, "Primary"));
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ВложенныйЗапрос.Trip КАК Trip,
	               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest,
	               |	ВложенныйЗапрос.SecondaryCompany КАК Company,
	               |	ВложенныйЗапрос.SecondaryLegalEntity КАК LegalEntity,
	               |	ВложенныйЗапрос.SecondarySegment КАК Segment,
	               |	ВложенныйЗапрос.SecondarySegmentLawson КАК SegmentLawson,
	               |	ВложенныйЗапрос.SecondaryCostCenter КАК CostCenter,
	               |	ВложенныйЗапрос.SecondaryProductLine КАК ProductLine,
	               |	TripNonLawsonCompaniesStops_Source.ActualArrivalLocalTime КАК ArrivalLocalTimeSource,
	               |	TripNonLawsonCompaniesStops_Source.ActualDepartureLocalTime КАК DepartureLocalTimeSource,
	               |	TripNonLawsonCompaniesStops_Destination.ActualArrivalLocalTime КАК ArrivalLocalTimeDestination,
	               |	TripNonLawsonCompaniesStops_Destination.ActualDepartureLocalTime КАК DepartureLocalTimeDestination,
	               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Requestor КАК Requestor
	               |ПОМЕСТИТЬ ВТ
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	               |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
	               |			И (НЕ ParcelsДетали.Ссылка.ПометкаУдаления)
	               |			И (НЕ ParcelsДетали.СтрокаИнвойса.ПометкаУдаления)
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Source
	               |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Source.Ссылка
	               |			И (TripNonLawsonCompaniesStops_Source.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Source))
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Stops КАК TripNonLawsonCompaniesStops_Destination
	               |		ПО TripNonLawsonCompaniesParcels.Ссылка = TripNonLawsonCompaniesStops_Destination.Ссылка
	               |			И (TripNonLawsonCompaniesStops_Destination.Type = ЗНАЧЕНИЕ(Перечисление.StopsTypes.Destination)),
	               |	(ВЫБРАТЬ
	               |		TripNonLawsonCompanies.SecondaryCompany КАК SecondaryCompany,
	               |		TripNonLawsonCompanies.SecondaryLegalEntity КАК SecondaryLegalEntity,
	               |		TripNonLawsonCompanies.SecondarySegment КАК SecondarySegment,
	               |		TripNonLawsonCompanies.SecondarySegmentLawson КАК SecondarySegmentLawson,
	               |		TripNonLawsonCompanies.SecondaryCostCenter КАК SecondaryCostCenter,
	               |		TripNonLawsonCompanies.SecondaryProductLine КАК SecondaryProductLine,
	               |		TripNonLawsonCompanies.Ссылка КАК Trip
	               |	ИЗ
	               |		Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
	               |	ГДЕ
	               |		TripNonLawsonCompanies.Ссылка = &Trip
	               |		И TripNonLawsonCompanies.SecondaryLegalEntity = &LegalEntity) КАК ВложенныйЗапрос
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Ссылка В(&Primary)
	               |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	СУММА(LocalDistributionCostsPerItemОбороты.TotalCostsSumОборот) КАК Sum,
	               |	ВТ.Trip.Номер КАК TripNo,
	               |	ВТ.TransportRequest.Номер КАК TransportRequestNo,
	               |	ВТ.TransportRequest.Recharge КАК Recharge,
	               |	ВТ.TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouse,
	               |	ВТ.TransportRequest.DeliverTo.Наименование КАК DeliverTo,
	               |	ВТ.Trip.TypeOfTransport КАК TypeOfTransport,
	               |	ВТ.TransportRequest.ProjectClient.Наименование КАК Client,
	               |	ВТ.Trip,
	               |	ВТ.Trip.Currency.НаименованиеEng КАК TripCurrencyEng,
	               |	ВТ.TransportRequest.RechargeType КАК RechargeType,
	               |	ВТ.TransportRequest.RechargeToLegalEntity КАК RechargeToLegalEntity,
	               |	ВТ.CostCenter.Наименование КАК CostCenterName,
	               |	ВТ.TransportRequest.RechargeToAU КАК RechargeToAU,
	               |	ВТ.TransportRequest.RechargeToActivity КАК RechargeToActivity,
	               |	ВТ.TransportRequest.ActivityLawson КАК ActivityCode,
	               |	ВТ.TransportRequest.ClientForRecharge КАК ClientForRecharge,
	               |	ВТ.TransportRequest.AgreementForRecharge КАК AgreementForRecharge,
	               |	ВТ.Company КАК Company,
	               |	ВТ.CostCenter.Код КАК CostCenterКод,
	               |	ВТ.ProductLine.Код КАК ProductLineКод,
	               |	ВТ.Requestor,
	               |	ВТ.ArrivalLocalTimeSource,
	               |	ВТ.DepartureLocalTimeSource,
	               |	ВТ.ArrivalLocalTimeDestination,
	               |	ВТ.DepartureLocalTimeDestination,
	               |	ВТ.TransportRequest
	               |ИЗ
	               |	ВТ КАК ВТ
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerItem.Обороты(
	               |				,
	               |				,
	               |				Регистратор,
	               |				Item.TransportRequest.LegalEntity = &LegalEntity
	               |					И Trip В
	               |						(ВЫБРАТЬ
	               |							ВТ.Trip
	               |						ИЗ
	               |							ВТ КАК ВТ)) КАК LocalDistributionCostsPerItemОбороты
	               |		ПО ВТ.Trip = LocalDistributionCostsPerItemОбороты.Trip
	               |			И ВТ.TransportRequest = LocalDistributionCostsPerItemОбороты.Item.TransportRequest
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ.Trip.Номер,
	               |	ВТ.TransportRequest.Номер,
	               |	ВТ.TransportRequest.Recharge,
	               |	ВТ.TransportRequest.PickUpWarehouse.Наименование,
	               |	ВТ.TransportRequest.DeliverTo.Наименование,
	               |	ВТ.Trip.TypeOfTransport,
	               |	ВТ.TransportRequest.ProjectClient.Наименование,
	               |	ВТ.Trip,
	               |	ВТ.Trip.Currency.НаименованиеEng,
	               |	ВТ.TransportRequest.RechargeType,
	               |	ВТ.TransportRequest.RechargeToLegalEntity,
	               |	ВТ.TransportRequest.RechargeToAU,
	               |	ВТ.TransportRequest.RechargeToActivity,
	               |	ВТ.TransportRequest.ActivityLawson,
	               |	ВТ.TransportRequest.ClientForRecharge,
	               |	ВТ.TransportRequest.AgreementForRecharge,
	               |	ВТ.Company,
	               |	ВТ.CostCenter.Код,
	               |	ВТ.ProductLine.Код,
	               |	ВТ.Requestor,
	               |	ВТ.ArrivalLocalTimeSource,
	               |	ВТ.DepartureLocalTimeSource,
	               |	ВТ.ArrivalLocalTimeDestination,
	               |	ВТ.DepartureLocalTimeDestination,
	               |	ВТ.CostCenter.Наименование,
	               |	ВТ.TransportRequest";
	
	КонецЕсли;
	//} RGS AArsentev 13.12.2017 S-I-0004211
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл 
		
		Если НомерПП > 124 Тогда 
			
			МассивТабДок.Добавить(ТабДок);
			
			ТабДок = Новый ТабличныйДокумент;	
			Макет = ДокументОбъект.ПолучитьМакет("SWPS_Lawson_Unload");
			ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
			ТабДок.Вывести(ОбластьШапка);
			
			НомерПП = 1;
			 			
		КонецЕсли;
		
		ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
		ПараметрыОбласти = ОбластьСтрока.Параметры;
		ПараметрыОбласти.SWPSSupplierCode = СокрЛП(Объект.ServiceProvider.SWPSSupplierCode);
		ПараметрыОбласти.Qty = "1";
		ПараметрыОбласти.UOM = "EA-each";
		ПараметрыОбласти.LineDescription = Лев(СокрЛП(Выборка.TransportRequestNo) + "/" + СокрЛП(Выборка.TripNo) 
			+ " " + СокрЛП(Выборка.TypeOfTransport) + " from " + СокрЛП(Выборка.PickUpWarehouse) 
			+ " to " + СокрЛП(Выборка.DeliverTo) + ?(ЗначениеЗаполнено(Выборка.Client), " for " + СокрЛП(Выборка.Client), ""), 255);
			
		ПараметрыОбласти.PartNumber = СокрЛП(Объект.FiscalInvoiceNo);	 //S-I-0002485
			
		ПараметрыОбласти.UnitPrice = Выборка.Sum;
		ПараметрыОбласти.Currency = ВРег(СокрЛП(Выборка.TripCurrencyEng));
		
		//Delivery Date should be the following - Current date + 13 days
		ПараметрыОбласти.DeliveryDate = Формат(ТекущаяДата() + 86400*13, "ДФ=""ddMMyyyy""");
		
		Если Объект.Company.Country <> Справочники.CountriesOfProcessLevels.RU Тогда
			ПараметрыОбласти.AccountingUnitDescription = СокрЛП(Выборка.CostCenterКод) + ": " + СокрЛП(Выборка.CostCenterName) + " (Logistics)";
		Иначе
			ПараметрыОбласти.AccountingUnitDescription = СокрЛП(Выборка.CostCenterКод) + ": " + СокрЛП(Выборка.CostCenterName) + " (MCC)";
		КонецЕсли;
		ПараметрыОбласти.ActivityCode = СокрЛП(Выборка.ActivityCode);
		
		//ПараметрыОбласти.Req_Type = ПолучитьReq_TypeПоERPTreatment(Выборка.ERPTreatmentNonLawson);  //S-I-0002485
		ПараметрыОбласти.Req_Type = "Expense";
		
		Taxonomy = ОпределитьTaxonomy(Выборка.Trip);
		
		ПараметрыОбласти.Taxonomy = Taxonomy;
		ПараметрыОбласти.Shipping_Method = "98-Standard";
		ПараметрыОбласти.Payment_Method = "Compliant";  
		
		RechargeInfo = "";
		Если Выборка.Recharge Тогда 
			
			Если Выборка.RechargeType = Перечисления.RechargeType.Internal Тогда
				RechargeInfo = "Internal: " + СокрЛП(Выборка.RechargeToLegalEntity) + ", AU:" + СокрЛП(Выборка.RechargeToAU) 
				+ ", AC:" + СокрЛП(Выборка.RechargeToActivity);
			иначеЕсли Выборка.RechargeType = Перечисления.RechargeType.External Тогда
				RechargeInfo = "External" + ?(ЗначениеЗаполнено(Выборка.ClientForRecharge), ": " + СокрЛП(Выборка.ClientForRecharge) + " ", "") 
				+ ?(ЗначениеЗаполнено(Выборка.AgreementForRecharge), СокрЛП(Выборка.AgreementForRecharge), "");
			КонецЕсли;
			
		КонецЕсли;
		ПараметрыОбласти.Shipping_Instructions = RechargeInfo;
		ПараметрыОбласти.ArrivalLocalTimeSource = Выборка.ArrivalLocalTimeSource;
		ПараметрыОбласти.DepartureLocalTimeSource = Выборка.DepartureLocalTimeSource;
		ПараметрыОбласти.ArrivalLocalTimeDestination = Выборка.ArrivalLocalTimeDestination;
		ПараметрыОбласти.DepartureLocalTimeDestination = Выборка.DepartureLocalTimeDestination;
		ПараметрыОбласти.Requestor = СокрЛП(Выборка.Requestor);
		ПараметрыОбласти.Items = ПолучитьНаименованияТоваров(Выборка.TransportRequest,Выборка.Trip);
		
		// { RGS AArsentev 05.02.2018
		ApproveInformation = ПолучитьApprove(Выборка.Trip);
		
		ПараметрыОбласти.Approve = ApproveInformation.Approved;
		
		Если ApproveInformation.Свойство("InformationForApproval") Тогда
			ПараметрыОбласти.InformationForApproval = ApproveInformation.InformationForApproval;
		КонецЕсли;
		// } RGS AArsentev 05.02.2018
		
		ТабДок.Вывести(ОбластьСтрока);
		
		НомерПП = НомерПП + 1;
		 				
	КонецЦикла;
	//{ RGS AArsentev 13.12.2017 S-I-0004211
	КонецЦикла;
	//} RGS AArsentev 13.12.2017 S-I-0004211
	
	МассивТабДок.Добавить(ТабДок);

	Возврат МассивТабДок;   	
	
КонецФункции

&НаКлиенте
Процедура FillByRentalTrucks(Команда)
	
	СтруктураНастройки = Новый Структура;
	СтруктураНастройки.Вставить("Имя", "ВыборИзRentalTrucks");
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("СтруктураНастройки", СтруктураНастройки);
	СтруктураПараметров.Вставить("РежимВыбора", Истина);
	СтруктураПараметров.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Документ.RentalTrucksCostsSums.ФормаВыбора", СтруктураПараметров, Элементы.Trips, Элементы.Trips, 
	ВариантОткрытияОкна.ОтдельноеОкно, , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "НеобходимоПеречитать" 
		И Источник = Объект.Ссылка Тогда
		ЭтаФорма.Прочитать();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Оповестить("НеобходимоПеречитать", , Объект.Ссылка);
	Для Каждого СтрокаДанных ИЗ Объект.Trips Цикл
		ОповеститьОбИзменении(СтрокаДанных.Trip);
	КонецЦикла;
	
КонецПроцедуры

//{ RGS ASeryakov 16/11/2017 12:00:00 AM S-I-0003904
#Область RGSASeryakov

&НаКлиенте
Процедура POsPONoПриИзменении(Элемент)
	
	ПроверитьМаскуКода();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоответствуетМаскеPONo(ТекущееЗначение, НомерСтроки, ОписаниеОшибки)
	// Маска PONo,	XRSU00166A- кол-во знаков 10,	XRSU-буквенно-числовой код,	00166-числовой код,	A-постфикс
	
	БуквенноЧисловойКод = Лев(ТекущееЗначение, 4);
	ЧисловойКод = Сред(ТекущееЗначение,5,5);
	Постфикс = Прав(ТекущееЗначение,1);
	
	ДопустимыеСимволы = ВРег("abcdefghijklmnopqrstuvwxyz") + "0123456789";
	
	ОбъектОбработки = Обработки.rgsЗагрузкаДанныхИзExcel.Создать();
	
	Если ОбъектОбработки.ПроверитьНедопустимыеСимволы(ДопустимыеСимволы, БуквенноЧисловойКод) Тогда
		
		Если СтрДлина(БуквенноЧисловойКод)>1 Тогда
			
			Параметр2 = НСтр("ru = 'установлены недопустимые символы'; en = 'has invalid characters'");
			
		Иначе
			
			Параметр2 = НСтр("ru = 'установлен недопустимый символ'; en = 'is invalid characte'");
			
		КонецЕсли;
		
		ШаблонОшибки = НСтр("ru = 'Для кода %1 %2 в буквенно-числовом коде: '; en = 'Code %1 %2 in an alphanumeric code '") + БуквенноЧисловойКод + "!";
		ОписаниеОшибки = СтрШаблон(ШаблонОшибки, ТекущееЗначение, Параметр2);
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Если СтроковыеФункцииКлиентСервер.СтрокаВЧисло(ЧисловойКод) = Неопределено Тогда
		
		ШаблонОшибки = НСтр("ru = 'Для кода %1 установлен недопустимый символ в числовом коде: '; en = 'Code %1 is invalid character in an numeric code '") + ЧисловойКод + "!";
		ОписаниеОшибки = СтрШаблон(ШаблонОшибки, ТекущееЗначение);
		
		Возврат Ложь;
		
	КонецЕсли;
	
	ДопустимыеСимволы = ВРег("abcdefghijklmnopqrstuvwxyz");
	
	Если ОбъектОбработки.ПроверитьНедопустимыеСимволы(ДопустимыеСимволы, Постфикс) Тогда
		
		ШаблонОшибки = НСтр("ru = 'Для кода %1 постфиксом должна быть английская заглавная буква - %2!'; en = 'Code %1 postfix must be english uppercase letter - %2!'");
		ОписаниеОшибки = СтрШаблон(ШаблонОшибки, ТекущееЗначение, Постфикс);
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьНаСоответствиеМаске()

&НаКлиенте
Процедура ПроверитьМаскуКода()
	
	ОписаниеОшибки = "";
	ТекущееЗначение = Элементы.POs.ТекущиеДанные.PONo;
	НомерСтроки = Элементы.POs.ТекущиеДанные.НомерСтроки;
	
	Если НЕ СоответствуетМаскеPONo(ТекущееЗначение, НомерСтроки,ОписаниеОшибки) Тогда
		
		ТекстСообщения = НСтр("ru = 'PONo не соответствует формату номера PO!'; en = 'PONo does not match the number format of the PO!'") +" "+ ОписаниеОшибки;;
		
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
		Объект.POs[НомерСтроки-1].PONo = "";
		
	КонецЕсли;
	
КонецПроцедуры // ПроверитьМаскуКода()

&НаКлиенте
Процедура LoadFromExcel(Команда)
	
	ЗагрузитьДанные();
	
КонецПроцедуры

#Область ДиалогВыбораФайлаExcel

&НаКлиенте
Процедура ЗагрузитьДанные()
	
	Если Объект.POs.Количество() = 0 Тогда
		ТекстСообщения = НСтр("ru = 'Не заполнена таблица ""POs"" для загрузки данных ""GR""!'; en = 'Not filled table ""POs"" to load the data ""GR""!'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	Иначе
		
		ПоказатьВопрос(
		Новый ОписаниеОповещения("LoadData", 
		ЭтотОбъект, ),
		"Выполнить заполнение данных из Excel?", 
		РежимДиалогаВопрос.ДаНет,
		60,
		КодВозвратаДиалога.Нет,
		,
		КодВозвратаДиалога.Нет);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура LoadData(Результат, Параметр) Экспорт 
	
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Файлы xlsx (*.xlsx)'") + "|*.xlsx" );
	НастройкиДиалога.Вставить("Rental", ЭтотОбъект);
	
	// Фильтр на загружаемые поля, ПредставлениеПолей - задается именами из файла через запятую
	ПредставлениеПолей = "PO Number";
	
	
	Если СтрНайти(ПредставлениеПолей, ",") <> 0 Тогда
		
		МассивПолейОтбора = СтрРазделить(ПредставлениеПолей, ",", Ложь);
		УдалитьНедопустимыеСимволыВМассиве(МассивПолейОтбора);
		
	Иначе
		
		УдалитьНедопустимыеСимволыВСтроке(ПредставлениеПолей);
		МассивПолейОтбора = Новый Массив;
		МассивПолейОтбора.Добавить(ПредставлениеПолей);
		
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("ПоляОтбора", МассивПолейОтбора);
	
	// Если отбор по полям не накладывается ДополнительныеПараметры передается как пустая структура.
	Оповещение = Новый ОписаниеОповещения("LoadFile", ЭтотОбъект,ДополнительныеПараметры);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, НастройкиДиалога, Новый УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура LoadFile(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	Если Модифицированность Тогда
		
		ТекстСообщения = НСтр("ru = 'Необходимо записать документ для загрузки данных ""GR""!'; en = 'You must save the document to load data ""GR""!'");
		Предупреждение(ТекстСообщения);
		
	Иначе
		
		АдресФайла = РезультатПомещенияФайлов.Хранение;
		
		Если СтрНайти(РезультатПомещенияФайлов.Имя, "GRs YTD") = 0 Тогда
			
			ТекстСообщения = НСтр("ru = 'Файл не предназначен для загрузки данных ""GR""!'; en = 'File is not designed to load data ""GR""!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Иначе
			
			РасширениеФайла = "xlsx";
			ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьДанныеНаСервере(АдресФайла, РасширениеФайла, ДополнительныеПараметры)
	
	ЕстьGR = Ложь;
	
	ОбъектОбработки = Обработки.rgsЗагрузкаДанныхИзExcel.Создать();
	Таблица = ОбъектОбработки.ЗагрузитьДанные(АдресФайла, РасширениеФайла, ДополнительныеПараметры);
	
	ТаблицаДокумента = Объект.POs.Выгрузить();
	
	Результат = Документы.APInvoice.ПодготовитьДанныеТаблиц(Таблица, ТаблицаДокумента, ДополнительныеПараметры, ЕстьGR);
	
	
	Если НЕ Результат.Пустой() Тогда
		
		ТаблицаРезультат = Результат.Выгрузить();
		
		Если ЕстьGR Тогда
		
			Объект.POs.Загрузить(ТаблицаРезультат);
			Модифицированность = Истина;
		Иначе
			
			ТекстСообщения = НСтр("ru = 'Данных для загрузки ""GR"" не обнаружено!'; en = 'Data to load ""GR"" was not found!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			
		КонецЕсли;
		
	КонецЕсли;
	
	
КонецПроцедуры // ЗагрузитьДанныеНаСервере()

&НаСервереБезКонтекста
Процедура УдалитьНедопустимыеСимволыВМассиве(МассивПолей)
	
	ОбъектОбработки = Обработки.rgsЗагрузкаДанныхИзExcel.Создать();
	
	Для Индекс=0 ПО МассивПолей.Количество()-1 Цикл
		
		Элемент = МассивПолей[Индекс];
		ОбъектОбработки.УдалитьНедопустимыеСимволы(Элемент);
		МассивПолей.Установить(Индекс,Элемент);
		
	КонецЦикла;
	
КонецПроцедуры // УдалитьНедопустимыеСимволы()

&НаСервереБезКонтекста
Процедура УдалитьНедопустимыеСимволыВСтроке(Строка)
	
	ОбъектОбработки = Обработки.rgsЗагрузкаДанныхИзExcel.Создать();
	
	ОбъектОбработки.УдалитьНедопустимыеСимволы(Строка);
	
КонецПроцедуры // УдалитьНедопустимыеСимволы()

&НаСервере
Функция ПолучитьНаименованияТоваров(TR, Trip)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ParcelsДетали.СтрокаИнвойса.DescriptionRus КАК DescriptionRus
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsДетали
	               |		ПО TripNonLawsonCompaniesParcels.Parcel = ParcelsДетали.Ссылка
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR
	               |	И TripNonLawsonCompaniesParcels.Ссылка = &Trip
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ParcelsДетали.СтрокаИнвойса.DescriptionRus";
	Запрос.УстановитьПараметр("TR",TR);
	Запрос.УстановитьПараметр("Trip",Trip);
	
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() = 0 Тогда
		Возврат "";
	Иначе
		Возврат РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Результат, "DescriptionRus"),", ");
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция ПолучитьApprove(Trip)
	
	РеквизитыTrip = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Trip, "Дата,CostsPlanning,BaseCostsSumSLBUSD,ZeroBaseCostsSum,TotalAccessorialCostsSum,BaseCostsSum");
	СтруктураBaseCostsSumLimit = РегистрыСведений.BaseCostsSumLimitForApproval.ПолучитьПоследнее(РеквизитыTrip.Дата);
	LimitForApproval = ?(РеквизитыTrip.CostsPlanning = Перечисления.TypesOfCostsPlanning.Automatic, 
		СтруктураBaseCostsSumLimit.LimitForApprovalLevel1AutomaticPlanning, СтруктураBaseCostsSumLimit.LimitForApprovalLevel1ManualPlanning);
		
		ApproveInformation = Новый Структура;
		
		Если РеквизитыTrip.ZeroBaseCostsSum
			ИЛИ РеквизитыTrip.BaseCostsSumSLBUSD > LimitForApproval 
			ИЛИ РеквизитыTrip.TotalAccessorialCostsSum > (РеквизитыTrip.BaseCostsSum / 2) Тогда 
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			|	TripsNonLawsonApproval.ApprovalManager,
			|	TripsNonLawsonApproval.InformationForApproval
			|ИЗ
			|	Задача.TripsNonLawsonApproval КАК TripsNonLawsonApproval
			|ГДЕ
			|	TripsNonLawsonApproval.Выполнена
			|	И TripsNonLawsonApproval.Status = ЗНАЧЕНИЕ(Перечисление.StatusesOfApproval.Approved)
			|	И НЕ TripsNonLawsonApproval.ПометкаУдаления
			|	И TripsNonLawsonApproval.Trip = &Trip";
			Запрос.УстановитьПараметр("Trip",Trip);
			
			Результат = Запрос.Выполнить();
			
			Если НЕ Результат.Пустой() Тогда
				Выборка = Результат.Выбрать();
				Выборка.Следующий();
				ApproveInformation.Вставить("Approved", "Approved by " + СокрЛП(Выборка.ApprovalManager));
				ApproveInformation.Вставить("InformationForApproval", СокрЛП(Выборка.InformationForApproval));
			Иначе
				ApproveInformation.Вставить("Approved", "Approval is required");
			КонецЕсли;
			
		Иначе
			
			Если РеквизитыTrip.BaseCostsSumSLBUSD < 500 Тогда
				ApproveInformation.Вставить("Approved", "Automatic approve, sum less 500 USD");
			Иначе
				ApproveInformation.Вставить("Approved", "Automatic approve, sum less " + LimitForApproval + " USD");
			КонецЕсли;
			
		КонецЕсли;
		
		Возврат ApproveInformation;
		
КонецФункции
#КонецОбласти

&НаСервере
Функция ОпределитьTaxonomy(Trip)
	
	MOT = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "MOT");
	КодМот = СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(MOT, "Код"));
	
	Если КодМот = "SEA" Тогда
		Возврат "CLBABB01-Barge Bulk";
	ИначеЕсли КодМот = "AIR" ИЛИ КодМот = "COURIER" Тогда
		Возврат "CLFFAC01-Air Cargo";
	ИначеЕсли КодМот = "RAIL" Тогда
		Возврат "CLRARH01-Rail Hopper Car/Rail Transloading";
	ИначеЕсли КодМот = "TRUCK" Тогда
		Возврат "CLTRTV02- Truckload-Van/Flat Bed";
	Иначе
		Taxonomy = ПолучитьTaxonomyПоКлассуОпасности(Trip);
		Возврат Taxonomy;
	КонецЕсли;
	
КонецФункции

Функция ПолучитьTaxonomyПоКлассуОпасности(Trip)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	TripNonLawsonCompaniesParcels.Parcel.HazardClass.Код КАК HazardClass
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|ГДЕ
	|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
	|
	|СГРУППИРОВАТЬ ПО
	|	TripNonLawsonCompaniesParcels.Parcel.HazardClass.Код";
	Запрос.УстановитьПараметр("Trip",Trip);
	Результат = Запрос.Выполнить().Выгрузить();
	
	МассивHazardClass = Результат.ВыгрузитьКолонку("HazardClass");
	Hazard_Non = МассивHazardClass.Найти("Non");
	Hazard_9 = МассивHazardClass.Найти("9");
	Hazard_7 = МассивHazardClass.Найти("7");
	
	Если Hazard_7 <> Неопределено Тогда
		Возврат "CLTHRT01-Radioactive Sources Transportation";
	ИначеЕсли Hazard_Non = Неопределено ИЛИ Hazard_Non <> Hazard_9 Тогда
		Возврат "CLTHDT01-Dangerous Goods Transportation";
	Иначе 
		Возврат "";
	КонецЕсли;
	
КонецФункции

// { RGS AArsentev 07.06.2018 S-I-0005386
Процедура ОбновитьДатуВыгрузки()
	
	Объект.UploadDate = ТекущаяДата();
	Записать();
	
КонецПроцедуры // } RGS AArsentev 07.06.2018 S-I-0005386

// { RGS riet_test_ru0149app35 25.10.2018 10:07:12 - S-I-0005850
&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеВидимостью(Форма, Объект)
	
	Элементы = Форма.Элементы;
	
	Элементы.FiscalInvoiceNo.Видимость = (Объект.FiscalInvoiceNoNeeded = ПредопределенноеЗначение("Перечисление.YesNo.Yes"));
	
КонецПроцедуры

&НаКлиенте
Процедура FiscalInvoiceNoNeededПриИзменении(Элемент)
	УправлениеВидимостью(ЭтаФорма, Объект);
КонецПроцедуры
// } RGS riet_test_ru0149app35 25.10.2018 10:09:00 - S-I-0005850
#КонецОбласти