
/////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	// { RGS DKazanskiy 17.10.2018 13:38:19 - S-I-0005455
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	// } RGS DKazanskiy 17.10.2018 13:38:31 - S-I-0005455
	
	Если ПометкаУдаления Тогда
		ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
		ModificationDate = ТекущаяДата();
		Возврат;
	КонецЕсли;
	
	Дата = НачалоМесяца(Дата);
	
	ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ModificationDate = ТекущаяДата();
	
	ТипТарифа = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ServiceProvider, "RentalTrucksCostsType");
	Если НЕ ЗначениеЗаполнено(ТипТарифа) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Для Service provider не заполнено поле 'Rental trucks costs type'!",
		ЭтотОбъект, "ServiceProvider", , Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(ДатаНачала) ИЛИ НЕ ЗначениеЗаполнено(ДатаОкончания)Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"Не заполнен период!",
		, , , Отказ);
	КонецЕсли;
	
	ПроверитьПоДругимДокам(Отказ);
	
	Если РежимЗаписи <> РежимЗаписиДокумента.Проведение Тогда 
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаТЧ Из RentalTrucks Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Cost) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("In line " + СтрокаТЧ.НомерСтроки + " 'By trips': ""Cost"" is empty!",
				ЭтотОбъект, "RentalTrucks[" + (СтрокаТЧ.НомерСтроки - 1) + "].Cost", , Отказ);
			
		КонецЕсли;		
				
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Currency) Тогда

			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("In line " + СтрокаТЧ.НомерСтроки + " 'By trips': ""Currency"" is empty!",
				ЭтотОбъект, "RentalTrucks[" + (СтрокаТЧ.НомерСтроки - 1) + "].Currency", , Отказ);
			
		КонецЕсли;

	КонецЦикла;
	
	Для Каждого СтрокаТЧ Из RentalTrucksManual Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Cost) Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("In line " + СтрокаТЧ.НомерСтроки + " 'By trips': ""Cost"" is empty!",
				ЭтотОбъект, "RentalTrucksManual[" + (СтрокаТЧ.НомерСтроки - 1) + "].Cost", , Отказ);
			
		КонецЕсли;		
				
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Currency) Тогда

			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("In line " + СтрокаТЧ.НомерСтроки + " 'Manual entry': ""Currency"" is empty!",
				ЭтотОбъект, "RentalTrucksManual[" + (СтрокаТЧ.НомерСтроки - 1) + "].Currency", , Отказ);
			
		КонецЕсли;

	КонецЦикла;

	// выполним проверку распределения суммы по процентам
	ТаблицаПроверки = RentalTrucksManual.Выгрузить();
	ТаблицаПроверки.Свернуть("Vehicle, Equipment", "BaseCostPercent");
	
	Для каждого ТекСтрокаПроверки из ТаблицаПроверки Цикл
		
		Если ТекСтрокаПроверки.BaseCostPercent > 100 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Для транспортного средства " + СокрЛП(ТекСтрокаПроверки.Vehicle) + "("+ СокрЛП(ТекСтрокаПроверки.Equipment) +") сумма AU %% превышает 100!",
				, , , Отказ);
		КонецЕсли;
			
		
	КонецЦикла;
	
	// { RGS AFokin 05.09.2018 23:59:59 S-I-0005829
	Для каждого СтрокаRentalTrucks Из RentalTrucks Цикл
		ТрипОбъект = СтрокаRentalTrucks.Trip.ПолучитьОбъект();
		Если НЕ ЗначениеЗаполнено(ТрипОбъект.Currency) Тогда
			ТрипОбъект.Currency = ?(ЗначениеЗаполнено(СтрокаRentalTrucks.Currency), СтрокаRentalTrucks.Currency, Справочники.Валюты.ПустаяСсылка()); 
		КонецЕсли;
		ТрипОбъект.ОбменДанными.Загрузка = Истина;
		ТрипОбъект.Записать();
	КонецЦикла;	
	// } RGS AFokin 05.09.2018 23:59:59 S-I-0005829
	
КонецПроцедуры

Процедура ПроверитьПоДругимДокам(Отказ)
	
	Если ЭтоНовый() Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	RentalTrucksCostsSumsRentalTrucks.Ссылка,
	               |	RentalTrucksCostsSumsRentalTrucks.Trip
	               |ИЗ
	               |	Документ.RentalTrucksCostsSums.RentalTrucks КАК RentalTrucksCostsSumsRentalTrucks
	               |ГДЕ
	               |	RentalTrucksCostsSumsRentalTrucks.Trip В(&Trips)
	               |	И RentalTrucksCostsSumsRentalTrucks.Ссылка <> &Ссылка
	               |	И RentalTrucksCostsSumsRentalTrucks.Ссылка.Проведен
	               |	И RentalTrucksCostsSumsRentalTrucks.LegalEntity = &LegalEntity";
	Запрос.УстановитьПараметр("Trips", RentalTrucks.ВыгрузитьКолонку("Trip"));
	Запрос.УстановитьПараметр("LegalEntity", LegalEntity);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Количество()>0 Тогда
		Пока Результат.Следующий() Цикл
			Сообщить(СокрЛП(Результат.Trip) + "  is already in posted "+ СокрЛП(Результат.Ссылка));
		КонецЦикла;
		Отказ = Истина;
	КонецЕсли;
						
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////
// ПРОВЕДЕНИЕ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	НужноСогласование = ТребуетсяСогласование();
	
	Если НужноСогласование Тогда
		ЕстьСогласование = ПроверитьСогласование();
		Если Не ЕстьСогласование Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Документ не согласован, проверьте пожалуйста");
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	СформироватьДвиженияLocalDistributionCostsPerItem(Отказ);
	СформироватьДвиженияLocalDistributionCostsPerKG(Отказ);
	СформироватьДвиженияLocalDistributionCostsMilageWeightVolume(Отказ);
	// { RGS AArsentev 5/22/2017 11:30:01 AM - S-I-0002788
	СформироватьДвиженияLocalDistributionAccessorialCostsPerItem(Отказ);
	// } RGS AArsentev 5/22/2017 11:30:20 AM - S-I-0002788
	Если Не Отказ Тогда
		ЗаполнитьВерификацию();
	КонецЕсли;
	
КонецПроцедуры

Процедура СформироватьДвиженияLocalDistributionCostsPerKG(Отказ)
	
	LocalDistributionCostsPerKG = Движения.LocalDistributionCostsPerKG;
	LocalDistributionCostsPerKG.Записывать = Истина;
	LocalDistributionCostsPerKG.Очистить();

	Для Каждого ТекСтрокаRentalTrucks Из RentalTrucks Цикл
		Движение = Движения.LocalDistributionCostsPerKG.Добавить();
		Движение.Период 				= Дата;
		Движение.Trip 					= ТекСтрокаRentalTrucks.Trip;
		Движение.MOT 					= ТекСтрокаRentalTrucks.Trip.MOT;
		Движение.Equipment 				= ТекСтрокаRentalTrucks.Trip.Equipment;
		Движение.SourceLocation 		= ТекСтрокаRentalTrucks.TransportRequest.PickUpWarehouse;
		Движение.DestinationLocation 	= ТекСтрокаRentalTrucks.TransportRequest.DeliverTo;
		Движение.Segment 				= ТекСтрокаRentalTrucks.Segment;
		Движение.SubSegment 			= ТекСтрокаRentalTrucks.AU.SubSegment;
		Движение.Geomarket 				= ТекСтрокаRentalTrucks.AU.Geomarket;
		Движение.SubGeomarket 			= ТекСтрокаRentalTrucks.AU.SubGeomarket;
		
		CostsSumUSD 			= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.Cost, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.Trip.Дата);
		AccessorialCostsSumUSD 	= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.AccessorialCosts, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.Trip.Дата);	
		
		Движение.CostsSumPerKGUSD 		= (CostsSumUSD + AccessorialCostsSumUSD) / ?(ТекСтрокаRentalTrucks.Weight = 0, 1, ТекСтрокаRentalTrucks.Weight);
		Движение.Регистратор 			= Ссылка;
		
	КонецЦикла;
	
	Для Каждого ТекСтрокаRentalTrucks Из RentalTrucksManual Цикл
		Движение = Движения.LocalDistributionCostsPerKG.Добавить();
		Движение.Период 				= Дата;
		
		МОТы = ТекСтрокаRentalTrucks.Equipment.MOTs;
		
		Движение.MOT 					= ?(МОТы.Количество() > 0, МОТы[0].MOT, "");
		Движение.Equipment 				= ТекСтрокаRentalTrucks.Equipment;
		Движение.SourceLocation 		= ТекСтрокаRentalTrucks.LocationFrom;
		Движение.DestinationLocation 	= ТекСтрокаRentalTrucks.LocationTo;
		Движение.Segment 				= ТекСтрокаRentalTrucks.AU.Segment;
		Движение.SubSegment 			= ТекСтрокаRentalTrucks.AU.SubSegment;
		Движение.Geomarket 				= ТекСтрокаRentalTrucks.AU.Geomarket;
		Движение.SubGeomarket 			= ТекСтрокаRentalTrucks.AU.SubGeomarket;
		
		CostsSumUSD 			= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.Cost, ТекСтрокаRentalTrucks.Currency, Дата);
		AccessorialCostsSumUSD 	= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.AccessorialCosts, ТекСтрокаRentalTrucks.Currency, Дата);	
		
		Движение.CostsSumPerKGUSD 		= (CostsSumUSD + AccessorialCostsSumUSD) / ?(ТекСтрокаRentalTrucks.Weight = 0, 1, ТекСтрокаRentalTrucks.Weight);
		Движение.Регистратор 			= Ссылка;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияLocalDistributionCostsMilageWeightVolume(Отказ) 

	LocalDistributionCostsMilageWeightVolume = Движения.LocalDistributionCostsMilageWeightVolume;
	LocalDistributionCostsMilageWeightVolume.Записывать = Истина;
	LocalDistributionCostsMilageWeightVolume.Очистить();
	
	// пишем движения по расчету через Trip
	ТаблицаДвижений = ПолучитьТаблицуДвиженийLocalDistributionCostsMilageWeightVolume();	
	Движения.LocalDistributionCostsMilageWeightVolume.Загрузить(ТаблицаДвижений);
	
	// пишем ручные движения
	
	Для Каждого ТекСтрокаRentalTrucks Из RentalTrucksManual Цикл
		Движение = Движения.LocalDistributionCostsMilageWeightVolume.Добавить();
		Движение.Период 				= Дата;
		
		МОТы = ТекСтрокаRentalTrucks.Equipment.MOTs;
		
		Движение.MOT 					= ?(МОТы.Количество() > 0, МОТы[0].MOT, "");
		Движение.ParentCompany			= ТекСтрокаRentalTrucks.LegalEntity.ParentCompany;
		Движение.Equipment 				= ТекСтрокаRentalTrucks.Equipment;
		Движение.SourceLocation 		= ТекСтрокаRentalTrucks.LocationFrom;
		Движение.DestinationLocation 	= ТекСтрокаRentalTrucks.LocationTo;
		Движение.Segment 				= ТекСтрокаRentalTrucks.AU.Segment;
		Движение.SubSegment 			= ТекСтрокаRentalTrucks.AU.SubSegment;
		Движение.Geomarket 				= ТекСтрокаRentalTrucks.AU.Geomarket;
		Движение.SubGeomarket 			= ТекСтрокаRentalTrucks.AU.SubGeomarket;
		
		CostsSumUSD 			= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.Cost, ТекСтрокаRentalTrucks.Currency, Дата);
		AccessorialCostsSumUSD 	= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.AccessorialCosts, ТекСтрокаRentalTrucks.Currency, Дата);	
		
		//Движение.CostsSumPerKGUSD 		= (CostsSumUSD + AccessorialCostsSumUSD) / ?(ТекСтрокаRentalTrucks.Weight = 0, 1, ТекСтрокаRentalTrucks.Weight);
		Движение.Регистратор 			= Ссылка;
		
		Движение.Milage					= ТекСтрокаRentalTrucks.Milage;
		Движение.MilageOfParcel			= ТекСтрокаRentalTrucks.Milage;
		Движение.Sum					= CostsSumUSD + AccessorialCostsSumUSD;
		Движение.SumOfMilage			= CostsSumUSD + AccessorialCostsSumUSD;
		Движение.Volume					= ТекСтрокаRentalTrucks.Volume;
		Движение.Weight					= ТекСтрокаRentalTrucks.Weight;
		Движение.TonneKilometers		= ТекСтрокаRentalTrucks.Weight * ТекСтрокаRentalTrucks.Milage / 1000;
		
	КонецЦикла;	
	
КонецПроцедуры

Процедура СформироватьДвиженияLocalDistributionCostsPerItem(Отказ)
	               	
	// регистр LocalDistributionCostsPerItem 
	
	// сначала распределяем суммы по парселям пропорционально весу
	// затем по товарам поровну
   	
	ДвиженияLocalDistributionCostsPerItem = Движения.LocalDistributionCostsPerItem;
	
	ДвиженияLocalDistributionCostsPerItem.Записывать = Истина;
	ДвиженияLocalDistributionCostsPerItem.Очистить();
	
	// регистр International Domestic Fact Costs   	
	
	ДвиженияDomesticFactCosts = Движения.InternationalAndDomesticFactCosts;
	
	ДвиженияDomesticFactCosts.Записывать = Истина;
	ДвиженияDomesticFactCosts.Очистить();
	
	Таблица_RentalTrucks = RentalTrucks.Выгрузить();	
	Таблица_RentalTrucks.Свернуть("Trip, Currency", "Cost, AccessorialCosts");
	
	Для Каждого ТекСтрокаRentalTrucks Из Таблица_RentalTrucks Цикл
		
		ATA_FD = ТекСтрокаRentalTrucks.Trip.Stops.Найти(Перечисления.StopsTypes.Destination, "Type").ActualArrivalLocalTime;
		
		TotalCostsSum = ТекСтрокаRentalTrucks.Cost + ТекСтрокаRentalTrucks.AccessorialCosts; 	
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Parcels", ТекСтрокаRentalTrucks.Trip.Parcels.Выгрузить());
		
		Запрос.Текст = "ВЫБРАТЬ
		|	Parcels.Parcel КАК Parcel,
		|	Parcels.NumOfParcels КАК NumOfParcels
		|ПОМЕСТИТЬ Parcels
		|ИЗ
		|	&Parcels КАК Parcels
		|;
		|ВЫБРАТЬ
		|	TripParcels.Parcel.GrossWeightKG / TripParcels.Parcel.NumOfParcels * TripParcels.NumOfParcels КАК GrossWeightKG,
		|	0 КАК TotalCostsSumPerParcel,
		|	0 КАК TotalAccessorialCostsSumPerParcel,
		|	0 КАК BaseCostsSumPerParcel,
		|	0 КАК TotalCostsSumPerParcelUSD,
		|	0 КАК TotalAccessorialCostsSumPerParcelUSD,
		|	0 КАК BaseCostsSumPerParcelUSD,
		|	TripParcels.Parcel
		|ИЗ
		|	Parcels КАК TripParcels
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ParcelsДетали.Ссылка КАК Parcel,
		|	ParcelsДетали.СтрокаИнвойса КАК Item,
		|	1 КАК Количество,
		|	0 КАК BaseCostsSumPerItem,
		|	0 КАК TotalAccessorialCostsSumPerItem,
		|	0 КАК TotalCostsSumPerItem,
		|	0 КАК BaseCostsSumPerItemUSD,
		|	0 КАК TotalAccessorialCostsSumPerItemUSD,
		|	0 КАК TotalCostsSumPerItemUSD,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр.Segment КАК Segment,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр.SubSegment КАК SubSegment,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр.Geomarket КАК Geomarket,
		|	ParcelsДетали.СтрокаИнвойса.КостЦентр.SubGeomarket КАК SubGeomarket,
		|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК ParentCompany
		|ИЗ
		|	Справочник.Parcels.Детали КАК ParcelsДетали
		|ГДЕ
		|	ParcelsДетали.Ссылка В
		|			(ВЫБРАТЬ
		|				Parcels.Parcel
		|			ИЗ
		|				Parcels КАК Parcels)";
		
		Результат = Запрос.ВыполнитьПакет();			   
		
		ТЗParcels = Результат[1].Выгрузить();
		
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), ТекСтрокаRentalTrucks.Cost, ТЗParcels, "BaseCostsSumPerParcel");
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), ТекСтрокаRentalTrucks.AccessorialCosts, ТЗParcels, "TotalAccessorialCostsSumPerParcel");
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), TotalCostsSum, ТЗParcels, "TotalCostsSumPerParcel");
		                                      		
		BaseCostSLBUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.Cost, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.Trip.Дата);
		AccessorialCostsUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(ТекСтрокаRentalTrucks.AccessorialCosts, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.Trip.Дата); 
		CostUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(TotalCostsSum, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.Trip.Дата); 
		
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), BaseCostSLBUSD, ТЗParcels, "BaseCostsSumPerParcelUSD");
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), AccessorialCostsUSD, ТЗParcels, "TotalAccessorialCostsSumPerParcelUSD");
		УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), CostUSD, ТЗParcels, "TotalCostsSumPerParcelUSD");
		
		ТЗItems = Результат[2].Выгрузить();
		СтруктураОтбораПоParcel = Новый Структура("Parcel");
		Для Каждого СтрParcel Из ТЗParcels Цикл
			
			СтруктураОтбораПоParcel.Parcel = СтрParcel.Parcel;
			ТЗParcelItems = ТЗItems.Скопировать(СтруктураОтбораПоParcel);
			
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.BaseCostsSumPerParcel, ТЗParcelItems, "BaseCostsSumPerItem");
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.TotalAccessorialCostsSumPerParcel, ТЗParcelItems, "TotalAccessorialCostsSumPerItem");
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.TotalCostsSumPerParcel, ТЗParcelItems, "TotalCostsSumPerItem");
			
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.BaseCostsSumPerParcelUSD, ТЗParcelItems, "BaseCostsSumPerItemUSD");
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.TotalAccessorialCostsSumPerParcelUSD, ТЗParcelItems, "TotalAccessorialCostsSumPerItemUSD");
			УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.TotalCostsSumPerParcelUSD, ТЗParcelItems, "TotalCostsSumPerItemUSD");
			
			Для Каждого СтрокаТЗ Из ТЗParcelItems Цикл
				
				Движение = ДвиженияLocalDistributionCostsPerItem.Добавить();
				Движение.Период = ТекСтрокаRentalTrucks.Trip.Дата;
				Движение.Trip 	= ТекСтрокаRentalTrucks.Trip.Ссылка;
				Движение.Parcel = СтрокаТЗ.Parcel;
				Движение.Item 	= СтрокаТЗ.Item;
				
				Движение.BaseCostsSum 				= СтрокаТЗ.BaseCostsSumPerItem;
				Движение.TotalAccessorialCostsSum 	= СтрокаТЗ.TotalAccessorialCostsSumPerItem;
				Движение.TotalCostsSum 				= СтрокаТЗ.TotalCostsSumPerItem;
				Движение.Регистратор 				= Ссылка;
				Движение.BaseCostsSumUSD 			= СтрокаТЗ.BaseCostsSumPerItemUSD;
				Движение.TotalAccessorialCostsSumUSD = СтрокаТЗ.TotalAccessorialCostsSumPerItemUSD;
				Движение.TotalCostsSumUSD 			= СтрокаТЗ.TotalCostsSumPerItemUSD;
				
			КонецЦикла;
			
			СформироватьДвиженияDomesticFactCosts(ТЗParcelItems, ДвиженияDomesticFactCosts, ATA_FD);
			
		КонецЦикла;
		
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	RentalTrucksCostsSumsRentalTrucksManual.LegalEntity.ParentCompany КАК ParentCompany,
	|	СУММА(RentalTrucksCostsSumsRentalTrucksManual.Cost) КАК Cost,
	|	RentalTrucksCostsSumsRentalTrucksManual.Currency,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.Segment КАК Segment,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.SubSegment КАК SubSegment,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.Geomarket КАК Geomarket,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.SubGeomarket КАК SubGeomarket,
	|	СУММА(RentalTrucksCostsSumsRentalTrucksManual.AccessorialCosts) КАК AccessorialCosts
	|ИЗ
	|	Документ.RentalTrucksCostsSums.RentalTrucksManual КАК RentalTrucksCostsSumsRentalTrucksManual
	|ГДЕ
	|	RentalTrucksCostsSumsRentalTrucksManual.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	RentalTrucksCostsSumsRentalTrucksManual.Currency,
	|	RentalTrucksCostsSumsRentalTrucksManual.LegalEntity.ParentCompany,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.Segment,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.SubSegment,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.Geomarket,
	|	RentalTrucksCostsSumsRentalTrucksManual.AU.SubGeomarket";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	// пишем движения по ручной части
	Пока Результат.Следующий() Цикл
		
		CostsSumSLBUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Результат.Cost, Результат.Currency, Дата);
		
		Если CostsSumSLBUSD <> 0 Тогда
			
			Движение = ДвиженияDomesticFactCosts.Добавить();
			
			Движение.Период 				= НачалоМесяца(?(День(Дата) > 25, ДобавитьМесяц(Дата, 1), Дата));
			Движение.CostsType 				= Перечисления.FactCostsTypes.Freight;
			Движение.DomesticInternational 	= Перечисления.DomesticInternational.Domestic;
			Движение.Регистратор 			= Ссылка;
			Движение.ParentCompany 			= Результат.ParentCompany;
			Движение.Geomarket 				= Результат.Geomarket;
			Движение.SubGeomarket 			= Результат.SubGeomarket;
			Движение.Segment 				= Результат.Segment;
			Движение.SubSegment 			= Результат.SubSegment;    			
			Движение.Sum 					= CostsSumSLBUSD;
			
		КонецЕсли;
		
		AccessorialCostsSumPerItemUSD = LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Результат.AccessorialCosts, Результат.Currency, Дата);
		
		Если AccessorialCostsSumPerItemUSD <> 0 Тогда 
			
			Движение = ДвиженияDomesticFactCosts.Добавить();
			
			Движение.Период 				= НачалоМесяца(?(День(Дата) > 25, ДобавитьМесяц(Дата, 1), Дата));
			Движение.CostsType 				= Перечисления.FactCostsTypes.AccessorialCosts;
			Движение.DomesticInternational 	= Перечисления.DomesticInternational.Domestic;
			Движение.Регистратор 			= Ссылка;
			Движение.ParentCompany 			= Результат.ParentCompany;
			Движение.Geomarket 				= Результат.Geomarket;
			Движение.SubGeomarket 			= Результат.SubGeomarket;
			Движение.Segment 				= Результат.Segment;
			Движение.SubSegment 			= Результат.SubSegment;   			
			Движение.Sum 					= AccessorialCostsSumPerItemUSD;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияDomesticFactCosts(ТЗParcelItems, ДвиженияDomesticFactCosts, ATA_FD)
	          	
	СurrencyUSD = Справочники.Валюты.НайтиПоКоду("840");
	
	ТЗLines = ТЗParcelItems.Скопировать(, "ParentCompany,Geomarket,SubGeomarket,Segment,SubSegment,BaseCostsSumPerItemUSD,TotalAccessorialCostsSumPerItemUSD");
	                
	ТЗLines.Свернуть("ParentCompany,Geomarket,SubGeomarket,Segment,SubSegment", "BaseCostsSumPerItemUSD,TotalAccessorialCostsSumPerItemUSD");
	
	Для Каждого СтрокаТЗ Из ТЗLines Цикл
		
		Если СтрокаТЗ.BaseCostsSumPerItemUSD <> 0 Тогда 
			
			Движение = ДвиженияDomesticFactCosts.Добавить();
			
			Движение.Период 				= НачалоМесяца(?(День(Дата) > 25, ДобавитьМесяц(Дата, 1), Дата));
			Движение.CostsType 				= Перечисления.FactCostsTypes.Freight;
			Движение.DomesticInternational 	= Перечисления.DomesticInternational.Domestic;
			Движение.Регистратор 			= Ссылка;
			Движение.ParentCompany 			= СтрокаТЗ.ParentCompany;
			Движение.Geomarket 				= СтрокаТЗ.Geomarket;
			Движение.SubGeomarket 			= СтрокаТЗ.SubGeomarket;
			Движение.Segment 				= СтрокаТЗ.Segment;
			Движение.SubSegment 			= СтрокаТЗ.SubSegment;
			
			Движение.Sum = СтрокаТЗ.BaseCostsSumPerItemUSD;
			
		КонецЕсли;
		
		Если СтрокаТЗ.TotalAccessorialCostsSumPerItemUSD <> 0 Тогда 
			
			Движение = ДвиженияDomesticFactCosts.Добавить();
			
			Движение.Период 				= НачалоМесяца(?(День(Дата) > 25, ДобавитьМесяц(Дата, 1), Дата));
			Движение.CostsType 				= Перечисления.FactCostsTypes.AccessorialCosts;
			Движение.DomesticInternational 	= Перечисления.DomesticInternational.Domestic;
			Движение.Регистратор 			= Ссылка;
			Движение.ParentCompany 			= СтрокаТЗ.ParentCompany;
			Движение.Geomarket 				= СтрокаТЗ.Geomarket;
			Движение.SubGeomarket 			= СтрокаТЗ.SubGeomarket;
			Движение.Segment 				= СтрокаТЗ.Segment;
			Движение.SubSegment 			= СтрокаТЗ.SubSegment;
			
			Движение.Sum 					= СтрокаТЗ.TotalAccessorialCostsSumPerItemUSD;
			
		КонецЕсли;

	КонецЦикла;
	        		  		
КонецПроцедуры

Функция ПолучитьТаблицуДвиженийLocalDistributionCostsMilageWeightVolume()
	
	
	// { RGS AArsentev 12.04.2018 - Не учитываются случаи движения от Source до Destination
	//ТаблицаРасстояний = ПолучитьТаблицуДвиженийRouteOfLocation();
	//ТаблицаРасстоянийМеждуСкладами = ргМодульКартографии.ПолучитьВсеКомбинацииРасстояний(ТаблицаРасстояний);
	//
	//ТаблицаРасстоянийМеждуСкладами.Свернуть("Период, LocationStart, LocationEnd, Mileage, Trip");
	
	Трипы = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(RentalTrucks.Выгрузить(), "Trip");
	
	ТаблицаМаршрутов = Новый ТаблицаЗначений;
	
	ТаблицаМаршрутов.Колонки.Добавить("Период",			ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	ТаблицаМаршрутов.Колонки.Добавить("LocationStart",	Новый ОписаниеТипов("СправочникСсылка.Warehouses"));
	ТаблицаМаршрутов.Колонки.Добавить("LocationEnd",		Новый ОписаниеТипов("СправочникСсылка.Warehouses"));
	ТаблицаМаршрутов.Колонки.Добавить("Mileage",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,3));
	ТаблицаМаршрутов.Колонки.Добавить("Trip",			Новый ОписаниеТипов("ДокументСсылка.TripNonLawsonCompanies"));
	
	Для Каждого Элемент Из Трипы Цикл
		ТаблицаРасстоянийМеждуСкладами = ПолучитьТаблицуМаршрутов(Элемент.Ссылка);
		Документы.rgsBudgetSums.ДополнитьТаблицу(ТаблицаРасстоянийМеждуСкладами, ТаблицаМаршрутов);
	КонецЦикла;
	// } RGS AArsentev 12.04.2018
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТаблицаРасстояний.LocationStart КАК SourceLocation,
	|	ТаблицаРасстояний.LocationEnd КАК DestinationLocation,
	|	ТаблицаРасстояний.Trip КАК Trip,
	|	ТаблицаРасстояний.Mileage КАК Milage
	|ПОМЕСТИТЬ ТаблицаРасстояний
	|ИЗ
	|	&ТаблицаРасстояний КАК ТаблицаРасстояний
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	RentalTrucksCostsSumsRentalTrucks.Trip,
	|	RentalTrucksCostsSumsRentalTrucks.Cost + RentalTrucksCostsSumsRentalTrucks.AccessorialCosts КАК Cost,
	|	RentalTrucksCostsSumsRentalTrucks.Currency
	|ПОМЕСТИТЬ Trips
	|ИЗ
	|	Документ.RentalTrucksCostsSums.RentalTrucks КАК RentalTrucksCostsSumsRentalTrucks
	|ГДЕ
	|	RentalTrucksCostsSumsRentalTrucks.Ссылка = &Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	TripNonLawsonCompaniesParcels.Ссылка.Дата КАК Период,
	|	TripNonLawsonCompaniesParcels.Ссылка.Equipment,
	|	TripNonLawsonCompaniesParcels.Ссылка.MOT,
	|	TripNonLawsonCompaniesParcels.Parcel.HazardClass КАК HazardClass,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Company КАК ParentCompany,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.Geomarket КАК Geomarket,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.SubGeomarket КАК SubGeomarket,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.Segment КАК Segment,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.SubSegment КАК SubSegment,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse КАК SourceLocation,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo КАК DestinationLocation,
	|	СУММА(TripNonLawsonCompaniesParcels.Parcel.CubicMeters * TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels) КАК Volume,
	|	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeight * TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels) КАК Weight,
	|	Trips.Trip,
	|	Trips.Trip.TotalCostsSumUSD
	|ПОМЕСТИТЬ ТаблицаParcel
	|ИЗ
	|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Trips КАК Trips
	|		ПО TripNonLawsonCompaniesParcels.Ссылка = Trips.Trip
	|
	|СГРУППИРОВАТЬ ПО
	|	TripNonLawsonCompaniesParcels.Ссылка.Дата,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.Company,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.Geomarket,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.SubGeomarket,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.Segment,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.CostCenter.SubSegment,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.PickUpWarehouse,
	|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest.DeliverTo,
	|	TripNonLawsonCompaniesParcels.Parcel.HazardClass,
	|	TripNonLawsonCompaniesParcels.Ссылка.Equipment,
	|	TripNonLawsonCompaniesParcels.Ссылка.MOT,
	|	Trips.Trip
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаParcel.Период,
	|	ТаблицаParcel.Equipment,
	|	ТаблицаParcel.MOT,
	|	ТаблицаParcel.HazardClass,
	|	ТаблицаParcel.ParentCompany,
	|	ТаблицаParcel.Geomarket,
	|	ТаблицаParcel.SubGeomarket,
	|	ТаблицаParcel.Segment,
	|	ТаблицаParcel.SubSegment,
	|	ТаблицаParcel.SourceLocation,
	|	ТаблицаParcel.DestinationLocation,
	|	ТаблицаParcel.Volume,
	|	ТаблицаParcel.Weight,
	|	ЕСТЬNULL(ТаблицаРасстояний.Milage, 0) КАК MilageOfParcel,
	|	ТаблицаParcel.Weight * ЕСТЬNULL(ТаблицаРасстояний.Milage, 0) / 1000 КАК TonneKilometers,
	|	ТаблицаParcel.Trip
	|ИЗ
	|	ТаблицаParcel КАК ТаблицаParcel
	|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаРасстояний КАК ТаблицаРасстояний
	|		ПО ТаблицаParcel.SourceLocation = ТаблицаРасстояний.SourceLocation
	|			И ТаблицаParcel.DestinationLocation = ТаблицаРасстояний.DestinationLocation
	|			И ТаблицаParcel.Trip = ТаблицаРасстояний.Trip";
	
	Запрос.УстановитьПараметр("Ссылка",				Ссылка);
	Запрос.УстановитьПараметр("ТаблицаРасстояний",	ТаблицаМаршрутов);
	
	ТаблицаДвижений = Запрос.Выполнить().Выгрузить();
	
	ТаблицаДвижений.Колонки.Добавить("Milage",		ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,3));
	ТаблицаДвижений.Колонки.Добавить("Sum",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	ТаблицаДвижений.Колонки.Добавить("SumOfMilage",	ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));
	
	Трипы = ТаблицаДвижений.ВыгрузитьКолонку("Trip");
	
	ТаблицаЗатрат = RentalTrucks.Выгрузить();
	
	Для каждого ТекТрип из Трипы Цикл
		
		ТаблицаТрипа 		 = ТаблицаМаршрутов.Скопировать(Новый Структура("Trip", ТекТрип));
		ТаблицаДвиженийТрипа = ТаблицаДвижений.Скопировать(Новый Структура("Trip", ТекТрип));
		ТаблицаЗатратТрипа =  ТаблицаЗатрат.Скопировать(Новый Структура("Trip", ТекТрип));
		
		// Распределяем общий пробег "Milage" И "SumOfMilage" по "Weight"
		MilageТек			= 0;
		MilageВсего			= ТаблицаТрипа.Итог("Mileage");
		SumOfMilageТек		= 0;
		//SumOfMilageВсего	= ТекТрип.TotalCostsSumUSD;
		SumOfMilageВсего = 0;
		
		Для Каждого Элемент Из ТаблицаЗатратТрипа Цикл
			SumOfMilageВсего = SumOfMilageВсего + LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Элемент.Cost + Элемент.AccessorialCosts , Элемент.Currency, ТекТрип.Дата);
		КонецЦикла;
		
		MilageOfParcelВсего	= ТаблицаДвиженийТрипа.Итог("MilageOfParcel");
		
		ТекСчетчик	= 1;
		ВсегоСтрок	= ТаблицаДвиженийТрипа.Количество();
		
		// Если базы распределения нет, то ничего делать не надо
		Если MilageOfParcelВсего <> 0 Тогда
		
			Для Каждого СтрокаДвижений Из ТаблицаДвижений Цикл
				
				Если НЕ СтрокаДвижений.Trip = ТекТрип Тогда
					Продолжить;
				КонецЕсли;
				
				Если ТекСчетчик = ВсегоСтрок Тогда
					СтрокаДвижений.Milage		= MilageВсего - MilageТек;
					СтрокаДвижений.SumOfMilage	= SumOfMilageВсего - SumOfMilageТек;
				Иначе
					СтрокаДвижений.Milage		= MilageВсего * СтрокаДвижений.MilageOfParcel / MilageOfParcelВсего;
					СтрокаДвижений.SumOfMilage	= SumOfMilageВсего * СтрокаДвижений.MilageOfParcel / MilageOfParcelВсего;
				КонецЕсли;
				
				MilageТек		= MilageТек + СтрокаДвижений.Milage;
				SumOfMilageТек	= SumOfMilageТек + СтрокаДвижений.SumOfMilage;
				ТекСчетчик		= ТекСчетчик + 1;
				
			КонецЦикла;
			
		КонецЕсли;	
		
		// Распределение суммы по тонно километрам
		SumТек					= 0;
		//SumВсего				= ТекТрип.TotalCostsSumUSD;
		SumВсего				= SumOfMilageВсего;
		TonneKilometersВсего	= ТаблицаДвиженийТрипа.Итог("TonneKilometers");
		
		ТекСчетчик	= 1;
		ВсегоСтрок	= ТаблицаДвиженийТрипа.Количество();
		
		// Если базы распределения нет, то ничего делать не надо
		Если TonneKilometersВсего <> 0 Тогда
		
			Для Каждого СтрокаДвижений Из ТаблицаДвижений Цикл
				
				Если НЕ СтрокаДвижений.Trip = ТекТрип Тогда
					Продолжить;
				КонецЕсли;
				
				Если ТекСчетчик = ВсегоСтрок Тогда
					СтрокаДвижений.Sum = SumВсего - SumТек;
				Иначе
					СтрокаДвижений.Sum = SumВсего * СтрокаДвижений.TonneKilometers / TonneKilometersВсего;
				КонецЕсли;
				
				SumТек		= SumТек + СтрокаДвижений.Sum;
				ТекСчетчик	= ТекСчетчик + 1;
				
			КонецЦикла;
			
		КонецЕсли;	
		
	КонецЦикла;
		
	Возврат ТаблицаДвижений;
	
КонецФункции

Функция ПолучитьТаблицуДвиженийRouteOfLocation(Трип)
	
	ТаблицаДвижений = Новый ТаблицаЗначений;
	
	ТаблицаДвижений.Колонки.Добавить("Период",			ОбщегоНазначения.ПолучитьОписаниеТиповДаты(ЧастиДаты.ДатаВремя));
	ТаблицаДвижений.Колонки.Добавить("LocationStart",	Новый ОписаниеТипов("СправочникСсылка.Warehouses"));
	ТаблицаДвижений.Колонки.Добавить("LocationEnd",		Новый ОписаниеТипов("СправочникСсылка.Warehouses"));
	ТаблицаДвижений.Колонки.Добавить("Mileage",			ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,3));
	ТаблицаДвижений.Колонки.Добавить("Trip",			Новый ОписаниеТипов("ДокументСсылка.TripNonLawsonCompanies"));
	
	ТекLocation = Неопределено;
	Для Каждого СтрStops Из Трип.Stops Цикл
		
		Если СтрStops.Type = Перечисления.StopsTypes.Source Тогда
			ТекLocation = СтрStops.Location;
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		
		НоваяСтрока.Период			= Трип.Дата;
		НоваяСтрока.LocationStart	= ТекLocation;
		НоваяСтрока.LocationEnd		= СтрStops.Location;
		НоваяСтрока.Mileage			= СтрStops.Mileage;
		НоваяСтрока.Trip			= Трип;
			
		ТекLocation = СтрStops.Location;
		
	КонецЦикла;
	
	Возврат ТаблицаДвижений;
	
КонецФункции

Функция ПолучитьВсеКомбинацииРасстояний(ТаблицаРасстояний) Экспорт
	
	ТаблицаРезультат = ТаблицаРасстояний.Скопировать();
	
	ВсегоСтрок = ТаблицаРасстояний.Количество();
	
	Для ы = 1 По ВсегоСтрок Цикл
		
		ТекРасстояние = ТаблицаРасстояний[ы-1].Mileage;
		Для ыы = ы + 1 По ВсегоСтрок Цикл
			
			Если НЕ ТаблицаРасстояний[ыы-1].Trip = ТаблицаРасстояний[ы-1].Trip  Тогда
				Продолжить;
			КонецЕсли;
			
			НоваяСтрока = ТаблицаРезультат.Добавить();
			
			НоваяСтрока.LocationStart	= ТаблицаРасстояний[ы-1].LocationStart;
			НоваяСтрока.LocationEnd		= ТаблицаРасстояний[ыы-1].LocationEnd;
			НоваяСтрока.Mileage			= ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			НоваяСтрока.Trip			= ТаблицаРасстояний[ыы-1].Trip;
			
			ТекРасстояние = ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаРезультат;
	
КонецФункции

// { RGS AArsentev 5/22/2017 11:30:01 AM - S-I-0002788
Процедура СформироватьДвиженияLocalDistributionAccessorialCostsPerItem(Отказ)
	
	ДвиженияLocalDistributionAccessorialCostsPerItem = Движения.LocalDistributionAccessorialCostsPerItem;
	
	ДвиженияLocalDistributionAccessorialCostsPerItem.Записывать = Истина;
	ДвиженияLocalDistributionAccessorialCostsPerItem.Очистить();
	
	Таблица_RentalTrucks = RentalTrucks.Выгрузить();	
	Таблица_RentalTrucks.Свернуть("Trip, Идентификатор, Currency, DateTrip");
	
	Для Каждого ТекСтрокаRentalTrucks Из Таблица_RentalTrucks Цикл
		
		СтруктураПоиска = Новый Структура("Идентификатор", ТекСтрокаRentalTrucks.Идентификатор);
		
		МассивНайденныхСтрок = AccessorialCosts.НайтиСтроки(СтруктураПоиска);
		
		Если МассивНайденныхСтрок.Количество() = 0 Тогда
			Продолжить
		Иначе
			
			Для Каждого Строка Из МассивНайденныхСтрок Цикл
				
				ATA_FD = ТекСтрокаRentalTrucks.Trip.Stops.Найти(Перечисления.StopsTypes.Destination, "Type").ActualArrivalLocalTime;
				
				Запрос = Новый Запрос;
				Запрос.УстановитьПараметр("Parcels", ТекСтрокаRentalTrucks.Trip.Parcels.Выгрузить());
				
				Запрос.Текст = "ВЫБРАТЬ
				|	Parcels.Parcel КАК Parcel,
				|	Parcels.NumOfParcels КАК NumOfParcels
				|ПОМЕСТИТЬ Parcels
				|ИЗ
				|	&Parcels КАК Parcels
				|;
				|ВЫБРАТЬ
				|	TripParcels.Parcel.GrossWeightKG / TripParcels.Parcel.NumOfParcels * TripParcels.NumOfParcels КАК GrossWeightKG,
				|	0 КАК AccessorialCostsSumPerParcel,
				|	TripParcels.Parcel
				|ИЗ
				|	Parcels КАК TripParcels
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ
				|	ParcelsДетали.Ссылка КАК Parcel,
				|	ParcelsДетали.СтрокаИнвойса КАК Item,
				|	1 КАК Количество,
				|	0 КАК AccessorialCostsSumPerItem,
				|	ParcelsДетали.СтрокаИнвойса.КостЦентр.Segment КАК Segment,
				|	ParcelsДетали.СтрокаИнвойса.КостЦентр.SubSegment КАК SubSegment,
				|	ParcelsДетали.СтрокаИнвойса.КостЦентр.Geomarket КАК Geomarket,
				|	ParcelsДетали.СтрокаИнвойса.КостЦентр.SubGeomarket КАК SubGeomarket,
				|	ParcelsДетали.СтрокаИнвойса.SoldTo КАК ParentCompany
				|ИЗ
				|	Справочник.Parcels.Детали КАК ParcelsДетали
				|ГДЕ
				|	ParcelsДетали.Ссылка В
				|			(ВЫБРАТЬ
				|				Parcels.Parcel
				|			ИЗ
				|				Parcels КАК Parcels)";
				
				Результат = Запрос.ВыполнитьПакет();
				
				ТЗParcels = Результат[1].Выгрузить();
				
				УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcels.ВыгрузитьКолонку("GrossWeightKG"), Строка.Sum, ТЗParcels, "AccessorialCostsSumPerParcel");
				
				ТЗItems = Результат[2].Выгрузить();
				СтруктураОтбораПоParcel = Новый Структура("Parcel");
				Для Каждого СтрParcel Из ТЗParcels Цикл
					
					СтруктураОтбораПоParcel.Parcel = СтрParcel.Parcel;
					ТЗParcelItems = ТЗItems.Скопировать(СтруктураОтбораПоParcel);
					
					УчетНДС.РаспределитьСуммуПоСтолбцу(ТЗParcelItems.ВыгрузитьКолонку("Количество"), СтрParcel.AccessorialCostsSumPerParcel, ТЗParcelItems, "AccessorialCostsSumPerItem");
					
					Для Каждого СтрокаТЗ Из ТЗParcelItems Цикл
						
						
						Движение = ДвиженияLocalDistributionAccessorialCostsPerItem.Добавить();
						Движение.Период = ТекСтрокаRentalTrucks.DateTrip;
						Движение.Trip 	= ТекСтрокаRentalTrucks.Trip;     
						Движение.Parcel = СтрокаТЗ.Parcel;
						Движение.Item 	= СтрокаТЗ.Item;
						Движение.CostType = Строка.CostType;
						
						Движение.AccessorialCostsSum = СтрокаТЗ.AccessorialCostsSumPerItem;
						
						Если ЗначениеЗаполнено(СтрокаТЗ.AccessorialCostsSumPerItem) И ЗначениеЗаполнено(ТекСтрокаRentalTrucks.Currency) И ЗначениеЗаполнено(ТекСтрокаRentalTrucks.DateTrip) Тогда 
							Движение.AccessorialCostsSumUSD 		= LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(СтрокаТЗ.AccessorialCostsSumPerItem, ТекСтрокаRentalTrucks.Currency, ТекСтрокаRentalTrucks.DateTrip);
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЦикла;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // } RGS AArsentev 5/22/2017 11:30:01 AM - S-I-0002788

Функция ТребуетсяСогласование()
	
	CostSum = 0;
	Для Каждого Строка Из RentalTrucks Цикл
		CostSum = CostSum + LocalDistributionForNonLawsonСервер.ПолучитьCostsSumSLBUSD(Строка.Cost, Строка.Currency, Дата);
	КонецЦикла;
	
	СтруктураBaseCostsSumLimit = РегистрыСведений.BaseCostsSumLimitForApproval.ПолучитьПоследнее(Дата);
	
	Возврат (CostSum > СтруктураBaseCostsSumLimit.LimitForApprovalLevel1ManualPlanning);
	
КонецФункции

Функция ПроверитьСогласование()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	RentalCostsApproval.Ссылка
	|ИЗ
	|	Задача.RentalCostsApproval КАК RentalCostsApproval
	|ГДЕ
	|	RentalCostsApproval.Выполнена
	|	И RentalCostsApproval.RentalCost = &RentalCost
	|	И RentalCostsApproval.Status = ЗНАЧЕНИЕ(Перечисление.StatusesOFApproval.Approved)
	|	И НЕ RentalCostsApproval.ПометкаУдаления";
	Запрос.УстановитьПараметр("RentalCost", Ссылка);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

Процедура ЗаполнитьВерификацию()
	
	УстановитьПривилегированныйРежим(Истина);
	Для Каждого Трип Из RentalTrucks Цикл
		
		ДокТрип = Трип.Trip.ПолучитьОбъект();
		ДокТрип.ОбменДанными.Загрузка = Истина;
		ДокТрип.VerifiedByBillingSpecialist = Дата;
		ДокТрип.BillingSpecialist = ПараметрыСеанса.ТекущийПользователь;
		ЕстьЗаписьBill = ПроверитьТаблицуBill(Трип.Trip);
		Если Не ЕстьЗаписьBill Тогда
			ДокСтрокаBill = ДокТрип.Bills.Добавить();
			ДокСтрокаBill.Bill = "Rental costs - " + Номер;
		КонецЕсли;
		ДокТрип.Записать();
		
	КонецЦикла;
	УстановитьПривилегированныйРежим(Ложь);
	
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

// { RGS AArsentev 12.04.2018 - Не учитываются случаи движения от Source до Destination
Функция ПолучитьТаблицуМаршрутов(Трип)
	
	ТаблицаРасстояний = ПолучитьТаблицуДвиженийRouteOfLocation(Трип);
	
	ТаблицаРезультат = ТаблицаРасстояний.Скопировать();
	
	ВсегоСтрок = ТаблицаРасстояний.Количество();
	
	Для ы = 1 По ВсегоСтрок Цикл
		
		ТекРасстояние = ТаблицаРасстояний[ы-1].Mileage;
		Для ыы = ы + 1 По ВсегоСтрок Цикл
			
			НоваяСтрока = ТаблицаРезультат.Добавить();
			
			НоваяСтрока.LocationStart	= ТаблицаРасстояний[ы-1].LocationStart;
			НоваяСтрока.LocationEnd		= ТаблицаРасстояний[ыы-1].LocationEnd;
			НоваяСтрока.Mileage			= ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			НоваяСтрока.Trip			= Трип;
			
			ТекРасстояние = ТекРасстояние + ТаблицаРасстояний[ыы-1].Mileage;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаРезультат;
	
КонецФункции // } RGS AArsentev 12.04.2018

