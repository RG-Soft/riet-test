
Функция ПолучитьСтруктуруCompanySettings(Company, ДатаTransportRequest) Экспорт 
	
	СтруктураCompanySettings = Новый Структура(
		"InTMS, DefaultLegalEntity, DefaultCostCenter, SpecifyCostCenter, SpecifySegment, SpecifyProductLine, SpecifyAgreementForRecharge, SpecifyAcquisitionCost, UseCostCenterFromLegalEntityForNON_PO",
		Ложь, Неопределено, Неопределено, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь);
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаTransportRequest", ДатаTransportRequest);
	Запрос.УстановитьПараметр("Company", Company);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.DefaultLegalEntity,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.SpecifySegment,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.SpecifyAgreementForRecharge,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.SpecifyCostCenter,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.SpecifyProductLine,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.SpecifyAcquisitionCost,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.InTMS,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.DefaultCostCenter,
	               |	LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних.UseCostCenterFromLegalEntityForNON_PO
	               |ИЗ
	               |	РегистрСведений.LocalDistributionSettingsForNonLawsonCompanies.СрезПоследних(&ДатаTransportRequest, Company = &Company) КАК LocalDistributionSettingsForNonLawsonCompaniesСрезПоследних";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		
		ЗаполнитьЗначенияСвойств(СтруктураCompanySettings, Выборка);
		
	КонецЕсли;

	Возврат СтруктураCompanySettings;	
	
КонецФункции

Функция РазрешеноРедактироватьAcceptedTransportRequest(Ссылка, МассивParcels=Неопределено) экспорт
	
	// сначала проверим права на редактирование
	РазрешеноРедактированиеTR = (РольДоступна("LocalDistributionAdministrator_ForNonLawsonCompanies")
		ИЛИ РольДоступна("LocalDistributionSpecialist_ForNonLawsonCompanies")
		ИЛИ РольДоступна("LocalDistributionBillingSpecialist_ForNonLawsonCompanies"));
		
	Если Не РазрешеноРедактированиеTR Тогда 
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ТекстОшибки = "Нельзя вносить изменения в заявку, принятую специалистом!";
		иначе
			ТекстОшибки = "It is not allowed to change accepted by specialist transport request!";
		КонецЕсли;

		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);
		Возврат Ложь;
		
	КонецЕсли;
	
	Если МассивParcels = Неопределено Тогда 
		Возврат Истина;
	КонецЕсли;
	
	// проверим нет ли уже проведенных трипов
	СсылкаВПроведенномTrip = Ложь;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивParcels", МассивParcels);
	
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	               |	TripNonLawsonCompaniesParcels.Ссылка КАК Trip
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Parcel В(&МассивParcels)
	               |	И TripNonLawsonCompaniesParcels.Ссылка.Проведен";
	
	Выборка = Запрос.Выполнить().Выбрать();
	          		
	Пока Выборка.Следующий() Цикл 
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
			ТекстОшибки = "Нельзя вносить изменения в " + СокрЛП(Ссылка) + ",
			|т.к. он уже добавлен в проведенную поставку: " + СокрЛП(Выборка.Trip) + "!";
		иначе
			ТекстОшибки = "It is not allowed to change " + СокрЛП(Ссылка) + ",
			|it is in posted trip: " + СокрЛП(Выборка.Trip) + "!";
		КонецЕсли;

		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстОшибки);

		СсылкаВПроведенномTrip = Истина;
		
	КонецЦикла;
	
	Возврат Не СсылкаВПроведенномTrip;
	  	 	
КонецФункции

// ПЕЧАТНЫЕ ФОРМЫ

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	               		
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ExportInvoice") тогда
		
		ТабДокумент = ПечатьExportInvoice(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ExportInvoice",
				"Export invoice", ТабДокумент);
				
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ТранспортнаяНакладная") тогда
		
		ТабДокумент = Документы.TripNonLawsonCompanies.ПечатьТранспортнаяНакладная(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ТранспортнаяНакладная",
		"Транспортная накладная N4", ТабДокумент);
		
	ИначеЕсли УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаявкаНаТранспортировкуПоРоссии") тогда
		
		ТабДокумент = ПечатьЗаявкаНаТранспортировкуПоРоссии(МассивОбъектов, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "ЗаявкаНаТранспортировкуПоРоссии",
		"Заявка на транспортировку по России", ТабДокумент);
		
	КонецЕсли;

КонецПроцедуры

Функция ПечатьExportInvoice(МассивОбъектов, ОбъектыПечати) 
	
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.КлючПараметровПечати = "ExportInvoice";
	
	Макет = ПолучитьМакет("ExportInvoice");
	
	Для Каждого TransportRequest из МассивОбъектов Цикл 
		
		ТекстЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 1
		               |	TransportRequest.DeliverTo.Наименование КАК DeliverToName,
		               |	TransportRequest.DeliverToAddress КАК DeliverToAddress,
		               |	TransportRequest.DeliverTo.City КАК DeliverToCity,
		               |	TransportRequest.DeliverTo.RCACountry КАК DeliverToCountryCode,
		               |	TransportRequest.DeliverToContact КАК DeliverToContact,
		               |	TransportRequest.DeliverToPhone КАК DeliverToPhone,
		               |	TransportRequest.DeliverToEmail КАК DeliverToEmail,
		               |	TransportRequest.SegmentLawson.Код КАК SegmentCode,
		               |	TransportRequest.Company.CompanyNo КАК CompanyNo,
		               |	TransportRequest.Incoterms.Код КАК IncotermsCode,
		               |	ВЫБОР
		               |		КОГДА TransportRequest.ActivityLawson = ЗНАЧЕНИЕ(справочник.ActivityCodes.пустаяссылка)
		               |			ТОГДА TransportRequest.Activity
		               |		ИНАЧЕ TransportRequest.ActivityLawson
		               |	КОНЕЦ КАК Activity,
		               |	TransportRequest.ConsignTo.Наименование КАК ConsignToName,
		               |	TransportRequest.ConsignTo.SoldToAddress КАК ConsignToAddress,
		               |	TransportRequest.LegalEntity.Наименование КАК LegalEntityName,
		               |	TransportRequest.LegalEntity.SoldToAddress КАК LegalEntityAddress,
		               |	TransportRequest.PickUpWarehouse.Наименование КАК PickUpWarehouseName,
		               |	TransportRequest.PickUpFromAddress КАК PickUpAddress,
		               |	TransportRequest.PickUpWarehouse.City КАК PickUpCity,
		               |	TransportRequest.PickUpWarehouse.RCACountry КАК PickUpCountryCode,
		               |	TransportRequest.PickUpFromContact КАК PickUpFromContact,
		               |	TransportRequest.PickUpFromPhone КАК PickUpFromPhone,
		               |	TransportRequest.PickUpFromEmail КАК PickUpFromEmail,
		               |	TransportRequest.Номер,
		               |	TransportRequest.Дата,
		               |	TransportRequest.CostCenter.Код КАК AUCode,
		               |	BORGs.Код КАК BORGCode,
		               |	TransportRequest.Shipper.Наименование КАК ShipperName,
		               |	TransportRequest.Shipper.SoldToAddress КАК ShipperAddress,
		               |	TransportRequest.CustomUnionTransaction
		               |ИЗ
		               |	Документ.TransportRequest КАК TransportRequest
		               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.BORGs КАК BORGs
		               |		ПО TransportRequest.Company = BORGs.Компания
		               |			И TransportRequest.CostCenter = BORGs.DefaultAU
		               |			И (НЕ BORGs.ПометкаУдаления)
		               |ГДЕ
		               |	TransportRequest.Ссылка = &TransportRequest
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	Items.Ссылка КАК Item,
		               |	Items.НомерСтрокиИнвойса КАК ItemNo,
		               |	Items.НаименованиеТовара КАК ItemDescription,
		               |	Items.DescriptionRus КАК ItemDescriptionRUS,
		               |	Items.СерийныйНомер КАК SerialNo,
		               |	Items.СтранаПроисхождения КАК CountryOO,
		               |	Items.КодПоИнвойсу КАК PartNo,
		               |	Items.Количество КАК QTY,
		               |	Items.ЕдиницаИзмерения КАК UOM,
		               |	Items.NetWeight,
		               |	Items.Цена КАК UnitPrice,
		               |	Items.Сумма КАК TotalValue,
		               |	Items.TNVED КАК HTC,
		               |	Items.RAN,
		               |	Items.Currency
		               |ИЗ
		               |	Справочник.СтрокиИнвойса КАК Items
		               |ГДЕ
		               |	Items.TransportRequest = &TransportRequest
		               |	И НЕ Items.ПометкаУдаления
		               |
		               |УПОРЯДОЧИТЬ ПО
		               |	ItemNo
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	Parcels.Ссылка.GrossWeightKG КАК WeightKG,
		               |	Parcels.Ссылка.LengthCM КАК LengthCM,
		               |	Parcels.Ссылка.WidthCM КАК WidthCM,
		               |	Parcels.Ссылка.HeightCM КАК HeightCM,
		               |	Parcels.Ссылка.PackingType.Код КАК PackageType,
		               |	Parcels.HazardClass КАК HazardClass,
		               |	Parcels.CubicMeters КАК CubicMeters,
		               |	Parcels.Код КАК PackageNumber,
		               |	Parcels.NumOfParcels КАК Qty
		               |ИЗ
		               |	Справочник.Parcels КАК Parcels
		               |ГДЕ
		               |	Parcels.TransportRequest = &TransportRequest
		               |	И НЕ Parcels.Отменен
		               |
		               |УПОРЯДОЧИТЬ ПО
		               |	PackageNumber
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ParcelItems.СтрокаИнвойса КАК Item,
		               |	ParcelItems.Ссылка.Код КАК PackageNumber
		               |ИЗ
		               |	Справочник.Parcels.Детали КАК ParcelItems
		               |ГДЕ
		               |	ParcelItems.Ссылка.TransportRequest = &TransportRequest
		               |	И НЕ ParcelItems.Ссылка.Отменен";
		
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("TransportRequest", TransportRequest);
		
		НомерСтрокиНачало = ТабДок.ВысотаТаблицы + 1;
		
		УстановитьПривилегированныйРежим(Истина);
		Результаты = Запрос.ВыполнитьПакет();
		
		ВыборкаШапки = Результаты[0].Выбрать();
		ВыборкаШапки.Следующий();
		
		ВыборкаItems = Результаты[1].Выбрать();
		
		ВыборкаParcels = Результаты[2].Выбрать();
		
		ТаблицаPackageNumbers = Результаты[3].Выгрузить();
		ТаблицаPackageNumbers.Индексы.Добавить("Item");
		
		// Шапка
		ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
		ПараметрыШапки = ОбластьШапка.Параметры;
		
		// Ship-To
		ПараметрыШапки.ShipToName = ВыборкаШапки.DeliverToName;
		
		ПараметрыШапки.ShipToAddress = ВыборкаШапки.DeliverToAddress + ", "
			+ ВыборкаШапки.DeliverToCity + ", "
			+ ВыборкаШапки.DeliverToCountryCode;
		
		ПараметрыШапки.ShipToAttention = ВыборкаШапки.DeliverToContact + " " + ВыборкаШапки.DeliverToPhone + " " + ВыборкаШапки.DeliverToEmail;
		
		// Consign-To
		ПараметрыШапки.ConsignToName = ВыборкаШапки.ConsignToName;
		
		ПараметрыШапки.ConsignToAddress = ВыборкаШапки.ConsignToAddress;
		
		ПараметрыШапки.ConsignToAttention = ВыборкаШапки.DeliverToContact + " " + ВыборкаШапки.DeliverToPhone + " " + ВыборкаШапки.DeliverToEmail;
		
		// Shipper
		Если ВыборкаШапки.CustomUnionTransaction Тогда 
			ПараметрыШапки.ShipperName = СокрЛП(ВыборкаШапки.ShipperName); 			
			ПараметрыШапки.ShipperAddress = СокрЛП(ВыборкаШапки.ShipperAddress);
		иначе     			
			ПараметрыШапки.ShipperName = СокрЛП(ВыборкаШапки.LegalEntityName); 			
			ПараметрыШапки.ShipperAddress = СокрЛП(ВыборкаШапки.LegalEntityAddress);  			
		КонецЕсли;
		
		ПараметрыШапки.PickUpWarehouse = СокрЛП(ВыборкаШапки.PickUpWarehouseName);
		
		ПараметрыШапки.PickUpAddress = ВыборкаШапки.PickUpAddress + ", "
			+ ВыборкаШапки.PickUpCity + ", "
			+ ВыборкаШапки.PickUpCountryCode;
		
		ПараметрыШапки.ShipperContact = СокрЛП(ВыборкаШапки.PickUpFromContact) + " " + СокрЛП(ВыборкаШапки.PickUpFromPhone) + " " + СокрЛП(ВыборкаШапки.PickUpFromEmail);
		
		ПараметрыШапки.InvoiceNo = ВыборкаШапки.Номер;
		ПараметрыШапки.Date = Формат(ВыборкаШапки.Дата, "ДФ='dd.MM.yyyy'");
		
		ПараметрыШапки.AU = СокрЛП(ВыборкаШапки.AUCode);
		
		ПараметрыШапки.Segment = СокрЛП(ВыборкаШапки.SegmentCode) + " / " + СокрЛП(ВыборкаШапки.BORGCode) + "-" + ВыборкаШапки.CompanyNo + " / " + СокрЛП(ВыборкаШапки.AUCode) + " / " + ВыборкаШапки.Activity;
			
		ТабДок.Вывести(ОбластьШапка);
		
		// Items     
		ОбластьItem = Макет.ПолучитьОбласть("Items");
		ПараметрыItem = ОбластьItem.Параметры;
		TotalValueSum = 0;
		СтруктураПоиска = Новый Структура("Item");
		Пока ВыборкаItems.Следующий() цикл
			
			ЗаполнитьЗначенияСвойств(ПараметрыItem, ВыборкаItems, "ItemNo, Qty, UOM, HTC, ItemDescription, ItemDescriptionRUS, NetWeight, PartNo, SerialNo, RAN, CountryOO");
			
			СurrencyUSD = Справочники.Валюты.НайтиПоКоду("840");
			
			Если ВыборкаItems.Currency <> СurrencyUSD Тогда 
				                     				
				СтруктураСurrencyUSD = ОбщегоНазначения.ПолучитьКурсВалюты(СurrencyUSD, ВыборкаШапки.Дата);
				СтруктураСurrency = ОбщегоНазначения.ПолучитьКурсВалюты(ВыборкаItems.Currency, ВыборкаШапки.Дата);
				
				UnitPrice = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(
						ВыборкаItems.UnitPrice, ВыборкаItems.Currency, СurrencyUSD, 
						СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
					  
				TotalValue = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(
						ВыборкаItems.TotalValue, ВыборкаItems.Currency, СurrencyUSD, 
						СтруктураСurrency.Курс, СтруктураСurrencyUSD.Курс, СтруктураСurrency.Кратность, СтруктураСurrencyUSD.Кратность);
					
			иначе
				
				UnitPrice = ВыборкаItems.UnitPrice; 
				TotalValue = ВыборкаItems.TotalValue;
				
			КонецЕсли;
			
			ПараметрыItem.UnitPrice = UnitPrice; 
			ПараметрыItem.TotalValue = TotalValue; 
			
			TotalValueSum = TotalValueSum + TotalValue;
			
			PackageNumber= "";
			СтруктураПоиска.Item = ВыборкаItems.Item;
			МассивСтрок = ТаблицаPackageNumbers.НайтиСтроки(СтруктураПоиска);
			Для Каждого Стр из МассивСтрок Цикл 
				PackageNumber = PackageNumber + ", " + СокрЛП(Стр.PackageNumber);
			КонецЦикла;
			ПараметрыItem.PackageNumber = Сред(PackageNumber, 3);
			
			ТабДок.Вывести(ОбластьItem);
			
		Конеццикла;
		
		// Шапка Parcels     
		ОбластьШапкаParcels = Макет.ПолучитьОбласть("ШапкаParcels");
		ТабДок.Вывести(ОбластьШапкаParcels);
		
		// Parcels   
		ОбластьParcel = Макет.ПолучитьОбласть("Parcel");
		ПараметрыParcel = ОбластьParcel.Параметры;	
		TotalWeight = 0;
		TotalVolume = 0;
		Hazardous = "No";
		Пока ВыборкаParcels.Следующий() цикл
			
			ЗаполнитьЗначенияСвойств(ПараметрыParcel, ВыборкаParcels, "PackageNumber, Qty, PackageType, WeightKG, LengthCM, WidthCM, HeightCM");
			
			ПараметрыParcel.PackageNumber = СокрЛП(ПараметрыParcel.PackageNumber);
			
			ПараметрыParcel.VolumeSea = Окр(ВыборкаParcels.CubicMeters, 2);
			ПараметрыParcel.VolumeAir = Окр(ВыборкаParcels.CubicMeters*1000/6, 2);
			
			TotalWeight = TotalWeight + ВыборкаParcels.WeightKG;
			TotalVolume = TotalVolume + ПараметрыParcel.VolumeSea;
			
			Если ЗначениеЗаполнено(ВыборкаParcels.HazardClass) 
				И ВыборкаParcels.HazardClass <> Справочники.HazardClasses.NonHazardous Тогда
				Hazardous = "Yes";
			КонецЕсли;
			
			ТабДок.Вывести(ОбластьParcel);
			
		Конеццикла;
		
		// выведем подвал     
		ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
		ПараметрыПодвала = ОбластьПодвал.Параметры;
		
		ПараметрыПодвала.TotalWeight = TotalWeight;
		ПараметрыПодвала.TotalVolume = TotalVolume;
		ПараметрыПодвала.TotalValue = TotalValueSum;
		ПараметрыПодвала.Pieces = ВыборкаParcels.Количество();
		ПараметрыПодвала.Hazardous = Hazardous;
		ПараметрыПодвала.Incoterms = СокрЛП(ВыборкаШапки.IncotermsCode);
		
		ТабДок.Вывести(ОбластьПодвал);
		
		ТабДок.АвтоМасштаб = Истина;
		ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабДок, НомерСтрокиНачало, ОбъектыПечати, TransportRequest);
		
	КонецЦикла;  // TransportRequest
	
	Возврат ТабДок;

КонецФункции

Функция ПечатьЗаявкаНаТранспортировкуПоРоссии(МассивОбъектов, ОбъектыПечати)
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "ЗаявкаНаТранспортировкуПоРоссии";
	Макет = ПолучитьМакет("ЗаявкаНаТранспортировкуПоРоссии");
	
	Для Каждого TR из МассивОбъектов Цикл
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	TransportRequest.CustomUnionTransaction,
		               |	TransportRequest.Shipper,
		               |	TransportRequest.ConsignTo,
		               |	TransportRequest.RequestedLocalTime,
		               |	TransportRequest.ReadyToShipLocalTime,
		               |	TransportRequest.RequiredDeliveryLocalTime,
		               |	TransportRequest.Номер,
		               |	TransportRequest.PayingEntity,
		               |	TransportRequest.PickUpWarehouse,
		               |	TransportRequest.PickUpFromContact,
		               |	TransportRequest.PickUpFromPhone,
		               |	TransportRequest.PickUpFromEmail,
		               |	TransportRequest.DeliverTo,
		               |	TransportRequest.DeliverToContact,
		               |	TransportRequest.DeliverToPhone,
		               |	TransportRequest.DeliverToEmail,
		               |	TransportRequest.Comments,
		               |	TransportRequest.CostCenter,
		               |	TransportRequest.LegalEntity.NameRus,
		               |	ВЫРАЗИТЬ(TransportRequest.LegalEntity.SoldToAddressRus КАК СТРОКА(500)) КАК LegalEntityAddressRus,
		               |	TransportRequest.Activity,
		               |	TransportRequest.ActivityLawson,
		               |	TransportRequest.Requestor КАК Alias,
		               |	TransportRequest.Дата,
		               |	TransportRequest.Company,
		               |	TransportRequest.LegalEntity.CostCenter КАК LegalEntityCostCenter,
		               |	TransportRequest.AcceptedBySpecialistLocalTime,
		               |	TransportRequest.Specialist КАК Planner,
		               |	TransportRequest.LegalEntity
		               |ИЗ
		               |	Документ.TransportRequest КАК TransportRequest
		               |ГДЕ
		               |	TransportRequest.Ссылка = &TR";
		Запрос.УстановитьПараметр("TR", TR);
		Результат = Запрос.Выполнить();
		Если НЕ Результат.Пустой() Тогда
			
			НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
			УстановитьПривилегированныйРежим(Истина);
			
			Выборка = Результат.Выбрать();
			Выборка.Следующий();
			ЕстьTRIP = Ложь;
			ЗапросTrip = Новый Запрос;
			ЗапросTrip.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			                   |	TripNonLawsonCompaniesParcels.Ссылка КАК Trips,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.MOT.Наименование КАК MOT,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.EquipmentNo,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Driver,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.ContactPhoneNumberOfTheDriver,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Operator,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.CreationDate,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.TotalCostsSum,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.Currency,
			                   |	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider.NameRus КАК ServiceProvider
			                   |ИЗ
			                   |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
			                   |ГДЕ
			                   |	TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR";
			ЗапросTrip.УстановитьПараметр("TR", TR);
			РезультатTrip = ЗапросTrip.Выполнить();
			Если НЕ РезультатTrip.Пустой() Тогда
				
				ЕстьTRIP = Истина;
				ВыборкаTrip = РезультатTrip.Выгрузить();
				СпособДоставки = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "MOT"),", ");
				
				Перевозчик = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "ServiceProvider"),", ");
				НомерТС = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "EquipmentNo"),", ");
				Водитель = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "Driver"),", ");
				КонтактныйНомерВодителя = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "ContactPhoneNumberOfTheDriver"),", ");
				Coordinator = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ВыборкаTrip, "Operator"),", ");
				ДатаСозданияТрипа = ВыборкаTrip[0].CreationDate;
				
			КонецЕсли;
			
			
			
			Шапка = Макет.ПолучитьОбласть("Шапка");
			
			Шапка.Параметры.Параметр_1 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.LegalEntity, "NameRus");
			Шапка.Параметры.Параметр_2 = "" + Выборка.CostCenter + "/" + Выборка.Activity;
			
			Шапка.Параметры.Параметр_3 = Формат(Выборка.ReadyToShipLocalTime, "ДФ='dd.MM.yyyy ЧЧ:mm'");
			Шапка.Параметры.Параметр_4 = Формат(Выборка.RequiredDeliveryLocalTime, "ДФ='dd.MM.yyyy ЧЧ:mm'");
			Шапка.Параметры.Параметр_5 = Выборка.Номер;
			Шапка.Параметры.Параметр_6 = Выборка.CostCenter;
			
			
			CompanySettings = Документы.TransportRequest.ПолучитьСтруктуруCompanySettings(Выборка.Company, Выборка.дата);
			Если CompanySettings.UseCostCenterFromLegalEntityForNON_PO Тогда
				 Шапка.Параметры.Параметр_6 = СокрЛП(Выборка.LegalEntityCostCenter);
			Иначе
				 Шапка.Параметры.Параметр_6 = СокрЛП(Выборка.CostCenter);
			КонецЕсли;
			
			Если ЗначениеЗаполнено(Выборка.Activity) Тогда
				
				Шапка.Параметры.Параметр_7 = Выборка.Activity;
				
			Иначе
				
				Шапка.Параметры.Параметр_7 = Выборка.ActivityLawson;
				
			КонецЕсли;
			
			Если ЕстьTRIP Тогда
				Шапка.Параметры.Перевозчик = Перевозчик;
				Шапка.Параметры.НомерТС = НомерТС;
				Шапка.Параметры.Водитель = Водитель;
				Шапка.Параметры.КонтактныйНомерВодителя = КонтактныйНомерВодителя;
			КонецЕсли;
			
			//Если НЕ Выборка.CustomUnionTransaction Тогда
			//	
			//	Если Выборка.PayingEntity = Перечисления.PayingEntities.S Тогда
			//		
			//		Шапка.Параметры.Параметр_8 = Выборка.LegalEntityNameRus;
			//		Шапка.Параметры.Параметр_9 = Выборка.LegalEntityAddressRus;
			//		
			//	Иначе
			//		
			//		Шапка.Параметры.Параметр_8 = Выборка.LegalEntityNameRus;
			//		Шапка.Параметры.Параметр_9 = Выборка.LegalEntityAddressRus;
			//		
			//	КонецЕсли;
			//	
			//Иначе
			//	
			//	Шапка.Параметры.Параметр_8 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.Shipper, "NameRus");
			//	Шапка.Параметры.Параметр_9 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.Shipper, "SoldToAddressRus");
			//	
			//	Шапка.Параметры.Параметр_12 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.ConsignTo, "NameRus");
			//	Шапка.Параметры.Параметр_13 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.ConsignTo, "SoldToAddressRus");
			//	
			//КонецЕсли;
			
			Шапка.Параметры.Параметр_16 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.PickUpWarehouse, "NameRus");
			Шапка.Параметры.Параметр_17 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.PickUpWarehouse, "AddressRus");
			Шапка.Параметры.Параметр_24 = Выборка.PickUpFromContact;
			Шапка.Параметры.Параметр_25 = Выборка.PickUpFromPhone;
			Шапка.Параметры.Параметр_26 = Выборка.PickUpFromEmail;
			
			Шапка.Параметры.Параметр_20 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.DeliverTo, "NameRus");
			Шапка.Параметры.Параметр_21 = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Выборка.DeliverTo, "AddressRus");
			Шапка.Параметры.Параметр_27 = Выборка.DeliverToContact;
			Шапка.Параметры.Параметр_28 = Выборка.DeliverToPhone;
			Шапка.Параметры.Параметр_29 = Выборка.DeliverToEmail;
			
			ТабличныйДокумент.Вывести(Шапка);
			
			ШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
			ТабличныйДокумент.Вывести(ШапкаТаблицы);
			
			ЗапросItems = Новый Запрос;
			ЗапросItems.Текст = "ВЫБРАТЬ
			                    |	ParcelsДетали.Ссылка КАК Ссылка,
			                    |	ParcelsДетали.Ссылка.LengthCM КАК LengthCM,
			                    |	ParcelsДетали.Ссылка.WidthCM КАК WidthCM,
			                    |	ParcelsДетали.Ссылка.HeightCM КАК HeightCM,
			                    |	ParcelsДетали.Ссылка.GrossWeightKG КАК GrossWeightKG,
			                    |	ParcelsДетали.Ссылка.NumOfParcels КАК NumOfParcels,
			                    |	ParcelsДетали.Ссылка.HazardClass
			                    |ИЗ
			                    |	Справочник.Parcels.Детали КАК ParcelsДетали
			                    |ГДЕ
			                    |	ParcelsДетали.Ссылка.TransportRequest = &TR
			                    |
			                    |СГРУППИРОВАТЬ ПО
			                    |	ParcelsДетали.Ссылка,
			                    |	ParcelsДетали.Ссылка.LengthCM,
			                    |	ParcelsДетали.Ссылка.WidthCM,
			                    |	ParcelsДетали.Ссылка.HeightCM,
			                    |	ParcelsДетали.Ссылка.GrossWeightKG,
			                    |	ParcelsДетали.Ссылка.NumOfParcels,
			                    |	ParcelsДетали.Ссылка.HazardClass
			                    |;
			                    |
			                    |////////////////////////////////////////////////////////////////////////////////
			                    |ВЫБРАТЬ
			                    |	ParcelsДетали.СтрокаИнвойса.DescriptionRus КАК DescriptionRus,
			                    |	ParcelsДетали.СтрокаИнвойса.СерийныйНомер КАК СерийныйНомер,
			                    |	ParcelsДетали.Ссылка,
			                    |	ParcelsДетали.СтрокаИнвойса.МеждународныйКодТНВЭД КАК HTC,
			                    |	ParcelsДетали.СтрокаИнвойса.СтранаПроисхождения КАК СтранаПроисхождения,
			                    |	ParcelsДетали.СтрокаИнвойса.Сумма КАК Сумма
			                    |ИЗ
			                    |	Справочник.Parcels.Детали КАК ParcelsДетали
			                    |ГДЕ
			                    |	ParcelsДетали.Ссылка.TransportRequest = &TR";
			ЗапросItems.УстановитьПараметр("TR",TR);
			РезультатItems = ЗапросItems.ВыполнитьПакет();
			
			Parcels = РезультатItems[0].Выгрузить();
			Item = РезультатItems[1].Выгрузить();
			
			ОбщийВес = 0;
			ОбщееКоличество = 0;
			ОбщаяСумма = 0;
			МассивHTC = Новый ТаблицаЗначений;
			МассивHTC.Колонки.Добавить("HTC");
			МассивСтранПроисхожджения = Новый ТаблицаЗначений;
			МассивСтранПроисхожджения.Колонки.Добавить("СтранаПроисхождения");
			Если Parcels.Количество() <> 0 Тогда
				
				СтрокаТаблицы = Макет.ПолучитьОбласть("СтрокаТаблицы");
				н = 1;
				Для Каждого Строка ИЗ Parcels Цикл
					Отбор = Новый Структура;
					Отбор.Вставить("Ссылка", Строка.Ссылка);
					ItemsПоParcel = Item.Скопировать(Отбор);
					СтрокаТаблицы.Параметры.НомерСтроки = н;
					СтрокаТаблицы.Параметры.НаименованиеТовара = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ItemsПоParcel, "DescriptionRus"),", ");
					СтрокаТаблицы.Параметры.СерийныйНомер = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ItemsПоParcel, "СерийныйНомер"),", ");
					
					Для Каждого СтрокаItem Из ItemsПоParcel Цикл
						СтрокаМассивHTC = МассивHTC.Добавить();
						СтрокаМассивHTC.HTC = СтрокаItem.HTC;
						
						СтрокаМассивСтранПроисхожджения = МассивСтранПроисхожджения.Добавить();
						СтрокаМассивСтранПроисхожджения.СтранаПроисхождения = СтрокаItem.СтранаПроисхождения;
						
						ОбщаяСумма = ОбщаяСумма + СтрокаItem.Сумма;
					КонецЦикла;
					
					СтрокаТаблицы.Параметры.Длина = Строка.LengthCM;
					СтрокаТаблицы.Параметры.Ширина = Строка.WidthCM;
					СтрокаТаблицы.Параметры.Высота = Строка.HeightCM;
					СтрокаТаблицы.Параметры.HazardClass = Строка.HazardClass;
					СтрокаТаблицы.Параметры.ВесЗаЕдиницу = Формат(Строка.GrossWeightKG / Строка.NumOfParcels, "ЧДЦ=3");
					СтрокаТаблицы.Параметры.КолВоМест = Строка.NumOfParcels;
					
					ТабличныйДокумент.Вывести(СтрокаТаблицы);
					н = н + 1;
					ОбщийВес = ОбщийВес + Строка.GrossWeightKG;
					ОбщееКоличество = ОбщееКоличество + Строка.NumOfParcels;
				КонецЦикла;
				
			КонецЕсли;
			
			
			
			ПодвалТаблицы = Макет.ПолучитьОбласть("ПодвалТаблицы");
			Если ЕстьTRIP Тогда
				ПодвалТаблицы.Параметры.Параметр_31 = СпособДоставки;
				
				ТаблицаTrips = ЗапросTrip.Выполнить().Выгрузить();
				ТаблицаВалют = ТаблицаTrips.Скопировать();
				//ТаблицаTrips.Свернуть("Currency");
				Валюты = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ТаблицаTrips, "Currency");
				Если Валюты.Количество() > 1 Тогда
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("В трипах имеются суммы в разных валютах, таблица 'Оплата' не будет заполнена");
				Иначе
					СтоимостьДоставки = 0;
					ТаблицаTrips.Свернуть("Trips, TotalCostsSum");
					Для каждого СтрокаТрип Из ТаблицаTrips Цикл
					
						СтоимостьДоставки = СтоимостьДоставки + СтрокаТрип.TotalCostsSum;
					
					КонецЦикла;
					
					Если Валюты.Количество() > 0 Тогда
						ПодвалТаблицы.Параметры.Валюта = Валюты[0];
						ПодвалТаблицы.Параметры.СтоимостьПеревозки = СтоимостьДоставки;
						ПодвалТаблицы.Параметры.СуммаБезНДС = СтоимостьДоставки;
					КонецЕсли;
				
				КонецЕсли;
				
			КонецЕсли;
			
			
			ПодвалТаблицы.Параметры.HTC = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(МассивHTC, "HTC"),", ");
			ПодвалТаблицы.Параметры.Параметр_30 = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(МассивСтранПроисхожджения, "СтранаПроисхождения"),", ");
			ПодвалТаблицы.Параметры.CargoValue = ?(ЗначениеЗаполнено(ОбщаяСумма), ОбщаяСумма, "");
			
			// { RGS AArsentev 24.08.2017 S-I-0003412
			HazardClass = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(Parcels, "HazardClass"),", ");
			ПодвалТаблицы.Параметры.Параметр_32 = Выборка.Comments;
			//ПодвалТаблицы.Параметры.Параметр_32 = "Hazard class - " + HazardClass + ?(ЗначениеЗаполнено(Выборка.Comments), ", " + Символы.ПС + Выборка.Comments,"");
			// } RGS AArsentev 24.08.2017 S-I-0003412
			ПодвалТаблицы.Параметры.ОбщийВес = ОбщийВес;
			ПодвалТаблицы.Параметры.ОбщееКоличество = ОбщееКоличество;
			
			
			ТабличныйДокумент.Вывести(ПодвалТаблицы);
			
			Подписи = Макет.ПолучитьОбласть("Подписи");
			Подписи.Параметры.Параметр_33 = Выборка.Alias;
			
			Подписи.Параметры.LogisticsPlanner = Выборка.Planner;
			Подписи.Параметры.ДатаОтправкиВРаботуЗаявкиЛогисту = Формат(Выборка.RequestedLocalTime, "ДФ=dd.MM.yyyy");
			Подписи.Параметры.ДатаПринятияЛогистомВРаботу = Формат(Выборка.AcceptedBySpecialistLocalTime, "ДФ=dd.MM.yyyy");
			
			Если ЕстьTRIP Тогда
				Подписи.Параметры.Coordinator = Coordinator;
				Подписи.Параметры.ДатаСозданияТрипа = Формат(Дата(ДатаСозданияТрипа), "ДФ=dd.MM.yyyy");
			КонецЕсли;
			
			ТабличныйДокумент.Вывести(Подписи);
			
			ТабличныйДокумент.АвтоМасштаб = Истина;
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
КонецФункции

// { RGS AArsentev 13.04.2018
Функция ПроверитьСоответствиеCompanyLE(LegalEntity, ConsignTo) Экспорт
	
	Проверять = Истина;
	
	Если СокрЛП(LegalEntity.ParentCompany.Код) = "SLI RU" И СокрЛП(ConsignTo.ParentCompany.Код) = "SLI KZ" Тогда
		Проверять = Ложь;
	ИначеЕсли СокрЛП(LegalEntity.ParentCompany.Код) = "SLI KZ" И СокрЛП(ConsignTo.ParentCompany.Код) = "SLI RU" Тогда
		Проверять = Ложь;
	ИначеЕсли СокрЛП(LegalEntity.ParentCompany.Код) = "SLI-SMI RU" И СокрЛП(ConsignTo.ParentCompany.Код) = "SLI KZ" Тогда
		Проверять = Ложь;
	ИначеЕсли СокрЛП(LegalEntity.ParentCompany.Код) = "SLI KZ" И СокрЛП(ConsignTo.ParentCompany.Код) = "SLI-SMI RU" Тогда
		Проверять = Ложь;
	КонецЕсли;
	
	Возврат Проверять;
	
КонецФункции // } RGS AArsentev 13.04.2018

// { RGS DKazanskiy 18.07.2018 14:51:08 - 
Функция ПроверитьСоответствиеShipperConsignTo(Объект) Экспорт
	
	Если НЕ Объект.CustomUnionTransaction Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Shipper) или НЕ ЗначениеЗаполнено(Объект.ConsignTo) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат РегистрыСведений.DGFShipperConsingToSettings.ЕстьСоответствие(Объект.Shipper, Объект.ConsignTo);
	
КонецФункции
// } RGS DKazanskiy 18.07.2018 14:51:12 - 