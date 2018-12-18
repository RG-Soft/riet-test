

&НаКлиенте
Процедура PickUpFromCountryПриИзменении(Элемент)
		
	CountryAZ = ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.AZ"); // S-I-0002174 AZ (только внутри AZ)
	Если Не ЗначениеЗаполнено(Объект.DeliverToCountry) И Объект.PickUpFromCountry = CountryAZ Тогда    
		Объект.DeliverToCountry = CountryAZ;
	КонецЕсли;
	
	CountryTM = ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.TM"); // S-I-0002694 TM (только внутри TM)
	Если Не ЗначениеЗаполнено(Объект.DeliverToCountry) И Объект.PickUpFromCountry = CountryTM Тогда    
		Объект.DeliverToCountry = CountryTM;
	КонецЕсли;
	
	Объект.PickUpFromCity = Неопределено;
	МассивCities = ПолучитьМассивCities(Объект.PickUpFromCountry);
	
	НовыйМассивПараметров = Новый Массив;
	НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", МассивCities));
	НовыеПараметрыВыбора = Новый ФиксированныйМассив(НовыйМассивПараметров);
	Элементы.PickUpFromCity.ПараметрыВыбора = НовыеПараметрыВыбора;
	ОчиститьДеревоЗнач();
	ТаблицаГрузовыхМест.Очистить();
	
КонецПроцедуры

&НаКлиенте
Процедура DeliverToCountryПриИзменении(Элемент)
	
	Объект.DeliverToCity = Неопределено;
	МассивCities = ПолучитьМассивCities(Объект.DeliverToCountry);
	
	НовыйМассивПараметров = Новый Массив;
	НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", МассивCities));
	НовыеПараметрыВыбора = Новый ФиксированныйМассив(НовыйМассивПараметров);
	Элементы.DeliverToCity.ПараметрыВыбора = НовыеПараметрыВыбора;
	ОчиститьДеревоЗнач();
	ТаблицаГрузовыхМест.Очистить();
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивCities(Country);
	
	Если ЗначениеЗаполнено(Country) Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	Warehouses.City
		|ИЗ
		|	Справочник.Warehouses КАК Warehouses
		|ГДЕ
		|	Warehouses.RCACountry = &RCACountry
		|	И НЕ Warehouses.City.ПометкаУдаления
		|
		|СГРУППИРОВАТЬ ПО
		|	Warehouses.City";
		Запрос.УстановитьПараметр("RCACountry", Country);
		Результат = Запрос.Выполнить().Выгрузить();
		Возврат Результат.ВыгрузитьКолонку("City");
		
	Иначе
		
		МассивCities = Новый Массив;
		
		Возврат МассивCities;
		
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура PickUpFromCityНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Объект.PickUpFromCountry) Тогда
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура DeliverToCityНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Объект.DeliverToCountry) Тогда
		СтандартнаяОбработка = Ложь;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура РасчитатьПоДаннымНаСервере()
	
	//ОбъемныйВес = ?(((Объект.Length/ 100) * (Объект.Width/100) * (Объект.Height/100) * Объект.NumOfParcels * 167) < Объект.GrossWeightKG * Объект.NumOfParcels, Объект.GrossWeightKG * Объект.NumOfParcels, ((Объект.Length * Объект.Width * Объект.Height) / 100 * Объект.NumOfParcels * 167));
	ДанныеПоДокументуTripNonLawson = ПолучитьДанныеNonLawson(0);
	
	ДанныеПоДокументуTripNonLawson.Свернуть("Trip, SumPerTonneKillometer, SumPerKG, ServiceProvider, MOT, Milage, TotalActualDuration, Sum");
	
	//ТаблицаПоTrips.Свернуть("Trip, SumPerTonneKillometer, SumPerKG, ServiceProvider, MOT, Milage, TotalActualDuration");
	КонечнаяТаблица = Новый ТаблицаЗначений;
	КонечнаяТаблица.Колонки.Добавить("PickUpFromCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
	КонечнаяТаблица.Колонки.Добавить("DeliverToCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
	КонечнаяТаблица.Колонки.Добавить("Sum", Новый ОписаниеТипов("Число"));
	КонечнаяТаблица.Колонки.Добавить("MOT", Новый ОписаниеТипов("СправочникСсылка.MOTs"));
	КонечнаяТаблица.Колонки.Добавить("ServiceProvider", Новый ОписаниеТипов("СправочникСсылка.ServiceProviders"));
	КонечнаяТаблица.Колонки.Добавить("TotalActualDuration", Новый ОписаниеТипов("Строка"));
	КонечнаяТаблица.Колонки.Добавить("Equipment", Новый ОписаниеТипов("СправочникСсылка.Equipments"));
	
	
	MOTs = ДанныеПоДокументуTripNonLawson.Скопировать();
	MOTs.Свернуть("MOT");
	
	КолВоЦиклов = 0;
	КоличествоServiceProviders = 3;
	
	Если ЗначениеЗаполнено(Объект.Equipment) Тогда
		Элементы.РезультатДеревоEquipment.Видимость = Ложь;
	Иначе
		Элементы.РезультатДеревоEquipment.Видимость = Истина;
	КонецЕсли;
	
	Для Каждого СтрокаMOT Из MOTs Цикл
		Если НЕ СтрокаMOT.MOT = Справочники.MOTs.AIR И НЕ СтрокаMOT.MOT = Справочники.MOTs.COURIER И НЕ СтрокаMOT.MOT = Справочники.MOTs.НайтиПоКоду("TRUCK") Тогда
			Продолжить;
		КонецЕсли;
		Отбор = Новый Структура();
		Отбор.Вставить("MOT", СтрокаMOT.MOT);
		
		ТаблицаПоMOT = ДанныеПоДокументуTripNonLawson.Скопировать(Отбор);
		
		ТаблицаПоMOT.Сортировать("Sum Возр");
		
		КолВоЦиклов = 0;
		МассивSP = Новый Массив;
		МассивTrips = Новый Массив;
		Для Каждого Элемент Из ТаблицаПоMOT Цикл
			Если Элемент.SumPerKG = 0 ИЛИ Элемент.SumPerTonneKillometer = 0 Тогда
				Продолжить
			КонецЕсли;
			Если МассивSP.Найти(Элемент.ServiceProvider) = Неопределено И КоличествоServiceProviders > КолВоЦиклов
				И МассивTrips.Найти(Элемент.Trip) = Неопределено Тогда
				КолВоЦиклов = КолВоЦиклов + 1;
				СтрокаТаблицы = КонечнаяТаблица.Добавить();
				СтрокаТаблицы.PickUpFromCity = Объект.PickUpFromCity;
				СтрокаТаблицы.DeliverToCity = Объект.DeliverToCity;
				СтрокаТаблицы.MOT = СтрокаMOT.MOT;
				СтрокаТаблицы.ServiceProvider = Элемент.ServiceProvider;
				СтрокаТаблицы.TotalActualDuration = ПолучитьПредставлениеDuration(Элемент.TotalActualDuration);
				СтрокаТаблицы.Equipment = Элемент.Trip.Equipment;
				//Если СтрокаMOT.MOT = Справочники.MOTs.AIR Тогда
					СтрокаТаблицы.Sum = ПересчитатьВалюту(Элемент.Sum);
				//Иначе
				//	СтрокаТаблицы.Sum = ПересчитатьВалюту(Элемент.SumPerTonneKillometer);
				///КонецЕсли;
				Если КолВоЦиклов = 3 Тогда
					ПовторялсяТрижды = ПроверитьКолВоПодрядчиков(Элемент.ServiceProvider, КонечнаяТаблица);
					Если ПовторялсяТрижды Тогда
						МассивSP.Добавить(Элемент.ServiceProvider);
						КоличествоServiceProviders = 4;
					КонецЕсли;
				КонецЕсли;
				МассивTrips.Добавить(Элемент.Trip);
				
			Иначе
				Продолжить
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДанныеЗапроса.PickUpFromCity,
	               |	ДанныеЗапроса.DeliverToCity,
	               |	ДанныеЗапроса.Sum,
	               |	ДанныеЗапроса.MOT,
	               |	ДанныеЗапроса.ServiceProvider,
	               |	ДанныеЗапроса.TotalActualDuration,
	               |	ДанныеЗапроса.Equipment
	               |ПОМЕСТИТЬ ДанныеТЗ
	               |ИЗ
	               |	&ДанныеЗапросаТаблица КАК ДанныеЗапроса
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДанныеТЗ.Sum КАК Sum,
	               |	ДанныеТЗ.ServiceProvider КАК ServiceProvider,
	               |	ДанныеТЗ.MOT КАК MOT,
	               |	ДанныеТЗ.TotalActualDuration КАК Days,
	               |	ДанныеТЗ.Equipment
	               |ИЗ
	               |	ДанныеТЗ КАК ДанныеТЗ
	               |ИТОГИ ПО
	               |	MOT";
	Запрос.УстановитьПараметр("ДанныеЗапросаТаблица", КонечнаяТаблица);
	
	//Дерево = РеквизитФормыВЗначение("РезультатДерево");
	Дерево = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
	ЗначениеВРеквизитФормы(Дерево, "РезультатДерево");
	
	ПолучитьСуммыRentals();
	
КонецПроцедуры

&НаКлиенте
Процедура РасчитатьПоДанным(Команда)
	РасчитатьПоДаннымНаСервере();
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеNonLawson(ОбъемныйВесТекЛинии)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	TripNonLawsonCompaniesParcels.Ссылка КАК Trip,
	|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider КАК ServiceProvider,
	|	TripNonLawsonCompaniesParcels.Ссылка.MOT КАК MOT,
	|	СУММА(ВЫБОР
	|			КОГДА TripNonLawsonCompaniesParcels.Ссылка.GrossWeightKG = 0
	|					ИЛИ TripNonLawsonCompaniesParcels.Parcel.NumOfParcels = 0
	|				ТОГДА 0
	|			ИНАЧЕ ЕСТЬNULL(LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот, 0) / TripNonLawsonCompaniesParcels.Ссылка.GrossWeightKG * TripNonLawsonCompaniesParcels.Parcel.GrossWeight * (TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels)
	|		КОНЕЦ) КАК Sum,
	|	СУММА(ВЫБОР
	|			КОГДА TripNonLawsonCompaniesParcels.Ссылка.GrossWeightKG = 0
	|					ИЛИ TripNonLawsonCompaniesParcels.Parcel.NumOfParcels = 0
	|				ТОГДА 0
	|			ИНАЧЕ ЕСТЬNULL(LocalDistributionCostsMilageWeightVolumeОбороты.TonneKilometersОборот, 0) / TripNonLawsonCompaniesParcels.Ссылка.GrossWeightKG * TripNonLawsonCompaniesParcels.Parcel.GrossWeight * (TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels)
	|		КОНЕЦ) КАК TonneKilometers,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation.RCACountry КАК PickUpFromCountry,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation.City КАК PickUpFromCity,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation.RCACountry КАК DeliverToCountry,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation.City КАК DeliverToCity,
	|	Сумма(TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG * TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels) КАК GrossWeightKG,
	|	СУММА(TripNonLawsonCompaniesParcels.Parcel.VolumeWeight * TripNonLawsonCompaniesParcels.NumOfParcels / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels) КАК VolumeWeight,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MilageОборот,
	|	LocalDistributionCostsPerKGОбороты.CostsSumPerKGUSDОборот
	|ПОМЕСТИТЬ ТаблицаДанных
	|ИЗ
	|	РегистрНакопления.LocalDistributionCostsMilageWeightVolume.Обороты(
	|			&ДатаНачала,
	|			&ДатаОкончания,
	|			Запись,
	|			SourceLocation.City = &FromCity
	|				И SourceLocation.RCACountry = &FromRCACountry
	|				И DestinationLocation.City = &ToCity
	|				И DestinationLocation.RCACountry = &ToRCACountry) КАК LocalDistributionCostsMilageWeightVolumeОбороты
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	|		ПО LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор = TripNonLawsonCompaniesParcels.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerKG.Обороты(
	|				&ДатаНачала,
	|				&ДатаОкончания,
	|				Запись,
	|				SourceLocation.City = &FromCity
	|					И SourceLocation.RCACountry = &FromRCACountry
	|					И DestinationLocation.City = &ToCity
	|					И DestinationLocation.RCACountry = &ToRCACountry) КАК LocalDistributionCostsPerKGОбороты
	|		ПО LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор = LocalDistributionCostsPerKGОбороты.Регистратор
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.MOT = LocalDistributionCostsPerKGОбороты.MOT
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation = LocalDistributionCostsPerKGОбороты.SourceLocation
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation = LocalDistributionCostsPerKGОбороты.DestinationLocation
	|ГДЕ
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор ССЫЛКА Документ.TripNonLawsonCompanies
	|	И LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот <> 0
	|   // ДопОтборы
	|
	|СГРУППИРОВАТЬ ПО
	|	TripNonLawsonCompaniesParcels.Ссылка.ServiceProvider,
	|	TripNonLawsonCompaniesParcels.Ссылка.MOT,
	|	TripNonLawsonCompaniesParcels.Ссылка,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Период,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation.RCACountry,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation.City,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation.RCACountry,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation.City,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MilageОборот,
	|	LocalDistributionCostsPerKGОбороты.CostsSumPerKGUSDОборот
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаДанных.Trip КАК Trip,
	|	ТаблицаДанных.ServiceProvider КАК ServiceProvider,
	|	ТаблицаДанных.MOT КАК MOT,
	|	СУММА(ТаблицаДанных.Sum) КАК Sum,
	|	СУММА(ТаблицаДанных.TonneKilometers) КАК TonneKilometers,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА ТаблицаДанных.TonneKilometers = 0
	|				ТОГДА 0
	|			ИНАЧЕ ТаблицаДанных.Sum / ТаблицаДанных.TonneKilometers
	|		КОНЕЦ КАК ЧИСЛО(10, 2)) КАК SumPerTonneKillometer,
	|	ТаблицаДанных.PickUpFromCountry КАК PickUpFromCountry,
	|	ТаблицаДанных.PickUpFromCity КАК PickUpFromCity,
	|	ТаблицаДанных.DeliverToCountry КАК DeliverToCountry,
	|	ТаблицаДанных.DeliverToCity КАК DeliverToCity,
	|	ТаблицаДанных.GrossWeightKG КАК GrossWeightKG,
	|	ТаблицаДанных.VolumeWeight КАК VolumeWeight,
	|	ВЫРАЗИТЬ(ТаблицаДанных.MilageОборот КАК ЧИСЛО(10, 0)) КАК Milage,
	|	ТаблицаДанных.Trip.TotalActualDuration КАК TotalActualDuration,
	|	ТаблицаДанных.CostsSumPerKGUSDОборот КАК SumPerKG
	|ИЗ
	|	ТаблицаДанных КАК ТаблицаДанных
	| // ОтборСборнаяОтправка
	|
	|СГРУППИРОВАТЬ ПО
	|	ТаблицаДанных.Trip,
	|	ТаблицаДанных.ServiceProvider,
	|	ТаблицаДанных.MOT,
	|	ТаблицаДанных.DeliverToCity,
	|	ТаблицаДанных.PickUpFromCity,
	|	ТаблицаДанных.PickUpFromCountry,
	|	ТаблицаДанных.DeliverToCountry,
	|	ТаблицаДанных.GrossWeightKG,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА ТаблицаДанных.TonneKilometers = 0
	|				ТОГДА 0
	|			ИНАЧЕ ТаблицаДанных.Sum / ТаблицаДанных.TonneKilometers
	|		КОНЕЦ КАК ЧИСЛО(10, 2)),
	|	ТаблицаДанных.VolumeWeight,
	|	ТаблицаДанных.Trip.TotalActualDuration,
	|	ТаблицаДанных.CostsSumPerKGUSDОборот,
	|	ВЫРАЗИТЬ(ТаблицаДанных.MilageОборот КАК ЧИСЛО(10, 0))";
	
	Запрос.УстановитьПараметр("FromCity", Объект.PickUpFromCity);
	Запрос.УстановитьПараметр("FromRCACountry", Объект.PickUpFromCountry);
	Запрос.УстановитьПараметр("ToCity", Объект.DeliverToCity);
	Запрос.УстановитьПараметр("ToRCACountry", Объект.DeliverToCountry);
	
	Запрос.УстановитьПараметр("ДатаНачала", ДобавитьМесяц(ТекущаяДата(),-12));
	Запрос.УстановитьПараметр("ДатаОкончания", ТекущаяДата());
	
	Если ОбъемныйВесТекЛинии = 0 Тогда
		
		ДопОтборы = "";
		
		Если ЗначениеЗаполнено(Объект.MOT) Тогда
			
			ДопОтборы = ДопОтборы + "
			|	И TripNonLawsonCompaniesParcels.Ссылка.MOT = &MOT";
			Запрос.УстановитьПараметр("MOT", Объект.MOT);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.Equipment) Тогда
			
			ДопОтборы = ДопОтборы + "
			|	И TripNonLawsonCompaniesParcels.Ссылка.Equipment = &Equipment";
			Запрос.УстановитьПараметр("Equipment", Объект.Equipment);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ДопОтборы) Тогда
			Запрос.Текст = СтрЗаменить(Запрос.Текст, "// ДопОтборы", ДопОтборы);
		КонецЕсли;
		
	Иначе
		
		ОтборСборнаяОтправка = "
		| ГДЕ
		|	ТаблицаДанных.GrossWeightKG <= &GrossWeightKG ";
		Запрос.УстановитьПараметр("GrossWeightKG", ОбъемныйВесТекЛинии);
		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "// ОтборСборнаяОтправка", ОтборСборнаяОтправка);
		
	КонецЕсли;
	
	РезультатПоTripNon = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатПоTripNon;
	
КонецФункции

&НаСервере
Функция ПолучитьДанныеTrip(ОбъемныйВесТекЛинии)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор КАК Регистратор,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation КАК SourceLocation,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation КАК DestinationLocation,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MOT КАК MOT,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор.ServiceProvider КАК РегистраторServiceProvider,
	|	LocalDistributionCostsPerKGОбороты.CostsSumPerKGUSDОборот КАК CostsSumPerKGUSD,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.WeightОборот КАК WeightОборот,
	|	ВЫРАЗИТЬ(LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот / LocalDistributionCostsMilageWeightVolumeОбороты.TonneKilometersОборот КАК ЧИСЛО(10, 2)) КАК CostsSumPerTKUSD,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MilageОборот
	|ПОМЕСТИТЬ ВременнаяТаблица
	|ИЗ
	|	РегистрНакопления.LocalDistributionCostsMilageWeightVolume.Обороты(
	|			&ДатаНачала,
	|			&ДатаОкончания,
	|			Запись,
	|			SourceLocation.City = &FromCity
	|				И SourceLocation.RCACountry = &FromRCACountry
	|				И DestinationLocation.City = &ToCity
	|				И DestinationLocation.RCACountry = &ToRCACountry) КАК LocalDistributionCostsMilageWeightVolumeОбороты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.LocalDistributionCostsPerKG.Обороты(
	|				&ДатаНачала,
	|				&ДатаОкончания,
	|				Запись,
	|				SourceLocation.City = &FromCity
	|					И SourceLocation.RCACountry = &FromRCACountry
	|					И DestinationLocation.City = &ToCity
	|					И DestinationLocation.RCACountry = &ToRCACountry) КАК LocalDistributionCostsPerKGОбороты
	|		ПО LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор = LocalDistributionCostsPerKGОбороты.Регистратор
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation = LocalDistributionCostsPerKGОбороты.SourceLocation
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation = LocalDistributionCostsPerKGОбороты.DestinationLocation
	|			И LocalDistributionCostsMilageWeightVolumeОбороты.MOT = LocalDistributionCostsPerKGОбороты.MOT
	|ГДЕ
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор ССЫЛКА Документ.Trip
	|	И LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.SourceLocation,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.DestinationLocation,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MOT,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.Регистратор.ServiceProvider,
	|	LocalDistributionCostsPerKGОбороты.CostsSumPerKGUSDОборот,
	|	LocalDistributionCostsMilageWeightVolumeОбороты.WeightОборот,
	|	ВЫРАЗИТЬ(LocalDistributionCostsMilageWeightVolumeОбороты.SumОборот / LocalDistributionCostsMilageWeightVolumeОбороты.TonneKilometersОборот КАК ЧИСЛО(10, 2)),
	|	LocalDistributionCostsMilageWeightVolumeОбороты.MilageОборот
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВременнаяТаблица.Регистратор КАК Trip,
	|	ВременнаяТаблица.MOT КАК MOT,
	|	ВременнаяТаблица.РегистраторServiceProvider КАК ServiceProvider,
	|	ВременнаяТаблица.CostsSumPerKGUSD КАК SumPerKG,
	|	ВременнаяТаблица.CostsSumPerTKUSD КАК SumPerTonneKillometer,
	|	ВременнаяТаблица.SourceLocation.RCACountry КАК PickUpFromRCACountry,
	|	ВременнаяТаблица.SourceLocation.City КАК PickUpFromCity,
	|	ВременнаяТаблица.DestinationLocation.RCACountry КАК DeliverToRCACountry,
	|	ВременнаяТаблица.DestinationLocation.City КАК DeliverToCity,
	|	ВременнаяТаблица.MilageОборот КАК Milage
	|ИЗ
	|	ВременнаяТаблица КАК ВременнаяТаблица
	|ГДЕ
	|	ВременнаяТаблица.WeightОборот <= &VolumeWeight
	|
	|СГРУППИРОВАТЬ ПО
	|	ВременнаяТаблица.Регистратор,
	|	ВременнаяТаблица.MOT,
	|	ВременнаяТаблица.РегистраторServiceProvider,
	|	ВременнаяТаблица.CostsSumPerKGUSD,
	|	ВременнаяТаблица.CostsSumPerTKUSD,
	|	ВременнаяТаблица.SourceLocation.RCACountry,
	|	ВременнаяТаблица.SourceLocation.City,
	|	ВременнаяТаблица.DestinationLocation.RCACountry,
	|	ВременнаяТаблица.DestinationLocation.City,
	|	ВременнаяТаблица.MilageОборот";
	
	Запрос.УстановитьПараметр("FromCity", Объект.PickUpFromCity);
	Запрос.УстановитьПараметр("FromRCACountry", Объект.PickUpFromCountry);
	Запрос.УстановитьПараметр("ToCity", Объект.DeliverToCity);
	Запрос.УстановитьПараметр("ToRCACountry", Объект.DeliverToCountry);
	Запрос.УстановитьПараметр("VolumeWeight", ОбъемныйВесТекЛинии);
	Запрос.УстановитьПараметр("ДатаНачала", ДобавитьМесяц(ТекущаяДата(),-12));
	Запрос.УстановитьПараметр("ДатаОкончания", ТекущаяДата());
	
	РезультатПоTrip = Запрос.Выполнить().Выгрузить();
	
	Возврат РезультатПоTrip;
	
КонецФункции

Процедура ДополнитьТаблицу(ТаблицаИсточник, ТаблицаПриемник) Экспорт
	
	Для Каждого СтрокаТаблицыИсточник Из ТаблицаИсточник Цикл
		
		ЗаполнитьЗначенияСвойств(ТаблицаПриемник.Добавить(), СтрокаТаблицыИсточник);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Полный = Истина;
	СборнаяОтправка = Истина;
	PerKG = Истина;
	АктивнаяСтрока = 1;
	//Элементы.РезультатОтдельная.Видимость = Ложь;
	Элементы.ОтборыParcel.Видимость = Истина;
	Элементы.Объем.Видимость = Истина;
	Элементы.ОтборыОтдельнаяОтправка.Видимость = Ложь;
	Элементы.РезультатRentals.Видимость = Ложь;
	Элементы.РасчитатьПоДанным.Видимость = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПолныйПриИзменении(Элемент)
	Если Полный Тогда
		Сокращенный = Ложь;
	Иначе
		Сокращенный = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СокращенныйПриИзменении(Элемент)
	
	Если Сокращенный Тогда
		Полный = Ложь;
	Иначе
		Полный = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура PerTonneKillometerПриИзменении(Элемент)
	Если PerTonneKillometer Тогда
		PerKG = Ложь;
	Иначе
		PerKG = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура PerKGПриИзменении(Элемент)
	Если PerKG Тогда
		PerTonneKillometer = Ложь;
	Иначе
		PerTonneKillometer = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоРазвернуть(Команда)
	
	КоллекцияЭлементовДерева = РезультатДерево.ПолучитьЭлементы();
	
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл
		ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
		Элементы.РезультатДерево.Развернуть(ИдентификаторСтроки);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДеревоСвернуть(Команда)
	
	КоллекцияЭлементовДерева = РезультатДерево.ПолучитьЭлементы();
	
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл
		ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
		Элементы.РезультатДерево.Свернуть(ИдентификаторСтроки);
	КонецЦикла;
	
КонецПроцедуры


&НаСервере
Процедура ДобавитьЛиниюГрузаНаСервере()
	
	Если ЗначениеЗаполнено(Объект.GrossWeightKG) И ЗначениеЗаполнено(Объект.Length) И ЗначениеЗаполнено(Объект.Width) 
		И ЗначениеЗаполнено(Объект.Height) И ЗначениеЗаполнено(Объект.NumOfParcels) Тогда
		НоваяЛиния = ТаблицаГрузовыхМест.Добавить();
		НоваяЛиния.Вес = Объект.GrossWeightKG;
		НоваяЛиния.Length = Объект.Length;
		НоваяЛиния.Width = Объект.Width;
		НоваяЛиния.Height = Объект.Height;
		НоваяЛиния.Num = Объект.NumOfParcels;
	Иначе
		Если Не ЗначениеЗаполнено(Объект.GrossWeightKG) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан вес грузового места");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.Length) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указана длина грузового места");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.Width) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указана ширина грузового места");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.Height) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указана высота грузового места");
		КонецЕсли;
		Если Не ЗначениеЗаполнено(Объект.NumOfParcels) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указано количество грузовых мест");
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ДобавитьЛиниюГруза(Команда)
	ДобавитьЛиниюГрузаНаСервере();
	ПосчитатьОбъем();
КонецПроцедуры


&НаКлиенте
Процедура ТаблицаГрузовыхМестПриАктивизацииСтроки(Элемент)
	
	//ТекущиеДанные = Элементы.ТаблицаГрузовыхМест.ТекущиеДанные;
	//
	//Если ТекущиеДанные = Неопределено ИЛИ АктивнаяСтрока = Элементы.ТаблицаГрузовыхМест.ТекущаяСтрока Тогда
	//	
	//	Возврат;
	//	
	//Иначе
	//	
	//	ОбъемныйВесТекЛинии = ?(((ТекущиеДанные.Length/ 100) * (ТекущиеДанные.Width/100) * (ТекущиеДанные.Height/100) * ТекущиеДанные.Num * 167) < ТекущиеДанные.Вес * ТекущиеДанные.Num, ТекущиеДанные.Вес * ТекущиеДанные.Num, ((ТекущиеДанные.Length * ТекущиеДанные.Width * ТекущиеДанные.Height) / 100 * ТекущиеДанные.Num * 167)); 
	//	
	//	АктивнаяСтрока = Элементы.ТаблицаГрузовыхМест.ТекущаяСтрока;
	//	
	//	ПолучитьСуммыПеревозок(ОбъемныйВесТекЛинии);
	//	
	//КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьСуммыПеревозок(ОбъемныйВесТекЛинии)
	
	ОчиститьДеревоЗнач();
	
	Если ОтдельнаяОтправка Тогда 
		Если Не ЗначениеЗаполнено(Объект.PickUpFromCity) Или  Не ЗначениеЗаполнено(Объект.DeliverToCity) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Проверьте пожалуйста город отправки и прибытия");
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("ДокументСсылка.Trip"));
	МассивТипов.Добавить(Тип("ДокументСсылка.TripNonLawsonCompanies"));
	
	ТаблицаПоTrips = Новый ТаблицаЗначений;
	ТаблицаПоTrips.Колонки.Добавить("Trip", Новый ОписаниеТипов(МассивТипов));
	ТаблицаПоTrips.Колонки.Добавить("ServiceProvider", Новый ОписаниеТипов("СправочникСсылка.ServiceProviders"));
	ТаблицаПоTrips.Колонки.Добавить("MOT", Новый ОписаниеТипов("СправочникСсылка.MOTs"));
	//ТаблицаПоTrips.Колонки.Добавить("Sum", Новый ОписаниеТипов("Число"));
	//ТаблицаПоTrips.Колонки.Добавить("TonneKilometers", Новый ОписаниеТипов("Число"));
	ТаблицаПоTrips.Колонки.Добавить("Milage", Новый ОписаниеТипов("Число"));
	ТаблицаПоTrips.Колонки.Добавить("PickUpFromCountry", Новый ОписаниеТипов("СправочникСсылка.CountriesOfProcessLevels"));
	ТаблицаПоTrips.Колонки.Добавить("PickUpFromCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
	ТаблицаПоTrips.Колонки.Добавить("DeliverToCountry", Новый ОписаниеТипов("СправочникСсылка.CountriesOfProcessLevels"));
	ТаблицаПоTrips.Колонки.Добавить("DeliverToCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
	ТаблицаПоTrips.Колонки.Добавить("SumPerTonneKillometer", Новый ОписаниеТипов("Число"));
	ТаблицаПоTrips.Колонки.Добавить("SumPerKG", Новый ОписаниеТипов("Число"));
	ТаблицаПоTrips.Колонки.Добавить("TotalActualDuration", Новый ОписаниеТипов("Число"));
	
	
	ДанныеПоДокументуTripNonLawson = ПолучитьДанныеNonLawson(ОбъемныйВесТекЛинии);
	
	//ДанныеПоДокументуTrip = ПолучитьДанныеTrip(ОбъемныйВесТекЛинии);
	
	РезультатВыборки.Очистить();
	Элементы.РезультатДеревоEquipment.Видимость = Ложь;
	//Если ДанныеПоДокументуTripNonLawson <> Неопределено И ДанныеПоДокументуTrip <> Неопределено Тогда
	Если ДанныеПоДокументуTripNonLawson <> Неопределено Тогда
		
		//ДополнитьТаблицу(ДанныеПоДокументуTrip, ТаблицаПоTrips);
		ДополнитьТаблицу(ДанныеПоДокументуTripNonLawson, ТаблицаПоTrips);
		
		КонечнаяТаблица = Новый ТаблицаЗначений;
		КонечнаяТаблица.Колонки.Добавить("PickUpFromCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
		КонечнаяТаблица.Колонки.Добавить("DeliverToCity", Новый ОписаниеТипов("СправочникСсылка.Cities"));
		КонечнаяТаблица.Колонки.Добавить("Sum", Новый ОписаниеТипов("Число"));
		КонечнаяТаблица.Колонки.Добавить("MOT", Новый ОписаниеТипов("СправочникСсылка.MOTs"));
		КонечнаяТаблица.Колонки.Добавить("ServiceProvider", Новый ОписаниеТипов("СправочникСсылка.ServiceProviders"));
		КонечнаяТаблица.Колонки.Добавить("TotalActualDuration", Новый ОписаниеТипов("Строка"));
		КонечнаяТаблица.Колонки.Добавить("Equipment", Новый ОписаниеТипов("СправочникСсылка.Equipments"));
		
		ТаблицаПоTrips.Свернуть("Trip, SumPerTonneKillometer, SumPerKG, ServiceProvider, MOT, Milage, TotalActualDuration");
		
		MOTs = ТаблицаПоTrips.Скопировать();
		MOTs.Свернуть("MOT");
		
		КолВоЦиклов = 0;
		КоличествоServiceProviders = 3;
		Для Каждого СтрокаMOT Из MOTs Цикл
			Если НЕ СтрокаMOT.MOT = Справочники.MOTs.AIR И НЕ СтрокаMOT.MOT = Справочники.MOTs.COURIER И НЕ СтрокаMOT.MOT = Справочники.MOTs.НайтиПоКоду("TRUCK") Тогда
				Продолжить;
			КонецЕсли;
			Отбор = Новый Структура();
			Отбор.Вставить("MOT", СтрокаMOT.MOT);
			
			ТаблицаПоMOT = ТаблицаПоTrips.Скопировать(Отбор);
			Если СтрокаMOT.MOT = Справочники.MOTs.AIR Тогда
				ТаблицаПоMOT.Сортировать("SumPerKG Возр");
			Иначе
				ТаблицаПоMOT.Сортировать("SumPerTonneKillometer Возр");
			КонецЕсли;
			
			КолВоЦиклов = 0;
			МассивSP = Новый Массив;
			МассивTrips = Новый Массив;
			Для Каждого Элемент Из ТаблицаПоMOT Цикл
				Если Элемент.SumPerKG = 0 ИЛИ Элемент.SumPerTonneKillometer = 0 Тогда
					Продолжить
				КонецЕсли;
				Если МассивSP.Найти(Элемент.ServiceProvider) = Неопределено И КоличествоServiceProviders > КолВоЦиклов
					И МассивTrips.Найти(Элемент.Trip) = Неопределено Тогда
					КолВоЦиклов = КолВоЦиклов + 1;
					СтрокаТаблицы = КонечнаяТаблица.Добавить();
					СтрокаТаблицы.PickUpFromCity = Объект.PickUpFromCity;
					СтрокаТаблицы.DeliverToCity = Объект.DeliverToCity;
					СтрокаТаблицы.MOT = СтрокаMOT.MOT;
					СтрокаТаблицы.ServiceProvider = Элемент.ServiceProvider;
					СтрокаТаблицы.TotalActualDuration = ПолучитьПредставлениеDuration(Элемент.TotalActualDuration);
					Если СтрокаMOT.MOT = Справочники.MOTs.AIR Тогда
						СтрокаТаблицы.Sum = ПересчитатьВалюту(Элемент.SumPerKG * ОбъемныйВесТекЛинии);
					Иначе
						СтрокаТаблицы.Sum = ПересчитатьВалюту(Элемент.SumPerTonneKillometer * (ОбъемныйВесТекЛинии / 1000) * Элемент.Milage);
					КонецЕсли;
					Если КолВоЦиклов = 3 Тогда
						ПовторялсяТрижды = ПроверитьКолВоПодрядчиков(Элемент.ServiceProvider, КонечнаяТаблица);
						Если ПовторялсяТрижды Тогда
							МассивSP.Добавить(Элемент.ServiceProvider);
							КоличествоServiceProviders = 4;
						КонецЕсли;
					КонецЕсли;
					МассивTrips.Добавить(Элемент.Trip);
					
				Иначе
					Продолжить
				КонецЕсли;
				
			КонецЦикла;
		КонецЦикла;
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	ДанныеЗапроса.PickUpFromCity,
		               |	ДанныеЗапроса.DeliverToCity,
		               |	ДанныеЗапроса.Sum,
		               |	ДанныеЗапроса.MOT,
		               |	ДанныеЗапроса.ServiceProvider,
		               |	ДанныеЗапроса.TotalActualDuration,
		               |	ДанныеЗапроса.Equipment
		               |ПОМЕСТИТЬ ДанныеТЗ
		               |ИЗ
		               |	&ДанныеЗапросаТаблица КАК ДанныеЗапроса
		               |;
		               |
		               |////////////////////////////////////////////////////////////////////////////////
		               |ВЫБРАТЬ
		               |	ДанныеТЗ.Sum КАК Sum,
		               |	ДанныеТЗ.ServiceProvider КАК ServiceProvider,
		               |	ДанныеТЗ.MOT КАК MOT,
		               |	ДанныеТЗ.TotalActualDuration КАК Days,
		               |	ДанныеТЗ.Equipment
		               |ИЗ
		               |	ДанныеТЗ КАК ДанныеТЗ
		               |ИТОГИ ПО
		               |	MOT";
		Запрос.УстановитьПараметр("ДанныеЗапросаТаблица", КонечнаяТаблица);
		
		//Дерево = РеквизитФормыВЗначение("РезультатДерево");
		Дерево = Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
		ЗначениеВРеквизитФормы(Дерево, "РезультатДерево");
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОчиститьДеревоЗнач()
	тДерево = РеквизитФормыВЗначение("РезультатДерево");
	тДерево.Строки.Очистить();
	ЗначениеВРеквизитФормы(тДерево, "РезультатДерево");
	//АктивнаяСтрока = 1;
КонецПроцедуры


&НаКлиенте
Процедура PickUpFromCityПриИзменении(Элемент)
	ОчиститьДеревоЗнач();
	ТаблицаГрузовыхМест.Очистить();
КонецПроцедуры


&НаКлиенте
Процедура DeliverToCityПриИзменении(Элемент)
	ОчиститьДеревоЗнач();
	ТаблицаГрузовыхМест.Очистить();
КонецПроцедуры


&НаКлиенте
Процедура ТаблицаГрузовыхМестПриИзменении(Элемент)
	
	ПосчитатьОбъем();
	ОчиститьДеревоЗнач();
	
КонецПроцедуры

&НаСервере
Процедура ПосчитатьОбъем()
	
	Объем = 0;
	Вес = 0;
	Для Каждого Строка Из ТаблицаГрузовыхМест Цикл
		Объем = Объем + (Строка.Length/ 100) * (Строка.Width/100) * (Строка.Height/100) * Строка.Num;
		Вес = Вес + Строка.Вес * Строка.Num;
	КонецЦикла;
	ОбъемОтправки = Объем;
	ВесОтправки = Вес;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьПредставлениеDuration(Знач Duration)
	
	Дней = Цел(Duration/86400);
	Duration = Duration - Дней*86400;
	
	Если Duration > 0 Тогда
		Дней = Дней + 1;
	КонецЕсли;
	
	Возврат СокрЛП(Дней) + " days/дней";
	
КонецФункции

Функция ПроверитьКолВоПодрядчиков(SP, Таблица);
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ДанныеЗапроса.PickUpFromCity,
	|	ДанныеЗапроса.DeliverToCity,
	|	ДанныеЗапроса.Sum,
	|	ДанныеЗапроса.MOT,
	|	ДанныеЗапроса.ServiceProvider,
	|	ДанныеЗапроса.TotalActualDuration
	|ПОМЕСТИТЬ ДанныеТЗ
	|ИЗ
	|	&ДанныеЗапросаТаблица КАК ДанныеЗапроса
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеТЗ.ServiceProvider,
	|	СУММА(1) КАК КолВо
	|ИЗ
	|	ДанныеТЗ КАК ДанныеТЗ
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеТЗ.ServiceProvider";
	Запрос.УстановитьПараметр("ДанныеЗапросаТаблица", Таблица);
	Запрос.УстановитьПараметр("ServiceProvider", SP);
	
	Результат = Запрос.Выполнить().Выбрать();
	Результат.Следующий();
	Если Результат.КолВо = 3 Тогда
		Возврат Истина;
	Иначе 
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура РасчитатьСумму(Команда)
	
	ОбъемныйВес = 0;
	
	Для Каждого СтрокаТЧ Из ТаблицаГрузовыхМест Цикл
		ОбъемныйВес = ОбъемныйВес + ?(((СтрокаТЧ.Length/ 100) * (СтрокаТЧ.Width/100) * (СтрокаТЧ.Height/100) * СтрокаТЧ.Num * 167) < СтрокаТЧ.Вес * СтрокаТЧ.Num, СтрокаТЧ.Вес * СтрокаТЧ.Num, ((СтрокаТЧ.Length/ 100 * СтрокаТЧ.Width/ 100 * СтрокаТЧ.Height/ 100)  * СтрокаТЧ.Num * 167));
	КонецЦикла;
	
	Если ОбъемныйВес <> 0 Тогда
		ПолучитьСуммыПеревозок(ОбъемныйВес);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Currency = Справочники.Валюты.НайтиПоКоду("840");
КонецПроцедуры

&НаСервере
Функция ПересчитатьВалюту(Сумма)
	
	СurrencyUSD = Справочники.Валюты.НайтиПоКоду("840");
	СтруктураСurrencyUSD = ОбщегоНазначения.ПолучитьКурсВалюты(СurrencyUSD, ТекущаяДата());
	СтруктураСurrency = ОбщегоНазначения.ПолучитьКурсВалюты(Currency, ТекущаяДата());
	
	СуммаВВалюте = ОбщегоНазначения.ПересчитатьИзВалютыВВалюту(
	Сумма, СurrencyUSD, Currency, 
	СтруктураСurrencyUSD.Курс, СтруктураСurrency.Курс, СтруктураСurrencyUSD.Кратность, СтруктураСurrency.Кратность);
	
	Возврат СуммаВВалюте;
	
КонецФункции

&НаКлиенте
Процедура СборнаяОтправкаПриИзменении(Элемент)
	ОчиститьДеревоЗнач();
	Если СборнаяОтправка Тогда
		ОтдельнаяОтправка = Ложь;
		//Элементы.РезультатСборная.Видимость = Истина;
		//Элементы.Currency.Видимость = Истина;
		//Элементы.РезультатОтдельная.Видимость = Ложь;
		Элементы.ТаблицаГрузовыхМест.Видимость = Истина;
		Элементы.РезультатДеревоРасчитатьСумму.Видимость = Истина;
		Элементы.РасчитатьПоДанным.Видимость = Ложь;
		Элементы.ОтборыParcel.Видимость = Истина;
		Элементы.Объем.Видимость = Истина;
		Элементы.ОтборыОтдельнаяОтправка.Видимость = Ложь;
		Элементы.РезультатRentals.Видимость = Ложь;
	Иначе
		ОтдельнаяОтправка = Истина;
		//Элементы.РезультатСборная.Видимость = Ложь;
		//Элементы.Currency.Видимость = Ложь;
		//Элементы.РезультатОтдельная.Видимость = Истина;
		Элементы.ТаблицаГрузовыхМест.Видимость = Ложь;
		Элементы.РезультатДеревоРасчитатьСумму.Видимость = Ложь;
		Элементы.РасчитатьПоДанным.Видимость = Истина;
		Элементы.ОтборыParcel.Видимость = Ложь;
		Элементы.Объем.Видимость = Ложь;
		Элементы.ОтборыОтдельнаяОтправка.Видимость = Истина;
		Элементы.РезультатRentals.Видимость = Истина;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОтдельнаяОтправкаПриИзменении(Элемент)
	ОчиститьДеревоЗнач();
	Если ОтдельнаяОтправка Тогда
		СборнаяОтправка = Ложь;
		//Элементы.РезультатСборная.Видимость = Ложь;
		//Элементы.Currency.Видимость = Ложь;
		//Элементы.РезультатОтдельная.Видимость = Истина;
		Элементы.ТаблицаГрузовыхМест.Видимость = Ложь;
		Элементы.РезультатДеревоРасчитатьСумму.Видимость = Ложь;
		Элементы.РасчитатьПоДанным.Видимость = Истина;
		Элементы.ОтборыParcel.Видимость = Ложь;
		Элементы.Объем.Видимость = Ложь;
		Элементы.ОтборыОтдельнаяОтправка.Видимость = Истина;
		Элементы.РезультатRentals.Видимость = Истина;
	Иначе
		СборнаяОтправка = Истина;
		//Элементы.РезультатСборная.Видимость = Истина;
		//Элементы.Currency.Видимость = Истина;
		//Элементы.РезультатОтдельная.Видимость = Ложь;
		Элементы.ТаблицаГрузовыхМест.Видимость = Истина;
		Элементы.РезультатДеревоРасчитатьСумму.Видимость = Истина;
		Элементы.РасчитатьПоДанным.Видимость = Ложь;
		Элементы.ОтборыParcel.Видимость = Истина;
		Элементы.Объем.Видимость = Истина;
		Элементы.ОтборыОтдельнаяОтправка.Видимость = Ложь;
		Элементы.РезультатRentals.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПолучитьСуммыRentals()
	
	РезультатRentals.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	RentalTrucksCostsSumsRentalTrucks.Trip КАК Trip,
	|	RentalTrucksCostsSumsRentalTrucks.Cost КАК Cost,
	|	RentalTrucksCostsSumsRentalTrucks.Milage КАК Milage,
	|	RentalTrucksCostsSumsRentalTrucks.Weight КАК Weight,
	|	RentalTrucksCostsSumsRentalTrucks.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
	|	RentalTrucksCostsSumsRentalTrucks.TransportRequest.DeliverTo КАК DeliverTo,
	|	RentalTrucksCostsSumsRentalTrucks.Trip.ServiceProvider КАК ServiceProvider,
	|	RentalTrucksCostsSumsRentalTrucks.Trip.MOT КАК MOT,
	|	RentalTrucksCostsSumsRentalTrucks.Trip.Equipment КАК Equipment,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА RentalTrucksCostsSumsRentalTrucks.Milage = 0
	|					ИЛИ RentalTrucksCostsSumsRentalTrucks.Weight = 0
	|				ТОГДА 0
	|			ИНАЧЕ RentalTrucksCostsSumsRentalTrucks.Cost / (RentalTrucksCostsSumsRentalTrucks.Weight * RentalTrucksCostsSumsRentalTrucks.Milage / 1000)
	|		КОНЕЦ КАК ЧИСЛО(12, 2)) КАК SumPerTonneKillometer
	|ИЗ
	|	Документ.RentalTrucksCostsSums.RentalTrucks КАК RentalTrucksCostsSumsRentalTrucks
	|ГДЕ
	|	RentalTrucksCostsSumsRentalTrucks.Ссылка.Проведен
	|	И ВЫБОР
	|			КОГДА RentalTrucksCostsSumsRentalTrucks.Milage = 0
	|					ИЛИ RentalTrucksCostsSumsRentalTrucks.Weight = 0
	|				ТОГДА 0
	|			ИНАЧЕ RentalTrucksCostsSumsRentalTrucks.Cost / (RentalTrucksCostsSumsRentalTrucks.Weight * RentalTrucksCostsSumsRentalTrucks.Milage / 1000)
	|		КОНЕЦ <> 0
	|	И RentalTrucksCostsSumsRentalTrucks.TransportRequest.PickUpWarehouse.RCACountry = &PickUpRCACountry
	|	И RentalTrucksCostsSumsRentalTrucks.TransportRequest.PickUpWarehouse.City = &PickUpCity
	|	И RentalTrucksCostsSumsRentalTrucks.TransportRequest.DeliverTo.RCACountry = &DeliverToRCACountry
	|	И RentalTrucksCostsSumsRentalTrucks.TransportRequest.DeliverTo.City = &DeliverToCity
	|	И RentalTrucksCostsSumsRentalTrucks.Ссылка.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|  // ДопОтборы";
	
	Запрос.УстановитьПараметр("DeliverToCity", Объект.DeliverToCity);
	Запрос.УстановитьПараметр("DeliverToRCACountry", Объект.DeliverToCountry);
	Запрос.УстановитьПараметр("PickUpCity", Объект.PickUpFromCity);
	Запрос.УстановитьПараметр("PickUpRCACountry", Объект.PickUpFromCountry);
	Запрос.УстановитьПараметр("ДатаНачала", ДобавитьМесяц(ТекущаяДата(),-12));
	Запрос.УстановитьПараметр("ДатаОкончания", ТекущаяДата());
	
	ДопОтборы = "";
	
	Если ЗначениеЗаполнено(Объект.MOT) Тогда
		
		ДопОтборы = ДопОтборы + "
		|	И RentalTrucksCostsSumsRentalTrucks.Trip.MOT = &MOT";
		Запрос.УстановитьПараметр("MOT", Объект.MOT);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Equipment) Тогда
		
		ДопОтборы = ДопОтборы + "
		|	И RentalTrucksCostsSumsRentalTrucks.Trip.Equipment = &Equipment";
		Запрос.УстановитьПараметр("Equipment", Объект.Equipment);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДопОтборы) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "// ДопОтборы", ДопОтборы);
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	РезультатЗапроса.Свернуть("Trip, SumPerTonneKillometer, ServiceProvider, MOT, Milage");
		
	MOTs = РезультатЗапроса.Скопировать();
	MOTs.Свернуть("MOT");
	
	КолВоЦиклов = 0;
	КоличествоServiceProviders = 3;
	Для Каждого СтрокаMOT Из MOTs Цикл
		Если НЕ СтрокаMOT.MOT = Справочники.MOTs.AIR И НЕ СтрокаMOT.MOT = Справочники.MOTs.COURIER И НЕ СтрокаMOT.MOT = Справочники.MOTs.НайтиПоКоду("TRUCK") Тогда
			Продолжить;
		КонецЕсли;
		Отбор = Новый Структура();
		Отбор.Вставить("MOT", СтрокаMOT.MOT);
		
		ТаблицаПоMOT = РезультатЗапроса.Скопировать(Отбор);
		ТаблицаПоMOT.Сортировать("SumPerTonneKillometer Возр");
		
		КолВоЦиклов = 0;
		МассивSP = Новый Массив;
		МассивTrips = Новый Массив;
		Для Каждого Элемент Из ТаблицаПоMOT Цикл
			Если Элемент.SumPerTonneKillometer = 0 Тогда
				Продолжить
			КонецЕсли;
			Если МассивTrips.Найти(Элемент.Trip) = Неопределено И МассивSP.Найти(Элемент.ServiceProvider) = Неопределено И КолВоЦиклов < 4 Тогда
				
				КолВоЦиклов = КолВоЦиклов + 1;
				СтрокаТаблицы = РезультатRentals.Добавить();
				СтрокаТаблицы.MOT = СтрокаMOT.MOT;
				СтрокаТаблицы.ServiceProvider = Элемент.ServiceProvider;
				СтрокаТаблицы.SumPerTonneKillometer = ПересчитатьВалюту(Элемент.SumPerTonneKillometer);
				
				МассивSP.Добавить(Элемент.ServiceProvider);
				
				МассивTrips.Добавить(Элемент.Trip);
				
			Иначе
				Продолжить
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура PickUpFromCountryНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь; 	
	ДанныеВыбора = ПолучитьСписокCountries(Объект.DeliverToCountry);
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСписокCountries(Country)
	
	СписокCountries = Новый СписокЗначений;
	CountryAZ = ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.AZ");
	CountryTM = ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.TM");
	
	Если Country = CountryAZ ИЛИ Country = CountryTM Тогда 
		
		СписокCountries.Добавить(Country);
		
	Иначе
		
		Если Не ЗначениеЗаполнено(Объект.PickUpFromCountry) И Не ЗначениеЗаполнено(Объект.DeliverToCountry) Тогда
			СписокCountries.Добавить(CountryAZ);
			СписокCountries.Добавить(CountryTM);
		КонецЕсли;
		
		СписокCountries.Добавить(ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.RU"));
		СписокCountries.Добавить(ПредопределенноеЗначение("Справочник.CountriesOfProcessLevels.KZ"));
		
	КонецЕсли;

	Возврат СписокCountries;
	
КонецФункции

&НаКлиенте
Процедура PickUpFromCountryАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = ПолучитьСписокCountries(Объект.DeliverToCountry);
	
КонецПроцедуры

&НаКлиенте
Процедура PickUpFromCountryОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = ПолучитьСписокCountries(Объект.DeliverToCountry);
	
КонецПроцедуры

&НаКлиенте
Процедура DeliverToCountryАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = ПолучитьСписокCountries(Объект.PickUpFromCountry);
	
КонецПроцедуры

&НаКлиенте
Процедура DeliverToCountryОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = ПолучитьСписокCountries(Объект.PickUpFromCountry);

КонецПроцедуры

&НаКлиенте
Процедура DeliverToCountryНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь; 	
	ДанныеВыбора = ПолучитьСписокCountries(Объект.PickUpFromCountry);
	
КонецПроцедуры


