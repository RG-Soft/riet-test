
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	      		
	ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ModificationDate = ТекущаяДата();

	ЭтоAP_Invoice = (TransportationRegisterType = Перечисления.TransportationRegisterType.AP_Invoice); 		
	ЭтоSWPS_PO = (TransportationRegisterType = Перечисления.TransportationRegisterType.SWPS_PO);
	
	Если Не ЗначениеЗаполнено(TransportationRegisterType) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Type"" не заполнено!",
		ЭтотОбъект, "TransportationRegisterType", , Отказ);
		
	иначе
		
		Если ЭтоAP_Invoice Тогда 
			OneClickRequestPONo = Неопределено;
		ИначеЕсли ЭтоSWPS_PO Тогда 
			InvoiceNumber = Неопределено;
			BookedToERP_date = Неопределено;
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Company) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Company"" не заполнено!",
		ЭтотОбъект, "Company", , Отказ);
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(LegalEntity) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Legal entity"" не заполнено!",
		ЭтотОбъект, "LegalEntity", , Отказ);
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ServiceProvider) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Service provider"" не заполнено!",
		ЭтотОбъект, "ServiceProvider", , Отказ);
		
	КонецЕсли;
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда  
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(SumVAT) И Не ЗначениеЗаполнено(SumVAT) И Не ЗначениеЗаполнено(SumVAT) И Trips.Итог("Sum") = 0 Тогда
	Иначе
		
		Если Не ЗначениеЗаполнено(SumVAT) тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Sum w/o VAT"" не заполнено!",
			ЭтотОбъект, "SumVAT", , Отказ);
			
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(SumWithVAT) тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Sum with VAT"" не заполнено!",
			ЭтотОбъект, "SumWithVAT", , Отказ);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(SumWithVAT)
			И ЗначениеЗаполнено(SumVAT)
			И SumWithVAT <> SumVAT + VAT Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sum with VAT"" не равно ""Sum w/o VAT"" + ""VAT""!",
			ЭтотОбъект, "VAT", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
	Если Trips.Количество() = 0 Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Список ""Trips"" не заполнен!",
		ЭтотОбъект, "Trips", , Отказ);
		
	Иначе
		
		Если SumVAT <> Trips.Итог("Sum") Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sum with VAT"" не сходится с общей суммой по трипам",
			ЭтотОбъект, "SumWithVAT", , Отказ);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЭтоAP_Invoice И Не ЗначениеЗаполнено(InvoiceNumber) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Invoice number"" не заполнено!",
		ЭтотОбъект, "InvoiceNumber", , Отказ);
		
	КонецЕсли;
	         	
	Если Не ЗначениеЗаполнено(FiscalInvoiceNo) И FiscalInvoiceNoNeeded = Перечисления.YesNo.Yes тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Fiscal no."" не заполнено!",
		ЭтотОбъект, "FiscalInvoiceNo", , Отказ);
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(FiscalInvoiceDate) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Fiscal date"" не заполнено!",
		ЭтотОбъект, "FiscalInvoiceDate", , Отказ);
		
	КонецЕсли;        		
	
	Если Не ЗначениеЗаполнено(Received) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Received"" не заполнено!",
		ЭтотОбъект, "Received", , Отказ);
		
	КонецЕсли;
	
	Если ЭтоAP_Invoice И Не ЗначениеЗаполнено(BookedToERP_date) тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Поле ""Booked to ERP date"" не заполнено!",
		ЭтотОбъект, "BookedToERP_date", , Отказ);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(LegalEntity) И ЗначениеЗаполнено(ServiceProvider) тогда
		
		Трипы = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Trips, "Trip");
		
		Для Каждого Трип Из Трипы Цикл
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("Trip", Трип);
			Запрос.УстановитьПараметр("ServiceProvider", ServiceProvider);
			Запрос.УстановитьПараметр("LegalEntity", LegalEntity);
			
			//{ RGS AArsentev 13.12.2017 S-I-0004211
			Если Трип.Secondary Тогда
				Запрос.Текст = "ВЫБРАТЬ
				|	TripNonLawsonCompanies.Ссылка.ServiceProvider КАК ServiceProvider,
				|	TripNonLawsonCompanies.Ссылка КАК Trip,
				|	TripNonLawsonCompanies.Ссылка.VerifiedByBillingSpecialist КАК VerifiedByBillingSpecialist,
				|	TripNonLawsonCompanies.Ссылка.SecondaryLegalEntity КАК SecondaryLegalEntity
				|ИЗ
				|	Документ.TripNonLawsonCompanies КАК TripNonLawsonCompanies
				|ГДЕ
				|	TripNonLawsonCompanies.Ссылка = &Trip
				|	И TripNonLawsonCompanies.SecondaryLegalEntity = &LegalEntity
				|	И TripNonLawsonCompanies.ServiceProvider = &ServiceProvider
				|
				|СГРУППИРОВАТЬ ПО
				|	TripNonLawsonCompanies.Ссылка.ServiceProvider,
				|	TripNonLawsonCompanies.Ссылка.VerifiedByBillingSpecialist,
				|	TripNonLawsonCompanies.Ссылка,
				|	TripNonLawsonCompanies.Ссылка.SecondaryLegalEntity";
			Иначе
			//} RGS AArsentev 13.12.2017 S-I-0004211
				Запрос.Текст = "ВЫБРАТЬ
				|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider КАК ServiceProvider,
				|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
				|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity КАК LegalEntity,
				|	TripNonLawsonCompaniesParcels.Ссылка.VerifiedByBillingSpecialist КАК VerifiedByBillingSpecialist
				|ИЗ
				|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
				|ГДЕ
				|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
				|	И TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider = &ServiceProvider
				|	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity = &LegalEntity
				|
				|СГРУППИРОВАТЬ ПО
				|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider,
				|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.LegalEntity,
				|	TripNonLawsonCompaniesParcels.Ссылка.VerifiedByBillingSpecialist,
				|	TripNonLawsonCompaniesParcels.Ссылка";
			//{ RGS AArsentev 13.12.2017 S-I-0004211
			КонецЕсли;
			//} RGS AArsentev 13.12.2017 S-I-0004211
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Service provider либо Legal entity в " + СокрЛП(Трип) + " отличается от указанного в документе!",
				ЭтотОбъект, , , Отказ);
			Иначе
				//Выборка = Результат.Выбрать();
				//Пока Выборка.Следующий() Цикл
				//	Если Не ЗначениеЗаполнено(Выборка.VerifiedByBillingSpecialist) тогда
				//		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				//		"" + СокрЛП(Выборка.Trip) + " is not verified by billing specialist!",
				//		ЭтотОбъект, , , Отказ);
				//	КонецЕсли;
				//КонецЦикла;
			КонецЕсли;
		КонецЦикла;
				
	КонецЕсли;
	
	Если НЕ Отказ Тогда	
		Отказ = ПроверитьТЧ_Trip();		
	КонецЕсли;	
		 	
КонецПроцедуры

Функция ПроверитьТЧ_Trip()
	
	Ошибка = 0;
	Трипы = Trips.Выгрузить();
	Трипы.Колонки.Добавить("КолВо");
	//Проверка на Трипы использованные в других доках
	Для Каждого Элемент из Трипы Цикл
		
		Дубль = Документы.APInvoice.ПроверитьТрип(Элемент.Trip, Ссылка, LegalEntity);
		Если Дубль Тогда
			Ошибка = Ошибка + 1;
		КонецЕсли;
		
		Элемент.КолВо = 1;
	КонецЦикла;
	Трипы.Свернуть("Trip", "КолВо");
	//Проверим на дубли в ТЧ
	Для Каждого Строка из Трипы Цикл
		Если Строка.КолВо = 1 Тогда
			Продолжить
		Иначе
			Сообщить("Есть дубли по - "+Строка.Trip);
			Ошибка = Ошибка + 1;
		КонецЕсли		
	КонецЦикла;
	
	Если Ошибка = 0 Тогда
		Возврат  Ложь
	Иначе
		Возврат Истина
	КонецЕсли;
	
КонецФункции

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если Не Отказ Тогда
		
		Если TransportationRegisterType = Перечисления.TransportationRegisterType.SWPS_PO Тогда
			УстановитьПривилегированныйРежим(Истина);
			Для Каждого Трип Из Trips Цикл
				
				ДокТрип = Трип.Trip.ПолучитьОбъект();
				ДокТрип.ОбменДанными.Загрузка = Истина;
				ДокТрип.VerifiedByBillingSpecialist = Дата;
				ДокТрип.BillingSpecialist = ПараметрыСеанса.ТекущийПользователь;
				ЕстьЗаписьBill = ПроверитьТаблицуBill(Трип.Trip);
				
				Если Не ЕстьЗаписьBill Тогда
					ДокСтрокаBill = ДокТрип.Bills.Добавить();
					ДокСтрокаBill.Bill = "SWPS PO - " + Номер;
				КонецЕсли;
				ДокТрип.Записать();
				
			КонецЦикла;
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;
		
	КонецЕсли;
	
	
КонецПроцедуры

Функция ПроверитьТаблицуBill(Трип)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	TripNonLawsonCompaniesBills.НомерСтроки КАК НомерСтроки
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Bills КАК TripNonLawsonCompaniesBills
	|ГДЕ
	|	TripNonLawsonCompaniesBills.Ссылка = &Трип
	|	И TripNonLawsonCompaniesBills.Bill ПОДОБНО &Bill";
	Запрос.УстановитьПараметр("Трип", Трип);
	Запрос.УстановитьПараметр("Bill", "%" + Номер + "%");
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	Если ЗначениеЗаполнено(BORG) Тогда 
		Префикс = СокрЛП(BORG);	
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	//// { RGS riet_test_ru0149app35 25.10.2018 10:07:12 - S-I-0005850
	//Если FiscalInvoiceNoNeeded = Перечисления.YesNo.No
	//	или FiscalInvoiceNoNeeded = Перечисления.YesNo.ПустаяСсылка() Тогда
	//	ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("FiscalInvoiceNo"));
	//КонецЕсли;
	//// } RGS riet_test_ru0149app35 25.10.2018 10:09:00 - S-I-0005850	
КонецПроцедуры




